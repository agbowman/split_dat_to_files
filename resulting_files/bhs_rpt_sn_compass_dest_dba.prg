CREATE PROGRAM bhs_rpt_sn_compass_dest:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Case Start Date (Range Start):" = "CURDATE",
  "Case Start Date (Range End):" = "CURDATE",
  "Surgical Area:" = 0
  WITH outdev, s_start_dt, s_stop_dt,
  f_surg_area_cd
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs72_sndeldescription_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNDELDESCRIPTION"))
 DECLARE mf_cs72_snpostopcomments_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPOSTOPCOMMENTS"))
 DECLARE mf_cs72_snpostopdestination_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPOSTOPDESTINATION"))
 DECLARE mf_cs16289_publicschedulingcomments_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!12272"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs48_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2669"))
 DECLARE ml_day = i4 WITH protect, noconstant(- (1))
 DECLARE ml_delay_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
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
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_surg_case_id = f8
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_pat_type = vc
     2 s_dob = vc
     2 s_age = vc
     2 s_disch_dt = vc
     2 s_prim_surgeon = vc
     2 s_prim_surgeon_specialty = vc
     2 s_prim_procedure = vc
     2 s_case_nbr = vc
     2 s_sched_priority = vc
     2 s_surg_start_dt = vc
     2 s_surg_sched_start_tm = vc
     2 s_delay_reason = vc
     2 s_operating_room = vc
     2 s_surg_area = vc
     2 s_case_start_day = vc
     2 s_case_craeted_dt_tm = vc
     2 s_add_on_indicator = vc
     2 s_case_sched_duration = vc
     2 s_case_sched_patient_type = vc
     2 f_in_rm = dq8
     2 f_out_rm = dq8
     2 f_surg_start = dq8
     2 f_surg_stop = dq8
     2 s_rm_tot_time = vc
     2 s_surg_tot_time = vc
     2 s_postop_dest = vc
     2 s_del_desc = vc
     2 s_postop_comment = vc
     2 s_pub_sch_comment = vc
     2 s_asa = vc
     2 s_case_level = vc
     2 s_admit_dt_tm = vc
     2 s_fin_class = vc
     2 s_gender = vc
     2 l_ce_cnt = i4
     2 ce_qual[*]
       3 s_event_cd = vc
       3 s_result = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM surgical_case sc,
   person p,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   surg_case_procedure scp,
   prsnl pr,
   prsnl_group pg
  PLAN (sc
   WHERE sc.surg_start_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND (sc.surg_area_cd= $F_SURG_AREA_CD)
    AND sc.surg_complete_qty=1
    AND sc.cancel_reason_cd=0)
   JOIN (p
   WHERE p.person_id=sc.person_id
    AND p.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id
    AND e.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id
    AND scp.primary_proc_ind=1
    AND scp.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=scp.primary_surgeon_id)
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(scp.surg_specialty_id)) )
  ORDER BY sc.surg_case_id
  HEAD sc.surg_case_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_surg_case_id = sc.surg_case_id, m_rec->qual[m_rec->l_cnt].s_fin = trim
   (ea1.alias,3), m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_pat_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->
   qual[m_rec->l_cnt].s_disch_dt = format(e.disch_dt_tm,"YYYY-MM-DD HH:mm:ss;;q"), m_rec->qual[m_rec
   ->l_cnt].s_prim_surgeon = trim(pr.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_prim_procedure = trim(uar_get_code_description(scp.surg_proc_cd),3),
   m_rec->qual[m_rec->l_cnt].s_prim_surgeon_specialty = trim(pg.prsnl_group_name,3), m_rec->qual[
   m_rec->l_cnt].s_case_nbr = trim(sc.surg_case_nbr_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_sched_priority = trim(uar_get_code_display(sc.sched_type_cd),3), m_rec
   ->qual[m_rec->l_cnt].s_surg_start_dt = format(sc.surg_start_dt_tm,"MM/DD/YYYY;;q"), m_rec->qual[
   m_rec->l_cnt].s_surg_sched_start_tm = format(sc.sched_start_dt_tm,"HH:mm;;q"),
   m_rec->qual[m_rec->l_cnt].s_operating_room = trim(uar_get_code_display(sc.surg_op_loc_cd),3),
   m_rec->qual[m_rec->l_cnt].s_surg_area = trim(uar_get_code_display(sc.sched_surg_area_cd),3),
   ml_day = - (1),
   ml_day = weekday(sc.surg_start_dt_tm)
   IF (ml_day=0)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Sunday"
   ELSEIF (ml_day=1)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Monday"
   ELSEIF (ml_day=2)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Tuesday"
   ELSEIF (ml_day=3)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Wednesday"
   ELSEIF (ml_day=4)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Thursday"
   ELSEIF (ml_day=5)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Friday"
   ELSEIF (ml_day=6)
    m_rec->qual[m_rec->l_cnt].s_case_start_day = "Saturday"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_case_craeted_dt_tm = format(e.create_dt_tm,"YYYY-MM-DD HH:mm:ss;;q")
   IF (sc.add_on_ind=0)
    m_rec->qual[m_rec->l_cnt].s_add_on_indicator = "No"
   ELSEIF (sc.add_on_ind=1)
    m_rec->qual[m_rec->l_cnt].s_add_on_indicator = "Yes"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_case_sched_duration = trim(cnvtstring(sc.sched_dur,20,0),3), m_rec->
   qual[m_rec->l_cnt].s_case_sched_patient_type = trim(uar_get_code_display(sc.sched_pat_type_cd),3),
   m_rec->qual[m_rec->l_cnt].s_delay_reason = "-",
   m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_age = trim(cnvtstring(floor(datetimediff(sc.surg_start_dt_tm,
       cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),9)),20,0),3),
   m_rec->qual[m_rec->l_cnt].s_asa = trim(uar_get_code_display(sc.asa_class_cd),3), m_rec->qual[m_rec
   ->l_cnt].s_case_level = trim(uar_get_code_display(sc.case_level_cd),3), m_rec->qual[m_rec->l_cnt].
   s_fin_class = trim(uar_get_code_display(e.financial_class_cd),3),
   m_rec->qual[m_rec->l_cnt].s_gender = trim(uar_get_code_display(p.sex_cd),3), m_rec->qual[m_rec->
   l_cnt].s_admit_dt_tm = format(e.reg_dt_tm,"YYYY-MM-DD HH:mm;;q")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_delay sd
  PLAN (sd
   WHERE expand(ml_idx1,1,m_rec->l_cnt,sd.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
    AND sd.active_ind=1)
  ORDER BY sd.surg_case_id
  HEAD sd.surg_case_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,sd.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id
    ), ml_delay_cnt = 0,
   CALL echo(sd.surg_case_id)
  DETAIL
   IF (ml_idx2 > 0)
    ml_delay_cnt += 1
    IF (ml_delay_cnt=1)
     m_rec->qual[ml_idx2].s_delay_reason = trim(uar_get_code_display(sd.delay_reason_cd),3)
    ELSE
     m_rec->qual[ml_idx2].s_delay_reason = concat(m_rec->qual[ml_idx2].s_delay_reason,"; ",trim(
       uar_get_code_display(sd.delay_reason_cd),3))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   perioperative_document pd,
   clinical_event ce
  PLAN (sc
   WHERE expand(ml_idx1,1,m_rec->l_cnt,sc.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id))
   JOIN (pd
   WHERE pd.surg_case_id=sc.surg_case_id)
   JOIN (ce
   WHERE ce.encntr_id=sc.encntr_id
    AND operator(ce.reference_nbr,"LIKE",concat(trim(cnvtstring(cnvtint(pd.periop_doc_id)),3),"%"))
    AND ce.event_cd IN (mf_cs72_sndeldescription_cd, mf_cs72_snpostopcomments_cd,
   mf_cs72_snpostopdestination_cd)
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND trim(ce.event_tag,3) != "Date\Time Correction"
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.record_status_cd=mf_cs48_active_cd)
  ORDER BY sc.surg_case_id, ce.event_cd, ce.performed_dt_tm DESC
  HEAD sc.surg_case_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,sc.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
  DETAIL
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_ce_cnt += 1, stat = alterlist(m_rec->qual[ml_idx2].ce_qual,m_rec->qual[
     ml_idx2].l_ce_cnt), m_rec->qual[ml_idx2].ce_qual[m_rec->qual[ml_idx2].l_ce_cnt].s_event_cd =
    trim(uar_get_code_display(ce.event_cd),3),
    m_rec->qual[ml_idx2].ce_qual[m_rec->qual[ml_idx2].l_ce_cnt].s_result = trim(ce.result_val,3)
    IF (ce.event_cd=mf_cs72_sndeldescription_cd)
     IF (size(trim(m_rec->qual[ml_idx2].s_del_desc,3))=0)
      m_rec->qual[ml_idx2].s_del_desc = trim(ce.result_val,3)
     ELSE
      m_rec->qual[ml_idx2].s_del_desc = concat(m_rec->qual[ml_idx2].s_del_desc," <> ",trim(ce
        .result_val,3))
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_snpostopdestination_cd)
     IF (size(trim(m_rec->qual[ml_idx2].s_postop_dest,3))=0)
      m_rec->qual[ml_idx2].s_postop_dest = trim(ce.result_val,3)
     ENDIF
    ELSEIF (ce.event_cd=mf_cs72_snpostopcomments_cd)
     IF (size(trim(m_rec->qual[ml_idx2].s_postop_comment,3))=0)
      m_rec->qual[ml_idx2].s_postop_comment = trim(ce.result_val,3)
     ELSE
      m_rec->qual[ml_idx2].s_postop_comment = concat(m_rec->qual[ml_idx2].s_postop_comment," <> ",
       trim(ce.result_val,3))
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].l_ce_cnt=0))
    SET m_rec->qual[ml_idx1].l_ce_cnt += 1
    SET stat = alterlist(m_rec->qual[ml_idx1].ce_qual,m_rec->qual[ml_idx1].l_ce_cnt)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM perioperative_document pd,
   code_value cv1,
   sn_doc_ref sdr,
   case_times ct,
   code_value cv2
  PLAN (pd
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pd.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
    AND pd.rec_ver_id > 0
    AND pd.doc_term_reason_cd=0)
   JOIN (cv1
   WHERE cv1.code_value=pd.doc_type_cd
    AND cv1.code_set=14258
    AND cv1.cdf_meaning="ORNURSE")
   JOIN (sdr
   WHERE sdr.doc_type_cd=pd.doc_type_cd
    AND sdr.area_cd=pd.surg_area_cd)
   JOIN (ct
   WHERE ct.surg_case_id=pd.surg_case_id
    AND ct.stage_cd IN (sdr.stage_cd, 0))
   JOIN (cv2
   WHERE cv2.code_value=ct.task_assay_cd
    AND cv2.code_set=14003
    AND cv2.active_ind=1
    AND cv2.cdf_meaning IN ("CT-PATINRM", "CT-PATOUTRM", "CT-SURGSTART", "CT-SURGSTOP"))
  ORDER BY pd.surg_case_id
  HEAD pd.surg_case_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pd.surg_case_id,m_rec->qual[ml_idx1].f_surg_case_id)
  DETAIL
   IF (ml_idx2 > 0)
    IF (cv2.cdf_meaning="CT-PATINRM")
     m_rec->qual[ml_idx2].f_in_rm = ct.case_time_dt_tm
    ELSEIF (cv2.cdf_meaning="CT-PATOUTRM")
     m_rec->qual[ml_idx2].f_out_rm = ct.case_time_dt_tm
    ELSEIF (cv2.cdf_meaning="CT-SURGSTART")
     m_rec->qual[ml_idx2].f_surg_start = ct.case_time_dt_tm
    ELSEIF (cv2.cdf_meaning="CT-SURGSTOP")
     m_rec->qual[ml_idx2].f_surg_stop = ct.case_time_dt_tm
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
  IF ((m_rec->qual[ml_idx1].f_in_rm > 0)
   AND (m_rec->qual[ml_idx1].f_out_rm > 0))
   SET m_rec->qual[ml_idx1].s_rm_tot_time = trim(cnvtstring(datetimediff(cnvtdatetime(m_rec->qual[
       ml_idx1].f_out_rm),cnvtdatetime(m_rec->qual[ml_idx1].f_in_rm),4),20,0),3)
  ENDIF
  IF ((m_rec->qual[ml_idx1].f_surg_start > 0)
   AND (m_rec->qual[ml_idx1].f_surg_stop > 0))
   SET m_rec->qual[ml_idx1].s_surg_tot_time = trim(cnvtstring(datetimediff(cnvtdatetime(m_rec->qual[
       ml_idx1].f_surg_stop),cnvtdatetime(m_rec->qual[ml_idx1].f_surg_start),4),20,0),3)
  ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM sn_comment_text sct,
   long_text lt
  PLAN (sct
   WHERE expand(ml_idx1,1,m_rec->l_cnt,sct.root_id,m_rec->qual[ml_idx1].f_surg_case_id)
    AND sct.root_name="SURGICAL_CASE"
    AND sct.active_ind=1
    AND sct.comment_type_cd=mf_cs16289_publicschedulingcomments_cd
    AND sct.long_text_id > 0)
   JOIN (lt
   WHERE lt.long_text_id=sct.long_text_id)
  ORDER BY sct.root_id, sct.long_text_id
  HEAD sct.root_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,sct.root_id,m_rec->qual[ml_idx1].f_surg_case_id)
  HEAD sct.long_text_id
   IF (ml_idx2 > 0)
    IF (size(trim(lt.long_text,3)) > 0)
     IF (size(trim(m_rec->qual[ml_idx2].s_pub_sch_comment,3))=0)
      m_rec->qual[ml_idx2].s_pub_sch_comment = replace(replace(trim(lt.long_text,3),char(13)," "),
       char(10)," ")
     ELSE
      m_rec->qual[ml_idx2].s_pub_sch_comment = concat(m_rec->qual[ml_idx2].s_pub_sch_comment," <> ",
       replace(replace(trim(lt.long_text,3),char(13)," "),char(10)," "))
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((m_rec->l_cnt > 0))
  SELECT INTO  $OUTDEV
   primary_surgeon = trim(substring(1,125,m_rec->qual[d.seq].s_prim_surgeon),3), surgical_specialty
    = trim(substring(1,125,m_rec->qual[d.seq].s_prim_surgeon_specialty),3), or_case_number = trim(
    substring(1,30,m_rec->qual[d.seq].s_case_nbr),3),
   patient_type = trim(substring(1,30,m_rec->qual[d.seq].s_pat_type),3), scheduled_patient_type =
   trim(substring(1,30,m_rec->qual[d.seq].s_case_sched_patient_type),3), schedule_priority = trim(
    substring(1,40,m_rec->qual[d.seq].s_sched_priority),3),
   primary_procedure = trim(substring(1,120,m_rec->qual[d.seq].s_prim_procedure),3), case_start_date
    = trim(substring(1,120,m_rec->qual[d.seq].s_surg_start_dt),3), scheduled_start_time = trim(
    substring(1,25,m_rec->qual[d.seq].s_surg_sched_start_tm),3),
   delay_reasons = trim(substring(1,250,m_rec->qual[d.seq].s_delay_reason),3), operating_room = trim(
    substring(1,50,m_rec->qual[d.seq].s_operating_room),3), surgical_area = trim(substring(1,50,m_rec
     ->qual[d.seq].s_surg_area),3),
   tot_surgery_minutes = trim(substring(1,10,m_rec->qual[d.seq].s_surg_tot_time),3),
   tot_pat_in_rm_minutes = trim(substring(1,10,m_rec->qual[d.seq].s_rm_tot_time),3), case_start_day
    = trim(substring(1,25,m_rec->qual[d.seq].s_case_start_day),3),
   case_created_date_time = trim(substring(1,25,m_rec->qual[d.seq].s_case_craeted_dt_tm),3),
   add_on_indicator = trim(substring(1,5,m_rec->qual[d.seq].s_add_on_indicator),3),
   scheduled_case_duration = trim(substring(1,25,m_rec->qual[d.seq].s_case_sched_duration),3),
   discharge_date_time = trim(substring(1,25,m_rec->qual[d.seq].s_disch_dt),3), delay_comments =
   replace(replace(trim(substring(1,500,m_rec->qual[d.seq].s_del_desc),3),char(010),""),char(013),""),
   postop_location = trim(substring(1,500,m_rec->qual[d.seq].s_postop_dest),3),
   postop_comments = replace(replace(trim(substring(1,500,m_rec->qual[d.seq].s_postop_comment),3),
     char(010),""),char(013),""), in_rm_dt_tm = trim(substring(1,25,trim(format(cnvtdatetime(m_rec->
        qual[d.seq].f_in_rm),"MM/DD/YYYY HH:mm;;q"),3)),3), out_of_rm_dt_tm = trim(substring(1,25,
     trim(format(cnvtdatetime(m_rec->qual[d.seq].f_out_rm),"MM/DD/YYYY HH:mm;;q"),3)),3),
   surgery_start_dt_tm = trim(substring(1,25,trim(format(cnvtdatetime(m_rec->qual[d.seq].f_surg_start
        ),"MM/DD/YYYY HH:mm;;q"),3)),3), surgery_stop_dt_tm = trim(substring(1,25,trim(format(
       cnvtdatetime(m_rec->qual[d.seq].f_surg_stop),"MM/DD/YYYY HH:mm;;q"),3)),3), patient_name =
   trim(substring(1,150,m_rec->qual[d.seq].s_pat_name),3),
   public_sched_comment = replace(replace(trim(substring(1,1000,m_rec->qual[d.seq].s_pub_sch_comment),
      3),char(010),""),char(013),""), fin = trim(substring(1,50,m_rec->qual[d.seq].s_fin),3), mrn =
   trim(substring(1,50,m_rec->qual[d.seq].s_mrn),3),
   dob = trim(substring(1,30,m_rec->qual[d.seq].s_dob),3), age = trim(substring(1,30,m_rec->qual[d
     .seq].s_age),3), admit_dt_tm = trim(substring(1,30,m_rec->qual[d.seq].s_admit_dt_tm),3),
   asa = trim(substring(1,50,m_rec->qual[d.seq].s_asa),3), case_level = trim(substring(1,50,m_rec->
     qual[d.seq].s_case_level),3), pt_fin_class = trim(substring(1,150,m_rec->qual[d.seq].s_fin_class
     ),3),
   gender = trim(substring(1,50,m_rec->qual[d.seq].s_gender),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   ORDER BY primary_surgeon, surgical_specialty, or_case_number
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", row 0, col 0,
    CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
    col 0,
    CALL print("Report completed. No qualifying data found."), row + 1,
    row 6, col 0,
    CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
      "mm/dd/yyyy hh:mm:ss;;q")))
   WITH nocounter, nullreport, maxcol = 300,
    dio = 08
  ;end select
 ENDIF
#exit_script
END GO
