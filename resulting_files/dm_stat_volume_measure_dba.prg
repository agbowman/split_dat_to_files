CREATE PROGRAM dm_stat_volume_measure:dba
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
 DECLARE qualcnt = i4
 DECLARE bandval = i4
 DECLARE ds_cnt = i4
 DECLARE ds_begin_snapshot = f8
 DECLARE ds_end_snapshot = f8
 DECLARE ds_last_contain_hold = i4
 DECLARE ds_last_acc_hold = f8
 DECLARE ds_max_acc_hold = f8
 DECLARE ds_level_one = i4
 DECLARE ds_level_two = i4
 DECLARE ds_alter_cnt_one = i4
 DECLARE ds_alter_cnt_two = i4
 DECLARE ms_bucket_str = vc
 DECLARE ct_dk_str = vc
 DECLARE mf_prev_trigger_id = f8
 DECLARE mf_max_trigger_id = f8
 DECLARE ds_cnt = i4 WITH protect, noconstant(0)
 DECLARE ds_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ds_cnt3 = i4 WITH protect, noconstant(0)
 DECLARE ds_cnt4 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4
 DECLARE ml_pos = i4
 DECLARE mn_child_size = i4
 DECLARE mn_clinical_doc_updt_task = i4
 DECLARE mn_updt_task_lower = i4
 DECLARE mn_updt_task_upper = i4
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = dq8
 DECLARE md_end_timer = dq8
 DECLARE md_start_total_timer = dq8
 DECLARE md_end_total_timer = dq8
 DECLARE sbr_check_debug(null) = null
 DECLARE write_dm_info(z=vc) = null
 DECLARE dsvm_error(msg=vc) = null
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 DECLARE sbr_check_careset(ms_catalog_dk=vc,mn_cs_flag=i4,mn_cnt=i4) = null
 SET ds_cnt = 0
 SET ds_cnt2 = 0
 SET ds_cnt3 = 0
 SET ds_cnt4 = 0
 SET ml_idx = 0
 SET ml_pos = 0
 SET mn_child_size = 0
 SET mn_clinical_doc_updt_task = 4250111
 SET mn_updt_task_lower = 4250000
 SET mn_updt_task_upper = 4250999
 SET mf_prev_trigger_id = - (1)
 SET mf_max_trigger_id = 0
 SET qualcnt = 0
 SET ds_last_acc_hold = - (1)
 SET ds_max_acc_hold = 0
 SET ds_level_one = 0
 SET ds_level_two = 0
 SET ds_alter_cnt_one = 0
 SET ds_alter_cnt_two = 0
 SET ds_begin_snapshot = 0
 SET ds_end_snapshot = 0
 IF (validate(dm_stat_gather_dt,999)=999)
  SET ds_end_snapshot = cnvtdatetime(curdate,(hour(curtime) * 100))
  SET ds_begin_snapshot = cnvtdatetime(cnvtdate(ds_end_snapshot),((hour(ds_end_snapshot) - 1) * 100))
 ELSE
  SET ds_end_snapshot = cnvtdatetime(cnvtdate(dm_stat_gather_dt),(hour(dm_stat_gather_dt) * 100))
  SET ds_begin_snapshot = cnvtdatetime(cnvtdate(ds_end_snapshot),((hour(ds_end_snapshot) - 1) * 100))
 ENDIF
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 CALL sbr_check_debug(null)
 CALL dsvm_error("DEBUG INDICATOR")
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_VOLUME_MEASURE")
 CALL dsvm_error("ds_max_acc_hold")
 CALL echo("Getting LAST SNAPSHOT DATE TIME.")
 SELECT INTO "nl:"
  dm.info_date, dm.info_number
  FROM dm_info dm
  WHERE dm.info_domain="DM_STAT_VOLUME_MEASURE"
   AND dm.info_name IN ("LAST SNAPSHOT DATE TIME", "LAST ACCESSION_ID")
  DETAIL
   CASE (dm.info_name)
    OF "LAST SNAPSHOT DATE TIME":
     IF (ds_begin_snapshot < cnvtdatetime(dm.info_date))
      ds_begin_snapshot = cnvtdatetime(dm.info_date)
     ENDIF
    OF "LAST ACCESSION_ID":
     ds_last_acc_hold = dm.info_number
   ENDCASE
  WITH nocounter
 ;end select
 DECLARE t2 = f8
 SELECT INTO "nl:"
  dsvm_ret = max(a.accession_id)"#############.##"
  FROM accession a
  WHERE a.accession_id > ds_last_acc_hold
   AND a.updt_dt_tm < cnvtdatetime(ds_end_snapshot)
  DETAIL
   ds_max_acc_hold = dsvm_ret
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("START","RADIOLOGY VOLUMES")
 CALL echo("Getting radiology volumes.")
 SELECT INTO "nl:"
  rs_cdf = uar_get_code_meaning(ord.report_status_cd), es_cdf = uar_get_code_meaning(ord
   .exam_status_cd), dsvm_ret = count(*)
  FROM order_radiology ord,
   order_catalog oc
  PLAN (ord
   WHERE ord.order_id > 0
    AND ord.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (oc
   WHERE oc.catalog_cd=ord.catalog_cd
    AND oc.bill_only_ind=0)
  GROUP BY ord.report_status_cd, ord.exam_status_cd
  ORDER BY ord.report_status_cd
  HEAD REPORT
   qualcnt = (qualcnt+ 3), stat = alterlist(dsr->qual,qualcnt), dsr->qual[(qualcnt - 2)].
   stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot),
   dsr->qual[(qualcnt - 2)].snapshot_type = "RADIOLOGY_VOLUMES - ORDERS.3", stat = alterlist(dsr->
    qual[(qualcnt - 2)].qual,1), dsr->qual[(qualcnt - 2)].qual[1].stat_name = "Order Procedures",
   dsr->qual[(qualcnt - 2)].qual[1].stat_type = 1, dsr->qual[(qualcnt - 1)].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 1)].snapshot_type =
   "RADIOLOGY_VOLUMES - ORDERS BY RPT STATUS.3",
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "RADIOLOGY_VOLUMES -ORDERS BY EXAM STATUS.3", ds_cnt = 1,
   ds_cnt2 = 0
  DETAIL
   IF (trim(rs_cdf) != ""
    AND trim(es_cdf) != "")
    IF (ds_cnt=1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_name = trim(rs_cdf), dsr->qual[(qualcnt - 1)].qual[
     ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_number_val = dsvm_ret,
     ds_cnt = (ds_cnt+ 1)
    ELSE
     IF ((dsr->qual[(qualcnt - 1)].qual[(ds_cnt - 1)].stat_name != trim(rs_cdf)))
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_name = trim(rs_cdf), dsr->qual[(qualcnt - 1)].qual[
      ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_number_val = dsvm_ret,
      ds_cnt = (ds_cnt+ 1)
     ELSE
      dsr->qual[(qualcnt - 1)].qual[(ds_cnt - 1)].stat_number_val = (dsr->qual[(qualcnt - 1)].qual[(
      ds_cnt - 1)].stat_number_val+ dsvm_ret)
     ENDIF
    ENDIF
    ml_idx = 0, mn_child_size = size(dsr->qual[qualcnt].qual,5), ml_idx = locateval(ml_pos,(ml_idx+ 1
     ),mn_child_size,trim(es_cdf),dsr->qual[qualcnt].qual[ml_pos].stat_name)
    IF (ml_idx=0)
     ds_cnt2 = (ds_cnt2+ 1)
     IF (mod(ds_cnt2,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt2+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt2].stat_name = trim(es_cdf), dsr->qual[qualcnt].qual[ds_cnt2].
     stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt2].stat_number_val = dsvm_ret
    ELSE
     dsr->qual[qualcnt].qual[ml_idx].stat_number_val = (dsr->qual[qualcnt].qual[ml_idx].
     stat_number_val+ dsvm_ret)
    ENDIF
    dsr->qual[(qualcnt - 2)].qual[1].stat_number_val = (dsr->qual[(qualcnt - 2)].qual[1].
    stat_number_val+ dsvm_ret)
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[(qualcnt - 1)].qual,ds_cnt), stat = alterlist(dsr->qual[qualcnt].qual,
    ds_cnt2)
  WITH nocounter
 ;end select
 CALL dsvm_error("RADIOLOGY_VOLUMES")
 CALL sbr_debug_timer("END","RADIOLOGY VOLUMES")
 CALL sbr_debug_timer("START","PM TRANSACTION VOLUMES")
 CALL echo("Getting pm_transaction volumes.")
 SELECT INTO "nl:"
  pt.transaction, dsvm_ret = count(*)
  FROM pm_transaction pt
  WHERE pt.activity_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY pt.transaction
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "PM VOLUMES", ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = trim(pt.transaction), dsr->qual[qualcnt].qual[ds_cnt].
   stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = dsvm_ret
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 CALL dsvm_error("PM VOLUMES")
 CALL sbr_debug_timer("END","PM TRANSACTION VOLUMES")
 CALL sbr_debug_timer("START","SCHEDULING VOLUMES")
 CALL echo("Getting scheduling transaction volumes.")
 SELECT INTO "nl:"
  sea.action_meaning, dsvm_ret = count(*)
  FROM sch_event_action sea
  WHERE sea.version_dt_tm=cnvtdatetime("31-DEC-2100")
   AND sea.active_ind=1
   AND sea.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY sea.action_meaning
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "SCHEDULING VOLUMES", ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = trim(sea.action_meaning), dsr->qual[qualcnt].qual[
   ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = dsvm_ret
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 CALL dsvm_error("SCHEDULING VOLUMES")
 CALL sbr_debug_timer("END","SCHEDULING VOLUMES")
 CALL sbr_debug_timer("START","GENLAB ACCESSION VOLUMES")
 CALL echo("Getting pathnet genlab accession volumes.")
 SELECT INTO "nl:"
  dsvm_ret = count(*), max_acc_id = max(a.accession_id)
  FROM accession a
  WHERE a.accession_id > ds_last_acc_hold
   AND a.accession_id <= ds_max_acc_hold
   AND a.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), stat = alterlist(dsr->qual[qualcnt].
    qual,1),
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "PATHNET_VOLUMES - ACCESSIONS.2", dsr->qual[qualcnt].qual[1].stat_name =
   "Gen Lab Accessions",
   dsr->qual[qualcnt].qual[1].stat_type = 1, dsr->qual[qualcnt].qual[1].stat_number_val = dsvm_ret
   IF (max_acc_id > ds_last_acc_hold)
    ds_last_acc_hold = max_acc_id
   ENDIF
  WITH nocounter
 ;end select
 CALL dsvm_error("PATHNET_VOLUMES - ACCESSIONS")
 CALL sbr_debug_timer("END","GENLAB ACCESSION VOLUMES")
 CALL sbr_debug_timer("START","GENLAB CONTAINERS DISPATCHED VOLUMES")
 CALL echo("Getting  pathnet genlab containers dispatched volumes.")
 SELECT INTO "nl:"
  et_cdf = uar_get_code_meaning(ce.event_type_cd), dsvm_ret = count(*)
  FROM container_event ce
  WHERE ce.drawn_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY ce.event_type_cd
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "PATHNET_VOLUMES - GEN LAB CONTAINERS", ds_cnt = 1
  DETAIL
   IF (trim(et_cdf) != "")
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = trim(et_cdf), dsr->qual[qualcnt].qual[ds_cnt].
    stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = dsvm_ret,
    ds_cnt = (ds_cnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
  WITH nocounter
 ;end select
 CALL dsvm_error("PATHNET_VOLUMES - GEN LAB CONTAINERS")
 CALL sbr_debug_timer("END","GENLAB CONTAINERS DISPATCHED VOLUMES")
 CALL sbr_debug_timer("START","GENLAB COLLECTION LIST VOLUMES")
 CALL echo("Getting pathnet genlab collection list volumes.")
 SELECT INTO "nl:"
  cl.list_type_flag, dsvm_ret = count(*)
  FROM collection_list cl
  WHERE cl.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY cl.list_type_flag
  ORDER BY cl.list_type_flag
  HEAD REPORT
   list_cnt = 0, qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt),
   stat = alterlist(dsr->qual[qualcnt].qual,2), dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(
    ds_begin_snapshot), dsr->qual[qualcnt].snapshot_type = "PATHNET_VOLUMES - GEN LAB LISTS"
  HEAD cl.list_type_flag
   IF (cl.list_type_flag=1)
    dsr->qual[qualcnt].qual[1].stat_name = "COLLECTION", dsr->qual[qualcnt].qual[1].stat_type = 1,
    dsr->qual[qualcnt].qual[1].stat_number_val = (dsr->qual[qualcnt].qual[1].stat_number_val+
    dsvm_ret)
   ELSEIF (cl.list_type_flag=2)
    dsr->qual[qualcnt].qual[2].stat_name = "TRANSFER", dsr->qual[qualcnt].qual[2].stat_type = 1, dsr
    ->qual[qualcnt].qual[2].stat_number_val = (dsr->qual[qualcnt].qual[2].stat_number_val+ dsvm_ret)
   ENDIF
  WITH nocounter
 ;end select
 CALL dsvm_error("PATHNET_VOLUMES - GEN LAB LISTS")
 CALL sbr_debug_timer("END","GENLAB COLLECTION LIST VOLUMES")
 CALL sbr_debug_timer("START","PERFORMED RESULTS VOLUMES")
 CALL echo("Getting pathnet genlab/hla/bb performed results volumes.")
 DECLARE curr_cs_flg = i4 WITH noconstant(- (1))
 DECLARE curr_event = vc WITH noconstant("")
 DECLARE curr_activity = vc WITH noconstant("")
 SELECT INTO "nl:"
  et_cdf = uar_get_code_meaning(re.event_type_cd), at_cdf = uar_get_code_meaning(o.activity_type_cd),
  o.cs_flag
  FROM result_event re,
   result r,
   orders o,
   order_catalog oc
  WHERE re.event_dt_tm >= cnvtdatetime(ds_begin_snapshot)
   AND re.event_dt_tm < cnvtdatetime(ds_end_snapshot)
   AND r.result_id=re.result_id
   AND o.order_id=r.order_id
   AND oc.catalog_cd=o.catalog_cd
   AND oc.bill_only_ind=0
  ORDER BY et_cdf, at_cdf, o.cs_flag
  HEAD REPORT
   ds_cnt = 0, qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt),
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "PATHNET_VOLUMES - RESULTS"
  HEAD et_cdf
   curr_activity = "", curr_cs_flag = - (1), curr_event = et_cdf
  DETAIL
   IF (trim(et_cdf) != ""
    AND trim(at_cdf) != "")
    IF (at_cdf != curr_activity)
     curr_activity = at_cdf, curr_cs_flag = - (1)
    ENDIF
    IF (o.cs_flag != curr_cs_flag)
     ds_cnt = (ds_cnt+ 1), curr_cs_flag = o.cs_flag, stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt),
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = concat(curr_event," - ",curr_activity," - ",trim(
       cnvtstring(curr_cs_flag))), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = 1
    ELSE
     dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = (dsr->qual[qualcnt].qual[ds_cnt].
     stat_number_val+ 1)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL dsvm_error("PATHNET_VOLUMES - RESULTS")
 CALL sbr_debug_timer("END","PERFORMED RESULTS VOLUMES")
 CALL sbr_debug_timer("START","ESI INTERFACE BY CONTRIBUTOR VOLUMES")
 CALL echo("Getting ESI interface volumes by contributor.")
 SELECT INTO "nl:"
  cs.display, esi.msh_msg_type, esi.error_stat,
  dsvm_ret = count(*)
  FROM esi_log esi,
   contributor_system cs
  PLAN (cs
   WHERE cs.active_ind=1)
   JOIN (esi
   WHERE esi.contributor_system_cd=cs.contributor_system_cd
    AND esi.create_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
  GROUP BY cs.display, esi.msh_msg_type, esi.error_stat
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "ESI Interface Volumes.2", ds_cnt = 0
  DETAIL
   ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
   ENDIF
   dsr->qual[qualcnt].qual[ds_cnt].stat_name = concat(trim(cs.display),"||",trim(esi.msh_msg_type),
    "||",trim(esi.error_stat)), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].
   qual[ds_cnt].stat_number_val = dsvm_ret
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 CALL dsvm_error("ESI Interface Volumes")
 CALL sbr_debug_timer("END","ESI INTERFACE BY CONTRIBUTOR VOLUMES")
 CALL sbr_debug_timer("START","ESO INTERFACE VOLUMES")
 CALL echo("Getting ESO interface volumes")
 SELECT INTO "nl:"
  cfq.type, cfq.class, class =
  IF (isnumeric(substring(5,size(cfq.class,1),cfq.class)) > 0
   AND substring(1,4,cfq.class)="ORM_") "ORM"
  ELSE cfq.class
  ENDIF
  ,
  dsvm_ret = count(*)
  FROM cqm_fsieso_que cfq
  WHERE cfq.create_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND  EXISTS (
  (SELECT
   1
   FROM cqm_fsieso_tr_1 tr
   WHERE tr.queue_id=cfq.queue_id
    AND ((tr.process_status_flag+ 0)=90)))
  GROUP BY cfq.type, cfq.class
  HEAD REPORT
   qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[qualcnt].snapshot_type = "ESO Outbound Interface Volumes.2", ds_cnt = 0
  DETAIL
   ml_idx = 0, mn_child_size = size(dsr->qual[qualcnt].qual,5), ml_idx = locateval(ml_pos,(ml_idx+ 1),
    mn_child_size,concat(trim(class),"||",trim(cfq.type)),dsr->qual[qualcnt].qual[ml_pos].stat_name)
   IF (ml_idx=0)
    ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,10)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = concat(trim(class),"||",trim(cfq.type)), dsr->qual[
    qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = dsvm_ret
   ELSE
    dsr->qual[qualcnt].qual[ml_idx].stat_number_val = (dsr->qual[qualcnt].qual[ml_idx].
    stat_number_val+ dsvm_ret)
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 CALL dsvm_error("ESO Outbound Interface Volumes")
 CALL sbr_debug_timer("END","ESO INTERFACE VOLUMES")
 CALL sbr_debug_timer("START","COMM CLIENT VOLUMES")
 CALL echo("Getting comm client interface volumes.")
 DECLARE type_fnd = i4 WITH protect, noconstant(0)
 DECLARE type_cnt = i4 WITH protect, noconstant(0)
 DECLARE type_i = i4 WITH protect, noconstant(1)
 SET qualcnt = (qualcnt+ 2)
 SET stat = alterlist(dsr->qual,qualcnt)
 SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot)
 SET dsr->qual[qualcnt].snapshot_type = "ESO COM Srv Transactions Sent"
 SET dsr->qual[(qualcnt - 1)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot)
 SET dsr->qual[(qualcnt - 1)].snapshot_type = "ESO COM Srv Transactions Ignored"
 SET ds_cnt = 1
 SET ds_cnt2 = 0
 SELECT INTO "nl:"
  max_tr_id = max(tr.trigger_id)
  FROM cqm_oeninterface_tr_1 tr
  DETAIL
   mf_max_trigger_id = max_tr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dm.info_number
  FROM dm_info dm
  WHERE dm.info_domain="DM_STAT_VOLUME_MEASURE"
   AND dm.info_name="ESO_COM_SRV_TRIGGER_ID"
  DETAIL
   mf_prev_trigger_id = dm.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET mf_prev_trigger_id = mf_max_trigger_id
  INSERT  FROM dm_info di
   SET di.info_domain = "DM_STAT_VOLUME_MEASURE", di.info_name = "ESO_COM_SRV_TRIGGER_ID", di
    .info_number = mf_max_trigger_id
   WITH nocounter
  ;end insert
  COMMIT
 ELSE
  UPDATE  FROM dm_info di
   SET di.info_number = mf_max_trigger_id
   WHERE di.info_domain="DM_STAT_VOLUME_MEASURE"
    AND di.info_name="ESO_COM_SRV_TRIGGER_ID"
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 CALL echo(build("PREVIOUS TRIGGER ID",mf_prev_trigger_id))
 CALL echo(build("MAX TRIGGER ID",mf_max_trigger_id))
 SELECT INTO "nl:"
  que.type, tr.process_status_flag, dsvm_ret = count(*),
  max_trigger = max(tr.trigger_id)
  FROM cqm_oeninterface_tr_1 tr,
   cqm_oeninterface_que que
  PLAN (tr
   WHERE tr.trigger_id < mf_prev_trigger_id
    AND tr.trigger_id >= mf_max_trigger_id
    AND ((tr.queue_id+ 0) > 0)
    AND ((tr.process_status_flag+ 0) > 0)
    AND tr.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
   JOIN (que
   WHERE tr.queue_id=que.queue_id)
  GROUP BY que.type, tr.process_status_flag
  ORDER BY que.type
  DETAIL
   IF (tr.process_status_flag=70)
    IF (ds_cnt=1)
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt+ 9))
     ENDIF
     dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_name = trim(que.type), dsr->qual[(qualcnt - 1)].qual[
     ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_number_val = dsvm_ret,
     ds_cnt = (ds_cnt+ 1)
    ELSE
     IF ((dsr->qual[(qualcnt - 1)].qual[(ds_cnt - 1)].stat_name != trim(que.type)))
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_name = trim(que.type), dsr->qual[(qualcnt - 1)].
      qual[ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt].stat_number_val = dsvm_ret,
      ds_cnt = (ds_cnt+ 1)
     ELSE
      dsr->qual[(qualcnt - 1)].qual[(ds_cnt - 1)].stat_number_val = (dsr->qual[(qualcnt - 1)].qual[(
      ds_cnt - 1)].stat_number_val+ dsvm_ret)
     ENDIF
    ENDIF
   ELSE
    ml_idx = 0, mn_child_size = size(dsr->qual[qualcnt].qual,5), ml_idx = locateval(ml_pos,(ml_idx+ 1
     ),mn_child_size,trim(que.type),dsr->qual[qualcnt].qual[ml_pos].stat_name)
    IF (ml_idx=0)
     ds_cnt2 = (ds_cnt2+ 1)
     IF (mod(ds_cnt2,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt2+ 9))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt2].stat_name = trim(que.type), dsr->qual[qualcnt].qual[ds_cnt2].
     stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt2].stat_number_val = dsvm_ret
    ELSE
     dsr->qual[qualcnt].qual[ml_idx].stat_number_val = (dsr->qual[qualcnt].qual[ml_idx].
     stat_number_val+ dsvm_ret)
    ENDIF
   ENDIF
   IF (max_trigger > mf_prev_trigger_id)
    mf_prev_trigger_id = max_trigger
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[(qualcnt - 1)].qual,ds_cnt), stat = alterlist(dsr->qual[qualcnt].qual,
    ds_cnt2)
  WITH nocounter
 ;end select
 CALL dsvm_error("ESO COM Srv Transactions")
 CALL sbr_debug_timer("END","COMM CLIENT VOLUMES")
 CALL sbr_debug_timer("START","LOAD TIMER")
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 CALL sbr_debug_timer("END","LOAD TIMER")
 CALL sbr_debug_timer("START","FIRSTNET VOLUMES")
 RANGE OF r IS clinical_event
 SET stat = validate(r.clinsig_updt_dt_tm)
 FREE RANGE r
 IF (stat=1)
  CALL echo("Getting Clinical Documentation.")
  SELECT INTO "nl:"
   dsvm_ret = count(*)
   FROM clinical_event
   WHERE clinsig_updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
    AND updt_task=mn_clinical_doc_updt_task
   HEAD REPORT
    qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), mystat = alterlist(dsr->qual[qualcnt
     ].qual,10)
   DETAIL
    dsr->qual[qualcnt].qual[1].stat_name = "CLINICAL DOCUMENTATION", dsr->qual[qualcnt].qual[1].
    stat_type = 1, dsr->qual[qualcnt].qual[1].stat_number_val = dsvm_ret
   FOOT REPORT
    z = 0
   WITH nocounter
  ;end select
  CALL dsvm_error("CLINICAL DOCUMENTATION")
 ENDIF
 CALL echo("Getting Patient Tracking Starts.")
 SELECT INTO "nl:"
  dsvm_ret = count(*)
  FROM tracking_item
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ((person_id+ 0) > 0)
   AND start_tracking_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  HEAD REPORT
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "FIRSTNET VOLUMES.3"
  DETAIL
   dsr->qual[qualcnt].qual[2].stat_name = "PATIENT TRACKING STARTS", dsr->qual[qualcnt].qual[2].
   stat_type = 1, dsr->qual[qualcnt].qual[2].stat_number_val = dsvm_ret
  FOOT REPORT
   q = 0
  WITH nocounter
 ;end select
 CALL dsvm_error("FIRSTNET VOLUMES")
 CALL echo("Getting Patient Checkin.")
 SELECT INTO "nl:"
  x = count(*), cd_value = uar_get_code_meaning(tc.tracking_group_cd)
  FROM tracking_checkin tc
  WHERE tc.checkin_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND tc.updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  GROUP BY tc.tracking_group_cd
  DETAIL
   dsr->qual[qualcnt].qual[3].stat_name = "PATIENT CHECKINS"
   IF (cd_value="ER")
    dsr->qual[qualcnt].qual[3].stat_type = 1, dsr->qual[qualcnt].qual[3].stat_number_val = x
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dsr->qual[qualcnt].qual[3].stat_name = "PATIENT CHECKINS"
 ENDIF
 CALL dsvm_error("PATIENT CHECKINS")
 CALL echo("Getting complaint selection.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_item ti,
   tracking_complaint tc
  WHERE ti.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ti.updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
   AND tc.tracking_id=ti.tracking_id
   AND tc.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND tc.updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[4].stat_name = "COMPLAINT SELECTIONS", dsr->qual[qualcnt].qual[4].
   stat_type = 1, dsr->qual[qualcnt].qual[4].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("COMPLAINT SELECTIONS")
 CALL echo("Getting location changes.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_locator
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[5].stat_name = "LOCATION CHANGES", dsr->qual[qualcnt].qual[5].stat_type =
   1, dsr->qual[qualcnt].qual[5].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("LOCATION CHANGES")
 CALL echo("Getting update events.")
 SELECT INTO "nl:"
  event_update = sum(te.updt_cnt)
  FROM tracking_event te
  WHERE te.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND te.updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[6].stat_name = "UPDATE EVENTS", dsr->qual[qualcnt].qual[6].stat_type = 1,
   dsr->qual[qualcnt].qual[6].stat_number_val = event_update
  WITH nocounter
 ;end select
 CALL dsvm_error("UPDATE EVENTS")
 CALL echo("Getting patient departs.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_checkin
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND checkout_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[7].stat_name = "PATIENT DEPARTS", dsr->qual[qualcnt].qual[7].stat_type = 1,
   dsr->qual[qualcnt].qual[7].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("PATIENT DEPARTS")
 CALL echo("Getting provider checkins.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_item
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ((person_id+ 0)=0)
   AND start_tracking_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[8].stat_name = "PROVIDER CHECKINS", dsr->qual[qualcnt].qual[8].stat_type
    = 1, dsr->qual[qualcnt].qual[8].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("PROVIDER CHECKINS")
 CALL echo("Getting provider checkouts.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_item
  WHERE updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ((person_id+ 0) > 0)
   AND end_tracking_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
  DETAIL
   dsr->qual[qualcnt].qual[9].stat_name = "PROVIDER CHECKOUTS", dsr->qual[qualcnt].qual[9].stat_type
    = 1, dsr->qual[qualcnt].qual[9].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("PROVIDER CHECKOUTS")
 CALL echo("Getting provider assignments.")
 SELECT INTO "nl:"
  x = count(*)
  FROM tracking_item ti,
   tracking_prv_reln tpr
  WHERE ti.updt_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND ((ti.person_id+ 0) > 0)
   AND ti.updt_task BETWEEN mn_updt_task_lower AND mn_updt_task_upper
   AND tpr.tracking_id=ti.tracking_id
   AND tpr.assign_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  DETAIL
   dsr->qual[qualcnt].qual[10].stat_name = "PROVIDER ASSIGNMENTS", dsr->qual[qualcnt].qual[10].
   stat_type = 1, dsr->qual[qualcnt].qual[10].stat_number_val = x
  WITH nocounter
 ;end select
 CALL dsvm_error("PROVIDER ASSIGNMENTS")
 CALL sbr_debug_timer("END","FIRSTNET VOLUMES")
 CALL sbr_debug_timer("START","LOAD TIMER")
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 CALL sbr_debug_timer("END","LOAD TIMER")
 CALL sbr_debug_timer("START","ORDER VOLUMES")
 CALL echo("Getting order volumes.")
 SELECT INTO "nl:"
  cnt = count(*), o.catalog_type_cd, o.iv_ind,
  o.prn_ind, oa.action_type_cd, o.template_order_flag,
  oa.action_sequence, p.physician_ind, orc.bill_only_ind,
  o.orig_ord_as_flag, at_cdf = uar_get_code_meaning(oa.action_type_cd), ct_dk = uar_get_code_display(
   o.catalog_type_cd)
  FROM orders o,
   order_action oa,
   prsnl p,
   order_catalog orc
  WHERE oa.order_id=o.order_id
   AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
   AND oa.action_personnel_id=p.person_id
   AND o.catalog_cd=orc.catalog_cd
   AND o.template_order_flag IN (0, 1, 2, 5, 6)
  GROUP BY o.catalog_type_cd, oa.action_type_cd, o.iv_ind,
   o.prn_ind, o.template_order_flag, oa.action_sequence,
   p.physician_ind, orc.bill_only_ind, o.orig_ord_as_flag
  ORDER BY ct_dk
  HEAD REPORT
   ds_cnt = 1, ds_cnt2 = 1, ds_cnt3 = 1,
   ds_cnt4 = 1, ds_cnt5 = 1, ds_cnt6 = 1,
   ds_cnt7 = 1, ds_cnt8 = 1, ds_cnt9 = 1,
   qualcnt = (qualcnt+ 9), mn_add_child_ind = 0, stat = alterlist(dsr->qual,qualcnt),
   dsr->qual[(qualcnt - 8)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 8
   )].snapshot_type = "ORDER_VOLUMES - PYXIS", dsr->qual[(qualcnt - 7)].stat_snap_dt_tm =
   cnvtdatetime(ds_begin_snapshot),
   dsr->qual[(qualcnt - 7)].snapshot_type = "ORDER_VOLUMES - IV BY CATALOG TYPE", dsr->qual[(qualcnt
    - 6)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 6)].snapshot_type
    = "ORDER_VOLUMES - NON-IV BY CATALOG TYPE",
   dsr->qual[(qualcnt - 5)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 5
   )].snapshot_type = "ORDER_VOLUMES - PRN BY CATALOG TYPE", dsr->qual[(qualcnt - 4)].stat_snap_dt_tm
    = cnvtdatetime(ds_begin_snapshot),
   dsr->qual[(qualcnt - 4)].snapshot_type = "ORDER_VOLUMES - NON-PRN BY CATALOG TYPE", dsr->qual[(
   qualcnt - 3)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 3)].
   snapshot_type = "ORDER_VOLUMES -PHYSICIAN BY CATALOG TYPE",
   dsr->qual[(qualcnt - 2)].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[(qualcnt - 2
   )].snapshot_type = "ORDER_VOLUMES - NON-PHYS BY CATALOG TYPE", dsr->qual[(qualcnt - 1)].
   stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot),
   dsr->qual[(qualcnt - 1)].snapshot_type = "ORDER_VOLUMES -BILL ONLY BY CATALOG TYPE", dsr->qual[
   qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].snapshot_type =
   "ORDER_VOLUMES - NON-BILL ONLY BY CATALOG"
  DETAIL
   IF (trim(at_cdf) != ""
    AND trim(ct_dk) != "")
    IF (oa.action_sequence=1)
     IF (o.template_order_flag=2)
      IF (o.iv_ind=1)
       IF (ds_cnt2 > 1)
        IF ((dsr->qual[(qualcnt - 7)].qual[(ds_cnt2 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt2,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 7)].qual,(ds_cnt2+ 99))
         ENDIF
         dsr->qual[(qualcnt - 7)].qual[ds_cnt2].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 7)].
         qual[ds_cnt2].stat_type = 1, dsr->qual[(qualcnt - 7)].qual[ds_cnt2].stat_number_val = cnt,
         ds_cnt2 = (ds_cnt2+ 1)
        ELSE
         dsr->qual[(qualcnt - 7)].qual[(ds_cnt2 - 1)].stat_number_val = (dsr->qual[(qualcnt - 7)].
         qual[(ds_cnt2 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt2,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 7)].qual,(ds_cnt2+ 99))
        ENDIF
        dsr->qual[(qualcnt - 7)].qual[ds_cnt2].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 7)].
        qual[ds_cnt2].stat_type = 1, dsr->qual[(qualcnt - 7)].qual[ds_cnt2].stat_number_val = cnt,
        ds_cnt2 = (ds_cnt2+ 1)
       ENDIF
      ELSE
       IF (ds_cnt3 > 1)
        IF ((dsr->qual[(qualcnt - 6)].qual[(ds_cnt3 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt3,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 6)].qual,(ds_cnt3+ 99))
         ENDIF
         dsr->qual[(qualcnt - 6)].qual[ds_cnt3].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 6)].
         qual[ds_cnt3].stat_type = 1, dsr->qual[(qualcnt - 6)].qual[ds_cnt3].stat_number_val = cnt,
         ds_cnt3 = (ds_cnt3+ 1)
        ELSE
         dsr->qual[(qualcnt - 6)].qual[(ds_cnt3 - 1)].stat_number_val = (dsr->qual[(qualcnt - 6)].
         qual[(ds_cnt3 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt3,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 6)].qual,(ds_cnt3+ 99))
        ENDIF
        dsr->qual[(qualcnt - 6)].qual[ds_cnt3].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 6)].
        qual[ds_cnt3].stat_type = 1, dsr->qual[(qualcnt - 6)].qual[ds_cnt3].stat_number_val = cnt,
        ds_cnt3 = (ds_cnt3+ 1)
       ENDIF
      ENDIF
      IF (o.prn_ind=1)
       IF (ds_cnt4 > 1)
        IF ((dsr->qual[(qualcnt - 5)].qual[(ds_cnt4 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt4,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 5)].qual,(ds_cnt4+ 99))
         ENDIF
         dsr->qual[(qualcnt - 5)].qual[ds_cnt4].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 5)].
         qual[ds_cnt4].stat_type = 1, dsr->qual[(qualcnt - 5)].qual[ds_cnt4].stat_number_val = (dsr->
         qual[(qualcnt - 5)].qual[ds_cnt4].stat_number_val+ cnt),
         ds_cnt4 = (ds_cnt4+ 1)
        ELSE
         dsr->qual[(qualcnt - 5)].qual[(ds_cnt4 - 1)].stat_number_val = (dsr->qual[(qualcnt - 5)].
         qual[(ds_cnt4 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt4,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 5)].qual,(ds_cnt4+ 99))
        ENDIF
        dsr->qual[(qualcnt - 5)].qual[ds_cnt4].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 5)].
        qual[ds_cnt4].stat_type = 1, dsr->qual[(qualcnt - 5)].qual[ds_cnt4].stat_number_val = cnt,
        ds_cnt4 = (ds_cnt4+ 1)
       ENDIF
      ELSE
       IF (ds_cnt5 > 1)
        IF ((dsr->qual[(qualcnt - 4)].qual[(ds_cnt5 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt5,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 4)].qual,(ds_cnt5+ 99))
         ENDIF
         dsr->qual[(qualcnt - 4)].qual[ds_cnt5].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 4)].
         qual[ds_cnt5].stat_type = 1, dsr->qual[(qualcnt - 4)].qual[ds_cnt5].stat_number_val = cnt,
         ds_cnt5 = (ds_cnt5+ 1)
        ELSE
         dsr->qual[(qualcnt - 4)].qual[(ds_cnt5 - 1)].stat_number_val = (dsr->qual[(qualcnt - 4)].
         qual[(ds_cnt5 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt5,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 4)].qual,(ds_cnt5+ 99))
        ENDIF
        dsr->qual[(qualcnt - 4)].qual[ds_cnt5].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 4)].
        qual[ds_cnt5].stat_type = 1, dsr->qual[(qualcnt - 4)].qual[ds_cnt5].stat_number_val = cnt,
        ds_cnt5 = (ds_cnt5+ 1)
       ENDIF
      ENDIF
      IF (p.physician_ind=1)
       IF (ds_cnt6 > 1)
        IF ((dsr->qual[(qualcnt - 3)].qual[(ds_cnt6 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt6,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 3)].qual,(ds_cnt6+ 99))
         ENDIF
         dsr->qual[(qualcnt - 3)].qual[ds_cnt6].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 3)].
         qual[ds_cnt6].stat_type = 1, dsr->qual[(qualcnt - 3)].qual[ds_cnt6].stat_number_val = cnt,
         ds_cnt6 = (ds_cnt6+ 1)
        ELSE
         dsr->qual[(qualcnt - 3)].qual[(ds_cnt6 - 1)].stat_number_val = (dsr->qual[(qualcnt - 3)].
         qual[(ds_cnt6 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt6,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 3)].qual,(ds_cnt6+ 99))
        ENDIF
        dsr->qual[(qualcnt - 3)].qual[ds_cnt6].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 3)].
        qual[ds_cnt6].stat_type = 1, dsr->qual[(qualcnt - 3)].qual[ds_cnt6].stat_number_val = cnt,
        ds_cnt6 = (ds_cnt6+ 1)
       ENDIF
      ELSE
       IF (ds_cnt7 > 1)
        IF ((dsr->qual[(qualcnt - 2)].qual[(ds_cnt7 - 1)].stat_name != trim(ct_dk)))
         IF (mod(ds_cnt7,100)=1)
          stat = alterlist(dsr->qual[(qualcnt - 2)].qual,(ds_cnt7+ 99))
         ENDIF
         dsr->qual[(qualcnt - 2)].qual[ds_cnt7].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 2)].
         qual[ds_cnt7].stat_type = 1, dsr->qual[(qualcnt - 2)].qual[ds_cnt7].stat_number_val = cnt,
         ds_cnt7 = (ds_cnt7+ 1)
        ELSE
         dsr->qual[(qualcnt - 2)].qual[(ds_cnt7 - 1)].stat_number_val = (dsr->qual[(qualcnt - 2)].
         qual[(ds_cnt7 - 1)].stat_number_val+ cnt)
        ENDIF
       ELSE
        IF (mod(ds_cnt7,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 2)].qual,(ds_cnt7+ 99))
        ENDIF
        dsr->qual[(qualcnt - 2)].qual[ds_cnt7].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 2)].
        qual[ds_cnt7].stat_type = 1, dsr->qual[(qualcnt - 2)].qual[ds_cnt7].stat_number_val = (dsr->
        qual[(qualcnt - 2)].qual[ds_cnt7].stat_number_val+ cnt),
        ds_cnt7 = (ds_cnt7+ 1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (trim(at_cdf)="ORDER")
     IF (o.orig_ord_as_flag=4)
      IF (ds_cnt > 1)
       IF ((dsr->qual[(qualcnt - 8)].qual[(ds_cnt - 1)].stat_name != trim(ct_dk)))
        IF (mod(ds_cnt,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 8)].qual,(ds_cnt+ 99))
        ENDIF
        dsr->qual[(qualcnt - 8)].qual[ds_cnt].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 8)].qual[
        ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 8)].qual[ds_cnt].stat_number_val = cnt,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        dsr->qual[(qualcnt - 8)].qual[(ds_cnt - 1)].stat_number_val = (dsr->qual[(qualcnt - 8)].qual[
        (ds_cnt - 1)].stat_number_val+ cnt)
       ENDIF
      ELSE
       IF (mod(ds_cnt,100)=1)
        stat = alterlist(dsr->qual[(qualcnt - 8)].qual,(ds_cnt+ 99))
       ENDIF
       dsr->qual[(qualcnt - 8)].qual[ds_cnt].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 8)].qual[
       ds_cnt].stat_type = 1, dsr->qual[(qualcnt - 8)].qual[ds_cnt].stat_number_val = cnt,
       ds_cnt = (ds_cnt+ 1)
      ENDIF
     ENDIF
     IF (orc.bill_only_ind=1)
      IF (ds_cnt8 > 1)
       IF ((dsr->qual[(qualcnt - 1)].qual[(ds_cnt8 - 1)].stat_name != trim(ct_dk)))
        IF (mod(ds_cnt8,100)=1)
         stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt8+ 99))
        ENDIF
        dsr->qual[(qualcnt - 1)].qual[ds_cnt8].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 1)].
        qual[ds_cnt8].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt8].stat_number_val = cnt,
        ds_cnt8 = (ds_cnt8+ 1)
       ELSE
        dsr->qual[(qualcnt - 1)].qual[(ds_cnt8 - 1)].stat_number_val = (dsr->qual[(qualcnt - 1)].
        qual[(ds_cnt8 - 1)].stat_number_val+ cnt)
       ENDIF
      ELSE
       IF (mod(ds_cnt8,100)=1)
        stat = alterlist(dsr->qual[(qualcnt - 1)].qual,(ds_cnt8+ 99))
       ENDIF
       dsr->qual[(qualcnt - 1)].qual[ds_cnt8].stat_name = trim(ct_dk), dsr->qual[(qualcnt - 1)].qual[
       ds_cnt8].stat_type = 1, dsr->qual[(qualcnt - 1)].qual[ds_cnt8].stat_number_val = cnt,
       ds_cnt8 = (ds_cnt8+ 1)
      ENDIF
     ELSE
      IF (ds_cnt9 > 1)
       IF ((dsr->qual[qualcnt].qual[(ds_cnt9 - 1)].stat_name != trim(ct_dk)))
        IF (mod(ds_cnt9,100)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt9+ 99))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt9].stat_name = trim(ct_dk), dsr->qual[qualcnt].qual[ds_cnt9].
        stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt9].stat_number_val = cnt,
        ds_cnt9 = (ds_cnt9+ 1)
       ELSE
        dsr->qual[qualcnt].qual[(ds_cnt9 - 1)].stat_number_val = (dsr->qual[qualcnt].qual[(ds_cnt9 -
        1)].stat_number_val+ cnt)
       ENDIF
      ELSE
       IF (mod(ds_cnt9,100)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt9+ 99))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt9].stat_name = trim(ct_dk), dsr->qual[qualcnt].qual[ds_cnt9].
       stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt9].stat_number_val = cnt,
       ds_cnt9 = (ds_cnt9+ 1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual,qualcnt), stat = alterlist(dsr->qual[(qualcnt - 8)].qual,ds_cnt), stat
    = alterlist(dsr->qual[(qualcnt - 7)].qual,ds_cnt2),
   stat = alterlist(dsr->qual[(qualcnt - 6)].qual,ds_cnt3), stat = alterlist(dsr->qual[(qualcnt - 5)]
    .qual,ds_cnt4), stat = alterlist(dsr->qual[(qualcnt - 4)].qual,ds_cnt5),
   stat = alterlist(dsr->qual[(qualcnt - 3)].qual,ds_cnt6), stat = alterlist(dsr->qual[(qualcnt - 2)]
    .qual,ds_cnt7), stat = alterlist(dsr->qual[(qualcnt - 1)].qual,ds_cnt8),
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt9)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cnt = count(*), o.catalog_type_cd, oa.action_type_cd,
  at_cdf = uar_get_code_meaning(oa.action_type_cd), ct_dk = uar_get_code_display(o.catalog_type_cd)
  FROM orders o,
   order_action oa
  WHERE oa.order_id=o.order_id
   AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY o.catalog_type_cd, oa.action_type_cd
  HEAD REPORT
   ds_cnt = 1, qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt),
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "ORDER_VOLUMES - BY CATALOG BY ACTION.2"
  DETAIL
   IF (trim(at_cdf) != ""
    AND trim(ct_dk) != "")
    IF (mod(ds_cnt,20)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 19))
    ENDIF
    dsr->qual[qualcnt].qual[ds_cnt].stat_name = concat(trim(ct_dk)," - ",trim(at_cdf)), dsr->qual[
    qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
    ds_cnt = (ds_cnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 FREE RECORD careset_flags
 RECORD careset_flags(
   1 qual[*]
     2 value = i4
 ) WITH protect
 SET stat = alterlist(careset_flags->qual,6)
 SET careset_flags->qual[1].value = 1
 SET careset_flags->qual[2].value = 2
 SET careset_flags->qual[3].value = 4
 SET careset_flags->qual[4].value = 8
 SET careset_flags->qual[5].value = 16
 SET careset_flags->qual[6].value = 32
 SELECT INTO "nl:"
  cnt = count(*), o.catalog_type_cd, o.cs_flag,
  ct_dk = uar_get_code_display(o.catalog_type_cd)
  FROM orders o,
   order_action oa
  WHERE oa.order_id=o.order_id
   AND oa.action_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
  GROUP BY o.catalog_type_cd, o.cs_flag
  ORDER BY ct_dk
  HEAD REPORT
   ds_cnt = 1, qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt),
   dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot), dsr->qual[qualcnt].
   snapshot_type = "ORDER_VOLUMES - BY CATALOG BY CARE SET.3"
  HEAD ct_dk
   ds_cnt3 = ds_cnt
  DETAIL
   IF (trim(ct_dk) != "")
    IF (mod(ds_cnt,20)=1)
     stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 19))
    ENDIF
    ct_dk_str = trim(ct_dk), ds_cnt4 = cnt
    FOR (ds_cnt2 = 1 TO size(careset_flags->qual,5))
      IF (band(o.cs_flag,careset_flags->qual[ds_cnt2].value) > 0)
       CALL sbr_check_careset(ct_dk_str,careset_flags->qual[ds_cnt2].value,ds_cnt4)
      ENDIF
    ENDFOR
    ml_idx = 0, mn_child_size = size(careset_flags->qual,5)
    IF ( NOT (expand(ml_idx,1,mn_child_size,o.cs_flag,careset_flags->qual[ml_idx].value)))
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = concat(trim(ct_dk)," - ",trim(cnvtstring(o.cs_flag))
      ), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].
     stat_number_val = cnt,
     ds_cnt = (ds_cnt+ 1)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(dsr->qual[qualcnt].qual,ds_cnt)
  WITH nocounter
 ;end select
 SUBROUTINE sbr_check_careset(ms_catalog_dk,mn_cs_flag_bucket,mn_cnt)
   SET ms_bucket_str = concat(trim(ms_catalog_dk)," - ",trim(cnvtstring(mn_cs_flag_bucket)))
   SET mn_child_size = size(dsr->qual[qualcnt].qual,5)
   SET ml_idx = locateval(ml_pos,ds_cnt3,mn_child_size,ms_bucket_str,dsr->qual[qualcnt].qual[ml_pos].
    stat_name)
   IF (ml_idx=0)
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = ms_bucket_str
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = mn_cnt
    SET ds_cnt = (ds_cnt+ 1)
    IF (mod(ds_cnt,20)=1)
     SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 19))
    ENDIF
   ELSE
    SET dsr->qual[qualcnt].qual[ml_idx].stat_number_val = (dsr->qual[qualcnt].qual[ml_idx].
    stat_number_val+ mn_cnt)
   ENDIF
 END ;Subroutine
 CALL dsvm_error("ORDER_VOLUMES")
 CALL sbr_debug_timer("END","ORDER VOLUMES")
 CALL write_dm_info("x")
 CALL sbr_debug_timer("START","LOAD TIMER")
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END","LOAD TIMER")
 SUBROUTINE sbr_debug_timer(ms_input_mode,ms_input_str)
   IF (mn_debug_ind=1)
    CASE (ms_input_mode)
     OF "START":
      SET md_start_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END":
      SET md_end_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Ending timer for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_timer,md_start_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_timer = 0
      SET md_end_timer = 0
     OF "START_TOTAL":
      SET md_start_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting total timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END_TOTAL":
      SET md_end_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" TOTAL execution time for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_total_timer,md_start_total_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_total_timer = 0
      SET md_end_total_timer = 0
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_check_debug(null)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_VOLUME_MEASURE"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_VOLUME_MEASURE", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
   ENDIF
   CALL dsvm_error("CHECK_DEBUG")
 END ;Subroutine
 SUBROUTINE write_dm_info(z)
   CALL echo("Updating DM_INFO with current max_ids and snapshot dt/tm")
   UPDATE  FROM dm_info
    SET info_date = cnvtdatetime(ds_end_snapshot)
    WHERE info_domain="DM_STAT_VOLUME_MEASURE"
     AND info_name="LAST SNAPSHOT DATE TIME"
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info
     SET info_domain = "DM_STAT_VOLUME_MEASURE", info_name = "LAST SNAPSHOT DATE TIME", info_date =
      cnvtdatetime(ds_end_snapshot)
     WITH nocounter
    ;end insert
   ENDIF
   IF (ds_max_acc_hold > 0)
    UPDATE  FROM dm_info
     SET info_number = ds_max_acc_hold
     WHERE info_domain="DM_STAT_VOLUME_MEASURE"
      AND info_name="LAST ACCESSION_ID"
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM dm_info
      SET info_domain = "DM_STAT_VOLUME_MEASURE", info_name = "LAST ACCESSION_ID", info_number =
       ds_max_acc_hold
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   CALL dsvm_error("DM_INFO UPDATES")
   COMMIT
 END ;Subroutine
#exit_program
 FREE RECORD snaps_info
 FREE SET ds_cnt
 FREE SET ds_last_contain_hold
 FREE SET ds_last_acc_hold
 FREE SET ds_max_acc_hold
 FREE SET ds_level_one
 FREE SET ds_level_two
 FREE SET ds_alter_cnt_one
 FREE SET ds_alter_cnt_two
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_VOLUME_MEASURE")
END GO
