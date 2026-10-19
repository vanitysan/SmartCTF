// SmartCTF is a MOD that changes the point system and adds features to ultimately promote Teamwork in CTF.
// This Mod will only load for CTF, no other Gametype is supported
//*************************************************************
// Version History:
// v4       - {PiN}Kev                              (2004/01)
// v4A      - {DnF2}SiNiSTeR                        (2004/12)
// v4B/C    - {DnF2}SiNiSTeR                        (2005/03)
// v4D      - [es]Rush                              (2006/01)
// v4D++    - adminthis                             (2008/10)
// v4E      - adminthis, The_Cowboy & Sp0ngeb0b     (2009/12)
// v4G      - vanitysan aka HanNibaL                (2025/02)
// v4H      - vanitysan aka HanNibaL                (2025/08)
// v4I      - vanitysan aka HanNibaL                (2026/05)
// v4J      - vanitysan aka HanNibaL                (2026/10)
// v4K      - vanitysan aka HanNibaL                (2026/10)
//*************************************************************
// Contact Info:
// {PiN}Hai-Ping       http://forums.prounreal.com
// {DnF2}SiNiSTeR      #DutchNet [QuakeNet IRC]
// Rush               unrealadmin.org / rush@u.one.pl
// adminthis          unrealadmin.org
// The_Cowboy          unrealadmin.org
// Sp0ngeb0b           unrealadmin.org / spongebobut@yahoo.com
// vanitysan          Discord @ OldUnreal
//*************************************************************
// CHANGELOG: See Readme
//*************************************************************
class SmartCTF extends Mutator config(SmartCTF_4K);

#exec AUDIO IMPORT FILE="Sounds\start.wav" NAME="Start"

var config bool bXmasSB;
var config string bXmasStart, bXmasEnd;
var config bool bPlayCaptureSound, bPlayAssistSound, bPlaySavedSound, bPlayLeadSound;
var config bool bShowLongRangeMsg, bShowSpawnKillerGlobalMsg;
var config byte CoverMsgType, CoverSpreeMsgType, SealMsgType, SavedMsgType;
var config bool bRecordsPerHour;
var config bool bShowCountryFlags;
var config string CountryFlagsPackage;
var config bool bEnabled, bSmartScoring, bCountWarmup, bSpawnkillDetection;
var config int CapBonus, AssistBonus, GrabBonus, FlagKillBonus, CoverBonus, SealBonus, SpawnKillPenalty;
var config float ReturnBonus, CloseSaveBonus, CoverRadius, CloseSaveRadius;
var config float MultiKillWindow, SpawnProtectionSeconds;
var config bool bDrawFaces, bShowSpectators, bShowCarrierLocation;
var config bool bShowDamage, bShowRecords;
var config string RedFlag, BlueFlag, GreenFlag, YellowFlag, RedTeamHud, BlueTeamHud, GreenTeamHud, YellowTeamHud;
var config float PageSeconds;
var SmartCTFSettings Settings;
var config bool bDoKeybind, bExtraMsg, bRestorePlayerStats;
var config string LogoTexture, IntroSound;
var config float LogoDrawDelay, LogoFadeInTime, LogoFadeOutTime, IntroSoundDelay;
var config string CaptionLineOne, CaptionLineTwo, CaptionLineThree, CaptionLineFour;
var config bool bLogoTranslucent;
var config float LogoDrawTime;
var config string Position, Size;
var bool bDefaultInterfaces, bKeybindDone, bJoinPresentationDone;
var float JoinPresentationTime;
var texture SplashTexture;
var sound SplashSound;
var bool bIntroSoundPlayed;
var SmartCTFReconnect Reconnect;

var SmartCTFRecords Records;
var CTFFlag Flags[4];
var vector Bases[4];
var byte HasBase[4];
var PlayerReplicationInfo Contributors[256];
var byte ContributorFlag[256];
var byte LastHome[4];
var PlayerReplicationInfo LastCarrier[4];
var float LastStep;
var bool bEndSaved;
var float MatchSeconds;
var SmartCTFEndNotifier EndNotifier;
var PlayerPawn LocalPlayer;
var SmartCTFScoreBoard ClientBoard;
var SmartCTFServerInfo ClientInfo;
var HUD BoundHUD;
var ScoreBoard PreviousBoard;
var ServerInfo PreviousInfo;
var class<ScoreBoard> PreviousScoringType;
var SmartCTFVisualFlag VisualFlags[4];
var SmartCTFUI UI;
var SmartCTFAudioPlayer AudioPlayer;
var bool bLogoStarted;
var float LogoStartTime;

struct PickupCheck
{
    var Inventory Item;
    var Pawn Player;
    var int OldCharge;
    var Inventory OldOwned;
};
var PickupCheck PendingPickups[64];
var int NextPickup;

replication
{
    reliable if (Role == ROLE_Authority) Settings, Records;
}

function PreBeginPlay()
{
    local Mutator M;
    Super.PreBeginPlay();
    if (!bEnabled || CTFGame(Level.Game) == None) { Destroy(); return; }
    for (M=Level.Game.BaseMutator; M!=None; M=M.NextMutator)
        if (M!=Self && M.Class==Class) { Destroy(); return; }

}

function PostBeginPlay()
{
    local int I;
    local SmartCTFMessageProfile P;
    Super.PostBeginPlay();
    if (bDeleteMe) return;
    EndNotifier=Spawn(class'SmartCTFEndNotifier',Self,'EndGame');
    Settings = Spawn(class'SmartCTFSettings');
    Records = Spawn(class'SmartCTFRecords');
    if (Settings==None || Records==None) { Log("Failed to create configuration actors",'SmartCTF'); Destroy(); return; }
    Settings.LoadSettings(Self);
    Settings.ValidateSettings();
    for (I=0; I<3; I++)
    {
        // Named instances load separate, documented INI sections.
        switch(I)
        {
            case 0: P=Spawn(class'SmartCTFSpreeProfile'); break;
            case 1: P=None; break;
            case 2: P=Spawn(class'SmartCTFMultiProfile'); break;
        }
        if (P != None) Settings.Profiles[I]=P;
    }
    Level.Game.RegisterMessageMutator(Self);
    Level.Game.DeathMessageClass=class'SmartCTFDeathMessage';
    Level.Game.RegisterDamageMutator(Self);
    if (bRestorePlayerStats) { Reconnect=Spawn(class'SmartCTFReconnect'); if (Reconnect!=None) Reconnect.Controller=Self; }
    DiscoverFlags();
    LastStep=Level.TimeSeconds;
    SetTimer(0.25,True);
    LogStartup();
}

