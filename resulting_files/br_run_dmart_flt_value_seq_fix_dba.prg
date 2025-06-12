CREATE PROGRAM br_run_dmart_flt_value_seq_fix:dba
 FREE RECORD datamart_values_to_update
 RECORD datamart_values_to_update(
   1 values[*]
     2 br_datamart_value_id = f8
 )
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
 SET readme_data->message = "Readme Failed: Starting <br_run_flt_value_seq_fix.prg> script"
 DECLARE code_set_shared_meaning = vc WITH protect, constant("CODE_SET_SHARED")
 DECLARE mpage_type_flag = i2 WITH protect, constant(1)
 DECLARE list_increase_size = i4 WITH protect, constant(100)
 DECLARE value_count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE logdebugmessage(message=vc) = null
 DECLARE logdebugrecordstates(dummy_var=i2) = null
 DECLARE checkforerrors(error_message=vc) = null
 DECLARE cleanup(dummy_var=i2) = null
 CALL logdebugmessage("Starting the script execution.")
 CALL logdebugmessage("Starting pull of filter values to update.")
 SELECT INTO "nl:"
  FROM br_datamart_filter_category fil_cat,
   br_datamart_filter fil,
   br_datamart_category cat,
   br_datamart_value val
  PLAN (fil_cat
   WHERE fil_cat.filter_category_type_mean=code_set_shared_meaning)
   JOIN (fil
   WHERE fil.filter_category_mean=fil_cat.filter_category_mean)
   JOIN (cat
   WHERE cat.br_datamart_category_id=fil.br_datamart_category_id
    AND cat.category_type_flag != mpage_type_flag)
   JOIN (val
   WHERE val.br_datamart_category_id=cat.br_datamart_category_id
    AND val.br_datamart_filter_id=fil.br_datamart_filter_id
    AND val.value_seq != 0)
  HEAD REPORT
   value_count = 0
  DETAIL
   IF (mod(value_count,list_increase_size)=0)
    stat = alterlist(datamart_values_to_update->values,(value_count+ list_increase_size))
   ENDIF
   value_count = (value_count+ 1), datamart_values_to_update->values[value_count].
   br_datamart_value_id = val.br_datamart_value_id
  FOOT REPORT
   stat = alterlist(datamart_values_to_update->values,value_count)
  WITH nocounter
 ;end select
 CALL checkforerrors("ERROR 001: Failed to recieve filter values to update.")
 CALL logdebugmessage("Finished the pull of filter values to update.")
 CALL logdebugrecordstates(0)
 CALL logdebugmessage("Starting update of filter values to update.")
 FOR (index = 0 TO value_count)
   CALL logdebugmessage(concat("Updating value item- ",cnvtstring(index)))
   UPDATE  FROM br_datamart_value val
    SET val.value_seq = 0, val.updt_applctx = reqinfo->updt_applctx, val.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     val.updt_id = reqinfo->updt_task, val.updt_task = reqinfo->updt_id, val.updt_cnt = (val.updt_cnt
     + 1)
    PLAN (val
     WHERE (val.br_datamart_value_id=datamart_values_to_update->values[index].br_datamart_value_id))
    WITH nocounter
   ;end update
   CALL checkforerrors("ERROR 002: Failed while updating filter value's value_seqs.")
 ENDFOR
 CALL logdebugmessage("Finished updating filter value's value_seqs.")
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_run_flt_value_seq_fix.prg> script"
#exit_script
 CALL cleanup(0)
 IF (validate(running_bedrock_unit_test)=0)
  EXECUTE dm_readme_status
  IF ((readme_data->status="S"))
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
 CALL echorecord(readme_data)
 SUBROUTINE logdebugmessage(message)
   IF (validate(debug,0)=1)
    CALL echo("DEBUG MESSAGE: ")
    CALL echo(message)
   ENDIF
 END ;Subroutine
 SUBROUTINE logdebugrecordstates(message)
   IF (validate(debug,0)=1)
    CALL echo("DEBUG MESSAGE: ")
    CALL echorecord(datamart_values_to_update)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforerrors(error_message)
  DECLARE cur_error = vc WITH protect, noconstant("")
  IF (error(cur_error,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat(error_message,cur_error)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE cleanup(dummy_var)
   FREE RECORD datamart_values_to_update
 END ;Subroutine
END GO
