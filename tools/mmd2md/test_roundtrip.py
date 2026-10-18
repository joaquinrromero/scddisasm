import sys,os,shutil,time,re
sys.path.insert(0,'/home/claude/work/mdport/tools/mmd2md')
from mmdlib import pipeline as P, defs, levelstruct, emit as E
from mmdlib.trace import Analysis
repo='/home/claude/work/mdport'; src=repo+'/src'
ref=P.load_reference(repo,'/tmp/claude-0/ref')
dfs=defs.parse(src)
shared=P.shared_files(src)
for name in sys.argv[1:]:
    t=time.time()
    d=open(repo+'/tools/%s__.MMD'%name,'rb').read()
    ana=Analysis(d).run()
    names,blobs=P.build_names(d,ana,ref)
    S=levelstruct.detect(d,ana,names,dfs[0])
    o=E.Opts(); o.zone_dir='Level/_Test/'+name; o.act='Act 1 Test'; o.act_short='Act 1'; o.title=name; o.shared=shared
    shutil.rmtree(src+'/Level/_Test/'+name,ignore_errors=True)
    try:
      ok,raw,asm,files,info=P.roundtrip(repo,d,ana,names,blobs,S,dfs,o,'Level/_Test/%s/Act 1 Test.asm'%name)
    except Exception as e:
      import traceback; traceback.print_exc(); print(name,'CRASH',e); continue
    print(name,'OK' if ok else 'FAIL','raw',len(raw),'files',len(files),'segs',len(info['segments']),'%.0fs'%(time.time()-t))
