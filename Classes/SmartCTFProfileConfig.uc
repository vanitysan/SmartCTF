class SmartCTFProfileConfig extends Object config(SmartCTF_4J);

var config bool bEnabled, bAnimateColor, bRainbow;
var config color BaseColor, SecondColor;
var config float Duration, ColorSpeed;

function string GetText(int Index) { return ""; }
function string GetSound(int Index) { return ""; }

defaultproperties
{
    bEnabled=True
    bAnimateColor=True
    BaseColor=(R=255,G=210,B=80)
    SecondColor=(R=255,G=100,B=40)
    Duration=3
    ColorSpeed=3
}
