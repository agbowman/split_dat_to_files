CREATE PROGRAM bhs_rpt_central_line:dba
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
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_length_of_stay = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_reg_dt = vc
     2 s_discharge_dt = vc
     2 s_location = vc
     2 s_locs_dur_stay = vc
     2 s_service_line = vc
     2 s_weight = vc
     2 s_inserter = vc
     2 s_insertion_dt = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_race_2nd = vc
     2 s_ethnicity_2nd = vc
     2 s_attend = vc
     2 s_hispanic_ind = vc
     2 grouper[*]
       3 f_dyn_label_id = f8
       3 f_insert_dt = f8
       3 f_central_line_disc_dt = f8
       3 s_central_line_days = vc
       3 s_catheter_type = vc
       3 s_dly_discussion = vc
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_active_stat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_date_class_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DATE"))
 DECLARE mf_service_lvl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SERVICELEVELOPTIONS"))
 DECLARE mf_stat_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT"))
 DECLARE mf_stat_inp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSINPATIENT"))
 DECLARE mf_lvl_of_care_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LEVELOFCARE"
   ))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_central_line_disc_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEDISCONTINUEDATE"))
 DECLARE mf_central_line_insert_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEINSERTIONDATETIME"))
 DECLARE mf_inserter_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INSERTEROFVASCULARACCESS"))
 DECLARE mf_insertion_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATEOFVASCULARACCESSINSERTION"))
 DECLARE mf_centrallineactivity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEACTIVITY"))
 DECLARE mf_catheter_type_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Central Line Catheter Type:"))
 DECLARE mf_cs72_central_iv_dlydisc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "CENTRALLINEDAILYDISCUSSION")), protect
 DECLARE mf_cs355_user_def_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,
   "USERDEFINED"))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs333_attending = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
  ), protect
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(((curdate - day(curdate))+ 1),000000))
  SET mf_end_dt_tm = cnvtdatetime((curdate - day(curdate)),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_CENTRAL_LINE"
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
  SET ms_error = "Start date must be before the end date."
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
   encntr_loc_hist elh,
   ce_date_result cedr,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl att
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd IN (mf_central_line_insert_dt_cd, mf_centrallineactivity_cd)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1
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
    AND elh.active_ind=1)
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce.event_id)) )
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(e.encntr_id))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(mf_cs333_attending))
    AND (epr.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (epr.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (att
   WHERE (att.person_id= Outerjoin(epr.prsnl_person_id))
    AND (att.active_ind= Outerjoin(1))
    AND (att.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.person_id, e.encntr_id, ce.ce_dynamic_label_id,
   ce.event_end_dt_tm DESC, ce.performed_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  HEAD e.encntr_id
   ml_cnt2 = 0, ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_person_id = e.person_id, m_rec->qual[ml_cnt].f_encntr_id = e.encntr_id,
   m_rec->qual[ml_cnt].s_pat_name = p.name_full_formatted,
   m_rec->qual[ml_cnt].s_location = build2(trim(uar_get_code_display(e.loc_facility_cd),3),"/",trim(
     uar_get_code_display(e.loc_nurse_unit_cd),3)), m_rec->qual[ml_cnt].s_fin = ea.alias, m_rec->
   qual[ml_cnt].s_reg_dt = trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),3),
   m_rec->qual[ml_cnt].s_discharge_dt = trim(format(e.disch_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),3), m_rec
   ->qual[ml_cnt].f_length_of_stay = evaluate(e.disch_dt_tm,null,datetimediff(sysdate,e.reg_dt_tm),
    datetimediff(e.disch_dt_tm,e.reg_dt_tm)), m_rec->qual[ml_cnt].s_attend = trim(att
    .name_full_formatted)
  HEAD ce.ce_dynamic_label_id
   ml_cnt2 += 1,
   CALL alterlist(m_rec->qual[ml_cnt].grouper,ml_cnt2), m_rec->qual[ml_cnt].grouper[ml_cnt2].
   f_dyn_label_id = ce.ce_dynamic_label_id
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pl_sort =
  IF (pi.info_sub_type_cd=mf_cs356_race1) 1
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race2) 2
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race3) 3
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race4) 4
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race5) 5
  ENDIF
  FROM (dummyt d  WITH seq = value(size(m_rec->qual,5))),
   person_info pi
  PLAN (d)
   JOIN (pi
   WHERE (pi.person_id=m_rec->qual[d.seq].f_person_id)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def_cd
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5))
  ORDER BY d.seq, pl_sort
  DETAIL
   IF (textlen(trim(m_rec->qual[d.seq].s_race,3))=0)
    m_rec->qual[d.seq].s_race = trim(uar_get_code_display(pi.value_cd),3)
    IF (pi.info_sub_type_cd=mf_cs356_race2)
     m_rec->qual[d.seq].s_race_2nd = trim(uar_get_code_display(pi.value_cd),3)
    ENDIF
   ELSEIF (pi.value_cd > 0.0)
    m_rec->qual[d.seq].s_race = concat(m_rec->qual[d.seq].s_race,", ",trim(uar_get_code_display(pi
       .value_cd),3))
    IF (pi.info_sub_type_cd=mf_cs356_race2)
     m_rec->qual[d.seq].s_race_2nd = trim(uar_get_code_display(pi.value_cd),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pl_sort =
  IF (trim(bd.description,3)="ethnicity 1") 1
  ELSE 2
  ENDIF
  FROM (dummyt d  WITH seq = value(size(m_rec->qual,5))),
   bhs_demographics bd
  PLAN (d)
   JOIN (bd
   WHERE (bd.person_id=m_rec->qual[d.seq].f_person_id)
    AND bd.active_ind=1
    AND bd.end_effective_dt_tm > sysdate)
  ORDER BY d.seq, pl_sort
  DETAIL
   IF (trim(bd.description,3)="ethnicity 1")
    m_rec->qual[d.seq].s_ethnicity = trim(uar_get_code_display(bd.code_value),3)
   ELSEIF (trim(bd.description,3)="ethnicity 2")
    IF (textlen(trim(m_rec->qual[d.seq].s_ethnicity,3))=0)
     m_rec->qual[d.seq].s_ethnicity = trim(uar_get_code_display(bd.code_value),3), m_rec->qual[d.seq]
     .s_ethnicity_2nd = trim(uar_get_code_display(bd.code_value),3)
    ELSE
     m_rec->qual[d.seq].s_ethnicity = concat(m_rec->qual[d.seq].s_ethnicity,", ",trim(
       uar_get_code_display(bd.code_value),3)), m_rec->qual[d.seq].s_ethnicity_2nd = trim(
      uar_get_code_display(bd.code_value),3)
    ENDIF
   ELSEIF (trim(bd.description,3)="hispanic ind")
    m_rec->qual[d.seq].s_hispanic_ind = trim(bd.display,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_date_result cedr
  PLAN (ce
   WHERE expand(ml_cnt,1,m_rec->l_cnt,ce.encntr_id,m_rec->qual[ml_cnt].f_encntr_id)
    AND ce.event_cd IN (mf_central_line_insert_dt_cd, mf_weight_cd, mf_catheter_type_cd,
   mf_central_line_disc_dt_cd, mf_inserter_cd,
   mf_cs72_central_iv_dlydisc, mf_insertion_dt_cd)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.publish_flag=1)
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY ce.person_id, ce.encntr_id, ce.ce_dynamic_label_id,
   ce.event_end_dt_tm, ce.performed_dt_tm
  HEAD ce.encntr_id
   ml_idx = locateval(ml_cnt2,1,m_rec->l_cnt,ce.encntr_id,m_rec->qual[ml_cnt2].f_encntr_id)
  HEAD ce.ce_dynamic_label_id
   ml_idx2 = locateval(ml_cnt2,1,size(m_rec->qual[ml_idx].grouper,5),ce.ce_dynamic_label_id,m_rec->
    qual[ml_idx].grouper[ml_cnt2].f_dyn_label_id)
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_weight_cd:
     m_rec->qual[ml_idx].s_weight = ce.result_val
    OF mf_inserter_cd:
     m_rec->qual[ml_idx].s_inserter = ce.result_val
    OF mf_insertion_dt_cd:
     m_rec->qual[ml_idx].s_insertion_dt = trim(format(cedr.result_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
    OF mf_central_line_insert_dt_cd:
     m_rec->qual[ml_idx].grouper[ml_idx2].f_insert_dt = cedr.result_dt_tm
    OF mf_catheter_type_cd:
     m_rec->qual[ml_idx].grouper[ml_idx2].s_catheter_type = ce.result_val
    OF mf_central_line_disc_dt_cd:
     m_rec->qual[ml_idx].grouper[ml_idx2].f_central_line_disc_dt = cedr.result_dt_tm
    OF mf_cs72_central_iv_dlydisc:
     m_rec->qual[ml_idx].grouper[ml_idx2].s_dly_discussion = trim(ce.result_val,3)
   ENDCASE
  FOOT  ce.ce_dynamic_label_id
   IF ((m_rec->qual[ml_idx].grouper[ml_idx2].f_central_line_disc_dt != null)
    AND (m_rec->qual[ml_idx].grouper[ml_idx2].f_insert_dt != null))
    m_rec->qual[ml_idx].grouper[ml_idx2].s_central_line_days = trim(cnvtstring(datetimediff(m_rec->
       qual[ml_idx].grouper[ml_idx2].f_central_line_disc_dt,m_rec->qual[ml_idx].grouper[ml_idx2].
       f_insert_dt)),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE expand(ml_cnt,1,m_rec->l_cnt,o.encntr_id,m_rec->qual[ml_cnt].f_encntr_id)
    AND o.catalog_cd IN (mf_stat_obs_cd, mf_stat_inp_cd, mf_lvl_of_care_cd)
    AND o.active_ind=1
    AND o.active_status_cd=mf_active_stat_cd)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_service_lvl_cd)
  ORDER BY o.encntr_id, o.orig_order_dt_tm
  HEAD o.encntr_id
   ml_idx = locateval(ml_cnt2,1,m_rec->l_cnt,o.encntr_id,m_rec->qual[ml_cnt2].f_encntr_id), m_rec->
   qual[ml_idx].s_service_line = od.oe_field_display_value
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
  HEAD elh.encntr_id
   ml_idx = locateval(ml_cnt2,1,m_rec->l_cnt,elh.encntr_id,m_rec->qual[ml_cnt2].f_encntr_id)
  HEAD elh.encntr_loc_hist_id
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
  SET ms_subject = build2("Central Line Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"ACCOUNT NUMBER",','"LOCATION",',
   '"LOCATIONS DURING STAY",','"ADMIT DATE/TIME",',
   '"PROVIDER",','"LENGTH OF STAY",','"SERVICE LINE",','"WEIGHT (KG)",',
   '"CENTRAL LINE INSERT DATE/TIME",',
   '"CENTRAL LINE DAYS",','"CATHETER TYPE",','"CENTRAL LINE DISCONTINUE DATE/TIME",',
   '"DISCHARGE DATE/TIME",','"INSERTER",',
   '"DATE OF INSERTION",','"CENTRAL_LINE_DAILY_DISCUSSION",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
    FOR (ml_cnt2 = 1 TO size(m_rec->qual[ml_cnt].grouper,5))
     SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
       ml_cnt].s_fin,3),'","',
      trim(m_rec->qual[ml_cnt].s_location,3),'","',trim(m_rec->qual[ml_cnt].s_locs_dur_stay,3),'","',
      trim(m_rec->qual[ml_cnt].s_reg_dt,3),
      '","',trim(m_rec->qual[ml_cnt].s_attend,3),'","',trim(cnvtstring(m_rec->qual[ml_cnt].
        f_length_of_stay),3),'","',
      trim(m_rec->qual[ml_cnt].s_service_line,3),'","',trim(m_rec->qual[ml_cnt].s_weight,3),'","',
      trim(format(m_rec->qual[ml_cnt].grouper[ml_cnt2].f_insert_dt,"mm/dd/yyyy hh:mm;;d"),3),
      '","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2].s_central_line_days,3),'","',trim(m_rec->qual[
       ml_cnt].grouper[ml_cnt2].s_catheter_type,3),'","',
      trim(format(m_rec->qual[ml_cnt].grouper[ml_cnt2].f_central_line_disc_dt,"mm/dd/yyyy hh:mm;;d"),
       3),'","',trim(m_rec->qual[ml_cnt].s_discharge_dt,3),'","',trim(m_rec->qual[ml_cnt].s_inserter,
       3),
      '","',trim(m_rec->qual[ml_cnt].s_insertion_dt,3),'","',trim(m_rec->qual[ml_cnt].grouper[ml_cnt2
       ].s_dly_discussion,3),'"',
      char(13))
     SET stat = cclio("WRITE",frec)
    ENDFOR
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,50,m_rec->qual[d.seq].s_pat_name), race = substring(1,150,m_rec->qual[d
    .seq].s_race), ethnicity = substring(1,75,m_rec->qual[d.seq].s_ethnicity),
   secondary_race = substring(1,150,m_rec->qual[d.seq].s_race_2nd), secondary_ethnicity = substring(1,
    75,m_rec->qual[d.seq].s_ethnicity_2nd), hispanic_ind = substring(1,5,m_rec->qual[d.seq].
    s_hispanic_ind),
   account_number = substring(1,50,m_rec->qual[d.seq].s_fin), location = substring(1,50,m_rec->qual[d
    .seq].s_location), locations_during_stay = substring(1,500,m_rec->qual[d.seq].s_locs_dur_stay),
   admit_dt_tm = substring(1,50,m_rec->qual[d.seq].s_reg_dt), provider = substring(1,50,m_rec->qual[d
    .seq].s_attend), length_of_stay = m_rec->qual[d.seq].f_length_of_stay,
   service_line = substring(1,50,m_rec->qual[d.seq].s_service_line), weight_kg = substring(1,50,m_rec
    ->qual[d.seq].s_weight), central_line_insert_dt_tm = trim(format(m_rec->qual[d.seq].grouper[d2
     .seq].f_insert_dt,"mm/dd/yyyy hh:mm;;d"),3),
   central_line_days = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_central_line_days),
   catheter_type = substring(1,50,m_rec->qual[d.seq].grouper[d2.seq].s_catheter_type),
   central_line_discontinue_dt_tm = trim(format(m_rec->qual[d.seq].grouper[d2.seq].
     f_central_line_disc_dt,"mm/dd/yyyy hh:mm;;d"),3),
   discharge_dt_tm = substring(1,50,m_rec->qual[d.seq].s_discharge_dt), inserter = substring(1,50,
    m_rec->qual[d.seq].s_inserter), date_of_insertion = substring(1,50,m_rec->qual[d.seq].
    s_insertion_dt),
   daily_discussion = substring(1,200,m_rec->qual[d.seq].grouper[d2.seq].s_dly_discussion)
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
