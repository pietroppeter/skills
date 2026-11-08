// Screenshots old/new/inline/good.html in a folder at 390px, blocking CDN stylesheets and cdn.jsdelivr.net/gh scripts the way a claude.ai artifact does (Google Fonts allowed).
const {chromium}=require('playwright'); const dir=process.argv[2];
(async()=>{const b=await chromium.launch();
for (const n of ['old','new','inline','good']){
 const p=await b.newPage({viewport:{width:390,height:560},deviceScaleFactor:2});
 await p.route('**/*', r=>{const u=r.request().url(); if(u.startsWith('file:')||u.startsWith('data:')||/fonts\.(googleapis|gstatic)\.com/.test(u)) return r.continue();
   if(/cdn\.jsdelivr\.net\/gh\//.test(u)) return r.abort(); if(r.request().resourceType()==='stylesheet') return r.abort(); return r.continue();});
 await p.goto('file://'+dir+'/'+n+'.html'); await p.waitForTimeout(700);
 await p.screenshot({path:dir+'/'+n+'.png'}); await p.close();}
await b.close();})();
