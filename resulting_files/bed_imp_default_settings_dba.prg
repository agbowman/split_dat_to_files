CREATE PROGRAM bed_imp_default_settings:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_default_person_search b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_default_person_search_id = seq(bedrock_seq,nextval), b.setting_mean = requestin->list_0[d
   .seq].setting_mean, b.empi_ind = cnvtint(requestin->list_0[d.seq].empi_ind),
   b.display = requestin->list_0[d.seq].display, b.sequence = cnvtint(requestin->list_0[d.seq].
    sequence), b.updt_id = reqinfo->updt_id,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
