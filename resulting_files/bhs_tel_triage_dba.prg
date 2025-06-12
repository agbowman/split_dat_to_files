CREATE PROGRAM bhs_tel_triage:dba
 PROMPT
  "" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "User ID:" = "",
  "Provider:" = "",
  "Call Category:" = "",
  "Location:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  s_user, s_provider, s_call_cat,
  s_location
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_activity_recs
 RECORD m_activity_recs(
   1 recs[*]
     2 f_activity_id = f8
     2 f_clin_event_id = f8
 )
 FREE RECORD m_tel
 RECORD m_tel(
   1 forms[*]
     2 f_activity_id = f8
     2 f_dcp_forms_ref_id = f8
     2 s_version_dt_tm = vc
     2 f_encntr_id = f8
     2 s_reference_nbr = vc
     2 s_username = vc
     2 s_userid = vc
     2 s_provider = vc
     2 s_call_cat = vc
     2 f_person_id = f8
     2 s_form_dt_tm = vc
     2 s_activity_dt_tm = vc
     2 n_inerror_ind = f8
     2 n_closed_ind = f8
     2 s_location = vc
     2 f_location_cd = f8
     2 n_provider_filter_ind = i2
     2 n_call_cat_filter_ind = i2
     2 n_location_filter_ind = i2
     2 n_user_filter_ind = i2
 ) WITH protect
 DECLARE mf_provider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PROVIDER"))
 DECLARE mf_call_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CALLCATEGORY"))
 DECLARE mf_closed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MESSAGESTATUSCLOSED"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mn_call_param = i4 WITH protect, constant(6)
 DECLARE mn_loc_param = i4 WITH protect, constant(7)
 DECLARE ms_csv_filename = vc WITH protect, constant(cnvtlower(concat("teltriage_",format(sysdate,
     "dd_mmm_yyyy;;d"),".txt")))
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_user = vc WITH protect, noconstant( $S_USER)
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(format(cnvtdatetime( $S_BEG_DT),
    "dd-mmm-yyyy;;d")," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(format(cnvtdatetime( $S_END_DT),
    "dd-mmm-yyyy;;d")," 23:59:59"))
 DECLARE ms_provider = vc WITH protect, noconstant( $S_PROVIDER)
 DECLARE ms_call_cat = vc WITH protect, noconstant("")
 DECLARE ms_location = vc WITH protect, noconstant(" ")
 DECLARE ms_location_cd = vc WITH protect, noconstant(" ")
 DECLARE ms_loc_list = vc WITH protect, noconstant(" ")
 DECLARE ms_user_str2 = vc WITH protect, noconstant(" 1=1")
 DECLARE ms_provider_str = vc WITH protect, noconstant(" ")
 DECLARE ms_call_cat_str = vc WITH protect, noconstant(" ")
 DECLARE ms_closed_str = vc WITH protect, noconstant(" ")
 DECLARE ms_location_str = vc WITH protect, noconstant(" 1=1")
 DECLARE mn_user_ind = i4 WITH protect, noconstant(0)
 DECLARE mn_provider_ind = i4 WITH protect, noconstant(0)
 DECLARE mn_call_cat_ind = i4 WITH protect, noconstant(0)
 DECLARE mn_location_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_dcp_forms_ref_id = f8 WITH protect, noconstant(0)
 DECLARE mn_ops_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE mn_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_email_list = vc WITH protect, noconstant(" ")
 DECLARE ms_month = vc WITH protect, noconstant(" ")
 DECLARE ms_last_month = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_year = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  CALL echo("from ops")
  SET mn_ops_ind = 1
  SET ms_month = trim(cnvtstring(month(sysdate)))
  SET ms_beg_year = trim(cnvtstring(year(sysdate)))
  CASE (ms_month)
   OF "1":
    SET ms_month = "JAN"
    SET ms_last_month = "DEC"
    SET ms_beg_year = trim(cnvtstring((year(sysdate) - 1)))
   OF "2":
    SET ms_month = "FEB"
    SET ms_last_month = "JAN"
   OF "3":
    SET ms_month = "MAR"
    SET ms_last_month = "FEB"
   OF "4":
    SET ms_month = "APR"
    SET ms_last_month = "MAR"
   OF "5":
    SET ms_month = "MAY"
    SET ms_last_month = "APR"
   OF "6":
    SET ms_month = "JUN"
    SET ms_last_month = "MAY"
   OF "7":
    SET ms_month = "JUL"
    SET ms_last_month = "JUN"
   OF "8":
    SET ms_month = "AUG"
    SET ms_last_month = "JUL"
   OF "9":
    SET ms_month = "SEP"
    SET ms_last_month = "AUG"
   OF "10":
    SET ms_month = "OCT"
    SET ms_last_month = "SEP"
   OF "11":
    SET ms_month = "NOV"
    SET ms_last_month = "OCT"
   OF "12":
    SET ms_month = "DEC"
    SET ms_last_month = "NOV"
  ENDCASE
  SET ms_beg_dt_tm = concat("01-",ms_last_month,"-",trim(cnvtstring(ms_beg_year))," 00:00:00")
  SET ms_end_dt_tm = concat("01-",ms_month,"-",trim(cnvtstring(year(sysdate)))," 00:00:00")
  SET ms_output = ms_csv_filename
 ELSE
  CALL echo("testing")
  CALL echo(concat("dates: ",ms_beg_dt_tm," ",ms_end_dt_tm))
  SET ms_output = ms_csv_filename
 ENDIF
 IF (textlen(trim(ms_user)) > 0)
  SET ms_user_str2 = concat(' pr2.username = "',ms_user,'"')
  SET mn_user_ind = 1
 ENDIF
 IF (textlen(trim(ms_provider)) > 0)
  SET ms_provider_str = concat(" ce1.event_cd +0 = ",trim(cnvtstring(mf_provider_cd)),
   ' and trim(ce1.result_val) = "',ms_provider,'"')
  SET mn_provider_ind = 1
 ELSE
  SET ms_provider_str = concat(" ce1.event_cd +0 = ",trim(cnvtstring(mf_provider_cd)))
 ENDIF
 SET ms_data_type = reflect(parameter(mn_call_param,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_call_cat = parameter(mn_call_param,1)
  IF ( NOT (trim(ms_call_cat) IN (null, "", " ")))
   SET ms_call_cat_str = concat(" ce2.event_cd +0 = ",cnvtstring(mf_call_cat_cd),
    ' and trim(ce2.result_val) = "',ms_call_cat,'"')
   SET mn_call_cat_ind = 1
  ELSE
   SET ms_call_cat_str = concat(" ce2.event_cd +0 = ",trim(cnvtstring(mf_call_cat_cd)))
  ENDIF
 ELSE
  SET ms_call_cat_str = concat(" ce2.event_cd +0 = ",trim(cnvtstring(mf_call_cat_cd)),
   " and trim(ce2.result_val) in (")
  FOR (mn_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_call_cat = parameter(mn_call_param,mn_cnt)
   IF (mn_cnt=1)
    SET ms_call_cat_str = concat(ms_call_cat_str,'"',ms_call_cat,'"')
   ELSE
    SET ms_call_cat_str = concat(ms_call_cat_str,', "',ms_call_cat,'"')
   ENDIF
  ENDFOR
  SET ms_call_cat_str = concat(ms_call_cat_str,")")
  SET mn_call_cat_ind = 1
 ENDIF
 SET ms_closed_str = concat(" ce3.event_cd +0 = ",trim(cnvtstring(mf_closed_cd)))
 SET ms_data_type = reflect(parameter(mn_loc_param,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_location_cd = trim(cnvtstring(parameter(mn_loc_param,1)))
  IF ( NOT (ms_location_cd IN (null, "", " ", "0")))
   SET ms_location_cd = cnvtstring(parameter(mn_loc_param,1))
   SET ms_location_str = concat(" e.location_cd = ",ms_location_cd)
   SET mn_location_ind = 1
   SELECT DISTINCT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=cnvtreal(ms_location_cd)
     AND cv.code_set=220
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= sysdate
     AND cv.end_effective_dt_tm >= sysdate
    DETAIL
     ms_loc_list = trim(cv.display)
    WITH nocounter
   ;end select
  ELSE
   SET ms_location_str = " 1=1"
  ENDIF
 ELSE
  SET ms_location_str = " e.location_cd in ("
  FOR (mn_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
    SET ms_location_cd = cnvtstring(parameter(mn_loc_param,mn_cnt))
    IF (mn_cnt=1)
     SET ms_location_str = concat(ms_location_str,ms_location_cd)
    ELSE
     SET ms_location_str = concat(ms_location_str,", ",ms_location_cd)
    ENDIF
    SELECT DISTINCT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_value=cnvtreal(ms_location_cd)
      AND cv.code_set=220
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= sysdate
      AND cv.end_effective_dt_tm >= sysdate
     DETAIL
      IF (trim(ms_loc_list) IN (null, "", " "))
       ms_loc_list = trim(cv.display)
      ELSE
       ms_loc_list = concat(ms_loc_list,", ",trim(cv.display))
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
  SET ms_location_str = concat(ms_location_str,")")
  SET mn_location_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  WHERE dfr.active_ind=1
   AND dfr.description="Telephone Triage Form"
  DETAIL
   mf_dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND dfa.active_ind=1)
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.beg_effective_dt_tm <= dfa.version_dt_tm
    AND dfr.end_effective_dt_tm > dfa.version_dt_tm)
  HEAD REPORT
   pn_cnt = 0
  HEAD dfa.dcp_forms_activity_id
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_tel->forms,5))
    stat = alterlist(m_tel->forms,(pn_cnt+ 10))
   ENDIF
   m_tel->forms[pn_cnt].f_activity_id = dfa.dcp_forms_activity_id, m_tel->forms[pn_cnt].
   f_dcp_forms_ref_id = dfa.dcp_forms_ref_id, m_tel->forms[pn_cnt].f_encntr_id = dfa.encntr_id,
   m_tel->forms[pn_cnt].s_version_dt_tm = format(dfa.form_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"), m_tel->
   forms[pn_cnt].s_reference_nbr = trim(concat(trim(cnvtstring(dfa.dcp_forms_activity_id)),"*"))
  FOOT REPORT
   stat = alterlist(m_tel->forms,pn_cnt)
  WITH nocounter
 ;end select
 IF (size(m_tel->forms,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5))),
    dummyt d1,
    clinical_event ce1,
    clinical_event ce2
   PLAN (d)
    JOIN (ce1
    WHERE operator(ce1.reference_nbr,"LIKE",patstring(m_tel->forms[d.seq].s_reference_nbr,1))
     AND parser(ms_provider_str))
    JOIN (d1)
    JOIN (ce2
    WHERE ce2.event_id=ce1.parent_event_id
     AND ce2.result_status_cd=mf_inerror_cd)
   DETAIL
    IF ( NOT (ce1.result_val IN (null, "", " ")))
     m_tel->forms[d.seq].s_provider = ce1.result_val
    ENDIF
    IF (ce2.result_status_cd=mf_inerror_cd)
     m_tel->forms[d.seq].n_inerror_ind = 1
    ENDIF
    m_tel->forms[d.seq].n_provider_filter_ind = mn_provider_ind
   WITH nocounter, outerjoin = d1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5))),
    dummyt d1,
    clinical_event ce2,
    clinical_event ce3
   PLAN (d)
    JOIN (ce2
    WHERE operator(ce2.reference_nbr,"LIKE",patstring(m_tel->forms[d.seq].s_reference_nbr,1))
     AND parser(ms_call_cat_str))
    JOIN (d1)
    JOIN (ce3
    WHERE operator(ce3.reference_nbr,"LIKE",patstring(m_tel->forms[d.seq].s_reference_nbr,1))
     AND parser(ms_closed_str))
   DETAIL
    IF ( NOT (ce2.result_val IN (null, "", " ")))
     m_tel->forms[d.seq].s_call_cat = ce2.result_val
    ENDIF
    IF (ce3.result_val="Closed")
     m_tel->forms[d.seq].n_closed_ind = 1
    ENDIF
    m_tel->forms[d.seq].n_call_cat_filter_ind = mn_call_cat_ind
   WITH nocounter, outerjoin = d1
  ;end select
  SELECT INTO "nl:"
   e.encntr_id
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5))),
    encounter e
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind))
    JOIN (e
    WHERE (e.encntr_id=m_tel->forms[d.seq].f_encntr_id)
     AND parser(ms_location_str))
   DETAIL
    m_tel->forms[d.seq].s_location = uar_get_code_display(e.location_cd), m_tel->forms[d.seq].
    f_location_cd = e.location_cd, m_tel->forms[d.seq].n_location_filter_ind = mn_location_ind
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5))),
    dcp_forms_activity_prsnl dfap,
    prsnl pr2
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind)
     AND (m_tel->forms[d.seq].n_location_filter_ind=mn_location_ind))
    JOIN (dfap
    WHERE (dfap.dcp_forms_activity_id=m_tel->forms[d.seq].f_activity_id))
    JOIN (pr2
    WHERE pr2.person_id=dfap.prsnl_id
     AND parser(ms_user_str2))
   DETAIL
    m_tel->forms[d.seq].s_username = trim(pr2.name_full_formatted), m_tel->forms[d.seq].s_userid =
    trim(pr2.username), m_tel->forms[d.seq].n_user_filter_ind = mn_user_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (size(m_tel->forms,5) > 0)
  SELECT INTO value(ms_output)
   ps_location = substring(1,50,m_tel->forms[d.seq].s_location), ps_provider = substring(1,50,m_tel->
    forms[d.seq].s_provider), ps_call_cat = substring(1,50,m_tel->forms[d.seq].s_call_cat),
   ps_user = substring(1,50,m_tel->forms[d.seq].s_username)
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5)))
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind)
     AND (m_tel->forms[d.seq].n_location_filter_ind=mn_location_ind)
     AND (m_tel->forms[d.seq].n_user_filter_ind=mn_user_ind))
   ORDER BY ps_location
   HEAD REPORT
    col 0, row 0, "Volume Statistics: ",
    ms_beg_dt_tm, " to ", ms_end_dt_tm,
    ms_line = "   "
    IF (mn_location_ind=1)
     ms_line = concat("Location: ",ms_loc_list)
    ENDIF
    IF (mn_provider_ind=1)
     IF (textlen(trim(ms_line)) > 0)
      ms_line = concat(ms_line,"; Provider: ",ms_provider)
     ELSE
      ms_line = concat(ms_line,"Provider: ",ms_provider)
     ENDIF
    ENDIF
    IF (mn_call_cat_ind=1)
     ms_call_cat_str = substring(findstring('"',ms_call_cat_str),((textlen(ms_call_cat_str) -
      findstring('"',ms_call_cat_str))+ 1),ms_call_cat_str)
     IF (textlen(trim(ms_line)) > 0)
      ms_line = concat(ms_line,"; Call Category: ",ms_call_cat_str)
     ELSE
      ms_line = concat(ms_line,"Call Category: ",ms_call_cat_str)
     ENDIF
    ENDIF
    IF (mn_user_ind=1)
     IF (textlen(trim(ms_line)) > 0)
      ms_line = concat(ms_line,"; User: ",m_tel->forms[d.seq].s_username)
     ELSE
      ms_line = concat(ms_line,"User: ",m_tel->forms[d.seq].s_username)
     ENDIF
    ENDIF
    IF (textlen(trim(ms_line))=0)
     ms_line = "N/A"
    ENDIF
    col 0, row + 1, "Filter by: ",
    ms_line, pn_tot_cnt = 0, pn_tot_closed_cnt = 0,
    pn_tot_inerror_cnt = 0
   HEAD PAGE
    col 0, row + 2, "Counts by Location",
    col 0, row + 1, "Location",
    col 50, "In Error", col 60,
    "Closed", col 70, "Pending",
    col 80, "Total", row + 1
   HEAD ps_location
    pn_closed_cnt = 0, pn_inerror_cnt = 0, pn_subtot_cnt = 0,
    pn_print_cnt = fillstring(5," ")
   DETAIL
    pn_subtot_cnt = (pn_subtot_cnt+ 1), pn_tot_cnt = (pn_tot_cnt+ 1)
    IF ((m_tel->forms[d.seq].n_closed_ind=1))
     pn_closed_cnt = (pn_closed_cnt+ 1), pn_tot_closed_cnt = (pn_tot_closed_cnt+ 1)
    ELSEIF ((m_tel->forms[d.seq].n_inerror_ind=1))
     pn_inerror_cnt = (pn_inerror_cnt+ 1), pn_tot_inerror_cnt = (pn_tot_inerror_cnt+ 1)
    ENDIF
   FOOT  ps_location
    col 0, row + 1, m_tel->forms[d.seq].s_location,
    ps_print_cnt = trim(cnvtstring(pn_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_subtot_cnt - (pn_closed_cnt+ pn_inerror_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_subtot_cnt)), col 82, ps_print_cnt
   FOOT REPORT
    col 0, row + 2, "Total All Locations",
    ps_print_cnt = trim(cnvtstring(pn_tot_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_tot_cnt - (pn_tot_inerror_cnt+ pn_tot_closed_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_cnt)), col 82, ps_print_cnt
   WITH nocounter, maxcol = 300
  ;end select
  SELECT INTO value(ms_output)
   ps_location = substring(1,50,m_tel->forms[d.seq].s_location), ps_provider = substring(1,50,m_tel->
    forms[d.seq].s_provider), ps_call_cat = substring(1,50,m_tel->forms[d.seq].s_call_cat),
   ps_user = substring(1,50,m_tel->forms[d.seq].s_username)
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5)))
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind)
     AND (m_tel->forms[d.seq].n_location_filter_ind=mn_location_ind)
     AND (m_tel->forms[d.seq].n_user_filter_ind=mn_user_ind))
   ORDER BY ps_call_cat
   HEAD REPORT
    ms_line = "   ", pn_tot_cnt = 0, pn_tot_closed_cnt = 0,
    pn_tot_inerror_cnt = 0
   HEAD PAGE
    col 0, row + 2, "Counts by Call Category",
    col 0, row + 1, "Call Category",
    col 50, "In Error", col 60,
    "Closed", col 70, "Pending",
    col 80, "Total", row + 1
   HEAD ps_call_cat
    pn_closed_cnt = 0, pn_inerror_cnt = 0, pn_subtot_cnt = 0,
    pn_print_cnt = fillstring(5," ")
   DETAIL
    pn_subtot_cnt = (pn_subtot_cnt+ 1), pn_tot_cnt = (pn_tot_cnt+ 1)
    IF ((m_tel->forms[d.seq].n_closed_ind=1))
     pn_closed_cnt = (pn_closed_cnt+ 1), pn_tot_closed_cnt = (pn_tot_closed_cnt+ 1)
    ELSEIF ((m_tel->forms[d.seq].n_inerror_ind=1))
     pn_inerror_cnt = (pn_inerror_cnt+ 1), pn_tot_inerror_cnt = (pn_tot_inerror_cnt+ 1)
    ENDIF
   FOOT  ps_call_cat
    col 0, row + 1, m_tel->forms[d.seq].s_call_cat,
    ps_print_cnt = trim(cnvtstring(pn_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_subtot_cnt - (pn_closed_cnt+ pn_inerror_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_subtot_cnt)), col 82, ps_print_cnt
   FOOT REPORT
    col 0, row + 2, "Total All Call Categories",
    ps_print_cnt = trim(cnvtstring(pn_tot_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_tot_cnt - (pn_tot_inerror_cnt+ pn_tot_closed_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_cnt)), col 82, ps_print_cnt
   WITH nocounter, maxcol = 300, append
  ;end select
  FOR (ml_loop = 1 TO size(m_tel->forms,5))
    IF (trim(m_tel->forms[ml_loop].s_provider) <= " ")
     SET m_tel->forms[ml_loop].s_provider = "*unknown"
    ENDIF
  ENDFOR
  SELECT INTO value(ms_output)
   ps_location = substring(1,50,m_tel->forms[d.seq].s_location), ps_provider = substring(1,50,m_tel->
    forms[d.seq].s_provider), ps_call_cat = substring(1,50,m_tel->forms[d.seq].s_call_cat),
   ps_user = substring(1,50,m_tel->forms[d.seq].s_username)
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5)))
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind)
     AND (m_tel->forms[d.seq].n_location_filter_ind=mn_location_ind)
     AND (m_tel->forms[d.seq].n_user_filter_ind=mn_user_ind))
   ORDER BY ps_provider
   HEAD REPORT
    ms_line = "   ", pn_tot_cnt = 0, pn_tot_closed_cnt = 0,
    pn_tot_inerror_cnt = 0
   HEAD PAGE
    col 0, row + 2, "Counts by Provider",
    col 0, row + 1, "Provider",
    col 50, "In Error", col 60,
    "Closed", col 70, "Pending",
    col 80, "Total", row + 1
   HEAD ps_provider
    pn_closed_cnt = 0, pn_inerror_cnt = 0, pn_subtot_cnt = 0,
    pn_print_cnt = fillstring(5," ")
   DETAIL
    pn_subtot_cnt = (pn_subtot_cnt+ 1), pn_tot_cnt = (pn_tot_cnt+ 1)
    IF ((m_tel->forms[d.seq].n_closed_ind=1))
     pn_closed_cnt = (pn_closed_cnt+ 1), pn_tot_closed_cnt = (pn_tot_closed_cnt+ 1)
    ELSEIF ((m_tel->forms[d.seq].n_inerror_ind=1))
     pn_inerror_cnt = (pn_inerror_cnt+ 1), pn_tot_inerror_cnt = (pn_tot_inerror_cnt+ 1)
    ENDIF
   FOOT  ps_provider
    col 0, row + 1, m_tel->forms[d.seq].s_provider,
    ps_print_cnt = trim(cnvtstring(pn_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_subtot_cnt - (pn_closed_cnt+ pn_inerror_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_subtot_cnt)), col 82, ps_print_cnt
   FOOT REPORT
    col 0, row + 2, "Total All Providers",
    ps_print_cnt = trim(cnvtstring(pn_tot_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_tot_cnt - (pn_tot_inerror_cnt+ pn_tot_closed_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_cnt)), col 82, ps_print_cnt
   WITH nocounter, maxcol = 300, append
  ;end select
  SELECT INTO value(ms_output)
   ps_location = substring(1,50,m_tel->forms[d.seq].s_location), ps_provider = substring(1,50,m_tel->
    forms[d.seq].s_provider), ps_call_cat = substring(1,50,m_tel->forms[d.seq].s_call_cat),
   ps_user = substring(1,50,m_tel->forms[d.seq].s_username)
   FROM (dummyt d  WITH seq = value(size(m_tel->forms,5)))
   PLAN (d
    WHERE (m_tel->forms[d.seq].n_provider_filter_ind=mn_provider_ind)
     AND (m_tel->forms[d.seq].n_call_cat_filter_ind=mn_call_cat_ind)
     AND (m_tel->forms[d.seq].n_location_filter_ind=mn_location_ind)
     AND (m_tel->forms[d.seq].n_user_filter_ind=mn_user_ind))
   ORDER BY ps_user
   HEAD REPORT
    ms_line = "   ", pn_tot_cnt = 0, pn_tot_closed_cnt = 0,
    pn_tot_inerror_cnt = 0
   HEAD PAGE
    col 0, row + 2, "Counts by User",
    col 0, row + 1, "User",
    col 50, "In Error", col 60,
    "Closed", col 70, "Pending",
    col 80, "Total", row + 1
   HEAD ps_user
    pn_closed_cnt = 0, pn_inerror_cnt = 0, pn_subtot_cnt = 0,
    pn_print_cnt = fillstring(5," ")
   DETAIL
    pn_subtot_cnt = (pn_subtot_cnt+ 1), pn_tot_cnt = (pn_tot_cnt+ 1)
    IF ((m_tel->forms[d.seq].n_closed_ind=1))
     pn_closed_cnt = (pn_closed_cnt+ 1), pn_tot_closed_cnt = (pn_tot_closed_cnt+ 1)
    ELSEIF ((m_tel->forms[d.seq].n_inerror_ind=1))
     pn_inerror_cnt = (pn_inerror_cnt+ 1), pn_tot_inerror_cnt = (pn_tot_inerror_cnt+ 1)
    ENDIF
   FOOT  ps_user
    col 0, row + 1, m_tel->forms[d.seq].s_username,
    ps_print_cnt = trim(cnvtstring(pn_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_subtot_cnt - (pn_closed_cnt+ pn_inerror_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_subtot_cnt)), col 82, ps_print_cnt
   FOOT REPORT
    col 0, row + 2, "Total All Users",
    ps_print_cnt = trim(cnvtstring(pn_tot_inerror_cnt)), col 54, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_closed_cnt)), col 63, ps_print_cnt,
    ps_print_cnt = trim(cnvtstring((pn_tot_cnt - (pn_tot_inerror_cnt+ pn_tot_closed_cnt)))), col 73,
    ps_print_cnt,
    ps_print_cnt = trim(cnvtstring(pn_tot_cnt)), col 82, ps_print_cnt
   WITH nocounter, maxcol = 300, append
  ;end select
 ELSE
  SELECT INTO value(ms_output)
   DETAIL
    col 0, row 0, "No Records Found"
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_ops_ind=1)
  IF (findfile(ms_csv_filename)=1)
   CALL echo("found email file")
   SET ms_email_list = concat(
    "joe.echols@bhs.org, sandra.curry@bhs.org,Jessica.Skibiski@baystatehealth.org,",
    "julie.gentes@bhs.org, suzanne.cronin@bhs.org, Mary.Quigley@baystatehealth.org,",
    "joe.echols@bhs.org")
   SET ms_tmp_str = concat("Telephone Triage Report: ",ms_beg_dt_tm," - ",ms_end_dt_tm)
   CALL emailfile(ms_csv_filename,ms_csv_filename,ms_email_list,ms_tmp_str,1)
   IF (findfile(ms_csv_filename)=1)
    CALL echo("Unable to delete email file")
   ELSE
    CALL echo("Email File Deleted")
   ENDIF
  ELSE
   CALL echo("email file not found")
  ENDIF
 ENDIF
 FREE RECORD m_tel
 FREE RECORD m_activity_recs
#exit_script
END GO
