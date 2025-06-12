CREATE PROGRAM cco_check_von_prompt_load:dba
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
 SET readme_data->message = "Readme Failed: Starting cco_check_von_prompt_load.prg script"
 SET prompts_loaded = 0
 SELECT INTO "nl:"
  FROM ccl_prompt_definitions c
  WHERE c.program_name IN ("CCO_RPT_VON_EXTRACT_PROMPT", "CCO_RPT_VON_PATIENTLIST",
  "CCO_UPD_VON_ADMIN_PROMPT")
   AND c.position=0
  HEAD REPORT
   prompts_loaded = 0
  DETAIL
   prompts_loaded = (prompts_loaded+ 1)
  WITH nocounter
 ;end select
 IF (prompts_loaded=3)
  CALL echo("VON Prompts loaded successfully")
  SET readme_data->status = "S"
  SET readme_data->message = "Success: VON Prompts loaded successfully"
 ELSE
  CALL echo(build("not all VON Prompts loaded, count (3) =",prompts_loaded))
  SET readme_data->message = build("not all VON Prompts loaded, count (3) =",prompts_loaded)
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
