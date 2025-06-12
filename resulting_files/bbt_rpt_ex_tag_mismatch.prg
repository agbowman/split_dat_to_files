CREATE PROGRAM bbt_rpt_ex_tag_mismatch
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD captions(
   1 bb_exception = vc
   1 time = vc
   1 as_of_date = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 product_number = vc
   1 aborh = vc
   1 name = vc
   1 physician = vc
   1 expired = vc
   1 xmd = vc
   1 accession_number = vc
   1 product_type = vc
   1 unit = vc
   1 patient = vc
   1 alias = vc
   1 dispd = vc
   1 reason = vc
   1 tech = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 xm = vc
   1 emergency_dispensed = vc
   1 trans_reqs = vc
   1 dispensed_existing = vc
   1 product_nbr = vc
   1 patient_antibodies = vc
   1 product_antigens = vc
   1 date = vc
   1 validation_aborh = vc
   1 new_time = vc
   1 accession = vc
   1 previous = vc
   1 resulted = vc
   1 current = vc
   1 mrn = vc
   1 heading = vc
   1 accession_head = vc
   1 reason_head = vc
   1 patient_name = vc
   1 accession_nbr = vc
   1 dt_tm = vc
   1 exceptions = vc
   1 reason_for_override = vc
   1 products_xmd = vc
   1 type = vc
   1 xmd_dt_tm = vc
   1 xm_expire_dt_tm = vc
   1 dispensed_dt_tm = vc
   1 transfused_dt_tm = vc
   1 prod_attributes = vc
   1 all = vc
   1 mod_d = vc
   1 collected_dt_tm = vc
   1 prep_hours = vc
   1 mod_option = vc
   1 orig_product = vc
   1 new_product = vc
   1 default_exp = vc
   1 new_expire = vc
   1 tech = vc
   1 not_on_file = vc
   1 unit_abo = vc
   1 patient_abo = vc
   1 procedure = vc
   1 orderable = vc
   1 units = vc
   1 guideline = vc
   1 requested = vc
   1 approved = vc
   1 service_resource = vc
   1 nt_required = vc
   1 ts_only = vc
   1 none = vc
   1 results = vc
   1 verified = vc
   1 datetime = vc
   1 specimen = vc
   1 expiration = vc
   1 dob = vc
   1 override_reason = vc
   1 new_specimen = vc
   1 override = vc
   1 required_date = vc
   1 orderables = vc
   1 adjusted = vc
   1 collected = vc
   1 xm_expiration_dt_tm = vc
   1 not_adjusted = vc
   1 facility = vc
   1 updated_to = vc
   1 crossmatched = vc
   1 state = vc
   1 dispensed = vc
   1 patient_mrn = vc
   1 foot_note = vc
   1 product_order = vc
   1 ordering_physician = vc
   1 no_prod_order = vc
   1 patient_location = vc
   1 serial_number = vc
   1 label_product_number = vc
   1 tag_product_number = vc
   1 info_not_found = vc
 )
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE tagmismatch_var = f8 WITH constant(uar_get_code_by("MEANING",14072,"TAGMISMATCH")), protect
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE get_tag_mismatch_exceptions(dummy) = null WITH protect
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
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
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
 DECLARE _remlabel_prd_num = i4 WITH noconstant(1), protect
 DECLARE _remlabel_prd_typ = i4 WITH noconstant(1), protect
 DECLARE _remtag_prd_num = i4 WITH noconstant(1), protect
 DECLARE _remtag_prd_typ = i4 WITH noconstant(1), protect
 DECLARE _rempat_name = i4 WITH noconstant(1), protect
 DECLARE _rempat_loc = i4 WITH noconstant(1), protect
 DECLARE _remphysician = i4 WITH noconstant(1), protect
 DECLARE _remreason = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _courier70 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s2c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c16734144 = i4 WITH noconstant(0), protect
 SUBROUTINE get_tag_mismatch_exceptions(dummy)
   SELECT INTO "NL:"
    bbe.exception_id, override_reason_disp = uar_get_code_display(bbe.override_reason_cd),
    label_product_nbr_disp = concat(trim(p.product_nbr)," ",trim(p.product_sub_nbr)),
    label_product_type_disp = uar_get_code_display(p.product_cd), tag_product_nbr_disp = concat(trim(
      btve.tag_product_nbr_txt)," ",trim(btve.tag_product_sub_nbr_txt)), dispensed_dt_tm =
    cnvtdatetime(pe.event_dt_tm),
    patient_name = per.name_full_formatted, tech_id = pnl.username, encntr_alias = decode(ea.seq,"Y",
     "N"),
    patient_location = uar_get_code_display(pd.dispense_to_locn_cd), physician = pnl_prov
    .name_full_formatted
    FROM bb_exception bbe,
     bb_tag_verify_excpn btve,
     product_event pe,
     product p,
     person per,
     prsnl pnl,
     encntr_alias ea,
     patient_dispense pd,
     prsnl pnl_prov
    PLAN (bbe
     WHERE bbe.exception_type_cd=tagmismatch_var
      AND bbe.active_ind=1
      AND bbe.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm))
     JOIN (btve
     WHERE btve.exception_id=bbe.exception_id)
     JOIN (pe
     WHERE bbe.product_event_id=pe.product_event_id)
     JOIN (p
     WHERE pe.product_id=p.product_id
      AND (((request->cur_owner_area_cd > 0.0)
      AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
      AND (((request->cur_inv_area_cd > 0.0)
      AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
     JOIN (per
     WHERE pe.person_id=per.person_id)
     JOIN (pnl
     WHERE (pnl.person_id= Outerjoin(bbe.updt_id)) )
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(pe.encntr_id))
      AND (ea.encntr_alias_type_cd= Outerjoin(mrn_var))
      AND (ea.active_ind= Outerjoin(1)) )
     JOIN (pd
     WHERE pe.product_event_id=pd.product_event_id)
     JOIN (pnl_prov
     WHERE (pnl_prov.person_id= Outerjoin(pd.dispense_prov_id)) )
    ORDER BY dispensed_dt_tm, label_product_nbr_disp, bbe.exception_id
    HEAD REPORT
     _d0 = bbe.exception_id, _d1 = override_reason_disp, _d2 = label_product_nbr_disp,
     _d3 = label_product_type_disp, _d4 = tag_product_nbr_disp, _d5 = dispensed_dt_tm,
     _d6 = patient_name, _d7 = tech_id, _d8 = encntr_alias,
     _d9 = patient_location, _d10 = physician, _fenddetail = (rptreport->m_pageheight - rptreport->
     m_marginbottom),
     _fenddetail -= footpagesection(rpt_calcheight), encntr_alias_disp = fillstring(30," "),
     _fdrawheight = headreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > (rptreport->m_pageheight - rptreport->m_marginbottom)))
      CALL pagebreak(0)
     ENDIF
     dummy_val = headreportsection(rpt_render)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
     beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
     dummy_val = reporttitlesection(rpt_render),
     dummy_val = datetimesection(rpt_render), dummy_val = locationnamesection(rpt_render), dummy_val
      = address1section(rpt_render),
     dummy_val = address2section(rpt_render), dummy_val = address3section(rpt_render), dummy_val =
     address4section(rpt_render),
     dummy_val = addresscitystatesection(rpt_render), dummy_val = addresscountrysection(rpt_render),
     dummy_val = headpagesection(rpt_render)
    HEAD dispensed_dt_tm
     row + 0
    HEAD label_product_nbr_disp
     row + 0
    HEAD bbe.exception_id
     _fdrawheight = headbbe_exception_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = headbbe_exception_idsection(rpt_render)
    DETAIL
     IF (bbe.exception_id > 0)
      datafoundflag = true
     ENDIF
     IF (encntr_alias="Y")
      encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      encntr_alias_disp = captions->not_on_file
     ENDIF
     IF (btve.tag_product_type_cd > 0)
      tag_product_type_disp = uar_get_code_display(btve.tag_product_type_cd)
     ELSE
      tag_product_type_disp = captions->not_on_file
     ENDIF
     _bcontdetailsection = 0, bfirsttime = 1
     WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailsection=0)
        BREAK
       ENDIF
       dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection), bfirsttime
        = 0
     ENDWHILE
    FOOT  bbe.exception_id
     _fdrawheight = footbbe_exception_idsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = footbbe_exception_idsection(rpt_render)
    FOOT  label_product_nbr_disp
     row + 0
    FOOT  dispensed_dt_tm
     row + 0
    FOOT PAGE
     _yhold = _yoffset, _yoffset = _fenddetail, dummy_val = footpagesection(rpt_render),
     _yoffset = _yhold
    FOOT REPORT
     _fdrawheight = footreportsection(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      CALL pagebreak(0)
     ENDIF
     dummy_val = footreportsection(rpt_render)
   ;end select
 END ;Subroutine
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
 SUBROUTINE (headreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.050000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (reporttitlesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = reporttitlesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (reporttitlesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __captions__title = vc WITH noconstant(build2(captions->bb_exception,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 3.509
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__captions__title)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (datetimesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = datetimesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (datetimesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __cap_time = vc WITH noconstant(build2(captions->time,char(0))), protect
   DECLARE __time = vc WITH noconstant(build2(format(curtime,"@TIMENOSECONDS;;M"),char(0))), protect
   DECLARE __cap_asofdate = vc WITH noconstant(build2(captions->as_of_date,char(0))), protect
   DECLARE __asofdate = vc WITH noconstant(build2(format(curdate,"@DATECONDENSED;;d"),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 5.559)
    SET rptsd->m_width = 0.709
    SET rptsd->m_height = 0.225
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_time)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 6.559)
    SET rptsd->m_width = 0.709
    SET rptsd->m_height = 0.225
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__time)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.184)
    SET rptsd->m_x = (offsetx+ 5.559)
    SET rptsd->m_width = 0.709
    SET rptsd->m_height = 0.225
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_asofdate)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdleftborder
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.184)
    SET rptsd->m_x = (offsetx+ 6.559)
    SET rptsd->m_width = 0.709
    SET rptsd->m_height = 0.225
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__asofdate)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (locationnamesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = locationnamesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (locationnamesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_name,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (address1section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = address1sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (address1sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_address1 != " "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_address1 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_address1,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (address2section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = address2sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (address2sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_address2 != " "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_address2 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_address2,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (address3section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = address3sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (address3sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_address3 != " "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.876
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_address3 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_address3,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (address4section(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = address4sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (address4sectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_address4 != " "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_address4 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_address4,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (addresscitystatesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = addresscitystatesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (addresscitystatesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_citystatezip != ",   "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_citystatezip != ",   ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_citystatezip,char(0)
       ))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (addresscountrysection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = addresscountrysectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (addresscountrysectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF ( NOT (sub_get_location_country != " "))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.184)
    SET rptsd->m_width = 2.242
    SET rptsd->m_height = 0.167
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    IF (sub_get_location_country != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(sub_get_location_country,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.270000), private
   DECLARE __cap_bb_owner = vc WITH noconstant(build2(captions->bb_owner,char(0))), protect
   DECLARE __cap_inv_area = vc WITH noconstant(build2(captions->inventory_area,char(0))), protect
   DECLARE __cap_beg_date = vc WITH noconstant(build2(captions->beg_date,char(0))), protect
   DECLARE __cap_end_date = vc WITH noconstant(build2(captions->end_date,char(0))), protect
   DECLARE __beg_date = vc WITH noconstant(build2(format(beg_dt_tm,"@DATECONDENSED;;d"),char(0))),
   protect
   DECLARE __beg_time = vc WITH noconstant(build2(format(beg_dt_tm,"@TIMENOSECONDS;;M"),char(0))),
   protect
   DECLARE __end_dt = vc WITH noconstant(build2(format(end_dt_tm,"@DATECONDENSED;;d"),char(0))),
   protect
   DECLARE __end_tm = vc WITH noconstant(build2(format(end_dt_tm,"@TIMENOSECONDS;;M"),char(0))),
   protect
   DECLARE __cap_dispd = vc WITH noconstant(build2(captions->dispd,char(0))), protect
   DECLARE __cap_label_product_number = vc WITH noconstant(build2(captions->label_product_number,char
     (0))), protect
   DECLARE __cap_product_type = vc WITH noconstant(build2(captions->product_type,char(0))), protect
   DECLARE __cap_tag_product_number = vc WITH noconstant(build2(captions->tag_product_number,char(0))
    ), protect
   DECLARE __cap_product_type6 = vc WITH noconstant(build2(captions->product_type,char(0))), protect
   DECLARE __cap_pat_name = vc WITH noconstant(build2(captions->patient_name,char(0))), protect
   DECLARE __cap_alias = vc WITH noconstant(build2(captions->alias,char(0))), protect
   DECLARE __cap_pat_loc = vc WITH noconstant(build2(captions->patient_location,char(0))), protect
   DECLARE __cap_phys = vc WITH noconstant(build2(captions->physician,char(0))), protect
   DECLARE __cap_tech = vc WITH noconstant(build2(captions->tech,char(0))), protect
   DECLARE __cap_reason = vc WITH noconstant(build2(captions->reason,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.242
    SET rptsd->m_height = 0.209
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_bb_owner)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.442)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.242
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_inv_area)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.442)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 1.242
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cur_inv_area_disp,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 0.984
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_beg_date)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_end_date)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 1.834)
    SET rptsd->m_width = 0.809
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__beg_date)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__beg_time)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 5.059)
    SET rptsd->m_width = 0.634
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__end_dt)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.934)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__end_tm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 1.242
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(cur_owner_area_disp,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.042
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exception_disp,char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_dispd)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_label_product_number)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_product_type)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 2.209)
    SET rptsd->m_width = 1.309
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_tag_product_number)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.867
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_product_type6)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 3.692)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_pat_name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 1.050
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_alias)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 4.567)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_pat_loc)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.509)
    SET rptsd->m_x = (offsetx+ 5.634)
    SET rptsd->m_width = 0.809
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_phys)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.500)
    SET rptsd->m_x = (offsetx+ 6.750)
    SET rptsd->m_width = 0.684
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_tech)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 5.692)
    SET rptsd->m_width = 0.809
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_reason)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 2.046),(offsetx+ 0.559),(offsety+
     2.046))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.809),(offsety+ 2.046),(offsetx+ 2.118),(offsety+
     2.046))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.684),(offsety+ 2.046),(offsetx+ 4.434),(offsety+
     2.046))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.251),(offsety+ 2.046),(offsetx+ 3.559),(offsety+
     2.046))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.692),(offsety+ 2.046),(offsetx+ 6.501),(offsety+
     2.046))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.750),(offsety+ 2.037),(offsetx+ 7.434),(offsety+
     2.037))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.625),(offsety+ 2.046),(offsetx+ 5.501),(offsety+
     2.046))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (headbbe_exception_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headbbe_exception_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (headbbe_exception_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.050000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.680000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_prd_num = f8 WITH noconstant(0.0), private
   DECLARE drawheight_label_prd_typ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tag_prd_num = f8 WITH noconstant(0.0), private
   DECLARE drawheight_tag_prd_typ = f8 WITH noconstant(0.0), private
   DECLARE drawheight_pat_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_pat_loc = f8 WITH noconstant(0.0), private
   DECLARE drawheight_physician = f8 WITH noconstant(0.0), private
   DECLARE drawheight_reason = f8 WITH noconstant(0.0), private
   DECLARE __dispd_dt_tm = vc WITH noconstant(build2(format(dispensed_dt_tm,"@DATECONDENSED;;d"),char
     (0))), protect
   DECLARE __label_prd_num = vc WITH noconstant(build2(label_product_nbr_disp,char(0))), protect
   DECLARE __label_prd_typ = vc WITH noconstant(build2(label_product_type_disp,char(0))), protect
   DECLARE __tag_prd_num = vc WITH noconstant(build2(tag_product_nbr_disp,char(0))), protect
   DECLARE __tag_prd_typ = vc WITH noconstant(build2(tag_product_type_disp,char(0))), protect
   DECLARE __pat_name = vc WITH noconstant(build2(patient_name,char(0))), protect
   DECLARE __pat_loc = vc WITH noconstant(build2(patient_location,char(0))), protect
   DECLARE __physician = vc WITH noconstant(build2(physician,char(0))), protect
   DECLARE __reason = vc WITH noconstant(build2(override_reason_disp,char(0))), protect
   IF ( NOT (bbe.exception_id > 0))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_prd_num = 1
    SET _remlabel_prd_typ = 1
    SET _remtag_prd_num = 1
    SET _remtag_prd_typ = 1
    SET _rempat_name = 1
    SET _rempat_loc = 1
    SET _remphysician = 1
    SET _remreason = 1
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
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 1.309
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_courier70)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_prd_num = _remlabel_prd_num
   IF (_remlabel_prd_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_prd_num,((size(
        __label_prd_num) - _remlabel_prd_num)+ 1),__label_prd_num)))
    SET drawheight_label_prd_num = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_prd_num = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_prd_num,((size(__label_prd_num)
        - _remlabel_prd_num)+ 1),__label_prd_num)))))
     SET _remlabel_prd_num += rptsd->m_drawlength
    ELSE
     SET _remlabel_prd_num = 0
    ENDIF
    SET growsum += _remlabel_prd_num
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.809)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16734144)
   SET _holdremlabel_prd_typ = _remlabel_prd_typ
   IF (_remlabel_prd_typ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_prd_typ,((size(
        __label_prd_typ) - _remlabel_prd_typ)+ 1),__label_prd_typ)))
    SET drawheight_label_prd_typ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_prd_typ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_prd_typ,((size(__label_prd_typ)
        - _remlabel_prd_typ)+ 1),__label_prd_typ)))))
     SET _remlabel_prd_typ += rptsd->m_drawlength
    ELSE
     SET _remlabel_prd_typ = 0
    ENDIF
    SET growsum += _remlabel_prd_typ
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.251)
   SET rptsd->m_width = 1.309
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremtag_prd_num = _remtag_prd_num
   IF (_remtag_prd_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtag_prd_num,((size(
        __tag_prd_num) - _remtag_prd_num)+ 1),__tag_prd_num)))
    SET drawheight_tag_prd_num = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtag_prd_num = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtag_prd_num,((size(__tag_prd_num) -
       _remtag_prd_num)+ 1),__tag_prd_num)))))
     SET _remtag_prd_num += rptsd->m_drawlength
    ELSE
     SET _remtag_prd_num = 0
    ENDIF
    SET growsum += _remtag_prd_num
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.251)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremtag_prd_typ = _remtag_prd_typ
   IF (_remtag_prd_typ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtag_prd_typ,((size(
        __tag_prd_typ) - _remtag_prd_typ)+ 1),__tag_prd_typ)))
    SET drawheight_tag_prd_typ = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remtag_prd_typ = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtag_prd_typ,((size(__tag_prd_typ) -
       _remtag_prd_typ)+ 1),__tag_prd_typ)))))
     SET _remtag_prd_typ += rptsd->m_drawlength
    ELSE
     SET _remtag_prd_typ = 0
    ENDIF
    SET growsum += _remtag_prd_typ
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.692)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempat_name = _rempat_name
   IF (_rempat_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempat_name,((size(
        __pat_name) - _rempat_name)+ 1),__pat_name)))
    SET drawheight_pat_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempat_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempat_name,((size(__pat_name) -
       _rempat_name)+ 1),__pat_name)))))
     SET _rempat_name += rptsd->m_drawlength
    ELSE
     SET _rempat_name = 0
    ENDIF
    SET growsum += _rempat_name
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.625)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdrempat_loc = _rempat_loc
   IF (_rempat_loc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempat_loc,((size(
        __pat_loc) - _rempat_loc)+ 1),__pat_loc)))
    SET drawheight_pat_loc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempat_loc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempat_loc,((size(__pat_loc) -
       _rempat_loc)+ 1),__pat_loc)))))
     SET _rempat_loc += rptsd->m_drawlength
    ELSE
     SET _rempat_loc = 0
    ENDIF
    SET growsum += _rempat_loc
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.809
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremphysician = _remphysician
   IF (_remphysician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remphysician,((size(
        __physician) - _remphysician)+ 1),__physician)))
    SET drawheight_physician = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remphysician = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remphysician,((size(__physician) -
       _remphysician)+ 1),__physician)))))
     SET _remphysician += rptsd->m_drawlength
    ELSE
     SET _remphysician = 0
    ENDIF
    SET growsum += _remphysician
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.809
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremreason = _remreason
   IF (_remreason > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remreason,((size(__reason
        ) - _remreason)+ 1),__reason)))
    SET drawheight_reason = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remreason = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remreason,((size(__reason) - _remreason)
       + 1),__reason)))))
     SET _remreason += rptsd->m_drawlength
    ELSE
     SET _remreason = 0
    ENDIF
    SET growsum += _remreason
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.184)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 0.559
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dispd_dt_tm)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.750)
   SET rptsd->m_width = 1.309
   SET rptsd->m_height = drawheight_label_prd_num
   IF (ncalc=rpt_render
    AND _holdremlabel_prd_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_prd_num,((
       size(__label_prd_num) - _holdremlabel_prd_num)+ 1),__label_prd_num)))
   ELSE
    SET _remlabel_prd_num = _holdremlabel_prd_num
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.809)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_label_prd_typ
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c16734144)
   IF (ncalc=rpt_render
    AND _holdremlabel_prd_typ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_prd_typ,((
       size(__label_prd_typ) - _holdremlabel_prd_typ)+ 1),__label_prd_typ)))
   ELSE
    SET _remlabel_prd_typ = _holdremlabel_prd_typ
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.251)
   SET rptsd->m_width = 1.309
   SET rptsd->m_height = drawheight_tag_prd_num
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _holdremtag_prd_num > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtag_prd_num,((size
       (__tag_prd_num) - _holdremtag_prd_num)+ 1),__tag_prd_num)))
   ELSE
    SET _remtag_prd_num = _holdremtag_prd_num
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.251)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_tag_prd_typ
   IF (ncalc=rpt_render
    AND _holdremtag_prd_typ > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtag_prd_typ,((size
       (__tag_prd_typ) - _holdremtag_prd_typ)+ 1),__tag_prd_typ)))
   ELSE
    SET _remtag_prd_typ = _holdremtag_prd_typ
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.692)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_pat_name
   IF (ncalc=rpt_render
    AND _holdrempat_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempat_name,((size(
        __pat_name) - _holdrempat_name)+ 1),__pat_name)))
   ELSE
    SET _rempat_name = _holdrempat_name
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.376)
   SET rptsd->m_x = (offsetx+ 3.692)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(encntr_alias_disp,char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 4.625)
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = drawheight_pat_loc
   IF (ncalc=rpt_render
    AND _holdrempat_loc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempat_loc,((size(
        __pat_loc) - _holdrempat_loc)+ 1),__pat_loc)))
   ELSE
    SET _rempat_loc = _holdrempat_loc
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.126)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.809
   SET rptsd->m_height = drawheight_physician
   IF (ncalc=rpt_render
    AND _holdremphysician > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremphysician,((size(
        __physician) - _holdremphysician)+ 1),__physician)))
   ELSE
    SET _remphysician = _holdremphysician
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.376)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.750)
   SET rptsd->m_width = 0.809
   SET rptsd->m_height = drawheight_reason
   IF (ncalc=rpt_render
    AND _holdremreason > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremreason,((size(
        __reason) - _holdremreason)+ 1),__reason)))
   ELSE
    SET _remreason = _holdremreason
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.126)
   SET rptsd->m_x = (offsetx+ 6.750)
   SET rptsd->m_width = 0.692
   SET rptsd->m_height = 0.167
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tech_id,char(0)))
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
 SUBROUTINE (footbbe_exception_idsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footbbe_exception_idsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footbbe_exception_idsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.050000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footpagesection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footpagesectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footpagesectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.520000), private
   DECLARE __cap_report_id = vc WITH noconstant(build2(captions->report_id,char(0))), protect
   DECLARE __cap_page = vc WITH noconstant(build2(captions->page_no,char(0))), protect
   DECLARE __pageno = vc WITH noconstant(build2(format(curpage,"###"),char(0))), protect
   DECLARE __cap_printed = vc WITH noconstant(build2(captions->printed,char(0))), protect
   DECLARE __pr_date = vc WITH noconstant(build2(format(curdate,"@DATECONDENSED;;d"),char(0))),
   protect
   DECLARE __pr_time = vc WITH noconstant(build2(format(curtime,"@TIMENOSECONDS;;M"),char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.017)
    SET rptsd->m_width = 2.234
    SET rptsd->m_height = 0.234
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_report_id)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 2.734)
    SET rptsd->m_width = 0.517
    SET rptsd->m_height = 0.217
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_page)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 3.367)
    SET rptsd->m_width = 0.492
    SET rptsd->m_height = 0.225
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pageno)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.559
    SET rptsd->m_height = 0.217
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_printed)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 5.934)
    SET rptsd->m_width = 0.684
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pr_date)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 6.742)
    SET rptsd->m_width = 0.517
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pr_time)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ - (0.008)),(offsety+ 0.162),(offsetx+ 7.409),(
     offsety+ 0.162))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (footreportsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (footreportsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   DECLARE __cap_end_of_report = vc WITH noconstant(build2(captions->end_of_report,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 2.317)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.309
    SET _oldfont = uar_rptsetfont(_hreport,_courier70)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cap_end_of_report)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BBT_RPT_EX_TAG_MISMATCH"
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
   SET rptfont->m_fontname = rpt_courier
   SET rptfont->m_pointsize = 7
   SET _courier70 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 2
   SET _pen14s2c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = uar_rptencodecolor(192,87,255)
   SET _pen14s0c16734144 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 CALL get_tag_mismatch_exceptions(0)
 CALL finalizereport(_sendto)
END GO
