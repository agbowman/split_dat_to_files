CREATE PROGRAM dcp_add_shx_chart_request:dba
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
 SET readme_data->message = "Readme Failed:  Starting script DCP_ADD_SHX_CHART_REQUEST "
 SET shxreqnumind = 0
 SET errorcode = 0
 SET errormessage = fillstring(132," ")
 SET display_text = "Social History"
 SELECT INTO "nl:"
  cdr.request_number
  FROM chart_discern_request cdr
  WHERE cdr.request_number=1349802
  DETAIL
   shxreqnumind = 1
  WITH nocounter
 ;end select
 IF (shxreqnumind=0)
  INSERT  FROM chart_discern_request cdr
   SET cdr.active_ind = 1, cdr.display_text = display_text, cdr.process_flag = 0,
    cdr.request_number = 1349802, cdr.scope_bit_map = 19, cdr.chart_discern_request_id = seq(
     reference_seq,nextval),
    cdr.updt_applctx = reqinfo->updt_applctx, cdr.updt_cnt = 0, cdr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    cdr.updt_id = reqinfo->updt_id, cdr.updt_task = reqinfo->updt_task
  ;end insert
  SET errorcode = error(errormessage,1)
  IF (errorcode != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "FAIL: DCP_ADD_SHX_CHART_REQUEST failed insert. Request number: 1349802. Error Message: ",
    errormessage)
   ROLLBACK
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success - All required CHART_DISCERN_REQUEST rows were updated successfully."
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
