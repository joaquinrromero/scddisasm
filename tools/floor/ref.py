import re, numpy as np
from scdgfx import *
import os
SUB=os.path.join(os.path.dirname(os.path.abspath(__file__)),"..","..","src","Special Stage","Sub.asm")
def s16(v): v&=0xFFFF; return v-0x10000 if v&0x8000 else v
def s32(v): v&=0xFFFFFFFF; return v-(1<<32) if v&0x80000000 else v
def muls(a,b): return s16(a)*s16(b)
def divs(dividend,divisor):
    dd=s32(dividend); dv=s16(divisor)
    q=int(abs(dd)//abs(dv)); 
    if (dd<0)!=(dv<0): q=-q
    if -32768<=q<=32767: return q&0xFFFF
    return dd&0xFFFF            # overflow: register unchanged
# sine table straight from the disassembly
def load_sine():
    L=open(SUB,encoding="latin-1").read().split("\n"); i=next(k for k,l in enumerate(L) if l.startswith("SineTable:"))
    vals=[]; 
    for l in L[i+1:]:
        m=re.match(r'\s+dc\.w\s+(.*)',l)
        if not m: break
        vals+= [int(x.strip().lstrip('$'),16) for x in m.group(1).split(';')[0].split(',')]
    return vals
SINE=load_sine()
def get_sine(a):
    a&=0x1FF; d4=a
    if a&0x80: d4=(~d4)&0xFFFF
    d4&=0x7F
    v=SINE[d4]
    if a&0x100: v=-v
    return v
def get_cos(a): return get_sine((a+0x80)&0xFFFF)
def trace_table(camx,camy,camz,pitch,yaw,fov=0x80,center=-0x40,height=96):
    sp=get_sine(pitch); cp=get_cos(pitch); ys=get_sine(yaw); yc=get_cos(yaw)
    d0=s16(camx<<3); d1=s16(camy<<3)
    pcYs=s16(muls(cp,ys)>>5); pcYc=s16(muls(cp,yc)>>5)
    t=muls(fov,sp); psYsFOV=s32(muls(t,ys)>>5)
    t=muls(fov,sp); psYcFOV=s32(muls(t,yc)>>5)
    pcFOV=s32(muls(fov,cp))
    a1=s32(muls(-128,yc)<<3); a2=s32(muls(-128,ys)<<3); a3=s32(muls(127,yc)<<3); a4=s32(muls(127,ys)<<3)
    d4=s32(muls(sp,ys)>>5); cX=s16(muls(s16(fov+center),d4)>>8)
    d4=s32(muls(sp,yc)>>5); cY=s16(muls(s16(fov+center),d4)>>8)
    tab=[(0,s16(0xFFF8),0,0)]*3
    d2=-3
    for _ in range(height-3):
        d3=s32((muls(d2,sp)+pcFOV)>>5)
        if d3==0: d3=1
        def edge(base,sign_pc,pc,psfov,sub_psfov,add_c, cam, centre_op):
            d4=base
            d5=muls(pc,d2)
            d4 = d4-d5 if sign_pc<0 else d4+d5
            d4 = d4+psfov if not sub_psfov else d4-psfov
            d4=s32(d4)>>8
            d4=muls(d4,camz)
            d4=divs(d4,d3)
            return d4
        xs=edge(a1,-1,pcYs,psYsFOV,False,0,d0,0); xs=s16(xs+d0-cX)
        ys_=edge(a2,+1,pcYc,psYcFOV,True,0,d1,0); ys_=s16(ys_+d1+cY)
        dx=edge(a3,-1,pcYs,psYsFOV,False,0,d0,0); dx=s16(dx+d0-cX-xs)
        dy=edge(a4,+1,pcYc,psYcFOV,True,0,d1,0); dy=s16(dy+d1+cY-ys_)
        tab.append((xs,ys_,dx,dy)); d2=s16(d2-1)
    return tab
def decode_stage(n):
    stamps,smap,types=load_stage(n)
    nst=len(stamps)//512
    # unpack each stamp to 32x32 uint8 (cells column-major, tiles row-major 4bpp)
    S=np.zeros((nst+1,32,32),np.uint8)
    for i in range(nst):
        b=np.frombuffer(stamps[i*512:(i+1)*512],np.uint8)
        for cx in range(4):
            for cy in range(4):
                cell=b[(cx*4+cy)*32:(cx*4+cy+1)*32].reshape(8,4)
                px=np.empty((8,8),np.uint8); px[:,0::2]=cell>>4; px[:,1::2]=cell&15
                S[i+1,cy*8:cy*8+8,cx*8:cx*8+8]=px
    M=np.frombuffer(smap,">u2").reshape(128,128)
    return S,M
def stamp_pixel_xform(u,v,flags):
    # u,v = coords in the output stamp (arrays); returns coords in the stored stamp
    hf=(flags>>15)&1; rot=(flags>>13)&3
    u=np.where(hf==1,31-u,u)
    su=np.select([rot==0,rot==1,rot==2,rot==3],[u,v,31-u,31-v])
    sv=np.select([rot==0,rot==1,rot==2,rot==3],[v,31-u,31-v,u])
    return su,sv
def render(S,M,tab,w=256):
    h=len(tab); img=np.zeros((h,w),np.uint8)
    i=np.arange(w)
    for r,(sx,sy,dx,dy) in enumerate(tab):
        X=(sx*256+i*dx)>>11; Y=(sy*256+i*dy)>>11
        ok=(X>=0)&(X<4096)&(Y>=0)&(Y<4096)
        Xc=np.clip(X,0,4095); Yc=np.clip(Y,0,4095)
        raw=M[Yc>>5,Xc>>5].astype(np.int32)
        sid=((raw&0x7FF)>>2)
        su,sv=stamp_pixel_xform(Xc&31,Yc&31,raw)
        valid=ok&(sid>0)&(sid<S.shape[0])
        px=S[np.clip(sid,0,S.shape[0]-1),sv,su]
        img[r]=np.where(valid,px,0)
    return img
def palette(n):
    p=open(ROOT+"Stage %d/Palette.bin"%n,"rb").read()
    cols=[]
    for i in range(0,len(p),2):
        v=(p[i]<<8)|p[i+1]; cols.append((((v>>1)&7)*36,((v>>5)&7)*36,((v>>9)&7)*36))
    return cols
