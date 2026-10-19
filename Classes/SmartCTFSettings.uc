class SmartCTFSettings extends ReplicationInfo;

var bool bDoKeybind, bExtraMsg;
var string LogoTexture, IntroSound;
var float LogoDrawDelay, LogoFadeInTime, LogoFadeOutTime, IntroSoundDelay;
var string CaptionLineOne, CaptionLineTwo, CaptionLineThree, CaptionLineFour;
var bool bLogoTranslucent;
var float LogoDrawTime;
var string Position, Size;

var bool bXmasSB, bXmasImages;
var string bXmasStart, bXmasEnd;
var bool bShowCountryFlags;
var string CountryFlagsPackage;
var bool bDrawFaces, bShowSpectators, bShowCarrierLocation;
var bool bShowDamage, bShowRecords;
var string RedFlag, BlueFlag, GreenFlag, YellowFlag, RedTeamHud, BlueTeamHud, GreenTeamHud, YellowTeamHud;
var float UIScale, PanelWidth, PanelHeight, PageSeconds;
var color TextColor, AccentColor, TeamColors[4];
var string StatLabels[17];
var byte StatEnabled[17];
var byte ActiveTeams;
var bool bXmasActive, bFestiveSnow;
var SmartCTFMessageProfile Profiles[3];

replication
{
    reliable if (Role == ROLE_Authority)
        LogoDrawDelay,LogoFadeInTime,LogoFadeOutTime,CaptionLineOne,CaptionLineTwo,CaptionLineThree,CaptionLineFour,IntroSoundDelay,bLogoTranslucent,
        bDoKeybind,bExtraMsg,LogoTexture,IntroSound,Position,Size,LogoDrawTime,
        bShowCountryFlags, CountryFlagsPackage, bXmasActive, bXmasImages, bFestiveSnow, bDrawFaces, bShowSpectators, bShowCarrierLocation,
        bShowDamage, bShowRecords, RedFlag, BlueFlag, GreenFlag, YellowFlag, RedTeamHud, BlueTeamHud, GreenTeamHud, YellowTeamHud,
        PageSeconds,
         TextColor, AccentColor,
        TeamColors, StatLabels, StatEnabled, ActiveTeams,
        Profiles;
}

simulated function string FlagSkinName(byte Team)
{
    switch(Team) { case 0:return RedFlag; case 1:return BlueFlag; case 2:return GreenFlag; case 3:return YellowFlag; }
    return "";
}

simulated function string TeamHudName(byte Team)
{
    switch(Team) { case 0:return RedTeamHud; case 1:return BlueTeamHud; case 2:return GreenTeamHud; case 3:return YellowTeamHud; }
    return "";
}

static function int DateKey(string S)
{
    local int D, M, Limit, I;
    if (Len(S)==5) S=S$".";
    if (Len(S) != 6 || Mid(S,2,1) != "." || Right(S,1) != ".") return 0;
    for (I=0; I<5; I++)
        if (I != 2 && (Asc(Mid(S,I,1)) < 48 || Asc(Mid(S,I,1)) > 57)) return 0;
    D = int(Left(S,2)); M = int(Mid(S,3,2));
    if (M < 1 || M > 12) return 0;
    Limit = 31;
    if (M == 4 || M == 6 || M == 9 || M == 11) Limit = 30;
    if (M == 2) Limit = 29;
    if (D < 1 || D > Limit) return 0;
    return M * 100 + D;
}

static function bool InPeriod(int Today, string First, string Last)
{
    local int A, B;
    A = DateKey(First); B = DateKey(Last);
    if (A == 0 || B == 0) return False;
    if (A <= B) return Today >= A && Today <= B;
    return Today >= A || Today <= B;
}

function UpdateChristmas()
{
    local int Today;
    Today=Level.Month*100+Level.Day;
    bXmasActive=bXmasSB && InPeriod(Today,bXmasStart,bXmasEnd);
    bFestiveSnow=(Today==1224 || Today==1225 || Today==1231 || Today==101);
}

static function string Pad(int N)
{
    if (N < 10) return "0"$N;
    return string(N);
}

