class SmartCTFVisualFlag extends Actor;
var CTFFlag Flag;
var SmartCTF Controller;
var texture OriginalSkin, AppliedSkin;
var FlagBase VisibleBase;
var texture OriginalBaseSkin;
var bool bSaved;
var string LastPath;

simulated function Tick(float Delta)
{
    local string Path;
    local FlagBase B;
    if (Flag==None || Flag.bDeleteMe || Flag.Team>=4 || Controller==None || Controller.Settings==None) return;
    if (!bSaved) { OriginalSkin=Flag.Skin; bSaved=True; }
    if (VisibleBase==None)
        foreach AllActors(class'FlagBase',B)
            if (B.Team==Flag.Team) { VisibleBase=B; OriginalBaseSkin=B.Skin; break; }
    Path=Controller.Settings.FlagSkinName(Flag.Team);
    if (Path!=LastPath)
    {
        LastPath=Path; AppliedSkin=None;
        if (Path!="") AppliedSkin=texture(DynamicLoadObject(Path,class'Texture',True));
        if (Path!="" && AppliedSkin==None) Log("Cannot load flag skin: "$Path,'SmartCTF');
        if (AppliedSkin==None)
        {
            Flag.Skin=OriginalSkin;
            if (VisibleBase!=None) VisibleBase.Skin=OriginalBaseSkin;
        }
    }
    if (AppliedSkin!=None) Flag.Skin=AppliedSkin;
    // At home UT draws FlagBase.newflag while CTFFlag.pflag is hidden.
    if (AppliedSkin!=None && VisibleBase!=None) VisibleBase.Skin=AppliedSkin;
}

simulated function Destroyed()
{
    if (Flag!=None && bSaved && Flag.Skin==AppliedSkin) Flag.Skin=OriginalSkin;
    if (VisibleBase!=None && VisibleBase.Skin==AppliedSkin) VisibleBase.Skin=OriginalBaseSkin;
    Super.Destroyed();
}
defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
