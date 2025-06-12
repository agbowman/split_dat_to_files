CREATE PROGRAM bhs_medsec_alert_upd_data:dba
 PROMPT
  "behav id" = "0.0",
  "patient type flag" = ""
  WITH f_behav_id, l_pat_type_ind
 EXECUTE ccl_prompt_api_dataset "autoset"
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_beg_dt_tm = vc
   1 s_review_dt_tm = vc
   1 s_reason = vc
   1 s_reason_ft = vc
   1 s_clinical_contact = vc
   1 s_clin_contact_ft = vc
   1 s_clin_phys_name = vc
   1 s_clin_pcp_name = vc
   1 s_intervention = vc
   1 s_location = vc
   1 s_location_ft = vc
 )
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_end_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM bhs_pat_behav_ident b
  WHERE (b.bhs_pat_behav_ident_id= $F_BEHAV_ID)
   AND (b.pat_type_flag= $L_PAT_TYPE_IND)
  HEAD b.bhs_pat_behav_ident_id
   m_rec->s_beg_dt_tm = trim(format(b.beg_effective_dt_tm,"mm/dd/yyyy hh:mm;;d")), m_rec->
   s_review_dt_tm = trim(format(b.review_dt_tm,"mm/dd/yyyy hh:mm;;d")), m_rec->s_reason = b.reason
   IF (findstring("OTHER",b.reason))
    ml_pos = findstring("OTHER-",b.reason), ms_tmp = trim(substring((ml_pos+ 6),textlen(trim(b.reason
        )),b.reason),3), m_rec->s_reason_ft = ms_tmp
   ENDIF
   m_rec->s_clinical_contact = b.clinical_contact
   IF (findstring("Physician-",b.clinical_contact))
    ml_pos = findstring("Physician-",b.clinical_contact), ms_tmp = trim(substring((ml_pos+ 10),
      textlen(trim(b.clinical_contact)),b.clinical_contact),3), ml_end_pos = findstring("|",ms_tmp)
    IF (ml_end_pos != 0)
     ms_tmp = substring(1,(ml_end_pos - 1),ms_tmp)
    ENDIF
    CALL echo(ms_tmp), m_rec->s_clin_phys_name = ms_tmp
   ENDIF
   IF (findstring("PCP-",b.clinical_contact))
    ml_pos = findstring("PCP-",b.clinical_contact), ms_tmp = trim(substring((ml_pos+ 4),textlen(trim(
        b.clinical_contact)),b.clinical_contact),3), ml_end_pos = findstring("|",ms_tmp)
    IF (ml_end_pos != 0)
     ms_tmp = substring(1,(ml_end_pos - 1),ms_tmp)
    ENDIF
    CALL echo(ms_tmp), m_rec->s_clin_pcp_name = ms_tmp
   ENDIF
   IF (findstring("OTHER",b.clinical_contact))
    ml_pos = findstring("OTHER-",b.clinical_contact), ms_tmp = substring((ml_pos+ 6),textlen(trim(b
       .clinical_contact)),b.clinical_contact), m_rec->s_clin_contact_ft = ms_tmp
   ENDIF
   m_rec->s_intervention = trim(b.intervention), m_rec->s_location = trim(b.location)
   IF (findstring("OTHER",b.location))
    ml_pos = findstring("OTHER-",b.location), ms_tmp = substring((ml_pos+ 6),textlen(trim(b.location)
      ),b.location), m_rec->s_location_ft = ms_tmp
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_beg_dt_tm = m_rec->s_beg_dt_tm, ps_review_dt_tm = m_rec->s_review_dt_tm, ps_reason = trim(
   substring(1,1000,m_rec->s_reason),3),
  ps_reason_ft = trim(substring(1,1000,m_rec->s_reason_ft),3), ps_clin_contact = trim(substring(1,
    1000,m_rec->s_clinical_contact),3), ps_clin_contact_ft = trim(substring(1,1000,m_rec->
    s_clin_contact_ft),3),
  ps_phys_name = m_rec->s_clin_phys_name, ps_pcp_name = m_rec->s_clin_pcp_name, ps_intervention =
  trim(substring(1,4000,m_rec->s_intervention),3),
  ps_location = trim(substring(1,100,m_rec->s_location),3), ps_location_ft = trim(substring(1,100,
    m_rec->s_location_ft),3)
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
