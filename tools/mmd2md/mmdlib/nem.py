"""Nemesis decompressor used only to measure the exact compressed size of a blob (and validate it)."""


def nem_size(d, pos, maxtiles=0x1000):
    """Returns (compressed_size_in_bytes, tiles) or None when `d[pos:]` is not a plausible Nemesis stream."""
    n = len(d)
    if pos + 4 > n:
        return None
    hdr = (d[pos] << 8) | d[pos + 1]
    xor = hdr >> 15
    tiles = hdr & 0x7FFF
    if tiles == 0 or tiles > maxtiles:
        return None
    p = pos + 2
    table = {}
    pal = None
    while True:
        if p >= n:
            return None
        b = d[p]; p += 1
        if b == 0xFF:
            break
        if b & 0x80:
            pal = b & 0xF
            if p >= n:
                return None
            b = d[p]; p += 1
        if pal is None:
            return None
        ln = b & 0xF
        run = ((b >> 4) & 7) + 1
        if p >= n or ln == 0 or ln > 8:
            return None
        code = d[p]; p += 1
        if code >> ln:
            return None
        if (ln, code) in table:
            return None
        table[(ln, code)] = (run, pal)
    if not table:
        return None
    # bit stream
    bitpos = p * 8
    total = n * 8
    rows = tiles * 8
    nib = 0
    done = 0
    while done < rows:
        # read code
        code = 0; ln = 0
        while True:
            if bitpos >= total:
                return None
            code = (code << 1) | ((d[bitpos >> 3] >> (7 - (bitpos & 7))) & 1)
            bitpos += 1; ln += 1
            if ln == 6 and code == 0x3F:
                if bitpos + 7 > total:
                    return None
                v = 0
                for _ in range(7):
                    v = (v << 1) | ((d[bitpos >> 3] >> (7 - (bitpos & 7))) & 1); bitpos += 1
                run = (v >> 4) + 1
                break
            if (ln, code) in table:
                run = table[(ln, code)][0]
                break
            if ln > 8:
                return None
        nib += run
        while nib >= 8:
            nib -= 8; done += 1
            if done >= rows:
                break
    size = (bitpos + 7) // 8 - pos
    return size, tiles
