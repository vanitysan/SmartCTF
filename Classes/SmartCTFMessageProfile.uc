class SmartCTFMessageProfile extends ReplicationInfo;

var bool bEnabled, bAnimateColor, bRainbow;
var color BaseColor, SecondColor;
var float Duration, ColorSpeed;
var string Texts[9];
var string SoundNames[9];
var byte EntryCount;
var class<SmartCTFProfileConfig> ConfigClass;

replication
{
    reliable if (Role == ROLE_Authority)
        bEnabled,bAnimateColor,bRainbow,BaseColor,SecondColor,
        Duration,ColorSpeed,Texts,SoundNames,EntryCount;
}

simulated function color AnimatedColor(float T)
{
    local color Result;
    local float F;
    if (!bAnimateColor) return BaseColor;
    T *= FClamp(ColorSpeed,0.1,10);
    if (bRainbow)
    {
        Result.R = 128 + 127 * Sin(T);
        Result.G = 128 + 127 * Sin(T+2.0944);
        Result.B = 128 + 127 * Sin(T+4.1888);
        return Result;
    }
    F = 0.5 + 0.5 * Sin(T);
    Result.R = BaseColor.R * F + SecondColor.R * (1-F);
    Result.G = BaseColor.G * F + SecondColor.G * (1-F);
    Result.B = BaseColor.B * F + SecondColor.B * (1-F);
    return Result;
}

static function string ReplaceToken(string S, string Token, string Value)
{
    local int I, N;
    local string Result;
    // Do not rescan substituted player names (names may contain token syntax).
    I = InStr(S,Token);
    while (I >= 0 && N++ < 32)
    {
        Result = Result $ Left(S,I) $ Value;
        S = Mid(S,I+Len(Token));
        I = InStr(S,Token);
    }
    return Result $ S;
}

simulated function string FormatText(int Index, string PlayerName, string VictimName, string WeaponName, int Count)
{
    local string S;
    if (Index < 0 || Index >= EntryCount) return "";
    S = Texts[Index];
    S = ReplaceToken(S,"{count}",string(Count));
    S = ReplaceToken(S,"{weapon}",WeaponName);
    S = ReplaceToken(S,"{victim}",VictimName);
    return ReplaceToken(S,"{player}",PlayerName);
}

function PostBeginPlay()
{
    local SmartCTFProfileConfig C;
    local int I;
    Super.PostBeginPlay();
    if (Role!=ROLE_Authority || ConfigClass==None) return;
    C=new(None) ConfigClass;
    for (I=0; I<EntryCount; I++)
    {
        Texts[I]=C.GetText(I);
        SoundNames[I]=C.GetSound(I);
    }
    bEnabled=C.bEnabled;
    bAnimateColor=C.bAnimateColor;
    bRainbow=C.bRainbow;
    BaseColor=C.BaseColor;
    SecondColor=C.SecondColor;
    Duration=C.Duration;
    ColorSpeed=C.ColorSpeed;
}

defaultproperties
{
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=2
    bEnabled=True
    bAnimateColor=True
    BaseColor=(R=255,G=210,B=80)
    SecondColor=(R=255,G=100,B=40)
    Duration=3
    ColorSpeed=3
}

