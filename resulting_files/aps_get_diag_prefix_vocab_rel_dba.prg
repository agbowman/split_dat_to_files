CREATE PROGRAM aps_get_diag_prefix_vocab_rel:dba
 RECORD reply(
   1 diag_coding_vocabulary_cd = f8
   1 updt_cnt = i2
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
 SET failed = "F"
 SELECT INTO "nl:"
  FROM ap_prefix p
  WHERE (p.prefix_id=request->prefix_cd)
  DETAIL
   reply->diag_coding_vocabulary_cd = p.diag_coding_vocabulary_cd, reply->updt_cnt = p.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX"
  SET failed = "T"
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
