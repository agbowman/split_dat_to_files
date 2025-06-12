CREATE PROGRAM apslabellblcl1300_specbc_prd
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
   DECLARE sectionheight = f8 WITH noconstant(0.920000), private
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
    SET rptsd->m_y = (offsety+ 0.584)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _oldfont = uar_rptsetfont(_hreport,_fntcond)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession1,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.584)
    SET rptsd->m_x = (offsetx+ 0.959)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession2,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.584)
    SET rptsd->m_x = (offsetx+ 1.896)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession3,char(0)))
    IF (siteprefixcodeon=1)
     SET _fntcond = _default60
    ELSE
     SET _fntcond = _default80
    ENDIF
    SET rptsd->m_y = (offsety+ 0.584)
    SET rptsd->m_x = (offsetx+ 2.834)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession4,char(0)))
    SET rptsd->m_y = (offsety+ 0.105)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn3,char(0)))
    SET rptsd->m_y = (offsety+ 0.105)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn4,char(0)))
    SET rptsd->m_y = (offsety+ 0.105)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn1,char(0)))
    SET rptsd->m_y = (offsety+ 0.105)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mrn2,char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin1,char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin2,char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin3,char(0)))
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(fin4,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession1 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 0.063),(offsety+ 0.313))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession1,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name1,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession2 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.000),(offsety+ 0.313))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession2,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name2,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession3 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.938),(offsety+ 0.313))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession3,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name3,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession4 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 2.876),(offsety+ 0.313))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession4,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name4,char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(specimen_desc1,char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordering_physician1,char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(specimen_desc2,char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordering_physician2,char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(specimen_desc3,char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordering_physician3,char(0)))
    SET rptsd->m_y = (offsety+ 0.688)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(specimen_desc4,char(0)))
    SET rptsd->m_y = (offsety+ 0.792)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ordering_physician4,char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.438)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_spec_tag1,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 0.396)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.105
    SET _dummyfont = uar_rptsetfont(_hreport,_default60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_collect_dt_tm1,char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.365)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_spec_tag2,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 1.344)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.105
    SET _dummyfont = uar_rptsetfont(_hreport,_default60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_collect_dt_tm2,char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 2.303)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_spec_tag3,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 2.282)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.105
    SET _dummyfont = uar_rptsetfont(_hreport,_default60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_collect_dt_tm3,char(0)))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 3.261)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_spec_tag4,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.323)
    SET rptsd->m_x = (offsetx+ 3.240)
    SET rptsd->m_width = 0.448
    SET rptsd->m_height = 0.105
    SET _dummyfont = uar_rptsetfont(_hreport,_default60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(case_collect_dt_tm4,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "APSLABELLBLCL1300_SPECBC_PRD"
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
    , adequacy1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].adequacy_string),3)
    ELSE " "
    ENDIF
    , adequacy2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].adequacy_string),3)
    ELSE " "
    ENDIF
    ,
    adequacy3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].adequacy_string),3)
    ELSE " "
    ENDIF
    , adequacy4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].adequacy_string),3)
    ELSE " "
    ENDIF
    , admit_doc_name1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 3)].admit_doc_name),3)
    ELSE " "
    ENDIF
    ,
    admit_doc_name2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 2)].admit_doc_name),3)
    ELSE " "
    ENDIF
    , admit_doc_name3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 1)].admit_doc_name),3)
    ELSE " "
    ENDIF
    , admit_doc_name4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].label[(d1
       .seq * 4)].admit_doc_name),3)
    ELSE " "
    ENDIF
    ,
    admit_doc_name_last1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    , admit_doc_name_last2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    , admit_doc_name_last3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    ,
    admit_doc_name_last4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].admit_doc_name_last),3)
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
    , birthdate1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    birthdate2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    , birthdate3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    , birthdate4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    blk_modifier1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    , blk_modifier2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    , blk_modifier3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    ,
    blk_modifier4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    , blk_sld_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , blk_sld_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    blk_sld_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , blk_sld_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_collect_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_recvd_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_recvd_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_recvd_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_recvd_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_spec_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , case_spec_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    case_spec_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , case_spec_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , deceased_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 3)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    ,
    deceased_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 2)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    , deceased_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 1)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    , deceased_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[(d1.seq * 4)].
      deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    ,
    encounter_type1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , encounter_type2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , encounter_type3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    ,
    encounter_type4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , fin1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    , fin2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    ,
    fin3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    , fin4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    , fixative1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_disp),3)
    ELSE " "
    ENDIF
    ,
    fixative2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_disp),3)
    ELSE " "
    ENDIF
    , fixative3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_disp),3)
    ELSE " "
    ENDIF
    , fixative4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_disp),3)
    ELSE " "
    ENDIF
    ,
    fixative_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_added1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_added3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_added_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    formatted_accession1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 3)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , formatted_accession2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 2)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , formatted_accession3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 1)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    ,
    formatted_accession4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[(d1.seq *
       4)].fmt_accession_nbr,3))
    ELSE " "
    ENDIF
    , mnemonic1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].mnemonic),3)
    ELSE " "
    ENDIF
    , mnemonic2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].mnemonic),3)
    ELSE " "
    ENDIF
    ,
    mnemonic3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].mnemonic),3)
    ELSE " "
    ENDIF
    , mnemonic4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].mnemonic),3)
    ELSE " "
    ENDIF
    , mrn1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].mrn_alias),3)
    ELSE " "
    ENDIF
    ,
    mrn2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].mrn_alias),3)
    ELSE " "
    ENDIF
    , mrn3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].mrn_alias),3)
    ELSE " "
    ENDIF
    , mrn4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].mrn_alias),3)
    ELSE " "
    ENDIF
    ,
    nurse_room_bed_disp1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 3)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    , nurse_room_bed_disp2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 2)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    , nurse_room_bed_disp3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 1)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    ,
    nurse_room_bed_disp4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].label[(d1
       .seq * 4)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    , ordering_physician1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 3)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , ordering_physician2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 2)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    ,
    ordering_physician3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 1)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , ordering_physician4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].label[(d1
       .seq * 4)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , order_phys_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    ,
    order_phys_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    , order_phys_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    , order_phys_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].requesting_physician_name_last),3)
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
    , patient_name_last1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].name_last),3)
    ELSE " "
    ENDIF
    , patient_name_last2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].name_last),3)
    ELSE " "
    ENDIF
    ,
    patient_name_last3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].name_last),3)
    ELSE " "
    ENDIF
    , patient_name_last4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].name_last),3)
    ELSE " "
    ENDIF
    , priority1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].priority_disp),3)
    ELSE " "
    ENDIF
    ,
    priority2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].priority_disp),3)
    ELSE " "
    ENDIF
    , priority3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].priority_disp),3)
    ELSE " "
    ENDIF
    , priority4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].priority_disp),3)
    ELSE " "
    ENDIF
    ,
    resp_pathologist1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    , resp_pathologist2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    , resp_pathologist3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_pathologist4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    , resp_path_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_path_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    ,
    resp_path_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_path_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_resident2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    , resp_resident3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    , resp_resident4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,30,data->resrc[1].label[(d1
       .seq * 4)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_resident_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    ,
    resp_resident_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    , request_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , request_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    request_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , request_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , recvd_fixative1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    ,
    recvd_fixative2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    , recvd_fixative3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    , recvd_fixative_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].received_fixative_desc),3)
    ELSE " "
    ENDIF
    ,
    sex1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 3)].sex_disp),3)
    ELSE " "
    ENDIF
    , sex2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 2)].sex_disp),3)
    ELSE " "
    ENDIF
    , sex3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 1)].sex_disp),3)
    ELSE " "
    ENDIF
    ,
    sex4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].label[(d1
       .seq * 4)].sex_disp),3)
    ELSE " "
    ENDIF
    , slide_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 3)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , slide_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 2)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    ,
    slide_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 1)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , slide_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].label[(d1
       .seq * 4)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , specimen_type1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].specimen_disp),3)
    ELSE " "
    ENDIF
    ,
    specimen_type2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].specimen_disp),3)
    ELSE " "
    ENDIF
    , specimen_type3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].specimen_disp),3)
    ELSE " "
    ENDIF
    , specimen_type4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].specimen_disp),3)
    ELSE " "
    ENDIF
    ,
    specimen_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 3)].specimen_description),3)
    ELSE " "
    ENDIF
    , specimen_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 2)].specimen_description),3)
    ELSE " "
    ENDIF
    , specimen_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 1)].specimen_description),3)
    ELSE " "
    ENDIF
    ,
    specimen_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].label[(d1
       .seq * 4)].specimen_description),3)
    ELSE " "
    ENDIF
    , spec_blk_sld_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , spec_blk_sld_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    spec_blk_sld_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , spec_blk_sld_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , stain1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    ,
    stain2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    , stain3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    , stain4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    ,
    stain_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].stain_description),3)
    ELSE " "
    ENDIF
    , stain_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].stain_description),3)
    ELSE " "
    ENDIF
    , stain_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].stain_description),3)
    ELSE " "
    ENDIF
    ,
    stain_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].stain_description),3)
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
     _d0 = case_collect_dt_tm1, _d1 = case_collect_dt_tm2, _d2 = case_collect_dt_tm3,
     _d3 = case_collect_dt_tm4, _d4 = case_spec_tag1, _d5 = case_spec_tag2,
     _d6 = case_spec_tag3, _d7 = case_spec_tag4, _d8 = fin1,
     _d9 = fin2, _d10 = fin3, _d11 = fin4,
     _d12 = formatted_accession1, _d13 = formatted_accession2, _d14 = formatted_accession3,
     _d15 = formatted_accession4, _d16 = mrn1, _d17 = mrn2,
     _d18 = mrn3, _d19 = mrn4, _d20 = ordering_physician1,
     _d21 = ordering_physician2, _d22 = ordering_physician3, _d23 = ordering_physician4,
     _d24 = patient_name1, _d25 = patient_name2, _d26 = patient_name3,
     _d27 = patient_name4, _d28 = specimen_desc1, _d29 = specimen_desc2,
     _d30 = specimen_desc3, _d31 = specimen_desc4, _d32 = siteprefixcodeon,
     x = 0, y = 0
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
 CALL labeldataquery(0)
 CALL finalizereport(_sendto)
END GO
