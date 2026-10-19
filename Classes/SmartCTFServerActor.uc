class SmartCTFServerActor extends Actor;

function PostBeginPlay()
{
    local SmartCTF M;
    Super.PostBeginPlay();
    if (CTFGame(Level.Game)!=None)
    {
        foreach AllActors(class'SmartCTF',M) break;
        if (M==None)
        {
            M=Spawn(class'SmartCTF');
            if (M!=None && !M.bDeleteMe) Level.Game.BaseMutator.AddMutator(M);
        }
    }
    Destroy();
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
}
