CREATE PROGRAM bhs_ext_surg_prov_lab_ord:dba
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_dob = vc
     2 l_surg_count = i4
     2 s_surg_case_nbr = vc
     2 s_reg_dt = vc
     2 s_disch_dt = vc
     2 s_reason_for_visit = vc
     2 l_ocnt = i4
     2 oqual[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_as_mnemonic = vc
       3 s_order_status = vc
       3 s_order_dt = vc
       3 s_provider = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   encounter e,
   encntr_alias ea,
   person_alias pa,
   prsnl pr,
   person p
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime((curdate - 1),
    235959)
    AND o.active_ind=1
    AND o.catalog_type_cd=2513.00)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_provider_id IN (23913089.00, 750267.00, 26369377.00)
    AND oa.action_sequence=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
  ORDER BY e.encntr_id, o.order_id
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_fin = trim(ea.alias,3),
   m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa.alias,3), m_rec->qual[m_rec->l_cnt].s_dob = trim(format
    (cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec
   ->l_cnt].s_reg_dt = trim(format(e.reg_dt_tm,"MM/DD/YYYY HH:mm;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY HH:mm;;q"),3), m_rec
   ->qual[m_rec->l_cnt].s_reason_for_visit = trim(e.reason_for_visit,3)
  HEAD o.order_id
   m_rec->qual[m_rec->l_cnt].l_ocnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].oqual,m_rec->
    qual[m_rec->l_cnt].l_ocnt), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_order_mnemonic = trim(o
    .order_mnemonic,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   s_order_as_mnemonic = trim(o.ordered_as_mnemonic,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[
   m_rec->l_cnt].l_ocnt].s_order_status = trim(uar_get_code_display(o.order_status_cd),3),
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_provider = trim(pr
    .name_full_formatted,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   s_order_dt = trim(format(o.orig_order_dt_tm,"MM/DD/YYYY HH:mm;;q"),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc
  PLAN (sc
   WHERE expand(ml_idx1,1,m_rec->l_cnt,sc.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND sc.cancel_dt_tm = null)
  ORDER BY sc.encntr_id, sc.surg_case_id
  HEAD sc.encntr_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,sc.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
  HEAD sc.surg_case_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_surg_count += 1
    IF ((m_rec->qual[ml_idx2].l_surg_count=1))
     m_rec->qual[ml_idx2].s_surg_case_nbr = trim(sc.surg_case_nbr_formatted,3)
    ELSE
     m_rec->qual[ml_idx2].s_surg_case_nbr = concat(m_rec->qual[ml_idx2].s_surg_case_nbr,"; ",trim(sc
       .surg_case_nbr_formatted,3))
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = "lab_orders_by_provider_20231218.csv"
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"',"Provider",'","',"Patient",'","',
  "Patient DOB",'","',"CMRN",'","',"FIN",
  '","',"RegDT",'","',"DischDT",'","',
  "Reason for Visit",'","',"Surgical Cases Count",'","',"Surgical Cases",
  '","',"OrderID",'","',"Order Mnemonic",'","',
  "Ordered As Mnemonic",'","',"Order Status",'","',"OrderDT",
  '"',char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
    SET frec->file_buf = build('"',m_rec->qual[ml_idx1].oqual[ml_idx2].s_provider,'","',m_rec->qual[
     ml_idx1].s_pat_name,'","',
     m_rec->qual[ml_idx1].s_dob,'","',m_rec->qual[ml_idx1].s_cmrn,'","',m_rec->qual[ml_idx1].s_fin,
     '","',m_rec->qual[ml_idx1].s_reg_dt,'","',m_rec->qual[ml_idx1].s_disch_dt,'","',
     m_rec->qual[ml_idx1].s_reason_for_visit,'","',trim(cnvtstring(m_rec->qual[ml_idx1].l_surg_count,
       20,0),3),'","',m_rec->qual[ml_idx1].s_surg_case_nbr,
     '","',trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].f_order_id,20,0),3),'","',m_rec->qual[
     ml_idx1].oqual[ml_idx2].s_order_mnemonic,'","',
     m_rec->qual[ml_idx1].oqual[ml_idx2].s_order_as_mnemonic,'","',m_rec->qual[ml_idx1].oqual[ml_idx2
     ].s_order_status,'","',m_rec->qual[ml_idx1].oqual[ml_idx2].s_order_dt,
     '"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
