CREATE PROGRAM bhs_rpt_central_iv_by_date:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "",
  "Recipients" = ""
  WITH outdev, s_facility, s_recipients
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_refs
 RECORD m_refs(
   1 refs[*]
     2 s_reference_nbr = vc
 ) WITH protect
 FREE RECORD m_ivs
 RECORD m_ivs(
   1 ivs[*]
     2 f_encntr_id = f8
     2 s_reference_nbr = vc
     2 s_patient_name = vc
     2 f_person_id = f8
     2 s_loc_unit = vc
     2 s_loc_room = vc
     2 s_loc_bed = vc
     2 s_mrn_nbr = vc
     2 s_fin_nbr = vc
     2 s_catheter_type = vc
     2 s_start_dt_tm = vc
     2 s_catheter_num = vc
     2 n_discontinue_ind = i2
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_dcp_forms_ref_id = f8 WITH protect, noconstant(0)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_prev_line = vc WITH protect, noconstant(" ")
 DECLARE ms_facility = vc WITH protect, noconstant(trim( $S_FACILITY))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_email_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0.0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 IF (textlen(ms_facility) > 10)
  SET ms_email_filename = concat("bhs_rpt_ctrl_iv_",substring(1,10,ms_facility),".csv")
 ELSE
  SET ms_email_filename = concat("bhs_rpt_ctrl_iv_",ms_facility,".csv")
 ENDIF
 IF (trim(ms_recipients) <= " ")
  SET ms_recipients = "joe.echols@bhs.org"
 ELSE
  IF (cnvtupper(ms_facility)="BMC")
   SET ms_recipients = concat(ms_recipients,", nicole.mcavoy@bhs.org, ",
    "heidi.hannington@bhs.org, gina.malvezzi@bhs.org, patricia.daviau@bhs.org, lori.anderson@bhs.org"
    )
  ENDIF
  SET ms_recipients = concat(ms_recipients,", joe.echols@bhs.org")
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key=cnvtupper(ms_facility)
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  DETAIL
   mf_facility_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build2("facility cd: ",mf_facility_cd))
 CALL echo(build2("inpatient cd: ",mf_inpatient_cd))
 CALL echo(build2("fin cd: ",mf_fin_cd))
 CALL echo(build2("mrn cd: ",mf_mrn_cd))
 IF (((curqual < 1) OR (mf_facility_cd=0)) )
  CALL echo("facility not found - exit")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.description="IV Assessment (v001)"
    AND dfr.active_ind=1
    AND dfr.end_effective_dt_tm >= sysdate)
  HEAD REPORT
   mf_dcp_forms_ref_id = dfr.dcp_forms_ref_id,
   CALL echo(build2("dcp_forms_ref_id: ",mf_dcp_forms_ref_id))
  WITH nocounter
 ;end select
 CALL echo("get activity_ids and reference numbers")
 SELECT INTO "nl:"
  dfa.encntr_id, dfa.last_activity_dt_tm
  FROM dcp_forms_activity dfa,
   encounter e
  PLAN (dfa
   WHERE dfa.dcp_forms_ref_id=mf_dcp_forms_ref_id
    AND dfa.beg_activity_dt_tm BETWEEN cnvtdatetime("08-DEC-2009 00:00:00") AND cnvtdatetime(
    "08-DEC-2009 23:59:59"))
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND e.encntr_type_cd=mf_inpatient_cd)
  ORDER BY dfa.encntr_id, dfa.last_activity_dt_tm DESC
  HEAD REPORT
   pn_cnt = 0
  HEAD dfa.dcp_forms_activity_id
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_refs->refs,5))
    stat = alterlist(m_refs->refs,(pn_cnt+ 10))
   ENDIF
   m_refs->refs[pn_cnt].s_reference_nbr = trim(concat(trim(cnvtstring(dfa.dcp_forms_activity_id)),"*"
     ))
  FOOT REPORT
   stat = alterlist(m_refs->refs,pn_cnt),
   CALL echo(concat(trim(cnvtstring(pn_cnt))," activity_ids found"))
  WITH nocounter
 ;end select
 IF (size(m_refs->refs,5)=0)
  GO TO exit_script
 ENDIF
 CALL echo("get clinical_event information")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_refs->refs,5))),
   clinical_event ce,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p
  PLAN (d)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(m_refs->refs[d.seq].s_reference_nbr,1))
    AND trim(cnvtupper(ce.event_title_text)) IN ("CATHETER TYPE I", "CATHETER TYPE II",
   "CATHETER TYPE III", "CATHETER TYPE IV")
    AND  NOT (trim(cnvtupper(ce.result_val)) IN ("PERIPHERAL", "MIDLINE PERIPHERAL CATHETER")))
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.loc_facility_cd=mf_facility_cd
    AND e.disch_dt_tm=null
    AND e.encntr_type_cd=mf_inpatient_cd)
   JOIN (ea1
   WHERE ea1.encntr_id=ce.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=ce.encntr_id
    AND ea2.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   pn_cnt = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (pn_cnt > size(m_ivs->ivs,5))
    stat = alterlist(m_ivs->ivs,(pn_cnt+ 10))
   ENDIF
   m_ivs->ivs[pn_cnt].s_reference_nbr = trim(m_refs->refs[d.seq].s_reference_nbr), m_ivs->ivs[pn_cnt]
   .f_encntr_id = ce.encntr_id, m_ivs->ivs[pn_cnt].s_catheter_type = trim(ce.result_val),
   m_ivs->ivs[pn_cnt].s_catheter_num = substring(findstring("I",ce.event_title_text),(size(ce
     .event_title_text,1) - findstring("I",ce.event_title_text)),ce.event_title_text), m_ivs->ivs[
   pn_cnt].f_person_id = ce.person_id, m_ivs->ivs[pn_cnt].s_loc_unit = uar_get_code_display(e
    .loc_nurse_unit_cd),
   m_ivs->ivs[pn_cnt].s_loc_room = uar_get_code_display(e.loc_room_cd), m_ivs->ivs[pn_cnt].s_loc_bed
    = uar_get_code_display(e.loc_bed_cd), m_ivs->ivs[pn_cnt].s_fin_nbr = ea2.alias,
   m_ivs->ivs[pn_cnt].s_mrn_nbr = ea1.alias, m_ivs->ivs[pn_cnt].s_patient_name = p
   .name_full_formatted
  FOOT REPORT
   stat = alterlist(m_ivs->ivs,pn_cnt),
   CALL echo(build2("found ",pn_cnt," iv rows"))
  WITH nocounter
 ;end select
 IF (size(m_ivs->ivs,5)=0)
  CALL echo("no ivs found - exit")
  GO TO exit_script
 ENDIF
 CALL echo("get insertion date/time")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(m_ivs->ivs[d.seq].s_reference_nbr,1))
    AND trim(cnvtupper(ce.event_title_text))=concat("DATE/TIME OF INSERTION/ACCESS ",trim(m_ivs->ivs[
     d.seq].s_catheter_num)))
  DETAIL
   ms_line = trim(substring(3,16,ce.result_val)), ps_year = substring(1,4,ms_line), ps_month =
   substring(5,2,ms_line),
   ps_day = substring(7,2,ms_line), ps_hour = substring(9,2,ms_line), ps_min = substring(11,2,ms_line
    ),
   m_ivs->ivs[d.seq].s_start_dt_tm = concat(ps_month,"/",ps_day,"/",ps_year,
    " ",ps_hour,":",ps_min)
  WITH nocounter
 ;end select
 CALL echo("filter out discontinued records")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5))),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(m_ivs->ivs[d.seq].s_reference_nbr,1))
    AND trim(cnvtupper(ce.event_title_text)) IN (concat("DISCONTINUE REASON ",m_ivs->ivs[d.seq].
    s_catheter_num), concat("CENTRAL LINE ",m_ivs->ivs[d.seq].s_catheter_num)))
  DETAIL
   m_ivs->ivs[d.seq].n_discontinue_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO value(concat("bhscust:",ms_email_filename))
  ps_patient = m_ivs->ivs[d.seq].s_patient_name, ps_loc_unit = m_ivs->ivs[d.seq].s_loc_unit,
  ps_loc_room = m_ivs->ivs[d.seq].s_loc_room,
  ps_loc_bed = m_ivs->ivs[d.seq].s_loc_bed, ps_mrn = m_ivs->ivs[d.seq].s_mrn_nbr, ps_fin = m_ivs->
  ivs[d.seq].s_fin_nbr,
  ps_catheter = m_ivs->ivs[d.seq].s_catheter_type, ps_start_date = m_ivs->ivs[d.seq].s_start_dt_tm
  FROM (dummyt d  WITH seq = value(size(m_ivs->ivs,5)))
  PLAN (d
   WHERE (m_ivs->ivs[d.seq].n_discontinue_ind=0))
  ORDER BY ps_patient, ps_mrn, ps_fin,
   ps_start_date
  HEAD REPORT
   ms_line = "PATIENT,LOCATION,MRN #,ACCOUNT #,CATHETER TYPE,INSERTION DATE", col 0, row 0,
   ms_line
  DETAIL
   ms_line = concat('"',trim(m_ivs->ivs[d.seq].s_patient_name),'",',trim(m_ivs->ivs[d.seq].s_loc_unit
     ),";"), ms_line = concat(ms_line,trim(m_ivs->ivs[d.seq].s_loc_room),";",trim(m_ivs->ivs[d.seq].
     s_loc_bed),","), ms_line = concat(ms_line,trim(m_ivs->ivs[d.seq].s_mrn_nbr),",",trim(m_ivs->ivs[
     d.seq].s_fin_nbr),","),
   ms_line = concat(ms_line,trim(m_ivs->ivs[d.seq].s_catheter_type),",",trim(m_ivs->ivs[d.seq].
     s_start_dt_tm))
   IF (trim(ms_line)=trim(ms_prev_line))
    CALL echo("duplicate line")
   ELSE
    col 0, row + 1, ms_line
   ENDIF
   ms_prev_line = ms_line
  WITH nocounter
 ;end select
 IF (findfile(concat("bhscust:",ms_email_filename)) > 0)
  SET ms_line = concat("Central IV Report ",format(sysdate,"dd-mmm-yyyy hh:mm;;d"))
  CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
   ms_recipients,ms_line,1)
  IF (findfile(concat("bhscust:",ms_email_filename))=1)
   CALL echo("Unable to delete email file")
  ELSE
   CALL echo("Email File Deleted")
  ENDIF
 ELSE
  CALL echo("email file not found")
 ENDIF
#exit_script
 IF (size(m_ivs->ivs,5)=0)
  SET ms_dclcom_str = concat('"no data" | mail -s "NO DATA FOUND - Central IV Report ',trim(format(
     sysdate,"dd-mmm-yyyy hh:mm;;d")),'" ',ms_recipients)
  CALL echo(concat("dclcom_str: ",ms_dclcom_str))
  SET ml_dclcom_len = size(trim(ms_dclcom_str))
  SET mn_dclcom_stat = 0
  SET stat = dcl(ms_dclcom_str,ml_dclcom_len,mn_dclcom_stat)
  IF (stat=0)
   CALL echo("error sending email")
  ENDIF
 ENDIF
 FREE RECORD m_ivs
 FREE RECORD m_refs
END GO
