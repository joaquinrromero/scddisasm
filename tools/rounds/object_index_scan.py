import sys,os,re,struct,collections,glob
sys.path.insert(0,'/home/claude/work/unified/tools/rounds'); os.environ['CCZ']='/home/claude/work/mdport/src/Level/'
import rlib
from capstone import *
md=Cs(CS_ARCH_M68K,CS_MODE_BIG_ENDIAN|CS_MODE_M68K_000)
def fp(d,a,n=30):
    o=a-0x200000; out=[]
    for i in md.disasm(d[o:o+n*8],a,n):
        s=re.sub(r'\$[0-9a-f]{5,}','A',i.mnemonic+' '+i.op_str); out.append(s)
        if i.mnemonic in('rts','jmp','bra') : break
    return tuple(out)
rows={}
for f in sorted(glob.glob('/home/claude/work/mdport/tools/R*__.MMD')):
    r=os.path.basename(f)[:4]
    try: m=rlib.address_map(r,'/home/claude/work/mdport/src')
    except Exception as e: print(r,'fail',e); continue
    if 'ObjectIndex' not in m: print(r,'no idx'); continue
    d=open(f,'rb').read(); o=m['ObjectIndex']-0x200000; ptrs=[]
    while True:
        p=struct.unpack('>I',d[o+4*len(ptrs):o+4*len(ptrs)+4])[0]
        if not 0x200100<=p<0x240000: break
        ptrs.append(p)
    rows[r]=[fp(d,p) for p in ptrs]
import pickle; pickle.dump(rows,open('/tmp/objrows.pkl','wb'))
print(len(rows))
