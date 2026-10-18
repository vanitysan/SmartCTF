class SmartCTFDeathMessage extends DeathMessagePlus;

static function ClientReceive(PlayerPawn P, optional int Switch, optional PlayerReplicationInfo A, optional PlayerReplicationInfo B, optional Object OptionalObject)
{
    local SmartCTF M;
    foreach P.AllActors(class'SmartCTF',M) break;
    if (M==None || M.Settings==None) { Super.ClientReceive(P,Switch,A,B,OptionalObject); return; }
    // Preserve the original killer/victim feedback. Multikills are sent once by the server.
    if (A==P.PlayerReplicationInfo)
    {
        if (P.MyHUD!=None) P.MyHUD.LocalizedMessage(class'KillerMessagePlus',Switch,A,B,OptionalObject);
        if (ChallengeHUD(P.MyHUD)!=None) ChallengeHUD(P.MyHUD).ScoreTime=P.Level.TimeSeconds;
    }
    else if (B==P.PlayerReplicationInfo) P.ReceiveLocalizedMessage(class'VictimMessage',0,A);
    if (M.Settings.Profiles[2]==None || !M.Settings.Profiles[2].bEnabled)
    {
        if (TournamentPlayer(P)!=None && A==P.PlayerReplicationInfo)
        {
            if (A!=B && B!=None && Switch!=1)
            {
                if (P.Level.TimeSeconds-TournamentPlayer(P).LastKillTime<3)
                {
                    TournamentPlayer(P).MultiLevel++;
                    P.ReceiveLocalizedMessage(class'MultiKillMessage',TournamentPlayer(P).MultiLevel);
                }
                else TournamentPlayer(P).MultiLevel=0;
                TournamentPlayer(P).LastKillTime=P.Level.TimeSeconds;
            }
            else TournamentPlayer(P).MultiLevel=0;
        }
    }
    // Original UT death text, formatting and placement; no custom death profile.
    Super(LocalMessagePlus).ClientReceive(P,Switch,A,B,OptionalObject);
}
