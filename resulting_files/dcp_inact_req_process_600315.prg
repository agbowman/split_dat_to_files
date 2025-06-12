CREATE PROGRAM dcp_inact_req_process_600315
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
 SET readme_data->status = "S"
 UPDATE  FROM request_processing rp
  SET rp.active_ind = 0
  WHERE rp.request_number=3091000
   AND rp.destination_step_id=305615
   AND rp.active_ind=1
  WITH nocounter
 ;end update
 SET readme_data->status = "S"
 SET readme_data->message =
 "Request processing for 600315 inactivated.  Please cycle the process server."
 IF (curqual <= 0)
  SET readme_data->status = "S"
  SET readme_data->message = "No active request processing for 600315."
 ENDIF
 SELECT INTO "nl:"
  FROM request_processing rp
  WHERE rp.request_number=3091000
   AND rp.destination_step_id=305615
   AND rp.active_ind=1
  DETAIL
   readme_data->status = "F", readme_data->message = "Request processing for 600315 still active."
  WITH nocounter
 ;end select
 EXECUTE dm_readme_status
END GO
