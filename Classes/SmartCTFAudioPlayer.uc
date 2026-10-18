class SmartCTFAudioPlayer extends Info;
var sound LastEffect;
var int PlayedCount;

simulated function PlayEffect(sound Effect,float Volume)
{
    if (Effect==None || Volume<=0) return;
    LastEffect=Effect; PlayedCount++;
    PlaySound(Effect,SLOT_Interface,FClamp(Volume,0,4),True);
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
