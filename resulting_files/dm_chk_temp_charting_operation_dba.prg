CREATE PROGRAM dm_chk_temp_charting_operation:dba
 SET c_mod = "DM_CHK_TEMP_CHARTING_OPERATION 000"
 DECLARE readme_id = f8
 SET readme_id = 2181
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
 IF (validate(readme_data->readme_id,0)=0
  AND validate(readme_data->readme_id,1)=1)
  SET readme_data->readme_id = readme_id
 ENDIF
 DECLARE co_cnt = i4
 DECLARE tco_cnt = i4
 SET co_cnt = 0
 SET tco_cnt = 0
 SELECT DISTINCT INTO "nl:"
  co.charting_operations_id, co.batch_name
  FROM charting_operations co
  WHERE co.charting_operations_id > 0
  ORDER BY co.charting_operations_id
  HEAD REPORT
   co_cnt = 0
  HEAD co.charting_operations_id
   co_cnt = (co_cnt+ 1)
  DETAIL
   row + 0
  WITH nocounter
 ;end select
 IF (co_cnt > 0)
  SELECT INTO "nl:"
   cnt = count(tco.rowid)
   FROM temp_charting_operations tco
   WHERE tco.charting_operations_id > 0
   DETAIL
    row + 0
   FOOT REPORT
    tco_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (co_cnt != tco_cnt)
  SET readme_data->message =
  "Readme failed.  The number of rows on the temp and the charting_operations tables do not match."
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message =
  "Readme successful.  Temp_Charting_Operations table was successfully populated."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
