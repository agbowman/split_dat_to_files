CREATE PROGRAM bhs_mp_hospitalist_updt:dba
 PROMPT
  "JSON string to update" = "",
  "Transaction type" = ""
  WITH s_json, s_transaction_type
 FREE RECORD response
 RECORD response(
   1 status = i4
   1 status_text = vc
   1 error_message = vc
   1 cur_user_id = f8
   1 request_type = vc
   1 patients[*]
     2 hospitalist_row_id = f8
     2 diagnosis = vc
     2 level_of_care = vc
     2 floor = vc
     2 pending_arrival = i4
     2 ap_resident = vc
     2 attending_preceptor = vc
     2 attending_preceptor_id = f8
     2 urgent = i4
     2 notes = vc
     2 locked_ind = i2
     2 update_id = f8
     2 update_dt_tm = dq8
     2 update_cnt = i4
 ) WITH protect
 DECLARE mn_status_code_ok = i4 WITH protect, constant(200)
 DECLARE ms_status_text_ok = vc WITH protect, constant("OK")
 DECLARE mn_status_code_bad_request = i4 WITH protect, constant(400)
 DECLARE ms_status_text_bad_request = vc WITH protect, constant("Bad request")
 DECLARE mn_status_code_not_found = i4 WITH protect, constant(404)
 DECLARE ms_status_text_not_found = vc WITH protect, constant("Not found")
 DECLARE mn_status_code_locked = i4 WITH protect, constant(423)
 DECLARE ms_status_text_locked = vc WITH protect, constant("Locked")
 DECLARE mn_status_code_internal_err = i4 WITH protect, constant(500)
 DECLARE ms_status_text_internal_err = vc WITH protect, constant("Internal Server Error")
 DECLARE ms_request_type_get = vc WITH protect, constant("GET")
 DECLARE ms_request_type_post = vc WITH protect, constant("POST")
 DECLARE ms_request_type_lock = vc WITH protect, constant("LOCK")
 DECLARE ms_json = vc WITH protect, noconstant(trim( $S_JSON,3))
 DECLARE ms_transaction_type = vc WITH protect, noconstant(cnvtupper(trim( $S_TRANSACTION_TYPE,3)))
 DECLARE ml_status = i4 WITH protect, noconstant(0)
 DECLARE ml_last_updated_by = f8 WITH protect, noconstant(0.0)
 SET response->status = mn_status_code_internal_err
 SET response->status_text = ms_status_text_internal_err
 SET response->cur_user_id = reqinfo->updt_id
 SET response->request_type = ms_transaction_type
 CALL echo(build("*** attempting transaction: ",ms_transaction_type))
 SET ml_status = cnvtjsontorec(ms_json,0,0,1)
 IF (ml_status=1)
  IF (((ms_transaction_type=ms_request_type_get) OR (ms_transaction_type=ms_request_type_lock)) )
   CALL echo(build(ms_transaction_type))
   SELECT INTO "nl;"
    FROM bhs_hospitalist bh
    PLAN (bh
     WHERE (bh.hospitalist_row_id=data->hospitalist_row_id)
      AND bh.active_ind=1)
    DETAIL
     CALL echo(build(bh.hospitalist_row_id)), stat = alterlist(response->patients,1), response->
     patients[1].hospitalist_row_id = bh.hospitalist_row_id,
     response->patients[1].diagnosis = bh.diagnosis, response->patients[1].level_of_care = bh
     .level_of_care, response->patients[1].floor = bh.floor,
     response->patients[1].pending_arrival = bh.pending_arrival, response->patients[1].ap_resident =
     bh.ap_resident, response->patients[1].attending_preceptor = bh.attending_preceptor,
     response->patients[1].attending_preceptor_id = bh.attending_preceptor_id, response->patients[1].
     urgent = bh.urgent, response->patients[1].notes = bh.notes,
     response->patients[1].locked_ind = bh.locked_ind, response->patients[1].update_cnt = bh
     .update_cnt, response->patients[1].update_id = bh.update_id,
     response->patients[1].update_dt_tm = bh.update_dt_tm
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET response->status = mn_status_code_not_found
    SET response->status_text = ms_status_text_not_found
    SET response->error_message = build2("Requested patient record not found - ",data->
     hospitalist_row_id)
    GO TO exit_program
   ENDIF
   IF (ms_transaction_type=ms_request_type_lock)
    CALL echo("*** request type is LOCK - locking record")
    UPDATE  FROM bhs_hospitalist bh
     SET bh.update_cnt = (bh.update_cnt+ 1), bh.update_dt_tm = sysdate, bh.update_id = reqinfo->
      updt_id,
      bh.locked_ind = 1
     WHERE (bh.hospitalist_row_id=data->hospitalist_row_id)
     WITH nocounter
    ;end update
    COMMIT
    SELECT INTO "nl;"
     FROM bhs_hospitalist bh
     PLAN (bh
      WHERE (bh.hospitalist_row_id=data->hospitalist_row_id)
       AND bh.active_ind=1)
     DETAIL
      CALL echo(build(bh.hospitalist_row_id)), response->patients[1].locked_ind = bh.locked_ind,
      response->patients[1].update_cnt = bh.update_cnt,
      response->patients[1].update_id = bh.update_id, response->patients[1].update_dt_tm = bh
      .update_dt_tm
     WITH nocounter
    ;end select
    COMMIT
   ENDIF
   CALL echo(build("*** locked ind before check and status set",response->patients[1].locked_ind))
   IF ((response->patients[1].locked_ind=1))
    CALL echo("*** record already locked by someone else")
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE (p.person_id=response->patients[1].update_id)
      AND p.active_ind=1
     ORDER BY p.person_id
     HEAD p.person_id
      response->error_message = build2("Requested patient record is locked by - ",p
       .name_full_formatted)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET response->status = mn_status_code_locked
     SET response->status_text = ms_status_text_locked
     GO TO exit_program
    ENDIF
   ENDIF
  ELSEIF (ms_transaction_type=ms_request_type_post)
   CALL echo(build(ms_transaction_type))
   UPDATE  FROM bhs_hospitalist bh
    SET bh.diagnosis = data->diagnosis, bh.level_of_care = data->level_of_care, bh.floor = data->
     floor,
     bh.pending_arrival = cnvtint(data->pending_arrival), bh.ap_resident = data->ap_resident, bh
     .attending_preceptor = data->attending_preceptor,
     bh.attending_preceptor_id = cnvtreal(data->attending_preceptor_id), bh.urgent = cnvtint(data->
      urgent), bh.notes = data->notes,
     bh.update_cnt = (bh.update_cnt+ 1), bh.update_dt_tm = sysdate, bh.update_id = reqinfo->updt_id,
     bh.locked_ind = 0
    WHERE (bh.hospitalist_row_id=data->hospitalist_row_id)
    WITH nocounter
   ;end update
   COMMIT
  ELSE
   SET response->status = mn_status_code_bad_request
   SET response->status_text = ms_status_text_bad_request
   SET response->error_message = build2("Unknown method type - ",ms_transaction_type)
   CALL echo(response->error_message)
   GO TO exit_program
  ENDIF
 ELSE
  SET response->error_message = build2("Failed to convert json to rec. Status - ",ml_status)
  CALL echo(response->error_message)
  GO TO exit_program
 ENDIF
 SET response->status = mn_status_code_ok
 SET response->status_text = ms_status_text_ok
#exit_program
 SET _memory_reply_string = cnvtrectojson(response,2,1)
 CALL echo(_memory_reply_string)
END GO
