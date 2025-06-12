CREATE PROGRAM dcp_upd_core_ind:dba
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
 SET readme_data->message = build("Init core_ind on oe_format_fields table")
 EXECUTE dm_readme_status
 COMMIT
 UPDATE  FROM oe_format_fields off
  SET off.core_ind = 1
  WHERE ((off.clin_line_ind=1) OR (off.oe_field_id IN (
  (SELECT
   oef.oe_field_id
   FROM order_entry_fields oef
   WHERE oef.oe_field_meaning_id IN (114, 2037, 2055, 2071, 2097,
   2061, 2062, 2094, 2096)))))
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 SET readme_data->message = build("Finished Initializing core_ind.")
 EXECUTE dm_readme_status
 COMMIT
#exit_program
END GO
