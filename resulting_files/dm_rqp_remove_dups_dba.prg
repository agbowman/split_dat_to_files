CREATE PROGRAM dm_rqp_remove_dups:dba
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
 FREE RECORD rqp_temp
 RECORD rqp_temp(
   1 update_rec[*]
     2 request_number = i4
     2 sequence = i4
 )
 SET rqp_cnt = 0
 SET rqp_emsg = fillstring(132," ")
 SET rqp_ecode = 0
 EXECUTE ap_rqp_cleanup
 SELECT INTO "NL:"
  sort_var = build(r.request_number,r.format_script,r.target_request_number,r.service,r
   .destination_step_id), r.active_ind, r.sequence
  FROM request_processing r
  ORDER BY sort_var, r.active_ind DESC, r.sequence
  HEAD REPORT
   stat = alterlist(rqp_temp->update_rec,50), rqp_cnt = 0
  HEAD sort_var
   first_one = "Y"
  DETAIL
   IF (first_one="N")
    rqp_cnt = (rqp_cnt+ 1)
    IF (mod(rqp_cnt,50)=1
     AND rqp_cnt != 1)
     stat = alterlist(rqp_temp->update_rec,(rqp_cnt+ 49))
    ENDIF
    rqp_temp->update_rec[rqp_cnt].request_number = r.request_number, rqp_temp->update_rec[rqp_cnt].
    sequence = r.sequence
   ENDIF
   first_one = "N"
  WITH check
 ;end select
 IF (rqp_cnt > 0)
  FOR (rqp_dup_cnt = 1 TO rqp_cnt)
    DELETE  FROM request_processing r
     WHERE (rqp_temp->update_rec[rqp_dup_cnt].request_number=r.request_number)
      AND (rqp_temp->update_rec[rqp_dup_cnt].sequence=r.sequence)
    ;end delete
    SET rqp_ecode = error(rqp_emsg,1)
    IF (rqp_ecode != 0)
     SET readme_data->status = "F"
     SET readme_data->message = rqp_emsg
     GO TO exit_rqp_script
    ELSE
     SET readme_data->status = "S"
     SET readme_data->message = "Duplicate request_processing rows successfully deleted."
    ENDIF
  ENDFOR
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "No duplicate request_processing records found."
 ENDIF
#exit_rqp_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
END GO