function DiscoverFlags()
{
    local CTFFlag F;
    local int N;
    N=2;
    foreach AllActors(class'CTFFlag',F)
        if (F.Team<4)
        {
            Flags[F.Team]=F;
            if (F.HomeBase!=None) { Bases[F.Team]=F.HomeBase.Location; HasBase[F.Team]=1; }
            N=Max(N,int(F.Team)+1);
        }
    if (N>2) Settings.ActiveTeams=4;
    else Settings.ActiveTeams=2;
}

simulated function SmartCTFPlayerReplicationInfo Stats(PlayerReplicationInfo PRI)
{
    local SmartCTFPlayerReplicationInfo S;
    if (PRI==None) return None;
    foreach AllActors(class'SmartCTFPlayerReplicationInfo',S)
        if (S.PlayerInfo==PRI) return S;
    return None;
}

function SmartCTFPlayerReplicationInfo EnsureStats(Pawn P)
{
    local SmartCTFPlayerReplicationInfo S;
    if (P==None || P.PlayerReplicationInfo==None || !P.bIsPlayer) return None;
    S=Stats(P.PlayerReplicationInfo);
    if (S==None)
    {
        S=Spawn(class'SmartCTFPlayerReplicationInfo',P.PlayerReplicationInfo);
        if (S!=None)
        {
            S.PlayerInfo=P.PlayerReplicationInfo;
            S.SessionStart=int(MatchSeconds);
            if (Reconnect!=None) Reconnect.Register(P,S);
        }
    }
    return S;
}

function ModifyPlayer(Pawn Other)
{
    local SmartCTFPlayerReplicationInfo S;
    Super.ModifyPlayer(Other);
    S=EnsureStats(Other);
    if (S!=None) { S.SpawnTime=Level.TimeSeconds; S.bSpawnProtected=True; }
}

function bool Counting()
{
    if (Level.Game.bGameEnded) return False;
    if (bCountWarmup) return True;
    return !Level.Game.IsInState('PendingMatch');
}

function AddContributor(PlayerReplicationInfo PRI, byte FlagTeam)
{
    local int I, Free;
    Free=-1;
    if (PRI==None || FlagTeam>=4) return;
    for (I=0; I<256; I++)
    {
        if (Contributors[I]==PRI && ContributorFlag[I]==FlagTeam) return;
        if ((Contributors[I]==None || Contributors[I].bDeleteMe) && Free<0) Free=I;
    }
    if (Free>=0) { Contributors[Free]=PRI; ContributorFlag[Free]=FlagTeam; }
}

function ClearRun(byte FlagTeam)
{
    local int I;
    if (FlagTeam>=4) return;
    LastCarrier[FlagTeam]=None;
    for (I=0; I<256; I++)
        if (ContributorFlag[I]==FlagTeam) Contributors[I]=None;
}

function NoticeTo(Pawn P, byte Category, int Index, PlayerReplicationInfo A, optional PlayerReplicationInfo B, optional string WeaponName, optional int Count)
{
    local bool OwnSound;
    if (PlayerPawn(P)==None || (Category!=0 && Category!=2) || Index<0 || Index>=9 || (Category==2 && Index>=6)) return;
    OwnSound=(A!=None && A==P.PlayerReplicationInfo);
    if (Category==0 && Index>=7) OwnSound=(B!=None && B==P.PlayerReplicationInfo);
    PlayerPawn(P).ReceiveLocalizedMessage(class'SmartCTFNoticeMsg',
        class'SmartCTFNoticeMsg'.static.Pack(Category,Index,Count,OwnSound),A,B);
}

function NotifyAll(byte Category, int Index, PlayerReplicationInfo A, optional PlayerReplicationInfo B, optional int Count)
{
    local Pawn P;
    for (P=Level.PawnList; P!=None; P=P.NextPawn) NoticeTo(P,Category,Index,A,B,"",Count);
}

// Localized messages execute ClientReceive on the intended client, including dedicated servers.
function AudioTo(Pawn P,int Event)
{
    if (PlayerPawn(P)!=None) P.ReceiveLocalizedMessage(class'SmartCTFAudioMsg',Event);
}

function LegacyNotice(byte Mode,int Event,PlayerReplicationInfo PRI,optional PlayerReplicationInfo Other)
{
    if (PRI==None) return;
    if (Mode==1 && PlayerPawn(PRI.Owner)!=None)
        PlayerPawn(PRI.Owner).ClientMessage(class'SmartCTFMessage'.static.GetString(Event+64,PRI,Other));
    else if (Mode==2) BroadcastMessage(class'SmartCTFMessage'.static.GetString(Event,PRI,Other));
    else if (Mode==3) BroadcastLocalizedMessage(class'SmartCTFMessage',Event,PRI,Other);
}

function ResetSupportSprees()
{
    local SmartCTFPlayerReplicationInfo S;
    foreach AllActors(class'SmartCTFPlayerReplicationInfo',S) { S.CoverSpree=0; S.SealSpree=0; }
}

// Scores have already changed when CTF broadcasts the capture. Reconstruct the previous leader.
function int UniqueLeader(byte ScoringTeam,int Captures,bool BeforeCapture)
{
    local int I,Leader;
    local float Best,Score;
    local bool Tie;
    local TeamGamePlus G;
    G=TeamGamePlus(Level.Game); Leader=-1; Best=-1000000;
    if (G==None) return -1;
    for (I=0; I<4; I++) if (HasBase[I]!=0 && G.Teams[I]!=None)
    {
        Score=G.Teams[I].Score;
        if (BeforeCapture && I==ScoringTeam) Score-=Captures;
        if (Score>Best) { Best=Score; Leader=I; Tie=False; }
        else if (Score==Best) Tie=True;
    }
    if (Tie) return -1;
    return Leader;
}

