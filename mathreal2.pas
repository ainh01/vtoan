program math;
{$R project.rc}
{$APPTYPE GUI}
uses sdl2,sdl2_image,sysutils,sdl2_ttf,sdl2_mixer;
label lEditMode, lmainmenu, lstartmenu, lluyentapmenu, lmemorymenu, l1learner, l2learner, ahAgain;
const
fh='hinh\';
fht='hethong\';
wChu=34;
wChull=22;
wChul=16;
hChu=110;

type numerical = record
cauhoi,ans:string;
end;
ptata=record
timeshow:qword;
tex:psdl_texture;
end;
tata=record
now,n:longint;
tnext:qword;
l:boolean;
pic:array of ptata;
end;
tidlist=array of longint;
tobj=record
rect:tsdl_rect;
mtex,tex,altex,mctex : PSDL_Texture;
mcki,alki,ki:string;
loai:string;
giaTri:longint;
an:string;
tt:string;
tontai:boolean;
dangan:boolean;
kieu:string;
hinh:string;
ata:tata;
end;

var
cuaSo: psdl_window;
render: psdl_renderer;
typescreen: uint32;
chuot,key2:psdl_event;
key:puint8;

bgt,bgtmainmenu,bgtstartmenu,bgtluyentapmenu,bgtm1learner,bgtm2learner: psdl_texture;



nDayChinh,iNguoi1,iNguoi2:longint;
dayChinh:array of numerical;
nobj:longint;
obj:array of tobj;
lobjon,objon,objdown,objup:longint;
objst:char;
objdowned:boolean;
drawTime:qword;

whereMouseX,whereMouseY:longint;
xobj:longint;

minnum,maxnum:longint;
soluong:longint;
soluongmin,soluongmax:longint;
cheDo:string;
soNguoi,mucDo:string;
pcong,ptru,pchia,pnhan:boolean;

idmainmenu,idluyentapmenu,idstartmenu,idm1learner,idm2learner:tidlist;
nidmainmenu,nidluyentapmenu,nidstartmenu,nidm1learner,nidm2learner:longint;

blocktime1,blocktime2:qword;

lengthSt:longint;

timeEnd:qword;
chuahien:boolean;
phut:qword;

fps,tpf: longint;
dd:longint;

//function
procedure deleteObj(id:longint; var idlist:tidlist; var nid:longint);
begin
obj[idlist[id]].tontai:=false;
for id:=id to nid-1 do idlist[id]:=idlist[id+1];
dec(nid);
setlength(idlist,nid+1);
end;

procedure deleteObj(li:string; gt:longint; var idlist:tidlist; var nid:longint);
var i:longint;
begin
i:=1;
while i<=nid do
begin
if (obj[idlist[i]].loai=li) and (obj[idlist[i]].giatri=gt) then begin deleteobj(i,idlist,nid); dec(i); end;
inc(i);
end;
end;

function intToPChar(i:longint):pansichar;
var k:string;
begin
str(i,k);
inttopchar:=stralloc(length(k)+1);
strpcopy(inttopchar,k);
end;


function stp(s:ansistring):pansichar;
begin
stp:=stralloc(length(s)+1);
strpcopy(stp,s);
end;

function tsts(i:uint32):string;
begin
if (i=sdl_window_shown) then exit('Mini') else
if (i=sdl_window_fullscreen) then exit('Full');
end;

function its(i:Longint):ansistring;
begin
str(i,its);
end;

function trong(a,b,c,d:longint;e,f:longint):boolean;
begin
if (a<=e) and (e<=c) and (b<=f) and (f<=d) then exit(true);
exit(false);
end;

procedure an(id:longint);
begin
obj[id].dangan:=true;
end;

procedure hien(id:longint);
begin
obj[id].dangan:=false;
end;


function trongTron(a,b,c,d:longint; tx,ty:longint):boolean;
var dos,go:real;
x,y,ta,tb:real;
begin
dos:=a+(c-a)/2;
go:=b+(d-b)/2;
ta:=c-dos;
tb:=d-go;
x:=tx-dos;
y:=ty-go;

if (((sqr(x)/sqr(ta))+(sqr(y)/sqr(tb)))<=1) then exit(true) else exit(false);


end;

function onmouse(x,y:longint; idlist:tidlist;nid:longint):longint;
var i:longint;
begin
for i:=nid downto 1 do
if (obj[idlist[i]].dangan=false) then
begin
if (obj[idlist[i]].hinh='tron') then begin
if trongtron(obj[idlist[i]].rect.x,obj[idlist[i]].rect.y,obj[idlist[i]].rect.x+obj[idlist[i]].rect.w,obj[idlist[i]].rect.y+obj[idlist[i]].rect.h,x,y)
then exit(idlist[i]);
end
else begin
if trong(obj[idlist[i]].rect.x,obj[idlist[i]].rect.y,obj[idlist[i]].rect.x+obj[idlist[i]].rect.w,obj[idlist[i]].rect.y+obj[idlist[i]].rect.h,x,y)
then exit(idlist[i]); end;
end;
exit(0);
end;

function ranfrom(n,x:longint):longint;
begin
ranfrom:=random(x-n+1);
exit(ranfrom+n);
end;

//end function

procedure applyCheDo;
begin
ndaychinh:=0;
inguoi1:=1;
inguoi2:=1;
case cheDo of
'luyentap': begin soluongmin:=2; soluongmax:=2; end;
'memory':  begin soluongmin:=3; soluongmax:=5; end;
end;
case mucDo of
'de': begin minnum:=1; maxnum:=9;  end;
'trungbinh': begin minnum:=10; maxnum:=99; end;
'kho': begin minnum:=50; maxnum:=150; end;
end;
end;

function theoMucDo:longint;
begin
if (mucdo='de') then exit(1) else
if (mucdo='trungbinh') then exit(2) else
exit(6);
end;

function ranloaiphep(cong,tru,nhan,chia:boolean):string;
var i:longint;
a:array[1..4] of string;
begin
i:=0;
if cong then begin inc(i); a[i]:='pcong'; end;
if tru then begin inc(i); a[i]:='ptru'; end;
if nhan then begin inc(i); a[i]:='pnhan'; end;
if chia then begin inc(i); a[i]:='pchia'; end;
i:=ranfrom(1,i);
exit(a[i]);
end;

