CREATE PROGRAM bhs_dvt_risk_opsjobtask:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Type in email address or select report type:" = "Report",
  "email address" = "",
  "Send inbox messages to attending phy:" = "0"
  WITH outdev, bdate, edate,
  reporttype, email
 RECORD inboxrequest(
   1 person_id = f8
   1 encntr_id = f8
   1 stat_ind = i2
   1 task_type_cd = f8
   1 task_type_meaning = c12
   1 reference_task_id = f8
   1 task_dt_tm = dq8
   1 task_activity_meaning = c12
   1 msg_text = c32768
   1 msg_subject_cd = f8
   1 msg_subject = c255
   1 confidential_ind = i2
   1 read_ind = i2
   1 delivery_ind = i2
   1 event_id = f8
   1 event_class_meaning = c12
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
   1 task_status_meaning = c12
 )
 RECORD inboxreply(
   1 task_status = c1
   1 task_id = f8
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
     2 encntr_sec_ind = i2
   1 status_data
     2 status = c1
     2 substatus = i2
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 FREE RECORD patlist
 RECORD patlist(
   1 qual[*]
     2 encntr_id = f8
 )
 FREE RECORD patalert
 RECORD patalert(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 pat_name = vc
     2 attdprnslid = f8
     2 attdphy = vc
     2 alertmessage = vc
     2 currentprophylaxis = vc
     2 dvtrisk = vc
     2 nurseunit = vc
     2 room = vc
     2 alert[*]
       3 alerttype = i4
       3 alertreason = vc
       3 satisfied = i4
 )
 FREE RECORD alertinfo
 RECORD alertinfo(
   1 qual[*]
     2 messagepart1 = vc
     2 messagepart2 = vc
     2 satisfiers = vc
 )
 FREE RECORD truealert
 RECORD truealert(
   1 qual[*]
     2 encntr_id = f8
     2 alertmessage = vc
 )
 DECLARE pharmacologicprophylaxisfordvt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PHARMACOLOGICPROPHYLAXISFORDVT")), protect
 DECLARE plannedanticoagulation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PLANNEDANTICOAGULATION")), protect
 DECLARE riskofvenousthromboembolism = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "RISKOFVENOUSTHROMBOEMBOLISM")), protect
 DECLARE pharmacologicprophylaxisofdvt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHARMACOLOGICPROPHYLAXISOFDVT")), protect
 DECLARE historyexperienceof = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HISTORYEXPERIENCEOF"
   )), protect
 DECLARE riskfactorsfordvt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"RISKFACTORSFORDVT")),
 protect
 DECLARE dvtrisk = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DVTRISK")), protect
 DECLARE intenttofullyanticoagulate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INTENTTOFULLYANTICOAGULATE")), protect
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE active = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE expandcnt = i4 WITH protect, constant(140)
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE locnum = i4 WITH protect
 DECLARE pos2 = i4 WITH protect
 DECLARE locnum2 = i4 WITH protect
 DECLARE actual_size = i4 WITH protect
 DECLARE expand_total = i4 WITH protect
 DECLARE expand_start = i4 WITH noconstant(1), protect
 DECLARE expand_stop = i4 WITH noconstant(expandcnt), protect
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS")), protect
 DECLARE medstudent = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT")), protect
 DECLARE ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING")), protect
 DECLARE pendingrev = f8 WITH constant(uar_get_code_by("MEANING",6004,"PENDING REV")), protect
 DECLARE completed = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED")), protect
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE orderc = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
 DECLARE pneumaticcompressionboots = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "PNEUMATICCOMPRESSIONBOOTS")), protect
 DECLARE warfarin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN")), protect
 DECLARE enoxaparin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ENOXAPARIN")), protect
 DECLARE heparin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN")), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 SET attending = uar_get_code_by("displaykey",333,"ATTENDINGPHYSICIAN")
 DECLARE mock = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"MOCK")), protect
 DECLARE fullyanticoagulate = i4 WITH noconstant(0)
 DECLARE current_prophylaxis = vc WITH noconstant(" ")
 DECLARE patalertcnt = i4 WITH noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headrpt(ncalc=i2) = f8 WITH protect
 DECLARE headrptabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE secunit(ncalc=i2) = f8 WITH protect
 DECLARE secunitabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headperson(ncalc=i2) = f8 WITH protect
 DECLARE headpersonabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headdvt(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headdvtabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headappropiate(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE headappropiateabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footpage(ncalc=i2) = f8 WITH protect
 DECLARE footpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontheaddvt = i2 WITH noconstant(0), protect
 DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
 DECLARE _bcontheadappropiate = i2 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times24u0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE headrpt(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headrptabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headrptabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.590000), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime),";;q"),char(
      0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.510
    SET _oldfont = uar_rptsetfont(_hreport,_times24u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DVT Prophylaxis Report",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.552
    SET rptsd->m_height = 0.208
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE secunit(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = secunitabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE secunitabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.125)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.229
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(nurseunit,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headperson(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpersonabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpersonabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.208
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 3.646)
    SET rptsd->m_width = 0.854
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account #:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.646)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending Phy:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.396
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Current prophylaxis:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 0.542)
    SET rptsd->m_width = 3.104
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pat_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.094)
    SET rptsd->m_x = (offsetx+ 4.344)
    SET rptsd->m_width = 2.698
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(room,char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.792)
    SET rptsd->m_width = 2.698
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(acct_num,char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.594)
    SET rptsd->m_width = 2.698
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(attd_phy,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 6.250
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(current_prophylaxis2,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.104),(offsetx+ 7.500),(offsety+
     0.104))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headdvt(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headdvtabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headdvtabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(dvt_issue,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname2 = 1
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
   SET rptsd->m_x = (offsetx+ 0.792)
   SET rptsd->m_width = 6.396
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname2 = _remfieldname2
   IF (_remfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
        __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
    SET drawheight_fieldname2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
       _remfieldname2)+ 1),__fieldname2)))))
     SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname2 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname2)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.042)
   SET rptsd->m_width = 0.802
   SET rptsd->m_height = 0.208
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DVT Issue:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.792)
   SET rptsd->m_width = 6.396
   SET rptsd->m_height = drawheight_fieldname2
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size(
        __fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
   ELSE
    SET _remfieldname2 = _holdremfieldname2
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE headappropiate(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headappropiateabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headappropiateabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(trim(appropiate_prophylaxis,3),char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname2 = 1
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
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname2 = _remfieldname2
   IF (_remfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
        __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
    SET drawheight_fieldname2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
       _remfieldname2)+ 1),__fieldname2)))))
     SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname2 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname2)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.292)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.208
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Appropiate Prophylaxis:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 5.625
   SET rptsd->m_height = drawheight_fieldname2
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size(
        __fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
   ELSE
    SET _remfieldname2 = _holdremfieldname2
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
 SUBROUTINE footpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.344)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.208
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_DVT_RISK_OPSJOBTASK"
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
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 24
   SET rptfont->m_underline = rpt_on
   SET _times24u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_off
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET tab = fillstring(6,char(32))
 SET stat = alterlist(alertinfo->qual,9)
 SET alertinfo->qual[1].messagepart1 = build(
  "This patient has the following contraindication to pharmacologic prophylaxis")
 SET alertinfo->qual[1].messagepart2 = build("Please consider ordering the following")
 SET alertinfo->qual[1].satisfiers = concat(tab,"Pneumatic compression boot")
 SET alertinfo->qual[2].messagepart1 = concat(
  "This patient has been admitted for hip or knee arthroplasty but does not have ",
  "an active order for low molecular weight heparin or warfarin.")
 SET alertinfo->qual[2].messagepart2 = build("Please consider ordering one of the following")
 SET alertinfo->qual[2].satisfiers = concat(tab,
  "Warfarin (goal INR 2-3) - Starting the evening of surgery",char(10),tab,
  "Enoxaparin 30 mg SC Q12 hr - Starting 12-24 hr post-op",
  char(10),tab,"Enoxaparin 40 mg SC Q24 hr - Starting 12-24 hr post-op")
 SET alertinfo->qual[4].messagepart1 = build(
  "This patient has a history of or has experienced the following")
 SET alertinfo->qual[4].messagepart2 = build("Please consider ordering one of the following")
 SET alertinfo->qual[4].satisfiers = concat(tab,
  "Enoxaparin 30 mg SC Q12 hr - ONCE PRIMARY HEMOSTATIS IS ENSURED",char(10),tab,
  "Enoxaparin 40 mg SC Q24 hr",
  char(10),tab,"Heparin 5000 units sq q8 with compression boots")
 SET alertinfo->qual[5].messagepart1 = concat(
  "This patient was documented to be at MODERATE risk of DVT and ",
  "does not have a contraindication to pharmacologic prophylaxis but does not yet have ",
  "an active order for heparin or enoxaparin",char(10),char(10),
  "Patient's Condition")
 SET alertinfo->qual[5].messagepart2 = build("Please consider ordering one of the following")
 SET alertinfo->qual[5].satisfiers = concat(tab,"Heparin 5000 units sq q8",char(10),tab,
  "Enoxaparin 40 mg SC Q24 hr")
 SET alertinfo->qual[6].messagepart1 = concat(
  "This patient was documented to be at MODERATE risk of DVT and ",
  "does not have a contraindication to pharmacologic prophylaxis but does not yet have ",
  "an active order for heparin or enoxaparin")
 SET alertinfo->qual[6].messagepart2 = build(
  "Please consider ordering pneumatic compression boots and one of the following")
 SET alertinfo->qual[6].satisfiers = concat(tab,"Heparin 5000 units sq q8",char(10),tab,
  "Enoxaparin 40mg sq qd")
 SET alertinfo->qual[9].messagepart1 = concat(
  "This patient was documented to be at VERY HIGH/HIGH risk of DVT and ",
  "does not have a contraindication to pharmacologic prophylaxis but does not yet have ",
  "an active order for enoxaparin or warfarin.",char(10),char(10),
  "This patient has a history of or has experienced one of the following")
 SET alertinfo->qual[9].messagepart2 =
 "Please consider ordering pneumatic compression boots and one of the following"
 SET alertinfo->qual[9].satisfiers = concat(tab,
  "Heparin(Heparin Inj) - 5,000 units, Injection, Subcutaneous Injection, Every 8 hours",char(10),tab,
  "Enoxaparin (Enoxaparin Inj)- 40 mg, Injection, Subcutaneous Injection, Every 24 hours",
  char(10),tab,"If Creatinine Clearance < 30 mL/min",char(10),tab,
  "Enoxaparin (Enoxaparin Inj)- 30 mg, Injection, Subcutaneous Injection, Every 24 hours",char(10),
  tab,"Warfarin (Warfarin Tablet) - mg, Tablet, By Mouth, Once, T;1800",char(10),
  tab,"Pneumatic compression Boots - Patient to Wear Continuously, until fully ambulatory")
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  IF (cnvtupper( $REPORTTYPE)="SPREADSHEET")
   SET var_output = "dvtriskopsjob.csv"
  ELSE
   SET var_output = "dvtriskopsjob.pdf"
  ENDIF
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 IF (cnvtupper( $BDATE) IN ("BEGOFPREVDAY", "BOD"))
  SET beg_date_qual = cnvtdatetime((curdate - 1),030000)
  SET end_date_qual = cnvtdatetime(curdate,curtime3)
  CALL echo(format(cnvtdatetime(beg_date_qual),";;q"))
  CALL echo(format(cnvtdatetime(end_date_qual),";;q"))
 ELSE
  SET beg_date_qual = cnvtdatetime( $BDATE)
  SET end_date_qual = cnvtdatetime( $EDATE)
  IF (datetimediff(end_date_qual,beg_date_qual) > 31)
   CALL echo("Date range > 31")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
   GO TO exit_program
  ELSEIF (datetimediff(cnvtdatetime(end_date_qual),cnvtdatetime(beg_date_qual)) < 0)
   CALL echo("Date range < 0")
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
     "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08
   ;end select
   GO TO exit_program
  ENDIF
 ENDIF
 CALL echo(format(cnvtdatetime(beg_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual),";;q"))
 SET reccnt = 0
 CALL echo("Logic to find DVT Risk CareSet Orders")
 SELECT INTO "NL:"
  o.encntr_id, o.catalog_cd, o.orig_order_dt_tm
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
    AND o.catalog_cd IN (pharmacologicprophylaxisfordvt, plannedanticoagulation,
   riskofvenousthromboembolism)
    AND o.order_status_cd IN (completed, ordered)
    AND o.active_ind=1
    AND o.template_order_id=0)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence=1
    AND od.oe_field_meaning_id=9000
    AND  NOT (cnvtupper(trim(od.oe_field_display_value,3)) IN ("YES")))
  ORDER BY o.encntr_id, o.catalog_cd, o.orig_order_dt_tm DESC
  HEAD REPORT
   IF (size(patalert->qual,5) < 1)
    stat = alterlist(patalert->qual,100)
   ENDIF
  HEAD o.encntr_id
   fullyanticoagulate = 0, patalertcnt = (patalertcnt+ 1), alertcnt = 0
   IF (mod(patalertcnt,100)=1
    AND patalertcnt != 1)
    stat = alterlist(patalert->qual,(patalertcnt+ 99))
   ENDIF
   CALL echo("******encntrHead**********"),
   CALL echo(build("why:",o.encntr_id,"COUNT:",patalertcnt)), patalert->qual[patalertcnt].encntr_id
    = o.encntr_id,
   patalert->qual[patalertcnt].person_id = o.person_id,
   CALL echo(patalert->qual[patalertcnt].encntr_id)
  HEAD o.catalog_cd
   stat = 0
  HEAD o.orig_order_dt_tm
   stat = 0
  DETAIL
   IF (cnvtupper(trim(od.oe_field_display_value,3)) IN ("VERY HIGH/HIGH RISK"))
    alertcnt = (alertcnt+ 1),
    CALL echo(od.oe_field_display_value), stat = alterlist(patalert->qual[patalertcnt].alert,alertcnt
     ),
    patalert->qual[patalertcnt].alert[alertcnt].alerttype = 9, patalert->qual[patalertcnt].alert[
    alertcnt].alertreason = concat(char(10),tab,
     "Medical Patients with increased factors/co-morbidities;",char(10),tab,
     "Surgical pts undergoing major surgery (such as but not limited to general",
     " or orthopedic surgey (such as TJR procedures); ",char(10),tab,
     "patients with history of DVT/PE.",
     char(10),tab,"Trauma/Spinal Cord Injury/Burns as soon as safe")
   ELSEIF (cnvtupper(trim(od.oe_field_display_value,3)) IN ("MODERATE RISK*"))
    alertcnt = (alertcnt+ 1), stat = alterlist(patalert->qual[patalertcnt].alert,alertcnt), patalert
    ->qual[patalertcnt].alert[alertcnt].alerttype = 6,
    patalert->qual[patalertcnt].alert[alertcnt].alertreason = concat(char(10),tab,
     "Risk factor include any of the following:",char(10),tab,
     "Surgery requiring full admission, Ischemic stroke, Cancer, Heart failure,",char(10),tab,
     "Expected immobility greater than 24 hours, History of VTE, Hypercoagulable state,",char(10),
     tab,"Lung disease requiring oxygen or inability to walk greater than 1 block")
   ELSEIF (cnvtupper(trim(od.oe_field_display_value,3)) IN ("*FULLY ANTICOAGULATE*"))
    fullyanticoagulate = 1
   ELSEIF (o.catalog_cd IN (pharmacologicprophylaxisfordvt))
    fullyanticoagulate = 1,
    CALL echo("PHARMACOLOGICPROPHYLAXISFORDVT")
   ENDIF
  FOOT  o.orig_order_dt_tm
   stat = 0
  FOOT  o.catalog_cd
   stat = 0
  FOOT  o.encntr_id
   IF (fullyanticoagulate=1)
    CALL echo("FullyAnticoagulate"), tempsize = size(patalert->qual,5), patalertcnt = (patalertcnt -
    1),
    stat = alterlist(patalert->qual,patalertcnt), stat = alterlist(patalert->qual,tempsize)
   ENDIF
   CALL echo("******encntrFOOT**********")
  FOOT REPORT
   stat = alterlist(patalert->qual,patalertcnt)
  WITH separator = " ", format
 ;end select
 CALL echorecord(patalert)
 IF (size(patalert->qual,5) <= 0)
  CALL echo("no Patients Found")
  GO TO exit_program
 ENDIF
 CALL echo(build("Patients Found:",size(patalert->qual,5)))
 CALL echo("Locate Satisfiers")
 SET num = 1
 SELECT INTO "NL:"
  o.encntr_id, o.catalog_cd
  FROM orders o,
   order_action oa,
   order_ingredient oi
  PLAN (o
   WHERE expand(num,1,size(patalert->qual,5),o.encntr_id,patalert->qual[num].encntr_id)
    AND o.order_status_cd IN (inprocess, medstudent, ordered, pending, pendingrev)
    AND ((o.activity_type_cd+ 0)=pharmacy))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND ((oa.action_type_cd+ 0)=orderc))
   JOIN (oi
   WHERE oi.order_id=o.order_id
    AND oi.action_sequence=oa.action_sequence
    AND oi.catalog_cd IN (warfarin, enoxaparin, heparin))
  ORDER BY o.encntr_id, oi.catalog_cd
  HEAD o.encntr_id
   stat = 0
  HEAD oi.catalog_cd
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(patalert->qual,5),o.encntr_id,patalert->qual[
    locnum].encntr_id)
   IF (pos > 0)
    locnum = pos
    FOR (x = 1 TO size(patalert->qual[locnum].alert,5))
     tempalerttype = patalert->qual[locnum].alert[x].alerttype,
     IF (oi.catalog_cd IN (warfarin)
      AND tempalerttype IN (2, 3, 4, 5, 6,
     9))
      patalert->qual[locnum].alert[pos2].satisfied = 1
     ELSEIF (oi.catalog_cd IN (enoxaparin)
      AND tempalerttype IN (2, 3, 4, 5, 6,
     9))
      patalert->qual[locnum].alert[pos2].satisfied = 1
     ELSEIF (oi.catalog_cd IN (heparin)
      AND tempalerttype IN (5, 6, 7))
      patalert->qual[locnum].alert[pos2].satisfied = 1
     ENDIF
    ENDFOR
    IF (textlen(trim(patalert->qual[pos].currentprophylaxis,3)) > 0)
     patalert->qual[pos].currentprophylaxis = build(patalert->qual[pos].currentprophylaxis,", ")
    ENDIF
    patalert->qual[pos].currentprophylaxis = build(patalert->qual[pos].currentprophylaxis,
     uar_get_code_display(oi.catalog_cd))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  o.encntr_id, o.catalog_cd
  FROM orders o
  PLAN (o
   WHERE expand(num,1,size(patalert->qual,5),o.encntr_id,patalert->qual[num].encntr_id)
    AND o.order_status_cd IN (inprocess, medstudent, ordered, pending, pendingrev)
    AND o.catalog_cd IN (pneumaticcompressionboots))
  ORDER BY o.encntr_id, o.catalog_cd
  HEAD o.catalog_cd
   IF (textlen(trim(patalert->qual[pos].currentprophylaxis,3)) > 0)
    patalert->qual[pos].currentprophylaxis = build(patalert->qual[pos].currentprophylaxis,", ")
   ENDIF
   patalert->qual[pos].currentprophylaxis = build(patalert->qual[pos].currentprophylaxis,
    uar_get_code_display(o.catalog_cd))
  WITH nocounter
 ;end select
 CALL echo("Build patient alerts")
 SET type = 0
 FOR (x = 1 TO size(patalert->qual,5))
   FOR (y = 1 TO size(patalert->qual[x].alert,5))
     IF ((patalert->qual[x].alert[y].alerttype > 0)
      AND (patalert->qual[x].alert[y].satisfied <= 0))
      IF (textlen(trim(patalert->qual[x].alertmessage,3)) > 0)
       SET patalert->qual[x].alertmessage = concat(patalert->qual[x].alertmessage,char(10),char(10))
      ENDIF
      SET type = patalert->qual[x].alert[y].alerttype
      SET patalert->qual[x].alertmessage = concat(patalert->qual[x].alertmessage,alertinfo->qual[type
       ].messagepart1)
      IF (textlen(trim(patalert->qual[x].alert[y].alertreason)) > 0)
       SET patalert->qual[x].alertmessage = concat(patalert->qual[x].alertmessage,char(10),char(10),
        "            ",patalert->qual[x].alert[y].alertreason)
      ENDIF
      SET patalert->qual[x].alertmessage = concat(patalert->qual[x].alertmessage,char(10),char(10),
       " ",alertinfo->qual[type].messagepart2,
       char(10),alertinfo->qual[type].satisfiers,char(10),
       "__________________________________________________________________")
     ENDIF
   ENDFOR
   CALL echo(
    "########################################################################################")
   CALL echo(patalert->qual[x].alertmessage)
   CALL echo(
    "########################################################################################")
 ENDFOR
 CALL echo("Locate Attd Phy")
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (epr
   WHERE expand(num,1,size(patalert->qual,5),epr.encntr_id,patalert->qual[num].encntr_id)
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=attending
    AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  DETAIL
   pos = 0, locnum = 0, pos = locateval(locnum,1,size(patalert->qual,5),epr.encntr_id,patalert->qual[
    locnum].encntr_id)
   IF (pos > 0)
    patalert->qual[pos].attdphy = trim(pr.name_full_formatted,3), patalert->qual[pos].attdprnslid =
    pr.person_id,
    CALL echo(build("attd:",epr.prsnl_person_id))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(patalert)
 CALL echo("Find patient location")
 SET num = 0
 SELECT INTO "NL:"
  elh.encntr_id, elh.encntr_loc_hist_id, room = build(uar_get_code_display(elh.loc_room_cd),"-",
   uar_get_code_display(elh.loc_bed_cd))
  FROM encntr_loc_hist elh
  WHERE expand(num,1,size(patalert->qual,5),elh.encntr_id,patalert->qual[num].encntr_id)
   AND elh.beg_effective_dt_tm < cnvtdatetime(end_date_qual)
   AND elh.end_effective_dt_tm > cnvtdatetime(beg_date_qual)
  ORDER BY elh.encntr_id, elh.encntr_loc_hist_id DESC
  HEAD elh.encntr_id
   CALL echo(uar_get_code_display(elh.loc_nurse_unit_cd)), pos = 0, locnum = 0,
   pos = locateval(locnum,1,size(patalert->qual,5),elh.encntr_id,patalert->qual[locnum].encntr_id)
   IF (pos > 0)
    patalert->qual[pos].nurseunit = trim(uar_get_code_display(elh.loc_nurse_unit_cd),3), patalert->
    qual[pos].room = trim(room,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(patalert)
 CALL echo(curqual)
 CALL echo("End locate qualifying patients")
 DECLARE req = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hreply = i4
 DECLARE crmstatus = i4
 SET ecrmok = 0
 SET null = 0
 IF (validate(recdate,"Y")="Y"
  AND validate(recdate,"N")="N")
  RECORD recdate(
    1 datetime = dq8
  )
 ENDIF
 SUBROUTINE srvrequest(taskhandle,reqno)
   SET htask = taskhandle
   SET req = reqno
   SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
   IF (crmstatus != ecrmok)
    CALL echo("Invalid CrmBeginReq return status")
   ELSEIF (hreq=null)
    CALL echo("Invalid hReq handle")
   ELSE
    SET request_handle = hreq
    SET hinboxrequest = uar_crmgetrequest(hreq)
    IF (hinboxrequest=null)
     CALL echo("Invalid request handle return from CrmGetRequest")
    ELSE
     SET stat = uar_srvsetdouble(hinboxrequest,"PERSON_ID",inboxrequest->person_id)
     SET stat = uar_srvsetdouble(hinboxrequest,"ENCNTR_ID",inboxrequest->encntr_id)
     SET stat = uar_srvsetshort(hinboxrequest,"STAT_IND",cnvtint(inboxrequest->stat_ind))
     SET stat = uar_srvsetdouble(hinboxrequest,"TASK_TYPE_CD",inboxrequest->task_type_cd)
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_TYPE_MEANING",nullterm(inboxrequest->
       task_type_meaning))
     SET stat = uar_srvsetdouble(hinboxrequest,"REFERENCE_TASK_ID",inboxrequest->reference_task_id)
     SET recdate->datetime = inboxrequest->task_dt_tm
     SET stat = uar_srvsetdate2(hinboxrequest,"TASK_DT_TM",recdate)
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_ACTIVITY_MEANING",nullterm(inboxrequest->
       task_activity_meaning))
     SET stat = uar_srvsetstring(hinboxrequest,"MSG_TEXT",nullterm(inboxrequest->msg_text))
     SET stat = uar_srvsetdouble(hinboxrequest,"MSG_SUBJECT_CD",inboxrequest->msg_subject_cd)
     SET stat = uar_srvsetstring(hinboxrequest,"MSG_SUBJECT",nullterm(inboxrequest->msg_subject))
     SET stat = uar_srvsetshort(hinboxrequest,"CONFIDENTIAL_IND",cnvtint(inboxrequest->
       confidential_ind))
     SET stat = uar_srvsetshort(hinboxrequest,"READ_IND",cnvtint(inboxrequest->read_ind))
     SET stat = uar_srvsetshort(hinboxrequest,"DELIVERY_IND",cnvtint(inboxrequest->delivery_ind))
     SET stat = uar_srvsetdouble(hinboxrequest,"EVENT_ID",inboxrequest->event_id)
     SET stat = uar_srvsetstring(hinboxrequest,"EVENT_CLASS_MEANING",nullterm(inboxrequest->
       event_class_meaning))
     FOR (ndx1 = 1 TO size(inboxrequest->assign_prsnl_list,5))
      SET hassign_prsnl_list = uar_srvadditem(hinboxrequest,"ASSIGN_PRSNL_LIST")
      IF (hassign_prsnl_list=null)
       CALL echo("ASSIGN_PRSNL_LIST","Invalid handle")
      ELSE
       SET stat = uar_srvsetdouble(hassign_prsnl_list,"ASSIGN_PRSNL_ID",inboxrequest->
        assign_prsnl_list[ndx1].assign_prsnl_id)
      ENDIF
     ENDFOR
     SET stat = uar_srvsetstring(hinboxrequest,"TASK_STATUS_MEANING",nullterm(inboxrequest->
       task_status_meaning))
    ENDIF
   ENDIF
   IF (crmstatus=ecrmok)
    CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime,"hh:mm:ss.cc;3;m")))
    SET crmstatus = uar_crmperform(hreq)
    CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime,"hh:mm:ss.cc;3;m")))
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmPerform return status")
    ENDIF
   ELSE
    CALL echo("CrmPerform not executed do to begin request error")
   ENDIF
 END ;Subroutine
 SUBROUTINE srvreply(taskhandle,reqno)
   DECLARE item_cnt = i4 WITH protect
   SET htask = taskhandle
   SET req = reqno
   IF (crmstatus=ecrmok)
    SET hinboxreply = uar_crmgetreply(hreq)
    IF (hinboxreply=null)
     CALL echo("Invalid handle from CrmGetReply")
    ELSE
     CALL echo("Retrieving reply message")
     SET inboxreply->task_status = uar_srvgetstringptr(hinboxreply,"TASK_STATUS")
     SET inboxreply->task_id = uar_srvgetdouble(hinboxreply,"TASK_ID")
     SET item_cnt = uar_srvgetitemcount(hinboxreply,"ASSIGN_PRSNL_LIST")
     SET stat = alterlist(inboxreply->assign_prsnl_list,item_cnt)
     FOR (ndx1 = 1 TO item_cnt)
      SET hassign_prsnl_list = uar_srvgetitem(hinboxreply,"ASSIGN_PRSNL_LIST",(ndx1 - 1))
      IF (hassign_prsnl_list=null)
       CALL echo("Invalid handle return from SrvGetItem for hASSIGN_PRSNL_LIST")
      ELSE
       SET inboxreply->assign_prsnl_list[ndx1].assign_prsnl_id = uar_srvgetdouble(hassign_prsnl_list,
        "ASSIGN_PRSNL_ID")
       SET inboxreply->assign_prsnl_list[ndx1].encntr_sec_ind = uar_srvgetshort(hassign_prsnl_list,
        "ENCNTR_SEC_IND")
      ENDIF
     ENDFOR
     SET hstatus_data = uar_srvgetstruct(hinboxreply,"STATUS_DATA")
     IF (hstatus_data=null)
      CALL echo("Invalid handle")
     ELSE
      SET inboxreply->status_data.status = uar_srvgetstringptr(hstatus_data,"STATUS")
      SET inboxreply->status_data.substatus = uar_srvgetshort(hstatus_data,"SUBSTATUS")
      SET item_cnt = uar_srvgetitemcount(hstatus_data,"SUBEVENTSTATUS")
      SET stat = alterlist(inboxreply->status_data.subeventstatus,item_cnt)
      FOR (ndx2 = 1 TO item_cnt)
       SET hsubeventstatus = uar_srvgetitem(hstatus_data,"SUBEVENTSTATUS",(ndx2 - 1))
       IF (hsubeventstatus=null)
        CALL echo("Invalid handle return from SrvGetItem for hSUBEVENTSTATUS")
       ELSE
        SET inboxreply->status_data.subeventstatus[ndx2].operationname = uar_srvgetstringptr(
         hsubeventstatus,"OPERATIONNAME")
        SET inboxreply->status_data.subeventstatus[ndx2].operationstatus = uar_srvgetstringptr(
         hsubeventstatus,"OPERATIONSTATUS")
        SET inboxreply->status_data.subeventstatus[ndx2].targetobjectname = uar_srvgetstringptr(
         hsubeventstatus,"TARGETOBJECTNAME")
        SET inboxreply->status_data.subeventstatus[ndx2].targetobjectvalue = uar_srvgetstringptr(
         hsubeventstatus,"TARGETOBJECTVALUE")
       ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ELSE
    CALL echo("Could not retrieve reply due to CrmBegin request error")
   ENDIF
   CALL echo("Ending CRM Request")
   CALL uar_crmendreq(hreq)
 END ;Subroutine
 IF (email_ind=1)
  FOR (x = 1 TO size(patalert->qual,5))
   CALL echo(build("Send inbox messages. PersonID:",patalert->qual[x].person_id))
   IF (textlen(trim(patalert->qual[x].alertmessage)) > 1
    AND (patalert->qual[x].attdprnslid > 0))
    CALL echo(build("Inbox sent to:",patalert->qual[x].attdprnslid))
    SET inboxrequest->person_id = patalert->qual[x].person_id
    SET inboxrequest->encntr_id = patalert->qual[x].encntr_id
    SET inboxrequest->stat_ind = 1
    SET inboxrequest->task_type_cd = 0
    SET inboxrequest->task_type_meaning = "PHONE MSG"
    SET inboxrequest->reference_task_id = 0
    SET inboxrequest->task_dt_tm = cnvtdatetime(curdate,curtime3)
    SET inboxrequest->task_activity_meaning = "comp pers"
    SET inboxrequest->msg_text = fillstring(3100," ")
    SET inboxrequest->msg_text = patalert->qual[x].alertmessage
    SET inboxrequest->msg_subject_cd = 0
    SET inboxrequest->msg_subject = "DVT Risk Assessment Alert"
    SET inboxrequest->confidential_ind = 0
    SET inboxrequest->read_ind = 0
    SET inboxrequest->delivery_ind = 0
    SET inboxrequest->event_id = 0
    SET inboxrequest->event_class_meaning = " "
    SET inboxrequest->task_status_meaning = " "
    SET stat = alterlist(inboxrequest->assign_prsnl_list,1)
    SET inboxrequest->assign_prsnl_list[1].assign_prsnl_id = patalert->qual[x].attdprnslid
    CALL echo(build("Exit select:",curqual))
    SET reqc = 967102
    SET happc = 0
    SET appc = 3055000
    SET taskc = 3202004
    SET htaskc = 0
    SET hreqc = 0
    SET stat = uar_crmbeginapp(appc,happc)
    SET stat = uar_crmbegintask(happc,taskc,htaskc)
    CALL echo(build("beginReq",stat))
    CALL srvrequest(htaskc,reqc)
    CALL srvreply(htaskc,reqc)
    CALL echorecord(inboxrequest)
    CALL echorecord(inboxreply)
   ELSE
    CALL echo("Not sending message either no alert (may have been satisfied) or no attending")
   ENDIF
  ENDFOR
 ENDIF
 IF (size(patalert->qual,5) > 0)
  IF (cnvtupper( $REPORTTYPE)="SPREADSHEET")
   SELECT INTO value(var_output)
    nurse_unit = concat(patalert->qual[d.seq].nurseunit,patalert->qual[d.seq].room), pat_name =
    substring(1,40,p.name_full_formatted), acct_num = substring(1,11,ea.alias),
    attd_phy = substring(1,40,patalert->qual[d.seq].attdphy), dvt_risk = substring(1,20,patalert->
     qual[d.seq].dvtrisk), current_prophylaxis = patalert->qual[d.seq].currentprophylaxis,
    appropiate_prophylaxis = substring(1,100,check(build(alertinfo->qual[patalert->qual[d.seq].alert[
       d2.seq].alerttype].satisfiers,fillstring(100," ")))), dvt_issue = substring(1,700,check(build(
       alertinfo->qual[patalert->qual[d.seq].alert[d2.seq].alerttype].messagepart1,
       IF (trim(patalert->qual[d.seq].alert[d2.seq].alertreason,3) != "") build(":",char(32),patalert
         ->qual[d.seq].alert[d2.seq].alertreason)
       ELSE ""
       ENDIF
       ,fillstring(500," "))))
    FROM (dummyt d  WITH seq = value(size(patalert->qual,5))),
     (dummyt d2  WITH seq = 1),
     person p,
     encntr_alias ea
    PLAN (d
     WHERE maxrec(d2,size(patalert->qual[d.seq].alert,5)))
     JOIN (d2
     WHERE (patalert->qual[d.seq].alert[d2.seq].satisfied=0))
     JOIN (p
     WHERE (p.person_id=patalert->qual[d.seq].person_id))
     JOIN (ea
     WHERE (ea.encntr_id=patalert->qual[d.seq].encntr_id)
      AND ea.encntr_alias_type_cd=finnbr)
    ORDER BY nurse_unit, pat_name
    WITH nocounter, format, pcformat(value(filedelimiter1),value(filedelimiter2)),
     time = 300
   ;end select
  ELSE
   SET pagecnt = 0
   SET d0 = initializereport(0)
   SET becont = 0
   SELECT INTO "NL:"
    nurse_unit_sort = substring(1,40,patalert->qual[d1.seq].nurseunit), room = substring(1,30,
     patalert->qual[d1.seq].room), nurseunit = substring(1,30,patalert->qual[d1.seq].nurseunit),
    pat_name = substring(1,40,p.name_full_formatted), acct_num = substring(1,11,ea.alias), attd_phy
     = substring(1,40,patalert->qual[d1.seq].attdphy),
    dvt_risk = substring(1,20,patalert->qual[d1.seq].dvtrisk), current_prophylaxis2 = substring(1,40,
     IF (textlen(trim(patalert->qual[d1.seq].currentprophylaxis,3)) > 0) patalert->qual[d1.seq].
      currentprophylaxis
     ELSE "None"
     ENDIF
     ), appropiate_prophylaxis = substring(1,1200,build(char(32),alertinfo->qual[patalert->qual[d1
      .seq].alert[d2.seq].alerttype].messagepart2,char(58),char(10),alertinfo->qual[patalert->qual[d1
      .seq].alert[d2.seq].alerttype].satisfiers,
      fillstring(200," "))),
    dvt_issue = substring(1,600,build(alertinfo->qual[patalert->qual[d1.seq].alert[d2.seq].alerttype]
      .messagepart1,
      IF (trim(patalert->qual[d1.seq].alert[d2.seq].alertreason,3) != "") build(":",char(10),char(32),
        patalert->qual[d1.seq].alert[d2.seq].alertreason)
      ELSE ""
      ENDIF
      ,fillstring(500," ")))
    FROM (dummyt d1  WITH seq = size(patalert->qual,5)),
     dummyt d2,
     person p,
     encntr_alias ea
    PLAN (d1
     WHERE maxrec(d2,size(patalert->qual[d1.seq].alert,5)))
     JOIN (d2)
     JOIN (p
     WHERE (p.person_id=patalert->qual[d1.seq].person_id)
      AND (patalert->qual[d1.seq].alert[d2.seq].satisfied=0))
     JOIN (ea
     WHERE (ea.encntr_id=patalert->qual[d1.seq].encntr_id)
      AND ea.encntr_alias_type_cd=finnbr)
    ORDER BY nurse_unit_sort, room, pat_name
    HEAD REPORT
     d0 = headrpt(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      d0 = pagebreak(0)
     ENDIF
     d0 = secunit(rpt_render)
    HEAD nurse_unit_sort
     IF (pagecnt > 0)
      BREAK
     ENDIF
     pagecnt = (pagecnt+ 1)
    HEAD pat_name
     IF (((((_yoffset+ headperson(rpt_calcheight))+ headdvt(rpt_calcheight,10.5,becont)) > (10+
     headappropiate(rpt_calcheight,10.5,becont))) > 10))
      BREAK
     ENDIF
     d0 = headperson(rpt_render)
    HEAD dvt_issue
     IF ((((_yoffset+ headdvt(rpt_calcheight,10.5,becont))+ headappropiate(rpt_calcheight,10.5,becont
      )) > 10))
      BREAK, d0 = headperson(rpt_render)
     ENDIF
     d0 = headdvt(rpt_render,10.5,becont), d0 = headappropiate(rpt_render,10.5,becont)
    FOOT PAGE
     d0 = footpage(rpt_render)
    WITH nocounter
   ;end select
   SET d0 = finalizereport(value(var_output))
  ENDIF
 ENDIF
#exit_program
 IF (((size(patalert->qual,5) <= 0) OR (curqual=0)) )
  SET pagecnt = 0
  SET room = " "
  SET nurseunit = " "
  SET pat_name = " "
  SET acct_num = " "
  SET attd_phy = " "
  SET dvt_risk = " "
  SET current_prophylaxis2 = " "
  SET appropiate_prophylaxis = " "
  SET dvt_issue = " "
  SET d0 = initializereport(0)
  SET d0 = headrpt(rpt_render)
  SET d0 = footpage(rpt_render)
  SET d0 = finalizereport(value(var_output))
 ENDIF
 IF (email_ind=1)
  IF (findfile(trim(var_output))=1)
   EXECUTE bhs_ma_email_file
   CALL emailfile(var_output,var_output,trim( $EMAIL,3),"Discern Report: Dvt Risk",0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "Email sent to:", msg2 = trim( $EMAIL), y_pos = 18,
     row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))),
     msg1, row + 2, msg2
    WITH dio = 08, mine, time = 5,
     format
   ;end select
   SET stat = remove(trim(var_output))
   IF (stat=0)
    CALL echo("File could not be removed")
   ELSE
    CALL echo("File was removed")
   ENDIF
  ELSE
   CALL echo("File could not be removed. File does not exist or permission denied")
  ENDIF
 ENDIF
END GO
