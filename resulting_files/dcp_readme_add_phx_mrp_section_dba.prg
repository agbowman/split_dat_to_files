CREATE PROGRAM dcp_readme_add_phx_mrp_section:dba
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
 SET readme_data->message = "Readme Failed:  Script dcp_readme_add_phx_mrp_section "
 DECLARE phx_section_request = i4 WITH constant(1349804), protect
 DECLARE section_display = vc WITH constant("Pregnancy History"), protect
 DECLARE phxrequestexists = i2 WITH noconstant(0), protect
 DECLARE failure_ind = i2 WITH noconstant(0), protect
 DECLARE error_code = i4 WITH noconstant(0), protect
 DECLARE error_msg = vc WITH noconstant, protect
 SELECT INTO "nl:"
  cdr.request_number
  FROM chart_discern_request cdr
  WHERE cdr.request_number=phx_section_request
  DETAIL
   phxrequestexists = 1
  WITH nocounter
 ;end select
 IF (phxrequestexists=1)
  GO TO exit_script
 ENDIF
 INSERT  FROM chart_discern_request cdr
  SET cdr.active_ind = 1, cdr.display_text = section_display, cdr.process_flag = 0,
   cdr.request_number = phx_section_request, cdr.scope_bit_map = 19, cdr.chart_discern_request_id =
   seq(reference_seq,nextval),
   cdr.updt_applctx = reqinfo->updt_applctx, cdr.updt_cnt = 0, cdr.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cdr.updt_id = reqinfo->updt_id, cdr.updt_task = reqinfo->updt_task
 ;end insert
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET readme_data->message = concat(
   "FAILURE: dcp_readme_add_phx_mrp_section failed to insert section. Request number: ",trim(build(
     phx_section_request)),". Error Message: ",error_msg)
  ROLLBACK
  SET failure_ind = 1
 ELSE
  COMMIT
  SET failure_ind = 0
 ENDIF
#exit_script
 IF (failure_ind=0)
  SET readme_data->status = "S"
  IF (phxrequestexists=1)
   SET readme_data->message = "Success - Pregnancy History already exists in CHART_DISCERN_REQUEST."
  ELSE
   SET readme_data->message =
   "Success - Pregnancy History added to CHART_DISCERN_REQUEST successfully."
  ENDIF
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
