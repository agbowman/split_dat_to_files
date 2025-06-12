CREATE PROGRAM bhs_rpt_cmo_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 673936.00,
  "Begin Date" = "",
  "End Date" = "SYSDATE",
  "Recipients (Separate emails with a comma)" = ""
  WITH outdev, facility_cd, s_begin_date,
  s_end_date, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_bmc_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_cmo_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COMFORTMEASUREONLY"))
 DECLARE mf_cmos_order = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COMFORTMEASURESONLY"))
 CALL echo(build2("mf_CMOS_ORDER: ",mf_cmos_order))
 DECLARE mf_os_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cs71_prehosp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREHOSPICE"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant( $FACILITY_CD)
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtdatetime((curdate - 120),curtime3)
  SET mf_end_dt_tm = cnvtdatetime(sysdate)
  SET mf_facility_cd = mf_bmc_cd
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_CMO_ORDERS"
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
 IF (mf_begin_dt_tm > mf_end_dt_tm)
  SET ms_error = "Start Date must be less than End Date."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid"
  GO TO exit_script
 ENDIF
 IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
  SET ms_file_name = build("bhs_rpt_cmo_orders",format(mf_begin_dt_tm,"mm/dd/yy ;;d"),"_to",format(
    mf_end_dt_tm,"mm/dd/yy ;;d"),".csv")
  SET ms_file_name = replace(ms_file_name,"/","_",0)
  SET ms_file_name = replace(ms_file_name," ","_",0)
  SET ms_subject = build2("CMO Orders Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy;;d"))," to ",
   trim(format(mf_end_dt_tm,"mmm-dd-yyyy;;d")))
  SELECT INTO value(ms_file_name)
   FROM orders o,
    encounter e,
    order_action oa,
    person p,
    prsnl ps,
    encntr_alias ea,
    encntr_plan_reltn epr,
    organization org
   PLAN (o
    WHERE o.catalog_cd IN (mf_cmo_order_cd, mf_cmos_order)
     AND o.order_status_cd=mf_os_ordered_cd)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND e.disch_dt_tm = null
     AND e.loc_facility_cd=mf_facility_cd
     AND e.active_ind=1
     AND e.encntr_type_cd != mf_cs71_prehosp)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=mf_order_cd
     AND oa.action_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.active_ind=1
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND epr.priority_seq=1)
    JOIN (org
    WHERE (org.organization_id= Outerjoin(epr.organization_id)) )
    JOIN (ps
    WHERE ps.person_id=oa.action_personnel_id)
   ORDER BY oa.action_dt_tm, e.reg_dt_tm, p.name_last
   HEAD REPORT
    ms_temp = concat("PATIENT_FULL_NAME,ACC_NUMBER,REG_DATE_TIME,ORDERED_BY",
     ",CMO_ORDER_DATE,LENGTH_OF_STAY,LOCATION,PAYOR"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build('"',trim(p.name_full_formatted),'",','"',trim(ea.alias),
     '",','"',trim(format(e.reg_dt_tm,"mm/dd/yyyy hh:mm ;;d")),'",','"',
     trim(ps.name_full_formatted),'",','"',trim(format(oa.action_dt_tm,"mm/dd/yyyy hh:mm ;;d")),'",',
     '"',trim(format(datetimediff(cnvtdatetime(sysdate),e.reg_dt_tm),"DD Days HH Hours;;Z")),'",','"',
     concat(trim(uar_get_code_display(e.loc_facility_cd)),"/",trim(uar_get_code_display(e
        .loc_nurse_unit_cd)),"/",trim(uar_get_code_display(e.loc_room_cd))),
     '",','"',trim(org.org_name),'"'), col 0,
    ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 5000
  ;end select
  IF (curqual=0)
   SET ms_error = "No data found."
   IF (mn_ops=1)
    CALL uar_send_mail("CIScore@bhs.org","OPS Job Fail",build2(
      "bhs_rpt_cmo_orders ops job executed in ",curdomain," - no data was found"),"OPS JOB",1,
     "")
   ENDIF
   GO TO exit_script
  ENDIF
  EXECUTE bhs_ma_email_file
  CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   patient_full_name = p.name_full_formatted, acc_number = ea.alias, reg_date_time = format(e
    .reg_dt_tm,"mm/dd/yyyy hh:mm ;;d"),
   ordered_by = ps.name_full_formatted, cmo_order_date = format(oa.action_dt_tm,
    "mm/dd/yyyy hh:mm ;;d"), length_of_stay = format(datetimediff(cnvtdatetime(sysdate),e.reg_dt_tm),
    "DD Days HH Hours;;Z"),
   location = concat(trim(uar_get_code_display(e.loc_facility_cd)),"/",trim(uar_get_code_display(e
      .loc_nurse_unit_cd)),"/",trim(uar_get_code_display(e.loc_room_cd))), payor = org.org_name
   FROM orders o,
    encounter e,
    order_action oa,
    person p,
    prsnl ps,
    encntr_alias ea,
    encntr_plan_reltn epr,
    organization org
   PLAN (o
    WHERE o.catalog_cd IN (mf_cmo_order_cd, mf_cmos_order)
     AND o.order_status_cd=mf_os_ordered_cd)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND e.disch_dt_tm = null
     AND e.loc_facility_cd=mf_facility_cd
     AND e.active_ind=1
     AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND e.encntr_type_cd != mf_cs71_prehosp)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=mf_order_cd
     AND oa.action_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mf_fin_cd
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.active_ind=1
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND epr.priority_seq=1)
    JOIN (org
    WHERE (org.organization_id= Outerjoin(epr.organization_id)) )
    JOIN (ps
    WHERE ps.person_id=oa.action_personnel_id)
   ORDER BY oa.action_dt_tm, e.reg_dt_tm, p.name_last
   WITH nocounter, separator = " ", format
  ;end select
  IF (curqual=0)
   SET ms_error = "No data found."
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen( $S_RECIPIENTS) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, msg2 = "  Please try again.", row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
 ENDIF
END GO
