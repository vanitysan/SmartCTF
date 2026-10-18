class SmartCTFScoreBoard extends ScoreBoard;

var SmartCTF Controller;
var PlayerReplicationInfo Players[64];
var int Counts[4], PlayerCount;
var int Maximum[16];

static function bool IsRealSpectator(PlayerReplicationInfo PRI)
{
    return PRI!=None && PRI.bIsSpectator && !PRI.bWaitingPlayer;
}

function Gather()
{
    local PlayerReplicationInfo PRI, Temp;
    local int I,J,K;
    local SmartCTFPlayerReplicationInfo ST;
    PlayerCount=0;
    for (I=0; I<4; I++) Counts[I]=0;
    foreach AllActors(class'PlayerReplicationInfo',PRI)
        if (!IsRealSpectator(PRI) && PRI.Team<4 && PlayerCount<64)
        { Players[PlayerCount++]=PRI; Counts[PRI.Team]++; }
    for (I=1; I<PlayerCount; I++)
    {
        Temp=Players[I]; J=I-1;
        while (J>=0 && (Players[J].Score<Temp.Score || (Players[J].Score==Temp.Score && Players[J].PlayerID>Temp.PlayerID)))
        { Players[J+1]=Players[J]; J--; }
        Players[J+1]=Temp;
    }
    for (I=PlayerCount; I<64; I++) Players[I]=None;
    for (K=0; K<16; K++) Maximum[K]=0;
    for (I=0; I<PlayerCount; I++)
    {
        ST=Controller.Stats(Players[I]);
        if (ST!=None) for (K=0; K<16; K++) Maximum[K]=Max(Maximum[K],ST.Value(K));
    }
}

function ShowScores(Canvas C)
{
    local SmartCTFUI U;
    local SmartCTFSettings S;
    local int I,Rows;
    local float X,Y,W,H,Gap,FootH,TeamH,Line;
    local string Clock,Specs;
    local PlayerReplicationInfo PRI;
    local GameReplicationInfo G;
    local color FooterColor;
    if (Controller==None)
        foreach AllActors(class'SmartCTF',Controller) break;
    if (Controller==None || Controller.UI==None || Controller.Settings==None) return;
    U=Controller.UI; S=Controller.Settings; G=PlayerPawn(Owner).GameReplicationInfo;
    if (G==None) return;
    Gather(); U.Begin(C);
    W=C.ClipX*S.PanelWidth; H=C.ClipY*S.PanelHeight;
    X=(C.ClipX-W)*0.5; Y=C.ClipY*0.104;
    Line=U.StatHeight; Gap=C.ClipX*0.13; FootH=Line*5;
    if (G.RemainingTime>0) Clock="Remaining Time: "$(G.RemainingTime/60)$":"$S.Pad(G.RemainingTime%60);
    else Clock="Elapsed Time: "$(G.ElapsedTime/60)$":"$S.Pad(G.ElapsedTime%60);
    Rows=1; if (S.ActiveTeams==4) Rows=2;
    TeamH=(C.ClipY-Y-FootH-Line*3)/Rows;
    for (I=0; I<S.ActiveTeams; I++)
        if (Counts[I]>0)
            TeamPanel(C,U,S,I,X+(I%2)*(W+Gap)/2,Y+(I/2)*TeamH,(W-Gap)/2,TeamH-Line,Line);
    if (G.GameEndedComments!="") U.CenterText(C,G.GameEndedComments,0,Line,C.ClipX,Line*1.5,U.Accent());
    Y=C.ClipY-FootH;
    if (S.bShowSpectators)
    {
        foreach AllActors(class'PlayerReplicationInfo',PRI)
            if (IsRealSpectator(PRI) && PRI.PlayerName!="" && Pawn(PRI.Owner)!=None && Pawn(PRI.Owner).bIsPlayer)
            { if (Specs!="") Specs=Specs$", "; Specs=Specs$PRI.PlayerName; }
        U.CenterText(C,"Spectators: " $ Specs,0,Y,C.ClipX,Line,S.TextColor);
    }
    FooterColor.R=255; FooterColor.G=255;
    U.CenterText(C,"[ SmartCTF 4J | {PiN}Kev | {DnF2}SiNiSTeR | [es]Rush | adminthis & The_Cowboy & Sp0ngeb0b | vanitysan ]",0,Y+Line*1.4,C.ClipX,Line,FooterColor);
    U.CenterText(C,"Current Time: " $ ClientClock() @ " | " @ Clock,0,Y+Line*2.7,C.ClipX,Line,S.TextColor);
    U.CenterText(C,"Playing " $ Level.Title @ " on " @ G.ServerName,0,Y+Line*4,C.ClipX,Line,S.TextColor);
    U.ChristmasOverlay(C);
    U.Finish(C);
}

function string ClientClock()
{
    // This scoreboard runs on the viewport client; Level calendar fields are local.
    return class'SmartCTFSettings'.static.Pad(Level.Day)$"."$class'SmartCTFSettings'.static.Pad(Level.Month)$"."$Level.Year
        @class'SmartCTFSettings'.static.Pad(Level.Hour)$":"$class'SmartCTFSettings'.static.Pad(Level.Minute);
}

