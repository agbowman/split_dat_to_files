CREATE PROGRAM ags_org_load:dba
 PROMPT
  "TASK_ID (0.0) =" = 0
  WITH dtask_id
 CALL echo("***")
 CALL echo("***   BEG AGS_ORG_LOAD")
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
  DECLARE sstatus_file_name = vc WITH public, noconstant(concat("ags_org_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_ORG_LOAD"
  SET define_logging_sub = true
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "BEG >> AGS_ORG_LOAD"
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
   1 list_knt = i4
   1 list[*]
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
     2 loc_cva_alias_stamp = vc
 )
 FREE RECORD alt_rec
 RECORD alt_rec(
   1 qual_knt = i4
   1 qual[*]
     2 esi_alias_type = vc
     2 contrib_idx = i4
     2 alt_alias_pool_cd = f8
     2 alt_alias_type_cd = f8
     2 loc_cva_alias_stamp = vc
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
 DECLARE found_default_contrib_system = i2 WITH public, noconstant(false)
 DECLARE create_orgs = i2 WITH public, noconstant(false)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE esi_default_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY",73,"Default"))
 DECLARE org_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",396,"ORG"))
 DECLARE auth_data_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE active_active_status_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE client_alias_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",334,"CLIENT"))
 DECLARE work_phone_type_cd = f8 WITH publlic, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE work_addr_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE client_org_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE facility_org_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",278,"FACILITY"))
 DECLARE facility_loc_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "ORGEXTALIAS"))
 DECLARE alt_alias_field_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "ORGALTALIAS"))
 DECLARE found_address_delete = i2 WITH public, noconstant(false)
 DECLARE found_phone_delete = i2 WITH public, noconstant(false)
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
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_name="AGS_CREATE_ORGS")
  DETAIL
   IF (di.info_number > 0)
    create_orgs = true
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("***")
 CALL echo(build("***   create_orgs :",create_orgs))
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
 CALL echo("***")
 CALL echo("***   Validate Code Values")
 CALL echo("***")
 CALL echo(build("***   esi_default_cd :",esi_default_cd))
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
 CALL echo(build("***   ext_alias_field_cd :",ext_alias_field_cd))
 IF (ext_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET EXT_ALIAS VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "EXT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning ORGEXTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   alt_alias_field_cd :",alt_alias_field_cd))
 IF (alt_alias_field_cd < 1)
  SET failed = select_error
  SET table_name = "GET ALT_ALIAS VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ALT_ALIAS_FIELD_CD :: Select Error :: CODE_VALUE for meaning ORGALTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   work_phone_type_cd :",work_phone_type_cd))
 IF (work_phone_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "WORK_PHONE_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING BUSINESS invalid from CODE_SET 43"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   work_addr_type_cd :",work_addr_type_cd))
 IF (work_addr_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "WORK_ADDR_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING BUSINESS invalid from CODE_SET 212"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   org_class_cd :",org_class_cd))
 IF (org_class_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ORG_CLASS_CD :: Select Error :: CODE_VALUE for CDF_MEANING ORG invalid from CODE_SET 396"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   auth_data_status_cd :",auth_data_status_cd))
 IF (auth_data_status_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "AUTH_DATA_STATUS_CD :: Select Error :: CODE_VALUE for CDF_MEANING AUTH invalid from CODE_SET 8"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   active_active_status_cd :",active_active_status_cd))
 IF (active_active_status_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "ACTIVE_ACTIVE_STATUS_CD :: Select Error :: CODE_VALUE for CDF_MEANING ACTIVE invalid from CODE_SET 48"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   client_org_type_cd :",client_org_type_cd))
 IF (client_org_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "CLIENT_ORG_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING CLIENT invalid from CODE_SET 278"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("***   facility_org_type_cd :",facility_org_type_cd))
 IF (facility_org_type_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "FACILITY_ORG_TYPE_CD :: Select Error :: CODE_VALUE for CDF_MEANING FACILITY invalid from CODE_SET 278"
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
  CALL echo("***")
  CALL echo("***   MODE 3 CHK")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   max_id = max(o.ags_org_data_id), dknt = count(o.ags_org_data_id)
   FROM ags_org_data o
   PLAN (o
    WHERE o.ags_org_data_id >= beg_data_id
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
       2 ags_org_data_id = f8
       2 contrib_idx = i4
       2 alt1_idx = i4
       2 alt2_idx = i4
       2 alt3_idx = i4
       2 run_nbr = f8
       2 run_dt_tm = dq8
       2 file_row_nbr = i4
       2 org_exists_ind = i2
       2 organization_id = f8
       2 ext_alias_exists_ind = i2
       2 ext_alias_id = f8
       2 loc_exists_ind = i2
       2 loc_cd_exists_ind = i2
       2 loc_cva_exists_ind = i2
       2 loc_cva_ext_exist_ind = i2
       2 loc_cva_alt1_exist_ind = i2
       2 loc_cva_alt2_exist_ind = i2
       2 loc_cva_alt3_exist_ind = i2
       2 location_cd = f8
       2 add_location_table_ind = i2
       2 address_exists_ind = i2
       2 address_id = f8
       2 phone_exists_ind = i2
       2 phone_id = f8
       2 phone_action_flag = i2
       2 address_action_flag = i2
       2 org_table_org_name = c100
       2 name = c100
       2 street_addr = c100
       2 street_addr2 = c100
       2 street_addr3 = c100
       2 street_addr4 = c100
       2 city = c100
       2 state = c100
       2 state_cd = f8
       2 zipcode = c25
       2 county = c100
       2 county_cd = f8
       2 country = c100
       2 country_cd = f8
       2 phone_num = c100
       2 ext_alias_pool_disp = c40
       2 ext_alias = c100
       2 alt_alias1_pool_disp = c40
       2 alt_alias1_type_disp = c40
       2 alt_alias1_type_cd = f8
       2 alt_alias1 = c100
       2 alt_alias1_exists_ind = i2
       2 alt_alias1_id = f8
       2 alt_alias2_pool_disp = c40
       2 alt_alias2_type_disp = c40
       2 alt_alias2_type_cd = f8
       2 alt_alias2 = c100
       2 alt_alias2_exists_ind = i2
       2 alt_alias2_id = f8
       2 alt_alias3_pool_disp = c40
       2 alt_alias3_type_disp = c40
       2 alt_alias3_type_cd = f8
       2 alt_alias3 = c100
       2 alt_alias3_exists_ind = i2
       2 alt_alias3_id = f8
       2 status = vc
       2 stat_msg = vc
   )
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo("***")
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET hold->qual_knt = 0
   SET found_address_delete = false
   SET found_phone_delete = false
   CALL echo("***")
   CALL echo("***   Load Org Data")
   CALL echo("***")
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (o
      WHERE o.ags_org_data_id >= beg_data_id
       AND o.ags_org_data_id <= end_data_id
       AND ((o.organization_id+ 0) < 1)
       AND trim(o.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (o
      WHERE o.ags_org_data_id >= beg_data_id
       AND o.ags_org_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (o
      WHERE o.ags_org_data_id >= beg_data_id
       AND o.ags_org_data_id <= end_data_id
       AND ((o.organization_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSE
     PLAN (o
      WHERE o.ags_org_data_id >= beg_data_id
       AND o.ags_org_data_id <= end_data_id
       AND trim(o.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_org_data o,
     ags_job j
    HEAD REPORT
     stat = alterlist(hold->qual,data_size), idx = 0
    HEAD o.ags_org_data_id
     idx = (idx+ 1)
     IF (idx > size(hold->qual,5))
      stat = alterlist(hold->qual,(idx+ data_size))
     ENDIF
     hold->qual[idx].ags_org_data_id = o.ags_org_data_id
     IF ((contrib_rec->list_knt > 0))
      IF (size(trim(o.sending_facility,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->list_knt,o.sending_facility,contrib_rec->list[num]
        .sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
         contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(o
         .sending_facility,3),
        hold->qual[idx].contrib_idx = contrib_rec->list_knt
       ENDIF
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->list_knt,j.sending_system,contrib_rec->list[num].
        sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
         contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(j
         .sending_system,3),
        hold->qual[idx].contrib_idx = contrib_rec->list_knt
       ENDIF
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
         stat_msg),"[contrib]")
      ENDIF
     ELSE
      IF (size(trim(o.sending_facility,3)) > 0)
       contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
        contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(o
        .sending_facility,3),
       hold->qual[idx].contrib_idx = contrib_rec->list_knt
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       contrib_rec->list_knt = (contrib_rec->list_knt+ 1), stat = alterlist(contrib_rec->list,
        contrib_rec->list_knt), contrib_rec->list[contrib_rec->list_knt].sending_facility = trim(j
        .sending_system,3),
       hold->qual[idx].contrib_idx = contrib_rec->list_knt
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].
         stat_msg),"[contrib]")
      ENDIF
     ENDIF
     hold->qual[idx].ext_alias = trim(o.ext_alias,3), hold->qual[idx].name = trim(o.name,3), hold->
     qual[idx].organization_id = o.organization_id
     IF ((hold->qual[idx].organization_id > 0))
      hold->qual[idx].org_exists_ind = 1
     ELSE
      hold->qual[idx].org_exists_ind = 0
     ENDIF
     hold->qual[idx].location_cd = o.location_cd
     IF (o.location_cd > 0)
      hold->qual[idx].loc_cd_exists_ind = 1, hold->qual[idx].loc_exists_ind = 1
     ENDIF
     hold->qual[idx].add_location_table_ind = true, hold->qual[idx].street_addr = trim(o.street_addr,
      3), hold->qual[idx].street_addr2 = trim(o.street_addr2,3),
     hold->qual[idx].city = trim(o.city,3), hold->qual[idx].state = trim(o.state,3), hold->qual[idx].
     zipcode = trim(o.zipcode,3),
     hold->qual[idx].county = trim(o.county,3), hold->qual[idx].country = trim(o.country,3), hold->
     qual[idx].phone_num = trim(o.phone1,3)
     IF (cnvtupper(hold->qual[idx].street_addr)="<DEL>")
      hold->qual[idx].address_action_flag = 1, found_address_delete = true
     ELSEIF ( NOT ((hold->qual[idx].street_addr > " "))
      AND  NOT ((hold->qual[idx].street_addr2 > " "))
      AND  NOT ((hold->qual[idx].city > " "))
      AND  NOT ((hold->qual[idx].state > " "))
      AND  NOT ((hold->qual[idx].zipcode > " "))
      AND  NOT ((hold->qual[idx].county > " "))
      AND  NOT ((hold->qual[idx].country > " ")))
      hold->qual[idx].address_action_flag = 2
     ELSE
      hold->qual[idx].address_action_flag = 0
     ENDIF
     IF (cnvtupper(hold->qual[idx].phone_num)="<DEL>")
      hold->qual[idx].phone_action_flag = 1, found_phone_delete = true
     ELSEIF ( NOT ((hold->qual[idx].phone_num > " ")))
      hold->qual[idx].phone_action_flag = 2
     ELSE
      hold->qual[idx].phone_action_flag = 0
     ENDIF
     hold->qual[idx].alt_alias1 = trim(o.alt_alias1,3), hold->qual[idx].alt_alias1_type_disp = trim(o
      .alt_alias1_type,3)
     IF (size(trim(o.alt_alias1,3)) > 0)
      pos = 0, pos = locateval(num,1,alt_rec->qual_knt,o.alt_alias1_type,alt_rec->qual[num].
       esi_alias_type)
      IF (pos > 0)
       hold->qual[idx].alt1_idx = pos
      ELSE
       alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
       alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(o.alt_alias1_type,3),
       alt_rec->qual[alt_rec->qual_knt].contrib_idx = hold->qual[idx].contrib_idx, hold->qual[idx].
       alt1_idx = alt_rec->qual_knt
      ENDIF
     ELSE
      hold->qual[idx].alt1_idx = - (1)
     ENDIF
     hold->qual[idx].alt_alias2 = trim(o.alt_alias2), hold->qual[idx].alt_alias2_type_disp = o
     .alt_alias2_type
     IF (size(trim(o.alt_alias2,3)) > 0)
      pos = 0, pos = locateval(num,1,alt_rec->qual_knt,o.alt_alias2_type,alt_rec->qual[num].
       esi_alias_type)
      IF (pos > 0)
       hold->qual[idx].alt2_idx = pos
      ELSE
       alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
       alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(o.alt_alias2_type,3),
       alt_rec->qual[alt_rec->qual_knt].contrib_idx = hold->qual[idx].contrib_idx, hold->qual[idx].
       alt2_idx = alt_rec->qual_knt
      ENDIF
     ELSE
      hold->qual[idx].alt2_idx = - (1)
     ENDIF
     hold->qual[idx].alt_alias3 = trim(o.alt_alias3,3), hold->qual[idx].alt_alias3_type_disp = trim(o
      .alt_alias3_type,3)
     IF (size(trim(o.alt_alias3,3)) > 0)
      pos = 0, pos = locateval(num,1,alt_rec->qual_knt,o.alt_alias3_type,alt_rec->qual[num].
       esi_alias_type)
      IF (pos > 0)
       hold->qual[idx].alt3_idx = pos
      ELSE
       alt_rec->qual_knt = (alt_rec->qual_knt+ 1), stat = alterlist(alt_rec->qual,alt_rec->qual_knt),
       alt_rec->qual[alt_rec->qual_knt].esi_alias_type = trim(o.alt_alias3_type,3),
       alt_rec->qual[alt_rec->qual_knt].contrib_idx = hold->qual[idx].contrib_idx, hold->qual[idx].
       alt3_idx = alt_rec->qual_knt
      ENDIF
     ELSE
      hold->qual[idx].alt3_idx = - (1)
     ENDIF
    FOOT REPORT
     hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_ORG_DATA LOADING"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_ORG_DATA LOADING :: Select Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt > 0))
    CALL echo("***")
    CALL echo("***   Get Contributor System")
    CALL echo("***")
    IF ((contrib_rec->list_knt > 0))
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias cva,
       contributor_system cs,
       esi_alias_trans eat,
       (dummyt d  WITH seq = value(contrib_rec->list_knt))
      PLAN (d
       WHERE (contrib_rec->list[d.seq].contributor_system_cd < 1))
       JOIN (cva
       WHERE cva.code_set=89
        AND (cva.alias=contrib_rec->list[d.seq].sending_facility)
        AND cva.contributor_source_cd=esi_default_cd)
       JOIN (cs
       WHERE cs.contributor_system_cd=cva.code_value
        AND cs.active_ind=1)
       JOIN (eat
       WHERE eat.contributor_system_cd=cs.contributor_system_cd
        AND eat.active_ind=1)
      HEAD cva.alias
       contrib_rec->list[d.seq].sending_facility = cva.alias, contrib_rec->list[d.seq].
       contributor_system_cd = cs.contributor_system_cd, contrib_rec->list[d.seq].
       contributor_source_cd = cs.contributor_source_cd,
       contrib_rec->list[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->list[d.seq].
       time_zone = cs.time_zone, contrib_rec->list[d.seq].time_zone_idx = datetimezonebyname(
        contrib_rec->list[d.seq].time_zone),
       contrib_rec->list[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->list[d.seq].
       organization_id = cs.organization_id, found_ext_alias = false
      DETAIL
       IF (found_ext_alias=false
        AND eat.esi_alias_field_cd=ext_alias_field_cd)
        found_ext_alias = true, contrib_rec->list[d.seq].ext_alias_pool_cd = eat.alias_pool_cd,
        contrib_rec->list[d.seq].ext_alias_type_cd = eat.alias_entity_alias_type_cd,
        contrib_rec->list[d.seq].loc_cva_alias_stamp = concat("~",trim(cnvtupper(cnvtalphanum(
            uar_get_code_display(eat.alias_pool_cd)))),"~",trim(cnvtupper(cnvtalphanum(
            uar_get_code_display(eat.alias_entity_alias_type_cd)))))
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
    ELSE
     SET failed = input_error
     SET table_name = "GET CONTRIBUTOR SYSTEMS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg =
     "GET CONTRIBUTOR SYSTEMS :: Input Error :: contrib_rec->list_knt < 1 "
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    FOR (fidx = 1 TO hold->qual_knt)
      IF ((hold->qual[fidx].contrib_idx > 0))
       IF ((contrib_rec->list[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
        SET hold->qual[fidx].contrib_idx = - (1)
        SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
       ENDIF
      ENDIF
      IF ( NOT ((hold->qual[fidx].ext_alias > " ")))
       SET hold->qual[fidx].contrib_idx = - (1)
       SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[ext]")
      ENDIF
      IF ( NOT ((hold->qual[fidx].name > " ")))
       SET hold->qual[fidx].contrib_idx = - (1)
       SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[name]")
      ENDIF
    ENDFOR
    IF ((alt_rec->qual_knt > 0))
     CALL echo("***")
     CALL echo("***   Get alt Values")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM esi_alias_trans eat,
       (dummyt d  WITH seq = value(alt_rec->qual_knt))
      PLAN (d
       WHERE (alt_rec->qual[d.seq].contrib_idx > 0))
       JOIN (eat
       WHERE (eat.contributor_system_cd=contrib_rec->list[alt_rec->qual[d.seq].contrib_idx].
       contributor_system_cd)
        AND (eat.esi_alias_type=alt_rec->qual[d.seq].esi_alias_type)
        AND eat.alias_entity_name="ORGANIZATION"
        AND eat.esi_alias_field_cd=alt_alias_field_cd
        AND eat.active_ind=1)
      HEAD eat.esi_alias_type
       IF ((eat.esi_alias_type=alt_rec->qual[d.seq].esi_alias_type)
        AND (alt_rec->qual[d.seq].alt_alias_pool_cd < 1))
        alt_rec->qual[d.seq].alt_alias_pool_cd = eat.alias_pool_cd, alt_rec->qual[d.seq].
        alt_alias_type_cd = eat.alias_entity_alias_type_cd, alt_rec->qual[d.seq].loc_cva_alias_stamp
         = concat("~",trim(cnvtupper(cnvtalphanum(uar_get_code_display(eat.alias_pool_cd)))),"~",trim
         (cnvtupper(cnvtalphanum(uar_get_code_display(eat.alias_entity_alias_type_cd)))))
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "GET ALT VALUES"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("GET ALT VALUES :: Select Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "INFO"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
     " Rows Found For Processing")
    CALL echo("***")
    CALL echo("*** Does CVA Exist for LOCATION_CD > 0")
    CALL echo("***")
    CALL echo("***")
    CALL echo("***   Does Location CVA Exist")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM code_value_alias c,
      (dummyt d  WITH seq = value(hold->qual_knt))
     PLAN (d
      WHERE (hold->qual[d.seq].location_cd > 0)
       AND (hold->qual[d.seq].loc_cd_exists_ind > 0)
       AND (hold->qual[d.seq].loc_cva_ext_exist_ind=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (c
      WHERE (c.code_value=hold->qual[d.seq].location_cd)
       AND operator(c.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].ext_alias),trim(
          contrib_rec->list[hold->qual[d.seq].contrib_idx].loc_cva_alias_stamp),"*"),1))
       AND ((c.code_set+ 0)=220)
       AND ((c.contributor_source_cd+ 0)=contrib_rec->list[hold->qual[d.seq].contrib_idx].
      contributor_source_cd)
       AND c.alias_type_meaning="ORGEXTALIAS")
     DETAIL
      hold->qual[d.seq].loc_cva_ext_exist_ind = 1
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CHK LOCATION CVA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("CHK LOCATION CVA :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Does LOCATION_CD exist for EXT_ALIAS")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM code_value_alias c,
      (dummyt d  WITH seq = value(hold->qual_knt))
     PLAN (d
      WHERE (hold->qual[d.seq].location_cd < 1)
       AND (hold->qual[d.seq].loc_cd_exists_ind < 1)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (c
      WHERE operator(c.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].ext_alias),trim(
          contrib_rec->list[hold->qual[d.seq].contrib_idx].loc_cva_alias_stamp),"*"),1))
       AND ((c.code_set+ 0)=220)
       AND ((c.contributor_source_cd+ 0)=contrib_rec->list[hold->qual[d.seq].contrib_idx].
      contributor_source_cd)
       AND c.alias_type_meaning="ORGEXTALIAS")
     HEAD d.seq
      hold->qual[d.seq].loc_cva_ext_exist_ind = 1, hold->qual[d.seq].loc_cd_exists_ind = 1, hold->
      qual[d.seq].location_cd = c.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET LOCATION BY CVA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET LOCATION BY CVA :: Select Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    IF ((alt_rec->qual_knt > 0))
     CALL echo("***")
     CALL echo("***   Does Location Exist By ALT1 Alias")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias c,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].location_cd > 0)
        AND (hold->qual[d.seq].loc_cd_exists_ind > 0)
        AND (hold->qual[d.seq].loc_cva_alt1_exist_ind=0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt1_idx > 0))
       JOIN (c
       WHERE (c.code_value=hold->qual[d.seq].location_cd)
        AND operator(c.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].alt_alias1),trim(alt_rec
           ->qual[hold->qual[d.seq].alt1_idx].loc_cva_alias_stamp),"*"),1))
        AND ((c.code_set+ 0)=220)
        AND ((c.contributor_source_cd+ 0)=contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND c.alias_type_meaning="ORGALTALIAS")
      HEAD d.seq
       hold->qual[d.seq].loc_cva_alt1_exist_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK LOCATION BY ALT1_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK LOCATION BY ALT1_ALIAS :: Select Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Does Location Exist By ALT2 Alias")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias c,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].location_cd > 0)
        AND (hold->qual[d.seq].loc_cd_exists_ind > 0)
        AND (hold->qual[d.seq].loc_cva_alt2_exist_ind=0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt2_idx > 0))
       JOIN (c
       WHERE (c.code_value=hold->qual[d.seq].location_cd)
        AND operator(c.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].alt_alias2),trim(alt_rec
           ->qual[hold->qual[d.seq].alt2_idx].loc_cva_alias_stamp),"*"),1))
        AND ((c.code_set+ 0)=220)
        AND ((c.contributor_source_cd+ 0)=contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND c.alias_type_meaning="ORGALTALIAS")
      HEAD d.seq
       hold->qual[d.seq].loc_cva_alt2_exist_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK LOCATION BY ALT2_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK LOCATION BY ALT2_ALIAS :: Select Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Does Location Exist By ALT3 Alias")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM code_value_alias c,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].location_cd > 0)
        AND (hold->qual[d.seq].loc_cd_exists_ind > 0)
        AND (hold->qual[d.seq].loc_cva_alt3_exist_ind=0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt3_idx > 0))
       JOIN (c
       WHERE (c.code_value=hold->qual[d.seq].location_cd)
        AND operator(c.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].alt_alias3),trim(alt_rec
           ->qual[hold->qual[d.seq].alt3_idx].loc_cva_alias_stamp),"*"),1))
        AND ((c.code_set+ 0)=220)
        AND ((c.contributor_source_cd+ 0)=contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND c.alias_type_meaning="ORGALTALIAS")
      HEAD d.seq
       hold->qual[d.seq].loc_cva_alt3_exist_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK LOCATION BY ALT3_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK LOCATION BY ALT3_ALIAS :: Select Error :: ",
       trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    IF (create_orgs=true)
     CALL echo("***")
     CALL echo("***   Does EXT_ALIAS_ID Exist By ORG_ID")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].organization_id > 0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.organization_id=hold->qual[d.seq].organization_id)
        AND (o.alias_pool_cd=contrib_rec->list[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
        AND (o.org_alias_type_cd=contrib_rec->list[hold->qual[d.seq].contrib_idx].ext_alias_type_cd)
        AND o.active_ind=1)
      DETAIL
       hold->qual[d.seq].ext_alias_id = o.organization_alias_id, hold->qual[d.seq].
       ext_alias_exists_ind = true
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "EXT_ALIAS_ID CHK1"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS_ID CHK1 :: Select Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Get EXT_ALIAS_ID and ORG_ID")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].organization_id < 1)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o
       WHERE (o.alias=hold->qual[d.seq].ext_alias)
        AND (o.alias_pool_cd=contrib_rec->list[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
        AND (o.org_alias_type_cd=contrib_rec->list[hold->qual[d.seq].contrib_idx].ext_alias_type_cd)
        AND o.active_ind=1)
      DETAIL
       hold->qual[d.seq].ext_alias_id = o.organization_alias_id, hold->qual[d.seq].
       ext_alias_exists_ind = true, hold->qual[d.seq].organization_id = o.organization_id,
       hold->qual[d.seq].org_exists_ind = true
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "EXT_ALIAS_ID CHK2"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS_ID CHK2 :: Select Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     IF ((alt_rec->qual_knt > 0))
      CALL echo("***")
      CALL echo("***   Does ALT_ALIAS1 Exit")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM organization_alias o,
        (dummyt d  WITH seq = value(hold->qual_knt))
       PLAN (d
        WHERE (hold->qual[d.seq].alt_alias1 > " ")
         AND (hold->qual[d.seq].organization_id < 1)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].alt1_idx > 0))
        JOIN (o
        WHERE (o.alias=hold->qual[d.seq].alt_alias1)
         AND (o.alias_pool_cd=alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_pool_cd)
         AND (o.org_alias_type_cd=alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_type_cd)
         AND o.active_ind=1)
       DETAIL
        hold->qual[d.seq].alt_alias1_id = o.organization_alias_id, hold->qual[d.seq].
        alt_alias1_exists_ind = true
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "EXT_ALIAS1_ID CHK"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS1_ID CHK :: Select Error :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   Does ALT_ALIAS2 Exit")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM organization_alias o,
        (dummyt d  WITH seq = value(hold->qual_knt))
       PLAN (d
        WHERE (hold->qual[d.seq].alt_alias2 > " ")
         AND (hold->qual[d.seq].organization_id < 1)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].alt2_idx > 0))
        JOIN (o
        WHERE (o.alias=hold->qual[d.seq].alt_alias2)
         AND (o.alias_pool_cd=alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_pool_cd)
         AND (o.org_alias_type_cd=alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_type_cd)
         AND o.active_ind=1)
       DETAIL
        hold->qual[d.seq].alt_alias2_id = o.organization_alias_id, hold->qual[d.seq].
        alt_alias2_exists_ind = true
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "EXT_ALIAS2_ID CHK"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS2_ID CHK :: Select Error :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
      CALL echo("***")
      CALL echo("***   Does ALT_ALIAS3 Exit")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      SELECT INTO "nl:"
       FROM organization_alias o,
        (dummyt d  WITH seq = value(hold->qual_knt))
       PLAN (d
        WHERE (hold->qual[d.seq].alt_alias3 > " ")
         AND (hold->qual[d.seq].organization_id < 1)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].alt3_idx > 0))
        JOIN (o
        WHERE (o.alias=hold->qual[d.seq].alt_alias3)
         AND (o.alias_pool_cd=alt_rec->qual[hold->qual[d.seq].alt3_idx].alt_alias_pool_cd)
         AND (o.org_alias_type_cd=alt_rec->qual[hold->qual[d.seq].alt3_idx].alt_alias_type_cd)
         AND o.active_ind=1)
       DETAIL
        hold->qual[d.seq].alt_alias3_id = o.organization_alias_id, hold->qual[d.seq].
        alt_alias3_exists_ind = true
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "EXT_ALIAS3_ID CHK"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("EXT_ALIAS3_ID CHK :: Select Error :: ",trim(
         serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echo("***")
     CALL echo("***   Does Location Exist")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM location l,
       (dummyt d  WITH seq = value(hold->qual_knt))
      PLAN (d
       WHERE (hold->qual[d.seq].location_cd > 0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (l
       WHERE (l.location_cd=hold->qual[d.seq].location_cd)
        AND (l.organization_id=hold->qual[d.seq].organization_id))
      DETAIL
       hold->qual[d.seq].add_location_table_ind = false
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK LOCATION EXIST"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK LOCATION EXIST :: Select Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Determine Phone/Address Handling")
     CALL echo("***")
     CALL echo("***")
     CALL echo("***   Get Existing Phone")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       phone p
      PLAN (d
       WHERE (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (p
       WHERE (p.parent_entity_id=hold->qual[d.seq].organization_id)
        AND p.parent_entity_name="ORGANIZATION"
        AND p.phone_type_cd=work_phone_type_cd
        AND p.active_ind=1)
      DETAIL
       hold->qual[d.seq].phone_id = p.phone_id, hold->qual[d.seq].phone_exists_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK PHONE EXIST"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK PHONE EXIST :: Select Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Get Existing Address")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       address a
      PLAN (d
       WHERE (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (a
       WHERE (a.parent_entity_id=hold->qual[d.seq].organization_id)
        AND a.parent_entity_name="ORGANIZATION"
        AND a.address_type_cd=work_addr_type_cd
        AND a.active_ind=1)
      DETAIL
       hold->qual[d.seq].address_id = a.address_id, hold->qual[d.seq].address_exists_ind = 1
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "CHK ADDRESS EXIST"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("CHK ADDRESS EXIST :: Select Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Get New Sequence Numbers")
    CALL echo("***")
    FOR (x = 1 TO hold->qual_knt)
      IF ((hold->qual[x].contrib_idx > 0))
       IF (create_orgs=true)
        IF ((hold->qual[x].organization_id=0.0))
         SET ierrcode = error(serrmsg,1)
         SET ierrcode = 0
         SELECT INTO "nl:"
          y = seq(organization_seq,nextval)
          FROM dual
          DETAIL
           hold->qual[x].organization_id = cnvtreal(y)
          WITH nocounter
         ;end select
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = gen_nbr_error
          SET table_name = "GET NEW ORG ID"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("GET NEW ORG ID :: Select Error :: ",trim(
            serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
        IF ((hold->qual[x].ext_alias_id=0.0))
         SET ierrcode = error(serrmsg,1)
         SET ierrcode = 0
         SELECT INTO "nl:"
          y = seq(organization_seq,nextval)
          FROM dual
          DETAIL
           hold->qual[x].ext_alias_id = cnvtreal(y)
          WITH nocounter
         ;end select
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          SET failed = gen_nbr_error
          SET table_name = "GET NEW EXT_ALIAS_ID"
          SET ilog_status = 1
          SET log->qual_knt = (log->qual_knt+ 1)
          SET stat = alterlist(log->qual,log->qual_knt)
          SET log->qual[log->qual_knt].smsgtype = "ERROR"
          SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
          SET log->qual[log->qual_knt].smsg = concat("GET NEW EXT_ALIAS_ID :: Select Error :: ",trim(
            serrmsg))
          SET serrmsg = log->qual[log->qual_knt].smsg
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       IF ((hold->qual[x].location_cd=0.0))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(reference_seq,nextval)
         FROM dual
         DETAIL
          hold->qual[x].location_cd = cnvtreal(y)
         WITH nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "GET NEW LOC_CD"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("GET NEW LOC_CD :: Select Error :: ",trim(serrmsg
           ))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    CALL echorecord(hold)
    CALL echorecord(contrib_rec)
    CALL echorecord(alt_rec)
    IF (create_orgs=true)
     CALL echo("***")
     CALL echo("***   Handle Organizations")
     CALL echo("***")
     CALL echo("***")
     CALL echo("***   Add New Orgs")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_id = hold->qual[d.seq].organization_id, o.contributor_system_cd =
       contrib_rec->list[hold->qual[d.seq].contrib_idx].contributor_system_cd, o.org_name = hold->
       qual[d.seq].name,
       o.org_name_key = trim(cnvtupper(cnvtalphanum(hold->qual[d.seq].name))), o.federal_tax_id_nbr
        = "", o.org_status_cd = 0,
       o.ft_entity_id = 0, o.ft_entity_name = "", o.org_class_cd = org_class_cd,
       o.data_status_cd = auth_data_status_cd, o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd,
       o.beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), o.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm), o.active_ind = 1,
       o.active_status_cd = active_active_status_cd, o.active_status_prsnl_id = contrib_rec->list[
       hold->qual[d.seq].contrib_idx].contributor_system_cd, o.active_status_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[
       hold->qual[d.seq].contrib_idx].prsnl_person_id,
       o.updt_applctx = 4249900, o.updt_task = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].org_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ORG"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     IF (working_mode != 2)
      CALL echo("***")
      CALL echo("*** Doing Update ORGANIZATION")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      UPDATE  FROM organization o,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET o.org_name = hold->qual[d.seq].name, o.org_name_key = trim(cnvtupper(cnvtalphanum(hold->
           qual[d.seq].name))), o.active_ind = 1,
        o.active_status_cd = active_active_status_cd, o.active_status_prsnl_id = contrib_rec->list[
        hold->qual[d.seq].contrib_idx].prsnl_person_id, o.active_status_dt_tm = cnvtdatetime(dates->
         now_dt_tm),
        o.updt_cnt = (o.updt_cnt+ 1), o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id =
        contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id,
        o.updt_applctx = 4249900, o.updt_task = 4249900
       PLAN (d
        WHERE (hold->qual[d.seq].org_exists_ind=1)
         AND (hold->qual[d.seq].organization_id > 0.0)
         AND (hold->qual[d.seq].contrib_idx > 0))
        JOIN (o
        WHERE (o.organization_id=hold->qual[d.seq].organization_id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = update_error
       SET table_name = "ADD NEW ORG"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG :: Update Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echo("***")
     CALL echo("***   Add New ORG_ALIAS")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_alias_id = hold->qual[d.seq].ext_alias_id, o.organization_id = hold->qual[d
       .seq].organization_id, o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.alias_pool_cd = contrib_rec->list[
       hold->qual[d.seq].contrib_idx].ext_alias_pool_cd,
       o.org_alias_type_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].ext_alias_type_cd, o
       .alias = hold->qual[d.seq].ext_alias, o.alias_key = cnvtupper(hold->qual[d.seq].ext_alias),
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), o.data_status_cd = auth_data_status_cd,
       o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o
       .contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd
      PLAN (d
       WHERE (hold->qual[d.seq].ext_alias_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ORG_ALIAS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG_ALIAS :: Insert Error :: ",trim(serrmsg
        ))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle ALT ORG Aliases")
     CALL echo("***")
     CALL echo("***")
     CALL echo("***   Add New ALT_ALIAS1")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = hold->qual[d
       .seq].organization_id, o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.alias_pool_cd = alt_rec->qual[hold->
       qual[d.seq].alt1_idx].alt_alias_pool_cd,
       o.org_alias_type_cd = alt_rec->qual[hold->qual[d.seq].alt1_idx].alt_alias_type_cd, o.alias =
       hold->qual[d.seq].alt_alias1, o.alias_key = cnvtupper(hold->qual[d.seq].alt_alias1),
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), o.data_status_cd = auth_data_status_cd,
       o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o
       .contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd
      PLAN (d
       WHERE (hold->qual[d.seq].alt_alias1_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt1_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ALT_ALIAS1"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ALT_ALIAS1 :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Add New ALT_ALIAS2")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = hold->qual[d
       .seq].organization_id, o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.alias_pool_cd = alt_rec->qual[hold->
       qual[d.seq].alt2_idx].alt_alias_pool_cd,
       o.org_alias_type_cd = alt_rec->qual[hold->qual[d.seq].alt2_idx].alt_alias_type_cd, o.alias =
       hold->qual[d.seq].alt_alias2, o.alias_key = cnvtupper(hold->qual[d.seq].alt_alias2),
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), o.data_status_cd = auth_data_status_cd,
       o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o
       .contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd
      PLAN (d
       WHERE (hold->qual[d.seq].alt_alias2_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt2_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ALT_ALIAS2"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ALT_ALIAS2 :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Add New ALT_ALIAS3")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM organization_alias o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_alias_id = seq(organization_seq,nextval), o.organization_id = hold->qual[d
       .seq].organization_id, o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.alias_pool_cd = alt_rec->qual[hold->
       qual[d.seq].alt3_idx].alt_alias_pool_cd,
       o.org_alias_type_cd = alt_rec->qual[hold->qual[d.seq].alt3_idx].alt_alias_type_cd, o.alias =
       hold->qual[d.seq].alt_alias3, o.alias_key = cnvtupper(hold->qual[d.seq].alt_alias3),
       o.check_digit = 0, o.check_digit_method_cd = 0, o.beg_effective_dt_tm = cnvtdatetime(dates->
        now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm), o.data_status_cd = auth_data_status_cd,
       o.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm),
       o.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o
       .contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd
      PLAN (d
       WHERE (hold->qual[d.seq].alt_alias3_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].alt3_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ALT_ALIAS3"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ALT_ALIAS3 :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Addresses")
     CALL echo("***")
     CALL echo("***")
     CALL echo("***   Add New Address")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM address a,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET a.address_id = seq(address_seq,nextval), a.parent_entity_name = "ORGANIZATION", a
       .parent_entity_id = hold->qual[d.seq].organization_id,
       a.address_type_cd = work_addr_type_cd, a.address_format_cd = 0, a.contact_name = "",
       a.residence_type_cd = 0, a.comment_txt = "", a.street_addr = hold->qual[d.seq].street_addr,
       a.street_addr2 = hold->qual[d.seq].street_addr2, a.street_addr3 = hold->qual[d.seq].
       street_addr3, a.street_addr4 = hold->qual[d.seq].street_addr4,
       a.city = hold->qual[d.seq].city, a.state = hold->qual[d.seq].state, a.state_cd = hold->qual[d
       .seq].state_cd,
       a.zipcode = hold->qual[d.seq].zipcode, a.zip_code_group_cd = 0, a.postal_barcode_info = "",
       a.county = hold->qual[d.seq].county, a.county_cd = hold->qual[d.seq].county_cd, a.country =
       hold->qual[d.seq].country,
       a.country_cd = hold->qual[d.seq].country_cd, a.residence_cd = 0, a.mail_stop = "",
       a.address_type_seq = 0, a.beg_effective_mm_dd = 0, a.end_effective_mm_dd = 0,
       a.contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd, a.data_status_cd = auth_data_status_cd, a.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       a.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, a
       .beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), a.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       a.active_ind = 1, a.active_status_cd = active_active_status_cd, a.active_status_prsnl_id =
       contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       a.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_cnt = 0, a.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       a.updt_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, a.updt_applctx
        = 4249900, a.updt_task = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].address_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].address_id < 1)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].address_action_flag=0))
       JOIN (a)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ADDRESS"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ADDRESS :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     IF (working_mode != 2)
      CALL echo("***")
      CALL echo("***   Update Address")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      UPDATE  FROM address a,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET a.address_format_cd = 0, a.contact_name = "", a.residence_type_cd = 0,
        a.comment_txt = "", a.street_addr = hold->qual[d.seq].street_addr, a.street_addr2 = hold->
        qual[d.seq].street_addr2,
        a.street_addr3 = hold->qual[d.seq].street_addr3, a.street_addr4 = hold->qual[d.seq].
        street_addr4, a.city = hold->qual[d.seq].city,
        a.state = hold->qual[d.seq].state, a.state_cd = hold->qual[d.seq].state_cd, a.zipcode = hold
        ->qual[d.seq].zipcode,
        a.zip_code_group_cd = 0, a.postal_barcode_info = "", a.county = hold->qual[d.seq].county,
        a.county_cd = hold->qual[d.seq].county_cd, a.country = hold->qual[d.seq].country, a
        .country_cd = hold->qual[d.seq].country_cd,
        a.residence_cd = 0, a.mail_stop = "", a.address_type_seq = 0,
        a.updt_cnt = (a.updt_cnt+ 1), a.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), a.updt_id =
        contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id,
        a.updt_applctx = 4249900, a.updt_task = 4249900
       PLAN (d
        WHERE (hold->qual[d.seq].address_exists_ind=1)
         AND (hold->qual[d.seq].address_id > 0.0)
         AND (hold->qual[d.seq].organization_id > 0.0)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].address_action_flag=0))
        JOIN (a
        WHERE (a.address_id=hold->qual[d.seq].address_id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = update_error
       SET table_name = "UPDATE ADDRESS"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("UPDATE ADDRESS :: Update Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     IF (found_address_delete=true)
      CALL echo("***")
      CALL echo("***   Delete Address")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM address a,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET a.seq = 1
       PLAN (d
        WHERE (hold->qual[d.seq].address_exists_ind=1)
         AND (hold->qual[d.seq].address_id > 0.0)
         AND (hold->qual[d.seq].organization_id > 0.0)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].address_action_flag=1))
        JOIN (a
        WHERE (a.address_id=hold->qual[d.seq].address_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = delete_error
       SET table_name = "DELETE ADDRESS"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("DELETE ADDRESS :: Delete Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Phone")
     CALL echo("***")
     CALL echo("***")
     CALL echo("***   Add New Phone")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM phone p,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET p.phone_id = seq(phone_seq,nextval), p.parent_entity_name = "ORGANIZATION", p
       .parent_entity_id = hold->qual[d.seq].organization_id,
       p.phone_type_cd = work_phone_type_cd, p.phone_format_cd = 0, p.phone_num = hold->qual[d.seq].
       phone_num,
       p.phone_type_seq = 1, p.description = "", p.contact = "",
       p.call_instruction = "", p.modem_capability_cd = 0, p.extension = "",
       p.paging_code = "", p.beg_effective_mm_dd = 0, p.end_effective_mm_dd = 0,
       p.contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd, p.data_status_cd = auth_data_status_cd, p.data_status_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, p
       .beg_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), p.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       p.active_ind = 1, p.active_status_cd = active_active_status_cd, p.active_status_prsnl_id =
       contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id,
       p.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_cnt = 0, p.updt_dt_tm =
       cnvtdatetime(dates->now_dt_tm),
       p.updt_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, p.updt_applctx
        = 4249900, p.updt_task = 4249900
      PLAN (d
       WHERE (hold->qual[d.seq].phone_exists_ind=0)
        AND (hold->qual[d.seq].phone_id < 1)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0)
        AND (hold->qual[d.seq].phone_action_flag=0))
       JOIN (p)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW PHONE"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW PHONE :: Insert Error :: ",trim(serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     IF (working_mode != 2)
      CALL echo("***")
      CALL echo("***   Update Phone")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      UPDATE  FROM phone p,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET p.phone_format_cd = 0, p.phone_num = hold->qual[d.seq].phone_num, p.phone_type_seq = 1,
        p.description = "", p.contact = "", p.call_instruction = "",
        p.modem_capability_cd = 0, p.extension = "", p.paging_code = "",
        p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), p.updt_id =
        contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id,
        p.updt_applctx = 4249900, p.updt_task = 4249900
       PLAN (d
        WHERE (hold->qual[d.seq].phone_exists_ind=1)
         AND (hold->qual[d.seq].phone_id > 0)
         AND (hold->qual[d.seq].organization_id > 0.0)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].phone_action_flag=0))
        JOIN (p
        WHERE (p.phone_id=hold->qual[d.seq].phone_id))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = update_error
       SET table_name = "UPDATE PHONE"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("UPDATE PHONE :: Update Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     IF (found_phone_delete=true)
      CALL echo("***")
      CALL echo("***   Delete Phone")
      CALL echo("***")
      SET ierrcode = error(serrmsg,1)
      SET ierrcode = 0
      DELETE  FROM phone p,
        (dummyt d  WITH seq = value(hold->qual_knt))
       SET p.seq = 1
       PLAN (d
        WHERE (hold->qual[d.seq].phone_exists_ind=1)
         AND (hold->qual[d.seq].phone_id > 0)
         AND (hold->qual[d.seq].organization_id > 0.0)
         AND (hold->qual[d.seq].contrib_idx > 0)
         AND (hold->qual[d.seq].phone_action_flag=1))
        JOIN (p
        WHERE (p.phone_id=hold->qual[d.seq].phone_id))
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       ROLLBACK
       SET failed = delete_error
       SET table_name = "DELETE PHONE"
       SET ilog_status = 1
       SET log->qual_knt = (log->qual_knt+ 1)
       SET stat = alterlist(log->qual,log->qual_knt)
       SET log->qual[log->qual_knt].smsgtype = "ERROR"
       SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
       SET log->qual[log->qual_knt].smsg = concat("DELETE PHONE :: Delete Error :: ",trim(serrmsg))
       SET serrmsg = log->qual[log->qual_knt].smsg
       GO TO exit_script
      ENDIF
     ENDIF
     CALL echo("***")
     CALL echo("***   Add ORG_TYPE_RELTN Client")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_id = hold->qual[d.seq].organization_id, o.org_type_cd = client_org_type_cd,
       o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
      PLAN (d
       WHERE (hold->qual[d.seq].org_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ORG_TYPE_RELTN"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG_TYPE_RELTN :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Add ORG_TYPE_RELTN Facility")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM org_type_reltn o,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET o.organization_id = hold->qual[d.seq].organization_id, o.org_type_cd = facility_org_type_cd,
       o.updt_cnt = 0,
       o.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), o.updt_id = contrib_rec->list[hold->qual[d.seq]
       .contrib_idx].prsnl_person_id, o.updt_task = 4249900,
       o.updt_applctx = 4249900, o.active_ind = 1, o.active_status_cd = active_active_status_cd,
       o.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), o.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, o.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       o.end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm)
      PLAN (d
       WHERE (hold->qual[d.seq].org_exists_ind=0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (o)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW ORG_TYPE_RELTN 2"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW ORG_TYPE_RELTN 2 :: Insert Error :: ",trim(
        serrmsg))
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
     CALL echo("***")
     CALL echo("***   Handle Locations")
     CALL echo("***")
    ENDIF
    CALL echo("***")
    CALL echo("***   Add New Location Code Value")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    INSERT  FROM code_value c,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET c.code_value = hold->qual[d.seq].location_cd, c.code_set = 220, c.cdf_meaning = "FACILITY",
      c.display = trim(substring(1,40,hold->qual[d.seq].name)), c.display_key = trim(cnvtupper(
        cnvtalphanum(trim(substring(1,40,hold->qual[d.seq].name))))), c.description = trim(substring(
        1,60,hold->qual[d.seq].name)),
      c.definition = "", c.collation_seq = 0, c.active_type_cd = active_active_status_cd,
      c.active_ind = 1, c.active_dt_tm = cnvtdatetime(dates->now_dt_tm), c.inactive_dt_tm = null,
      c.active_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, c
      .updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm),
      c.updt_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, c.updt_task =
      4249900, c.updt_applctx = 4249900,
      c.active_ind = 1, c.begin_effective_dt_tm = cnvtdatetime(dates->now_dt_tm), c
      .end_effective_dt_tm = cnvtdatetime(dates->end_dt_tm),
      c.data_status_cd = auth_data_status_cd, c.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), c
      .data_status_prsnl_id = contrib_rec->list[hold->qual[d.seq].contrib_idx].prsnl_person_id
     PLAN (d
      WHERE (hold->qual[d.seq].loc_cd_exists_ind=0)
       AND (hold->qual[d.seq].location_cd > 0.0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (c)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = insert_error
     SET table_name = "ADD NEW LOCATION CODE_VALUE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION CODE_VALUE:: Insert Error :: ",trim
      (serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Add New Location Alias")
    CALL echo("***")
    CALL echo(build("***   hold->qual_knt :",hold->qual_knt))
    CALL echo(build("***   size(hold->qual,5) :",size(hold->qual,5)))
    CALL echo("***")
    SET beg_seq = 1
    SET max_seq = hold->qual_knt
    SET end_seq = 0
    SET end_seq = ((max_seq - beg_seq)/ 2)
    SET continue = true
    IF ((hold->qual_knt > 0))
     FOR (fdx = 1 TO hold->qual_knt)
      IF ((hold->qual[fdx].loc_cva_ext_exist_ind=0)
       AND (hold->qual[fdx].location_cd > 0.0)
       AND (hold->qual[fdx].contrib_idx > 0))
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       INSERT  FROM code_value_alias c
        SET c.alias = concat(trim(hold->qual[fdx].ext_alias),trim(contrib_rec->list[hold->qual[fdx].
           contrib_idx].loc_cva_alias_stamp),"~",trim(cnvtstring(hold->qual[fdx].ags_org_data_id))),
         c.alias_type_meaning = "ORGEXTALIAS", c.code_set = 220,
         c.code_value = hold->qual[fdx].location_cd, c.contributor_source_cd = contrib_rec->list[hold
         ->qual[fdx].contrib_idx].contributor_source_cd, c.primary_ind = 0,
         c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), c.updt_id = contrib_rec->
         list[hold->qual[fdx].contrib_idx].prsnl_person_id,
         c.updt_task = 4249900, c.updt_applctx = 4249900
        PLAN (c
         WHERE 0=0)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        ROLLBACK
        SET failed = insert_error
        SET table_name = "ADD NEW LOCATION ALIAS"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION ALIAS :: Insert Error :: ",trim(
          serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
      ENDIF
      IF ((alt_rec->qual_knt > 0))
       IF ((hold->qual[fdx].loc_cva_alt1_exist_ind=0)
        AND (hold->qual[fdx].location_cd > 0.0)
        AND (hold->qual[fdx].contrib_idx > 0)
        AND (hold->qual[fdx].alt1_idx > 0))
        CALL echo("***")
        CALL echo("***   Add New Location ALT1 Alias")
        CALL echo("***")
        SET beg_seq = 1
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM code_value_alias c
         SET c.alias = concat(trim(hold->qual[fdx].alt_alias1),trim(alt_rec->qual[hold->qual[fdx].
            alt1_idx].loc_cva_alias_stamp),"~",trim(cnvtstring(hold->qual[fdx].ags_org_data_id))), c
          .alias_type_meaning = "ORGALTALIAS", c.code_set = 220,
          c.code_value = hold->qual[fdx].location_cd, c.contributor_source_cd = contrib_rec->list[
          hold->qual[fdx].contrib_idx].contributor_source_cd, c.primary_ind = 0,
          c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), c.updt_id = contrib_rec->
          list[hold->qual[fdx].contrib_idx].prsnl_person_id,
          c.updt_task = 4249900, c.updt_applctx = 4249900
         PLAN (c
          WHERE 0=0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         ROLLBACK
         SET failed = insert_error
         SET table_name = "ADD NEW LOCATION ALT1 ALIAS"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION ALT1 ALIAS :: Insert Error :: ",
          trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((hold->qual[fdx].loc_cva_alt2_exist_ind=0)
        AND (hold->qual[fdx].location_cd > 0.0)
        AND (hold->qual[fdx].contrib_idx > 0)
        AND (hold->qual[fdx].alt2_idx > 0))
        CALL echo("***")
        CALL echo("***   Add New Location ALT2 Alias")
        CALL echo("***")
        SET beg_seq = 1
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM code_value_alias c
         SET c.alias = concat(trim(hold->qual[fdx].alt_alias2),trim(alt_rec->qual[hold->qual[fdx].
            alt2_idx].loc_cva_alias_stamp),"~",trim(cnvtstring(hold->qual[fdx].ags_org_data_id))), c
          .alias_type_meaning = "ORGALTALIAS", c.code_set = 220,
          c.code_value = hold->qual[fdx].location_cd, c.contributor_source_cd = contrib_rec->list[
          hold->qual[fdx].contrib_idx].contributor_source_cd, c.primary_ind = 0,
          c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), c.updt_id = contrib_rec->
          list[hold->qual[fdx].contrib_idx].prsnl_person_id,
          c.updt_task = 4249900, c.updt_applctx = 4249900
         PLAN (c
          WHERE 0=0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         ROLLBACK
         SET failed = insert_error
         SET table_name = "ADD NEW LOCATION ALT2 ALIAS"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION ALT2 ALIAS :: Insert Error :: ",
          trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
       ENDIF
       IF ((hold->qual[fdx].loc_cva_alt3_exist_ind=0)
        AND (hold->qual[fdx].location_cd > 0.0)
        AND (hold->qual[fdx].contrib_idx > 0)
        AND (hold->qual[fdx].alt3_idx > 0))
        CALL echo("***")
        CALL echo("***   Add New Location ALT3 Alias")
        CALL echo("***")
        SET beg_seq = 1
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM code_value_alias c
         SET c.alias = concat(trim(hold->qual[fdx].alt_alias3),trim(alt_rec->qual[hold->qual[fdx].
            alt3_idx].loc_cva_alias_stamp),"~",trim(cnvtstring(hold->qual[fdx].ags_org_data_id))), c
          .alias_type_meaning = "ORGALTALIAS", c.code_set = 220,
          c.code_value = hold->qual[fdx].location_cd, c.contributor_source_cd = contrib_rec->list[
          hold->qual[fdx].contrib_idx].contributor_source_cd, c.primary_ind = 0,
          c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), c.updt_id = contrib_rec->
          list[hold->qual[fdx].contrib_idx].prsnl_person_id,
          c.updt_task = 4249900, c.updt_applctx = 4249900
         PLAN (c
          WHERE 0=0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         ROLLBACK
         SET failed = insert_error
         SET table_name = "ADD NEW LOCATION ALT3 ALIAS"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION ALT3 ALIAS :: Insert Error :: ",
          trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     CALL echo("***")
     CALL echo("***  qual_knt !> 0")
     CALL echo("***")
    ENDIF
    IF (create_orgs=true)
     CALL echo("***")
     CALL echo("***   Add New Location")
     CALL echo("***")
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     INSERT  FROM location l,
       (dummyt d  WITH seq = value(hold->qual_knt))
      SET l.location_cd = hold->qual[d.seq].location_cd, l.location_type_cd = facility_loc_type_cd, l
       .organization_id = hold->qual[d.seq].organization_id,
       l.resource_ind = 0, l.active_ind = 1, l.active_status_cd = active_active_status_cd,
       l.active_status_dt_tm = cnvtdatetime(dates->now_dt_tm), l.active_status_prsnl_id = contrib_rec
       ->list[hold->qual[d.seq].contrib_idx].prsnl_person_id, l.beg_effective_dt_tm = cnvtdatetime(
        dates->now_dt_tm),
       l.census_ind = 0, l.contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
       contributor_system_cd, l.data_status_cd = auth_data_status_cd,
       l.data_status_dt_tm = cnvtdatetime(dates->now_dt_tm), l.data_status_prsnl_id = contrib_rec->
       list[hold->qual[d.seq].contrib_idx].prsnl_person_id, l.end_effective_dt_tm = cnvtdatetime(
        dates->end_dt_tm),
       l.updt_cnt = 0, l.updt_dt_tm = cnvtdatetime(dates->now_dt_tm), l.updt_id = contrib_rec->list[
       hold->qual[d.seq].contrib_idx].prsnl_person_id,
       l.updt_task = 4249900, l.updt_applctx = 4249900, l.facility_accn_prefix_cd = 0,
       l.discipline_type_cd = 0, l.view_type_cd = 0, l.patcare_node_ind = 1,
       l.exp_lvl_cd = 0, l.chart_format_id = 0
      PLAN (d
       WHERE (hold->qual[d.seq].location_cd > 0.0)
        AND (hold->qual[d.seq].organization_id > 0.0)
        AND (hold->qual[d.seq].loc_exists_ind=0)
        AND (hold->qual[d.seq].add_location_table_ind=true)
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (l)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      ROLLBACK
      SET failed = insert_error
      SET table_name = "ADD NEW LOCATION"
      SET ilog_status = 1
      SET log->qual_knt = (log->qual_knt+ 1)
      SET stat = alterlist(log->qual,log->qual_knt)
      SET log->qual[log->qual_knt].smsgtype = "ERROR"
      SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
      SET log->qual[log->qual_knt].smsg = concat("ADD NEW LOCATION :: Insert Error :: ",trim(serrmsg)
       )
      SET serrmsg = log->qual[log->qual_knt].smsg
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***   Update Data to Complete")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_org_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.organization_id = hold->qual[d.seq].organization_id, o.location_cd = hold->qual[d.seq].
      location_cd, o.contributor_system_cd = contrib_rec->list[hold->qual[d.seq].contrib_idx].
      contributor_system_cd
     PLAN (d
      WHERE (hold->qual[d.seq].ags_org_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (o
      WHERE (o.ags_org_data_id=hold->qual[d.seq].ags_org_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE ORG_DATA COMPLETE"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG_DATA COMPLETE :: Update Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
    CALL echo("***")
    CALL echo("***   Update ORG Data to IN ERROR")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_org_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "IN ERROR", o.status_dt_tm = cnvtdatetime(curdate,curtime3), o.stat_msg = trim(
       substring(1,40,hold->qual[d.seq].stat_msg))
     PLAN (d
      WHERE (hold->qual[d.seq].contrib_idx < 1))
      JOIN (o
      WHERE (o.ags_org_data_id=hold->qual[d.seq].ags_org_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = update_error
     SET table_name = "UPDATE ORG_DATA IN ERROR"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE ORG_DATA IN ERROR :: Update Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
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
   IF (it_avg > 0)
    SET dates->it_est_end_dt_tm = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((max_data_id -
         end_data_id)+ 1))/ it_avg))),",S"),dates->it_end_dt_tm)
   ENDIF
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
     DECLARE sender = vc WITH public, noconstant("sf3151")
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
 SET log->qual[log->qual_knt].smsg = "END >> AGS_ORG_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL echo("***")
  CALL echo("***   END LOGGING")
  CALL echo("***")
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("***")
 CALL echo("***   END AGS_ORG_LOAD")
 CALL echo("***")
 SET script_ver = "009 09/08/06"
END GO