function chuyenDau(i:string):string;
begin
case i of
'ptru': exit('-');
'pcong': exit('+');
end;
end;
procedure themcauhoi;
var
i,ans,chia1,chia2:longint;
loaiphepnow:string;
begin
inc(ndaychinh);
setlength(daychinh,ndaychinh+1);
soluong:=ranfrom(soluongmin,soluongmax);
loaiphepnow:=ranloaiphep(pcong,ptru,pnhan,pchia);
if (loaiphepnow='pchia') then begin
ans:=ranfrom(minnum,maxnum);
chia2:=ranfrom(minnum,maxnum);
chia1:=ans*chia2;
daychinh[ndaychinh].cauhoi:=its(chia1)+#32+'/'+#32+its(chia2);
daychinh[ndaychinh].ans:=its(ans);
end
else
if (loaiphepnow='pnhan') then
begin
chia1:=ranfrom(minnum,maxnum);
chia2:=ranfrom(minnum,maxnum);
ans:=chia1*chia2;
daychinh[ndaychinh].cauhoi:=its(chia1)+' x '+its(chia2);
daychinh[ndaychinh].ans:=its(ans);
end
else
begin
i:=1;
ans:=ranfrom(minnum,maxnum*theomucdo);
chia1:=ans;
daychinh[ndaychinh].cauhoi:='';
while i<soluong do
begin
inc(i);
chia2:=ranfrom(minnum,maxnum*theomucdo);
case loaiphepnow of
'pcong': dec(chia1,chia2);
'ptru':  inc(chia1,chia2);
end;
daychinh[ndaychinh].cauhoi:=chuyendau(loaiphepnow)+#32+its(chia2)+#32+daychinh[ndaychinh].cauhoi;
loaiphepnow:=ranloaiphep(pcong,ptru,false,false);
end;
if (chia1 < 0) then
begin
chia2:=ranfrom(minnum,maxnum*theomucdo);
ans:=ans+chia2-chia1;
chia1:=chia2;
end;
daychinh[ndaychinh].cauhoi:=its(chia1)+#32+daychinh[ndaychinh].cauhoi;
daychinh[ndaychinh].ans:=its(ans);
end;
end;


                                                 {2,3,5,7}
procedure viet(x,y,w,h,consosieudai:longint; var idlist:tidlist; var nid:longint; word:pansichar; style:longint; font:pansichar;size:longint; c1r,c1g,c1b,c2r,c2g,c2b:longint);
var vsur : PSDL_Surface;
vfont : PTTF_Font;
vC1, vC2 : TSDL_Color;
var i:uint32;
begin
w:=w*strlen(word);
lengthst:=w;
if (x=-1) then begin x:=(1366-lengthst) div 2; end;
x:=x div dd;
y:=y div dd;
w:=w div dd;
h:=h div dd;
vFont := TTF_OpenFont(font,size);
if (style=1) then ttf_setfontstyle(vfont,ttf_style_normal) else
begin
case style of
2: ttf_setfontstyle(vfont,TTF_STYLE_BOLD);
3: ttf_setfontstyle(vfont,TTF_STYLE_ITALIC);
5: ttf_setfontstyle(vfont,TTF_STYLE_UNDERLINE);
6: ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_ITALIC);
7: ttf_setfontstyle(vfont,TTF_STYLE_STRIKETHROUGH);
10:ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_UNDERLINE);
14:ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_STRIKETHROUGH);
15:ttf_setfontstyle(vfont,TTF_STYLE_ITALIC or TTF_STYLE_UNDERLINE);
21:ttf_setfontstyle(vfont,TTF_STYLE_ITALIC or TTF_STYLE_STRIKETHROUGH);
30:ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_ITALIC or TTF_STYLE_UNDERLINE);
35:ttf_setfontstyle(vfont,TTF_STYLE_UNDERLINE or TTF_STYLE_STRIKETHROUGH);
42:ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_ITALIC or TTF_STYLE_STRIKETHROUGH);
70:ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_UNDERLINE or TTF_STYLE_STRIKETHROUGH);
105: ttf_setfontstyle(vfont,TTF_STYLE_ITALIC or TTF_STYLE_UNDERLINE or TTF_STYLE_STRIKETHROUGH);
210: ttf_setfontstyle(vfont,TTF_STYLE_BOLD or TTF_STYLE_ITALIC or TTF_STYLE_UNDERLINE or TTF_STYLE_STRIKETHROUGH);
end;
end;
TTF_SetFontOutline(vFont, 4);
TTF_SetFontHinting(vFont, TTF_HINTING_NORMAL);
with vc1 do
begin
r:=c1r;
b:=c1b;
g:=c1g;
end;
with vc2 do
begin
r:=c2r;
g:=c2r;
b:=c2b;
end;
vsur:=TTF_Renderutf8_solid(vFont,word,  vc1);
i:=idlist[nid-consosieudai+1];
with obj[i] do
begin rect.x:=x;
rect.y:=y; rect.w:=w;
rect.h:=h; giaTri:=consosieudai;
tontai:=true;
loai:='chu';
tt:='';
ki:=font;
alki:=font;
altex:= sdl_createtexturefromsurface(render,vsur);
tex:= altex;
mtex:=tex;
mctex:=tex;
end;
end;


procedure addobj(x,y,w,h,g:longint;ant,kie,l,t,hd:ansistring;fi,fi2,fi3:pansichar; var idlist:tidlist; var nid:longint);
var sur:psdl_surface;
ft:text;
tmp:string;
begin
x:=x div dd;
y:=y div dd;
w:=w div dd;
h:=h div dd;
inc(nid);
if ((length(idlist)-1)<nid) then
setlength(idlist,nid+1);
inc(nobj);
if ((length(obj)-1)<nobj) then
setlength(obj,nobj+1);
idlist[nid]:=nobj;
with obj[nobj] do
begin rect.x:=x;
rect.y:=y; rect.w:=w;
rect.h:=h; giaTri:=g;
loai:=l;
an:=ant;
if (an='an') then dangan:=true else dangan:=false;
ki:=fi;
alki:=fi2;
hinh:=hd;
tontai:=true;
mcki:=fi3;
kieu:=kie;
tt:=t;
if (kie='ata') then
begin
assign(ft,stp(fht+fi));
reset(ft);
readln(ft,tmp);
if (tmp='lap') then ata.l:=true else ata.l:=false;
while not eof(ft) do
begin
inc(ata.n);
setlength(ata.pic,ata.n+1);
readln(ft,tmp);
ata.pic[ata.n].tex:=img_loadtexture(render,stp(fh+tmp));
readln(ft,ata.pic[ata.n].timeshow);
end;
close(ft);
ata.tnext:=0;
tex:=ata.pic[1].tex;
ata.now:=0;
end else
begin
mctex:= IMG_Loadtexture(render,stp(fh+fi3));
altex:= IMG_Loadtexture(render,stp(fh+fi2));
tex:= IMG_LoadTexture(render,stp(fh+fi));
mtex:=tex;
end;
end;
end;

procedure draw(idlist:tidlist;nid:longint);
var i:longint;
b:boolean;
begin
sdl_rendercopy(render,bgt,nil,nil);
i:=0;
while (i<nid) do
begin
inc(i);
with obj[idlist[i]] do
if (dangan=false) and (tontai=true) then
        begin
        b:=true;
        if (kieu='ata') then
                begin
                if (ata.tnext<=sdl_getticks) then
                        begin
                        if (ata.tnext=0) then ata.tnext:=sdl_getticks;
                        inc(ata.now);
                        if (ata.now>ata.n) and (ata.l) then ata.now:=1;
                        if (ata.now>ata.n) and (ata.l=false) then
                                begin b:=false; obj[idlist[i]].tontai:=false; ata.now:=0; ata.tnext:=0;
                                end;
                                if (ata.now<=ata.n) then
                                        begin
                                        tex:=ata.pic[ata.now].tex;
                                        mtex:=tex;
                                        mctex:=tex;
                                        altex:=tex;
                                        ata.tnext:=ata.pic[ata.now].timeshow+ata.tnext;
                                        end;
                        end;
                end;
                if (b) then sdl_rendercopy(render,tex,nil,@rect);
        end;
end;
sdl_renderpresent(render);
end;

procedure forceExit;
begin
sdl_destroywindow(cuaso);
sdl_destroyrenderer(render);
dispose(chuot);
dispose(key2);
sdl_quit;
halt(0);
end;

