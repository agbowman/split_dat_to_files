CREATE PROGRAM bed_imp_search_settings:dba
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
 INSERT  FROM br_person_search_settings b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_person_search_settings_id = seq(bedrock_seq,nextval), b.setting_mean = requestin->list_0[d
   .seq].setting_mean, b.display = requestin->list_0[d.seq].display,
   b.description = requestin->list_0[d.seq].description, b.data_type_flag = cnvtint(requestin->
    list_0[d.seq].data_type_flag), b.meaning = requestin->list_0[d.seq].meaning,
   b.codeset = cnvtint(requestin->list_0[d.seq].codeset), b.updt_id = reqinfo->updt_id, b.updt_cnt =
   0,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo->updt_task, b.updt_applctx =
   reqinfo->updt_applctx
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
