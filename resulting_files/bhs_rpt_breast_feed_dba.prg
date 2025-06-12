CREATE PROGRAM bhs_rpt_breast_feed:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 999999,
  "Nurse Unit" = value(634529558.00,999999),
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
   1 f_birth_cnt = f8
   1 f_cesarean_cnt = f8
   1 f_vaginal_cnt = f8
   1 f_other_cnt = f8
   1 f_formula_all_cnt = f8
   1 f_ex_breastmilk_all_cnt = f8
   1 f_any_breastmilk_all_cnt = f8
   1 f_any_breastmilk_vag_cnt = f8
   1 f_any_breastmilk_ces_cnt = f8
   1 s_ex_breastmilk_all_pct = vc
   1 s_any_breastmilk_all_pct = vc
   1 s_formula_all_pct = vc
   1 s_any_breastmilk_vag_pct = vc
   1 s_any_breastmilk_ces_pct = vc
   1 qual[*]
     2 n_qual_ind = i2
     2 s_pat_name = vc
     2 s_cmrn = vc
     2 s_location = vc
     2 s_feeding_plan = vc
     2 s_feeding_dc = vc
     2 s_delivery_dt = vc
     2 s_delivery_type = vc
 ) WITH protect
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_active_stat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_nb_feeding_plan_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FEEDINGPLANSNEWBORN"))
 DECLARE mf_ex_feeding_dc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EXCLUSIVEBREASTFEEDINGATDISCHARGE"))
 DECLARE mf_delivery_dt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYDATE"
   ))
 DECLARE mf_delivery_type_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",72,
   "Delivery type"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
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
  SET mf_begin_dt_tm = datetimefind(cnvtdatetime((curdate - 15),0),"M","B","B")
  SET mf_end_dt_tm = datetimefind(cnvtdatetime((curdate - 15),0),"M","E","E")
  SET ms_subject = build2("Breast Feeding Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"
     ))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_BREAST_FEED"
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
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1)
  SET ms_subject = build2("Breast Feeding Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d"
     ))," to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm;;d")))
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
  SET ms_facility_p = "e.loc_facility_cd in ("
  FOR (ml_loop = 1 TO ml_cnt)
    SET ms_facility_p = build2(ms_facility_p,cnvtstring(parameter(2,ml_loop)),",")
  ENDFOR
  SET ms_facility_p = concat(substring(1,(textlen(ms_facility_p) - 1),ms_facility_p),")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(2,0))
 ENDIF
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  SET ms_nurse_unit_p = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ms_nurse_unit_p = "e.loc_nurse_unit_cd in ("
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    SET ms_nurse_unit_p = concat(ms_nurse_unit_p,cnvtstring(parameter(3,ml_loop)),",")
  ENDFOR
  SET ms_nurse_unit_p = concat(substring(1,(textlen(ms_nurse_unit_p) - 1),ms_nurse_unit_p),")")
 ELSE
  SET ms_nurse_unit_p = concat("e.loc_nurse_unit_cd = ",cnvtstring( $F_NURSE_UNIT_CD))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   person p,
   person_alias pa,
   prsnl pr,
   ce_date_result cedr
  PLAN (ce
   WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.event_cd IN (mf_nb_feeding_plan_cd, mf_ex_feeding_dc_cd, mf_delivery_dt_cd,
   mf_delivery_type_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_cmrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND pa.active_status_cd=mf_active_stat_cd)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (cedr
   WHERE (cedr.event_id= Outerjoin(ce.event_id)) )
  ORDER BY e.encntr_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0, m_rec->l_cnt = 0, m_rec->f_birth_cnt = 0,
   m_rec->f_cesarean_cnt = 0, m_rec->f_vaginal_cnt = 0
  HEAD ce.encntr_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->qual[ml_cnt].s_cmrn = trim(
    pa.alias,3), m_rec->qual[ml_cnt].s_location = build2(trim(uar_get_code_display(e.loc_facility_cd),
     3),"/",trim(uar_get_code_display(e.loc_nurse_unit_cd),3))
  HEAD ce.event_id
   CASE (ce.event_cd)
    OF mf_nb_feeding_plan_cd:
     IF (textlen(m_rec->qual[ml_cnt].s_feeding_plan)=0)
      m_rec->qual[ml_cnt].s_feeding_plan = trim(ce.result_val,3)
     ENDIF
    OF mf_delivery_dt_cd:
     IF (textlen(m_rec->qual[ml_cnt].s_delivery_dt)=0)
      m_rec->qual[ml_cnt].s_delivery_dt = trim(format(cedr.result_dt_tm,"mm/dd/yy HH:mm;;d"),3)
     ENDIF
    OF mf_delivery_type_cd:
     IF (textlen(m_rec->qual[ml_cnt].s_delivery_type)=0)
      m_rec->qual[ml_cnt].s_delivery_type = trim(ce.result_val,3)
     ENDIF
    OF mf_ex_feeding_dc_cd:
     IF (textlen(m_rec->qual[ml_cnt].s_feeding_dc)=0)
      m_rec->qual[ml_cnt].s_feeding_dc = trim(ce.result_val,3)
     ENDIF
   ENDCASE
  FOOT  ce.encntr_id
   IF (textlen(trim(m_rec->qual[ml_cnt].s_delivery_dt,3)) > 0)
    m_rec->qual[ml_cnt].n_qual_ind = 1
   ENDIF
  FOOT REPORT
   m_rec->l_cnt = ml_cnt,
   CALL alterlist(m_rec->qual,m_rec->l_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_rec->l_cnt)
  PLAN (d
   WHERE (m_rec->qual[d.seq].n_qual_ind=1))
  HEAD d.seq
   m_rec->f_birth_cnt += 1
   CASE (cnvtupper(m_rec->qual[d.seq].s_feeding_dc))
    OF "*PARTIAL BREASTFEEDING/BREASTMILK*":
     m_rec->f_any_breastmilk_all_cnt += 1
    OF "*YES, EXCLUSIVE BREASTFEEDING/BREASTMILK*":
     m_rec->f_any_breastmilk_all_cnt += 1,m_rec->f_ex_breastmilk_all_cnt += 1
    OF "*NO BREASTFEEDING/BREASTMILK, FORMULA FEEDING*":
     m_rec->f_formula_all_cnt += 1
   ENDCASE
   IF (cnvtupper(m_rec->qual[d.seq].s_delivery_type)="*VAGINAL*")
    m_rec->f_vaginal_cnt += 1
    IF (cnvtupper(m_rec->qual[d.seq].s_feeding_dc) IN ("*YES, EXCLUSIVE BREASTFEEDING*",
    "*PARTIAL BREASTFEEDING/BREASTMILK*"))
     m_rec->f_any_breastmilk_vag_cnt += 1
    ENDIF
   ELSEIF (cnvtupper(m_rec->qual[d.seq].s_delivery_type) IN ("*C-SECTION*", "*CESAREAN*"))
    m_rec->f_cesarean_cnt += 1
    IF (cnvtupper(m_rec->qual[d.seq].s_feeding_dc) IN ("*YES, EXCLUSIVE BREASTFEEDING*",
    "*PARTIAL BREASTFEEDING/BREASTMILK*"))
     m_rec->f_any_breastmilk_ces_cnt += 1
    ENDIF
   ENDIF
  FOOT REPORT
   m_rec->l_cnt += 10,
   CALL alterlist(m_rec->qual,m_rec->l_cnt)
   FOR (ml_loop = 0 TO 9)
     m_rec->qual[(m_rec->l_cnt - ml_loop)].n_qual_ind = 1
   ENDFOR
   m_rec->f_other_cnt = (m_rec->f_birth_cnt - (m_rec->f_vaginal_cnt+ m_rec->f_cesarean_cnt)), m_rec->
   s_any_breastmilk_all_pct = trim(format(((m_rec->f_any_breastmilk_all_cnt/ m_rec->f_birth_cnt) *
     100),"###.##%;R"),3), m_rec->s_any_breastmilk_vag_pct = trim(format(((m_rec->
     f_any_breastmilk_vag_cnt/ m_rec->f_vaginal_cnt) * 100),"###.##%;R"),3),
   m_rec->s_any_breastmilk_ces_pct = trim(format(((m_rec->f_any_breastmilk_ces_cnt/ m_rec->
     f_cesarean_cnt) * 100),"###.##%;R"),3), m_rec->s_ex_breastmilk_all_pct = trim(format(((m_rec->
     f_ex_breastmilk_all_cnt/ m_rec->f_birth_cnt) * 100),"###.##%;R"),3), m_rec->s_formula_all_pct
    = trim(format(((m_rec->f_formula_all_cnt/ m_rec->f_birth_cnt) * 100),"###.##%;R"),3),
   m_rec->qual[(m_rec->l_cnt - 8)].s_pat_name = build2("Total Births: ",trim(cnvtstring(m_rec->
      f_birth_cnt),3)), m_rec->qual[(m_rec->l_cnt - 7)].s_pat_name = build2("Total Cesarean: ",trim(
     cnvtstring(m_rec->f_cesarean_cnt),3)), m_rec->qual[(m_rec->l_cnt - 6)].s_pat_name = build2(
    "Total Vaginal: ",trim(cnvtstring(m_rec->f_vaginal_cnt),3)),
   m_rec->qual[(m_rec->l_cnt - 5)].s_pat_name = build2("Total Other: ",trim(cnvtstring(m_rec->
      f_other_cnt),3)), m_rec->qual[(m_rec->l_cnt - 4)].s_pat_name = build2(
    "PCT of Exclusive Breastmilk of all Births: ",m_rec->s_ex_breastmilk_all_pct), m_rec->qual[(m_rec
   ->l_cnt - 3)].s_pat_name = build2("PCT of Any Breastmilk of all Births: ",m_rec->
    s_any_breastmilk_all_pct),
   m_rec->qual[(m_rec->l_cnt - 2)].s_pat_name = build2("PCT of Formula of all Births: ",m_rec->
    s_formula_all_pct), m_rec->qual[(m_rec->l_cnt - 1)].s_pat_name = build2(
    "PCT of Any Breastmilk of all Vaginal Births: ",m_rec->s_any_breastmilk_vag_pct), m_rec->qual[
   m_rec->l_cnt].s_pat_name = build2("PCT of Any Breastmilk of all Cesarean Births: ",m_rec->
    s_any_breastmilk_ces_pct)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(mf_begin_dt_tm,"mm_dd_yy ;;d"),3),
   "_to_",trim(format(mf_end_dt_tm,"mm_dd_yy;;d"),3),
   ".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PATIENT NAME",','"PATIENT CMRN",','"LOCATION",',
   '"NEWBORN FEEDING PLAN",','"EXCLUSIVE BREASTFEEDING AT DISCHARGE",',
   '"DELIVERY DT/TM",','"DELIVERY TYPE",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
    IF ((m_rec->qual[ml_cnt].n_qual_ind=1))
     SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_pat_name,3),'","',trim(m_rec->qual[
       ml_cnt].s_cmrn,3),'","',
      trim(m_rec->qual[ml_cnt].s_location,3),'","',trim(m_rec->qual[ml_cnt].s_feeding_plan,3),'","',
      trim(m_rec->qual[ml_cnt].s_feeding_dc,3),
      '","',trim(m_rec->qual[ml_cnt].s_delivery_dt,3),'","',trim(m_rec->qual[ml_cnt].s_delivery_type,
       3),'"',
      char(13))
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,100,m_rec->qual[d.seq].s_pat_name), patient_cmrn = substring(1,100,
    m_rec->qual[d.seq].s_cmrn), location = substring(1,100,m_rec->qual[d.seq].s_location),
   newborn_feeding_plan = substring(1,100,m_rec->qual[d.seq].s_feeding_plan),
   exclusive_breastfeeding_at_dc = substring(1,100,m_rec->qual[d.seq].s_feeding_dc), delivery_dt_tm
    = substring(1,100,m_rec->qual[d.seq].s_delivery_dt),
   delivery_type = substring(1,100,m_rec->qual[d.seq].s_delivery_type)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   WHERE (m_rec->qual[d.seq].n_qual_ind=1)
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
