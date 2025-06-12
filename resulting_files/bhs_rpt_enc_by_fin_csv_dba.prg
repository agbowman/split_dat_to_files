CREATE PROGRAM bhs_rpt_enc_by_fin_csv:dba
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  ps_med_svc = trim(uar_get_code_display(e.med_service_cd),3)
  FROM encntr_alias ea,
   encounter e
  PLAN (ea
   WHERE expand(ml_exp,1,size(requestin->list_0,5),ea.alias,trim(requestin->list_0[ml_exp].
     account_number,3)))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
  ORDER BY ps_med_svc
  HEAD REPORT
   pl_cnt = size(m_rec->alias,5)
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->alias,5))
    CALL alterlist(m_rec->alias,(pl_cnt+ 500))
   ENDIF
   m_rec->alias[pl_cnt].s_encntr_id = trim(cnvtstring(e.encntr_id),3), m_rec->alias[pl_cnt].s_alias
    = trim(ea.alias,3), m_rec->alias[pl_cnt].s_alias_type = trim(uar_get_code_display(ea
     .encntr_alias_type_cd),3),
   m_rec->alias[pl_cnt].s_alias_pool_disp = trim(uar_get_code_display(ea.alias_pool_cd),3), m_rec->
   alias[pl_cnt].s_encntr_class = trim(uar_get_code_display(e.encntr_class_cd),3), m_rec->alias[
   pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3),
   m_rec->alias[pl_cnt].s_active_status = trim(uar_get_code_display(e.active_status_cd),3), m_rec->
   alias[pl_cnt].s_med_svc = trim(uar_get_code_display(e.med_service_cd),3)
   IF (e.disch_dt_tm != null)
    m_rec->alias[pl_cnt].s_disch_dt_tm = trim(format(e.disch_dt_tm,"mm/dd/yy hh:mm;;d"),3)
   ENDIF
   IF (e.depart_dt_tm != null)
    m_rec->alias[pl_cnt].s_depart_dt_tm = trim(format(e.depart_dt_tm,"mm/dd/yy hh:mm;;d"),3)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->alias,pl_cnt)
  WITH nocounter, expand = 2
 ;end select
#exit_script
END GO
