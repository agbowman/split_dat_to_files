CREATE PROGRAM bhs_rpt_experian_authrec:dba
 PROMPT
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 cpt[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_name_last = vc
     2 s_name_first = vc
     2 s_dob = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_cpt = vc
     2 s_dos = vc
     2 s_encntr_type = vc
     2 s_ins_mnem = vc
     2 s_referral_id = vc
     2 s_csn = vc
     2 s_pat_status = vc
     2 s_svc_cd = vc
     2 s_nurse_unit = vc
     2 s_fac_npi = vc
     2 s_fac_taxid = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs334_hp_alias = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!12011"))
 CALL echo(build2("mf_CS334_HP_ALIAS: ",mf_cs334_hp_alias))
 DECLARE mf_cs334_npi = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654022"))
 CALL echo(build2("mf_CS334_NPI: ",mf_cs334_npi))
 DECLARE mf_cs400_cpt4 = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2954"))
 CALL echo(build2("mf_CS400_CPT4: ",mf_cs400_cpt4))
 DECLARE mf_cs27121_hp_alias = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2961173")
  )
 CALL echo(build2("mf_CS27121_HP_ALIAS: ",mf_cs27121_hp_alias))
 DECLARE ms_loc_dir = vc WITH protect, constant("$CCLUSERDIR")
 DECLARE ms_rem_dir = vc WITH protect, constant("CISCORE/EXPERIAN")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_user = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_pass = vc WITH protect, constant("C!sftp01")
 DECLARE ms_file_name = vc WITH protect, constant(concat("passportauthrecon",trim(format(sysdate,
     "YYYYMMDD;;d"),3),".txt"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_check_domain
 IF (validate(request->batch_selection)=0)
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ELSE
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 CALL echo("get patients")
 SELECT INTO "nl:"
  sa.encntr_id, sa.sch_state_cd, cm.charge_item_id,
  uar_get_code_display(cm.field1_id), cm.field1_id, cm.field6
  FROM sch_appt sa,
   encounter e,
   person p,
   charge c,
   charge_mod cm,
   encntr_alias ea1,
   encntr_alias ea2,
   organization_alias oa
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND sa.encntr_id > 0.0)
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (c
   WHERE c.encntr_id=sa.encntr_id)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.active_ind=1
    AND cm.field1_id IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14002
     AND cv.cdf_meaning IN ("CPT4", "HCPCS"))))
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm >= e.reg_dt_tm
    AND ea1.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm >= e.reg_dt_tm
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (oa
   WHERE oa.organization_id=e.organization_id
    AND oa.active_ind=1
    AND oa.end_effective_dt_tm > sysdate
    AND oa.org_alias_type_cd=mf_cs334_npi)
  ORDER BY e.encntr_id, c.charge_item_id, cm.field1_id
  HEAD REPORT
   pl_cnt = 0
  HEAD p.person_id
   null
  HEAD e.encntr_id
   null
  HEAD cm.field1_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->cpt,5))
    CALL alterlist(m_rec->cpt,(pl_cnt+ 50))
   ENDIF
   m_rec->cpt[pl_cnt].f_person_id = e.person_id, m_rec->cpt[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->cpt[pl_cnt].s_name_last = trim(p.name_last,3),
   m_rec->cpt[pl_cnt].s_name_first = trim(p.name_first,3), m_rec->cpt[pl_cnt].s_dob = trim(format(
     cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;d"),3), m_rec->cpt[pl_cnt
   ].s_fin = trim(ea1.alias,3),
   m_rec->cpt[pl_cnt].s_mrn = trim(ea2.alias,3), m_rec->cpt[pl_cnt].s_cpt = trim(cm.field6,3), m_rec
   ->cpt[pl_cnt].s_dos = trim(format(sa.beg_dt_tm,"MM/DD/YYYY;;d"),3),
   m_rec->cpt[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->cpt[
   pl_cnt].s_pat_status = trim(uar_get_code_display(p.person_status_cd),3), m_rec->cpt[pl_cnt].
   s_svc_cd = trim(uar_get_code_display(e.med_service_cd),3),
   m_rec->cpt[pl_cnt].s_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->cpt[
   pl_cnt].s_fac_npi = trim(oa.alias,3)
  FOOT REPORT
   CALL alterlist(m_rec->cpt,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_rec->cpt,5)=0)
  CALL echo("no patients found")
  GO TO exit_script
 ENDIF
 CALL echo("get ins")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->cpt,5))),
   encntr_plan_reltn epr,
   health_plan hp,
   health_plan_alias hpa
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=m_rec->cpt[d.seq].f_encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id)
   JOIN (hpa
   WHERE hpa.health_plan_id=hp.health_plan_id
    AND hpa.plan_alias_type_cd=mf_cs27121_hp_alias)
  ORDER BY d.seq, epr.priority_seq
  HEAD d.seq
   m_rec->cpt[d.seq].s_ins_mnem = trim(hpa.alias,3)
  WITH nocounter
 ;end select
 CALL echo("CCLIO")
 IF (size(m_rec->cpt,5) > 0)
  SET frec->file_name = concat(ms_file_name)
  SET stat = cclio("OPEN",frec)
  FOR (ml_loop = 1 TO size(m_rec->cpt,5))
   SET frec->file_buf = concat(m_rec->cpt[ml_loop].s_name_last,"|",m_rec->cpt[ml_loop].s_name_first,
    "|",m_rec->cpt[ml_loop].s_dob,
    "|",m_rec->cpt[ml_loop].s_fin,"|",m_rec->cpt[ml_loop].s_mrn,"|",
    m_rec->cpt[ml_loop].s_cpt,"|",m_rec->cpt[ml_loop].s_dos,"|",m_rec->cpt[ml_loop].s_encntr_type,
    "|",m_rec->cpt[ml_loop].s_ins_mnem,"|","|","|",
    m_rec->cpt[ml_loop].s_pat_status,"|",m_rec->cpt[ml_loop].s_svc_cd,"|",m_rec->cpt[ml_loop].
    s_nurse_unit,
    "|",m_rec->cpt[ml_loop].s_fac_npi,"|","",char(13),
    char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  SET stat = bhs_ftp_cmd(concat("put ",ms_file_name),ms_ftp_host,ms_ftp_user,ms_ftp_pass,ms_loc_dir,
   ms_rem_dir)
  IF (stat=0
   AND gl_bhs_prod_flag=1)
   SET ms_dcl = concat("mv ",ms_file_name," ",trim(logical("bhscust"),3),"/ftp_backup/")
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
   CALL uar_send_mail("joe.echols@bhs.org",build2(curprog," - FTP Fail Backup"),build2(ms_file_name,
     " has been moved into 'bhscust/ftp_backup'.  The intended destination was ",ms_rem_dir),
    "FTP_FAIL",1,
    "IPM.NOTE")
   CALL pause(5)
   SET ms_dcl = concat("rm -f ",build(substring(1,(size(ms_file_name) - 4),ms_file_name),"*"))
   CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
