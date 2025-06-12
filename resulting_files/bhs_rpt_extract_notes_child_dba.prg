CREATE PROGRAM bhs_rpt_extract_notes_child:dba
 CALL echo("*** OUTPUT DIR ***")
 CALL echo(ms_output_sub_fold)
 CALL echo(ms_output_dir_str)
 IF ( NOT (validate(requestin)))
  FREE RECORD requestin
  RECORD requestin(
    1 list_0[*]
      2 encounter_id = vc
  ) WITH protect
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 f_encntr_id = f8
   1 note[*]
     2 f_clinical_event_id = f8
     2 s_filename = vc
     2 s_latest_blob = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_search_dt = vc
     2 s_create_dt = vc
     2 s_note_type = vc
     2 s_note_title = vc
     2 f_parent_event_id = f8
     2 j_event_id = f8
     2 version[*]
       3 f_ce_id = f8
       3 f_event_id = f8
       3 s_sequence = vc
       3 s_content = vc
       3 s_updt_dt_tm = vc
       3 s_updt_prsnl = vc
       3 s_addendum = vc
       3 blob[*]
         4 f_be_id = f8
         4 l_sequence = i4
         4 l_length = i4
         4 s_content = vc
         4 f_comp_cd = f8
 ) WITH protect
 EXECUTE bhs_hlp_ccl
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE _creatertf(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
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
 DECLARE _remitem0 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_note = i2 WITH noconstant(0), protect
 DECLARE _hrtf_item0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
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
 SUBROUTINE sec_note(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = sec_noteabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE sec_noteabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_item0 = f8 WITH noconstant(0.0), private
   DECLARE __item0 = vc WITH noconstant(build2(ms_blob_rtf,char(0))), protect
   IF (bcontinue=0)
    SET _remitem0 = 1
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
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (substring(1,5,__item0) != "{\rtf")
    SET _holdremitem0 = _remitem0
    IF (_remitem0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remitem0,((size(__item0)
         - _remitem0)+ 1),__item0)))
     SET drawheight_item0 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remitem0 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remitem0,((size(__item0) - _remitem0)+ 1
        ),__item0)))))
      SET _remitem0 = (_remitem0+ rptsd->m_drawlength)
     ELSE
      SET _remitem0 = 0
     ENDIF
     SET growsum = (growsum+ _remitem0)
    ENDIF
   ENDIF
   IF (substring(1,5,__item0)="{\rtf")
    IF (ncalc=rpt_render
     AND _remitem0 > 0)
     IF (_hrtf_item0=0)
      SET _hrtf_item0 = uar_rptcreatertf(_hreport,__item0,7.000)
     ENDIF
     IF (_hrtf_item0 != 0)
      SET _fdrawheight = maxheight
      SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_item0,(offsetx+ 0.250),(offsety+ 0.000),
       _fdrawheight)
     ENDIF
     IF ((_fdrawheight > (sectionheight - 0.000)))
      SET sectionheight = (0.000+ _fdrawheight)
     ENDIF
     IF (_rptstat != rpt_continue)
      SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_item0)
      SET _hrtf_item0 = 0
      SET _remitem0 = 0
     ENDIF
    ENDIF
    SET growsum = (growsum+ _remitem0)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = drawheight_item0
   IF (substring(1,5,__item0) != "{\rtf")
    IF (ncalc=rpt_render
     AND _holdremitem0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremitem0,((size(
         __item0) - _holdremitem0)+ 1),__item0)))
    ELSE
     SET _remitem0 = _holdremitem0
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
   SET rptreport->m_reportname = "BHS_RPT_EXTRACT_NOTES"
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
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 IF (ms_input_type="1")
  IF (size(requestin->list_0,5)=0)
   SET ms_log = ".CSV input file contains no records or is in the incorrect format"
   GO TO exit_script
  ENDIF
  CALL alterlist(m_rec->list,size(requestin->list_0,5))
  FOR (ml_list = 1 TO size(requestin->list_0,5))
    SET m_rec->list[ml_list].f_encntr_id = cnvtreal(requestin->list_0[ml_list].encounter_id)
  ENDFOR
  SET ms_dclcom = concat("rm -f ",ms_filename_in)
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(ms_dclcom),ml_stat)
  CALL echo(ml_stat)
 ENDIF
 IF (ms_output_type="1")
  SET ms_filetype = ".txt"
  SET ms_output_type_st = "TEXT"
 ELSEIF (ms_output_type="2")
  SET ms_filetype = ".rtf"
  SET ms_output_type_st = "RTF"
 ELSEIF (ms_output_type="3")
  SET ms_filetype = ".pdf"
  SET ms_output_type_st = "PDF"
 ENDIF
 IF (ms_input_type="1")
  SET ms_index_filename = concat("Index_",format(cnvtdatetime(curdate,curtime3),"MM_DD_YYYY-HHMM;;d"),
   "_",piece(ms_filename_in,".",1,""),"_",
   ms_output_type_st,".csv")
 ELSE
  SET ms_index_filename = concat("Index_",format(mf_beg_dt_tm,"MM_DD_YYYY;;d"),"-",format(
    mf_end_dt_tm,"MM_DD_YYYY;;d"),"_",
   ms_output_type_st,".csv")
 ENDIF
 SELECT
  IF (ms_input_type="1"
   AND mn_any_note_type_ind=0)
   PLAN (ce1
    WHERE expand(ml_encounter_cnt,1,size(m_rec->list,5),ce1.encntr_id,m_rec->list[ml_encounter_cnt].
     f_encntr_id)
     AND expand(ml_note_type_cnt,1,size(m_select_notes->select_notes,5),ce1.event_cd,m_select_notes->
     select_notes[ml_note_type_cnt].f_select_note)
     AND ce1.event_id=ce1.parent_event_id
     AND  NOT (ce1.result_status_cd IN (mf_cancel_cd, mf_in_error_cd, mf_inerror_cd, mf_inerrnomut_cd,
    mf_inerrornoview_cd))
     AND ce1.valid_until_dt_tm > sysdate)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.parent_event_id
     AND ce2.valid_until_dt_tm > sysdate)
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ea1
    WHERE ea1.encntr_id=ce1.encntr_id
     AND ea1.active_ind=1
     AND ea1.end_effective_dt_tm > sysdate
     AND ea1.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ea2
    WHERE ea2.encntr_id=ce1.encntr_id
     AND ea2.active_ind=1
     AND ea2.end_effective_dt_tm > sysdate
     AND ea2.encntr_alias_type_cd=mf_mrn_cd)
    JOIN (pa
    WHERE pa.person_id=ce1.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=mf_cmrn_cd)
  ELSEIF (ms_input_type IN ("2", "3")
   AND mn_any_note_type_ind=0)
   PLAN (ce1
    WHERE expand(ml_note_type_cnt,1,size(m_select_notes->select_notes,5),ce1.event_cd,m_select_notes
     ->select_notes[ml_note_type_cnt].f_select_note)
     AND ce1.event_id=ce1.parent_event_id
     AND  NOT (ce1.result_status_cd IN (mf_cancel_cd, mf_in_error_cd, mf_inerror_cd, mf_inerrnomut_cd,
    mf_inerrornoview_cd))
     AND ce1.valid_until_dt_tm > sysdate
     AND ce1.clinsig_updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.parent_event_id
     AND ce2.valid_until_dt_tm > sysdate)
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ea1
    WHERE ea1.encntr_id=ce1.encntr_id
     AND ea1.active_ind=1
     AND ea1.end_effective_dt_tm > sysdate
     AND ea1.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ea2
    WHERE ea2.encntr_id=ce1.encntr_id
     AND ea2.active_ind=1
     AND ea2.end_effective_dt_tm > sysdate
     AND ea2.encntr_alias_type_cd=mf_mrn_cd)
    JOIN (pa
    WHERE pa.person_id=ce1.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=mf_cmrn_cd)
  ELSEIF (ms_input_type="1"
   AND mn_any_note_type_ind=1)
   PLAN (ce1
    WHERE expand(ml_encounter_cnt,1,size(m_rec->list,5),ce1.encntr_id,m_rec->list[ml_encounter_cnt].
     f_encntr_id)
     AND ce1.event_cd IN (
    (SELECT
     nt.event_cd
     FROM v500_event_set_explode nt
     WHERE nt.event_cd != 0
      AND nt.event_set_cd=252731336.0))
     AND ce1.event_id=ce1.parent_event_id
     AND  NOT (ce1.result_status_cd IN (mf_cancel_cd, mf_in_error_cd, mf_inerror_cd, mf_inerrnomut_cd,
    mf_inerrornoview_cd))
     AND ce1.valid_until_dt_tm > sysdate)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.parent_event_id
     AND ce2.valid_until_dt_tm > sysdate)
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ea1
    WHERE ea1.encntr_id=ce1.encntr_id
     AND ea1.active_ind=1
     AND ea1.end_effective_dt_tm > sysdate
     AND ea1.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ea2
    WHERE ea2.encntr_id=ce1.encntr_id
     AND ea2.active_ind=1
     AND ea2.end_effective_dt_tm > sysdate
     AND ea2.encntr_alias_type_cd=mf_mrn_cd)
    JOIN (pa
    WHERE pa.person_id=ce1.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=mf_cmrn_cd)
  ELSEIF (ms_input_type IN ("2", "3")
   AND mn_any_note_type_ind=1)
   PLAN (ce1
    WHERE ce1.event_cd IN (
    (SELECT
     nt.event_cd
     FROM v500_event_set_explode nt
     WHERE nt.event_cd != 0
      AND nt.event_set_cd=252731336.0))
     AND ce1.event_id=ce1.parent_event_id
     AND  NOT (ce1.result_status_cd IN (mf_cancel_cd, mf_in_error_cd, mf_inerror_cd, mf_inerrnomut_cd,
    mf_inerrornoview_cd))
     AND ce1.valid_until_dt_tm > sysdate
     AND ce1.clinsig_updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.parent_event_id
     AND ce2.valid_until_dt_tm > sysdate)
    JOIN (cb
    WHERE cb.event_id=ce2.event_id
     AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
     AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ea1
    WHERE ea1.encntr_id=ce1.encntr_id
     AND ea1.active_ind=1
     AND ea1.end_effective_dt_tm > sysdate
     AND ea1.encntr_alias_type_cd=mf_fin_cd)
    JOIN (ea2
    WHERE ea2.encntr_id=ce1.encntr_id
     AND ea2.active_ind=1
     AND ea2.end_effective_dt_tm > sysdate
     AND ea2.encntr_alias_type_cd=mf_mrn_cd)
    JOIN (pa
    WHERE pa.person_id=ce1.person_id
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > sysdate
     AND pa.person_alias_type_cd=mf_cmrn_cd)
  ELSE
  ENDIF
  INTO "nl:"
  FROM clinical_event ce1,
   clinical_event ce2,
   ce_blob cb,
   person_alias pa,
   encntr_alias ea1,
   encntr_alias ea2
  ORDER BY ce1.clinsig_updt_dt_tm, ce1.clinical_event_id, ce2.parent_event_id,
   ce2.collating_seq
  HEAD ce1.clinical_event_id
   ml_note = (ml_note+ 1)
   IF (mod(ml_note,100)=1)
    CALL alterlist(m_rec->note,(ml_note+ 99))
   ENDIF
   m_rec->note[ml_note].f_clinical_event_id = ce1.clinical_event_id, m_rec->note[ml_note].f_person_id
    = ce1.person_id, m_rec->note[ml_note].f_encntr_id = ce1.encntr_id,
   m_rec->note[ml_note].s_mrn = trim(ea2.alias), m_rec->note[ml_note].s_cmrn = trim(pa.alias), m_rec
   ->note[ml_note].s_fin = trim(ea1.alias),
   m_rec->note[ml_note].s_search_dt = format(ce1.clinsig_updt_dt_tm,"mm/dd/yy hh:mm;;d"), m_rec->
   note[ml_note].s_create_dt = format(ce1.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), m_rec->note[ml_note].
   s_note_type = trim(uar_get_code_display(ce1.event_cd)),
   m_rec->note[ml_note].s_note_title = trim(ce1.event_title_text), m_rec->note[ml_note].
   f_parent_event_id = ce1.parent_event_id, ms_filename_out = concat(trim(cnvtalphanum(cnvtlower(
       m_rec->note[ml_note].s_note_type))),"_",trim(cnvtstring(m_rec->note[ml_note].f_parent_event_id,
      20)),"_",trim(cnvtstring(ml_note)),
    ms_filetype),
   m_rec->note[ml_note].s_filename = cnvtlower(ms_filename_out), ml_ver = 0
  HEAD ce2.clinical_event_id
   ml_ver = (ml_ver+ 1),
   CALL alterlist(m_rec->note[ml_note].version,ml_ver), m_rec->note[ml_note].version[ml_ver].f_ce_id
    = ce2.clinical_event_id,
   m_rec->note[ml_note].version[ml_ver].f_event_id = ce2.event_id, m_rec->note[ml_note].version[
   ml_ver].s_sequence = trim(ce2.collating_seq), m_rec->note[ml_note].version[ml_ver].s_updt_dt_tm =
   format(ce2.updt_dt_tm,"mm/dd/yy hh:mm;;d"),
   m_rec->note[ml_note].version[ml_ver].s_updt_prsnl = trim(cnvtstring(ce2.updt_id))
   IF ((m_rec->note[ml_note].version[ml_ver].s_sequence != "")
    AND (m_rec->note[ml_note].version[ml_ver].s_sequence != "1"))
    m_rec->note[ml_note].version[ml_ver].s_addendum = concat("  ",trim(ce2.event_title_text),"  ")
   ENDIF
  FOOT  ce2.clinical_event_id
   m_rec->note[ml_note].j_event_id = ce2.event_id
  FOOT REPORT
   CALL alterlist(m_rec->note,ml_note), ml_note_total = ml_note,
   CALL echo(build2("Total notes found: ",ml_note_total))
  WITH nocounter
 ;end select
 IF (ms_input_type="1")
  SET ms_input_summary = concat("file ",ms_filename_in,char(10),"Input File Location: ",
   ms_input_file_dir_str)
 ELSE
  SET ms_input_summary = concat(format(mf_beg_dt_tm,"MM/DD/YYYY-HH:MM;;d")," - ",format(mf_end_dt_tm,
    "MM/DD/YYYY-HH:MM;;d"))
 ENDIF
 IF (ml_note_total > 0)
  SELECT DISTINCT INTO "nl:"
   var_person = m_rec->note[d.seq].f_person_id
   FROM (dummyt d  WITH seq = value(size(m_rec->note,5)))
   PLAN (d)
   ORDER BY d.seq
   DETAIL
    ml_patient_total = (ml_patient_total+ 1)
   WITH nocounter
  ;end select
  SET ms_log = concat("Input Type: ",ms_input_summary,char(10),"Found ",trim(cnvtstring(ml_note_total
     )),
   " notes under ",trim(cnvtstring(ml_patient_total))," patients.",char(10),"Extract Location: ",
   ms_output_dir_str,"\Notes",char(10),"JASON TEST SUB FOLD: ",ms_output_sub_fold,
   char(10),"JASON TEST DIR: ",ms_output_dir,char(10),"JASON TEST DIR STR: ",
   ms_output_dir_str,char(10),"Index Filename: ",ms_index_filename)
  IF (textlen(ms_email) > 0)
   SET ms_tmp = concat("Clinical Note Extract Summary ",cnvtlower(ms_index_filename))
   CALL uar_send_mail(ms_email,ms_tmp,ms_log,nullterm(concat("NOTES EXTRACTION ",curnode)),1,
    "IPM.NOTE")
  ENDIF
  IF (ms_output_type="4")
   GO TO exit_script
  ENDIF
 ELSE
  SET ms_log = concat("     Clinical Note Extract Summary",char(10),"Input Type: ",ms_input_summary,
   char(10),
   "Notes not found for current input.")
  GO TO exit_script
 ENDIF
 FOR (ml_note = 1 TO size(m_rec->note,5))
   CALL echo("********** 00")
   FOR (ml_ver = 1 TO size(m_rec->note[ml_note].version,5))
     IF (ml_ver=1)
      SET ms_blob_rtf = bhs_sbr_get_blob(m_rec->note[ml_note].version[ml_ver].f_event_id,1)
     ELSE
      SET ms_blob_rtf = concat(ms_blob_rtf,m_rec->note[ml_note].version[ml_ver].s_addendum,
       bhs_sbr_get_blob(m_rec->note[ml_note].version[ml_ver].f_event_id,1))
     ENDIF
   ENDFOR
   CALL echo("******* 1")
   IF (((ms_output_type="1") OR (ms_output_type="2")) )
    SELECT INTO value(m_rec->note[ml_note].s_filename)
     FROM dummyt d1
     HEAD REPORT
      col 0, ms_blob_rtf
     WITH nocounter, format = variable, maxcol = 35000
    ;end select
   ELSEIF (ms_output_type="3")
    CALL echo("******* 2")
    SET d0 = initializereport(0)
    SET becont = 0
    SET d0 = sec_note(rpt_render,7.75,becont)
    WHILE (becont=1)
     SET d0 = pagebreak(1)
     SET d0 = sec_note(rpt_render,7.75,becont)
    ENDWHILE
    SET d0 = finalizereport(m_rec->note[ml_note].s_filename)
   ENDIF
   CALL echo("******* 3")
   SET ml_stat = - (1)
   SET ms_dclcom = concat("$cust_script/bhs_ftp_file.ksh ",m_rec->note[ml_note].s_filename,
    " 172.17.10.5 'bhs\cisftp' C!sftp01 ","'",'"',
    ms_output_sub_fold,"\Notes",'"',"'")
   CALL dcl(ms_dclcom,size(ms_dclcom),ml_stat)
   CALL echo(ms_dclcom)
   CALL echo(build2("Status: ",ml_stat))
   CALL echo("******* 4")
   IF (ml_stat=0)
    IF (ml_header=0)
     SET ms_log = concat(ms_log,char(10),char(10),
      "Check if extract location exist, create folders if need.")
    ENDIF
    SET ms_log = concat(ms_log,char(10),m_rec->note[ml_note].s_filename," file not send successful.")
    SET ml_header = 1
   ENDIF
   CALL echo("******* 5")
   SET ml_stat = 0
   SET ms_dclcom = concat("rm -f ",m_rec->note[ml_note].s_filename)
   CALL dcl(ms_dclcom,size(ms_dclcom),ml_stat)
   CALL echo(ms_dclcom)
   CALL echo(build2("Status: ",ml_stat))
   CALL echo("******* 6")
 ENDFOR
 SELECT INTO value(ms_index_filename)
  FROM (dummyt d  WITH seq = value(size(m_rec->note,5)))
  PLAN (d)
  HEAD REPORT
   ms_tmp =
   "NOTE_SIGNIFICANT_DT_TM,FILE_NAME,ENCNTR_ID,PERSON_ID,CMRN,FIN,MRN,NOTE_TYPE,NOTE_TITLE,NOTE_CREATE_DT_TM,EVENT_ID",
   col 0, ms_tmp
  DETAIL
   ms_tmp = "", ms_tmp = concat(trim(m_rec->note[d.seq].s_search_dt),",",trim(m_rec->note[d.seq].
     s_filename),",",trim(cnvtstring(m_rec->note[d.seq].f_encntr_id)),
    ",",trim(cnvtstring(m_rec->note[d.seq].f_person_id)),",",trim(m_rec->note[d.seq].s_cmrn),",",
    trim(m_rec->note[d.seq].s_fin),",",trim(m_rec->note[d.seq].s_mrn),",",'"',
    trim(m_rec->note[d.seq].s_note_type),'"',",",'"',trim(m_rec->note[d.seq].s_note_title),
    '"',",",trim(m_rec->note[d.seq].s_create_dt),",",trim(cnvtstring(m_rec->note[d.seq].
      f_parent_event_id))), row + 1,
   col 0, ms_tmp
  WITH nocounter, format = variable, maxrow = 1,
   maxcol = 3000, append
 ;end select
 SET ms_dclcom = concat("$cust_script/bhs_ftp_file.ksh ",cnvtlower(ms_index_filename),
  " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',ms_output_sub_fold,
  '"',"'")
 CALL echo("*** FTP RESULTS ***")
 CALL echo(ms_dclcom)
 CALL echo("---")
 DECLARE j_dcl = i2
 SET j_dcl = - (1)
 SET j_dcl = dcl(ms_dclcom,size(ms_dclcom),ml_stat)
 CALL echo(ml_stat)
 CALL echo(j_dcl)
 CALL echo("%%%")
 SET ms_dclcom = concat("rm -f ",cnvtlower(ms_index_filename))
 CALL echo(ms_dclcom)
 CALL dcl(ms_dclcom,size(ms_dclcom),ml_stat)
 CALL echo(ml_stat)
#exit_script
END GO
