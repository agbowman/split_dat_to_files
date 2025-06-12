CREATE PROGRAM dm_stat_snaps_load:dba
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
 IF (validate(gs_client_mneumonic)=0)
  DECLARE gs_client_mneumonic = vc WITH public, noconstant("")
 ENDIF
 IF (validate(gs_node_name)=0)
  DECLARE gs_node_name = vc WITH public, noconstant("")
 ENDIF
 IF (validate(err_msg)=0)
  DECLARE err_msg = vc WITH protect, noconstant("")
 ENDIF
 IF (gs_client_mneumonic <= "")
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="CLIENT MNEMONIC"
   DETAIL
    gs_client_mneumonic = di.info_char
   WITH nocounter
  ;end select
  IF (error(err_msg,0) != 0)
   CALL esmerror(err_msg,esmexit)
  ENDIF
  IF (gs_client_mneumonic <= "")
   SET err_msg = "No client information available"
   CALL esmerror(err_msg,esmexit)
  ENDIF
 ENDIF
 IF (gs_node_name <= "")
  SET gs_node_name = curnode
  IF (gs_node_name <= "")
   SET err_msg = "No node information available"
   CALL esmerror(err_msg,esmexit)
  ENDIF
 ENDIF
 DECLARE mn_dsr_snap_size = i4 WITH protect, noconstant(0)
 DECLARE mn_dsr_val_size = i4 WITH protect, noconstant(0)
 DECLARE mn_exists_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_insert_snap_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_id_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_first_snapshot = vc WITH protect, noconstant("")
 SET mn_id_cnt = 1
 FREE RECORD snaps_info
 RECORD snaps_info(
   1 dss_id = f8
   1 err_msg = vc
   1 fail_flag = i2
   1 utc_ind = i2
   1 mnemonic = vc
 )
 IF (size(dsr->qual,5) > 0)
  SET ms_first_snapshot = dsr->qual[1].snapshot_type
 ENDIF
 FREE RECORD dsr_inds
 RECORD dsr_inds(
   1 qual[*]
     2 stat_snap_id = f8
     2 parent_exists_ind = i2
     2 qual[*]
       3 update_ind = i2
 )
 FREE RECORD dsr_ids
 RECORD dsr_ids(
   1 qual[*]
     2 new_stat_snap_id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET snaps_info->utc_ind = validate(curutc,- (1))
 SET snaps_info->mnemonic = gs_client_mneumonic
 SET mn_dsr_snap_size = size(dsr->qual,5)
 IF (mn_dsr_snap_size=0)
  GO TO exit_program
 ENDIF
 SET stat = alterlist(dsr_inds->qual,mn_dsr_snap_size)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = mn_dsr_snap_size)
  PLAN (d1
   WHERE d1.seq > 0)
  DETAIL
   IF ((dsr->qual[d1.seq].client_mnemonic=null))
    dsr->qual[d1.seq].client_mnemonic = snaps_info->mnemonic
   ENDIF
   IF ((dsr->qual[d1.seq].domain_name=null))
    dsr->qual[d1.seq].domain_name = reqdata->domain
   ENDIF
   IF ((dsr->qual[d1.seq].node_name=null))
    dsr->qual[d1.seq].node_name = gs_node_name
   ENDIF
   mn_dsr_val_size = size(dsr->qual[d1.seq].qual,5), stat = alterlist(dsr_inds->qual[d1.seq].qual,
    mn_dsr_val_size)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds,
   (dummyt d  WITH seq = mn_dsr_snap_size)
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ds
   WHERE ds.stat_snap_dt_tm=cnvtdatetimeutc(cnvtdatetime(dsr->qual[d.seq].stat_snap_dt_tm))
    AND (ds.client_mnemonic=dsr->qual[d.seq].client_mnemonic)
    AND (ds.domain_name=dsr->qual[d.seq].domain_name)
    AND (ds.node_name=dsr->qual[d.seq].node_name)
    AND (ds.snapshot_type=dsr->qual[d.seq].snapshot_type))
  DETAIL
   mn_exists_cnt = (mn_exists_cnt+ 1), dsr_inds->qual[d.seq].stat_snap_id = ds.dm_stat_snap_id,
   dsr_inds->qual[d.seq].parent_exists_ind = 1
  WITH nocounter
 ;end select
 IF (error(snaps_info->err_msg,0) > 0)
  ROLLBACK
  SET snaps_info->fail_flag = 1
  GO TO exit_program
 ENDIF
 SET mn_insert_snap_cnt = (mn_dsr_snap_size - mn_exists_cnt)
 IF (mn_insert_snap_cnt > 0)
  SET stat = alterlist(dsr_ids->qual,mn_insert_snap_cnt)
  EXECUTE dm2_dar_get_bulk_seq "dsr_ids->qual", mn_insert_snap_cnt, "new_stat_snap_id",
  1, "DM_CLINICAL_SEQ"
  IF ((m_dm2_seq_stat->n_status != 1))
   CALL echo("ERROR encountered in DM2_DAR_GET_BULK_SEQ.")
   CALL echo(m_dm2_seq_stat->s_error_msg)
   SET snaps_info->fail_flag = 1
   GO TO exit_program
  ENDIF
  SET ml_idx = 0
  SET ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_dsr_snap_size,0,dsr_inds->qual[ml_pos].
   parent_exists_ind)
  WHILE (ml_idx > 0)
    SET dsr_inds->qual[ml_idx].stat_snap_id = dsr_ids->qual[mn_id_cnt].new_stat_snap_id
    SET ml_idx = locateval(ml_pos,(ml_idx+ 1),mn_dsr_snap_size,0,dsr_inds->qual[ml_pos].
     parent_exists_ind)
    SET mn_id_cnt = (mn_id_cnt+ 1)
  ENDWHILE
  FREE RECORD dsr_ids
  FREE RECORD m_dm2_seq_stat
  INSERT  FROM dm_stat_snaps ds,
    (dummyt d  WITH seq = mn_dsr_snap_size)
   SET ds.dm_stat_snap_id = dsr_inds->qual[d.seq].stat_snap_id, ds.stat_snap_dt_tm = cnvtdatetime(dsr
     ->qual[d.seq].stat_snap_dt_tm), ds.client_mnemonic = dsr->qual[d.seq].client_mnemonic,
    ds.domain_name = dsr->qual[d.seq].domain_name, ds.node_name = dsr->qual[d.seq].node_name, ds
    .snapshot_type = dsr->qual[d.seq].snapshot_type,
    ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_id = reqinfo->updt_id, ds.updt_task =
    reqinfo->updt_task,
    ds.updt_applctx = reqinfo->updt_applctx, ds.updt_cnt = 0
   PLAN (d
    WHERE d.seq > 0
     AND (dsr_inds->qual[d.seq].parent_exists_ind=0))
    JOIN (ds)
   WITH nocounter
  ;end insert
  IF (error(snaps_info->err_msg,0) > 0)
   ROLLBACK
   SET snaps_info->fail_flag = 1
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_stat_snaps_values ssv,
   (dummyt d1  WITH seq = mn_dsr_snap_size),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE d1.seq > 0
    AND maxrec(d2,size(dsr->qual[d1.seq].qual,5))
    AND (dsr_inds->qual[d1.seq].stat_snap_id > 0)
    AND (dsr_inds->qual[d1.seq].parent_exists_ind=1))
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (ssv
   WHERE (ssv.dm_stat_snap_id=dsr_inds->qual[d1.seq].stat_snap_id)
    AND (ssv.stat_name=dsr->qual[d1.seq].qual[d2.seq].stat_name)
    AND (ssv.stat_seq=dsr->qual[d1.seq].qual[d2.seq].stat_seq))
  DETAIL
   dsr_inds->qual[d1.seq].qual[d2.seq].update_ind = 1
  WITH nocounter
 ;end select
 UPDATE  FROM dm_stat_snaps_values ssv,
   (dummyt d1  WITH seq = mn_dsr_snap_size),
   (dummyt d2  WITH seq = 1)
  SET ssv.stat_str_val = dsr->qual[d1.seq].qual[d2.seq].stat_str_val, ssv.stat_type = dsr->qual[d1
   .seq].qual[d2.seq].stat_type, ssv.stat_number_val = dsr->qual[d1.seq].qual[d2.seq].stat_number_val,
   ssv.stat_clob_val = dsr->qual[d1.seq].qual[d2.seq].stat_clob_val, ssv.stat_date_dt_tm =
   cnvtdatetime(dsr->qual[d1.seq].qual[d2.seq].stat_date_val), ssv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ssv.updt_cnt = (ssv.updt_cnt+ 1), ssv.updt_id = reqinfo->updt_id, ssv.updt_task = reqinfo->
   updt_task,
   ssv.updt_applctx = reqinfo->updt_applctx
  PLAN (d1
   WHERE d1.seq > 0
    AND maxrec(d2,size(dsr->qual[d1.seq].qual,5))
    AND (dsr_inds->qual[d1.seq].stat_snap_id > 0)
    AND (dsr_inds->qual[d1.seq].parent_exists_ind=1))
   JOIN (d2
   WHERE d2.seq > 0
    AND (dsr_inds->qual[d1.seq].qual[d2.seq].update_ind=1)
    AND trim(dsr->qual[d1.seq].qual[d2.seq].stat_name) != "")
   JOIN (ssv
   WHERE (ssv.dm_stat_snap_id=dsr_inds->qual[d1.seq].stat_snap_id)
    AND (ssv.stat_name=dsr->qual[d1.seq].qual[d2.seq].stat_name)
    AND (ssv.stat_seq=dsr->qual[d1.seq].qual[d2.seq].stat_seq))
  WITH nocounter
 ;end update
 IF (error(snaps_info->err_msg,0) > 0)
  ROLLBACK
  SET snaps_info->fail_flag = 1
  GO TO exit_program
 ENDIF
 COMMIT
 INSERT  FROM dm_stat_snaps_values ssv,
   (dummyt d1  WITH seq = mn_dsr_snap_size),
   (dummyt d2  WITH seq = 1)
  SET ssv.dm_stat_snap_id = dsr_inds->qual[d1.seq].stat_snap_id, ssv.stat_name = dsr->qual[d1.seq].
   qual[d2.seq].stat_name, ssv.stat_seq = dsr->qual[d1.seq].qual[d2.seq].stat_seq,
   ssv.stat_str_val = dsr->qual[d1.seq].qual[d2.seq].stat_str_val, ssv.stat_type = dsr->qual[d1.seq].
   qual[d2.seq].stat_type, ssv.stat_number_val = dsr->qual[d1.seq].qual[d2.seq].stat_number_val,
   ssv.stat_clob_val = dsr->qual[d1.seq].qual[d2.seq].stat_clob_val, ssv.stat_date_dt_tm =
   cnvtdatetime(dsr->qual[d1.seq].qual[d2.seq].stat_date_val), ssv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   ssv.updt_id = reqinfo->updt_id, ssv.updt_task = reqinfo->updt_task, ssv.updt_applctx = reqinfo->
   updt_applctx,
   ssv.updt_cnt = 0
  PLAN (d1
   WHERE d1.seq > 0
    AND maxrec(d2,size(dsr->qual[d1.seq].qual,5))
    AND (dsr_inds->qual[d1.seq].stat_snap_id > 0))
   JOIN (d2
   WHERE d2.seq > 0
    AND (dsr_inds->qual[d1.seq].qual[d2.seq].update_ind=0)
    AND trim(dsr->qual[d1.seq].qual[d2.seq].stat_name) != "")
   JOIN (ssv)
  WITH nocounter
 ;end insert
 IF (error(snaps_info->err_msg,0) > 0)
  ROLLBACK
  SET snaps_info->fail_flag = 1
  GO TO exit_program
 ENDIF
 IF ((validate(mn_rec_snapshot_ind,- (1))=- (1)))
  COMMIT
 ENDIF
#exit_program
 IF ((snaps_info->fail_flag=1))
  CALL esmerror(build("First_Snap: ",ms_first_snapshot,".  Error: ",snaps_info->err_msg,esmreturn))
  CALL echo("*************************************************")
  CALL echo(snaps_info->err_msg)
  CALL echo("*************************************************")
 ENDIF
 FREE RECORD snaps_info
 SET stat = initrec(dsr)
 FREE RECORD dsr_inds
END GO
