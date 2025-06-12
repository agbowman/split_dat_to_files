CREATE PROGRAM bed_ens_reason_grouping:dba
 FREE SET reply
 RECORD reply(
   1 grouping_codes[*]
     2 code_value = f8
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
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE rcnt = i4
 DECLARE repcnt = i4
 DECLARE next_code = f8
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET rcnt = size(request->reason_groupings,5)
 SET repcnt = 0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (active_cd=0.0)
  SET error_flag = "Y"
  SET error_msg = concat("No active_cd exists on cs 48")
  GO TO exit_script
 ENDIF
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="INACTIVE"
    AND cv.active_ind=1)
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (inactive_cd=0.0)
  SET error_flag = "Y"
  SET error_msg = concat("No inactive_cd exists on cs 48")
  GO TO exit_script
 ENDIF
 FOR (ii = 1 TO rcnt)
  IF ((request->reason_groupings[ii].reason_group_type_code_value > 0))
   SET foundtype = 0
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE (cv.code_value=request->reason_groupings[ii].reason_group_type_code_value)
      AND cv.code_set=29904
      AND cv.active_ind=1)
    DETAIL
     foundtype = 1
    WITH nocounter
   ;end select
   IF (foundtype=0)
    SET error_flag = "Y"
    SET error_msg = concat("Invalid reason group type code: ",cnvtstring(request->reason_groupings[ii
      ].reason_group_type_code_value))
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->reason_groupings[ii].action_flag=1))
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 29903
   SET request_cv->cd_value_list[1].display = request->reason_groupings[ii].name
   SET request_cv->cd_value_list[1].description = request->reason_groupings[ii].name
   SET request_cv->cd_value_list[1].definition = request->reason_groupings[ii].name
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].concept_cki = " "
   SET request_cv->cd_value_list[1].collation_seq = 0
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   SET next_code = 0.0
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET next_code = reply_cv->qual[1].code_value
    SET repcnt = (repcnt+ 1)
    SET stat = alterlist(reply->grouping_codes,repcnt)
    SET reply->grouping_codes[repcnt].code_value = next_code
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Error creating new code_value for ",request->reason_groupings[ii].name)
    GO TO exit_script
   ENDIF
   IF ((request->reason_groupings[ii].reason_group_type_code_value > 0.0))
    INSERT  FROM code_value_extension cve
     SET cve.code_set = 29903, cve.code_value = next_code, cve.field_name = "DENIALTYPE",
      cve.field_value = cnvtstring(request->reason_groupings[ii].reason_group_type_code_value), cve
      .updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id,
      cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error creating new DENIALTYPE code_value_extension for ",request->
      reason_groupings[ii].name)
     GO TO exit_script
    ENDIF
   ENDIF
  ELSEIF ((request->reason_groupings[ii].action_flag=2))
   UPDATE  FROM code_value cv
    SET cv.display = request->reason_groupings[ii].name, cv.display_key = cnvtupper(cnvtalphanum(
       request->reason_groupings[ii].name)), cv.description = request->reason_groupings[ii].name,
     cv.definition = request->reason_groupings[ii].name, cv.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
     updt_applctx
    WHERE (cv.code_value=request->reason_groupings[ii].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error updating code_value for ",request->reason_groupings[ii].name)
    GO TO exit_script
   ENDIF
   SET foundcve = 0
   SELECT INTO "nl"
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_value=request->reason_groupings[ii].code_value))
    DETAIL
     foundcve = 1
    WITH nocounter
   ;end select
   IF (foundcve=1)
    UPDATE  FROM code_value_extension cve
     SET cve.field_value = cnvtstring(request->reason_groupings[ii].reason_group_type_code_value),
      cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id,
      cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_task = reqinfo->updt_task, cve.updt_applctx =
      reqinfo->updt_applctx
     WHERE (cve.code_value=request->reason_groupings[ii].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating DENIALTYPE code_value_extension for ",request->
      reason_groupings[ii].name)
     GO TO exit_script
    ENDIF
   ELSE
    IF ((request->reason_groupings[ii].reason_group_type_code_value > 0.0))
     INSERT  FROM code_value_extension cve
      SET cve.code_set = 29903, cve.code_value = request->reason_groupings[ii].code_value, cve
       .field_name = "DENIALTYPE",
       cve.field_value = cnvtstring(request->reason_groupings[ii].reason_group_type_code_value), cve
       .updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id,
       cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error creating new DENIALTYPE code_value_extension for ",request->
       reason_groupings[ii].name)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ELSEIF ((request->reason_groupings[ii].action_flag=3))
   UPDATE  FROM code_value cv
    SET cv.inactive_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = 0, cv
     .active_status_prsnl_id = reqinfo->updt_id,
     cv.active_type_cd = inactive_cd, cv.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_task = reqinfo->updt_task,
     cv.updt_applctx = reqinfo->updt_applctx
    WHERE (cv.code_value=request->reason_groupings[ii].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Error deleting reason group: ",request->reason_groupings[ii].name)
    GO TO exit_script
   ENDIF
   UPDATE  FROM pft_denial_code_ref pdcr
    SET pdcr.denial_group_cd = 0.0, pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pdcr.updt_id =
     reqinfo->updt_id,
     pdcr.updt_task = reqinfo->updt_task, pdcr.updt_applctx = reqinfo->updt_applctx, pdcr.updt_cnt =
     (pdcr.updt_cnt+ 1)
    WHERE (pdcr.denial_group_cd=request->reason_groupings[ii].code_value)
    WITH nocounter
   ;end update
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_REASON_GROUPING  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
