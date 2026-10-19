class SmartCTFCoolMsg extends LocalMessagePlus;

var(Messages) string LongRangeString;
var(Messages) string UberLongRangeString;
var(Messages) string SpawnLamerString;
var Color SpawnLamerColor;

static function float GetOffset(int Switch, float YL, float ClipY )
{
  return ( default.YPos / 768.0 ) * ClipY - 2 * YL;
}

static function string GetString( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
  switch( Switch )
  {
    case 1: return default.LongRangeString;
    case 2: return default.UberLongRangeString;
    case 5: return default.SpawnLamerString;
  }
  return "";
}

static function Color GetColor( optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2 )
{
  switch( Switch )
  {
    case 1: return default.DrawColor;
    case 2: return default.DrawColor;
    case 5: return default.SpawnLamerColor;
  }
  return default.DrawColor;
}

defaultproperties
{
	LongRangeString="Long Range Kill!"
	UberLongRangeString="Uber Long Range Kill!"
	SpawnLamerString="Spawnkill..."
	SpawnLamerColor=(R=255,G=64)
	FontSize=1
	bIsSpecial=True
	bIsUnique=True
	bFadeMessage=True
	DrawColor=(G=224,B=224)
	YPos=196.000000
	bCenter=True
}
