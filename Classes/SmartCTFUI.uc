class SmartCTFUI extends Info;

#exec TEXTURE IMPORT NAME=shade FILE=Textures\shade.pcx MIPS=OFF
#exec TEXTURE IMPORT NAME=meter FILE=Textures\meter.pcx MIPS=OFF
#exec TEXTURE IMPORT NAME=faceless FILE=Textures\faceless.pcx MIPS=OFF
#exec TEXTURE IMPORT NAME=poweredModern FILE=Textures\powered-modern.pcx MIPS=OFF
#exec TEXTURE IMPORT NAME=redskin2 FILE=Textures\redskin2.png MIPS=OFF
#exec TEXTURE IMPORT NAME=blueskin2 FILE=Textures\blueskin2.png MIPS=OFF
#exec TEXTURE IMPORT NAME=greenskin2 FILE=Textures\greenskin2.png MIPS=OFF
#exec TEXTURE IMPORT NAME=yellowskin2 FILE=Textures\yellowskin2.png MIPS=OFF

var SmartCTFSettings Settings;
var SmartCTFXmasOverlay XmasOverlay;
var float Scale;
#exec new TrueTypeFontFactory Name="CursedTimer" FontName="Cursed Timer ULiL" Height=35 AntiAlias=1

var FontInfo LegacyFonts;
var Font BodyFont, NameFont, StatFont, TitleFont, TinyFont, CaptureFont;
var float BodyHeight, NameHeight, StatHeight, TitleHeight, TinyHeight;
var float LastBarX, LastBarWidth, LastTextWidth;
var float BarLabelWidth, BarDigitsWidth;

var Font OldFont;
var color OldColor;
var byte OldStyle;
var bool OldCenter, OldSmooth;
var float OldClipX, OldClipY, OldOrgX, OldOrgY, OldX, OldY, OldSpaceX, OldSpaceY;
var texture LoadedFlags[4];
var string LoadedNames[4];


simulated function Begin(Canvas C)
{
    local float XL;
    OldFont=C.Font; OldColor=C.DrawColor; OldStyle=C.Style;
    OldCenter=C.bCenter; OldSmooth=C.bNoSmooth;
    OldClipX=C.ClipX; OldClipY=C.ClipY; OldOrgX=C.OrgX; OldOrgY=C.OrgY;
    OldX=C.CurX; OldY=C.CurY; OldSpaceX=C.SpaceX; OldSpaceY=C.SpaceY;
    C.bCenter=False; C.bNoSmooth=False; C.Style=1;
    C.SpaceX=0; C.SpaceY=0;
    Scale=FMin(C.ClipX/1920.0,C.ClipY/1080.0);
    if (Settings!=None) Scale*=Settings.UIScale;
    if (LegacyFonts==None) LegacyFonts=Spawn(class'FontInfo');
    BodyFont=LegacyFonts.GetSmallFont(C.ClipX*Settings.UIScale);
    NameFont=LegacyFonts.GetBigFont(C.ClipX*Settings.UIScale);
    StatFont=LegacyFonts.GetSmallestFont(C.ClipX*Settings.UIScale);
    TitleFont=LegacyFonts.GetHugeFont(C.ClipX*Settings.UIScale);
    TinyFont=C.SmallFont; CaptureFont=font'CursedTimer';
    if (C.ClipX<1024) CaptureFont=NameFont;
    C.Font=BodyFont; C.StrLen("Test",XL,BodyHeight);
    C.Font=NameFont; C.StrLen("Test",XL,NameHeight);
    C.Font=StatFont; C.StrLen("Test",XL,StatHeight);
    C.Font=TitleFont; C.StrLen("Test",XL,TitleHeight);
    C.Font=TinyFont; C.StrLen("Test",XL,TinyHeight);

}

simulated function Finish(Canvas C)
{
    C.Font=OldFont; C.DrawColor=OldColor; C.Style=OldStyle;
    C.bCenter=OldCenter; C.bNoSmooth=OldSmooth;
    C.ClipX=OldClipX; C.ClipY=OldClipY; C.OrgX=OldOrgX; C.OrgY=OldOrgY;
    C.CurX=OldX; C.CurY=OldY; C.SpaceX=OldSpaceX; C.SpaceY=OldSpaceY;
}

simulated function Panel(Canvas C,float X,float Y,float W,float H)
{
    C.Style=4; C.DrawColor.R=255; C.DrawColor.G=255; C.DrawColor.B=255;
    C.SetPos(X,Y);
    C.DrawTile(texture'shade',W,H,0,0,texture'shade'.USize,texture'shade'.VSize);
    C.Style=1;
}

simulated function TeamHeader(Canvas C,int Team,float X,float Y,float W,float H)
{
    local texture T;
    switch(Team)
    {
        case 0:T=texture'redskin2';break;
        case 1:T=texture'blueskin2';break;
        case 2:T=texture'greenskin2';break;
        case 3:T=texture'yellowskin2';break;
    }
    Panel(C,X,Y,W,H);
    C.Style=3; C.DrawColor.R=0; C.DrawColor.G=0; C.DrawColor.B=0;
    switch(Team)
    {
        case 0:C.DrawColor.R=64;break;
        case 1:C.DrawColor.G=32;C.DrawColor.B=64;break;
        case 2:C.DrawColor.R=32;C.DrawColor.G=64;break;
        case 3:C.DrawColor.R=80;C.DrawColor.G=63;break;
    }
    C.SetPos(X,Y);
    C.DrawPattern(T,W,H,1);
    C.Style=1;
}

simulated function CenterText(Canvas C,string S,float X,float Y,float W,float H,color Col,optional font F)
{
    local float XL,YL;
    if (F==None) F=StatFont;
    C.Font=F; C.StrLen(S,XL,YL);
    Text(C,S,X+FMax(0,(W-XL)*0.5),Y,W,H,Col,F);
}

