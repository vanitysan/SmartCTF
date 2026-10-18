class SmartCTFRecordStore extends Object config(SmartCTF_4J_Records);

var config string RecordPlayer[16], RecordMap[16], RecordDate[16];
var config int RecordValue[16];
// Legacy import metadata only; the active switch lives in SmartCTF_4J.SmartCTF.
var config bool bRecordsPerHour;

defaultproperties
{
    bRecordsPerHour=False
}
