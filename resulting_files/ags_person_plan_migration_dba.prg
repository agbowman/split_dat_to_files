CREATE PROGRAM ags_person_plan_migration:dba
 PROMPT
  "LOGGING_IND (0-OFF,1-ON) = " = 0
  WITH logging_ind
 SET ags_person_plan_migration_mod = "001 11/02/06"
 CALL echo("<===== AGS_PERSON_PLAN_MIGRATION Begin =====>")
 CALL echo(concat("MOD:",ags_person_plan_migration_mod))
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 FREE RECORD holdrec
 RECORD holdrec(
   1 ags_job_id = f8
   1 ags_task_id = f8
   1 qual_cnt = i4
   1 qual[*]
     2 valid_person_id = i4
     2 ags_plan_data_id = f8
     2 birth_date = vc
     2 contributor_system_cd = f8
     2 elig_start_date = vc
     2 elig_end_date = vc
     2 ext_alias = vc
     2 file_row_nbr = i4
     2 gender = vc
     2 health_plan_id = f8
     2 name_first = vc
     2 name_last = vc
     2 person_id = f8
     2 person_rx_plan_reltn_id = f8
     2 plan_alias = vc
     2 plan_type = vc
     2 run_dt_tm = dq8
     2 run_nbr = i4
     2 sending_facility = vc
     2 ssn_alias = vc
     2 status = c10
     2 stat_msg = c40
 )
 FREE RECORD jobrec
 RECORD jobrec(
   1 qual_cnt = i4
   1 qual[*]
     2 sending_system = vc
     2 qual2_cnt = i4
     2 qual2[*]
       3 ags_job_id = f8
 )
 IF ((validate(failed,- (1))=- (1)))
  EXECUTE cclseclogin2
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  FREE RECORD log
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  SET define_logging_sub = true
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
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_person_plan_migration_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 DECLARE blogging = i4 WITH public, noconstant(cnvtint( $LOGGING_IND))
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lcount = i4 WITH public, noconstant(0)
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime2))
 DECLARE lminagspersondataid = f8 WITH public, noconstant(0.0)
 DECLARE lmaxagspersondataid = f8 WITH public, noconstant(0.0)
 IF (blogging > 0)
  CALL turn_on_tracing(null)
 ELSE
  CALL turn_off_tracing(null)
 ENDIF
 CALL echo("***")
 CALL echo("***   Select PERSON jobs to migrate")
 CALL echo("***")
 SELECT INTO "nl;"
  FROM ags_job j
  WHERE j.file_type="PERSON"
   AND  NOT (j.status IN ("IN ERROR", "BACK OUT", "PURGED"))
  ORDER BY j.run_nbr
  DETAIL
   lnum = 0, lpos = 0, lpos = locateval(lnum,1,jobrec->qual_cnt,j.sending_system,jobrec->qual[lnum].
    sending_system)
   IF (lpos <= 0)
    lidx = (jobrec->qual_cnt+ 1), jobrec->qual_cnt = lidx, stat = alterlist(jobrec->qual,lidx),
    jobrec->qual[lidx].sending_system = j.sending_system
   ELSE
    lidx = lpos
   ENDIF
   lidx2 = (jobrec->qual[lidx].qual2_cnt+ 1), jobrec->qual[lidx].qual2_cnt = lidx2, stat = alterlist(
    jobrec->qual[lidx].qual2,lidx2),
   jobrec->qual[lidx].qual2[lidx2].ags_job_id = j.ags_job_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_JOB"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ((jobrec->qual_cnt <= 0))
  SET table_name = "AGS_JOB"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "Msg :: No PERSON jobs qualified for migration!!"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echorecord(jobrec)
 CALL echo("***")
 CALL echo("***   Clean PERSON jobs before migrating")
 CALL echo("***")
 FOR (lidx = 1 TO jobrec->qual_cnt)
   FOR (lidx2 = 1 TO jobrec->qual[lidx].qual2_cnt)
    CALL echo(concat("execute AGS_PERSON_CLEAN value(",trim(cnvtstring(jobrec->qual[lidx].qual2[lidx2
        ].ags_job_id)),")"))
    EXECUTE ags_person_clean value(jobrec->qual[lidx].qual2[lidx2].ags_job_id)
   ENDFOR
 ENDFOR
 CALL echo("***")
 CALL echo("***   Create Job/Task rows")
 CALL echo("***")
 FOR (lidx = 1 TO jobrec->qual_cnt)
   CALL echo(build("sending_system:",jobrec->qual[lidx].sending_system))
   SET stat = initrec(holdrec)
   SELECT INTO "nl:"
    FROM ags_job j
    WHERE (j.sending_system=jobrec->qual[lidx].sending_system)
     AND j.filename="PLAN MIGRATION"
     AND j.file_type="PLAN"
     AND j.check_date="19000101"
     AND j.run_nbr=19000101
    DETAIL
     holdrec->ags_job_id = j.ags_job_id
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_JOB"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF ((holdrec->ags_job_id <= 0))
    CALL echo("Create AGS_JOB_ID")
    SELECT INTO "nl:"
     y = seq(gs_seq,nextval)
     FROM dual
     DETAIL
      holdrec->ags_job_id = cnvtreal(y)
     WITH format, nocounter
    ;end select
    CALL echo("***")
    CALL echo("***   Insert AGS_JOB row")
    CALL echo("***")
    INSERT  FROM ags_job j
     SET j.ags_job_id = holdrec->ags_job_id, j.sending_system = jobrec->qual[lidx].sending_system, j
      .filename = "PLAN MIGRATION",
      j.check_date = "19000101", j.file_type = "PLAN", j.run_dt_tm = cnvtdatetime(dtcurrent),
      j.run_nbr = 19000101, j.status = "WAITING", j.status_dt_tm = cnvtdatetime(dtcurrent)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = insert_error
     SET table_name = "AGS_JOB"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT AGS_JOB ITEMS :: Insert Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo(build("Existing AGS_JOB_ID:",holdrec->ags_job_id))
    CALL echo("***")
    CALL echo("***   Check for existing AGS_TASK row")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM ags_task t
     WHERE (t.ags_job_id=holdrec->ags_job_id)
     DETAIL
      holdrec->ags_task_id = t.ags_task_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = select_error
     SET table_name = "AGS_TASK"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SELECT AGS_TASK ITEMS :: Select Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((holdrec->ags_task_id <= 0))
    CALL echo("Create AGS_TASK_ID")
    CALL echo("***")
    CALL echo("***   Get Batch properties")
    CALL echo("***")
    SELECT INTO "nl:"
     min_id = min(p.ags_person_data_id), max_id = max(p.ags_person_data_id)
     FROM ags_person_data p
     WHERE expand(lnum,1,jobrec->qual[lidx].qual2_cnt,p.ags_job_id,jobrec->qual[lidx].qual2[lnum].
      ags_job_id)
      AND trim(p.status)="COMPLETE"
     HEAD REPORT
      lminagspersondataid = 0, lmaxagspersondataid = 0
     FOOT REPORT
      lminagspersondataid = min_id, lmaxagspersondataid = max_id
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = select_error
     SET table_name = "AGS_PERSON_DATA"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("SELECT AGS_PERSON_DATA ITEMS :: Select Error :: ",
      trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    CALL echo(build("lMinAgsPersonDataId: ",lminagspersondataid))
    CALL echo(build("lMaxAgsPersonDataId: ",lmaxagspersondataid))
    CALL echo("***")
    CALL echo("***   Insert AGS_TASK row")
    CALL echo("***")
    SELECT INTO "nl:"
     y = seq(gs_seq,nextval)
     FROM dual
     DETAIL
      holdrec->ags_task_id = cnvtreal(y)
     WITH format, nocounter
    ;end select
    INSERT  FROM ags_task t
     SET t.ags_task_id = holdrec->ags_task_id, t.ags_job_id = holdrec->ags_job_id, t.task_type =
      "PLAN",
      t.batch_program = "PLAN MIGRATION", t.batch_start_id = lminagspersondataid, t.batch_end_id =
      lmaxagspersondataid,
      t.batch_size = 5000, t.status = "WAITING", t.status_dt_tm = cnvtdatetime(dtcurrent)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     ROLLBACK
     SET failed = insert_error
     SET table_name = "AGS_TASK"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("INSERT AGS_TASK ITEMS :: Insert Error :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo("***")
   CALL echo("***   Select AGS_PERSON_DATA rows to migrate")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM ags_person_data p,
     ags_plan_data pl,
     dummyt d
    PLAN (p
     WHERE expand(lnum,1,jobrec->qual[lidx].qual2_cnt,p.ags_job_id,jobrec->qual[lidx].qual2[lnum].
      ags_job_id)
      AND ((p.person_id+ 0) > 0.0)
      AND trim(p.status)="COMPLETE")
     JOIN (d)
     JOIN (pl
     WHERE pl.ags_plan_data_id=p.ags_person_data_id)
    HEAD REPORT
     lidx2 = 0
    DETAIL
     lidx2 = (lidx2+ 1)
     IF (mod(lidx2,10)=1)
      holdrec->qual_cnt = (lidx2+ 9), stat = alterlist(holdrec->qual,holdrec->qual_cnt)
     ENDIF
     holdrec->qual[lidx2].ags_plan_data_id = p.ags_person_data_id, holdrec->qual[lidx2].birth_date =
     p.birth_date, holdrec->qual[lidx2].contributor_system_cd = p.contributor_system_cd,
     holdrec->qual[lidx2].elig_start_date = p.elig_start_date, holdrec->qual[lidx2].elig_end_date = p
     .elig_end_date, holdrec->qual[lidx2].ext_alias = p.ext_alias,
     holdrec->qual[lidx2].file_row_nbr = p.file_row_nbr, holdrec->qual[lidx2].gender = p.gender,
     holdrec->qual[lidx2].name_first = p.name_first,
     holdrec->qual[lidx2].name_last = p.name_last, holdrec->qual[lidx2].person_id = p.person_id,
     holdrec->qual[lidx2].plan_type = "PRESCRIPTION",
     holdrec->qual[lidx2].run_dt_tm = cnvtdatetime(dtcurrent), holdrec->qual[lidx2].run_nbr =
     19000101, holdrec->qual[lidx2].plan_alias = p.sending_facility,
     holdrec->qual[lidx2].sending_facility = p.sending_facility, holdrec->qual[lidx2].ssn_alias = p
     .ssn_alias
    FOOT REPORT
     holdrec->qual_cnt = lidx2, stat = alterlist(holdrec->qual,holdrec->qual_cnt)
    WITH outerjoin = d, dontexist
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "AGS_PERSON_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   CALL echo("***")
   CALL echo("***   Validate PERSON_IDs")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM person p,
     (dummyt d  WITH seq = value(holdrec->qual_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (p
     WHERE (p.person_id=holdrec->qual[d.seq].person_id))
    HEAD REPORT
     lcount = 0
    DETAIL
     lcount = (lcount+ 1), holdrec->qual[d.seq].valid_person_id = 1
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "PERSON"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   CALL echo("***")
   CALL echo("***   Update AGS_JOB record count")
   CALL echo("***")
   UPDATE  FROM ags_job j
    SET j.record_count = lcount, j.updt_applctx = 424990, j.updt_cnt = (j.updt_cnt+ 1),
     j.updt_dt_tm = cnvtdatetime(dtcurrent), j.updt_task = 424990
    WHERE (j.ags_job_id=holdrec->ags_job_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    ROLLBACK
    SET failed = update_error
    SET table_name = "AGS_JOB"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("INSERT AGS_TASK ITEMS :: Insert Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   CALL echorecord(holdrec)
   CALL echo("***")
   CALL echo("***   Insert AGS_PLAN_DATA rows")
   CALL echo("***")
   INSERT  FROM ags_plan_data p,
     (dummyt d  WITH seq = value(holdrec->qual_cnt))
    SET p.ags_job_id = holdrec->ags_job_id, p.ags_plan_data_id = holdrec->qual[d.seq].
     ags_plan_data_id, p.birth_date = holdrec->qual[d.seq].birth_date,
     p.contributor_system_cd = holdrec->qual[d.seq].contributor_system_cd, p.elig_start_date =
     holdrec->qual[d.seq].elig_start_date, p.elig_end_date = holdrec->qual[d.seq].elig_end_date,
     p.ext_alias = holdrec->qual[d.seq].ext_alias, p.file_row_nbr = holdrec->qual[d.seq].file_row_nbr,
     p.gender = holdrec->qual[d.seq].gender,
     p.name_first = holdrec->qual[d.seq].name_first, p.name_last = holdrec->qual[d.seq].name_last, p
     .person_id = holdrec->qual[d.seq].person_id,
     p.plan_type = holdrec->qual[d.seq].plan_type, p.run_dt_tm = cnvtdatetime(holdrec->qual[d.seq].
      run_dt_tm), p.run_nbr = holdrec->qual[d.seq].run_nbr,
     p.plan_alias = holdrec->qual[d.seq].plan_alias, p.sending_facility = holdrec->qual[d.seq].
     sending_facility, p.ssn_alias = holdrec->qual[d.seq].ssn_alias,
     p.status = "WAITING", p.status_dt_tm = cnvtdatetime(dtcurrent)
    PLAN (d
     WHERE d.seq > 0
      AND (holdrec->qual[d.seq].valid_person_id != 0)
      AND (holdrec->qual[d.seq].ags_plan_data_id > 0.0))
     JOIN (p)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET table_name = "AGS_PLAN_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
 ENDFOR
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
      FOR (exe_idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[exe_idx].smsgtype,"#######")," :: ",
           format(log->qual[exe_idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[
            exe_idx].smsg))))
        IF ((exe_idx=log->qual_knt))
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
        IF ((exe_idx != log->qual_knt))
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
 SUBROUTINE turn_on_tracing(null)
   SET trace = echorecord
   SET trace = rdbprogram
   SET trace = srvuint
   SET trace = cost
   SET trace = callecho
   SET message = information
   SET tracing_on = true
 END ;Subroutine
 SUBROUTINE turn_off_tracing(null)
   SET trace = noechorecord
   SET trace = nordbprogram
   SET trace = nosrvuint
   SET trace = nocost
   SET trace = nocallecho
   SET message = noinformation
   SET tracing_on = false
 END ;Subroutine
#exit_script
 IF (failed != false)
  ROLLBACK
  CALL echorecord(log)
  IF ((holdrec->ags_task_id > 0))
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE (t.ags_task_id=holdrec->ags_task_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Select Error :: ",trim(serrmsg))
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
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PERSON_PLAN_MIGRATION"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 SET script_ver = "001 11/02/06"
 CALL echo(concat("MOD:",ags_person_plan_migration_mod))
 CALL echo("<===== AGS_PERSON_PLAN_MIGRATION End =====>")
END GO
