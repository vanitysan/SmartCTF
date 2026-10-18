class SmartCTFEndNotifier extends Info;
function Trigger(Actor Other,Pawn EventInstigator)
{
    if (SmartCTF(Owner)!=None && Level.Game!=None && Level.Game.bGameEnded)
        SmartCTF(Owner).SaveEndRecords();
}
defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
}
