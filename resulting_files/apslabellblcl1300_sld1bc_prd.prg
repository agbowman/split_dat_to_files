CREATE PROGRAM apslabellblcl1300_sld1bc_prd
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
 DECLARE _default50 = i4 WITH noconstant(0), protect
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
   IF (patient_name1 != " ")
    DECLARE __clientsite1 = vc WITH noconstant(build2(
      IF (client_site != " ") client_site
      ELSE clientsite
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name2 != " ")
    DECLARE __clientsite2 = vc WITH noconstant(build2(
      IF (client_site != " ") client_site
      ELSE clientsite
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name3 != " ")
    DECLARE __clientsite3 = vc WITH noconstant(build2(
      IF (client_site != " ") client_site
      ELSE clientsite
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name4 != " ")
    DECLARE __clientsite4 = vc WITH noconstant(build2(
      IF (client_site != " ") client_site
      ELSE clientsite
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name1 != " ")
    DECLARE __clientloc1 = vc WITH noconstant(build2(
      IF (client_loc != " ") client_loc
      ELSE clientlocation
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name2 != " ")
    DECLARE __clientloc2 = vc WITH noconstant(build2(
      IF (client_loc != " ") client_loc
      ELSE clientlocation
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name3 != " ")
    DECLARE __clientloc3 = vc WITH noconstant(build2(
      IF (client_loc != " ") client_loc
      ELSE clientlocation
      ENDIF
      ,char(0))), protect
   ENDIF
   IF (patient_name4 != " ")
    DECLARE __clientloc4 = vc WITH noconstant(build2(
      IF (client_loc != " ") client_loc
      ELSE clientlocation
      ENDIF
      ,char(0))), protect
   ENDIF
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
    SET rptsd->m_y = (offsety+ 0.021)
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
    SET rptsd->m_y = (offsety+ 0.021)
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
    SET rptsd->m_y = (offsety+ 0.021)
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
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 2.834)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.146
    SET _dummyfont = uar_rptsetfont(_hreport,_fntcond)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(formatted_accession4,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.126
    SET _dummyfont = uar_rptsetfont(_hreport,_default70)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(spec_blk_sld_tag1,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.417
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(spec_blk_sld_tag2,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.417
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(spec_blk_sld_tag3,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 2.855)
    SET rptsd->m_width = 0.417
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(spec_blk_sld_tag4,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 0.521)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(blk_modifier1,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 1.459)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(blk_modifier2,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 2.396)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(blk_modifier3,char(0)))
    SET rptsd->m_y = (offsety+ 0.136)
    SET rptsd->m_x = (offsetx+ 3.323)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(blk_modifier4,char(0)))
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mnemonic1,char(0)))
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mnemonic2,char(0)))
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mnemonic3,char(0)))
    SET rptsd->m_y = (offsety+ 0.219)
    SET rptsd->m_x = (offsetx+ 2.865)
    SET rptsd->m_width = 0.698
    SET rptsd->m_height = 0.126
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(mnemonic4,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession1 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 0.084),(offsety+ 0.344))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession1,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.594)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name1,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession2 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.021),(offsety+ 0.344))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession2,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.594)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name2,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession3 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 1.959),(offsety+ 0.344))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession3,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.594)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.865
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name3,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (formatted_accession4 != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_datamatrix,(offsetx+ 2.896),(offsety+ 0.344))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 0.27
     SET rptbce->m_height = 0.27
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(formatted_accession4,char(0)))
    ENDIF
    SET rptsd->m_y = (offsety+ 0.594)
    SET rptsd->m_x = (offsetx+ 2.855)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.126
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(patient_name4,char(0)))
    SET rptsd->m_y = (offsety+ 0.678)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.115
    SET _dummyfont = uar_rptsetfont(_hreport,_default60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(request_dt_tm1,char(0)))
    SET rptsd->m_y = (offsety+ 0.678)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.605
    SET rptsd->m_height = 0.115
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(request_dt_tm2,char(0)))
    SET rptsd->m_y = (offsety+ 0.678)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.605
    SET rptsd->m_height = 0.115
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(request_dt_tm3,char(0)))
    SET rptsd->m_y = (offsety+ 0.678)
    SET rptsd->m_x = (offsetx+ 2.855)
    SET rptsd->m_width = 0.605
    SET rptsd->m_height = 0.115
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(request_dt_tm4,char(0)))
    SET rptsd->m_y = (offsety+ 0.761)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.115
    IF (patient_name1 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientsite1)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.761)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.115
    IF (patient_name2 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientsite2)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.761)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.115
    IF (patient_name3 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientsite3)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.761)
    SET rptsd->m_x = (offsetx+ 2.855)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.115
    IF (patient_name4 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientsite4)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.834)
    SET rptsd->m_x = (offsetx+ 0.042)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.094
    SET _dummyfont = uar_rptsetfont(_hreport,_default50)
    IF (patient_name1 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientloc1)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.834)
    SET rptsd->m_x = (offsetx+ 0.980)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.094
    IF (patient_name2 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientloc2)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 1.917)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.094
    IF (patient_name3 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientloc3)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.834)
    SET rptsd->m_x = (offsetx+ 2.855)
    SET rptsd->m_width = 0.855
    SET rptsd->m_height = 0.094
    IF (patient_name4 != " ")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__clientloc4)
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 102
   SET rptreport->m_reportname = "APSLABELLBLCL1300_SLD1BC_PRD"
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
   SET rptfont->m_pointsize = 5
   SET _default50 = uar_rptcreatefont(_hreport,rptfont)
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
    , admit_doc_name1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].admit_doc_name),3)
    ELSE " "
    ENDIF
    , admit_doc_name2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].admit_doc_name),3)
    ELSE " "
    ENDIF
    ,
    admit_doc_name3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].admit_doc_name),3)
    ELSE " "
    ENDIF
    , admit_doc_name4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].admit_doc_name),3)
    ELSE " "
    ENDIF
    , admit_doc_name_last1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    ,
    admit_doc_name_last2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    , admit_doc_name_last3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    , admit_doc_name_last4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].admit_doc_name_last),3)
    ELSE " "
    ENDIF
    ,
    age1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].age,3)
    ELSE " "
    ENDIF
    , age2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].age,3)
    ELSE " "
    ENDIF
    , age3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].age,3)
    ELSE " "
    ENDIF
    ,
    age4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].age,3
      )
    ELSE " "
    ENDIF
    , birthdate1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    , birthdate2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    birthdate3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    , birthdate4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      birth_dt_tm_string,3)
    ELSE " "
    ENDIF
    , blk_modifier1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    ,
    blk_modifier2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    , blk_modifier3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    , blk_modifier4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      cassette_origin_modifier,3)
    ELSE " "
    ENDIF
    ,
    blk_sld_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , blk_sld_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , blk_sld_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    blk_sld_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_collect_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_collect_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_collect_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_recvd_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_recvd_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_recvd_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    , case_recvd_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_received_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    case_spec_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , case_spec_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , case_spec_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    case_spec_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      case_specimen_tag_disp,3)
    ELSE " "
    ENDIF
    , clientsite = trim(substring(1,20,"")), clientlocation = trim(substring(1,20,"")),
    deceased_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 3)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    , deceased_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 2)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    , deceased_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[((d1.seq *
      4) - 1)].deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    ,
    deceased_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) format(data->resrc[1].label[(d1.seq * 4)].
      deceased_dt_tm,"@SHORTDATETIMENOSEC;;D")
    ELSE " "
    ENDIF
    , encounter_type1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , encounter_type2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    ,
    encounter_type3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , encounter_type4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].encntr_type_disp),3)
    ELSE " "
    ENDIF
    , fin1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    ,
    fin2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    , fin3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    , fin4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fin_nbr_alias),3)
    ELSE " "
    ENDIF
    ,
    fixative1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_disp),3)
    ELSE " "
    ENDIF
    , fixative2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_disp),3)
    ELSE " "
    ENDIF
    , fixative3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_disp),3)
    ELSE " "
    ENDIF
    ,
    fixative4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_disp),3)
    ELSE " "
    ENDIF
    , fixative_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_desc),3)
    ELSE " "
    ENDIF
    , fixative_added1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_added2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_added_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    , fixative_added_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].fixative_added_desc),3)
    ELSE " "
    ENDIF
    ,
    fixative_added_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].fixative_added_desc),3)
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
    , inventory_2dbarcode1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 3)].inventory_code,3))
    ELSE " "
    ENDIF
    ,
    inventory_2dbarcode2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 2)].inventory_code,3))
    ELSE " "
    ENDIF
    , inventory_2dbarcode3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[((d1
       .seq * 4) - 1)].inventory_code,3))
    ELSE " "
    ENDIF
    , inventory_2dbarcode4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) nullterm(trim(data->resrc[1].label[(d1.seq *
       4)].inventory_code,3))
    ELSE " "
    ENDIF
    ,
    mnemonic1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].mnemonic),3)
    ELSE " "
    ENDIF
    , mnemonic2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].mnemonic),3)
    ELSE " "
    ENDIF
    , mnemonic3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].mnemonic),3)
    ELSE " "
    ENDIF
    ,
    mnemonic4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].mnemonic),3)
    ELSE " "
    ENDIF
    , mrn1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].mrn_alias),3)
    ELSE " "
    ENDIF
    , mrn2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].mrn_alias),3)
    ELSE " "
    ENDIF
    ,
    mrn3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].mrn_alias),3)
    ELSE " "
    ENDIF
    , mrn4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].mrn_alias),3)
    ELSE " "
    ENDIF
    , nurse_room_bed_disp1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 3)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    ,
    nurse_room_bed_disp2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 2)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    , nurse_room_bed_disp3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].
       label[((d1.seq * 4) - 1)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    , nurse_room_bed_disp4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,23,data->resrc[1].label[(d1
       .seq * 4)].loc_nurse_room_bed_disp),3)
    ELSE " "
    ENDIF
    ,
    ordering_physician1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , ordering_physician2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , ordering_physician3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    ,
    ordering_physician4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].requesting_physician_name_full),3)
    ELSE " "
    ENDIF
    , order_phys_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    , order_phys_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    ,
    order_phys_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    , order_phys_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].requesting_physician_name_last),3)
    ELSE " "
    ENDIF
    , patient_name1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].name_full_formatted),3)
    ELSE " "
    ENDIF
    ,
    patient_name2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].name_full_formatted),3)
    ELSE " "
    ENDIF
    , patient_name3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].name_full_formatted),3)
    ELSE " "
    ENDIF
    , patient_name4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].name_full_formatted),3)
    ELSE " "
    ENDIF
    ,
    patient_name_last1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].name_last),3)
    ELSE " "
    ENDIF
    , patient_name_last2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].name_last),3)
    ELSE " "
    ENDIF
    , patient_name_last3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].name_last),3)
    ELSE " "
    ENDIF
    ,
    patient_name_last4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].name_last),3)
    ELSE " "
    ENDIF
    , priority1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].priority_disp),3)
    ELSE " "
    ENDIF
    , priority2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].priority_disp),3)
    ELSE " "
    ENDIF
    ,
    priority3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].priority_disp),3)
    ELSE " "
    ENDIF
    , priority4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].priority_disp),3)
    ELSE " "
    ENDIF
    , resp_pathologist1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_pathologist2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    , resp_pathologist3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    , resp_pathologist4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].responsible_pathologist_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_path_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_path_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_path_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    ,
    resp_path_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].responsible_pathologist_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    , resp_resident2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    ,
    resp_resident3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    , resp_resident4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,40,data->resrc[1].label[(d1
       .seq * 4)].responsible_resident_name_full),3)
    ELSE " "
    ENDIF
    , resp_resident_lastname1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    ,
    resp_resident_lastname2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident_lastname3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    , resp_resident_lastname4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].responsible_resident_name_last),3)
    ELSE " "
    ENDIF
    ,
    request_dt_tm1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , request_dt_tm2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , request_dt_tm3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].request_dt_tm_string,3)
    ELSE " "
    ENDIF
    ,
    request_dt_tm4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      request_dt_tm_string,3)
    ELSE " "
    ENDIF
    , recvd_fixative1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    , recvd_fixative2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    ,
    recvd_fixative3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].received_fixative_disp,3)
    ELSE " "
    ENDIF
    , recvd_fixative_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].received_fixative_desc),3)
    ELSE " "
    ENDIF
    , sex1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 3)].sex_disp),3)
    ELSE " "
    ENDIF
    ,
    sex2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 2)].sex_disp),3)
    ELSE " "
    ENDIF
    , sex3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 1)].sex_disp),3)
    ELSE " "
    ENDIF
    , sex4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].label[(d1
       .seq * 4)].sex_disp),3)
    ELSE " "
    ENDIF
    ,
    slide_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 3)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , slide_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 2)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , slide_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].
       label[((d1.seq * 4) - 1)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    ,
    slide_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,6,data->resrc[1].label[(d1
       .seq * 4)].slide_tag_disp),3)
    ELSE " "
    ENDIF
    , specimen_type1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].specimen_disp),3)
    ELSE " "
    ENDIF
    , specimen_type2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].specimen_disp),3)
    ELSE " "
    ENDIF
    ,
    specimen_type3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].specimen_disp),3)
    ELSE " "
    ENDIF
    , specimen_type4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].specimen_disp),3)
    ELSE " "
    ENDIF
    , specimen_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 3)].specimen_description),3)
    ELSE " "
    ENDIF
    ,
    specimen_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 2)].specimen_description),3)
    ELSE " "
    ENDIF
    , specimen_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].
       label[((d1.seq * 4) - 1)].specimen_description),3)
    ELSE " "
    ENDIF
    , specimen_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,20,data->resrc[1].label[(d1
       .seq * 4)].specimen_description),3)
    ELSE " "
    ENDIF
    ,
    spec_blk_sld_tag1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 3)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , spec_blk_sld_tag2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 2)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , spec_blk_sld_tag3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[((d1.seq * 4)
       - 1)].spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    ,
    spec_blk_sld_tag4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(data->resrc[1].label[(d1.seq * 4)].
      spec_blk_sld_tag_disp,3)
    ELSE " "
    ENDIF
    , stain1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    , stain2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    ,
    stain3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    , stain4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].stain_mnemonic),3)
    ELSE " "
    ENDIF
    , stain_desc1 =
    IF ((((d1.seq * 4) - 3) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 3)].stain_description),3)
    ELSE " "
    ENDIF
    ,
    stain_desc2 =
    IF ((((d1.seq * 4) - 2) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 2)].stain_description),3)
    ELSE " "
    ENDIF
    , stain_desc3 =
    IF ((((d1.seq * 4) - 1) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].
       label[((d1.seq * 4) - 1)].stain_description),3)
    ELSE " "
    ENDIF
    , stain_desc4 =
    IF (((d1.seq * 4) <= size(data->resrc[1].label,5))) trim(substring(1,15,data->resrc[1].label[(d1
       .seq * 4)].stain_description),3)
    ELSE " "
    ENDIF
    ,
    siteprefixcodeon =
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
     _d0 = blk_modifier1, _d1 = blk_modifier2, _d2 = blk_modifier3,
     _d3 = blk_modifier4, _d4 = blk_sld_tag1, _d5 = blk_sld_tag2,
     _d6 = blk_sld_tag3, _d7 = blk_sld_tag4, _d8 = clientsite,
     _d9 = clientlocation, _d10 = formatted_accession1, _d11 = formatted_accession2,
     _d12 = formatted_accession3, _d13 = formatted_accession4, _d14 = mnemonic1,
     _d15 = mnemonic2, _d16 = mnemonic3, _d17 = mnemonic4,
     _d18 = patient_name1, _d19 = patient_name2, _d20 = patient_name3,
     _d21 = patient_name4, _d22 = request_dt_tm1, _d23 = request_dt_tm2,
     _d24 = request_dt_tm3, _d25 = request_dt_tm4, _d26 = spec_blk_sld_tag1,
     _d27 = spec_blk_sld_tag2, _d28 = spec_blk_sld_tag3, _d29 = spec_blk_sld_tag4,
     _d30 = siteprefixcodeon, x = 0, y = 0
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
 EXECUTE pcs_label_integration_util
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET encounter_alias_type_cd = 0.0
 SET epr_admit_doc_cd = 0.0
 SET client_site = fillstring(30," ")
 SET client_loc = fillstring(30," ")
 DECLARE issitecodeon = i2 WITH noconstant(0), protect
 SET code_set = 4
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
     CALL echo(build("This is the value of accession number****",data->resrc[r].label[l].
       accession_nbr))
     IF (cnvtreal(substring(1,5,data->resrc[r].label[l].accession_nbr))=0)
      SELECT INTO "nl:"
       FROM accession a,
        ap_prefix ap,
        code_value_extension cve,
        code_value_extension cve2
       PLAN (a
        WHERE (a.accession=data->resrc[r].label[l].accession_nbr))
        JOIN (ap
        WHERE ap.prefix_id != outerjoin(0)
         AND ap.accession_format_cd=outerjoin(a.accession_format_cd))
        JOIN (cve
        WHERE cve.code_value=outerjoin(ap.accession_format_cd)
         AND cve.code_set=outerjoin(2057)
         AND cnvtupper(cve.field_name)=outerjoin("CLIENT_SITE")
         AND ap.site_cd=outerjoin(0))
        JOIN (cve2
        WHERE cve2.code_value=outerjoin(ap.accession_format_cd)
         AND cve2.code_set=outerjoin(2057)
         AND cnvtupper(cve2.field_name)=outerjoin("CLIENT_LOC")
         AND ap.site_cd=outerjoin(0))
       DETAIL
        client_site = cve.field_value, client_loc = cve2.field_value
       WITH nocounter
      ;end select
     ELSEIF (cnvtreal(substring(1,5,data->resrc[r].label[l].accession_nbr)) > 0)
      SELECT INTO "nl:"
       FROM accession a,
        ap_prefix ap,
        code_value_extension cve,
        code_value_extension cve2
       PLAN (a
        WHERE (a.accession=data->resrc[r].label[l].accession_nbr))
        JOIN (ap
        WHERE ap.prefix_id != outerjoin(0)
         AND ap.site_cd=outerjoin(a.site_prefix_cd))
        JOIN (cve
        WHERE cve.code_value=outerjoin(a.site_prefix_cd)
         AND cve.code_set=outerjoin(2062)
         AND cnvtupper(cve.field_name)=outerjoin("CLIENT_SITE")
         AND ap.site_cd > outerjoin(0))
        JOIN (cve2
        WHERE cve2.code_value=outerjoin(a.site_prefix_cd)
         AND cve2.code_set=outerjoin(2062)
         AND cnvtupper(cve2.field_name)=outerjoin("CLIENT_LOC")
         AND ap.site_cd > outerjoin(0))
       DETAIL
        client_site = cve.field_value, client_loc = cve2.field_value
       WITH nocounter
      ;end select
      CALL echo(build("This is site code client site***",client_site))
      CALL echo(build("This is site code client loc***",client_loc))
     ENDIF
     SELECT INTO "nl:"
      alias_type = decode(pa.seq,"P",ea.seq,"E"," ")
      FROM org_alias_pool_reltn oa,
       (dummyt d1  WITH seq = 1),
       person_alias pa,
       (dummyt d2  WITH seq = 1),
       encntr_alias ea
      PLAN (oa
       WHERE (oa.organization_id=data->resrc[r].label[l].organization_id)
        AND ((oa.alias_entity_name="PERSON_ALIAS"
        AND oa.alias_entity_alias_type_cd=mrn_alias_type_cd) OR (oa.alias_entity_name="ENCNTR_ALIAS"
        AND oa.alias_entity_alias_type_cd=encounter_alias_type_cd))
        AND oa.active_ind=1
        AND oa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((oa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (oa.end_effective_dt_tm=
       null)) )
       JOIN (((d1
       WHERE d1.seq=1)
       JOIN (pa
       WHERE oa.alias_entity_name="PERSON_ALIAS"
        AND (pa.person_id=data->resrc[r].label[l].person_id)
        AND pa.alias_pool_cd=oa.alias_pool_cd
        AND pa.active_ind=1
        AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pa.end_effective_dt_tm=
       null)) )
       ) ORJOIN ((d2
       WHERE d2.seq=1)
       JOIN (ea
       WHERE oa.alias_entity_name="ENCNTR_ALIAS"
        AND (ea.encntr_id=data->resrc[r].label[l].encntr_id)
        AND ea.alias_pool_cd=oa.alias_pool_cd
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND ((ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ea.end_effective_dt_tm=
       null)) )
       ))
      DETAIL
       IF (textlen(trim(data->resrc[r].label[l].mrn_alias))=0)
        data->resrc[r].label[l].mrn_alias = "Unknown"
       ENDIF
       IF (alias_type="P")
        data->resrc[r].label[l].mrn_alias = pa.alias
       ELSEIF (alias_type="E")
        data->resrc[r].label[l].fin_nbr_alias = ea.alias
       ENDIF
      WITH nocounter, outerjoin = d1, outerjoin = d2
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
       AND (data->resrc[r].label[l].case_specimen_tag_cd > 0)
      DETAIL
       data->resrc[r].label[l].case_specimen_tag_disp = a.tag_disp, data->resrc[r].label[l].
       case_specimen_tag_seq = a.tag_sequence
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      a.tag_disp
      FROM ap_tag a
      PLAN (a
       WHERE (data->resrc[r].label[l].cassette_tag_cd=a.tag_id)
        AND (data->resrc[r].label[l].cassette_tag_cd > 0))
      DETAIL
       data->resrc[r].label[l].cassette_tag_disp = a.tag_disp, data->resrc[r].label[l].
       cassette_tag_seq = a.tag_sequence
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
       WHERE (data->resrc[r].label[l].slide_tag_cd=a.tag_id)
        AND (data->resrc[r].label[l].slide_tag_cd > 0))
      DETAIL
       data->resrc[r].label[l].slide_tag_disp = a.tag_disp, data->resrc[r].label[l].slide_tag_seq = a
       .tag_sequence
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      aptgr.tag_separator
      FROM ap_prefix_tag_group_r aptgr
      WHERE (data->resrc[r].label[l].prefix_cd=aptgr.prefix_id)
       AND 3=aptgr.tag_type_flag
       AND (data->resrc[r].label[l].slide_tag_cd > 0)
      DETAIL
       data->resrc[r].label[l].slide_sep_disp = aptgr.tag_separator
      WITH nocounter
     ;end select
     SET data->resrc[r].label[l].spec_blk_sld_tag_disp = trim(build(trim(data->resrc[r].label[l].
        case_specimen_tag_disp,3),trim(data->resrc[r].label[l].cassette_sep_disp,3),trim(data->resrc[
        r].label[l].cassette_tag_disp,3),trim(data->resrc[r].label[l].slide_sep_disp,3),trim(data->
        resrc[r].label[l].slide_tag_disp,3)),3)
     SET data->resrc[r].label[l].spec_blk_tag_disp = trim(build(trim(data->resrc[r].label[l].
        case_specimen_tag_disp,3),trim(data->resrc[r].label[l].cassette_sep_disp,3),trim(data->resrc[
        r].label[l].cassette_tag_disp,3)),3)
     SET data->resrc[r].label[l].blk_sld_tag_disp = trim(build(trim(data->resrc[r].label[l].
        cassette_sep_disp,3),trim(data->resrc[r].label[l].cassette_tag_disp,3),trim(data->resrc[r].
        label[l].slide_sep_disp,3),trim(data->resrc[r].label[l].slide_tag_disp,3)),3)
     SET data->resrc[r].label[l].acc_site_pre_yy_nbr = trim(build(trim(substring(1,5,data->resrc[r].
         label[l].accession_nbr),3),"-",trim(substring(6,2,data->resrc[r].label[l].accession_nbr),3),
       "-",trim(substring(10,2,data->resrc[r].label[l].accession_nbr),3),
       "-",trim(substring(12,7,data->resrc[r].label[l].accession_nbr),3)),3)
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
     SET data->resrc[r].label[l].inventory_code = getinventorybarcode(data->resrc[r].label[l].
      accession_nbr,data->resrc[r].label[l].case_specimen_tag_seq,data->resrc[r].label[l].
      cassette_tag_seq,data->resrc[r].label[l].slide_tag_seq,0)
     IF (textlen(trim(data->resrc[r].label[l].inventory_code))=0)
      SET error_count = (error_count+ 1)
     ENDIF
   ENDFOR
 ENDFOR
 SET _sendto =  $OUTDEV
 CALL initializereport(0)
 CALL labeldataquery(0)
 CALL finalizereport(_sendto)
END GO
