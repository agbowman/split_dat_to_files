CREATE PROGRAM bed_get_res_check_flex_rule:dba
 FREE SET reply
 RECORD reply(
   1 dup_flex_rule_ind = i2
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
 SET odur_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16162
   AND cv.cdf_meaning="ODUR"
   AND cv.active_ind=1
  DETAIL
   odur_code = cv.code_value
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
 SET tapptloc_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16160
   AND cv.cdf_meaning="T_APPTLOC"
   AND cv.active_ind=1
  DETAIL
   tapptloc_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = T_APPTLOC from",
   " code set 16160.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = T_APPTLOC found on",
   " code set 16160.")
 ENDIF
 SET dapptloc_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16160
   AND cv.cdf_meaning="D_APPTLOC"
   AND cv.active_ind=1
  DETAIL
   dapptloc_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = D_APPTLOC from",
   " code set 16160.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = D_APPTLOC found on",
   " code set 16160.")
 ENDIF
 SET flex_tok_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16148
   AND cv.cdf_meaning="FLEXTOKTYPE"
   AND cv.active_ind=1
  DETAIL
   flex_tok_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = FLEXTOKTYPE from",
   " code set 16148.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = FLEXTOKTYPE found on",
   " code set 16148.")
 ENDIF
 SET dappt_loc_ind = 0
 SELECT INTO "nl:"
  FROM sch_simple_assoc a
  PLAN (a
   WHERE a.parent_table="CODE_VALUE"
    AND a.parent_id=odur_code
    AND a.assoc_type_cd=flex_tok_code
    AND a.child_table="CODE_VALUE"
    AND a.child_id=dapptloc_code
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   dappt_loc_ind = 1
  WITH nocounter
 ;end select
 IF (dappt_loc_ind=0)
  INSERT  FROM sch_simple_assoc t
   SET t.parent_table = "CODE_VALUE", t.parent_id = odur_code, t.assoc_type_cd = flex_tok_code,
    t.child_table = "CODE_VALUE", t.child_id = dapptloc_code, t.parent_meaning = "ODUR",
    t.child_meaning = "D_APPTLOC", t.assoc_type_meaning = "FLEXTOKTYPE", t.seq_nbr = 0,
    t.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), t.candidate_id = seq(sch_candidate_seq,
     nextval), t.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), t.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), t.active_ind = 1,
    t.active_status_cd = active_code_value, t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t
    .active_status_prsnl_id = 0,
    t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_applctx = 0, t.updt_id = 0,
    t.updt_cnt = 0, t.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat(
    "Unable to insert row for flex token meaning=D_APPTLOC on sch_simple_assoc")
   GO TO exit_script
  ENDIF
 ENDIF
 SET tappt_loc_ind = 0
 SELECT INTO "nl:"
  FROM sch_simple_assoc a
  PLAN (a
   WHERE a.parent_table="CODE_VALUE"
    AND a.parent_id=odur_code
    AND a.assoc_type_cd=flex_tok_code
    AND a.child_table="CODE_VALUE"
    AND a.child_id=tapptloc_code
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   tappt_loc_ind = 1
  WITH nocounter
 ;end select
 IF (tappt_loc_ind=0)
  INSERT  FROM sch_simple_assoc t
   SET t.parent_table = "CODE_VALUE", t.parent_id = odur_code, t.assoc_type_cd = flex_tok_code,
    t.child_table = "CODE_VALUE", t.child_id = tapptloc_code, t.parent_meaning = "ODUR",
    t.child_meaning = "T_APPTLOC", t.assoc_type_meaning = "FLEXTOKTYPE", t.seq_nbr = 0,
    t.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), t.candidate_id = seq(sch_candidate_seq,
     nextval), t.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), t.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), t.active_ind = 1,
    t.active_status_cd = active_code_value, t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t
    .active_status_prsnl_id = 0,
    t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_applctx = 0, t.updt_id = 0,
    t.updt_cnt = 0, t.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET reply->error_msg = concat(
    "Unable to insert row for flex token meaning=T_APPTLOC on sch_simple_assoc")
   GO TO exit_script
  ENDIF
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
 SET equal_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16160
   AND cv.cdf_meaning="EQUAL"
   AND cv.active_ind=1
  DETAIL
   equal_code = cv.code_value
  WITH nocounter
 ;end select
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
 SET flex_cnt = 0
 SET cat_cnt = 0
 SELECT INTO "nl:"
  FROM sch_flex_string sfs,
   sch_flex_list sfl,
   sch_flex_list sfl2,
   sch_flex_list sfl3,
   sch_order_duration sod
  PLAN (sfs
   WHERE sfs.flex_type_cd=odur_code
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
  ORDER BY sfs.sch_flex_id
  HEAD REPORT
   flex_cnt = 0, cat_cnt = 0
  HEAD sfs.sch_flex_id
   flex_cnt = (flex_cnt+ 1)
   IF (sod.catalog_cd > 0)
    cat_cnt = (cat_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (flex_cnt > 1
  AND cat_cnt != 1)
  SET reply->dup_flex_rule_ind = 1
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
