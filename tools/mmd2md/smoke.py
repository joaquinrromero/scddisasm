#!/usr/bin/env python3
"""Headless smoke test of a generated Mega Drive ROM (Unicorn M68K, no video/sound).

    python tools/mmd2md/smoke.py "out/md/R31A Collision Chaos Act 1 Present.bin" [frames]

Runs the ROM with V-INTs and random controller input and reports: error traps hit, CPU faults and writes
to the ROM (the Sega CD kept self-modifying data in RAM; on a cartridge those writes are silently lost).
"""
import collections, random, re, struct, sys
from unicorn import Uc, UcError, UC_ARCH_M68K, UC_MODE_BIG_ENDIAN, UC_PROT_ALL, UC_HOOK_CODE, UC_HOOK_MEM_WRITE, UC_HOOK_MEM_READ
from unicorn.m68k_const import UC_M68K_REG_A7, UC_M68K_REG_PC, UC_M68K_REG_SR

try:
    from unicorn.m68k_const import UC_CPU_M68K_M68000
    from unicorn.unicorn_const import UC_CPU_M68K_M68000 as _x  # noqa
except Exception:
    pass


def run(path, frames=300, seed=1, probes=None):
    rom = open(path, 'rb').read()
    random.seed(seed)
    uc = Uc(UC_ARCH_M68K, UC_MODE_BIG_ENDIAN)
    try:
        uc.ctl_set_cpu_model(1)
    except Exception:
        pass
    uc.mem_map(0, 0x400000, UC_PROT_ALL)
    uc.mem_write(0, rom[:0x400000])
    uc.mem_map(0xA00000, 0x200000, UC_PROT_ALL)
    uc.mem_map(0xC00000, 0x1000, UC_PROT_ALL)
    uc.mem_map(0xFF0000, 0x10000, UC_PROT_ALL)
    uc.mem_map(0xFFFF0000, 0x10000, UC_PROT_ALL)
    uc.mem_write(0xA10001, b'\xA0')
    for a in (0xA10003, 0xA10005, 0xA10009, 0xA1000B):
        uc.mem_write(a, b'\xFF')
    uc.mem_write(0xC00004, b'\x34\x08')
    entry, vint, trap = struct.unpack('>I', rom[4:8])[0], struct.unpack('>I', rom[0x78:0x7c])[0], struct.unpack('>I', rom[8:12])[0]
    rom_end = len(rom)
    writes = collections.Counter()
    st = {'trap': 0, 'v': False, 'ran': 0}
    hist = collections.deque(maxlen=300)

    def wr(uc_, access, addr, size, value, ud):
        if addr < rom_end:
            writes[(uc_.reg_read(UC_M68K_REG_PC), addr)] += 1
        elif 0xFF0000 <= addr < 0x1000000:
            v = (value & ((1 << 8 * size) - 1)).to_bytes(size, 'big'); uc_.mem_write(0xFFFF0000 + (addr & 0xFFFF), v)
        elif addr >= 0xFFFF0000:
            v = (value & ((1 << 8 * size) - 1)).to_bytes(size, 'big'); uc_.mem_write(0xFF0000 + (addr & 0xFFFF), v)

    def rd(uc_, access, addr, size, value, ud):
        if 0xA11100 <= addr <= 0xA11101:
            uc_.mem_write(0xA11100, b'\x00\x00')
    uc.hook_add(UC_HOOK_MEM_WRITE, wr)
    uc.hook_add(UC_HOOK_MEM_READ, rd)

    def code(uc_, addr, size, ud):
        hist.append(addr)
        if probes and addr in probes: probes[addr](uc_)
        if addr == trap:
            st['trap'] += 1; uc_.emu_stop()
        if uc_.mem_read(addr, 2) == b'\x4e\x73':          # RTE (manual: the model has no exception frames)
            a7 = uc_.reg_read(UC_M68K_REG_A7); sr, pc = struct.unpack('>HI', bytes(uc_.mem_read(a7, 6)))
            uc_.reg_write(UC_M68K_REG_A7, a7 + 6); uc_.reg_write(UC_M68K_REG_SR, sr); uc_.reg_write(UC_M68K_REG_PC, pc)
            st['v'] = False; uc_.emu_stop()
    uc.hook_add(UC_HOOK_CODE, code, begin=0, end=0x400000)
    uc.reg_write(UC_M68K_REG_A7, 0x00FFFFFE if struct.unpack('>I', rom[0:4])[0] == 0x01000000 else struct.unpack('>I', rom[0:4])[0])
    uc.reg_write(UC_M68K_REG_PC, entry); uc.reg_write(UC_M68K_REG_SR, 0x2700)
    f = 0; fault = None
    while f < frames and not st['trap']:
        try:
            uc.emu_start(uc.reg_read(UC_M68K_REG_PC), 0xFFFFFFFF, count=30000)
        except UcError as e:
            fault = '%s at $%X' % (e, uc.reg_read(UC_M68K_REG_PC)); break
        sr = uc.reg_read(UC_M68K_REG_SR)
        if not st['v'] and (sr >> 8) & 7 < 6 and uc.reg_read(UC_M68K_REG_PC) != vint and st['ran'] >= 1:
            st['v'] = True; st['ran'] = 0
            v = random.choice([0xFF, 0xF7, 0xF7, 0xBF, 0xB7, 0xFB, 0xFD, 0xF3])
            for x in (0xA10003, 0xA10005):
                uc.mem_write(x, bytes([v]))
            a7 = uc.reg_read(UC_M68K_REG_A7) - 6
            uc.mem_write(a7, struct.pack('>HI', sr, uc.reg_read(UC_M68K_REG_PC))); uc.reg_write(UC_M68K_REG_A7, a7)
            uc.reg_write(UC_M68K_REG_SR, (sr & 0xF8FF) | 0x2600); uc.reg_write(UC_M68K_REG_PC, vint)
            f += 1
        else:
            st['ran'] += 1
    a7 = uc.reg_read(UC_M68K_REG_A7)
    try:
        base = a7 if a7 >= 0xFFFF0000 else 0xFFFF0000 + (a7 & 0xFFFF)
        stack = list(struct.unpack('>16I', bytes(uc.mem_read(base, 64))))
    except Exception:
        stack = []
    return {'frames': f, 'trap': st['trap'], 'fault': fault, 'rom_writes': sorted(writes.items()),
            'pc': uc.reg_read(UC_M68K_REG_PC), 'hist': list(hist), 'stack': stack,
            'regs': {n: uc.reg_read(getattr(__import__('unicorn.m68k_const', fromlist=['x']), 'UC_M68K_REG_' + n))
                     for n in ('D0', 'D1', 'D2', 'A0', 'A1', 'A2', 'A5', 'A6', 'A7')}}


