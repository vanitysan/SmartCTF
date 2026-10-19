class SmartCTFSplashLayout extends Object;

static function string Trim(string Text)
{
    while (Left(Text,1)==" ") Text=Mid(Text,1);
    while (Right(Text,1)==" ") Text=Left(Text,Len(Text)-1);
    return Caps(Text);
}

static function float Distance(string Text,float Screen)
{
    Text=Trim(Text);
    if (Right(Text,1)=="%") return float(Left(Text,Len(Text)-1))*Screen/100;
    if (Right(Text,2)=="PX") return float(Left(Text,Len(Text)-2));
    return float(Text);
}

static function float Axis(string Position,float Screen,float Extent,bool Vertical)
{
    local int Split;
    local string Code,Value;
    local float Result;
    Split=InStr(Position,",");
    if (Vertical)
    {
        if (Split<0) Position="CENTER";
        else Position=Mid(Position,Split+1);
    }
    else if (Split>=0) Position=Left(Position,Split);
    Position=Trim(Position);
    Result=(Screen-Extent)*0.5;
    Split=InStr(Position,":");
    if (Split>=0)
    {
        Code=Trim(Left(Position,Split)); Value=Mid(Position,Split+1);
        if ((!Vertical && Code=="LEFT") || (Vertical && Code=="TOP")) Result=Distance(Value,Screen);
        else if ((!Vertical && Code=="RIGHT") || (Vertical && Code=="BOTTOM")) Result=Screen-Extent-Distance(Value,Screen);
    }
    return FClamp(Result,0,FMax(0,Screen-Extent));
}

static function float ImageScale(string Size,float ScreenX,float ScreenY,float TextureX,float TextureY)
{
    local int Split;
    local string Mode,Value;
    local float Factor;
    Split=InStr(Size,":"); if (Split<0) return 1;
    Mode=Trim(Left(Size,Split)); Value=Trim(Mid(Size,Split+1));
    Factor=float(Value);
    if (Right(Value,1)=="%") Factor=float(Left(Value,Len(Value)-1))/100;
    if (Mode=="BYSCREENX") return FMax(0,Factor*ScreenX/FMax(1,TextureX));
    if (Mode=="BYSCREENY") return FMax(0,Factor*ScreenY/FMax(1,TextureY));
    if (Mode=="BYSELF") return FMax(0,Factor);
    return 1;
}
