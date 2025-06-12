CREATE PROGRAM apslabellblcl0720_specbc_prd
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD data(
   1 maxlabel = i2
   1 current_dt_tm_string = c8
   1 resrc[1]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 label[*]
       3 worklist_nbr = i4
       3 service_resource_cd = f8
       3 mnemonic = vc
       3 description = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_string = c8
       3 priority_cd = f8
       3 priority_disp = c15
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 case_specimen_tag_disp = c15
       3 case_specimen_tag_seq = i4
       3 cassette_id = f8
       3 cassette_tag_cd = f8
       3 cassette_tag_disp = c15
       3 cassette_tag_seq = i4
       3 cassette_sep_disp = c1
       3 cassette_origin_modifier = c7
       3 slide_id = f8
       3 slide_tag_cd = f8
       3 slide_tag_disp = c15
       3 slide_tag_seq = i4
       3 slide_sep_disp = c1
       3 slide_origin_modifier = c7
       3 spec_blk_sld_tag_disp = c15
       3 spec_blk_tag_disp = c15
       3 blk_sld_tag_disp = c15
       3 prefix_cd = f8
       3 accession_nbr = c21
       3 fmt_accession_nbr = c21
       3 acc_site_pre_yy_nbr = c21
       3 acc_site = c5
       3 acc_pre = c2
       3 acc_yy = c2
       3 acc_yyyy = c4
       3 acc_nbr = c7
       3 case_year = i4
       3 case_number = i4
       3 responsible_pathologist_id = f8
       3 responsible_pathologist_name_full = vc
       3 responsible_pathologist_name_last = vc
       3 responsible_pathologist_initial = c2
       3 responsible_resident_id = f8
       3 responsible_resident_name_full = vc
       3 responsible_resident_name_last = vc
       3 responsible_resident_initial = c2
       3 requesting_physician_id = f8
       3 requesting_physician_name_full = vc
       3 requesting_physician_name_last = vc
       3 case_received_dt_tm = dq8
       3 case_received_dt_tm_string = c8
       3 case_collect_dt_tm = dq8
       3 case_collect_dt_tm_string = c8
       3 mrn_alias = vc
       3 fin_nbr_alias = vc
       3 encntr_id = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 birth_dt_tm_string = c8
       3 deceased_dt_tm = dq8
       3 age = vc
       3 sex_cd = f8
       3 sex_disp = vc
       3 sex_desc = vc
       3 admit_doc_name = vc
       3 admit_doc_name_last = vc
       3 organization_id = f8
       3 loc_bed_cd = f8
       3 loc_bed_disp = c15
       3 loc_building_cd = f8
       3 loc_building_disp = c15
       3 loc_facility_cd = f8
       3 loc_facility_disp = c15
       3 location_cd = f8
       3 location_disp = c15
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = c15
       3 loc_room_cd = f8
       3 loc_room_disp = c15
       3 loc_nurse_room_bed_disp = vc
       3 encntr_type_cd = f8
       3 encntr_type_disp = c15
       3 encntr_type_desc = vc
       3 adequacy_ind = i2
       3 adequacy_string = vc
       3 specimen_cd = f8
       3 specimen_disp = c15
       3 specimen_description = vc
       3 received_fixative_cd = f8
       3 received_fixative_disp = c15
       3 received_fixative_desc = vc
       3 fixative_added_cd = f8
       3 fixative_added_disp = c15
       3 fixative_added_desc = vc
       3 fixative_cd = f8
       3 fixative_disp = c15
       3 fixative_desc = vc
       3 supplemental_tag = c2
       3 pieces = c3
       3 sl_supplemental_tag = c2
       3 stain_task_assay_cd = f8
       3 stain_mnemonic = vc
       3 stain_description = vc
       3 inventory_type = i2
       3 inventory_code = vc
       3 location_code = vc
       3 compartment_code = vc
       3 spec_tracking_loc_disp = vc
       3 compartment_disp = vc
       3 storage_shelf_disp = vc
       3 organization_name = vc
       3 domain = vc
       3 identifier_type = vc
       3 identifier_code = vc
       3 identifier_disp = vc
       3 hopper = vc
       3 cassette_color = vc
       3 generic_field1 = vc
       3 generic_field2 = vc
       3 generic_field3 = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE detailsection(ncalc=i2) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _diotype = i2 WITH noconstant(16), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_zebra), protect
 DECLARE _flmargin = f8 WITH noconstant(0.0), protect
 DECLARE _ftmargin = f8 WITH noconstant(0.0), protect
 DECLARE _flabelwidth = f8 WITH noconstant(0.0), protect
 DECLARE _flabelheight = f8 WITH noconstant(0.0), protect
 DECLARE _frowgutter = f8 WITH noconstant(0.0), protect
 DECLARE _fcolgutter = f8 WITH noconstant(0.0), protect
 DECLARE _nrows = i4 WITH noconstant(0), protect
 DECLARE _ncols = i4 WITH noconstant(0), protect
 DECLARE _default100 = i4 WITH noconstant(0), protect
 DECLARE _default70 = i4 WITH noconstant(0), protect
 DECLARE _default90 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE detailsection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.240000), private
   IF (ncalc=rpt_render)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 0.063),(offsety+ 0.281))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 0.27
    SET rptbce->m_height = 0.27
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bprintinterp = 0
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(barcode_accession,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.928
    SET rptsd->m_height = 0.178
    SET _oldfont = uar_rptsetfont(_hreport,_default90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name,char(0)))
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn,char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 0.917)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin,char(0)))
    SET rptsd->m_flags = 0
    IF (siteprefixcodeon=1)
     SET _fntcond = _default90
    ELSE
     SET _fntcond = _default100
    ENDIF
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.480
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession,char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 1.521)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_default100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_specimen_tag,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.698)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(specimen_description,char(0)))
    SET rptsd->m_y = (offsety+ 0.803)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 1.448
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordering_physician,char(0)))
    SET rptsd->m_y = (offsety+ 0.896)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_collect_dt_tm,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "APSLABELLBLCL0720_SPECBC_PRD"
   SET rptreport->m_pagewidth = 2.00
   SET rptreport->m_pageheight = 1.25
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.00
   SET rptreport->m_marginright = 0.00
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.00
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _default100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _default90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 7
   SET _default70 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE showlabeldata(dummy) = null WITH protect
 SUBROUTINE showlabeldata(ncalc)
   SET _flmargin = rptreport->m_marginleft
   SET _ftmargin = rptreport->m_margintop
   SET _flabelwidth = 2.000000
   SET _flabelheight = 1.250000
   SET _frowgutter = 0.000000
   SET _fcolgutter = 0.000000
   SET _ncols = 1
   SET _nrows = 1
   SELECT
    admit_doctor = trim(substring(1,30,data->resrc[1].label[d1.seq].admit_doc_name),3),
    admit_doctor_lastname = trim(substring(1,30,data->resrc[1].label[d1.seq].admit_doc_name_last),3),
    accession_site_prefix_nbr = nullterm(trim(data->resrc[1].label[d1.seq].acc_site_pre_yy_nbr,3)),
    adequacy = trim(substring(1,15,data->resrc[1].label[d1.seq].adequacy_string),3), age = trim(data
     ->resrc[1].label[d1.seq].age,3), barcode_accession = nullterm(trim(data->resrc[1].label[d1.seq].
      fmt_accession_nbr,3)),
    bed = trim(substring(1,4,data->resrc[1].label[d1.seq].loc_bed_disp),3), birthdate = trim(data->
     resrc[1].label[d1.seq].birth_dt_tm_string,3), block_slide_tag = trim(data->resrc[1].label[d1.seq
     ].blk_sld_tag_disp,3),
    building = trim(substring(1,15,data->resrc[1].label[d1.seq].loc_building_disp),3), cassette_tag
     = trim(data->resrc[1].label[d1.seq].cassette_tag_disp,3), case_collect_dt_tm = trim(data->resrc[
     1].label[d1.seq].case_collect_dt_tm_string,3),
    case_received_dt_tm = trim(data->resrc[1].label[d1.seq].case_received_dt_tm_string,3),
    case_specimen_tag = trim(data->resrc[1].label[d1.seq].case_specimen_tag_disp,3), deceased_dt_tm
     = format(data->resrc[1].label[d1.seq].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D"),
    encounter_type = trim(substring(1,15,data->resrc[1].label[d1.seq].encntr_type_disp),3), facility
     = trim(substring(1,15,data->resrc[1].label[d1.seq].loc_facility_disp),3), fin = trim(data->
     resrc[1].label[d1.seq].fin_nbr_alias,3),
    fixative = trim(substring(1,15,data->resrc[1].label[d1.seq].fixative_disp),3),
    fixative_description = trim(substring(1,15,data->resrc[1].label[d1.seq].fixative_desc),3),
    fixative_added = trim(substring(1,15,data->resrc[1].label[d1.seq].fixative_added_disp),3),
    fixative_added_description = trim(substring(1,15,data->resrc[1].label[d1.seq].fixative_added_desc
      ),3), formatted_accession = nullterm(trim(data->resrc[1].label[d1.seq].fmt_accession_nbr,3)),
    location = trim(substring(1,15,data->resrc[1].label[d1.seq].location_disp),3),
    mnemonic = trim(substring(1,15,data->resrc[1].label[d1.seq].mnemonic),3), mrn = trim(data->resrc[
     1].label[d1.seq].mrn_alias,3), nurse_unit = trim(substring(1,15,data->resrc[1].label[d1.seq].
      loc_nurse_unit_disp),3),
    ordering_physician = trim(substring(1,40,data->resrc[1].label[d1.seq].
      requesting_physician_name_full),3), ordering_physician_lastname = trim(substring(1,40,data->
      resrc[1].label[d1.seq].requesting_physician_name_last),3), organization = trim(substring(1,40,
      data->resrc[1].label[d1.seq].organization_name),3),
    patient_location = trim(data->resrc[1].label[d1.seq].loc_nurse_room_bed_disp,3), patient_name =
    trim(substring(1,40,data->resrc[1].label[d1.seq].name_full_formatted),3), patient_name_last =
    trim(substring(1,40,data->resrc[1].label[d1.seq].name_last),3),
    priority = trim(data->resrc[1].label[d1.seq].priority_disp,3), responsible_pathologist = trim(
     substring(1,40,data->resrc[1].label[d1.seq].responsible_pathologist_name_full),3),
    responsible_pathologist_lastname = trim(substring(1,40,data->resrc[1].label[d1.seq].
      responsible_pathologist_name_last),3),
    responsible_resident = trim(substring(1,40,data->resrc[1].label[d1.seq].
      responsible_resident_name_full),3), responsible_resident_lastname = trim(substring(1,40,data->
      resrc[1].label[d1.seq].responsible_resident_name_last),3), request_dt_tm = trim(data->resrc[1].
     label[d1.seq].request_dt_tm_string,3),
    received_fixative = trim(data->resrc[1].label[d1.seq].received_fixative_disp,3),
    received_fixative_description = trim(data->resrc[1].label[d1.seq].received_fixative_desc,3), room
     = trim(substring(1,6,data->resrc[1].label[d1.seq].loc_room_disp),3),
    sex = trim(data->resrc[1].label[d1.seq].sex_disp,3), slide_tag = trim(data->resrc[1].label[d1.seq
     ].slide_tag_disp,3), specimen_type = trim(substring(1,40,data->resrc[1].label[d1.seq].
      specimen_disp),3),
    specimen_description = trim(substring(1,40,data->resrc[1].label[d1.seq].specimen_description),3),
    specimen_block_slide_tag = trim(data->resrc[1].label[d1.seq].spec_blk_sld_tag_disp,3), stain =
    trim(substring(1,15,data->resrc[1].label[d1.seq].stain_mnemonic),3),
    stain_description = trim(substring(1,15,data->resrc[1].label[d1.seq].stain_description),3),
    siteprefixcodeon =
    IF (issitecodeon=1) issitecodeon
    ELSEIF (issitecodeon=0
     AND cnvtreal(substring(1,5,data->resrc[1].label[d1.seq].accession_nbr)) > 0) 1
    ENDIF
    FROM (dummyt d1  WITH seq = size(data->resrc[1].label,5))
    PLAN (d1)
    HEAD REPORT
     _d0 = barcode_accession, _d1 = case_collect_dt_tm, _d2 = case_specimen_tag,
     _d3 = fin, _d4 = formatted_accession, _d5 = mrn,
     _d6 = ordering_physician, _d7 = patient_name, _d8 = specimen_description,
     _d9 = siteprefixcodeon, x = 0, y = 0
    DETAIL
     IF (y >= _nrows)
      x = 0, y = 0,
      CALL pagebreak(0)
     ENDIF
     _xoffset = ((_flmargin+ (_flabelwidth * x))+ (_fcolgutter * x)), _yoffset = ((_ftmargin+ (
     _flabelheight * y))+ (_frowgutter * y)), dummy_val = detailsection(rpt_render),
     x = (x+ 1)
     IF (x >= _ncols)
      x = 0, y = (y+ 1)
     ENDIF
   ;end select
 END ;Subroutine
#script
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET encounter_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 DECLARE issitecodeon = i2 WITH noconstant(0), protect
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET encounter_alias_type_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET epr_admit_doc_cd = code_value
 SELECT INTO "nl:"
  sitecodelength = a.site_code_length
  FROM accession_setup a
  WHERE a.accession_setup_id=72696.00
   AND a.site_code_length > 0
  DETAIL
   IF (sitecodelength > 0)
    issitecodeon = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (r = 1 TO size(data->resrc,5))
   EXECUTE aps_get__cd_info value(data->resrc[r].service_resource_cd)
   SET data->resrc[r].service_resource_disp = cdinfo->display
   FOR (l = 1 TO size(data->resrc[r].label,5))
     SELECT INTO "nl:"
      ea.encntr_id, fmt_alias = cnvtalias(ea.alias,ea.alias_pool_cd), ea.encntr_alias_type_cd
      FROM encntr_alias ea
      PLAN (ea
       WHERE (data->resrc[r].label[l].encntr_id=ea.encntr_id)
        AND ea.encntr_alias_type_cd IN (mrn_alias_type_cd, encounter_alias_type_cd)
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ea.end_effective_dt_tm=
       null)) )
      HEAD REPORT
       data->resrc[r].label[l].mrn_alias = "Unknown"
      DETAIL
       IF (ea.encntr_alias_type_cd=mrn_alias_type_cd)
        data->resrc[r].label[l].mrn_alias = fmt_alias
       ELSEIF (ea.encntr_alias_type_cd=encounter_alias_type_cd)
        data->resrc[r].label[l].fin_nbr_alias = fmt_alias
       ENDIF
      FOOT REPORT
       CALL echo(build("data->resrc[",r,"].label[",l,"].mrn_alias = ",
        data->resrc[r].label[l].mrn_alias)),
       CALL echo(build("data->resrc[",r,"].label[",l,"].fin_nbr_alias = ",
        data->resrc[r].label[l].fin_nbr_alias))
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      epr.prsnl_person_id, p.person_id
      FROM encntr_prsnl_reltn epr,
       person p,
       dummyt d
      PLAN (d)
       JOIN (epr
       WHERE (epr.encntr_id=data->resrc[r].label[l].encntr_id)
        AND epr.encntr_prsnl_r_cd=epr_admit_doc_cd
        AND epr.active_ind=1
        AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (epr.end_effective_dt_tm=
       null)) )
       JOIN (p
       WHERE p.person_id=epr.prsnl_person_id)
      DETAIL
       data->resrc[r].label[l].admit_doc_name = p.name_full_formatted, data->resrc[r].label[l].
       admit_doc_name_last = p.name_last
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].request_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       request_dt_tm),"@SHORTDATE;;D")
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].priority_cd)
     SET data->resrc[r].label[l].priority_disp = cdinfo->display
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      WHERE (data->resrc[r].label[l].case_specimen_tag_cd=a.tag_id)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].cassette_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 2=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].cassette_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].slide_tag_cd=a.tag_id))
      DETAIL
       data->resrc[r].label[l].slide_tag_disp = a.tag_disp
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 3=aptgr.tag_type_flag
      DETAIL
       data->resrc[r].label[l].slide_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].spec_blk_sld_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r].label[l].slide_tag_disp
      )
     SET data->resrc[r].label[l].spec_blk_tag_disp = build(data->resrc[r].label[l].
      case_specimen_tag_disp,data->resrc[r].label[l].cassette_sep_disp,data->resrc[r].label[l].
      cassette_tag_disp)
     SET data->resrc[r].label[l].blk_sld_tag_disp = build(data->resrc[r].label[l].cassette_sep_disp,
      data->resrc[r].label[l].cassette_tag_disp,data->resrc[r].label[l].slide_sep_disp,data->resrc[r]
      .label[l].slide_tag_disp)
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = build(substring(1,5,data->resrc[r].label[l].
       accession_nbr),"-",substring(6,2,data->resrc[r].label[l].accession_nbr),"-",substring(10,2,
       data->resrc[r].label[l].accession_nbr),
      "-",substring(12,7,data->resrc[r].label[l].accession_nbr))
     SET data->resrc[r].label[l].acc_site = build(substring(1,5,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_pre = build(substring(6,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yy = build(substring(10,2,data->resrc[r].label[l].accession_nbr)
      )
     SET data->resrc[r].label[l].acc_yyyy = build(substring(8,4,data->resrc[r].label[l].accession_nbr
       ))
     SET data->resrc[r].label[l].acc_nbr = build(substring(12,7,data->resrc[r].label[l].accession_nbr
       ))
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].responsible_pathologist_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].responsible_pathologist_name_full = p.name_full_formatted, data->
       resrc[r].label[l].responsible_pathologist_name_last = p.name_last, data->resrc[r].label[l].
       responsible_pathologist_initial = build(substring(1,1,p.name_first_key),substring(1,1,p
         .name_last_key))
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].responsible_resident_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].responsible_resident_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].responsible_resident_name_last = p.name_last, data->resrc[r].label[l].
       responsible_resident_initial = build(substring(1,1,p.name_first_key),substring(1,1,p
         .name_last_key))
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      p.name_full_formatted
      FROM person p
      WHERE (data->resrc[r].label[l].requesting_physician_id=p.person_id)
      DETAIL
       data->resrc[r].label[l].requesting_physician_name_full = p.name_full_formatted, data->resrc[r]
       .label[l].requesting_physician_name_last = p.name_last
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].case_received_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_received_dt_tm),"@SHORTDATETIMENOSEC;;D")
     SET data->resrc[r].label[l].case_collect_dt_tm_string = format(cnvtdatetime(data->resrc[r].
       label[l].case_collect_dt_tm),"@SHORTDATETIMENOSEC;;D")
     SET data->resrc[r].label[l].birth_dt_tm_string = format(cnvtdatetime(data->resrc[r].label[l].
       birth_dt_tm),"@SHORTDATETIMENOSEC;;D")
     SET age = cnvtage(cnvtdate2(format(data->resrc[r].label[l].birth_dt_tm,"mm/dd/yyyy;;d"),
       "@SHORTDATE;;D"),cnvtint(format(data->resrc[r].label[l].birth_dt_tm,"hhmm;;m")))
     SET data->resrc[r].label[l].age = age
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].sex_cd)
     SET data->resrc[r].label[l].sex_disp = cdinfo->display
     SET data->resrc[r].label[l].sex_desc = cdinfo->description
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_bed_cd)
     SET data->resrc[r].label[l].loc_bed_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_building_cd)
     SET data->resrc[r].label[l].loc_building_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_facility_cd)
     SET data->resrc[r].label[l].loc_facility_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].location_cd)
     SET data->resrc[r].label[l].location_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_nurse_unit_cd)
     SET data->resrc[r].label[l].loc_nurse_unit_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].loc_room_cd)
     SET data->resrc[r].label[l].loc_room_disp = cdinfo->display
     SET data->resrc[r].label[l].loc_nurse_room_bed_disp = build(data->resrc[r].label[l].
      loc_nurse_unit_disp,data->resrc[r].label[l].loc_room_disp,data->resrc[r].label[l].loc_bed_disp)
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].encntr_type_cd)
     SET data->resrc[r].label[l].encntr_type_disp = cdinfo->display
     SET data->resrc[r].label[l].encntr_type_desc = cdinfo->description
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].specimen_cd)
     SET data->resrc[r].label[l].specimen_disp = cdinfo->display
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].received_fixative_cd)
     SET data->resrc[r].label[l].received_fixative_disp = cdinfo->display
     SET data->resrc[r].label[l].received_fixative_desc = cdinfo->description
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].fixative_added_cd)
     SET data->resrc[r].label[l].fixative_added_disp = cdinfo->display
     SET data->resrc[r].label[l].fixative_added_desc = cdinfo->description
     EXECUTE aps_get__cd_info value(data->resrc[r].label[l].fixative_cd)
     SET data->resrc[r].label[l].fixative_disp = cdinfo->display
     SET data->resrc[r].label[l].fixative_desc = cdinfo->description
   ENDFOR
 ENDFOR
 SET _sendto =  $OUTDEV
 CALL initializereport(0)
 CALL showlabeldata(0)
 CALL finalizereport(_sendto)
END GO
