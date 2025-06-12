CREATE PROGRAM bhs_mp_get_order_info:dba
 PROMPT
  "OrderID" = 0
  WITH f_order_id
 DECLARE mf_order_id = f8 WITH protect, noconstant(cnvtreal( $F_ORDER_ID))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_order_id = f8
   1 f_person_id = f8
   1 f_encntr_id = f8
 ) WITH protect
 FREE RECORD m_out
 RECORD m_out(
   1 fin = vc
   1 cmrn = vc
   1 dob = vc
   1 order_status = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o,
   person p
  PLAN (o
   WHERE o.order_id=mf_order_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
  DETAIL
   m_rec->f_encntr_id = o.encntr_id, m_rec->f_person_id = o.person_id, m_rec->f_order_id = o.order_id,
   m_out->order_status = trim(uar_get_code_display(o.order_status_cd),3), m_out->dob = trim(format(p
     .birth_dt_tm,"MM/DD/YYYY;;q"),3)
  WITH nocounter
 ;end select
 IF ((m_rec->f_encntr_id > 0))
  SELECT INTO "nl:"
   FROM encntr_alias ea
   PLAN (ea
    WHERE (ea.encntr_id=m_rec->f_encntr_id)
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   ORDER BY ea.encntr_id, ea.beg_effective_dt_tm
   HEAD ea.encntr_id
    m_out->fin = trim(ea.alias,3)
   WITH nocounter
  ;end select
 ENDIF
 IF ((m_rec->f_person_id > 0))
  SELECT INTO "nl:"
   FROM person_alias pa
   PLAN (pa
    WHERE (pa.person_id=m_rec->f_person_id)
     AND pa.active_ind=1
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
   ORDER BY pa.person_id, pa.beg_effective_dt_tm
   HEAD pa.person_id
    m_out->cmrn = trim(pa.alias,3)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET _memory_reply_string = cnvtrectojson(m_out)
 CALL echo(_memory_reply_string)
END GO
