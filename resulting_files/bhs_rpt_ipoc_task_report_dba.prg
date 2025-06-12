CREATE PROGRAM bhs_rpt_ipoc_task_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Acct#" = ""
  WITH outdev, ms_acct_nbr
 DECLARE mf_modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_authverified = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_primaryeventid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID")),
 protect
 DECLARE mf_barrierstogoals = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BARRIERSTOMEETINGDISCHARGEGOALS")), protect
 DECLARE mf_plannextsteps = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PLANNEXTSTEPS")),
 protect
 DECLARE mf_importanttoday = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WHATSIMPORTANTTOTHEPTFAMILYTODAY")), protect
 DECLARE mf_goalsfortoday = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PTFAMILYTEAMSGOALSFORTODAY")), protect
 DECLARE mf_goalsforstay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PTFAMILYTEAMSGOALSFORSTAY")), protect
 DECLARE mf_statusofpplan = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "STATUSOFPTFAMILYSTEAMSPLAN")), protect
 DECLARE mf_anticipateddateofdcknown = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ISTHEANTICIPATEDDATEOFDCKNOWN")), protect
 DECLARE mf_anticipateddischargedate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTICIPATEDDISCHARGEDATE")), protect
 DECLARE ms_attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 FREE RECORD ipoc
 RECORD ipoc(
   1 mf_person_id = f8
   1 ms_patient_name = vc
   1 ms_mrn = vc
   1 mf_encntr_id = f8
   1 ms_dob = vc
   1 ms_age = vc
   1 ms_accout_no = vc
   1 ms_mrn = vc
   1 ms_admit_date = vc
   1 ms_patient_type = vc
   1 ms_attending = vc
   1 ms_loc_cnt = i2
   1 ms_weight = vc
   1 ms_location = vc
   1 mf_resplannextsteps = vc
   1 mf_resimportanttoday = vc
   1 mf_resgoalsfortoday = vc
   1 mf_resgoalsforstay = vc
   1 mf_resstatusofpplan = vc
   1 mf_resanticipateddateofdcknown = vc
   1 mf_resanticipateddischargedate = vc
 )
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   person p,
   encntr_domain ed
  PLAN (ea
   WHERE (ea.alias= $MS_ACCT_NBR)
    AND ea.encntr_alias_type_cd=mf_finnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (ed
   WHERE e.encntr_id=ed.encntr_id)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mf_mrn
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD e.encntr_id
   ipoc->mf_encntr_id = e.encntr_id, ipoc->mf_person_id = e.person_id, ipoc->ms_admit_date = format(e
    .reg_dt_tm,"mm/dd/yy;;d"),
   ipoc->ms_dob = format(p.birth_dt_tm,"mm/dd/yy;;d"), ipoc->ms_accout_no = ea.alias, ipoc->ms_mrn =
   ea2.alias,
   ipoc->mf_encntr_id = e.encntr_id, ipoc->ms_patient_name = trim(p.name_full_formatted,3), ipoc->
   ms_age = trim(cnvtage(p.birth_dt_tm),3),
   ipoc->ms_location = concat(trim(uar_get_code_display(ed.loc_nurse_unit_cd),3)," ",trim(
     uar_get_code_display(ed.loc_room_cd),3),trim(uar_get_code_display(ed.loc_bed_cd),3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl prn
  PLAN (epr
   WHERE (ipoc->mf_encntr_id=epr.encntr_id)
    AND 1=epr.active_ind
    AND ms_attendingphysician=epr.encntr_prsnl_r_cd
    AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm)
   JOIN (prn
   WHERE prn.person_id=epr.prsnl_person_id)
  DETAIL
   ipoc->ms_attending = concat(trim(prn.name_first,3)," ",trim(prn.name_last,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2
  PLAN (dfr
   WHERE dfr.definition="*Interdisciplinary Plan of Care - BHS*"
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND (dfa.encntr_id=ipoc->mf_encntr_id))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=mf_primaryeventid
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.result_status_cd IN (mf_modified, mf_altered, mf_authverified))
   JOIN (ce1
   WHERE ce.event_id=ce1.parent_event_id
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce1.view_level=0
    AND ce1.result_status_cd IN (mf_modified, mf_altered, mf_authverified))
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce2.view_level=1
    AND ce2.result_status_cd IN (mf_modified, mf_altered, mf_authverified)
    AND ce2.event_cd IN (mf_plannextsteps, mf_importanttoday, mf_goalsfortoday, mf_goalsforstay,
   mf_statusofpplan,
   mf_anticipateddateofdcknown, mf_anticipateddischargedate))
  ORDER BY ce2.event_cd, ce2.updt_dt_tm DESC
  HEAD ce2.event_cd
   IF (ce2.event_cd=mf_anticipateddateofdcknown)
    ipoc->mf_resanticipateddateofdcknown = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd=mf_anticipateddischargedate)
    ipoc->mf_resanticipateddischargedate = format(cnvtdatetime(cnvtdate2(substring(3,8,ce2.result_val
        ),"yyyymmdd"),cnvttime2(substring(11,6,ce2.result_val),"HHMMSS")),"mm/dd/yy;;d")
   ELSEIF (ce2.event_cd=mf_statusofpplan)
    ipoc->mf_resstatusofpplan = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd=mf_goalsforstay)
    ipoc->mf_resgoalsforstay = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd=mf_goalsfortoday)
    ipoc->mf_resgoalsfortoday = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd=mf_importanttoday)
    ipoc->mf_resimportanttoday = trim(ce2.result_val,3)
   ELSEIF (ce2.event_cd=mf_plannextsteps)
    ipoc->mf_resplannextsteps = trim(ce2.result_val,3)
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headipoc(ncalc=i2) = f8 WITH protect
 DECLARE headipocabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailipoc(ncalc=i2) = f8 WITH protect
 DECLARE detailipocabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _helvetica14b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica16bu0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica200 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica140 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"bhscust:baystate_logo_bw.jpg")
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headipoc(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headipocabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headipocabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.270000), private
   DECLARE __today = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime3),";;q"),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica16bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("My Plan of Care",char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 1.938),(offsety+ 0.010),3.635,
     0.615,1)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 2.563)
    SET rptsd->m_width = 2.563
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__today)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailipoc(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailipocabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailipocabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(8.650000), private
   DECLARE __patname = vc WITH noconstant(build2(ipoc->ms_patient_name,char(0))), protect
   DECLARE __room = vc WITH noconstant(build2(ipoc->ms_location,char(0))), protect
   DECLARE __attend_doc = vc WITH noconstant(build2(ipoc->ms_attending,char(0))), protect
   DECLARE __admitdate = vc WITH noconstant(build2(ipoc->ms_admit_date,char(0))), protect
   DECLARE __anticdate_disch_known = vc WITH noconstant(build2(ipoc->mf_resanticipateddateofdcknown,
     char(0))), protect
   DECLARE __plan_status = vc WITH noconstant(build2(ipoc->mf_resstatusofpplan,char(0))), protect
   DECLARE __goal_for_stay = vc WITH noconstant(build2(ipoc->mf_resgoalsforstay,char(0))), protect
   DECLARE __todays_goal = vc WITH noconstant(build2(ipoc->mf_resgoalsfortoday,char(0))), protect
   DECLARE __important_today = vc WITH noconstant(build2(ipoc->mf_resimportanttoday,char(0))),
   protect
   DECLARE __next_steps = vc WITH noconstant(build2(ipoc->mf_resplannextsteps,char(0))), protect
   DECLARE __antic_disch_dt = vc WITH noconstant(build2(ipoc->mf_resanticipateddischargedate,char(0))
    ), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room: ",char(0)))
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Day of Admit: ",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending Physician: ",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Is the Anticipated Date of Discharge Known?: ",char(0)))
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status of Patients Plan: ",char(0)))
    SET rptsd->m_y = (offsety+ 3.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Pt/Familys & Teams Goals for Stay: ",char(0)))
    SET rptsd->m_y = (offsety+ 4.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Pt/Familys & Teams Goals for Today: ",char(0)))
    SET rptsd->m_y = (offsety+ 5.500)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Whats Important to the Pt/Family Today: ",char(0)))
    SET rptsd->m_y = (offsety+ 6.750)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Plan/Next Steps: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patname)
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__room)
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 2.563)
    SET rptsd->m_width = 3.563
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attend_doc)
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 1.813)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admitdate)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__anticdate_disch_known)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 2.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 1.000
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__plan_status)
    SET rptsd->m_y = (offsety+ 3.250)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 1.000
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__goal_for_stay)
    SET rptsd->m_y = (offsety+ 4.500)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 1.000
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__todays_goal)
    SET rptsd->m_y = (offsety+ 5.750)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 1.000
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__important_today)
    SET rptsd->m_y = (offsety+ 7.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 1.000
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__next_steps)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Anticipated Discharge Date: ",char(0)
      ))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 3.625
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__antic_disch_dt)
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 8.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.427
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica200)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Copy",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_IPOC_TASK_REPORT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 16
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _helvetica16bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _helvetica140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _helvetica14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET rptfont->m_bold = rpt_off
   SET _helvetica200 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET page_size = 10.18
 SET d0 = initializereport(0)
 SET d0 = headipoc(rpt_render)
 SET d0 = detailipoc(rpt_render)
 SET d0 = finalizereport( $OUTDEV)
END GO
