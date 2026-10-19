class SmartCTFReconnectEntry extends Info;
var SmartCTFReconnectEntry NextEntry;
var SmartCTFReconnect Manager;
var PlayerPawn Player;
var SmartCTFPlayerReplicationInfo Stats;
var string Address, SavedName;
var float SavedScore, SavedDeaths, ActiveSeconds, PlayedSeconds, LastSeen;
var bool bHasSnapshot;
var int Captures, Assists, Grabs, Returns, FlagKills, Covers, Seals, DefKills, Frags, HeadShots, DamageDealt, ShieldBelts, Amps, BestSpree;
var float CarrierSeconds;

function Capture()
{
    local PlayerReplicationInfo PRI;
    if (Stats==None || Manager==None) return;
    PRI=Stats.PlayerInfo;
    if (PRI!=None)
    {
        SavedScore=PRI.Score; SavedDeaths=PRI.Deaths; SavedName=PRI.PlayerName;
        PlayedSeconds=FMax(0,Level.TimeSeconds-PRI.StartTime);
    }
    ActiveSeconds=FMax(0,Manager.Controller.MatchSeconds-Stats.SessionStart);
    LastSeen=Level.TimeSeconds;
    Captures=Stats.Captures;
    Assists=Stats.Assists;
    Grabs=Stats.Grabs;
    Returns=Stats.Returns;
    FlagKills=Stats.FlagKills;
    Covers=Stats.Covers;
    Seals=Stats.Seals;
    DefKills=Stats.DefKills;
    Frags=Stats.Frags;
    HeadShots=Stats.HeadShots;
    DamageDealt=Stats.DamageDealt;
    ShieldBelts=Stats.ShieldBelts;
    Amps=Stats.Amps;
    BestSpree=Stats.BestSpree;
    CarrierSeconds=Stats.CarrierSeconds;
    bHasSnapshot=True;
}

function Restore(PlayerPawn P,SmartCTFPlayerReplicationInfo S)
{
    if (Stats!=None) Stats.ReconnectEntry=None;
    P.PlayerReplicationInfo.Score=SavedScore;
    P.PlayerReplicationInfo.Deaths=SavedDeaths;
    P.PlayerReplicationInfo.StartTime=Level.TimeSeconds-PlayedSeconds;
    S.SessionStart=int(Manager.Controller.MatchSeconds-ActiveSeconds);
    S.Captures=Captures;
    S.Assists=Assists;
    S.Grabs=Grabs;
    S.Returns=Returns;
    S.FlagKills=FlagKills;
    S.Covers=Covers;
    S.Seals=Seals;
    S.DefKills=DefKills;
    S.Frags=Frags;
    S.HeadShots=HeadShots;
    S.DamageDealt=DamageDealt;
    S.ShieldBelts=ShieldBelts;
    S.Amps=Amps;
    S.BestSpree=BestSpree;
    S.CarrierSeconds=CarrierSeconds;
    // A reconnect cannot revive a timed multikill window or a carried flag.
    S.MultiLevel=0; S.LastKillTime=-100;
    S.FragSpree=0; S.CoverSpree=0; S.SealSpree=0; S.SpawnKillSpree=0;
    Player=P; Stats=S; S.ReconnectEntry=Self;
    Log("Restored match statistics for "$P.PlayerReplicationInfo.PlayerName,'SmartCTF');
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
