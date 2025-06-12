CREATE PROGRAM dcp_rdm_del_agc_data:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_rdm_del_agc_data.prg."
 DECLARE row_cnt = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect
 DECLARE chart_source_cd = f8 WITH protect
 DECLARE chart_type_cd = f8 WITH protect
 DECLARE chart_definition_id = f8 WITH protect, noconstant(0.0)
 DECLARE ref_dataset_id = f8 WITH protect, noconstant(0.0)
 DECLARE male_cd = f8 WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=255550
   AND cv.display_key="CDCWHO"
   AND cv.active_ind=1
  DETAIL
   chart_source_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up code value for DISPLAY_KEY 'CDCWHO' from CODE_SET 255550.",error_msg)
  GO TO exit_script
 ENDIF
 IF (chart_source_cd <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: DISPLAY_KEY of 'CDCWHO' from CODE_SET 255550 not found, CDC'S WHO chart hasn't been imported. No need to import data."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=255551
   AND cv.cdf_meaning="LENAGE"
   AND cv.active_ind=1
  DETAIL
   chart_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up code value for CDF_MEANING 'LENAGE' from CODE_SET 255551.",error_msg)
  GO TO exit_script
 ENDIF
 IF (chart_type_cd <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: CDF_MEANING of 'LENAGE' from CODE_SET 255551 not found. Chart hasn't been imported. No need to import data"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=57
   AND cv.cdf_meaning="MALE"
   AND cv.active_ind=1
  DETAIL
   male_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up code value for CDF_MEANING 'MALE' from CODE_SET 57.",error_msg)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***	chart source code: ",chart_source_cd))
 CALL echo(build("***	chart_type_cd: ",chart_type_cd))
 CALL echo(build("***	male_cd: ",male_cd))
 CALL echo("***")
 SELECT INTO "nl:"
  FROM chart_definition cd
  WHERE cd.chart_source_cd=chart_source_cd
   AND cd.chart_type_cd=chart_type_cd
   AND cd.sex_cd=male_cd
   AND cd.active_ind=1
  DETAIL
   row_cnt = (row_cnt+ 1), chart_definition_id = cd.chart_definition_id
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up chart definition for CDC's WHO length-for-age 0-2 years.",error_msg)
  GO TO exit_script
 ENDIF
 IF (row_cnt <= 0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success: No data exists on chart_definition table. Chart has not been imported. No need to import new data"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***	chart_definition_id: ",chart_definition_id))
 CALL echo("***")
 SELECT INTO "nl:"
  FROM ref_dataset rd
  WHERE rd.chart_definition_id=chart_definition_id
   AND rd.active_ind=1
   AND rd.display_name="98"
  ORDER BY rd.display_name
  DETAIL
   ref_dataset_id = rd.ref_dataset_id
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed looking up data set ids for CDC's WHO length-for-age 0-2 years.",error_msg)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***	ref_dataset_id: ",ref_dataset_id))
 CALL echo("***")
 DELETE  FROM ref_datapoint rdp
  WHERE rdp.ref_dataset_id=ref_dataset_id
 ;end delete
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Query failed while deleting the incorrect rows on the REF_DATAPOINT table.",error_msg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: dcp_rdm_del_agc_data performed all required tasks.",
  "Please import cer_install:who_lenage_0_2_years_data-correction.csv ",
  "and cer_install:who_lenage_0_2_years_stats-correction.csv files ",
  "by running the 'cps_import_charts go' command in CCL.")
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
