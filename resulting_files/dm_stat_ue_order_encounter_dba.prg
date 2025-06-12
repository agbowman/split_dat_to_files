CREATE PROGRAM dm_stat_ue_order_encounter:dba
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
 DECLARE ms_snapshot_type = vc WITH protect, constant("UE_PARENT_ORDERS_ENCOUNTER.4")
 DECLARE ml_idx = i4
 DECLARE ml_pos = i4
 DECLARE mn_cvg_size = i4
 DECLARE cvg_parent_val = f8 WITH protect, noconstant(0)
 SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET modify_cd = uar_get_code_by("MEANING",6003,"MODIFY")
 SET cancel_cd = uar_get_code_by("MEANING",6003,"CANCEL")
 SET discont_cd = uar_get_code_by("MEANING",6003,"DISCONTINUE")
 SET systemauto_cd = uar_get_code_by("MEANING",4038,"SYSTEMAUTO")
 SET systemdisch_cd = uar_get_code_by("MEANING",4038,"SYSTEMDISCH")
 SET systemtrans_cd = uar_get_code_by("MEANING",4038,"SYSTEMTRANS")
 SET updbycleanup_cd = uar_get_code_by("MEANING",4038,"UPDBYCLEANUP")
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 FREE RECORD code_value_groups
 RECORD code_value_groups(
   1 qual[*]
     2 child_code_value = f8
     2 parent_code_value = f8
 )
 SET ds_cnt = 1
 SELECT INTO "nl:"
  cvg.child_code_value, cvg.parent_code_value
  FROM code_value_group cvg
  WHERE (cvg.parent_code_value=
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=69
    AND c.code_value=cvg.parent_code_value))
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(code_value_groups->qual,(ds_cnt+ 9))
   ENDIF
   code_value_groups->qual[ds_cnt].child_code_value = cvg.child_code_value, code_value_groups->qual[
   ds_cnt].parent_code_value = cvg.parent_code_value, ds_cnt = (ds_cnt+ 1)
  FOOT REPORT
   mn_cvg_size = (ds_cnt - 1), stat = alterlist(code_value_groups->qual,mn_cvg_size)
  WITH nocounter
 ;end select
 SET ds_cnt = 1
 SET qualcnt = 0
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, orv.review_type_flag, o.order_status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh,
   order_review orv
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
   JOIN (orv
   WHERE orv.order_id=outerjoin(o.order_id)
    AND orv.action_sequence=outerjoin(1)
    AND orv.review_type_flag=outerjoin(2))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd, orv.review_type_flag, o.order_status_cd
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
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",orv.review_type_flag,"||",
    uar_get_code_display(o.order_status_cd),"||",uar_get_code_meaning(o.order_status_cd),"||",o
    .order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER_ENCOUNTER - UE_NBR_NEW_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
  o.activity_type_cd, orv.review_type_flag, o.order_status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   order_review orv,
   encounter e
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (orv
   WHERE orv.order_id=outerjoin(o.order_id)
    AND orv.action_sequence=outerjoin(1)
    AND orv.review_type_flag=outerjoin(2)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
   o.activity_type_cd, orv.review_type_flag, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",orv.review_type_flag,"||",
    uar_get_code_display(o.order_status_cd),"||",uar_get_code_meaning(o.order_status_cd),"||",o
    .order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER_ENCOUNTER - UE_NBR_NEW_ORDERS ;No encounter")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=modify_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_MODIFIED_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_MODIFIED_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encounter e
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=modify_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND ((o.orderable_type_flag+ 0) != 6)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_MODIFIED_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_MODIFIED_ORDERS ;No encounter")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.ad_hoc_order_flag != 0
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ADHOC_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_ADHOC_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encounter e
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.ad_hoc_order_flag != 0
    AND ((o.orderable_type_flag+ 0) != 6)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ADHOC_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_ADHOC_ORDERS")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.order_provider_id, oa.communication_type_cd,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  orv.review_type_flag, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
  elh.encntr_type_cd, o.activity_type_cd, o.order_status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   order_review orv,
   encntr_loc_hist elh
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.pathway_catalog_id > 0
   AND oa.order_id=o.order_id
   AND oa.template_order_flag IN (0, 1, 5)
   AND ((o.orderable_type_flag+ 0) != 6)
   AND ((o.encntr_id+ 0) > 0)
   AND orv.order_id=outerjoin(o.order_id)
   AND orv.action_sequence=outerjoin(1)
   AND orv.review_type_flag=outerjoin(2)
   AND elh.encntr_id=o.encntr_id
   AND elh.beg_effective_dt_tm <= oa.action_dt_tm
   AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
   AND elh.active_ind=1
  GROUP BY oa.action_personnel_id, oa.order_provider_id, oa.communication_type_cd,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   orv.review_type_flag, elh.loc_facility_cd, elh.loc_nurse_unit_cd,
   elh.encntr_type_cd, o.activity_type_cd, o.order_status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_POWERPLAN_ORDERS", dsr->qual[qualcnt].
   qual[ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",
    uar_get_code_meaning(o.catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",orv.review_type_flag,"||",
    uar_get_code_display(o.order_status_cd),"||",uar_get_code_meaning(o.order_status_cd),"||",o
    .order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_POWERPLAN_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.order_provider_id, oa.communication_type_cd,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  orv.review_type_flag, e.loc_facility_cd, e.loc_nurse_unit_cd,
  e.encntr_type_cd, o.activity_type_cd, o.order_status_cd,
  cnt = count(1)
  FROM order_action oa,
   orders o,
   order_review orv,
   encounter e
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.pathway_catalog_id > 0
   AND oa.order_id=o.order_id
   AND oa.template_order_flag IN (0, 1, 5)
   AND ((o.orderable_type_flag+ 0) != 6)
   AND ((o.encntr_id+ 0) > 0)
   AND orv.order_id=outerjoin(o.order_id)
   AND orv.action_sequence=outerjoin(1)
   AND orv.review_type_flag=outerjoin(2)
   AND e.encntr_id=o.encntr_id
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM encntr_loc_hist elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1
    AND ((elh.encntr_id+ 0) > 0))))
  GROUP BY oa.action_personnel_id, oa.order_provider_id, oa.communication_type_cd,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   orv.review_type_flag, e.loc_facility_cd, e.loc_nurse_unit_cd,
   e.encntr_type_cd, o.activity_type_cd, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_POWERPLAN_ORDERS", dsr->qual[qualcnt].
   qual[ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",
    uar_get_code_meaning(o.catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",orv.review_type_flag,"||",
    uar_get_code_display(o.order_status_cd),"||",uar_get_code_meaning(o.order_status_cd),"||",o
    .order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_POWERPLAN_ORDERS")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.cs_order_id > 0
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_CARESET_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_CARESET_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encounter e
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND o.cs_order_id > 0
    AND ((o.orderable_type_flag+ 0) != 6)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_CARESET_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_NEW_CARESET_ORDERS")
 SET stat_seq = 0
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encntr_loc_hist elh
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd IN (cancel_cd, discont_cd))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND  NOT (o.discontinue_type_cd IN (systemauto_cd, systemdisch_cd, systemtrans_cd,
   updbycleanup_cd))
    AND ((o.orderable_type_flag+ 0) != 6)
    AND ((o.encntr_id+ 0) > 0))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm <= oa.action_dt_tm
    AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
    AND elh.active_ind=1)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   elh.loc_facility_cd, elh.loc_nurse_unit_cd, elh.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   ml_idx = 0, ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_cvg_size,elh.encntr_type_cd,code_value_groups
    ->qual[ml_pos].child_code_value)
   IF (ml_idx > 0)
    cvg_parent_val = code_value_groups->qual[ml_idx].parent_code_value
   ELSE
    cvg_parent_val = 0
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_CANCELLED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(elh.loc_facility_cd),"||",
    uar_get_code_meaning(elh.loc_facility_cd),
    "||",elh.loc_facility_cd,"||",uar_get_code_display(elh.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(elh.loc_nurse_unit_cd),"||",elh.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(elh.encntr_type_cd),"||",uar_get_code_meaning(elh.encntr_type_cd),"||",elh
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_ORDERS_CANCELLED")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
  e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
  o.activity_type_cd, o.order_status_cd, cnt = count(1)
  FROM order_action oa,
   orders o,
   encounter e
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd IN (cancel_cd, discont_cd))
   JOIN (o
   WHERE oa.order_id=o.order_id
    AND  NOT (o.discontinue_type_cd IN (systemauto_cd, systemdisch_cd, systemtrans_cd,
   updbycleanup_cd))
    AND ((o.orderable_type_flag+ 0) != 6)
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND ((elh.end_effective_dt_tm+ 0) >= oa.action_dt_tm)
     AND elh.active_ind=1
     AND ((elh.encntr_id+ 0) > 0)))))
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   oa.action_type_cd, o.catalog_type_cd, o.orig_ord_as_flag,
   e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_type_cd,
   o.activity_type_cd, o.order_status_cd
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
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_CANCELLED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_clob_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",uar_get_code_display(oa.action_type_cd),
    "||",
    uar_get_code_meaning(oa.action_type_cd),"||",uar_get_code_display(e.loc_facility_cd),"||",
    uar_get_code_meaning(e.loc_facility_cd),
    "||",e.loc_facility_cd,"||",uar_get_code_display(e.loc_nurse_unit_cd),"||",
    uar_get_code_meaning(e.loc_nurse_unit_cd),"||",e.loc_nurse_unit_cd,"||",uar_get_code_display(
     cvg_parent_val),
    "||",uar_get_code_meaning(cvg_parent_val),"||",cvg_parent_val,"||",
    uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",e
    .encntr_type_cd,
    "||",oa.order_provider_id,"||",oa.action_personnel_id,"||",
    o.orig_ord_as_flag,"||",uar_get_code_display(o.activity_type_cd),"||",uar_get_code_meaning(o
     .activity_type_cd),
    "||",o.activity_type_cd,"||",uar_get_code_display(o.order_status_cd),"||",
    uar_get_code_meaning(o.order_status_cd),"||",o.order_status_cd), dsr->qual[qualcnt].qual[ds_cnt].
   stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS_ENCOUNTER - UE_NBR_ORDERS_CANCELLED")
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
