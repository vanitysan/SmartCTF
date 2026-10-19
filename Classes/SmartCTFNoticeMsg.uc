class SmartCTFNoticeMsg extends LocalMessagePlus;

static function int Pack(byte Category,int Index,int Count,bool OwnSound)
{
    local int Value;
    Value=Clamp(Count,0,16777215)*128+Index*8+Category*2;
    if (OwnSound) Value++;
    return Value;
}

static simulated function ClientReceive(PlayerPawn P,optional int Switch,
    optional PlayerReplicationInfo A,optional PlayerReplicationInfo B,optional Object OptionalObject)
{
    local SmartCTFClientNotices Queue;
    if (P==None || Viewport(P.Player)==None) return;
    foreach P.AllActors(class'SmartCTFClientNotices',Queue)
        if (Queue.Owner==P) break;
    if (Queue==None) Queue=P.Spawn(class'SmartCTFClientNotices',P);
    if (Queue!=None) Queue.Enqueue((Switch/2)%4,(Switch/8)%16,Switch/128,Switch%2==1,A,B);
}

defaultproperties
{
    bIsConsoleMessage=False
    bBeep=False
}
