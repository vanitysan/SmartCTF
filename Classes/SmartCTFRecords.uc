class SmartCTFRecords extends ReplicationInfo;

var string RecordPlayer[17], RecordMap[17], RecordDate[17];
var int RecordValue[17];
var bool bRecordsPerHour;
var bool bCommitted;

replication
{
    reliable if (Role == ROLE_Authority)
        RecordPlayer,RecordMap,RecordDate,RecordValue,bRecordsPerHour;
}

function Commit(SmartCTFSettings Settings,int ActiveSeconds)
{
    if (bCommitted || Settings==None) return;
    UpdateRecords(Settings,ActiveSeconds);
    bCommitted=True;
}

function UpdateRecords(SmartCTFSettings Settings,int ActiveSeconds)
{
    local SmartCTFPlayerReplicationInfo S;
    local int I, N, Seconds;
    
    if (Settings == None) return;
    foreach AllActors(class'SmartCTFPlayerReplicationInfo',S)
    {
        if (S.PlayerInfo == None || class'SmartCTFScoreBoard'.static.IsRealSpectator(S.PlayerInfo)) continue;
        Seconds = Max(1,ActiveSeconds-S.SessionStart);
        for (I=0; I<17; I++)
        {
            N = S.Value(I);
            // Best spree is a run length, not an hourly rate.
            if (bRecordsPerHour && I != 15) N = float(N)*3600.0/Seconds;
            if (N <= RecordValue[I]) continue;
            RecordValue[I] = N;

            RecordPlayer[I] = S.PlayerInfo.PlayerName;
            RecordMap[I] = Level.Title;
            RecordDate[I] = Settings.Pad(Level.Day)$"."$Settings.Pad(Level.Month)$"."$Level.Year@Settings.Pad(Level.Hour)$":"$Settings.Pad(Level.Minute)$":"$Settings.Pad(Level.Second);
        }
    }
    SaveRecords();
}

function LoadSettings()
{
    local SmartCTFRecordStore Legacy;
    local SmartCTFEndStats Store;
    local int I;
    Legacy=new(None) class'SmartCTFRecordStore';
    bRecordsPerHour=class'SmartCTF'.default.bRecordsPerHour;
    if (bRecordsPerHour) Store=new(None) class'SmartCTFHourlyStats';
    else Store=new(None) class'SmartCTFEndStats';
    for (I=0; I<17; I++)
    {
        RecordValue[I]=Store.GetCount(I); RecordPlayer[I]=Store.GetPlayerName(I);
        RecordMap[I]=Store.GetMapName(I); RecordDate[I]=Store.GetRecordDate(I);
        // Import once into the bank matching the legacy mode; never overwrite named entries.
        if (I<ArrayCount(Legacy.RecordValue) && !Store.bInitialized && bRecordsPerHour==Legacy.bRecordsPerHour && RecordValue[I]==0 && RecordPlayer[I]=="")
        {
            RecordValue[I]=Legacy.RecordValue[I]; RecordPlayer[I]=Legacy.RecordPlayer[I];
            RecordMap[I]=Legacy.RecordMap[I]; RecordDate[I]=Legacy.RecordDate[I];
        }
    }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if (Role==ROLE_Authority) LoadSettings();
}

function SaveRecords()
{
    local SmartCTFEndStats Store, Other;
    local int I;
    if (bRecordsPerHour)
    { Store=new(None) class'SmartCTFHourlyStats'; Other=new(None) class'SmartCTFEndStats'; }
    else
    { Store=new(None) class'SmartCTFEndStats'; Other=new(None) class'SmartCTFHourlyStats'; }
    for (I=0; I<17; I++)
    {
        Store.SetRecord(I,RecordValue[I],RecordPlayer[I],RecordMap[I],RecordDate[I]);
    }
    Store.bInitialized=True;
    Store.SaveConfig();
    // Seal the unused bank too, so a later mode change cannot re-import the old values.
    if (!Other.bInitialized) { Other.bInitialized=True; Other.SaveConfig(); }
}

defaultproperties
{
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=1
    bRecordsPerHour=False
}