procedure forceExit(i:longint);
begin
sdl_destroywindow(cuaso);
sdl_destroyrenderer(render);
dispose(chuot);
dispose(key2);
sdl_quit;
end;

procedure loadAgain(fi:string);
var t:text;
var x,y,w,h,g:longint;
l,tt,hd:ansistring;
li,ali,aali,an,kie:ansistring;
begin
if (fileexists(fi)=false) then
begin
assign(t,fi);
rewrite(t);
close(t);
end;
assign(t,fi);
reset(t);
while not eof(t) do
begin
readln(t,x,y,w,h,g);
readln(t,an);
readln(t,kie);
readln(t,l);
readln(t,tt);
readln(t,hd);
readln(t,li);
readln(t,ali);
readln(t,aali);
if (fi=fht+'mainmenu.txt') then addObj(x,y,w,h,g,an,kie,l,tt,hd,stp(li),stp(ali),stp(aali),idmainmenu,nidmainmenu)
else if (fi=fht+'startmenu.txt') then addObj(x,y,w,h,g,an,kie,l,tt,hd,stp(li),stp(ali),stp(aali),idstartmenu,nidstartmenu)
else if (fi=fht+'luyentapmenu.txt') then addObj(x,y,w,h,g,an,kie,l,tt,hd,stp(li),stp(ali),stp(aali),idluyentapmenu,nidluyentapmenu)
else if (fi=fht+'m1learner.txt') then addObj(x,y,w,h,g,an,kie,l,tt,hd,stp(li),stp(ali),stp(aali),idm1learner,nidm1learner)
else if (fi=fht+'m2learner.txt') then addObj(x,y,w,h,g,an,kie,l,tt,hd,stp(li),stp(ali),stp(aali),idm2learner,nidm2learner);
end;
close(t);
end;