function ValidateSettings()
{
    LogoDrawTime=FClamp(LogoDrawTime,0,120);
    LogoDrawDelay=FClamp(LogoDrawDelay,0,120);
    LogoFadeInTime=FClamp(LogoFadeInTime,0,120);
    LogoFadeOutTime=FClamp(LogoFadeOutTime,0,120);
    IntroSoundDelay=FClamp(IntroSoundDelay,0,120);

    PageSeconds = FClamp(PageSeconds,3,60);
    if (DateKey(bXmasStart)==0 || DateKey(bXmasEnd)==0) Log("Invalid Christmas period; overlay disabled.",'SmartCTF');
    UpdateChristmas();
}

function LoadSettings(SmartCTF C)
{
    if (C==None) return;
    bDoKeybind=C.bDoKeybind;
    bExtraMsg=C.bExtraMsg;
    LogoTexture=C.LogoTexture;
    IntroSound=C.IntroSound;
    Position=C.Position;
    Size=C.Size;
    LogoDrawTime=C.LogoDrawTime;
    LogoDrawDelay=C.LogoDrawDelay;
    LogoFadeInTime=C.LogoFadeInTime;
    LogoFadeOutTime=C.LogoFadeOutTime;
    CaptionLineOne=C.CaptionLineOne;
    CaptionLineTwo=C.CaptionLineTwo;
    CaptionLineThree=C.CaptionLineThree;
    CaptionLineFour=C.CaptionLineFour;
    IntroSoundDelay=C.IntroSoundDelay;
    bLogoTranslucent=C.bLogoTranslucent;

    bXmasSB=C.bXmasSB; bXmasImages=C.bXmasImages;
    bXmasStart=C.bXmasStart; bXmasEnd=C.bXmasEnd;
    bShowCountryFlags=C.bShowCountryFlags;
    CountryFlagsPackage=C.CountryFlagsPackage;
    bDrawFaces=C.bDrawFaces;
    bShowSpectators=C.bShowSpectators;
    bShowCarrierLocation=C.bShowCarrierLocation;
    bShowDamage=C.bShowDamage;
    bShowRecords=C.bShowRecords;
    RedFlag=C.RedFlag;
    BlueFlag=C.BlueFlag;
    GreenFlag=C.GreenFlag;
    YellowFlag=C.YellowFlag;
    RedTeamHud=C.RedTeamHud;
    BlueTeamHud=C.BlueTeamHud;
    GreenTeamHud=C.GreenTeamHud;
    YellowTeamHud=C.YellowTeamHud;
    PageSeconds=C.PageSeconds;
}

defaultproperties
{
    bXmasSB=True
    bXmasImages=True
    bXmasStart="01.12."
    bXmasEnd="06.01."
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=2
    bDrawFaces=True
    bShowSpectators=True
    bShowCarrierLocation=True
    bShowDamage=True
    bShowRecords=True
    UIScale=1
    PanelWidth=0.87
    PanelHeight=0.90
    PageSeconds=7
    ActiveTeams=2
    TextColor=(R=255,G=255,B=255)
    AccentColor=(R=9,G=151,B=247)
    TeamColors(0)=(R=255,G=0,B=0)
    TeamColors(1)=(R=0,G=168,B=255)
    TeamColors(2)=(R=0,G=255,B=0)
    TeamColors(3)=(R=255,G=255,B=0)
    StatLabels(0)="Points"
    StatLabels(1)="Frags"
    StatLabels(2)="Captures"
    StatLabels(3)="Assists"
    StatLabels(4)="Grabs"
    StatLabels(5)="Returns"
    StatLabels(6)="Flag kills"
    StatLabels(7)="Covers"
    StatLabels(8)="Seals"
    StatLabels(9)="Defense kills"
    StatLabels(10)="Headshots"
    StatLabels(11)="Damage dealt"
    StatLabels(12)="Carrier seconds"
    StatLabels(13)="Shield belts"
    StatLabels(14)="Damage amps"
    StatLabels(15)="Best spree"
    StatLabels(16)="Deaths"
    StatEnabled(0)=1
    StatEnabled(1)=1
    StatEnabled(2)=1
    StatEnabled(3)=1
    StatEnabled(4)=1
    StatEnabled(5)=1
    StatEnabled(6)=1
    StatEnabled(7)=1
    StatEnabled(8)=1
    StatEnabled(9)=1
    StatEnabled(10)=1
    StatEnabled(11)=1
    StatEnabled(12)=1
    StatEnabled(13)=1
    StatEnabled(14)=1
    StatEnabled(15)=1
    StatEnabled(16)=1
}
