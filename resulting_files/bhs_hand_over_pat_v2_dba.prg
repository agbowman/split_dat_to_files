CREATE PROGRAM bhs_hand_over_pat_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient List" = "",
  "Print Options" = 0
  WITH outdev, patlist, printoptions
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 FREE RECORD dgapl_reply
 RECORD dgapl_reply(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,dgapl_request), replace(reply,dgapl_reply)
 RECORD dgp_reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 RECORD request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i4
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
 )
 DECLARE selection = i4
 FOR (i = 1 TO size(dgapl_reply->patient_lists,5))
   IF ((dgapl_reply->patient_lists[i].patient_list_id=cnvtreal( $PATLIST)))
    SET selection = i
    SET i = (size(dgapl_reply->patient_lists,5)+ 1)
   ENDIF
 ENDFOR
 SET request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 SET stat = alterlist(request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
   SET request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_name
   SET request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i].
   parent_entity_id
 ENDFOR
 SET num_filters = size(dgapl_reply->patient_lists[selection].encntr_type_filters,5)
 SET stat = alterlist(request->encntr_type_filters,num_filters)
 FOR (i = 1 TO num_filters)
  SET request->encntr_type_filters[i].encntr_type_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_type_cd
  SET request->encntr_type_filters[i].encntr_class_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_class_cd
 ENDFOR
 SET dgp_reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE pagebreak = vc WITH noconstant(" "), public
 CALL echo(build("ListType:",listtype))
 CALL echorecord(request)
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom  WITH replace(reply,dgp_reply)
  OF "CARETEAM":
   EXECUTE bhs_dcp_get_pl_careteam2
  OF "LOCATION":
   EXECUTE dcp_get_pl_location  WITH replace(reply,dgp_reply)
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp replace(reply,dgp_reply)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(reply,dgp_reply)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(reply,dgp_reply)
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group  WITH replace(reply,dgp_reply)
  OF "SERVICE":
   EXECUTE dcp_get_pl_service  WITH replace(reply,dgp_reply)
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt  WITH replace(reply,dgp_reply)
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt  WITH replace(reply,dgp_reply)
  OF "QUERY":
   EXECUTE dcp_get_pl_query  WITH replace(reply,dgp_reply)
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule  WITH replace(reply,dgp_reply)
  ELSE
   GO TO error
 ENDCASE
 CALL echorecord(dgp_reply)
 DECLARE prsnl = vc
 DECLARE patientlist = vc
 DECLARE attending = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")),
 protect
 DECLARE code_status_cd1 = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRNOCPRBUTOKTOINTUBATE")), protect
 DECLARE code_status_cd2 = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRDNINOCPRNOINTUBATION")), protect
 DECLARE code_status_cd3 = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODECONFIRMED")), protect
 DECLARE code_status_cd4 = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODEPRESUMED")), protect
 DECLARE code_status_cd5 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd6 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd7 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDRESUSCITATION")), protect
 DECLARE code_status_cd8 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NOPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd9 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "RESUSCITATIONPERIOPERATIVE")), protect
 DECLARE discontinued_14281 = f8 WITH public, constant(uar_get_code_by("displaykey",14281,
   "DISCONTINUED")), protect
 DECLARE todoitems = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TODOITEMS")), protect
 DECLARE pendinglist = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ITEMSPENDING")), protect
 DECLARE currentchiefcomplaint = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "CURRENTCHIEFCOMPLAINT")), protect
 DECLARE pastmedicalhx = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PASTMEDICALHX")), protect
 DECLARE historyofpresentillnesstransfer = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYOFPRESENTILLNESSTRANSFER")), protect
 DECLARE contingencyplan = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CONTINGENCYPLAN")),
 protect
 DECLARE topicforfollowupi = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOPICFORFOLLOWUPI")),
 protect
 DECLARE topicforfollowupii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOPICFORFOLLOWUPII")),
 protect
 DECLARE topicforfollowupiii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOPICFORFOLLOWUPIII"
   )), protect
 DECLARE topicforfollowupiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOPICFORFOLLOWUPIV")),
 protect
 DECLARE topicforfollowupv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOPICFORFOLLOWUPV")),
 protect
 DECLARE followupdetaili = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FOLLOWUPDETAILI")),
 protect
 DECLARE followupdetailii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FOLLOWUPDETAILII")),
 protect
 DECLARE followupdetailiii = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FOLLOWUPDETAILIII")),
 protect
 DECLARE followupdetailiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FOLLOWUPDETAILIV")),
 protect
 DECLARE followupdetailv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FOLLOWUPDETAILV")),
 protect
 DECLARE abileft = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABILEFT")), protect
 DECLARE abiright = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABIRIGHT")), protect
 DECLARE abicomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ABICOMMENTS")), protect
 DECLARE ceweight = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT")), protect
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE allergyactive = f8 WITH constant(uar_get_code_by("MEANING",12025,"ACTIVE")), protect
 DECLARE rounds_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",14122,"ROUNDSNOTE"))
 DECLARE eventval = vc WITH public, noconstant(" ")
 DECLARE eventvaltitle = vc WITH public, noconstant(" ")
 DECLARE tempeventval = vc WITH public, noconstant(" ")
 DECLARE formtitle = vc WITH public, noconstant(" ")
 DECLARE age = vc WITH public, noconstant(" ")
 DECLARE weight = vc WITH public, noconstant(" ")
 FREE RECORD eventseq
 RECORD eventseq(
   1 qual[*]
     2 event_cd = f8
     2 seq = i4
 )
 FREE RECORD patientlevelinfo
 RECORD patientlevelinfo(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 age = vc
     2 weight = vc
     2 allergies[*]
       3 desc = vc
 )
 SET stat = alterlist(eventseq->qual,100)
 SET seqcnt = 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = abileft
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = abiright
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = abicomments
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = todoitems
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = contingencyplan
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = pastmedicalhx
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = historyofpresentillnesstransfer
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = currentchiefcomplaint
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = pendinglist
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = topicforfollowupi
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = topicforfollowupii
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = topicforfollowupiii
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = topicforfollowupiv
 SET seqcnt += 1
 SET eventseq->qual[seqcnt].seq = seqcnt
 SET eventseq->qual[seqcnt].event_cd = topicforfollowupv
 SET stat = alterlist(eventseq->qual,seqcnt)
 SELECT INTO "NL:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   prsnl = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT
  d.name
  FROM dcp_patient_list d
  WHERE (d.patient_list_id=request->patient_list_id)
  DETAIL
   patientlist = d.name
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
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
 DECLARE _rempending_list = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpersondetail2 = i2 WITH noconstant(0), protect
 DECLARE _remsticknotetxt = i4 WITH noconstant(1), protect
 DECLARE _bcontstickynotesec = i2 WITH noconstant(0), protect
 DECLARE _times18bu0 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
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
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (headreport(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times18bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formtitle,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpage(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpageabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.740000), private
   DECLARE __date = vc WITH noconstant(build2(format(cnvtdatetime(sysdate),"MM/DD/YY HH:MM ;;D"),char
     (0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 5.948
    SET rptsd->m_height = 0.281
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patientlist,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient List:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 4.500
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prsnl,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.427
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Requested by:",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.177)
    SET rptsd->m_width = 2.198
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.635
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room #",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.896)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN #",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.542)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patients Last Name, First Name",char(
       0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.323
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.323
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Code Status ",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.031)),(offsety+ 0.693),(offsetx+ 7.511),(
     offsety+ 0.693))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpersonid(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpersonidabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpersonidabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   DECLARE __attending_name = vc WITH noconstant(build2(ps.name_full_formatted,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.542)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.name_full_formatted,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(room,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.875)
    SET rptsd->m_width = 0.531
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ea.alias,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.510
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attending_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.302)
    SET rptsd->m_width = 2.198
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(o.ordered_as_mnemonic,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 1.542)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.375
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.802)
    SET rptsd->m_width = 0.573
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(age,char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 2.052)
    SET rptsd->m_width = 0.635
    SET rptsd->m_height = 0.208
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(weight,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (allergytitle(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergytitleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (allergytitleabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (allergy(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergyabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (allergyabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 6.750
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tempallergies,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (eventtitle(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = eventtitleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (eventtitleabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 4.365
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(eventvaltitle,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (persondetail2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = persondetail2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (persondetail2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pending_list = f8 WITH noconstant(0.0), private
   DECLARE __pending_list = vc WITH noconstant(build2(eventval,char(0))), protect
   IF (bcontinue=0)
    SET _rempending_list = 1
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
   SET rptsd->m_x = (offsetx+ 0.677)
   SET rptsd->m_width = 6.573
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempending_list = _rempending_list
   IF (_rempending_list > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempending_list,((size(
        __pending_list) - _rempending_list)+ 1),__pending_list)))
    SET drawheight_pending_list = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempending_list = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempending_list,((size(__pending_list) -
       _rempending_list)+ 1),__pending_list)))))
     SET _rempending_list += rptsd->m_drawlength
    ELSE
     SET _rempending_list = 0
    ENDIF
    SET growsum += _rempending_list
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.677)
   SET rptsd->m_width = 6.573
   SET rptsd->m_height = drawheight_pending_list
   IF (ncalc=rpt_render
    AND _holdrempending_list > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempending_list,((
       size(__pending_list) - _holdrempending_list)+ 1),__pending_list)))
   ELSE
    SET _rempending_list = _holdrempending_list
   ENDIF
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
 SUBROUTINE (stickynotesec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = stickynotesecabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (stickynotesecabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sticknotetxt = f8 WITH noconstant(0.0), private
   DECLARE __sticknotetxt = vc WITH noconstant(build2(stickynotevalue,char(0))), protect
   IF (bcontinue=0)
    SET _remsticknotetxt = 1
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
    SET rptsd->m_y = (offsety+ 0.177)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsticknotetxt = _remsticknotetxt
   IF (_remsticknotetxt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsticknotetxt,((size(
        __sticknotetxt) - _remsticknotetxt)+ 1),__sticknotetxt)))
    SET drawheight_sticknotetxt = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsticknotetxt = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsticknotetxt,((size(__sticknotetxt) -
       _remsticknotetxt)+ 1),__sticknotetxt)))))
     SET _remsticknotetxt += rptsd->m_drawlength
    ELSE
     SET _remsticknotetxt = 0
    ENDIF
    SET growsum += _remsticknotetxt
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.177)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = drawheight_sticknotetxt
   IF (ncalc=rpt_render
    AND _holdremsticknotetxt > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsticknotetxt,((
       size(__sticknotetxt) - _holdremsticknotetxt)+ 1),__sticknotetxt)))
   ELSE
    SET _remsticknotetxt = _holdremsticknotetxt
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.052)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.260
   SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sticky Notes:",char(0)))
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
 SUBROUTINE (pagebreaksec(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pagebreaksecabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pagebreaksecabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pagebreak,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_HAND_OVER_PAT_V2"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.20
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
   SET rptfont->m_pointsize = 18
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times18bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET becont = 0
 SET reinti = 0
 SET reinti1 = 0
 SET pos = 0
 SET num = 0
 SET eventvalcnt = 0
 SET blob_size = 0
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed_trimmed = fillstring(64000," ")
 SET blob_uncompressed = fillstring(64000," ")
 SET blob_rtf = fillstring(64000," ")
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed_trimmed = fillstring(64000," ")
 SET blob_return_len = 0
 SET blob_return_len2 = 0
 SET topiccnt = 0
 SET stat = alterlist(patientlevelinfo->qual,size(dgp_reply->patients,5))
 FOR (d = 1 TO size(dgp_reply->patients,5))
   SET patientlevelinfo->qual[d].person_id = dgp_reply->patients[d].person_id
 ENDFOR
 SELECT INTO "NL:"
  FROM clinical_event ce,
   (dummyt d  WITH seq = value(size(dgp_reply->patients,5)))
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=patientlevelinfo->qual[d.seq].person_id)
    AND ce.event_cd=ceweight
    AND ((ce.result_status_cd+ 0) IN (altered, modified, auth)))
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   patientlevelinfo->qual[d.seq].weight = trim(build(format(cnvtreal(ce.event_tag),"###.##")," kg")),
   CALL echo(patientlevelinfo->qual[d.seq].weight)
  WITH nocounter
 ;end select
 CALL echo(build(abileft,"!",abiright,"!",abicomments))
 CALL echo("Loading allergies")
 SELECT INTO "NL:"
  FROM allergy a,
   nomenclature n,
   (dummyt d  WITH seq = value(size(patientlevelinfo->qual,5)))
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=patientlevelinfo->qual[d.seq].person_id)
    AND a.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN a.beg_effective_dt_tm AND a.end_effective_dt_tm
    AND a.reaction_status_cd=allergyactive)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY a.person_id, a.allergy_id
  HEAD a.person_id
   allergycnt = 0
  HEAD a.allergy_id
   allergycnt += 1, stat = alterlist(patientlevelinfo->qual[d.seq].allergies,allergycnt),
   patientlevelinfo->qual[d.seq].allergies[allergycnt].desc = n.source_string
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.person_id, p.name_full_formatted, room = build(uar_get_code_display(e.loc_room_cd),"-",
   uar_get_code_display(e.loc_bed_cd)),
  ea.alias, ep.prsnl_person_id, ps.name_full_formatted,
  o.ordered_as_mnemonic, ce1.result_val, eventsequence = eventseq->qual[devent.seq].seq
  FROM encounter e,
   person p,
   clinical_event ce1,
   clinical_event ce2,
   (dummyt d  WITH seq = value(size(dgp_reply->patients,5))),
   encntr_alias ea,
   encntr_prsnl_reltn ep,
   prsnl ps,
   (dummyt devent  WITH seq = value(size(eventseq->qual,5))),
   dummyt d1,
   dummyt d2,
   orders o,
   ce_blob cb
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=dgp_reply->patients[d.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1079
    AND ea.active_ind=1)
   JOIN (ep
   WHERE e.encntr_id=ep.encntr_id
    AND ep.encntr_prsnl_r_cd=attending
    AND ep.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ep.beg_effective_dt_tm AND ep.end_effective_dt_tm)
   JOIN (ps
   WHERE ep.prsnl_person_id=ps.person_id
    AND ps.active_ind=1)
   JOIN (o
   WHERE ((o.person_id=e.person_id
    AND o.encntr_id=e.encntr_id
    AND o.dept_status_cd != discontinued_14281
    AND o.catalog_cd IN (code_status_cd1, code_status_cd2, code_status_cd3, code_status_cd4,
   code_status_cd5,
   code_status_cd6, code_status_cd7, code_status_cd8, code_status_cd9)) OR (o.order_id=0.0
    AND  NOT (e.encntr_id IN (
   (SELECT
    o1.encntr_id
    FROM orders o1
    WHERE o1.person_id=e.person_id
     AND o1.encntr_id=e.encntr_id
     AND o1.dept_status_cd != discontinued_14281
     AND o1.catalog_cd IN (code_status_cd1, code_status_cd2, code_status_cd3, code_status_cd4,
    code_status_cd5,
    code_status_cd6, code_status_cd7, code_status_cd8, code_status_cd9)))))) )
   JOIN (devent)
   JOIN (d1)
   JOIN (ce1
   WHERE ce1.encntr_id=e.encntr_id
    AND ((( $PRINTOPTIONS=1)
    AND ce1.event_cd IN (pendinglist, todoitems)) OR (( $PRINTOPTIONS=2)
    AND ce1.event_cd IN (abileft, abiright, abicomments, pendinglist, todoitems,
   currentchiefcomplaint, pastmedicalhx, historyofpresentillnesstransfer, contingencyplan,
   topicforfollowupi,
   topicforfollowupii, topicforfollowupiii, topicforfollowupiv, topicforfollowupv)))
    AND (ce1.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate)))
    AND (ce1.updt_dt_tm>= Outerjoin(datetimeadd(cnvtdatetime(sysdate),- (2))))
    AND (eventseq->qual[devent.seq].event_cd=ce1.event_cd)
    AND ((ce1.result_status_cd+ 0) IN (altered, modified, auth)))
   JOIN (cb
   WHERE (cb.event_id= Outerjoin(ce1.event_id)) )
   JOIN (d2)
   JOIN (ce2
   WHERE ce2.encntr_id=e.encntr_id
    AND ((ce2.result_status_cd+ 0) IN (altered, modified, auth))
    AND ((ce1.event_cd=topicforfollowupi
    AND ce2.event_cd=followupdetaili) OR (((ce1.event_cd=topicforfollowupii
    AND ce2.event_cd=followupdetailii) OR (((ce1.event_cd=topicforfollowupiii
    AND ce2.event_cd=followupdetailiii) OR (((ce1.event_cd=topicforfollowupiv
    AND ce2.event_cd=followupdetailiv) OR (ce1.event_cd=topicforfollowupv
    AND ce2.event_cd=followupdetailv)) )) )) )) )
  ORDER BY room, p.person_id, eventsequence,
   ce1.event_cd, ce1.updt_dt_tm DESC
  HEAD REPORT
   topiccnt = 0,
   MACRO (seteventtitletxt)
    eventvaltitle =
    IF (ce1.event_cd=pendinglist) "Items Pending:"
    ELSEIF (ce1.event_cd=todoitems) "To Do Items:"
    ELSEIF (ce1.event_cd=currentchiefcomplaint) "Chief Complaint:"
    ELSEIF (ce1.event_cd=pastmedicalhx) "Past Medical Hx:"
    ELSEIF (ce1.event_cd=historyofpresentillnesstransfer) "hx of Present Illness:"
    ELSEIF (ce1.event_cd=contingencyplan) "Contingency Plan:"
    ELSEIF (ce1.event_cd IN (topicforfollowupi, topicforfollowupii, topicforfollowupiii,
    topicforfollowupiv, topicforfollowupv)
     AND topiccnt < 1) "Topics & Info:"
    ELSEIF (ce1.event_cd=abileft) "ABILeft:"
    ELSEIF (ce1.event_cd=abiright) "ABIRight:"
    ELSEIF (ce1.event_cd=abicomments) "ABIComments:"
    ELSE ""
    ENDIF
   ENDMACRO
   IF (( $PRINTOPTIONS=1))
    formtitle = "Transfer/HandOver Report"
   ELSE
    formtitle = "Transfer/HandOver Report W/ Detail"
   ENDIF
   d0 = headreport(rpt_render)
  HEAD PAGE
   IF (curpage > 1)
    d0 = pagebreak(0)
   ENDIF
   d0 = headpage(rpt_render)
  HEAD room
   temproom = "place holder for sort"
  HEAD p.person_id
   IF (((_yoffset+ headpersonid(rpt_calcheight)) > 10.5))
    BREAK
   ENDIF
   weight = patientlevelinfo->qual[d.seq].weight, age = cnvtage(cnvtdatetime(p.birth_dt_tm)), d0 =
   headpersonid(rpt_render),
   f1 = p.name_full_formatted, f2 = room, f6 = ea.alias,
   f7 = ps.name_full_formatted, f4 = o.ordered_as_mnemonic, reinit = 0,
   topiccnt = 0
   IF (size(patientlevelinfo->qual[d.seq].allergies,5) > 0)
    d0 = allergytitle(rpt_render)
    FOR (x = 1 TO size(patientlevelinfo->qual[d.seq].allergies,5))
     tempallergies = trim(patientlevelinfo->qual[d.seq].allergies[x].desc),d0 = allergy(rpt_render)
    ENDFOR
   ENDIF
  HEAD ce1.event_cd
   IF (textlen(ce1.result_val) > 0)
    eventvalcnt += 1
    IF (ce1.event_cd=historyofpresentillnesstransfer)
     blob_size = cnvtint(cb.blob_length), blob_out_detail = fillstring(64000," "),
     blob_compressed_trimmed = fillstring(64000," "),
     blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
     fillstring(64000," "),
     blob_compressed_trimmed = cb.blob_contents, blob_return_len = 0, blob_return_len2 = 0,
     CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
     size(blob_uncompressed),blob_return_len),
     CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
     eventval = trim(blob_rtf,3)
    ELSE
     eventval = ce1.result_val
    ENDIF
    IF (textlen(ce2.result_val) > 0)
     tempeventval = trim(ce2.result_val,3), tempeventval = replace(trim(tempeventval,3),char(13),
      " , "), tempeventval = replace(trim(tempeventval),char(10),""),
     tempeventval = build2(" - ",tempeventval), eventval = build2(eventval,tempeventval)
    ENDIF
    IF (((_yoffset+ persondetail2(rpt_calcheight,8.5,becont)) > 10))
     reinit = 1, topiccnt = 0, BREAK,
     d0 = headpersonid(rpt_render)
    ENDIF
    seteventtitletxt, d0 = eventtitle(rpt_render), d0 = persondetail2(rpt_render,8.5,becont)
    IF (becont=1)
     reinit = 1, BREAK, topiccnt = 0,
     seteventtitletxt, d0 = eventtitle(rpt_render), d0 = persondetail2(rpt_render,8.5,becont)
    ELSE
     reinit = 0
    ENDIF
    IF (ce1.event_cd IN (topicforfollowupi, topicforfollowupii, topicforfollowupiii,
    topicforfollowupiv, topicforfollowupv))
     topiccnt += 1
    ENDIF
   ENDIF
  FOOT PAGE
   IF (reinit=1)
    reinit = 0, pagebreak = "Countinued to next page", d0 = pagebreaksec(rpt_render)
   ENDIF
  WITH nocounter, format, separator = " ",
   outerjoin = d1, outerjoin = d2, memsort,
   nullreport
 ;end select
 SET d0 = finalizereport( $OUTDEV)
END GO
