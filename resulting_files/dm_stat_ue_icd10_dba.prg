CREATE PROGRAM dm_stat_ue_icd10:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE dsvm_error(msg=vc) = null
 DECLARE stat_seq = i4 WITH protect, noconstant(0)
 DECLARE ms_snapshot_type = vc WITH protect, constant("UE_ICD10_METRICS")
 DECLARE delimiter = c3 WITH constant("{]|")
 DECLARE problem_cd = f8
 DECLARE diagnosis_cd = f8
 DECLARE order_icd9_cd = f8
 DECLARE accn_icd9_cd = f8
 DECLARE charge_icd9_cd = f8
 DECLARE future_cd = f8
 SET diagnosis_cd = uar_get_code_by("MEANING",25321,"DIAGNOSIS")
 SET problem_cd = uar_get_code_by("MEANING",25321,"PROBLEM")
 SET accn_icd9_cd = uar_get_code_by("MEANING",23549,"ACCNICD9")
 SET charge_icd9_cd = uar_get_code_by("MEANING",23549,"CHARGEICD9")
 SET future_cd = uar_get_code_by("MEANING",6004,"FUTURE")
 SET order_icd9_cd = uar_get_code_by("MEANING",23549,"ORDERICD9")
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SET ds_cnt = 1
 SET qualcnt = 0
 SET stat_seq = 0
 SELECT INTO "nl:"
  nc.parent_entity_id, cnt = count(ncl.nomenclature_id)
  FROM nomen_cat_list ncl,
   nomenclature n,
   nomen_category nc
  PLAN (ncl
   WHERE ncl.nomenclature_id != 0
    AND ncl.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (n
   WHERE n.nomenclature_id=ncl.nomenclature_id)
   JOIN (nc
   WHERE nc.nomen_category_id=ncl.parent_category_id
    AND nc.category_type_cd IN (problem_cd, diagnosis_cd)
    AND nc.parent_entity_name="PRSNL")
  GROUP BY nc.parent_entity_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "NBR_DIAGNOSIS_FAVORITES", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(nc.parent_entity_id), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  FOOT REPORT
   IF (stat_seq=0)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "NBR_DIAGNOSIS_FAVORITES", dsr->qual[qualcnt].qual[
    ds_cnt].stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ICD10_METRICS - NBR_DIAGNOSIS_FAVORITES")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.order_provider_id, cnt = count(ner.parent_entity_id)
  FROM orders o,
   order_action oa,
   nomen_entity_reltn ner
  PLAN (o
   WHERE o.active_ind=1
    AND o.order_status_cd=future_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_provider_id != 0
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (ner
   WHERE ner.parent_entity_id=o.order_id
    AND ner.parent_entity_name="ORDERS"
    AND ner.reltn_type_cd IN (order_icd9_cd, accn_icd9_cd, charge_icd9_cd))
  GROUP BY oa.order_provider_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FUTURE_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(oa.order_provider_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  FOOT REPORT
   IF (stat_seq=0)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FUTURE_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ICD10_METRICS - FUTURE_ORDERS")
 SET stat_seq = 0
 SELECT INTO "nl:"
  d.diag_prsnl_id, cnt = count(d.diagnosis_id)
  FROM diagnosis d,
   nomenclature n,
   encntr_loc_hist elh
  PLAN (d
   WHERE d.active_ind=1
    AND d.diag_prsnl_id != 0
    AND d.updt_dt_tm > cnvtdatetime(ds_begin_snapshot)
    AND d.beg_effective_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
    ds_end_snapshot))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
   JOIN (elh
   WHERE elh.encntr_id=d.encntr_id
    AND elh.beg_effective_dt_tm <= d.beg_effective_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= d.beg_effective_dt_tm)
    AND elh.active_ind=1)
  GROUP BY d.diag_prsnl_id, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
   elh.encntr_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "NBR_DIAGNOSIS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(d.diag_prsnl_id,delimiter,uar_get_code_display(elh.loc_facility_cd),
    delimiter,uar_get_code_meaning(elh.loc_facility_cd),
    delimiter,elh.loc_facility_cd,delimiter,uar_get_code_display(elh.loc_nurse_unit_cd),delimiter,
    uar_get_code_meaning(elh.loc_nurse_unit_cd),delimiter,elh.loc_nurse_unit_cd,delimiter,
    uar_get_code_display(elh.encntr_type_cd),
    delimiter,uar_get_code_meaning(elh.encntr_type_cd),delimiter,elh.encntr_type_cd), dsr->qual[
   qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ICD10_METRICS - NBR_DIAGNOSIS")
 SELECT INTO "nl:"
  d.diag_prsnl_id, cnt = count(d.diagnosis_id)
  FROM diagnosis d,
   nomenclature n,
   encounter e
  PLAN (d
   WHERE d.active_ind=1
    AND d.diag_prsnl_id != 0
    AND d.updt_dt_tm > cnvtdatetime(ds_begin_snapshot)
    AND d.beg_effective_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
    ds_end_snapshot))
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
   JOIN (e
   WHERE e.encntr_id=d.encntr_id
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=d.encntr_id
     AND elh.beg_effective_dt_tm <= d.beg_effective_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= d.beg_effective_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
  GROUP BY d.diag_prsnl_id, e.loc_facility_cd, e.loc_nurse_unit_cd,
   e.encntr_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "NBR_DIAGNOSIS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(d.diag_prsnl_id,delimiter,uar_get_code_display(e.loc_facility_cd),delimiter,
    uar_get_code_meaning(e.loc_facility_cd),
    delimiter,e.loc_facility_cd,delimiter,uar_get_code_display(e.loc_nurse_unit_cd),delimiter,
    uar_get_code_meaning(e.loc_nurse_unit_cd),delimiter,e.loc_nurse_unit_cd,delimiter,
    uar_get_code_display(e.encntr_type_cd),
    delimiter,uar_get_code_meaning(e.encntr_type_cd),delimiter,e.encntr_type_cd), dsr->qual[qualcnt].
   qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  FOOT REPORT
   IF (stat_seq=0)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = "NBR_DIAGNOSIS", dsr->qual[qualcnt].qual[ds_cnt].
    stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
   ENDIF
  WITH nocounter, nullreport
 ;end select
 CALL dsvm_error("UE_ICD10_METRICS - NBR_DIAGNOSIS - NO_ENCOUNTER")
 SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
END GO
