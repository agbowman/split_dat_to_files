CREATE PROGRAM bed_ens_alias_pool_details:dba
 IF ( NOT (validate(reply,0)))
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
 ENDIF
 DECLARE check_digit_cd = f8
 DECLARE active_cd = f8
 DECLARE auth_cd = f8
 DECLARE cur_method_cd = f8
 DECLARE cur_extension_pool_cd = f8
 DECLARE cur_append_value = vc
 DECLARE cur_combine_flag = i4
 DECLARE cur_sys_assign_flag = i4
 DECLARE cur_sys_assign_related_person_flag = i4 WITH noconstant(0), protect
 DECLARE cur_check_digit_cd = f8
 DECLARE method_cd = f8
 DECLARE extension_pool_cd = f8
 DECLARE append_value = vc
 DECLARE combine_flag = i4
 DECLARE sys_assign_flag = i4
 DECLARE sys_assign_related_person_flag = i4 WITH noconstant(0), protect
 DECLARE check_digit_cd = f8
 DECLARE error_msg = vc
 DECLARE dcnt = i4
 DECLARE seqcnt = i4
 DECLARE etgcnt = i4
 DECLARE etcnt = i4
 DECLARE new_group_cd = f8
 DECLARE def_sequence_cd = f8
 DECLARE effective_alias_ind = i2
 DECLARE cur_effective_alias_ind = i2
 DECLARE eff_found = i4
 DECLARE row_found = i2
 DECLARE rowexists(dummyvar=i2,dummyvar=i2) = i2
 SET row_found = 0
 SET error_flag = "F"
 SET eff_found = column_exists("ALIAS_POOL","EFFECTIVE_ALIAS_IND")
 CALL echo(build("eff_found = ",eff_found))
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
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH"
    AND cv.active_ind=1)
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 SET def_sequence_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=14163
    AND cv.cdf_meaning="DEFAULT"
    AND cv.active_ind=1)
  DETAIL
   def_sequence_cd = cv.code_value
  WITH nocounter
 ;end select
 SET dcnt = size(request->details,5)
 FOR (ii = 1 TO dcnt)
  SELECT INTO "NL:"
   FROM alias_pool ap
   PLAN (ap
    WHERE (ap.alias_pool_cd=request->details[ii].alias_pool_code_value))
   DETAIL
    cur_check_digit_cd = ap.check_digit_cd, cur_method_cd = ap.alias_method_cd, cur_extension_pool_cd
     = ap.alias_pool_ext_cd,
    cur_append_value = ap.alias_append_value, cur_combine_flag = ap.cmb_inactive_ind,
    cur_sys_assign_flag = ap.sys_assign_flag,
    cur_sys_assign_related_person_flag = ap.sys_assign_related_person_flag
    IF (validate(ap.effective_alias_ind)=1)
     cur_effective_alias_ind = ap.effective_alias_ind
    ELSE
     cur_effective_alias_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF ((request->details[ii].check_digit.action_flag=2))
    SET request->details[ii].check_digit.script = cnvtlower(trim(request->details[ii].check_digit.
      script))
    IF (size(trim(request->details[ii].check_digit.script)) > 0)
     SET check_digit_cd = 0.0
     SELECT INTO "nl:"
      FROM code_value cv,
       code_value_extension cve
      PLAN (cv
       WHERE cv.code_set=266
        AND cv.active_ind=1
        AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
       JOIN (cve
       WHERE cve.code_value=cv.code_value
        AND cve.field_name="SCRIPT"
        AND (cnvtlower(trim(cve.field_value))=request->details[ii].check_digit.script))
      DETAIL
       check_digit_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (check_digit_cd <= 0)
      SELECT INTO "nl:"
       temp = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        check_digit_cd = cnvtreal(temp)
       WITH nocounter
      ;end select
      INSERT  FROM code_value cv
       SET cv.code_value = check_digit_cd, cv.code_set = 266, cv.cdf_meaning = "USERDEFINED",
        cv.display = "User Defined", cv.display_key = "USERDEFINED", cv.description = "User Defined",
        cv.definition = "User Defined", cv.collation_seq = 0, cv.active_type_cd = active_cd,
        cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm = null,
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt =
        0,
        cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv
        .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), cv.data_status_cd = auth_cd,
        cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.data_status_prsnl_id = reqinfo->updt_id, cv.active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding check digit script to cs 266 for pool: ",trim(cnvtstring(
          request->details[ii].alias_pool_code_value)),".")
       GO TO exit_script
      ENDIF
      INSERT  FROM code_value_extension cve
       SET cve.code_value = check_digit_cd, cve.field_name = "SCRIPT", cve.code_set = 266,
        cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id, cve.updt_cnt
         = 0,
        cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->updt_applctx, cve.field_type
         = 0,
        cve.field_value = request->details[ii].check_digit.script
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding check digit script to cve 266 for pool: ",trim(cnvtstring
         (request->details[ii].alias_pool_code_value)),".")
       GO TO exit_script
      ENDIF
     ENDIF
     SET request->details[ii].check_digit.code_value = check_digit_cd
    ELSEIF ((request->details[ii].check_digit.code_value > 0))
     SET check_digit_cd = request->details[ii].check_digit.code_value
    ENDIF
   ELSE
    SET check_digit_cd = cur_check_digit_cd
   ENDIF
   IF ((request->details[ii].alias_method.action_flag=2))
    SET method_cd = request->details[ii].alias_method.code_value
    SET extension_pool_cd = request->details[ii].alias_method.extension_pool_code_value
    SET append_value = request->details[ii].alias_method.append_value
   ELSE
    SET method_cd = cur_method_cd
    SET extension_pool_cd = cur_extension_pool_cd
    SET append_value = cur_append_value
   ENDIF
   IF ((request->details[ii].combine.action_flag=2))
    SET combine_flag = request->details[ii].combine.combine_flag
   ELSE
    SET combine_flag = cur_combine_flag
   ENDIF
   SET sys_assign_flag = cur_sys_assign_flag
   IF (validate(request->details[ii].sys_assign.action_flag))
    IF ((request->details[ii].sys_assign.action_flag=2))
     SET sys_assign_flag = request->details[ii].sys_assign.sys_assign_flag
    ENDIF
   ENDIF
   SET sys_assign_related_person_flag = cur_sys_assign_related_person_flag
   IF (validate(request->details[ii].person_reltn.action_flag))
    IF ((request->details[ii].person_reltn.action_flag=2))
     SET sys_assign_related_person_flag = request->details[ii].person_reltn.person_reltn_flag
    ENDIF
   ENDIF
   IF ((request->details[ii].effective_alias.action_flag=2)
    AND eff_found=1)
    SET effective_alias_ind = request->details[ii].effective_alias.effective_alias_ind
   ELSE
    SET effective_alias_ind = cur_effective_alias_ind
   ENDIF
   IF (eff_found=0)
    UPDATE  FROM alias_pool ap
     SET ap.check_digit_cd = check_digit_cd, ap.alias_method_cd = method_cd, ap.alias_pool_ext_cd =
      extension_pool_cd,
      ap.alias_append_value = append_value, ap.cmb_inactive_ind = combine_flag, ap.updt_id = reqinfo
      ->updt_id,
      ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      ap.updt_cnt = (ap.updt_cnt+ 1), ap.sys_assign_flag = sys_assign_flag, ap
      .sys_assign_related_person_flag = sys_assign_related_person_flag
     WHERE (ap.alias_pool_cd=request->details[ii].alias_pool_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating alias pool: ",trim(cnvtstring(request->details[ii].
        alias_pool_code_value)),".")
     GO TO exit_script
    ENDIF
   ELSEIF (eff_found=1)
    UPDATE  FROM alias_pool ap
     SET ap.check_digit_cd = check_digit_cd, ap.alias_method_cd = method_cd, ap.alias_pool_ext_cd =
      extension_pool_cd,
      ap.alias_append_value = append_value, ap.cmb_inactive_ind = combine_flag, ap
      .effective_alias_ind = effective_alias_ind,
      ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
      updt_applctx,
      ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_cnt = (ap.updt_cnt+ 1), ap
      .sys_assign_flag = sys_assign_flag,
      ap.sys_assign_related_person_flag = sys_assign_related_person_flag
     WHERE (ap.alias_pool_cd=request->details[ii].alias_pool_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error updating alias pool: ",trim(cnvtstring(request->details[ii].
        alias_pool_code_value)),".")
     GO TO exit_script
    ENDIF
   ENDIF
   SET seqcnt = size(request->details[ii].sequence,5)
   IF (seqcnt > 0)
    FOR (jj = 1 TO seqcnt)
      IF ((request->details[ii].sequence[jj].action_flag=2)
       AND (request->details[ii].sequence[jj].type_code_value > 0.0))
       SET row_found = rowexists(ii,jj)
       IF (row_found != 0)
        CASE (request->details[ii].sequence[jj].sequence_settings_mask)
         OF 1:
          CALL updatestartcolumn(ii,jj)
         OF 2:
          CALL updatemaxcolumn(ii,jj)
         OF 3:
          CALL updatestartcolumn(ii,jj)
          CALL updatemaxcolumn(ii,jj)
         OF 4:
          CALL updatecurrentcolumn(ii,jj)
         OF 5:
          CALL updatestartcolumn(ii,jj)
          CALL updatecurrentcolumn(ii,jj)
         OF 6:
          CALL updatemaxcolumn(ii,jj)
          CALL updatecurrentcolumn(ii,jj)
         OF 7:
          CALL updatestartcolumn(ii,jj)
          CALL updatemaxcolumn(ii,jj)
          CALL updatecurrentcolumn(ii,jj)
        ENDCASE
       ENDIF
       IF (row_found=0
        AND (request->details[ii].sequence[jj].type_code_value=def_sequence_cd))
        INSERT  FROM alias_pool_seq aps
         SET aps.alias_pool_cd = request->details[ii].alias_pool_code_value, aps.ap_seq_type_cd =
          request->details[ii].sequence[jj].type_code_value, aps.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          aps.updt_id = reqinfo->updt_id, aps.updt_cnt = 0, aps.updt_task = reqinfo->updt_task,
          aps.updt_applctx = reqinfo->updt_applctx, aps.start_nbr = request->details[ii].sequence[jj]
          .start, aps.max_nbr = request->details[ii].sequence[jj].max,
          aps.next_nbr = request->details[ii].sequence[jj].current
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Error adding sequence for pool: ",trim(cnvtstring(request->details[
            ii].alias_pool_code_value)),".")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET etgcnt = size(request->details[ii].enc_groups,5)
   IF (etgcnt > 0)
    FOR (jj = 1 TO etgcnt)
     IF ((request->details[ii].enc_groups[jj].action_flag=1))
      SELECT INTO "nl:"
       temp = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        new_group_cd = cnvtreal(temp)
       WITH nocounter
      ;end select
      INSERT  FROM code_value cv
       SET cv.code_value = new_group_cd, cv.code_set = 25893, cv.cdf_meaning = null,
        cv.display = trim(request->details[ii].enc_groups[jj].group_name), cv.display_key = cnvtupper
        (cnvtalphanum(trim(request->details[ii].enc_groups[jj].group_name))), cv.description = trim(
         request->details[ii].enc_groups[jj].group_name),
        cv.definition = trim(request->details[ii].enc_groups[jj].group_name), cv.collation_seq = 0,
        cv.active_type_cd = active_cd,
        cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm = null,
        cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt =
        0,
        cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv
        .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), cv.data_status_cd = auth_cd,
        cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
        cv.data_status_prsnl_id = reqinfo->updt_id, cv.active_status_prsnl_id = reqinfo->updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding enc group to cs 25893 for pool: ",trim(cnvtstring(request
          ->details[ii].alias_pool_code_value)),".")
       GO TO exit_script
      ENDIF
      INSERT  FROM code_value_group cvg
       SET cvg.child_code_value = new_group_cd, cvg.code_set = 263, cvg.collation_seq = 0,
        cvg.parent_code_value = request->details[ii].alias_pool_code_value, cvg.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id,
        cvg.updt_cnt = 0, cvg.updt_task = reqinfo->updt_task, cvg.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding enc group to code_value_group for pool: ",trim(cnvtstring
         (request->details[ii].alias_pool_code_value)),".")
       GO TO exit_script
      ENDIF
      INSERT  FROM alias_pool_seq aps
       SET aps.alias_pool_cd = request->details[ii].alias_pool_code_value, aps.ap_seq_type_cd =
        new_group_cd, aps.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        aps.updt_id = reqinfo->updt_id, aps.updt_cnt = 0, aps.updt_task = reqinfo->updt_task,
        aps.updt_applctx = reqinfo->updt_applctx, aps.start_nbr = 0, aps.max_nbr = 0,
        aps.next_nbr = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Error adding enc group to alias_pool_seq for pool: ",trim(cnvtstring(
          request->details[ii].alias_pool_code_value)),".")
       GO TO exit_script
      ENDIF
      SET etcnt = size(request->details[ii].enc_groups[jj].enc_types,5)
      IF (etcnt > 0)
       FOR (kk = 1 TO etcnt)
         IF ((request->details[ii].enc_groups[jj].enc_types[kk].action_flag=1))
          INSERT  FROM code_value_group cvg
           SET cvg.child_code_value = request->details[ii].enc_groups[jj].enc_types[kk].
            enc_type_code_value, cvg.code_set = 25893, cvg.collation_seq = 0,
            cvg.parent_code_value = new_group_cd, cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            cvg.updt_id = reqinfo->updt_id,
            cvg.updt_task = reqinfo->updt_task, cvg.updt_cnt = 0, cvg.updt_applctx = reqinfo->
            updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Error adding enc group types to cvg for pool: ",trim(cnvtstring(
              request->details[ii].alias_pool_code_value)),".")
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF ((request->details[ii].enc_groups[jj].action_flag=2))
      UPDATE  FROM code_value cv
       SET cv.display = request->details[ii].enc_groups[jj].group_name
       WHERE (cv.code_value=request->details[ii].enc_groups[jj].group_code_value)
        AND cv.code_set=25893
      ;end update
     ELSEIF ((request->details[ii].enc_groups[jj].action_flag=3))
      DELETE  FROM alias_pool_seq aps
       WHERE (aps.alias_pool_cd=request->details[ii].alias_pool_code_value)
        AND (aps.ap_seq_type_cd=request->details[ii].enc_groups[jj].group_code_value)
       WITH nocounter
      ;end delete
      DELETE  FROM code_value_group cvg
       WHERE (cvg.parent_code_value=request->details[ii].alias_pool_code_value)
        AND (cvg.child_code_value=request->details[ii].enc_groups[jj].group_code_value)
       WITH nocounter
      ;end delete
      IF ((request->details[ii].enc_groups[jj].group_code_value != def_sequence_cd))
       DELETE  FROM code_value_group cvg
        WHERE (cvg.parent_code_value=request->details[ii].enc_groups[jj].group_code_value)
        WITH nocounter
       ;end delete
       UPDATE  FROM code_value cv
        SET cv.active_ind = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->
         updt_id,
         cv.updt_task = reqinfo->updt_task, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_applctx = reqinfo
         ->updt_applctx
        WHERE (cv.code_value=request->details[ii].enc_groups[jj].group_code_value)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Error inactivating enc group for pool: ",trim(cnvtstring(request->
           details[ii].alias_pool_code_value)),".")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
     IF ((((request->details[ii].enc_groups[jj].action_flag=2)) OR ((request->details[ii].enc_groups[
     jj].action_flag=0))) )
      SET etcnt = size(request->details[ii].enc_groups[jj].enc_types,5)
      IF (etcnt > 0)
       FOR (kk = 1 TO etcnt)
         IF ((request->details[ii].enc_groups[jj].enc_types[kk].action_flag=1))
          INSERT  FROM code_value_group cvg
           SET cvg.child_code_value = request->details[ii].enc_groups[jj].enc_types[kk].
            enc_type_code_value, cvg.code_set = 25893, cvg.collation_seq = 0,
            cvg.parent_code_value = request->details[ii].enc_groups[jj].group_code_value, cvg
            .updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id,
            cvg.updt_task = reqinfo->updt_task, cvg.updt_cnt = 0, cvg.updt_applctx = reqinfo->
            updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Error adding enc group to cs 25893 for pool: ",trim(cnvtstring(
              request->details[ii].alias_pool_code_value)),".")
           GO TO exit_script
          ENDIF
         ELSEIF ((request->details[ii].enc_groups[jj].enc_types[kk].action_flag=3))
          DELETE  FROM code_value_group cvg
           WHERE (cvg.parent_code_value=request->details[ii].enc_groups[jj].group_code_value)
            AND (cvg.child_code_value=request->details[ii].enc_groups[jj].enc_types[kk].
           enc_type_code_value)
           WITH nocounter
          ;end delete
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF ((request->details[ii].alias_reassign.action_flag=2))
    SET found = 0
    SELECT INTO "nl:"
     FROM code_value_extension cve
     PLAN (cve
      WHERE cve.code_set=263
       AND cve.field_name="ALIASREASSIGN"
       AND (cve.code_value=request->details[ii].alias_pool_code_value))
     DETAIL
      found = 1
     WITH nocounter
    ;end select
    IF (found=1)
     UPDATE  FROM code_value_extension cve
      SET cve.field_value = cnvtstring(request->details[ii].alias_reassign.option_ind), cve
       .updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->updt_id,
       cve.updt_task = reqinfo->updt_task, cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_applctx =
       reqinfo->updt_applctx
      WHERE cve.code_set=263
       AND cve.field_name="ALIASREASSIGN"
       AND (cve.code_value=request->details[ii].alias_pool_code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error updating ALIASREASSIGN for pool: ",trim(cnvtstring(request->
         details[ii].alias_pool_code_value)),".")
      GO TO exit_script
     ENDIF
    ELSE
     INSERT  FROM code_value_extension cve
      SET cve.code_set = 263, cve.field_name = "ALIASREASSIGN", cve.field_type = 1,
       cve.code_value = request->details[ii].alias_pool_code_value, cve.field_value = cnvtstring(
        request->details[ii].alias_reassign.option_ind), cve.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_cnt = 0,
       cve.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Error adding ALIASREASSIGN for pool: ",trim(cnvtstring(request->
         details[ii].alias_pool_code_value)),".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=stable
     AND l.attr_name=scolumn
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    DETAIL
     ce_flag = 1
    WITH nocounter
   ;end select
   RETURN(ce_flag)
 END ;Subroutine
 SUBROUTINE updatestartcolumn(ii,jj)
   UPDATE  FROM alias_pool_seq aps
    SET aps.start_nbr = request->details[ii].sequence[jj].start
    WHERE (aps.ap_seq_type_cd=request->details[ii].sequence[jj].type_code_value)
     AND (aps.alias_pool_cd=request->details[ii].alias_pool_code_value)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE updatecurrentcolumn(ii,jj)
   UPDATE  FROM alias_pool_seq aps
    SET aps.next_nbr = request->details[ii].sequence[jj].current
    WHERE (aps.ap_seq_type_cd=request->details[ii].sequence[jj].type_code_value)
     AND (aps.alias_pool_cd=request->details[ii].alias_pool_code_value)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE updatemaxcolumn(ii,jj)
   UPDATE  FROM alias_pool_seq aps
    SET aps.max_nbr = request->details[ii].sequence[jj].max
    WHERE (aps.ap_seq_type_cd=request->details[ii].sequence[jj].type_code_value)
     AND (aps.alias_pool_cd=request->details[ii].alias_pool_code_value)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE rowexists(ii,jj)
  SELECT INTO "nl:"
   FROM alias_pool_seq aps
   WHERE (aps.ap_seq_type_cd=request->details[ii].sequence[jj].type_code_value)
    AND (aps.alias_pool_cd=request->details[ii].alias_pool_code_value)
   WITH nocounter
  ;end select
  RETURN(curqual)
 END ;Subroutine
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_ENS_ALIAS_POOL_DETAILS >> ERROR MESSAGE: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
