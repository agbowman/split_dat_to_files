CREATE PROGRAM bbt_tag_emerg_2d_barcode
 EXECUTE reportrtl
 RECORD tag_request(
   1 debug_ind = i2
   1 tag_type = c20
   1 sub_tag_type = c20
   1 taglist[*]
     2 product_event_id = f8
     2 event_type_cd = f8
     2 event_type_mean = c12
     2 product_id = f8
     2 derivative_ind = i2
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 tech_id = f8
     2 tech_name = c15
     2 pe_event_dt_tm = dq8
     2 name_full_formatted = c50
     2 alias_mrn = c20
     2 alias_fin = c20
     2 alias_ssn = c20
     2 birth_dt_tm = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c6
     2 patient_location = c30
     2 prvdr_name_full_formatted = c50
     2 product_cd = f8
     2 product_disp = c40
     2 product_desc = c60
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 cur_abo_cd = f8
     2 cur_abo_disp = c20
     2 cur_rh_cd = f8
     2 cur_rh_disp = c20
     2 supplier_prefix = c5
     2 segment_nbr = c20
     2 cur_volume = i4
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c15
     2 quantity = i4
     2 item_volume = i4
     2 item_unit_per_vial = i4
     2 item_unit_meas_cd = f8
     2 item_unit_meas_disp = c15
     2 bb_id_nbr = c20
     2 product_expire_dt_tm = dq8
     2 accession = c20
     2 xm_result_value_alpha = c15
     2 xm_result_event_prsnl_username = c15
     2 xm_result_event_dt_tm = dq8
     2 xm_expire_dt_tm = dq8
     2 reason_cd = f8
     2 reason_disp = c15
     2 person_abo_cd = f8
     2 person_abo_disp = c20
     2 person_rh_cd = f8
     2 person_rh_disp = c20
     2 antibody_cnt = i4
     2 antibodylist[*]
       3 antibody_cd = f8
       3 antibody_disp = c15
       3 trans_req_ind = i2
     2 antigen_cnt = i4
     2 antigenlist[*]
       3 antigen_cd = f8
       3 antigen_disp = c15
     2 cmpnt_cnt = i4
     2 cmpntlist[*]
       3 product_id = f8
       3 product_cd = f8
       3 product_disp = c40
       3 product_nbr = c20
       3 product_sub_nbr = c5
       3 cur_abo_cd = f8
       3 cur_abo_disp = c20
       3 cur_rh_cd = f8
       3 supplier_prefix = c5
       3 cur_rh_disp = c20
     2 unknown_patient_ind = i2
     2 unknown_patient_text = c50
     2 dispense_tech_id = f8
     2 dispense_tech_username = c15
     2 dispense_dt_tm = dq8
     2 dispense_courier_id = f8
     2 dispense_courier = c50
     2 dispense_prvdr_id = f8
     2 dispense_prvdr_name = c50
     2 pooled_product_ind = i2
     2 admit_prvdr_id = f8
     2 admit_prvdr_name = c50
     2 anchor_dt_tm = dq8
     2 person_aborh_barcode = vc
     2 product_barcode_nbr = c20
     2 cur_supplier_id = f8
     2 pooled_product_ind = i2
     2 alpha_translation_ind = i2
     2 alias_mrn_formatted = c25
     2 alias_fin_formatted = c25
     2 alias_ssn_formatted = c25
     2 flag_chars = c2
     2 owner_area = f8
     2 inventory_area = f8
     2 address[*]
       3 enc_loc_facility_cd = f8
       3 enc_facility_address1 = vc
       3 enc_facility_address2 = vc
       3 enc_facility_address3 = vc
       3 enc_facility_address4 = vc
       3 enc_facility_citystatezip = vc
       3 enc_facility_country = vc
     2 serial_nbr = c22
     2 product_type_barcode = vc
   1 bbid_preference_ind = i2
 )
 RECORD tag_from_request(
   1 tag_per_event[*]
     2 derivative_ind = i2
     2 patient_name = vc
     2 patient_id = f8
     2 patient_location = vc
     2 patient_aborh_disp = vc
     2 bb_id = vc
     2 mrn = vc
     2 fin = vc
     2 dob = vc
     2 sex = c15
     2 dispense_physician_name = vc
     2 prod_nbr = vc
     2 prod_desc = vc
     2 prod_aborh_disp = vc
     2 prod_expiration = vc
     2 prod_volume = vc
     2 unit_count = c5
     2 prepared_by = vc
     2 prepared_dttm = vc
     2 patient_trans_req = vc
     2 patient_antibodies = vc
     2 product_special_testing = vc
     2 product_antigen = vc
     2 owninvarea_disp = vc
     2 crossmatch_interp = vc
     2 crossmatch_verified_by = vc
     2 crossmatch_dttm = vc
     2 accession_nbr = vc
     2 ordering_physician_name = vc
     2 qty_iu = vc
     2 unknown_patient_ind = i2
     2 patient_aborh_barcode = vc
     2 address[*]
       3 facility_disp = vc
       3 enc_facility_address1 = vc
       3 enc_facility_address2 = vc
       3 enc_facility_address3 = vc
       3 enc_facility_address4 = vc
       3 enc_facility_citystatezip = vc
       3 enc_facility_country = vc
     2 alias_mrn_raw = vc
     2 alias_fin_raw = vc
     2 serial_nbr = c22
     2 unit_number_barcode = vc
     2 product_type_barcode = vc
     2 product_type_barcode_nbr = vc
   1 bbid_preference = i2
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
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
 DECLARE _flmargin = f8 WITH noconstant(0.0), protect
 DECLARE _ftmargin = f8 WITH noconstant(0.0), protect
 DECLARE _flabelwidth = f8 WITH noconstant(0.0), protect
 DECLARE _flabelheight = f8 WITH noconstant(0.0), protect
 DECLARE _frowgutter = f8 WITH noconstant(0.0), protect
 DECLARE _fcolgutter = f8 WITH noconstant(0.0), protect
 DECLARE _nrows = i4 WITH noconstant(0), protect
 DECLARE _ncols = i4 WITH noconstant(0), protect
 DECLARE _helvetica90 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica9b0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c8 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH dio = 0
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
 SUBROUTINE (detailsection(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.183561), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName67",build2("PRE",char(0))),char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName68",build2("15 min",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName72",build2("POST",char(0))),char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow1(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.183562), private
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName73",build2("TIME",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.177
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.177
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow2(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow2abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow2abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.175580), private
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName80",build2("TEMP",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow3(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow3abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow3abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.175580), private
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName87",build2("PULSE",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow4(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow4abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow4abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.175580), private
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName94",build2("RESP",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (tablerow5(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow5abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (tablerow5abs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.175581), private
   SET rptsd->m_flags = 276
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdleftborder
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.258)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_CellName101",build2("B.P.",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 1.321)
   SET rptsd->m_width = 1.182
   SET rptsd->m_height = 0.169
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 2.510)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.636)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.761)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 5.887)
   SET rptsd->m_width = 1.119
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 7.013)
   SET rptsd->m_width = 1.057
   SET rptsd->m_height = 0.169
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset += sectionheight
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.250),offsety,(offsetx+ 0.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.313),offsety,(offsetx+ 1.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.502),offsety,(offsetx+ 2.502),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.628),offsety,(offsetx+ 3.628),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.754),offsety,(offsetx+ 4.754),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.880),offsety,(offsetx+ 5.880),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.006),offsety,(offsetx+ 7.006),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.069),offsety,(offsetx+ 8.069),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ 0.000),(offsetx+ 8.070),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.251),(offsety+ sectionheight),(offsetx+ 8.070),(
     offsety+ sectionheight))
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(11.000000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   DECLARE __txtproductvolume = vc WITH noconstant(build2(
     IF (tag_per_event_derivative_ind=0) build(concat("Product Volume: ",tag_per_event_prod_volume))
     ELSE tag_per_event_qty_iu
     ENDIF
     ,char(0))), protect
   DECLARE __txtspecialtesting = vc WITH noconstant(build2(trim(tag_per_event_product_special_testing
      ),char(0))), protect
   DECLARE __txtproductantigens = vc WITH noconstant(build2(trim(tag_per_event_product_antigen),char(
      0))), protect
   DECLARE __txttagbbid = vc WITH noconstant(build2(
     IF (tag_from_request_bbid_preference) tag_per_event_bb_id
     ENDIF
     ,char(0))), protect
   DECLARE __txtpatienttransfusionrequirements = vc WITH noconstant(build2(trim(
      tag_per_event_patient_trans_req),char(0))), protect
   DECLARE __txtpatientantibodies = vc WITH noconstant(build2(trim(tag_per_event_patient_antibodies),
     char(0))), protect
   DECLARE __txtbbid = vc WITH noconstant(build2(
     IF (tag_from_request_bbid_preference) tag_per_event_bb_id
     ENDIF
     ,char(0))), protect
   DECLARE __txtlabelpatienttransfusionreq = vc WITH noconstant(build2(
     IF (textlen(trim(tag_per_event_patient_trans_req)) > 120) build(concat(
        "Patient Transfusion Requirements: ",substring(1,120,tag_per_event_patient_trans_req),
        "(MORE)"))
     ELSE build("Patient Transfusion Requirements: ",tag_per_event_patient_trans_req)
     ENDIF
     ,char(0))), protect
   DECLARE __txtemerglblxm = vc WITH noconstant(build2(
     IF (tag_per_event_unknown_patient_ind=1) " "
     ELSE "Emergency Uncrossmatched"
     ENDIF
     ,char(0))), protect
   DECLARE __txtemergxm = vc WITH noconstant(build2(
     IF (((tag_per_event_unknown_patient_ind=1) OR ((tag_request->sub_tag_type="BLANK"))) ) " "
     ELSE "Emergency Uncrossmatched"
     ENDIF
     ,char(0))), protect
   DECLARE __txttagproductvolumeqty = vc WITH noconstant(build2(
     IF (tag_per_event_derivative_ind=0) build(concat("Product Volume: ",tag_per_event_prod_volume))
     ELSE tag_per_event_qty_iu
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c8)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.501),(offsety+ 7.875),3.445,2.944,
     rpt_nofill,rpt_black)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_oneandahalf
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 4.625)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 7.750
    SET rptsd->m_height = 0.750
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblDeclaration0",build2(concat(
         "BECAUSE DELAY IN TRANSFUSION WILL JEOPARDIZE THE PATIENT'S LIFE, I AUTHORIZE THE ADMINISTRATION OF THIS UNIT OF",
         " UNCROSSMATCHED BLOOD.",_crlf,
         "	      Physician Signature ___________________________________________________________________"
         ),char(0))),char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.375),(offsety+ 3.125),3.695,1.500,
     rpt_nofill,rpt_black)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.320),(offsety+ 3.125),3.695,1.500,
     rpt_nofill,rpt_black)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_y = (offsety+ 8.695)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.612
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblDOB",build2("DOB:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.876)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblPatientABORh",build2("Patient ABO/Rh:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.126)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblProductABORh",build2("Product ABO/Rh:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.320)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblProductNumber",build2("Product Number:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.716)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.320
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblProductType",build2("Product Type:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.917)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.570
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblProductExpiration",build2("Product Expiration:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.126)
    SET rptsd->m_x = (offsetx+ 3.695)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_aborh_disp,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.320)
    SET rptsd->m_x = (offsetx+ 3.695)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_nbr,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.716)
    SET rptsd->m_x = (offsetx+ 3.570)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_desc,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.917)
    SET rptsd->m_x = (offsetx+ 3.751)
    SET rptsd->m_width = 2.070
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_expiration,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 10.320)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 2.876
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtproductvolume)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.195)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 3.320
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblHeadTag",build2("EMERGENCY TRANSFUSION TAG",char(0))),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.695)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagPatientLocation",build2("Patient Location:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.716)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagPatientName",build2("Patient:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.952)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagPatientAboRh",build2("Patient ABO/Rh:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.945)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.320
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagBBID",build2("Blood Bank ID #:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.195)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagDOB",build2("DOB:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.195)
    SET rptsd->m_x = (offsetx+ 2.445)
    SET rptsd->m_width = 0.695
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagSex",build2("Sex:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.945)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.403
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagPhysician",build2("Physician:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.306)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagProductNumber",build2("Product Number:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.681)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagProductType",build2("Product Type:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.369)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagProductAboRh",build2("Product ABO/Rh:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.126)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.570
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagProductExpiration",build2("Product Expiration:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.570
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagCrossmatchInterp",build2("Crossmatch Interp:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.195)
    SET rptsd->m_x = (offsetx+ 0.376)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblPatientTransfusionRequirements",build2("Patient Transfusion Requirements: ",
        char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.820)
    SET rptsd->m_x = (offsetx+ 0.376)
    SET rptsd->m_width = 1.612
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblPatientAntibodies",build2("Patient Antibodies:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.195)
    SET rptsd->m_x = (offsetx+ 4.445)
    SET rptsd->m_width = 1.945
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblSpecialProductTesting",build2("Special Product Testing:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.820)
    SET rptsd->m_x = (offsetx+ 4.445)
    SET rptsd->m_width = 1.612
    SET rptsd->m_height = 0.334
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblProductAntigens",build2("Product Antigens:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.306)
    SET rptsd->m_x = (offsetx+ 5.445)
    SET rptsd->m_width = 2.570
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_nbr,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.681)
    SET rptsd->m_x = (offsetx+ 5.195)
    SET rptsd->m_width = 2.820
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_desc,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 5.556)
    SET rptsd->m_width = 2.320
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_aborh_disp,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.126)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prod_expiration,char(0))
     )
    SET rptsd->m_flags = 12
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.320)
    SET rptsd->m_x = (offsetx+ 4.445)
    SET rptsd->m_width = 3.570
    SET rptsd->m_height = 0.445
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtspecialtesting)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.945)
    SET rptsd->m_x = (offsetx+ 4.445)
    SET rptsd->m_width = 3.570
    SET rptsd->m_height = 0.625
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtproductantigens)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.945)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.237
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblBBID",build2("Blood Bank ID #:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblPatinetName",build2("Patient Name:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.501)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.528
    SET rptsd->m_height = 0.257
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblMRN",build2("MRN:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.501)
    SET rptsd->m_x = (offsetx+ 4.125)
    SET rptsd->m_width = 0.612
    SET rptsd->m_height = 0.257
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblFIN",build2("FIN:",char(0))),char(0)))
    SET _yoffset = (offsety+ 6.319)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 6.319)
     SET holdheight = 0
     SET holdheight += tablerow(rpt_render)
     SET holdheight += tablerow1(rpt_render)
     SET holdheight += tablerow2(rpt_render)
     SET holdheight += tablerow3(rpt_render)
     SET holdheight += tablerow4(rpt_render)
     SET holdheight += tablerow5(rpt_render)
     SET _yoffset = offsety
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 10.119)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblCrossmatchInterp",build2("Crossmatch Interp:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagPreparedBy",build2("Prepared By:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.945)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblPreparedDateTime",build2("Prepared Date/Time:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.751)
    SET rptsd->m_x = (offsetx+ 5.320)
    SET rptsd->m_width = 2.695
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prepared_by,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.945)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 2.320
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_prepared_dttm,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.945)
    SET rptsd->m_x = (offsetx+ 0.945)
    SET rptsd->m_width = 3.001
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_dispense_physician_name,
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.716)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_patient_name,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_aztec,(offsetx+ 5.375),(offsety+ 8.875))
    SET rptbce->m_recsize = 88
    SET rptbce->m_width = 0.50
    SET rptbce->m_height = 0.32
    SET rptbce->m_rotation = 0
    SET rptbce->m_ratio = 300
    SET rptbce->m_barwidth = 1
    SET rptbce->m_bscale = 1
    SET rptbce->m_bprintinterp = 0
    SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(
      IF (tag_from_request_bbid_preference) build(concat("*",trim(tag_per_event_alias_mrn_raw),"!",
         trim(tag_per_event_bb_id),"!",
         trim(tag_per_event_patient_name),"!",trim(replace(trim(tag_per_event_unit_number_barcode),
           " ","%")),"!",trim(tag_per_event_patient_aborh_disp),
         "*"))
      ELSE build(concat("*",trim(tag_per_event_alias_mrn_raw),"!",trim(tag_per_event_patient_name),
         "!",
         trim(replace(trim(tag_per_event_unit_number_barcode)," ","%")),"!",trim(
          tag_per_event_patient_aborh_disp),"*"))
      ENDIF
      ,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_oneandahalf
    SET rptsd->m_y = (offsety+ 5.320)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 7.750
    SET rptsd->m_height = 1.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblDeclaration1",build2(concat(
         "At the bedside, we certify that we have identified intended recipient by armband and compared this with blood l",
         "abel and the unit identification.  Transfusionist__________________  Witness__________________",
         _crlf,
         "Transfusion started by _____________________________ 	Date started _________________  Time started ___________",
         _crlf,
         "Transfusion completed/stopped by ______________________  Date stopped _________________  Time stopped __________",
         "_",_crlf,"Amount Transfused____________________________________"),char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_y = (offsety+ 1.695)
    SET rptsd->m_x = (offsetx+ 1.320)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_patient_location,char(0)
      ))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.952)
    SET rptsd->m_x = (offsetx+ 1.445)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_patient_aborh_disp,char(
       0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.945)
    SET rptsd->m_x = (offsetx+ 1.320)
    SET rptsd->m_width = 2.570
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txttagbbid)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.195)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_dob,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.195)
    SET rptsd->m_x = (offsetx+ 2.751)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_sex,char(0)))
    SET rptsd->m_flags = 12
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.320)
    SET rptsd->m_x = (offsetx+ 0.376)
    SET rptsd->m_width = 3.570
    SET rptsd->m_height = 0.500
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtpatienttransfusionrequirements)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 3.945)
    SET rptsd->m_x = (offsetx+ 0.376)
    SET rptsd->m_width = 3.570
    SET rptsd->m_height = 0.625
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtpatientantibodies)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.695)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 1.869
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_dob,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.876)
    SET rptsd->m_x = (offsetx+ 3.626)
    SET rptsd->m_width = 1.695
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_patient_aborh_disp,char(
       0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 7.945)
    SET rptsd->m_x = (offsetx+ 3.820)
    SET rptsd->m_width = 2.001
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtbbid)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.126)
    SET rptsd->m_x = (offsetx+ 3.626)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.299
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_patient_name,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.501)
    SET rptsd->m_x = (offsetx+ 3.001)
    SET rptsd->m_width = 1.070
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_mrn,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 8.501)
    SET rptsd->m_x = (offsetx+ 4.445)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_fin,char(0)))
    SET rptsd->m_flags = 12
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 10.528)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 3.251
    SET rptsd->m_height = 0.292
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtlabelpatienttransfusionreq)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 10.119)
    SET rptsd->m_x = (offsetx+ 3.876)
    SET rptsd->m_width = 1.945
    SET rptsd->m_height = 0.174
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtemerglblxm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.501)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.445
    SET rptsd->m_height = 0.174
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txtemergxm)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.306)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 3.626
    SET rptsd->m_height = 0.202
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txttagproductvolumeqty)
    SET rptsd->m_flags = 68
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_oneandahalf
    SET rptsd->m_y = (offsety+ 7.445)
    SET rptsd->m_x = (offsetx+ 0.251)
    SET rptsd->m_width = 7.375
    SET rptsd->m_height = 0.445
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica9b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblDeclaration2",build2(concat(
         "Blood Warmer used? 	   		NO      	YES 		Filter(s) used:	 Std Blood Administration Set    Other_________________",
         _crlf,"Reaction Noted?	        	NO     		YES   If yes, immediately follow protocol"),char(0)
        )),char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 2.626),(offsety+ 7.569),0.112,0.090,
     rpt_nofill,rpt_black)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.070),(offsety+ 7.569),0.112,0.090,
     rpt_nofill,rpt_black)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.820),(offsety+ 7.694),0.112,0.090,
     rpt_nofill,rpt_black)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.195),(offsety+ 7.694),0.112,0.090,
     rpt_nofill,rpt_black)
    SET rptsd->m_flags = 12
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_y = (offsety+ 0.181)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_facility_disp,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.306)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_address1,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.445
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_owninvarea_disp,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.431)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_address2,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.556)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_address3,char(0))
     )
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.806)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_citystatezip,char
      (0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.931)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_country,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.681)
    SET rptsd->m_x = (offsetx+ 5.625)
    SET rptsd->m_width = 2.403
    SET rptsd->m_height = 0.160
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(address_enc_facility_address4,char(0))
     )
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.195)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 1.244
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagMRN",build2("MRN:",char(0))),char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.445)
    SET rptsd->m_x = (offsetx+ 0.320)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblTagFIN",build2("FIN:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.195)
    SET rptsd->m_x = (offsetx+ 0.695)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_mrn,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.445)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 3.251
    SET rptsd->m_height = 0.202
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_fin,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (tag_per_event_alias_mrn_raw != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 0.320),(offsety+ 1.375))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 1.75
     SET rptbce->m_height = 0.25
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",tag_per_event_alias_mrn_raw,"*"
        ),char(0)))
    ENDIF
    IF (tag_per_event_alias_fin_raw != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code39,(offsetx+ 0.320),(offsety+ 2.625))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 1.82
     SET rptbce->m_height = 0.25
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",tag_per_event_alias_fin_raw,"*"
        ),char(0)))
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.507)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.445
    SET rptsd->m_height = 0.209
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName1",build2("Serial Number:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.494)
    SET rptsd->m_x = (offsetx+ 5.320)
    SET rptsd->m_width = 2.570
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_serial_nbr,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.528)
    SET rptsd->m_x = (offsetx+ 2.626)
    SET rptsd->m_width = 0.959
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_lblSerialNumber",build2("Serial Number:",char(0))),char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 9.528)
    SET rptsd->m_x = (offsetx+ 3.570)
    SET rptsd->m_width = 2.320
    SET rptsd->m_height = 0.209
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(tag_per_event_serial_nbr,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen13s0c0)
    IF (tag_per_event_product_type_barcode != " ")
     SET _rptdummy = uar_rptbarcodeinit(rptbce,rpt_code128,(offsetx+ 4.375),(offsety+ 1.868))
     SET rptbce->m_recsize = 88
     SET rptbce->m_width = 1.60
     SET rptbce->m_height = 0.24
     SET rptbce->m_rotation = 0
     SET rptbce->m_ratio = 300
     SET rptbce->m_barwidth = 1
     SET rptbce->m_bprintinterp = 0
     SET rptbce->m_bcheckdigit = 1
     SET _rptstat = uar_rptbarcodeex(_hreport,rptbce,build2(build("*",
        tag_per_event_product_type_barcode,"*"),char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BBT_TAG_EMERG_2D_BARCODE"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.00
   SET rptreport->m_marginright = 0.00
   SET rptreport->m_margintop = 0.00
   SET rptreport->m_marginbottom = 0.00
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 9
   SET rptfont->m_bold = rpt_on
   SET _helvetica9b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica90 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_rgbcolor = uar_rptencodecolor(8,0,0)
   SET _pen14s0c8 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE selectquery(dummy) = null WITH protect
 SUBROUTINE selectquery(ncalc)
   SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
   SET _flmargin = rptreport->m_marginleft
   SET _ftmargin = rptreport->m_margintop
   SET _flabelwidth = 8.500000
   SET _flabelheight = 11.000000
   SET _frowgutter = 0.000000
   SET _fcolgutter = 0.000000
   SET _ncols = 1
   SET _nrows = 1
   SELECT
    tag_per_event_derivative_ind = tag_from_request->tag_per_event[d1.seq].derivative_ind,
    tag_per_event_patient_name = substring(1,40,tag_from_request->tag_per_event[d1.seq].patient_name),
    tag_per_event_patient_location = substring(1,30,tag_from_request->tag_per_event[d1.seq].
     patient_location),
    tag_per_event_patient_id = tag_from_request->tag_per_event[d1.seq].patient_id,
    tag_per_event_patient_aborh_disp = tag_from_request->tag_per_event[d1.seq].patient_aborh_disp,
    tag_per_event_bb_id = substring(1,30,tag_from_request->tag_per_event[d1.seq].bb_id),
    tag_per_event_mrn = substring(1,30,tag_from_request->tag_per_event[d1.seq].mrn),
    tag_per_event_fin = substring(1,30,tag_from_request->tag_per_event[d1.seq].fin),
    tag_per_event_dob = tag_from_request->tag_per_event[d1.seq].dob,
    tag_per_event_sex = tag_from_request->tag_per_event[d1.seq].sex,
    tag_per_event_dispense_physician_name = substring(1,40,tag_from_request->tag_per_event[d1.seq].
     dispense_physician_name), tag_per_event_prod_nbr = substring(1,30,tag_from_request->
     tag_per_event[d1.seq].prod_nbr),
    tag_per_event_serial_nbr = substring(1,30,tag_from_request->tag_per_event[d1.seq].serial_nbr),
    tag_per_event_prod_desc = substring(1,30,tag_from_request->tag_per_event[d1.seq].prod_desc),
    tag_per_event_prod_aborh_disp = tag_from_request->tag_per_event[d1.seq].prod_aborh_disp,
    tag_per_event_prod_expiration = tag_from_request->tag_per_event[d1.seq].prod_expiration,
    tag_per_event_prod_volume = substring(1,30,tag_from_request->tag_per_event[d1.seq].prod_volume),
    tag_per_event_prepared_by = substring(1,30,tag_from_request->tag_per_event[d1.seq].prepared_by),
    tag_per_event_prepared_dttm = tag_from_request->tag_per_event[d1.seq].prepared_dttm,
    tag_per_event_patient_trans_req = substring(1,200,tag_from_request->tag_per_event[d1.seq].
     patient_trans_req), tag_per_event_patient_antibodies = substring(1,200,tag_from_request->
     tag_per_event[d1.seq].patient_antibodies),
    tag_per_event_product_special_testing = substring(1,200,tag_from_request->tag_per_event[d1.seq].
     product_special_testing), tag_per_event_product_antigen = substring(1,200,tag_from_request->
     tag_per_event[d1.seq].product_antigen), tag_per_event_owninvarea_disp = substring(1,50,
     tag_from_request->tag_per_event[d1.seq].owninvarea_disp),
    tag_per_event_crossmatch_interp = substring(1,30,tag_from_request->tag_per_event[d1.seq].
     crossmatch_interp), tag_per_event_qty_iu = substring(1,60,tag_from_request->tag_per_event[d1.seq
     ].qty_iu), tag_per_event_unknown_patient_ind = tag_from_request->tag_per_event[d1.seq].
    unknown_patient_ind,
    address_enc_facility_address1 = substring(1,30,tag_from_request->tag_per_event[d1.seq].address[d2
     .seq].enc_facility_address1), address_enc_facility_address2 = substring(1,30,tag_from_request->
     tag_per_event[d1.seq].address[d2.seq].enc_facility_address2), address_enc_facility_address3 =
    substring(1,30,tag_from_request->tag_per_event[d1.seq].address[d2.seq].enc_facility_address3),
    address_enc_facility_address4 = substring(1,30,tag_from_request->tag_per_event[d1.seq].address[d2
     .seq].enc_facility_address4), address_enc_facility_citystatezip = substring(1,30,
     tag_from_request->tag_per_event[d1.seq].address[d2.seq].enc_facility_citystatezip),
    address_enc_facility_country = substring(1,30,tag_from_request->tag_per_event[d1.seq].address[d2
     .seq].enc_facility_country),
    address_facility_disp = substring(1,30,tag_from_request->tag_per_event[d1.seq].address[d2.seq].
     facility_disp), tag_from_request_bbid_preference = tag_from_request->bbid_preference,
    tag_per_event_alias_mrn_raw = substring(1,30,tag_from_request->tag_per_event[d1.seq].
     alias_mrn_raw),
    tag_per_event_alias_fin_raw = substring(1,30,tag_from_request->tag_per_event[d1.seq].
     alias_fin_raw), tag_per_event_patient_aborh_barcode = substring(1,30,tag_from_request->
     tag_per_event[d1.seq].patient_aborh_barcode), tag_per_event_unit_number_barcode = substring(1,30,
     tag_from_request->tag_per_event[d1.seq].unit_number_barcode),
    tag_per_event_product_type_barcode = substring(1,30,tag_from_request->tag_per_event[d1.seq].
     product_type_barcode), tag_per_event_product_type_barcode_nbr = substring(1,30,tag_from_request
     ->tag_per_event[d1.seq].product_type_barcode_nbr)
    FROM (dummyt d1  WITH seq = value(size(tag_from_request->tag_per_event,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1)
     JOIN (d2)
    HEAD REPORT
     _d0 = tag_per_event_derivative_ind, _d1 = tag_per_event_patient_name, _d2 =
     tag_per_event_patient_location,
     _d3 = tag_per_event_patient_aborh_disp, _d4 = tag_per_event_bb_id, _d5 = tag_per_event_mrn,
     _d6 = tag_per_event_fin, _d7 = tag_per_event_dob, _d8 = tag_per_event_sex,
     _d9 = tag_per_event_dispense_physician_name, _d10 = tag_per_event_prod_nbr, _d11 =
     tag_per_event_serial_nbr,
     _d12 = tag_per_event_prod_desc, _d13 = tag_per_event_prod_aborh_disp, _d14 =
     tag_per_event_prod_expiration,
     _d15 = tag_per_event_prod_volume, _d16 = tag_per_event_prepared_by, _d17 =
     tag_per_event_prepared_dttm,
     _d18 = tag_per_event_patient_trans_req, _d19 = tag_per_event_patient_antibodies, _d20 =
     tag_per_event_product_special_testing,
     _d21 = tag_per_event_product_antigen, _d22 = tag_per_event_owninvarea_disp, _d23 =
     tag_per_event_qty_iu,
     _d24 = tag_per_event_unknown_patient_ind, _d25 = address_enc_facility_address1, _d26 =
     address_enc_facility_address2,
     _d27 = address_enc_facility_address3, _d28 = address_enc_facility_address4, _d29 =
     address_enc_facility_citystatezip,
     _d30 = address_enc_facility_country, _d31 = address_facility_disp, _d32 =
     tag_from_request_bbid_preference,
     _d33 = tag_per_event_alias_mrn_raw, _d34 = tag_per_event_alias_fin_raw, _d35 =
     tag_per_event_unit_number_barcode,
     _d36 = tag_per_event_product_type_barcode, x = 0, y = 0
    DETAIL
     IF (y >= _nrows)
      x = 0, y = 0,
      CALL pagebreak(0)
     ENDIF
     _xoffset = ((_flmargin+ (_flabelwidth * x))+ (_fcolgutter * x)), _yoffset = ((_ftmargin+ (
     _flabelheight * y))+ (_frowgutter * y)), dummy_val = detailsection(rpt_render),
     x += 1
     IF (x >= _ncols)
      x = 0, y += 1
     ENDIF
   ;end select
 END ;Subroutine
 EXECUTE cpm_create_file_name_logical "bbt_tag_emerg_2D", "dat", "x"
 SET rpt_filename = cpm_cfn_info->file_name
 SET _sendto = cpm_cfn_info->file_name_logical
 SET tag_cnt = size(tag_request->taglist,5)
 IF (tag_cnt=0)
  SET tag_cnt = 1
 ENDIF
 SET stat = alterlist(tag_request->taglist,tag_cnt)
 SET stat = alterlist(tag_from_request->tag_per_event,tag_cnt)
 RECORD antibody(
   1 antibodylist[10]
     2 antibody_cd = f8
     2 antibody_disp = c15
     2 trans_req_ind = i2
 )
 RECORD antigen(
   1 antigenlist[10]
     2 antigen_cd = f8
     2 antigen_disp = c15
 )
 RECORD component(
   1 cmpntlist[10]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c40
     2 product_nbr = c20
     2 serial_nbr = c22
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 cur_abo_cd = f8
     2 cur_abo_disp = c20
     2 cur_rh_cd = f8
     2 cur_rh_disp = c20
     2 supplier_prefix = c5
 )
 SET antbdy = 0
 SET antibody_cnt = 0
 SET addtnl_antibody_ind = 0
 DECLARE antibody_disp = c109
 SET antibody_disp = ""
 SET antgen = 0
 SET antigen_cnt = 0
 SET addtnl_antigen_ind = 0
 DECLARE antigen_disp = c109
 SET antigen_disp = ""
 SET cmpnt = 0
 SET cmpnt_cnt = 0
 SET addtnl_cmpnt_ind = 0
 DECLARE cmpnt_disp_row = c109
 SET cmpnt_disp_row = ""
 DECLARE cmpnt_disp = c34
 SET cmpnt_col = 0
 SET rpt_row = 0
 DECLARE tech_name = c15
 DECLARE product_disp = c40
 DECLARE product_desc = c60
 DECLARE product_nbr = c20
 DECLARE serial_nbr = c22
 DECLARE product_sub_nbr = c5
 DECLARE product_flag_chars = c2 WITH public, noconstant("  ")
 DECLARE product_nbr_full = c30
 DECLARE alternate_nbr = c20
 DECLARE segment_nbr = c20
 DECLARE cur_unit_meas_disp = c15
 DECLARE bb_id_nbr = c20
 DECLARE cur_abo_disp = c20
 DECLARE cur_rh_disp = c20
 DECLARE supplier_prefix = c5
 DECLARE accession = c20
 DECLARE xm_result_value_alpha = c15
 DECLARE xm_result_event_prsnl_username = c15
 DECLARE reason_disp = c15
 DECLARE name_full_formatted = c50
 DECLARE alias_mrn = c25
 DECLARE alias_fin = c25
 DECLARE alias_ssn = c25
 DECLARE alias_mrn_formatted = c25
 DECLARE alias_fin_formatted = c25
 DECLARE alias_ssn_formatted = c25
 DECLARE age = c12
 DECLARE sex_disp = c6
 DECLARE patient_location = c30
 DECLARE prvdr_name_full_formatted = c50
 DECLARE person_abo_disp = c20
 DECLARE person_rh_disp = c20
 DECLARE dispense_tech_username = c15
 DECLARE dispense_courier = c50
 DECLARE dispense_prvdr_name = c50
 DECLARE admit_prvdr_name = c50
 DECLARE qty_vol_disp = c36
 DECLARE qty_vol_disp_1 = c36 WITH public, noconstant(" ")
 DECLARE derivative_ind = i2 WITH public, noconstant(0)
 DECLARE patient_name_barcode = vc WITH public, noconstant(" ")
 DECLARE mrn_barcode = vc WITH public, noconstant(" ")
 DECLARE fin_barcode = vc WITH public, noconstant(" ")
 DECLARE dob_barcode = vc WITH public, noconstant(" ")
 DECLARE bbid_barcode = vc WITH public, noconstant(" ")
 DECLARE person_aborh_barcode = vc WITH public, noconstant(" ")
 DECLARE product_barcode_nbr = c20 WITH public, noconstant(" ")
 DECLARE product_num_barcode = vc WITH public, noconstant(" ")
 DECLARE product_type_barcode_nbr = vc WITH public, noconstant(" ")
 DECLARE product_type_barcode = vc WITH public, noconstant(" ")
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(tag_cnt))
  DETAIL
   patient_name_barcode = " ", mrn_barcode = " ", fin_barcode = " ",
   dob_barcode = " ", bbid_barcode = " ", person_aborh_barcode = " ",
   product_num_barcode = " ", pe_event_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].
    pe_event_dt_tm), tech_name = trim(tag_request->taglist[d.seq].tech_name),
   product_disp = trim(tag_request->taglist[d.seq].product_disp), product_desc = trim(tag_request->
    taglist[d.seq].product_desc), product_nbr = trim(tag_request->taglist[d.seq].product_nbr),
   serial_nbr = trim(tag_request->taglist[d.seq].serial_nbr), product_sub_nbr = trim(tag_request->
    taglist[d.seq].product_sub_nbr), product_flag_chars = trim(tag_request->taglist[d.seq].flag_chars
    ),
   product_nbr_full = concat(trim(tag_request->taglist[d.seq].supplier_prefix),trim(tag_request->
     taglist[d.seq].product_nbr)," ",trim(tag_request->taglist[d.seq].product_sub_nbr))
   IF (textlen(trim(product_nbr))=13)
    product_barcode_nbr = concat(trim(tag_request->taglist[d.seq].product_nbr),trim(tag_request->
      taglist[d.seq].flag_chars))
   ELSE
    product_barcode_nbr = trim(tag_request->taglist[d.seq].product_barcode_nbr)
   ENDIF
   IF (textlen(trim(product_barcode_nbr)) > 0)
    IF (findstring("!",trim(product_barcode_nbr),1,0)=1
     AND textlen(trim(product_barcode_nbr)) >= 13
     AND textlen(trim(product_barcode_nbr)) <= 19)
     product_num_barcode = concat("e",trim(product_barcode_nbr),"u")
    ELSEIF (textlen(trim(product_barcode_nbr))=15)
     product_num_barcode = concat("=",trim(product_barcode_nbr),"u")
    ELSE
     product_num_barcode = concat("r",trim(product_barcode_nbr),"u")
    ENDIF
   ENDIF
   alternate_nbr = trim(tag_request->taglist[d.seq].alternate_nbr), segment_nbr = trim(tag_request->
    taglist[d.seq].segment_nbr), product_type_barcode_nbr = tag_request->taglist[d.seq].
   product_type_barcode
   IF (textlen(trim(product_type_barcode_nbr)) > 0)
    product_type_barcode = concat("<",trim(product_type_barcode_nbr),"v")
   ENDIF
   IF ((tag_request->taglist[d.seq].cur_volume > 0))
    cur_volume = trim(cnvtstring(tag_request->taglist[d.seq].cur_volume))
   ELSE
    cur_volume = " "
   ENDIF
   cur_unit_meas_disp = trim(tag_request->taglist[d.seq].cur_unit_meas_disp), bb_id_nbr = trim(
    tag_request->taglist[d.seq].bb_id_nbr)
   IF (textlen(trim(bb_id_nbr)) > 0)
    bbid_barcode = concat("r",trim(bb_id_nbr),"s")
   ENDIF
   product_expire_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].product_expire_dt_tm),
   derivative_ind = tag_request->taglist[d.seq].derivative_ind
   IF ((tag_request->taglist[d.seq].derivative_ind != 1))
    cur_abo_disp = trim(tag_request->taglist[d.seq].cur_abo_disp), cur_rh_disp = trim(tag_request->
     taglist[d.seq].cur_rh_disp), supplier_prefix = trim(tag_request->taglist[d.seq].supplier_prefix),
    qty_vol_disp = concat("VOL: ",trim(cnvtstring(tag_request->taglist[d.seq].cur_volume))," ",trim(
      tag_request->taglist[d.seq].cur_unit_meas_disp)), qty_vol_disp_1 = concat(trim(cnvtstring(
       tag_request->taglist[d.seq].cur_volume))," ",trim(tag_request->taglist[d.seq].
      cur_unit_meas_disp))
   ELSE
    cur_abo_disp = " ", cur_rh_disp = " ", supplier_prefix = " "
    IF ((tag_request->taglist[d.seq].item_unit_per_vial=0))
     qty_vol_disp = concat("QTY: ",trim(cnvtstring(tag_request->taglist[d.seq].quantity)),"  VOL: ",
      trim(cnvtstring(tag_request->taglist[d.seq].item_volume))," ",
      trim(tag_request->taglist[d.seq].item_unit_meas_disp)), qty_vol_disp_1 = concat(trim(cnvtstring
       (tag_request->taglist[d.seq].quantity)),"  VOL: ",trim(cnvtstring(tag_request->taglist[d.seq].
        item_volume))," ",trim(tag_request->taglist[d.seq].item_unit_meas_disp))
    ELSE
     qty_vol_disp = concat("QTY: ",trim(cnvtstring(tag_request->taglist[d.seq].quantity)),
      "  IU PER: ",trim(cnvtstring(tag_request->taglist[d.seq].item_unit_per_vial)),"  TOT IU: ",
      trim(cnvtstring(tag_request->taglist[d.seq].item_volume))), qty_vol_disp_1 = concat(trim(
       cnvtstring(tag_request->taglist[d.seq].quantity)),"  IU PER: ",trim(cnvtstring(tag_request->
        taglist[d.seq].item_unit_per_vial)),"  TOT IU: ",trim(cnvtstring(tag_request->taglist[d.seq].
        item_volume)))
    ENDIF
   ENDIF
   accession = trim(tag_request->taglist[d.seq].accession), xm_result_value_alpha = trim(tag_request
    ->taglist[d.seq].xm_result_value_alpha), xm_result_event_prsnl_username = trim(tag_request->
    taglist[d.seq].xm_result_event_prsnl_username),
   xm_result_event_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].xm_result_event_dt_tm),
   xm_expire_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].xm_expire_dt_tm), reason_disp = trim(
    tag_request->taglist[d.seq].reason_disp)
   IF (((tag_type != emergency_tag) OR ((tag_request->taglist[d.seq].unknown_patient_ind != 1))) )
    name_full_formatted = trim(tag_request->taglist[d.seq].name_full_formatted)
    IF (textlen(trim(name_full_formatted)) > 0)
     patient_name_barcode = concat("r",trim(name_full_formatted),"n")
    ENDIF
    alias_mrn = trim(tag_request->taglist[d.seq].alias_mrn), alias_mrn_formatted = trim(tag_request->
     taglist[d.seq].alias_mrn_formatted)
    IF (textlen(trim(alias_mrn)) > 0)
     mrn_barcode = concat("r",trim(alias_mrn),"i")
    ENDIF
    alias_fin = trim(tag_request->taglist[d.seq].alias_fin), alias_fin_formatted = trim(tag_request->
     taglist[d.seq].alias_fin_formatted)
    IF (textlen(trim(alias_fin)) > 0)
     fin_barcode = concat("r",trim(alias_fin),"f")
    ENDIF
    alias_ssn = trim(tag_request->taglist[d.seq].alias_ssn), alias_ssn_formatted = trim(tag_request->
     taglist[d.seq].alias_ssn_formatted), age = trim(tag_request->taglist[d.seq].age),
    sex_disp = trim(tag_request->taglist[d.seq].sex_disp), patient_location = trim(tag_request->
     taglist[d.seq].patient_location), prvdr_name_full_formatted = trim(tag_request->taglist[d.seq].
     prvdr_name_full_formatted),
    person_abo_disp = trim(tag_request->taglist[d.seq].person_abo_disp), person_rh_disp = trim(
     tag_request->taglist[d.seq].person_rh_disp)
    IF (textlen(trim(tag_request->taglist[d.seq].person_aborh_barcode)) > 0)
     person_aborh_barcode = concat("r",trim(tag_request->taglist[d.seq].person_aborh_barcode),"b")
    ENDIF
    birth_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].birth_dt_tm)
    IF (birth_dt_tm > 0)
     dob_barcode = build("r",cnvtstring(year(birth_dt_tm)),format(cnvtstring(julian(birth_dt_tm)),
       "###;P0;"),format(cnvtstring(hour(birth_dt_tm)),"##;P0;"),format(cnvtstring(minute(birth_dt_tm
         )),"##;P0;"),
      "s")
    ENDIF
   ELSE
    name_full_formatted = tag_request->taglist[d.seq].unknown_patient_text
    IF (textlen(trim(name_full_formatted)) > 0)
     patient_name_barcode = concat("r",trim(name_full_formatted),"n")
    ENDIF
    alias_mrn = " ", mrn_barcode = " ", alias_fin = " ",
    fin_barcode = " ", age = " ", sex_disp = " ",
    patient_location = " ", prvdr_name_full_formatted = " ", person_abo_disp = " ",
    person_rh_disp = " ", person_aborh_barcode = " ", birth_dt_tm = cnvtdatetime(""),
    dob_barcode = " "
   ENDIF
   antibody_cnt = cnvtint(tag_request->taglist[d.seq].antibody_cnt), stat = alter(antibody->
    antibodylist,tag_request->taglist[d.seq].antibody_cnt)
   FOR (antbdy = 1 TO antibody_cnt)
     antibody->antibodylist[antbdy].antibody_cd = tag_request->taglist[d.seq].antibodylist[antbdy].
     antibody_cd, antibody->antibodylist[antbdy].antibody_disp = trim(tag_request->taglist[d.seq].
      antibodylist[antbdy].antibody_disp), antibody->antibodylist[antbdy].trans_req_ind = tag_request
     ->taglist[d.seq].antibodylist[antbdy].trans_req_ind
   ENDFOR
   antigen_cnt = cnvtint(tag_request->taglist[d.seq].antigen_cnt), stat = alter(antigen->antigenlist,
    tag_request->taglist[d.seq].antigen_cnt)
   FOR (antgen = 1 TO antigen_cnt)
    antigen->antigenlist[antgen].antigen_cd = tag_request->taglist[d.seq].antigenlist[antgen].
    antigen_cd,antigen->antigenlist[antgen].antigen_disp = trim(tag_request->taglist[d.seq].
     antigenlist[antgen].antigen_disp)
   ENDFOR
   cmpnt_cnt = tag_request->taglist[d.seq].cmpnt_cnt, stat = alter(component->cmpntlist,tag_request->
    taglist[d.seq].cmpnt_cnt)
   FOR (cmpnt = 1 TO cmpnt_cnt)
     component->cmpntlist[cmpnt].product_id = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_id,
     component->cmpntlist[cmpnt].product_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_cd,
     component->cmpntlist[cmpnt].product_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      product_disp),
     component->cmpntlist[cmpnt].product_nbr = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      product_nbr), component->cmpntlist[cmpnt].serial_nbr = trim(tag_request->taglist[d.seq].
      cmpntlist[cmpnt].serial_nbr), component->cmpntlist[cmpnt].product_sub_nbr = trim(tag_request->
      taglist[d.seq].cmpntlist[cmpnt].product_sub_nbr),
     component->cmpntlist[cmpnt].cur_abo_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_abo_cd,
     component->cmpntlist[cmpnt].cur_abo_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      cur_abo_disp), component->cmpntlist[cmpnt].supplier_prefix = trim(tag_request->taglist[d.seq].
      cmpntlist[cmpnt].supplier_prefix),
     component->cmpntlist[cmpnt].cur_rh_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_rh_cd,
     component->cmpntlist[cmpnt].cur_rh_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      cur_rh_disp)
   ENDFOR
   dispense_tech_username = trim(tag_request->taglist[d.seq].dispense_tech_username), dispense_dt_tm
    = cnvtdatetime(tag_request->taglist[d.seq].dispense_dt_tm), dispense_courier = trim(tag_request->
    taglist[d.seq].dispense_courier),
   dispense_prvdr_name = trim(tag_request->taglist[d.seq].dispense_prvdr_name), tag_from_request->
   bbid_preference = tag_request->bbid_preference_ind, tag_from_request->tag_per_event[d.seq].
   derivative_ind = tag_request->taglist[d.seq].derivative_ind,
   tag_from_request->tag_per_event[d.seq].unknown_patient_ind = tag_request->taglist[d.seq].
   unknown_patient_ind, tag_from_request->tag_per_event[d.seq].patient_name = trim(
    name_full_formatted), tag_from_request->tag_per_event[d.seq].prod_nbr = product_nbr_full,
   tag_from_request->tag_per_event[d.seq].serial_nbr = serial_nbr, tag_from_request->tag_per_event[d
   .seq].product_type_barcode = product_type_barcode, tag_from_request->tag_per_event[d.seq].
   product_type_barcode_nbr = product_type_barcode_nbr,
   tag_from_request->tag_per_event[d.seq].unit_number_barcode = product_barcode_nbr, tag_from_request
   ->tag_per_event[d.seq].prod_desc = product_desc, tag_from_request->tag_per_event[d.seq].
   prod_aborh_disp = trim(concat(trim(cur_abo_disp)," ",trim(cur_rh_disp)))
   IF (product_expire_dt_tm > 0)
    tag_from_request->tag_per_event[d.seq].prod_expiration = concat(format(cnvtdatetime(
       product_expire_dt_tm),"@SHORTDATE4YR")," ",format(cnvtdatetime(product_expire_dt_tm),
      "@TIMENOSECONDS"))
   ENDIF
   IF ((tag_from_request->tag_per_event[d.seq].derivative_ind != 1))
    tag_from_request->tag_per_event[d.seq].prod_volume =
    IF (cur_volume != null) concat(trim(cur_volume)," ",trim(cur_unit_meas_disp))
    ELSE ""
    ENDIF
   ELSE
    tag_from_request->tag_per_event[d.seq].qty_iu = qty_vol_disp
   ENDIF
   tag_from_request->tag_per_event[d.seq].product_special_testing = "", tag_from_request->
   tag_per_event[d.seq].product_antigen = ""
   FOR (agencnt = 1 TO antigen_cnt)
     IF (uar_get_code_meaning(antigen->antigenlist[agencnt].antigen_cd) IN ("+", "-"))
      IF ((tag_from_request->tag_per_event[d.seq].product_antigen != ""))
       tag_from_request->tag_per_event[d.seq].product_antigen = build(concat(tag_from_request->
         tag_per_event[d.seq].product_antigen,",",antigen->antigenlist[agencnt].antigen_disp))
      ELSE
       tag_from_request->tag_per_event[d.seq].product_antigen = antigen->antigenlist[agencnt].
       antigen_disp
      ENDIF
     ELSEIF (uar_get_code_meaning(antigen->antigenlist[agencnt].antigen_cd)="SPTYP")
      IF ((tag_from_request->tag_per_event[d.seq].product_special_testing != ""))
       tag_from_request->tag_per_event[d.seq].product_special_testing = build(concat(tag_from_request
         ->tag_per_event[d.seq].product_special_testing,",",antigen->antigenlist[agencnt].
         antigen_disp))
      ELSE
       tag_from_request->tag_per_event[d.seq].product_special_testing = antigen->antigenlist[agencnt]
       .antigen_disp
      ENDIF
     ENDIF
   ENDFOR
   owner_area_disp = uar_get_code_display(tag_request->taglist[d.seq].owner_area), inv_area_disp =
   uar_get_code_display(tag_request->taglist[d.seq].inventory_area), tag_from_request->tag_per_event[
   d.seq].owninvarea_disp = trim(concat(trim(owner_area_disp)," ",trim(inv_area_disp)))
   IF ((((tag_request->tag_type != "EMERGENCY")) OR ((tag_request->taglist[d.seq].unknown_patient_ind
    != 1))) )
    tag_from_request->tag_per_event[d.seq].patient_id = tag_request->taglist[d.seq].person_id,
    tag_from_request->tag_per_event[d.seq].patient_aborh_disp = trim(concat(trim(person_abo_disp)," ",
      trim(person_rh_disp))), tag_from_request->tag_per_event[d.seq].patient_aborh_barcode = trim(
     tag_request->taglist[d.seq].person_aborh_barcode),
    tag_from_request->tag_per_event[d.seq].patient_location = trim(patient_location),
    tag_from_request->tag_per_event[d.seq].bb_id = bb_id_nbr, tag_from_request->tag_per_event[d.seq].
    mrn = alias_mrn_formatted,
    tag_from_request->tag_per_event[d.seq].alias_mrn_raw = alias_mrn, tag_from_request->
    tag_per_event[d.seq].alias_fin_raw = alias_fin, tag_from_request->tag_per_event[d.seq].fin =
    alias_fin_formatted,
    tag_from_request->tag_per_event[d.seq].dob = format(birth_dt_tm,"@SHORTDATE4YR;;D"),
    tag_from_request->tag_per_event[d.seq].sex = sex_disp, tag_from_request->tag_per_event[d.seq].
    patient_antibodies = "",
    tag_from_request->tag_per_event[d.seq].patient_trans_req = ""
    FOR (acnt = 1 TO antibody_cnt)
      IF ((antibody->antibodylist[acnt].trans_req_ind=0))
       IF ((tag_from_request->tag_per_event[d.seq].patient_antibodies != null))
        tag_from_request->tag_per_event[d.seq].patient_antibodies = build(concat(tag_from_request->
          tag_per_event[d.seq].patient_antibodies,",",antibody->antibodylist[acnt].antibody_disp))
       ELSE
        tag_from_request->tag_per_event[d.seq].patient_antibodies = antibody->antibodylist[acnt].
        antibody_disp
       ENDIF
      ELSE
       IF ((tag_from_request->tag_per_event[d.seq].patient_trans_req != null))
        tag_from_request->tag_per_event[d.seq].patient_trans_req = build(concat(tag_from_request->
          tag_per_event[d.seq].patient_trans_req,",",antibody->antibodylist[acnt].antibody_disp))
       ELSE
        tag_from_request->tag_per_event[d.seq].patient_trans_req = antibody->antibodylist[acnt].
        antibody_disp
       ENDIF
      ENDIF
    ENDFOR
    stat = alterlist(tag_request->taglist[d.seq].address,1), stat = alterlist(tag_from_request->
     tag_per_event[d.seq].address,1), tag_from_request->tag_per_event[d.seq].address[1].facility_disp
     = uar_get_code_display(tag_request->taglist[d.seq].address[1].enc_loc_facility_cd),
    tag_from_request->tag_per_event[d.seq].address[1].enc_facility_address1 = trim(tag_request->
     taglist[d.seq].address[1].enc_facility_address1), tag_from_request->tag_per_event[d.seq].
    address[1].enc_facility_address2 = trim(tag_request->taglist[d.seq].address[1].
     enc_facility_address2), tag_from_request->tag_per_event[d.seq].address[1].enc_facility_address3
     = trim(tag_request->taglist[d.seq].address[1].enc_facility_address3),
    tag_from_request->tag_per_event[d.seq].address[1].enc_facility_citystatezip = trim(tag_request->
     taglist[d.seq].address[1].enc_facility_citystatezip), tag_from_request->tag_per_event[d.seq].
    address[1].enc_facility_country = trim(tag_request->taglist[d.seq].address[1].
     enc_facility_country)
   ENDIF
   tag_from_request->tag_per_event[d.seq].prepared_by = tech_name
   IF ((((tag_request->tag_type="COMPONENT")) OR ((tag_request->tag_type="EMERGENCY")
    AND (tag_request->taglist[d.seq].unknown_patient_ind != 1))) )
    tag_from_request->tag_per_event[d.seq].dispense_physician_name = dispense_prvdr_name
    IF ((tag_request->sub_tag_type != "BLANK"))
     tag_from_request->tag_per_event[d.seq].unit_count = cnvtstring(cmpnt_cnt)
    ENDIF
    IF (pe_event_dt_tm > 0)
     tag_from_request->tag_per_event[d.seq].prepared_dttm = concat(format(cnvtdatetime(pe_event_dt_tm
        ),"@SHORTDATE4YR")," ",format(cnvtdatetime(pe_event_dt_tm),"@TIMENOSECONDS"))
    ENDIF
   ELSEIF ((tag_request->tag_type="CROSSMATCH"))
    tag_from_request->tag_per_event[d.seq].crossmatch_interp = xm_result_value_alpha,
    tag_from_request->tag_per_event[d.seq].crossmatch_verified_by = xm_result_event_prsnl_username
    IF (xm_result_event_dt_tm > 0)
     tag_from_request->tag_per_event[d.seq].crossmatch_dttm = concat(format(cnvtdatetime(
        xm_result_event_dt_tm),"@SHORTDATE4YR")," ",format(cnvtdatetime(xm_result_event_dt_tm),
       "@TIMENOSECONDS"))
    ENDIF
    tag_from_request->tag_per_event[d.seq].accession_nbr = accession, tag_from_request->
    tag_per_event[d.seq].ordering_physician_name = prvdr_name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 CALL initializereport(0)
 CALL selectquery(0)
 CALL finalizereport(_sendto)
END GO
