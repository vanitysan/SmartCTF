class SmartCTFServerInfo extends ServerInfo;
var SmartCTF Controller;

function RenderInfo(Canvas C)
{
    local SmartCTFUI U;
    local SmartCTFSettings S;
    local SmartCTFRecords R;
    local SmartCTFPlayerReplicationInfo ST,Best;
    local GameReplicationInfo G;
    local TournamentGameReplicationInfo TG;
    local PlayerReplicationInfo PRI;
    local int I,J,Enabled[17],Count,Rows,Page,Pages,Bots,Players,Value;
    local float X,Y,W,H,Line,Pad,LX,RX,CW,RY,Top,TableW,LabelW,NumberW,Gap,XL,YL,NumberRight,WhoX,WhereX,WhenX,Remaining;
    local string Title,Who,ValueText,MapText,DateText;
    if (Controller==None) foreach AllActors(class'SmartCTF',Controller) break;
    if (Controller==None || Controller.UI==None || Controller.Settings==None) return;
    U=Controller.UI; S=Controller.Settings; R=Controller.Records;
    G=PlayerPawn(Owner).GameReplicationInfo; TG=TournamentGameReplicationInfo(G);
    if (G==None) return;
    U.Begin(C);
    W=C.ClipX*0.80*(S.PanelWidth/0.87)+48*U.Scale;
    Line=U.BodyHeight; Pad=24*U.Scale;
    for (I=0; I<17; I++) if (S.StatEnabled[I]!=0) Enabled[Count++]=I;
    // Keep the classic compact centered window; only paginate rows that cannot fit.
    Rows=Min(Min(9,Count),Max(1,int((C.ClipY*S.PanelHeight-Line*22)/(Line*1.15))));
    H=Line*22+Rows*Line*1.15;
    X=(C.ClipX-W)*0.5; Y=(C.ClipY-H)*0.5;
    LX=X+Pad; RX=X+W*0.62; CW=W*0.36-Pad;
    U.Panel(C,X,Y,W,H); U.InfoHeader(C,X,Y,W,U.TitleHeight*1.5);
    U.CenterText(C,"Server Info",X,Y+Line*0.4,W,Line*1.9,U.Accent(),U.TitleFont);
    Top=Y+U.TitleHeight*1.5+Pad;
    U.Text(C,"Contact Info",LX,Top,W*0.52,Line*1.4,U.Accent(),U.NameFont);
    U.Text(C,"Message of the Day",RX,Top,CW,Line*1.4,U.Accent(),U.NameFont);
    RY=Top+Line*1.8;
    InfoLine(C,U,S,"Name:",G.ServerName,LX,RY,W*0.55,Line);
    InfoLine(C,U,S,"Admin:",G.AdminName,LX,RY,W*0.55,Line);
    InfoLine(C,U,S,"E-mail:",G.AdminEmail,LX,RY,W*0.55,Line);
    RY=Top+Line*1.8;
    U.Text(C,G.MOTDLine1,RX,RY,CW,Line,S.TextColor);
    U.Text(C,G.MOTDLine2,RX,RY+Line*1.2,CW,Line,S.TextColor);
    U.Text(C,G.MOTDLine3,RX,RY+Line*2.4,CW,Line,S.TextColor);
    U.Text(C,G.MOTDLine4,RX,RY+Line*3.6,CW,Line,S.TextColor);
    foreach AllActors(class'PlayerReplicationInfo',PRI)
        if (!class'SmartCTFScoreBoard'.static.IsRealSpectator(PRI) && Pawn(PRI.Owner)!=None && Pawn(PRI.Owner).bIsPlayer)
        { Players++; if (PRI.bIsABot) Bots++; }
    Top+=Line*8;
    U.Text(C,"Game Stats",LX,Top,W*0.52,Line*1.4,U.Accent(),U.NameFont);
    U.Text(C,"Server Stats",RX,Top,CW,Line*1.4,U.Accent(),U.NameFont);
    RY=Top+Line*1.8;
    InfoLine(C,U,S,"GameType:",G.GameName,LX,RY,W*0.55,Line);
    InfoLine(C,U,S,"Players:",Players@" ["$Bots$" Bots]",LX,RY,W*0.55,Line);
    RY=Top+Line*1.8;
    if (TG!=None)
    {
        InfoLine(C,U,S,"Games Hosted:",string(TG.TotalGames),RX,RY,CW,Line);
        InfoLine(C,U,S,"Flags Captured:",string(TG.TotalFlags),RX,RY,CW,Line);
    }
    Top+=Line*5.6;
    Pages=Max(1,(Count+Rows-1)/Max(1,Rows)); Page=int(Level.TimeSeconds/S.PageSeconds)%Pages;
    Title="SmartCTF Record Holders";
    if (!S.bShowRecords) Title="SmartCTF Match Leaders";
    else if (R!=None && R.bRecordsPerHour) Title="SmartCTF Records per Hour";
    else Title="SmartCTF Match Records";
    if (Pages>1) Title=Title@" ("$(Page+1)$"/"$Pages$")";
    U.Image(C,texture'UTMenu.TrophyCTF',LX,Top-Line*0.4,Line*2.4,Line*2.4,True);
    U.Text(C,Title,LX+Line*2.5,Top,W-Pad*2-Line*2.5,Line*1.4,U.Accent(),U.NameFont);
    Top+=Line*1.8; TableW=W-Pad*2;
    // Measure across all pages so the seven-digit value column never moves.
    C.Font=U.StatFont; Gap=FMax(8,12*U.Scale);
    for (I=0; I<10; I++) { C.StrLen(string(I),XL,YL); NumberW=FMax(NumberW,XL*7); }
    for (I=0; I<Count; I++)
    { C.StrLen(RecordLabel(S.StatLabels[Enabled[I]]),XL,YL); LabelW=FMax(LabelW,XL); }
    LabelW=FMin(LabelW,TableW*0.26);
    // Also keep unusually large values readable without shifting individual rows.
    if (R!=None) for (I=0; I<Count; I++)
    { C.StrLen(string(R.RecordValue[Enabled[I]]),XL,YL); NumberW=FMax(NumberW,XL); }
    NumberRight=LX+LabelW+Gap+NumberW;
    WhoX=NumberRight+Gap*2;
    Remaining=LX+TableW-WhoX;
    WhereX=WhoX+Remaining*0.38;
    WhenX=WhoX+Remaining*0.72;
    WhoX=FMin(WhereX-Gap*4,FMax(WhoX+Gap*3,LX+TableW*0.30));
    U.Text(C,"Who",WhoX,Top,WhereX-WhoX-Gap,Line,U.Accent(),U.StatFont);
    U.Text(C,"Where",WhereX,Top,WhenX-WhereX-Gap,Line,U.Accent(),U.StatFont);
    U.Text(C,"When",WhenX,Top,LX+TableW-WhenX,Line,U.Accent(),U.StatFont);
    Top+=Line*1.2;
    for (J=0; J<Rows && Page*Rows+J<Count; J++)
    {
        I=Enabled[Page*Rows+J]; Who="--"; ValueText="0"; MapText="--"; DateText="--";
        if (S.bShowRecords && R!=None)
        {
            Who=R.RecordPlayer[I]; ValueText=string(R.RecordValue[I]);
            MapText=R.RecordMap[I]; DateText=R.RecordDate[I];

        }
        else
        {
            Best=None; Value=0;
            foreach AllActors(class'SmartCTFPlayerReplicationInfo',ST)
                if (ST.PlayerInfo!=None && !class'SmartCTFScoreBoard'.static.IsRealSpectator(ST.PlayerInfo) && ST.Value(I)>Value)
                { Value=ST.Value(I); Best=ST; }
            if (Best!=None) Who=Best.PlayerInfo.PlayerName;
            ValueText=string(Value); MapText=Level.Title; DateText="Current match";
        }
        if (Who=="" || Who=="--") { Who="--"; ValueText="--"; MapText="--"; DateText="--"; }
        // Stored timestamps retain seconds; the compact display shows minutes.
        if (Len(DateText)==19) DateText=Left(DateText,16);
        U.Text(C,RecordLabel(S.StatLabels[I]),LX,Top,LabelW,Line,U.Accent(),U.StatFont);
        C.Font=U.StatFont; C.StrLen(ValueText,XL,YL);
        U.Text(C,ValueText,NumberRight-XL,Top,XL+1,Line,S.TextColor,U.StatFont);
        U.Text(C,Who,WhoX,Top,WhereX-WhoX-Gap,Line,S.TextColor,U.StatFont);
        U.Text(C,MapText,WhereX,Top,WhenX-WhereX-Gap,Line,S.TextColor,U.StatFont);
        U.Text(C,DateText,WhenX,Top,LX+TableW-WhenX,Line,S.TextColor,U.StatFont);
        Top+=Line*1.15;
    }
    U.ChristmasOverlay(C);
    U.Finish(C);
}

function string RecordLabel(string Label)
{
    if (Left(Caps(Label),5)=="MOST " || Left(Caps(Label),5)=="BEST ") return Label;
    return "Most "$Label;
}

function InfoLine(Canvas C,SmartCTFUI U,SmartCTFSettings S,string Label,string ValueText,float X,out float Y,float W,float H)
{
    local float LabelW,XL,YL;
    C.Font=U.BodyFont;
    if (Label=="Name:" || Label=="Admin:" || Label=="E-mail:") LabelW=88*U.Scale;
    else if (Label=="GameType:" || Label=="Players:") LabelW=192*U.Scale;
    else LabelW=W*0.42;
    C.StrLen(Label,XL,YL); LabelW=FMax(LabelW,XL+8*U.Scale);
    U.Text(C,Label,X,Y,LabelW,H,U.Accent());
    U.Text(C,ValueText,X+LabelW,Y,W-LabelW,H,S.TextColor);
    Y+=H*1.2;
}
defaultproperties
{
    RemoteRole=ROLE_None
}

