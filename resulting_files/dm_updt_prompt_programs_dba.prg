CREATE PROGRAM dm_updt_prompt_programs:dba
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
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting dm_updt_prompt_programs script."
 UPDATE  FROM ccl_prompt_programs
  SET control_class_id = 1
  WHERE control_class_id=0
   AND list(program_name,group_no) IN (
  (SELECT
   program_name, group_no
   FROM ccl_prompt_definitions))
  WITH nocounter
 ;end update
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM ccl_prompt_programs
  WHERE control_class_id=0
   AND list(program_name,group_no) IN (
  (SELECT
   program_name, group_no
   FROM ccl_prompt_definitions))
  WITH nocounter
 ;end select
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET readme_data->message = "Updated all qualifying rows."
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = "Not all qualifying rows were updated."
  SET readme_data->status = "F"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
