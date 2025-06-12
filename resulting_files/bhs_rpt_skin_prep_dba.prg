CREATE PROGRAM bhs_rpt_skin_prep:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm:" = "SYSDATE",
  "End dt/tm:" = "SYSDATE",
  "Surgical Unit:" = value(588640212.00,588640265.00),
  "Surgical Specialty:" = value(594974763.00),
  "Recipients (Separate emails with a comma)" = ""
  WITH outdev, s_begin_date, s_end_date,
  f_surg_unit, f_specialty, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 RECORD data(
   1 patients[*]
     2 s_patient_name = vc
     2 f_patient_id = f8
     2 f_encntr_id = f8
     2 f_ce_event_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_surgeon_name = vc
     2 s_powerform_completed = vc
     2 s_surgical_unit = vc
     2 s_skin_prep_at_home = vc
     2 s_surgery = vc
     2 s_skin_prep_in_preop_complete = vc
 ) WITH protect
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_ma_email_file
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_dcp_generic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DCPGENERICCODE"))
 DECLARE mf_skin_prep_at_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SKINPREPATHOME"))
 DECLARE mf_skin_prep_in_preop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SKINPREPINPREOPCOMPLETE"))
 DECLARE mf_prep_focused_assessment_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREOPFOCUSEDASSESSMENTBHS"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num1 = i4 WITH protect, noconstant(0)
 DECLARE ml_num2 = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ms_surg_unit_p = vc WITH protect, noconstant(" ")
 DECLARE ms_specialty_p = vc WITH protect, noconstant(" ")
 DECLARE ms_date_range = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  IF (day(curdate)=1)
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(curdate,000000),0)
   SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  ELSE
   SET mf_begin_dt_tm = cnvtlookbehind(build2('"',day((curdate - 1)),', D"'),cnvtdatetime(curdate,
     000000),0)
   SET mf_begin_dt_tm = cnvtlookbehind("1, M",cnvtdatetime(mf_begin_dt_tm),0)
   SET mf_end_dt_tm = cnvtlookbehind(build2('"',day(curdate),', D"'),cnvtdatetime(curdate,000000),0)
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_SKIN_PREP"
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
 ELSEIF (datetimediff(cnvtdatetime(mf_end_dt_tm),cnvtdatetime(mf_begin_dt_tm)) > 366)
  SET ms_error = "Date range exceeds 1 year."
  GO TO exit_script
 ELSEIF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 SET ms_data_type = reflect(parameter(4,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_temp = cnvtstring(parameter(4,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_surg_unit_p = concat("sc.surg_area_cd in(",trim(ms_temp))
   ELSE
    SET ms_surg_unit_p = concat(ms_surg_unit_p,", ",trim(ms_temp))
   ENDIF
  ENDFOR
  SET ms_surg_unit_p = concat(ms_surg_unit_p,")")
 ELSEIF (parameter(4,1)=999999)
  SET ms_surg_unit_p = "1=1"
 ELSE
  SET ms_surg_unit_p = cnvtstring(parameter(4,1),20)
  SET ms_surg_unit_p = concat("sc.surg_area_cd = ",trim(ms_surg_unit_p))
 ENDIF
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_temp = cnvtstring(parameter(5,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_specialty_p = concat(" pg.prsnl_group_type_cd in(",trim(ms_temp))
   ELSE
    SET ms_specialty_p = concat(ms_specialty_p,", ",trim(ms_temp))
   ENDIF
  ENDFOR
  SET ms_specialty_p = concat(ms_specialty_p,")")
 ELSEIF (parameter(5,1)=999999)
  SET ms_specialty_p = "1=1"
 ELSE
  SET ms_specialty_p = cnvtstring(parameter(5,1),20)
  SET ms_specialty_p = concat(" pg.prsnl_group_type_cd = ",trim(ms_specialty_p))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1,
   person p,
   surgical_case sc,
   prsnl pr,
   surg_proc_detail spd,
   orders o,
   prsnl_group pg
  PLAN (ce
   WHERE ce.event_cd=mf_prep_focused_assessment_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(mf_mrn_cd)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (sc
   WHERE sc.encntr_id=e.encntr_id
    AND sc.cancel_dt_tm = null
    AND sc.active_ind=1
    AND parser(ms_surg_unit_p)
    AND  NOT (sc.surg_area_cd IN (null, 0.00))
    AND sc.surgeon_prsnl_id != 0.00)
   JOIN (pr
   WHERE pr.person_id=outerjoin(sc.surgeon_prsnl_id))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id)
   JOIN (spd
   WHERE spd.catalog_cd=o.catalog_cd)
   JOIN (pg
   WHERE pg.prsnl_group_id=spd.surg_specialty_id
    AND parser(ms_specialty_p))
  ORDER BY ce.event_end_dt_tm, e.reg_dt_tm, p.name_last
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (ml_cnt > size(data->patients,5))
    CALL alterlist(data->patients,(ml_cnt+ 9))
   ENDIF
   data->patients[ml_cnt].f_ce_event_id = ce.event_id, data->patients[ml_cnt].f_encntr_id = ce
   .encntr_id, data->patients[ml_cnt].f_patient_id = p.person_id,
   data->patients[ml_cnt].s_patient_name = p.name_full_formatted, data->patients[ml_cnt].s_mrn = ea
   .alias, data->patients[ml_cnt].s_fin = ea1.alias,
   data->patients[ml_cnt].s_powerform_completed = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   data->patients[ml_cnt].s_surgery = uar_get_code_display(spd.catalog_cd), data->patients[ml_cnt].
   s_surgeon_name = pr.name_full_formatted,
   data->patients[ml_cnt].s_surgical_unit = uar_get_code_display(sc.surg_area_cd)
  FOOT REPORT
   CALL alterlist(data->patients,ml_cnt)
  WITH nocounter
 ;end select
 SET ms_date_range = build2(format(mf_begin_dt_tm,"mm/dd/yy ;;d")," -",format(mf_end_dt_tm,
   "mm/dd/yy ;;d"))
 IF (curqual=0)
  SET ms_error = "No data found for the following date range: "
  IF (mn_ops=1
   AND gl_bhs_prod_flag=1)
   CALL uar_send_mail("CIScore@bhs.org","OPS Job Fail",build2(
     "bhs_rpt_skin_prep ops job was executed in ",curdomain,
     " - no data was found for the following date range: ",ms_date_range),"OPS JOB",1,
    "")
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2
  PLAN (ce1
   WHERE expand(ml_num1,1,size(data->patients,5),ce1.parent_event_id,data->patients[ml_num1].
    f_ce_event_id)
    AND ce1.event_cd=mf_dcp_generic_cd)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_cd IN (mf_skin_prep_at_home_cd, mf_skin_prep_in_preop_cd)
    AND ce2.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce2.view_level=1
    AND ce2.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cnvtupper(ce2.event_tag) != "IN ERROR")
  DETAIL
   ml_num2 = 0, ml_idx = locateval(ml_num2,1,size(data->patients,5),ce1.parent_event_id,data->
    patients[ml_num2].f_ce_event_id)
   IF (ml_idx > 0)
    CASE (ce2.event_cd)
     OF mf_skin_prep_at_home_cd:
      data->patients[ml_idx].s_skin_prep_at_home = ce2.event_tag
     OF mf_skin_prep_in_preop_cd:
      data->patients[ml_idx].s_skin_prep_in_preop_complete = ce2.event_tag
    ENDCASE
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
  SET ms_file_name = build("bhs_rpt_skin_prep",format(mf_begin_dt_tm,"mm/dd/yy ;;d"),"_to",format(
    mf_end_dt_tm,"mm/dd/yy ;;d"),".csv")
  SET ms_file_name = replace(ms_file_name,"/","_",0)
  SET ms_file_name = replace(ms_file_name," ","_",0)
  SET ms_subject = build2("GYN Skin Prep Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy;;d")),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy;;d")))
  SELECT INTO value(ms_file_name)
   FROM (dummyt d  WITH seq = size(data->patients,5))
   PLAN (d)
   ORDER BY data->patients[d.seq].s_powerform_completed, data->patients[d.seq].s_surgical_unit
   HEAD REPORT
    ms_temp = concat("SURGEON,PATIENT FULL NAME,MRN #,ACC #,POWERFORM COMPLETED",
     ",SKIN PREP AT HOME,SKIN PREP IN PREOP COMPLETE,SURGERY,SURGICAL UNIT"), col 0, ms_temp
   DETAIL
    row + 1, ms_temp = build('"',trim(data->patients[d.seq].s_surgeon_name),'",','"',trim(data->
      patients[d.seq].s_patient_name),
     '",','"',trim(data->patients[d.seq].s_mrn),'",','"',
     trim(data->patients[d.seq].s_fin),'",','"',trim(data->patients[d.seq].s_powerform_completed),
     '",',
     '"',trim(data->patients[d.seq].s_skin_prep_at_home),'",','"',trim(data->patients[d.seq].
      s_skin_prep_in_preop_complete),
     '",','"',trim(data->patients[d.seq].s_surgery),'",','"',
     trim(data->patients[d.seq].s_surgical_unit),'"'), col 0,
    ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 5000
  ;end select
  CALL emailfile(value(ms_file_name),ms_file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   surgeon = substring(0,100,data->patients[d.seq].s_surgeon_name), patient_name_full_formatted =
   substring(0,100,data->patients[d.seq].s_patient_name), mrn# = substring(0,100,data->patients[d.seq
    ].s_mrn),
   acc# = substring(0,100,data->patients[d.seq].s_fin), powerform_completed = substring(0,100,data->
    patients[d.seq].s_powerform_completed), skin_prep_at_home = substring(0,100,data->patients[d.seq]
    .s_skin_prep_at_home),
   skin_prep_in_preop_complete = substring(0,100,data->patients[d.seq].s_skin_prep_in_preop_complete),
   surgery = substring(0,100,data->patients[d.seq].s_surgery), surgical_unit = substring(0,100,data->
    patients[d.seq].s_surgical_unit)
   FROM (dummyt d  WITH seq = size(data->patients,5))
   PLAN (d)
   ORDER BY powerform_completed, surgical_unit
   WITH nocounter, format, separator = " "
  ;end select
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
    msg1 = ms_error, msg2 = ms_date_range, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
 ENDIF
END GO
