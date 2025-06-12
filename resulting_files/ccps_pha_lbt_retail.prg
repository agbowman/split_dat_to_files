CREATE PROGRAM ccps_pha_lbt_retail
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
 RECORD preproc_ret(
   1 qual[*]
     2 rx_nbr = vc
     2 sig = vc
     2 disp_qty = vc
     2 refills_remain = i2
     2 exp_dt_tm = dq8
     2 lot_nbr = vc
     2 cost = f8
     2 pat_pd = f8
     2 payment_method = vc
     2 phys_id = f8
     2 phys_dea = vc
     2 ord_phys_address_street = vc
     2 ord_phys_address_city = vc
     2 ord_phys_address_state = vc
     2 ord_phys_zipcode = vc
     2 warn_lbl_cnt = i2
     2 warn_lbl[*]
       3 label_nbr = i2
       3 label_txt = vc
 )
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE layout_query(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE overlay_sec(ncalc=i2) = f8 WITH protect
 DECLARE tablerow(ncalc=i2) = f8 WITH protect
 DECLARE tablerowabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE tablerow1(ncalc=i2) = f8 WITH protect
 DECLARE tablerow1abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE overlay_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE outerlabel_sec(ncalc=i2) = f8 WITH protect
 DECLARE outerlabel_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE outerlabelsig_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE outerlabelsig_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE innerlabel_sec(ncalc=i2) = f8 WITH protect
 DECLARE innerlabel_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE innerlabelsig_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE innerlabelsig_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE warninglabel_sec(ncalc=i2) = f8 WITH protect
 DECLARE warninglabel_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE baglabel_sec(ncalc=i2) = f8 WITH protect
 DECLARE baglabel_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE paymentmethod_sec(ncalc=i2) = f8 WITH protect
 DECLARE paymentmethod_secabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE overflowsig_sec(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE overflowsig_secabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE initializereport(dummy) = null WITH protect
 IF (validate(_bsubreport) != 1)
  DECLARE _bsubreport = i1 WITH noconstant(0), protect
 ENDIF
 IF (_bsubreport=0)
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 ENDIF
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
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remsig = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontouterlabelsig_sec = i2 WITH noconstant(0), protect
 DECLARE _remsig = i4 WITH noconstant(1), protect
 DECLARE _bcontinnerlabelsig_sec = i2 WITH noconstant(0), protect
 DECLARE _remol_overflowsig = i4 WITH noconstant(1), protect
 DECLARE _remil_overflowsig = i4 WITH noconstant(1), protect
 DECLARE _bcontoverflowsig_sec = i2 WITH noconstant(0), protect
 DECLARE _helvetica80 = i4 WITH noconstant(0), protect
 DECLARE _helvetica60 = i4 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica6b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE sig = vc WITH noconstant(trim(preproc_ret->qual[label_rec_ndx].sig)), protect
 DECLARE ol_sig = vc WITH noconstant(sig), protect
 DECLARE ol_overflowsig = vc WITH noconstant(" "), protect
 DECLARE il_sig = vc WITH noconstant(sig), protect
 DECLARE il_overflowsig = vc WITH noconstant(" "), protect
 SUBROUTINE layout_query(dummy)
   SELECT
    FROM (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,evaluate(preproc_ret->qual[d1.seq].warn_lbl_cnt,0,1,preproc_ret->qual[d1.seq].
       warn_lbl_cnt)))
     JOIN (d2)
    ORDER BY d1.seq, d2.seq
    HEAD REPORT
     _d0 = d2.seq, _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    HEAD d1.seq
     sig_height = outerlabelsig_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     WHILE (sig_height > 0.67)
       wordbreak = findstring(" ",ol_sig,1,1), ol_sig = substring(1,(wordbreak - 1),sig),
       ol_overflowsig = substring((wordbreak+ 1),(textlen(sig) - wordbreak),sig),
       sig_height = outerlabelsig_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     ENDWHILE
     sig_height = innerlabelsig_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     WHILE (sig_height > 0.51)
       wordbreak = findstring(" ",il_sig,1,1), il_sig = substring(1,(wordbreak - 1),sig),
       il_overflowsig = substring((wordbreak+ 1),(textlen(sig) - wordbreak),sig),
       sig_height = innerlabelsig_sec(rpt_calcheight,(_fenddetail - _yoffset),_bholdcontinue)
     ENDWHILE
     _fdrawheight = outerlabel_sec(rpt_calcheight)
     IF (_fdrawheight > 0)
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _fdrawheight = (_fdrawheight+ innerlabel_sec(rpt_calcheight))
      ENDIF
      IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
       _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ innerlabelsig_sec(rpt_calcheight,((
        _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
       IF (_bholdcontinue=1)
        _fdrawheight = (_fenddetail+ 1)
       ENDIF
      ENDIF
     ENDIF
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = outerlabel_secabs(rpt_render,_xoffset,0.318), _bcontouterlabelsig_sec = 0,
     bfirsttime = 1
     WHILE (((_bcontouterlabelsig_sec=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontouterlabelsig_sec, _fdrawheight = outerlabelsig_sec(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_bholdcontinue=1) OR (_fdrawheight > 0)) )
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ innerlabelsig_sec(rpt_calcheight,((
          _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontouterlabelsig_sec=0)
        BREAK
       ENDIF
       dummy_val = outerlabelsig_secabs(rpt_render,_xoffset,0.808,(_fenddetail - 0.808),
        _bcontouterlabelsig_sec), bfirsttime = 0
     ENDWHILE
     _fdrawheight = innerlabel_sec(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = innerlabel_secabs(rpt_render,_xoffset,0.318), _bcontinnerlabelsig_sec = 0,
     bfirsttime = 1
     WHILE (((_bcontinnerlabelsig_sec=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontinnerlabelsig_sec, _fdrawheight = innerlabelsig_sec(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontinnerlabelsig_sec=0)
        BREAK
       ENDIF
       dummy_val = innerlabelsig_secabs(rpt_render,_xoffset,0.757,(_fenddetail - 0.757),
        _bcontinnerlabelsig_sec), bfirsttime = 0
     ENDWHILE
     _yoffset = 0.380
    HEAD d2.seq
     row + 0
    DETAIL
     _fdrawheight = warninglabel_sec(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = warninglabel_sec(rpt_render)
    FOOT  d2.seq
     row + 0
    FOOT  d1.seq
     FOR (baglabel_sec_ndx = 1 TO 2)
       IF (baglabel_sec_ndx=2)
        _xhold = _xoffset, _xoffset = 3.125
       ENDIF
       _fdrawheight = baglabel_sec(rpt_calcheight)
       IF (_fdrawheight > 0)
        IF ((_fenddetail >= (_yoffset+ _fdrawheight)))
         _bholdcontinue = 0, _fdrawheight = (_fdrawheight+ overflowsig_sec(rpt_calcheight,((
          _fenddetail - _yoffset) - _fdrawheight),_bholdcontinue))
         IF (_bholdcontinue=1)
          _fdrawheight = (_fenddetail+ 1)
         ENDIF
        ENDIF
       ENDIF
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ENDIF
       dummy_val = baglabel_secabs(rpt_render,_xoffset,2.688)
       IF (baglabel_sec_ndx=2)
        _xoffset = _xhold
       ENDIF
     ENDFOR
     _fdrawheight = paymentmethod_sec(rpt_calcheight)
     IF (((_yoffset+ _fdrawheight) > _fenddetail))
      BREAK
     ENDIF
     dummy_val = paymentmethod_secabs(rpt_render,_xoffset,2.688), _bcontoverflowsig_sec = 0,
     bfirsttime = 1
     WHILE (((_bcontoverflowsig_sec=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontoverflowsig_sec, _fdrawheight = overflowsig_sec(rpt_calcheight,(
        _fenddetail - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontoverflowsig_sec=0)
        BREAK
       ENDIF
       dummy_val = overflowsig_sec(rpt_render,(_fenddetail - _yoffset),_bcontoverflowsig_sec),
       bfirsttime = 0
     ENDWHILE
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   IF (_bsubreport=0)
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
   ENDIF
 END ;Subroutine
 SUBROUTINE overlay_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = overlay_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerowabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerowabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.070)
   SET rptsd->m_width = 3.243
   SET rptsd->m_height = 1.993
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.320)
   SET rptsd->m_width = 1.566
   SET rptsd->m_height = 1.993
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 4.892)
   SET rptsd->m_width = 3.545
   SET rptsd->m_height = 1.993
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),offsety,(offsetx+ 0.063),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.313),offsety,(offsetx+ 3.313),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 4.885),offsety,(offsetx+ 4.885),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.438),offsety,(offsetx+ 8.438),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ 0.000),(offsetx+ 8.438),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.063),(offsety+ sectionheight),(offsetx+ 8.438),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE tablerow1(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = tablerow1abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE tablerow1abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   SET rptsd->m_flags = 0
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 0.007)
   SET rptsd->m_width = 3.243
   SET rptsd->m_height = 1.993
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 3.257)
   SET rptsd->m_width = 3.243
   SET rptsd->m_height = 1.993
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   SET rptsd->m_y = (offsety+ 0.007)
   SET rptsd->m_x = (offsetx+ 6.507)
   SET rptsd->m_width = 1.993
   SET rptsd->m_height = 1.993
   IF (ncalc=rpt_render)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build("",char(0)))
   ENDIF
   IF (ncalc=0)
    SET _yoffset = (_yoffset+ sectionheight)
   ENDIF
   IF (ncalc=rpt_render)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),offsety,(offsetx+ 0.000),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 3.250),offsety,(offsetx+ 3.250),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.500),offsety,(offsetx+ 6.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 8.500),offsety,(offsetx+ 8.500),(offsety+
     sectionheight))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.000),(offsetx+ 8.500),(offsety+
     0.000))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ sectionheight),(offsetx+ 8.500),(
     offsety+ sectionheight))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE overlay_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(4.750000), private
   DECLARE holdheight = f8 WITH noconstant(0.0), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _yoffset = (offsety+ 0.375)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 0.375)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _yoffset = (offsety+ 2.750)
    SET _fholdoffsety = (_yoffset - offsety)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ 2.750)
     SET holdheight = 0
     SET holdheight = (holdheight+ tablerow1(rpt_render))
     SET _yoffset = offsety
    ENDIF
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.313),(offsety+ 0.375),1.573,0.500,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.313),(offsety+ 0.875),1.573,0.500,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.313),(offsety+ 1.375),1.573,0.500,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.885),(offsety+ 2.000),3.552,0.375,
     rpt_nofill,rpt_white)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE outerlabel_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = outerlabel_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE outerlabel_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
    DECLARE __brand_name = vc WITH noconstant(build2(build2("generic for ",trim(label_data->
        ingredients[1].identifiers.brand_name)),char(0))), protect
   ENDIF
   DECLARE __label_description = vc WITH noconstant(build2(trim(label_data->ingredients[1].
      label_description),char(0))), protect
   DECLARE __facility_name_phone = vc WITH noconstant(build2(build2(trim(label_data->facility.
       description)," ",trim(label_data->facility.phone)),char(0))), protect
   DECLARE __facility_address = vc WITH noconstant(build2(build2(trim(label_data->facility.address.
       street)," ",trim(label_data->facility.address.city),", ",trim(label_data->facility.address.
       state),
      " ",trim(label_data->facility.address.zipcode)),char(0))), protect
   DECLARE __person_name = vc WITH noconstant(build2(trim(label_data->person.name),char(0))), protect
   DECLARE __printed_date = vc WITH noconstant(build2(format(sysdate,"@SHORTDATE"),char(0))), protect
   DECLARE __rx_number = vc WITH noconstant(build2(build2("Rx# ",trim(preproc_ret->qual[label_rec_ndx
       ].rx_nbr)),char(0))), protect
   DECLARE __ordering_phys = vc WITH noconstant(build2(build2("Dr. ",trim(label_data->personnel.
       ordering_physician_name)),char(0))), protect
   DECLARE __qty = vc WITH noconstant(build2(build2("Qty: ",trim(preproc_ret->qual[label_rec_ndx].
       disp_qty)),char(0))), protect
   DECLARE __refills_remain = vc WITH noconstant(build2(
     IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 0))
      IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 1)) build2(trim(cnvtstring(preproc_ret->
          qual[label_rec_ndx].refills_remain))," refills")
      ELSE build2(trim(cnvtstring(preproc_ret->qual[label_rec_ndx].refills_remain))," refill")
      ENDIF
     ELSE "no refills"
     ENDIF
     ,char(0))), protect
   DECLARE __pharmacist = vc WITH noconstant(build2(build2(trim(label_data->personnel.pharmacist_name
       ),", Rph"),char(0))), protect
   DECLARE __manufacturer = vc WITH noconstant(build2(build2("Mfr: ",trim(label_data->med.identifiers
       .manufacturer)),char(0))), protect
   DECLARE __expiration = vc WITH noconstant(build2(build2("Use before: ",format(preproc_ret->qual[
       label_rec_ndx].exp_dt_tm,"@SHORTDATE")),char(0))), protect
   DECLARE __lot_number = vc WITH noconstant(build2(build2("Lot: ",trim(preproc_ret->qual[
       label_rec_ndx].lot_nbr)),char(0))), protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.250),(offsety+ 0.531),3.063,0.844,
     rpt_nofill,rpt_white)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.031
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.167)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__brand_name)
    ENDIF
    SET rptsd->m_y = (offsety+ 1.031)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label_description)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.125
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facility_name_phone)
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facility_address)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.208)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printed_date)
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.125
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "CAUTION: federal law prohibits transfer of this drug to any person other than patient for whom prescribed.",
      char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rx_number)
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordering_phys)
    SET rptsd->m_y = (offsety+ 1.344)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__qty)
    SET rptsd->m_y = (offsety+ 1.344)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__refills_remain)
    SET rptsd->m_y = (offsety+ 1.490)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pharmacist)
    SET rptsd->m_y = (offsety+ 1.646)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__manufacturer)
    SET rptsd->m_y = (offsety+ 1.490)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__expiration)
    SET rptsd->m_y = (offsety+ 1.646)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lot_number)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE outerlabelsig_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = outerlabelsig_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE outerlabelsig_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.670000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sig = f8 WITH noconstant(0.0), private
   DECLARE __sig = vc WITH noconstant(build2(ol_sig,char(0))), protect
   IF (bcontinue=0)
    SET _remsig = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdallborders
   SET rptsd->m_paddingwidth = 0.031
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsig = _remsig
   IF (_remsig > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsig,((size(__sig) -
       _remsig)+ 1),__sig)))
    SET drawheight_sig = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsig = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsig,((size(__sig) - _remsig)+ 1),__sig
       )))))
     SET _remsig = (_remsig+ rptsd->m_drawlength)
    ELSE
     SET _remsig = 0
    ENDIF
    SET growsum = (growsum+ _remsig)
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = drawheight_sig
   IF (ncalc=rpt_render
    AND _holdremsig > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsig,((size(__sig)
        - _holdremsig)+ 1),__sig)))
   ELSE
    SET _remsig = _holdremsig
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE innerlabel_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = innerlabel_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE innerlabel_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   DECLARE __cost = vc WITH noconstant(build2(build2("Total: ",format(preproc_ret->qual[label_rec_ndx
       ].cost,"######.##;I$;F")),char(0))), protect
   DECLARE __person_name = vc WITH noconstant(build2(trim(label_data->person.name),char(0))), protect
   DECLARE __printed_date = vc WITH noconstant(build2(format(sysdate,"@SHORTDATE"),char(0))), protect
   DECLARE __person_address = vc WITH noconstant(build2(build2(trim(label_data->person.address.street
       )," ",trim(label_data->person.address.city),", ",trim(label_data->person.address.state),
      " ",trim(label_data->person.address.zipcode)),char(0))), protect
   DECLARE __rx_number = vc WITH noconstant(build2(build2("Rx# ",trim(preproc_ret->qual[label_rec_ndx
       ].rx_nbr)),char(0))), protect
   DECLARE __pharmacist = vc WITH noconstant(build2(build2(trim(label_data->personnel.pharmacist_name
       ),", Rph"),char(0))), protect
   IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
    DECLARE __brand_name = vc WITH noconstant(build2(build2("generic for ",trim(label_data->
        ingredients[1].identifiers.brand_name)),char(0))), protect
   ENDIF
   DECLARE __label_description = vc WITH noconstant(build2(trim(label_data->ingredients[1].
      label_description),char(0))), protect
   DECLARE __manufacturer = vc WITH noconstant(build2(build2("Mfr: ",trim(label_data->med.identifiers
       .manufacturer)),char(0))), protect
   DECLARE __refills_remain = vc WITH noconstant(build2(
     IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 0))
      IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 1)) build2(trim(cnvtstring(preproc_ret->
          qual[label_rec_ndx].refills_remain))," refills")
      ELSE build2(trim(cnvtstring(preproc_ret->qual[label_rec_ndx].refills_remain))," refill")
      ENDIF
     ELSE "no refills"
     ENDIF
     ,char(0))), protect
   DECLARE __qty = vc WITH noconstant(build2(build2("Qty: ",trim(preproc_ret->qual[label_rec_ndx].
       disp_qty)),char(0))), protect
   DECLARE __lot_number = vc WITH noconstant(build2(build2("Lot: ",trim(preproc_ret->qual[
       label_rec_ndx].lot_nbr)),char(0))), protect
   DECLARE __ndc = vc WITH noconstant(build2(build2("NDC: ",trim(label_data->med.identifiers.ndc)),
     char(0))), protect
   DECLARE __expiration = vc WITH noconstant(build2(build2("Use before: ",format(preproc_ret->qual[
       label_rec_ndx].exp_dt_tm,"@SHORTDATE")),char(0))), protect
   DECLARE __ordering_phys = vc WITH noconstant(build2(build2("Dr. ",trim(label_data->personnel.
       ordering_physician_name)),char(0))), protect
   DECLARE __dea = vc WITH noconstant(build2(build2("DEA: ",trim(preproc_ret->qual[label_rec_ndx].
       phys_dea)),char(0))), protect
   DECLARE __person_name2 = vc WITH noconstant(build2(trim(label_data->person.name),char(0))),
   protect
   DECLARE __rx_number2 = vc WITH noconstant(build2(build2("Rx# ",trim(preproc_ret->qual[
       label_rec_ndx].rx_nbr)),char(0))), protect
   DECLARE __phys_address = vc WITH noconstant(build2(build2(trim(preproc_ret->qual[label_rec_ndx].
       ord_phys_address_street)," ",trim(preproc_ret->qual[label_rec_ndx].ord_phys_address_city),", ",
      trim(preproc_ret->qual[label_rec_ndx].ord_phys_address_state),
      " ",trim(preproc_ret->qual[label_rec_ndx].ord_phys_zipcode)),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.031
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.219)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.240
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cost)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.000),(offsety+ 0.469),3.240,0.583,
     rpt_nofill,rpt_white)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.500)
    SET rptsd->m_width = 0.792
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printed_date)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 3.302
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_address)
    SET rptsd->m_y = (offsety+ 0.260)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rx_number)
    SET rptsd->m_y = (offsety+ 0.260)
    SET rptsd->m_x = (offsetx+ 6.500)
    SET rptsd->m_width = 1.802
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pharmacist)
    SET rptsd->m_flags = 1056
    SET rptsd->m_y = (offsety+ 0.833)
    SET rptsd->m_x = (offsetx+ 6.875)
    SET rptsd->m_width = 1.406
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__brand_name)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.833)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.844
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label_description)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 1.156)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__manufacturer)
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 6.938)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__refills_remain)
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 0.542
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__qty)
    SET rptsd->m_y = (offsety+ 1.156)
    SET rptsd->m_x = (offsetx+ 6.938)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__lot_number)
    SET rptsd->m_y = (offsety+ 1.010)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ndc)
    SET rptsd->m_y = (offsety+ 1.219)
    SET rptsd->m_x = (offsetx+ 6.938)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__expiration)
    SET rptsd->m_y = (offsety+ 1.344)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordering_phys)
    SET rptsd->m_y = (offsety+ 1.344)
    SET rptsd->m_x = (offsetx+ 6.938)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dea)
    SET rptsd->m_y = (offsety+ 1.760)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 3.240
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_name2)
    SET rptsd->m_y = (offsety+ 1.615)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rx_number2)
    SET rptsd->m_y = (offsety+ 1.490)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.167
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__phys_address)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE innerlabelsig_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = innerlabelsig_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE innerlabelsig_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_sig = f8 WITH noconstant(0.0), private
   DECLARE __sig = vc WITH noconstant(build2(il_sig,char(0))), protect
   IF (bcontinue=0)
    SET _remsig = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdallborders
   SET rptsd->m_paddingwidth = 0.031
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremsig = _remsig
   IF (_remsig > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remsig,((size(__sig) -
       _remsig)+ 1),__sig)))
    SET drawheight_sig = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remsig = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remsig,((size(__sig) - _remsig)+ 1),__sig
       )))))
     SET _remsig = (_remsig+ rptsd->m_drawlength)
    ELSE
     SET _remsig = 0
    ENDIF
    SET growsum = (growsum+ _remsig)
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 3.375
   SET rptsd->m_height = drawheight_sig
   IF (ncalc=rpt_render
    AND _holdremsig > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremsig,((size(__sig)
        - _holdremsig)+ 1),__sig)))
   ELSE
    SET _remsig = _holdremsig
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE warninglabel_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = warninglabel_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE warninglabel_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __warning_label = vc WITH noconstant(build2(preproc_ret->qual[label_rec_ndx].warn_lbl[d2
     .seq].label_txt,char(0))), protect
   IF ( NOT (textlen(preproc_ret->qual[label_rec_ndx].warn_lbl[d2.seq].label_txt) > 0))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 292
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = bor(bor(rpt_sdbottomborder,rpt_sdleftborder),rpt_sdrightborder)
    SET rptsd->m_paddingwidth = 0.031
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.375)
    SET rptsd->m_width = 1.573
    SET rptsd->m_height = 0.500
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica6b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__warning_label)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE baglabel_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = baglabel_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE baglabel_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   DECLARE __facility_name_phone = vc WITH noconstant(build2(build2(trim(label_data->facility.
       description)," ",trim(label_data->facility.phone)),char(0))), protect
   DECLARE __facility_address = vc WITH noconstant(build2(build2(trim(label_data->facility.address.
       street)," ",trim(label_data->facility.address.city),", ",trim(label_data->facility.address.
       state),
      " ",trim(label_data->facility.address.zipcode)),char(0))), protect
   DECLARE __person_name = vc WITH noconstant(build2(trim(label_data->person.name),char(0))), protect
   DECLARE __printed_date = vc WITH noconstant(build2(format(sysdate,"@SHORTDATE"),char(0))), protect
   DECLARE __person_address = vc WITH noconstant(build2(build2(trim(label_data->person.address.street
       )," ",trim(label_data->person.address.city),", ",trim(label_data->person.address.state),
      " ",trim(label_data->person.address.zipcode)),char(0))), protect
   DECLARE __label_description = vc WITH noconstant(build2(trim(label_data->ingredients[1].
      label_description),char(0))), protect
   IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
    DECLARE __brand_name = vc WITH noconstant(build2(build2("generic for ",trim(label_data->
        ingredients[1].identifiers.brand_name)),char(0))), protect
   ENDIF
   DECLARE __manufacturer = vc WITH noconstant(build2(build2("Mfr: ",trim(label_data->med.identifiers
       .manufacturer)),char(0))), protect
   DECLARE __qty = vc WITH noconstant(build2(build2("Qty: ",trim(preproc_ret->qual[label_rec_ndx].
       disp_qty)),char(0))), protect
   DECLARE __ndc = vc WITH noconstant(build2(build2("NDC: ",trim(label_data->med.identifiers.ndc)),
     char(0))), protect
   DECLARE __rx_number = vc WITH noconstant(build2(build2("Rx# ",trim(preproc_ret->qual[label_rec_ndx
       ].rx_nbr)),char(0))), protect
   DECLARE __ordering_phys = vc WITH noconstant(build2(build2("Dr. ",trim(label_data->personnel.
       ordering_physician_name)),char(0))), protect
   DECLARE __phys_address = vc WITH noconstant(build2(build2(trim(preproc_ret->qual[label_rec_ndx].
       ord_phys_address_street)," ",trim(preproc_ret->qual[label_rec_ndx].ord_phys_address_city),", ",
      trim(preproc_ret->qual[label_rec_ndx].ord_phys_address_state),
      " ",trim(preproc_ret->qual[label_rec_ndx].ord_phys_zipcode)),char(0))), protect
   DECLARE __refills_remain = vc WITH noconstant(build2(
     IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 0))
      IF ((preproc_ret->qual[label_rec_ndx].refills_remain > 1)) build2(trim(cnvtstring(preproc_ret->
          qual[label_rec_ndx].refills_remain))," refills")
      ELSE build2(trim(cnvtstring(preproc_ret->qual[label_rec_ndx].refills_remain))," refill")
      ENDIF
     ELSE "no refills"
     ENDIF
     ,char(0))), protect
   DECLARE __cost = vc WITH noconstant(build2(format(preproc_ret->qual[label_rec_ndx].cost,
      "######.##;I$;F"),char(0))), protect
   DECLARE __insurance_coverage = vc WITH noconstant(build2(format(preproc_ret->qual[label_rec_ndx].
      ins_pd,"######.##;I$;F"),char(0))), protect
   DECLARE __patient_responsibility = vc WITH noconstant(build2(format(preproc_ret->qual[
      label_rec_ndx].pat_pd,"######.##;I$;F"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.031
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facility_name_phone)
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__facility_address)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.281)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_name)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.281)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.792
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__printed_date)
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.417)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__person_address)
    SET rptsd->m_y = (offsety+ 0.552)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__label_description)
    SET rptsd->m_y = (offsety+ 0.698)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF (textlen(trim(label_data->ingredients[1].identifiers.brand_name)) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__brand_name)
    ENDIF
    SET rptsd->m_y = (offsety+ 0.844)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__manufacturer)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 1.177)
    SET rptsd->m_width = 0.896
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__qty)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 2.021)
    SET rptsd->m_width = 1.229
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ndc)
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__rx_number)
    SET rptsd->m_y = (offsety+ 1.104)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ordering_phys)
    SET rptsd->m_y = (offsety+ 1.260)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica60)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__phys_address)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.240
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__refills_remain)
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cost)
    SET rptsd->m_y = (offsety+ 1.521)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__insurance_coverage)
    SET rptsd->m_y = (offsety+ 1.677)
    SET rptsd->m_x = (offsetx+ 2.438)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_responsibility)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total:",char(0)))
    SET rptsd->m_y = (offsety+ 1.521)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ins Pd:",char(0)))
    SET rptsd->m_y = (offsety+ 1.677)
    SET rptsd->m_x = (offsetx+ 1.688)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.240
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pat Pd:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.000),(offsety+ 1.714),(offsetx+ 3.208),(offsety+
     1.714))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE paymentmethod_sec(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = paymentmethod_secabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE paymentmethod_secabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(2.000000), private
   DECLARE __payment_method = vc WITH noconstant(build2(build2(trim(preproc_ret->qual[label_rec_ndx].
       payment_method)),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 272
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdallborders
    SET rptsd->m_paddingwidth = 0.031
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.563)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 2.000
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__payment_method)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE overflowsig_sec(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = overflowsig_secabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE overflowsig_secabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.740000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_ol_overflowsig = f8 WITH noconstant(0.0), private
   DECLARE drawheight_il_overflowsig = f8 WITH noconstant(0.0), private
   IF (textlen(ol_overflowsig) > 0)
    DECLARE __ol_overflowsig = vc WITH noconstant(build2(ol_overflowsig,char(0))), protect
   ENDIF
   IF (textlen(il_overflowsig) > 0)
    DECLARE __il_overflowsig = vc WITH noconstant(build2(il_overflowsig,char(0))), protect
   ENDIF
   IF ( NOT (((textlen(ol_overflowsig) > 0) OR (textlen(il_overflowsig) > 0)) ))
    RETURN(0.0)
   ENDIF
   IF (bcontinue=0)
    SET _remol_overflowsig = 1
    SET _remil_overflowsig = 1
   ENDIF
   SET rptsd->m_flags = 37
   SET rptsd->m_borders = rpt_sdallborders
   SET rptsd->m_padding = rpt_sdallborders
   SET rptsd->m_paddingwidth = 0.031
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.469)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (textlen(ol_overflowsig) > 0)
    SET _holdremol_overflowsig = _remol_overflowsig
    IF (_remol_overflowsig > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remol_overflowsig,((size
        (__ol_overflowsig) - _remol_overflowsig)+ 1),__ol_overflowsig)))
     SET drawheight_ol_overflowsig = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remol_overflowsig = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remol_overflowsig,((size(
         __ol_overflowsig) - _remol_overflowsig)+ 1),__ol_overflowsig)))))
      SET _remol_overflowsig = (_remol_overflowsig+ rptsd->m_drawlength)
     ELSE
      SET _remol_overflowsig = 0
     ENDIF
     SET growsum = (growsum+ _remol_overflowsig)
    ENDIF
   ELSE
    SET _remol_overflowsig = 0
    SET _holdremol_overflowsig = _remol_overflowsig
   ENDIF
   SET rptsd->m_flags = 37
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.469)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   IF (textlen(il_overflowsig) > 0)
    SET _holdremil_overflowsig = _remil_overflowsig
    IF (_remil_overflowsig > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remil_overflowsig,((size
        (__il_overflowsig) - _remil_overflowsig)+ 1),__il_overflowsig)))
     SET drawheight_il_overflowsig = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remil_overflowsig = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remil_overflowsig,((size(
         __il_overflowsig) - _remil_overflowsig)+ 1),__il_overflowsig)))))
      SET _remil_overflowsig = (_remil_overflowsig+ rptsd->m_drawlength)
     ELSE
      SET _remil_overflowsig = 0
     ENDIF
     SET growsum = (growsum+ _remil_overflowsig)
    ENDIF
   ELSE
    SET _remil_overflowsig = 0
    SET _holdremil_overflowsig = _remil_overflowsig
   ENDIF
   SET rptsd->m_flags = 36
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.469)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = drawheight_ol_overflowsig
   IF (ncalc=rpt_render
    AND _holdremol_overflowsig > 0)
    IF (textlen(ol_overflowsig) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremol_overflowsig,((
        size(__ol_overflowsig) - _holdremol_overflowsig)+ 1),__ol_overflowsig)))
    ENDIF
   ELSE
    SET _remol_overflowsig = _holdremol_overflowsig
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.271)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.125
   SET rptsd->m_height = 0.240
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (textlen(ol_overflowsig) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sig Line Overflow",char(0)))
    ENDIF
   ENDIF
   SET rptsd->m_flags = 36
   SET rptsd->m_borders = rpt_sdallborders
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.469)
   ENDIF
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = drawheight_il_overflowsig
   IF (ncalc=rpt_render
    AND _holdremil_overflowsig > 0)
    IF (textlen(il_overflowsig) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremil_overflowsig,((
        size(__il_overflowsig) - _holdremil_overflowsig)+ 1),__il_overflowsig)))
    ENDIF
   ELSE
    SET _remil_overflowsig = _holdremil_overflowsig
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_y = (offsety+ 0.271)
   SET rptsd->m_x = (offsetx+ 5.375)
   SET rptsd->m_width = 3.063
   SET rptsd->m_height = 0.240
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (textlen(il_overflowsig) > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sig Line Overflow",char(0)))
    ENDIF
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
   IF (_bsubreport=0)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "CCPS_PHA_LBT_RETAIL"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_portrait
    SET rptreport->m_marginleft = 0.00
    SET rptreport->m_marginright = 0.00
    SET rptreport->m_margintop = 0.00
    SET rptreport->m_marginbottom = 0.00
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
   ENDIF
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
   SET rptfont->m_fontname = rpt_helvetica
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET rptfont->m_bold = rpt_off
   SET _helvetica60 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET _helvetica80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 6
   SET rptfont->m_bold = rpt_on
   SET _helvetica6b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 CALL initializereport(0)
 SET _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
 SET _fholdenddetail = _fenddetail
 CALL layout_query(0)
 SET _fenddetail = _fholdenddetail
 CALL finalizereport(_sendto)
 CALL echo(build2("RptReport->m_horzPrintOffset = ",rptreport->m_horzprintoffset))
 CALL echo(build2("_SendTo = ",_sendto))
END GO
