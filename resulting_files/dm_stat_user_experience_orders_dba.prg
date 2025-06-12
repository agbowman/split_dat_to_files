CREATE PROGRAM dm_stat_user_experience_orders:dba
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
 DECLARE mn_powerplan_action_val = f8
 SET stat = uar_get_meaning_by_codeset(16809,"ORDER",1,mn_powerplan_action_val)
 SET pharm_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET genlab_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
 SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET cancel_cd = uar_get_code_by("MEANING",6003,"CANCEL")
 SET discont_cd = uar_get_code_by("MEANING",6003,"DISCONTINUE")
 SET modify_cd = uar_get_code_by("MEANING",6003,"MODIFY")
 SET systemauto_cd = uar_get_code_by("MEANING",4038,"SYSTEMAUTO")
 SET systemdisch_cd = uar_get_code_by("MEANING",4038,"SYSTEMDISCH")
 SET systemtrans_cd = uar_get_code_by("MEANING",4038,"SYSTEMTRANS")
 SET updbycleanup_cd = uar_get_code_by("MEANING",4038,"UPDBYCLEANUP")
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SET qualcnt = 0
 SET ds_cnt = 1
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  cnt = count(1), o.catalog_type_cd
  FROM order_action oa,
   orders o
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd
    AND oa.template_order_flag IN (0, 1, 5))
   JOIN (o
   WHERE oa.order_id=o.order_id)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   o.catalog_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PARENT_ORDERS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_str_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",oa.order_provider_id,"||",
    oa.action_personnel_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS - UE_NBR_NEW_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  cnt = count(1)
  FROM order_action oa,
   orders o
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.ad_hoc_order_flag != 0
   AND oa.order_id=o.order_id
   AND oa.template_order_flag IN (0, 1, 5)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PARENT_ORDERS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ADHOC_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(uar_get_code_display(oa.communication_type_cd),"||",
    uar_get_code_meaning(oa.communication_type_cd),"||",oa.order_provider_id,
    "||",oa.action_personnel_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS - UE_NBR_NEW_ADHOC_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  cnt = count(1)
  FROM order_action oa,
   orders o
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.pathway_catalog_id > 0
   AND oa.order_id=o.order_id
   AND oa.template_order_flag IN (0, 1, 5)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PARENT_ORDERS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_POWERPLAN_ORDERS", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(uar_get_code_display(oa.communication_type_cd),"||",
    uar_get_code_meaning(oa.communication_type_cd),"||",oa.order_provider_id,
    "||",oa.action_personnel_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS - UE_NBR_NEW_POWERPLAN_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  cnt = count(1)
  FROM order_action oa,
   orders o
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.cs_order_id > 0
   AND oa.order_id=o.order_id
   AND oa.template_order_flag IN (0, 1, 5)
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PARENT_ORDERS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_CARESET_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(uar_get_code_display(oa.communication_type_cd),"||",
    uar_get_code_meaning(oa.communication_type_cd),"||",oa.order_provider_id,
    "||",oa.action_personnel_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS - UE_NBR_NEW_CARESET_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
  cnt = count(1), o.catalog_type_cd
  FROM order_action oa,
   orders o
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd IN (cancel_cd, discont_cd)
   AND oa.order_id=o.order_id
   AND  NOT (o.discontinue_type_cd IN (systemauto_cd, systemdisch_cd, systemtrans_cd, updbycleanup_cd
  ))
  GROUP BY oa.action_personnel_id, oa.communication_type_cd, oa.order_provider_id,
   o.catalog_type_cd
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_PARENT_ORDERS.2"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_CANCELLED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(uar_get_code_display(o.catalog_type_cd),"||",uar_get_code_meaning(o
     .catalog_type_cd),"||",uar_get_code_display(oa.communication_type_cd),
    "||",uar_get_code_meaning(oa.communication_type_cd),"||",oa.order_provider_id,"||",
    oa.action_personnel_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_PARENT_ORDERS - UE_NBR_ORDERS_CANCELLED")
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 SET ds_cnt = 1
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   prsnl pnl
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND oa.action_type_cd=order_cd)
   JOIN (pnl
   WHERE oa.action_personnel_id=pnl.person_id)
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ORDERS", dsr->qual[qualcnt].qual[ds_cnt].
   stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl.name_first)),
    "|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.ad_hoc_order_flag != 0
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_ADHOC_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_ADHOC_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.pathway_catalog_id > 0
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_POWERPLAN_ORDERS", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_POWERPLAN_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.cs_order_id > 0
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_CARESET_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_CARESET_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd IN (cancel_cd, discont_cd)
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_CANCELLED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_ORDERS_CANCELLED")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=modify_cd
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_ORDERS_MODIFIED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_ORDERS_MODIFIED")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.catalog_type_cd=pharm_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_PHARM_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_PHARM_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd IN (cancel_cd, discont_cd)
   AND o.catalog_type_cd=pharm_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_PHARM_ORDERS_CANCELLED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_PHARM_ORDERS_CANCELLED")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=modify_cd
   AND o.catalog_type_cd=pharm_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_PHARM_ORDERS_MODIFIED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_PHARM_ORDERS_MODIFIED")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=order_cd
   AND o.catalog_type_cd=genlab_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_NEW_LAB_ORDERS", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_NEW_LAB_ORDERS")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd IN (cancel_cd, discont_cd)
   AND o.catalog_type_cd=genlab_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_LAB_ORDERS_CANCELLED", dsr->qual[qualcnt].
   qual[ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_LAB_ORDERS_CANCELLED")
 SELECT INTO "nl:"
  oa.action_personnel_id, cnt = count(*), pnl.name_last,
  pnl.name_first, pnl.username, pnl.physician_ind,
  pnl.position_cd, pnl.person_id
  FROM order_action oa,
   orders o,
   prsnl pnl
  WHERE oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_type_cd=modify_cd
   AND o.catalog_type_cd=genlab_cd
   AND oa.order_id=o.order_id
   AND oa.action_personnel_id=pnl.person_id
  GROUP BY oa.action_personnel_id, pnl.name_last, pnl.name_first,
   pnl.username, pnl.physician_ind, pnl.position_cd,
   pnl.person_id
  HEAD REPORT
   IF (ds_cnt=1)
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
     = cnvtdatetime(ds_begin_snapshot),
    dsr->qual[qualcnt].snapshot_type = "UE_ORDERS"
   ENDIF
   stat_seq = 0
  DETAIL
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UE_NBR_LAB_ORDERS_MODIFIED", dsr->qual[qualcnt].qual[
   ds_cnt].stat_str_val = build(trim(substring(1,80,pnl.name_last)),"|",trim(substring(1,80,pnl
      .name_first)),"|",trim(pnl.username),
    "|",pnl.physician_ind,"|",uar_get_code_display(pnl.position_cd),"|",
    cnvtstring(pnl.person_id,11,2)), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
   dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
   ds_cnt = (ds_cnt+ 1),
   stat_seq = (stat_seq+ 1)
  WITH nocounter
 ;end select
 CALL dsvm_error("UE_ORDERS - UE_NBR_LAB_ORDERS_MODIFIED")
 IF (qualcnt > 0)
  SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
END GO
