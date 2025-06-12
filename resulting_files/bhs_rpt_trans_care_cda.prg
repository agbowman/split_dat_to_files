CREATE PROGRAM bhs_rpt_trans_care_cda
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ftp
 FREE RECORD m_encntr_in
 RECORD m_encntr_in(
   1 l_cnt = i4
   1 encntr[*]
     2 f_encntr_id = f8
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 cda[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_disch_dt_tm = vc
     2 c_status = c1
 ) WITH protect
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_password = vc WITH protect, constant("gJeZD64")
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_backend_dir = vc WITH protect, constant(logical("bhscust"))
 DECLARE ms_remote_directory = vc WITH protect, constant("ciscore\HIE\INPUT_FILES")
 DECLARE ms_filename_in = vc WITH protect, constant("toc_encounter_list_input.csv")
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_rpt_trans_care_",trim(format(sysdate,
     "mmddyyhhmmss;;d")),".csv"))
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_template_param = vc WITH protect, noconstant(" ")
 DECLARE ml_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_prod_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ml_encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 SET logical encntr_in_ls value(concat("bhscust:",ms_filename_in))
 FREE DEFINE rtl2
 DEFINE rtl2 "encntr_in_ls"  WITH nomodify
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "Encounter ID"
  HEAD REPORT
   m_encntr_in->l_cnt = 0
  DETAIL
   m_encntr_in->l_cnt += 1, stat = alterlist(m_encntr_in->encntr,m_encntr_in->l_cnt), m_encntr_in->
   encntr[m_encntr_in->l_cnt].f_encntr_id = cnvtreal(trim(r.line,3))
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 CALL echorecord(m_encntr_in)
 IF (gl_bhs_prod_flag=0)
  SET ml_prod_ind = 0
 ELSE
  SET ml_prod_ind = 1
 ENDIF
 SET ms_template_param = "T:572564578.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE expand(ml_encntr_cnt,1,size(m_encntr_in->encntr,5),e.encntr_id,m_encntr_in->encntr[
    ml_encntr_cnt].f_encntr_id)
    AND e.disch_dt_tm != null)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pa
   WHERE pa.person_id=e.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  ORDER BY e.disch_dt_tm, e.encntr_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.disch_dt_tm
   null
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->cda,5))
    stat = alterlist(m_rec->cda,(pl_cnt+ 10))
   ENDIF
   m_rec->cda[pl_cnt].f_encntr_id = e.encntr_id, m_rec->cda[pl_cnt].f_person_id = e.person_id, m_rec
   ->cda[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
   m_rec->cda[pl_cnt].s_fin = trim(ea.alias), m_rec->cda[pl_cnt].s_cmrn = trim(pa.alias)
  FOOT REPORT
   stat = alterlist(m_rec->cda,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(m_rec)
 IF (curqual < 1)
  SET ms_output = "No records found for CDA out"
 ELSE
  FOR (ml_loop = 1 TO size(m_rec->cda,5))
    IF (validate(reply2))
     SET stat = initrec(reply2)
    ELSE
     RECORD reply2(
       1 status_data[1]
         2 status = c1
     )
    ENDIF
    SET trace = recpersist
    EXECUTE bhs_si_ccd_trigger 0, ms_template_param, m_rec->cda[ml_loop].f_person_id,
    m_rec->cda[ml_loop].f_encntr_id, "" WITH replace("REPLY","REPLY2")
    IF ((reply2->status_data[1].status != "S"))
     CALL echo("reply 2 status failed")
     SET ml_fail_cnt += 1
     SET m_rec->cda[ml_loop].c_status = "F"
    ELSE
     SET m_rec->cda[ml_loop].c_status = "S"
    ENDIF
    SET trace = norecpersist
  ENDFOR
  SET ms_output = trim(concat("CDAs found: ",trim(cnvtstring(size(m_rec->cda,5))),"; success: ",trim(
     cnvtstring((size(m_rec->cda,5) - ml_fail_cnt))),"; failed: ",
    trim(cnvtstring(ml_fail_cnt))))
 ENDIF
 CALL echo("create the file")
 IF (size(m_rec->cda,5) > 0)
  SELECT INTO value(ms_filename)
   FROM (dummyt d  WITH seq = value(size(m_rec->cda,5)))
   PLAN (d)
   HEAD REPORT
    ms_tmp = "encntr_id,person_id,fin,cmrn,disch_dt_tm,status", col 0, ms_tmp
   DETAIL
    row + 1, ms_tmp = concat('"',trim(cnvtstring(m_rec->cda[d.seq].f_encntr_id)),'",','"',trim(
      cnvtstring(m_rec->cda[d.seq].f_person_id)),
     '",','"',m_rec->cda[d.seq].s_fin,'",','"',
     m_rec->cda[d.seq].s_cmrn,'",','"',m_rec->cda[d.seq].s_disch_dt_tm,'",',
     '"',m_rec->cda[d.seq].c_status,'"'), col 0,
    ms_tmp
   WITH nocounter, maxrow = 1
  ;end select
 ELSE
  SET ms_filename = replace(ms_filename,".csv",".txt")
  SELECT INTO value(ms_filename)
   FROM dummyt d
   HEAD REPORT
    col 0, "No data found"
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("ftp file to share")
 IF (ml_prod_ind=1)
  SET ms_ftp_path = '"ciscore/HIE/PROD/Transition of Care CDA"'
 ELSE
  SET ms_ftp_path = '"ciscore/HIE/NONPROD/Transition of Care CDA"'
 ENDIF
 SET ms_ftp_cmd = concat("put ",ms_filename)
 SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
  ms_ftp_path)
 CALL pause(1)
 SET ms_dcl = concat("rm -f ",ms_filename)
 CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 CALL echo(build2("dcl stat: ",mn_dcl_stat))
 SET ms_dcl = concat("rm -f ",ms_filename_in)
 CALL echo(ms_dcl)
 CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 CALL echo(mn_dcl_stat)
#exit_script
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  HEAD REPORT
   col 0, ms_output
  WITH nocounter
 ;end select
 FREE RECORD m_rec
 FREE RECORD m_encntr_in
END GO
