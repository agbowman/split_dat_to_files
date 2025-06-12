CREATE PROGRAM ccps_pha_lbt_pass
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE reportrtl
 RECORD label_data(
   1 batch_description = vc
   1 dispense
     2 id = f8
     2 category = c40
     2 device_ind = i2
     2 from_cd = f8
     2 from_location = vc
   1 facility
     2 address
       3 address_formatted = vc
       3 street = vc
       3 city = vc
       3 state = vc
       3 zipcode = vc
     2 description = c40
     2 phone = vc
   1 fill_cycle
     2 start_dt_tm = dq8
     2 start_dt_tm_formatted = vc
     2 stop_dt_tm = dq8
     2 stop_dt_tm_formatted = vc
   1 ingredient_list
     2 description = vc
     2 dose = vc
     2 quantity_form = vc
     2 generic_name = vc
     2 label_description = vc
     2 description_dose = vc
     2 generic_name_dose = vc
     2 label_description_dose = vc
     2 gen_name_dose_normrate = vc
   1 ingredients[*]
     2 description = vc
     2 label_description = vc
     2 sequence = i4
     2 dose
       3 form_description = c40
       3 form_display = vc
       3 quantity = f8
       3 quantity_unit = c40
       3 quantity_string = vc
     2 freetext_dose = vc
     2 identifiers
       3 cdm = c25
       3 brand_name = vc
       3 generic_name = vc
       3 ndc = c13
     2 strength = f8
     2 strength_unit = c40
     2 strength_string = vc
     2 volume = f8
     2 volume_unit = c40
     2 volume_string = vc
     2 normrate = vc
   1 label
     2 comment1 = vc
     2 comment2 = vc
     2 description = c40
     2 type = c40
     2 type_meaning = c12
   1 med
     2 charge_quantity = f8
     2 count = i4
     2 credit_quantity = f8
     2 description = vc
     2 dose
       3 form_description = c40
       3 form_display = vc
       3 quantity = f8
       3 quantity_unit = c40
       3 quantity_string = vc
     2 dose_route_freq = vc
     2 fill_dose_units = vc
     2 fill_note = vc
     2 fill_quantity = f8
     2 fill_quantity_string = vc
     2 floorstock_ind = i2
     2 formulary_status = c40
     2 frequency = c40
     2 frequency_type_flag = i2
     2 freetext_dose = vc
     2 freetext_rate = vc
     2 identifiers
       3 cdm = c25
       3 brand_name = vc
       3 generic_name = vc
       3 manufacturer = vc
       3 ndc = c13
     2 ingredient
       3 count = i4
       3 description = vc
       3 sequence = i4
     2 iv
       3 bag_nbr = i4
       3 bag_nbr_calc = i4
       3 in_sequence = i4
       3 infuse_over = f8
       3 infuse_over_string = vc
       3 infuse_unit = c40
       3 rate_ml_hr = f8
       3 rate_ml_hr_string = vc
       3 replace_every = f8
       3 replace_every_unit = c40
       3 replace_every_string = vc
       3 rate = f8
       3 set_size = i4
     2 legal_status = c40
     2 normalized_rate = f8
     2 normalized_rate_unit = c40
     2 normalized_rate_string = vc
     2 note = vc
     2 package
       3 count = f8
       3 number = i4
       3 quantity = i4
     2 pick_quantity_string = vc
     2 prn = c3
     2 prn_reason = vc
     2 route = c40
     2 strength = f8
     2 strength_unit = c40
     2 strength_string = vc
     2 template_nonformulary_id = f8
     2 therapeutic
       3 class = vc
       3 class_code = c20
       3 class_sort = c20
     2 titrate_ind = i2
     2 total_volume = f8
     2 total_volume_string = vc
     2 volume = f8
     2 volume_unit = c40
     2 volume_string = vc
   1 misc
     2 update_id = f8
     2 update_dt_tm = dq8
     2 update_dt_tm_formatted = vc
     2 fill_hx_id = vc
     2 duplicate_print_ind = i2
   1 order_info
     2 id = vc
     2 action_meaning = c12
     2 admin_count = i4
     2 comment = vc
     2 cost = f8
     2 description = vc
     2 interactions = vc
     2 needs_verify_flag = i2
     2 needs_rx_verify_flag = i2
     2 ordered_as_mnemonic = vc
     2 price = f8
     2 priority_cd = f8
     2 priority = vc
     2 status_flag = i4
     2 status_description = c40
     2 type = i4
     2 type_flag = i2
     2 dates
       3 entered_dt_tm = dq8
       3 entered_dt_tm_formatted = vc
       3 admin_dt_tm = dq8
       3 admin_dt_tm_formatted = vc
       3 start_dt_tm = dq8
       3 start_dt_tm_formatted = vc
       3 stop_dt_tm = dq8
       3 stop_dt_tm_formatted = vc
       3 soft_stop_dt_tm = dq8
       3 soft_stop_dt_tm_formatted = vc
       3 status_dt_tm = dq8
       3 status_dt_tm_formatted = vc
       3 original_order_dt_tm = dq8
       3 original_order_dt_tm_formatted = vc
   1 person
     2 address
       3 street = vc
       3 city = vc
       3 state = vc
       3 zipcode = vc
       3 address_formatted = vc
     2 age = c12
     2 bed = c40
     2 birth_dt_tm = dq8
     2 birth_dt_tm_formatted = vc
     2 fin_nbr = vc
     2 loc_room_bed = vc
     2 location = c40
     2 med_rec_nbr = vc
     2 name = vc
     2 phone = vc
     2 race = c40
     2 room = c40
     2 sex = c40
   1 personnel
     2 admitting_physician_name = vc
     2 attending_physician_name = vc
     2 ordering_physician_name = vc
     2 pharmacist_id = f8
     2 pharmacist_name = vc
     2 pharmacist_initials = c8
   1 run
     2 id = f8
     2 run_type_meaning = c12
     2 user_name = vc
     2 user_username = vc
   1 user_defined
     2 clinical_result_1 = vc
     2 clinical_result_2 = vc
     2 encounter_alias_1 = vc
     2 encounter_alias_2 = vc
     2 med_identifier_1 = vc
     2 med_identifier_2 = vc
     2 med_identifier_3 = vc
     2 order_detail_1 = vc
     2 order_detail_2 = vc
     2 person_alias_1 = vc
     2 person_alias_2 = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE phys_sec(ncalc=i2) = f8 WITH protect
 DECLARE phys_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE label_description_sec(ncalc=i2) = f8 WITH protect
 DECLARE label_description_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE brand_name_sec(ncalc=i2) = f8 WITH protect
 DECLARE brand_name_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE comment1_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE comment1_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE comment2_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE comment2_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE footer_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE footer_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _bsubreport = i1 WITH noconstant(0), protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
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
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(16), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_zebra), protect
 DECLARE _remlabel_comment1 = i2 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontcomment1_sec = i2 WITH noconstant(0), protect
 DECLARE _remlabel_comment2 = i2 WITH noconstant(1), protect
 DECLARE _bcontcomment2_sec = i2 WITH noconstant(0), protect
 DECLARE _remcaution_literal = i2 WITH noconstant(1), protect
 DECLARE _bcontfooter_sec = i2 WITH noconstant(0), protect
 DECLARE _default80 = i4 WITH noconstant(0), protect
 DECLARE _default100 = i4 WITH noconstant(0), protect
 DECLARE _default60 = i4 WITH noconstant(0), protect
 DECLARE _pen5s0c0 = i4 WITH noconstant(0), protect
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
    SET spool value(sfilename) value(ssendreport) WITH deleted
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
 SUBROUTINE phys_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = phys_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE phys_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE __personnel_ordering_physician_name = vc WITH noconstant(build2(concat("Ordering Dr: ",
      label_data->personnel.ordering_physician_name),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.002)
    SET rptsd->m_width = 2.917
    SET rptsd->m_height = 0.135
    SET _oldfont = uar_rptsetfont(_hreport,_default80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__personnel_ordering_physician_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE label_description_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = label_description_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE label_description_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE __label_description = vc WITH noconstant(build2(label_data->ingredients[ingred_idx].
     label_description,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 8
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.002)
    SET rptsd->m_width = 2.917
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_default100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label_description)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE brand_name_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = brand_name_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE brand_name_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE __brand_name = vc WITH noconstant(build2(concat("For Brand Name: ",trim(label_data->
       ingredients[ingred_idx].identifiers.brand_name)),char(0))), protect
   IF ( NOT ((label_data->ingredients[ingred_idx].identifiers.brand_name > " ")))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 8
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.002)
    SET rptsd->m_width = 2.917
    SET rptsd->m_height = 0.135
    SET _oldfont = uar_rptsetfont(_hreport,_default80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__brand_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE comment1_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = comment1_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE comment1_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_comment1 = f8 WITH noconstant(0.0), private
   DECLARE __label_comment1 = vc WITH noconstant(build2(label_data->label.comment1,char(0))), protect
   IF ( NOT ((label_data->label.comment1 > " ")))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_comment1 = 1
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
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_default80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_comment1 = _remlabel_comment1
   IF (_remlabel_comment1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_comment1,((size(
        __label_comment1) - _remlabel_comment1)+ 1),__label_comment1)))
    SET drawheight_label_comment1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_comment1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_comment1,((size(__label_comment1
        ) - _remlabel_comment1)+ 1),__label_comment1)))))
     SET _remlabel_comment1 = (_remlabel_comment1+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_comment1 = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_comment1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = drawheight_label_comment1
   IF (ncalc=rpt_render
    AND _holdremlabel_comment1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_comment1,((
       size(__label_comment1) - _holdremlabel_comment1)+ 1),__label_comment1)))
   ELSE
    SET _remlabel_comment1 = _holdremlabel_comment1
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
 SUBROUTINE comment2_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = comment2_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE comment2_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_label_comment2 = f8 WITH noconstant(0.0), private
   DECLARE __label_comment2 = vc WITH noconstant(build2(label_data->label.comment2,char(0))), protect
   IF ( NOT ((label_data->label.comment2 > " ")))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remlabel_comment2 = 1
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
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_default80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremlabel_comment2 = _remlabel_comment2
   IF (_remlabel_comment2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlabel_comment2,((size(
        __label_comment2) - _remlabel_comment2)+ 1),__label_comment2)))
    SET drawheight_label_comment2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlabel_comment2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlabel_comment2,((size(__label_comment2
        ) - _remlabel_comment2)+ 1),__label_comment2)))))
     SET _remlabel_comment2 = (_remlabel_comment2+ rptsd->m_drawlength)
    ELSE
     SET _remlabel_comment2 = 0
    ENDIF
    SET growsum = (growsum+ _remlabel_comment2)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = drawheight_label_comment2
   IF (ncalc=rpt_render
    AND _holdremlabel_comment2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlabel_comment2,((
       size(__label_comment2) - _holdremlabel_comment2)+ 1),__label_comment2)))
   ELSE
    SET _remlabel_comment2 = _holdremlabel_comment2
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
 SUBROUTINE footer_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footer_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footer_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_caution_literal = f8 WITH noconstant(0.0), private
   DECLARE __fill_qty = vc WITH noconstant(build2(label_data->med.pick_quantity_string,char(0))),
   protect
   DECLARE __caution_literal = vc WITH noconstant(build2(
     "CAUTION: Federal law PROHIBITS the transfer of this drug to any person other than the patient for whom it was prescribed.",
     char(0))), protect
   IF (bcontinue=0)
    SET _remcaution_literal = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.292)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_default60)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcaution_literal = _remcaution_literal
   IF (_remcaution_literal > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcaution_literal,((size
       (__caution_literal) - _remcaution_literal)+ 1),__caution_literal)))
    SET drawheight_caution_literal = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcaution_literal = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcaution_literal,((size(
        __caution_literal) - _remcaution_literal)+ 1),__caution_literal)))))
     SET _remcaution_literal = (_remcaution_literal+ rptsd->m_drawlength)
    ELSE
     SET _remcaution_literal = 0
    ENDIF
    SET growsum = (growsum+ _remcaution_literal)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 1.970)
   SET rptsd->m_width = 0.448
   SET rptsd->m_height = 0.135
   SET _dummyfont = uar_rptsetfont(_hreport,_default80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fill_qty)
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.292)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 2.917
   SET rptsd->m_height = drawheight_caution_literal
   SET _dummyfont = uar_rptsetfont(_hreport,_default60)
   IF (ncalc=rpt_render
    AND _holdremcaution_literal > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcaution_literal,((
       size(__caution_literal) - _holdremcaution_literal)+ 1),__caution_literal)))
   ELSE
    SET _remcaution_literal = _holdremcaution_literal
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 0.271
   SET rptsd->m_height = 0.135
   SET _dummyfont = uar_rptsetfont(_hreport,_default80)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FILL:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 0.939)
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.135
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RPh:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.273),(offsety+ 0.234),(offsetx+ 0.825),(offsety+
     0.234))
   ENDIF
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.325),(offsety+ 0.234),(offsetx+ 1.877),(offsety+
     0.234))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.002)
   SET rptsd->m_width = 0.271
   SET rptsd->m_height = 0.135
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mfr:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.273),(offsety+ 0.109),(offsetx+ 0.825),(offsety+
     0.109))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.939)
   SET rptsd->m_width = 0.271
   SET rptsd->m_height = 0.135
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Lot#:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.325),(offsety+ 0.109),(offsetx+ 1.877),(offsety+
     0.109))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.970)
   SET rptsd->m_width = 0.271
   SET rptsd->m_height = 0.135
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Exp:",char(0)))
   ENDIF
   SET _dummypen = uar_rptsetpen(_hreport,_pen5s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.283),(offsety+ 0.109),(offsetx+ 2.835),(offsety+
     0.109))
   ENDIF
   SET rptsd->m_flags = 1024
   SET rptsd->m_y = (offsety+ 0.125)
   SET rptsd->m_x = (offsetx+ 2.523)
   SET rptsd->m_width = 0.396
   SET rptsd->m_height = 0.135
   SET _dummyfont = uar_rptsetfont(_hreport,_default60)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No Refills",char(0)))
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CCPS_PHA_LBT_PASS"
   SET rptreport->m_pagewidth = 3.00
   SET rptreport->m_pageheight = 1.00
   SET rptreport->m_orientation = rpt_invportrait
   SET rptreport->m_marginleft = 0.04
   SET rptreport->m_marginright = 0.04
   SET rptreport->m_margintop = 0.04
   SET rptreport->m_marginbottom = 0.04
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _default100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _default80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET _default60 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.005
   SET _pen5s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SELECT INTO "NL:"
  p_printer_type_cdf = uar_get_code_meaning(p.printer_type_cd)
  FROM output_dest o,
   device d,
   printer p
  PLAN (o
   WHERE cnvtupper(o.name)=cnvtupper(trim(label_rec->qual[label_rec_ndx].output_device_s)))
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
   IF (_xdiv > 1)
    _xshift = (cnvtreal(o.label_xpos)/ _xdiv)
   ENDIF
   IF (_xdiv > 1)
    _yshift = (cnvtreal(o.label_ypos)/ _ydiv)
   ENDIF
  WITH nocounter
 ;end select
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _bsubreport = 1
 EXECUTE ccps_pha_lbt_header_addr  $1
 SET _bsubreport = 0
 SET _fdrawheight = phys_sec(rpt_calcheight)
 IF (((_yoffset+ _fdrawheight) > _fenddetail))
  CALL pagebreak(0)
 ENDIF
 SET dummy_val = phys_sec(rpt_render)
 FOR (ingred_idx = 1 TO size(label_data->ingredients,5))
   SET _fdrawheight = label_description_sec(rpt_calcheight)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = label_description_sec(rpt_render)
   SET _fdrawheight = brand_name_sec(rpt_calcheight)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = brand_name_sec(rpt_render)
 ENDFOR
 SET bfirsttime = 1
 WHILE (((_bcontcomment1_sec=1) OR (bfirsttime=1)) )
   SET _bholdcontinue = _bcontcomment1_sec
   SET _fdrawheight = comment1_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = comment1_sec(rpt_render,(_fenddetail - _yoffset),_bcontcomment1_sec)
   SET bfirsttime = 0
 ENDWHILE
 SET bfirsttime = 1
 WHILE (((_bcontcomment2_sec=1) OR (bfirsttime=1)) )
   SET _bholdcontinue = _bcontcomment2_sec
   SET _fdrawheight = comment2_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = comment2_sec(rpt_render,(_fenddetail - _yoffset),_bcontcomment2_sec)
   SET bfirsttime = 0
 ENDWHILE
 SET bfirsttime = 1
 WHILE (((_bcontfooter_sec=1) OR (bfirsttime=1)) )
   SET _bholdcontinue = _bcontfooter_sec
   SET _fdrawheight = footer_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
   IF (((_yoffset+ _fdrawheight) > _fenddetail))
    CALL pagebreak(0)
   ENDIF
   SET dummy_val = footer_sec(rpt_render,(_fenddetail - _yoffset),_bcontfooter_sec)
   SET bfirsttime = 0
 ENDWHILE
 CALL finalizereport(_sendto)
END GO
