CREATE PROGRAM bhs_rpt_powerform_detail:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Forms:" = 0,
  "Status:" = 0,
  "Facility:" = 0,
  "Email to:" = ""
  WITH outdev, ms_start_dt, ms_end_dt,
  ml_form_cd, ml_status_cd, mf_facilities_cd,
  ms_email_list
 RECORD m_rec(
   1 m_fac[*]
     2 ms_fac_name = vc
     2 mf_fac_cd = f8
     2 m_unit[*]
       3 ms_unit_name = vc
       3 mf_unit_cd = f8
       3 m_form[*]
         4 mf_form_id = f8
         4 ms_form_name = vc
         4 ms_create_dt = vc
         4 ms_form_status = vc
         4 ms_update_prsnl = vc
         4 ms_update_dt = vc
         4 ms_pat_name = vc
         4 mf_encounter = f8
         4 ms_fin = vc
         4 ms_admit_dt = vc
 ) WITH protect
 EXECUTE bhs_sys_stand_subroutine
 DECLARE mf_start_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DT,"DD-MMM-YYYY"),
   000000))
 DECLARE mf_end_dt = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DT,"DD-MMM-YYYY"),
   235959))
 DECLARE mn_form_param = i2 WITH protect, constant(4)
 DECLARE mn_stat_param = i2 WITH protect, constant(5)
 DECLARE mn_fac_param = i2 WITH protect, constant(6)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ms_output = vc WITH protect, noconstant(trim( $OUTDEV))
 DECLARE ms_email = vc WITH protect, noconstant(trim( $MS_EMAIL_LIST))
 DECLARE ms_delimiter1 = vc WITH protect, noconstant("")
 DECLARE ms_delimiter2 = vc WITH protect, noconstant("")
 DECLARE ms_log = vc WITH protect, noconstant("ERROR")
 DECLARE ms_email_ms = vc WITH protect, noconstant(" ")
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_form = vc WITH protect, noconstant(" ")
 DECLARE ms_stat = vc WITH protect, noconstant(" ")
 DECLARE ms_fac = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_unit_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_form_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_upd_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 IF (mf_start_dt >= mf_end_dt)
  SET ms_log = "Start date must be less than End date."
  GO TO exit_script
 ENDIF
 IF (size(ms_email,3) > 0)
  IF (findstring("@",ms_email) > 0)
   SET mn_email_ind = 1
   SET ms_output = "powerform_detail_rpt.csv"
   SET ms_delimiter1 = '"'
   SET ms_delimiter2 = ","
  ELSE
   SET ms_log = "Your email address is invalid. Please enter a valid address."
   GO TO exit_script
  ENDIF
 ENDIF
 SET ms_data_type = reflect(parameter(mn_form_param,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(mn_form_param,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_form = concat(" dfa.dcp_forms_ref_id in (",trim(ms_tmp_str))
   ELSE
    SET ms_form = concat(ms_form,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_form = concat(ms_form,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_form = parameter(mn_form_param,1)
  IF (trim(ms_form)=char(42))
   SET ms_form = " 1=1"
  ENDIF
 ELSE
  SET ms_form = cnvtstring(parameter(mn_form_param,1),20)
  SET ms_form = concat(" dfa.dcp_forms_ref_id = ",trim(ms_form))
 ENDIF
 SET ms_data_type = reflect(parameter(mn_stat_param,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(mn_stat_param,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_stat = concat(" dfa.form_status_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_stat = concat(ms_stat,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_stat = concat(ms_stat,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_stat = parameter(mn_stat_param,1)
  IF (trim(ms_stat)=char(42))
   SET ms_stat = " 1=1"
  ENDIF
 ELSE
  SET ms_stat = cnvtstring(parameter(mn_stat_param,1),20)
  SET ms_stat = concat(" dfa.form_status_cd = ",trim(ms_stat))
 ENDIF
 SET ms_data_type = reflect(parameter(mn_fac_param,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(mn_fac_param,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_fac = concat(" e.loc_facility_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_fac = concat(ms_fac,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_fac = concat(ms_fac,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_fac = parameter(mn_fac_param,1)
  IF (trim(ms_fac)=char(42))
   SET ms_fac = " 1=1"
  ENDIF
 ELSE
  SET ms_fac = cnvtstring(parameter(mn_fac_param,1),20)
  SET ms_fac = concat(" e.loc_facility_cd = ",trim(ms_fac))
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   encounter e,
   encntr_alias ea,
   person p,
   dcp_forms_activity_prsnl dfap
  PLAN (dfa
   WHERE dfa.active_ind=1
    AND dfa.beg_activity_dt_tm >= cnvtdatetime(mf_start_dt)
    AND dfa.beg_activity_dt_tm <= cnvtdatetime(mf_end_dt)
    AND parser(ms_stat)
    AND parser(ms_form))
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND e.active_ind=1
    AND parser(ms_fac))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (dfap
   WHERE dfap.dcp_forms_activity_id=dfa.dcp_forms_activity_id)
  ORDER BY e.loc_facility_cd, e.loc_nurse_unit_cd, dfa.dcp_forms_activity_id,
   dfap.updt_dt_tm
  HEAD e.loc_facility_cd
   ml_fac_cnt = (ml_fac_cnt+ 1)
   IF (mod(ml_fac_cnt,100)=1)
    CALL alterlist(m_rec->m_fac,(ml_fac_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].ms_fac_name = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->
   m_fac[ml_fac_cnt].mf_fac_cd = e.loc_facility_cd, ml_unit_cnt = 0
  HEAD e.loc_nurse_unit_cd
   ml_unit_cnt = (ml_unit_cnt+ 1)
   IF (mod(ml_unit_cnt,100)=1)
    CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit,(ml_unit_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].ms_unit_name = trim(uar_get_code_display(e
     .loc_nurse_unit_cd)), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].mf_unit_cd = e
   .loc_nurse_unit_cd, ml_form_cnt = 0
  HEAD dfa.dcp_forms_activity_id
   ml_form_cnt = (ml_form_cnt+ 1)
   IF (mod(ml_form_cnt,100)=1)
    CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form,(ml_form_cnt+ 99))
   ENDIF
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_pat_name = trim(p
    .name_full_formatted), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_fin =
   trim(ea.alias), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_admit_dt =
   format(e.arrive_dt_tm,"mm/dd/yy hh:mm;;d"),
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].mf_form_id = dfa
   .dcp_forms_activity_id, m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].
   mf_encounter = dfa.encntr_id, m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].
   ms_form_name = trim(dfa.description),
   m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_create_dt = format(dfa
    .beg_activity_dt_tm,"mm/dd/yy hh:mm;;d"), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[
   ml_form_cnt].ms_form_status = trim(uar_get_code_display(dfa.form_status_cd)), ml_upd_cnt = 0
  DETAIL
   ml_upd_cnt = (ml_upd_cnt+ 1)
   IF (ml_upd_cnt=1)
    m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_update_prsnl = trim(dfap
     .prsnl_ft), m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form[ml_form_cnt].ms_update_dt =
    format(dfap.updt_dt_tm,"mm/dd/yy hh:mm;;d")
   ENDIF
  FOOT  e.loc_nurse_unit_cd
   CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit[ml_unit_cnt].m_form,ml_form_cnt)
  FOOT  e.loc_facility_cd
   CALL alterlist(m_rec->m_fac[ml_fac_cnt].m_unit,ml_unit_cnt)
  FOOT REPORT
   CALL alterlist(m_rec->m_fac,ml_fac_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value(ms_output)
  facility = substring(1,60,m_rec->m_fac[d1.seq].ms_fac_name), nursing_unit = substring(1,60,m_rec->
   m_fac[d1.seq].m_unit[d2.seq].ms_unit_name), form_id = substring(1,60,cnvtstring(m_rec->m_fac[d1
    .seq].m_unit[d2.seq].m_form[d3.seq].mf_form_id)),
  form = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_form_name), form_create
   = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_create_dt), form_status =
  substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_form_status),
  modified_at = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_update_dt),
  modified_by = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_update_prsnl),
  patient_full_name = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_pat_name),
  patient_admit = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_admit_dt),
  account_number = substring(1,60,m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_fin),
  encounter_number = substring(1,60,cnvtstring(m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].
    mf_encounter))
  FROM (dummyt d1  WITH seq = value(size(m_rec->m_fac,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->m_fac[d1.seq].m_unit,5)))
   JOIN (d2
   WHERE maxrec(d3,size(m_rec->m_fac[d1.seq].m_unit[d2.seq].m_form,5)))
   JOIN (d3)
  ORDER BY m_rec->m_fac[d1.seq].ms_fac_name, m_rec->m_fac[d1.seq].m_unit[d2.seq].ms_unit_name, m_rec
   ->m_fac[d1.seq].m_unit[d2.seq].m_form[d3.seq].ms_form_name
  WITH nocounter, format, pcformat(value(ms_delimiter1),value(ms_delimiter2))
 ;end select
 IF (mn_email_ind=1)
  CALL emailfile(ms_output,ms_output,ms_email,concat("Powerform Detail Report - ",format(cnvtdatetime
     (curdate,curtime),";;q")," - ",curprog),1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    ms_email_ms = concat("File has been emailed to: ",ms_email), col 0,
    "{PS/792 0 translate 90 rotate/}",
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)),
    ms_email_ms
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
 IF (ms_log != "ERROR")
  SELECT INTO  $OUTDEV
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ELSE
  SET ms_log = "SUCCESS"
 ENDIF
 FREE RECORD m_rec
END GO
