CREATE PROGRAM cps_upd_encntrproc_readme:dba
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
 SET readme_data->message = "Failed: starting cps_upd_encntrproc_readme"
 DECLARE rowcount = i4 WITH noconstant(0)
 DECLARE updatecount = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM scd_term_data td
  WHERE ((td.scd_term_data_key="encounter") OR (td.scd_term_data_key="proc_id_*"))
   AND td.fkey_entity_name != "ENCOUNTER"
   AND td.fkey_entity_name != "PROCEDURE"
   AND td.fkey_id != 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = "Term data for encounters does not exists:Completed Successfully"
  SET readme_data->status = "S"
  GO TO end_script
 ENDIF
 SET rowcount = curqual
 UPDATE  FROM scd_term_data td
  SET td.fkey_entity_name = "ENCOUNTER"
  WHERE td.scd_term_data_key="encounter"
   AND td.fkey_entity_name != "ENCOUNTER"
   AND td.fkey_entity_name != "PROCEDURE"
   AND td.fkey_id != 0
  WITH nocounter
 ;end update
 SET updatecount = curqual
 UPDATE  FROM scd_term_data td
  SET td.fkey_entity_name = "PROCEDURE"
  WHERE td.scd_term_data_key="proc_id_*"
   AND td.fkey_entity_name != "ENCOUNTER"
   AND td.fkey_entity_name != "PROCEDURE"
   AND td.fkey_id != 0
  WITH nocounter
 ;end update
 SET updatecount = (curqual+ updatecount)
 IF (updatecount=rowcount)
  SET readme_data->message = build(updatecount,"   Rows are updated:Completed Successfully")
  SET readme_data->status = "S"
  COMMIT
 ELSE
  SET readme_data->message = "Term data for encounter procedures failed to update"
  ROLLBACK
 ENDIF
#end_script
 EXECUTE dm_readme_status echorecord(readme_data)
END GO
