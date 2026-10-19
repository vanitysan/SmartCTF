class SmartCTFPlayerReplicationInfo extends ReplicationInfo;

var PlayerReplicationInfo PlayerInfo;
var SmartCTFReconnectEntry ReconnectEntry;
var int Captures, Assists, Grabs, Returns, FlagKills, Covers, Seals, DefKills;
var int Frags, HeadShots, DamageDealt;
var int ShieldBelts, Amps, BestSpree;
var float CarrierSeconds, SpawnTime, LastKillTime;
var int FragSpree, MultiLevel;
var int CoverSpree,SealSpree,SpawnKillSpree;
var bool bSpawnProtected;
var int SessionStart;
var string CountryPrefix;
// Address and resolver stay on the server; only the country code is replicated.
var Actor CountryResolver;
var bool bCountryDone;
var int CountryAttempts;
var float NextResolverSearch;
var string CachedCountryPath;
var texture CachedCountryFlag;

replication
{
    reliable if (Role == ROLE_Authority)
        CountryPrefix,PlayerInfo,Captures,Assists,Grabs,Returns,FlagKills,Covers,Seals,DefKills,
        Frags,HeadShots,DamageDealt,ShieldBelts,Amps,
        BestSpree,CarrierSeconds,SessionStart;
}

function Destroyed()
{
    if (Role==ROLE_Authority && ReconnectEntry!=None)
    {
        ReconnectEntry.Capture();
        ReconnectEntry.Player=None;
        ReconnectEntry.Stats=None;
    }
    Super.Destroyed();
}

function Timer()
{
    if (PlayerInfo == None || PlayerInfo.bDeleteMe) { Destroy(); return; }
    ResolveCountry();
}

static function string CountryCode(string Reply)
{
    local int I, Pos, Ch;
    if (Reply=="" || Left(Reply,1)=="!") return "";
    // Same colon-separated resolver protocol as 4H: country code is field five.
    for (I=0; I<4; I++)
    {
        Pos=InStr(Reply,":"); if (Pos<0) return "";
        Reply=Mid(Reply,Pos+1);
    }
    Pos=InStr(Reply,":"); if (Pos>=0) Reply=Left(Reply,Pos);
    Reply=Caps(Reply);
    if (Len(Reply)<2 || Len(Reply)>3) return "";
    for (I=0; I<Len(Reply); I++)
    {
        Ch=Asc(Mid(Reply,I,1)); if (Ch<65 || Ch>90) return "";
    }
    return Reply;
}

function ResolveCountry()
{
    local PlayerPawn P;
    local Actor A;
    local string Address, Reply;
    local int Pos;
    if (Role!=ROLE_Authority || bCountryDone || !class'SmartCTF'.default.bShowCountryFlags) return;
    P=PlayerPawn(PlayerInfo.Owner);
    if (PlayerInfo.bIsABot || P==None || NetConnection(P.Player)==None)
    { bCountryDone=True; return; }
    if (CountryResolver==None || CountryResolver.bDeleteMe)
    {
        if (Level.TimeSeconds<NextResolverSearch) return;
        NextResolverSearch=Level.TimeSeconds+10;
        CountryResolver=None;
        foreach AllActors(class'Actor',A,'IpToCountry') { CountryResolver=A; break; }
        if (CountryResolver==None) return;
    }
    Address=P.GetPlayerNetworkAddress();
    Pos=InStr(Address,":"); if (Pos>=0) Address=Left(Address,Pos);
    if (Address=="") return;
    Reply=CountryResolver.GetItemName(Address);
    CountryAttempts++;
    if (Reply=="!Disabled" || CountryAttempts>=120) bCountryDone=True;
    if (Reply=="" || Left(Reply,1)=="!") return;
    CountryPrefix=CountryCode(Reply);
    bCountryDone=True;
}

simulated function texture CountryFlag(string PackageName)
{
    local string Path;
    if (CountryPrefix=="" || PackageName=="") return None;
    Path=PackageName$"."$CountryPrefix;
    if (Path!=CachedCountryPath)
    {
        CachedCountryPath=Path;
        CachedCountryFlag=texture(DynamicLoadObject(Path,class'Texture',True));
    }
    return CachedCountryFlag;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Role == ROLE_Authority) SetTimer(2,True);
}

simulated function int Value(int I)
{
    switch(I)
    {
        case 0: if (PlayerInfo != None) return int(PlayerInfo.Score); return 0;
        case 1: return Frags;
        case 2: return Captures;
        case 3: return Assists;
        case 4: return Grabs;
        case 5: return Returns;
        case 6: return FlagKills;
        case 7: return Covers;
        case 8: return Seals;
        case 9: return DefKills;
        case 10: return HeadShots;
        case 11: return DamageDealt;
        case 12: return int(CarrierSeconds);
        case 13: return ShieldBelts;
        case 14: return Amps;
        case 15: return BestSpree;
        case 16: if (PlayerInfo!=None) return int(PlayerInfo.Deaths); return 0;
    }
    return 0;
}

defaultproperties
{
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=4
    LastKillTime=-100
}
