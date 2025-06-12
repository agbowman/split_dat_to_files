CREATE PROGRAM al_bhs_rpt_pivie:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = value(999999),
  "Nurse Unit" = value(999999),
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, f_facility_cd, f_nurse_unit_cd,
  s_begin_date, s_end_date, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_reg_dt = vc
     2 s_facility = vc
     2 s_locs_dur_stay = vc
     2 grouper[*]
       3 s_periph_dc_reason = vc
       3 s_periph_line_insert_dt = vc
       3 s_periph_line_removal_dt = vc
       3 s_pivie_trained_rev = vc
       3 s_pivie_skin_color = vc
       3 s_pivie_blisters = vc
       3 s_pivie_distal_pulse = vc
       3 s_pivie_swelling = vc
       3 s_pivie_severity = vc
       3 s_pivie_infusate_name = vc
       3 s_pivie_infusate_color = vc
       3 s_pivie_dress_applied = vc
       3 s_pivie_medication = vc
       3 s_pivie_skin_other = vc
       3 s_dc_loc = vc
       3 f_periph_line_removal_dt = f8
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_periph_iv_insert_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVINSERTIONDATETIME"))
 DECLARE mf_periph_iv_dc_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVDCDATETIME"))
 DECLARE mf_periph_iv_dc_reason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PERIPHERALIVDCREASON"))
 DECLARE mf_trainedreviewer_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIETRAINEDREVIEWERCONTACTED"))
 DECLARE mf_skincolor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PIVIESKINCOLOR"
   ))
 DECLARE mf_skinother_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PIVIESKINOTHER"
   ))
 DECLARE mf_blisters_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PIVIEBLISTERS"))
 DECLARE mf_distalpulse_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIEDISTALPULSE"))
 DECLARE mf_swelling_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PIVIESWELLING"))
 DECLARE mf_severity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PIVIESEVERITY"))
 DECLARE mf_nameofinfusate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIENAMEOFINFUSATE"))
 DECLARE mf_infusatecolor_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIEINFUSATECOLOR"))
 DECLARE mf_medication_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIEMEDICATION"))
 DECLARE mf_dressingapplied_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PIVIEDRESSINGAPPLIED"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_expand = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE ml_grp_idx = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_PIVIE"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime(mf_begin_dt_tm) > cnvtdatetime(mf_end_dt_tm))
  SET ms_error = "Start date must be less than end date."
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 93)
  SET ms_error = "Date range exceeds 3 months."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_item_list = reflect(parameter(2,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(2,ml_loop))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(2,ml_loop))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(2,0))
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_nurse_unit_p = build2("elh.loc_nurse_unit_cd in (",parameter(3,ml_loop))
    ELSE
     SET ms_nurse_unit_p = build2(ms_nurse_unit_p,",",parameter(3,ml_loop))
    ENDIF
  ENDFOR
  SET ms_nurse_unit_p = concat(ms_nurse_unit_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_nurse_unit_p = build2("elh.loc_nurse_unit_cd = ",parameter(3,0))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_loc_hist elh
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd=mf_periph_iv_dc_reason_cd
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.publish_flag=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND parser(ms_facility_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND parser(ms_nurse_unit_p)
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd != 0
    AND elh.beg_effective_dt_tm != elh.end_effective_dt_tm)
  ORDER BY ce.encntr_id, ce.ce_dynamic_label_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD ce.encntr_id
   IF (((cnvtupper(ce.result_val) IN ("*DISCONT*INFILTRATE*", "*DISCONT*PHLEBITIS*", "*LEAKING*"))
    OR (((cnvtupper(ce.result_val) IN ("*COOL*TO*TOUCH*", "*EDEMATOUS*", "*ERYTHEMA*")) OR (cnvtupper
   (ce.result_val) IN ("*PAINFUL*"))) )) )
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->qual,5))
     CALL alterlist(m_rec->qual,(ml_cnt+ 99))
    ENDIF
    m_rec->qual[ml_cnt].f_encntr_id = ce.encntr_id, m_rec->qual[ml_cnt].s_facility =
    uar_get_code_display(e.loc_facility_cd), m_rec->qual[ml_cnt].s_reg_dt = trim(format(e.reg_dt_tm,
      "mm/dd/yyyy hh:mm:ss;;d"),3)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt=0))
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   person p,
   encntr_alias ea,
   ce_date_result cedr
  PLAN (ce
   WHERE expand(ml_expand,1,size(m_rec->qual,5),ce.encntr_id,m_rec->qual[ml_expand].f_encntr_id)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd IN (mf_periph_iv_dc_reason_cd, mf_periph_iv_insert_dt_cd, mf_periph_iv_dc_dt_cd,
   mf_trainedreviewer_cd, mf_skincolor_cd,
   mf_blisters_cd, mf_distalpulse_cd, mf_swelling_cd, mf_severity_cd, mf_nameofinfusate_cd,
   mf_infusatecolor_cd, mf_medication_cd, mf_dressingapplied_cd, mf_skinother_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.publish_flag=1)
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY ce.encntr_id, ce.ce_dynamic_label_id, ce.event_end_dt_tm,
   ce.performed_dt_tm
  HEAD REPORT
   ml_cnt = 0, ml_cnt2 = 0, ml_idx = 0
  HEAD ce.encntr_id
   ml_idx = locateval(ml_cnt,1,size(m_rec->qual,5),ce.encntr_id,m_rec->qual[ml_cnt].f_encntr_id),
   m_rec->qual[ml_idx].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[ml_idx].s_fin = trim(
    ea.alias,3)
  HEAD ce.ce_dynamic_label_id
   ml_cnt2 = (size(m_rec->qual[ml_idx].grouper,5)+ 1),
   CALL alterlist(m_rec->qual[ml_idx].grouper,ml_cnt2)
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_periph_iv_dc_reason_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_periph_dc_reason = trim(ce.result_val,3)
    OF mf_periph_iv_insert_dt_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_periph_line_insert_dt = trim(format(cedr.result_dt_tm,
       "mm/dd/yyyy hh:mm:ss;;d"),3)
    OF mf_periph_iv_dc_dt_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_periph_line_removal_dt = trim(format(cedr.result_dt_tm,
       "mm/dd/yyyy hh:mm:ss;;d"),3),m_rec->qual[ml_idx].grouper[ml_cnt2].f_periph_line_removal_dt =
     cedr.result_dt_tm
    OF mf_trainedreviewer_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_trained_rev = trim(ce.result_val,3)
    OF mf_skincolor_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_skin_color = trim(ce.result_val,3)
    OF mf_blisters_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_blisters = trim(ce.result_val,3)
    OF mf_distalpulse_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_distal_pulse = trim(ce.result_val,3)
    OF mf_swelling_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_swelling = trim(ce.result_val,3)
    OF mf_severity_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_severity = trim(ce.result_val,3)
    OF mf_nameofinfusate_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_infusate_name = trim(ce.result_val,3)
    OF mf_infusatecolor_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_infusate_color = trim(ce.result_val,3)
    OF mf_medication_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_medication = trim(ce.result_val,3)
    OF mf_dressingapplied_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_dress_applied = trim(ce.result_val,3)
    OF mf_skinother_cd:
     m_rec->qual[ml_idx].grouper[ml_cnt2].s_pivie_skin_other = trim(ce.result_val,3)
   ENDCASE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE expand(ml_cnt,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_cnt].f_encntr_id)
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd != 0
    AND elh.beg_effective_dt_tm != elh.end_effective_dt_tm)
  ORDER BY elh.encntr_id, elh.end_effective_dt_tm
  HEAD REPORT
   ml_idx = 0, ml_cnt2 = 0
  HEAD elh.encntr_id
   ml_idx = locateval(ml_cnt2,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_cnt2].f_encntr_id)
  HEAD elh.encntr_loc_hist_id
   FOR (ml_grp_idx = 1 TO size(m_rec->qual[ml_idx].grouper,5))
     IF ((m_rec->qual[ml_idx].grouper[ml_grp_idx].f_periph_line_removal_dt > 0)
      AND size(trim(m_rec->qual[ml_idx].grouper[ml_grp_idx].s_dc_loc,3))=0)
      IF (cnvtdatetime(m_rec->qual[ml_idx].grouper[ml_grp_idx].f_periph_line_removal_dt) BETWEEN
      cnvtdatetime(elh.beg_effective_dt_tm) AND cnvtdatetime(elh.end_effective_dt_tm))
       m_rec->qual[ml_idx].grouper[ml_grp_idx].s_dc_loc = trim(uar_get_code_display(elh
         .loc_nurse_unit_cd),3)
      ENDIF
     ENDIF
   ENDFOR
   IF (textlen(trim(m_rec->qual[ml_idx].s_locs_dur_stay,3))=0)
    IF (elh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     m_rec->qual[ml_idx].s_locs_dur_stay = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd),3),
      "(",trim(format(datetimediff(sysdate,elh.beg_effective_dt_tm),"#######.##;R"),3),")")
    ELSE
     m_rec->qual[ml_idx].s_locs_dur_stay = build2(trim(uar_get_code_display(elh.loc_nurse_unit_cd),3),
      "(",trim(format(datetimediff(elh.end_effective_dt_tm,elh.beg_effective_dt_tm),"#######.##;R"),3
       ),")")
    ENDIF
   ELSE
    IF (elh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     m_rec->qual[ml_idx].s_locs_dur_stay = build2(m_rec->qual[ml_idx].s_locs_dur_stay,", ",trim(
       uar_get_code_display(elh.loc_nurse_unit_cd),3),"(",trim(format(datetimediff(sysdate,elh
         .beg_effective_dt_tm),"#####.##;R"),3),
      ")")
    ELSE
     m_rec->qual[ml_idx].s_locs_dur_stay = build2(m_rec->qual[ml_idx].s_locs_dur_stay,", ",trim(
       uar_get_code_display(elh.loc_nurse_unit_cd),3),"(",trim(format(datetimediff(elh
         .end_effective_dt_tm,elh.beg_effective_dt_tm),"#####.##;R"),3),
      ")")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET ms_subject = build2("Vascular Access PIVIE Report ",trim(format(mf_begin_dt_tm,
     "mmm-dd-yyyy hh:mm ;;d"))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"ACCOUNT NUMBER",','"FACILITY",',
   '"NURSING UNIT WHEN THE PERIPHERAL IV DC REASON EVENT IS DOCUMENTED ",','"ADMIT DATE/TIME",',
   '"PERIPHERAL IV DC REASON",','"PERIPHERAL LINE INSERTION DT",','"PERIPHERAL LINE DISCONTINUE DT",',
   '"PIVIE TRAINED REVIEWER CONTACTED",','"PIVIE SKIN COLOR",',
   '"PIVIE SKIN OTHER",','"PIVIE BLISTERS",','"PIVIE DISTAL PULSE",','"PIVIE SWELLING",',
   '"PIVIE SEVERITY",',
   '"PIVIE NAME OF INFUSATE",','"PIVIE INFUSATE COLOR",','"PIVIE DRESSING APPLIED",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
    FOR (ml_cnt2 = 1 TO size(m_rec->qual[ml_cnt].grouper,5))
     SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
       ml_cnt].s_fin,3),'","',
      trim(m_rec->qual[ml_cnt].s_facility,3),'","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_dc_loc,
       3),'","',trim(m_rec->qual[ml_cnt].s_reg_dt,3),
      '","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_periph_dc_reason,3),'","',trim(m_rec->qual[
       ml_cnt].grouper[ml_cnt2].s_periph_line_insert_dt,3),'","',
      trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_periph_line_removal_dt,3),'","',trim(m_rec->qual[
       ml_cnt].grouper[ml_cnt2].s_pivie_trained_rev,3),'","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2
       ].s_pivie_skin_color,3),
      '","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_pivie_skin_other,3),'","',trim(m_rec->qual[
       ml_cnt].grouper[ml_cnt2].s_pivie_blisters,3),'","',
      trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_pivie_distal_pulse,3),'","',trim(m_rec->qual[ml_cnt
       ].grouper[ml_cnt2].s_pivie_swelling,3),'","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].
       s_pivie_severity,3),
      '","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_pivie_infusate_name,3),'","',trim(m_rec->
       qual[ml_cnt].grouper[ml_cnt2].s_pivie_infusate_color,3),'","',
      trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_pivie_dress_applied,3),'"',char(13))
     SET stat = cclio("WRITE",frec)
    ENDFOR
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,150,m_rec->qual[d.seq].s_pat_name), account_number = substring(1,50,
    m_rec->qual[d.seq].s_fin), facility = substring(1,50,m_rec->qual[d.seq].s_facility),
   nursing_unit_when_the_peripheral_iv_dc_reason_event_is_documented = substring(1,50,m_rec->qual[d
    .seq].grouper[d2.seq].s_dc_loc), admit_dt_tm = substring(1,50,m_rec->qual[d.seq].s_reg_dt),
   peripheral_iv_dc_reason = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_periph_dc_reason),
   peripheral_line_insertion_dt = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].
    s_periph_line_insert_dt), peripheral_line_discontinue_dt = substring(1,50,m_rec->qual[d.seq].
    grouper[d2.seq].s_periph_line_removal_dt), pivie_trained_reviewer_contacted = substring(1,50,
    m_rec->qual[d.seq].grouper[d2.seq].s_pivie_trained_rev),
   pivie_skin_color = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_skin_color),
   pivie_skin_other = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_skin_other),
   pivie_blisters = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_blisters),
   pivie_distal_pulse = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_distal_pulse),
   pivie_swelling = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_swelling),
   pivie_severity = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_severity),
   pivie_name_of_infusate = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_infusate_name),
   pivie_infusate_color = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_infusate_color),
   pivie_dressing_applied = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_pivie_dress_applied)
   FROM (dummyt d  WITH seq = m_rec->l_cnt),
    dummyt d2
   PLAN (d
    WHERE maxrec(d2,size(m_rec->qual[d.seq].grouper,5)))
    JOIN (d2)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (((mn_ops=1) OR (textlen(trim( $OUTDEV,3))=0)) )
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
