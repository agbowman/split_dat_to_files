CREATE PROGRAM bhs_sn_extract_dt_save_pref:dba
 DECLARE ms_backend_dir = vc WITH protect, constant(concat(trim(logical("BHSCUST")),
   "/surginet/pref_card/data/"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD m_pref
 RECORD m_pref(
   1 s_surg_area = vc
   1 s_doc_type = vc
   1 s_surgeon_name = vc
   1 s_proc_name = vc
   1 s_specialty = vc
   1 s_avg_duration = vc
   1 s_tot_num_case = vc
   1 s_comment = vc
   1 s_filename = vc
   1 icnt = i4
   1 item[*]
     2 f_item_id = f8
     2 s_item_type = vc
     2 s_item_desc = vc
     2 s_item_nbr = vc
     2 s_open = vc
     2 s_hold = vc
     2 s_sch = vc
     2 s_item_loc = vc
     2 s_bin = vc
 )
 FREE RECORD m_fin_pref
 RECORD m_fin_pref(
   1 s_surg_area = vc
   1 s_doc_type = vc
   1 s_surgeon_name = vc
   1 s_proc_name = vc
   1 s_specialty = vc
   1 s_avg_duration = vc
   1 s_tot_num_case = vc
   1 s_comment = vc
   1 s_filename = vc
   1 icnt = i4
   1 item[*]
     2 f_item_id = f8
     2 s_item_type = vc
     2 s_item_desc = vc
     2 s_item_nbr = vc
     2 s_open = vc
     2 s_hold = vc
     2 s_sch = vc
     2 s_item_loc = vc
     2 s_bin = vc
 )
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE sec_header(ncalc=i2) = f8 WITH protect
 DECLARE sec_headerabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_line(ncalc=i2) = f8 WITH protect
 DECLARE sec_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_pref(ncalc=i2) = f8 WITH protect
 DECLARE sec_prefabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_itemheader(ncalc=i2) = f8 WITH protect
 DECLARE sec_itemheaderabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_itemtype(ncalc=i2) = f8 WITH protect
 DECLARE sec_itemtypeabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_itemlocation(ncalc=i2) = f8 WITH protect
 DECLARE sec_itemlocationabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_item(ncalc=i2) = f8 WITH protect
 DECLARE sec_itemabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE sec_note(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE sec_noteabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
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
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remtxt_comment = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_note = i2 WITH noconstant(0), protect
 DECLARE _hrtf_txt_comment = i4 WITH noconstant(0), protect
 DECLARE _times90 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times9u0 = i4 WITH noconstant(0), protect
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
 SUBROUTINE sec_header(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_headerabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.700000), private
   DECLARE __txt_surgicalarea = vc WITH noconstant(build2(m_fin_pref->s_surg_area,char(0))), protect
   DECLARE __txt_documenttype = vc WITH noconstant(build2(m_fin_pref->s_doc_type,char(0))), protect
   DECLARE __txt_curdate = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime3),";;q"),
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 2.125
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BAYSTATE HEALTH SYSTEM",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _dummyfont = uar_rptsetfont(_hreport,_times90)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Surgical Area:",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Document Type:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_surgicalarea)
    SET rptsd->m_y = (offsety+ 0.521)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_documenttype)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Downtime Preference Card Report",char
      (0)))
    SET rptsd->m_y = (offsety+ 0.531)
    SET rptsd->m_x = (offsetx+ 4.063)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Generate Date: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.521)
    SET rptsd->m_x = (offsetx+ 4.875)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_curdate)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.095),(offsetx+ 7.469),(offsety+
     0.095))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_pref(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_prefabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_prefabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.990000), private
   DECLARE __txt_surgetonname = vc WITH noconstant(build2(m_fin_pref->s_surgeon_name,char(0))),
   protect
   DECLARE __txt_procedurename = vc WITH noconstant(build2(m_fin_pref->s_proc_name,char(0))), protect
   DECLARE __txt_specialty = vc WITH noconstant(build2(m_fin_pref->s_specialty,char(0))), protect
   DECLARE __txt_averageduration = vc WITH noconstant(build2(m_fin_pref->s_avg_duration,char(0))),
   protect
   DECLARE __txt_totalnumberofcases = vc WITH noconstant(build2(m_fin_pref->s_tot_num_case,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Surgeon Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedure Name:",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Specialty",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Average Duration:",char(0)))
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total Number of Cases:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_surgetonname)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_procedurename)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_specialty)
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.000
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_averageduration)
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 6.063
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_totalnumberofcases)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_itemheader(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_itemheaderabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_itemheaderabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.520000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.177
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Item Number",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Item Description",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Bin",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pick Location",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Item Type",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 7.063)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sch Ind",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Hold",char(0)))
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.177
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Open",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_itemtype(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_itemtypeabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_itemtypeabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __txt_itemtype = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_item_type,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times9u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_itemtype)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_itemlocation(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_itemlocationabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_itemlocationabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __txt_itemlocation = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_item_loc,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times9u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET oldbackcolor = uar_rptsetbackcolor(_hreport,uar_rptencodecolor(192,192,192))
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_itemlocation)
    SET oldbackcolor = uar_rptresetbackcolor(_hreport)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_item(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_itemabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_itemabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE __txt_bin = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_bin,char(0))), protect
   DECLARE __txt_itemdescription = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_item_desc,
     char(0))), protect
   DECLARE __txt_schind = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_sch,char(0))), protect
   DECLARE __txt_hold = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_hold,char(0))), protect
   DECLARE __txt_open = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_open,char(0))), protect
   DECLARE __txt_itemnumber = vc WITH noconstant(build2(m_fin_pref->item[ml_cnt].s_item_nbr,char(0))),
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
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.313
    SET _oldfont = uar_rptsetfont(_hreport,_times90)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_bin)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 3.938
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_itemdescription)
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 7.063)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_schind)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.625)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_hold)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_open)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.000)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.313
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__txt_itemnumber)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE sec_note(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_noteabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_noteabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_txt_comment = f8 WITH noconstant(0.0), private
   DECLARE __txt_comment = vc WITH noconstant(build2(m_fin_pref->s_comment,char(0))), protect
   IF (bcontinue=0)
    SET _remtxt_comment = 1
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
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 7.375
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times90)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (substring(1,5,__txt_comment) != "{\rtf")
    SET _holdremtxt_comment = _remtxt_comment
    IF (_remtxt_comment > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remtxt_comment,((size(
         __txt_comment) - _remtxt_comment)+ 1),__txt_comment)))
     SET drawheight_txt_comment = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remtxt_comment = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remtxt_comment,((size(__txt_comment) -
        _remtxt_comment)+ 1),__txt_comment)))))
      SET _remtxt_comment = (_remtxt_comment+ rptsd->m_drawlength)
     ELSE
      SET _remtxt_comment = 0
     ENDIF
     SET growsum = (growsum+ _remtxt_comment)
    ENDIF
   ENDIF
   IF (substring(1,5,__txt_comment)="{\rtf")
    IF (ncalc=rpt_render
     AND _remtxt_comment > 0)
     IF (_hrtf_txt_comment=0)
      SET _hrtf_txt_comment = uar_rptcreatertf(_hreport,__txt_comment,7.375)
     ENDIF
     IF (_hrtf_txt_comment != 0)
      SET _fdrawheight = maxheight
      SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_txt_comment,(offsetx+ 0.063),(offsety+ 0.000),
       _fdrawheight)
     ENDIF
     IF ((_fdrawheight > (sectionheight - 0.000)))
      SET sectionheight = (0.000+ _fdrawheight)
     ENDIF
     IF (_rptstat != rpt_continue)
      SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_txt_comment)
      SET _hrtf_txt_comment = 0
      SET _remtxt_comment = 0
     ENDIF
    ENDIF
    SET growsum = (growsum+ _remtxt_comment)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.063)
   SET rptsd->m_width = 7.375
   SET rptsd->m_height = drawheight_txt_comment
   IF (substring(1,5,__txt_comment) != "{\rtf")
    IF (ncalc=rpt_render
     AND _holdremtxt_comment > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremtxt_comment,((
        size(__txt_comment) - _holdremtxt_comment)+ 1),__txt_comment)))
    ELSE
     SET _remtxt_comment = _holdremtxt_comment
    ENDIF
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
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_SN_EXTRACT_DT_SAVE_PREF"
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
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 52
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 9
   SET _times90 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_on
   SET _times9u0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SELECT INTO "nl:"
  FROM preference_card pc,
   prsnl p,
   order_catalog oc,
   prsnl_group pg,
   sn_comment_text ct,
   long_text_reference ltr,
   pref_card_pick_list pcpl,
   mm_omf_item_master moim,
   dummyt d1,
   loc_resource_r lrr,
   locator_rollup lr
  PLAN (pc
   WHERE (pc.pref_card_id= $1)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=outerjoin(pc.prsnl_id))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(pc.catalog_cd))
   JOIN (pg
   WHERE pg.prsnl_group_id=outerjoin(pc.surg_specialty_id))
   JOIN (ct
   WHERE ct.root_name=outerjoin("PREFERENCE_CARD")
    AND ct.root_id=outerjoin(pc.pref_card_id)
    AND ct.active_ind=outerjoin(1))
   JOIN (ltr
   WHERE ltr.long_text_id=outerjoin(ct.long_text_id))
   JOIN (pcpl
   WHERE pcpl.pref_card_id=outerjoin(pc.pref_card_id)
    AND pcpl.active_ind=outerjoin(1))
   JOIN (moim
   WHERE moim.item_master_id=outerjoin(pcpl.item_id))
   JOIN (d1)
   JOIN (lrr
   WHERE lrr.service_resource_cd=pc.surg_area_cd
    AND lrr.loc_resource_type_cd IN (747))
   JOIN (lr
   WHERE lr.location_cd=lrr.location_cd
    AND lr.item_id=pcpl.item_id)
  ORDER BY moim.type_cd, pcpl.item_id, lrr.sequence DESC
  HEAD REPORT
   m_pref->s_surg_area = trim(uar_get_code_display(pc.surg_area_cd),3), m_pref->s_doc_type = trim(
    uar_get_code_display(pc.doc_type_cd),3), m_pref->s_surgeon_name = trim(p.name_full_formatted,3),
   m_pref->s_proc_name = trim(oc.primary_mnemonic,3), m_pref->s_specialty = trim(pg.prsnl_group_name,
    3)
   IF (pc.override_hist_avg_dur != 0)
    m_pref->s_avg_duration = trim(cnvtstring(pc.override_hist_avg_dur,20),3)
   ELSE
    m_pref->s_avg_duration = trim(cnvtstring(pc.hist_avg_dur,20),3)
   ENDIF
   IF (pc.override_tot_nbr_cases != 0)
    m_pref->s_tot_num_case = trim(cnvtstring(pc.override_tot_nbr_cases,20),3)
   ELSE
    m_pref->s_tot_num_case = trim(cnvtstring(pc.tot_nbr_cases,20),3)
   ENDIF
   m_pref->s_comment = trim(ltr.long_text,3), m_pref->s_filename = concat(ms_backend_dir,trim(
     cnvtstring(pc.pref_card_id,20),3),".pdf"), m_pref->icnt = 0
  HEAD pcpl.item_id
   m_pref->icnt = (m_pref->icnt+ 1), stat = alterlist(m_pref->item,m_pref->icnt), m_pref->item[m_pref
   ->icnt].f_item_id = pcpl.item_id,
   m_pref->item[m_pref->icnt].s_item_type = trim(uar_get_code_display(moim.type_cd),3), m_pref->item[
   m_pref->icnt].s_item_desc = moim.description, m_pref->item[m_pref->icnt].s_item_nbr = moim
   .stock_nbr,
   m_pref->item[m_pref->icnt].s_bin = "", m_pref->item[m_pref->icnt].s_item_loc = "", m_pref->item[
   m_pref->icnt].s_open = trim(cnvtstring(pcpl.request_open_qty,20),3),
   m_pref->item[m_pref->icnt].s_hold = trim(cnvtstring(pcpl.request_hold_qty,20),3), m_pref->item[
   m_pref->icnt].s_sch = ""
   IF (moim.scheduable_ind != 0)
    m_pref->item[m_pref->icnt].s_sch = "Yes"
   ELSE
    m_pref->item[m_pref->icnt].s_sch = "No"
   ENDIF
  DETAIL
   IF (lr.location_cd IS NOT null)
    m_pref->item[m_pref->icnt].s_item_loc = trim(uar_get_code_display(lr.location_cd),3), m_pref->
    item[m_pref->icnt].s_bin = trim(uar_get_code_display(lr.locator_cd),3)
   ENDIF
  FOOT  pcpl.item_id
   IF (size(m_pref->item[m_pref->icnt].s_item_loc)=0)
    m_pref->item[m_pref->icnt].s_item_loc = "<Not Defined>"
   ENDIF
   IF (size(m_pref->item[m_pref->icnt].s_bin)=0)
    m_pref->item[m_pref->icnt].s_bin = "<Not Defined>"
   ENDIF
  WITH nocounter, outerjoin(d1)
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_pref->icnt)
  PLAN (d)
  ORDER BY m_pref->item[d.seq].s_item_type, m_pref->item[d.seq].s_item_loc, m_pref->item[d.seq].s_bin,
   m_pref->item[d.seq].s_item_desc, m_pref->item[d.seq].s_item_nbr
  HEAD REPORT
   m_fin_pref->s_surg_area = m_pref->s_surg_area, m_fin_pref->s_doc_type = m_pref->s_doc_type,
   m_fin_pref->s_surgeon_name = m_pref->s_surgeon_name,
   m_fin_pref->s_proc_name = m_pref->s_proc_name, m_fin_pref->s_specialty = m_pref->s_specialty,
   m_fin_pref->s_avg_duration = m_pref->s_avg_duration,
   m_fin_pref->s_tot_num_case = m_pref->s_tot_num_case, m_fin_pref->s_comment = m_pref->s_comment,
   m_fin_pref->s_filename = m_pref->s_filename,
   m_fin_pref->icnt = 0
  DETAIL
   m_fin_pref->icnt = (m_fin_pref->icnt+ 1), stat = alterlist(m_fin_pref->item,m_fin_pref->icnt),
   m_fin_pref->item[m_fin_pref->icnt].f_item_id = m_pref->item[d.seq].f_item_id,
   m_fin_pref->item[m_fin_pref->icnt].s_bin = m_pref->item[d.seq].s_bin, m_fin_pref->item[m_fin_pref
   ->icnt].s_hold = m_pref->item[d.seq].s_hold, m_fin_pref->item[m_fin_pref->icnt].s_item_desc =
   m_pref->item[d.seq].s_item_desc,
   m_fin_pref->item[m_fin_pref->icnt].s_item_loc = m_pref->item[d.seq].s_item_loc, m_fin_pref->item[
   m_fin_pref->icnt].s_item_nbr = m_pref->item[d.seq].s_item_nbr, m_fin_pref->item[m_fin_pref->icnt].
   s_item_type = m_pref->item[d.seq].s_item_type,
   m_fin_pref->item[m_fin_pref->icnt].s_open = m_pref->item[d.seq].s_open, m_fin_pref->item[
   m_fin_pref->icnt].s_sch = m_pref->item[d.seq].s_sch
  WITH nocounter
 ;end select
 DECLARE mf_page_size = f8 WITH protect, constant(10.25)
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 SET d0 = sec_header(rpt_render)
 SET d0 = sec_line(rpt_render)
 SET d0 = sec_pref(rpt_render)
 SET d0 = sec_line(rpt_render)
 SET d0 = sec_itemheader(rpt_render)
 SET d0 = sec_line(rpt_render)
 FOR (ml_cnt = 1 TO m_fin_pref->icnt)
   IF (ml_cnt > 1
    AND (m_fin_pref->item[(ml_cnt - 1)].s_item_type != m_fin_pref->item[ml_cnt].s_item_type))
    SET mf_rem_space = (mf_page_size - ((_yoffset+ sec_itemtype(rpt_calcheight))+ sec_itemlocation(
     rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
     SET d0 = sec_pref(rpt_render)
     SET d0 = sec_line(rpt_render)
     SET d0 = sec_itemheader(rpt_render)
     SET d0 = sec_line(rpt_render)
    ENDIF
    SET d0 = sec_itemtype(rpt_render)
    SET d0 = sec_itemlocation(rpt_render)
   ELSEIF (ml_cnt=1)
    SET d0 = sec_itemtype(rpt_render)
   ENDIF
   IF (ml_cnt > 1
    AND (m_fin_pref->item[(ml_cnt - 1)].s_item_loc != m_fin_pref->item[ml_cnt].s_item_loc)
    AND (m_fin_pref->item[(ml_cnt - 1)].s_item_type=m_fin_pref->item[ml_cnt].s_item_type))
    SET mf_rem_space = (mf_page_size - (_yoffset+ sec_itemlocation(rpt_calcheight)))
    IF (mf_rem_space <= 0.25)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
     SET d0 = sec_pref(rpt_render)
     SET d0 = sec_line(rpt_render)
     SET d0 = sec_itemheader(rpt_render)
     SET d0 = sec_line(rpt_render)
    ENDIF
    SET d0 = sec_itemlocation(rpt_render)
   ELSEIF (ml_cnt=1)
    SET d0 = sec_itemlocation(rpt_render)
   ENDIF
   SET mf_rem_space = (mf_page_size - (_yoffset+ sec_item(rpt_calcheight)))
   IF (mf_rem_space <= 0.25)
    SET _yoffset = 10.18
    SET d0 = pagebreak(0)
    SET d0 = sec_pref(rpt_render)
    SET d0 = sec_line(rpt_render)
    SET d0 = sec_itemheader(rpt_render)
    SET d0 = sec_line(rpt_render)
    SET d0 = sec_itemtype(rpt_render)
    SET d0 = sec_itemlocation(rpt_render)
   ENDIF
   SET d0 = sec_item(rpt_render)
 ENDFOR
 IF (size(m_fin_pref->s_comment) > 0)
  SET d0 = pagebreak(0)
  SET d0 = sec_pref(rpt_render)
  SET d0 = sec_line(rpt_render)
  SET becont = 0
  SET d0 = sec_note(rpt_render,7.75,becont)
  WHILE (becont=1)
    SET d0 = pagebreak(1)
    SET d0 = sec_pref(rpt_render)
    SET d0 = sec_line(rpt_render)
    SET d0 = sec_note(rpt_render,7.75,becont)
  ENDWHILE
 ENDIF
 SET d0 = finalizereport(value(m_fin_pref->s_filename))
#exit_script
END GO
