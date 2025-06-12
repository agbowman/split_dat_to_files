CREATE PROGRAM bhs_rpt_ord_by_practice:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Location" = 0
  WITH outdev, s_beg_date, s_end_date,
  f_location
 FREE RECORD m_info
 RECORD m_info(
   1 s_facility_name = vc
   1 orders[*]
     2 f_encntr_id = f8
     2 s_fin = vc
     2 s_mrn = vc
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_order_id = f8
     2 s_order_name = vc
     2 s_order_det = vc
     2 s_ord_provider = vc
   1 phys[*]
     2 l_order_cnt = i4
     2 s_phys_name = vc
     2 f_person_id = f8
   1 pat[*]
     2 l_order_cnt = i4
     2 s_pat_name = vc
     2 f_person_id = f8
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim(concat( $S_BEG_DATE," 00:00:00")))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(concat( $S_END_DATE," 23:59:59")))
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_LOCATION))
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_incompl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_ptcare_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE mf_anc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"ANCILLARYOP"))
 DECLARE mf_card_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CARDIOLOGYOP"))
 DECLARE mf_combo_lab_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"COMBOLABOP"
   ))
 DECLARE mf_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTOP"))
 DECLARE mf_ctscan_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"CTSCANOP"))
 DECLARE mf_gene_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"GENETICSOP"))
 DECLARE mf_labinoff_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABINOFFICEOP")
  )
 DECLARE mf_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABORATORYOP"))
 DECLARE mf_micro_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MICROOP"))
 DECLARE mf_mra_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MRAOP"))
 DECLARE mf_mri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"MRIOP"))
 DECLARE mf_neuro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"NEUROOP"))
 DECLARE mf_pathology_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "PATHOLOGYOP"))
 DECLARE mf_pet_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PETSCANOP"))
 DECLARE mf_ptcare_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PATIENTCAREOP"))
 DECLARE mf_proc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PROCEDUREOP"))
 DECLARE mf_pulm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PULMONARYOP"))
 DECLARE mf_rad_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGYOP"))
 DECLARE mf_repro_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"REPROLABOP"))
 DECLARE mf_surg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"SURGICALOP"))
 DECLARE mf_ther_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"THERAPYOP"))
 DECLARE mf_vasc_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"VASCULAROP"))
 DECLARE mf_vol_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"VOLUMESPECOP"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0)
 DECLARE ml_cont_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE head_section(ncalc=i2) = f8 WITH protect
 DECLARE head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patient_section(ncalc=i2) = f8 WITH protect
 DECLARE patient_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE order_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE order_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE provider_section(ncalc=i2) = f8 WITH protect
 DECLARE provider_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE pat_ord_cnt_section(ncalc=i2) = f8 WITH protect
 DECLARE pat_ord_cnt_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE divider_section(ncalc=i2) = f8 WITH protect
 DECLARE divider_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE phys_totals_head_section(ncalc=i2) = f8 WITH protect
 DECLARE phys_totals_head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE phys_totals_det_section(ncalc=i2) = f8 WITH protect
 DECLARE phys_totals_det_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE pat_totals_head_section(ncalc=i2) = f8 WITH protect
 DECLARE pat_totals_head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE pat_totals_det_section(ncalc=i2) = f8 WITH protect
 DECLARE pat_totals_det_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE foot_section(ncalc=i2) = f8 WITH protect
 DECLARE foot_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
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
 DECLARE _remorder = i4 WITH noconstant(1), protect
 DECLARE _remorder_name = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontorder_section = i2 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"BHSCUST:bayst_health_logo.jpg")
 END ;Subroutine
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
 SUBROUTINE head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.380000), private
   DECLARE __location = vc WITH noconstant(build2(m_info->s_facility_name,char(0))), protect
   DECLARE __date_range = vc WITH noconstant(build2(concat(substring(1,11,ms_beg_dt_tm)," to ",
      substring(1,11,ms_end_dt_tm)),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Request orders by Facility",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_range)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 2.250),(offsety+ 0.000),3.000,
     0.563,1)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patient_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patient_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patient_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   DECLARE __pat_name = vc WITH noconstant(build2(m_info->orders[ml_loop].s_pat_name,char(0))),
   protect
   DECLARE __mrn = vc WITH noconstant(build2(m_info->orders[ml_loop].s_mrn,char(0))), protect
   DECLARE __fin = vc WITH noconstant(build2(m_info->orders[ml_loop].s_fin,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACCT:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE order_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = order_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE order_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order = f8 WITH noconstant(0.0), private
   DECLARE drawheight_order_name = f8 WITH noconstant(0.0), private
   DECLARE __order = vc WITH noconstant(build2(m_info->orders[ml_loop].s_order_det,char(0))), protect
   DECLARE __order_name = vc WITH noconstant(build2(m_info->orders[ml_loop].s_order_name,char(0))),
   protect
   IF (bcontinue=0)
    SET _remorder = 1
    SET _remorder_name = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_oneandahalf
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 4.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremorder = _remorder
   IF (_remorder > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder,((size(__order)
        - _remorder)+ 1),__order)))
    SET drawheight_order = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder,((size(__order) - _remorder)+ 1),
       __order)))))
     SET _remorder = (_remorder+ rptsd->m_drawlength)
    ELSE
     SET _remorder = 0
    ENDIF
    SET growsum = (growsum+ _remorder)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   SET _holdremorder_name = _remorder_name
   IF (_remorder_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remorder_name,((size(
        __order_name) - _remorder_name)+ 1),__order_name)))
    SET drawheight_order_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remorder_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remorder_name,((size(__order_name) -
       _remorder_name)+ 1),__order_name)))))
     SET _remorder_name = (_remorder_name+ rptsd->m_drawlength)
    ELSE
     SET _remorder_name = 0
    ENDIF
    SET growsum = (growsum+ _remorder_name)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.000)
   SET rptsd->m_width = 4.500
   SET rptsd->m_height = drawheight_order
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
   IF (ncalc=rpt_render
    AND _holdremorder > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder,((size(
        __order) - _holdremorder)+ 1),__order)))
   ELSE
    SET _remorder = _holdremorder
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.938
   SET rptsd->m_height = drawheight_order_name
   SET _dummyfont = uar_rptsetfont(_hreport,_helvetica12b0)
   IF (ncalc=rpt_render
    AND _holdremorder_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremorder_name,((size(
        __order_name) - _holdremorder_name)+ 1),__order_name)))
   ELSE
    SET _remorder_name = _holdremorder_name
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
 SUBROUTINE provider_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = provider_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE provider_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __order_provider = vc WITH noconstant(build2(m_info->orders[ml_loop].s_ord_provider,char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ORDERING PROVIDER",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_provider)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pat_ord_cnt_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pat_ord_cnt_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pat_ord_cnt_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __pat_ord_cnt = vc WITH noconstant(build2(m_info->pat[ml_idx].l_order_cnt,char(0))),
   protect
   DECLARE __pat_name = vc WITH noconstant(build2(m_info->orders[ml_loop].s_pat_name,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total orders for patient",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_ord_cnt)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.000)
    SET rptsd->m_width = 3.250
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_name)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE divider_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = divider_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE divider_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.130000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 7.479),(offsety+
     0.063))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE phys_totals_head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = phys_totals_head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE phys_totals_head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Orders by Physician",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE phys_totals_det_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = phys_totals_det_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE phys_totals_det_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __order_provider = vc WITH noconstant(build2(m_info->phys[d.seq].s_phys_name,char(0))),
   protect
   DECLARE __phys_ord_cnt = vc WITH noconstant(build2(m_info->phys[d.seq].l_order_cnt,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_provider)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__phys_ord_cnt)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pat_totals_head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pat_totals_head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pat_totals_head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Orders by Physician",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pat_totals_det_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pat_totals_det_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pat_totals_det_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __patient_name = vc WITH noconstant(build2(m_info->pat[d.seq].s_pat_name,char(0))),
   protect
   DECLARE __pat_ord_cnt = vc WITH noconstant(build2(m_info->pat[d.seq].l_order_cnt,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__patient_name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_ord_cnt)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE foot_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = foot_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE foot_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_ORD_BY_PRACTICE"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
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
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica120 = uar_rptcreatefont(_hreport,rptfont)
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
 SET d0 = initializereport(0)
 SET m_info->s_facility_name = trim(uar_get_code_display(mf_facility_cd))
 SELECT INTO "nl:"
  ps_activity_type = trim(uar_get_code_display(o.active_status_cd)), ps_order_name = trim(
   uar_get_code_display(o.catalog_cd)), pn_sort_by =
  IF (o.activity_type_cd IN (mf_combo_lab_op_cd, mf_gene_op_cd, mf_labinoff_cd, mf_lab_cd,
  mf_micro_op_cd,
  mf_pathology_op_cd, mf_repro_op_cd, mf_vol_op_cd)) 1
  ELSE 2
  ENDIF
  FROM orders o,
   encntr_domain ed,
   person p,
   prsnl pr,
   order_action oa
  PLAN (o
   WHERE o.catalog_type_cd=mf_ptcare_cat_cd
    AND o.activity_type_cd IN (mf_anc_cd, mf_card_cd, mf_combo_lab_op_cd, mf_consult_cd, mf_ctscan_cd,
   mf_gene_op_cd, mf_labinoff_cd, mf_lab_cd, mf_micro_op_cd, mf_mra_cd,
   mf_mri_cd, mf_neuro_cd, mf_pathology_op_cd, mf_pet_op_cd, mf_ptcare_cd,
   mf_proc_cd, mf_pulm_cd, mf_rad_cd, mf_repro_op_cd, mf_surg_cd,
   mf_ther_cd, mf_vasc_op_cd, mf_vol_op_cd)
    AND o.dcp_clin_cat_cd=mf_req_order_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND  NOT (o.order_status_cd IN (mf_del_cd, mf_void_cd, mf_incompl_cd))
    AND  NOT (o.order_status_cd IN (mf_canceled_cd, mf_discont_cd)
    AND o.discontinue_type_cd != mf_disch_discont_cd))
   JOIN (ed
   WHERE ed.encntr_id=o.encntr_id
    AND ed.loc_facility_cd=mf_facility_cd)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= sysdate)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id
    AND p.active_ind=1)
  ORDER BY p.name_full_formatted, pn_sort_by, ps_order_name
  HEAD REPORT
   pl_ord_cnt = 0, pl_pat_cnt = 0, pl_phys_cnt = 0
  HEAD p.person_id
   pl_pat_ord_cnt = 0, pl_pat_cnt = (pl_pat_cnt+ 1), stat = alterlist(m_info->pat,pl_pat_cnt),
   m_info->pat[pl_pat_cnt].f_person_id = p.person_id, m_info->pat[pl_pat_cnt].s_pat_name = trim(p
    .name_full_formatted)
  HEAD o.order_id
   pl_pat_ord_cnt = (pl_pat_ord_cnt+ 1)
   IF (pl_phys_cnt > 0)
    ml_idx = locateval(ml_cnt,1,pl_phys_cnt,pr.person_id,m_info->phys[ml_cnt].f_person_id)
    IF (ml_idx > 0)
     m_info->phys[ml_idx].l_order_cnt = (m_info->phys[ml_idx].l_order_cnt+ 1)
    ENDIF
   ENDIF
   IF (((pl_phys_cnt=0) OR (ml_idx=0)) )
    pl_phys_cnt = (pl_phys_cnt+ 1), stat = alterlist(m_info->phys,pl_phys_cnt), m_info->phys[
    pl_phys_cnt].f_person_id = pr.person_id,
    m_info->phys[pl_phys_cnt].s_phys_name = trim(pr.name_full_formatted), m_info->phys[pl_phys_cnt].
    l_order_cnt = 1
   ENDIF
   pl_ord_cnt = (pl_ord_cnt+ 1)
   IF (pl_ord_cnt > size(m_info->orders,5))
    stat = alterlist(m_info->orders,(pl_ord_cnt+ 10))
   ENDIF
   m_info->orders[pl_ord_cnt].f_encntr_id = o.encntr_id, m_info->orders[pl_ord_cnt].f_order_id = o
   .order_id, m_info->orders[pl_ord_cnt].f_person_id = o.person_id,
   m_info->orders[pl_ord_cnt].s_order_name = trim(uar_get_code_display(o.catalog_cd)), m_info->
   orders[pl_ord_cnt].s_order_det = trim(o.clinical_display_line), m_info->orders[pl_ord_cnt].
   s_pat_name = trim(p.name_full_formatted),
   m_info->orders[pl_ord_cnt].s_ord_provider = trim(pr.name_full_formatted)
  FOOT  p.person_id
   m_info->pat[pl_pat_cnt].l_order_cnt = pl_pat_ord_cnt
  FOOT REPORT
   stat = alterlist(m_info->orders,pl_ord_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No records found"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_info->orders,5))),
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (d)
   JOIN (ea1
   WHERE (ea1.encntr_id=m_info->orders[d.seq].f_encntr_id)
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(m_info->orders[d.seq].f_encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  DETAIL
   m_info->orders[d.seq].s_fin = trim(ea1.alias), m_info->orders[d.seq].s_mrn = trim(ea2.alias)
  WITH nocounter
 ;end select
 SET d0 = head_section(rpt_render)
 SET d0 = divider_section(rpt_render)
 FOR (ml_loop = 1 TO size(m_info->orders,5))
   SET ml_idx = locateval(ml_cnt,1,size(m_info->pat,5),m_info->orders[ml_loop].f_person_id,m_info->
    pat[ml_cnt].f_person_id)
   SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   IF ((mf_rem_space < ((patient_section(rpt_calcheight)+ 0.32)+ divider_section(rpt_calcheight))))
    SET d0 = foot_section(rpt_render)
    SET d0 = pagebreak(0)
    SET d0 = head_section(rpt_render)
    SET d0 = divider_section(rpt_render)
   ENDIF
   IF (size(m_info->orders,5) > ml_loop)
    IF ((m_info->orders[ml_loop].f_person_id != m_info->orders[(ml_loop+ 1)].f_person_id))
     SET mf_rem_space = (mf_page_size - (((_yoffset+ provider_section(rpt_calcheight))+
     pat_ord_cnt_section(rpt_calcheight))+ foot_section(rpt_calcheight)))
    ELSE
     SET mf_rem_space = (mf_page_size - ((_yoffset+ provider_section(rpt_calcheight))+ foot_section(
      rpt_calcheight)))
    ENDIF
   ELSEIF (ml_loop=size(m_info->orders,5))
    SET mf_rem_space = (mf_page_size - (((_yoffset+ provider_section(rpt_calcheight))+
    pat_ord_cnt_section(rpt_calcheight))+ foot_section(rpt_calcheight)))
   ELSE
    SET mf_rem_space = (mf_page_size - ((_yoffset+ provider_section(rpt_calcheight))+ foot_section(
     rpt_calcheight)))
   ENDIF
   IF ((mf_rem_space < ((0.6+ patient_section(rpt_calcheight))+ provider_section(rpt_calcheight))))
    SET d0 = foot_section(rpt_render)
    SET d0 = pagebreak(0)
    SET d0 = head_section(rpt_render)
    SET d0 = divider_section(rpt_render)
   ENDIF
   SET d0 = patient_section(rpt_render)
   SET d0 = provider_section(rpt_render)
   SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   SET d0 = order_section(rpt_render,mf_rem_space,ml_cont_ind)
   WHILE (ml_cont_ind=1)
     SET d0 = foot_section(rpt_render)
     SET d0 = pagebreak(0)
     SET d0 = head_section(rpt_render)
     SET d0 = divider_section(rpt_render)
     SET d0 = patient_section(rpt_render)
     SET d0 = provider_section(rpt_render)
     SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
     SET d0 = order_section(rpt_render,mf_rem_space,ml_cont_ind)
   ENDWHILE
   IF (size(m_info->orders,5) > ml_loop)
    IF ((m_info->orders[ml_loop].f_person_id != m_info->orders[(ml_loop+ 1)].f_person_id))
     SET d0 = pat_ord_cnt_section(rpt_render)
    ENDIF
   ELSEIF (ml_loop=size(m_info->orders,5))
    SET d0 = pat_ord_cnt_section(rpt_render)
   ENDIF
   SET d0 = divider_section(rpt_render)
 ENDFOR
 SET d0 = foot_section(rpt_render)
 SELECT INTO "nl:"
  ps_name = trim(m_info->phys[d.seq].s_phys_name)
  FROM (dummyt d  WITH seq = value(size(m_info->phys,5)))
  ORDER BY ps_name
  HEAD REPORT
   d0 = pagebreak(0), d0 = head_section(rpt_render), d0 = divider_section(rpt_render),
   d0 = phys_totals_head_section(rpt_render), d0 = divider_section(rpt_render)
  DETAIL
   mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   IF (mf_rem_space < phys_totals_det_section(rpt_calcheight))
    d0 = pagebreak(0), d0 = head_section(rpt_render), d0 = divider_section(rpt_render),
    d0 = phys_totals_head_section(rpt_render), d0 = divider_section(rpt_render)
   ENDIF
   d0 = phys_totals_det_section(rpt_render)
  FOOT REPORT
   d0 = foot_section(rpt_render)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_name = trim(m_info->pat[d.seq].s_pat_name)
  FROM (dummyt d  WITH seq = value(size(m_info->pat,5)))
  ORDER BY ps_name
  HEAD REPORT
   d0 = pagebreak(0), d0 = head_section(rpt_render), d0 = divider_section(rpt_render),
   d0 = pat_totals_head_section(rpt_render), d0 = divider_section(rpt_render)
  DETAIL
   mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   IF (mf_rem_space < pat_totals_det_section(rpt_calcheight))
    d0 = pagebreak(0), d0 = head_section(rpt_render), d0 = divider_section(rpt_render),
    d0 = pat_totals_head_section(rpt_render), d0 = divider_section(rpt_render)
   ENDIF
   d0 = pat_totals_det_section(rpt_render)
  FOOT REPORT
   d0 = foot_section(rpt_render)
  WITH nocounter
 ;end select
 SET d0 = finalizereport(value(ms_output))
#exit_script
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