def load_syms(lst):
    syms = []
    for ln in open(lst, errors='ignore'):
        m = re.match(r'^([0-9A-F]{8}) +([A-Za-z_][\w.]*):', ln)
        if m:
            syms.append((int(m.group(1), 16), m.group(2)))
    syms.sort()
    return syms


def sym(syms, a):
    import bisect
    i = bisect.bisect_right(syms, (a, '\uffff')) - 1
    return '%s+%X' % (syms[i][1], a - syms[i][0]) if i >= 0 else '?'


if __name__ == '__main__':
    r = run(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 300)
    print('frames %d  error-traps %d  fault %s  ROM writes %d' % (r['frames'], r['trap'], r['fault'], len(r['rom_writes'])))
    for (pc, addr), n in r['rom_writes'][:20]:
        print('  write to $%06X from $%06X  x%d' % (addr, pc, n))
    if len(sys.argv) > 3 and (r['trap'] or r['fault']):
        syms = load_syms(sys.argv[3])
        print('PC $%X %s' % (r['pc'], sym(syms, r['pc'])), {k: '%X' % v for k, v in r['regs'].items()})
        print('stack:', ' '.join('%X(%s)' % (x, sym(syms, x)) for x in r['stack'] if 0x200 < x < len(open(sys.argv[1], 'rb').read())))
        h = []
        for a in r['hist']:
            s = sym(syms, a)
            if not h or h[-1] != s.split('+')[0]:
                h.append(s.split('+')[0])
        print('last routines:', ' > '.join(h[-40:]))
    sys.exit(1 if (r['trap'] or r['fault'] or r['rom_writes']) else 0)
