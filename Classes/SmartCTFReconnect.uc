class SmartCTFReconnect extends Info;
var SmartCTF Controller;
var SmartCTFReconnectEntry First;
var int EntryCount;

static function string HostAddress(string Address)
{
    local int I,Last,Colons;
    if (Left(Address,1)=="[")
    {
        I=InStr(Address,"]");
        if (I>0) return Caps(Mid(Address,1,I-1));
        return "";
    }
    for (I=0; I<Len(Address); I++) if (Mid(Address,I,1)==":") { Last=I; Colons++; }
    if (Colons==1) return Caps(Left(Address,Last));
    return Caps(Address);
}

function Register(Pawn P,SmartCTFPlayerReplicationInfo S)
{
    if (PlayerPawn(P)==None || S==None || S.PlayerInfo==None || S.PlayerInfo.bIsABot
        || class'SmartCTFScoreBoard'.static.IsRealSpectator(S.PlayerInfo)
        || NetConnection(PlayerPawn(P).Player)==None) return;
    RegisterIdentity(PlayerPawn(P),S,HostAddress(PlayerPawn(P).GetPlayerNetworkAddress()));
}

function RegisterIdentity(PlayerPawn P,SmartCTFPlayerReplicationInfo S,string Address)
{
    local SmartCTFReconnectEntry E,Free;
    if (Controller==None || !Controller.bRestorePlayerStats || Level.Game.bGameEnded
        || P==None || P.PlayerReplicationInfo==None || S==None || S.ReconnectEntry!=None
        || Address=="" || P.PlayerReplicationInfo.PlayerName=="") return;
    for (E=First; E!=None; E=E.NextEntry)
    {
        if (E.Player!=None && !E.Player.bDeleteMe) continue;
        if (E.bHasSnapshot && E.Address==Address && E.SavedName~=P.PlayerReplicationInfo.PlayerName)
        { E.Restore(P,S); return; }
        if (Free==None || E.LastSeen<Free.LastSeen) Free=E;
    }
    if (EntryCount<256)
    {
        E=Spawn(class'SmartCTFReconnectEntry');
        if (E==None) return;
        E.NextEntry=First; First=E; EntryCount++;
    }
    else E=Free;
    if (E==None) return;
    E.Manager=Self; E.Player=P; E.Stats=S; E.Address=Address;
    S.ReconnectEntry=E;
    E.Capture();
}

function UpdatePlayers()
{
    local Pawn P;
    local SmartCTFPlayerReplicationInfo S;
    local SmartCTFReconnectEntry E;
    if (Controller==None || !Controller.bRestorePlayerStats || Level.Game.bGameEnded) return;
    for (P=Level.PawnList; P!=None; P=P.NextPawn)
        if (PlayerPawn(P)!=None && P.PlayerReplicationInfo!=None)
        {
            S=Controller.EnsureStats(P);
            if (S!=None && S.ReconnectEntry==None) Register(P,S);
        }
    for (E=First; E!=None; E=E.NextEntry)
        if (E.Player!=None && !E.Player.bDeleteMe && E.Stats!=None
            && E.Stats.PlayerInfo!=None && !E.Stats.PlayerInfo.bDeleteMe) E.Capture();
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
