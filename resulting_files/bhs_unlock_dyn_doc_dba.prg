CREATE PROGRAM bhs_unlock_dyn_doc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient" = 0,
  "Documents" = 0,
  "Check Unlock History" = 0,
  "Date Range" = "SYSDATE",
  "to" = "SYSDATE"
  WITH outdev, f_patient_id, f_session_id,
  n_hist_ind, s_start_dt, s_end_dt
 RECORD data(
   1 f_session_id = f8
   1 f_session_data_id = f8
   1 f_lock_user_id = f8
   1 f_event_id = f8
   1 f_lock_date = f8
   1 s_unlock_user = vc
   1 s_locked_doc = vc
 ) WITH protect
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE ms_error = vc WITH protect, noconstant("")
 IF (( $F_SESSION_ID=null)
  AND ( $N_HIST_IND=0))
  SET ms_error = "Invalid parameters."
  GO TO exit_program
 ENDIF
 IF (( $N_HIST_IND=0))
  SELECT INTO "nl:"
   FROM dd_session ds,
    dd_contribution dc,
    dd_session_data dsd,
    clinical_event ce
   PLAN (ds
    WHERE (ds.dd_session_id= $F_SESSION_ID)
     AND ds.parent_entity_name="DD_CONTRIBUTION"
     AND ds.session_user_id > 0.0)
    JOIN (dc
    WHERE dc.dd_contribution_id=ds.parent_entity_id
     AND (dc.person_id= $F_PATIENT_ID))
    JOIN (dsd
    WHERE ds.dd_session_id=dsd.dd_session_id)
    JOIN (ce
    WHERE ce.event_id=dc.mdoc_event_id
     AND ce.event_class_cd=mf_mdoc_cd
     AND ce.valid_until_dt_tm > sysdate)
   DETAIL
    data->f_session_id = ds.dd_session_id, data->f_session_data_id = dsd.dd_session_data_id, data->
    f_lock_user_id = ds.session_user_id,
    data->f_lock_date = ds.session_dt_tm, data->f_event_id = ce.event_id, data->s_locked_doc =
    substring(1,50,ce.event_title_text)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET ms_error = "Unable to unlock document - session did not qualify."
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    data->s_unlock_user = p.username
   WITH nocounter
  ;end select
  DELETE  FROM dd_session_data
   WHERE (dd_session_data_id=data->f_session_data_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET ms_error = "Error deleting dd_session_data_id."
   GO TO exit_program
  ENDIF
  DELETE  FROM dd_session
   WHERE (dd_session_id=data->f_session_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET ms_error = "Error deleting dd_session_id."
   GO TO exit_program
  ENDIF
  INSERT  FROM dm_info di
   SET di.info_domain = "BHS_DYNAMIC_DOC_UNLOCK", di.info_name = concat(data->s_locked_doc," [",trim(
      format(sysdate,"mmddyyhhmmss;;d")),"]"), di.info_char = data->s_unlock_user,
    di.info_domain_id = data->f_lock_user_id, di.info_date = cnvtdatetime(data->f_lock_date), di
    .info_number = data->f_event_id,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET ms_error = "Error updating unlock history."
   GO TO exit_program
  ENDIF
  COMMIT
  SELECT INTO value( $OUTDEV)
   unlock_user = di.info_char, document_title = di.info_name, unlock_date = format(di.updt_dt_tm,
    "MM/DD/YYYY HH:MM ;;D"),
   lock_date = format(di.info_date,"MM/DD/YYYY HH:MM ;;D"), event_id = di.info_number
   FROM dm_info di
   WHERE di.info_domain="BHS_DYNAMIC_DOC_UNLOCK"
    AND (di.updt_id=reqinfo->updt_id)
   ORDER BY di.updt_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   unlock_user = di.info_char, unlocked_document = di.info_name, lock_date = format(di.info_date,
    "MM/DD/YYYY HH:MM ;;D"),
   locked_person_id = di.info_domain_id, unlock_date = format(di.updt_dt_tm,"MM/DD/YYYY HH:MM ;;D"),
   event_id = di.info_number,
   updt_id = di.updt_id
   FROM dm_info di
   WHERE di.info_domain="BHS_DYNAMIC_DOC_UNLOCK"
    AND di.updt_dt_tm BETWEEN cnvtdatetime( $S_START_DT) AND cnvtdatetime( $S_END_DT)
   ORDER BY di.updt_dt_tm DESC
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
