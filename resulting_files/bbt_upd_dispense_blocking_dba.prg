CREATE PROGRAM bbt_upd_dispense_blocking:dba
 RECORD reply(
   1 dispense_block_id = f8
   1 qual[*]
     2 product_cd = f8
     2 block_product_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET new_dispense_block_id = 0.0
 SET new_block_product_id = 0.0
 SET qual_cnt = 0
 SET block_cnt = 0
 SET block = 0
 SET stat = alterlist(reply->qual,10)
 IF ((request->dispense_block_id=0))
  SET new_dispense_block_id = next_pathnet_seq(0)
  IF (curqual=0)
   CALL load_process_status("F","get next pathnet_seq",build(
     "get next pathnet_seq failed--dispense_block_id =",request->dispense_block_id))
   GO TO exit_script
  ENDIF
  INSERT  FROM bb_dspns_block db
   SET db.dispense_block_id = new_dispense_block_id, db.product_cd = request->product_cd, db
    .allow_override_ind = request->allow_override_ind,
    db.active_ind = request->active_ind, db.updt_cnt = 0, db.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    db.updt_id = reqinfo->updt_id, db.updt_task = reqinfo->updt_task, db.updt_applctx = reqinfo->
    updt_applctx,
    db.active_status_cd =
    IF ((request->active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , db.active_status_dt_tm = cnvtdatetime(curdate,curtime3), db.active_status_prsnl_id = reqinfo->
    updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL load_process_status("F","insert into bb_dspns_block",build(
     "insert into bb_dspns_block failed--dispense_block_id =",request->dispense_block_id))
   GO TO exit_script
  ENDIF
  CALL process_blocking(new_dispense_block_id)
  SET reply->dispense_block_id = new_dispense_block_id
 ELSE
  IF ((request->changed_ind=1))
   SELECT INTO "nl:"
    db.dispense_block_id
    FROM bb_dspns_block db
    WHERE (db.dispense_block_id=request->dispense_block_id)
     AND (db.updt_cnt=request->updt_cnt)
    WITH nocounter, forupdate(db)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock bb_dspns_block forupdate",build(
      "lock bb_dspns_block forupdate failed--dispense_block_id =",request->dispense_block_id))
    GO TO exit_script
   ENDIF
   UPDATE  FROM bb_dspns_block db
    SET db.allow_override_ind = request->allow_override_ind, db.active_ind = request->active_ind, db
     .updt_cnt = (db.updt_cnt+ 1),
     db.updt_dt_tm = cnvtdatetime(curdate,curtime3), db.updt_id = reqinfo->updt_id, db.updt_task =
     reqinfo->updt_task,
     db.updt_applctx = reqinfo->updt_applctx, db.active_ind = request->active_ind, db
     .active_status_cd =
     IF ((request->active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     ,
     db.active_status_dt_tm = cnvtdatetime(curdate,curtime3), db.active_status_prsnl_id = reqinfo->
     updt_id
    WHERE (db.dispense_block_id=request->dispense_block_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL load_process_status("F","update into bb_dspns_block",build(
      "update into bb_dspns_block failed--dispense_block_id =",request->dispense_block_id))
    GO TO exit_script
   ENDIF
  ENDIF
  CALL process_blocking(request->dispense_block_id)
 ENDIF
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
 SUBROUTINE process_blocking(sub_pass_dispense_block_id)
   SET stat = alterlist(reply->qual,10)
   CALL process_block_added(sub_pass_dispense_block_id)
   CALL process_block_removed(sub_pass_dispense_block_id)
   SET stat = alterlist(reply->qual,qual_cnt)
 END ;Subroutine
 SUBROUTINE process_block_added(sub_dispense_block_id)
  SET block_cnt = size(request->block_added,5)
  FOR (block = 1 TO block_cnt)
    SET new_block_product_id = next_pathnet_seq(0)
    IF (curqual=0)
     CALL load_process_status("F","get next pathnet_seq",build(
       "get next pathnet_seq failed--block_product_id =",request->block_added[block].block_product_id
       ))
     GO TO exit_script
    ENDIF
    INSERT  FROM bb_dspns_block_product dbp
     SET dbp.block_product_id = new_block_product_id, dbp.dispense_block_id = sub_dispense_block_id,
      dbp.product_cd = request->block_added[block].product_cd,
      dbp.updt_cnt = 0, dbp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dbp.updt_id = reqinfo->
      updt_id,
      dbp.updt_task = reqinfo->updt_task, dbp.updt_applctx = reqinfo->updt_applctx, dbp.active_ind =
      1,
      dbp.active_status_cd = reqdata->active_status_cd, dbp.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3), dbp.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL load_process_status("F","insert into bb_dspns_block_product",build(
       "insert into bb_dspns_block_product failed--dispense_block_id =",request->block_added[block].
       dispense_block_id))
     GO TO exit_script
    ENDIF
    SET qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1
     AND qual_cnt != 1)
     SET stat = alterlist(reply->qual,(qual_cnt+ 9))
    ENDIF
    SET reply->qual[qual_cnt].product_cd = request->block_added[block].product_cd
    SET reply->qual[qual_cnt].block_product_id = new_block_product_id
  ENDFOR
 END ;Subroutine
 SUBROUTINE process_block_removed(sub_dispense_block_id)
  SET block_cnt = size(request->block_removed,5)
  FOR (block = 1 TO block_cnt)
    SELECT INTO "nl:"
     dbp.block_product_id
     FROM bb_dspns_block_product dbp
     WHERE (dbp.block_product_id=request->block_removed[block].block_product_id)
      AND (dbp.updt_cnt=request->block_removed[block].updt_cnt)
     WITH nocounter, forupdate(dbp)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock bb_dspns_block_product forupdate",build(
       "lock bb_dspns_block_product forupdate failed--block_product_id =",request->block_removed[
       block].block_product_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_dspns_block_product dbp
     SET dbp.updt_cnt = (dbp.updt_cnt+ 1), dbp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dbp
      .updt_id = reqinfo->updt_id,
      dbp.updt_task = reqinfo->updt_task, dbp.updt_applctx = reqinfo->updt_applctx, dbp.active_ind =
      0,
      dbp.active_status_cd = reqdata->inactive_status_cd, dbp.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3), dbp.active_status_prsnl_id = reqinfo->updt_id
     WHERE (dbp.block_product_id=request->block_removed[block].block_product_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL load_process_status("F","update into bb_dspns_block_product",build(
       "update into bb_dspns_block_product failed--dispense_block_id =",request->block_removed[block]
       .dispense_block_id))
     GO TO exit_script
    ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 SUBROUTINE load_process_status(sub_status,sub_process,sub_message)
   SET reply->status_data.status = sub_status
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = sub_process
   SET reply->status_data.subeventstatus[count1].operationstatus = sub_status
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_dispense_blocking"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
