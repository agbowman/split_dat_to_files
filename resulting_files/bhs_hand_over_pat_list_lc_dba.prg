CREATE PROGRAM bhs_hand_over_pat_list_lc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient List" = "",
  "Print Options" = 0
  WITH outdev, patlist, printoptions
 FREE RECORD output
 RECORD output(
   1 name = vc
   1 room = vc
 )
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
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE pagebreak = vc WITH noconstant(" "), public
 CALL echo(build("ListType:",listtype))
 CALL echorecord(request)
 CALL echo("")
 CALL echo("")
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
 DECLARE todoitems = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TODOITEMS")), protect
 DECLARE pendinglist = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ITEMSPENDING")), protect
 DECLARE attending = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")),
 protect
 DECLARE code_status_cd1 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NORESUSCITATION")), protect
 DECLARE code_status_cd2 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd3 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "FULLRESUSCITATION")), protect
 DECLARE code_status_cd4 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd5 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "LIMITEDRESUSCITATION")), protect
 DECLARE code_status_cd6 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "NOPERIOPERATIVERESUSCITATION")), protect
 DECLARE code_status_cd7 = f8 WITH public, constant(uar_get_code_by("displaykey",200,
   "RESUSCITATIONPERIOPERATIVE")), protect
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
 DECLARE _createfonts(dummy) = null WITH public
 DECLARE _createpens(dummy) = null WITH public
 DECLARE pagebreak(dummy) = null WITH public
 DECLARE finalizereport(ssendreport=vc) = null WITH public
 DECLARE headreport(ncalc=i2) = f8 WITH public
 DECLARE headreportabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE headpage(ncalc=i2) = f8 WITH public
 DECLARE headpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE headpersonid(ncalc=i2) = f8 WITH public
 DECLARE headpersonidabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE persondetail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
 DECLARE persondetailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 public
 DECLARE persondetail2(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH public
 DECLARE persondetail2abs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 public
 DECLARE persondetail12(ncalc=i2) = f8 WITH public
 DECLARE persondetail12abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH public
 DECLARE initializereport(dummy) = null WITH public
 DECLARE _hreport = i4 WITH noconstant(0), public
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontpersondetail = i2 WITH noconstant(0), protect
 DECLARE _remtodoitem = i2 WITH noconstant(1), protect
 DECLARE _bcontpersondetail2 = i2 WITH noconstant(0), protect
 DECLARE _rempending_list = i2 WITH noconstant(1), protect
 DECLARE _times18bu0 = i4 WITH noconstant(0), public
 DECLARE _times140 = i4 WITH noconstant(0), public
 DECLARE _times10b0 = i4 WITH noconstant(0), public
 DECLARE _times100 = i4 WITH noconstant(0), public
 DECLARE _times14b0 = i4 WITH noconstant(0), public
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), public
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
 SUBROUTINE headreport(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
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
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times18bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Transfer / HandOver Report",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.820000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 5.938
    SET rptsd->m_height = 0.271
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
    SET rptsd->m_width = 1.417
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Requested by:",char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.188)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_times140)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(format(cnvtdatetime(curdate,curtime2),
       "MM/DD/YY HH:MM ;;D"),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.635
    SET rptsd->m_height = 0.281
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Room #",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN #",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 2.375
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patients Last Name, First Name",char(
       0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.323
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Code Status ",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpersonid(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpersonidabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpersonidabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 2.490
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p.name_full_formatted,char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(room,char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.875)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ea.alias,char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 1.510
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ps.name_full_formatted,char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(o.ordered_as_mnemonic,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE persondetail(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = persondetailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE persondetailabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _remtodoitem = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtodoitem = _remtodoitem
   IF (_remtodoitem > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtodoitem,((size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
        ENDIF
        ) - _remtodoitem)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
       ENDIF
       )))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtodoitem = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtodoitem,((size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
        ENDIF
        ) - _remtodoitem)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
       ENDIF
       )))))
     SET _remtodoitem = (_remtodoitem+ rptsd->m_drawlength)
    ELSE
     SET _remtodoitem = 0
    ENDIF
    SET growsum = (growsum+ _remtodoitem)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdremtodoitem > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtodoitem,((size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
        ENDIF
        ) - _holdremtodoitem)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2("To Do:",char(13),ce.result_val)
       ENDIF
       )))
   ELSE
    SET _remtodoitem = _holdremtodoitem
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE persondetail2(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = persondetail2abs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE persondetail2abs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   IF (bcontinue=0)
    SET _rempending_list = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 6.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempending_list = _rempending_list
   IF (_rempending_list > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempending_list,((size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
          .result_val)
        ENDIF
        ) - _rempending_list)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
         .result_val)
       ENDIF
       )))
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempending_list = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempending_list,((size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
          .result_val)
        ENDIF
        ) - _rempending_list)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
         .result_val)
       ENDIF
       )))))
     SET _rempending_list = (_rempending_list+ rptsd->m_drawlength)
    ELSE
     SET _rempending_list = 0
    ENDIF
    SET growsum = (growsum+ _rempending_list)
   ENDIF
   SET rptsd->m_flags = 4
   IF (ncalc=rpt_render
    AND _holdrempending_list > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempending_list,((
       size(
        IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
          .result_val)
        ENDIF
        ) - _holdrempending_list)+ 1),
       IF (textlen(trim(ce.result_val,3)) > 0) build2(char(13),"Pending List:",char(13),ce1
         .result_val)
       ENDIF
       )))
   ELSE
    SET _rempending_list = _holdrempending_list
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE persondetail12(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = persondetail12abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE persondetail12abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 1.448
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pagebreak,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "bhs_hand_over_pat_list_lc"
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
   CALL _createfonts(0)
   CALL _createpens(0)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
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
 SET becont1 = 0
 SET reinti1 = 0
 SELECT INTO "NL:"
  p.person_id, ce.event_cd, p.name_full_formatted,
  room = uar_get_code_display(e.loc_room_cd), ce.result_val, ea.alias,
  ep.prsnl_person_id, ps.name_full_formatted, o.ordered_as_mnemonic,
  ce1.result_val
  FROM encounter e,
   person p,
   clinical_event ce,
   clinical_event ce1,
   (dummyt d  WITH seq = value(size(dgp_reply->patients,5))),
   encntr_alias ea,
   encntr_prsnl_reltn ep,
   prsnl ps,
   dummyt d1,
   orders o
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
    AND cnvtdatetime(curdate,curtime3) BETWEEN ep.beg_effective_dt_tm AND ep.end_effective_dt_tm)
   JOIN (ps
   WHERE ep.prsnl_person_id=ps.person_id
    AND ps.active_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=outerjoin(e.encntr_id)
    AND ce.event_cd=outerjoin(todoitems)
    AND ce.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ce.updt_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (2))))
   JOIN (ce1
   WHERE ce1.encntr_id=outerjoin(e.encntr_id)
    AND ce1.event_cd=outerjoin(pendinglist)
    AND ce1.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ce1.updt_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (2))))
   JOIN (d1)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd IN (code_status_cd1, code_status_cd2, code_status_cd3, code_status_cd4,
   code_status_cd5,
   code_status_cd6, code_status_cd7))
  ORDER BY p.person_id, ce.updt_dt_tm DESC, ce1.updt_dt_tm DESC
  HEAD REPORT
   d0 = headreport(rpt_render)
  HEAD PAGE
   IF (curpage > 1)
    d0 = pagebreak(0)
   ENDIF
   d0 = headpage(rpt_render)
  HEAD p.person_id
   IF (((_yoffset+ headpersonid(rpt_calcheight)) > 10.5))
    BREAK
   ENDIF
   d0 = headpersonid(rpt_render), f1 = p.name_full_formatted, f2 = room,
   f6 = ea.alias, f7 = ps.name_full_formatted, f4 = o.ordered_as_mnemonic
  HEAD ce.event_cd
   f3 = ce.result_val
   IF (((_yoffset+ persondetail(rpt_calcheight,8.5,becont)) > 10.5))
    BREAK, d0 = headpersonid(rpt_render)
   ENDIF
   d0 = persondetail(rpt_render,8.5,becont)
   IF (becont=1)
    reinit = 1, BREAK, d0 = persondetail(rpt_render,8.5,becont)
   ELSE
    reinit = 1
   ENDIF
  HEAD ce1.event_cd
   f8 = ce1.result_val
   IF (((_yoffset+ persondetail2(rpt_calcheight,8.5,becont)) > 10.5))
    BREAK, d0 = headpersonid(rpt_render)
   ENDIF
   d0 = persondetail2(rpt_render,8.5,becont)
   IF (becont1=1)
    reinit1 = 1, BREAK, d0 = persondetail2(rpt_render,8.5,becont)
   ELSE
    reinit1 = 1
   ENDIF
  FOOT PAGE
   IF (((reinit=1) OR (reinit1=1)) )
    pagebreak = "End Of Page", d0 = persondetail12(rpt_render)
   ENDIF
  WITH nocounter, format, separator = " ",
   outerjoin = d1
 ;end select
 SET d0 = finalizereport( $OUTDEV)
END GO
