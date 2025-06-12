CREATE PROGRAM bhs_rpt_req_lab_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 f_person_id = f8
   1 s_patient_name = vc
   1 s_dob = vc
   1 s_age = vc
   1 s_sex = vc
   1 s_mrn = vc
   1 s_fin = vc
   1 s_cmrn = vc
   1 s_location = vc
   1 f_facility = f8
   1 s_attending_md = vc
   1 labs[*]
     2 f_lab_order_id = f8
     2 s_lab_order_dt_tm = vc
     2 s_lab_name = vc
     2 s_lab_det = vc
     2 s_ord_provider = vc
     2 s_req_type = vc
     2 f_act_type_cd = f8
     2 s_lab_det_extra = vc
     2 icd9s[*]
       3 s_txt = vc
       3 s_cd = vc
   1 labs_by_time[*]
     2 f_lab_order_id = f8
     2 l_labs_idx = i4
     2 s_ord_provider = vc
     2 f_act_type_cd = f8
 ) WITH protect
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_lab_req_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"LABOPREQUEST")
  )
 DECLARE mf_op_lab_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"OPLABTOBEDONE")
  )
 DECLARE mf_icd9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
 DECLARE mf_act_enc_ord_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ACTIVEENCOUNTERORDER"))
 DECLARE mf_oef_gen_op_cd1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SURGICALPATHOLOGYPOC"))
 DECLARE mf_oef_gen_op_cd2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "GESTATIONALAGE"))
 DECLARE mf_oef_gen_op_cd3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "ULTRASOUND"))
 DECLARE mf_oef_gen_op_cd4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"LNMP"))
 DECLARE mf_oef_gen_op_cd5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"ETHNICITY"
   ))
 DECLARE mf_oef_gen_op_cd6 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "GENETICSCLINICALINDICATION"))
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_incompl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE mf_pat_care_op_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE mf_lab_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"LABORATORYOP"))
 DECLARE mf_lab_gene_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"GENETICSOP")
  )
 DECLARE mf_lab_repro_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"REPROLABOP"
   ))
 DECLARE mf_lab_vol_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"VOLUMESPECOP"
   ))
 DECLARE mf_bwwc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,
   "BAYSTATEWESSONWOMENS"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_loop2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0)
 DECLARE ml_cont_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_fin = vc WITH protect, noconstant("")
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE page_head_section(ncalc=i2) = f8 WITH protect
 DECLARE page_head_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_head(ncalc=i2) = f8 WITH protect
 DECLARE req_orders_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_type(ncalc=i2) = f8 WITH protect
 DECLARE req_orders_typeabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_det(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE req_orders_detabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE req_orders_provider(ncalc=i2) = f8 WITH protect
 DECLARE req_orders_providerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_dt_signed(ncalc=i2) = f8 WITH protect
 DECLARE req_orders_dt_signedabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
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
 DECLARE _bcontreq_orders_det = i2 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica120 = i4 WITH noconstant(0), protect
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
 SUBROUTINE page_head_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_head_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_head_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.920000), private
   DECLARE __pat_name = vc WITH noconstant(build2(m_info->s_patient_name,char(0))), protect
   DECLARE __location = vc WITH noconstant(build2(m_info->s_location,char(0))), protect
   DECLARE __attending = vc WITH noconstant(build2(m_info->s_attending_md,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(m_info->s_dob,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(m_info->s_age,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(m_info->s_mrn,char(0))), protect
   DECLARE __sex = vc WITH noconstant(build2(m_info->s_sex,char(0))), protect
   DECLARE __cmrn = vc WITH noconstant(build2(m_info->s_cmrn,char(0))), protect
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
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Referred Outpatient Orders",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient:",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending MD:",char(0)))
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_y = (offsety+ 1.625)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Gender:",char(0)))
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CMRN:",char(0)))
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACCT:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pat_name)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 1.063)
    SET rptsd->m_width = 3.375
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attending)
    SET rptsd->m_y = (offsety+ 1.615)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.688
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 1.615)
    SET rptsd->m_x = (offsetx+ 2.625)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_y = (offsety+ 1.615)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sex)
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cmrn)
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 2.250),(offsety+ 0.000),3.000,
     0.563,1)
    SET rptsd->m_y = (offsety+ 1.375)
    SET rptsd->m_x = (offsetx+ 5.500)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ms_tmp_fin,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_headabs(ncalc,offsetx,offsety)
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
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LABORATORY ORDERS",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_type(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_typeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_typeabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.360000), private
   DECLARE __req_type = vc WITH noconstant(build2(m_info->labs[ml_idx].s_req_type,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.000
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "All of the following Laboratory Orders are to be done:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__req_type)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_det(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_detabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_detabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.310000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_order = f8 WITH noconstant(0.0), private
   DECLARE drawheight_order_name = f8 WITH noconstant(0.0), private
   DECLARE __order = vc WITH noconstant(build2(m_info->labs[ml_idx].s_lab_det,char(0))), protect
   DECLARE __order_name = vc WITH noconstant(build2(m_info->labs[ml_idx].s_lab_name,char(0))),
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
   SET rptsd->m_x = (offsetx+ 3.563)
   SET rptsd->m_width = 4.000
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
   SET rptsd->m_width = 3.438
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
   SET rptsd->m_x = (offsetx+ 3.563)
   SET rptsd->m_width = 4.000
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
   SET rptsd->m_width = 3.438
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
 SUBROUTINE req_orders_provider(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_providerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_providerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.560000), private
   DECLARE __order_provider = vc WITH noconstant(build2(m_info->labs[ml_idx].s_ord_provider,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 36
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ORDERING PROVIDER",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 5.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_provider)
    SET rptsd->m_flags = 36
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 5.438
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "All orders below are electronically signed by this provider",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_dt_signed(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_dt_signedabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_dt_signedabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __order_dt_tm = vc WITH noconstant(build2(m_info->labs[ml_idx].s_lab_order_dt_tm,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.750)
    SET rptsd->m_width = 2.750
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__order_dt_tm)
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
   DECLARE sectionheight = f8 WITH noconstant(1.220000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.271
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica120)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "PLEASE BRING THIS FORM WITH YOU TO THE LAB TO HAVE YOUR LAB WORK DRAWN",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "LAB TESTING REQUIRES A PHYSICIANS ORDER AND SIGNATURE TO BE PERFORMED",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_RPT_REQ_LAB_ORDERS"
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
 IF (validate(request->visit,"Z") != "Z")
  SET ms_output = request->output_device
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSEIF (cnvtreal( $F_ENCNTR_ID) > 0.0)
  SET ms_output =  $OUTDEV
  SET mf_encntr_id = cnvtreal( $F_ENCNTR_ID)
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2,
   person_alias pa
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.person_alias_type_cd=outerjoin(mf_cmrn_cd))
  HEAD p.person_id
   m_info->f_person_id = p.person_id, m_info->s_patient_name = trim(p.name_full_formatted), m_info->
   s_dob = trim(format(p.birth_dt_tm,"dd-mmm-yyyy;;d")),
   m_info->s_age = trim(cnvtage(p.birth_dt_tm),3), m_info->s_sex = uar_get_code_display(p.sex_cd),
   m_info->s_cmrn = trim(pa.alias),
   m_info->s_fin = trim(ea1.alias), m_info->s_mrn = trim(ea2.alias), m_info->f_facility = e
   .loc_facility_cd,
   m_info->s_location = trim(uar_get_code_display(e.loc_nurse_unit_cd))
  WITH nocounter
 ;end select
 IF ((m_info->f_facility=mf_bwwc_cd))
  SET ms_tmp_fin = m_info->s_fin
 ELSE
  SET ms_tmp_fin = ""
 ENDIF
 CALL echo("get attending physician")
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE epr.encntr_id=mf_encntr_id
    AND epr.encntr_prsnl_r_cd=mf_attending_cd
    AND epr.end_effective_dt_tm > sysdate
    AND epr.active_ind=1)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.active_ind=1)
  DETAIL
   m_info->s_attending_md = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 CALL echo("get labs")
 SELECT INTO "nl:"
  ps_field_name = trim(uar_get_code_display(od.oe_field_id))
  FROM orders o,
   order_detail od,
   order_action oa,
   prsnl p
  PLAN (o
   WHERE o.encntr_id=mf_encntr_id
    AND o.catalog_type_cd=mf_pat_care_op_cat_cd
    AND o.dcp_clin_cat_cd=mf_req_order_cd
    AND o.activity_type_cd IN (mf_lab_op_cd, mf_lab_gene_op_cd, mf_lab_repro_op_cd, mf_lab_vol_op_cd)
    AND o.active_ind=1
    AND  NOT (o.order_status_cd IN (mf_del_cd, mf_void_cd, mf_incompl_cd))
    AND  NOT (o.order_status_cd IN (mf_canceled_cd, mf_discont_cd)
    AND o.discontinue_type_cd != mf_disch_discont_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id != mf_act_enc_ord_cd)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id
    AND p.active_ind=1)
  ORDER BY o.order_id, o.active_status_dt_tm DESC, od.parent_action_sequence DESC,
   od.detail_sequence
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_info->labs,5))
    stat = alterlist(m_info->labs,(pl_cnt+ 10))
   ENDIF
   m_info->labs[pl_cnt].f_lab_order_id = o.order_id, m_info->labs[pl_cnt].s_lab_order_dt_tm = trim(
    format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")), m_info->labs[pl_cnt].s_lab_name = trim(
    uar_get_code_display(o.catalog_cd)),
   m_info->labs[pl_cnt].s_ord_provider = trim(p.name_full_formatted), m_info->labs[pl_cnt].
   f_act_type_cd = o.activity_type_cd, pl_icd9_cnt = 0,
   pl_det_cnt = 0
  DETAIL
   pl_det_cnt = (pl_det_cnt+ 1)
   IF (od.oe_field_id IN (mf_op_lab_cd, mf_lab_req_cd)
    AND findstring(trim(od.oe_field_display_value),o.order_detail_display_line) > 0)
    m_info->labs[pl_cnt].s_req_type = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id=mf_icd9_cd)
    IF (pl_icd9_cnt < 3)
     pl_icd9_cnt = (pl_icd9_cnt+ 1), stat = alterlist(m_info->labs[pl_cnt].icd9s,pl_icd9_cnt), m_info
     ->labs[pl_cnt].icd9s[pl_icd9_cnt].s_txt = trim(od.oe_field_display_value,3)
    ENDIF
   ENDIF
   IF (od.oe_field_id != mf_icd9_cd
    AND  NOT (od.oe_field_meaning IN ("STOPDTTM", "STOPTYPE", "REQSTARTDTTM"))
    AND findstring(trim(od.oe_field_display_value),o.order_detail_display_line) > 0)
    IF (pl_det_cnt=1)
     m_info->labs[pl_cnt].s_lab_det = trim(od.oe_field_display_value), m_info->labs[pl_cnt].
     s_req_type = trim(od.oe_field_display_value)
    ELSE
     IF (od.oe_field_meaning="OTHER"
      AND cnvtupper(ps_field_name)="COPY TO PROVIDER")
      m_info->labs[pl_cnt].s_lab_det = concat(m_info->labs[pl_cnt].s_lab_det,", Copy results to: ",
       trim(od.oe_field_display_value))
     ELSE
      m_info->labs[pl_cnt].s_lab_det = concat(m_info->labs[pl_cnt].s_lab_det,", ",trim(od
        .oe_field_display_value))
     ENDIF
    ENDIF
   ENDIF
   IF (o.activity_type_cd=mf_lab_gene_op_cd)
    IF (od.oe_field_id=mf_oef_gen_op_cd1)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
    IF (od.oe_field_id=mf_oef_gen_op_cd2)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
    IF (od.oe_field_id=mf_oef_gen_op_cd3)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
    IF (od.oe_field_id=mf_oef_gen_op_cd4)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
    IF (od.oe_field_id=mf_oef_gen_op_cd5)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
    IF (od.oe_field_id=mf_oef_gen_op_cd6)
     m_info->labs[pl_cnt].s_lab_det_extra = concat(m_info->labs[pl_cnt].s_lab_det_extra,trim(
       uar_get_code_display(od.oe_field_id)),": ",trim(od.oe_field_display_value),". ")
    ENDIF
   ENDIF
  FOOT  o.order_id
   m_info->labs[pl_cnt].s_lab_det = concat(m_info->labs[pl_cnt].s_lab_det,", ",m_info->labs[pl_cnt].
    s_lab_det_extra)
  FOOT REPORT
   stat = alterlist(m_info->labs,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_info->labs,5)=0)
  GO TO exit_script
 ENDIF
 CALL echo("get ICD9 codes")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_info->labs,5))),
   dummyt d2,
   diagnosis d,
   nomenclature n
  PLAN (d1
   WHERE maxrec(d2,size(m_info->labs[d1.seq].icd9s,5)))
   JOIN (d2)
   JOIN (d
   WHERE d.encntr_id=mf_encntr_id
    AND (d.diagnosis_display=m_info->labs[d1.seq].icd9s[d2.seq].s_txt))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id
    AND n.active_ind=1)
  DETAIL
   m_info->labs[d1.seq].icd9s[d2.seq].s_cd = trim(n.source_identifier)
  WITH nocounter
 ;end select
 FOR (ml_loop = 1 TO size(m_info->labs,5))
   FOR (ml_loop2 = 1 TO size(m_info->labs[ml_loop].icd9s,5))
     SET m_info->labs[ml_loop].s_lab_det = concat(m_info->labs[ml_loop].s_lab_det,", Dx #",trim(
       cnvtstring(ml_loop2)),": ",trim(m_info->labs[ml_loop].icd9s[ml_loop2].s_cd))
   ENDFOR
   SET m_info->labs[ml_loop].s_lab_det = concat(m_info->labs[ml_loop].s_lab_det,ms_tmp)
   CALL echo(build2(m_info->labs[ml_loop].s_lab_det,";;;"))
 ENDFOR
 CALL echo("order the lab list by req type")
 SELECT INTO "nl:"
  ps_act_type = uar_get_code_display(m_info->labs[d.seq].f_act_type_cd), ps_req_type = trim(m_info->
   labs[d.seq].s_req_type), ps_provider = trim(m_info->labs[d.seq].s_ord_provider),
  ps_lab_name = trim(m_info->labs[d.seq].s_lab_name)
  FROM (dummyt d  WITH seq = value(size(m_info->labs,5)))
  PLAN (d)
  ORDER BY ps_act_type, ps_req_type, ps_lab_name,
   ps_provider
  HEAD REPORT
   stat = alterlist(m_info->labs_by_time,size(m_info->labs,5)), pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), m_info->labs_by_time[pl_cnt].l_labs_idx = d.seq, m_info->labs_by_time[pl_cnt
   ].f_lab_order_id = m_info->labs[d.seq].f_lab_order_id,
   m_info->labs_by_time[pl_cnt].s_ord_provider = m_info->labs[d.seq].s_ord_provider, m_info->
   labs_by_time[pl_cnt].f_act_type_cd = m_info->labs[d.seq].f_act_type_cd
  WITH nocounter
 ;end select
 SET d0 = page_head_section(rpt_render)
 SET d0 = req_orders_head(rpt_render)
 SET ms_tmp = "zzzzz"
 FOR (ml_loop = 1 TO size(m_info->labs_by_time,5))
   SET ml_idx = m_info->labs_by_time[ml_loop].l_labs_idx
   IF (ml_loop=1)
    SET d0 = req_orders_type(rpt_render)
   ENDIF
   SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   IF (trim(m_info->labs[ml_idx].s_req_type) != trim(ms_tmp)
    AND ml_loop != 1)
    SET d0 = foot_section(rpt_render)
    CALL echo("1")
    SET d0 = pagebreak(0)
    SET d0 = page_head_section(rpt_render)
    SET d0 = req_orders_head(rpt_render)
    SET d0 = req_orders_type(rpt_render)
    SET d0 = req_orders_provider(rpt_render)
   ELSEIF (mf_rem_space < 0.25)
    SET d0 = foot_section(rpt_render)
    CALL echo("2")
    SET d0 = pagebreak(0)
    SET d0 = page_head_section(rpt_render)
    SET d0 = req_orders_head(rpt_render)
    SET d0 = req_orders_type(rpt_render)
    SET d0 = req_orders_provider(rpt_render)
   ELSEIF ((mf_rem_space < ((0.32+ req_orders_dt_signed(rpt_calcheight))+ req_orders_provider(
    rpt_calcheight))))
    SET d0 = foot_section(rpt_render)
    CALL echo("3")
    SET d0 = pagebreak(0)
    SET d0 = page_head_section(rpt_render)
    SET d0 = req_orders_head(rpt_render)
    SET d0 = req_orders_type(rpt_render)
    SET d0 = req_orders_provider(rpt_render)
   ELSE
    IF (ml_loop=1)
     SET d0 = req_orders_provider(rpt_render)
    ELSE
     IF (trim(m_info->labs_by_time[ml_loop].s_ord_provider) != trim(m_info->labs_by_time[(ml_loop - 1
      )].s_ord_provider))
      SET d0 = req_orders_provider(rpt_render)
     ENDIF
    ENDIF
   ENDIF
   SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
   SET d0 = req_orders_det(rpt_render,mf_rem_space,ml_cont_ind)
   WHILE (ml_cont_ind=1)
     SET d0 = foot_section(rpt_render)
     CALL echo("4")
     SET d0 = pagebreak(0)
     SET d0 = page_head_section(rpt_render)
     SET d0 = req_orders_head(rpt_render)
     SET d0 = req_orders_type(rpt_render)
     SET mf_rem_space = (mf_page_size - (_yoffset+ foot_section(rpt_calcheight)))
     SET d0 = req_orders_provider(rpt_render)
     SET d0 = req_orders_det(rpt_render,mf_rem_space,ml_cont_ind)
   ENDWHILE
   SET d0 = req_orders_dt_signed(rpt_render)
   SET ms_tmp = m_info->labs[ml_idx].s_req_type
   IF (ml_loop=size(m_info->labs,5))
    SET d0 = foot_section(rpt_render)
   ENDIF
 ENDFOR
 SET d0 = finalizereport(value(ms_output))
#exit_script
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
