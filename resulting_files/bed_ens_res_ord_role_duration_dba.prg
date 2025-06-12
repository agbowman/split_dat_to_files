CREATE PROGRAM bed_ens_res_ord_role_duration:dba
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
 FREE SET temp_orders
 RECORD temp_orders(
   1 orders[*]
     2 catalog_code_value = f8
     2 dept_code_value = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET res_role_code = 0
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
 SET ovr_code = 0.0
 SET inh_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=23001
   AND cv.cdf_meaning IN ("OVERRIDE", "INHERIT")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="OVERRIDE")
    ovr_code = cv.code_value
   ELSEIF (cv.cdf_meaning="INHERIT")
    inh_code = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (ovr_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = OVERRIDE from",
   " code set 23001.")
 ENDIF
 IF (inh_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = INHERIT from",
   " code set 23001.")
 ENDIF
 SET min_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=54
   AND cv.cdf_meaning="MINUTES"
   AND cv.active_ind=1
  DETAIL
   min_code = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = MINUTES from",
   " code set 54.")
 ELSEIF (curqual > 1)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Multiple code values with cdf_meaning = MINUTES found on",
   " code set 54.")
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
   AND cv.cdf_meaning="INFIX"
   AND cv.active_ind=1
  DETAIL
   infix_code = cv.code_value
  WITH nocounter
 ;end select
 IF (infix_code=0)
  SET error_flag = "Y"
  SET reply->error_msg = concat("Unable to retrive code value with cdf_meaning = INFIX from",
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
 SET req_cnt = size(request->ord_roles,5)
 FOR (x = 1 TO req_cnt)
   IF ((request->ord_roles[x].overwrite_ind=1))
    SET temp_cnt = 0
    SET delete_ind = 1
    SET temp_cnt = size(temp_orders->orders,5)
    IF (temp_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = temp_cnt)
      PLAN (d
       WHERE (temp_orders->orders[d.seq].catalog_code_value=request->ord_roles[x].catalog_code_value)
        AND (temp_orders->orders[d.seq].dept_code_value=request->ord_roles[x].dept_code_value))
      DETAIL
       delete_ind = 0
      WITH nocounter
     ;end select
    ENDIF
    IF (delete_ind=1)
     DELETE  FROM sch_order_role s
      WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
       AND (s.location_cd=request->ord_roles[x].dept_code_value)
      WITH nocounter
     ;end delete
     DELETE  FROM sch_order_duration s
      WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
       AND (s.location_cd=request->ord_roles[x].dept_code_value)
      WITH nocounter
     ;end delete
     SET stat = alterlist(temp_orders->orders,(temp_cnt+ 1))
     SET temp_orders->orders[(temp_cnt+ 1)].catalog_code_value = request->ord_roles[x].
     catalog_code_value
     SET temp_orders->orders[(temp_cnt+ 1)].dept_code_value = request->ord_roles[x].dept_code_value
    ENDIF
    INSERT  FROM sch_order_role s
     SET s.catalog_cd = request->ord_roles[x].catalog_code_value, s.location_cd = request->ord_roles[
      x].dept_code_value, s.seq_nbr = request->ord_roles[x].seq_nbr,
      s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s
      .list_role_id = request->ord_roles[x].ord_role_id,
      s.sch_flex_id = 0, s.candidate_id = seq(sch_candidate_seq,nextval), s.beg_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
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
     SET reply->error_msg = concat("Unable to insert order role: ",trim(cnvtstring(request->
        ord_roles[x].ord_role_id))," on sch_order_role.")
     GO TO exit_script
    ENDIF
   ENDIF
   DECLARE dur_unit_mean = vc
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->ord_roles[x].duration_unit_code_value)
     AND cv.active_ind=1
    DETAIL
     dur_unit_mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   DECLARE set_unit_mean = vc
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->ord_roles[x].setup_unit_code_value)
     AND cv.active_ind=1
    DETAIL
     set_unit_mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   DECLARE clean_unit_mean = vc
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->ord_roles[x].cleanup_unit_code_value)
     AND cv.active_ind=1
    DETAIL
     clean_unit_mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   DECLARE off_unit_mean = vc
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.code_value=request->ord_roles[x].offset_unit_code_value)
     AND cv.active_ind=1
    DETAIL
     off_unit_mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   SET row_exists_ind = 0
   SELECT INTO "nl:"
    FROM sch_order_duration s
    PLAN (s
     WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
      AND (s.location_cd=request->ord_roles[x].dept_code_value)
      AND (s.seq_nbr=request->ord_roles[x].seq_nbr)
      AND s.sch_flex_id=0
      AND s.active_ind=1)
    DETAIL
     row_exists_ind = 1
    WITH nocounter
   ;end select
   SET flex_id = 0.0
   SELECT INTO "nl:"
    FROM sch_flex_string sfs,
     sch_flex_list sfl,
     sch_flex_list sfl2,
     sch_flex_list sfl3,
     sch_order_duration sod
    PLAN (sod
     WHERE (sod.catalog_cd=request->ord_roles[x].catalog_code_value)
      AND sod.sch_flex_id > 0
      AND sod.location_cd=0
      AND sod.seq_nbr=0
      AND sod.active_ind=1)
     JOIN (sfs
     WHERE sfs.sch_flex_id=sod.sch_flex_id
      AND sfs.flex_type_cd=ord_loc_code
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
      AND (sfl3.parent_id=request->ord_roles[x].dept_code_value))
    DETAIL
     flex_id = sfs.sch_flex_id
    WITH nocounter
   ;end select
   SET override_ind = 1
   SELECT INTO "nl:"
    FROM sch_order_duration s
    PLAN (s
     WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
      AND s.location_cd=0
      AND s.seq_nbr=0
      AND s.sch_flex_id=flex_id
      AND s.active_ind=1
      AND (s.duration_units=request->ord_roles[x].duration)
      AND (s.duration_units_cd=request->ord_roles[x].duration_unit_code_value)
      AND (s.setup_units=request->ord_roles[x].setup_duration)
      AND (s.setup_units_cd=request->ord_roles[x].setup_unit_code_value)
      AND (s.cleanup_units=request->ord_roles[x].cleanup_duration)
      AND (s.cleanup_units_cd=request->ord_roles[x].cleanup_unit_code_value))
    DETAIL
     override_ind = 0
    WITH nocounter
   ;end select
   IF (row_exists_ind=0
    AND override_ind=1)
    INSERT  FROM sch_order_duration s
     SET s.catalog_cd = request->ord_roles[x].catalog_code_value, s.location_cd = request->ord_roles[
      x].dept_code_value, s.seq_nbr = request->ord_roles[x].seq_nbr,
      s.sch_flex_id = 0, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_units = request->
      ord_roles[x].setup_duration,
      s.setup_units_cd = request->ord_roles[x].setup_unit_code_value, s.setup_units_meaning =
      set_unit_mean, s.duration_units = request->ord_roles[x].duration,
      s.duration_units_cd = request->ord_roles[x].duration_unit_code_value, s.duration_units_meaning
       = dur_unit_mean, s.cleanup_units = request->ord_roles[x].cleanup_duration,
      s.cleanup_units_cd = request->ord_roles[x].cleanup_unit_code_value, s.cleanup_units_meaning =
      clean_unit_mean, s.offset_type_cd = ovr_code,
      s.offset_type_meaning = "OVERRIDE", s.offset_beg_units = request->ord_roles[x].offset, s
      .offset_beg_units_cd = request->ord_roles[x].offset_unit_code_value,
      s.offset_beg_units_meaning = off_unit_mean, s.offset_end_units = 0, s.offset_end_units_cd = 0,
      s.offset_end_units_meaning = null, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id
       = seq(sch_candidate_seq,nextval),
      s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), s.active_ind = 1,
      s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      s.active_status_prsnl_id = reqinfo->updt_id,
      s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
      reqinfo->updt_task,
      s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.arrival_units = 0,
      s.arrival_units_cd = 0, s.arrival_units_meaning = null, s.recovery_units = 0,
      s.recovery_units_cd = 0, s.recovery_units_meaning = null
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert order role durations: ",trim(cnvtstring(request
        ->ord_roles[x].ord_role_id))," on sch_order_duration.")
     GO TO exit_script
    ENDIF
   ELSEIF (row_exists_ind=0
    AND override_ind=0)
    INSERT  FROM sch_order_duration s
     SET s.catalog_cd = request->ord_roles[x].catalog_code_value, s.location_cd = request->ord_roles[
      x].dept_code_value, s.seq_nbr = request->ord_roles[x].seq_nbr,
      s.sch_flex_id = 0, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.setup_units = 0,
      s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES", s.duration_units = 0,
      s.duration_units_cd = min_code, s.duration_units_meaning = "MINUTES", s.cleanup_units = 0,
      s.cleanup_units_cd = min_code, s.cleanup_units_meaning = "MINUTES", s.offset_type_cd = inh_code,
      s.offset_type_meaning = "INHERIT", s.offset_beg_units = request->ord_roles[x].offset, s
      .offset_beg_units_cd = request->ord_roles[x].offset_unit_code_value,
      s.offset_beg_units_meaning = off_unit_mean, s.offset_end_units = 0, s.offset_end_units_cd = 0,
      s.offset_end_units_meaning = null, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id
       = seq(sch_candidate_seq,nextval),
      s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), s.active_ind = 1,
      s.active_status_cd = active_code_value, s.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      s.active_status_prsnl_id = reqinfo->updt_id,
      s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_id = reqinfo->updt_id, s.updt_task =
      reqinfo->updt_task,
      s.updt_applctx = reqinfo->updt_applctx, s.updt_cnt = 0, s.arrival_units = 0,
      s.arrival_units_cd = 0, s.arrival_units_meaning = null, s.recovery_units = 0,
      s.recovery_units_cd = 0, s.recovery_units_meaning = null
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to insert order role durations: ",trim(cnvtstring(request
        ->ord_roles[x].ord_role_id))," on sch_order_duration.")
     GO TO exit_script
    ENDIF
   ELSEIF (row_exists_ind=1
    AND override_ind=1)
    UPDATE  FROM sch_order_duration s
     SET s.setup_units = request->ord_roles[x].setup_duration, s.setup_units_cd = request->ord_roles[
      x].setup_unit_code_value, s.setup_units_meaning = set_unit_mean,
      s.duration_units = request->ord_roles[x].duration, s.duration_units_cd = request->ord_roles[x].
      duration_unit_code_value, s.duration_units_meaning = dur_unit_mean,
      s.cleanup_units = request->ord_roles[x].cleanup_duration, s.cleanup_units_cd = request->
      ord_roles[x].cleanup_unit_code_value, s.cleanup_units_meaning = clean_unit_mean,
      s.offset_type_cd = ovr_code, s.offset_type_meaning = "OVERRIDE", s.offset_beg_units = request->
      ord_roles[x].offset,
      s.offset_beg_units_cd = request->ord_roles[x].offset_unit_code_value, s
      .offset_beg_units_meaning = off_unit_mean, s.offset_end_units = 0,
      s.offset_end_units_cd = 0, s.offset_end_units_meaning = null, s.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx,
      s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
      AND (s.location_cd=request->ord_roles[x].dept_code_value)
      AND (s.seq_nbr=request->ord_roles[x].seq_nbr)
      AND s.sch_flex_id=0
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update order role durations: ",trim(cnvtstring(request
        ->ord_roles[x].ord_role_id))," on sch_order_duration.")
     GO TO exit_script
    ENDIF
   ELSEIF (row_exists_ind=1
    AND override_ind=0)
    UPDATE  FROM sch_order_duration s
     SET s.setup_units = 0, s.setup_units_cd = min_code, s.setup_units_meaning = "MINUTES",
      s.duration_units = 0, s.duration_units_cd = min_code, s.duration_units_meaning = "MINUTES",
      s.cleanup_units = 0, s.cleanup_units_cd = min_code, s.cleanup_units_meaning = "MINUTES",
      s.offset_type_cd = inh_code, s.offset_type_meaning = "INHERIT", s.offset_beg_units = request->
      ord_roles[x].offset,
      s.offset_beg_units_cd = request->ord_roles[x].offset_unit_code_value, s
      .offset_beg_units_meaning = off_unit_mean, s.offset_end_units = 0,
      s.offset_end_units_cd = 0, s.offset_end_units_meaning = null, s.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx,
      s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.catalog_cd=request->ord_roles[x].catalog_code_value)
      AND (s.location_cd=request->ord_roles[x].dept_code_value)
      AND (s.seq_nbr=request->ord_roles[x].seq_nbr)
      AND s.sch_flex_id=0
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update order role durations: ",trim(cnvtstring(request
        ->ord_roles[x].ord_role_id))," on sch_order_duration.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
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
