CREATE PROGRAM bhs_ops_toc_one_day_child:dba
 PROMPT
  "Beg Date Time:" = "SYSDATE",
  "End Date Time:" = "SYSDATE"
  WITH s_beg_dt_tm, s_end_dt_tm
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
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
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_template_param = vc WITH protect, noconstant(" ")
 DECLARE ml_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_prod_ind = i4 WITH protect, noconstant(0)
 SET reply->status_data[1].status = "F"
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 IF (gl_bhs_prod_flag=0)
  SET ms_template_param = "T:569732517.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
 ELSE
  SET ml_prod_ind = 1
  SET ms_template_param = "T:572564578.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
 ENDIF
 SET ms_beg_dt_tm = trim( $S_BEG_DT_TM)
 SET ms_end_dt_tm = trim( $S_END_DT_TM)
 IF (((textlen(ms_beg_dt_tm)=0) OR (textlen(ms_end_dt_tm)=0)) )
  SET ms_log = "Must populate both beg and end dates"
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_beg_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_log = "Beg date must be < end date"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
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
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->cda,5))
    stat = alterlist(m_rec->cda,(pl_cnt+ 10))
   ENDIF
   m_rec->cda[pl_cnt].f_encntr_id = e.encntr_id, m_rec->cda[pl_cnt].f_person_id = e.person_id, m_rec
   ->cda[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
   m_rec->cda[pl_cnt].s_fin = trim(ea.alias), m_rec->cda[pl_cnt].s_cmrn = trim(pa.alias)
  FOOT REPORT
   stat = alterlist(m_rec->cda,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = "No records found for CDA out"
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
     SET ml_fail_cnt = (ml_fail_cnt+ 1)
     SET m_rec->cda[ml_loop].c_status = "F"
    ELSE
     SET m_rec->cda[ml_loop].c_status = "S"
    ENDIF
    SET trace = norecpersist
    CALL bhs_sbr_log("log","",0,"ENCNTR_ID",m_rec->cda[ml_loop].f_encntr_id,
     "",trim(concat("CDA: ",trim(cnvtstring(ml_loop))," of ",trim(cnvtstring(size(m_rec->cda,5))))),
     m_rec->cda[ml_loop].c_status)
    SET ms_tmp = concat("latest CDA-",trim(cnvtstring(ml_loop))," of ",trim(cnvtstring(size(m_rec->
        cda,5))),": ",
     trim(m_rec->cda[ml_loop].s_disch_dt_tm)," EncntrID: ",trim(cnvtstring(m_rec->cda[ml_loop].
       f_encntr_id)))
    CALL bhs_sbr_log("stop","",0,"",0.0,
     "",ms_tmp,"R")
  ENDFOR
 ENDIF
 SET ms_tmp = concat("CDAs found: ",trim(cnvtstring(size(m_rec->cda,5))),char(13),"; success: ",trim(
   cnvtstring((size(m_rec->cda,5) - ml_fail_cnt))),
  char(13),"; failed: ",trim(cnvtstring(ml_fail_cnt)),char(13),"Job Name: Transition of Care CDA",
  char(13),"Job Run Date: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),"Begin Date: ",
  trim(ms_beg_dt_tm),char(13),"End Date: ",trim(ms_end_dt_tm),char(13),
  "Error: ",ms_log,char(13),char(13))
 CALL bhs_sbr_log("log","",0,"CDA",0.0,
  "",concat("CDAs found: ",trim(cnvtstring(size(m_rec->cda,5))),char(13),"; success: ",trim(
    cnvtstring((size(m_rec->cda,5) - ml_fail_cnt))),
   char(13),"; failed: ",trim(cnvtstring(ml_fail_cnt))),"S")
 SET reply->status_data[1].status = "S"
 SET reply->status_data[1].subeventstatus[1].targetobjectname = "Log Msg"
 SET reply->status_data[1].subeventstatus[1].targetobjectvalue = ms_tmp
#exit_script
 IF ((reply->status_data[1].status="S")
  AND ml_fail_cnt <= 0)
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "CDAs found and sent successfully.","End Time","S")
  CALL echo("send email - Success")
  CALL uar_send_mail(nullterm("Vitaliy.Kiriukhin@bhs.org"),nullterm(concat(
     "Transition of Care CDA Ops Success: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm("Trans Care CDA Ops"),1,
   nullterm("IPM.NOTE"))
  SET reply->status_data[1].subeventstatus[1].operationstatus =
  "EMAILED to Vitaliy.Kiriukhin@bhs.org"
 ELSE
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("Failed: ",ms_log)),"End Time","F")
  CALL echo("send email - Error")
  CALL uar_send_mail(nullterm("Vitaliy.Kiriukhin@bhs.org"),nullterm(concat(
     "Transition of Care CDA Ops Failed: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm("Trans Care CDA Ops"),1,
   nullterm("IPM.NOTE"))
  SET reply->status_data[1].subeventstatus[1].operationstatus =
  "EMAILED to Vitaliy.Kiriukhin@bhs.org"
 ENDIF
 SET ml_mes_count = ((ml_mes_count+ size(m_rec->cda,5)) - ml_fail_cnt)
 FREE RECORD m_rec
END GO
