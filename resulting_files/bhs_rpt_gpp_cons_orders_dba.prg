CREATE PROGRAM bhs_rpt_gpp_cons_orders:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Number of Days to Lookback:" = ""
  WITH outdev, l_lookup_days
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "COMPLETED"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_cs6003_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_cs71_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OBSERVATION"))
 DECLARE mf_cs71_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_cs71_expiredip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"
   ))
 DECLARE mf_cs71_disches_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES"))
 DECLARE mf_cs71_dischobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_cs71_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_cs71_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_cs71_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_cs71_expiredes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES"
   ))
 DECLARE mf_cs71_expiredobv_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDOBV"))
 DECLARE mf_cs71_expireddaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EXPIREDDAYSTAY"))
 DECLARE mf_cs71_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"
   ))
 DECLARE mf_cs71_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"
   ))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 FREE RECORD ord_cat
 RECORD ord_cat(
   1 l_cnt = i4
   1 list[*]
     2 f_cat_cd = f8
     2 s_cat_prim_mnem = vc
 ) WITH protect
 FREE RECORD ord
 RECORD ord(
   1 l_cnt = i4
   1 list[*]
     2 f_order_id = f8
     2 s_ord_name = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_ord_date = vc
     2 s_pat_name = vc
     2 s_prov_name = vc
     2 s_order_detail = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_name = concat("bhs_consult_orders_",trim(format(sysdate,"MMDDYYYY;;q")),".csv")
 SET frec->file_buf = "w"
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE oc.primary_mnemonic IN ("Consult Geriatric BMC", "Psych Consult (Adult)",
  "Consult Palliative Care")
  HEAD REPORT
   ord_cat->l_cnt = 0
  DETAIL
   ord_cat->l_cnt += 1, stat = alterlist(ord_cat->list,ord_cat->l_cnt), ord_cat->list[ord_cat->l_cnt]
   .f_cat_cd = oc.catalog_cd,
   ord_cat->list[ord_cat->l_cnt].s_cat_prim_mnem = trim(oc.primary_mnemonic,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   order_action oa,
   prsnl p,
   person pp,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (o
   WHERE expand(ml_idx1,1,ord_cat->l_cnt,o.catalog_cd,ord_cat->list[ml_idx1].f_cat_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
    235959)
    AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_ordered_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_cs6003_order_cd)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.encntr_type_cd IN (mf_cs71_observation_cd, mf_cs71_dischip_cd, mf_cs71_expiredip_cd,
   mf_cs71_disches_cd, mf_cs71_dischobv_cd,
   mf_cs71_preadmitdaystay_cd, mf_cs71_dischdaystay_cd, mf_cs71_daystay_cd, mf_cs71_expiredes_cd,
   mf_cs71_expiredobv_cd,
   mf_cs71_expireddaystay_cd, mf_cs71_emergency_cd, mf_cs71_inpatient_cd))
   JOIN (pp
   WHERE pp.person_id=e.person_id)
   JOIN (ea1
   WHERE (ea1.encntr_id= Outerjoin(e.encntr_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea1.active_ind= Outerjoin(1))
    AND (ea1.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  HEAD REPORT
   ord->l_cnt = 0
  DETAIL
   ord->l_cnt += 1, stat = alterlist(ord->list,ord->l_cnt), ord->list[ord->l_cnt].s_ord_date = format
   (o.orig_order_dt_tm,"MM/DD/YYYY HH:mm:ss;;q"),
   ord->list[ord->l_cnt].s_ord_name = trim(o.ordered_as_mnemonic,3), ord->list[ord->l_cnt].s_pat_name
    = trim(pp.name_full_formatted,3), ord->list[ord->l_cnt].s_prov_name = trim(p.name_full_formatted,
    3),
   ord->list[ord->l_cnt].f_order_id = o.order_id, ord->list[ord->l_cnt].s_fin = trim(ea2.alias,3),
   ord->list[ord->l_cnt].s_mrn = trim(ea1.alias,3),
   ord->list[ord->l_cnt].s_order_detail = trim(o.order_detail_display_line,3)
  WITH nocounter
 ;end select
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"Patient Name",','"FIN/Account Number",','"MRN",','"Consult Order",',
  '"Order Date/Time",',
  '"Ordering Provider",','"Order Detail"',char(10))
 SET stat = cclio("WRITE",frec)
 IF ((ord->l_cnt > 0))
  FOR (ml_idx1 = 1 TO ord->l_cnt)
   SET frec->file_buf = concat('"',ord->list[ml_idx1].s_pat_name,'","',ord->list[ml_idx1].s_fin,'","',
    ord->list[ml_idx1].s_mrn,'","',ord->list[ml_idx1].s_ord_name,'","',ord->list[ml_idx1].s_ord_date,
    '","',ord->list[ml_idx1].s_prov_name,'","',ord->list[ml_idx1].s_order_detail,'"',
    char(10))
   SET stat = cclio("WRITE",frec)
  ENDFOR
 ENDIF
 SET stat = cclio("CLOSE",frec)
 EXECUTE bhs_ma_email_file
 DECLARE ms_rec = vc WITH protect, noconstant("")
 SET ms_rec = concat(
  "Steven.Downs@bhs.org, Sherrie.Vilbon@bhs.org, Lydia.Dollar@bhs.org, angelce.lazovski@bhs.org, ",
  " Jaime.Caron@baystatehealth.org")
 CALL emailfile(frec->file_name,frec->file_name,ms_rec,"Consult Orders Report",1)
#exit_script
END GO
