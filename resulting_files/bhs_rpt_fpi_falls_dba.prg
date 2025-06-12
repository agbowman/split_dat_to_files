CREATE PROGRAM bhs_rpt_fpi_falls:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 999999,
  "Nurse Unit" = 999999,
  "Begin dt/tm" = "SYSDATE",
  "End dt/tm" = "SYSDATE",
  "Recipients" = ""
  WITH outdev, f_facility_cd, f_nurseunit_cd,
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
 RECORD data(
   1 l_pat_cnt = i4
   1 pats[*]
     2 s_pat_last_name = vc
     2 s_pat_first_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_facility = vc
     2 s_pat_phone = vc
     2 s_pri_insurance = vc
     2 s_sec_insurance = vc
     2 s_lives_indep = vc
     2 s_fall_in_past_yr = vc
     2 s_feel_unsteady = vc
     2 s_fear_of_falling = vc
     2 s_fpi_package_given = vc
     2 f_parent_event_id = f8
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_pat_dob = f8
     2 f_form_completed = f8
     2 s_age = vc
     2 s_race = vc
     2 s_sex = vc
     2 s_hispanic_ind = vc
     2 s_reason_visit = vc
     2 f_service_date = f8
     2 s_init_dc_stat = vc
     2 s_rehab_date = vc
 ) WITH protect
 EXECUTE bhs_ma_email_file
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_inprogress_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_home_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"HOME"))
 DECLARE mf_livesindependent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "55YRSOROLDERLIVESINDEPENDENTLY"))
 DECLARE mf_fallinthepastyear_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FALLINTHEPASTYEAR"))
 DECLARE mf_feelunsteady_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FEELUNSTEADYGETUPSTANDTRYSITWALK"))
 DECLARE mf_fearoffalling_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FEAROFFALLING"))
 DECLARE mf_fpipackagegiven_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FPIPACKAGEGIVENTOPATIENTFAMILY"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4
 DECLARE ml_num1 = i4 WITH protect, noconstant(0)
 DECLARE ml_num2 = i4 WITH protect, noconstant(0)
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_BEGIN_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_facility_p = vc WITH protect, noconstant(" ")
 DECLARE ms_nurseunit_p = vc WITH protect, noconstant(" ")
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE l_ndx = i4
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SET mf_begin_dt_tm = cnvtdatetime((curdate - 1),000000)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_FPI_FALLS"
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
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
 ELSE
  SET ms_facility_p = cnvtstring( $F_FACILITY_CD)
  SET ms_facility_p = concat("e.loc_facility_cd = ",trim(ms_facility_p))
 ENDIF
 IF (( $F_NURSEUNIT_CD=999999))
  SET ms_nurseunit_p = "1=1"
 ELSE
  SET ms_nurseunit_p = cnvtstring( $F_NURSEUNIT_CD)
  SET ms_nurseunit_p = concat("e.loc_nurse_unit_cd = ",trim(ms_nurseunit_p))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE ce.event_cd IN (mf_fallinthepastyear_cd, mf_feelunsteady_cd, mf_fearoffalling_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND parser(ms_facility_p)
    AND parser(ms_nurseunit_p)
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY uar_get_code_display(e.loc_facility_cd), ce.event_end_dt_tm DESC
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   IF (cnvtupper(ce.event_tag)="YES")
    ml_idx1 = locateval(ml_num1,1,size(data->pats,5),e.person_id,data->pats[ml_num1].f_person_id)
    IF (ml_idx1=0)
     ml_idx2 = locateval(ml_num2,1,size(data->pats,5),ce.parent_event_id,data->pats[ml_num2].
      f_parent_event_id)
     IF (ml_idx2=0)
      ml_cnt += 1
      IF (ml_cnt > size(data->pats,5))
       CALL alterlist(data->pats,(ml_cnt+ 10))
      ENDIF
      data->pats[ml_cnt].f_parent_event_id = ce.parent_event_id, data->pats[ml_cnt].f_person_id = e
      .person_id, data->pats[ml_cnt].f_encntr_id = e.encntr_id,
      data->pats[ml_cnt].f_form_completed = ce.event_end_dt_tm, data->pats[ml_cnt].s_facility =
      uar_get_code_display(e.loc_facility_cd), data->pats[ml_cnt].f_service_date = ce.performed_dt_tm
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   CALL alterlist(data->pats,ml_cnt), data->l_pat_cnt = ml_cnt, ml_num1 = 0
  WITH nocounter
 ;end select
 IF (curqual=0
  AND mn_ops=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_num1,1,size(data->pats,5),ce.parent_event_id,data->pats[ml_num1].f_parent_event_id
    )
    AND ce.event_cd IN (mf_livesindependent_cd, mf_fallinthepastyear_cd, mf_feelunsteady_cd,
   mf_fearoffalling_cd, mf_fpipackagegiven_cd)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_modified_cd, mf_inprogress_cd)
    AND ce.view_level=1)
  HEAD REPORT
   ml_idx1 = 0
  DETAIL
   ml_num2 = 0, ml_idx1 = locateval(ml_num2,1,size(data->pats,5),ce.parent_event_id,data->pats[
    ml_num2].f_parent_event_id)
   IF (ml_idx1 > 0)
    CASE (ce.event_cd)
     OF mf_livesindependent_cd:
      data->pats[ml_idx1].s_lives_indep = ce.event_tag
     OF mf_fallinthepastyear_cd:
      data->pats[ml_idx1].s_fall_in_past_yr = ce.event_tag
     OF mf_feelunsteady_cd:
      data->pats[ml_idx1].s_feel_unsteady = ce.event_tag
     OF mf_fearoffalling_cd:
      data->pats[ml_idx1].s_fear_of_falling = ce.event_tag
     OF mf_fpipackagegiven_cd:
      data->pats[ml_idx1].s_fpi_package_given = ce.event_tag
    ENDCASE
   ENDIF
  FOOT REPORT
   ml_num1 = 0
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   phone ph
  PLAN (e
   WHERE expand(ml_num1,1,size(data->pats,5),e.encntr_id,data->pats[ml_num1].f_encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.phone_type_cd= Outerjoin(mf_home_phone_cd))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.phone_type_seq= Outerjoin(1))
    AND (ph.active_ind= Outerjoin(1))
    AND (ph.end_effective_dt_tm>= Outerjoin(sysdate)) )
  HEAD REPORT
   ml_idx1 = 0
  DETAIL
   ml_num2 = 0, ml_idx1 = locateval(ml_num2,1,size(data->pats,5),e.encntr_id,data->pats[ml_num2].
    f_encntr_id)
   IF (ml_idx1 > 0)
    data->pats[ml_idx1].s_pat_last_name = p.name_last, data->pats[ml_idx1].s_pat_first_name = p
    .name_first, data->pats[ml_idx1].s_mrn = ea1.alias,
    data->pats[ml_idx1].s_fin = ea2.alias, data->pats[ml_idx1].f_pat_dob = cnvtdatetimeutc(
     datetimezone(p.birth_dt_tm,p.birth_tz),1), data->pats[ml_idx1].s_pat_phone = ph.phone_num,
    data->pats[ml_idx1].s_age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),
    data->pats[ml_idx1].s_sex = uar_get_code_display(p.sex_cd), data->pats[ml_idx1].s_reason_visit =
    e.reason_for_visit
   ENDIF
  FOOT REPORT
   ml_num1 = 0
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  b.description, b.display, ethnicity = uar_get_code_description(b.code_value)
  FROM bhs_demographics b,
   code_value cv,
   code_value_alias cva
  PLAN (cv
   WHERE cv.code_set=104490)
   JOIN (cva
   WHERE cva.code_set=cv.code_set
    AND cva.code_value=cv.code_value)
   JOIN (b
   WHERE b.code_value=cva.code_value
    AND expand(l_ndx,1,data->l_pat_cnt,b.person_id,data->pats[l_ndx].f_person_id)
    AND b.description="ethnicity 1")
  HEAD REPORT
   ml_idx1 = 0
  DETAIL
   ml_idx1 = locateval(ml_num,1,data->l_pat_cnt,b.person_id,data->pats[ml_num].f_person_id), data->
   pats[ml_idx1].s_race = ethnicity
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  b.description
  FROM bhs_demographics b
  PLAN (b
   WHERE expand(l_ndx,1,data->l_pat_cnt,b.person_id,data->pats[l_ndx].f_person_id)
    AND b.description="hispanic ind")
  HEAD REPORT
   ml_idx1 = 0
  DETAIL
   ml_idx1 = locateval(ml_num,1,data->l_pat_cnt,b.person_id,data->pats[ml_num].f_person_id), data->
   pats[ml_idx1].s_hispanic_ind = b.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_plan_reltn epr,
   organization org
  PLAN (epr
   WHERE expand(ml_num1,1,size(data->pats,5),epr.encntr_id,data->pats[ml_num1].f_encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (org
   WHERE org.organization_id=epr.organization_id)
  HEAD REPORT
   ml_idx1 = 0
  DETAIL
   ml_num2 = 0, ml_idx1 = locateval(ml_num2,1,size(data->pats,5),epr.encntr_id,data->pats[ml_num2].
    f_encntr_id)
   IF (ml_idx1 > 0)
    IF (epr.priority_seq=1)
     data->pats[ml_idx1].s_pri_insurance = org.org_name
    ELSEIF (epr.priority_seq=2)
     data->pats[ml_idx1].s_sec_insurance = org.org_name
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((textlen( $S_RECIPIENTS) > 1) OR (mn_ops=1)) )
  IF (mn_ops=1)
   SET frec->file_name = build("bhs_rpt_fpi_falls",format(mf_begin_dt_tm,"mm/dd/yy ;;d"),".csv")
  ELSE
   SET frec->file_name = build("bhs_rpt_fpi_falls",format(mf_begin_dt_tm,"mm/dd/yy ;;d"),"_to",format
    (mf_end_dt_tm,"mm/dd/yy ;;d"),".csv")
  ENDIF
  SET frec->file_name = replace(frec->file_name,"/","_",0)
  SET frec->file_name = replace(frec->file_name," ","_",0)
  SET ms_subject = build2("FPI Falls Report ",trim(format(mf_begin_dt_tm,"mmm-dd-yyyy hh:mm ;;d")),
   " to ",trim(format(mf_end_dt_tm,"mmm-dd-yyyy hh:mm ;;d")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"FACILITY",','"PATIENT LAST NAME",','"PATIENT FIRST NAME",','"DOB",',
   '"MRN #",',
   '"ACCT #",','"PRIMARY INSURANCE",','"SECONDARY INSURANCE",','"PHONE #",','"LIVES INDEPENDENTLY",',
   '"FALL IN PAST YEAR",','"FEEL UNSTEADY",','"FEAR OF FALLING",','"FPI PACKAGE GIVEN",',
   '"FORM COMPLETED",',
   '"AGE",','"RACE",','"SEX",','"HISPANIC IND",','"REASON FOR VISIT",',
   '"SERVICE DATE",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO data->l_pat_cnt)
   SET frec->file_buf = build('"',trim(data->pats[ml_idx1].s_facility,3),'","',trim(data->pats[
     ml_idx1].s_pat_last_name,3),'","',
    trim(data->pats[ml_idx1].s_pat_first_name,3),'","',trim(format(data->pats[ml_idx1].f_pat_dob,
      "mm/dd/yyyy ;;d"),3),'","',trim(data->pats[ml_idx1].s_mrn,3),
    '","',trim(data->pats[ml_idx1].s_fin,3),'","',trim(data->pats[ml_idx1].s_pri_insurance,3),'","',
    trim(data->pats[ml_idx1].s_sec_insurance,3),'","',trim(data->pats[ml_idx1].s_pat_phone,3),'","',
    trim(data->pats[ml_idx1].s_lives_indep,3),
    '","',trim(data->pats[ml_idx1].s_fall_in_past_yr,3),'","',trim(data->pats[ml_idx1].
     s_feel_unsteady,3),'","',
    trim(data->pats[ml_idx1].s_fear_of_falling,3),'","',trim(data->pats[ml_idx1].s_fpi_package_given,
     3),'","',trim(format(data->pats[ml_idx1].f_form_completed,"mm/dd/yyyy hh:mm;;d"),3),
    '","',trim(data->pats[ml_idx1].s_age,3),'","',trim(data->pats[ml_idx1].s_race,3),'","',
    trim(data->pats[ml_idx1].s_sex,3),'","',trim(data->pats[ml_idx1].s_hispanic_ind,3),'","',trim(
     data->pats[ml_idx1].s_reason_visit,3),
    '","',trim(format(data->pats[ml_idx1].f_service_date,"mm/dd/yyyy hh:mm;;d"),3),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  CALL emailfile(value(frec->file_name),frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   facility = substring(1,200,data->pats[d.seq].s_facility), patient_last_name = substring(1,200,data
    ->pats[d.seq].s_pat_last_name), patient_first_name = substring(1,200,data->pats[d.seq].
    s_pat_first_name),
   dob = substring(1,200,format(data->pats[d.seq].f_pat_dob,"mm/dd/yyyy ;;d")), mrn# = substring(1,
    200,data->pats[d.seq].s_mrn), acct# = substring(1,200,data->pats[d.seq].s_fin),
   pri_insurance = substring(1,200,data->pats[d.seq].s_pri_insurance), sec_insurance = substring(1,
    200,data->pats[d.seq].s_sec_insurance), phone# = substring(1,200,data->pats[d.seq].s_pat_phone),
   lives_independently = substring(1,200,data->pats[d.seq].s_lives_indep), fall_in_past_year =
   substring(1,200,data->pats[d.seq].s_fall_in_past_yr), feel_unsteady = substring(1,200,data->pats[d
    .seq].s_feel_unsteady),
   fear_of_falling = substring(1,200,data->pats[d.seq].s_fear_of_falling), fpi_package_given =
   substring(1,200,data->pats[d.seq].s_fpi_package_given), form_completed = substring(1,200,format(
     data->pats[d.seq].f_form_completed,"mm/dd/yyyy hh:mm;;d")),
   age = substring(1,200,data->pats[d.seq].s_age), race = substring(1,200,data->pats[d.seq].s_race),
   sex = substring(1,200,data->pats[d.seq].s_sex),
   hispanic_ind = substring(1,200,data->pats[d.seq].s_hispanic_ind), reason_for_visit = substring(1,
    200,data->pats[d.seq].s_reason_visit), service_date = substring(1,200,format(data->pats[d.seq].
     f_service_date,"mm/dd/yyyy hh:mm;;d"))
   FROM (dummyt d  WITH seq = size(data->pats,5))
   PLAN (d)
   ORDER BY facility, patient_last_name, patient_first_name,
    form_completed
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
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
