class SmartCTFEndStats extends Object config(SmartCTF_4K_Records);
struct RecordEntry
{
    var int Count;
    var string PlayerName, MapName, RecordDate;
};
var config bool bInitialized;
var config RecordEntry MostPoints, MostFrags, MostCaps, MostAssists, MostGrabs, MostReturns, MostFlagKills, MostCovers, MostSeals, MostDefenseKills, MostHeadShots, MostDamage, MostCarrierSeconds, MostShieldBelts, MostDamageAmps, BestSpree, MostDeaths;
function int GetCount(int I)
{
    switch (I)
    {
        case 0: return MostPoints.Count;
        case 1: return MostFrags.Count;
        case 2: return MostCaps.Count;
        case 3: return MostAssists.Count;
        case 4: return MostGrabs.Count;
        case 5: return MostReturns.Count;
        case 6: return MostFlagKills.Count;
        case 7: return MostCovers.Count;
        case 8: return MostSeals.Count;
        case 9: return MostDefenseKills.Count;
        case 10: return MostHeadShots.Count;
        case 11: return MostDamage.Count;
        case 12: return MostCarrierSeconds.Count;
        case 13: return MostShieldBelts.Count;
        case 14: return MostDamageAmps.Count;
        case 15: return BestSpree.Count;
        case 16: return MostDeaths.Count;
    }
    return 0;
}
function string GetPlayerName(int I)
{
    switch (I)
    {
        case 0: return MostPoints.PlayerName;
        case 1: return MostFrags.PlayerName;
        case 2: return MostCaps.PlayerName;
        case 3: return MostAssists.PlayerName;
        case 4: return MostGrabs.PlayerName;
        case 5: return MostReturns.PlayerName;
        case 6: return MostFlagKills.PlayerName;
        case 7: return MostCovers.PlayerName;
        case 8: return MostSeals.PlayerName;
        case 9: return MostDefenseKills.PlayerName;
        case 10: return MostHeadShots.PlayerName;
        case 11: return MostDamage.PlayerName;
        case 12: return MostCarrierSeconds.PlayerName;
        case 13: return MostShieldBelts.PlayerName;
        case 14: return MostDamageAmps.PlayerName;
        case 15: return BestSpree.PlayerName;
        case 16: return MostDeaths.PlayerName;
    }
    return "";
}
function string GetMapName(int I)
{
    switch (I)
    {
        case 0: return MostPoints.MapName;
        case 1: return MostFrags.MapName;
        case 2: return MostCaps.MapName;
        case 3: return MostAssists.MapName;
        case 4: return MostGrabs.MapName;
        case 5: return MostReturns.MapName;
        case 6: return MostFlagKills.MapName;
        case 7: return MostCovers.MapName;
        case 8: return MostSeals.MapName;
        case 9: return MostDefenseKills.MapName;
        case 10: return MostHeadShots.MapName;
        case 11: return MostDamage.MapName;
        case 12: return MostCarrierSeconds.MapName;
        case 13: return MostShieldBelts.MapName;
        case 14: return MostDamageAmps.MapName;
        case 15: return BestSpree.MapName;
        case 16: return MostDeaths.MapName;
    }
    return "";
}
function string GetRecordDate(int I)
{
    switch (I)
    {
        case 0: return MostPoints.RecordDate;
        case 1: return MostFrags.RecordDate;
        case 2: return MostCaps.RecordDate;
        case 3: return MostAssists.RecordDate;
        case 4: return MostGrabs.RecordDate;
        case 5: return MostReturns.RecordDate;
        case 6: return MostFlagKills.RecordDate;
        case 7: return MostCovers.RecordDate;
        case 8: return MostSeals.RecordDate;
        case 9: return MostDefenseKills.RecordDate;
        case 10: return MostHeadShots.RecordDate;
        case 11: return MostDamage.RecordDate;
        case 12: return MostCarrierSeconds.RecordDate;
        case 13: return MostShieldBelts.RecordDate;
        case 14: return MostDamageAmps.RecordDate;
        case 15: return BestSpree.RecordDate;
        case 16: return MostDeaths.RecordDate;
    }
    return "";
}
function SetRecord(int I,int N,string Player,string Map,string Date)
{
    local RecordEntry E;
    E.Count=N; E.PlayerName=Player; E.MapName=Map; E.RecordDate=Date;
    switch (I)
    {
        case 0: MostPoints=E; break;
        case 1: MostFrags=E; break;
        case 2: MostCaps=E; break;
        case 3: MostAssists=E; break;
        case 4: MostGrabs=E; break;
        case 5: MostReturns=E; break;
        case 6: MostFlagKills=E; break;
        case 7: MostCovers=E; break;
        case 8: MostSeals=E; break;
        case 9: MostDefenseKills=E; break;
        case 10: MostHeadShots=E; break;
        case 11: MostDamage=E; break;
        case 12: MostCarrierSeconds=E; break;
        case 13: MostShieldBelts=E; break;
        case 14: MostDamageAmps=E; break;
        case 15: BestSpree=E; break;
        case 16: MostDeaths=E; break;
    }
}
