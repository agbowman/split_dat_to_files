CREATE PROGRAM bhs_break_sched_lock:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel Last Name or EN#" = "",
  "Personnel" = 0,
  "Scheduling Locks" = 0,
  "Check Unlock History" = 0,
  "Date Range" = "SYSDATE",
  "to" = "SYSDATE"
  WITH outdev, s_prsnl_user, f_prsnl_id,
  f_sched_lock_id, n_hist_ind, s_start_dt,
  s_end_dt
 DECLARE mf_inactive_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"INACTIVE"))
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (( $F_SCHED_LOCK_ID=null)
  AND ( $N_HIST_IND=0))
  SET ms_error = "Invalid parameters."
  GO TO exit_program
 ENDIF
 IF (( $N_HIST_IND=0))
  UPDATE  FROM sch_lock sl
   SET sl.active_ind = 0, sl.status_flag = 4, sl.status_meaning = "RELEASED",
    sl.active_status_cd = mf_inactive_cd, sl.active_status_dt_tm = cnvtdatetime(curdate,curtime3), sl
    .active_status_prsnl_id = reqinfo->updt_id,
    sl.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), sl.release_dt_tm = cnvtdatetime(curdate,
     curtime3), sl.release_prsnl_id = reqinfo->updt_id,
    sl.updt_cnt = (sl.updt_cnt+ 1), sl.updt_dt_tm = cnvtdatetime(curdate,curtime3), sl.updt_id =
    reqinfo->updt_id
   WHERE (sl.sch_lock_id= $F_SCHED_LOCK_ID)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET ms_error = "Error inactivating lock."
   GO TO exit_program
  ENDIF
  COMMIT
  SELECT DISTINCT INTO value( $OUTDEV)
   executed =
   IF ((sl.sch_lock_id= $F_SCHED_LOCK_ID)) "*** X ***"
   ENDIF
   , sched_lock_id = sl.sch_lock_id, unlock_by = p2.name_full_formatted,
   unlock_time = sl.release_dt_tm"@SHORTDATETIME", appt_location = uar_get_code_display(sa
    .appt_location_cd), resource = uar_get_code_display(sa.resource_cd),
   appt_type = se.appt_synonym_free, locked_by = p1.name_full_formatted, lock_time = sl.granted_dt_tm
   "@SHORTDATETIME"
   FROM sch_lock sl,
    sch_event se,
    sch_appt sa,
    sch_booking sb,
    prsnl p1,
    prsnl p2
   PLAN (sl
    WHERE (sl.release_prsnl_id=reqinfo->updt_id)
     AND sl.parent_table="SCH_EVENT"
     AND sl.status_flag=4
     AND sl.status_meaning="RELEASED")
    JOIN (se
    WHERE se.sch_event_id=sl.parent_id)
    JOIN (sa
    WHERE sa.sch_event_id=se.sch_event_id
     AND sa.resource_cd > 0)
    JOIN (sb
    WHERE sb.booking_id=sa.booking_id)
    JOIN (p1
    WHERE p1.person_id=sl.granted_prsnl_id)
    JOIN (p2
    WHERE p2.person_id=sl.release_prsnl_id)
   ORDER BY sl.release_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ELSE
  SELECT DISTINCT INTO value( $OUTDEV)
   sched_lock_id = sl.sch_lock_id, unlock_by = p2.name_full_formatted, unlock_user = p2.username,
   unlock_time = sl.release_dt_tm"@SHORTDATETIME", appt_location = uar_get_code_display(sa
    .appt_location_cd), resource = uar_get_code_display(sa.resource_cd),
   appt_type = se.appt_synonym_free, locked_by = p1.name_full_formatted, lock_time = sl.granted_dt_tm
   "@SHORTDATETIME"
   FROM sch_lock sl,
    sch_event se,
    sch_appt sa,
    sch_booking sb,
    prsnl p1,
    prsnl p2
   PLAN (sl
    WHERE sl.release_dt_tm BETWEEN cnvtdatetime( $S_START_DT) AND cnvtdatetime( $S_END_DT)
     AND sl.status_flag=4
     AND sl.status_meaning="RELEASED"
     AND sl.parent_table="SCH_EVENT")
    JOIN (se
    WHERE se.sch_event_id=sl.parent_id)
    JOIN (sa
    WHERE sa.sch_event_id=se.sch_event_id
     AND sa.resource_cd > 0)
    JOIN (sb
    WHERE sb.booking_id=sa.booking_id)
    JOIN (p1
    WHERE p1.person_id=sl.granted_prsnl_id)
    JOIN (p2
    WHERE p2.person_id=sl.release_prsnl_id)
   ORDER BY sl.release_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
  IF (curqual=0)
   SET ms_error = "There is no history for the provided date range."
   GO TO exit_program
  ENDIF
 ENDIF
#exit_program
 IF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
