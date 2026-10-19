import struct, os
import os
REPO=os.path.abspath(os.path.join(os.path.dirname(__file__),"..",".."))
ROOT=os.path.join(REPO,"src","Special Stage","Data")+"/"
def kosdec(data):
    out=bytearray(); pos=0
    def rd16():
        nonlocal pos; v=data[pos]|(data[pos+1]<<8); pos+=2; return v
    desc=rd16(); bits=16
    def getbit():
        nonlocal desc,bits
        b=desc&1; desc>>=1; bits-=1
        if bits==0: desc=rd16(); bits=16
        return b
    while True:
        if getbit():
            out.append(data[pos]); pos+=1
        else:
            if getbit():
                lo=data[pos]; hi=data[pos+1]; pos+=2
                dist=((hi&0xF8)<<5)|lo; dist=dist-0x2000
                cnt=hi&7
                if cnt==0:
                    cnt=data[pos]; pos+=1
                    if cnt==0: break
                    if cnt==1: continue
                    cnt+=1
                else: cnt+=2
            else:
                cnt=((getbit()<<1)|getbit())+2
                dist=data[pos]-0x100; pos+=1
            for _ in range(cnt): out.append(out[len(out)+dist])
    return bytes(out)
def load_stage(n):
    d=ROOT+"Stage %d/"%n
    stamps=kosdec(open(d+"Stamps.kos","rb").read())
    smap=kosdec(open(d+"Stamp Map.kos","rb").read())
    types=open(d+"Stamp Types.bin","rb").read()
    return stamps,smap,types
if __name__=="__main__":
    for n in range(1,9):
        try:
            s,m,t=load_stage(n)
            vals=struct.unpack(">%dH"%(len(m)//2),m)
            ids=set((v&0x7FF)>>2 for v in vals); flags=set(v&0xF800 for v in vals)
            print("stage",n,"stamps bytes",len(s),"=",len(s)/512,"stamps; map bytes",len(m),"distinct ids",len(ids),"max id",max(ids),"flags",sorted(hex(f) for f in flags)[:6],"types",len(t))
        except Exception as e: print(n,"ERR",e)
