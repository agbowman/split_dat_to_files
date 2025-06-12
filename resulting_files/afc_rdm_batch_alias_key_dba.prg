CREATE PROGRAM afc_rdm_batch_alias_key:dba
 SET afc_rdm_batch_alias_key = "78042.FT.000"
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
 SET readme_data->message = "Failed Readme: starting afc_rdm_batch_alias_key.prg script..."
 DECLARE checkrunstatus() = i4
 DECLARE getminid() = null
 DECLARE getmaxid() = null
 DECLARE getstartid() = null
 DECLARE updateinforow() = null
 DECLARE rdm_errmsg = vc
 DECLARE run_status = i4
 DECLARE min_id = f8
 DECLARE max_id = f8
 DECLARE batch_start = f8
 DECLARE batch_end = f8
 SET run_status = checkrunstatus(null)
 IF (run_status=2)
  SET readme_data->status = "S"
  CALL echo("Cat2/Cat5 steps have already run successfully")
  GO TO end_program
 ELSEIF (run_status=1)
  CALL getstartid(null)
 ELSE
  CALL getminid(null)
 ENDIF
 CALL getmaxid(null)
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->status = "F"
  GO TO end_program
 ENDIF
 SET batch_start = min_id
 SET batch_end = (min_id+ 10000)
 WHILE (batch_start <= max_id)
   EXECUTE afc_rdm_batch_alias_update batch_start, batch_end
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->status = "F"
    GO TO end_program
   ENDIF
   COMMIT
   SET batch_start = (batch_start+ 10000)
   SET batch_end = (batch_end+ 10000)
 ENDWHILE
 CALL updateinforow(null)
 SET readme_data->status = "S"
#end_program
 CALL echo("end of program")
 IF ((readme_data->status="S"))
  SET readme_data->status = "S"
  SET readme_data->message = "batch_alias_key field updated successfully."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Error encountered updating batch_alias_key field"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SUBROUTINE checkrunstatus(null)
   DECLARE run_ind = i4
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="UPDATE BCE_EVENT_LOG README"
     AND di.info_name IN ("CAT 2 COMPLETE", "CAT 2/5 COMPLETE")
     AND di.info_char="INST1"
    DETAIL
     IF (di.info_name="CAT 2/5 COMPLETE")
      run_ind = 2
     ELSEIF (di.info_name="CAT 2 COMPLETE")
      run_ind = 1
     ELSE
      run_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (run_ind=1)
    RETURN(1)
   ELSEIF (run_ind=2)
    RETURN(2)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getminid(null)
   SELECT INTO "nl:"
    FROM bce_event_log b
    WHERE b.bce_event_log_id != 0
    ORDER BY b.bce_event_log_id
    DETAIL
     min_id = b.bce_event_log_id
    WITH maxrec = 1, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getstartid(null)
   SELECT INTO "nl:"
    next_id = di.info_number
    FROM dm_info di
    WHERE di.info_domain="UPDATE BCE_EVENT_LOG README"
     AND di.info_name="CAT 2 COMPLETE"
     AND di.info_char="INST1"
    DETAIL
     min_id = cnvtreal(next_id)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getmaxid(null)
   SELECT INTO "nl:"
    FROM bce_event_log b
    WHERE b.bce_event_log_id != 0
    ORDER BY b.bce_event_log_id DESC
    DETAIL
     max_id = b.bce_event_log_id
    WITH maxrec = 1, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updateinforow(null)
   IF (run_status=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "UPDATE BCE_EVENT_LOG README", di.info_name = "CAT 2 COMPLETE", di
      .info_number = max_id,
      di.info_char = "INST1", di.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info di
     SET di.info_name = "CAT 2/5 COMPLETE"
     WHERE di.info_domain="UPDATE BCE_EVENT_LOG README"
      AND di.info_name="CAT 2 COMPLETE"
      AND di.info_char="INST1"
    ;end update
   ENDIF
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->status = "F"
    GO TO end_program
   ENDIF
   COMMIT
 END ;Subroutine
END GO
