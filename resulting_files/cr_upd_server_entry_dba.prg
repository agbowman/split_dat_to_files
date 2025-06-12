CREATE PROGRAM cr_upd_server_entry:dba
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
 DECLARE cr_request_number = f8 WITH constant(3091000.0), protect
 DECLARE cr_dest_step_id = f8 WITH constant(1370050.0), protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script cr_upd_server_entry..."
 DECLARE max_seq = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  r.*
  FROM request_processing r
  WHERE r.request_number=cr_request_number
   AND r.destination_step_id=cr_dest_step_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failure occurred reading the REQUEST_PROCESSING row for request_number ",cnvtstring(
    cr_request_number)," - Error:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM request_processing r
   WHERE r.request_number=cr_request_number
   FOOT REPORT
    max_seq = max(r.sequence)
   WITH nocounter
  ;end select
  INSERT  FROM request_processing r
   SET r.destination_step_id = cr_dest_step_id, r.request_number = cr_request_number, r.sequence = (
    max_seq+ 1),
    r.updt_dt_tm = cnvtdatetime(sysdate), r.active_ind = 0
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Readme failed to insert REQUEST_PROCESSING row for request_number ",cnvtstring(cr_request_number
     )," - Error:",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
   SET readme_data->status = "S"
   SET readme_data->message = concat(
    "Success: Finished updating request_processing table for request_number ",cnvtstring(
     cr_request_number))
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success: No records found that needed to be updated."
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
