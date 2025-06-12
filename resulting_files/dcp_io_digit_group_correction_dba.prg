CREATE PROGRAM dcp_io_digit_group_correction:dba
 DECLARE checksupportedlocale(null) = i2 WITH protect
 SUBROUTINE checksupportedlocale(null)
   DECLARE current_locale = vc WITH protect, noconstant("")
   SET current_locale = cnvtupper(logical("CCL_LANG"))
   IF (current_locale="")
    SET current_locale = cnvtupper(logical("LANG"))
   ENDIF
   IF (current_locale IN ("EN_US", "EN_UK", "EN_AUS", "EN_US.*", "EN_UK.*",
   "EN_AUS.*"))
    RETURN(1)
   ENDIF
   CALL echo(logical("CCL_LANG"))
   CALL echo(logical("LANG"))
   CALL echo(
    "The current back-end configuration is not compatible, please contact your system administrator")
   RETURN(0)
 END ;Subroutine
 DECLARE dcp_parse_numeric_string() = f8
 DECLARE determinemaxid(null) = null WITH protect
 DECLARE determinechunksize(null) = null WITH protect
 DECLARE processiotable(null) = null WITH protect
 DECLARE processiorange(min_id=f8,max_id=f8) = null WITH protect
 DECLARE in_process = i2 WITH protect, noconstant(0)
 DECLARE min_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 DECLARE current_min_id = f8 WITH protect, noconstant(0.0)
 DECLARE current_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE inerror = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE chunk_size = f8 WITH protect, noconstant(0.0)
 SUBROUTINE determinemaxid(null)
   SELECT INTO "nl:"
    selected_max_id = max(io.ce_io_result_id)
    FROM ce_intake_output_result io
    DETAIL
     max_id = selected_max_id
    WITH nocounter
   ;end select
   IF (error(error_msg,1) != 0)
    CALL echo(build("Failed to determine the max ce_io_result_id, Error:",error_msg))
    GO TO exit_program
   ENDIF
   CALL echo(build("Max ce_io_result_id is: ",max_id))
   IF (max_id <= 0)
    CALL echo("Invalid max ce_io_result_id!")
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE determinechunksize(null)
  SET chunk_size = 100000
  CALL echo(build("Processing",chunk_size,"rows at a time"))
 END ;Subroutine
 DECLARE checkinprocess(null) = null WITH protect
 DECLARE setinprocess(null) = null WITH protect
 DECLARE removeinprocess(null) = null WITH protect
 DECLARE updateinprocess(min_id=f8) = null WITH protect
 SUBROUTINE checkinprocess(null)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="IO DIGIT GROUP CORRECTION"
   HEAD REPORT
    in_process = 0
   DETAIL
    in_process = 1, current_min_id = di.info_number
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   CALL echo(build("Failed to check if the update is already in process, Error:",error_msg))
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE setinprocess(null)
   SET min_id = 1.0
   SET current_min_id = min_id
   INSERT  FROM dm_info di
    SET di.info_domain = "IO DIGIT GROUP CORRECTION", di.info_name = "MIN IO EVENT ID", di.info_char
      = "IN PROCESS",
     di.info_number = min_id
    WITH nocounter
   ;end insert
   COMMIT
   IF (error(error_msg,1) != 0)
    CALL echo(build("Failed set the update to in process, Error:",error_msg))
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE removeinprocess(null)
   DELETE  FROM dm_info di
    WHERE di.info_domain="IO DIGIT GROUP CORRECTION"
     AND di.info_name="MIN IO EVENT ID"
     AND di.info_char="IN PROCESS"
    WITH nocounter
   ;end delete
   COMMIT
   IF (error(error_msg,1) != 0)
    CALL echo(build("Failed remove the in process flag, Error:",error_msg))
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE updateinprocess(min_id)
   UPDATE  FROM dm_info di
    SET di.info_number = min_id
    WHERE di.info_domain="IO DIGIT GROUP CORRECTION"
    WITH nocounter
   ;end update
   COMMIT
   IF (error(error_msg,1) != 0)
    CALL echo(build("Failed update the in process flag, Error:",error_msg))
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE processiorange(min_id,max_id)
   CALL echo(build("Processing ce_io_result_ids ",min_id," to ",max_id))
   RECORD volumes(
     1 events[*]
       2 ce_io_result_id = f8
       2 correct_volume = f8
   )
   SELECT INTO "nl:"
    io.ce_io_result_id, correct_volume = dcp_parse_numeric_string(ce.result_val)
    FROM ce_intake_output_result io,
     clinical_event ce
    PLAN (io
     WHERE io.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND io.ce_io_result_id >= min_id
      AND io.ce_io_result_id <= max_id)
     JOIN (ce
     WHERE ce.event_id=io.event_id
      AND ce.result_status_cd != inerror
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND findstring(",",ce.result_val) > 0
      AND dcp_parse_numeric_string(ce.result_val) != io.io_volume
      AND ce.event_end_dt_tm=io.io_end_dt_tm)
    HEAD REPORT
     count = 0
    HEAD io.ce_io_result_id
     count = (count+ 1)
     IF (mod(count,10)=1)
      stat = alterlist(volumes->events,(count+ 9))
     ENDIF
     volumes->events[count].ce_io_result_id = io.ce_io_result_id, volumes->events[count].
     correct_volume = correct_volume
    FOOT REPORT
     stat = alterlist(volumes->events,count)
    WITH nocounter
   ;end select
   IF (error(error_msg,1) != 0)
    CALL echo(build("Failed to determine if the range has any affected IO data, Error:",error_msg))
    FREE RECORD volumes
    GO TO exit_program
   ENDIF
   IF (size(volumes->events,5) > 0)
    UPDATE  FROM ce_intake_output_result io,
      (dummyt d  WITH seq = value(size(volumes->events,5)))
     SET io.io_volume = volumes->events[d.seq].correct_volume
     PLAN (d)
      JOIN (io
      WHERE (io.ce_io_result_id=volumes->events[d.seq].ce_io_result_id))
     WITH nocounter
    ;end update
    IF (error(error_msg,1) != 0)
     CALL echo(build("Failed to update the affected IO data, Error:",error_msg))
     FREE RECORD volumes
     GO TO exit_program
    ENDIF
   ENDIF
   FREE RECORD volumes
 END ;Subroutine
 SUBROUTINE processiotable(null)
   WHILE (current_max_id < max_id)
     SET current_max_id = (current_min_id+ chunk_size)
     IF (current_max_id > max_id)
      SET current_max_id = max_id
     ENDIF
     CALL processiorange(current_min_id,current_max_id)
     SET current_min_id = (current_max_id+ 1)
     IF (current_min_id < max_id)
      CALL updateinprocess(current_min_id)
     ENDIF
   ENDWHILE
 END ;Subroutine
 IF (checksupportedlocale(null)=0)
  GO TO exit_program
 ENDIF
 CALL echo("Starting IO Digit Group Correction")
 SET message = noinformation
 CALL checkinprocess(null)
 IF (in_process=0)
  CALL setinprocess(null)
 ELSE
  CALL echo(build("Already in process, starting at ce_io_result_id: ",current_min_id))
 ENDIF
 CALL determinemaxid(null)
 CALL determinechunksize(null)
 CALL processiotable(null)
 CALL removeinprocess(null)
 CALL echo("Sucessfully completed IO correction!")
 COMMIT
#exit_program
END GO
