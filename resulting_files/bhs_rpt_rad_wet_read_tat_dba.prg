CREATE PROGRAM bhs_rpt_rad_wet_read_tat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Exam Complete Start" = curdate,
  "Exam Complete End" = curdate,
  "Patient type at exam:" = 309310.00,
  "Section:" = 561917007.00,
  "Modality:" = "CT"
  WITH outdev, s_start_date, s_end_date,
  f_pat_type_exam, f_section_cd, s_modality
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_person_id = f8
     2 s_dob = vc
     2 s_institution = vc
     2 s_pat_type_at_exam = vc
     2 s_year_complete = vc
     2 s_month_complete = vc
     2 s_accession = vc
     2 s_hrs_of_day_complete = vc
     2 s_order_procedure = vc
     2 s_day_of_week_complete = vc
     2 l_day_of_week_complete = i4
     2 s_exam_complete_dt = vc
     2 l_tot_cnt = i4
     2 s_addendum = vc
     2 s_final_dt = vc
     2 s_order_dt = vc
     2 s_transport_dt = vc
     2 s_start_dt = vc
     2 s_transcribe_dt = vc
     2 s_wet_read_dt = vc
     2 s_exam_room = vc
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_priority = vc
     2 s_comment = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_addtext_cd = f8 WITH constant(uar_get_code_by("MEANING",30460,"ADDTEXT"))
 DECLARE ms_start_date = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_modality_string = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat("rad_exam_wet_read_tat_",format(cnvtdatetime(sysdate),
     "MMDDYYYY;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SET ms_start_date = concat( $S_START_DATE," 00:00:00")
 SET ms_end_date = concat( $S_END_DATE," 23:59:59")
 SET ms_modality_string = trim( $S_MODALITY)
 SELECT DISTINCT INTO "nl:"
  FROM omf_radmgmt_order_st oros,
   order_radiology o,
   order_catalog oc,
   encntr_alias fin,
   encntr_alias mrn,
   person p,
   person_alias cmrn,
   dummyt d1,
   omf_radreport_st orrs,
   dummyt d2,
   rad_init_read rir,
   dummyt d3,
   tracking_item ti,
   tracking_event te,
   track_event t
  PLAN (oros
   WHERE oros.exam_complete_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND (oros.section_cd= $F_SECTION_CD)
    AND (oros.encntr_type_at_exam_cmplt_cd= $F_PAT_TYPE_EXAM))
   JOIN (o
   WHERE o.order_id=oros.order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.primary_mnemonic=patstring(concat(value(ms_modality_string),"*")))
   JOIN (fin
   WHERE fin.encntr_id=oros.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (mrn
   WHERE mrn.encntr_id=oros.encntr_id
    AND mrn.encntr_alias_type_cd=mf_mrn_cd
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=oros.patient_id)
   JOIN (cmrn
   WHERE cmrn.person_id=p.person_id
    AND cmrn.person_alias_type_cd=mf_cmrn_cd
    AND cmrn.active_ind=1
    AND cmrn.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d1)
   JOIN (orrs
   WHERE ((orrs.order_id=o.parent_order_id) OR (orrs.order_id=o.order_id))
    AND orrs.order_id != 0.00)
   JOIN (d2)
   JOIN (rir
   WHERE rir.order_id=o.order_id
    AND rir.activity_cd=mf_addtext_cd
    AND rir.read_by_dt_tm IN (
   (SELECT
    min(rir0.read_by_dt_tm)
    FROM rad_init_read rir0
    WHERE rir0.order_id=rir.order_id)))
   JOIN (d3)
   JOIN (ti
   WHERE ti.encntr_id=oros.encntr_id)
   JOIN (te
   WHERE te.tracking_id=ti.tracking_id
    AND te.active_ind=1)
   JOIN (t
   WHERE t.track_event_id=te.track_event_id
    AND t.tracking_group_cd=te.tracking_group_cd
    AND t.display_key="TRANSPORT")
  ORDER BY oros.order_id
  HEAD oros.order_id
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->qual,m_rec->l_cnt),
   m_rec->qual[ml_cnt].f_encntr_id = oros.encntr_id, m_rec->qual[ml_cnt].f_person_id = oros
   .patient_id, m_rec->qual[ml_cnt].f_order_id = oros.order_id,
   m_rec->qual[ml_cnt].s_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;D"), m_rec->qual[ml_cnt].
   s_institution = trim(uar_get_code_display(oros.perf_inst_cd),3), m_rec->qual[ml_cnt].
   s_pat_type_at_exam = trim(uar_get_code_display(oros.encntr_type_at_exam_cmplt_cd),3),
   m_rec->qual[ml_cnt].s_year_complete = trim(cnvtstring(year(oros.exam_complete_dt_tm),20,0),3)
   IF (month(oros.exam_complete_dt_tm)=1)
    m_rec->qual[ml_cnt].s_month_complete = "01-January"
   ELSEIF (month(oros.exam_complete_dt_tm)=2)
    m_rec->qual[ml_cnt].s_month_complete = "02-February"
   ELSEIF (month(oros.exam_complete_dt_tm)=3)
    m_rec->qual[ml_cnt].s_month_complete = "03-March"
   ELSEIF (month(oros.exam_complete_dt_tm)=4)
    m_rec->qual[ml_cnt].s_month_complete = "04-April"
   ELSEIF (month(oros.exam_complete_dt_tm)=5)
    m_rec->qual[ml_cnt].s_month_complete = "05-May"
   ELSEIF (month(oros.exam_complete_dt_tm)=6)
    m_rec->qual[ml_cnt].s_month_complete = "06-June"
   ELSEIF (month(oros.exam_complete_dt_tm)=7)
    m_rec->qual[ml_cnt].s_month_complete = "07-July"
   ELSEIF (month(oros.exam_complete_dt_tm)=8)
    m_rec->qual[ml_cnt].s_month_complete = "08-August"
   ELSEIF (month(oros.exam_complete_dt_tm)=9)
    m_rec->qual[ml_cnt].s_month_complete = "09-September"
   ELSEIF (month(oros.exam_complete_dt_tm)=10)
    m_rec->qual[ml_cnt].s_month_complete = "10-October"
   ELSEIF (month(oros.exam_complete_dt_tm)=11)
    m_rec->qual[ml_cnt].s_month_complete = "11-November"
   ELSEIF (month(oros.exam_complete_dt_tm)=12)
    m_rec->qual[ml_cnt].s_month_complete = "12-December"
   ELSE
    m_rec->qual[ml_cnt].s_month_complete = "-"
   ENDIF
   m_rec->qual[ml_cnt].s_accession = trim(oros.accession_nbr,3), m_rec->qual[ml_cnt].
   s_hrs_of_day_complete = trim(cnvtstring(floor((oros.exam_complete_min_nbr/ 60)),20,0)), m_rec->
   qual[ml_cnt].s_order_procedure = trim(uar_get_code_display(oros.catalog_cd),3)
   IF (weekday(oros.exam_complete_dt_tm) IN (0, 7))
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Sunday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=1)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Monday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=2)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Tuesday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=3)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Wednesday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=4)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Thursday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=5)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Friday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=6)
    m_rec->qual[ml_cnt].s_day_of_week_complete = "Saturday"
   ENDIF
   m_rec->qual[ml_cnt].l_day_of_week_complete = weekday(oros.exam_complete_dt_tm), m_rec->qual[ml_cnt
   ].s_exam_complete_dt = format(oros.exam_complete_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[ml_cnt]
   .s_addendum = trim(cnvtstring(orrs.report_status_flag,20,0),3),
   m_rec->qual[ml_cnt].s_final_dt = format(orrs.final_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[
   ml_cnt].s_order_dt = format(oros.order_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[ml_cnt].
   s_transport_dt = format(te.requested_dt_tm,"MM/DD/YYYY HH:mm;;q"),
   m_rec->qual[ml_cnt].s_start_dt = format(oros.start_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[
   ml_cnt].s_transcribe_dt = format(oros.transcribe_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[ml_cnt]
   .s_wet_read_dt = format(rir.read_by_dt_tm,"MM/DD/YYYY HH:mm;;q"),
   m_rec->qual[ml_cnt].s_exam_room = trim(uar_get_code_display(oros.exam_room_cd),3), m_rec->qual[
   ml_cnt].s_cmrn = trim(cmrn.alias,3), m_rec->qual[ml_cnt].s_mrn = trim(mrn.alias,3),
   m_rec->qual[ml_cnt].s_fin = trim(fin.alias,3), m_rec->qual[ml_cnt].s_priority = trim(
    uar_get_code_display(oros.priority_cd),3), m_rec->qual[ml_cnt].l_tot_cnt = 0
  DETAIL
   m_rec->qual[ml_cnt].l_tot_cnt += 1
  WITH outerjoin = d1, dontcare = orrs, outerjoin = d2,
   dontcare = rir, outerjoin = d3, time = 30,
   nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dummyt d1,
   order_comment oc,
   long_text lt
  PLAN (d1)
   JOIN (oc
   WHERE (oc.order_id=m_rec->qual[d1.seq].f_order_id))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY oc.order_id, oc.action_sequence DESC, lt.long_text_id
  HEAD oc.order_id
   m_rec->qual[d1.seq].s_comment = " "
  HEAD oc.action_sequence
   null
  HEAD lt.long_text_id
   IF ((m_rec->qual[d1.seq].s_comment=" "))
    m_rec->qual[d1.seq].s_comment = replace(replace(trim(lt.long_text,3),char(13)," "),char(10)," ")
   ELSE
    m_rec->qual[d1.seq].s_comment = concat(m_rec->qual[d1.seq].s_comment,"; ",replace(replace(trim(lt
        .long_text,3),char(13)," "),char(10)," "))
   ENDIF
  WITH nocounter
 ;end select
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  institution = trim(substring(1,60,m_rec->qual[d.seq].s_institution),3), patient_type_at_exam = trim
  (substring(1,30,m_rec->qual[d.seq].s_pat_type_at_exam),3), year_complete = trim(substring(1,10,
    m_rec->qual[d.seq].s_year_complete),3),
  month_complte = trim(substring(1,15,m_rec->qual[d.seq].s_month_complete),3), accession = trim(
   substring(1,50,m_rec->qual[d.seq].s_accession),3), order_procedure = trim(substring(1,100,m_rec->
    qual[d.seq].s_order_procedure),3),
  day_of_week_complete = trim(substring(1,15,m_rec->qual[d.seq].s_day_of_week_complete),3), addendum
   = trim(substring(1,20,m_rec->qual[d.seq].s_addendum),3), exam_complete_dt_tm = trim(substring(1,20,
    m_rec->qual[d.seq].s_exam_complete_dt),3),
  final_dt_tm = trim(substring(1,20,m_rec->qual[d.seq].s_final_dt),3), wet_read_dt_tm = trim(
   substring(1,20,m_rec->qual[d.seq].s_wet_read_dt),3), ordered_dt_tm = trim(substring(1,20,m_rec->
    qual[d.seq].s_order_dt),3),
  transport_dt_tm = trim(substring(1,20,m_rec->qual[d.seq].s_transport_dt),3), transcribe_dt_tm =
  trim(substring(1,20,m_rec->qual[d.seq].s_transcribe_dt),3), start_dt_tm = trim(substring(1,20,m_rec
    ->qual[d.seq].s_start_dt),3),
  tot_cnt = build(m_rec->qual[d.seq].l_tot_cnt), exam_room = trim(substring(1,60,m_rec->qual[d.seq].
    s_exam_room),3), mrn = trim(substring(1,20,m_rec->qual[d.seq].s_mrn),3),
  financial_number = trim(substring(1,20,m_rec->qual[d.seq].s_fin),3), priority = trim(substring(1,50,
    m_rec->qual[d.seq].s_priority),3), dob = trim(substring(1,50,m_rec->qual[d.seq].s_dob),3),
  order_comment = trim(substring(1,20000,m_rec->qual[d.seq].s_comment),3)
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  PLAN (d)
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_out = concat("Radiology_Exam_Wet_Read_TAT_",format(curdate,"YYYYMMDD;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output_dest,ms_filename_out, $OUTDEV,
   "Baystate Medical Center Radiology Exam Wet Read TAT",0)
 ENDIF
#exit_script
END GO
