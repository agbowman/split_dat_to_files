CREATE PROGRAM bbt_add_trans_comm_prod:dba
 RECORD reply(
   1 trans_commit_id = f8
   1 trans_commit_assay[*]
     2 trans_commit_assay_id = f8
     2 task_assay_cd = f8
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
 SET stat = alterlist(reply->trans_commit_assay,request->qual_count)
 SET tc = 0
 SET reqinfo->commit_ind = 0
 SET next_code = 0.0
 SET tc_active_ind = 0
 SET trans_commit_id = 0.0
 SET trans_commit_assay_id = 0.0
 IF ((request->trans_commit_id=0))
  SET trans_commit_id = next_pathnet_seq(0)
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "Add transfusion_committee row"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_trans_comm_prod"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "Get next pathnet_seq for transfusion_committee failed"
   GO TO exit_script
  ENDIF
  INSERT  FROM transfusion_committee tc
   SET tc.trans_commit_id = trans_commit_id, tc.product_cd = request->product_cd, tc.single_trans_ind
     = request->single_trans_ind,
    tc.single_pre_hours = request->single_pre_hours, tc.single_post_hours = request->
    single_post_hours, tc.active_ind = request->active_ind,
    tc.active_status_cd =
    IF ((request->active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , tc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), tc.active_status_prsnl_id = reqinfo->
    updt_id,
    tc.updt_cnt = 0, tc.updt_dt_tm = cnvtdatetime(curdate,curtime3), tc.updt_id = reqinfo->updt_id,
    tc.updt_task = reqinfo->updt_task, tc.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "Add transfusion_committee row"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_trans_comm_prod"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "Error adding transfusion_committee row.  No updates."
   GO TO exit_script
  ELSE
   SET reply->trans_commit_id = trans_commit_id
  ENDIF
 ELSE
  SET trans_commit_id = request->trans_commit_id
 ENDIF
 FOR (tc = 1 TO request->qual_count)
   SET trans_commit_assay_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET count1 = (count1+ 1)
    IF (count1 > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,count1)
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "Add trans_commit_assay row"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_trans_comm_prod"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "Get next pathnet_seq for trans_commit_assay failed"
    GO TO exit_script
   ENDIF
   INSERT  FROM trans_commit_assay tca
    SET tca.trans_commit_assay_id = trans_commit_assay_id, tca.trans_commit_id = trans_commit_id, tca
     .task_assay_cd = request->qual[tc].task_assay_cd,
     tca.pre_hours = request->qual[tc].pre_hours, tca.post_hours = request->qual[tc].post_hours, tca
     .all_results_ind = request->qual[tc].all_results_ind,
     tca.active_ind = request->qual[tc].active_ind, tca.active_status_cd =
     IF ((request->qual[tc].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , tca.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     tca.active_status_prsnl_id = reqinfo->updt_id, tca.updt_cnt = 0, tca.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     tca.updt_id = reqinfo->updt_id, tca.updt_task = reqinfo->updt_task, tca.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET count1 = (count1+ 1)
    IF (count1 > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,count1)
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "Add trans_commit_row row"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_add_trans_comm_prod"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue =
    "Error adding trans_commit_row.  No updates."
    GO TO exit_script
   ELSE
    SET reply->trans_commit_assay[tc].trans_commit_assay_id = trans_commit_assay_id
    SET reply->trans_commit_assay[tc].task_assay_cd = request->qual[tc].task_assay_cd
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 SET stat = alterlist(reply->trans_commit_assay,tc)
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
#exit_script
END GO
