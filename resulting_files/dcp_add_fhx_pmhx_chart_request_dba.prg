CREATE PROGRAM dcp_add_fhx_pmhx_chart_request:dba
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
 SET readme_data->message = "Readme Failed:  Starting script DCP_ADD_FHX_PMHX_CHART_REQUEST "
 SET fhxreqnumind = 0
 SET pmhxreqnumind = 0
 SET failedind = 1
 SET errorcode = 0
 SET errormessage = fillstring(132," ")
 SET family_display_text = fillstring(60," ")
 SET family_display_text = "Family History"
 SET past_medical_display_text = fillstring(60," ")
 SET past_medical_display_text = "Past Medical History"
 SELECT INTO "nl:"
  cdr.request_number
  FROM chart_discern_request cdr
  WHERE ((cdr.request_number=1349800) OR (cdr.request_number=1349801))
  DETAIL
   IF (cdr.request_number=1349800)
    fhxreqnumind = 1
   ELSEIF (cdr.request_number=1349801)
    pmhxreqnumind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (fhxreqnumind=0)
  INSERT  FROM chart_discern_request cdr
   SET cdr.active_ind = 1, cdr.display_text = family_display_text, cdr.process_flag = 0,
    cdr.request_number = 1349800, cdr.scope_bit_map = 19, cdr.chart_discern_request_id = seq(
     reference_seq,nextval),
    cdr.updt_applctx = reqinfo->updt_applctx, cdr.updt_cnt = 0, cdr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    cdr.updt_id = reqinfo->updt_id, cdr.updt_task = reqinfo->updt_task
  ;end insert
  SET errorcode = error(errormessage,1)
  IF (errorcode != 0)
   SET readme_data->message = concat(
    "FAIL: DCP_ADD_FHX_PMHX_CHART_REQUEST failed insert. Request number: 1349800. Error Message: ",
    errormessage)
   ROLLBACK
   SET failedind = 1
  ELSE
   COMMIT
   SET failedind = 0
  ENDIF
 ELSE
  SET failedind = 0
 ENDIF
 IF (pmhxreqnumind=0
  AND failedind=0)
  INSERT  FROM chart_discern_request cdr
   SET cdr.active_ind = 1, cdr.display_text = past_medical_display_text, cdr.process_flag = 0,
    cdr.request_number = 1349801, cdr.scope_bit_map = 19, cdr.chart_discern_request_id = seq(
     reference_seq,nextval),
    cdr.updt_applctx = reqinfo->updt_applctx, cdr.updt_cnt = 0, cdr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    cdr.updt_id = reqinfo->updt_id, cdr.updt_task = reqinfo->updt_task
  ;end insert
  SET errorcode = error(errormessage,1)
  IF (errorcode != 0)
   SET readme_data->message = concat(
    "FAIL: DCP_ADD_FHX_PMHX_CHART_REQUEST failed insert. Request number: 1349801. Error Message: ",
    errormessage)
   ROLLBACK
   SET failedind = 1
  ELSE
   COMMIT
   SET failedind = 0
  ENDIF
 ENDIF
 IF (failedind=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Success - All required CHART_DISCERN_REQUEST rows were updated successfully."
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