function bool CaptureAudio(PlayerReplicationInfo PRI,int Captures)
{
    local int BeforeLeader,AfterLeader;
    local Pawn P;
    local bool LeadPlayed;
    if (PRI==None || PRI.Team>=4) return False;
    BeforeLeader=UniqueLeader(PRI.Team,Captures,True);
    AfterLeader=UniqueLeader(PRI.Team,Captures,False);
    LeadPlayed=bPlayLeadSound && AfterLeader==PRI.Team && AfterLeader!=BeforeLeader;
    if (bPlayLeadSound && BeforeLeader!=AfterLeader)
        for (P=Level.PawnList; P!=None; P=P.NextPawn)
            if (P.bIsPlayer && P.PlayerReplicationInfo!=None && !class'SmartCTFScoreBoard'.static.IsRealSpectator(P.PlayerReplicationInfo))
            {
                if (AfterLeader>=0 && P.PlayerReplicationInfo.Team==AfterLeader) AudioTo(P,3);
                else if (BeforeLeader>=0 && P.PlayerReplicationInfo.Team==BeforeLeader) AudioTo(P,4);
            }
    if (bPlayCaptureSound && !LeadPlayed) AudioTo(Pawn(PRI.Owner),0);
    return LeadPlayed;
}

function ProcessFlag(CTFFlag F, int Event, PlayerReplicationInfo PRI,optional bool bAudioHandled,optional bool bLeadPlayed)
{
    local SmartCTFPlayerReplicationInfo S, AS;
    local int I;
    local float Bonus;
    local bool bClose,bCloseMessage;
    if (F==None || F.Team>=4 || !Counting()) return;
    S=Stats(PRI);
    switch(Event)
    {
        case 6:
            if (PRI==None || PRI.Team==F.Team) return;
            ClearRun(F.Team);
            if (S!=None) S.Grabs++;
            if (bSmartScoring && PRI!=None) PRI.Score+=GrabBonus;
        case 4:
            if (PRI==None || PRI.Team==F.Team) return;
            AddContributor(PRI,F.Team);
            LastCarrier[F.Team]=PRI;
            break;
        case 2:
            AddContributor(PRI,F.Team);
            LastCarrier[F.Team]=None;
            break;
        case 0:
            if (PRI==None || PRI.Team>=4) return;
            if (!bAudioHandled) bLeadPlayed=CaptureAudio(PRI,1);
            if (S!=None) S.Captures++;
            if (bSmartScoring) PRI.Score+=CapBonus;
            for (I=0; I<256; I++)
                if (ContributorFlag[I]==F.Team && Contributors[I]!=None && Contributors[I]!=PRI
                    && !Contributors[I].bDeleteMe && Contributors[I].Team==PRI.Team)
                {
                    AS=Stats(Contributors[I]);
                    if (AS!=None) AS.Assists++;
                    if (bPlayAssistSound && !bLeadPlayed) AudioTo(Pawn(Contributors[I].Owner),1);
                    if (bSmartScoring) Contributors[I].Score+=AssistBonus;
                }
            ClearRun(F.Team);
            ResetSupportSprees();
            LastCarrier[F.Team]=None;
            break;
        case 1:
            if (S!=None) S.Returns++;
            for (I=0; I<4; I++)
                if (I!=F.Team && HasBase[I]!=0 && HasBase[F.Team]!=0
                    && VSize(Bases[I]-Bases[F.Team])>CloseSaveRadius*2
                    && VSize(F.Location-Bases[I])<CloseSaveRadius)
                { bClose=True; if (Flags[I]!=None && Flags[I].bHome) bCloseMessage=True; }
            Bonus=ReturnBonus;
            if (bClose) Bonus=CloseSaveBonus;
            if (bCloseMessage && PRI!=None)
            {
                LegacyNotice(SavedMsgType,7,PRI);
                if (bPlaySavedSound) AudioTo(Pawn(PRI.Owner),2);
            }
            if (bSmartScoring && PRI!=None) PRI.Score+=Bonus;
        case 3:
        case 5:
            ResetSupportSprees();
            ClearRun(F.Team);
            LastCarrier[F.Team]=None;
            break;
    }
}

