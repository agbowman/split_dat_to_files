CREATE PROGRAM ct_rpt_trial_prescreen_lo:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "For Report Order By:" = 0,
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, orderby, gender,
  qualifier, age1, age2,
  evalby
 EXECUTE reportrtl
 RECORD paramlists(
   1 etypecnt = i4
   1 eanyflag = i2
   1 equal[*]
     2 etypecd = f8
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
   1 protcnt = i4
   1 pqual[*]
     2 primary_mnemonic = vc
 )
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD runpsjobrequest(
   1 type_flag = i2
   1 job_details = vc
 )
 RECORD details_request(
   1 startdttm = dq8
   1 enddttm = dq8
   1 eanyflag = i2
   1 enctrlist[*]
     2 etypecd = f8
   1 fanyflag = i2
   1 facilitylist[*]
     2 faccd = f8
   1 protlist[*]
     2 primary_mnemonic = vc
   1 agequalifiercd = f8
   1 age1 = i4
   1 age2 = i4
   1 gendercd = f8
 )
 RECORD details_reply(
   1 jobdetails = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_patient = vc
   1 rpt_encounter = vc
   1 rpt_gender = vc
   1 rpt_age = vc
   1 rpt_reg_dt = vc
   1 rpt_race = vc
   1 rpt_facility = vc
   1 rpt_pt_inquiry_rpt = vc
   1 rpt_pt_view_prescreen = vc
 )
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD protlist(
   1 protqual[*]
     2 primary_mnemonic = vc
     2 init_service = vc
     2 prot_master_id = f8
     2 personcnt = i4
     2 personqual[*]
       3 person_id = f8
       3 comment = vc
 )
 RECORD eksctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD eksctreply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD recdate(
   1 datetime = dq8
 )
 RECORD calling_reply(
   1 skip = i2
   1 org_security_ind = i2
   1 org_security_fnd = i2
   1 protocol_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD calling_fac_reply(
   1 skip = i2
   1 org_security_ind = i2
   1 org_security_fnd = i2
   1 facility_list[*]
     2 facility_display = vc
     2 facility_cd = f8
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE pending_job_head(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE pending_job_headabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE pending_job_protocol(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE pending_job_protocolabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE pending_job_foot(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE pending_job_footabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE no_patient_qualified_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE no_patient_qualified_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref
   )) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
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
 DECLARE _rempending_job_label = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpending_job_head = i2 WITH noconstant(0), protect
 DECLARE _rempending_job_protocol = i4 WITH noconstant(1), protect
 DECLARE _bcontpending_job_protocol = i2 WITH noconstant(0), protect
 DECLARE _rempending_job_label = i4 WITH noconstant(1), protect
 DECLARE _bcontpending_job_foot = i2 WITH noconstant(0), protect
 DECLARE _remno_patient_msg = i4 WITH noconstant(1), protect
 DECLARE _bcontno_patient_qualified_section = i2 WITH noconstant(0), protect
 DECLARE _courier9b0 = i4 WITH noconstant(0), protect
 DECLARE _courier80 = i4 WITH noconstant(0), protect
 DECLARE _courier90 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _courier100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE pending_job_head(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pending_job_headabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pending_job_headabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pending_job_label = f8 WITH noconstant(0.0), private
   DECLARE __pending_job_label = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "PENDING_JOB_PRESCREEN_RPT",
      "A prescreening job cannot be run for the following protocols because another job is already running:"
      ),char(0))), protect
   IF (bcontinue=0)
    SET _rempending_job_label = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier9b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempending_job_label = _rempending_job_label
   IF (_rempending_job_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempending_job_label,((
       size(__pending_job_label) - _rempending_job_label)+ 1),__pending_job_label)))
    SET drawheight_pending_job_label = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempending_job_label = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempending_job_label,((size(
        __pending_job_label) - _rempending_job_label)+ 1),__pending_job_label)))))
     SET _rempending_job_label = (_rempending_job_label+ rptsd->m_drawlength)
    ELSE
     SET _rempending_job_label = 0
    ENDIF
    SET growsum = (growsum+ _rempending_job_label)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_pending_job_label
   IF (ncalc=rpt_render
    AND _holdrempending_job_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempending_job_label,
       ((size(__pending_job_label) - _holdrempending_job_label)+ 1),__pending_job_label)))
   ELSE
    SET _rempending_job_label = _holdrempending_job_label
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pending_job_protocol(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pending_job_protocolabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pending_job_protocolabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pending_job_protocol = f8 WITH noconstant(0.0), private
   DECLARE __pending_job_protocol = vc WITH noconstant(build2(eksctrequest->checkct[i].
     primary_mnemonic,char(0))), protect
   IF (bcontinue=0)
    SET _rempending_job_protocol = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempending_job_protocol = _rempending_job_protocol
   IF (_rempending_job_protocol > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempending_job_protocol,(
       (size(__pending_job_protocol) - _rempending_job_protocol)+ 1),__pending_job_protocol)))
    SET drawheight_pending_job_protocol = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempending_job_protocol = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempending_job_protocol,((size(
        __pending_job_protocol) - _rempending_job_protocol)+ 1),__pending_job_protocol)))))
     SET _rempending_job_protocol = (_rempending_job_protocol+ rptsd->m_drawlength)
    ELSE
     SET _rempending_job_protocol = 0
    ENDIF
    SET growsum = (growsum+ _rempending_job_protocol)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.750
   SET rptsd->m_height = drawheight_pending_job_protocol
   IF (ncalc=rpt_render
    AND _holdrempending_job_protocol > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdrempending_job_protocol,((size(__pending_job_protocol) - _holdrempending_job_protocol)+ 1
       ),__pending_job_protocol)))
   ELSE
    SET _rempending_job_protocol = _holdrempending_job_protocol
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pending_job_foot(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pending_job_footabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pending_job_footabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pending_job_label = f8 WITH noconstant(0.0), private
   DECLARE __pending_job_label = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "PENDING_JOB3_PRESCREEN_RPT",
      "The status of pending screening jobs can be monitored in the PowerTrials Screening Job Status application."
      ),char(0))), protect
   IF (bcontinue=0)
    SET _rempending_job_label = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempending_job_label = _rempending_job_label
   IF (_rempending_job_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempending_job_label,((
       size(__pending_job_label) - _rempending_job_label)+ 1),__pending_job_label)))
    SET drawheight_pending_job_label = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempending_job_label = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempending_job_label,((size(
        __pending_job_label) - _rempending_job_label)+ 1),__pending_job_label)))))
     SET _rempending_job_label = (_rempending_job_label+ rptsd->m_drawlength)
    ELSE
     SET _rempending_job_label = 0
    ENDIF
    SET growsum = (growsum+ _rempending_job_label)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_pending_job_label
   IF (ncalc=rpt_render
    AND _holdrempending_job_label > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempending_job_label,
       ((size(__pending_job_label) - _holdrempending_job_label)+ 1),__pending_job_label)))
   ELSE
    SET _rempending_job_label = _holdrempending_job_label
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE no_patient_qualified_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_patient_qualified_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE no_patient_qualified_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_no_patient_msg = f8 WITH noconstant(0.0), private
   DECLARE __no_patient_msg = vc WITH noconstant(build2(uar_i18ngetmessage(i18nhandle,
      "NO_PT_FOUND_PRESCREEN_RPT","None of the patients evaluated passed any protocol prescreening"),
     char(0))), protect
   IF (bcontinue=0)
    SET _remno_patient_msg = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.010)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremno_patient_msg = _remno_patient_msg
   IF (_remno_patient_msg > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remno_patient_msg,((size(
        __no_patient_msg) - _remno_patient_msg)+ 1),__no_patient_msg)))
    SET drawheight_no_patient_msg = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remno_patient_msg = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remno_patient_msg,((size(__no_patient_msg
        ) - _remno_patient_msg)+ 1),__no_patient_msg)))))
     SET _remno_patient_msg = (_remno_patient_msg+ rptsd->m_drawlength)
    ELSE
     SET _remno_patient_msg = 0
    ENDIF
    SET growsum = (growsum+ _remno_patient_msg)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.010)
   SET rptsd->m_width = 8.000
   SET rptsd->m_height = drawheight_no_patient_msg
   IF (ncalc=rpt_render
    AND _holdremno_patient_msg > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremno_patient_msg,((
       size(__no_patient_msg) - _holdremno_patient_msg)+ 1),__no_patient_msg)))
   ELSE
    SET _remno_patient_msg = _holdremno_patient_msg
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "CT_RPT_TRIAL_PRESCREEN_LO"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.25
   SET rptreport->m_marginbottom = 0.25
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 60
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_on
   SET _courier9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _courier80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _courier90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _courier100 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE encntrtypecd = f8 WITH public, noconstant(0.0)
 DECLARE facilitycd = f8 WITH public, noconstant(0.0)
 DECLARE startdttm = dq8 WITH public
 DECLARE enddttm = dq8 WITH public
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE outline = vc WITH public
 DECLARE eparse = c20 WITH public
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE num2 = i4 WITH public, noconstant(0)
 DECLARE screener_id = f8 WITH public, noconstant(0.0)
 DECLARE tmpexpression = vc WITH public
 DECLARE tmpparam = vc WITH public
 DECLARE toutputdev = vc WITH public
 DECLARE pmnemonic = vc WITH public
 DECLARE callingcnt = i2 WITH public, noconstant(0)
 DECLARE bset = i2 WITH public, noconstant(0)
 DECLARE prot_cnt = i2 WITH public, noconstant(0)
 DECLARE bfound = i2 WITH public, noconstant(0)
 DECLARE person_cnt = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE k = i4 WITH public, noconstant(0)
 DECLARE totallinestr = vc WITH public
 DECLARE datestr = vc WITH public
 DECLARE screenerstr = vc WITH public
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE mrn_count = i4 WITH public, noconstant(0)
 DECLARE title = vc WITH public
 DECLARE length = i2 WITH public, noconstant(0)
 DECLARE match_count = i4 WITH public, noconstant(0)
 DECLARE pooldisp = vc WITH public
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE lastrow = i2 WITH public, noconstant(0)
 DECLARE last_mod = c3 WITH public, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH public, noconstant(fillstring(30," "))
 DECLARE faccnt = i4 WITH public, noconstant(0)
 DECLARE persongender = f8 WITH public, noconstant(0.0)
 DECLARE personage = i2 WITH public, noconstant(0)
 DECLARE agequal = f8 WITH public, noconstant(0.0)
 DECLARE age1value = i4 WITH public, noconstant(0)
 DECLARE age2value = i4 WITH public, noconstant(0)
 DECLARE genderqual = vc WITH public
 DECLARE age_qual = vc WITH public
 DECLARE equal_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE grtrthan_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE grtrthaneq_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE lessthan_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE lessthaneq_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE notequal_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE between_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE agestartdttm = dq8 WITH public
 DECLARE ageenddttm = dq8 WITH public
 DECLARE age1lookback = vc WITH public
 DECLARE age2lookback = vc WITH public
 DECLARE minutes_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE hours_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE days_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE weeks_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE months_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE years_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE age1unit = f8 WITH public, noconstant(0.0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE checkprotcnt = i4 WITH public, noconstant(0)
 DECLARE pendingjob = f8 WITH public, constant(uar_get_code_by("MEANING",17917,"PENDING"))
 DECLARE pending_job_ind = i2 WITH public, noconstant(0)
 DECLARE labels = vc WITH public
 EXECUTE ct_trial_prescreen:dba  $OUTDEV,  $EXECMODE,  $STARTDATE,
  $ENDDATE,  $ENCNTRTYPECD,  $FACILITYCD,
  $TRIGGERNAME,  $ORDERBY,  $GENDER,
  $QUALIFIER,  $AGE1,  $AGE2,
  $EVALBY
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 IF ((eksctrequest->opsind=1)
  AND (eksctrequest->execmodeflag=1))
  IF (pending_job_ind=1)
   SET bfirsttime = 1
   WHILE (((_bcontpending_job_head=1) OR (bfirsttime=1)) )
     SET _bholdcontinue = _bcontpending_job_head
     SET _fdrawheight = pending_job_head(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ELSEIF (_bholdcontinue=1
      AND _bcontpending_job_head=0)
      CALL pagebreak(0)
     ENDIF
     SET dummy_val = pending_job_head(rpt_render,(_fenddetail - _yoffset),_bcontpending_job_head)
     SET bfirsttime = 0
   ENDWHILE
   FOR (i = 1 TO size(eksctrequest->checkct,5))
    SET bfirsttime = 1
    WHILE (((_bcontpending_job_protocol=1) OR (bfirsttime=1)) )
      SET _bholdcontinue = _bcontpending_job_protocol
      SET _fdrawheight = pending_job_protocol(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
      IF (((_yoffset+ _fdrawheight) > _fenddetail))
       CALL pagebreak(0)
      ELSEIF (_bholdcontinue=1
       AND _bcontpending_job_protocol=0)
       CALL pagebreak(0)
      ENDIF
      SET dummy_val = pending_job_protocol(rpt_render,(_fenddetail - _yoffset),
       _bcontpending_job_protocol)
      SET bfirsttime = 0
    ENDWHILE
   ENDFOR
   SET bfirsttime = 1
   WHILE (((_bcontpending_job_foot=1) OR (bfirsttime=1)) )
     SET _bholdcontinue = _bcontpending_job_foot
     SET _fdrawheight = pending_job_foot(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ELSEIF (_bholdcontinue=1
      AND _bcontpending_job_foot=0)
      CALL pagebreak(0)
     ENDIF
     SET dummy_val = pending_job_foot(rpt_render,(_fenddetail - _yoffset),_bcontpending_job_foot)
     SET bfirsttime = 0
   ENDWHILE
   GO TO endreport
  ENDIF
 ENDIF
 IF (((eksctrequest->opsind) OR ((eksctrequest->execmodeflag=- (1)))) )
  SET _bsubreport = 1
  EXECUTE ct_sub_rpt_trial_prescreen_pt  $OUTDEV,  $EXECMODE,  $STARTDATE,
   $ENDDATE,  $ENCNTRTYPECD,  $FACILITYCD,
   $TRIGGERNAME,  $ORDERBY,  $GENDER,
   $QUALIFIER,  $AGE1,  $AGE2,
   $EVALBY
  SET _bsubreport = 0
 ENDIF
 IF (cnt
  AND ( $EXECMODE != "PATIENTINQ"))
  IF ( NOT (eksctrequest->opsind)
   AND ( $EXECMODE != "PATIENTINQ"))
   IF ((eksctreply->ctfndind=1))
    IF (size(eksctreply->qual,5) > 0)
     IF (size(screenerstr)=0)
      SELECT INTO "nl:"
       FROM person p
       WHERE (p.person_id=reqinfo->updt_id)
       DETAIL
        screenerstr = p.name_full_formatted
       WITH nocounter
      ;end select
     ENDIF
     IF (( $ORDERBY=1))
      SET _bsubreport = 1
      EXECUTE ct_sub_rpt_prescreen_by_person  $OUTDEV,  $EXECMODE,  $STARTDATE,
       $ENDDATE,  $ENCNTRTYPECD,  $FACILITYCD,
       $TRIGGERNAME,  $ORDERBY,  $GENDER,
       $QUALIFIER,  $AGE1,  $AGE2,
       $EVALBY
      SET _bsubreport = 0
     ENDIF
     IF (( $ORDERBY=0))
      SET _bsubreport = 1
      EXECUTE ct_sub_rpt_prescreen_by_prot  $OUTDEV,  $EXECMODE,  $STARTDATE,
       $ENDDATE,  $ENCNTRTYPECD,  $FACILITYCD,
       $TRIGGERNAME,  $ORDERBY,  $GENDER,
       $QUALIFIER,  $AGE1,  $AGE2,
       $EVALBY
      SET _bsubreport = 0
     ENDIF
    ENDIF
   ELSE
    SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
    SET bfirsttime = 1
    WHILE (((_bcontno_patient_qualified_section=1) OR (bfirsttime=1)) )
      SET _bholdcontinue = _bcontno_patient_qualified_section
      SET _fdrawheight = no_patient_qualified_section(rpt_calcheight,(_fenddetail - _yoffset),
       _bholdcontinue)
      IF (((_yoffset+ _fdrawheight) > _fenddetail))
       CALL pagebreak(0)
      ELSEIF (_bholdcontinue=1
       AND _bcontno_patient_qualified_section=0)
       CALL pagebreak(0)
      ENDIF
      SET dummy_val = no_patient_qualified_section(rpt_render,(_fenddetail - _yoffset),
       _bcontno_patient_qualified_section)
      SET bfirsttime = 0
    ENDWHILE
   ENDIF
  ENDIF
 ENDIF
#endreport
 CALL finalizereport(_sendto)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF ((eksctrequest->opsind=1)
  AND (eksctrequest->execmodeflag=1))
  IF (pending_job_ind=1)
   GO TO endprogram
  ENDIF
 ENDIF
 IF (cnt=0)
  SELECT INTO  $OUTDEV
   WHERE 1=1
   DETAIL
    row + 1, outline = uar_i18nbuildmessage(i18nhandle,"NO_PT_PRESCREEN_RPT",
     "No eligible patients found from %1 to %2.","ss",nullterm(trim(format(startdttm,
        "@LONGDATE;t(3);q"),3)),
     nullterm(trim(format(enddttm,"@LONGDATE;t(3);q"),3))), col 5,
    outline
   WITH nocounter
  ;end select
 ENDIF
#endprogram
 SET last_mod = "004"
 SET mod_date = "Dec 14, 2017"
END GO
