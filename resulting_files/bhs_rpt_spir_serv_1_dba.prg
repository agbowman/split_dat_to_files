CREATE PROGRAM bhs_rpt_spir_serv_1:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date" = "CURDATE",
  "Output to screen:" = 0,
  "Send to email" = 1,
  "Enter email address:" = ""
  WITH outdev, s_beg_dt, s_end_dt,
  n_chk_screen, n_chk_email, s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_mrn = vc
     2 enc[*]
       3 f_encntr_id = f8
       3 s_admit_dt_tm = vc
       3 s_religion = vc
       3 s_nurse_unit = vc
       3 s_room_bed = vc
       3 ord[*]
         4 f_order_id = f8
         4 s_reason = vc
         4 s_ordered_by = vc
         4 s_ordering_pos = vc
         4 s_order_dt_tm = vc
         4 s_order_status = vc
         4 s_complete_dt_tm = vc
       3 form[*]
         4 s_beliefs = vc
         4 s_practices = vc
         4 s_support = vc
         4 s_preference = vc
         4 s_entered_by = vc
         4 s_describespiritualneeds = vc
   1 nurs[*]
     2 f_nurse_unit_cd = f8
     2 s_disp = vc
 ) WITH protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_spir_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTSPIRITUALSERVICES"))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mn_screen_out = i2 WITH protect, constant( $N_CHK_SCREEN)
 DECLARE mn_email_out = i2 WITH protect, constant( $N_CHK_EMAIL)
 DECLARE ms_email_to = vc WITH protect, constant(trim( $S_EMAIL))
 DECLARE ms_email_file = vc WITH protect, constant(concat("bhs_spir1_",trim(format(sysdate,
     "mmddyy_hhmm;;d")),".csv"))
 DECLARE mf_belief_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALBELIEFS"))
 DECLARE mf_practices_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPRACTICES"))
 DECLARE mf_support_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REQUESTSSPIRITUALSUPPORT"))
 DECLARE mf_prefs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPREFERENCE"))
 DECLARE mf_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SPIRITUALSERVICESREASON"))
 DECLARE mf_describespiritualneeds = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DESCRIBESPIRITUALNEEDS")), protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_bmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmc_psych_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("BMC", "BMCINPTPSYCH")
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  HEAD cv.display_key
   IF (cv.display_key="BMC")
    mf_bmc_cd = cv.code_value
   ELSEIF (cv.display_key="BMCINPTPSYCH")
    mf_bmc_psych_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get nurse units")
 SELECT INTO "nl:"
  lg2.child_loc_cd, ps_disp = uar_get_code_display(lg2.child_loc_cd)
  FROM location_group lg1,
   location_group lg2,
   code_value cv
  PLAN (lg1
   WHERE lg1.parent_loc_cd IN (mf_bmc_cd, mf_bmc_psych_cd)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning="NURSEUNIT"
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  ORDER BY ps_disp
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, stat = alterlist(m_rec->nurs,pl_cnt), m_rec->nurs[pl_cnt].f_nurse_unit_cd = cv
   .code_value,
   m_rec->nurs[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 CALL echo("get patients")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p,
   bhs_demographics b
  PLAN (ed
   WHERE ((ed.loc_facility_cd+ 0) IN (mf_bmc_cd, mf_bmc_psych_cd))
    AND expand(ml_cnt,1,size(m_rec->nurs,5),ed.loc_nurse_unit_cd,m_rec->nurs[ml_cnt].f_nurse_unit_cd)
    AND ((ed.active_ind+ 0)=1)
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_obs_cd, mf_ed_cd, mf_day_cd)
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((elh.active_ind+ 0)=1)
    AND ((elh.loc_nurse_unit_cd+ 0)=ed.loc_nurse_unit_cd)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (b
   WHERE (b.person_id= Outerjoin(p.person_id))
    AND (b.active_ind= Outerjoin(1))
    AND (trim(b.description)= Outerjoin("religion")) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  ORDER BY ed.loc_nurse_unit_cd, p.person_id
  HEAD REPORT
   pl_per = 0, pl_enc = 0
  HEAD p.person_id
   pl_enc = 0, pl_per += 1
   IF (pl_per > size(m_rec->pat,5))
    stat = alterlist(m_rec->pat,(pl_per+ 10))
   ENDIF
   m_rec->pat[pl_per].f_person_id = p.person_id, m_rec->pat[pl_per].s_pat_name = trim(p
    .name_full_formatted), m_rec->pat[pl_per].s_mrn = trim(ea.alias)
  HEAD e.encntr_id
   pl_enc += 1
   IF (pl_enc > size(m_rec->pat[pl_per].enc,5))
    stat = alterlist(m_rec->pat[pl_per].enc,(pl_enc+ 10))
   ENDIF
   m_rec->pat[pl_per].enc[pl_enc].f_encntr_id = e.encntr_id, m_rec->pat[pl_per].enc[pl_enc].
   s_admit_dt_tm = trim(format(e.reg_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_rec->pat[pl_per].enc[pl_enc].
   s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd)),
   m_rec->pat[pl_per].enc[pl_enc].s_room_bed = concat(trim(uar_get_code_display(e.loc_room_cd))," ",
    trim(uar_get_code_display(e.loc_bed_cd))), m_rec->pat[pl_per].enc[pl_enc].s_religion = trim(b
    .display)
  FOOT  p.person_id
   stat = alterlist(m_rec->pat[pl_per].enc,pl_enc)
  FOOT REPORT
   stat = alterlist(m_rec->pat,pl_per)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echo("get orders")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   orders o,
   order_action oa,
   order_detail od,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.person_id=m_rec->pat[d1.seq].f_person_id)
    AND o.catalog_cd=mf_spir_consult_cd
    AND ((o.encntr_id+ 0)=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND o.template_order_id=0
    AND o.orig_ord_as_flag=0)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_reason_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id
    AND p.active_ind=1)
  ORDER BY d1.seq, d2.seq
  HEAD REPORT
   pl_cnt = 0
  HEAD o.person_id
   pl_cnt = 0
  HEAD o.encntr_id
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1, stat = alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,pl_cnt), m_rec->pat[d1.seq].enc[
   d2.seq].ord[pl_cnt].f_order_id = o.order_id,
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,
     "mm/dd/yyyy hh:mm;;d")), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_order_status = trim(
    uar_get_code_display(o.order_status_cd)), m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ordered_by
    = trim(p.name_full_formatted),
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ordering_pos = trim(uar_get_code_display(p
     .position_cd))
   IF (o.order_status_cd=mf_completed_cd)
    m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_complete_dt_tm = trim(format(o.active_status_dt_tm,
      "mm/dd/yyyy;;d"))
   ENDIF
  DETAIL
   m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_reason = trim(od.oe_field_display_value)
  WITH nocounter
 ;end select
 CALL echo("get dtas grouped by form")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt d2,
   clinical_event ce,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.person_id=m_rec->pat[d1.seq].f_person_id)
    AND ((ce.encntr_id+ 0)=m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id)
    AND ce.event_cd IN (mf_belief_cd, mf_practices_cd, mf_support_cd, mf_prefs_cd,
   mf_describespiritualneeds)
    AND ce.event_end_dt_tm > cnvtdatetime(m_rec->pat[d1.seq].enc[d2.seq].s_admit_dt_tm)
    AND ce.valid_until_dt_tm > sysdate
    AND  NOT (trim(ce.result_val) IN (null, "", " ")))
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND p.active_ind=1)
  ORDER BY ce.person_id, ce.encntr_id, ce.parent_event_id
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.person_id
   pl_cnt = 0
  HEAD ce.encntr_id
   pl_cnt = 0
  HEAD ce.parent_event_id
   pl_cnt += 1, stat = alterlist(m_rec->pat[d1.seq].enc[d2.seq].form,pl_cnt), m_rec->pat[d1.seq].enc[
   d2.seq].form[pl_cnt].s_entered_by = trim(p.name_full_formatted)
  DETAIL
   IF (ce.event_cd=mf_belief_cd)
    m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_beliefs = trim(ce.result_val)
   ELSEIF (ce.event_cd=mf_practices_cd)
    m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_practices = trim(ce.result_val)
   ELSEIF (ce.event_cd=mf_support_cd)
    m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_preference = trim(ce.result_val)
   ELSEIF (ce.event_cd=mf_prefs_cd)
    m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_support = trim(ce.result_val)
   ELSEIF (ce.event_cd=mf_describespiritualneeds)
    m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_describespiritualneeds = replace(replace(ce
      .result_val,char(10)," ",0),char(13)," ")
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_email_out=1)
  CALL echo("email is checked")
  SELECT INTO value(ms_email_file)
   pf_person_id = m_rec->pat[d1.seq].f_person_id, ps_pat_name = m_rec->pat[d1.seq].s_pat_name,
   pf_encntr_id = m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
    JOIN (d2)
   ORDER BY ps_pat_name, pf_encntr_id
   HEAD REPORT
    pl_cnt = 0, pl_maxrow = 0, ms_tmp = concat(
     "Patient_Name,MRN,Current_Location,Location,Admit_Date,Religion,Order_ID,",
     "Reason_for_Consult,Ordered_by,Ordering_position,Order_Dt_Tm,Order_Status,Entered_By,Religious/Spiritual_Beliefs,",
     "Religigous/Spiritual_Practices,Religious/Spiritual_Support,Religious/Spiritual_Preferences,",
     "Describe_Religious/Spiritual_Needs ,Completion_Dt_Tm"),
    col 0, row 0, ms_tmp
   HEAD pf_encntr_id
    pl_maxrow = size(m_rec->pat[d1.seq].enc[d2.seq].form,5)
    IF (pl_maxrow < size(m_rec->pat[d1.seq].enc[d2.seq].ord,5))
     pl_maxrow = size(m_rec->pat[d1.seq].enc[d2.seq].ord,5), stat = alterlist(m_rec->pat[d1.seq].enc[
      d2.seq].form,pl_maxrow)
    ELSE
     stat = alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,pl_maxrow)
    ENDIF
    IF (pl_maxrow > 0)
     FOR (pl_cnt = 1 TO pl_maxrow)
       ms_tmp = concat('"',m_rec->pat[d1.seq].s_pat_name,'","',m_rec->pat[d1.seq].s_mrn,'","',
        m_rec->pat[d1.seq].enc[d2.seq].s_nurse_unit,'","',m_rec->pat[d1.seq].enc[d2.seq].s_room_bed,
        '","',m_rec->pat[d1.seq].enc[d2.seq].s_admit_dt_tm,
        '","',m_rec->pat[d1.seq].enc[d2.seq].s_religion,'","',trim(cnvtstring(m_rec->pat[d1.seq].enc[
          d2.seq].ord[pl_cnt].f_order_id)),'","',
        m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_reason,'","',m_rec->pat[d1.seq].enc[d2.seq].ord[
        pl_cnt].s_ordered_by,'","',m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ordering_pos,
        '","',m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_order_dt_tm,'","',m_rec->pat[d1.seq].enc[
        d2.seq].ord[pl_cnt].s_order_status,'","',
        m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_entered_by,'","',m_rec->pat[d1.seq].enc[d2.seq]
        .form[pl_cnt].s_beliefs,'","',m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_practices,
        '","',m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_preference,'","',m_rec->pat[d1.seq].enc[
        d2.seq].form[pl_cnt].s_support,'","',
        m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_describespiritualneeds,'","',m_rec->pat[d1.seq]
        .enc[d2.seq].ord[pl_cnt].s_complete_dt_tm,'"'), col 0, row + 1,
       ms_tmp
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, maxcol = 10000,
    format, separator = " "
  ;end select
  CALL echo("sending email")
  EXECUTE bhs_sys_stand_subroutine
  CALL emailfile(ms_email_file,ms_email_file,ms_email_to,concat("Spiritual Services Rpt1 - ",trim(
     format(sysdate,"mm-dd-yy hh:mm;;d"))),1)
  IF (mn_screen_out=0)
   SELECT INTO  $OUTDEV
    HEAD REPORT
     col 0, "Emailed file ", ms_email_file,
     " to ", ms_email_to
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (mn_screen_out=1)
  SELECT INTO value(ms_output)
   pf_person_id = m_rec->pat[d1.seq].f_person_id, ps_pat_name = m_rec->pat[d1.seq].s_pat_name,
   pf_encntr_id = m_rec->pat[d1.seq].enc[d2.seq].f_encntr_id
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->pat[d1.seq].enc,5)))
    JOIN (d2)
   ORDER BY ps_pat_name, pf_encntr_id
   HEAD REPORT
    pl_col = 0, pl_cnt = 0, pl_maxrow = 0,
    col pl_col, "Patient_Name", pl_col += 50,
    col pl_col, "MRN", pl_col += 50,
    col pl_col, "Current_Location", pl_col += 50,
    col pl_col, "Location", pl_col += 50,
    col pl_col, "Admit_Date", pl_col += 50,
    col pl_col, "Religion", pl_col += 50,
    col pl_col, "Order_ID", pl_col += 50,
    col pl_col, "Reason_for_Consult", pl_col += 50,
    col pl_col, "Ordered_by", pl_col += 50,
    col pl_col, "Ordering_position", pl_col += 50,
    col pl_col, "Order_Dt_Tm", pl_col += 50,
    col pl_col, "Order_Status", pl_col += 50,
    col pl_col, "Entered_By", pl_col += 50,
    col pl_col, "Religious/Spiritual_Beliefs", pl_col += 50,
    col pl_col, "Religigous/Spiritual_Practices", pl_col += 50,
    col pl_col, "Religious/Spiritual_Support", pl_col += 50,
    col pl_col, "Religious/Spiritual_Preferences", pl_col += 50,
    col pl_col, "Describe_Religious/Spiritual_Needs", pl_col += 50,
    col pl_col, "Completion_Dt_Tm", pl_col += 150
   HEAD pf_encntr_id
    pl_maxrow = size(m_rec->pat[d1.seq].enc[d2.seq].form,5)
    IF (pl_maxrow < size(m_rec->pat[d1.seq].enc[d2.seq].ord,5))
     pl_maxrow = size(m_rec->pat[d1.seq].enc[d2.seq].ord,5), stat = alterlist(m_rec->pat[d1.seq].enc[
      d2.seq].form,pl_maxrow)
    ELSE
     stat = alterlist(m_rec->pat[d1.seq].enc[d2.seq].ord,pl_maxrow)
    ENDIF
    IF (pl_maxrow > 0)
     FOR (pl_cnt = 1 TO pl_maxrow)
       row + 1, pl_col = 0, col pl_col,
       m_rec->pat[d1.seq].s_pat_name, pl_col += 50, col pl_col,
       m_rec->pat[d1.seq].s_mrn, pl_col += 50, col pl_col,
       m_rec->pat[d1.seq].enc[d2.seq].s_nurse_unit, pl_col += 50, col pl_col,
       m_rec->pat[d1.seq].enc[d2.seq].s_room_bed, pl_col += 50, col pl_col,
       m_rec->pat[d1.seq].enc[d2.seq].s_admit_dt_tm, pl_col += 50, col pl_col,
       m_rec->pat[d1.seq].enc[d2.seq].s_religion, pl_col += 50, ms_tmp = trim(cnvtstring(m_rec->pat[
         d1.seq].enc[d2.seq].ord[pl_cnt].f_order_id)),
       col pl_col, ms_tmp, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_reason, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ordered_by, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_ordering_pos, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_order_dt_tm, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_order_status, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_entered_by, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_beliefs, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_practices, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_preference, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_support, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].form[pl_cnt].s_describespiritualneeds, pl_col += 50,
       col pl_col, m_rec->pat[d1.seq].enc[d2.seq].ord[pl_cnt].s_complete_dt_tm, pl_col += 150
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, maxcol = 10000,
    format, separator = " "
  ;end select
  SELECT INTO "nl:"
   DETAIL
    row + 0
   WITH skipreport = value(1)
  ;end select
 ENDIF
#exit_script
 FREE RECORD m_rec
END GO
