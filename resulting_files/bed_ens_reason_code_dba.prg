CREATE PROGRAM bed_ens_reason_code:dba
 FREE SET reply
 RECORD reply(
   1 reason_codes[*]
     2 code_value = f8
   1 error_code = vc
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
 DECLARE error_code = vc
 DECLARE rcnt = i4
 DECLARE repcnt = i4
 DECLARE next_code = f8
 DECLARE newid = f8
 DECLARE code_set = i4
 DECLARE rc_name = vc
 DECLARE ppi = vc
 DECLARE psi = vc
 DECLARE pti = vc
 DECLARE req_val = vc
 DECLARE post_val = vc
 DECLARE foundpa = i2
 DECLARE foundpdcr = i2
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 DECLARE codeset = i4
 DECLARE aliasval = vc
 DECLARE reqalias = vc
 DECLARE foundalias = i2
 DECLARE prio = i2
 DECLARE tech_cd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET rcnt = size(request->reason_codes,5)
 SET repcnt = 0
 SET rc_name = fillstring(40," ")
 SET error_msg = fillstring(250," ")
 SET error_code = fillstring(6," ")
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
 SET tech_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=29904
    AND cv.cdf_meaning="TECHNICAL"
    AND cv.active_ind=1)
  DETAIL
   tech_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (tech_cd=0.0)
  SET error_flag = "Y"
  SET error_msg = concat("No tech_cd exists on cs 29904")
  GO TO exit_script
 ENDIF
 FOR (ii = 1 TO rcnt)
   IF ((request->reason_codes[ii].action_flag=1))
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 24730
    SET request_cv->cd_value_list[1].display = request->reason_codes[ii].display
    SET request_cv->cd_value_list[1].description = request->reason_codes[ii].display
    SET request_cv->cd_value_list[1].definition = request->reason_codes[ii].display
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
     SET stat = alterlist(reply->reason_codes,repcnt)
     SET reply->reason_codes[repcnt].code_value = next_code
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Error creating new code_value for ",request->reason_codes[ii].display)
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     nid = seq(pft_ref_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      newid = cnvtreal(nid)
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error creating new pft id for ",request->reason_codes[ii].display)
     GO TO exit_script
    ENDIF
    IF ((request->reason_codes[ii].reason_type_code_value=tech_cd))
     SET prio = 1
    ELSE
     SET prio = 0
    ENDIF
    INSERT  FROM pft_denial_code_ref pdcr
     SET pdcr.pft_denial_code_ref_id = newid, pdcr.denial_cd = next_code, pdcr.denial_type_cd =
      request->reason_codes[ii].reason_type_code_value,
      pdcr.denial_group_cd = request->reason_codes[ii].reason_group_code_value, pdcr.priority_level
       = prio, pdcr.autowriteoff_ind = 0,
      pdcr.trans_alias_cd = 0.0, pdcr.process_ind = 0, pdcr.updt_id = reqinfo->updt_id,
      pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pdcr.updt_task = reqinfo->updt_task, pdcr
      .updt_applctx = reqinfo->updt_applctx,
      pdcr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error creating new pft row for ",request->reason_codes[ii].display)
     GO TO exit_script
    ENDIF
    IF ((request->reason_codes[ii].alias > " "))
     INSERT  FROM pft_alias pa
      SET pa.seq = 1, pa.parent_entity_name = "DEFAULT", pa.parent_entity_id = next_code,
       pa.alias = request->reason_codes[ii].alias, pa.code_value = next_code, pa.updt_id = reqinfo->
       updt_id,
       pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_task = reqinfo->updt_task, pa
       .updt_applctx = reqinfo->updt_applctx,
       pa.updt_cnt = 0, pa.active_ind = 1, pa.active_status_cd = active_cd,
       pa.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pa.active_status_prsnl_id = reqinfo->
       updt_id, pa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error creating new pft_alias row for ",request->reason_codes[ii].
       display)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->reason_codes[ii].action_flag=2))
    SET foundpdcr = 0
    SELECT INTO "nl:"
     FROM pft_denial_code_ref pdcr
     PLAN (pdcr
      WHERE (pdcr.denial_cd=request->reason_codes[ii].code_value))
     DETAIL
      foundpdcr = 1
     WITH nocounter
    ;end select
    IF ((request->reason_codes[ii].reason_type_code_value=tech_cd))
     SET prio = 1
    ELSE
     SET prio = 0
    ENDIF
    IF (foundpdcr=1)
     UPDATE  FROM pft_denial_code_ref pdcr
      SET pdcr.denial_type_cd = request->reason_codes[ii].reason_type_code_value, pdcr
       .denial_group_cd = request->reason_codes[ii].reason_group_code_value, pdcr.priority_level =
       prio,
       pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pdcr.updt_id = reqinfo->updt_id, pdcr
       .updt_task = reqinfo->updt_task,
       pdcr.updt_applctx = reqinfo->updt_applctx, pdcr.updt_cnt = (pdcr.updt_cnt+ 1)
      WHERE (pdcr.denial_cd=request->reason_codes[ii].code_value)
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error updating new pft row for ",request->reason_codes[ii].display)
      GO TO exit_script
     ENDIF
    ELSE
     SELECT INTO "nl:"
      nid = seq(pft_ref_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       newid = cnvtreal(nid)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error creating new pft id for ",request->reason_codes[ii].display)
      GO TO exit_script
     ENDIF
     INSERT  FROM pft_denial_code_ref pdcr
      SET pdcr.pft_denial_code_ref_id = newid, pdcr.denial_cd = request->reason_codes[ii].code_value,
       pdcr.denial_type_cd = request->reason_codes[ii].reason_type_code_value,
       pdcr.denial_group_cd = request->reason_codes[ii].reason_group_code_value, pdcr.priority_level
        = prio, pdcr.autowriteoff_ind = 0,
       pdcr.trans_alias_cd = 0.0, pdcr.process_ind = 0, pdcr.updt_id = reqinfo->updt_id,
       pdcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pdcr.updt_task = reqinfo->updt_task, pdcr
       .updt_applctx = reqinfo->updt_applctx,
       pdcr.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
    SET code_set = 0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->reason_codes[ii].code_value))
     DETAIL
      code_set = cv.code_set, rc_name = trim(cv.display)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error getting code set row for ",request->reason_codes[ii].display)
     GO TO exit_script
    ENDIF
    IF (rc_name != trim(request->reason_codes[ii].display))
     UPDATE  FROM code_value cv
      SET cv.display = request->reason_codes[ii].display, cv.display_key = cnvtupper(cnvtalphanum(
         request->reason_codes[ii].display)), cv.description = request->reason_codes[ii].display,
       cv.definition = request->reason_codes[ii].display, cv.updt_id = reqinfo->updt_id, cv
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
       .updt_cnt+ 1)
      WHERE (cv.code_value=request->reason_codes[ii].code_value)
     ;end update
    ENDIF
    IF (((code_set=26398) OR (code_set=26399)) )
     SET ppi = cnvtstring(request->reason_codes[ii].post_primary_ind)
     SET psi = cnvtstring(request->reason_codes[ii].post_secondary_ind)
     SET pti = cnvtstring(request->reason_codes[ii].post_tertiary_ind)
     SET reqval = concat(ppi,psi,pti)
     CASE (reqval)
      OF "111":
       SET postval = "0"
      OF "000":
       SET postval = "1"
      OF "101":
       SET postval = "2"
      OF "100":
       SET postval = "3"
      OF "110":
       SET postval = "4"
      OF "001":
       SET postval = "5"
      OF "010":
       SET postval = "6"
      OF "011":
       SET postval = "7"
      ELSE
       SET postval = "1"
     ENDCASE
     SELECT INTO "nl:"
      FROM code_value_extension cve
      PLAN (cve
       WHERE (cve.code_value=request->reason_codes[ii].code_value)
        AND cve.field_name="POST NO POST METHOD")
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM code_value_extension cve
       SET cve.code_set = code_set, cve.code_value = request->reason_codes[ii].code_value, cve
        .field_name = "POST NO POST METHOD",
        cve.field_type = 1, cve.field_value = postval, cve.updt_applctx = reqinfo->updt_applctx,
        cve.updt_cnt = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->
        updt_id,
        cve.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding code_value_extension row for ",request->reason_codes[ii].
        display)
       GO TO exit_script
      ENDIF
     ELSE
      UPDATE  FROM code_value_extension cve
       SET cve.field_value = postval, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_applctx = reqinfo->
        updt_applctx,
        cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id, cve
        .updt_task = reqinfo->updt_task
       WHERE (cve.code_value=request->reason_codes[ii].code_value)
        AND cve.code_set=code_set
        AND cve.field_name="POST NO POST METHOD"
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error updating code_value_extension row for ",request->reason_codes[ii
        ].display)
       GO TO exit_script
      ENDIF
     ENDIF
     SET foundpa = 0
     SELECT INTO "nl:"
      FROM pft_alias pa
      PLAN (pa
       WHERE (pa.code_value=request->reason_codes[ii].code_value)
        AND pa.parent_entity_name="DEFAULT")
      DETAIL
       foundpa = 1
      WITH nocounter
     ;end select
     IF (foundpa=0)
      SELECT INTO "nl:"
       FROM code_value_extension cve
       PLAN (cve
        WHERE cve.code_set=code_set
         AND (cve.code_value=request->reason_codes[ii].code_value)
         AND cve.field_name="X12B")
       DETAIL
        aliasval = trim(cve.field_value)
       WITH nocounter
      ;end select
      IF (curqual=1)
       INSERT  FROM pft_alias pa
        SET pa.active_ind = 1, pa.active_status_cd = active_cd, pa.active_status_dt_tm = cnvtdatetime
         (curdate,curtime3),
         pa.active_status_prsnl_id = reqinfo->updt_id, pa.alias = aliasval, pa.beg_effective_dt_tm =
         cnvtdatetime(curdate,curtime3),
         pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pa.code_value = request->
         reason_codes[ii].code_value, pa.parent_entity_id = request->reason_codes[ii].code_value,
         pa.parent_entity_name = "DEFAULT", pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = 0,
         pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task
          = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error adding/syncing pft_alias row for ",request->reason_codes[ii].
         display)
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (code_set=24730)
     SET foundalias = 0
     SET reqalias = trim(request->reason_codes[ii].alias)
     SET foundpa = 0
     SELECT INTO "nl:"
      FROM pft_alias pa
      PLAN (pa
       WHERE pa.parent_entity_name="DEFAULT"
        AND (pa.code_value=request->reason_codes[ii].code_value))
      DETAIL
       foundpa = (foundpa+ 1)
       IF (trim(pa.alias)=reqalias)
        foundalias = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (foundpa=1)
      IF (foundalias=0)
       UPDATE  FROM pft_alias pa
        SET pa.alias = request->reason_codes[ii].alias, pa.updt_applctx = reqinfo->updt_applctx, pa
         .updt_cnt = (pa.updt_cnt+ 1),
         pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task
          = reqinfo->updt_task
        WHERE pa.parent_entity_name="DEFAULT"
         AND (pa.code_value=request->reason_codes[ii].code_value)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error updating pft_alias row for ",request->reason_codes[ii].display)
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF (foundpa > 1)
      IF (foundalias=0)
       SET error_flag = "Y"
       SET error_msg = concat("Invalid condition - too many alias values for:  ",request->
        reason_codes[ii].display)
       SET error_code = "RC0001"
       GO TO exit_script
      ENDIF
     ELSE
      INSERT  FROM pft_alias pa
       SET pa.active_ind = 1, pa.active_status_cd = active_cd, pa.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        pa.active_status_prsnl_id = reqinfo->updt_id, pa.alias = request->reason_codes[ii].alias, pa
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pa.code_value = request->
        reason_codes[ii].code_value, pa.parent_entity_id = request->reason_codes[ii].code_value,
        pa.parent_entity_name = "DEFAULT", pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = 0,
        pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task
         = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding pft_alias row for ",request->reason_codes[ii].display)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->reason_codes[ii].action_flag=3))
    SET codeset = 0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->reason_codes[ii].code_value))
     DETAIL
      codeset = cv.code_set
     WITH nocounter
    ;end select
    IF (codeset=24730)
     UPDATE  FROM code_value cv
      SET cv.inactive_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = 0, cv
       .active_status_prsnl_id = reqinfo->updt_id,
       cv.active_type_cd = inactive_cd, cv.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cv
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       cv.updt_id = reqinfo->updt_id, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_task = reqinfo->
       updt_task,
       cv.updt_applctx = reqinfo->updt_applctx
      WHERE (cv.code_value=request->reason_codes[ii].code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error updating code_value_extension for ",request->reason_codes[ii].
       display)
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo(build("Skipping remove action because of invalid code set"))
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_code = error_code
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_ENS_REASON_CODE  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
