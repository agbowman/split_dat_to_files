CREATE PROGRAM bhs_rpt_dvt_prophylaxis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Output Type" = "excel",
  "Facility" = value(673936.00),
  "Nurse Unit" = value(999999,511345058.00,634529558.00,634532070.00,473916584.00,
   473916693.00)
  WITH outdev, s_output_type, f_facility_cd,
  f_nurse_unit_cd
 FREE RECORD data
 RECORD data(
   1 status = c1
   1 pat_cnt = i4
   1 enc_cnt = i4
   1 patients[*]
     2 name_full_formatted = vc
     2 fin = vc
     2 admit_dt_tm = f8
     2 loc_nurse_unit = c40
     2 attending_md_name = vc
   1 orders[*]
     2 encounter_id = f8
     2 order_id = f8
     2 order_dt_tm = vc
     2 catalog_cd = vc
     2 order_mnem = vc
 ) WITH protect
 SUBROUTINE pgbreak(dummy)
   SET d0 = pagebreak(dummy)
   SET d0 = headpagesection(rpt_render)
   SET d0 = columnheadersection(rpt_render)
 END ;Subroutine
 DECLARE ms_output_type = vc WITH protect, constant(trim(cnvtlower( $S_OUTPUT_TYPE),3))
 DECLARE mf_fin = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_os_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_attending_phys_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_comp_boots_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "PNEUMATICCOMPRESSIONBOOTS"))
 DECLARE mf_heparin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"HEPARIN"))
 DECLARE mf_enoxaparin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENOXAPARIN"))
 DECLARE mf_warfarin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"WARFARIN"))
 DECLARE mf_apixaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"APIXABAN"))
 DECLARE mf_dabigatran_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DABIGATRAN"))
 DECLARE mf_rivaroxaban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"RIVAROXABAN"
   ))
 DECLARE mf_fondaparinux_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FONDAPARINUX"))
 DECLARE mf_bivalirudin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BIVALIRUDIN"
   ))
 DECLARE mf_argatroban_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ARGATROBAN50MGIN50MLNACL"))
 DECLARE mf_argatrobansrd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ARGATROBAN50MGIN50MLNACLESRD"))
 DECLARE mf_dextrose5inwater_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DEXTROSE5INWATER"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE mf_facility_cd = f8 WITH protect, noconstant( $F_FACILITY_CD)
 DECLARE mf_nurse_unit_cd = f8 WITH protect, noconstant(0)
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ms_facility_p = vc WITH protect, noconstant("")
 DECLARE ms_nurse_unit_p = vc WITH protect, noconstant("")
 DECLARE pdate = vc WITH protect, noconstant(" ")
 DECLARE pfacility = vc WITH protect, noconstant(" ")
 DECLARE pnurseunit = vc WITH protect, noconstant(" ")
 DECLARE plocnurseunit = vc WITH protect, noconstant(" ")
 DECLARE pnamefullformatted = vc WITH protect, noconstant(" ")
 DECLARE pfin = vc WITH protect, noconstant(" ")
 DECLARE padmitdttm = vc WITH protect, noconstant(" ")
 DECLARE pattendingmdname = vc WITH protect, noconstant(" ")
 SET data->status = "F"
 SET ms_item_list = reflect(parameter(3,0))
 IF (( $F_FACILITY_CD=999999))
  SET ms_facility_p = "1=1"
  SET pfacility = "<all>"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_facility_p = build2("ed.loc_facility_cd in (",parameter(3,ml_loop))
     SET pfacility = uar_get_code_display(parameter(3,ml_loop))
    ELSE
     SET ms_facility_p = build2(ms_facility_p,",",parameter(3,ml_loop))
     SET pfacility = build2(pfacility,", ",uar_get_code_display(parameter(3,ml_loop)))
    ENDIF
  ENDFOR
  SET ms_facility_p = concat(ms_facility_p,")")
 ELSEIF (substring(1,1,ms_item_list)="F")
  SET ms_facility_p = build2("ed.loc_facility_cd = ",parameter(3,0))
  SET pfacility = uar_get_code_display( $F_FACILITY_CD)
 ENDIF
 SET ms_item_list = reflect(parameter(4,0))
 IF (( $F_NURSE_UNIT_CD=999999))
  CALL echo("nurse unit any")
  SET ms_nurse_unit_p = "1=1"
  SET pnurseunit = "<all>"
 ELSEIF (substring(1,1,ms_item_list)="L")
  CALL echo("nurse unit list")
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (ml_loop = 1 TO ml_cnt)
    IF (ml_loop=1)
     SET ms_nurse_unit_p = build2("ed.loc_nurse_unit_cd in (",parameter(4,ml_loop))
     SET pnurseunit = uar_get_code_display(parameter(4,ml_loop))
    ELSE
     SET ms_nurse_unit_p = build2(ms_nurse_unit_p,",",parameter(4,ml_loop))
     SET pnurseunit = build2(pnurseunit,", ",uar_get_code_display(parameter(4,ml_loop)))
    ENDIF
  ENDFOR
  SET ms_nurse_unit_p = concat(ms_nurse_unit_p,")")
  CALL echo(build2("ms_nurse_unit_p: ",ms_nurse_unit_p))
 ELSE
  SET ms_nurse_unit_p = concat("ed.loc_nurse_unit_cd = ",cnvtstring( $F_NURSE_UNIT_CD))
  SET pnurseunit = uar_get_code_display( $F_NURSE_UNIT_CD)
 ENDIF
 CALL echo("select 1")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   orders o,
   person p
  PLAN (ed
   WHERE parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND ed.active_ind=1
    AND ed.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null)
   JOIN (o
   WHERE o.encntr_id=ed.encntr_id
    AND o.catalog_cd IN (mf_comp_boots_cd, mf_heparin_cd, mf_enoxaparin_cd, mf_warfarin_cd,
   mf_apixaban_cd,
   mf_dabigatran_cd, mf_rivaroxaban_cd, mf_fondaparinux_cd, mf_bivalirudin_cd, mf_argatroban_cd,
   mf_argatrobansrd_cd, mf_dextrose5inwater_cd)
    AND o.order_status_cd=mf_os_ordered_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
  HEAD REPORT
   data->enc_cnt = 0
  DETAIL
   data->enc_cnt += 1
   IF ((size(data->orders,5) < data->enc_cnt))
    stat = alterlist(data->orders,(data->enc_cnt+ 100))
   ENDIF
   data->orders[data->enc_cnt].encounter_id = ed.encntr_id, data->orders[data->enc_cnt].order_id = o
   .order_id, data->orders[data->enc_cnt].catalog_cd = trim(uar_get_code_display(o.catalog_cd),3),
   data->orders[data->enc_cnt].order_dt_tm = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d"), data->
   orders[data->enc_cnt].order_mnem = trim(o.ordered_as_mnemonic,3),
   CALL echo(build2("name: ",p.name_full_formatted))
  FOOT REPORT
   stat = alterlist(data->orders,data->enc_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(data)
 CALL echo("select 2")
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   person p,
   encntr_prsnl_reltn epr,
   prsnl pr,
   encntr_alias ea
  PLAN (ed
   WHERE parser(ms_facility_p)
    AND parser(ms_nurse_unit_p)
    AND ed.active_ind=1
    AND ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND  NOT (expand(ml_cnt,1,data->enc_cnt,ed.encntr_id,data->orders[ml_cnt].encounter_id)))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null)
   JOIN (p
   WHERE p.person_id=ed.person_id)
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ea.encntr_alias_type_cd=mf_fin
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (epr
   WHERE (epr.encntr_id= Outerjoin(ed.encntr_id))
    AND (epr.active_ind= Outerjoin(1))
    AND (epr.encntr_prsnl_r_cd= Outerjoin(mf_attending_phys_cd))
    AND (epr.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(epr.prsnl_person_id)) )
  ORDER BY uar_get_code_display(ed.loc_nurse_unit_cd), e.reg_dt_tm, p.name_last
  DETAIL
   data->pat_cnt += 1
   IF ((size(data->patients,5) < data->pat_cnt))
    CALL alterlist(data->patients,(data->pat_cnt+ 100))
   ENDIF
   data->patients[data->pat_cnt].name_full_formatted = trim(p.name_full_formatted), data->patients[
   data->pat_cnt].admit_dt_tm = e.reg_dt_tm, data->patients[data->pat_cnt].loc_nurse_unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd)),
   data->patients[data->pat_cnt].name_full_formatted = trim(p.name_full_formatted), data->patients[
   data->pat_cnt].fin = trim(ea.alias), data->patients[data->pat_cnt].attending_md_name = trim(pr
    .name_full_formatted)
  FOOT REPORT
   CALL alterlist(data->patients,data->pat_cnt)
  WITH nocounter, expand = 1
 ;end select
 IF (curqual=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (ms_output_type="excel")
  SELECT INTO value( $OUTDEV)
   nurse_unit = substring(1,50,data->patients[d.seq].loc_nurse_unit), patient_name = substring(1,75,
    data->patients[d.seq].name_full_formatted), fin = data->patients[d.seq].fin,
   admit_dt_tm = format(data->patients[d.seq].admit_dt_tm,"MM/DD/YY HH:MM;;D"), attending_phys =
   substring(1,100,data->patients[d.seq].attending_md_name)
   FROM (dummyt d  WITH seq = value(size(data->patients,5)))
   PLAN (d)
   ORDER BY d.seq
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
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
  DECLARE _times180 = i4 WITH noconstant(0), protect
  DECLARE _times60 = i4 WITH noconstant(0), protect
  DECLARE _times140 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _times110 = i4 WITH noconstant(0), protect
  DECLARE _times11b0 = i4 WITH noconstant(0), protect
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
     SET rptsd->m_flags = 512
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 6.750)
     SET rptsd->m_width = 1.063
     SET rptsd->m_height = 0.178
     SET _oldfont = uar_rptsetfont(_hreport,_times100)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.011)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 1.938
     SET rptsd->m_height = 0.126
     SET _dummyfont = uar_rptsetfont(_hreport,_times60)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curprog,char(0)))
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
    DECLARE sectionheight = f8 WITH noconstant(1.650000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 2.251)
     SET rptsd->m_width = 2.990
     SET rptsd->m_height = 0.313
     SET _oldfont = uar_rptsetfont(_hreport,_times180)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DVT Prophylaxis Report",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 1.000)
     SET rptsd->m_x = (offsetx+ 0.938)
     SET rptsd->m_width = 6.500
     SET rptsd->m_height = 0.625
     SET _dummyfont = uar_rptsetfont(_hreport,_times100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pnurseunit,char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 0.938
     SET rptsd->m_height = 0.240
     SET _dummyfont = uar_rptsetfont(_hreport,_times140)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.511)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 0.875
     SET rptsd->m_height = 0.240
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Facility: ",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.563)
     SET rptsd->m_x = (offsetx+ 0.938)
     SET rptsd->m_width = 6.500
     SET rptsd->m_height = 0.365
     SET _dummyfont = uar_rptsetfont(_hreport,_times100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pfacility,char(0)))
     SET rptsd->m_flags = 640
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.063)
     SET rptsd->m_width = 2.063
     SET rptsd->m_height = 0.251
     SET _dummyfont = uar_rptsetfont(_hreport,_times120)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pdate,char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (columnheadersection(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = columnheadersectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (columnheadersectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.570000), private
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.448),(offsetx+ 7.501),(offsety
      + 0.448))
     SET rptsd->m_flags = 1028
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 1.438)
     SET rptsd->m_width = 0.771
     SET rptsd->m_height = 0.376
     SET _oldfont = uar_rptsetfont(_hreport,_times11b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 3.126)
     SET rptsd->m_width = 0.376
     SET rptsd->m_height = 0.376
     SET _dummyfont = uar_rptsetfont(_hreport,_times110)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct No.",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 4.438)
     SET rptsd->m_width = 0.813
     SET rptsd->m_height = 0.376
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date/Time",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 5.938)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.376
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD Name",char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.063)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 0.771
     SET rptsd->m_height = 0.376
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Location",char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE (columnsection(ncalc=i2) =f8 WITH protect)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = columnsectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE (columnsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
    DECLARE sectionheight = f8 WITH noconstant(0.220000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 0.698
     SET rptsd->m_height = 0.126
     SET _oldfont = uar_rptsetfont(_hreport,_times60)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(plocnurseunit,char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 1.438)
     SET rptsd->m_width = 1.063
     SET rptsd->m_height = 0.126
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pnamefullformatted,char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 3.126)
     SET rptsd->m_width = 0.438
     SET rptsd->m_height = 0.126
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pfin,char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 4.438)
     SET rptsd->m_width = 0.563
     SET rptsd->m_height = 0.126
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(padmitdttm,char(0)))
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_y = (offsety+ 0.001)
     SET rptsd->m_x = (offsetx+ 5.948)
     SET rptsd->m_width = 2.053
     SET rptsd->m_height = 0.126
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(pattendingmdname,char(0)))
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 104
    SET rptreport->m_reportname = "BHS_RPT_DVT_PROPHYLAXIS"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
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
    SET rptfont->m_pointsize = 18
    SET _times180 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 14
    SET _times140 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET _times120 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 11
    SET rptfont->m_bold = rpt_on
    SET _times11b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_bold = rpt_off
    SET _times110 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SET d0 = initializereport(0)
  SET pdate = format(cnvtdatetime(curdate,curtime),"MMM-DD-YYYY HH:MM;;D")
  SET d0 = headpagesection(rpt_render)
  SET d0 = headreportsection(rpt_render)
  SET d0 = columnheadersection(rpt_render)
  FOR (ml_cnt = 1 TO value(data->pat_cnt))
    SET plocnurseunit = data->patients[ml_cnt].loc_nurse_unit
    SET pnamefullformatted = data->patients[ml_cnt].name_full_formatted
    SET pfin = data->patients[ml_cnt].fin
    SET padmitdttm = format(data->patients[ml_cnt].admit_dt_tm,"MM/DD/YY HH:MM;;D")
    SET pattendingmdname = data->patients[ml_cnt].attending_md_name
    IF (((_yoffset+ columnsection(rpt_calcheight)) > 10.5))
     SET d0 = pgbreak(1)
    ENDIF
    SET d0 = columnsection(rpt_render)
  ENDFOR
  SET d0 = finalizereport(value( $OUTDEV))
 ENDIF
 SET data->status = "S"
#exit_script
 IF ((data->status != "S"))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "DVT Prophylaxis Report", "{F/1}{CPI/14}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
 CALL echorecord(data)
END GO
