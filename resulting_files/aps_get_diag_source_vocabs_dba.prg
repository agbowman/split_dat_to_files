CREATE PROGRAM aps_get_diag_source_vocabs:dba
 RECORD reply(
   1 vocab_qual[5]
     2 include_vocab_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  asvr.include_source_vocabulary_cd
  FROM ap_source_vocabulary_r asvr
  WHERE (request->source_vocab_cd=asvr.source_vocabulary_cd)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,5)=1
    AND x != 1)
    stat = alter(reply->vocab_qual,(x+ 4))
   ENDIF
   reply->vocab_qual[x].include_vocab_cd = asvr.include_source_vocabulary_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus.targetobjectvalue = "AP_SOURCE_VOCABULARY_R"
 ELSE
  SET stat = alter(reply->vocab_qual,x)
 ENDIF
#exit_script
 IF (x=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->vocab_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
