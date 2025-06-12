CREATE PROGRAM bhs_rpt_msg_cntr_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician" = 0,
  "Location" = value(999999),
  "Start Date" = curdate,
  "End Date" = curdate
  WITH outdev, phys_id, f_facility_cd,
  start_date, end_date
 DECLARE md_start_dt_tm = dq8 WITH protect, constant(cnvtdatetime(cnvtdate( $START_DATE),0))
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(cnvtdatetime(cnvtdate( $END_DATE),235959))
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE ms_date_range = vc WITH protect, constant(concat(format(md_start_dt_tm,"MM/DD/YYYY;;D"),
   " to ",format(md_end_dt_tm,"MM/DD/YYYY;;D")))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mc_status = c1 WITH protect, noconstant("Z")
 DECLARE ms_status_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_phys_name = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_fac_cd_p = vc WITH protect, noconstant("")
 DECLARE ms_facility_disp = vc WITH protect, noconstant("")
 DECLARE p_page = vc WITH protect
 DECLARE p_dt_tm = vc WITH protect
 DECLARE p_name = vc WITH protect
 DECLARE p_catalog = vc WITH protect
 DECLARE p_action = vc WITH protect
 DECLARE p_event = vc WITH protect
 DECLARE p_order_mnem = vc WITH protect
 DECLARE p_electronic = vc WITH protect
 FREE RECORD clinev
 RECORD clinev(
   1 qual[*]
     2 d_action_dt_tm = dq8
     2 s_name_full_formatted = vc
     2 s_catalog_disp = vc
     2 s_action_type_disp = vc
     2 s_event_tag = vc
     2 s_facility = vc
 )
 FREE RECORD rx
 RECORD rx(
   1 qual[*]
     2 d_orig_order_dt_tm = dq8
     2 s_name_full_formatted = vc
     2 s_order_mnemonic = vc
     2 n_electronic_ind = i2
     2 s_facility = vc
 )
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
  SET ms_facility_disp = "ALL"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    IF (i=1)
     SET ms_facility_p = build2("e.loc_facility_cd in (",parameter(3,i))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(3,i))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("e.loc_facility_cd = ",parameter(3,0))
 ENDIF
 IF (ms_facility_disp != "ALL")
  SET ms_fac_cd_p = replace(ms_facility_p,"e.loc_facility_cd","c.code_value")
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=220
    AND c.active_ind=1
    AND c.end_effective_dt_tm > sysdate
    AND parser(ms_fac_cd_p)
   ORDER BY c.display DESC
   HEAD REPORT
    ms_facility_disp = " "
   DETAIL
    ms_facility_disp = build2(trim(c.display,3),", ",ms_facility_disp)
   FOOT REPORT
    ms_facility_disp = substring(1,(textlen(ms_facility_disp) - 1),ms_facility_disp)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id= $PHYS_ID)
  DETAIL
   ms_phys_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (ms_phys_name IN ("", " ", null))
  SET mc_status = "F"
  SET ms_status_msg = "Physician not found"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cep.action_dt_tm, p.name_full_formatted, ce_catalog_disp = uar_get_code_display(ce.catalog_cd),
  cep_action_type_disp = uar_get_code_display(cep.action_type_cd), ce.event_tag
  FROM ce_event_prsnl cep,
   clinical_event ce,
   encounter e,
   person p
  PLAN (cep
   WHERE (cep.action_prsnl_id= $PHYS_ID)
    AND cep.action_dt_tm BETWEEN cnvtdatetime(md_start_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND cep.valid_until_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.end_effective_dt_tm > sysdate
    AND parser(ms_facility_p))
   JOIN (p
   WHERE p.person_id=ce.person_id)
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, stat = alterlist(clinev->qual,ml_cnt), clinev->qual[ml_cnt].d_action_dt_tm = cep
   .action_dt_tm,
   clinev->qual[ml_cnt].s_name_full_formatted = p.name_full_formatted, clinev->qual[ml_cnt].
   s_catalog_disp = uar_get_code_display(ce.catalog_cd), clinev->qual[ml_cnt].s_action_type_disp =
   uar_get_code_display(cep.action_type_cd),
   clinev->qual[ml_cnt].s_event_tag = ce.event_tag, clinev->qual[ml_cnt].s_facility =
   uar_get_code_display(e.loc_facility_cd)
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   order_detail od,
   encounter e,
   person p
  PLAN (oa
   WHERE ((oa.order_provider_id+ 0)= $PHYS_ID)
    AND oa.action_dt_tm BETWEEN cnvtdatetime(md_start_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND oa.order_status_cd=mf_ordered_cd
    AND oa.action_type_cd=mf_order_cd)
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.orig_ord_as_flag=1)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_meaning= Outerjoin("REQROUTINGTYPE"))
    AND (trim(cnvtupper(od.oe_field_display_value))= Outerjoin("ROUTE TO PHARMACY ELECTRONICALLY")) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.end_effective_dt_tm > sysdate
    AND parser(ms_facility_p))
   JOIN (p
   WHERE p.person_id=o.person_id)
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, stat = alterlist(rx->qual,ml_cnt), rx->qual[ml_cnt].d_orig_order_dt_tm = o
   .orig_order_dt_tm,
   rx->qual[ml_cnt].s_name_full_formatted = p.name_full_formatted, rx->qual[ml_cnt].s_order_mnemonic
    = o.order_mnemonic
   IF (od.order_id > 0)
    rx->qual[ml_cnt].n_electronic_ind = 1
   ELSE
    rx->qual[ml_cnt].n_electronic_ind = 0
   ENDIF
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
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
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _times60 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times200 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
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
 SUBROUTINE (headpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.190000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.021
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times60)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 8.938)
    SET rptsd->m_width = 0.344
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Page:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 9.313)
    SET rptsd->m_width = 0.678
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_page,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.120000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.376)
    SET rptsd->m_width = 4.813
    SET rptsd->m_height = 0.376
    SET _oldfont = uar_rptsetfont(_hreport,_times200)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician Activity Report",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Physician:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.511)
    SET rptsd->m_x = (offsetx+ 0.803)
    SET rptsd->m_width = 3.011
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_phys_name,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.511)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 0.928
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Range:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 8.146)
    SET rptsd->m_width = 1.855
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_date_range,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_facility_disp,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headclinevsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headclinevsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headclinevsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.657),(offsetx+ 10.001),(offsety
     + 0.657))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Clinical Events",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Catalog",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 0.605
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Action",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 7.313)
    SET rptsd->m_width = 0.771
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Event Tag",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailclinevsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailclinevsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailclinevsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.011)
    SET rptsd->m_width = 1.240
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_name,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_catalog,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_action,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 7.313)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_event,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headrxsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headrxsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headrxsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.720000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.657),(offsetx+ 10.001),(offsety
     + 0.657))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Prescriptions",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date/Time",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.146
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Electronic",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 4.438)
    SET rptsd->m_width = 1.469
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Order Mnemonic",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailrxsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailrxsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailrxsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_dt_tm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_name,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_electronic,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 4.438)
    SET rptsd->m_width = 5.563
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(p_order_mnem,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_MSG_CNTR_AUDIT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
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
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _times60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 20
   SET _times200 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET p_page = "1"
 SET d0 = headpagesection(rpt_render)
 SET d0 = headreportsection(rpt_render)
 SET d0 = headclinevsection(rpt_render)
 FOR (ml_cnt = 1 TO value(size(clinev->qual,5)))
   SET p_dt_tm = format(cnvtdatetime(clinev->qual[ml_cnt].d_action_dt_tm),"MM/DD/YYYY HH:MM;;D")
   SET p_name = clinev->qual[ml_cnt].s_name_full_formatted
   SET p_catalog = clinev->qual[ml_cnt].s_catalog_disp
   SET p_action = clinev->qual[ml_cnt].s_action_type_disp
   SET p_event = clinev->qual[ml_cnt].s_event_tag
   IF (((_yoffset+ detailclinevsection(rpt_calcheight)) > 7.5))
    SET d0 = pgbreak(1)
    SET d0 = headclinevsection(rpt_render)
   ENDIF
   SET d0 = detailclinevsection(rpt_render)
 ENDFOR
 IF (((_yoffset+ detailrxsection(rpt_calcheight)) > 7.5))
  SET d0 = pgbreak(1)
 ENDIF
 SET d0 = headrxsection(rpt_render)
 FOR (ml_cnt = 1 TO value(size(rx->qual,5)))
   SET p_dt_tm = format(cnvtdatetime(rx->qual[ml_cnt].d_orig_order_dt_tm),"YYYY-MM-DD HH:MM;;D")
   SET p_name = rx->qual[ml_cnt].s_name_full_formatted
   SET p_order_mnem = rx->qual[ml_cnt].s_order_mnemonic
   IF ((rx->qual[ml_cnt].n_electronic_ind=1))
    SET p_electronic = "Yes"
   ELSE
    SET p_electronic = "No"
   ENDIF
   IF (((_yoffset+ detailrxsection(rpt_calcheight)) > 7.5))
    SET d0 = pgbreak(1)
    SET d0 = headrxsection(rpt_render)
   ENDIF
   SET d0 = detailrxsection(rpt_render)
 ENDFOR
 SET d0 = finalizereport(value( $OUTDEV))
 SET mc_status = "S"
 SUBROUTINE pgbreak(dummy)
   CALL echo("Page break")
   SET p_page = cnvtstring((cnvtint(p_page)+ 1))
   SET d0 = pagebreak(dummy)
   SET d0 = headpagesection(rpt_render)
 END ;Subroutine
#exit_script
 IF (ml_debug_flag >= 10)
  CALL echorecord(clinev)
  CALL echorecord(rx)
 ENDIF
 IF (mc_status != "S")
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    row 0, col 0, "Failure generating report",
    row + 1, col 0, "Status:          ",
    mc_status, row + 1, col 0,
    "Status Message:  ", ms_status_msg
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(concat("Status:         ",mc_status))
 CALL echo(concat("Status Message: ",ms_status_msg))
 FREE RECORD clinev
 FREE RECORD rx
END GO
