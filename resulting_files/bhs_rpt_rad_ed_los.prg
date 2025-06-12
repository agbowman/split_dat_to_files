CREATE PROGRAM bhs_rpt_rad_ed_los
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Exam Complete Start" = "CURDATE",
  "Exam Complete End" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3958"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3957"))
 DECLARE mf_cs221_bmcct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",221,"BMCCT"))
 DECLARE mf_cs221_bmcedct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",221,"BMCEDCT"))
 DECLARE mf_cs221_bmcmri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",221,"BMCMRI"))
 DECLARE mf_cs200_ct3drendwopostproc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT 3D Rend W/O Post Proc"))
 DECLARE mf_cs200_ct3drendwpostproc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT 3D Rend W/ Post Proc"))
 DECLARE mf_cs200_ctguidanceneedle_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Guidance Needle"))
 DECLARE mf_cs200_ctguidanceplacementrxfield_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",
   200,"CT Guidance Placement Rx Field"))
 DECLARE mf_cs200_ctguidancestereotacticlocal_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAY",200,"CT Guidance Stereotactic Local"))
 DECLARE mf_cs200_ctguidancetissueablation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",
   200,"CT Guidance Tissue Ablation"))
 DECLARE mf_cs200_ctguideabdparacentesis_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Guide Abd Paracentesis"))
 DECLARE mf_cs200_ctguideablationbonetumorsperc_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAY",200,"CT Guide Ablation bone tumor(s), perc."))
 DECLARE mf_cs200_ctguideablationchest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Guide Ablation Chest"))
 DECLARE mf_cs200_ctguidecryoablatebonetumorsperc_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAY",200,"CT Guide Cryoablate bone tumor(s), perc"))
 DECLARE mf_cs200_ctguidecryoablationunilat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",
   200,"CT Guide Cryo Ablation Unilat"))
 DECLARE mf_cs200_ctguidecryotherapychest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",
   200,"CT Guide Cryotherapy Chest"))
 DECLARE mf_cs200_ctltdorlocalization_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Ltd or Localization"))
 DECLARE mf_cs200_ctoutsidefilmconsult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Outside Film Consult"))
 DECLARE mf_cs200_ctoutsideimages_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Outside Images"))
 DECLARE mf_cs200_ctpercvertebroplasty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Perc Vertebroplasty"))
 DECLARE mf_cs200_ctperfusion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Perfusion"))
 DECLARE mf_cs200_ctpleuraldrainagewdwellingcath_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAY",200,"CT Pleural Drainage w/dwelling cath"))
 DECLARE mf_cs200_ctpunchaspircystbreast_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Punch/Aspir Cyst Breast"))
 DECLARE mf_cs200_ctradguideperdrainwplace_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",
   200,"CT Rad Guide Per Drain W/ Place"))
 DECLARE mf_cs200_cttubepericardiostomy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT Tube Pericardiostomy"))
 DECLARE mf_cs200_ctusimageguidebiopsy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT/ US Image Guide Biopsy"))
 DECLARE mf_cs200_ctusimageguidedrain_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "CT/ US Image Guide Drain"))
 DECLARE mf_cs200_mrioutsidefilmconsult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "MRI Outside Film Consult"))
 DECLARE mf_cs200_outsideimagesir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Outside Images-IR"))
 DECLARE mf_cs200_outsideimagesmm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Outside Images-MM"))
 DECLARE mf_cs200_outsideimagesmri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Outside Images-MRI"))
 DECLARE mf_cs200_outsideimagesnm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Outside Images-NM"))
 DECLARE mf_cs200_outsideimagesus_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Outside Images-US"))
 DECLARE mf_cs200_usoutsidefilmconsult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "US Outside Film Consult"))
 DECLARE mf_cs200_xrcarm1hour1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "XR C-Arm < 1 Hour"))
 DECLARE mf_cs200_xrcarm1hour2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "XR C-Arm > 1 Hour"))
 DECLARE mf_cs200_xroutsidefilmconsultdiagrad_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAY",200,"XR Outside Film Consult (Diag Rad)"))
 DECLARE mf_cs200_xroutsideimagesdiagrad_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "XR Outside Images-Diag Rad"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
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
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_person_id = f8
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
     2 s_addendum = vc
     2 s_final_dt = vc
     2 s_order_dt = vc
     2 s_start_dt = vc
     2 s_exam_room = vc
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_priority = vc
     2 s_comment = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM omf_radmgmt_order_st oros,
   encounter enc,
   order_radiology orad3,
   (left JOIN omf_radreport_st orrs ON orrs.order_id != 0.00
    AND ((orad3.parent_order_id > 0.00
    AND orrs.order_id=orad3.parent_order_id) OR (orrs.order_id=orad3.order_id)) ),
   encntr_alias ea1,
   encntr_alias ea2,
   person_alias pa
  WHERE ((oros.procedure_type_flag=1
   AND oros.precomplete_cancel_ind=0) OR (orrs.final_dt_tm IS NOT null
   AND oros.tat_qual_ind=1
   AND oros.procedure_type_flag IN (0, 2)))
   AND orad3.order_id=oros.order_id
   AND oros.encntr_id=enc.encntr_id
   AND oros.exam_complete_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
   AND oros.encntr_type_at_exam_cmplt_cd IN (mf_cs71_inpatient_cd, mf_cs71_emergency_cd)
   AND oros.section_cd IN (mf_cs221_bmcct_cd, mf_cs221_bmcedct_cd, mf_cs221_bmcmri_cd)
   AND  NOT (oros.catalog_cd IN (mf_cs200_ct3drendwopostproc_cd, mf_cs200_ct3drendwpostproc_cd,
  mf_cs200_ctguidanceneedle_cd, mf_cs200_ctguidanceplacementrxfield_cd,
  mf_cs200_ctguidancestereotacticlocal_cd,
  mf_cs200_ctguidancetissueablation_cd, mf_cs200_ctguideabdparacentesis_cd,
  mf_cs200_ctguideablationbonetumorsperc_cd, mf_cs200_ctguideablationchest_cd,
  mf_cs200_ctguidecryoablatebonetumorsperc_cd,
  mf_cs200_ctguidecryoablationunilat_cd, mf_cs200_ctguidecryotherapychest_cd,
  mf_cs200_ctltdorlocalization_cd, mf_cs200_ctoutsidefilmconsult_cd, mf_cs200_ctoutsideimages_cd,
  mf_cs200_ctpercvertebroplasty_cd, mf_cs200_ctperfusion_cd,
  mf_cs200_ctpleuraldrainagewdwellingcath_cd, mf_cs200_ctpunchaspircystbreast_cd,
  mf_cs200_ctradguideperdrainwplace_cd,
  mf_cs200_cttubepericardiostomy_cd, mf_cs200_ctusimageguidebiopsy_cd,
  mf_cs200_ctusimageguidedrain_cd, mf_cs200_mrioutsidefilmconsult_cd, mf_cs200_outsideimagesir_cd,
  mf_cs200_outsideimagesmm_cd, mf_cs200_outsideimagesmri_cd, mf_cs200_outsideimagesnm_cd,
  mf_cs200_outsideimagesus_cd, mf_cs200_usoutsidefilmconsult_cd,
  mf_cs200_xrcarm1hour1_cd, mf_cs200_xrcarm1hour2_cd, mf_cs200_xroutsidefilmconsultdiagrad_cd,
  mf_cs200_xroutsideimagesdiagrad_cd))
   AND ea1.encntr_id=enc.encntr_id
   AND ea1.active_ind=1
   AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd
   AND ea2.encntr_id=enc.encntr_id
   AND ea2.active_ind=1
   AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd
   AND pa.person_id=enc.person_id
   AND pa.active_ind=1
   AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND pa.person_alias_type_cd=mf_cs4_cmrn_cd
  ORDER BY oros.order_id, orrs.omf_radreport_st_id DESC, pa.beg_effective_dt_tm DESC
  HEAD oros.order_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = enc.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = enc.person_id, m_rec->qual[m_rec->l_cnt].f_order_id = oros
   .order_id, m_rec->qual[m_rec->l_cnt].s_institution = trim(uar_get_code_display(oros.perf_inst_cd),
    3),
   m_rec->qual[m_rec->l_cnt].s_pat_type_at_exam = trim(uar_get_code_display(oros
     .encntr_type_at_exam_cmplt_cd),3), m_rec->qual[m_rec->l_cnt].s_year_complete = trim(cnvtstring(
     year(oros.exam_complete_dt_tm),20,0),3)
   IF (month(oros.exam_complete_dt_tm)=1)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "01-January"
   ELSEIF (month(oros.exam_complete_dt_tm)=2)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "02-February"
   ELSEIF (month(oros.exam_complete_dt_tm)=3)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "03-March"
   ELSEIF (month(oros.exam_complete_dt_tm)=4)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "04-April"
   ELSEIF (month(oros.exam_complete_dt_tm)=5)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "05-May"
   ELSEIF (month(oros.exam_complete_dt_tm)=6)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "06-June"
   ELSEIF (month(oros.exam_complete_dt_tm)=7)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "07-July"
   ELSEIF (month(oros.exam_complete_dt_tm)=8)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "08-August"
   ELSEIF (month(oros.exam_complete_dt_tm)=9)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "09-September"
   ELSEIF (month(oros.exam_complete_dt_tm)=10)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "10-October"
   ELSEIF (month(oros.exam_complete_dt_tm)=11)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "11-November"
   ELSEIF (month(oros.exam_complete_dt_tm)=12)
    m_rec->qual[m_rec->l_cnt].s_month_complete = "12-December"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_month_complete = "-"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_accession = trim(oros.accession_nbr,3), m_rec->qual[m_rec->l_cnt].
   s_hrs_of_day_complete = trim(cnvtstring(floor((oros.exam_complete_min_nbr/ 60)),20,0)), m_rec->
   qual[m_rec->l_cnt].s_order_procedure = trim(uar_get_code_display(oros.catalog_cd),3)
   IF (weekday(oros.exam_complete_dt_tm) IN (0, 7))
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Sunday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=1)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Monday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=2)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Tuesday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=3)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Wednesday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=4)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Thursday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=5)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Friday"
   ELSEIF (weekday(oros.exam_complete_dt_tm)=6)
    m_rec->qual[m_rec->l_cnt].s_day_of_week_complete = "Saturday"
   ENDIF
   m_rec->qual[m_rec->l_cnt].l_day_of_week_complete = weekday(oros.exam_complete_dt_tm), m_rec->qual[
   m_rec->l_cnt].s_exam_complete_dt = format(oros.exam_complete_dt_tm,"MM/DD/YYYY;;q"), m_rec->qual[
   m_rec->l_cnt].s_addendum = trim(cnvtstring(orrs.report_status_flag,20,0),3),
   m_rec->qual[m_rec->l_cnt].s_final_dt = format(orrs.final_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->
   qual[m_rec->l_cnt].s_order_dt = format(oros.order_dt_tm,"MM/DD/YYYY HH:mm;;q"), m_rec->qual[m_rec
   ->l_cnt].s_start_dt = format(oros.start_dt_tm,"MM/DD/YYYY HH:mm;;q"),
   m_rec->qual[m_rec->l_cnt].s_exam_room = trim(uar_get_code_display(oros.exam_room_cd),3), m_rec->
   qual[m_rec->l_cnt].s_cmrn = trim(pa.alias,3), m_rec->qual[m_rec->l_cnt].s_mrn = trim(ea2.alias,3),
   m_rec->qual[m_rec->l_cnt].s_fin = trim(ea1.alias,3), m_rec->qual[m_rec->l_cnt].s_priority = trim(
    uar_get_code_display(oros.priority_cd),3)
  WITH nocounter
 ;end select
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM order_comment oc,
   long_text lt
  PLAN (oc
   WHERE expand(ml_idx1,1,m_rec->l_cnt,oc.order_id,m_rec->qual[ml_idx1].f_order_id))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind=1)
  ORDER BY oc.order_id, oc.action_sequence DESC, lt.long_text_id
  HEAD oc.order_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,oc.order_id,m_rec->qual[ml_idx1].f_order_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_comment = trim(lt.long_text,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO  $OUTDEV
  institution = trim(substring(1,60,m_rec->qual[d.seq].s_institution),3), patient_type_at_exam = trim
  (substring(1,30,m_rec->qual[d.seq].s_pat_type_at_exam),3), year_complete = trim(substring(1,10,
    m_rec->qual[d.seq].s_year_complete),3),
  month_complte = trim(substring(1,15,m_rec->qual[d.seq].s_month_complete),3), accession = trim(
   substring(1,50,m_rec->qual[d.seq].s_accession),3), hour_of_day_complete = trim(substring(1,50,
    m_rec->qual[d.seq].s_hrs_of_day_complete),3),
  order_procedure = trim(substring(1,100,m_rec->qual[d.seq].s_order_procedure),3),
  day_of_week_complete = trim(substring(1,15,m_rec->qual[d.seq].s_day_of_week_complete),3),
  exam_complete_date = trim(substring(1,20,m_rec->qual[d.seq].s_exam_complete_dt),3),
  final_dt_tm = trim(substring(1,20,m_rec->qual[d.seq].s_final_dt),3), ordered_dt_tm = trim(substring
   (1,20,m_rec->qual[d.seq].s_order_dt),3), start_dt_tm = trim(substring(1,20,m_rec->qual[d.seq].
    s_start_dt),3),
  exam_room = trim(substring(1,60,m_rec->qual[d.seq].s_exam_room),3), mrn = trim(substring(1,20,m_rec
    ->qual[d.seq].s_mrn),3), cmrn = trim(substring(1,20,m_rec->qual[d.seq].s_cmrn),3),
  financial_number = trim(substring(1,20,m_rec->qual[d.seq].s_fin),3), priority = trim(substring(1,50,
    m_rec->qual[d.seq].s_priority),3), order_comment = replace(replace(trim(substring(1,2000,m_rec->
      qual[d.seq].s_comment),3),char(13)," "),char(10)," ")
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  PLAN (d)
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
