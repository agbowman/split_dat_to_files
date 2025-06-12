CREATE PROGRAM bhs_add_other_prsnl_alias:dba
 DECLARE ml_comma_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs320_other_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9852"))
 DECLARE mf_cs263_lynx_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,
   "LYNXPHYSICIANCODE"))
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_prsnl_id = f8
     2 s_alias = vc
     2 l_valid_prsnl = i4
     2 l_exist_ind = i4
 )
 SET logical prsnl_other value("/cerner/d_p627/bhscust/pa_other_alias.csv")
 FREE DEFINE rtl2
 DEFINE rtl2 "prsnl_other"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
  DETAIL
   ml_comma_loc = findstring(",",trim(r.line,3)), m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,
    m_rec->l_cnt),
   m_rec->qual[m_rec->l_cnt].f_prsnl_id = cnvtreal(substring(1,(ml_comma_loc - 1),trim(r.line,3))),
   m_rec->qual[m_rec->l_cnt].s_alias = trim(substring((ml_comma_loc+ 1),50,trim(r.line,3)),3), m_rec
   ->qual[m_rec->l_cnt].l_exist_ind = 0,
   m_rec->qual[m_rec->l_cnt].l_valid_prsnl = 0
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 SELECT INTO "nl:"
  FROM prsnl pa
  WHERE expand(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_prsnl_id)
  DETAIL
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_prsnl_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_valid_prsnl = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM prsnl_alias pa
  WHERE expand(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_prsnl_id)
   AND pa.prsnl_alias_type_cd=mf_cs320_other_cd
   AND pa.alias_pool_cd=mf_cs263_lynx_cd
  DETAIL
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_prsnl_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_exist_ind = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 CALL echorecord(m_rec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((m_rec->qual[ml_idx1].l_valid_prsnl=1)
    AND (m_rec->qual[ml_idx1].l_exist_ind=0))
    INSERT  FROM prsnl_alias pa
     SET pa.active_ind = 1, pa.active_status_cd = 188, pa.active_status_dt_tm = cnvtdatetime(sysdate),
      pa.active_status_prsnl_id = 21310040.0, pa.alias = trim(m_rec->qual[ml_idx1].s_alias,3), pa
      .alias_pool_cd = mf_cs263_lynx_cd,
      pa.beg_effective_dt_tm = cnvtdatetime(sysdate), pa.check_digit = 0, pa.check_digit_method_cd =
      0.0,
      pa.contributor_system_cd = 0.0, pa.data_status_cd = 25, pa.data_status_dt_tm = cnvtdatetime(
       sysdate),
      pa.data_status_prsnl_id = 21310040.0, pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pa
      .person_id = m_rec->qual[ml_idx1].f_prsnl_id,
      pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.prsnl_alias_sub_type_cd = 0.0, pa
      .prsnl_alias_type_cd = mf_cs320_other_cd,
      pa.updt_applctx = 1234, pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdatetime(sysdate),
      pa.updt_id = 21310040.0, pa.updt_task = 1234
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
 ENDFOR
#exit_script
END GO
