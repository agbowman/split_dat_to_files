CREATE PROGRAM bhs_rpt_ipoc_by_unit:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Select Facility" = 0,
  "Select Nursing Unit or Any(*) for All :" = 0,
  'enter "report_preview to print to screen' = "report_preview "
  WITH outdev, fname, nunit,
  email
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE ms_line = vc WITH noconstant(fillstring(32000,"")), protect
 DECLARE ms_fileout = vc WITH noconstant( $OUTDEV), protect
 DECLARE ml_cntline = i4 WITH noconstant(0), protect
 DECLARE ms_tmp = vc WITH protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 DECLARE mf_daystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE mf_observation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")), protect
 DECLARE mf_barrierstogoals = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BARRIERSTOMEETINGDISCHARGEGOALS")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN")), protect
 DECLARE ml_unit_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_is_any = vc WITH noconstant(substring(1,1,reflect( $NUNIT))), protect
 DECLARE mf_primaryeventid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID")),
 protect
 DECLARE mf_ipoc_form = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERDISCIPLINARYPLANOFCAREFORM")), protect
 DECLARE ml_sendind = i4 WITH noconstant(0), protect
 DECLARE ml_valid_email = i4 WITH noconstant(0), protect
 DECLARE ms_outfile = vc WITH constant(concat("ipoc_",format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDDHHMMSS;;q"),".csv")), protect
 DECLARE mf_anticipateddischargedate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTICIPATEDDISCHARGEDATE")), protect
 DECLARE mf_unit = f8 WITH protect
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 IF (ms_is_any="C")
  SET mf_unit = 0.0
 ELSE
  SET mf_unit =  $NUNIT
 ENDIF
 IF (((findstring("@BHS.ORG",cnvtupper( $EMAIL),1,1) > 0) OR (findstring("@BAYSTATEHEALTH.ORG",
  cnvtupper( $EMAIL),10,1) > 0)) )
  SET ml_sendind = 1
  SET ml_valid_email = 1
  SET ms_fileout = ms_outfile
 ELSEIF (cnvtupper( $EMAIL) != "REPORT_PREVIEW")
  SET ml_sendind = 1
  SET ml_valid_email = 0
 ENDIF
 FREE RECORD ipoc
 RECORD ipoc(
   1 units[*]
     2 mf_person_id = f8
     2 ms_patient_name = vc
     2 ms_mrn = vc
     2 mf_encntr_id = f8
     2 ms_dob = vc
     2 ms_age = vc
     2 ms_accout_no = vc
     2 ms_mrn = vc
     2 ms_admit_date = vc
     2 ms_patient_type = vc
     2 ms_attending = vc
     2 ms_res_date = vc
     2 ms_location = vc
     2 mf_resbarrierstogoals = vc
     2 mf_resanticipateddischargedate = vc
     2 ml_unitcnt = i4
 )
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   person p,
   encntr_domain ed
  PLAN (ed
   WHERE (ed.loc_facility_cd= $FNAME)
    AND ((ed.loc_nurse_unit_cd=mf_unit
    AND mf_unit != 0) OR (mf_unit=0
    AND ms_is_any="C"))
    AND ed.active_status_cd=mf_active
    AND ed.active_ind=1
    AND ed.loc_nurse_unit_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND ((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
     AND expand(ml_cnt,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt].s_unit_display_key)))
     AND cv.active_type_cd IN (mf_active)))
    AND ed.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm=null
    AND e.encntr_type_cd IN (mf_daystay, mf_inpatient, mf_observation))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mf_finnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY ed.loc_nurse_unit_cd, ed.encntr_id
  HEAD REPORT
   ml_unit_cnt = 0, stat = alterlist(ipoc->units,10)
  HEAD ed.encntr_id
   ml_unit_cnt = (ml_unit_cnt+ 1)
   IF (mod(ml_unit_cnt,10)=1
    AND ml_unit_cnt > 1)
    stat = alterlist(ipoc->units,(ml_unit_cnt+ 9))
   ENDIF
   ipoc->units[ml_unit_cnt].mf_encntr_id = e.encntr_id, ipoc->units[ml_unit_cnt].mf_person_id = e
   .person_id, ipoc->units[ml_unit_cnt].ms_admit_date = format(e.reg_dt_tm,"mm/dd/yy;;d"),
   ipoc->units[ml_unit_cnt].ms_accout_no = ea.alias, ipoc->units[ml_unit_cnt].ms_patient_name = p
   .name_full_formatted, ipoc->units[ml_unit_cnt].ms_location = trim(uar_get_code_display(ed
     .loc_nurse_unit_cd),3),
   ipoc->units[ml_unit_cnt].ml_unitcnt = ml_unit_cnt
  FOOT REPORT
   stat = alterlist(ipoc->units,ml_unit_cnt),
   CALL echo(build("ml_unit_cnt  =",ml_unit_cnt))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No Patients found in selected Units", col 0, "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  units_mf_person_id = ipoc->units[ml_num].mf_person_id
  FROM encntr_prsnl_reltn epr,
   prsnl prn
  PLAN (epr
   WHERE expand(ml_num,1,size(ipoc->units,5),epr.encntr_id,ipoc->units[ml_num].mf_encntr_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=mf_attendingphysician
    AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm)
   JOIN (prn
   WHERE prn.person_id=epr.prsnl_person_id
    AND prn.active_ind=1
    AND prn.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY epr.encntr_id
  HEAD epr.encntr_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(ipoc->units,5),epr.encntr_id,ipoc->units[
    ml_numres].mf_encntr_id)
   IF (ml_attloc != 0)
    ipoc->units[ml_attloc].ms_attending = concat(trim(prn.name_first,3)," ",trim(prn.name_last,3))
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce1,
   clinical_event ce2
  PLAN (ce
   WHERE expand(ml_numres,1,size(ipoc->units,5),ce.encntr_id,ipoc->units[ml_numres].mf_encntr_id)
    AND ce.event_cd=mf_ipoc_form
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ce1
   WHERE ce.event_id=ce1.parent_event_id
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce1.view_level=0)
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce2.view_level=1
    AND ce2.event_cd IN (mf_barrierstogoals, mf_anticipateddischargedate))
  ORDER BY ce2.encntr_id, ce2.event_cd, ce2.updt_dt_tm DESC
  HEAD ce2.encntr_id
   ml_loc = 0, ml_loc = locateval(ml_numres,1,size(ipoc->units,5),ce2.encntr_id,ipoc->units[ml_numres
    ].mf_encntr_id)
  HEAD ce2.event_cd
   IF (ce2.event_cd=mf_barrierstogoals
    AND ml_loc != 0)
    ipoc->units[ml_loc].mf_resbarrierstogoals = substring(1,200,ce2.result_val), ipoc->units[ml_loc].
    ms_res_date = trim(format(ce2.valid_from_dt_tm,"mm/dd/yy  HH:MM;;d"),3)
   ENDIF
   IF (ce2.event_cd=mf_anticipateddischargedate)
    ipoc->units[ml_loc].mf_resanticipateddischargedate = format(cnvtdatetime(cnvtdate2(substring(3,8,
        ce2.result_val),"yyyymmdd"),cnvttime2(substring(11,6,ce2.result_val),"HHMMSS")),"mm/dd/yy;;d"
     )
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echo("end select")
 IF (cnvtupper( $EMAIL)="REPORT_PREVIEW"
  AND ml_sendind=0
  AND ml_valid_email=0)
  SELECT INTO value(ms_fileout)
   patient_name = substring(1,30,ipoc->units[d1.seq].ms_patient_name), date_of_admit = substring(1,30,
    ipoc->units[d1.seq].ms_admit_date), account_num = substring(1,15,ipoc->units[d1.seq].ms_accout_no
    ),
   location = substring(1,15,ipoc->units[d1.seq].ms_location), attendindmd = substring(1,30,ipoc->
    units[d1.seq].ms_attending), barriers_to_meeting_goals = substring(1,200,ipoc->units[d1.seq].
    mf_resbarrierstogoals),
   anticipated_discharge_date = substring(1,30,ipoc->units[d1.seq].mf_resanticipateddischargedate),
   chart_date = substring(1,30,ipoc->units[d1.seq].ms_res_date)
   FROM (dummyt d1  WITH seq = value(size(ipoc->units,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format,
    expand = 1
  ;end select
 ELSEIF (ml_sendind=1
  AND ml_valid_email=1)
  CALL echo(build("ms_fileout = ",ms_fileout))
  SELECT INTO value(ms_fileout)
   patient_name = substring(1,30,ipoc->units[d1.seq].ms_patient_name), date_of_admit = substring(1,30,
    ipoc->units[d1.seq].ms_admit_date), account_num = substring(1,15,ipoc->units[d1.seq].ms_accout_no
    ),
   location = substring(1,15,ipoc->units[d1.seq].ms_location), attendindmd = substring(1,30,ipoc->
    units[d1.seq].ms_attending), barriers_to_meeting_goals = substring(1,200,ipoc->units[d1.seq].
    mf_resbarrierstogoals),
   anticipated_discharge_date = substring(1,30,ipoc->units[d1.seq].mf_resanticipateddischargedate),
   chart_date = substring(1,30,ipoc->units[d1.seq].ms_res_date)
   FROM (dummyt d1  WITH seq = value(size(ipoc->units,5)))
   PLAN (d1)
   HEAD REPORT
    ms_line = trim(build(trim("Patient_name"),",",trim("date_of_admit"),",",trim("Account_num"),
      ",",trim("location"),",",trim("attendindMD",3),",",
      trim("barriers_to_meeting_goals"),",",trim("anticipated_discharge_date"),",",trim("chart_date")
      ),3), col 0, ms_line,
    row + 1
   DETAIL
    ms_line = substring(1,1000,trim(build(concat('"',trim(patient_name,3),'"'),",",trim(date_of_admit,
        3),",",trim(account_num,3),
       ",",trim(location,3),",",concat('"',trim(attendindmd),'"'),",",
       concat('"',trim(barriers_to_meeting_goals),'"'),",",trim(anticipated_discharge_date,3),",",
       trim(chart_date,3)),3)), col 0, ms_line,
    row + 1
   WITH nocounter, format = variable, maxrow = 1,
    maxcol = 2000
  ;end select
  IF (curqual > 0)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("IPOC Report ")
   CALL emailfile(value(ms_fileout),ms_fileout, $EMAIL,ms_tmp,1)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Email Sent", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ELSE
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("IPOC Report no Data Returned")
   CALL emailfile(value(ms_fileout),ms_fileout, $EMAIL,ms_tmp,1)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "No Data Qualifed Email Sent", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1
    WITH dio = 08
   ;end select
  ENDIF
 ELSEIF (ml_sendind=1
  AND ml_valid_email=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Invalid Email must end with @bhs.org or @baystatehealth.org", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
 CALL echorecord(ipoc)
#exit_program
END GO
