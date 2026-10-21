import pickle,json,struct,collections,re,sys,os
sys.path.insert(0,'/home/claude/work/unified/tools/rounds'); os.environ['CCZ']='/home/claude/work/mdport/src/Level/'
import rlib
CR={}
rows=pickle.load(open('/tmp/objrows.pkl','rb')); used=pickle.load(open('/tmp/used.pkl','rb'))
nul=lambda t: len(t)<=2
# names: pristine PPZ index comments
names={}
t=open('/home/claude/work/unified/src/Level/Palmtree Panic/Object Index (Act 1 Present).asm',errors='replace').read()
for m in re.finditer(r'dc\.l\s+(\w+)\s*;\s*([0-9A-F]{2})\s*-\s*(.*)',t): names[int(m.group(2),16)]=(m.group(1),m.group(3).strip())
ops_abs={0x11FC,0x13FC}
ops_new={0x12BC,0x14BC,0x16BC,0x18BC,0x1ABC,0x1CBC,0x137C,0x157C,0x177C,0x197C,0x1B7C,0x1D7C}   # move.b #id,(aN) / 0(aN)
ops_self={0x10BC,0x117C}
created=collections.defaultdict(lambda: collections.defaultdict(set)); res=collections.defaultdict(list)
# generic names from the rounds' own index labels
lab=collections.defaultdict(collections.Counter)
for r in sorted(rows):
    m=json.load(open(f'/tmp/addrmap_{r}.json')); d=open(f'/home/claude/work/mdport/tools/{r}__.MMD','rb').read()
    fos=m['FindObjSlot']; end=m.get('LevelChunks',0x210000)-0x200000
    call=struct.pack('>HI',0x4EB9,fos)
    p=0x100; ids=set()
    while True:
        p=d.find(call,p,end)
        if p<0: break
        if p%2==0:
            for q in range(p+6,min(p+6+48,end),2):
                w=struct.unpack('>H',d[q:q+2])[0]
                if w in ops_new:
                    v=struct.unpack('>H',d[q+2:q+4])[0]
                    if w>=0x137C and struct.unpack('>H',d[q+4:q+6])[0]!=0: continue
                    if 1<=v<=0x60: ids.add(v)
        p+=2
    for q in range(0x100,end-8,2):
        w=struct.unpack('>H',d[q:q+2])[0]
        if w in ops_new|ops_self:
            v=struct.unpack('>H',d[q+2:q+4])[0]
            if w in (0x137C,0x157C,0x177C,0x197C,0x1B7C,0x1D7C,0x117C) and struct.unpack('>H',d[q+4:q+6])[0]!=0: continue
            if 1<=v<=0x60: ids.add(v)
        elif w in ops_abs:
            v=struct.unpack('>H',d[q+2:q+4])[0]
            a=struct.unpack('>I' if w==0x13FC else '>H',d[q+4:q+8] if w==0x13FC else d[q+4:q+6])[0]
            if w==0x11FC: a|=0xFFFF0000 if a&0x8000 else 0
            if 0xFFFFD000<=a<0xFFFFE000 and (a-0xFFFFD000)%0x40==0 and 1<=v<=0x60: ids.add(v)
    for q in range(0x100,end-4,2):                    # morph: move.b #id,(a0)
        w=struct.unpack('>H',d[q:q+2])[0]
        if w in ops_self:
            v=struct.unpack('>H',d[q+2:q+4])[0]
            if w==0x117C and struct.unpack('>H',d[q+4:q+6])[0]!=0: continue
            if 1<=v<=0x60: ids.add(v)
    CR[r]=set(ids)
    for v in ids: created[v][r[1]].add(r[2:])
    o=m['ObjectIndex']-0x200000
    ptrs=[struct.unpack('>I',d[o+4*i:o+4*i+4])[0] for i in range(len(rows[r]))]
    inv={v:k for k,v in m.items()}
    for s,pt in enumerate(ptrs):
        n=inv.get(pt)
        if n and not rlib.AUTO.fullmatch(n): lab[s+1][n]+=1
    for s,tt in enumerate(rows[r]):
        if not nul(tt) and not used[r].get(s+1) and (s+1) not in ids: res[s+1].append(r)
out=['Implemented objects that NO layout places and that no code creates (spawn via FindObjSlot+move.b #id / morph move.b #id,(a0)).','Objects created by other objects (explosion, points, lost ring, ...) are NOT listed. Names: PPZ index comment, else most common non-auto label.','']
for oid in sorted(res):
    rs=res[oid]; zs=collections.defaultdict(list)
    for r in rs: zs[r[1]].append(r[2:])
    nm=names.get(oid,(lab[oid].most_common(1)[0][0] if lab[oid] else f'Obj{oid:02X}', ''))
    out.append(f"ID {oid:02X}  {nm[0]} {('- '+nm[1]) if nm[1] else ''}  unused in {len(rs)} rounds: "+' '.join(f"Z{z}:{'/'.join(sorted(v))}" for z,v in sorted(zs.items())))
open('/home/claude/work/unified/tools/rounds/object_unused.txt','w').write('\n'.join(out)+'\n')
# also: created-only objects
co=[f"ID {v:02X} {names.get(v,('',''))[0]} created by code in {sum(len(x) for x in created[v].values())} rounds, placed in layouts of {sum(1 for r in used if used[r].get(v))}" for v in sorted(created)]
open('/home/claude/work/unified/tools/rounds/object_created.txt','w').write('\n'.join(co)+'\n')
print('\n'.join(out)[:5500])
pickle.dump(CR,open('/tmp/created.pkl','wb'))
