CREATE PROGRAM aprlabellblreservebc_prd
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD data(
   1 qual[*]
     2 accession_nbr = c21
     2 person_name = c100
     2 acc_site_pre_yy_nbr = c21
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
 DECLARE _default60 = i4 WITH noconstant(0), protect
 DECLARE _default100 = i4 WITH noconstant(0), protect
 DECLARE _default70 = i4 WITH noconstant(0), protect
 DECLARE _default80 = i4 WITH noconstant(0), protect
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
   DECLARE sectionheight = f8 WITH noconstant(0.940000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.136
    SET _oldfont = uar_rptsetfont(_hreport,_fntcond)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession1,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.959)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.136
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession2,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 1.896)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.136
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession3,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 2.844)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession4,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name1,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name2,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name3,char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name4,char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(current_date1,char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(current_date2,char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(current_date3,char(0)))
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.605
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(current_date4,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (patient_name1 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 0.084),(offsety+ 0.563))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 2
     SET rptbce->m_bscale = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession1,char(0)))
    ENDIF
    IF (patient_name2 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.011),(offsety+ 0.563))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 2
     SET rptbce->m_bscale = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession2,char(0)))
    ENDIF
    IF (patient_name3 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.959),(offsety+ 0.563))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 2
     SET rptbce->m_bscale = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession3,char(0)))
    ENDIF
    IF (patient_name4 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 2.896),(offsety+ 0.563))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 2
     SET rptbce->m_bscale = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession4,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "APRLABELLBLRESERVEBC_PRD"
   SET rptreport->m_pagewidth = 3.75
   SET rptreport->m_pageheight = 0.94
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
   SET rptfont->m_pointsize = 6
   SET _default60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _default80 = uar_rptcreatefont(_hreport,rptfont)
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
 DECLARE labeldataquery(dummy) = null WITH protect
 SUBROUTINE labeldataquery(ncalc)
   SET _flmargin = rptreport->m_marginleft
   SET _ftmargin = rptreport->m_margintop
   SET _flabelwidth = 3.750000
   SET _flabelheight = 0.937500
   SET _frowgutter = 0.000000
   SET _fcolgutter = 0.000000
   SET _ncols = 1
   SET _nrows = 1
   SELECT
    accn_site_prefix_nbr1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 3)].acc_site_pre_yy_nbr,3))
    ELSE " "
    ENDIF
    , accn_site_prefix_nbr2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 2)].acc_site_pre_yy_nbr,3))
    ELSE " "
    ENDIF
    , accn_site_prefix_nbr3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 1)].acc_site_pre_yy_nbr,3))
    ELSE " "
    ENDIF
    ,
    accn_site_prefix_nbr4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[(d1.seq *
       4)].acc_site_pre_yy_nbr,3))
    ELSE " "
    ENDIF
    , age1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].age,3)
    ELSE " "
    ENDIF
    , age2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].age,3)
    ELSE " "
    ENDIF
    ,
    age3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].age,3)
    ELSE " "
    ENDIF
    , age4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].age,3
      )
    ELSE " "
    ENDIF
    , current_date1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->current_dt_tm_string,3)
    ELSE ""
    ENDIF
    ,
    current_date2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->current_dt_tm_string,3)
    ELSE ""
    ENDIF
    , current_date3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->current_dt_tm_string,3)
    ELSE ""
    ENDIF
    , current_date4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->current_dt_tm_string,3)
    ELSE ""
    ENDIF
    ,
    fin1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].fin_nbr_alias,3)
    ELSE " "
    ENDIF
    , fin2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].fin_nbr_alias,3)
    ELSE " "
    ENDIF
    , fin3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].fin_nbr_alias,3)
    ELSE " "
    ENDIF
    ,
    fin4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      fin_nbr_alias,3)
    ELSE " "
    ENDIF
    , formatted_accession1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 3)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , formatted_accession2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 2)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    ,
    formatted_accession3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 1)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , formatted_accession4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[(d1.seq *
       4)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , mrn1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].mrn_alias,3)
    ELSE " "
    ENDIF
    ,
    mrn2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].mrn_alias,3)
    ELSE " "
    ENDIF
    , mrn3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].mrn_alias,3)
    ELSE " "
    ENDIF
    , mrn4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      mrn_alias,3)
    ELSE " "
    ENDIF
    ,
    patient_name1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].name_full_formatted),3)
    ELSE " "
    ENDIF
    , patient_name2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].name_full_formatted),3)
    ELSE " "
    ENDIF
    , patient_name3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].name_full_formatted),3)
    ELSE " "
    ENDIF
    ,
    patient_name4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].name_full_formatted),3)
    ELSE " "
    ENDIF
    , sex1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].sex_disp,3)
    ELSE " "
    ENDIF
    , sex2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].sex_disp,3)
    ELSE " "
    ENDIF
    ,
    sex3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].sex_disp,3)
    ELSE " "
    ENDIF
    , sex4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      sex_disp,3)
    ELSE " "
    ENDIF
    , siteprefixcodeon =
    IF (issitecodeon=1) issitecodeon
    ELSEIF (issitecodeon=0
     AND cnvtreal(substring(1,5,data->resrc[1].label[d1.seq].accession_nbr)) > 0) 1
    ENDIF
    FROM (dummyt d1  WITH seq = evaluate2(
      IF (mod(size(data->resrc[1].label,5),4) > 0) value(((size(data->resrc[1].label,5)/ 4)+ 1))
      ELSE value((size(data->resrc[1].label,5)/ 4))
      ENDIF
      ))
    PLAN (d1)
    HEAD REPORT
     _d0 = current_date1, _d1 = current_date2, _d2 = current_date3,
     _d3 = current_date4, _d4 = formatted_accession1, _d5 = formatted_accession2,
     _d6 = formatted_accession3, _d7 = formatted_accession4, _d8 = patient_name1,
     _d9 = patient_name2, _d10 = patient_name3, _d11 = patient_name4,
     _d12 = siteprefixcodeon, x = 0, y = 0
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
 SET _sendto =  $OUTDEV
 DECLARE issitecodeon = i2 WITH noconstant(0), protect
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
 CALL initializereport(0)
 CALL labeldataquery(0)
 CALL finalizereport(_sendto)
END GO
