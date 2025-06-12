CREATE PROGRAM bed_ens_wizard_history:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(request->history,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_wizard_hist b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_wizard_hist_id = seq(bedrock_seq,nextval), b.solution_mean = request->history[d.seq].
   solution_mean, b.wizard_mean = request->history[d.seq].step_mean,
   b.prsnl_id = reqinfo->updt_id, b.log_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
