CREATE PROGRAM dm_chk_temp_oe_format:dba
 SET c_mod = "DM_CHK_TEMP_OE_FORMAT 000"
 DECLARE readme_id = f8
 SET readme_id = 2182
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
 DECLARE oef_cnt = i4
 DECLARE toef_cnt = i4
 SET oef_cnt = 0
 SET toef_cnt = 0
 SELECT DISTINCT INTO "nl:"
  oef.oe_format_id, oef.oe_format_name
  FROM order_entry_format oef
  WHERE oef.oe_format_id > 0
  ORDER BY oef.oe_format_id
  HEAD REPORT
   oef_cnt = 0
  DETAIL
   oef_cnt = (oef_cnt+ 1)
  WITH nocounter
 ;end select
 IF (oef_cnt > 0)
  SELECT INTO "nl:"
   cnt = count(toef.rowid)
   FROM temp_oe_format toef
   WHERE toef.oe_format_id > 0
   DETAIL
    row + 0
   FOOT REPORT
    toef_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (oef_cnt != toef_cnt)
  SET readme_data->message =
  "Readme failed.  The number of rows on the temp and the order_entry_format tables do not match."
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = "Readme successful.  Temp_OE_Format table was successfully populated."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
END GO
