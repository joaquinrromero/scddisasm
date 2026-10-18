/* Headless libretro harness (Genesis Plus GX core). Usage: h ROM FRAMES [scenario]
   env: SNAPS=120,330  -> OUT/s_<n>.ppm + OUT/r_<n>.bin (68k work RAM) at those frames
        HASHEVERY=250  -> prints "H <frame> <hash>" every N frames
        OUT=dir  CORE=path/to/genesis_plus_gx_libretro.so
   scenario 1 = hold RIGHT and press jump periodically. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <dlfcn.h>
struct gi{const char*p;const void*d;size_t s;const char*m;};
static uint32_t fb[512*512];static unsigned W,H;static int fmt=0,frame=0,scen=0;
static int env(unsigned c,void*d){if(c==10){fmt=*(int*)d;return 1;}return 0;}
static void vid(const void*d,unsigned w,unsigned h,size_t p){if(!d)return;W=w;H=h;
 for(unsigned y=0;y<h;y++)for(unsigned x=0;x<w;x++){uint32_t o;
  if(fmt==2){uint16_t q=((uint16_t*)((char*)d+y*p))[x];o=((q>>11)<<3)<<16|(((q>>5)&63)<<2)<<8|((q&31)<<3);}
  else o=((uint32_t*)((char*)d+y*p))[x]; fb[y*w+x]=o;}}
static void as(int16_t l,int16_t r){} static size_t asb(const int16_t*d,size_t n){return n;} static void poll(void){}
static int16_t inp(unsigned a,unsigned b,unsigned c,unsigned d){if(!scen||a!=0||b!=1)return 0;
 if(d==7)return (frame/240)%5!=4; if(d==0||d==8)return (frame%90)<20; if(d==3)return frame>200&&frame<204; return 0;}
static void dump(const char*dir,int n){char f[256];snprintf(f,256,"%s/s_%d.ppm",dir,n);FILE*o=fopen(f,"wb");
 fprintf(o,"P6\n%u %u\n255\n",W,H);for(unsigned i=0;i<W*H;i++){fputc(fb[i]>>16,o);fputc(fb[i]>>8,o);fputc(fb[i],o);}fclose(o);}
int main(int c,char**v){const char*core=getenv("CORE")?getenv("CORE"):"./gpgx/genesis_plus_gx_libretro.so";
 const char*out=getenv("OUT")?getenv("OUT"):".";void*h=dlopen(core,RTLD_NOW);if(!h){puts(dlerror());return 1;}
 void(*se)(void*)=dlsym(h,"retro_set_environment"),(*sv)(void*)=dlsym(h,"retro_set_video_refresh"),
 (*sa)(void*)=dlsym(h,"retro_set_audio_sample"),(*sab)(void*)=dlsym(h,"retro_set_audio_sample_batch"),
 (*sp)(void*)=dlsym(h,"retro_set_input_poll"),(*si)(void*)=dlsym(h,"retro_set_input_state"),(*init)(void)=dlsym(h,"retro_init"),(*run)(void)=dlsym(h,"retro_run");
 int(*load)(struct gi*)=dlsym(h,"retro_load_game");void*(*mem)(unsigned)=dlsym(h,"retro_get_memory_data");
 se(env);sv(vid);sa(as);sab(asb);sp(poll);si(inp);init();
 FILE*f=fopen(v[1],"rb");if(!f){puts("no rom");return 1;}fseek(f,0,2);size_t n=ftell(f);rewind(f);void*b=malloc(n);fread(b,1,n,f);
 struct gi g={v[1],b,n,0};if(!load(&g)){puts("load fail");return 1;}
 int N=atoi(v[2]);if(c>3)scen=atoi(v[3]);int he=getenv("HASHEVERY")?atoi(getenv("HASHEVERY")):0;
 int snaps[64],ns=0;if(getenv("SNAPS")){char*s=strdup(getenv("SNAPS"));for(char*t=strtok(s,",");t&&ns<64;t=strtok(0,","))snaps[ns++]=atoi(t);}
 uint8_t*ram=mem(2);uint8_t*vram=mem(3);unsigned*pcp=mem(4);int pcs=getenv("PCSAMPLES")?atoi(getenv("PCSAMPLES")):0;
 for(int i=1;i<=N;i++){frame=i;run();
  if(he&&i%he==0){uint64_t hh=1469598103934665603ULL;for(unsigned k=0;k<W*H;k++){hh^=fb[k];hh*=1099511628211ULL;}printf("H %d %016llx\n",i,(unsigned long long)hh);}
  if(pcs&&i>N-pcs){unsigned*q=mem(4);printf("P %u\n",*q);}
  for(int k=0;k<ns;k++)if(snaps[k]==i){dump(out,i);char fn[256];snprintf(fn,256,"%s/r_%d.bin",out,i);FILE*r=fopen(fn,"wb");fwrite(ram,1,65536,r);fclose(r);if(vram){snprintf(fn,256,"%s/v_%d.bin",out,i);r=fopen(fn,"wb");fwrite(vram,1,65536,r);fclose(r);}}}
 return 0;}
