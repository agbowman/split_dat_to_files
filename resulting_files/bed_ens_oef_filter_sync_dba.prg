CREATE PROGRAM bed_ens_oef_filter_sync:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 FREE SET temp_upd
 RECORD temp_upd(
   1 temp[*]
     2 id = f8
     2 entity2_display = vc
 )
 SET temp_cnt = 0
 SELECT INTO "nl:"
  FROM dcp_entity_reltn d,
   code_value cv
  PLAN (d
   WHERE d.entity_reltn_mean IN ("AT/*", "CT/*", "ORC/*")
    AND d.entity2_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_value=d.entity2_id
    AND cnvtupper(cv.display) != cnvtupper(d.entity2_display))
  HEAD REPORT
   cnt = 0, temp_cnt = 0, stat = alterlist(temp_upd->temp,100)
  DETAIL
   cnt = (cnt+ 1), temp_cnt = (temp_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_upd->temp,(temp_cnt+ 100)), cnt = 1
   ENDIF
   temp_upd->temp[temp_cnt].id = d.dcp_entity_reltn_id, temp_upd->temp[temp_cnt].entity2_display = cv
   .display
  FOOT REPORT
   stat = alterlist(temp_upd->temp,temp_cnt)
  WITH nocounter
 ;end select
 IF (temp_cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM dcp_entity_reltn der,
   (dummyt d  WITH seq = value(temp_cnt))
  SET der.entity2_display = temp_upd->temp[d.seq].entity2_display, der.updt_applctx = reqinfo->
   updt_applctx, der.updt_cnt = (der.updt_cnt+ 1),
   der.updt_dt_tm = cnvtdatetime(curdate,curtime3), der.updt_id = reqinfo->updt_id, der.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (der
   WHERE (der.dcp_entity_reltn_id=temp_upd->temp[d.seq].id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
