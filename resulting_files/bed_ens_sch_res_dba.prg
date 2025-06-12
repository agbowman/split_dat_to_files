CREATE PROGRAM bed_ens_sch_res:dba
 FREE SET reply
 RECORD reply(
   1 resource_cd = f8
   1 error_msg = vc
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
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET resource_cd = 0.0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET request_cv->cd_value_list[1].action_flag = 1
 SET request_cv->cd_value_list[1].code_set = 14231
 SET request_cv->cd_value_list[1].display = request->resource_name
 SET request_cv->cd_value_list[1].description = request->resource_name
 SET request_cv->cd_value_list[1].cdf_meaning = ""
 SET request_cv->cd_value_list[1].active_ind = 1
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 SET next_code = 0.0
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET next_code = reply_cv->qual[1].code_value
  SET reply->resource_cd = next_code
  INSERT  FROM sch_resource sr
   SET sr.resource_cd = next_code, sr.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), sr
    .res_type_flag = 1,
    sr.mnemonic = request->resource_name, sr.mnemonic_key = cnvtupper(request->resource_name), sr
    .description = request->resource_name,
    sr.active_ind = 1, sr.active_status_cd = active_cd, sr.null_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"),
    sr.candidate_id = seq(sch_candidate_seq,nextval), sr.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), sr.active_status_prsnl_id = reqinfo->updt_id,
    sr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sr.end_effective_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    sr.updt_id = reqinfo->updt_id, sr.updt_task = reqinfo->updt_task, sr.updt_applctx = reqinfo->
    updt_applctx,
    sr.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET error_flag = "F"
  SET error_msg = concat("Error updating step status, br_client_id: ",cnvtstring(curclientid),
   " step mean: ",request->step_mean)
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