function TeamPanel(Canvas C,SmartCTFUI U,SmartCTFSettings S,int Team,float X,float Y,float W,float H,float Line)
{
    local TournamentGameReplicationInfo G;
    local SmartCTFPlayerReplicationInfo ST;
    local int I,N,PerPage,Page,Pages,Skip,Shown,Score,K,Metric[6],PingSum,PLSum,PanelRows;
    local float Pad,Gap,Header,RowH,RY,Face,NameX,StatW,ScoreW,XL,YL,NameW,MetaX,NameColumnW,MetaW,TimeW,ScoreColumnW,FlagShift,FlagHeight,FlagWidth,InfoGap;
    local texture CountryImage;
    local string NameText,Details;
    local color Col;
    Col=S.TeamColors[Team]; Pad=20*U.Scale; Gap=10*U.Scale;
    G=TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
    if (G!=None && G.Teams[Team]!=None) Score=int(G.Teams[Team].Score);
    Header=U.NameHeight+24*U.Scale;
    RowH=U.NameHeight+U.StatHeight*3+18*U.Scale;
    PerPage=Max(1,int((H-Header-Pad-Line)/RowH));
    Pages=Max(1,(Counts[Team]+PerPage-1)/PerPage);
    Page=int(Level.TimeSeconds/S.PageSeconds)%Pages;
    PanelRows=Min(Max(Counts[(Team/2)*2],Counts[(Team/2)*2+1]),PerPage);
    U.Panel(C,X,Y+Header,W,Pad+PanelRows*RowH);
    U.TeamHeader(C,Team,X,Y,W,Header);
    Face=FMax(20,32*U.Scale);
    U.Image(C,U.TeamIcon(Team),X+Pad,Y+(Header-Face)*0.5,Face,Face,True);
    C.Font=U.CaptureFont; C.StrLen(string(Score),XL,YL);
    U.Text(C,string(Score),X+Pad+Face+Gap,Y+(Header-YL)*0.5,Face*2,Header,Col,U.CaptureFont);
    C.Font=U.NameFont; C.StrLen("Frags / Pts",XL,YL);
    U.Text(C,"Frags / Pts",X+W-Pad-XL,Y+(Header-YL)*0.5,XL+1,Header,Col,U.NameFont);
    for (I=0; I<PlayerCount; I++) if (Players[I].Team==Team) { PingSum+=Players[I].Ping; PLSum+=Players[I].PacketLoss; }
    MetaX=X+Pad+Face*2+Gap*2;
    U.Text(C,"PING:"$(PingSum/Max(1,Counts[Team]))$" PL:"$(PLSum/Max(1,Counts[Team]))$"%",MetaX,Y+Header*0.35,FMax(0,W-Pad-XL-(MetaX-X)-Gap),U.TinyHeight,S.TextColor,U.TinyFont);
    U.Text(C,"TM:"$Max(1,PlayerPawn(Owner).GameReplicationInfo.ElapsedTime/60),MetaX,Y+Header*0.35+U.TinyHeight,W*0.3,U.TinyHeight,S.TextColor,U.TinyFont);
    // Shared columns: measure approximately 15 name characters in the current font.
    // Reserve the widest score across all teams so every panel has the same layout.
    NameX=X+Pad+Face+Gap;
    C.Font=U.NameFont; C.StrLen("000000000000000",NameColumnW,YL);
    C.StrLen("0 / 0",ScoreColumnW,YL);
    for (I=0; I<PlayerCount; I++)
    {
        ST=Controller.Stats(Players[I]); Details=string(int(Players[I].Score));
        if (ST!=None) Details=ST.Frags$" / "$Details;
        C.StrLen(Details,XL,YL); ScoreColumnW=FMax(ScoreColumnW,XL);
    }
    C.Font=U.TinyFont; C.StrLen("TM:999 ",TimeW,YL);
    C.StrLen("EFF:100%",MetaW,YL); MetaW+=TimeW;
    NameColumnW=FMax(0,FMin(NameColumnW,X+W-Pad-ScoreColumnW-NameX-MetaW-Gap*2));
    Skip=Page*PerPage;
    for (I=0; I<PlayerCount; I++)
    {
        if (Players[I].Team!=Team) continue;
        if (N++<Skip) continue;
        if (Shown>=PerPage) break;
        RY=Y+Header+Pad+Shown*RowH;
        if (Players[I].HasFlag!=None)
            U.Image(C,texture'Botpack.GreenFlag',X+Pad,RY,Face,Face,True);
        else
        {
            if (S.bDrawFaces && Players[I].TalkTexture!=None) U.Image(C,Players[I].TalkTexture,X+Pad,RY,Face,Face,True);
            else U.Image(C,texture'faceless',X+Pad,RY,Face,Face,True);
            U.Image(C,texture'Botpack.IconSelection',X+Pad,RY,Face,Face,True,True);
        }
        NameX=X+Pad+Face+Gap;
        NameText=Players[I].PlayerName;
        if (Players[I].bAdmin) NameText="[A] "$NameText;
        ST=Controller.Stats(Players[I]);
        Details=string(int(Players[I].Score));
        if (ST!=None) Details=ST.Frags$" / "$Details;
        C.Font=U.NameFont; C.StrLen(Details,ScoreW,YL);
        U.Text(C,Details,X+W-Pad-ScoreW,RY,ScoreW+1,U.NameHeight,NameColor(Players[I],S),U.NameFont);
        NameW=NameColumnW;
        U.Text(C,NameText,NameX,RY,NameW,U.NameHeight,NameColor(Players[I],S),U.NameFont);
        MetaX=NameX+NameColumnW+Gap;
        Details="TM:"$Max(1,int((Level.TimeSeconds-Players[I].StartTime)/60));
        U.Text(C,Details,MetaX,RY+(U.NameHeight-U.TinyHeight)*0.5,TimeW,U.TinyHeight,S.TextColor,U.TinyFont);
        if (ST!=None)
        {
            Details="EFF:"$int(100.0*ST.Frags/Max(1,ST.Frags+int(Players[I].Deaths)))$"%";
            U.Text(C,Details,MetaX+TimeW,RY+(U.NameHeight-U.TinyHeight)*0.5,FMax(0,X+W-Pad-ScoreColumnW-Gap-MetaX-TimeW),U.TinyHeight,S.TextColor,U.TinyFont);
        }
        FlagShift=0;
        InfoGap=3*U.Scale;
        if (S.bShowCountryFlags && ST!=None)
        {
            CountryImage=ST.CountryFlag(S.CountryFlagsPackage);
            if (CountryImage!=None)
            {
                // Exact aspect-correct bounds keep both vertical gaps equal.
                FlagHeight=FMin(16*U.Scale,Face*CountryImage.VSize/FMax(1,CountryImage.USize));
                FlagWidth=FlagHeight*CountryImage.USize/FMax(1,CountryImage.VSize);
                U.Image(C,CountryImage,X+Pad+(Face-FlagWidth)*0.5,RY+Face+InfoGap,FlagWidth,FlagHeight);
                FlagShift=FlagHeight+InfoGap;
            }
        }
        if (Players[I].bIsABot)
        {
            U.Text(C,"BOT",X+Pad,RY+Face+FlagShift+InfoGap,Face+Gap,U.TinyHeight,S.TextColor,U.TinyFont);
            if (Players[I].Team==PlayerPawn(Owner).PlayerReplicationInfo.Team && BotReplicationInfo(Players[I])!=None)
                U.Text(C,Left(string(BotReplicationInfo(Players[I]).RealOrders),3),X+Pad,RY+Face+FlagShift+InfoGap+U.TinyHeight,Face+Gap,U.TinyHeight,S.TextColor,U.TinyFont);
        }
        else
        {
            U.Text(C,"PI:"$Players[I].Ping,X+Pad,RY+Face+FlagShift+InfoGap,Face+Gap,U.TinyHeight,S.TextColor,U.TinyFont);
            U.Text(C,"PL:"$Players[I].PacketLoss$"%",X+Pad,RY+Face+FlagShift+InfoGap+U.TinyHeight,Face+Gap,U.TinyHeight,S.TextColor,U.TinyFont);
        }
        if (ST!=None)
        {
            Metric[0]=2; Metric[1]=4; Metric[2]=3;
            Metric[3]=7; Metric[4]=9; Metric[5]=6;
            if (int(Level.TimeSeconds/S.PageSeconds)%2==1)
            { Metric[2]=5; if (S.bShowDamage) Metric[5]=11; }
            StatW=(X+W-Pad-NameX-Gap)/2;
            for (K=0; K<6; K++)
                U.Bar(C,StatLabel(Metric[K],S),ST.Value(Metric[K]),Maximum[Metric[K]],NameX+(K/3)*(StatW+Gap),RY+U.NameHeight+(K%3)*U.StatHeight,StatW,U.StatHeight,Col);
        }
        Shown++;
    }
    if (Pages>1) U.Text(C,"Page "$(Page+1)$"/"$Pages,X+Pad,Y+Header+Pad+Shown*RowH,W-Pad*2,Line,Col);
}

function color NameColor(PlayerReplicationInfo PRI,SmartCTFSettings S)
{
    local color Col;
    if (PRI==PlayerPawn(Owner).PlayerReplicationInfo) { Col.R=255; Col.G=255; return Col; }
    if (PRI.bAdmin) return S.TextColor;
    return S.TeamColors[Min(PRI.Team,3)];
}

function string StatLabel(int Index,SmartCTFSettings S)
{
    switch(Index)
    {
        case 2:return "Caps";
        case 3:return "Assists";
        case 4:return "Grabs";
        case 6:return "FlagKls";
        case 9:return "DefKills";
        case 11:return "Damage";
    }
    return S.StatLabels[Index];
}

defaultproperties
{
    RemoteRole=ROLE_None
}
