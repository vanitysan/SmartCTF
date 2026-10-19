class SmartCTFAudioPlayer extends Info;
var sound LastEffect;
var int PlayedCount;

simulated function PlayEffect(sound Effect)
{
    local PlayerPawn P;
    P=PlayerPawn(Owner);
    if (Effect==None || P==None) return;
    LastEffect=Effect; PlayedCount++;
    P.ClientPlaySound(Effect,,True);
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