simulated function InfoHeader(Canvas C,float X,float Y,float W,float H)
{
    C.Style=3; C.DrawColor.R=32; C.DrawColor.G=32; C.DrawColor.B=32;
    C.SetPos(X,Y); C.DrawPattern(texture'UnrealShare.newblue',W,H,1); C.Style=1;
}

simulated function texture TeamIcon(int Team)
{
    local string Path;
    if (Team<0 || Team>=4) return None;
    Path=Settings.TeamHudName(Team);
    if (LoadedNames[Team]!=Path)
    {
        LoadedNames[Team]=Path; LoadedFlags[Team]=None;
        if (Path!="") LoadedFlags[Team]=texture(DynamicLoadObject(Path,class'Texture',True));
        if (Path!="" && LoadedFlags[Team]==None) Log("Cannot load team HUD texture: "$Path,'SmartCTF');
    }
    if (LoadedFlags[Team]!=None) return LoadedFlags[Team];
    switch(Team)
    {
        case 0:return texture'Botpack.I_TeamR';
        case 1:return texture'Botpack.I_TeamB';
        case 2:return texture'Botpack.I_TeamG';
        case 3:return texture'Botpack.I_TeamY';
    }
}

simulated function Bar(Canvas C,string Label,int Count,int Maximum,float X,float Y,float W,float H,color Col)
{
    local float NumberWidth,YL,Gap,ValueRight,Available;
    local string NumberText;
    Gap=FMax(3,5*Scale); C.Font=StatFont;
    NumberText=string(Count);
    C.StrLen(NumberText,NumberWidth,YL);
    // Shared across every row and both rotating statistic pages.
    ValueRight=FMin(W,BarLabelWidth+Gap+BarDigitsWidth);
    Text(C,Label$":",X,Y,FMax(0,ValueRight-NumberWidth-Gap),H,Settings.TextColor,StatFont);
    Text(C,NumberText,X+ValueRight-NumberWidth,Y,NumberWidth+1,H,Settings.TextColor,StatFont);
    Available=FMax(0,W-ValueRight-Gap);
    LastBarX=X+ValueRight+Gap;
    LastBarWidth=Available*FClamp(float(Count)/Max(1,Maximum),0,1);
    if (Count<=0 || Maximum<=0 || LastBarWidth<1) return;
    C.DrawColor=MeterColor(Count,Maximum); C.Style=1; C.SetPos(LastBarX,Y+(H-FMax(1,H*0.3))*0.5);
    C.DrawTile(texture'meter',LastBarWidth,FMax(1,H*0.3),0,0,texture'meter'.USize,texture'meter'.VSize);
}

static function color MeterColor(int Count,int Maximum)
{
    local color Result;
    local float Fraction;
    Fraction=FClamp(float(Count)/Max(1,Maximum),0,1);
    Result.R=255*(1-Fraction); Result.G=255; Result.B=255*(1-Fraction);
    return Result;
}

simulated function Text(Canvas C, string S, float X, float Y, float W, float H, color Col, optional font F)
{
    local float XL,YL;
    local string Full;
    LastTextWidth=0;
    if (W<=0 || H<=0 || S=="") return;
    C.Font=F; if (C.Font==None) C.Font=BodyFont;
    C.StrLen(S,XL,YL);
    if (XL>W)
    {
        Full=S;
        while (Len(Full)>0 && XL>W)
        {
            Full=Left(Full,Len(Full)-1);
            S=Full$"..";
            C.StrLen(S,XL,YL);
        }
        if (XL>W) return;
    }
    C.Style=1; C.DrawColor=Col; C.SetPos(X,Y);
    C.DrawText(S,False); LastTextWidth=XL;
}

simulated function RightText(Canvas C,string S,float X,float Y,float W,float H,color Col)
{
    local float XL,YL;
    local string Full;
    C.Font=StatFont; C.StrLen(S,XL,YL);
    Full=S;
    while (XL>W && Len(Full)>0)
    {
        Full=Left(Full,Len(Full)-1); S=Full$".."; C.StrLen(S,XL,YL);
    }
    if (XL>W || W<=0) return;
    Text(C,S,X+W-XL,Y,W,H,Col,StatFont);
}

simulated function Image(Canvas C, texture T, float X, float Y, float W, float H, optional bool bTranslucent, optional bool bDim)
{
    local float F, DW,DH;
    if (T==None || T.USize<=0 || T.VSize<=0 || W<=0 || H<=0) return;
    F=FMin(W/T.USize,H/T.VSize);
    DW=T.USize*F; DH=T.VSize*F;
    C.Style=2; if (bTranslucent) C.Style=3;
    C.DrawColor.R=255; C.DrawColor.G=255; C.DrawColor.B=255;
    if (bDim) { C.DrawColor.R=64; C.DrawColor.G=64; C.DrawColor.B=64; }
    C.SetPos(X+(W-DW)*0.5,Y+(H-DH)*0.5);
    C.DrawTile(T,DW,DH,0,0,T.USize,T.VSize);
    C.Style=1;
}

simulated function color Accent()
{
    return Settings.AccentColor;
}

simulated function ChristmasOverlay(Canvas C)
{
    if (Settings==None || !Settings.bXmasActive) return;
    if (XmasOverlay==None) XmasOverlay=Spawn(class'SmartCTFXmasOverlay');
    if (XmasOverlay==None) return;
    XmasOverlay.Settings=Settings;
    XmasOverlay.renderSnow(C);
}

simulated function Destroyed()
{
    if (XmasOverlay!=None) XmasOverlay.Destroy();
    if (LegacyFonts!=None) LegacyFonts.Destroy();
    Super.Destroyed();
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
