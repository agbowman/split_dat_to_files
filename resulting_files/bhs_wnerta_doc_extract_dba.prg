CREATE PROGRAM bhs_wnerta_doc_extract:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 cds[*]
     2 f_cd = f8
     2 s_disp_key = vc
   1 pat[*]
     2 f_person_id = f8
     2 f_first_encntr_id = f8
     2 s_mrn = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_name_last = vc
     2 s_name_first = vc
     2 s_middle_initial = vc
     2 s_dob = vc
     2 s_ssn = vc
     2 doc[*]
       3 f_event_id = f8
       3 n_mdoc_ind = i2
       3 f_encntr_id = f8
       3 s_filename = vc
       3 s_reg_dt_tm = vc
       3 s_signed_by = vc
       3 s_signed_by_id = vc
       3 s_signed_dt_tm = vc
       3 s_facility = vc
       3 s_doc_name = vc
       3 s_doc_type = vc
       3 s_doc_cat = vc
       3 s_doc_path = vc
       3 s_action = vc
       3 s_action_status = vc
 ) WITH protect
 DECLARE ms_file_pat_notes = vc WITH protect, constant("bhs_wnr_doc_2015b_03.csv")
 DECLARE ms_ftp_path = vc WITH protect, noconstant(
  "ciscore\WNERTA_EXTRACT\PROD\NEPHROLOGY_NOTES\2015b\03")
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_ssn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"SSN"))
 DECLARE mf_no_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE mf_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE mf_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_in_error_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inerrnomut_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerrornoview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE ml_pat = i4 WITH protect, noconstant(0)
 DECLARE ml_doc = i4 WITH protect, noconstant(0)
 DECLARE ms_file = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_blob_rtf = vc WITH protect, noconstant(" ")
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_num2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_pat = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_notes_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_file_ind = i4 WITH protect, noconstant(0)
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
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsec_note = i2 WITH noconstant(0), protect
 DECLARE _hrtf_fieldname0 = i4 WITH noconstant(0), protect
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
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(ms_blob_rtf,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
   ENDIF
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   IF (ncalc=rpt_render
    AND _remfieldname0 > 0)
    IF (_hrtf_fieldname0=0)
     SET _hrtf_fieldname0 = uar_rptcreatertf(_hreport,__fieldname0,7.250)
    ENDIF
    SET _fdrawheight = maxheight
    SET _rptstat = uar_rptrtfdraw(_hreport,_hrtf_fieldname0,(offsetx+ 0.000),(offsety+ 0.000),
     _fdrawheight)
    IF ((_fdrawheight > (sectionheight - 0.000)))
     SET sectionheight = (0.000+ _fdrawheight)
    ENDIF
    IF (_rptstat != rpt_continue)
     SET _rptstat = uar_rptdestroyrtf(_hreport,_hrtf_fieldname0)
     SET _hrtf_fieldname0 = 0
     SET _remfieldname0 = 0
    ENDIF
   ENDIF
   SET growsum = (growsum+ _remfieldname0)
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
   SET rptreport->m_reportname = "BHS_WNERTA_DOC_EXTRACT"
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
   SET rptfont->m_recsize = 50
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
 IF (size(requestin->list_0,5)=0)
  GO TO exit_script
 ENDIF
 FOR (ml_loop = 1 TO size(requestin->list_0,5))
   CALL alterlist(m_rec->pat,ml_loop)
   SET m_rec->pat[ml_loop].f_person_id = cnvtreal(requestin->list_0[ml_loop].person_id)
   SET m_rec->pat[ml_loop].f_first_encntr_id = cnvtreal(requestin->list_0[ml_loop].encntr_id)
   SET m_rec->pat[ml_loop].s_mrn = requestin->list_0[ml_loop].mrn
   SET m_rec->pat[ml_loop].s_cmrn = requestin->list_0[ml_loop].cmrn
   SET m_rec->pat[ml_loop].s_fin = requestin->list_0[ml_loop].fin
   SET m_rec->pat[ml_loop].s_name_last = requestin->list_0[ml_loop].last_name
   SET m_rec->pat[ml_loop].s_name_first = requestin->list_0[ml_loop].first_name
   SET m_rec->pat[ml_loop].s_middle_initial = requestin->list_0[ml_loop].middle_initial
   SET m_rec->pat[ml_loop].s_dob = requestin->list_0[ml_loop].birthdate
   SET m_rec->pat[ml_loop].s_ssn = requestin->list_0[ml_loop].ssn
 ENDFOR
 FREE RECORD requestin
 CALL echo(build2("rec size: ",size(m_rec->pat,5)))
 CALL echo(
  "******************************************************************************************************"
  )
 CALL echo("here")
 IF (size(m_rec->pat,5)=0)
  CALL echo("no patients found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ce.person_id, ce.event_id
  FROM encounter e,
   clinical_event ce,
   encntr_loc_hist elh,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   prsnl pr,
   ce_blob cb
  PLAN (e
   WHERE (e.person_id=m_rec->pat[1].f_person_id)
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND  NOT (ce.result_status_cd IN (mf_cancel_cd, mf_in_error_cd, mf_inerror_cd, mf_inerrnomut_cd,
   mf_inerrornoview_cd))
    AND ce.event_cd IN (1596729.00, 139638010.00, 150226276.00, 342720467.00, 342720471.00,
   342720475.00, 342720479.00, 342720483.00, 565310553.00, 567447369.00)
    AND ce.person_id=e.person_id)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND elh.active_ind=1
    AND ((ce.performed_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm) OR (ce
   .performed_dt_tm > e.disch_dt_tm)) )
   JOIN (ea1
   WHERE ea1.encntr_id=ce.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > sysdate
    AND ea1.encntr_alias_type_cd=1077
    AND ea1.alias="WNR*")
   JOIN (ea2
   WHERE ea2.encntr_id=ce.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.encntr_alias_type_cd=1079)
   JOIN (p
   WHERE p.person_id=ce.person_id)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id)
   JOIN (cb
   WHERE cb.event_id=ce.event_id)
  ORDER BY ce.person_id, ce.event_id DESC
  HEAD REPORT
   pl_tot_cnt = 0, pl_cnt = 0
  HEAD ce.person_id
   pl_cnt = 0
  HEAD ce.event_id
   ml_notes_ind = 1, pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->pat[1].doc,pl_cnt),
   m_rec->pat[1].doc[pl_cnt].f_event_id = ce.event_id
   IF (ce.event_class_cd=mf_mdoc_cd)
    m_rec->pat[1].doc[pl_cnt].n_mdoc_ind = 1
   ENDIF
   m_rec->pat[1].doc[pl_cnt].f_encntr_id = ce.encntr_id, m_rec->pat[1].doc[pl_cnt].s_reg_dt_tm = trim
   (format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->pat[1].doc[pl_cnt].s_signed_by = trim(pr
    .name_full_formatted),
   m_rec->pat[1].doc[pl_cnt].s_signed_by_id = trim(cnvtstring(ce.performed_prsnl_id)), m_rec->pat[1].
   doc[pl_cnt].s_signed_dt_tm = trim(format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d")), m_rec->pat[1].
   doc[pl_cnt].s_facility = trim(uar_get_code_display(elh.loc_facility_cd)),
   m_rec->pat[1].doc[pl_cnt].s_doc_name = trim(ce.event_title_text), m_rec->pat[1].doc[pl_cnt].
   s_doc_type = trim(uar_get_code_display(ce.event_cd)), m_rec->pat[1].doc[pl_cnt].s_doc_path =
   "CIS CE_BLOB table"
  FOOT  ce.person_id
   pl_tot_cnt = (pl_tot_cnt+ pl_cnt)
  FOOT REPORT
   CALL echo(build2("tot notes found: ",pl_tot_cnt))
  WITH nocounter, expand = 1
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(m_rec->pat[1].doc,5))),
    ce_event_prsnl cep
   PLAN (d)
    JOIN (cep
    WHERE (cep.event_id=m_rec->pat[1].doc[d.seq].f_event_id))
   ORDER BY cep.event_id, cep.action_dt_tm DESC
   HEAD cep.event_id
    m_rec->pat[1].doc[d.seq].s_action = trim(uar_get_code_display(cep.action_type_cd)), m_rec->pat[1]
    .doc[d.seq].s_action_status = trim(uar_get_code_display(cep.action_status_cd))
   WITH nocounter
  ;end select
  FOR (ml_loop = 1 TO size(m_rec->pat[1].doc,5))
    IF (textlen(trim(m_rec->pat[1].doc[ml_loop].s_action))=0
     AND textlen(trim(m_rec->pat[1].doc[ml_loop].s_action_status))=0)
     SET m_rec->pat[1].doc[ml_loop].s_action = "Perform"
     SET m_rec->pat[1].doc[ml_loop].s_action_status = "Completed"
    ENDIF
  ENDFOR
 ENDIF
 FOR (ml_loop = 1 TO size(m_rec->pat,5))
   FOR (ml_doc = 1 TO size(m_rec->pat[ml_loop].doc,5))
    SELECT INTO "nl:"
     FROM ce_blob cb
     PLAN (cb
      WHERE (cb.event_id=m_rec->pat[ml_loop].doc[ml_doc].f_event_id)
       AND cb.valid_until_dt_tm > sysdate)
     ORDER BY cb.event_id
     HEAD REPORT
      ps_blob_out = fillstring(64000," "), pl_blob_ret_len = 0
     HEAD cb.event_id
      ps_blob_out = fillstring(64000," "), pl_blob_ret_len = 0
      IF (cb.compression_cd=mf_comp_cd)
       CALL uar_ocf_uncompress(trim(cb.blob_contents),textlen(trim(cb.blob_contents)),ps_blob_out,
       size(ps_blob_out),64000), ms_blob_rtf = trim(ps_blob_out)
      ELSEIF (cb.compression_cd=mf_no_comp_cd)
       ms_blob_rtf = trim(cb.blob_contents)
       IF (findstring("ocf_blob",ms_blob_rtf) > 0)
        ms_blob_rtf = replace(ms_blob_rtf,"ocf_blob","",0)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET ms_file = concat("bhs_wnr_neph_",trim(cnvtstring(m_rec->pat[ml_loop].doc[ml_doc].f_event_id)
       ),".pdf")
     SET m_rec->pat[ml_loop].doc[ml_doc].s_filename = ms_file
     CALL echo(concat("filename: ",ms_file))
     SET d0 = initializereport(0)
     SET becont = 0
     SET d0 = sec_note(rpt_render,7.75,becont)
     WHILE (becont=1)
      SET d0 = pagebreak(1)
      SET d0 = sec_note(rpt_render,7.75,becont)
     ENDWHILE
     SET d0 = finalizereport(ms_file)
     SET ms_dcl = concat("$cust_script/bhs_ftp_file.ksh ",ms_file,
      " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',ms_ftp_path,
      '"',"'")
     CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
    ENDIF
   ENDFOR
 ENDFOR
 IF (ml_notes_ind > 0)
  IF (findfile(ms_file_pat_notes) > 0)
   SET ml_file_ind = 1
  ENDIF
  SELECT INTO value(ms_file_pat_notes)
   FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,size(m_rec->pat[d1.seq].doc,5)))
    JOIN (d2)
   ORDER BY d1.seq, d2.seq
   HEAD REPORT
    ms_tmp = concat(
     "|CIS Person ID|,|CIS First Encounter ID|,|MRN|,|CMRN|,|FIN|,|Last Name|,|First Name|,|Middle Initial|,",
     "|Birthdate|,|Social Security|,|CIS Event ID|,|CIS Encntr ID|,|Reg Dt Tm|,|Signed By|,|Signed Dt Tm|,",
     "|Signed By Cerner ID|,",
     "|Action Type|,|Action Status|,|Location|,|Doc Name|,|Doc Type|,|Doc Category|,|Path and File|,",
     "|pdf filename|")
    IF (ml_file_ind=0)
     col 0, ms_tmp
    ENDIF
   HEAD d1.seq
    ms_tmp_pat = "", ms_tmp = "", ms_tmp_pat = concat("|",trim(cnvtstring(m_rec->pat[d1.seq].
       f_person_id)),"|,","|",trim(cnvtstring(m_rec->pat[d1.seq].f_first_encntr_id)),
     "|,","|",trim(m_rec->pat[d1.seq].s_mrn),"|,","|",
     trim(m_rec->pat[d1.seq].s_cmrn),"|,","|",trim(m_rec->pat[d1.seq].s_fin),"|,",
     "|",trim(m_rec->pat[d1.seq].s_name_last),"|,","|",trim(m_rec->pat[d1.seq].s_name_first),
     "|,","|",trim(m_rec->pat[d1.seq].s_middle_initial),"|,","|",
     trim(m_rec->pat[d1.seq].s_dob),"|,","|",trim(m_rec->pat[d1.seq].s_ssn),"|,")
   HEAD d2.seq
    ms_tmp = concat(ms_tmp_pat,"|",trim(cnvtstring(m_rec->pat[d1.seq].doc[d2.seq].f_event_id)),"|,",
     "|",
     trim(cnvtstring(m_rec->pat[d1.seq].doc[d2.seq].f_encntr_id)),"|,","|",trim(m_rec->pat[d1.seq].
      doc[d2.seq].s_reg_dt_tm),"|,",
     "|",trim(m_rec->pat[d1.seq].doc[d2.seq].s_signed_by),"|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq
      ].s_signed_dt_tm),
     "|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq].s_signed_by_id),"|,","|",
     trim(m_rec->pat[d1.seq].doc[d2.seq].s_action),"|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq].
      s_action_status),"|,",
     "|",trim(m_rec->pat[d1.seq].doc[d2.seq].s_facility),"|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq]
      .s_doc_name),
     "|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq].s_doc_type),"|,","|",
     trim(m_rec->pat[d1.seq].doc[d2.seq].s_doc_cat),"|,","|",trim(m_rec->pat[d1.seq].doc[d2.seq].
      s_doc_path),"|,",
     "|",trim(m_rec->pat[d1.seq].doc[d2.seq].s_filename),"|"), row + 1, col 0,
    ms_tmp
   WITH nocounter, format = variable, maxrow = 1,
    maxcol = 3000, append
  ;end select
  SET ms_dcl = concat("$cust_script/bhs_ftp_file.ksh ",ms_file_pat_notes,
   " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',ms_ftp_path,
   '"',"'")
  CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 ELSE
  CALL echo("no notes found")
 ENDIF
#exit_script
 FREE RECORD m_rec
 FREE SET all
END GO
