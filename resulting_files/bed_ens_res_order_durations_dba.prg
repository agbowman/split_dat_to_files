CREATE PROGRAM bed_ens_res_order_durations:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET active_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = ACTIVE from",
   " code set 48.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = ACTIVE found on",
   " code set 48.")
 ENDIF
 SET ord_loc_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16162
   AND cv.cdf_meaning="ODUR"
   AND cv.active_ind=1
  DETAIL
   ord_loc_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = ODUR from",
   " code set 16162.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = ODUR found on",
   " code set 16162.")
 ENDIF
 SET infix_code = 0.0
 SET postfix_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16163
   AND cv.cdf_meaning IN ("INFIX", "POSTFIX")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="INFIX")
    infix_code = cv.code_value
   ELSEIF (cv.cdf_meaning="POSTFIX")
    postfix_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (infix_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = INFIX from",
   " code set 16163.")
 ELSEIF (postfix_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = POSTFIX found on",
   " code set 16163.")
 ENDIF
 SET tapptloc_code = 0.0
 SET dapptloc_code = 0.0
 SET equal_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16160
   AND cv.cdf_meaning IN ("T_APPTLOC", "EQUAL", "D_APPTLOC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="T_APPTLOC")
    tapptloc_code = cv.code_value
   ELSEIF (cv.cdf_meaning="EQUAL")
    equal_code = cv.code_value
   ELSEIF (cv.cdf_meaning="D_APPTLOC")
    dapptloc_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (tapptloc_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = T_APPTLOC from",
   " code set 16160.")
 ELSEIF (equal_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = EQUAL found on",
   " code set 16160.")
 ELSEIF (dapptloc_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = D_APPTLOC found on",
   " code set 16160.")
 ENDIF
 SET dtasource_code = 0.0
 SET operand_code = 0.0
 SET operator_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16161
   AND cv.cdf_meaning IN ("DATASOURCE", "OPERAND", "OPERATOR")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DATASOURCE")
    dtasource_code = cv.code_value
   ELSEIF (cv.cdf_meaning="OPERAND")
    operand_code = cv.code_value
   ELSEIF (cv.cdf_meaning="OPERATOR")
    operator_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (dtasource_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = DATASOURCE from",
   " code set 16161.")
 ELSEIF (operand_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = OPERAND found on",
   " code set 16161.")
 ELSEIF (operator_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = OPERATOR found on",
   " code set 16161.")
 ENDIF
 SET hc_code = 0.0
 SET ds_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16164
   AND cv.cdf_meaning IN ("DATASOURCE", "HARDCODED")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DATASOURCE")
    ds_code = cv.code_value
   ELSEIF (cv.cdf_meaning="HARDCODED")
    hc_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (ds_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = DATASOURCE from",
   " code set 16164.")
 ELSEIF (hc_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = HARDCODED found on",
   " code set 16164.")
 ENDIF
 SET location_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16149
   AND cv.cdf_meaning="LOCATION"
   AND cv.active_ind=1
  DETAIL
   location_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = LOCATION from",
   " code set 16149.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = LOCATION found on",
   " code set 16149.")
 ENDIF
 SET double_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16131
   AND cv.cdf_meaning="DOUBLE"
   AND cv.active_ind=1
  DETAIL
   double_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = DOUBLE from",
   " code set 16131.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = DOUBLE found on",
   " code set 16131.")
 ENDIF
 DECLARE dur_unit_mean = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->duration_unit_code_value)
   AND cv.active_ind=1
  DETAIL
   dur_unit_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 DECLARE set_unit_mean = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->setup_unit_code_value)
   AND cv.active_ind=1
  DETAIL
   set_unit_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 DECLARE clean_unit_mean = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->cleanup_unit_code_value)
   AND cv.active_ind=1
  DETAIL
   clean_unit_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 DECLARE arr_unit_mean = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->arrival_unit_code_value)
   AND cv.active_ind=1
  DETAIL
   arr_unit_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 DECLARE rec_unit_mean = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->recovery_unit_code_value)
   AND cv.active_ind=1
  DETAIL
   rec_unit_mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET flex_id = 0.0
 SELECT INTO "nl:"
  FROM sch_flex_string sfs,
   sch_flex_list sfl,
   sch_flex_list sfl2,
   sch_flex_list sfl3,
   sch_order_duration sod
  PLAN (sfs
   WHERE sfs.flex_type_cd=ord_loc_code
    AND sfs.active_ind=1)
   JOIN (sfl
   WHERE sfl.sch_flex_id=sfs.sch_flex_id
    AND sfl.flex_orient_cd=infix_code
    AND sfl.flex_token_cd=tapptloc_code
    AND sfl.flex_eval_cd=hc_code)
   JOIN (sfl2
   WHERE sfl2.sch_flex_id=sfl.sch_flex_id
    AND (sfl2.seq_nbr=(sfl.seq_nbr+ 1))
    AND sfl2.flex_orient_cd=infix_code
    AND sfl2.flex_token_cd=equal_code
    AND sfl2.active_ind=1)
   JOIN (sfl3
   WHERE sfl3.sch_flex_id=sfs.sch_flex_id
    AND (sfl3.seq_nbr=(sfl2.seq_nbr+ 1))
    AND sfl3.flex_orient_cd=infix_code
    AND sfl3.flex_token_cd=dapptloc_code
    AND sfl3.flex_eval_cd=ds_code
    AND sfl3.data_source_cd=location_code
    AND (sfl3.parent_id=request->dept_code_value))
   JOIN (sod
   WHERE sod.sch_flex_id=outerjoin(sfl3.sch_flex_id)
    AND sod.catalog_cd=outerjoin(request->catalog_code_value)
    AND sod.location_cd=outerjoin(0)
    AND sod.seq_nbr=outerjoin(0)
    AND sod.active_ind=outerjoin(1))
  DETAIL
   IF (sod.catalog_cd > 0)
    flex_id = sfs.sch_flex_id
   ELSEIF (flex_id=0)
    flex_id = sfs.sch_flex_id
   ENDIF
  WITH nocounter
 ;end select
 SET update_ind = 0
 IF (flex_id=0)
  DECLARE dept_disp = vc
  DECLARE flex_rule_disp = vc
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value=request->dept_code_value)
    AND cv.active_ind=1
   DETAIL
    dept_disp = cv.display
   WITH nocounter
  ;end select
  SET flex_rule_disp = concat("Appt Location = ",dept_disp)
  SET dup_ind = 0
  SELECT INTO "nl:"
   FROM sch_flex_string sfs
   WHERE sfs.mnemonic_key=cnvtupper(trim(flex_rule_disp))
    AND sfs.flex_type_cd=ord_loc_code
   DETAIL
    dup_ind = 1
   WITH nocounter
  ;end select
  DECLARE check_dup = vc
  SET dup_cnt = 0
  WHILE (dup_ind=1)
    SET dup_cnt = (dup_cnt+ 1)
    SET dup_ind = 0
    SET check_dup = concat(flex_rule_disp," ",trim(cnvtstring(dup_cnt)))
    SELECT INTO "nl:"
     FROM sch_flex_string sfs
     WHERE sfs.mnemonic_key=cnvtupper(trim(check_dup))
      AND sfs.flex_type_cd=ord_loc_code
     DETAIL
      dup_ind = 1
     WITH nocounter
    ;end select
  ENDWHILE
  IF (dup_cnt > 0)
   SET flex_rule_disp = check_dup
  ENDIF
  SET new_flex_id = 0.0
  SELECT INTO "NL:"
   j = seq(sch_flex_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_flex_id = cnvtreal(j)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to retrieve next code value in SCH_FLEX_SEQ.")
  ENDIF
  INSERT  FROM sch_flex_string s
   SET s.sch_flex_id = new_flex_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.mnemonic =
    flex_rule_disp,
    s.mnemonic_key = cnvtupper(trim(flex_rule_disp)), s.mnemonic_key_nls = null, s.description =
    flex_rule_disp,
    s.info_sch_text_id = 0, s.flex_type_cd = ord_loc_code, s.flex_type_meaning = "ODUR",
    s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
    .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
    active_code_value,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->
    updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx,
    s.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_string.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = postfix_code, s.seq_nbr = 0,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "POSTFIX", s.flex_token_cd
     = tapptloc_code,
    s.flex_token_meaning = "T_APPTLOC", s.token_type_cd = operand_code, s.token_type_meaning =
    "OPERAND",
    s.data_type_cd = double_code, s.data_type_meaning = "DOUBLE", s.flex_eval_cd = hc_code,
    s.flex_eval_meaning = "HARDCODED", s.precedence = 0, s.dynamic_text = null,
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = null, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = 0,
    s.data_source_meaning = null, s.parent_table = null, s.parent_id = 0,
    s.parent_meaning = null, s.display_table = null, s.display_id = 0,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = postfix_code, s.seq_nbr = 1,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "POSTFIX", s.flex_token_cd
     = dapptloc_code,
    s.flex_token_meaning = "D_APPTLOC", s.token_type_cd = dtasource_code, s.token_type_meaning =
    "DATASOURCE",
    s.data_type_cd = double_code, s.data_type_meaning = "DOUBLE", s.flex_eval_cd = ds_code,
    s.flex_eval_meaning = "DATASOURCE", s.precedence = 0, s.dynamic_text = "SCH_GETF_FLEX_APPTLOC",
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = dept_disp, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = location_code,
    s.data_source_meaning = "LOCATION", s.parent_table = "CODE_VALUE", s.parent_id = request->
    dept_code_value,
    s.parent_meaning = null, s.display_table = "CODE_VALUE", s.display_id = request->dept_code_value,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = postfix_code, s.seq_nbr = 2,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "POSTFIX", s.flex_token_cd
     = equal_code,
    s.flex_token_meaning = "EQUAL", s.token_type_cd = operator_code, s.token_type_meaning =
    "OPERATOR",
    s.data_type_cd = 0, s.data_type_meaning = null, s.flex_eval_cd = 0,
    s.flex_eval_meaning = null, s.precedence = 4, s.dynamic_text = null,
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = null, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = 0,
    s.data_source_meaning = null, s.parent_table = null, s.parent_id = 0,
    s.parent_meaning = null, s.display_table = null, s.display_id = 0,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = infix_code, s.seq_nbr = 0,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "INFIX", s.flex_token_cd
     = tapptloc_code,
    s.flex_token_meaning = "T_APPTLOC", s.token_type_cd = operand_code, s.token_type_meaning =
    "OPERAND",
    s.data_type_cd = double_code, s.data_type_meaning = "DOUBLE", s.flex_eval_cd = hc_code,
    s.flex_eval_meaning = "HARDCODED", s.precedence = 0, s.dynamic_text = null,
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = null, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = 0,
    s.data_source_meaning = null, s.parent_table = null, s.parent_id = 0,
    s.parent_meaning = null, s.display_table = null, s.display_id = 0,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = infix_code, s.seq_nbr = 1,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "INFIX", s.flex_token_cd
     = equal_code,
    s.flex_token_meaning = "EQUAL", s.token_type_cd = operator_code, s.token_type_meaning =
    "OPERATOR",
    s.data_type_cd = 0, s.data_type_meaning = null, s.flex_eval_cd = 0,
    s.flex_eval_meaning = null, s.precedence = 4, s.dynamic_text = null,
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = null, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = 0,
    s.data_source_meaning = null, s.parent_table = null, s.parent_id = 0,
    s.parent_meaning = null, s.display_table = null, s.display_id = 0,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  INSERT  FROM sch_flex_list s
   SET s.sch_flex_id = new_flex_id, s.flex_orient_cd = infix_code, s.seq_nbr = 2,
    s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.flex_orient_meaning = "INFIX", s.flex_token_cd
     = dapptloc_code,
    s.flex_token_meaning = "D_APPTLOC", s.token_type_cd = dtasource_code, s.token_type_meaning =
    "DATASOURCE",
    s.data_type_cd = double_code, s.data_type_meaning = "DOUBLE", s.flex_eval_cd = ds_code,
    s.flex_eval_meaning = "DATASOURCE", s.precedence = 0, s.dynamic_text = "SCH_GETF_FLEX_APPTLOC",
    s.oe_field_id = 0, s.dt_tm_value = null, s.double_value = 0,
    s.string_value = dept_disp, s.candidate_id = seq(sch_candidate_seq,nextval), s.null_dt_tm =
    cnvtdatetime("31-DEC-2100"),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.data_source_cd = location_code,
    s.data_source_meaning = "LOCATION", s.parent_table = "CODE_VALUE", s.parent_id = request->
    dept_code_value,
    s.parent_meaning = null, s.display_table = "CODE_VALUE", s.display_id = request->dept_code_value,
    s.display_meaning = null, s.font_name = null, s.font_size = 0,
    s.bold = 0, s.italic = 0, s.strikethru = 0,
    s.underline = 0, s.offset_units = 0, s.offset_units_cd = 0,
    s.offset_units_meaning = null, s.filter_table = null, s.filter_id = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to insert new flex rule: ",trim(flex_rule_disp),
    " on sch_flex_list.")
   GO TO exit_script
  ENDIF
  SET flex_id = new_flex_id
 ELSE
  SELECT INTO "nl:"
   FROM sch_order_duration sod
   PLAN (sod
    WHERE (sod.catalog_cd=request->catalog_code_value)
     AND sod.sch_flex_id=flex_id
     AND sod.location_cd=0
     AND sod.seq_nbr=0
     AND sod.active_ind=1)
   DETAIL
    update_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET flex_rule_ind = 0
 SELECT INTO "nl:"
  FROM sch_order_duration sod
  PLAN (sod
   WHERE (sod.catalog_cd=request->catalog_code_value)
    AND sod.sch_flex_id > 0
    AND sod.location_cd=0
    AND sod.seq_nbr=0
    AND sod.active_ind=1)
  DETAIL
   IF (sod.sch_flex_id != flex_id)
    flex_rule_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (update_ind=0)
  INSERT  FROM sch_order_duration s
   SET s.catalog_cd = request->catalog_code_value, s.location_cd = 0, s.seq_nbr = 0,
    s.sch_flex_id = flex_id, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_units = request->
    setup_duration,
    s.setup_units_cd = request->setup_unit_code_value, s.setup_units_meaning = set_unit_mean, s
    .duration_units = request->duration,
    s.duration_units_cd = request->duration_unit_code_value, s.duration_units_meaning = dur_unit_mean,
    s.cleanup_units = request->cleanup_duration,
    s.cleanup_units_cd = request->cleanup_unit_code_value, s.cleanup_units_meaning = clean_unit_mean,
    s.offset_type_cd = 0,
    s.offset_type_meaning = null, s.offset_beg_units = 0, s.offset_beg_units_cd = 0,
    s.offset_beg_units_meaning = null, s.offset_end_units = 0, s.offset_end_units_cd = 0,
    s.offset_end_units_meaning = null, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id =
    seq(sch_candidate_seq,nextval),
    s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), s.active_ind = 1,
    s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s
    .active_status_prsnl_id = reqinfo->updt_id,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.arrival_units = request->
    arrival_duration,
    s.arrival_units_cd = request->arrival_unit_code_value, s.arrival_units_meaning = arr_unit_mean, s
    .recovery_units = request->recovery_duration,
    s.recovery_units_cd = request->recovery_unit_code_value, s.recovery_units_meaning = rec_unit_mean
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat(
    "Unable to insert flex location order duration for catalog code value: ",trim(cnvtstring(request
      ->catalog_code_value))," on sch_order_duration.")
   GO TO exit_script
  ENDIF
 ELSE
  UPDATE  FROM sch_order_duration s
   SET s.setup_units = request->setup_duration, s.setup_units_cd = request->setup_unit_code_value, s
    .setup_units_meaning = set_unit_mean,
    s.duration_units = request->duration, s.duration_units_cd = request->duration_unit_code_value, s
    .duration_units_meaning = dur_unit_mean,
    s.cleanup_units = request->cleanup_duration, s.cleanup_units_cd = request->
    cleanup_unit_code_value, s.cleanup_units_meaning = clean_unit_mean,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.arrival_units = request->
    arrival_duration,
    s.arrival_units_cd = request->arrival_unit_code_value, s.arrival_units_meaning = arr_unit_mean, s
    .recovery_units = request->recovery_duration,
    s.recovery_units_cd = request->recovery_unit_code_value, s.recovery_units_meaning = rec_unit_mean
   WHERE (s.catalog_cd=request->catalog_code_value)
    AND s.location_cd=0
    AND s.seq_nbr=0
    AND s.sch_flex_id=flex_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat(
    "Unable to update flex location order duration for catalog code value: ",trim(cnvtstring(request
      ->catalog_code_value))," on sch_order_duration.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (flex_rule_ind=0)
  UPDATE  FROM sch_order_duration s
   SET s.setup_units = request->setup_duration, s.setup_units_cd = request->setup_unit_code_value, s
    .setup_units_meaning = set_unit_mean,
    s.duration_units = request->duration, s.duration_units_cd = request->duration_unit_code_value, s
    .duration_units_meaning = dur_unit_mean,
    s.cleanup_units = request->cleanup_duration, s.cleanup_units_cd = request->
    cleanup_unit_code_value, s.cleanup_units_meaning = clean_unit_mean,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
    reqinfo->updt_task,
    s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = (s.updt_cnt+ 1), s.arrival_units = request->
    arrival_duration,
    s.arrival_units_cd = request->arrival_unit_code_value, s.arrival_units_meaning = arr_unit_mean, s
    .recovery_units = request->recovery_duration,
    s.recovery_units_cd = request->recovery_unit_code_value, s.recovery_units_meaning = rec_unit_mean
   WHERE (s.catalog_cd=request->catalog_code_value)
    AND s.location_cd=0
    AND s.seq_nbr=0
    AND s.sch_flex_id=0
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat("Unable to update base duration for catalog code value: ",trim(
     cnvtstring(request->catalog_code_value))," on sch_order_duration.")
   GO TO exit_script
  ENDIF
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
