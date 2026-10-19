class SmartCTFMultiConfig extends SmartCTFProfileConfig config(SmartCTF_4K);

var config string Texts[6], SoundNames[6];

function string GetText(int Index)
{
    if (Index < 0 || Index >= 6) return "";
    return Texts[Index];
}
function string GetSound(int Index)
{
    if (Index < 0 || Index >= 6) return "";
    return SoundNames[Index];
}

defaultproperties
{
    Texts(0)="DOUBLE KILL!"
    Texts(1)="TRIPLE KILL!"
    Texts(2)="MULTI KILL!"
    Texts(3)="MEGA KILL!"
    Texts(4)="ULTRA KILL!"
    Texts(5)="MONSTER KILL! ({count})"
    BaseColor=(R=255,G=90,B=60)
    SoundNames(0)="Announcer.doublekill"
    SoundNames(1)="Announcer.triplekill"
    SoundNames(2)="Announcer.multikill"
    SoundNames(3)="Announcer.megakill"
    SoundNames(4)="Announcer.ultrakill"
    SoundNames(5)="Announcer.monsterkill"
    bEnabled=True
    bAnimateColor=True
    SecondColor=(R=60,G=100,B=255)
    Duration=4
    ColorSpeed=3
    bRainbow=False
}
