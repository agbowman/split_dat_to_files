CREATE PROGRAM bhs_ops_ext_case_times:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_finnbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_snendorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNENDORHOLDMIN")),
 protect
 DECLARE mf_snstartorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNSTARTORHOLDMIN"
   )), protect
 DECLARE mf_snpacuout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Stop Time")), protect
 DECLARE mf_snpacuin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Start Time")), protect
 DECLARE mf_snorout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - Out OR (min)")),
 protect
 DECLARE mf_snorin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - In OR (min)")),
 protect
 DECLARE mf_snpreopout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - Out Pre OP (min)")), protect
 DECLARE mf_snpreopin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - In Pre OP (min)")), protect
 DECLARE mf_pacuext_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUEXTENDEDRECOVERY")),
 protect
 DECLARE mf_pacuii_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUII")), protect
 DECLARE mf_pacui_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUI")), protect
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="CURMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtdatetime(format(cnvtdatetime(curdate,0),"01-MMM-YYYY;;d")
     ),"DD-MMM-YYYY 00:00:00;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="CURMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtlookahead("1,M",cnvtdatetime(format(
        cnvtdatetime(curdate,0),"01-MMM-YYYY;;d")))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 SET frec->file_name = concat("/cerner/d_p627/bhscust/surginet/extract/daily/",
  "sn_case_time_detail.csv")
 IF (cnvtdatetime(mf_start_dt) > cnvtdatetime(mf_stop_dt))
  CALL echo("Dates invalid")
  GO TO exit_script
 ENDIF
 FREE RECORD m_loc
 RECORD m_loc(
   1 l_cnt = i4
   1 qual[*]
     2 f_loc_cd = f8
 )
 FREE RECORD m_case_time
 RECORD m_case_time(
   1 l_cnt = i4
   1 list[*]
     2 f_encntr_id = f8
     2 f_sched_dttm = f8
     2 s_sched_day = vc
     2 s_sched_rm = vc
     2 s_actual_rm = vc
     2 s_sched_area = vc
     2 s_case_nm = vc
     2 s_acct_nm = vc
     2 s_specialty = vc
     2 f_checkin_dttm = f8
     2 f_preopin_dttm = f8
     2 f_preopout_dttm = f8
     2 f_patinrm_dttm = f8
     2 f_procstart_dttm = f8
     2 f_procend_dttm = f8
     2 s_surgstart_day = vc
     2 f_surstart_dttm = f8
     2 f_surstop_dttm = f8
     2 f_patoutrm_dttm = f8
     2 f_orholdin_dttm = f8
     2 f_orholdout_dttm = f8
     2 f_pacu1in_dttm = f8
     2 f_pacu1out_dttm = f8
     2 f_pacu2in_dttm = f8
     2 f_pacu2out_dttm = f8
     2 f_pacu3in_dttm = f8
     2 f_pacu3out_dttm = f8
     2 s_cancel_ind = vc
     2 f_cancel_dttm = f8
     2 s_cancel_res = vc
     2 s_schproc_name = vc
     2 s_proc_name = vc
     2 s_proc_type = vc
     2 s_schsurgeon = vc
     2 s_procsurgeon = vc
     2 l_procdur_mins = i4
     2 f_proccode = f8
     2 s_schproc_type = vc
     2 f_reg_dt = f8
     2 s_mrn = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=221
   AND cv.cdf_meaning="SURGAREA"
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND cv.display_key IN ("BFMCENDOSCOPYMINORPROCEDURES", "BFMCLABORANDDELIVERY",
  "BFMCSURGICALSERVICES", "BMCENDOSCOPYCENTER", "BMCINPTOR",
  "BMCLABORANDDELIVERY", "BNHENDOSCOPYCENTER", "BNHSURGICALSERVICES", "BWHENDOSCOPYSPECIALPROCEDURES",
  "BWHSURGICALSERVICES",
  "CHESTNUTSURGERYCENTER", "PEDIATRICPROCEDUREUNIT")
  ORDER BY cv.display
  DETAIL
   m_loc->l_cnt += 1, stat = alterlist(m_loc->qual,m_loc->l_cnt), m_loc->qual[m_loc->l_cnt].f_loc_cd
    = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case s,
   surg_case_procedure scp,
   prsnl prn,
   prsnl prn2,
   encntr_alias ea,
   encntr_alias ea2,
   prsnl_group png,
   dummyt d1,
   case_times c1,
   dummyt d2,
   sn_acuity_level sa1
  PLAN (s
   WHERE s.sched_start_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND expand(ml_idx1,1,m_loc->l_cnt,s.surg_case_nbr_locn_cd,m_loc->qual[ml_idx1].f_loc_cd))
   JOIN (scp
   WHERE (scp.surg_case_id= Outerjoin(s.surg_case_id)) )
   JOIN (prn
   WHERE (prn.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
   JOIN (prn2
   WHERE (prn2.person_id= Outerjoin(scp.primary_surgeon_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(s.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_finnbr_cd))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(s.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_cs319_mrn_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (png
   WHERE (png.prsnl_group_id= Outerjoin(scp.surg_specialty_id)) )
   JOIN (d1)
   JOIN (c1
   WHERE c1.surg_case_id=s.surg_case_id
    AND c1.task_assay_cd IN (mf_snpreopin_cd, mf_snpreopout_cd, mf_snorin_cd, mf_snorout_cd,
   mf_snstartorhold_cd,
   mf_snendorhold_cd))
   JOIN (d2)
   JOIN (sa1
   WHERE sa1.surg_case_id=s.surg_case_id
    AND sa1.acuity_level_cd IN (mf_pacui_cd, mf_pacuii_cd, mf_pacuext_cd))
  ORDER BY scp.surg_case_proc_id, s.surg_case_nbr_formatted
  HEAD REPORT
   m_case_time->l_cnt = 0, pl_add_ind = 0
  HEAD scp.surg_case_proc_id
   pl_add_ind = 1, m_case_time->l_cnt += 1, stat = alterlist(m_case_time->list,m_case_time->l_cnt),
   m_case_time->list[m_case_time->l_cnt].f_sched_dttm = s.sched_start_dt_tm, m_case_time->list[
   m_case_time->l_cnt].s_sched_day = evaluate(cnvtstring(s.sched_start_day),"0","SUNDAY","1","MONDAY",
    "2","TUESDAY","3","WEDNESDAY","4",
    "THURSDAY","5","FRIDAY","6","SATURDAY",
    "-"), m_case_time->list[m_case_time->l_cnt].s_sched_rm = uar_get_code_display(s.sched_op_loc_cd),
   m_case_time->list[m_case_time->l_cnt].s_actual_rm = uar_get_code_display(s.surg_op_loc_cd),
   m_case_time->list[m_case_time->l_cnt].s_sched_area = uar_get_code_display(s.surg_case_nbr_locn_cd),
   m_case_time->list[m_case_time->l_cnt].s_case_nm = s.surg_case_nbr_formatted,
   m_case_time->list[m_case_time->l_cnt].s_acct_nm = ea.alias, m_case_time->list[m_case_time->l_cnt].
   s_mrn = trim(ea2.alias,3), m_case_time->list[m_case_time->l_cnt].f_checkin_dttm = s.checkin_dt_tm,
   m_case_time->list[m_case_time->l_cnt].s_surgstart_day = evaluate(cnvtstring(s.surg_start_day),"0",
    "SUNDAY","1","MONDAY",
    "2","TUESDAY","3","WEDNESDAY","4",
    "THURSDAY","5","FRIDAY","6","SATURDAY",
    "-"), m_case_time->list[m_case_time->l_cnt].f_surstart_dttm = s.surg_start_dt_tm, m_case_time->
   list[m_case_time->l_cnt].f_surstop_dttm = s.surg_stop_dt_tm,
   m_case_time->list[m_case_time->l_cnt].f_cancel_dttm = s.cancel_dt_tm, m_case_time->list[
   m_case_time->l_cnt].s_cancel_res = uar_get_code_display(s.cancel_reason_cd), m_case_time->list[
   m_case_time->l_cnt].s_cancel_ind = evaluate(s.cancel_reason_cd,null,"-",0,"Cancel"),
   m_case_time->list[m_case_time->l_cnt].f_procstart_dttm = scp.proc_start_dt_tm, m_case_time->list[
   m_case_time->l_cnt].f_procend_dttm = scp.proc_end_dt_tm, m_case_time->list[m_case_time->l_cnt].
   s_schproc_name = uar_get_code_description(scp.sched_surg_proc_cd),
   m_case_time->list[m_case_time->l_cnt].s_proc_name = uar_get_code_description(scp.surg_proc_cd),
   m_case_time->list[m_case_time->l_cnt].s_proc_type = evaluate(scp.primary_proc_ind,1,"PRIMARY",0,
    "SECONDARY"), m_case_time->list[m_case_time->l_cnt].s_schsurgeon = prn.name_full_formatted,
   m_case_time->list[m_case_time->l_cnt].s_procsurgeon = prn2.name_full_formatted, m_case_time->list[
   m_case_time->l_cnt].l_procdur_mins = scp.proc_dur_min, m_case_time->list[m_case_time->l_cnt].
   f_proccode = scp.sched_ud5_cd,
   m_case_time->list[m_case_time->l_cnt].s_specialty = png.prsnl_group_name, m_case_time->list[
   m_case_time->l_cnt].s_schproc_type = evaluate(scp.sched_primary_ind,1,"PRIMARY",0,"SECONDARY"),
   m_case_time->list[m_case_time->l_cnt].f_encntr_id = s.encntr_id
  DETAIL
   IF (pl_add_ind=1)
    CASE (c1.task_assay_cd)
     OF mf_snpreopin_cd:
      m_case_time->list[m_case_time->l_cnt].f_preopin_dttm = c1.case_time_dt_tm
     OF mf_snpreopout_cd:
      m_case_time->list[m_case_time->l_cnt].f_preopout_dttm = c1.case_time_dt_tm
     OF mf_snorin_cd:
      m_case_time->list[m_case_time->l_cnt].f_patinrm_dttm = c1.case_time_dt_tm
     OF mf_snorout_cd:
      m_case_time->list[m_case_time->l_cnt].f_patoutrm_dttm = c1.case_time_dt_tm
     OF mf_snstartorhold_cd:
      m_case_time->list[m_case_time->l_cnt].f_orholdin_dttm = c1.case_time_dt_tm
     OF mf_snendorhold_cd:
      m_case_time->list[m_case_time->l_cnt].f_orholdout_dttm = c1.case_time_dt_tm
    ENDCASE
    CASE (sa1.acuity_level_cd)
     OF mf_pacui_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu1in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu1out_dttm = sa1.acuity_stop_dt_tm
     OF mf_pacuii_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu2in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu2out_dttm = sa1.acuity_stop_dt_tm
     OF mf_pacuext_cd:
      m_case_time->list[m_case_time->l_cnt].f_pacu3in_dttm = sa1.acuity_start_dt_tm,m_case_time->
      list[m_case_time->l_cnt].f_pacu3out_dttm = sa1.acuity_stop_dt_tm
    ENDCASE
   ENDIF
  FOOT  scp.surg_case_proc_id
   pl_add_ind = 0
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF ((m_case_time->l_cnt > 0))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"',"DATE_OF_SURGERY",'","',"DAY_OF_WEEK",'","',
   "SCHED_OR_RM",'","',"ACTUAL_OR_RM",'","',"OR_CASE_#",
   '","',"SURGICAL_AREA",'","',"PAT_ACCT#",'","',
   "SCHED_START_DT",'","',"CANCEL_FLAG",'","',"CHECKIN_DT",
   '","',"PREOP_IN_DT",'","',"PREOP_OUT_DT",'","',
   "PREOP_TMINS",'","',"PAT_INRM_DT",'","',"SURGERY_START_DT",
   '","',"SURGERY_STOP_DT",'","',"PAT_OUTRM_DT",'","',
   "ORHOLD_START_DT",'","',"ORHOLD_END_DT",'","',"SURGERY_TMINS",
   '","',"ORROOM_TMINS",'","',"ORHOLD_TMINS",'","',
   "PACU1_IN_DT",'","',"PACU1_OUT_DT",'","',"PACU1_TMINS",
   '","',"PACU2_IN_DT",'","',"PACU2_OUT_DT",'","',
   "PACU2_TMINS",'","',"PACU3_IN_DT",'","',"PACU3_OUT_DT",
   '","',"PACU3_TMINS",'","',"PACU_TMIN",'","',
   "SCH_PROC_CODE",'","',"SCH_PROC_NAME",'","',"SCH_PROC_TYPE",
   '","',"SCH_SURGEON",'","',"PREFORM_PROC_NAME",'","',
   "PREFORM_PROC_TYPE",'","',"PREFORM_PROC_SPECIALTY",'","',"PREFORM_PROC_SURGEON",
   '","',"PROC_START_DT",'","',"PROC_END_DT",'","',
   "PROC_MINS",'","',"CANCEL_DATE",'","',"CANCEL_REASON",
   '","',"MRN",'"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_case_time->l_cnt)
   SET frec->file_buf = build('"',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_sched_dttm),
      "MM/DD/YYYY;;q"),3),'","',trim(m_case_time->list[ml_idx1].s_sched_day,3),'","',
    trim(m_case_time->list[ml_idx1].s_sched_rm,3),'","',trim(m_case_time->list[ml_idx1].s_actual_rm,3
     ),'","',trim(m_case_time->list[ml_idx1].s_case_nm,3),
    '","',trim(m_case_time->list[ml_idx1].s_sched_area,3),'","',trim(m_case_time->list[ml_idx1].
     s_acct_nm,3),'","',
    trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_sched_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(m_case_time->list[ml_idx1].s_cancel_ind,3),'","',trim(format(cnvtdatetime(m_case_time
       ->list[ml_idx1].f_checkin_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_preopin_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].
       f_preopout_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',
    trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_preopout_dttm),
       cnvtdatetime(m_case_time->list[ml_idx1].f_preopin_dttm),4),20,2),3),'","',trim(format(
      cnvtdatetime(m_case_time->list[ml_idx1].f_patinrm_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim
    (format(cnvtdatetime(m_case_time->list[ml_idx1].f_surstart_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_surstop_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].
       f_patoutrm_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',
    trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_orholdin_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_orholdout_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[
        ml_idx1].f_surstop_dttm),cnvtdatetime(m_case_time->list[ml_idx1].f_surstart_dttm),4),20,2),3),
    '","',trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_patoutrm_dttm),
       cnvtdatetime(m_case_time->list[ml_idx1].f_patinrm_dttm),4),20,2),3),'","',trim(cnvtstring(
      datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_orholdout_dttm),cnvtdatetime(m_case_time
        ->list[ml_idx1].f_orholdin_dttm),4),20,2),3),'","',
    trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu1in_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu1out_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[
        ml_idx1].f_pacu1out_dttm),cnvtdatetime(m_case_time->list[ml_idx1].f_pacu1in_dttm),4),20,2),3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu2in_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].
       f_pacu2out_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',
    trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu2out_dttm),
       cnvtdatetime(m_case_time->list[ml_idx1].f_pacu2in_dttm),4),20,2),3),'","',trim(format(
      cnvtdatetime(m_case_time->list[ml_idx1].f_pacu3in_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim
    (format(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu3out_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),
    '","',trim(cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu3out_dttm),
       cnvtdatetime(m_case_time->list[ml_idx1].f_pacu3in_dttm),4),20,2),3),'","',trim(cnvtstring(((
      datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].f_pacu1out_dttm),cnvtdatetime(m_case_time
        ->list[ml_idx1].f_pacu1in_dttm),4)+ datetimediff(cnvtdatetime(m_case_time->list[ml_idx1].
        f_pacu2out_dttm),cnvtdatetime(m_case_time->list[ml_idx1].f_pacu2in_dttm),4))+ datetimediff(
       cnvtdatetime(m_case_time->list[ml_idx1].f_pacu3out_dttm),cnvtdatetime(m_case_time->list[
        ml_idx1].f_pacu3in_dttm),4)),20,2),3),'","',
    trim(cnvtstring(m_case_time->list[ml_idx1].f_proccode,20,0),3),'","',trim(m_case_time->list[
     ml_idx1].s_schproc_name,3),'","',trim(m_case_time->list[ml_idx1].s_schproc_type,3),
    '","',trim(m_case_time->list[ml_idx1].s_schsurgeon,3),'","',trim(m_case_time->list[ml_idx1].
     s_proc_name,3),'","',
    trim(m_case_time->list[ml_idx1].s_proc_type,3),'","',trim(m_case_time->list[ml_idx1].s_specialty,
     3),'","',trim(m_case_time->list[ml_idx1].s_procsurgeon,3),
    '","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].f_procstart_dttm),
      "MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(format(cnvtdatetime(m_case_time->list[ml_idx1].
       f_procend_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',
    trim(cnvtstring(m_case_time->list[ml_idx1].l_procdur_mins,20,0),3),'","',trim(format(cnvtdatetime
      (m_case_time->list[ml_idx1].f_cancel_dttm),"MM/DD/YYYY HH:mm:ss;;q"),3),'","',trim(m_case_time
     ->list[ml_idx1].s_cancel_res,3),
    '","',trim(m_case_time->list[ml_idx1].s_mrn,3),'"',char(13),char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
#exit_script
END GO
