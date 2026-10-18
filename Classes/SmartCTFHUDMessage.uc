class SmartCTFHUDMessage extends LocalMessagePlus;

var SmartCTFNoticeData Pending[32];
var int NextSlot;

static function int Register(SmartCTFNoticeData D)
{
    local int Slot;
    Slot=Default.NextSlot;
    Default.Pending[Slot]=D;
    Default.NextSlot=(Slot+1)%32;
    return Slot;
}

static function Reset()
{
    local int I;
    for (I=0; I<32; I++) Default.Pending[I]=None;
    Default.NextSlot=0;
}

static function int GetFontSize(int Switch)
{
    local SmartCTFNoticeData D;
    D=class'SmartCTFHUDMessage'.default.Pending[Clamp(Switch,0,31)];
    // A zero-width native entry asks for its font on every rendered frame.
    // This callback means the stock HUD has accepted this slot for display.
    if (D!=None) D.bDrawRequested=True;
    if (D!=None && D.Category==2 && D.Index>0) return 2;
    return 1;
}

// Native ChallengeHUD caches a special message's color at insertion and supplies fading.
// Normal death messages render their profile color continuously through RenderComplexMessage.
static function Configure(SmartCTFMessageProfile P,byte Category)
{
    Default.DrawColor=P.BaseColor;
    Default.Lifetime=Clamp(int(P.Duration+0.5),1,15);
    Default.bFadeMessage=False;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo A, optional PlayerReplicationInfo B, optional Object OptionalObject)
{
    // Native queue owns priority, replacement and expiry. Text is painted once
    // in its original location with the current color by the HUD mutator.
    return "";
}

static function float GetOffset(int Switch,float YL,float ClipY)
{
    local SmartCTFNoticeData D;
    D=class'SmartCTFHUDMessage'.default.Pending[Clamp(Switch,0,31)];
    if (D!=None && D.Category==2) return class'MultiKillMessage'.static.GetOffset(D.Index+1,YL,ClipY);
    return class'CriticalEventPlus'.static.GetOffset(0,YL,ClipY);
}

defaultproperties
{
    FontSize=1
    bIsSpecial=True
    bIsUnique=True
    bFadeMessage=True
    bCenter=True
    bBeep=False
    YPos=196
}
