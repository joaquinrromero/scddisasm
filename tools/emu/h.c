/* tools/emu/h.c — minimal libretro host for Genesis Plus GX
 * Usage: ./h <core.so> <rom.md> <frames> [capture_frame...]
 *   Runs <frames> total frames, saves frame_NNNN.ppm + wram_NNNN.bin
 *   at every capture_frame listed, then exits.
 * Input: RIGHT held every frame; B pressed every 60 frames.
 * The video callback stores last RGB565 frame; saved as PPM (RGB888).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <dlfcn.h>
#include "libretro.h"

/* ---- libretro function pointers ---- */
static void (*p_retro_init)(void);
static void (*p_retro_deinit)(void);
static bool (*p_retro_load_game)(const struct retro_game_info *);
static void (*p_retro_run)(void);
static size_t (*p_retro_get_memory_size)(unsigned);
static void *(*p_retro_get_memory_data)(unsigned);
static void (*p_retro_set_environment)(retro_environment_t);
static void (*p_retro_set_video_refresh)(retro_video_refresh_t);
static void (*p_retro_set_audio_sample)(retro_audio_sample_t);
static void (*p_retro_set_audio_sample_batch)(retro_audio_sample_batch_t);
static void (*p_retro_set_input_poll)(retro_input_poll_t);
static void (*p_retro_set_input_state)(retro_input_state_t);

/* ---- log callback ---- */
#include <stdarg.h>
static void cb_log(enum retro_log_level level, const char *fmt, ...){
    (void)level;
    va_list ap; va_start(ap,fmt); vfprintf(stderr,fmt,ap); va_end(ap);
}

/* ---- frame buffer ---- */
static uint16_t fb[720*576];   /* max 720×576 at RGB565 */
static unsigned fb_w, fb_h, fb_pitch;
static int cur_frame;

static void cb_video(const void *d, unsigned w, unsigned h, size_t p) {
    fb_w=w; fb_h=h; fb_pitch=p;
    if(d && d != RETRO_HW_FRAME_BUFFER_VALID)
        memcpy(fb,d,h*(p));
}
static void cb_audio(int16_t l,int16_t r){(void)l;(void)r;}
static size_t cb_audio_batch(const int16_t *d,size_t f){(void)d;return f;}
static void cb_input_poll(void){}
static int16_t cb_input_state(unsigned port,unsigned dev,unsigned idx,unsigned id){
    if(port!=0) return 0;
    /* RIGHT always held */
    if(id==RETRO_DEVICE_ID_JOYPAD_RIGHT) return 1;
    /* B every 60 frames */
    if(id==RETRO_DEVICE_ID_JOYPAD_B && (cur_frame%60)<3) return 1;
    return 0;
}
static bool cb_env(unsigned cmd, void *d){
    switch(cmd){
        case RETRO_ENVIRONMENT_SET_PIXEL_FORMAT: {
            enum retro_pixel_format *f=d;
            *f=RETRO_PIXEL_FORMAT_RGB565; /* request RGB565 */
            return true;
        }
        case RETRO_ENVIRONMENT_GET_LOG_INTERFACE: {
            struct retro_log_callback *l=d;
            l->log=cb_log;
            return true;
        }
        default: return false;
    }
}

static void save_ppm(const char *path){
    FILE *f=fopen(path,"wb");
    if(!f){perror(path);return;}
    fprintf(f,"P6\n%u %u\n255\n",fb_w,fb_h);
    for(unsigned y=0;y<fb_h;y++){
        const uint16_t *row=(const uint16_t*)((const uint8_t*)fb + y*fb_pitch);
        for(unsigned x=0;x<fb_w;x++){
            uint16_t px=row[x];
            uint8_t r5=(px>>11)&0x1F, g6=(px>>5)&0x3F, b5=px&0x1F;
            uint8_t rgb[3]={(uint8_t)(r5<<3|(r5>>2)),(uint8_t)(g6<<2|(g6>>4)),(uint8_t)(b5<<3|(b5>>2))};
            fwrite(rgb,1,3,f);
        }
    }
    fclose(f);
    printf("  saved %s (%ux%u)\n",path,fb_w,fb_h);
}

static void save_wram(const char *path){
    void *d=p_retro_get_memory_data(RETRO_MEMORY_SYSTEM_RAM);
    size_t s=p_retro_get_memory_size(RETRO_MEMORY_SYSTEM_RAM);
    if(!d||!s){puts("  no WRAM"); return;}
    FILE *f=fopen(path,"wb");
    if(!f){perror(path);return;}
    fwrite(d,1,s,f);
    fclose(f);
    printf("  saved %s (%zu bytes)\n",path,(size_t)s);
}

#define LOAD(sym) p_##sym = dlsym(dl,#sym); if(!p_##sym){fprintf(stderr,"missing "#sym"\n");return 1;}

int main(int argc,char**argv){
    if(argc<4){fprintf(stderr,"Usage: h <core.so> <rom> <frames> [cap_frame...]\n");return 1;}
    const char *core_path=argv[1], *rom_path=argv[2];
    int total=atoi(argv[3]);

    /* capture frames list */
    int caps[64]; int ncap=0;
    for(int i=4;i<argc&&ncap<64;i++) caps[ncap++]=atoi(argv[i]);

    void *dl=dlopen(core_path,RTLD_LAZY);
    if(!dl){fprintf(stderr,"%s\n",dlerror());return 1;}
    LOAD(retro_init) LOAD(retro_deinit) LOAD(retro_load_game)
    LOAD(retro_run) LOAD(retro_get_memory_size) LOAD(retro_get_memory_data)
    LOAD(retro_set_environment) LOAD(retro_set_video_refresh)
    LOAD(retro_set_audio_sample) LOAD(retro_set_audio_sample_batch)
    LOAD(retro_set_input_poll) LOAD(retro_set_input_state)

    p_retro_set_environment(cb_env);
    p_retro_set_video_refresh(cb_video);
    p_retro_set_audio_sample(cb_audio);
    p_retro_set_audio_sample_batch(cb_audio_batch);
    p_retro_set_input_poll(cb_input_poll);
    p_retro_set_input_state(cb_input_state);
    p_retro_init();

    /* load ROM */
    FILE *rf=fopen(rom_path,"rb");
    if(!rf){perror(rom_path);return 1;}
    fseek(rf,0,SEEK_END); long rsz=ftell(rf); rewind(rf);
    void *rom_data=malloc(rsz);
    fread(rom_data,1,rsz,rf); fclose(rf);
    struct retro_game_info gi={rom_path,rom_data,(size_t)rsz,NULL};
    if(!p_retro_load_game(&gi)){fputs("load_game failed\n",stderr);return 1;}
    free(rom_data);
    printf("Loaded %s (%ld bytes), running %d frames\n",rom_path,rsz,total);

    /* run */
    for(cur_frame=0;cur_frame<total;cur_frame++){
        p_retro_run();
        /* check captures */
        for(int i=0;i<ncap;i++){
            if(caps[i]==cur_frame){
                char path[128];
                printf("Frame %d:\n",cur_frame);
                snprintf(path,sizeof(path),"frame_%04d.ppm",cur_frame);
                save_ppm(path);
                snprintf(path,sizeof(path),"wram_%04d.bin",cur_frame);
                save_wram(path);
            }
        }
        if(cur_frame%100==99) printf("  frame %d/%d\r",cur_frame+1,total);
    }
    printf("\nDone.\n");
    p_retro_deinit();
    dlclose(dl);
    return 0;
}
