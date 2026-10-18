class SmartCTFSpreeConfig extends SmartCTFProfileConfig config(SmartCTF_4J);

#exec AUDIO IMPORT FILE="Sounds\holyshit.wav" NAME="Holyshit"

var config string Texts[9], SoundNames[9];

function string GetText(int Index)
{
    if (Index < 0 || Index >= 9) return "";
    return Texts[Index];
}
function string GetSound(int Index)
{
    if (Index < 0 || Index >= 9) return "";
    return SoundNames[Index];
}

defaultproperties
{
    Texts(0)="{player} is on a killing spree! ({count})"
    Texts(1)="{player} is on a rampage! ({count})"
    Texts(2)="{player} is dominating! ({count})"
    Texts(3)="{player} is unstoppable! ({count})"
    Texts(4)="{player} is GODLIKE! ({count})"
    Texts(5)="This is just too easy for {player}! ({count})"
    Texts(6)="{player} is Brutalizing the Competition! ({count})"
    Texts(7)="{player} ended the spree of {victim}! ({count})"
    Texts(8)="{player} ended their own spree! ({count})"
    BaseColor=(R=255,G=200,B=60)
    SoundNames(0)="Announcer.killingspree"
    SoundNames(1)="Announcer.rampage"
    SoundNames(2)="Announcer.dominating"
    SoundNames(3)="Announcer.unstoppable"
    SoundNames(4)="Announcer.godlike"
    SoundNames(5)="Botpack.SpreeSound"
    SoundNames(6)="SmartCTF_4J.Holyshit"
    bEnabled=True
    bAnimateColor=True
    SecondColor=(R=255,G=100,B=40)
    Duration=4
    ColorSpeed=3
    bRainbow=True
    SoundNames(7)="Botpack.SpreeSound"
    SoundNames(8)="Announcer.failed"
}
