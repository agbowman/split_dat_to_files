CREATE PROGRAM cpm_srv_exp_set_req_proc:dba
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
 SET serverinstalled = 0
 SELECT INTO "nl:"
  FROM dm_info
  WHERE info_domain="EXPEDITE SERVER"
   AND info_name="INSTALLED"
  DETAIL
   serverinstalled = 1
  WITH nocounter
 ;end select
 SET serverinstalled = 0
 IF (serverinstalled=1)
  UPDATE  FROM request_processing
   SET destination_step_id = 36010
   WHERE ((request_number IN (200014, 200118, 200296)
    AND format_script="PFMT_APS_INITIATE_EXPEDITE") OR (((request_number IN (250218, 250074, 225070,
   225193)
    AND format_script="PFMT_GL_TO_EXPEDITE") OR (((request_number IN (275001, 275002, 295180)
    AND format_script="PFMT_MIC_EXPEDITE") OR (((request_number=275065
    AND format_script="PFMT_MIC_ACT_EXPEDITE") OR (((request_number=400101
    AND format_script="PFMT_RAD_TO_EXP_AFTER_EXAM") OR (request_number IN (455013, 455028, 455077)
    AND format_script="PFMT_RAD_TO_EXPEDITE")) )) )) )) ))
    AND destination_step_id=0
   WITH nocounter
  ;end update
  SET numrowsupdated = 0
  SELECT INTO "nl:"
   FROM request_processing
   WHERE destination_step_id=36010
   DETAIL
    numrowsupdated = (numrowsupdated+ 1)
   WITH nocounter
  ;end select
  IF (numrowsupdated < 11)
   SET readme_data->status = "F"
   SET readme_data->message =
   "Request_processing.destination_step_id not updated for expedite server"
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message =
   "Request_processing.destination_step_id was updated successfully for expedite server"
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Expedite server not installed.  No rows need to be updated"
 ENDIF
 EXECUTE dm_readme_status
END GO
