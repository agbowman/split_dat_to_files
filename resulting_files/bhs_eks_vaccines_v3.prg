CREATE PROGRAM bhs_eks_vaccines_v3
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beginning Date:" = 0,
  "Ending Date:" = curdate,
  "Type of Vaccine" = "3",
  "Facility" = 0,
  "Nurse Unit" = 0,
  "Totals" = "YES"
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt7,
  prompt6
 DECLARE place_flu_cd = f8
 DECLARE place_pneum_cd = f8
 DECLARE flu_vaccine_cd = f8
 DECLARE flu_vaccine_inact_cd = f8
 DECLARE flu_vaccine_live_cd = f8
 DECLARE pneum_23vaccine_cd = f8
 DECLARE pneum_13vaccine_cd = f8
 DECLARE pneum_7vaccine_cd = f8
 DECLARE pneum_vaccine_cd = f8
 DECLARE order_action_cd = f8
 DECLARE fin_nbr_cd = f8
 SET flu_vaccine_cd = uar_get_code_by("DISPLAY",200,"Influenza Virus Vaccine")
 SET flu_vaccine_inact_cd = uar_get_code_by("DISPLAY",200,"influenza virus vaccine, inactivated")
 SET flu_vaccine_live_cd = uar_get_code_by("DISPLAY",200,"Influenza virus vaccine, live")
 SET pneum_23vaccine_cd = uar_get_code_by("DISPLAY",200,"Pneumococcal 23-Valent Vaccine")
 SET pneum_13vaccine_cd = uar_get_code_by("DISPLAY",200,"pneumococcal 13-valent vaccine")
 SET pneum_7vaccine_cd = uar_get_code_by("DISPLAY",200,"pneumococcal 7-valent vaccine")
 SET pneum_vaccine_cd = uar_get_code_by("DISPLAY",200,"Pneumococcal Vaccine")
 SET h1n1_1 = uar_get_code_by("displaykey",200,"INFLUENZAH1N1VACCINES")
 SET h1n1_2 = uar_get_code_by("displaykey",200,"INFLUENZAVIRUSVACCINEH1N1INACTIVE")
 SET h1n1_3 = uar_get_code_by("displaykey",200,"INFLUENZAVIRUSVACCINEH1N1LIVE")
 SET h1n1_4 = uar_get_code_by("displaykey",200,"RECHECKH1N1IMMUNIZATIONSTATUS")
 SET order_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET fin_nbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE mf_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD vaccine
 RECORD vaccine(
   1 list[*]
     2 eks_order_id = f8
     2 eks_orig_order_dt_tm = dq8
     2 eks_catalog_cd = f8
     2 eks_task_status_cd = f8
     2 eks_task_updt_prsnl = vc
     2 new_order_id = f8
     2 new_orig_order_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_facility_cd = f8
     2 patient_name = vc
     2 acct_num = vc
     2 new_ordered_as_mnemonic = vc
     2 new_clinical_display_line = vc
     2 new_charted_dt_tm = dq8
     2 new_chart_person = vc
     2 prsnl_id = f8
     2 prsnl_name = vc
     2 status = vc
     2 comment = vc
 )
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   encounter e,
   dummyt d,
   clinical_event ce,
   prsnl pr
  PLAN (o
   WHERE ((( $4="3")
    AND o.catalog_cd IN (flu_vaccine_cd, flu_vaccine_inact_cd, flu_vaccine_live_cd,
   pneum_23vaccine_cd, pneum_13vaccine_cd,
   pneum_7vaccine_cd, pneum_vaccine_cd, h1n1_1, h1n1_2, h1n1_3,
   h1n1_4)) OR (((( $4="2")
    AND o.catalog_cd IN (pneum_23vaccine_cd, pneum_13vaccine_cd, pneum_7vaccine_cd, pneum_vaccine_cd)
   ) OR (( $4="1")
    AND o.catalog_cd IN (flu_vaccine_cd, flu_vaccine_inact_cd, flu_vaccine_live_cd, h1n1_1, h1n1_2,
   h1n1_3, h1n1_4))) ))
    AND o.active_ind=1)
   JOIN (oa
   WHERE o.order_id=oa.order_id
    AND oa.action_type_cd=order_action_cd
    AND oa.action_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),235959))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND (e.loc_facility_cd= $PROMPT5)
    AND (e.loc_nurse_unit_cd= $PROMPT7)
    AND e.active_ind=1)
   JOIN (d)
   JOIN (ce
   WHERE ce.order_id=outerjoin(o.order_id)
    AND ce.view_level=outerjoin(1)
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND  NOT (ce.result_status_cd IN (mf_inerror_cd))
    AND ce.event_tag_set_flag=1)
   JOIN (pr
   WHERE pr.person_id=outerjoin(ce.verified_prsnl_id))
  ORDER BY o.order_id
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(vaccine->list,(cnt+ 99))
   ENDIF
   vaccine->list[cnt].eks_order_id = o.order_id, vaccine->list[cnt].eks_orig_order_dt_tm = o
   .orig_order_dt_tm, vaccine->list[cnt].eks_catalog_cd = o.catalog_cd,
   vaccine->list[cnt].new_order_id = o.order_id, vaccine->list[cnt].new_orig_order_dt_tm = o
   .orig_order_dt_tm, vaccine->list[cnt].encntr_id = o.encntr_id,
   vaccine->list[cnt].person_id = o.person_id, vaccine->list[cnt].new_ordered_as_mnemonic = build(o
    .ordered_as_mnemonic), vaccine->list[cnt].new_clinical_display_line = o.simplified_display_line,
   vaccine->list[cnt].eks_task_updt_prsnl = pr.name_full_formatted, vaccine->list[cnt].
   new_charted_dt_tm = ce.event_end_dt_tm, vaccine->list[cnt].new_chart_person = pr
   .name_full_formatted,
   vaccine->list[cnt].status = ce.event_tag
   IF (uar_get_code_display(ce.result_status_cd)="Auth (Verified)")
    vaccine->list[cnt].status = "Given"
   ELSEIF (ce.clinical_event_id > 0)
    vaccine->list[cnt].status = trim(ce.event_tag,3)
   ELSE
    vaccine->list[cnt].status = uar_get_code_display(o.dept_status_cd)
    IF ((vaccine->list[cnt].status="Ordered"))
     vaccine->list[cnt].status = "Not Charted"
    ENDIF
   ENDIF
  FOOT REPORT
   IF (cnt > 0)
    stat = alterlist(vaccine->list,cnt)
   ELSE
    stat = alterlist(vaccine->list,1)
   ENDIF
  WITH outerjoin = d, nullreport
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(vaccine->list,5))),
   person p,
   order_action oa,
   prsnl pr,
   encounter e,
   encntr_alias ea,
   dummyt d2
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=vaccine->list[d.seq].person_id))
   JOIN (e
   WHERE (e.encntr_id=vaccine->list[d.seq].encntr_id))
   JOIN (ea
   WHERE ea.encntr_alias_type_cd=fin_nbr_cd
    AND ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
   JOIN (d2)
   JOIN (oa
   WHERE (oa.order_id=vaccine->list[d.seq].new_order_id)
    AND (oa.action_sequence=
   (SELECT
    o.last_action_sequence
    FROM orders o
    WHERE o.order_id=oa.order_id)))
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
  DETAIL
   vaccine->list[d.seq].loc_nurse_unit_cd = e.loc_nurse_unit_cd, vaccine->list[d.seq].loc_facility_cd
    = e.loc_facility_cd, vaccine->list[d.seq].loc_room_cd = e.loc_room_cd,
   vaccine->list[d.seq].loc_bed_cd = e.loc_bed_cd, vaccine->list[d.seq].patient_name = p
   .name_full_formatted, vaccine->list[d.seq].prsnl_id = pr.person_id,
   vaccine->list[d.seq].prsnl_name = pr.name_full_formatted, vaccine->list[d.seq].acct_num = trim(ea
    .alias)
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(vaccine->list,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=vaccine->list[d.seq].new_order_id)
    AND od.oe_field_meaning IN ("DCREASON", "CANCELREASON"))
  DETAIL
   vaccine->list[d.seq].comment = trim(od.oe_field_display_value,3), vaccine->list[d.seq].
   new_charted_dt_tm = od.updt_dt_tm
  WITH nocounter
 ;end select
 CALL echorecord(vaccine)
 DECLARE beg_date_disp = vc
 DECLARE end_date_disp = vc
 DECLARE unit_disp = vc
 DECLARE roombed = vc
 SET beg_date_disp = format(cnvtdate( $2),"MM/DD/YYYY;;D")
 SET end_date_disp = format(cnvtdate( $3),"MM/DD/YYYY;;D")
 SET unit_disp = uar_get_code_display( $PROMPT7)
 DECLARE becont = i4 WITH noconstant(0)
 DECLARE ptname = vc
 DECLARE ptacct = vc
 DECLARE med = vc
 DECLARE status = vc
 DECLARE admindt = vc
 DECLARE orddate = vc
 DECLARE adminprsnl = vc
 DECLARE given_cnt = i2
 DECLARE notgiven_cnt = i2
 DECLARE notdone_cnt = i2
 DECLARE discon_cnt = i2
 DECLARE ordered_count = i2
 DECLARE cs_count = i2
 DECLARE percentage_given = vc
 DECLARE percentage_notgiven = vc
 DECLARE percentage_dc = vc
 DECLARE percentage_notdone = vc
 DECLARE percentage_ordered = vc
 DECLARE sectionheader = vc
 DECLARE pagesize = f8 WITH protect, constant(8.0)
 DECLARE rem_space = f8 WITH protect, noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreport(ncalc=i2) = f8 WITH protect
 DECLARE headreportabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headsection(ncalc=i2) = f8 WITH protect
 DECLARE headsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footsection(ncalc=i2) = f8 WITH protect
 DECLARE footsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreport(ncalc=i2) = f8 WITH protect
 DECLARE footreportabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times10bu0 = i4 WITH noconstant(0), protect
 DECLARE _times12bu0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
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
 SUBROUTINE headreport(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headreportabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.670000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 2.302
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health System",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.615
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vaccine Audit Report",char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.781
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Range:",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 0.813)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(beg_date_disp,char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 1.677)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("To",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 2.115)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(end_date_disp,char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 0.365
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unit:",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 7.250)
    SET rptsd->m_width = 0.583
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(unit_disp,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 8.250)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.590000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 512
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 3.917
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sectionheader,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.646)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Loc:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.302)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ord DT:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.604)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Med:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.271)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.760
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Chart DT:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 8.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ptacct,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.302)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ptname,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.604)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(med,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.271)
    SET rptsd->m_width = 1.479
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(status,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(admindt,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 8.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(adminprsnl,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.646)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(roombed,char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.688)
    SET rptsd->m_width = 0.958
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(orddate,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.630000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 1.406
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Ordered:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cs_count,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.260)
    SET rptsd->m_x = (offsetx+ 0.760)
    SET rptsd->m_width = 0.740
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Given:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.260)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(given_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 0.260)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_given,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.760)
    SET rptsd->m_width = 1.052
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Given:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_notgiven,char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(notgiven_cnt,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.781)
    SET rptsd->m_x = (offsetx+ 0.771)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Done:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.781)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(notdone_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 0.781)
    SET rptsd->m_x = (offsetx+ 2.771)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_notdone,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 0.760)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Charted:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordered_count,char(0)))
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 2.781)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_ordered,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.781)
    SET rptsd->m_width = 1.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Cancel/Dc:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.271)
    SET rptsd->m_x = (offsetx+ 2.021)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(discon_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 1.271)
    SET rptsd->m_x = (offsetx+ 2.771)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_dc,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreport(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.470000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 3.521)
    SET rptsd->m_width = 1.792
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("End of Report",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 0.052)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Run Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 7.792)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_EKS_VACCINES_V3"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SELECT INTO "NL:"
    p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
    FROM output_dest o,
     device d,
     printer p
    PLAN (o
     WHERE cnvtupper(o.name)=cnvtupper(trim(_sendto)))
     JOIN (d
     WHERE d.device_cd=o.device_cd)
     JOIN (p
     WHERE p.device_cd=d.device_cd)
    DETAIL
     CASE (cnvtint(p_printer_type_cdf))
      OF 8:
      OF 26:
      OF 29:
       _outputtype = rpt_postscript,_xdiv = 72,_ydiv = 72
      OF 16:
      OF 20:
      OF 24:
       _outputtype = rpt_zebra,_xdiv = 203,_ydiv = 203
      OF 42:
       _outputtype = rpt_zebra300,_xdiv = 300,_ydiv = 300
      OF 43:
       _outputtype = rpt_zebra600,_xdiv = 600,_ydiv = 600
      OF 32:
      OF 18:
      OF 19:
      OF 27:
      OF 31:
       _outputtype = rpt_intermec,_xdiv = 203,_ydiv = 203
      OF 45:
       _outputtype = rpt_intermec_dp203,_xdiv = 203,_ydiv = 203
      OF 46:
       _outputtype = rpt_intermec_dp300,_xdiv = 300,_ydiv = 300
      ELSE
       _xdiv = 1,_ydiv = 1
     ENDCASE
     _diotype = cnvtint(p_printer_type_cdf), _sendto = d.name
     IF (_xdiv > 1)
      rptreport->m_horzprintoffset = (cnvtreal(o.label_xpos)/ _xdiv)
     ENDIF
     IF (_xdiv > 1)
      rptreport->m_vertprintoffset = (cnvtreal(o.label_ypos)/ _ydiv)
     ENDIF
    WITH nocounter
   ;end select
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
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times12bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET _times10bu0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
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
 SET d0 = headreport(0)
 SET d0 = detailsection(rpt_render)
 IF (( $4 IN ("1", "3")))
  SET sectionheader = "Influenza:"
  SET d0 = headsection(rpt_render)
  FOR (x = 1 TO size(vaccine->list,5))
    IF ((vaccine->list[x].eks_catalog_cd IN (flu_vaccine_cd, flu_vaccine_inact_cd,
    flu_vaccine_live_cd, h1n1_1, h1n1_2,
    h1n1_3, h1n1_4)))
     SET cs_count = (cs_count+ 1)
     SET ptname = substring(1,20,trim(vaccine->list[x].patient_name,3))
     SET ptacct = trim(vaccine->list[x].acct_num,3)
     SET med = trim(vaccine->list[x].new_ordered_as_mnemonic,3)
     IF ((vaccine->list[x].comment > " "))
      SET status = build(vaccine->list[x].status,":",vaccine->list[x].comment)
     ELSE
      SET status = vaccine->list[x].status
     ENDIF
     SET admindt = format(vaccine->list[x].new_charted_dt_tm,"mm/dd/yyyy hh:mm;;d")
     SET orddate = format(vaccine->list[x].new_orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
     IF ((vaccine->list[x].new_chart_person > " "))
      SET adminprsnl = vaccine->list[x].new_chart_person
     ELSEIF ( NOT ((vaccine->list[x].status="Not Charted*")))
      SET adminprsnl = vaccine->list[x].prsnl_name
     ELSE
      SET adminprsnl = " "
     ENDIF
     IF ((vaccine->list[x].loc_room_cd > 0))
      SET roombed = concat(trim(uar_get_code_display(vaccine->list[x].loc_room_cd)),"/",trim(
        uar_get_code_display(vaccine->list[x].loc_bed_cd)))
     ELSE
      SET roombed = "Discharge"
     ENDIF
     SELECT INTO "nl:"
      FROM dummyt d
      PLAN (d
       WHERE 1=1)
      DETAIL
       CASE (vaccine->list[x].status)
        OF "Given":
         given_cnt = (given_cnt+ 1)
        OF "Not Given*":
         notgiven_cnt = (notgiven_cnt+ 1)
        OF "Not Done*":
         notdone_cnt = (notdone_cnt+ 1)
        OF "Discontinued*":
         discon_cnt = (discon_cnt+ 1)
        OF "Cancel*":
         discon_cnt = (discon_cnt+ 1)
        OF "Not Charted":
         ordered_count = (ordered_count+ 1)
       ENDCASE
      WITH nocounter
     ;end select
     SET rem_space = (pagesize - (_yoffset+ detailsection(rpt_calcheight)))
     IF (rem_space < 0.35)
      SET d0 = pagebreak(0)
      SET d0 = headreport(rpt_render)
      SET d0 = headsection(rpt_render)
     ENDIF
     SET d0 = detailsection(rpt_render)
    ENDIF
  ENDFOR
  SET percentage_given = format(((given_cnt * 100)/ cs_count),"###.##%")
  SET percentage_notgiven = format(((notgiven_cnt * 100)/ cs_count),"###.##%")
  SET percentage_notdone = format(((notdone_cnt * 100.00)/ cs_count),"###.##%")
  SET percentage_ordered = format(((ordered_count * 100.00)/ cs_count),"###.##%")
  SET percentage_dc = format(((discon_cnt * 100.00)/ cs_count),"###.##%")
  IF (( $7="YES")
   AND cs_count > 0)
   SET d0 = footsection(rpt_render)
  ENDIF
 ENDIF
 IF (( $4 IN ("2", "3")))
  SET percentage_given = " "
  SET percentage_notgiven = " "
  SET percentage_notdone = " "
  SET percentage_ordered = " "
  SET percentage_dc = " "
  SET given_cnt = 0
  SET notgiven_cnt = 0
  SET notdone_cnt = 0
  SET discon_cnt = 0
  SET ordered_count = 0
  SET cs_count = 0
  SET sectionheader = "Pneumococcal:"
  SET d0 = headsection(rpt_render)
  FOR (x = 1 TO size(vaccine->list,5))
    IF ((vaccine->list[x].eks_catalog_cd IN (pneum_23vaccine_cd, pneum_13vaccine_cd,
    pneum_7vaccine_cd, pneum_vaccine_cd)))
     SET cs_count = (cs_count+ 1)
     SET ptname = substring(1,20,trim(vaccine->list[x].patient_name,3))
     SET ptacct = trim(vaccine->list[x].acct_num,3)
     SET med = trim(vaccine->list[x].new_ordered_as_mnemonic,3)
     IF ((vaccine->list[x].comment > " "))
      SET status = build(vaccine->list[x].status,":",vaccine->list[x].comment)
     ELSE
      SET status = vaccine->list[x].status
     ENDIF
     SET admindt = format(vaccine->list[x].new_charted_dt_tm,"mm/dd/yyyy hh:mm;;d")
     SET orddate = format(vaccine->list[x].new_orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
     IF ((vaccine->list[x].new_chart_person > " "))
      SET adminprsnl = vaccine->list[x].new_chart_person
     ELSEIF ( NOT ((vaccine->list[x].status="Not Charted*")))
      SET adminprsnl = vaccine->list[x].prsnl_name
     ELSE
      SET adminprsnl = " "
     ENDIF
     IF ((vaccine->list[x].loc_room_cd > 0))
      SET roombed = concat(trim(uar_get_code_display(vaccine->list[x].loc_room_cd)),"/",trim(
        uar_get_code_display(vaccine->list[x].loc_bed_cd)))
     ELSE
      SET roombed = "Discharge"
     ENDIF
     SELECT INTO "nl:"
      FROM dummyt d
      DETAIL
       CASE (vaccine->list[x].status)
        OF "Given":
         given_cnt = (given_cnt+ 1)
        OF "Not Given*":
         notgiven_cnt = (notgiven_cnt+ 1)
        OF "Not Done*":
         notdone_cnt = (notdone_cnt+ 1)
        OF "Discontinued*":
         discon_cnt = (discon_cnt+ 1)
        OF "Cancel*":
         discon_cnt = (discon_cnt+ 1)
        OF "Not Charted":
         ordered_count = (ordered_count+ 1)
       ENDCASE
      WITH nocounter
     ;end select
     SET rem_space = (pagesize - (_yoffset+ detailsection(rpt_calcheight)))
     IF (rem_space < 0.25)
      CALL echo("break page2")
      SET d0 = pagebreak(0)
      SET d0 = headreport(rpt_render)
      SET d0 = headsection(rpt_render)
     ENDIF
     SET d0 = detailsection(rpt_render)
    ENDIF
  ENDFOR
  SET percentage_given = format(((given_cnt * 100)/ cs_count),"###.##%")
  SET percentage_notgiven = format(((notgiven_cnt * 100)/ cs_count),"###.##%")
  SET percentage_notdone = format(((notdone_cnt * 100.00)/ cs_count),"###.##%")
  SET percentage_ordered = format(((ordered_count * 100.00)/ cs_count),"###.##%")
  SET percentage_dc = format(((discon_cnt * 100.00)/ cs_count),"###.##%")
  SET rem_space = (pagesize - (_yoffset+ footsection(rpt_calcheight)))
  IF (rem_space < 1.0)
   CALL echo("break page2")
   SET d0 = pagebreak(0)
   SET d0 = headreport(rpt_render)
   SET d0 = headsection(rpt_render)
  ENDIF
  IF (( $7="YES")
   AND cs_count > 0)
   SET d0 = footsection(rpt_render)
  ENDIF
 ENDIF
 SET d0 = footreport(rpt_render)
 SET d0 = finalizereport(value( $1))
 GO TO exit_script
 SELECT INTO  $1
  care_set = vaccine->list[d.seq].eks_catalog_cd
  FROM (dummyt d  WITH seq = value(size(vaccine->list,5)))
  ORDER BY care_set
  HEAD REPORT
   cs_count = 0, cs_ordered_count = 0, cs_admin_count = 0,
   given_cnt = 0, notgiven_cnt = 0, notdone_cnt = 0,
   discon_cnt = 0
  HEAD PAGE
   col 1, curprog, col 50,
   "Baystate Health System", row + 1, col 50,
   "Vaccination Audit Report", row + 1
   IF (( $4="1"))
    col 50, "Influenza only"
   ELSEIF (( $4="2"))
    col 50, "Pneumococcal only"
   ELSEIF (( $4="3"))
    col 50, "Both Influenza and Pneumococcal"
   ENDIF
   row + 1, beg_date_disp = format(cnvtdate( $2),"MM/DD/YYYY;;D"), end_date_disp = format(cnvtdate(
      $3),"MM/DD/YYYY;;D"),
   col 50, "Date Range: ", beg_date_disp,
   " to ", end_date_disp, row + 2
  HEAD care_set
   cs_count = 0, cs_ordered_count = 0, cs_admin_count = 0,
   given_cnt = 0, notgiven_cnt = 0, notdone_cnt = 0,
   discon_cnt = 0, care_set_disp = build("**",uar_get_code_display(care_set),":"), col 1,
   care_set_disp, row + 1, row + 1,
   col 1, "Acct", col 12,
   "Patient", col 45, "Ord Dt",
   col 60, "Location", col 92,
   "Admin Dt.", col 103, "Admin Prsnl",
   row + 1
  DETAIL
   IF ((vaccine->list[d.seq].eks_order_id > 0))
    cs_count = (cs_count+ 1)
   ENDIF
   CASE (vaccine->list[d.seq].status)
    OF "Given":
     given_cnt = (given_cnt+ 1)
    OF "Not Given*":
     notgiven_cnt = (notgiven_cnt+ 1)
    OF "Not Done*":
     notdone_cnt = (notdone_cnt+ 1)
    OF "Discontinued*":
     discon_cnt = (discon_cnt+ 1)
    OF "Cancel*":
     discon_cnt = (discon_cnt+ 1)
    OF "Not Charted":
     cs_ordered_count = (cs_ordered_count+ 1)
   ENDCASE
   col 1, vaccine->list[d.seq].acct_num, name_disp = substring(1,30,vaccine->list[d.seq].patient_name
    ),
   col 12, name_disp, eks_date_disp = format(vaccine->list[d.seq].eks_orig_order_dt_tm,
    "MM/DD/YYYY;;D"),
   col 45, eks_date_disp, eks_task_status_disp = substring(1,10,uar_get_code_display(vaccine->list[d
     .seq].eks_task_status_cd)),
   col 57, eks_task_status_disp, loc_disp = fillstring(20," "),
   loc_disp = concat(trim(uar_get_code_display(vaccine->list[d.seq].loc_nurse_unit_cd)),"/",trim(
     uar_get_code_display(vaccine->list[d.seq].loc_room_cd)),"/",trim(uar_get_code_display(vaccine->
      list[d.seq].loc_bed_cd))), col 60, loc_disp,
   new_chart_dt_tm_disp = format(vaccine->list[d.seq].new_charted_dt_tm,"MM/DD/YYYY;;D"), col 92,
   new_chart_dt_tm_disp,
   new_chart_person_name = substring(1,20,vaccine->list[d.seq].new_chart_person), col 103,
   new_chart_person_name,
   row + 1
   IF ((vaccine->list[d.seq].new_order_id > 0))
    new_order_disp = vaccine->list[d.seq].new_ordered_as_mnemonic, col 12, new_order_disp,
    order_prsnl_disp = concat(substring(1,30,vaccine->list[d.seq].status),"-",substring(1,20,vaccine
      ->list[d.seq].prsnl_name)), col 60, order_prsnl_disp,
    row + 1, col 60, vaccine->list[d.seq].comment,
    row + 1, row + 1
   ENDIF
  FOOT  care_set
   IF (( $PROMPT6="YES"))
    care_set_disp = uar_get_code_display(care_set), percentage = 0.00, col 30,
    "Total Ordered: ", col 60, cs_count,
    row + 1, percentage = 0.00, percentage = ((given_cnt * 100)/ cs_count),
    col 30, "Total Given: ", col 60,
    given_cnt, col 80, percentage"###.##%",
    row + 1, percentage = 0.00, percentage = ((notgiven_cnt * 100.00)/ cs_count),
    col 30, "Total Not Given: ", col 60,
    notgiven_cnt, col 80, percentage"###.##%",
    row + 1, percentage = 0.00, percentage = ((notdone_cnt * 100.00)/ cs_count),
    col 30, "Total Not Done: ", col 60,
    notdone_cnt, col 80, percentage"###.##%",
    row + 1, percentage = 0.00, percentage = ((discon_cnt * 100.00)/ cs_count),
    col 30, "Total Cancle/Discont: ", col 60,
    discon_cnt, col 80, percentage"###.##%",
    row + 1, percentage = 0.00, percentage = ((cs_ordered_count * 100.00)/ cs_count),
    col 30, "Total Not Charted: ", col 60,
    cs_ordered_count, col 80, percentage"###.##%",
    row + 2
   ENDIF
 ;end select
#exit_script
 SET last_mod =
 "005 02/03/17 PP049572             414345068 Restructured query to fetch the result without time delay"
END GO
