CREATE PROGRAM bhs_rpt_hepb_peds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beginning Date:" = 0,
  "Ending Date:" = curdate,
  "Type of Vaccine" = "1",
  "Facility" = 673936.00,
  "Nurse Unit" = 0,
  "Totals" = "YES",
  "Less than 8 days old" = 1
  WITH outdev, beg_dt, end_dt,
  type_vac, facility, unit,
  total, lessthandays
 DECLARE ms_continue = i4 WITH noconstant(0), protect
 DECLARE mf_modified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"MODIFIED")), protect
 DECLARE mf_authverified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_order_action_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE mf_hepbpedivac = f8 WITH constant(uar_get_code_by("DESCRIPTION",200,
   "hepatitis B pediatric vaccine")), protect
 DECLARE mf_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE beg_date_disp = vc
 DECLARE end_date_disp = vc
 DECLARE unit_disp = vc
 DECLARE roombed = vc
 SET beg_date_disp = format(cnvtdate( $BEG_DT),"MM/DD/YYYY;;D")
 SET end_date_disp = format(cnvtdate( $END_DT),"MM/DD/YYYY;;D")
 SET unit_disp = uar_get_code_display( $UNIT)
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
 DECLARE vfc_count = i2
 DECLARE cs_count = i2
 DECLARE percentage_given = vc
 DECLARE percentage_notgiven = vc
 DECLARE percentage_dc = vc
 DECLARE percentage_notdone = vc
 DECLARE ms_percentage_vfc = vc
 DECLARE percentage_ordered = vc
 DECLARE sectionheader = vc
 DECLARE pagesize = f8 WITH protect, constant(8.0)
 DECLARE rem_space = f8 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD vaccine
 RECORD vaccine(
   1 vfc_cnt = i4
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
     2 vfc_value = vc
 )
 SELECT INTO "nl:"
  vfc_status = uar_get_code_display(im.vfc_status_cd)
  FROM order_action oa,
   orders o,
   clinical_event ce,
   immunization_modifier im,
   prsnl pr,
   person p
  PLAN (oa
   WHERE oa.action_type_cd=mf_order_action_cd
    AND oa.action_dt_tm BETWEEN cnvtdatetime(cnvtdate( $BEG_DT),0) AND cnvtdatetime(cnvtdate( $END_DT
     ),235959))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ( $TYPE_VAC="1")
    AND o.catalog_cd IN (mf_hepbpedivac)
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE e.encntr_id=o.encntr_id
     AND (e.loc_facility_cd= $FACILITY)
     AND (e.loc_nurse_unit_cd= $UNIT))))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND ((p.birth_dt_tm > cnvtlookbehind("8 D")) OR (( $LESSTHANDAYS=0))) )
   JOIN (ce
   WHERE ce.order_id=outerjoin(o.order_id)
    AND ce.view_level=outerjoin(1)
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ce.result_status_cd != outerjoin(mf_inerror_cd)
    AND ce.event_tag_set_flag=outerjoin(1))
   JOIN (pr
   WHERE pr.person_id=outerjoin(ce.verified_prsnl_id))
   JOIN (im
   WHERE im.event_id=outerjoin(ce.event_id)
    AND im.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY o.order_id
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(vaccine->list,(cnt+ 9))
   ENDIF
   vaccine->list[cnt].eks_order_id = o.order_id, vaccine->list[cnt].eks_orig_order_dt_tm = o
   .orig_order_dt_tm, vaccine->list[cnt].eks_catalog_cd = o.catalog_cd,
   vaccine->list[cnt].new_order_id = o.order_id, vaccine->list[cnt].new_orig_order_dt_tm = o
   .orig_order_dt_tm, vaccine->list[cnt].encntr_id = o.encntr_id,
   vaccine->list[cnt].person_id = o.person_id, vaccine->list[cnt].new_ordered_as_mnemonic = build(o
    .ordered_as_mnemonic), vaccine->list[cnt].new_clinical_display_line = o.simplified_display_line,
   vaccine->list[cnt].eks_task_updt_prsnl = pr.name_full_formatted
   IF (im.vfc_status_cd > 0)
    vaccine->list[cnt].vfc_value = trim(vfc_status,3), vaccine->vfc_cnt = (vaccine->vfc_cnt+ 1)
   ELSE
    vaccine->list[cnt].vfc_value = trim(" ",3)
   ENDIF
   vaccine->list[cnt].new_charted_dt_tm = ce.event_end_dt_tm, vaccine->list[cnt].new_chart_person =
   pr.name_full_formatted, vaccine->list[cnt].status = ce.event_tag
   IF (ce.result_status_cd IN (mf_authverified))
    vaccine->list[cnt].status = "Given"
   ELSEIF (ce.result_status_cd=mf_not_done_cd)
    vaccine->list[cnt].status = trim(ce.event_tag,3)
   ELSE
    vaccine->list[cnt].status = uar_get_code_display(o.dept_status_cd)
    IF ((vaccine->list[cnt].status="Ordered"))
     vaccine->list[cnt].status = "Not Charted"
    ELSEIF ((vaccine->list[cnt].status="Completed"))
     vaccine->list[cnt].status = "Given"
    ENDIF
   ENDIF
  FOOT REPORT
   IF (cnt > 0)
    stat = alterlist(vaccine->list,cnt)
   ELSE
    stat = alterlist(vaccine->list,1)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(vaccine)
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
   WHERE ea.encntr_alias_type_cd=mf_finnbr
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
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headreport(ncalc=i2) = f8 WITH protect
 DECLARE headreportabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headsection(ncalc=i2) = f8 WITH protect
 DECLARE headsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE no_data_found(ncalc=i2) = f8 WITH protect
 DECLARE no_data_foundabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
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
 DECLARE _rempatname = i4 WITH noconstant(1), protect
 DECLARE _remmedordered = i4 WITH noconstant(1), protect
 DECLARE _remordstatus = i4 WITH noconstant(1), protect
 DECLARE _remdis_vfc = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _souvenir240 = i4 WITH noconstant(0), protect
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
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 2.302
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Baystate Health System",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 1.615
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hep B Audit Report",char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 0.781
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Range:",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 0.802
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(beg_date_disp,char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 1.927)
    SET rptsd->m_width = 0.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("To",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.396)
    SET rptsd->m_x = (offsetx+ 2.365)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(end_date_disp,char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 7.125)
    SET rptsd->m_width = 0.365
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unit:",char(0)))
    SET rptsd->m_flags = 1024
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 7.500)
    SET rptsd->m_width = 0.583
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(unit_disp,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 8.500)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.302
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
    SET rptsd->m_x = (offsetx+ 0.313)
    SET rptsd->m_width = 3.917
    SET rptsd->m_height = 0.229
    SET _oldfont = uar_rptsetfont(_hreport,_times12bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sectionheader,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.615)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Loc:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.708)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ord DT:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Med:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.292)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Status:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.083)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Chart DT:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 7.021)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider:",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 8.427)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Vaccine for Children:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE no_data_found(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = no_data_foundabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE no_data_foundabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF ( NOT (size(vaccine->list,5)=0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 276
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.156)
    SET rptsd->m_x = (offsetx+ 0.740)
    SET rptsd->m_width = 8.948
    SET rptsd->m_height = 0.656
    SET _oldfont = uar_rptsetfont(_hreport,_souvenir240)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Patients Qualified for report",
      char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_patname = f8 WITH noconstant(0.0), private
   DECLARE drawheight_medordered = f8 WITH noconstant(0.0), private
   DECLARE drawheight_ordstatus = f8 WITH noconstant(0.0), private
   DECLARE drawheight_dis_vfc = f8 WITH noconstant(0.0), private
   DECLARE __patname = vc WITH noconstant(build2(ptname,char(0))), protect
   DECLARE __medordered = vc WITH noconstant(build2(med,char(0))), protect
   DECLARE __ordstatus = vc WITH noconstant(build2(status,char(0))), protect
   DECLARE __dis_vfc = vc WITH noconstant(build2(trim(vaccine->list[x].vfc_value,3),char(0))),
   protect
   IF (bcontinue=0)
    SET _rempatname = 1
    SET _remmedordered = 1
    SET _remordstatus = 1
    SET _remdis_vfc = 1
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
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatname = _rempatname
   IF (_rempatname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatname,((size(
        __patname) - _rempatname)+ 1),__patname)))
    SET drawheight_patname = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatname = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatname,((size(__patname) -
       _rempatname)+ 1),__patname)))))
     SET _rempatname = (_rempatname+ rptsd->m_drawlength)
    ELSE
     SET _rempatname = 0
    ENDIF
    SET growsum = (growsum+ _rempatname)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremmedordered = _remmedordered
   IF (_remmedordered > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmedordered,((size(
        __medordered) - _remmedordered)+ 1),__medordered)))
    SET drawheight_medordered = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmedordered = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmedordered,((size(__medordered) -
       _remmedordered)+ 1),__medordered)))))
     SET _remmedordered = (_remmedordered+ rptsd->m_drawlength)
    ELSE
     SET _remmedordered = 0
    ENDIF
    SET growsum = (growsum+ _remmedordered)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.281)
   SET rptsd->m_width = 0.667
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremordstatus = _remordstatus
   IF (_remordstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remordstatus,((size(
        __ordstatus) - _remordstatus)+ 1),__ordstatus)))
    SET drawheight_ordstatus = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remordstatus = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remordstatus,((size(__ordstatus) -
       _remordstatus)+ 1),__ordstatus)))))
     SET _remordstatus = (_remordstatus+ rptsd->m_drawlength)
    ELSE
     SET _remordstatus = 0
    ENDIF
    SET growsum = (growsum+ _remordstatus)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.417)
   SET rptsd->m_width = 2.083
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdis_vfc = _remdis_vfc
   IF (_remdis_vfc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdis_vfc,((size(
        __dis_vfc) - _remdis_vfc)+ 1),__dis_vfc)))
    SET drawheight_dis_vfc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdis_vfc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdis_vfc,((size(__dis_vfc) -
       _remdis_vfc)+ 1),__dis_vfc)))))
     SET _remdis_vfc = (_remdis_vfc+ rptsd->m_drawlength)
    ELSE
     SET _remdis_vfc = 0
    ENDIF
    SET growsum = (growsum+ _remdis_vfc)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.010)
   SET rptsd->m_width = 0.615
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ptacct,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_patname
   IF (ncalc=rpt_render
    AND _holdrempatname > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempatname,((size(
        __patname) - _holdrempatname)+ 1),__patname)))
   ELSE
    SET _rempatname = _holdrempatname
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 1.448
   SET rptsd->m_height = drawheight_medordered
   IF (ncalc=rpt_render
    AND _holdremmedordered > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmedordered,((size(
        __medordered) - _holdremmedordered)+ 1),__medordered)))
   ELSE
    SET _remmedordered = _holdremmedordered
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.281)
   SET rptsd->m_width = 0.667
   SET rptsd->m_height = drawheight_ordstatus
   IF (ncalc=rpt_render
    AND _holdremordstatus > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremordstatus,((size(
        __ordstatus) - _holdremordstatus)+ 1),__ordstatus)))
   ELSE
    SET _remordstatus = _holdremordstatus
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.073)
   SET rptsd->m_width = 0.802
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(admindt,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.948)
   SET rptsd->m_width = 1.240
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(adminprsnl,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.615)
   SET rptsd->m_width = 0.521
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(roombed,char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.813)
   SET rptsd->m_width = 0.833
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(orddate,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.417)
   SET rptsd->m_width = 2.083
   SET rptsd->m_height = drawheight_dis_vfc
   IF (ncalc=rpt_render
    AND _holdremdis_vfc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdis_vfc,((size(
        __dis_vfc) - _holdremdis_vfc)+ 1),__dis_vfc)))
   ELSE
    SET _remdis_vfc = _holdremdis_vfc
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
 SUBROUTINE footsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.990000), private
   DECLARE __dis_vfc_total = vc WITH noconstant(build2(vaccine->vfc_cnt,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.260
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Ordered:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cs_count,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 1.010)
    SET rptsd->m_width = 0.740
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Given:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(given_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_given,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 1.010)
    SET rptsd->m_width = 1.052
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Given:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_notgiven,char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(notgiven_cnt,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.031)
    SET rptsd->m_x = (offsetx+ 1.021)
    SET rptsd->m_width = 0.917
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Done:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.031)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(notdone_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 1.031)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_notdone,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.271)
    SET rptsd->m_x = (offsetx+ 1.010)
    SET rptsd->m_width = 1.115
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Not Charted:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.271)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordered_count,char(0)))
    SET rptsd->m_y = (offsety+ 1.271)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_ordered,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.510)
    SET rptsd->m_x = (offsetx+ 1.031)
    SET rptsd->m_width = 1.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Cancel/Dc:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.510)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(discon_cnt,char(0)))
    SET rptsd->m_y = (offsety+ 1.510)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(percentage_dc,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.729)
    SET rptsd->m_x = (offsetx+ 1.031)
    SET rptsd->m_width = 1.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total VFC:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.729)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dis_vfc_total)
    SET rptsd->m_y = (offsety+ 1.729)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_percentage_vfc,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.157),(offsetx+ 10.489),(offsety
     + 0.157))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
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
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (ms_continue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("End of Report",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 7.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Run Date:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 8.042)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.094),(offsetx+ 10.479),(offsety
     + 0.094))
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 9.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_HEPB_PEDS"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.25
   SET rptreport->m_marginright = 0.25
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
   SET rptfont->m_recsize = 50
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
   SET rptfont->m_fontname = rpt_souvenir
   SET rptfont->m_pointsize = 24
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_off
   SET _souvenir240 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 8
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
 SET sectionheader = "Hepatitis B:"
 SET d0 = headsection(rpt_render)
 FOR (x = 1 TO size(vaccine->list,5))
   IF ((vaccine->list[x].eks_catalog_cd IN (mf_hepbpedivac)))
    SET cs_count = (cs_count+ 1)
    SET ptname = substring(1,20,trim(vaccine->list[x].patient_name,3))
    SET ptacct = trim(vaccine->list[x].acct_num,3)
    SET med = trim(vaccine->list[x].new_ordered_as_mnemonic,3)
    IF ((vaccine->list[x].comment > " "))
     SET status = vaccine->list[x].comment
    ELSE
     SET status = vaccine->list[x].status
    ENDIF
    SET admindt = format(vaccine->list[x].new_charted_dt_tm,"@SHORTDATETIME")
    SET orddate = format(vaccine->list[x].new_orig_order_dt_tm,"@SHORTDATETIME")
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
    SET rem_space = (pagesize - (_yoffset+ detailsection(rpt_calcheight,rem_space,becont)))
    IF (detailsection(rpt_calcheight,rem_space,becont) > rem_space)
     SET ms_continue = 1
     SET d0 = footreport(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = headreport(rpt_render)
     SET d0 = headsection(rpt_render)
     SET rem_space = (pagesize - _yoffset)
    ENDIF
    WHILE (becont=1)
      SET ms_continue = 1
      SET d0 = footreport(rpt_render)
      SET d0 = pagebreak(0)
      SET d0 = headreport(rpt_render)
      SET d0 = headsection(rpt_render)
      SET rem_space = (pagesize - _yoffset)
      SET becont = 0
    ENDWHILE
    SET d0 = detailsection(rpt_render,rem_space,becont)
    SET rem_space = (pagesize - _yoffset)
   ENDIF
 ENDFOR
 SET percentage_given = format(((given_cnt * 100)/ cs_count),"###.##%")
 SET percentage_notgiven = format(((notgiven_cnt * 100)/ cs_count),"###.##%")
 SET percentage_notdone = format(((notdone_cnt * 100.00)/ cs_count),"###.##%")
 SET percentage_ordered = format(((ordered_count * 100.00)/ cs_count),"###.##%")
 SET percentage_dc = format(((discon_cnt * 100.00)/ cs_count),"###.##%")
 SET ms_percentage_vfc = format(((vaccine->vfc_cnt * 100.00)/ cs_count),"###.##%")
 IF (( $TOTAL="YES")
  AND cs_count > 0)
  IF ((rem_space < (footsection(rpt_calcheight)+ footreport(rpt_calcheight))))
   SET _yoffset = (pagesize - footreport(rpt_calcheight))
   SET ms_continue = 1
   SET d0 = footreport(rpt_render)
   SET d0 = pagebreak(0)
   SET d0 = headreport(rpt_render)
  ENDIF
  SET d0 = footsection(rpt_render)
 ENDIF
 SET d0 = no_data_found(rpt_render)
 SET ms_continue = 0
 SET d0 = footreport(rpt_render)
 SET d0 = finalizereport(value( $OUTDEV))
END GO
