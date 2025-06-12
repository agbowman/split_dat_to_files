CREATE PROGRAM br_ens_step:dba
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
 SET error_flag = " "
 DECLARE error_msg = vc
 SET org_id = 0.0
 IF ((request->step_mean > " ")
  AND (request->step_disp > " ")
  AND (request->step_cat_mean > " ")
  AND (request->step_cat_disp > " "))
  SET error_flag = "N"
 ELSE
  SET error_flag = "F"
  SET error_msg = "Invalide request data, "
  GO TO exit_script
 ENDIF
 INSERT  FROM br_step bs
  SET bs.step_mean = request->step_mean, bs.step_disp = request->step_disp, bs.step_cat_mean =
   request->step_cat_mean,
   bs.step_cat_disp = request->step_cat_disp, bs.default_seq = request->default_seq, bs
   .est_min_to_complete = request->est_min_to_complete,
   bs.step_type =
   IF ((request->step_type > " ")) request->step_type
   ELSE "IMP&MAINT"
   ENDIF
   , bs.updt_id = reqinfo->updt_id, bs.updt_dt_tm = cnvtdatetime(curdate,curtime),
   bs.updt_cnt = 0, bs.updt_task = reqinfo->updt_task, bs.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET error_flag = "F"
  SET error_msg = concat("Error adding step,"," step mean: ",request->step_mean)
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
