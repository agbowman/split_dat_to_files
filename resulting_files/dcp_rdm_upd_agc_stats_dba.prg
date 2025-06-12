CREATE PROGRAM dcp_rdm_upd_agc_stats:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dcp_rdm_upd_agc_stats.prg."
 DECLARE error_msg = vc WITH protect
 DECLARE chart_source_cd = f8 WITH protect, noconstant(0.0)
 DECLARE chart_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE chart_definition_id = f8 WITH protect, noconstant(0.0)
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE bad_stat_median_value = f8 WITH protect, noconstant(28.71954895)
 DECLARE bad_stat_coeffnt_var_value = f8 WITH protect, noconstant(0.079293656)
 DECLARE bad_stat_box_cox_power_value = f8 WITH protect, noconstant(- (0.1202368))
 DECLARE non_interp_row_cnt = i4 WITH protect, noconstant(25)
 DECLARE interp_row_cnt = i4 WITH protect, noconstant(57)
 DECLARE isdatabad = i2 WITH protect, noconstant(0)
 DECLARE isdatastillbad = i2 WITH protect, noconstant(0)
 DECLARE datastatfile = vc WITH protect, noconstant("cer_install:pretermfentonhcage_stats_v2.csv")
 SET row_cnt = 0
 SELECT INTO "nl:"
  FROM chart_definition cd
  DETAIL
   row_cnt = (row_cnt+ 1)
  WITH nocounter
 ;end select
 IF (row_cnt <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: No data exists on chart_definition table. Chart hasn't been imported. No need to import data"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=255551
   AND cv.cdf_meaning="PREMHCFORAGE"
   AND cv.active_ind=1
  DETAIL
   chart_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up code value for CDF_MEANING 'PREMHCFORAGE' from CODE_SET 255551.",
   error_msg)
  GO TO exit_script
 ENDIF
 IF (chart_type_cd <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: CDF_MEANING of 'PREMHCFORAGE' from CODE_SET 255551 not found. Chart hasn't been imported. No need to import data"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=255550
   AND cv.display_key="FENTON"
   AND cv.active_ind=1
  DETAIL
   chart_source_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up code value for DISPLAY_KEY 'FENTON' from CODE_SET 255550.",error_msg)
  GO TO exit_script
 ENDIF
 IF (chart_source_cd <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: DISPLAY_KEY of 'FENTON' from CODE_SET 255550 not found, Fenton chart hasn't been imported. No need to import data."
  GO TO exit_script
 ENDIF
 CALL echo(build("chart source code: ",chart_source_cd))
 CALL echo(build("chart_type_cd: ",chart_type_cd))
 SET row_cnt = 0
 SELECT INTO "nl:"
  FROM chart_definition cd
  WHERE cd.chart_source_cd=chart_source_cd
   AND cd.chart_type_cd=chart_type_cd
  DETAIL
   row_cnt = (row_cnt+ 1), chart_definition_id = cd.chart_definition_id
  WITH nocounter
 ;end select
 IF (row_cnt > 1)
  CALL echo("Failed: Multiple Fenton preterm head circumference charts found.")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed: Multiple Fenton preterm head circumference charts found.",error_msg)
  GO TO exit_script
 ENDIF
 CALL echo(build("chart_definition_id: ",chart_definition_id))
 IF (chart_definition_id <= 0)
  CALL echo(
   "The chart: Preterm Head Circumference-for-Age 22-50 Weeks. Fenton, 2003 has not been imported.")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: The Fenton Head Circ Chart hasn't been imported. dcp_rdm_upd_agc_stats performed all required tasks."
  GO TO exit_script
 ENDIF
 SET row_cnt = 0
 SELECT INTO "nl:"
  FROM ref_datastats rds
  WHERE rds.chart_definition_id=chart_definition_id
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (rds.median_value=bad_stat_median_value
    AND rds.coeffnt_var_value=bad_stat_coeffnt_var_value
    AND rds.box_cox_power_value=bad_stat_box_cox_power_value)
    isdatabad = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("row count: ",row_cnt))
 CALL echo(build("isDataBad: ",isdatabad))
 IF (row_cnt=non_interp_row_cnt
  AND isdatabad=0)
  CALL echo("data is valid")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: The Fenton Head Circ Chart data is valid. dcp_rdm_upd_agc_stats performed all required tasks."
  GO TO exit_script
 ELSEIF (row_cnt=interp_row_cnt
  AND isdatabad=0)
  CALL echo("data contains interpolated data and is valid")
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: The interpolated Fenton Head Circ Chart data is valid. dcp_rdm_upd_agc_stats performed all required tasks."
  GO TO exit_script
 ELSEIF (row_cnt=interp_row_cnt
  AND isdatabad=1)
  CALL echo("Contains interp data with bad data, Import can't handle this, so fail.")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure: The interpolated Fenton Head Circ Chart data is invalid. ",error_msg)
  GO TO exit_script
 ELSEIF (row_cnt != non_interp_row_cnt
  AND row_cnt != interp_row_cnt)
  CALL echo("Contains less/more rows than either data file.")
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure: Found invalid number of rows, cannot validate if data is correct",error_msg)
  GO TO exit_script
 ELSEIF (row_cnt=non_interp_row_cnt
  AND isdatabad=1)
  CALL echo(
   "Data is invalid and contains the correct number of rows, so run script to import valid data.")
  EXECUTE dm_dbimport value(datastatfile), "cps_rdm_imp_chart_datastats", 500
  IF ((readme_data->status="F"))
   CALL echo("cps_rdm_imp_chart_datastats failed.")
   GO TO exit_script
  ENDIF
  SET row_cnt = 0
  SELECT INTO "nl:"
   FROM ref_datastats rds
   WHERE rds.chart_definition_id=chart_definition_id
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (rds.median_value=bad_stat_median_value
     AND rds.coeffnt_var_value=bad_stat_coeffnt_var_value
     AND rds.box_cox_power_value=bad_stat_box_cox_power_value)
     isdatastillbad = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("row cnt after import: ",row_cnt))
  CALL echo(build("isDataStillBad:",isdatastillbad))
  IF (row_cnt != non_interp_row_cnt)
   CALL echo("Import script cps_rdm_imp_chart_datastats failed, number of rows is not correct.")
   SET readme_data->status = "F"
   SET readme_data->message =
   "Failure: Script cps_rdm_imp_chart_datastats failed, did not update the correct number of rows."
   GO TO exit_script
  ELSEIF (isdatastillbad=1)
   CALL echo("Import script cps_rdm_imp_chart_datastats failed, data is still invalid")
   SET readme_data->status = "F"
   SET readme_data->message =
   "Failure: Script cps_rdm_imp_chart_datastats failed, data is still invalid."
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dcp_rdm_upd_agc_stats performed all required tasks"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
