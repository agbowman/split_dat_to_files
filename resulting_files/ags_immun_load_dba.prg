CREATE PROGRAM ags_immun_load:dba
 PROMPT
  "TASK_ID (0.0) =" = 0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEG AGS_IMMUN_LOAD")
 CALL echo("***")
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 IF ((validate(failed,- (1))=- (1)))
  EXECUTE cclseclogin2
  CALL echo("***")
  CALL echo("***   Declare Common Variables")
  CALL echo("***")
  IF ((validate(false,- (1))=- (1)))
   DECLARE false = i2 WITH public, noconstant(0)
  ENDIF
  IF ((validate(true,- (1))=- (1)))
   DECLARE true = i2 WITH public, noconstant(1)
  ENDIF
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  CALL echo("***")
  CALL echo("***   BEG LOGGING")
  CALL echo("***")
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  DECLARE eknt = i4 WITH public, noconstant(0)
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  DECLARE handle_logging(slog_file=vc,semail=vc,istatus_flag=i4) = null WITH protect
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_immun_load_",format(cnvtdatetime
     (curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_IMMUN_LOAD"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_IMMUN_LOAD"
  CALL echo("***")
  CALL echo("***   Common Variables/Records Declared in calling program")
  CALL echo("***")
 ENDIF
 SET working_task_id =  $DTASK_ID
 DECLARE working_sending_system = vc WITH public, noconstant(" ")
 DECLARE working_mode = i2 WITH public, noconstant(0)
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_kill_ind = i2 WITH public, noconstant(0)
 DECLARE beg_data_id = f8 WITH public, noconstant(0.0)
 DECLARE end_data_id = f8 WITH public, noconstant(0.0)
 DECLARE max_data_id = f8 WITH public, noconstant(0.0)
 DECLARE data_size = i4 WITH public, noconstant(1000)
 DECLARE default_data_size = i4 WITH public, noconstant(1000)
 DECLARE data_knt = i4 WITH public, noconstant(0)
 DECLARE it_avg = i4 WITH public, noconstant(0)
 DECLARE working_timers = i4 WITH public, noconstant(0)
 FREE RECORD contrib_rec
 RECORD contrib_rec(
   1 qual_knt = i4
   1 qual[*]
     2 sending_facility = vc
     2 contributor_system_cd = f8
     2 contributor_source_cd = f8
     2 time_zone_flag = i2
     2 time_zone = vc
     2 time_zone_idx = i4
     2 prsnl_person_id = f8
     2 organization_id = f8
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
 )
 FREE RECORD dates
 RECORD dates(
   1 now_dt_tm = dq8
   1 end_dt_tm = dq8
   1 batch_start_dt_tm = dq8
   1 it_end_dt_tm = dq8
   1 it_est_end_dt_tm = dq8
 )
 SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dates->batch_start_dt_tm = cnvtdatetime(dates->now_dt_tm)
 SET dates->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 SET current_dt_tm = cnvtdatetime(curdate,curtime3)
 SET max_date = cnvtdatetime("31-DEC-2100 00:00:00.00")
 SET run_event_lup_ind = false
 DECLARE found_default_contrib_system = i2 WITH public, noconstant(false)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE auth_data_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE root_event_reltn_cd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE active_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"INACTIVE"
   ))
 DECLARE immun_event_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE male_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE esi_default_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",73,"Default"))
 DECLARE cernerchr_contributor_source_cd = f8 WITH public, constant(uar_get_code_by("MEANING",73,
   "CERNERCHR"))
 DECLARE routclinical_inquire_security_cd = f8 WITH public, constant(uar_get_code_by("MEANING",87,
   "ROUTCLINICAL"))
 DECLARE immunization_entry_mode_cd = f8 WITH public, constant(uar_get_code_by("MEANING",29520,
   "IMMUNIZATION"))
 DECLARE ssn_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PRSNEXTALIAS"))
 CALL echo("***")
 CALL echo("***   Log Starting Conditions")
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("WORKING_TASK_ID :: ",trim(cnvtstring(working_task_id)))
 CALL echo("***")
 CALL echo(build("***   $dTASK_ID        :",working_task_id))
 CALL echo("***")
 IF (working_task_id > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Processing")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_start_dt_tm
     = cnvtdatetime(dates->batch_start_dt_tm),
    t.batch_end_dt_tm = cnvtdatetime(dates->end_dt_tm)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK PROCESSING"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK PROCESSING :: Select Error :: ",trim(serrmsg)
    )
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  SET failed = input_error
  SET table_name = "PARAMETER VALIDATION"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID TASK_ID :: Input Error :: ",trim(cnvtstring(
     working_task_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (esi_default_cd < 1)
  SET failed = select_error
  SET table_name = "GET ESI_DEFAULT_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ESI_DEFAULT_CD :: Select Error :: CODE_VALUE for display Default invalid from CODE_SET 73"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ext_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET SSN_ALIAS VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "EXT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning PRSNSSN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (male_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET MALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "MALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING MALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (female_sex_cd < 1)
  SET failed = select_error
  SET table_name = "GET FEMALE_SEX_CD"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "FEMALE_SEX_CD :: Select Error :: CODE_VALUE for CDF_MEANING FEMALE invalid from CODE_SET 57"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Task Data")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_task t
  PLAN (t
   WHERE t.ags_task_id=working_task_id)
  HEAD REPORT
   beg_data_id = t.batch_start_id
   IF (t.iteration_start_id > 0)
    beg_data_id = t.iteration_start_id
   ENDIF
   max_data_id = t.batch_end_id, data_size = t.batch_size
   IF (data_size < 1)
    data_size = default_data_size
   ENDIF
   working_job_id = t.ags_job_id, working_mode = t.mode_flag, working_kill_ind = t.kill_ind,
   working_timers = t.timers_flag
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET TASK DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET TASK DATA :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = input_error
  SET table_name = "GET TASK DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET TASK DATA :: Input Error :: Invalid TASK_ID ",trim(
    cnvtstring(working_task_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (working_kill_ind > 0)
  SET ilog_status = 2
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "GET TASK DATA :: KILL_IND Set to Kill"
  GO TO exit_script
 ENDIF
 IF (working_timers < 1)
  SET trace = nocallecho
 ELSE
  SET trace = callecho
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 IF (beg_data_id < 1)
  SET failed = input_error
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG_DATA_ID :: Invalid Value :: Less Than 1"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Process Data")
 CALL echo("***")
 IF (((beg_data_id+ data_size) > max_data_id))
  SET end_data_id = max_data_id
 ELSE
  SET end_data_id = ((beg_data_id+ data_size) - 1)
 ENDIF
 IF (end_data_id < 1
  AND working_mode=3)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   max_id = max(o.ags_immun_data_id), dknt = count(o.ags_immun_data_id)
   FROM ags_immun_data o
   PLAN (o
    WHERE o.ags_immun_data_id >= beg_data_id
     AND o.status IN ("IN ERROR", "BACK OUT"))
   HEAD REPORT
    x = 1
   DETAIL
    x = 1
   FOOT REPORT
    max_data_id = max_id, data_knt = dknt
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "MODE 3 CHK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("MODE 3 CHK :: Select Error :: ",trim(serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  IF (data_knt <= data_size)
   SET end_data_id = max_data_id
  ELSE
   SET end_data_id = ((beg_data_id+ data_size) - 1)
  ENDIF
  CALL echo("***")
  CALL echo("***   Update Task Batch End")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.batch_end_id = max_data_id
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK BATCH_END_ID"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK BATCH_END_ID :: Select Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   end_data_id    :",end_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 WHILE (beg_data_id <= end_data_id
  AND working_kill_ind < 1)
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("BEG PROCESSING :: BEG_DATA_ID :: ",trim(cnvtstring(
      beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
    trim(cnvtstring(max_data_id)))
   FREE RECORD hold
   RECORD hold(
     1 qual_knt = i4
     1 qual[*]
       2 ags_immun_data_id = f8
       2 run_nbr = i4
       2 run_dt_tm = dq8
       2 file_row_nbr = i4
       2 person_id = f8
       2 event_id = f8
       2 event_cd = f8
       2 clinical_event_id = f8
       2 sending_facility = vc
       2 ext_alias = vc
       2 unable_to_do_ssn_chk = i2
       2 ssn_alias = vc
       2 name_first = vc
       2 name_last = vc
       2 birth_date = vc
       2 gender = vc
       2 status = vc
       2 stat_msg = vc
       2 birth_dt_tm = dq8
       2 sex_cd = f8
       2 contributor_system_cd = f8
       2 contrib_idx = i4
       2 claim_identifier = vc
       2 prev_claim_identifier = vc
       2 line_item_number = vc
       2 action = vc
       2 service_date = vc
       2 service_dt_tm = dq8
       2 event_code = vc
       2 ref_nbr_search = vc
       2 ref_nbr = vc
       2 prev_ref_nbr = vc
       2 person_exists_ind = i4
       2 ext_alias_exists_ind = i4
       2 ext_alias_person_alias_id = f8
       2 ssn_alias_exists_ind = i4
       2 ssn_alias_person_alias_id = f8
       2 prsnl_person_id = f8
   )
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo("***")
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET run_event_lup_ind = false
   CALL echo("***")
   CALL echo("***   Load Immun Data")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (o
      WHERE o.ags_immun_data_id >= beg_data_id
       AND o.ags_immun_data_id <= end_data_id
       AND ((o.person_id+ 0) < 1)
       AND ((o.event_id+ 0) < 1)
       AND trim(o.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (o
      WHERE o.ags_immun_data_id >= beg_data_id
       AND o.ags_immun_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (o
      WHERE o.ags_immun_data_id >= beg_data_id
       AND o.ags_immun_data_id <= end_data_id
       AND ((o.person_id+ 0) < 1)
       AND ((o.event_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSE
     PLAN (o
      WHERE o.ags_immun_data_id >= beg_data_id
       AND o.ags_immun_data_id <= end_data_id
       AND trim(o.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_immun_data o,
     ags_job j
    HEAD REPORT
     stat = alterlist(hold->qual,data_size), idx = 0
    HEAD o.ags_immun_data_id
     idx = (idx+ 1)
     IF (idx > size(hold->qual,5))
      stat = alterlist(hold->qual,(idx+ data_size))
     ENDIF
     hold->qual[idx].status = "S", hold->qual[idx].stat_msg = " "
     IF ((contrib_rec->qual_knt > 0))
      IF (size(trim(o.sending_facility,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,o.sending_facility,contrib_rec->qual[num]
        .sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(o
         .sending_facility,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,j.sending_system,contrib_rec->qual[num].
        sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
         .sending_system,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg =
       concat(trim(hold->qual[idx].stat_msg),"[contrib]")
      ENDIF
     ELSE
      IF (size(trim(o.sending_facility,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(o
        .sending_facility,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
        .sending_system,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg =
       concat(trim(hold->qual[idx].stat_msg),"[contrib]")
      ENDIF
     ENDIF
     hold->qual[idx].ags_immun_data_id = o.ags_immun_data_id, hold->qual[idx].run_nbr = o.run_nbr,
     hold->qual[idx].person_id = o.person_id,
     hold->qual[idx].event_id = o.event_id, hold->qual[idx].event_code = trim(o.event_code,3), hold->
     qual[idx].event_cd = o.event_cd,
     hold->qual[idx].sending_facility = trim(o.sending_facility,3), hold->qual[idx].ext_alias = trim(
      o.ext_alias,3), hold->qual[idx].ssn_alias = trim(o.ssn_alias,3),
     hold->qual[idx].name_first = trim(o.name_first,3), hold->qual[idx].name_last = trim(o.name_last,
      3), hold->qual[idx].gender = trim(o.gender,3),
     hold->qual[idx].claim_identifier = trim(o.claim_identifier,3), hold->qual[idx].
     prev_claim_identifier = trim(o.prev_claim_identifier,3), hold->qual[idx].line_item_number = trim
     (o.line_item_number_txt,3),
     hold->qual[idx].action = trim(o.action,3), hold->qual[idx].service_date = trim(o.service_date,3),
     hold->qual[idx].service_dt_tm = cnvtdate2(substring(1,8,trim(o.service_date,3)),"YYYYMMDD"),
     hold->qual[idx].birth_date = trim(o.birth_date,3), hold->qual[idx].birth_dt_tm = cnvtdate2(trim(
       o.birth_date,3),"YYYYMMDD"), hold->qual[idx].sex_cd =
     IF ((hold->qual[idx].gender="M")) male_sex_cd
     ELSEIF ((hold->qual[idx].gender="F")) female_sex_cd
     ELSE 0
     ENDIF
     ,
     hold->qual[idx].ref_nbr_search = build(hold->qual[idx].claim_identifier,"~",hold->qual[idx].
      line_item_number,"*"), hold->qual[idx].ref_nbr = build(hold->qual[idx].claim_identifier,"~",
      hold->qual[idx].line_item_number)
     IF ((hold->qual[idx].prev_claim_identifier > " "))
      hold->qual[idx].prev_ref_nbr = build(hold->qual[idx].prev_claim_identifier,"~*")
     ELSE
      hold->qual[idx].prev_ref_nbr = ""
     ENDIF
     IF ((hold->qual[idx].ssn_alias > " "))
      IF ((hold->qual[idx].name_first > " "))
       IF ((hold->qual[idx].name_last > " "))
        IF (size(trim(o.birth_date)) > 0)
         IF ((hold->qual[idx].sex_cd > 0))
          hold->qual[idx].contrib_idx = hold->qual[idx].contrib_idx
         ELSE
          hold->qual[idx].unable_to_do_ssn_chk = true, hold->qual[idx].stat_msg = "Invalid SEX_CD"
         ENDIF
        ELSE
         hold->qual[idx].unable_to_do_ssn_chk = true, hold->qual[idx].stat_msg =
         "Invalid BIRTH_DT_TM"
        ENDIF
       ELSE
        hold->qual[idx].unable_to_do_ssn_chk = true, hold->qual[idx].stat_msg = "Invalid NAME_LAST"
       ENDIF
      ELSE
       hold->qual[idx].unable_to_do_ssn_chk = true, hold->qual[idx].stat_msg = "Invalid NAME_FIRST"
      ENDIF
     ELSE
      hold->qual[idx].unable_to_do_ssn_chk = true, hold->qual[idx].stat_msg = "Invalid SSN_ALIAS"
     ENDIF
     IF (o.event_cd=0)
      run_event_lup_ind = true
     ENDIF
    FOOT REPORT
     hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_IMMUN_DATA LOADING"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_IMMUN_DATA LOADING :: Select Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   CALL echo("***")
   CALL echo("***   Get Contributor System")
   CALL echo("***")
   IF ((contrib_rec->qual_knt < 1))
    SET failed = input_error
    SET table_name = "GET CONTRIBUTOR SYSTEMS"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg =
    "GET CONTRIBUTOR SYSTEMS :: Input Error :: contrib_rec->qual_knt < 1"
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_alias cva,
     contributor_system cs,
     esi_alias_trans eat,
     (dummyt d  WITH seq = value(contrib_rec->qual_knt))
    PLAN (d
     WHERE (contrib_rec->qual[d.seq].contributor_system_cd < 1))
     JOIN (cva
     WHERE cva.code_set=89
      AND (cva.alias=contrib_rec->qual[d.seq].sending_facility)
      AND cva.contributor_source_cd=esi_default_cd)
     JOIN (cs
     WHERE cs.contributor_system_cd=cva.code_value
      AND cs.active_ind=1)
     JOIN (eat
     WHERE eat.contributor_system_cd=cs.contributor_system_cd
      AND eat.active_ind=1)
    HEAD cva.alias
     contrib_rec->qual[d.seq].sending_facility = cva.alias, contrib_rec->qual[d.seq].
     contributor_system_cd = cs.contributor_system_cd, contrib_rec->qual[d.seq].contributor_source_cd
      = cs.contributor_source_cd,
     contrib_rec->qual[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->qual[d.seq].time_zone
      = cs.time_zone, contrib_rec->qual[d.seq].time_zone_idx = datetimezonebyname(contrib_rec->qual[d
      .seq].time_zone),
     contrib_rec->qual[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->qual[d.seq].
     organization_id = cs.organization_id, found_ext_alias = false,
     found_ssn_alias = false, found_attend_doc_alias = false, found_admit_doc_alias = false,
     found_billing_org_alias = false, found_billing_prsnl_alias = false
    DETAIL
     IF (found_ext_alias=false
      AND eat.esi_alias_field_cd=ext_alias_field_cd)
      found_ext_alias = true, contrib_rec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd,
      contrib_rec->qual[d.seq].ext_alias_type_cd = eat.alias_entity_alias_type_cd
     ENDIF
     IF (found_ssn_alias=false
      AND eat.esi_alias_field_cd=ssn_alias_field_cd)
      found_ssn_alias = true, contrib_rec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd,
      contrib_rec->qual[d.seq].ssn_alias_type_cd = eat.alias_entity_alias_type_cd
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET CONTRIBUTOR SYSTEMS"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("GET CONTRIBUTOR SYSTEMS :: Select Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   FOR (fidx = 1 TO hold->qual_knt)
     IF ((hold->qual[fidx].contrib_idx > 0))
      IF ((contrib_rec->qual[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
       SET hold->qual[fidx].contrib_idx = - (1)
       SET hold->qual[fidx].status = "F"
       SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
      ENDIF
     ENDIF
   ENDFOR
   IF ((hold->qual_knt > 0))
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
     " Rows Found For Processing")
    CALL echo("***")
    CALL echo("***   EXT_ALIAS MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].person_id=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(hold->qual[d.seq].ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd
      )
       AND p.active_ind=1)
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ext_alias_exists_ind = 1,
      hold->qual[d.seq].ext_alias_person_alias_id = p.person_alias_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "EXT_ALIAS MATCH"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS MATCH :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   SSN MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p,
      person per
     PLAN (d
      WHERE (hold->qual[d.seq].person_id < 1)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].unable_to_do_ssn_chk=false)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(cnvtstring(cnvtint(hold->qual[d.seq].ssn_alias)))
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd
      )
       AND p.active_ind=1)
      JOIN (per
      WHERE per.person_id=p.person_id
       AND per.abs_birth_dt_tm=datetimezone(hold->qual[d.seq].birth_dt_tm,contrib_rec->qual[hold->
       qual[d.seq].contrib_idx].time_zone_idx,1)
       AND per.name_first_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first))
       AND per.name_last_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last))
       AND (per.sex_cd=hold->qual[d.seq].sex_cd))
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ssn_alias_exists_ind = 1,
      hold->qual[d.seq].ssn_alias_person_alias_id = p.person_alias_id
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "SSN MATCH"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SSN MATCH :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   GET EVENT ID")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      clinical_event ce
     PLAN (d
      WHERE (hold->qual[d.seq].event_id=0.0)
       AND (hold->qual[d.seq].person_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (ce
      WHERE (ce.reference_nbr=hold->qual[d.seq].ref_nbr)
       AND (ce.contributor_system_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd))
     DETAIL
      hold->qual[d.seq].event_id = ce.event_id, hold->qual[d.seq].clinical_event_id = ce
      .clinical_event_id, hold->qual[d.seq].event_cd = ce.event_cd
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET EVENT ID"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET EVENT ID :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   MAP CPT CODE TO EVENT CD")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value_alias cva
     PLAN (d
      WHERE (hold->qual[d.seq].event_cd=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cva
      WHERE cva.alias=trim(hold->qual[d.seq].event_code)
       AND cva.code_set=72
       AND cva.contributor_source_cd=cernerchr_contributor_source_cd)
     DETAIL
      hold->qual[d.seq].event_cd = cva.code_value
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "MAP CPT CODE TO EVENT CD"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("MAP CPT CODE TO EVENT CD :: Select Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   MAP CPT CODE TO EVENT CD 2")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value_alias cva
     PLAN (d
      WHERE (hold->qual[d.seq].event_cd=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (cva
      WHERE cva.alias=trim(hold->qual[d.seq].event_code)
       AND cva.code_set=72
       AND (cva.contributor_source_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_source_cd))
     DETAIL
      hold->qual[d.seq].event_cd = cva.code_value
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "MAP CPT CODE TO EVENT CD 2"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("MAP CPT CODE TO EVENT CD 2 :: Select Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF ((hold->qual[temp_i].person_id=0))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[mrn]")
      ENDIF
      IF ((hold->qual[temp_i].event_cd=0))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[eventcd]")
      ENDIF
      IF ((hold->qual[temp_i].person_id > 0)
       AND (hold->qual[temp_i].event_cd > 0))
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = select_error
        SET table_name = "CE SELECT"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat("CE SELECT :: Select Error :: ",trim(serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
       CALL echo("***")
       CALL echo("***   move contrib_sys info to hold")
       CALL echo("***")
       SET contrib_rec_size = size(contrib_rec->qual,5)
       FOR (z = 1 TO contrib_rec_size)
         IF ((contrib_rec->qual[z].sending_facility=hold->qual[temp_i].sending_facility))
          SET hold->qual[temp_i].contributor_system_cd = contrib_rec->qual[z].contributor_system_cd
          SET hold->qual[temp_i].prsnl_person_id = contrib_rec->qual[z].prsnl_person_id
         ENDIF
       ENDFOR
       CALL echo("***")
       CALL echo("***   See if clinical event exists")
       CALL echo("***")
       SELECT INTO "nl:"
        FROM clinical_event ce
        WHERE (ce.reference_nbr=hold->qual[temp_i].ref_nbr)
         AND (ce.contributor_system_cd=contrib_rec->qual[hold->qual[temp_i].contrib_idx].
        contributor_system_cd)
        DETAIL
         hold->qual[temp_i].clinical_event_id = ce.clinical_event_id
        WITH nocounter
       ;end select
       IF ((hold->qual[temp_i].clinical_event_id=0))
        SELECT INTO "nl:"
         y = seq(clinical_event_seq,nextval)
         FROM dual
         DETAIL
          hold->qual[temp_i].clinical_event_id = cnvtreal(y)
         WITH format, nocounter
        ;end select
        SELECT INTO "nl:"
         y = seq(clinical_event_seq,nextval)
         FROM dual
         DETAIL
          hold->qual[temp_i].event_id = cnvtreal(y)
         WITH format, nocounter
        ;end select
        CALL echo("***")
        CALL echo("***   INSERT CLINICAL EVENT")
        CALL echo("***")
        INSERT  FROM clinical_event ce
         SET ce.clinical_event_id = hold->qual[temp_i].clinical_event_id, ce.encntr_id = 0, ce
          .person_id = hold->qual[temp_i].person_id,
          ce.event_start_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.event_start_tz =
          0, ce.encntr_financial_id = 0,
          ce.event_id = hold->qual[temp_i].event_id, ce.valid_until_dt_tm = cnvtdatetime(max_date),
          ce.event_title_text = null,
          ce.view_level = 1, ce.order_id = 0, ce.catalog_cd = 0,
          ce.series_ref_nbr = cnvtstring(cnvtint(hold->qual[temp_i].event_id)), ce.accession_nbr =
          null, ce.contributor_system_cd = hold->qual[temp_i].contributor_system_cd,
          ce.reference_nbr = hold->qual[temp_i].ref_nbr, ce.parent_event_id = hold->qual[temp_i].
          event_id, ce.event_reltn_cd = root_event_reltn_cd,
          ce.valid_from_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.event_class_cd =
          immun_event_class_cd, ce.event_cd = hold->qual[temp_i].event_cd,
          ce.event_tag = concat("Line No. ",hold->qual[temp_i].line_item_number), ce.event_end_dt_tm
           = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.event_end_dt_tm_os = 0,
          ce.event_end_tz = 0, ce.result_val = null, ce.result_units_cd = 0,
          ce.result_time_units_cd = 0, ce.task_assay_cd = 0, ce.record_status_cd =
          active_active_status_cd,
          ce.result_status_cd = auth_data_status_cd, ce.authentic_flag = 1, ce.publish_flag = 1,
          ce.qc_review_cd = 0, ce.normalcy_cd = 0, ce.normalcy_method_cd = 0,
          ce.inquire_security_cd = routclinical_inquire_security_cd, ce.resource_group_cd = 0, ce
          .resource_cd = 0,
          ce.subtable_bit_map = 4, ce.collating_seq = null, ce.verified_dt_tm = null,
          ce.verified_tz = 0, ce.verified_prsnl_id = hold->qual[temp_i].prsnl_person_id, ce
          .performed_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm),
          ce.performed_tz = 0, ce.performed_prsnl_id = hold->qual[temp_i].prsnl_person_id, ce
          .note_importance_bit_map = 0,
          ce.event_tag_set_flag = 0, ce.normal_low = null, ce.normal_high = null,
          ce.critical_low = null, ce.critical_high = null, ce.expiration_dt_tm = null,
          ce.updt_dt_tm = cnvtdatetime(current_dt_tm), ce.clinsig_updt_dt_tm = cnvtdatetime(hold->
           qual[temp_i].service_dt_tm), ce.updt_id = hold->qual[temp_i].prsnl_person_id,
          ce.updt_task = 424990, ce.updt_cnt = 0, ce.updt_applctx = 424990,
          ce.order_action_sequence = 0, ce.entry_mode_cd = immunization_entry_mode_cd, ce.source_cd
           = 0,
          ce.clinical_seq = trim(hold->qual[temp_i].line_item_number), ce.task_assay_version_nbr = 0,
          ce.modifier_long_text_id = 0
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = select_error
         SET table_name = "CLINICAL EVENT INSERT"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("CLINICAL EVENT INSERT :: Select Error :: ",trim(
           serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        IF (curqual > 0)
         CALL echo("***")
         CALL echo("***   Insert CE_MED_RESULT")
         CALL echo("***")
         INSERT  FROM ce_med_result ce
          SET ce.event_id = hold->qual[temp_i].event_id, ce.admin_start_dt_tm = cnvtdatetime(hold->
            qual[temp_i].service_dt_tm), ce.valid_until_dt_tm = cnvtdatetime(max_date),
           ce.valid_from_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.updt_dt_tm =
           cnvtdatetime(current_dt_tm), ce.updt_id = hold->qual[temp_i].prsnl_person_id,
           ce.updt_task = 424990, ce.updt_cnt = 0, ce.updt_applctx = 424990
          WITH nocounter
         ;end insert
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "CE MED RESULT INSERT"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("CE MED RESULT INSERT :: Select Error :: ",trim(
            serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
       ELSEIF ((hold->qual[temp_i].clinical_event_id > 0))
        CALL echo("***")
        CALL echo("***   UPDATE CLINICAL EVENT")
        CALL echo("***")
        IF (cnvtint(hold->qual[temp_i].action) > 0
         AND working_mode != 2)
         CALL echo("***")
         CALL echo("***   update only if action is greater than 0 CLINICAL_EVENT")
         CALL echo("***")
         UPDATE  FROM clinical_event ce
          SET ce.person_id = hold->qual[temp_i].person_id, ce.event_start_dt_tm = cnvtdatetime(hold->
            qual[temp_i].service_dt_tm), ce.event_start_tz = 0,
           ce.valid_until_dt_tm = cnvtdatetime(max_date), ce.view_level = 1, ce.contributor_system_cd
            = hold->qual[temp_i].contributor_system_cd,
           ce.reference_nbr = hold->qual[temp_i].ref_nbr, ce.parent_event_id = hold->qual[temp_i].
           event_id, ce.event_reltn_cd = root_event_reltn_cd,
           ce.valid_from_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.event_class_cd =
           immun_event_class_cd, ce.event_cd = hold->qual[temp_i].event_cd,
           ce.event_tag = concat("Line No. ",hold->qual[temp_i].line_item_number), ce.event_end_dt_tm
            = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.event_end_dt_tm_os = 0,
           ce.event_end_tz = 0, ce.result_val = null, ce.result_units_cd = 0,
           ce.result_time_units_cd = 0, ce.task_assay_cd = 0, ce.record_status_cd =
           active_active_status_cd,
           ce.result_status_cd = auth_data_status_cd, ce.authentic_flag = 1, ce.publish_flag = 1,
           ce.qc_review_cd = 0, ce.normalcy_cd = 0, ce.normalcy_method_cd = 0,
           ce.inquire_security_cd = routclinical_inquire_security_cd, ce.resource_group_cd = 0, ce
           .resource_cd = 0,
           ce.subtable_bit_map = 4, ce.collating_seq = null, ce.verified_dt_tm = null,
           ce.verified_tz = 0, ce.verified_prsnl_id = hold->qual[temp_i].prsnl_person_id, ce
           .performed_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm),
           ce.performed_tz = 0, ce.performed_prsnl_id = hold->qual[temp_i].prsnl_person_id, ce
           .note_importance_bit_map = 0,
           ce.event_tag_set_flag = 0, ce.normal_low = null, ce.normal_high = null,
           ce.critical_low = null, ce.critical_high = null, ce.expiration_dt_tm = null,
           ce.clinsig_updt_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.updt_cnt = (ce
           .updt_cnt+ 1), ce.updt_dt_tm = cnvtdatetime(current_dt_tm),
           ce.updt_task = 424990, ce.updt_applctx = 424990, ce.updt_id = hold->qual[temp_i].
           prsnl_person_id
          WHERE (hold->qual[temp_i].clinical_event_id > 0)
           AND (ce.clinical_event_id=hold->qual[temp_i].clinical_event_id)
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "CLINICAL EVENT UPDATE 1"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("CLINICAL EVENT UPDATE 1 :: Select Error :: ",
           trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
         CALL echo("***")
         CALL echo("***   update only if action is greater than 0 CE_MED_RESULT")
         CALL echo("***")
         UPDATE  FROM ce_med_result ce
          SET ce.event_id = hold->qual[temp_i].event_id, ce.admin_start_dt_tm = cnvtdatetime(hold->
            qual[temp_i].service_dt_tm), ce.valid_until_dt_tm = cnvtdatetime(max_date),
           ce.valid_from_dt_tm = cnvtdatetime(hold->qual[temp_i].service_dt_tm), ce.updt_dt_tm =
           cnvtdatetime(current_dt_tm), ce.updt_cnt = (ce.updt_cnt+ 1),
           ce.updt_task = 424990, ce.updt_applctx = 424990, ce.updt_id = hold->qual[temp_i].
           prsnl_person_id
          WHERE (hold->qual[temp_i].event_id > 0)
           AND (ce.event_id=hold->qual[temp_i].event_id)
          WITH nocounter
         ;end update
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "CE MED RESULT UPDATE 1"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("CE MED RESULT UPDATE 1 :: Select Error :: ",
           trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ELSEIF (working_mode != 2)
         CALL echo("***")
         CALL echo("***   inactivate if action is greater than 0 CLINICAL_EVENT")
         CALL echo("***")
         UPDATE  FROM clinical_event ce
          SET ce.valid_until_dt_tm = cnvtdatetime(current_dt_tm), ce.updt_cnt = (ce.updt_cnt+ 1), ce
           .updt_dt_tm = cnvtdatetime(current_dt_tm),
           ce.updt_task = 424990, ce.updt_applctx = 424990, ce.updt_id = hold->qual[temp_i].
           prsnl_person_id
          WHERE (hold->qual[temp_i].clinical_event_id > 0)
           AND (ce.clinical_event_id=hold->qual[temp_i].clinical_event_id)
           AND working_mode != 2
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "CLINICAL EVENT UPDATE 2"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("CLINICAL EVENT UPDATE 2 :: Select Error :: ",
           trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
         CALL echo("***")
         CALL echo("***   inactivate if action is greater than 0 CE_MED_RESULT")
         CALL echo("***")
         UPDATE  FROM ce_med_result ce
          SET ce.event_id = hold->qual[temp_i].event_id, ce.valid_until_dt_tm = cnvtdatetime(
            current_dt_tm), ce.updt_dt_tm = cnvtdatetime(current_dt_tm),
           ce.updt_cnt = (ce.updt_cnt+ 1), ce.updt_task = 424990, ce.updt_applctx = 424990,
           ce.updt_id = hold->qual[temp_i].prsnl_person_id
          WHERE (hold->qual[temp_i].event_id > 0)
           AND (ce.event_id=hold->qual[temp_i].event_id)
          WITH nocounter
         ;end update
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "CE MED RESULT UPDATE 2"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("CE MED RESULT UPDATE 2 :: Select Error :: ",
           trim(serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    CALL echo("***")
    CALL echo("***   Update Data to Complete")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_immun_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.person_id = hold->qual[d.seq].person_id, o.event_id = hold->qual[d.seq].event_id, o.event_cd
       = hold->qual[d.seq].event_cd,
      o.contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd
     PLAN (d
      WHERE (hold->qual[d.seq].ags_immun_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (o
      WHERE (o.ags_immun_data_id=hold->qual[d.seq].ags_immun_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE IMMUN DATA COMPLETE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE IMMUN DATA COMPLETE :: Update Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
    CALL echo("***")
    CALL echo("***   Update Immun Data to IN ERROR")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_immun_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "IN ERROR", o.status_dt_tm = cnvtdatetime(curdate,curtime3), o.stat_msg = trim(
       substring(1,40,hold->qual[d.seq].stat_msg))
     PLAN (d
      WHERE (hold->qual[d.seq].ags_immun_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx < 1))
      JOIN (o
      WHERE (o.ags_immun_data_id=hold->qual[d.seq].ags_immun_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE IMMUN DATA IN ERROR"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE IMMUN DATA IN ERROR :: Update Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
    CALL echo("***")
    CALL echo("***   Find prev events to inactivate")
    CALL echo("***")
    FREE RECORD inact_rec
    RECORD inact_rec(
      1 qual_knt = i4
      1 qual[*]
        2 event_id = f8
        2 prsnl_person_id = f8
    )
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      clinical_event ce
     PLAN (d
      WHERE (hold->qual[d.seq].prev_claim_identifier > " ")
       AND (hold->qual[d.seq].prev_ref_nbr > " "))
      JOIN (ce
      WHERE operator(ce.reference_nbr,"LIKE",notrim(patstring(hold->qual[d.seq].prev_ref_nbr,1)))
       AND (ce.contributor_system_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd))
     HEAD REPORT
      iknt = 0, stat = alterlist(inact_rec->qual,data_size)
     DETAIL
      iknt = (iknt+ 1)
      IF (size(inact_rec->qual,5)=iknt)
       stat = alterlist(inact_rec->qual,(iknt+ data_size))
      ENDIF
      inact_rec->qual[iknt].event_id = ce.event_id, inact_rec->qual[iknt].prsnl_person_id = hold->
      qual[d.seq].prsnl_person_id
     FOOT REPORT
      inact_rec->qual_knt = iknt, stat = alterlist(inact_rec->qual,iknt)
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = select_error
     SET table_name = "GET EVENT_ID TO INACT"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET EVENT_ID TO INACT :: Select Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF ((inact_rec->qual_knt > 0))
     CALL echo("***")
     CALL echo("***   Inactive Prev Claims on CLINICAL_EVENT")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM clinical_event ce,
       (dummyt d  WITH seq = value(inact_rec->qual_knt))
      SET ce.valid_until_dt_tm = cnvtdatetime(dates->now_dt_tm), ce.updt_cnt = (ce.updt_cnt+ 1), ce
       .updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
       ce.updt_task = 424990, ce.updt_applctx = 424990, ce.updt_id = inact_rec->qual[d.seq].
       prsnl_person_id
      PLAN (d
       WHERE (inact_rec->qual[d.seq].event_id > 0))
       JOIN (ce
       WHERE (ce.event_id=inact_rec->qual[d.seq].event_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "INACTIVE IMMUN DATA IN ERROR"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INACTIVE IMMUN DATA IN ERROR :: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Inactive Prev Claims on CE_MED_RESULT")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     UPDATE  FROM ce_med_result cm,
       (dummyt d  WITH seq = value(inact_rec->qual_knt))
      SET cm.valid_until_dt_tm = cnvtdatetime(dates->now_dt_tm), cm.updt_dt_tm = cnvtdatetime(dates->
        now_dt_tm), cm.updt_cnt = (cm.updt_cnt+ 1),
       cm.updt_task = 424990, cm.updt_applctx = 424990, cm.updt_id = inact_rec->qual[d.seq].
       prsnl_person_id
      PLAN (d
       WHERE (inact_rec->qual[d.seq].event_id > 0))
       JOIN (cm
       WHERE (cm.event_id=inact_rec->qual[d.seq].event_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = update_error
      SET table_name = "INACTIVE IMMUN DATA IN ERROR"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("INACTIVE IMMUN DATA IN ERROR :: Update Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     COMMIT
    ENDIF
   ELSE
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = "No Rows Found For Processing"
   ENDIF
   CALL echo("***")
   CALL echo("***   Get KILL_IND")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_task t
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    DETAIL
     working_kill_ind = t.kill_ind
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET KILL_IND"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("GET KILL_IND :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   SET dates->it_end_dt_tm = cnvtdatetime(curdate,curtime3)
   SET it_avg = 0
   IF ((hold->qual_knt > 0))
    SET it_avg = (cnvtreal(hold->qual_knt)/ datetimediff(dates->it_end_dt_tm,dates->now_dt_tm,5))
   ENDIF
   CALL echo("***")
   CALL echo(build("***   it_avg :",it_avg))
   CALL echo("***")
   IF (it_avg > 0)
    SET dates->it_est_end_dt_tm = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((max_data_id -
         end_data_id)+ 1))/ it_avg))),",S"),dates->it_end_dt_tm)
   ENDIF
   CALL echorecord(dates)
   CALL echo("***")
   CALL echo("***   Update Iteration")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.iteration_start_id = beg_data_id, t.iteration_end_id = end_data_id, t.iteration_count =
     hold->qual_knt,
     t.iteration_start_dt_tm = cnvtdatetime(dates->now_dt_tm), t.iteration_end_dt_tm = cnvtdatetime(
      dates->it_end_dt_tm), t.iteration_average = it_avg,
     t.est_completion_dt_tm = cnvtdatetime(dates->it_est_end_dt_tm)
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "UPDATE ITERATION"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("UPDATE ITERATION :: Update Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "INFO"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("END PROCESSING :: BEG_DATA_ID :: ",trim(cnvtstring(
      beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
    trim(cnvtstring(max_data_id)))
   SET beg_data_id = (end_data_id+ 1)
   IF (((beg_data_id+ data_size) > max_data_id))
    SET end_data_id = max_data_id
   ELSE
    SET end_data_id = ((beg_data_id+ data_size) - 1)
   ENDIF
 ENDWHILE
 IF (working_task_id > 0
  AND working_kill_ind < 1)
  CALL echo("***")
  CALL echo("***   Update Task to Complete")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "COMPLETE", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK COMPLETE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK COMPLETE :: Select Error :: ",trim(serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  SET job_complete = true
  SELECT INTO "nl:"
   FROM ags_task t
   WHERE t.ags_job_id=working_job_id
    AND t.status != "COMPLETE"
   DETAIL
    job_complete = false
   WITH nocounter
  ;end select
  IF (job_complete)
   UPDATE  FROM ags_job j
    SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE j.ags_job_id=working_job_id
    WITH nocounter
   ;end update
  ENDIF
 ELSEIF (working_task_id > 0
  AND working_kill_ind > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Waiting Kill_ind = 1")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "WAITING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK COMPLETE"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_TASK KILL_IND WAITING :: Select Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[idx].smsgtype,"#######")," :: ",
           format(log->qual[idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[idx].
            smsg))))
        IF ((idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("cermsg")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
  CALL echo("***")
  CALL echo("***   failed != FALSE")
  CALL echo("***")
  IF (working_task_id > 0)
   CALL echo("***")
   CALL echo("***   Update Task to Error")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK ERROR"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK ERROR :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_IMMUN_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("***")
 CALL echo("***   END AGS_IMMUN_LOAD")
 CALL echo("***")
 CALL echorecord(contrib_rec)
 SET script_ver = "010 09/08/06"
END GO
