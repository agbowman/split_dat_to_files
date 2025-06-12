CREATE PROGRAM bhs_ext_trauma_audit_score:dba
 DECLARE ml_wild_pos = i4
 DECLARE ms_temp_str = vc
 DECLARE ml_idx1 = i4
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs72_auditscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "AUDITSCORE"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_fin = vc
     2 s_row = vc
     2 f_encntr_id = f8
     2 s_audit_score = vc
 )
 FREE DEFINE rtl2
 DEFINE rtl2 "bhscust:al_trauma_file.csv"
 SELECT INTO "nl:"
  FROM rtl2t r
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].s_row =
   trim(r.line,3)
   IF ((m_rec->l_cnt > 1)
    AND size(trim(r.line,3)) > 0)
    ml_idx1 = findstring(",",trim(r.line,3)), ms_temp_str = trim(substring((ml_idx1+ 1),size(trim(r
        .line,3)),trim(r.line,3)),3), ml_idx1 = findstring(",",trim(ms_temp_str,3)),
    m_rec->qual[m_rec->l_cnt].s_fin = trim(substring(1,(ml_idx1 - 1),ms_temp_str),3)
   ENDIF
   IF ((m_rec->l_cnt=1))
    m_rec->qual[m_rec->l_cnt].s_audit_score = "AUDIT Score"
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 2 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM encntr_alias ea,
     clinical_event ce
    PLAN (ea
     WHERE (ea.alias=m_rec->qual[ml_idx1].s_fin)
      AND ea.active_ind=1
      AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
     JOIN (ce
     WHERE ce.encntr_id=ea.encntr_id
      AND ce.event_cd=mf_cs72_auditscore_cd
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.view_level=1
      AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd))
    ORDER BY ea.encntr_id, ce.performed_dt_tm DESC
    HEAD ea.encntr_id
     m_rec->qual[ml_idx1].s_audit_score = trim(ce.result_val,3)
    WITH nocounter
   ;end select
 ENDFOR
 SET frec->file_name = concat("bhs_trauma_audit_score",format(cnvtdatetime(sysdate),"MMDDYYYY;;q"),
  ".csv")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
  SET frec->file_buf = build(m_rec->qual[ml_idx1].s_row,",",m_rec->qual[ml_idx1].s_audit_score,char(
    13),char(10))
  SET stat = cclio("WRITE",frec)
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
