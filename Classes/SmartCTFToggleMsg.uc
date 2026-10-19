class SmartCTFToggleMsg extends LocalMessagePlus;

static simulated function ClientReceive(PlayerPawn P,optional int Switch,optional PlayerReplicationInfo A,optional PlayerReplicationInfo B,optional Object O)
{
    local SmartCTF M;
    if (P==None || Viewport(P.Player)==None) return;
    foreach P.AllActors(class'SmartCTF',M)
        if (M.LocalPlayer==P) { M.ToggleInterfaces(); break; }
}
