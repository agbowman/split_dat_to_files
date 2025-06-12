CREATE PROGRAM bhs_sens_prob_ccd:dba
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 EXECUTE bhs_ma_email_file
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = vc
   1 ccd[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_event_id = f8
     2 s_id_type = vc
     2 f_event_dt_tm = f8
     2 s_event_dt_tm = vc
     2 s_fin = vc
     2 n_sens_prob_ind = i2
     2 c_status = c1
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_sens_prob_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12033,
   "SENSITIVE"))
 DECLARE ms_encntr_type = vc WITH protect, noconstant(" ")
 DECLARE ms_dm_info_name = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ccd_size = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_template_param = vc WITH protect, noconstant(" ")
 DECLARE mn_prod_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_min_encntr_id = vc WITH protect, noconstant(" ")
 DECLARE ms_max_encntr_id = vc WITH protect, noconstant(" ")
 CALL echo(concat("mf_ACTIVE_CD: ",trim(cnvtstring(mf_active_cd))))
 CALL echo(build2("mf_SENS_PROB_CAT_CD: ",mf_sens_prob_cat_cd))
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="BHS_SENS_PROB_CCD"
   AND d.info_name="STOP"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET ms_log = "DM_INFO row set to stop - exiting"
  GO TO exit_script
 ENDIF
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 SET reply->status_data[1].status = "F"
 SET ml_num = size(requestin->list_0,5)
 IF (ml_num > 0)
  CALL echo(build2("ml_num: ",ml_num))
  CALL alterlist(m_rec->pat,ml_num)
  FOR (ml_loop = 1 TO size(requestin->list_0,5))
    SET m_rec->pat[ml_loop].f_encntr_id = cnvtreal(requestin->list_0[ml_loop].encntr_id)
    SET m_rec->pat[ml_loop].f_person_id = cnvtreal(requestin->list_0[ml_loop].person_id)
    SET m_rec->pat[ml_loop].s_fin = trim(requestin->list_0[ml_loop].fin)
  ENDFOR
  SET ms_min_encntr_id = trim(requestin->list_0[1].encntr_id)
  SET ms_max_encntr_id = trim(requestin->list_0[ml_num].encntr_id)
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=m_rec->pat[1].f_encntr_id)
   HEAD REPORT
    ms_encntr_type = cnvtupper(trim(uar_get_code_display(e.encntr_type_class_cd))), ms_dm_info_name
     = concat(trim(cnvtupper(ms_encntr_type)),"_STOP_DT_TM"),
    CALL echo(ms_encntr_type)
   WITH nocounter
  ;end select
 ELSE
  SET ms_log = "requestin size = 0; exit"
  GO TO exit_script
 ENDIF
 IF (gl_bhs_prod_flag=1)
  SET mn_prod_ind = 1
 ENDIF
 IF (ms_encntr_type="OUT*")
  SET ms_filename = concat("bhs_sens_cda_outpt_",trim(format(sysdate,"mmddyyhhmmss;;d")),".csv")
 ELSEIF (ms_encntr_type="IN*")
  SET ms_filename = concat("bhs_sens_cda_inpt_",trim(format(sysdate,"mmddyyhhmmss;;d")),".csv")
 ENDIF
 CALL echo(concat("ms_filename: ",ms_filename))
 CALL echo("get problems")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pat,5))),
   problem p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=m_rec->pat[d.seq].f_person_id)
    AND p.active_ind=1
    AND p.active_status_cd=mf_active_cd
    AND p.classification_cd=mf_sens_prob_cat_cd)
  ORDER BY d.seq
  HEAD REPORT
   pl_cnt = 0, pl_prob_cnt = 0
  HEAD d.seq
   ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),m_rec->pat[d.seq].f_encntr_id,m_rec->ccd[ml_num].
    f_encntr_id,
    p.person_id,m_rec->ccd[ml_num].f_person_id)
   IF (ml_idx=0)
    pl_cnt += 1, pl_prob_cnt += 1,
    CALL alterlist(m_rec->ccd,pl_cnt),
    m_rec->ccd[pl_cnt].f_person_id = p.person_id, m_rec->ccd[pl_cnt].f_encntr_id = m_rec->pat[d.seq].
    f_encntr_id, m_rec->ccd[pl_cnt].f_event_id = p.problem_id,
    m_rec->ccd[pl_cnt].s_id_type = "PROBLEM", m_rec->ccd[pl_cnt].f_event_dt_tm = p
    .beg_effective_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(p.beg_effective_dt_tm,
      "dd-mmm-yyyy hh:mm:ss;;d")),
    m_rec->ccd[pl_cnt].s_fin = trim(m_rec->pat[d.seq].s_fin), m_rec->ccd[pl_cnt].n_sens_prob_ind = 1
   ENDIF
  FOOT REPORT
   CALL echo(concat(trim(cnvtstring(pl_prob_cnt))," rows found on problem"))
  WITH nocounter
 ;end select
 SET ml_ccd_size = size(m_rec->ccd,5)
 IF (ml_ccd_size=0)
  SET ms_log = "No CCDs found"
  CALL bhs_sbr_log("log","",0,"CCD",0.0,
   "","NO CCDs FOUND","S")
  UPDATE  FROM dm_info d
   SET d.info_char = "No CCDs found", d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
   WHERE d.info_domain="BHS_SENS_PROB_CCD"
    AND d.info_name="RUNNING"
   WITH nocounter
  ;end update
  COMMIT
  IF (curqual > 0)
   CALL echo("dm_info row updated")
  ENDIF
 ELSE
  CALL echo(build2("call gen ccd script: ",ml_ccd_size," CCDs"))
  CALL bhs_sbr_log("log","",0,"CCD",0.0,
   "",trim(build2("Total CCDs found: ",ml_ccd_size)),"R")
  IF (gl_bhs_prod_flag=0)
   SET ms_template_param = "T:568695666.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
  ELSE
   SET ms_template_param = "T:569993167.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
  ENDIF
  FOR (ml_loop = 1 TO ml_ccd_size)
    IF (validate(reply2))
     SET stat = initrec(reply2)
    ELSE
     RECORD reply2(
       1 status_data[1]
         2 status = c1
     )
    ENDIF
    SET trace = recpersist
    EXECUTE bhs_si_ccd_trigger 0, ms_template_param, m_rec->ccd[ml_loop].f_person_id,
    m_rec->ccd[ml_loop].f_encntr_id, "" WITH replace("REPLY","REPLY2")
    IF ((reply2->status_data[1].status != "S"))
     SET ml_fail_cnt += 1
     SET m_rec->ccd[ml_loop].c_status = "F"
    ELSE
     SET ml_sent_cnt += 1
     SET m_rec->ccd[ml_loop].c_status = "S"
    ENDIF
    SET trace = norecpersist
    SET ms_tmp = concat("latest CCD-",trim(cnvtstring(ml_loop))," of ",trim(cnvtstring(ml_ccd_size)),
     " ",
     "personID: ",trim(cnvtstring(m_rec->ccd[ml_loop].f_person_id))," encntrID: ",trim(cnvtstring(
       m_rec->ccd[ml_loop].f_encntr_id))," eventID: ",
     trim(cnvtstring(m_rec->ccd[ml_loop].f_event_id)))
    CALL bhs_sbr_log("stop","",0,"",0.0,
     "",ms_tmp,"R")
    UPDATE  FROM dm_info d
     SET d.info_char = ms_tmp, d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
     WHERE d.info_domain="BHS_SENS_PROB_CCD"
      AND d.info_name="RUNNING"
     WITH nocounter
    ;end update
    COMMIT
    IF (curqual > 0)
     CALL echo("dm_info row updated")
    ENDIF
  ENDFOR
  SELECT INTO value(ms_filename)
   FROM (dummyt d  WITH seq = value(ml_ccd_size)),
    person_alias pa
   PLAN (d)
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(m_rec->ccd[d.seq].f_person_id))
     AND pa.active_ind=1
     AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd)) )
   ORDER BY d.seq
   HEAD REPORT
    ms_tmp = "encntr_id,person_id,event_name,event_id,event_dt_tm,fin,cmrn,send_status", col 0,
    ms_tmp
   HEAD d.seq
    row + 1, ms_tmp = concat('"',trim(cnvtstring(m_rec->ccd[d.seq].f_encntr_id)),'",','"',trim(
      cnvtstring(m_rec->ccd[d.seq].f_person_id)),
     '",','"',m_rec->ccd[d.seq].s_id_type,'",','"',
     trim(cnvtstring(m_rec->ccd[d.seq].f_event_id)),'",','"',m_rec->ccd[d.seq].s_event_dt_tm,'",',
     '"',m_rec->ccd[d.seq].s_fin,'",','"',trim(pa.alias),
     '",','"',m_rec->ccd[d.seq].c_status,'"'), col 0,
    ms_tmp
   WITH nocounter, maxrow = 1, maxcol = 1000
  ;end select
  CALL bhs_sbr_log("log","",0,"CCD",0.0,
   "",concat("CCD csv file generated: ",ms_filename),"R")
 ENDIF
 SET ms_tmp = trim(concat("CCDs found: ",trim(cnvtstring(ml_ccd_size)),"; sent: ",trim(cnvtstring(
     ml_sent_cnt)),"; failed: ",
   trim(cnvtstring(ml_fail_cnt))))
 CALL bhs_sbr_log("log","",0,"CCD",0.0,
  "",ms_tmp,"S")
 SET reply->status_data[1].status = "S"
 CALL echo("FTP file to share")
 IF (ml_ccd_size=0)
  SET ms_filename = replace(ms_filename,".csv",".txt")
  SELECT INTO value(ms_filename)
   FROM dummyt d
   HEAD REPORT
    col 0, "No data found",
    CALL echo("no data found")
   WITH nocounter
  ;end select
  SET ms_log = "no data found"
  CALL uar_send_mail(nullterm("CISCore@bhs.org"),nullterm(ms_tmp),nullterm(
    "no ccds found for this job"),nullterm("CCD OPS JOB"),1,
   nullterm("IPM.NOTE"))
  GO TO exit_script
 ENDIF
 IF (mn_prod_ind=1)
  SET ms_ftp_path = "ciscore\HIE\PROD\PVIX CCD"
 ELSE
  SET ms_ftp_path = "ciscore\HIE\NONPROD\PVIX CCD"
 ENDIF
 IF (((gl_bhs_prod_flag=1) OR (gs_bhs_domain_name="READ")) )
  SET ms_dcl = concat("$cust_script/bhs_ftp_file.ksh ",ms_filename,
   " transfer.baystatehealth.org CernerFTP gJeZD64 '",'"',ms_ftp_path,
   '"',"'")
 ELSE
  SET ms_dcl = concat("$bhscust/bhs_ftp_file.ksh ",ms_filename,
   " transfer.baystatehealth.org CernerFTP gJeZD64 '",'"',ms_ftp_path,
   '"',"'")
 ENDIF
 CALL echo(ms_dcl)
 CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 CALL echo(build2("ftp dcl stat: ",mn_dcl_stat))
 SET ms_tmp = concat(gs_bhs_domain_name," ",ms_encntr_type," SensCDA job: ",ms_min_encntr_id,
  " - ",ms_max_encntr_id)
 SET ms_tmp = concat(ms_tmp,char(10),"CCDs executes for range ",ms_min_encntr_id," to ",
  ms_max_encntr_id)
 SET ms_tmp = concat(ms_tmp,char(10),"CCDs found: ",trim(cnvtstring(ml_ccd_size)),"; sent: ",
  trim(cnvtstring(ml_sent_cnt)),"; failed: ",trim(cnvtstring(ml_fail_cnt)))
 CALL emailfile(value(ms_filename),ms_filename,"joe.echols@bhs.org",ms_tmp,0)
 CALL pause(5)
 SET ms_dcl = concat("rm -f ",ms_filename)
 CALL dcl(ms_dcl,size(ms_dcl),mn_dcl_stat)
 CALL echo(build2("rm dcl stat: ",mn_dcl_stat))
 GO TO exit_script
#exit_script
 CALL echo(concat("Log: ",ms_log))
 IF ((reply->status_data[1].status="S"))
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("CCDs found: ",ml_ccd_size)),"End Time","S")
 ELSE
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("Failed: ",ms_log)),"End Time","F")
 ENDIF
 SET ms_tmp = concat("CCDs executes for range ",ms_min_encntr_id," too ",ms_max_encntr_id)
 SET ms_log = concat(ms_log,char(10),ms_tmp)
 IF ((reply->status_data[1].status="F"))
  SET ms_log = concat(ms_log,char(10),"failed")
 ELSE
  SET ms_tmp = trim(concat("CCDs found: ",trim(cnvtstring(ml_ccd_size)),"; sent: ",trim(cnvtstring(
      ml_sent_cnt)),"; failed: ",
    trim(cnvtstring(ml_fail_cnt))))
  SET ms_log = concat(ms_log,char(10),ms_tmp)
 ENDIF
 FREE RECORD m_rec
END GO
