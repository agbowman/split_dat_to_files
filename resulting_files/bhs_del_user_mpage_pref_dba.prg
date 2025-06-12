CREATE PROGRAM bhs_del_user_mpage_pref:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel Last Name" = "",
  "Personnel" = 0,
  "ViewPoint Preference" = "",
  "View Deletion History" = 0,
  "Date Range" = "SYSDATE",
  "   to" = "SYSDATE"
  WITH outdev, s_prsnl_last_name, f_prsnl_id,
  s_viewpoint_pref, n_hist_ind, s_start_dt,
  s_end_dt
 DECLARE ms_viewpoint = vc WITH protect, constant( $S_VIEWPOINT_PREF)
 DECLARE mf_prsnl_id = f8 WITH protect, constant( $F_PRSNL_ID)
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_del_user = vc WITH protect, noconstant("")
 DECLARE ms_prsnl_user = vc WITH protect, noconstant("")
 DECLARE mf_parent_entity_id = f8 WITH protect, noconstant(0)
 IF (( $F_PRSNL_ID=null)
  AND ( $N_HIST_IND=0))
  SET ms_error = "Invalid parameters."
  GO TO exit_program
 ENDIF
 IF (( $N_HIST_IND=0))
  SELECT INTO "nl:"
   FROM app_prefs a,
    name_value_prefs n
   PLAN (a
    WHERE a.prsnl_id=mf_prsnl_id)
    JOIN (n
    WHERE n.parent_entity_id=a.app_prefs_id
     AND n.parent_entity_name="APP_PREFS"
     AND cnvtupper(n.pvc_name)=ms_viewpoint)
   DETAIL
    mf_parent_entity_id = n.parent_entity_id
   WITH nocounter
  ;end select
  IF (mf_parent_entity_id IN (0.00, null))
   SET ms_error = "mPage Preference Data Not Found."
   GO TO exit_program
  ENDIF
  DELETE  FROM name_value_prefs
   WHERE parent_entity_id=mf_parent_entity_id
    AND parent_entity_name="APP_PREFS"
    AND cnvtupper(pvc_name)=ms_viewpoint
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET ms_error = "Error deleting mpage preference."
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.person_id IN (reqinfo->updt_id, mf_prsnl_id)
   DETAIL
    IF ((reqinfo->updt_id=mf_prsnl_id))
     ms_del_user = p.username, ms_prsnl_user = p.username
    ELSEIF ((p.person_id=reqinfo->updt_id))
     ms_del_user = p.username
    ELSEIF (p.person_id=mf_prsnl_id)
     ms_prsnl_user = p.username
    ENDIF
   WITH nocounter
  ;end select
  INSERT  FROM dm_info di
   SET di.info_domain = "BHS_DEL_USER_MPAGE_PREF", di.info_name = concat(ms_prsnl_user,"|",
     ms_viewpoint," [",trim(format(sysdate,"mmddyyhhmmss;;d")),
     "]"), di.info_char = ms_del_user,
    di.info_domain_id = mf_prsnl_id, di.info_date = cnvtdatetime(curdate,curtime3), di.info_number =
    mf_parent_entity_id,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET ms_error = "Error updating deletion history."
   GO TO exit_program
  ENDIF
  COMMIT
  SELECT INTO value( $OUTDEV)
   program_user = di.info_char, mpage_pref_user = di.info_name, deletion_date = di.updt_dt_tm,
   parent_entity_id = di.info_number, update_prsnl_id = di.updt_id, mpage_pref_prsnl_id = di
   .info_domain_id
   FROM dm_info di
   WHERE di.info_domain="BHS_DEL_USER_MPAGE_PREF"
    AND (di.updt_id=reqinfo->updt_id)
   ORDER BY di.updt_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   program_user = di.info_char, mpage_pref_user = di.info_name, deletion_date = di.updt_dt_tm,
   parent_entity_id = di.info_number, update_prsnl_id = di.updt_id, mpage_pref_prsnl_id = di
   .info_domain_id
   FROM dm_info di
   WHERE di.info_domain="BHS_DEL_USER_MPAGE_PREF"
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
