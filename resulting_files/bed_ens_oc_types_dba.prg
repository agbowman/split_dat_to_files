CREATE PROGRAM bed_ens_oc_types:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
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
 SET failed = "N"
 SET 6000_cd = 0.0
 SET 106_cd = 0.0
 SET 5801_cd = 0.0
 DECLARE cdf_meaning = vc
 SET 6000_cd = request->catalog_type.code_value
 IF ((request->catalog_type.action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 6000
  SET request_cv->cd_value_list[1].cdf_meaning = cnvtupper(substring(1,12,request->catalog_type.
    display))
  SET request_cv->cd_value_list[1].display = request->catalog_type.display
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->catalog_type.display
    ))
  SET request_cv->cd_value_list[1].description = request->catalog_type.display
  SET request_cv->cd_value_list[1].definition = "cer_exe:generic_shrorder"
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 6000_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  INSERT  FROM common_data_foundation c
   SET c.code_set = 6000, c.cdf_meaning = cnvtupper(substring(1,12,request->catalog_type.display)), c
    .display = request->catalog_type.display,
    c.definition = "cer_exe:generic_shrorder", c.updt_dt_tm = cnvtdatetime(curdate,curtime), c
    .updt_id = reqinfo->updt_id,
    c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
   PLAN (c)
   WITH nocounter
  ;end insert
 ENDIF
 SET 106_cd = request->activity_type.code_value
 IF ((request->activity_type.action_flag=1))
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_value=6000_cd)
   DETAIL
    cdf_meaning = c.cdf_meaning
   WITH nocounter
  ;end select
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 106
  SET request_cv->cd_value_list[1].cdf_meaning = ""
  SET request_cv->cd_value_list[1].display = request->activity_type.display
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->activity_type.
    display))
  SET request_cv->cd_value_list[1].description = request->activity_type.display
  SET request_cv->cd_value_list[1].definition = cdf_meaning
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 106_cd = reply_cv->qual[1].code_value
  ELSE
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
