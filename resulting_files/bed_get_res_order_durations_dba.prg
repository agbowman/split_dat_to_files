CREATE PROGRAM bed_get_res_order_durations:dba
 FREE SET reply
 RECORD reply(
   1 duration = i4
   1 duration_unit_code_value = f8
   1 setup_duration = i4
   1 setup_unit_code_value = f8
   1 cleanup_duration = i4
   1 cleanup_unit_code_value = f8
   1 arrival_duration = i4
   1 arrival_unit_code_value = f8
   1 recovery_duration = i4
   1 recovery_unit_code_value = f8
   1 new_flex_warn_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
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
 SET flex_ind = 0
 SELECT INTO "nl:"
  FROM sch_order_duration sod,
   sch_flex_string sfs,
   sch_flex_list sfl,
   sch_flex_list sfl2,
   sch_flex_list sfl3
  PLAN (sod
   WHERE (sod.catalog_cd=request->catalog_code_value)
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
    AND (sfl3.parent_id=request->dept_code_value))
  DETAIL
   reply->duration = sod.duration_units, reply->duration_unit_code_value = sod.duration_units_cd,
   reply->setup_duration = sod.setup_units,
   reply->setup_unit_code_value = sod.setup_units_cd, reply->cleanup_duration = sod.cleanup_units,
   reply->cleanup_unit_code_value = sod.cleanup_units_cd,
   reply->arrival_duration = sod.arrival_units, reply->arrival_unit_code_value = sod.arrival_units_cd,
   reply->recovery_duration = sod.recovery_units,
   reply->recovery_unit_code_value = sod.recovery_units_cd, flex_ind = 1
  WITH nocounter
 ;end select
 IF (flex_ind=0)
  SELECT INTO "nl:"
   FROM sch_order_duration sod
   PLAN (sod
    WHERE (sod.catalog_cd=request->catalog_code_value)
     AND sod.sch_flex_id=0
     AND sod.location_cd=0
     AND sod.seq_nbr=0
     AND sod.active_ind=1)
   DETAIL
    reply->duration = sod.duration_units, reply->duration_unit_code_value = sod.duration_units_cd,
    reply->setup_duration = sod.setup_units,
    reply->setup_unit_code_value = sod.setup_units_cd, reply->cleanup_duration = sod.cleanup_units,
    reply->cleanup_unit_code_value = sod.cleanup_units_cd,
    reply->arrival_duration = sod.arrival_units, reply->arrival_unit_code_value = sod
    .arrival_units_cd, reply->recovery_duration = sod.recovery_units,
    reply->recovery_unit_code_value = sod.recovery_units_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM sch_order_duration sod,
    sch_flex_string sfs
   PLAN (sod
    WHERE (sod.catalog_cd=request->catalog_code_value)
     AND sod.sch_flex_id > 0
     AND sod.location_cd=0
     AND sod.seq_nbr=0
     AND sod.active_ind=1)
    JOIN (sfs
    WHERE sfs.sch_flex_id=sod.sch_flex_id
     AND sfs.flex_type_cd=ord_loc_code
     AND sfs.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     sfl.sch_flex_id
     FROM sch_flex_list sfl,
      sch_flex_list sfl2
     WHERE sfl.sch_flex_id=sfs.sch_flex_id
      AND sfl.flex_orient_cd=infix_code
      AND sfl.flex_token_cd=tapptloc_code
      AND sfl.flex_eval_cd=hc_code
      AND sfl2.sch_flex_id=sfl.sch_flex_id
      AND (sfl2.seq_nbr=(sfl.seq_nbr+ 1))
      AND sfl2.flex_orient_cd=infix_code
      AND sfl2.flex_token_cd=equal_code
      AND sfl2.active_ind=1))))
   HEAD REPORT
    reply->new_flex_warn_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
