CREATE PROGRAM bhs_provider_dept_maint_data:dba
 PROMPT
  "phys id" = "0.0"
  WITH f_phys_id
 EXECUTE ccl_prompt_api_dataset "autoset"
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_provider_name = vc
   1 s_dept = vc
   1 s_title = vc
   1 s_status = vc
   1 l_sms_alias = i4
 )
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM bhs_provider_dept b
  WHERE (b.person_id= $F_PHYS_ID)
  HEAD b.person_id
   m_rec->s_provider_name = b.provider_name, m_rec->s_dept = b.dept, m_rec->s_title = b.title,
   m_rec->s_status = b.status, m_rec->l_sms_alias = b.sms_alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET m_rec->s_provider_name = "Provider not found"
 ENDIF
 SELECT INTO "nl:"
  provider_name = m_rec->s_provider_name, dept = m_rec->s_dept, title = m_rec->s_title,
  status = m_rec->s_status, sms_alias = m_rec->l_sms_alias
  FROM dummyt d
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