procedure taoManHinh;
var theT:text;
su:ansistring;
begin
if (fileexists(fht+'setting.txt')=false) then
begin
fps:=60;
tpf:=round(1000/fps);
dd:=1;
typescreen:=sdl_window_fullscreen;
assign(theT,fht+'setting.txt');
rewrite(theT);
writeln(theT,fps);
write(theT,'full');
close(theT);
end else
begin
su:='';
assign(theT,fht+'setting.txt');
reset(theT);
readln(theT,fps);
readln(theT,su);
if (su='full') then begin dd:=1; typescreen:=sdl_window_fullscreen end else
if (su='thuong') then begin dd:=2; typescreen:=sdl_window_shown; end;
close(theT);
end;
cuaso:=sdl_createwindow('Math',350,150,1366,768,typescreen); render:=sdl_createrenderer(cuaso,-1,0);
if (typescreen=sdl_window_shown) then sdl_setwindowsize(cuaso,683,384);
end;
procedure khoiDong;
begin
if (sdl_init(sdl_init_everything) <>0) then halt;
taomanhinh;
               {//}
nobj:=0;
bgt:=img_loadtexture(render,fh+'V.png');
draw(idmainmenu,0);
randomize;
nDayChinh:=0;
iNguoi1:=0;
iNguoi2:=0;
nidmainmenu:=0;
nidstartmenu:=0;
nidluyentapmenu:=0;
nidm1learner:=0;
nidm2learner:=0;
setlength(dayChinh,0);
nobj:=0;
setlength(obj,1);
new(chuot);
new(key);
new(key2);
lobjon:=0;
objon:=0;
objst:=#0;
drawTime:=0;
if TTF_Init = -1 then HALT;
loadagain(fht+'mainmenu.txt');
viet(200,200,wchu,hchu+40,1,idmainmenu,nidmainmenu,stp('FPS:  '+its(fps)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
viet(200,430,wchu,hchu+40,2,idmainmenu,nidmainmenu,stp('Screen:  '+tsts(typescreen)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
loadagain(fht+'startmenu.txt');
loadagain(fht+'luyentapmenu.txt');
loadagain(fht+'m1learner.txt');
nidm1learner:=nidm1learner+6;
setlength(obj,nobj+7);
nobj:=nobj+6;
setlength(idm1learner,nidm1learner+1);
idm1learner[nidm1learner-5]:=idm1learner[nidm1learner-6]+1;
idm1learner[nidm1learner-4]:=idm1learner[nidm1learner-5]+1;
idm1learner[nidm1learner-3]:=idm1learner[nidm1learner-4]+1;
idm1learner[nidm1learner-2]:=idm1learner[nidm1learner-3]+1;
idm1learner[nidm1learner-1]:=idm1learner[nidm1learner-2]+1;
idm1learner[nidm1learner]:=idm1learner[nidm1learner-1]+1;
with obj[idm1learner[nidm1learner-3]] do
begin kieu:='ata'; tontai:=false; rect.x:=530 div dd; dangan:=false; rect.y:=360 div dd; rect.w:=130 div dd; rect.h:=110 div dd;
ata.now:=0; ata.n:=3; ata.tnext:=0; ata.l:=false; setlength(ata.pic,4);
with ata.pic[1] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tick1.png');  end; with ata.pic[2] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tick2.png'); end; with ata.pic[3] do begin
timeshow:=290; tex:=img_loadtexture(render,fh+'tick3.png'); end; end;
with obj[idm1learner[nidm1learner-4]] do
begin kieu:='ata'; tontai:=false; rect.x:=530 div dd; dangan:=false; rect.y:=360 div dd; rect.w:=130 div dd; rect.h:=110 div dd;
ata.now:=0; ata.n:=3; ata.tnext:=0; ata.l:=false; setlength(ata.pic,4);
with ata.pic[1] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tet1.png');  end; with ata.pic[2] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tet2.png'); end; with ata.pic[3] do begin
timeshow:=290; tex:=img_loadtexture(render,fh+'tet3.png'); end; end;

loadagain(fht+'m2learner.txt');
nidm2learner:=nidm2learner+8;
setlength(obj,nobj+9);
nobj:=nobj+8;
setlength(idm2learner,nidm2learner+1);
idm2learner[nidm2learner-7]:=idm2learner[nidm2learner-8]+1;
idm2learner[nidm2learner-6]:=idm2learner[nidm2learner-7]+1;
idm2learner[nidm2learner-5]:=idm2learner[nidm2learner-6]+1;
idm2learner[nidm2learner-4]:=idm2learner[nidm2learner-5]+1;
idm2learner[nidm2learner-3]:=idm2learner[nidm2learner-4]+1;
idm2learner[nidm2learner-2]:=idm2learner[nidm2learner-3]+1;
idm2learner[nidm2learner-1]:=idm2learner[nidm2learner-2]+1;
idm2learner[nidm2learner]:=idm2learner[nidm2learner-1]+1;

with obj[idm2learner[nidm2learner-4]] do
begin kieu:='ata'; tontai:=false; rect.x:=330 div dd; dangan:=false; rect.y:=360 div dd; rect.w:=130 div dd; rect.h:=110 div dd;
ata.now:=0; ata.n:=3; ata.tnext:=0; ata.l:=false; setlength(ata.pic,4);
with ata.pic[1] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tick1.png');  end; with ata.pic[2] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tick2.png'); end; with ata.pic[3] do begin
timeshow:=290; tex:=img_loadtexture(render,fh+'tick3.png'); end; end;
with obj[idm2learner[nidm2learner-5]] do
begin kieu:='ata'; tontai:=false; rect.x:=330 div dd; dangan:=false; rect.y:=360 div dd; rect.w:=130 div dd; rect.h:=110 div dd;
ata.now:=0; ata.n:=3; ata.tnext:=0; ata.l:=false; setlength(ata.pic,4);
with ata.pic[1] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tet1.png');  end; with ata.pic[2] do begin
timeshow:=40; tex:=img_loadtexture(render,fh+'tet2.png'); end; with ata.pic[3] do begin
timeshow:=290; tex:=img_loadtexture(render,fh+'tet3.png'); end; end;
bgtmainmenu:=IMG_LoadTexture(render,fh+'wall.png');
bgtstartmenu:=IMG_LoadTexture(render,fh+'bgt.png');
bgtluyentapmenu:=IMG_LoadTexture(render,fh+'bgtlt.png');
bgtm1learner:=IMG_LoadTexture(render,fh+'nen1p.png');
bgtm2learner:=img_loadtexture(render,fh+'nen2p.png');
end;

function mainmenu():string;
var dsfps:longint;
dstypeScreen:uint32;
theT:text;
procedure hienslls(id,id2:longint;idlist:tidlist);
begin
for id:=id to id2 do hien(idlist[id]);
end;
procedure anslls(id,id2:longint;idlist:tidlist);
begin
for id:=id to id2 do an(idlist[id]);
end;
begin
dsfps:=fps;
dstypeScreen:=typescreen;
objdowned:=false;
drawTime:=0;
bgt:=bgtmainmenu;
objon:=0;
lobjon:=0;
objdown:=0;
objup:=0;
hienslls(2,nidmainmenu,idmainmenu);
anslls(4,nidmainmenu,idmainmenu);
while(sdl_pollevent(chuot)=1) do;
repeat
while(sdl_pollevent(chuot)=1) do
begin
        case chuot^.type_ of
        sdl_windowevent: if (typescreen=sdl_window_fullscreen) then forceexit;
        sdl_mousebuttondown : begin objdown:=onmouse(whereMousex,wheremousey,idmainmenu,nidmainmenu);
        if (objdown<>0) and (objdowned=false) then begin obj[objdown].tex:=obj[objdown].mctex; objdowned:=true; end;
        if (chuot^.button.button=sdl_button_middle) then obj[1].dangan:=not obj[1].dangan;
        end;
        sdl_mousebuttonup: begin objup:=onmouse(whereMousex,wheremousey,idmainmenu,nidmainmenu);
        objdowned:=false;
        obj[objdown].tex:=obj[objdown].mtex;
        obj[objup].tex:=obj[objup].altex;
        if (objdown=objup) and (objdown<>0) then if (obj[objdown].loai='nut') then
        begin obj[lobjon].tex:=obj[lobjon].mtex;
        case obj[objdown].tt of
        'caidat': begin viet(200,200,wchu,hchu+40,1,idmainmenu,nidmainmenu,stp('FPS:  '+its(dsfps)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
        viet(200,430,wchu,hchu+40,2,idmainmenu,nidmainmenu,stp('Screen:  '+tsts(dstypescreen)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
        hienslls(4,nidmainmenu,idmainmenu); end;
        'fps+': begin if (dsfps=30) then dsfps:=60 else inc(dsfps,60); if (dsfps>240) then dsfps:=30;
        viet(200,200,wchu,hchu+40,1,idmainmenu,nidmainmenu,stp('FPS:  '+its(dsfps)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
        end;
        'fps-': begin if (dsfps=60) then dsfps:=30 else dec(dsfps,60); if (dsfps<30) then dsfps:=240;
        viet(200,200,wchu,hchu+40,1,idmainmenu,nidmainmenu,stp('FPS:  '+its(dsfps)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
        end;
        'screen+', 'screen-': begin if (dstypescreen=sdl_window_shown) then dstypescreen:=sdl_window_fullscreen else dstypescreen:=sdl_window_shown;
        viet(200,430,wchu,hchu+40,2,idmainmenu,nidmainmenu,stp('Screen:  '+tsts(dstypescreen)),1,'VBAMASN.TTF',200,255,255,255,255,255,255);
        end;
        'ok': begin if (dsfps<>fps) or (dstypescreen<>typescreen) then begin {save} begin assign(thet,fht+'setting.txt'); rewrite(thet); writeln(thet,dsfps);
        if (dstypescreen=sdl_window_shown) then write(thet,'thuong') else write(thet,'full'); close(thet);  end; {save}
        fps:=dsfps;
        typescreen:=typescreen;
        if (dstypescreen<>typescreen) then begin forceexit(1); exit('ok'); end; end;
        anslls(4,nidmainmenu,idmainmenu);
        end;
        'dong': begin anslls(4,nidmainmenu,idmainmenu); dsfps:=fps;
        dstypeScreen:=typescreen; end;
        otherwise exit(obj[objdown].tt);
        end;
        end;
        end;
        sdl_mousemotion: Begin
        whereMousex:=chuot^.motion.x;
        whereMousey:=chuot^.motion.y;
        if (objdowned=false) then begin
        objon:=onmouse(whereMousex,wheremousey,idmainmenu,nidmainmenu);
        obj[lobjon].tex:=obj[lobjon].mtex;
        if (objon<>0) then begin lobjon:=objon;  obj[lobjon].tex:=obj[lobjon].altex; end;
        end;
        End;
        end;
end;
sdl_pumpevents();
key:=sdl_getkeyboardstate(nil);
if ((key[sdl_scancode_escape])=1) and (obj[idmainmenu[1]].dangan=false) then begin exit('exit'); end;
if (sdl_getticks>=drawTime) then begin draw(idmainmenu,nidmainmenu); inc(drawTime,tpf); end;
sdl_delay(1); until false;
end;

function startmenu():string;
begin
objdowned:=false;
drawTime:=0;
bgt:=bgtstartmenu;
objon:=0;
lobjon:=0;
objdown:=0;
objup:=0;
while(sdl_pollevent(chuot)=1) do;
repeat
while(sdl_pollevent(chuot)=1) do
begin
        case chuot^.type_ of
        sdl_windowevent: if (typescreen=sdl_window_fullscreen) then forceexit;
        sdl_mousebuttondown : begin objdown:=onmouse(whereMousex,wheremousey,idstartmenu,nidstartmenu);
        if (objdown<>0) and (objdowned=false) then begin obj[objdown].tex:=obj[objdown].mctex; objdowned:=true; end;
        end;
        sdl_mousebuttonup: begin objup:=onmouse(whereMousex,wheremousey,idstartmenu,nidstartmenu);
        objdowned:=false;
        obj[objdown].tex:=obj[objdown].mtex;
        obj[objup].tex:=obj[objup].altex;
        if (objdown=objup) and (objdown<>0) then begin if (obj[objdown].loai='nut') then begin obj[lobjon].tex:=obj[lobjon].mtex; exit(obj[objdown].tt); end;  end;
        end;
        sdl_mousemotion: Begin
        whereMousex:=chuot^.motion.x;
        whereMousey:=chuot^.motion.y;
        if (objdowned=false) then begin
        objon:=onmouse(whereMousex,wheremousey,idstartmenu,nidstartmenu);
        obj[lobjon].tex:=obj[lobjon].mtex;
        if (objon<>0) then begin lobjon:=objon;  obj[lobjon].tex:=obj[lobjon].altex; end;
        end;
        End;
        end;
end;
sdl_pumpevents();
key:=sdl_getkeyboardstate(nil);
if ((key[sdl_scancode_escape])=1) then begin exit('mainmenu'); end;
if (sdl_getticks>=drawTime) then begin draw(idstartmenu,nidstartmenu); inc(drawTime,tpf); end;
sdl_delay(1); until false;
end;

function luyentapmenu():string;
var bangphep:boolean;
xhien:qword;
function nophep:boolean;
begin
exit(not (pcong or ptru or pchia or pnhan));
end;
procedure anmd(a:string);
begin
case a of
'de': an(idluyentapmenu[20]);
'trungbinh': an(idluyentapmenu[21]);
'kho': an(idluyentapmenu[22]);
'pcong': an(idluyentapmenu[16]);
'ptru': an(idluyentapmenu[17]);
'pnhan': an(idluyentapmenu[18]);
'1': an(idluyentapmenu[23]);
'2': an(idluyentapmenu[24]);
'pchia': an(idluyentapmenu[19]);
end;
end;
procedure hnmd(a:string);
begin
case a of
'1': hien(idluyentapmenu[23]);
'2': hien(idluyentapmenu[24]);
'de': hien(idluyentapmenu[20]);
'trungbinh': hien(idluyentapmenu[21]);
'kho': hien(idluyentapmenu[22]);
'pcong': hien(idluyentapmenu[16]);
'ptru': hien(idluyentapmenu[17]);
'pnhan': hien(idluyentapmenu[18]);
'pchia': hien(idluyentapmenu[19]);
end;
end;
procedure hiensll(id,id2:longint;idlist:tidlist);
begin
if bangphep=true then begin
for id:=id to id2 do an(idlist[id]) end else begin
for id:=id to id2 do hien(idlist[id]);            end;
bangphep:=not bangphep;
end;
procedure hienslls(id,id2:longint;idlist:tidlist);
begin
for id:=id to id2 do hien(idlist[id]);
end;
procedure anslls(id,id2:longint;idlist:tidlist);
begin
for id:=id to id2 do an(idlist[id]);
end;
begin

objdowned:=false;
drawTime:=0;
soNguoi:='1';
mucDo:='de';
phut:=0;
xhien:=0;
bangphep:=true;
hiensll(10,15,idluyentapmenu);
pcong:=true;
hien(idluyentapmenu[16]);
anslls(17,19,idluyentapmenu);
hien(idluyentapmenu[20]);
anslls(21,22,idluyentapmenu);
hien(idluyentapmenu[23]);
an(idluyentapmenu[24]);
anslls(25,27,idluyentapmenu);
ptru:=false;
pchia:=false;
pnhan:=false;
bgt:=bgtluyentapmenu;
objon:=0;
lobjon:=0;
objdown:=0;
objup:=0;
while(sdl_pollevent(chuot)=1) do;
repeat
while(sdl_pollevent(chuot)=1) do
begin
        case chuot^.type_ of
        sdl_windowevent: if (typescreen=sdl_window_fullscreen) then forceexit;
        sdl_mousebuttondown : begin objdown:=onmouse(whereMousex,wheremousey,idluyentapmenu,nidluyentapmenu);
        if (objdown<>0) and (objdowned=false) then begin obj[objdown].tex:=obj[objdown].mctex; objdowned:=true;
        if (obj[objdown].tt='mlearner') then xhien:=sdl_getticks+600;
        end;
        end;
        sdl_mousebuttonup: begin objup:=onmouse(whereMousex,wheremousey,idluyentapmenu,nidluyentapmenu);
        objdowned:=false;
        obj[objdown].tex:=obj[objdown].mtex;
        obj[objup].tex:=obj[objup].altex;
        xhien:=0;
        if (obj[objdown].tt='mlearner') then case obj[objup].tt of
        '1phut':begin phut:=60000; obj[lobjon].tex:=obj[lobjon].mtex; exit(obj[objdown].tt); end;
        '2phut':begin phut:=120000; obj[lobjon].tex:=obj[lobjon].mtex; exit(obj[objdown].tt); end;
        '3phut':begin phut:=180000; obj[lobjon].tex:=obj[lobjon].mtex; exit(obj[objdown].tt); end;
        end;
        if (objdown=objup) and (objdown<>0) then begin if (obj[objdown].loai='nut') then
        begin
        case obj[objdown].tt of
        'de','trungbinh','kho': begin anmd(mucdo); hnmd(obj[objdown].tt); mucdo:=obj[objdown].tt;  end;
        'pcong': begin pcong:=not pcong; if (nophep) then pcong:=not pcong else begin if pcong then hnmd('pcong') else anmd('pcong'); end; end;
        'ptru': begin ptru:= not ptru; if (nophep) then ptru:=not ptru else begin if ptru then hnmd('ptru') else anmd('ptru'); end; end;
        'pchia': begin pchia:=not pchia; if (nophep) then pchia:=not pchia else begin if pchia then hnmd('pchia') else anmd('pchia'); end; end;
        'pnhan': begin pnhan:=not pnhan; if (nophep) then pnhan:=not pnhan else begin if pnhan then hnmd('pnhan') else anmd('pnhan'); end; end;
        'hien': hiensll(10,15,idluyentapmenu);
        'tonghop': begin pcong:=true; ptru:=true; pchia:=true; pnhan:=true; hnmd('pcong');
        hnmd('ptru');
        hnmd('pchia');
        hnmd('pnhan');
        end;
        '1': begin anmd('2'); songuoi:='1'; hnmd('1'); end;
        '2': begin anmd('1'); songuoi:='2'; hnmd('2'); end;
        otherwise begin obj[lobjon].tex:=obj[lobjon].mtex; exit(obj[objdown].tt); end;
        end;
        end;
        end;
        anslls(25,27,idluyentapmenu);
        end;
        sdl_mousemotion: Begin
        whereMousex:=chuot^.motion.x;
        whereMousey:=chuot^.motion.y;
        if (objdowned=false) then begin
        objon:=onmouse(whereMousex,wheremousey,idluyentapmenu,nidluyentapmenu);
        obj[lobjon].tex:=obj[lobjon].mtex;
        if (objon<>0) then begin lobjon:=objon;  obj[lobjon].tex:=obj[lobjon].altex; end;
        end;
        End;
        end;
end;
if (xhien<>0) and (xhien<=sdl_getticks) then begin xhien:=0; hienslls(25,27,idluyentapmenu); end;
sdl_pumpevents();
key:=sdl_getkeyboardstate(nil);
if ((key[sdl_scancode_escape])=1) then begin exit('startmenu'); end;
if (sdl_getticks>=drawTime) then begin draw(idluyentapmenu,nidluyentapmenu); inc(drawTime,tpf); end;
sdl_delay(1); until false;
end;

function m1learner():string;
var i1:longint;
c1,hci:char;
turnback:boolean;
timeToWait:qword;
st1:string;
banphim:boolean;
procedure hiensll(id,id2:longint;idlist:tidlist);
begin
if banphim=true then begin
for id:=id to id2 do an(idlist[id]) end else begin
for id:=id to id2 do hien(idlist[id]);   end;
banphim:=not banphim;
end;
begin
drawTime:=0;
bgt:= bgtm1learner;
timeend:=maxlongint*100; chuahien:=true;
banphim:=true;
hiensll(1,nidm1learner,idm1learner);
with obj[idm1learner[nidm1learner-6]] do
begin dangan:=true;
tontai:=false;
end;
if (phut<>0) then
begin
with obj[idm1learner[nidm1learner-6]] do
begin dangan:=false;
tontai:=true;
timetowait:=sdl_getticks+3100;
end;
while (timetowait>sdl_getticks) do
begin
if (sdl_getticks>=drawTime) then begin draw(idm1learner,nidm1learner); inc(drawTime,tpf); end;
end;
timeend:=sdl_getticks+phut; chuahien:=true
end;
phut:=0;
objdowned:=false;
banphim:=false;
hiensll(1,nidm1learner,idm1learner);
{nho an cai bang}
an(idm1learner[15]);
{so diem tren bang.an:=true;}
an(idm1learner[nidm1learner-5]);
obj[idm1learner[nidm1learner-5]].tontai:=true;
{nut tick.an:=true;}
obj[idm1learner[nidm1learner-2]].tontai:=false;
an(idm1learner[16]);
banphim:=true;
hiensll(3,14,idm1learner);
hci:=#0;
drawTime:=0;
bgt:= bgtm1learner;
objon:=0;
lobjon:=0;
objdown:=0;
objup:=0;
st1:='';
themcauhoi;
c1:=daychinh[1].ans[1];
i1:=1;
turnback:=false;
while(sdl_pollevent(chuot)=1) do;
viet(-1,200,wchu,hchu,1,idm1learner,nidm1learner,stp(daychinh[1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
repeat
while(sdl_pollevent(chuot)=1) do
begin
        case chuot^.type_ of
        sdl_windowevent: if (typescreen=sdl_window_fullscreen) then forceexit;
        sdl_mousebuttondown : begin objdown:=onmouse(whereMousex,wheremousey,idm1learner,nidm1learner);
        if (objdown<>0) and (objdowned=false) then begin obj[objdown].tex:=obj[objdown].mctex; objdowned:=true; end;
        end;
        sdl_mousebuttonup: begin objup:=onmouse(whereMousex,wheremousey,idm1learner,nidm1learner);
        objdowned:=false;
        obj[objdown].tex:=obj[objdown].mtex;
        obj[objup].tex:=obj[objup].altex;
        if (objdown=objup) and (objdown<>0) then begin if (obj[objdown].loai='nut') then
        case obj[objdown].tt of
        '0','1','2','3','4','5','6','7','8','9': if (blocktime1<=sdl_getticks) and ((chuahien=true) and (timeEnd>sdl_getticks)) then hci:=obj[objdown].tt[1];
        'hien': begin hiensll(3,14,idm1learner); end;
        'startmenu': if (chuahien) and (inguoi1>1) then
begin
chuahien:=false;
{hien bang}
hien(idm1learner[15]);
{hien so}
viet(520,320,wchu+40,hchu+70,6,idm1learner,nidm1learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm1learner[nidm1learner-5]);
{an diem}
an(idm1learner[nidm1learner-2]);
an(idm1learner[nidm1learner-1]);
an(idm1learner[nidm1learner]);
{hien tick xanh}
hien(idm1learner[16]);
end else exit(obj[objdown].tt);
        otherwise exit(obj[objdown].tt);
        end;
        end;
        end;
        sdl_mousemotion: Begin
        whereMousex:=chuot^.motion.x;
        whereMousey:=chuot^.motion.y;
        if (objdowned=false) then begin
        objon:=onmouse(whereMousex,wheremousey,idm1learner,nidm1learner);
        obj[lobjon].tex:=obj[lobjon].mtex;
        if (objon<>0) then begin lobjon:=objon;  obj[lobjon].tex:=obj[lobjon].altex; end;
        end;
        End;
        sdl_keyup: begin if (blocktime1<=sdl_getticks) and ((chuahien=false) or (timeEnd>sdl_getticks)) then
case chuot^.key.keysym.scancode of
sdl_scancode_1, sdl_scancode_kp_1:hci:='1';
sdl_scancode_2, sdl_scancode_kp_2:hci:='2';
sdl_scancode_3, sdl_scancode_kp_3:hci:='3';
sdl_scancode_4, sdl_scancode_kp_4:hci:='4';
sdl_scancode_5, sdl_scancode_kp_5:hci:='5';
sdl_scancode_6, sdl_scancode_kp_6:hci:='6';
sdl_scancode_7, sdl_scancode_kp_7:hci:='7';
sdl_scancode_8, sdl_scancode_kp_8:hci:='8';
sdl_scancode_9, sdl_scancode_kp_9:hci:='9';
sdl_scancode_0, sdl_scancode_kp_0:hci:='0';
end;
if (chuot^.key.keysym.scancode=sdl_scancode_escape) then exit('startmenu');
end;
end;
end;
{//}
if turnback and (blocktime1<=sdl_getticks) then begin viet(-1,200,wchu,hchu,1,idm1learner,nidm1learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
turnback:=false; end;
if (hci<>#0) then
begin
if (c1=hci) then
begin {dung}
inc(i1);
st1:=st1+hci;
if (i1>length(daychinh[inguoi1].ans)) then
        begin
        {dung toan bo}
        i1:=1;
        inc(inguoi1);
        if (inguoi1>=ndaychinh) then
        themcauhoi;
        c1:=daychinh[inguoi1].ans[1]; st1:='';
        obj[idm1learner[nidm1learner-3]].tontai:=true;
        obj[idm1learner[nidm1learner-3]].ata.now:=0;
        obj[idm1learner[nidm1learner-3]].ata.tnext:=0;
        obj[idm1learner[nidm1learner-4]].tontai:=false;
        obj[idm1learner[nidm1learner-4]].ata.now:=0;
        obj[idm1learner[nidm1learner-4]].ata.tnext:=0;
        viet(1030,70,wchu+10,hchu,3,idm1learner,nidm1learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',80,255,255,0,255,255,0);
        viet(-1,200,wchu,hchu,1,idm1learner,nidm1learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
        end else c1:=daychinh[inguoi1].ans[i1];
viet(500,400,wchu,hchu,2,idm1learner,nidm1learner,stp(st1),3,'VBAMASN.TTF',100,255,255,125,255,255,0);
end else
begin
i1:=1;
st1:='';
c1:=daychinh[inguoi1].ans[1];
obj[idm1learner[nidm1learner-1]].tontai:=false;
obj[idm1learner[nidm1learner-4]].tontai:=true;
        obj[idm1learner[nidm1learner-4]].ata.now:=0;
obj[idm1learner[nidm1learner-4]].ata.tnext:=0;
obj[idm1learner[nidm1learner-3]].tontai:=false;
obj[idm1learner[nidm1learner-3]].ata.now:=0;
obj[idm1learner[nidm1learner-3]].ata.tnext:=0;
blocktime1:=sdl_getticks+1500;
turnback:=true;
viet(-1,200,wchu,hchu,1,idm1learner,nidm1learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,241,3,10,255,255,255);
 {sai}
end;
hci:=#0;
end;
{//}
if (timeEnd<=sdl_getticks) and (chuahien) then
begin
chuahien:=false;
{hien bang}
hien(idm1learner[15]);
{hien so}
viet(520,320,wchu+40,hchu+70,6,idm1learner,nidm1learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm1learner[nidm1learner-5]);
{an diem}
an(idm1learner[nidm1learner-2]);
an(idm1learner[nidm1learner-1]);
an(idm1learner[nidm1learner]);
{hien tick xanh}
hien(idm1learner[16]);
end;
{///}
if (sdl_getticks>=drawTime) then begin draw(idm1learner,nidm1learner); inc(drawTime,tpf); end;
sdl_delay(1); until false;
end;

function m2learner():string;
var i1,i2,wchud:longint;
c1,hci,c2,hcii:char;
st1,st2:string;
turnback1,turnback2:boolean;
timetowait:qword;
banphim:boolean;
procedure anslls(id,id2:longint;idlist:tidlist);
begin
for id:=id to id2 do an(idlist[id]);
end;
procedure hiensll(id,id2:longint;idlist:tidlist);
begin
if banphim=true then begin
for id:=id to id2 do an(idlist[id]) end else begin
for id:=id to id2 do hien(idlist[id]);            end;
banphim:=not banphim;
end;
begin
drawTime:=0;
bgt:= bgtm2learner;
timeend:=maxlongint*100; chuahien:=true;
banphim:=true;
hiensll(1,nidm2learner,idm2learner);
{//}
with obj[idm2learner[nidm2learner-8]] do
begin dangan:=true;
tontai:=false;
end;
if (phut<>0) then
begin
with obj[idm2learner[nidm2learner-8]] do
begin dangan:=false;
tontai:=true;
timetowait:=sdl_getticks+3100;
end;
while (timetowait>sdl_getticks) do
begin
if (sdl_getticks>=drawTime) then begin draw(idm2learner,nidm2learner); inc(drawTime,tpf); end;
end;
timeend:=sdl_getticks+phut; chuahien:=true
end;
{//}
phut:=0;
objdowned:=false;
banphim:=false;
hiensll(1,nidm2learner,idm2learner);
anslls(15,21,idm2learner);
obj[idm2learner[19]].tontai:=false;
obj[idm2learner[19]].dangan:=false;
obj[idm2learner[20]].tontai:=false;
obj[idm2learner[20]].dangan:=false;
hci:=#0;
hcii:=#0;
drawTime:=0;
bgt:= bgtm2learner;
objon:=0;
lobjon:=0;
objdown:=0;
objup:=0;
st1:='';
st2:='';
if (chedo='luyentap') then wchud:=wchu else
if (chedo='memory') then wchud:=wchul;
themcauhoi;
c1:=daychinh[1].ans[1];
c2:=daychinh[1].ans[1];
i1:=1;
i2:=1;
turnback1:=false;
turnback2:=false;
obj[idm2learner[nidm2learner-1]].tontai:=false;
obj[idm2learner[nidm2learner-3]].tontai:=false;
an(idm2learner[nidm2learner-6]);
an(idm2learner[nidm2learner-7]);
while(sdl_pollevent(chuot)=1) do;
viet(2,200,wchud,hchu,1,idm2learner,nidm2learner,stp(daychinh[1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
viet(816,200,wchud,hchu,3,idm2learner,nidm2learner,stp(daychinh[1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
repeat
while(sdl_pollevent(chuot)=1) do
begin
        case chuot^.type_ of
        sdl_windowevent: if (typescreen=sdl_window_fullscreen) then forceexit;
        sdl_mousebuttondown : begin objdown:=onmouse(whereMousex,wheremousey,idm2learner,nidm2learner);
        if (objdown<>0) and (objdowned=false) then begin obj[objdown].tex:=obj[objdown].mctex; objdowned:=true; end;
        end;
        sdl_mousebuttonup: begin objup:=onmouse(whereMousex,wheremousey,idm2learner,nidm2learner);
        objdowned:=false;
        obj[objdown].tex:=obj[objdown].mtex;
        obj[objup].tex:=obj[objup].altex;
        if (objdown=objup) and (objdown<>0) then begin if (obj[objdown].loai='nut') then
        case obj[objdown].tt of
        '0','1','2','3','4','5','6','7','8','9': if (blocktime2<=sdl_getticks) and ((chuahien=true) and (timeEnd>sdl_getticks)) then hcii:=obj[objdown].tt[1];
        'hien': begin hiensll(3,14,idm2learner);  end;
        'startmenu': if (chuahien) and ((inguoi1>1) or (inguoi2>1)) then
begin
chuahien:=false;
begin
{hien bang}
hien(idm2learner[15]);
hien(idm2learner[16]);
{hien so}
viet(120,290,wchu+40,hchu+70,7,idm2learner,nidm2learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm2learner[nidm2learner-6]);
end;
begin
{hien bang}
hien(idm2learner[17]);
hien(idm2learner[18]);
{hien so}
viet(985,290,wchu+40,hchu+70,8,idm2learner,nidm2learner,stp(its(inguoi2-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm2learner[nidm2learner-7]);
end;
{an diem}
anslls(2,14,idm2learner);
an(idm2learner[nidm2learner-3]);
an(idm2learner[nidm2learner-2]);
an(idm2learner[nidm2learner-1]);
an(idm2learner[nidm2learner]);
end else exit(obj[objdown].tt);
        otherwise exit(obj[objdown].tt);
        end;
        end;
        end;
        sdl_mousemotion: Begin
        whereMousex:=chuot^.motion.x;
        whereMousey:=chuot^.motion.y;
        if (objdowned=false) then begin
        objon:=onmouse(whereMousex,wheremousey,idm2learner,nidm2learner);
        obj[lobjon].tex:=obj[lobjon].mtex;
        if (objon<>0) then begin lobjon:=objon;  obj[lobjon].tex:=obj[lobjon].altex; end;
        end;
        End;
        sdl_keyup: begin if (blocktime1<=sdl_getticks) and ((chuahien=false) or (timeEnd>sdl_getticks)) then
case chuot^.key.keysym.scancode of
sdl_scancode_1:hci:='1';
sdl_scancode_2:hci:='2';
sdl_scancode_3:hci:='3';
sdl_scancode_4:hci:='4';
sdl_scancode_5:hci:='5';
sdl_scancode_6:hci:='6';
sdl_scancode_7:hci:='7';
sdl_scancode_8:hci:='8';
sdl_scancode_9:hci:='9';
sdl_scancode_0:hci:='0';
end;
if (blocktime2<=sdl_getticks) and ((chuahien=false) or (timeEnd>sdl_getticks)) then
case chuot^.key.keysym.scancode of
sdl_scancode_kp_1:hcii:='1';
sdl_scancode_kp_2:hcii:='2';
sdl_scancode_kp_3:hcii:='3';
sdl_scancode_kp_4:hcii:='4';
sdl_scancode_kp_5:hcii:='5';
sdl_scancode_kp_6:hcii:='6';
sdl_scancode_kp_7:hcii:='7';
sdl_scancode_kp_8:hcii:='8';
sdl_scancode_kp_9:hcii:='9';
sdl_scancode_kp_0:hcii:='0';
end;
if (chuot^.key.keysym.scancode=sdl_scancode_escape) then exit('startmenu');
end;
end;
end;
{//}
if turnback1 and (blocktime1<=sdl_getticks) then begin viet(2,200,wchud,hchu,1,idm2learner,nidm2learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
turnback1:=false; end;
if (hci<>#0) then
begin
if (c1=hci) then
begin {dung}
inc(i1);
st1:=st1+hci;
if (i1>length(daychinh[inguoi1].ans)) then
        begin
        {dung toan bo}
        i1:=1;
        inc(inguoi1);
        if (inguoi1>=ndaychinh) then
        themcauhoi;
        c1:=daychinh[inguoi1].ans[1]; st1:='';
        obj[idm2learner[19]].tontai:=true;
        obj[idm2learner[19]].ata.now:=0;
        obj[idm2learner[19]].ata.tnext:=0;
        obj[idm2learner[20]].tontai:=false;
        obj[idm2learner[20]].ata.now:=0;
        obj[idm2learner[20]].ata.tnext:=0;
        viet(350,40,wchu+10,hchu,2,idm2learner,nidm2learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',80,255,40,40,255,255,0);
        obj[idm2learner[nidm2learner-1]].tontai:=true;
        viet(2,200,wchud,hchu,1,idm2learner,nidm2learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
        end else c1:=daychinh[inguoi1].ans[i1];
end else
begin
i1:=1;
st1:='';
c1:=daychinh[inguoi1].ans[1];
obj[idm2learner[20]].tontai:=true;
obj[idm2learner[20]].ata.now:=0;
obj[idm2learner[20]].ata.tnext:=0;
obj[idm2learner[19]].tontai:=false;
obj[idm2learner[19]].ata.now:=0;
obj[idm2learner[19]].ata.tnext:=0;
blocktime1:=sdl_getticks+1500;
turnback1:=true;
viet(2,200,wchud,hchu,1,idm2learner,nidm2learner,stp(daychinh[inguoi1].cauhoi+' = ___'),1,'VBAMASN.TTF',100,241,3,10,255,255,255);
 {sai}
end;
hci:=#0;
end;
if turnback2 and (blocktime2<=sdl_getticks) then begin viet(816,200,wchud,hchu,3,idm2learner,nidm2learner,stp(daychinh[inguoi2].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
turnback2:=false; end;
if (hcii<>#0) then
begin
if (c2=hcii) then
begin {dung}
inc(i2);
st2:=st2+hcii;
if (i2>length(daychinh[inguoi2].ans)) then
        begin
        {dung toan bo}
        i2:=1;
        inc(inguoi2);
        if (inguoi2>=ndaychinh) then
        themcauhoi;
        c2:=daychinh[inguoi2].ans[1]; st2:='';
        obj[idm2learner[19]].tontai:=true;
        obj[idm2learner[19]].ata.now:=0;
        obj[idm2learner[19]].ata.tnext:=0;
        obj[idm2learner[20]].tontai:=false;
        obj[idm2learner[20]].ata.now:=0;
        obj[idm2learner[20]].ata.tnext:=0;
        viet(830,40,wchu+10,hchu,4,idm2learner,nidm2learner,stp(its(inguoi2-1)),3,'VBAMASN.TTF',80,255,40,40,255,255,0);
        obj[idm2learner[nidm2learner-3]].tontai:=true;
        viet(816,200,wchud,hchu,3,idm2learner,nidm2learner,stp(daychinh[inguoi2].cauhoi+' = ___'),1,'VBAMASN.TTF',100,255,255,255,255,255,255);
        end else c2:=daychinh[inguoi2].ans[i2];
end else
begin
i2:=1;
st2:='';
c2:=daychinh[inguoi2].ans[1];
obj[idm2learner[20]].tontai:=true;
obj[idm2learner[20]].ata.now:=0;
obj[idm2learner[20]].ata.tnext:=0;
obj[idm2learner[19]].tontai:=false;
obj[idm2learner[19]].ata.now:=0;
obj[idm2learner[19]].ata.tnext:=0;
blocktime2:=sdl_getticks+1500;
turnback2:=true;
viet(816,200,wchud,hchu,3,idm2learner,nidm2learner,stp(daychinh[inguoi2].cauhoi+' = ___'),1,'VBAMASN.TTF',100,241,3,10,255,255,255);
 {sai}
end;
hcii:=#0;
end;
{//}
if (timeEnd<=sdl_getticks) and (chuahien) then
begin
chuahien:=false;
if (inguoi1>=inguoi2) then
begin
{hien bang}
hien(idm2learner[15]);
hien(idm2learner[16]);
{hien so}
viet(120,290,wchu+40,hchu+70,7,idm2learner,nidm2learner,stp(its(inguoi1-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm2learner[nidm2learner-6]);
end;
if (inguoi2>=inguoi1) then
begin
{hien bang}
hien(idm2learner[17]);
hien(idm2learner[18]);
{hien so}
viet(985,290,wchu+40,hchu+70,8,idm2learner,nidm2learner,stp(its(inguoi2-1)),3,'VBAMASN.TTF',200,255,255,255,255,255,0);
hien(idm2learner[nidm2learner-7]);
end;
{an diem}
anslls(2,14,idm2learner);
an(idm2learner[nidm2learner-3]);
an(idm2learner[nidm2learner-2]);
an(idm2learner[nidm2learner-1]);
an(idm2learner[nidm2learner]);
end;
{///}
if (sdl_getticks>=drawTime) then begin draw(idm2learner,nidm2learner); inc(drawTime,tpf); end;
sdl_delay(1); until false;
end;

begin
ahAgain:
khoiDong;
goto lmainmenu;
lmainmenu:
case mainmenu() of
'startmenu': goto lstartmenu;
'exit': forceexit;
'mainmenu': goto lmainmenu;
'luyentapmenu': begin cheDo:='luyentap'; goto lluyentapmenu; end;
'memorymenu': begin chedo:='memory'; goto lluyentapmenu; end;
'mlearner': begin applychedo; if songuoi='1' then goto l1learner else goto l2learner; end;
'ok': goto ahAgain;
end;
lstartmenu:
case startmenu() of
'startmenu': goto lstartmenu;
'exit': forceexit;
'mainmenu': goto lmainmenu;
'luyentapmenu': begin cheDo:='luyentap'; goto lluyentapmenu; end;
'memorymenu': begin chedo:='memory'; goto lluyentapmenu; end;
'mlearner': begin applychedo; if songuoi='1' then goto l1learner else goto l2learner; end;
end;
lluyentapmenu:
case luyentapmenu() of
'startmenu': goto lstartmenu;
'exit': forceexit;
'mainmenu': goto lmainmenu;
'luyentapmenu': begin cheDo:='luyentap'; goto lluyentapmenu; end;
'memorymenu': begin chedo:='memory'; goto lluyentapmenu; end;
'mlearner': begin applychedo; if songuoi='1' then goto l1learner else goto l2learner; end;
end;
l1learner:
case m1learner() of
'startmenu': goto lstartmenu;
'exit': forceexit;
'mainmenu': goto lmainmenu;
'luyentapmenu': begin cheDo:='luyentap'; goto lluyentapmenu; end;
'memorymenu': begin chedo:='memory'; goto lluyentapmenu; end;
'mlearner': begin applychedo; if songuoi='1' then goto l1learner else goto l2learner; end;
end;
l2learner:
case m2learner() of
'startmenu': goto lstartmenu;
'exit': forceexit;
'mainmenu': goto lmainmenu;
'luyentapmenu': begin cheDo:='luyentap'; goto lluyentapmenu; end;
'memorymenu': begin chedo:='memory'; goto lluyentapmenu; end;
'mlearner': begin applychedo; if songuoi='1' then goto l1learner else goto l2learner; end;
end;
end.

