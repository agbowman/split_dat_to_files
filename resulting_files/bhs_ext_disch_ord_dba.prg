CREATE PROGRAM bhs_ext_disch_ord:dba
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs200_discharge_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DISCHARGE"))
 DECLARE mf_cs200_dischargepatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DISCHARGEPATIENT"))
 DECLARE mf_cs200_dischargepatientedorder_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"DISCHARGEPATIENTEDORDER"))
 DECLARE mf_cs6004_cancelled_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3099")
  )
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
     2 s_reg_dt = vc
     2 s_disch_dt = vc
     2 l_ocnt = i4
     2 oqual[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_status = vc
       3 s_order_dt = vc
       3 s_provider = vc
       3 s_ord_hour = vc
       3 s_before_10 = vc
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
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime("01-JAN-2023 00:00:00") AND cnvtdatetime(
    "29-JAN-2024 23:59:59")
    AND o.active_ind=1
    AND o.catalog_cd IN (mf_cs200_discharge_cd, mf_cs200_dischargepatient_cd,
   mf_cs200_dischargepatientedorder_cd)
    AND o.order_status_cd != mf_cs6004_cancelled_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_provider_id IN (18145281.0, 26196655.0, 25548290.0, 22970878.0, 25203361.0,
   24218641.0, 25209752.0, 25984102.0, 25164008.0, 26750035.0,
   24452141.0, 24504891.0, 21877009.0, 22881151.0, 17966338.0,
   18251209.0, 23094450.0, 22319816.0, 22352568.0, 25526529.0,
   23021003.0, 25908749.0, 23126441.0, 23781548.0, 25001701.0,
   24370026.0, 25001753.0, 25914133.0, 25460217.0, 25460236.0,
   25460281.0, 25460288.0, 24744600.0, 25001780.0, 24484436.0,
   23906391.0, 25334999.0, 25914107.0, 25001717.0, 25921954.0,
   25460293.0, 25889470.0, 26369404.0, 26369377.0, 26369244.0,
   26369274.0, 25914120.0, 26369383.0, 26369403.0, 26749597.0,
   26749709.0, 26749762.0, 26749791.0, 26749835.0, 26749862.0,
   26747583.0, 26747643.0, 26747741.0, 26369369.0, 26748100.0,
   25498174.0, 25914125.0)
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
    (p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec->l_cnt].s_reg_dt = trim(format(e.reg_dt_tm,
     "MM/DD/YYYY HH:mm;;q"),3),
   m_rec->qual[m_rec->l_cnt].s_disch_dt = trim(format(e.disch_dt_tm,"MM/DD/YYYY HH:mm;;q"),3)
  HEAD o.order_id
   m_rec->qual[m_rec->l_cnt].l_ocnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].oqual,m_rec->
    qual[m_rec->l_cnt].l_ocnt), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   f_order_id = o.order_id,
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_order_mnemonic = trim(o
    .order_mnemonic,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   s_order_status = trim(uar_get_code_display(o.order_status_cd),3), m_rec->qual[m_rec->l_cnt].oqual[
   m_rec->qual[m_rec->l_cnt].l_ocnt].s_provider = trim(pr.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_order_dt = trim(format(o
     .orig_order_dt_tm,"MM/DD/YYYY HH:mm;;q"),3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->
   l_cnt].l_ocnt].s_ord_hour = trim(format(o.orig_order_dt_tm,"HH;;q"),3)
   IF (cnvtint(m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_ord_hour) < 10)
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_before_10 = "Y"
   ELSE
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_before_10 = "N"
   ENDIF
  WITH nocounter
 ;end select
 SET frec->file_name = "disch_orders_20240129.csv"
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"',"Ordering Provider",'","',"Patient",'","',
  "Patient DOB",'","',"CMRN",'","',"FIN",
  '","',"RegDT",'","',"DischDT",'","',
  "OrderID",'","',"Order Mnemonic",'","',"Order Status",
  '","',"OrderDT",'","',"OrderHour",'","',
  "OrderedBefore10am",'"',char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
    SET frec->file_buf = build('"',m_rec->qual[ml_idx1].oqual[ml_idx2].s_provider,'","',m_rec->qual[
     ml_idx1].s_pat_name,'","',
     m_rec->qual[ml_idx1].s_dob,'","',m_rec->qual[ml_idx1].s_cmrn,'","',m_rec->qual[ml_idx1].s_fin,
     '","',m_rec->qual[ml_idx1].s_reg_dt,'","',m_rec->qual[ml_idx1].s_disch_dt,'","',
     trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].f_order_id,20,0),3),'","',m_rec->qual[
     ml_idx1].oqual[ml_idx2].s_order_mnemonic,'","',m_rec->qual[ml_idx1].oqual[ml_idx2].
     s_order_status,
     '","',m_rec->qual[ml_idx1].oqual[ml_idx2].s_order_dt,'","',m_rec->qual[ml_idx1].oqual[ml_idx2].
     s_ord_hour,'","',
     m_rec->qual[ml_idx1].oqual[ml_idx2].s_before_10,'"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
