CREATE PROGRAM bhs_rad_critique_v3:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "",
  "Final Exam Begin Date" = "CURDATE",
  "Final exam End Date" = "CURDATE",
  "Modality" = 0,
  "Technologist" = 0
  WITH outdev, facility, fromdate,
  todate, modality, technologist
 FREE RECORD rec_str
 RECORD rec_str(
   1 techs[*]
     2 s_tech = vc
     2 f_tot_critiques = i4
     2 f_tot_proced_cnt = i4
     2 f_tech_id = f8
     2 orders[*]
       3 s_accession = vc
       3 s_procedure_name = vc
       3 s_order_date = vc
       3 s_critique_date = vc
       3 s_critique_comments = vc
       3 s_critique_author = vc
       3 s_critique_read = vc
       3 critiques[*]
         4 s_critique_desc = vc
 ) WITH protect
 DECLARE modality_cat_cd = f8
 DECLARE modality_cat_descrip = vc WITH noconstant(" ")
 DECLARE technologist_id = f8
 DECLARE user_name = vc WITH noconstant(" ")
 DECLARE facility_name = vc WITH noconstant(" ")
 DECLARE facility_cd = f8
 DECLARE strdate = vc WITH noconstant(" ")
 DECLARE enddate = vc WITH noconstant(" ")
 DECLARE strdatedisplay = vc WITH noconstant(" ")
 DECLARE enddatedisplay = vc WITH noconstant(" ")
 DECLARE becont = i4
 DECLARE critiques = vc WITH noconstant(" ")
 DECLARE tech_name = vc WITH noconstant(" ")
 DECLARE tech_id = vc WITH noconstant(" ")
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14202,"FINAL"))
 DECLARE mf_verify_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",21,"VERIFY"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 IF (reflect( $MODALITY)="F8")
  SELECT
   cv.display
   FROM code_value cv
   WHERE (cv.code_value= $MODALITY)
   DETAIL
    modality_cat_cd =  $MODALITY, modality_cat_descrip = cv.display
   WITH nocounter
  ;end select
 ELSE
  SET modality_cat_cd = 0
  SET modality_cat_descrip = "All Modalities"
 ENDIF
 IF (reflect( $TECHNOLOGIST)="F8")
  SET technologist_id =  $TECHNOLOGIST
 ELSE
  SET technologist_id = 0
 ENDIF
 IF (validate(request->batch_selection))
  SET tmp = findstring(":", $3,1,0)
  SET daystr = substring(1,(tmp - 1), $3)
  SET timestr = cnvtint(substring((tmp+ 1),4, $3))
  SET strdate = format(cnvtdatetime((curdate+ cnvtint(daystr)),timestr),";;Q")
  SET strdatedisplay = format(cnvtdatetime(strdate),"mm/dd/yyyy;;d")
  SET tmp = findstring(":", $4,1,0)
  SET daystr = substring(1,(tmp - 1), $4)
  SET timestr = cnvtint(substring((tmp+ 1),4, $4))
  SET enddate = format(cnvtdatetime((curdate+ cnvtint(daystr)),timestr),";;Q")
  SET enddatedisplay = format(cnvtdatetime(enddate),"mm/dd/yyyy;;d")
 ELSE
  SET strdate = format(cnvtdatetime(cnvtdate2( $3,"DD-MMM-YYYY"),0000),";;Q")
  SET enddate = format(cnvtdatetime(cnvtdate2( $4,"DD-MMM-YYYY"),2359),";;Q")
  SET strdatedisplay = format(cnvtdatetime(cnvtdate2( $3,"DD-MMM-YYYY"),0000),"mm/dd/yyyy;;d")
  SET enddatedisplay = format(cnvtdatetime(cnvtdate2( $4,"DD-MMM-YYYY"),0000),"mm/dd/yyyy;;d")
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  HEAD REPORT
   user_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=220
   AND cnvtupper(c.cdf_meaning)="FACILITY"
   AND c.display_key=trim( $2)
   AND c.active_ind=1
   AND c.description != "BMC"
  DETAIL
   facility_cd = c.code_value, facility_name = trim( $2)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM exam_critique_info ec,
   ce_event_prsnl cep,
   clinical_event ce,
   critique_prsnl cp,
   critique_code_assignments cca,
   order_radiology ord,
   orders o,
   order_catalog oc,
   encounter e,
   prsnl pr,
   prsnl pr1,
   prsnl pr2
  PLAN (pr)
   JOIN (cep
   WHERE cep.action_prsnl_id=pr.person_id
    AND cep.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND cep.action_dt_tm BETWEEN cnvtdatetime(strdate) AND cnvtdatetime(enddate)
    AND ((cep.action_type_cd+ 0)=mf_verify_cd)
    AND ((cep.action_status_cd+ 0)=mf_completed_cd))
   JOIN (ce
   WHERE cep.event_id=ce.event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1)
   JOIN (ord
   WHERE ce.order_id=ord.order_id
    AND ((ord.report_status_cd+ 0)=mf_final_cd))
   JOIN (o
   WHERE o.order_id=ord.order_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND ((modality_cat_cd=0
    AND oc.activity_subtype_cd > 0) OR (modality_cat_cd > 0
    AND oc.activity_subtype_cd=modality_cat_cd)) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((e.loc_facility_cd+ 0)=cnvtreal(facility_cd)))
   JOIN (ec
   WHERE ord.order_id=ec.order_id)
   JOIN (cp
   WHERE ec.critique_info_id=cp.critique_info_id)
   JOIN (pr1
   WHERE ec.created_by_id=pr1.person_id)
   JOIN (pr2
   WHERE cp.critiqued_id=pr2.person_id
    AND ((technologist_id=0
    AND pr2.person_id > 0) OR (technologist_id > 0
    AND pr2.person_id=technologist_id)) )
   JOIN (cca
   WHERE cp.critique_prsnl_id=cca.critique_prsnl_id)
  ORDER BY pr2.name_full_formatted, ord.accession, o.orig_order_dt_tm,
   ec.created_dt_tm
  HEAD REPORT
   tcnt = 0
  HEAD pr2.name_full_formatted
   tcnt = (tcnt+ 1)
   IF (tcnt > size(rec_str->techs,5))
    stat = alterlist(rec_str->techs,(tcnt+ 10))
   ENDIF
   rec_str->techs[tcnt].s_tech = substring(1,40,pr2.name_full_formatted), rec_str->techs[tcnt].
   f_tech_id = pr2.person_id, ocnt = 0
  HEAD ord.accession
   ocnt = (ocnt+ 1)
   IF (ocnt > size(rec_str->techs[tcnt].orders,5))
    stat = alterlist(rec_str->techs[tcnt].orders,(ocnt+ 10))
   ENDIF
   rec_str->techs[tcnt].orders[ocnt].s_accession = substring(6,13,ord.accession), rec_str->techs[tcnt
   ].orders[ocnt].s_procedure_name = substring(1,40,o.order_mnemonic), rec_str->techs[tcnt].orders[
   ocnt].s_order_date = format(o.orig_order_dt_tm,"mm/dd/yyyy;;d"),
   rec_str->techs[tcnt].orders[ocnt].s_critique_date = format(ec.created_dt_tm,"mm/dd/yyyy;;d"),
   rec_str->techs[tcnt].orders[ocnt].s_critique_comments = cp.comments, rec_str->techs[tcnt].orders[
   ocnt].s_critique_author = substring(1,40,pr1.name_full_formatted)
   IF (cp.read_ind=0)
    rec_str->techs[tcnt].orders[ocnt].s_critique_read = "N"
   ELSE
    rec_str->techs[tcnt].orders[ocnt].s_critique_read = "Y"
   ENDIF
   ccnt = 0
  HEAD cca.critique_type_cd
   ccnt = (ccnt+ 1)
   IF (ccnt > size(rec_str->techs[tcnt].orders[ocnt].critiques,5))
    stat = alterlist(rec_str->techs[tcnt].orders[ocnt].critiques,(ccnt+ 10))
   ENDIF
   rec_str->techs[tcnt].orders[ocnt].critiques[ccnt].s_critique_desc = uar_get_code_display(cca
    .critique_type_cd)
  FOOT  cca.critique_type_cd
   stat = alterlist(rec_str->techs[tcnt].orders[ocnt].critiques,ccnt)
  FOOT  ord.accession
   stat = alterlist(rec_str->techs[tcnt].orders,ocnt)
  FOOT REPORT
   stat = alterlist(rec_str->techs,tcnt)
  WITH nocounter
 ;end select
 CALL echorecord(rec_str)
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_report_header(ncalc=i2) = f8 WITH protect
 DECLARE sec_report_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE txt_col_headers(ncalc=i2) = f8 WITH protect
 DECLARE txt_col_headersabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE detailsection2(ncalc=i2) = f8 WITH protect
 DECLARE detailsection2abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_page_foot(ncalc=i2) = f8 WITH protect
 DECLARE sec_page_footabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _remf_technologist = i4 WITH noconstant(1), protect
 DECLARE _remf_critiques = i4 WITH noconstant(1), protect
 DECLARE _remf_accession = i4 WITH noconstant(1), protect
 DECLARE _remf_procedure = i4 WITH noconstant(1), protect
 DECLARE _remf_orderdate = i4 WITH noconstant(1), protect
 DECLARE _remf_critiquedate = i4 WITH noconstant(1), protect
 DECLARE _remf_critiquecomments = i4 WITH noconstant(1), protect
 DECLARE _remf_critiqueauthor = i4 WITH noconstant(1), protect
 DECLARE _remf_readind = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times8bu0 = i4 WITH noconstant(0), protect
 DECLARE _pen100s0c16777215 = i4 WITH noconstant(0), protect
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
 SUBROUTINE sec_report_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_report_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_report_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __txt_report_header = vc WITH noconstant(build2(concat(facility_name,
      " Procedure Critique Report for Exams Completed ",strdatedisplay," - ",enddatedisplay,
      char(10),modality_cat_descrip),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 10.375
    SET rptsd->m_height = 0.573
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_report_header)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE txt_col_headers(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = txt_col_headersabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE txt_col_headersabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times8bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Technologist",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Accession",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.875)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.604
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Date",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Critique Description",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Critique Comments",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.500)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Critique Author",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 10.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Read ?",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.969)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Critique Date",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_f_technologist = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_critiques = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_accession = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_procedure = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_orderdate = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_critiquedate = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_critiquecomments = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_critiqueauthor = f8 WITH noconstant(0.0), private
   DECLARE drawheight_f_readind = f8 WITH noconstant(0.0), private
   DECLARE __f_technologist = vc WITH noconstant(build2(tech_name,char(0))), protect
   DECLARE __f_critiques = vc WITH noconstant(build2(critiques,char(0))), protect
   DECLARE __f_accession = vc WITH noconstant(build2(rec_str->techs[x].orders[y].s_accession,char(0))
    ), protect
   DECLARE __f_procedure = vc WITH noconstant(build2(rec_str->techs[x].orders[y].s_procedure_name,
     char(0))), protect
   DECLARE __f_orderdate = vc WITH noconstant(build2(rec_str->techs[x].orders[y].s_order_date,char(0)
     )), protect
   DECLARE __f_critiquedate = vc WITH noconstant(build2(rec_str->techs[x].orders[y].s_critique_date,
     char(0))), protect
   DECLARE __f_critiquecomments = vc WITH noconstant(build2(rec_str->techs[x].orders[y].
     s_critique_comments,char(0))), protect
   DECLARE __f_critiqueauthor = vc WITH noconstant(build2(rec_str->techs[x].orders[y].
     s_critique_author,char(0))), protect
   DECLARE __f_readind = vc WITH noconstant(build2(rec_str->techs[x].orders[y].s_critique_read,char(0
      ))), protect
   IF (bcontinue=0)
    SET _remf_technologist = 1
    SET _remf_critiques = 1
    SET _remf_accession = 1
    SET _remf_procedure = 1
    SET _remf_orderdate = 1
    SET _remf_critiquedate = 1
    SET _remf_critiquecomments = 1
    SET _remf_critiqueauthor = 1
    SET _remf_readind = 1
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
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremf_technologist = _remf_technologist
   IF (_remf_technologist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_technologist,((size(
        __f_technologist) - _remf_technologist)+ 1),__f_technologist)))
    SET drawheight_f_technologist = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_technologist = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_technologist,((size(__f_technologist
        ) - _remf_technologist)+ 1),__f_technologist)))))
     SET _remf_technologist = (_remf_technologist+ rptsd->m_drawlength)
    ELSE
     SET _remf_technologist = 0
    ENDIF
    SET growsum = (growsum+ _remf_technologist)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_critiques = _remf_critiques
   IF (_remf_critiques > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_critiques,((size(
        __f_critiques) - _remf_critiques)+ 1),__f_critiques)))
    SET drawheight_f_critiques = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_critiques = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_critiques,((size(__f_critiques) -
       _remf_critiques)+ 1),__f_critiques)))))
     SET _remf_critiques = (_remf_critiques+ rptsd->m_drawlength)
    ELSE
     SET _remf_critiques = 0
    ENDIF
    SET growsum = (growsum+ _remf_critiques)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_accession = _remf_accession
   IF (_remf_accession > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_accession,((size(
        __f_accession) - _remf_accession)+ 1),__f_accession)))
    SET drawheight_f_accession = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_accession = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_accession,((size(__f_accession) -
       _remf_accession)+ 1),__f_accession)))))
     SET _remf_accession = (_remf_accession+ rptsd->m_drawlength)
    ELSE
     SET _remf_accession = 0
    ENDIF
    SET growsum = (growsum+ _remf_accession)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_procedure = _remf_procedure
   IF (_remf_procedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_procedure,((size(
        __f_procedure) - _remf_procedure)+ 1),__f_procedure)))
    SET drawheight_f_procedure = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_procedure = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_procedure,((size(__f_procedure) -
       _remf_procedure)+ 1),__f_procedure)))))
     SET _remf_procedure = (_remf_procedure+ rptsd->m_drawlength)
    ELSE
     SET _remf_procedure = 0
    ENDIF
    SET growsum = (growsum+ _remf_procedure)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_orderdate = _remf_orderdate
   IF (_remf_orderdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_orderdate,((size(
        __f_orderdate) - _remf_orderdate)+ 1),__f_orderdate)))
    SET drawheight_f_orderdate = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_orderdate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_orderdate,((size(__f_orderdate) -
       _remf_orderdate)+ 1),__f_orderdate)))))
     SET _remf_orderdate = (_remf_orderdate+ rptsd->m_drawlength)
    ELSE
     SET _remf_orderdate = 0
    ENDIF
    SET growsum = (growsum+ _remf_orderdate)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_critiquedate = _remf_critiquedate
   IF (_remf_critiquedate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_critiquedate,((size(
        __f_critiquedate) - _remf_critiquedate)+ 1),__f_critiquedate)))
    SET drawheight_f_critiquedate = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_critiquedate = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_critiquedate,((size(__f_critiquedate
        ) - _remf_critiquedate)+ 1),__f_critiquedate)))))
     SET _remf_critiquedate = (_remf_critiquedate+ rptsd->m_drawlength)
    ELSE
     SET _remf_critiquedate = 0
    ENDIF
    SET growsum = (growsum+ _remf_critiquedate)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_critiquecomments = _remf_critiquecomments
   IF (_remf_critiquecomments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_critiquecomments,((
       size(__f_critiquecomments) - _remf_critiquecomments)+ 1),__f_critiquecomments)))
    SET drawheight_f_critiquecomments = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_critiquecomments = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_critiquecomments,((size(
        __f_critiquecomments) - _remf_critiquecomments)+ 1),__f_critiquecomments)))))
     SET _remf_critiquecomments = (_remf_critiquecomments+ rptsd->m_drawlength)
    ELSE
     SET _remf_critiquecomments = 0
    ENDIF
    SET growsum = (growsum+ _remf_critiquecomments)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_critiqueauthor = _remf_critiqueauthor
   IF (_remf_critiqueauthor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_critiqueauthor,((
       size(__f_critiqueauthor) - _remf_critiqueauthor)+ 1),__f_critiqueauthor)))
    SET drawheight_f_critiqueauthor = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_critiqueauthor = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_critiqueauthor,((size(
        __f_critiqueauthor) - _remf_critiqueauthor)+ 1),__f_critiqueauthor)))))
     SET _remf_critiqueauthor = (_remf_critiqueauthor+ rptsd->m_drawlength)
    ELSE
     SET _remf_critiqueauthor = 0
    ENDIF
    SET growsum = (growsum+ _remf_critiqueauthor)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 10.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremf_readind = _remf_readind
   IF (_remf_readind > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remf_readind,((size(
        __f_readind) - _remf_readind)+ 1),__f_readind)))
    SET drawheight_f_readind = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remf_readind = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remf_readind,((size(__f_readind) -
       _remf_readind)+ 1),__f_readind)))))
     SET _remf_readind = (_remf_readind+ rptsd->m_drawlength)
    ELSE
     SET _remf_readind = 0
    ENDIF
    SET growsum = (growsum+ _remf_readind)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_f_technologist
   IF (ncalc=rpt_render
    AND _holdremf_technologist > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_technologist,((
       size(__f_technologist) - _holdremf_technologist)+ 1),__f_technologist)))
   ELSE
    SET _remf_technologist = _holdremf_technologist
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.750)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_f_critiques
   IF (ncalc=rpt_render
    AND _holdremf_critiques > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_critiques,((size
       (__f_critiques) - _holdremf_critiques)+ 1),__f_critiques)))
   ELSE
    SET _remf_critiques = _holdremf_critiques
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.000)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = drawheight_f_accession
   IF (ncalc=rpt_render
    AND _holdremf_accession > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_accession,((size
       (__f_accession) - _holdremf_accession)+ 1),__f_accession)))
   ELSE
    SET _remf_accession = _holdremf_accession
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.875)
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = drawheight_f_procedure
   IF (ncalc=rpt_render
    AND _holdremf_procedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_procedure,((size
       (__f_procedure) - _holdremf_procedure)+ 1),__f_procedure)))
   ELSE
    SET _remf_procedure = _holdremf_procedure
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.250)
   SET rptsd->m_width = 0.604
   SET rptsd->m_height = drawheight_f_orderdate
   IF (ncalc=rpt_render
    AND _holdremf_orderdate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_orderdate,((size
       (__f_orderdate) - _holdremf_orderdate)+ 1),__f_orderdate)))
   ELSE
    SET _remf_orderdate = _holdremf_orderdate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.000)
   SET rptsd->m_width = 0.698
   SET rptsd->m_height = drawheight_f_critiquedate
   IF (ncalc=rpt_render
    AND _holdremf_critiquedate > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_critiquedate,((
       size(__f_critiquedate) - _holdremf_critiquedate)+ 1),__f_critiquedate)))
   ELSE
    SET _remf_critiquedate = _holdremf_critiquedate
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.500)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_f_critiquecomments
   IF (ncalc=rpt_render
    AND _holdremf_critiquecomments > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_critiquecomments,
       ((size(__f_critiquecomments) - _holdremf_critiquecomments)+ 1),__f_critiquecomments)))
   ELSE
    SET _remf_critiquecomments = _holdremf_critiquecomments
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.500)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = drawheight_f_critiqueauthor
   IF (ncalc=rpt_render
    AND _holdremf_critiqueauthor > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_critiqueauthor,(
       (size(__f_critiqueauthor) - _holdremf_critiqueauthor)+ 1),__f_critiqueauthor)))
   ELSE
    SET _remf_critiqueauthor = _holdremf_critiqueauthor
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 10.000)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = drawheight_f_readind
   IF (ncalc=rpt_render
    AND _holdremf_readind > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremf_readind,((size(
        __f_readind) - _holdremf_readind)+ 1),__f_readind)))
   ELSE
    SET _remf_readind = _holdremf_readind
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
 SUBROUTINE detailsection2(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsection2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsection2abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen100s0c16777215)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 0.063),(offsetx+ 7.084),(offsety+
     0.063))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_page_foot(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_page_footabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_page_footabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.240000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.375)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RAD_CRITIQUE_V3"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
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
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_underline = rpt_on
   SET _times8bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.100
   SET rptpen->m_rgbcolor = rpt_white
   SET _pen100s0c16777215 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = sec_report_header(rpt_render)
 SET d0 = txt_col_headers(rpt_render)
 SET becont = 0
 FOR (x = 1 TO size(rec_str->techs,5))
  SET start = 1
  FOR (y = 1 TO size(rec_str->techs[x].orders,5))
    SET critiques = " "
    FOR (z = 1 TO size(rec_str->techs[x].orders[y].critiques,5))
     SET critiques = concat(critiques,rec_str->techs[x].orders[y].critiques[z].s_critique_desc,char(
       10))
     CALL echo(critiques)
    ENDFOR
    IF (((_yoffset+ detailsection(rpt_calcheight,6.5,becont)) > 7.5))
     SET d0 = sec_page_foot(rpt_render)
     SET d0 = pagebreak(1)
     SET start = 1
     SET d0 = txt_col_headers(rpt_render)
    ENDIF
    IF (start=1)
     SET tech_name = rec_str->techs[x].s_tech
     SET tech_id = cnvtstring(rec_str->techs[x].f_tech_id)
     SET start = 2
    ELSE
     SET tech_name = ""
     SET tech_id = ""
    ENDIF
    SET d0 = detailsection(rpt_render,6.5,becont)
    SET d0 = detailsection2(rpt_render)
  ENDFOR
 ENDFOR
 SET d0 = sec_page_foot(rpt_render)
 SET d0 = finalizereport( $OUTDEV)
#exit_program
END GO
