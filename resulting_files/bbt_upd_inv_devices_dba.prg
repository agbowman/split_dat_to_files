CREATE PROGRAM bbt_upd_inv_devices:dba
 RECORD reply(
   1 bb_inv_device_id = f8
   1 qual[*]
     2 device_r_cd = f8
     2 bb_inv_device_r_id = f8
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
 SET new_device_id = 0.0
 SET new_inv_device_r_id = 0.0
 SET qual_cnt = 0
 SET reltn_cnt = 0
 SET reltn = 0
 SET stat = alterlist(reply->qual,10)
 IF ((request->bb_inv_device_id=0))
  SET new_device_id = next_pathnet_seq(0)
  IF (curqual=0)
   CALL load_process_status("F","get next pathnet_seq",build(
     "get next pathnet_seq failed--bb_inv_device_id =",request->bb_inv_device_id))
   GO TO exit_script
  ENDIF
  INSERT  FROM bb_inv_device bbd
   SET bbd.bb_inv_device_id = new_device_id, bbd.device_type_cd = request->device_type_cd, bbd
    .active_ind = request->active_ind,
    bbd.updt_cnt = 0, bbd.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbd.updt_id = reqinfo->updt_id,
    bbd.updt_task = reqinfo->updt_task, bbd.updt_applctx = reqinfo->updt_applctx, bbd
    .active_status_cd =
    IF ((request->active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    ,
    bbd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bbd.active_status_prsnl_id = reqinfo->
    updt_id, bbd.description = request->description,
    bbd.interface_flag = request->interface_flag
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL load_process_status("F","insert into bb_inv_device",build(
     "insert into bb_inv_device failed--bb_inv_device_id =",request->bb_inv_device_id))
   GO TO exit_script
  ENDIF
  CALL process_reltns(new_device_id)
  SET reply->bb_inv_device_id = new_device_id
 ELSE
  IF ((request->changed_ind=1))
   SELECT INTO "nl:"
    bbd.bb_inv_device_id
    FROM bb_inv_device bbd
    WHERE (bbd.bb_inv_device_id=request->bb_inv_device_id)
    WITH nocounter, forupdate(bbd)
   ;end select
   IF (curqual=0)
    CALL load_process_status("F","lock bb_inv_device forupdate",build(
      "lock bb_inv_device forupdate failed--bb_inv_device_id =",request->bb_inv_device_id))
    GO TO exit_script
   ENDIF
   UPDATE  FROM bb_inv_device bbd
    SET bbd.updt_cnt = (bbd.updt_cnt+ 1), bbd.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbd
     .updt_id = reqinfo->updt_id,
     bbd.updt_task = reqinfo->updt_task, bbd.updt_applctx = reqinfo->updt_applctx, bbd.active_ind =
     request->active_ind,
     bbd.active_status_cd =
     IF ((request->active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , bbd.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bbd.active_status_prsnl_id = reqinfo
     ->updt_id,
     bbd.device_type_cd = request->device_type_cd, bbd.interface_flag = request->interface_flag
    WHERE (bbd.bb_inv_device_id=request->bb_inv_device_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL load_process_status("F","update into bb_inv_device",build(
      "update into bb_inv_device failed--bb_inv_device_id =",request->bb_inv_device_id))
    GO TO exit_script
   ENDIF
  ENDIF
  CALL process_reltns(request->bb_inv_device_id)
 ENDIF
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
 SUBROUTINE process_reltns(sub_pass_bb_inv_device_id)
   SET stat = alterlist(reply->qual,10)
   CALL process_reltn_added(sub_pass_bb_inv_device_id)
   CALL process_reltn_removed(sub_pass_bb_inv_device_id)
   SET stat = alterlist(reply->qual,qual_cnt)
 END ;Subroutine
 SUBROUTINE process_reltn_added(sub_bb_inv_device_id)
   SET invarea_cd = 0.0
   SET locn_cd = 0.0
   SET srvres_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(17396,"BBPATLOCN",1,locn_cd)
   SET stat = uar_get_meaning_by_codeset(17396,"BBINVAREA",1,invarea_cd)
   SET stat = uar_get_meaning_by_codeset(17396,"BBSRVRESRC",1,srvres_cd)
   SET reltn_cnt = size(request->reltn_added,5)
   FOR (reltn = 1 TO reltn_cnt)
     SET new_inv_device_r_id = next_pathnet_seq(0)
     IF (curqual=0)
      CALL load_process_status("F","get next pathnet_seq",build(
        "get next pathnet_seq failed--device_r_cd =",request->reltn_added[reltn].device_r_cd))
      GO TO exit_script
     ENDIF
     INSERT  FROM bb_inv_device_r bdr
      SET bdr.bb_inv_device_r_id = new_inv_device_r_id, bdr.bb_inv_device_id = sub_bb_inv_device_id,
       bdr.device_r_cd = request->reltn_added[reltn].device_r_cd,
       bdr.device_r_type_cd =
       IF ((request->reltn_added[reltn].device_r_type_mean="BBINVAREA")) invarea_cd
       ELSEIF ((request->reltn_added[reltn].device_r_type_mean="BBPATLOCN")) locn_cd
       ELSEIF ((request->reltn_added[reltn].device_r_type_mean="BBSRVRESRC")) srvres_cd
       ENDIF
       , bdr.updt_cnt = 0, bdr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bdr.updt_id = reqinfo->updt_id, bdr.updt_task = reqinfo->updt_task, bdr.updt_applctx = reqinfo
       ->updt_applctx,
       bdr.active_ind = 1, bdr.active_status_cd = reqdata->active_status_cd, bdr.active_status_dt_tm
        = cnvtdatetime(curdate,curtime3),
       bdr.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL load_process_status("F","insert into bb_inv_device_r",build(
        "insert into bb_inv_device_r failed--bb_inv_device_id =",request->reltn_added[reltn].
        bb_inv_device_id))
      GO TO exit_script
     ENDIF
     SET qual_cnt = (qual_cnt+ 1)
     IF (mod(qual_cnt,10)=1
      AND qual_cnt != 1)
      SET stat = alterlist(reply->qual,(qual_cnt+ 9))
     ENDIF
     SET reply->qual[qual_cnt].device_r_cd = request->reltn_added[reltn].device_r_cd
     SET reply->qual[qual_cnt].bb_inv_device_r_id = new_inv_device_r_id
   ENDFOR
 END ;Subroutine
 SUBROUTINE process_reltn_removed(sub_bb_inv_device_id)
  SET reltn_cnt = size(request->reltn_removed,5)
  FOR (reltn = 1 TO reltn_cnt)
    SELECT INTO "nl:"
     bdr.device_r_cd
     FROM bb_inv_device_r bdr
     WHERE bdr.bb_inv_device_id=sub_bb_inv_device_id
      AND (bdr.device_r_cd=request->reltn_removed[reltn].device_r_cd)
      AND bdr.active_ind=1
     WITH nocounter, forupdate(bdr)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock bb_inv_device_r forupdate",build(
       "lock bb_inv_device_r forupdate failed--device_r_cd =",request->reltn_removed[reltn].
       device_r_cd))
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_inv_device_r bdr
     SET bdr.updt_cnt = (bdr.updt_cnt+ 1), bdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdr
      .active_ind = 0,
      bdr.active_status_cd = reqdata->inactive_status_cd, bdr.active_status_dt_tm = cnvtdatetime(
       curdate,curtime3)
     WHERE bdr.bb_inv_device_id=sub_bb_inv_device_id
      AND (bdr.device_r_cd=request->reltn_removed[reltn].device_r_cd)
      AND bdr.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL load_process_status("F","update into bb_inv_device_r",build(
       "update into bb_inv_device_r failed--bb_inv_device_id =",request->reltn_removed[reltn].
       bb_inv_device_id))
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
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_inv_devices"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