function bool MutatorBroadcastLocalizedMessage(Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int Switch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject)
{
    local Pawn First;
    local CTFFlag F;
    local int I;
    local bool bAllowMessage,bLeadPlayed;
    local int Captured;
    // Honor message mutators further down the chain before processing anything.
    bAllowMessage=Super.MutatorBroadcastLocalizedMessage(Sender,Receiver,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
    if (ClassIsChildOf(Message,class'CTFMessage') || Message.Name=='CTF4Message')
    {
        F=CTFFlag(OptionalObject);
        if (F==None) F=CTFFlag(Sender);
        for (First=Level.PawnList; First!=None; First=First.NextPawn)
            if (First.bIsPlayer || First.IsA('MessagingSpectator')) break;
        if (Receiver==First)
        {
            if (Message.Name=='CTF4Message' && Switch==7)
            {
                for (I=0; I<4; I++)
                    if (LastCarrier[I]==RelatedPRI_1 && Flags[I]!=None && Flags[I].Holder==None)
                        ProcessFlag(Flags[I],2,RelatedPRI_1);
            }
            else if (Message.Name=='CTF4Message' && (Switch==12 || Switch==13))
            {
                for (I=0; I<4; I++)
                    if (LastCarrier[I]==RelatedPRI_1 && Flags[I]!=None && RelatedPRI_1!=None && I!=RelatedPRI_1.Team) Captured++;
                if (Captured>0) bLeadPlayed=CaptureAudio(RelatedPRI_1,Captured);
                // CTF4 sends one broadcast for a multi-capture, after some flags
                // already went home. Retain identity from pickup/drop events.
                for (I=0; I<4; I++)
                    if (LastCarrier[I]==RelatedPRI_1 && Flags[I]!=None && RelatedPRI_1!=None && I!=RelatedPRI_1.Team)
                        ProcessFlag(Flags[I],0,RelatedPRI_1,True,bLeadPlayed);
            }
            else
            {
                if (F==None && Switch==1 && RelatedPRI_1!=None && RelatedPRI_1.Team<4) F=Flags[RelatedPRI_1.Team];
                ProcessFlag(F,Switch,RelatedPRI_1);
            }
        }
    }
    if (ClassIsChildOf(Message,class'DeathMessagePlus')) Message=class'SmartCTFDeathMessage';
    return bAllowMessage;
}

static function bool IsInTeamZone(PlayerReplicationInfo PRI, byte Team)
{
    local string Area;
    if (PRI==None || Team>=4) return False;
    // Preserve 4H precedence: location name first, otherwise zone name.
    if (PRI.PlayerLocation!=None) Area=Caps(PRI.PlayerLocation.LocationName);
    else if (PRI.PlayerZone!=None) Area=Caps(PRI.PlayerZone.ZoneName);
    else return False;
    switch (Team)
    {
        case 0:return InStr(Area,"RED")!=-1;
        case 1:return InStr(Area,"BLUE")!=-1;
        case 2:return InStr(Area,"GREEN")!=-1;
        case 3:return InStr(Area,"GOLD")!=-1 || InStr(Area,"YELLOW")!=-1;
    }
    return False;
}

function bool PreventDeath(Pawn Victim, Pawn Killer, name DamageType, vector HitLocation)
{
    local SmartCTFPlayerReplicationInfo V, K;
    local PlayerReplicationInfo VP, KP;
    local Pawn Carrier, SealCarrier, P;
    local bool bTeamHasCarrier, bVictimTeamHasFlag;
    local int SpreeIndex, OldSpree;
    if (Super.PreventDeath(Victim,Killer,DamageType,HitLocation)) return True;
    if (Victim==None || Victim.PlayerReplicationInfo==None || !Counting()) return False;
    VP=Victim.PlayerReplicationInfo; V=EnsureStats(Victim);
    if (V!=None)
    {
        OldSpree=V.FragSpree;
        V.FragSpree=0; V.MultiLevel=0; V.LastKillTime=-100; V.SpawnKillSpree=0;
    }
    if (Settings.Profiles[0]!=None && Settings.Profiles[0].bEnabled)
    {
        // The stock game uses Pawn.Spree solely for its own announcements.
        // Independent replicated FragSpree owns the configurable replacement.
        Victim.Spree=0;
        if (Killer!=None) Killer.Spree=0;
        if (OldSpree>=5)
        {
            if (Killer!=None && Killer!=Victim) NotifyAll(0,7,Killer.PlayerReplicationInfo,VP,OldSpree);
            else NotifyAll(0,8,VP,VP,OldSpree);
        }
    }
    if (Killer==None || Killer==Victim) return False;
    KP=Killer.PlayerReplicationInfo;
    if (KP==None || KP.Team>=4 || VP.Team>=4) return False;
    K=EnsureStats(Killer);
    if (K==None) return False;
    if (KP.Team==VP.Team) return False;
    K.Frags++; K.FragSpree++; K.BestSpree=Max(K.BestSpree,K.FragSpree);
    if (DamageType=='Decapitated') K.HeadShots++;
    if (Level.TimeSeconds-K.LastKillTime<=MultiKillWindow) K.MultiLevel++;
    else K.MultiLevel=0;
    K.LastKillTime=Level.TimeSeconds;
    if (K.MultiLevel>0) NoticeTo(Killer,2,Min(K.MultiLevel-1,5),KP,VP,"",K.MultiLevel+1);
    if (K.FragSpree>=5 && K.FragSpree%5==0)
    {
        SpreeIndex=Min(K.FragSpree/5-1,6);
        NotifyAll(0,SpreeIndex,KP,None,K.FragSpree);
    }
    if (VP.HasFlag!=None)
    {
        K.FlagKills++;
        if (bSmartScoring) KP.Score+=FlagKillBonus;
    }
    else
    {
        // 4H support rules, extended to all four team identities and multiple carriers.
        for (P=Level.PawnList; P!=None; P=P.NextPawn)
            if (P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.HasFlag!=None)
            {
                if (P.PlayerReplicationInfo.Team==VP.Team) bVictimTeamHasFlag=True;
                if (P.PlayerReplicationInfo.Team==KP.Team)
                {
                    bTeamHasCarrier=True;
                    if (IsInTeamZone(P.PlayerReplicationInfo,KP.Team)) SealCarrier=P;
                    if (VSize(Victim.Location-P.Location)<=CoverRadius || VSize(Killer.Location-P.Location)<=CoverRadius)
                        Carrier=P;
                }
            }
        if (KP.HasFlag==None && Carrier!=None)
        {
            K.Covers++; K.CoverSpree++;
            if (bSmartScoring) KP.Score+=CoverBonus;
            if (K.CoverSpree==3) LegacyNotice(CoverSpreeMsgType,4,KP,VP);
            else if (K.CoverSpree==4) LegacyNotice(CoverSpreeMsgType,5,KP,VP);
            else LegacyNotice(CoverMsgType,0,KP,VP);
        }
        // Seal is independent of Cover, just as in 4H.
        if (!bVictimTeamHasFlag && IsInTeamZone(VP,KP.Team))
        {
            if (KP.HasFlag==None && SealCarrier!=None)
            {
                K.Seals++; K.SealSpree++;
                if (bSmartScoring) KP.Score+=SealBonus;
                if (K.SealSpree==2) LegacyNotice(SealMsgType,1,KP,VP);
            }
            // A seal is also defense only while our own flag is home.
            if (Flags[KP.Team]!=None && Flags[KP.Team].bHome
                && (!bTeamHasCarrier || KP.HasFlag!=None || SealCarrier!=None)) K.DefKills++;
        }
    }
    if (bSpawnkillDetection && V!=None && V.bSpawnProtected && Level.TimeSeconds-V.SpawnTime<=SpawnProtectionSeconds && DamageType!='Gibbed')
    {
        if (bSmartScoring) KP.Score-=SpawnKillPenalty;
        Killer.ReceiveLocalizedMessage(class'SmartCTFCoolMsg',5,KP,VP);
        K.SpawnKillSpree++;
        if (bShowSpawnKillerGlobalMsg && K.SpawnKillSpree>2) BroadcastLocalizedMessage(class'SmartCTFMessage',10,KP,VP);
    }
    if (bShowLongRangeMsg && TournamentPlayer(Killer)!=None && DamageType!='shot' && DamageType!='decapitated'
        && DamageType!='Gibbed' && DamageType!='RedeemerDeath' && DamageType!='Eradicated' && SuperShockRifle(Killer.Weapon)==None)
    {
        if (VSize(Victim.Location-Killer.Location)>3072) Killer.ReceiveLocalizedMessage(class'SmartCTFCoolMsg',2,KP,VP);
        else if (VSize(Victim.Location-Killer.Location)>1536) Killer.ReceiveLocalizedMessage(class'SmartCTFCoolMsg',1,KP,VP);
    }
    return False;
}

function MutatorTakeDamage(out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out vector HitLocation, out vector Momentum, name DamageType)
{
    local SmartCTFPlayerReplicationInfo S;
    Super.MutatorTakeDamage(ActualDamage,Victim,InstigatedBy,HitLocation,Momentum,DamageType);
    if (!Counting() || ActualDamage<=0 || Victim==None || InstigatedBy==None || Victim==InstigatedBy) return;
    if (Victim.PlayerReplicationInfo==None || InstigatedBy.PlayerReplicationInfo==None) return;
    if (Victim.PlayerReplicationInfo.Team==InstigatedBy.PlayerReplicationInfo.Team) return;
    S=EnsureStats(InstigatedBy);
    if (S!=None) S.DamageDealt+=Min(ActualDamage,Max(0,Victim.Health));
}

function bool HandlePickupQuery(Pawn Other, Inventory Item, out byte bAllowPickup)
{
    local bool Handled;
    local Inventory Owned;
    Handled=Super.HandlePickupQuery(Other,Item,bAllowPickup);
    if (Item==None || Other==None || !Counting() || (Handled && bAllowPickup==0)) return Handled;
    // Defer until after Touch/SpawnCopy, including replenishment of an existing item.
    if (Item.IsA('UT_ShieldBelt') || Item.IsA('UDamage') || Item.IsA('Weapon') || Item.IsA('HealthPack'))
    {
        Owned=Other.FindInventoryType(Item.Class);
        PendingPickups[NextPickup].Item=Item;
        PendingPickups[NextPickup].Player=Other;
        PendingPickups[NextPickup].OldOwned=Owned;
        PendingPickups[NextPickup].OldCharge=-1;
        if (Owned!=None) PendingPickups[NextPickup].OldCharge=Owned.Charge;
        NextPickup=(NextPickup+1)%64;
    }
    return Handled;
}

function ConfirmPickups()
{
    local int I;
    local Pawn P;
    local Inventory Item,Owned;
    local SmartCTFPlayerReplicationInfo S;
    for (I=0; I<64; I++)
    {
        P=PendingPickups[I].Player; Item=PendingPickups[I].Item;
        if (P==None || Item==None) continue;
        Owned=P.FindInventoryType(Item.Class);
        if (Owned!=None && (Owned!=PendingPickups[I].OldOwned || Owned.Charge>PendingPickups[I].OldCharge))
        {
            S=EnsureStats(P);
            if (S!=None)
            {
                S.bSpawnProtected=False;
                if (Item.IsA('UT_ShieldBelt')) S.ShieldBelts++;
                if (Item.IsA('UDamage')) S.Amps++;
            }
        }
        PendingPickups[I].Item=None; PendingPickups[I].Player=None;
        PendingPickups[I].OldOwned=None;
    }
}

function Timer()
{
    local Pawn P;
    local SmartCTFPlayerReplicationInfo S;
    local float DT;
    local int I;
    if (Settings==None) return;
    Settings.UpdateChristmas();
    DiscoverFlags();
    DT=FClamp(Level.TimeSeconds-LastStep,0,1);
    LastStep=Level.TimeSeconds;
    if (Level.Game.bGameEnded) { SaveEndRecords(); return; }
    if (!Counting()) return;
    MatchSeconds+=DT;
    for (P=Level.PawnList; P!=None; P=P.NextPawn)
    {
        S=EnsureStats(P);
        if (S==None || S.PlayerInfo.bIsSpectator) continue;
        for (I=0; I<4; I++)
        {
            if (Flags[I]==None || Flags[I].Holder!=P || I==S.PlayerInfo.Team) continue;
            AddContributor(S.PlayerInfo,I);
            LastCarrier[I]=S.PlayerInfo;
        }
        if (S.PlayerInfo.HasFlag!=None && CTFFlag(S.PlayerInfo.HasFlag)!=None && CTFFlag(S.PlayerInfo.HasFlag).Team!=S.PlayerInfo.Team) S.CarrierSeconds+=DT;
    }
    // Also clean up runs returned without a message (disconnect/map script).
    for (I=0; I<4; I++)
        if (Flags[I]!=None)
        {
            if (Flags[I].bHome && LastHome[I]==0) ClearRun(I);
            LastHome[I]=0;
            if (Flags[I].bHome) LastHome[I]=1;
        }
}

function SaveEndRecords()
{
    if (Records!=None && Settings!=None && !bEndSaved)
    { Records.Commit(Settings,int(MatchSeconds)); bEndSaved=True; }
}

function Trigger(Actor Other,Pawn EventInstigator)
{
    if (Role==ROLE_Authority && Level.Game!=None && Level.Game.bGameEnded) SaveEndRecords();
}

function Mutate(string Command, PlayerPawn Sender)
{
    if (Sender!=None && Left(Caps(Command),8)=="SMARTCTF")
    {
        if (Caps(Command)=="SMARTCTF APPLY")
        {
            if (Sender.PlayerReplicationInfo.bAdmin || Level.NetMode==NM_Standalone)
            {
                Settings.ValidateSettings();
                Sender.ClientMessage("SmartCTF 4K active settings validated. INI file edits require a server restart.");
            }
            else Sender.ClientMessage("Administrator login required.");
        }
        else if (Caps(Command)=="SMARTCTF STATS" || Caps(Command)=="SMARTCTF SHOWSTATS" || Caps(Command)=="SMARTCTF FORCESTATS" || Caps(Command)=="SMARTCTF TOGGLE")
            Sender.ReceiveLocalizedMessage(class'SmartCTFToggleMsg');
        else Sender.ClientMessage("SmartCTF 4K | F1: scores | F2: server and records | mutate smartctf apply (admin)");
    }
    Super.Mutate(Command,Sender);
}

simulated function Tick(float Delta)
{
    local PlayerPawn P;
    local ChallengeHUD H;
    local CTFFlag F;
    if (Role==ROLE_Authority)
    {
        ConfirmPickups();
        if (Reconnect!=None) Reconnect.UpdatePlayers();
    }
    if (Level.NetMode==NM_DedicatedServer || Settings==None) return;
    if (LocalPlayer==None)
        foreach AllActors(class'PlayerPawn',P)
            if (Viewport(P.Player)!=None) { LocalPlayer=P; break; }
    if (LocalPlayer==None) return;
    if (UI==None) UI=Spawn(class'SmartCTFUI');
    if (UI!=None) UI.Settings=Settings;
    // Enforce on the actual local instances, including HUDs created after joining.
    if (ClientBoard==None)
    {
        PreviousBoard=LocalPlayer.Scoring;
        PreviousScoringType=LocalPlayer.ScoringType;
        ClientBoard=Spawn(class'SmartCTFScoreBoard',LocalPlayer);
    }
    if (ClientBoard!=None)
    {
        ClientBoard.Controller=Self;
        if (!bDefaultInterfaces) { LocalPlayer.Scoring=ClientBoard; LocalPlayer.ScoringType=class'SmartCTFScoreBoard'; }
        else
        {
            if (LocalPlayer.Scoring!=None && LocalPlayer.Scoring!=ClientBoard) PreviousBoard=LocalPlayer.Scoring;
            LocalPlayer.Scoring=PreviousBoard; LocalPlayer.ScoringType=PreviousScoringType;
        }
    }
    H=ChallengeHUD(LocalPlayer.MyHUD);
    if (H!=None)
    {
        if (BoundHUD!=H || ClientInfo==None)
        {
            if (ClientInfo!=None) ClientInfo.Destroy();
            BoundHUD=H; PreviousInfo=H.ServerInfo;
            ClientInfo=Spawn(class'SmartCTFServerInfo',LocalPlayer);
            RegisterHUDMutator();
        }
        if (ClientInfo!=None)
        {
            ClientInfo.Controller=Self;
            if (bDefaultInterfaces)
            {
                if (H.ServerInfo!=None && H.ServerInfo!=ClientInfo) PreviousInfo=H.ServerInfo;
                H.ServerInfo=PreviousInfo;
            }
            else H.ServerInfo=ClientInfo;
        }
    }
    if (!bHUDMutator) RegisterHUDMutator();
    SetupClientPresentation();
    if (UI==None) return;
    foreach AllActors(class'CTFFlag',F)
        if (F.Team<4)
        {
            if (VisualFlags[F.Team]==None) VisualFlags[F.Team]=Spawn(class'SmartCTFVisualFlag');
            if (VisualFlags[F.Team]!=None)
            {
                VisualFlags[F.Team].Flag=F;
                VisualFlags[F.Team].Controller=Self;
            }
        }
}

static function string NoticeSoundPath(byte Category,int Index,bool OwnSound,string Configured)
{
    if (Category==0 && !OwnSound)
    {
        if (Index<7) return "Botpack.SpreeSound";
        return "";
    }
    if (Category==2 && !OwnSound) return "";
    return Configured;
}

simulated function AddNotice(byte Category, int Index, string PlayerName, string VictimName, string WeaponName, int Count, optional bool OwnSound)
{
    local SmartCTFMessageProfile Profile;
    local string S;
    local sound Effect;
    local string SoundPath;
    local SmartCTFNoticeData Data;
    local class<SmartCTFHUDMessage> MessageClass;
    local int Slot;
    if (Settings==None || Category>=3 || LocalPlayer==None) return;
    Profile=Settings.Profiles[Category];
    if (Profile==None || !Profile.bEnabled) return;
    S=Profile.FormatText(Index,PlayerName,VictimName,WeaponName,Count);
    if (S=="") return;
    // AddString writes console history only; ClientMessage would duplicate the HUD line.
    if (LocalPlayer.Player!=None && LocalPlayer.Player.Console!=None)
        LocalPlayer.Player.Console.AddString(S);
    if (LocalPlayer.MyHUD!=None)
    {
        Data=new(None) class'SmartCTFNoticeData'; Data.Profile=Profile; Data.Text=S; Data.Category=Category; Data.Index=Index;
        MessageClass=class'SmartCTFHUDMessage';
        if (Category==2) MessageClass=class'SmartCTFHUDMultiMessage';
        MessageClass.static.Configure(Profile);
        Slot=class'SmartCTFHUDMessage'.static.Register(Data);
        LocalPlayer.MyHUD.LocalizedMessage(MessageClass,Slot,None,None,Data);
    }
    SoundPath=NoticeSoundPath(Category,Index,OwnSound,Profile.SoundNames[Index]);
    if (Category==0 && Index<7 && !OwnSound)
    {
        LocalPlayer.PlaySound(sound'Botpack.SpreeSound',,4.0);
        return;
    }
    if (SoundPath!="")
    {
        Effect=sound(DynamicLoadObject(SoundPath,class'Sound',True));
        if (Effect!=None)
        {
            if (AudioPlayer==None) AudioPlayer=Spawn(class'SmartCTFAudioPlayer',LocalPlayer);
            if (AudioPlayer!=None) AudioPlayer.PlayEffect(Effect);
        }
        else Log("Cannot load message sound: "$SoundPath,'SmartCTF');
    }
}

simulated function DrawStartupLogo(Canvas C)
{
    local float Age, Size, X, Y, XL, YL, Brightness;
    if (!bLogoStarted)
    {
        bLogoStarted=True;
        LogoStartTime=Level.TimeSeconds;
    }
    Age=Level.TimeSeconds-LogoStartTime;
    if (Age>=6.2) return;
    Brightness=255*FClamp((6.2-Age)/3.2,0,1);
    Size=128*UI.Scale;
    X=C.ClipX-Size-16*UI.Scale;
    Y=40*UI.Scale;
    C.Style=3;
    C.DrawColor.R=Brightness;
    C.DrawColor.G=Brightness;
    C.DrawColor.B=Brightness;
    C.SetPos(X,Y);
    C.DrawTile(texture'poweredModern',Size,Size,0,0,256,256);
    C.Font=UI.BodyFont;
    C.StrLen("SmartCTF 4K",XL,YL);
    C.SetPos(X+(Size-XL)*0.5,Y+Size+8*UI.Scale);
    C.DrawText("SmartCTF 4K",False);
}

simulated event PostRender(Canvas C)
{
    local int I;
    local SmartCTFNoticeData D;
    local ChallengeHUD H;
    local float XL,YL,Y;
    if (UI!=None && Settings!=None && LocalPlayer!=None && !LocalPlayer.bShowScores)
    {
        UI.Begin(C);
        DrawStartupLogo(C);
        H=ChallengeHUD(LocalPlayer.MyHUD);
        for (I=0; I<32; I++)
        {
            D=class'SmartCTFHUDMessage'.default.Pending[I];
            if (D==None || !D.bDrawRequested) continue;
            D.bDrawRequested=False;
            if (H==None || H.bShowInfo || H.bHideCenterMessages || D.Profile==None) continue;
            C.Font=H.MyFonts.GetBigFont(C.ClipX);
            if (D.Category==2 && D.Index>0) C.Font=H.MyFonts.GetHugeFont(C.ClipX);
            C.StrLen(D.Text,XL,YL);
            Y=class'CriticalEventPlus'.static.GetOffset(0,YL,C.ClipY);
            if (D.Category==2) Y=class'MultiKillMessage'.static.GetOffset(D.Index+1,YL,C.ClipY);
            C.Style=1; C.DrawColor=D.Profile.AnimatedColor(Level.TimeSeconds);
            C.SetPos(FMax(0,(C.ClipX-XL)*0.5),Y); C.DrawText(D.Text,False);
        }
        if (Settings.bShowCarrierLocation) DrawCarrierLocations(C,H);
        DrawServerSplash(C);
        UI.Finish(C);
    }
    if (NextHUDMutator!=None) NextHUDMutator.PostRender(C);
}


static function string OnOff(bool Enabled)
{
    if (Enabled) return "ON";
    return "OFF";
}

function LogStartup()
{
    Log("####################################################",'SmartCTF');
    Log("#                    SmartCTF 4K                   #",'SmartCTF');
    Log("#               LOADED SUCCESSFULLY                #",'SmartCTF');
    Log("#--------------------------------------------------#",'SmartCTF');
    LogStartupLine("https://github.com/vanitysan/SmartCTF");
    Log("#--------------------------------------------------#",'SmartCTF');
    LogStartupLine("SpreeMSG=" $ OnOff(Settings.Profiles[0]!=None && Settings.Profiles[0].bEnabled));
    LogStartupLine("MultiMSG=" $ OnOff(Settings.Profiles[2]!=None && Settings.Profiles[2].bEnabled));
    LogStartupLine("RestorePlayerStats=" $ OnOff(Reconnect!=None));
    Log("####################################################",'SmartCTF');
}

function LogStartupLine(string Text)
{
    Text="# " $ Text;
    while (Len(Text)<51) Text=Text $ " ";
    Log(Text $ "#",'SmartCTF');
}

simulated function ToggleInterfaces()
{
    bDefaultInterfaces=!bDefaultInterfaces;
}

simulated function SetupClientPresentation()
{
    local string Binding;

    if (JoinPresentationTime==0) { JoinPresentationTime=Level.TimeSeconds+1; return; }
    if (Level.TimeSeconds<JoinPresentationTime) return;
    if (!bKeybindDone)
    {
        bKeybindDone=True;
        if (Settings.bDoKeybind)
        {
            Binding=LocalPlayer.ConsoleCommand("KEYBINDING F3");
            if (InStr(Caps(Binding),"MUTATE SMARTCTF")==-1)
                LocalPlayer.ConsoleCommand("SET INPUT F3 mutate smartctf toggle|"$Binding);
        }
        if (Settings.bExtraMsg)
        {
            if (Settings.bDoKeybind) LocalPlayer.ClientMessage("SmartCTF: F3 switches HUD between SmartCTF and Default.");
            else LocalPlayer.ClientMessage("SmartCTF: use mutate smartctf toggle to switch HUD interfaces.");
        }
    }
    if (!bJoinPresentationDone)
    {
        bJoinPresentationDone=True;
        bIntroSoundPlayed=False;
        SplashTexture=None; SplashSound=None;
        if (Settings.LogoTexture!="")
        {
            SplashTexture=texture(DynamicLoadObject(Settings.LogoTexture,class'Texture',True));
            if (SplashTexture==None) Log("Cannot load server splash texture: "$Settings.LogoTexture,'SmartCTF');
        }
        if (Settings.IntroSound!="")
        {
            SplashSound=sound(DynamicLoadObject(Settings.IntroSound,class'Sound',True));
            if (SplashSound==None) Log("Cannot load server intro sound: "$Settings.IntroSound,'SmartCTF');
        }
        JoinPresentationTime=Level.TimeSeconds;
    }
    if (!bIntroSoundPlayed && Level.TimeSeconds-JoinPresentationTime>=Settings.IntroSoundDelay)
    {
        bIntroSoundPlayed=True;
        if (SplashSound!=None) LocalPlayer.ClientReliablePlaySound(SplashSound);
        SplashSound=None;
    }
}

static function float SplashOpacity(float Age,float Delay,float FadeIn,float Hold,float FadeOut)
{
    Age-=FMax(0,Delay);
    if (Age<0) return 0;
    if (FadeIn>0 && Age<FadeIn) return Age/FadeIn;
    Age-=FMax(0,FadeIn);
    if (Age<FMax(0,Hold)) return 1;
    Age-=FMax(0,Hold);
    if (FadeOut>0 && Age<FadeOut) return 1-Age/FadeOut;
    return 0;
}

simulated function string SplashCaption(int Index)
{
    switch(Index)
    {
        case 0:return Settings.CaptionLineOne;
        case 1:return Settings.CaptionLineTwo;
        case 2:return Settings.CaptionLineThree;
        case 3:return Settings.CaptionLineFour;
    }
    return "";
}

simulated function DrawServerSplash(Canvas C)
{
    local float W,H,X,Y,Age,Opacity,XL,YL,Fit;
    local int I;
    local font PreviousFont;
    local bool PreviousCenter;
    local color PreviousColor;
    local byte PreviousStyle;
    local string Text;
    if (!bJoinPresentationDone) return;
    Age=Level.TimeSeconds-JoinPresentationTime;
    Opacity=SplashOpacity(Age,Settings.LogoDrawDelay,Settings.LogoFadeInTime,Settings.LogoDrawTime,Settings.LogoFadeOutTime);
    if (Opacity<=0) return;
    PreviousFont=C.Font; PreviousCenter=C.bCenter;
    PreviousColor=C.DrawColor; PreviousStyle=C.Style;
    C.bCenter=False;
    W=256; H=256;
    if (SplashTexture!=None) { W=SplashTexture.USize; H=SplashTexture.VSize; }
    Fit=class'SmartCTFSplashLayout'.static.ImageScale(Settings.Size,C.ClipX,C.ClipY,W,H);
    W*=Fit; H*=Fit;
    if (W>C.ClipX) { H*=C.ClipX/W; W=C.ClipX; }
    if (SplashTexture==None) H=0;
    X=class'SmartCTFSplashLayout'.static.Axis(Settings.Position,C.ClipX,W,False);
    Y=class'SmartCTFSplashLayout'.static.Axis(Settings.Position,C.ClipY,H,True);
    C.DrawColor.R=255*Opacity; C.DrawColor.G=255*Opacity; C.DrawColor.B=255*Opacity;
    C.Style=1;
    if (Settings.bLogoTranslucent || Opacity<1) C.Style=3;
    if (SplashTexture!=None && W>0 && H>0)
    {
        C.SetPos(X,Y);
        C.DrawTile(SplashTexture,W,H,0,0,SplashTexture.USize,SplashTexture.VSize);
    }
    C.Font=C.SmallFont;
    C.DrawColor.R=225*Opacity; C.DrawColor.G=225*Opacity; C.DrawColor.B=225*Opacity;
    C.Style=1; if (Opacity<1) C.Style=3;
    for (I=0; I<4; I++)
    {
        Text=SplashCaption(I);
        C.TextSize(Text,XL,YL);
        C.SetPos(X+int(W*0.5-XL*0.5),Y+int(H)+10*(I+1));
        C.DrawText(Text);
    }
    C.Font=PreviousFont; C.bCenter=PreviousCenter;
    C.DrawColor=PreviousColor; C.Style=PreviousStyle;
}

simulated function DrawCarrierLocations(Canvas C,ChallengeHUD H)
{
    local int I,Team,Rows[4];
    local PlayerReplicationInfo PRI;
    local float X,Y,W,Spacing,Line,HUDScale;
    local string Place;
    if (H==None || H.bHideHUD || H.bHideTeamInfo || H.bShowInfo || LocalPlayer.bShowMenu
        || LocalPlayer.GameReplicationInfo==None || LocalPlayer.PlayerReplicationInfo==None) return;
    HUDScale=H.Scale;
    Spacing=150; if (H.IsA('CTF4HUD')) Spacing=128;
    Line=UI.StatHeight; W=FMin(C.ClipX*0.36,360*UI.Scale);
    X=C.ClipX-W-6*UI.Scale;
    for (I=0; I<ArrayCount(LocalPlayer.GameReplicationInfo.PRIArray); I++)
    {
        PRI=LocalPlayer.GameReplicationInfo.PRIArray[I];
        if (PRI==None || PRI.HasFlag==None || PRI.Team>=4 || PRI==LocalPlayer.PlayerReplicationInfo
            || PRI.Team!=LocalPlayer.PlayerReplicationInfo.Team) continue;
        Team=PRI.Team;
        Y=C.ClipY-(350+Spacing*Team)*HUDScale+64*HUDScale+4*UI.Scale+Rows[Team]*Line*2;
        if (Y<0 || Y+Line*2>C.ClipY || (Rows[Team]+1)*Line*2>Spacing*HUDScale-68*HUDScale) continue;
        Place="Unknown area";
        if (PRI.PlayerLocation!=None && PRI.PlayerLocation.LocationName!="") Place=PRI.PlayerLocation.LocationName;
        else if (PRI.PlayerZone!=None && PRI.PlayerZone.ZoneName!="") Place=PRI.PlayerZone.ZoneName;
        UI.RightText(C,PRI.PlayerName,X,Y,W,Line,Settings.TeamColors[Team]);
        UI.RightText(C,Place,X,Y+Line,W,Line,Settings.TeamColors[Team]);
        Rows[Team]++;
    }
}

simulated function Destroyed()
{
    local int I;
    class'SmartCTFHUDMessage'.static.Reset();
    if (AudioPlayer!=None) AudioPlayer.Destroy();
    if (LocalPlayer!=None && LocalPlayer.Scoring==ClientBoard)
    { LocalPlayer.Scoring=PreviousBoard; LocalPlayer.ScoringType=PreviousScoringType; }
    if (ChallengeHUD(BoundHUD)!=None && ChallengeHUD(BoundHUD).ServerInfo==ClientInfo)
        ChallengeHUD(BoundHUD).ServerInfo=PreviousInfo;
    for (I=0; I<4; I++) if (VisualFlags[I]!=None) VisualFlags[I].Destroy();
    if (ClientBoard!=None) ClientBoard.Destroy();
    if (ClientInfo!=None) ClientInfo.Destroy();
    if (UI!=None) UI.Destroy();
    Super.Destroyed();
}

defaultproperties
{
    bDoKeybind=True
    bExtraMsg=True
    bRestorePlayerStats=True
    LogoTexture=""
    IntroSound="SmartCTF_4K.Start"
    Position="left:15px,top:30%"
    Size="byself:1"
    LogoDrawTime=10
    LogoDrawDelay=2
    LogoFadeInTime=1
    LogoFadeOutTime=1
    CaptionLineOne=""
    CaptionLineTwo=""
    CaptionLineThree=""
    CaptionLineFour=""
    IntroSoundDelay=2
    bLogoTranslucent=True


    bXmasSB=True
    bXmasStart="01.12."
    bXmasEnd="06.01."
    bShowCountryFlags=True
    CountryFlagsPackage="CountryFlags32e"
    bRecordsPerHour=False
    bDrawFaces=True
    bShowSpectators=True
    bShowCarrierLocation=True
    bShowDamage=True
    bShowRecords=True
    PageSeconds=7
    bPlayCaptureSound=True
    bPlayAssistSound=True
    bPlaySavedSound=True
    bPlayLeadSound=True
    bShowLongRangeMsg=True
    bShowSpawnKillerGlobalMsg=True
    CoverMsgType=2
    CoverSpreeMsgType=3
    SealMsgType=3
    SavedMsgType=3
    bEnabled=True
    bSmartScoring=True
    CapBonus=15
    AssistBonus=7
    GrabBonus=0
    FlagKillBonus=3
    CoverBonus=2
    SealBonus=3
    ReturnBonus=2
    CloseSaveBonus=10
    CoverRadius=768
    CloseSaveRadius=900
    MultiKillWindow=3
    bSpawnkillDetection=True
    SpawnProtectionSeconds=2
    bAlwaysRelevant=True
    bAddToPackageMap=True
    RemoteRole=ROLE_SimulatedProxy
    NetUpdateFrequency=2
    bCountWarmup=False
    SpawnKillPenalty=0
    RedFlag=""
    BlueFlag=""
    GreenFlag=""
    YellowFlag=""
    RedTeamHud=""
    BlueTeamHud=""
    GreenTeamHud=""
    YellowTeamHud=""
}
