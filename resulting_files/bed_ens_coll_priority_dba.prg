CREATE PROGRAM bed_ens_coll_priority:dba
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
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 2054
  SET request_cv->cd_value_list[1].display = request->display
  SET request_cv->cd_value_list[1].description = request->description
  SET request_cv->cd_value_list[1].definition = request->description
  SET request_cv->cd_value_list[1].concept_cki = " "
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   INSERT  FROM collection_priority cp
    SET cp.collection_priority_cd = reply_cv->qual[1].code_value, cp.col_list_ind = 0, cp
     .after_last_ind = 0,
     cp.before_first_ind = 0, cp.group_with_other_flag = 0, cp.immediate_print_ind = 0,
     cp.time_study_ind = 0, cp.updt_applctx = reqinfo->updt_applctx, cp.updt_cnt = 0,
     cp.updt_dt_tm = cnvtdatetime(curdate,curtime), cp.updt_id = reqinfo->updt_id, cp.updt_task =
     reqinfo->updt_task,
     cp.label_sequence = 9999, cp.default_report_priority_cd = request->report_priority_cd, cp
     .default_start_dt_tm = " ",
     cp.look_ahead_minutes = null, cp.look_back_minutes = null
    WITH nocounter
   ;end insert
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].code_set = 2054
  SET request_cv->cd_value_list[1].code_value = request->code_value
  SET request_cv->cd_value_list[1].display = request->display
  SET request_cv->cd_value_list[1].description = request->description
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  UPDATE  FROM collection_priority cp
   SET cp.default_report_priority_cd = request->report_priority_cd, cp.updt_applctx = reqinfo->
    updt_applctx, cp.updt_cnt = (cp.updt_cnt+ 1),
    cp.updt_dt_tm = cnvtdatetime(curdate,curtime), cp.updt_id = reqinfo->updt_id, cp.updt_task =
    reqinfo->updt_task
   WHERE (cp.collection_priority_cd=request->code_value)
   WITH nocounter
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
