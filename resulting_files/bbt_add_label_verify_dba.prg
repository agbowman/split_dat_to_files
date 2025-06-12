CREATE PROGRAM bbt_add_label_verify:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET status_count = 0
 SET nbr_of_rows = cnvtint(size(request->qual,5))
 SET nbr_to_add = size(request->qual,5)
 FOR (idx = 1 TO nbr_to_add)
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "bb_label_verify"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = cnvtstring(request->qual[idx].
     product_id)
    SET failed = "T"
   ELSE
    SET bb_label_verify_id = new_pathnet_seq
    INSERT  FROM bb_label_verify bblv
     SET bblv.bb_label_verify_id = bb_label_verify_id, bblv.product_id = request->qual[idx].
      product_id, bblv.label_verf_dt_tm = cnvtdatetime(curdate,curtime3),
      bblv.personnel_id = reqinfo->updt_id, bblv.updt_dt_tm = cnvtdatetime(curdate,curtime3), bblv
      .updt_id = reqinfo->updt_id,
      bblv.updt_task = reqinfo->updt_task, bblv.updt_applctx = reqinfo->updt_applctx, bblv.updt_cnt
       = 0,
      bblv.active_ind = 1, bblv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bblv
      .active_status_cd = reqdata->active_status_cd,
      bblv.active_status_prsnl_id = reqinfo->updt_id
    ;end insert
    IF (curqual=0)
     SET status_count = (status_count+ 1)
     IF (status_count > 1)
      SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[status_count].operationname = "ADD"
     SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
     SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB_LABEL_VERIFY"
     SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
     "Unable to add row to table in Label Verify"
     SET reqinfo->commit_ind = 0
    ELSE
     SET reqinfo->commit_ind = 1
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
 ENDFOR
END GO
