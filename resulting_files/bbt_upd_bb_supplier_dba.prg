CREATE PROGRAM bbt_upd_bb_supplier:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 bb_supplier_id = f8
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
 SET new_bb_supplier_id = 0.0
 SET qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET supplier_cnt = size(request->supplierlist,5)
 FOR (splr = 1 TO supplier_cnt)
   IF ((request->supplierlist[splr].bb_supplier_id=0))
    SET new_bb_supplier_id = next_pathnet_seq(0)
    IF (curqual=0)
     CALL load_process_status("F","get next pathnet_seq",build(
       "get next pathnet_seq failed--organization_id =",request->supplierlist[splr].organization_id))
     GO TO exit_script
    ENDIF
    INSERT  FROM bb_supplier bbs
     SET bbs.bb_supplier_id = new_bb_supplier_id, bbs.organization_id = request->supplierlist[splr].
      organization_id, bbs.barcode_value = request->supplierlist[splr].barcode_value,
      bbs.prefix_ind = request->supplierlist[splr].prefix_ind, bbs.prefix_value = request->
      supplierlist[splr].prefix_value, bbs.default_prefix_ind = request->supplierlist[splr].
      default_prefix_ind,
      bbs.alpha_translation_ind = request->supplierlist[splr].alpha_translation_ind, bbs.updt_cnt = 0,
      bbs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bbs.updt_id = reqinfo->updt_id, bbs.updt_task = reqinfo->updt_task, bbs.updt_applctx = reqinfo
      ->updt_applctx,
      bbs.active_ind = 1, bbs.active_status_cd = reqdata->active_status_cd, bbs.active_status_dt_tm
       = cnvtdatetime(curdate,curtime3),
      bbs.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL load_process_status("F","insert into bb_supplier",build(
       "insert into bb_supplier failed--organization_id =",request->supplierlist[splr].
       organization_id))
     GO TO exit_script
    ENDIF
    SET qual_cnt = (qual_cnt+ 1)
    IF (mod(qual_cnt,10)=1
     AND qual_cnt != 1)
     SET stat = alterlist(reply->qual,(qual_cnt+ 9))
    ENDIF
    SET reply->qual[qual_cnt].organization_id = request->supplierlist[splr].organization_id
    SET reply->qual[qual_cnt].bb_supplier_id = new_bb_supplier_id
   ELSE
    SELECT INTO "nl:"
     bbs.bb_supplier_id
     FROM bb_supplier bbs
     WHERE (bbs.bb_supplier_id=request->supplierlist[splr].bb_supplier_id)
      AND (bbs.updt_cnt=request->supplierlist[splr].updt_cnt)
     WITH nocounter, forupdate(bbs)
    ;end select
    IF (curqual=0)
     CALL load_process_status("F","lock bb_supplier forupdate",build(
       "lock bb_supplier forupdate failed--organization_id =",request->supplierlist[splr].
       organization_id))
     GO TO exit_script
    ENDIF
    UPDATE  FROM bb_supplier bbs
     SET bbs.prefix_ind = request->supplierlist[splr].prefix_ind, bbs.default_prefix_ind = request->
      supplierlist[splr].default_prefix_ind, bbs.alpha_translation_ind = request->supplierlist[splr].
      alpha_translation_ind,
      bbs.updt_cnt = (bbs.updt_cnt+ 1), bbs.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbs.updt_id
       = reqinfo->updt_id,
      bbs.updt_task = reqinfo->updt_task, bbs.updt_applctx = reqinfo->updt_applctx, bbs.active_ind =
      request->supplierlist[splr].active_ind,
      bbs.active_status_cd =
      IF ((request->supplierlist[splr].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , bbs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bbs.active_status_prsnl_id =
      reqinfo->updt_id
     WHERE (bbs.bb_supplier_id=request->supplierlist[splr].bb_supplier_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL load_process_status("F","update into bb_supplier",build(
       "update into bb_supplier failed--organization_id =",request->supplierlist[splr].
       organization_id))
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,qual_cnt)
 CALL load_process_status("S","SUCCESS","All records added/updated successfully")
 GO TO exit_script
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
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_upd_bb_supplier"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
