class SmartCTFClientNotices extends Info;

struct Notice
{
    var byte Category;
    var int Index, Count;
    var bool OwnSound;
    var string PlayerName, VictimName;
    var float Expires;
};
var Notice Pending[32];
var int Head, Size;

simulated function Enqueue(byte Category,int Index,int Count,bool OwnSound,PlayerReplicationInfo A,PlayerReplicationInfo B)
{
    local int Slot;
    if ((Category!=0 && Category!=2) || Index<0 || Index>=9 || (Category==2 && Index>=6)) return;
    if (Size==ArrayCount(Pending))
    { Head=(Head+1)%ArrayCount(Pending); Size--; }
    Slot=(Head+Size)%ArrayCount(Pending);
    Pending[Slot].Category=Category; Pending[Slot].Index=Index;
    Pending[Slot].Count=Count; Pending[Slot].OwnSound=OwnSound;
    Pending[Slot].PlayerName=""; Pending[Slot].VictimName="";
    if (A!=None) Pending[Slot].PlayerName=A.PlayerName;
    if (B!=None) Pending[Slot].VictimName=B.PlayerName;
    Pending[Slot].Expires=Level.TimeSeconds+10;
    Size++;
    Flush();
}

simulated function Flush()
{
    local SmartCTF M;
    local SmartCTFMessageProfile Profile;
    local PlayerPawn P;
    local int Remaining;
    P=PlayerPawn(Owner);
    if (P==None || P.bDeleteMe) { Destroy(); return; }
    foreach AllActors(class'SmartCTF',M)
        if (M.LocalPlayer==P) break;
    Remaining=Size;
    while (Remaining-->0 && Size>0)
    {
        Profile=None;
        if (M!=None && M.LocalPlayer==P && M.Settings!=None && P.MyHUD!=None)
            Profile=M.Settings.Profiles[Pending[Head].Category];
        if (Profile!=None && (!Profile.bEnabled || Profile.Texts[Pending[Head].Index]!=""))
        {
            if (Profile.bEnabled)
                M.AddNotice(Pending[Head].Category,Pending[Head].Index,Pending[Head].PlayerName,
                    Pending[Head].VictimName,"",Pending[Head].Count,Pending[Head].OwnSound);
        }
        else if (Level.TimeSeconds<Pending[Head].Expires)
        {
            // A deliberately blank entry must not hold up other messages.
            Pending[(Head+Size)%ArrayCount(Pending)]=Pending[Head];
            Head=(Head+1)%ArrayCount(Pending);
            continue;
        }
        else if (Profile==None)
            Log("Message expired waiting for client HUD/settings (category=" $Pending[Head].Category$").",'SmartCTF');
        Head=(Head+1)%ArrayCount(Pending); Size--;
    }
}

simulated function Tick(float Delta)
{
    if (Size>0) Flush();
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
}
