import os,re,pickle,sys,json,struct,collections,difflib
sys.path.insert(0,'.');os.environ['CCZ']='/home/claude/work/mdport/src/Level/'
import rlib
from capstone import Cs,CS_ARCH_M68K,CS_MODE_BIG_ENDIAN,CS_MODE_M68K_000
md=Cs(CS_ARCH_M68K,CS_MODE_BIG_ENDIAN|CS_MODE_M68K_000)
used=pickle.load(open('/tmp/used.pkl','rb'))
mn=lambda s:tuple(l.split()[0].split('.')[0] for l in s if l.split())
ref={};raw=[]
for r in sorted(used):
    p=rlib.round_path(r,generated=False)
    if not os.path.exists(p): continue
    by={x.name:x for x in rlib.routines(p)}
    if 'ObjectIndex' not in by: continue
    am=json.load(open(f'/tmp/addrmap_{r}.json')); addrs=sorted(set(am.values()))
    d=open(f'/home/claude/work/mdport/tools/{r}__.MMD','rb').read()
    tg=[m.group(1) for l in by['ObjectIndex'].lines for m in [re.match(r'\s*dc\.l\s+(\w+)',l)] if m]
    for s,n in enumerate(tg):
        x=by.get(n)
        if x is not None and len(x.sig)>3: ref.setdefault(mn(x.sig),[]).append((r,s+1,n))
        elif x is not None and 'rts' not in ' '.join(x.lines):
            m=re.search(r'_?([0-9A-F]{6})$',n); a=int(m.group(1),16) if m else am.get(n)
            nxt=[v for v in addrs if v>a]; e=min(nxt[0] if nxt else a+0x400,a+0x600)
            seq=[]
            for ins in md.disasm(d[a-0x200000:e-0x200000],a):
                seq.append(ins.mnemonic.split('.')[0])
                if ins.mnemonic in('rts','jmp','bra') and len(seq)>6 and ins.mnemonic!='bra': break
            raw.append((r,s+1,n,tuple(seq),used[r].get(s+1,0)))
print(len(ref),len(raw))
res=collections.defaultdict(list)
for r,i,n,seq,u in raw:
    best=(0,None)
    for k,v in ref.items():
        if abs(len(k)-len(seq))>0.5*max(len(k),len(seq)):continue
        sm=difflib.SequenceMatcher(None,seq,k,autojunk=False)
        if sm.real_quick_ratio()<.5: continue
        q=sm.ratio()
        if q>best[0]: best=(q,v[0])
    res[(i,n,len(seq))].append((r,u,best))
with open('raw_match.txt','w') as f:
    f.write('Raw (undecoded) object bodies: best mnemonic-sequence match to a decoded object (>=0.85 ~ same code)\n')
    for (i,n,l),v in sorted(res.items()):
        b=max(v,key=lambda t:t[2][0])[2]
        f.write(f"slot {i:02X} {n} ({l} ins) in {len(v)} rounds {v[0][0]}..; placed={'Y' if any(t[1] for t in v) else 'N'}; best {b[0]:.2f} -> {b[1]}\n")
print(open('raw_match.txt').read()[:6000])
