CREATE PROGRAM bed_ens_sch_appt_types:dba
 FREE SET reply
 RECORD reply(
   1 appt_type_code_value = f8
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET 14230_cd = 0.0
 SET 14249_cd = 0.0
 DECLARE active_cd = f8 WITH public, noconstant(0.0)
 DECLARE inactive_cd = f8 WITH public, noconstant(0.0)
 DECLARE required_cd = f8 WITH public, noconstant(0.0)
 DECLARE 16109_optional_cd = f8 WITH public, noconstant(0.0)
 DECLARE apptbook_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16109
    AND cv.cdf_meaning="REQUIRED"
    AND cv.active_ind=1)
  DETAIL
   required_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16109
    AND cv.cdf_meaning="OPTIONAL"
    AND cv.active_ind=1)
  DETAIL
   16109_optional_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=23026
    AND cv.cdf_meaning="APPTBOOK"
    AND cv.active_ind=1)
  DETAIL
   apptbook_cd = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->appt_type.code_value=0))
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=14230
     AND cnvtupper(c.display)=cnvtupper(request->appt_type.display)
     AND c.active_ind=0)
   DETAIL
    request->appt_type.code_value = c.code_value, request->action_flag = 2
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt_syn s
  PLAN (s
   WHERE (s.appt_type_cd=request->appt_type.code_value)
    AND s.primary_ind=1)
  DETAIL
   14249_cd = s.appt_synonym_cd
  WITH nocounter
 ;end select
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].active_ind = 1
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].active_ind = 1
  SET request_cv->cd_value_list[1].code_value = request->appt_type.code_value
 ELSEIF ((request->action_flag=3))
  SET request_cv->cd_value_list[1].action_flag = 3
  SET request_cv->cd_value_list[1].active_ind = 0
  SET request_cv->cd_value_list[1].code_value = request->appt_type.code_value
 ENDIF
 SET request_cv->cd_value_list[1].code_set = 14230
 SET request_cv->cd_value_list[1].cdf_meaning = ""
 SET request_cv->cd_value_list[1].display = request->appt_type.display
 SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->appt_type.display))
 SET request_cv->cd_value_list[1].description = request->appt_type.display
 SET request_cv->cd_value_list[1].definition = request->appt_type.display
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET 14230_cd = reply_cv->qual[1].code_value
 ELSE
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].active_ind = 1
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].active_ind = 1
  SET request_cv->cd_value_list[1].code_value = 14249_cd
 ELSEIF ((request->action_flag=3))
  SET request_cv->cd_value_list[1].action_flag = 3
  SET request_cv->cd_value_list[1].active_ind = 0
  SET request_cv->cd_value_list[1].code_value = 14249_cd
 ENDIF
 SET request_cv->cd_value_list[1].code_set = 14249
 SET request_cv->cd_value_list[1].cdf_meaning = ""
 SET request_cv->cd_value_list[1].display = request->appt_type.display
 SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->appt_type.display))
 SET request_cv->cd_value_list[1].description = request->appt_type.display
 SET request_cv->cd_value_list[1].definition = request->appt_type.display
 SET trace = recpersist
 EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
 IF ((reply_cv->status_data.status="S")
  AND (reply_cv->qual[1].code_value > 0))
  SET 14249_cd = reply_cv->qual[1].code_value
 ELSE
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->action_flag=1))
  SET ierrcode = 0
  INSERT  FROM sch_appt_type s
   SET s.appt_type_cd = 14230_cd, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.oe_format_id = 0,
    s.description = request->appt_type.display, s.info_sch_text_id = 0, s.null_dt_tm = cnvtdatetime(
     "31-DEC-2100"),
    s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime), s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
    s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_applctx = reqinfo->updt_applctx,
    s.updt_id = reqinfo->updt_id, s.updt_cnt = 0, s.updt_task = reqinfo->updt_task,
    s.appt_type_flag = 0, s.person_accept_cd = required_cd, s.person_accept_meaning = "REQUIRED",
    s.recur_cd = 16109_optional_cd, s.recur_meaning = "OPTIONAL", s.grp_resource_cd = 0,
    s.grp_prompt_cd = 0, s.grp_prompt_meaning = null
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM sch_appt_syn s
   SET s.appt_synonym_cd = 14249_cd, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.mnemonic =
    request->appt_type.display,
    s.mnemonic_key = cnvtupper(request->appt_type.display), s.allow_selection_flag = 1, s
    .info_sch_text_id = 0,
    s.appt_type_cd = 14230_cd, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.oe_format_id = 0,
    s.primary_ind = 1, s.order_sentence_id = 0, s.candidate_id = seq(sch_candidate_seq,nextval),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_applctx = reqinfo->updt_applctx, s.updt_id
     = reqinfo->updt_id,
    s.updt_cnt = 0, s.updt_task = reqinfo->updt_task, s.appt_type_flag = 0,
    s.mnemonic_key_nls = null
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM sch_appt_product s
   SET s.appt_type_cd = 14230_cd, s.product_cd = apptbook_cd, s.version_dt_tm = cnvtdatetime(
     "31-DEC-2100"),
    s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
    .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
    s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
    active_cd,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
    updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
    s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 1,
    s.updt_task = reqinfo->updt_task, s.product_meaning = "APPTBOOK"
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  INSERT  FROM sch_appt_loc s
   SET s.appt_type_cd = 14230_cd, s.location_cd = request->dept_code_value, s.version_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
    .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
    s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
    active_cd,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
    updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
    s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
    s.updt_task = reqinfo->updt_task, s.res_list_id = 0, s.sch_flex_id = 0,
    s.grp_res_list_id = 0
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET ierrcode = 0
  UPDATE  FROM sch_appt_type s
   SET s.description = request->appt_type.display, s.active_ind = 1, s.active_status_cd = active_cd,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
    updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
    s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1
    ),
    s.updt_task = reqinfo->updt_task
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_syn s
   SET s.mnemonic = request->appt_type.display, s.mnemonic_key = cnvtupper(request->appt_type.display
     ), s.active_ind = 1,
    s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_applctx = reqinfo->updt_applctx, s.updt_id
     = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
   PLAN (s
    WHERE s.appt_synonym_cd=14249_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_product s
   SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_loc s
   SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  SET ierrcode = 0
  UPDATE  FROM sch_appt_type s
   SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
     curdate,curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_syn s
   SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
     curdate,curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_synonym_cd=14249_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_product s
   SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
     curdate,curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM sch_appt_loc s
   SET s.active_ind = 0, s.active_status_cd = inactive_cd, s.active_status_dt_tm = cnvtdatetime(
     curdate,curtime),
    s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
    .updt_id = reqinfo->updt_id,
    s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx
   PLAN (s
    WHERE s.appt_type_cd=14230_cd)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
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
  SET reply->appt_type_code_value = 14230_cd
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
