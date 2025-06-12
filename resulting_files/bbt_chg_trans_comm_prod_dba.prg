CREATE PROGRAM bbt_chg_trans_comm_prod:dba
 RECORD reply(
   1 trans_commit_assay[*]
     2 trans_commit_assay_id = f8
     2 task_assay_cd = f8
     2 updt_cnt = i4
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
 SET tca_cnt = 0
 SET tca_cnt = size(request->qual,5)
 IF (tca_cnt=0)
  SET tca_cnt = 1
  SET stat = alterlist(rquest->qual,1)
 ELSE
  SET stat = alterlist(reply->trans_commit_assay,tca_cnt)
 ENDIF
 SELECT INTO "nl:"
  tc.trans_commit_id, tca.trans_commit_assay_id
  FROM (dummyt d  WITH seq = value(tca_cnt)),
   transfusion_committee tc,
   (dummyt d_tc  WITH seq = 1),
   trans_commit_assay tca
  PLAN (d
   WHERE d.seq=1)
   JOIN (tc
   WHERE (tc.trans_commit_id=request->trans_commit_id)
    AND (tc.updt_cnt=request->updt_cnt))
   JOIN (d_tc
   WHERE d_tc.seq=1)
   JOIN (tca
   WHERE tca.trans_commit_id=tc.trans_commit_id
    AND (tca.trans_commit_assay_id=request->qual[d.seq].trans_commit_assay_id)
    AND (tca.updt_cnt=request->qual[d.seq].updt_cnt))
  WITH nocounter, outerjoin(d_tc), forupdate(tc),
   forupdate(tca)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "lock transfusion_committee/trans_commit_assay forupdate"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_chg_trans_comm_prod"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Error locking transfusion_committee/trans_commit_assay forupdate"
  GO TO exit_script
 ENDIF
 UPDATE  FROM transfusion_committee tc
  SET tc.single_trans_ind = request->single_trans_ind, tc.single_pre_hours = request->
   single_pre_hours, tc.single_post_hours = request->single_post_hours,
   tc.active_ind = request->active_ind, tc.active_status_cd =
   IF ((request->active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , tc.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   tc.active_status_prsnl_id = reqinfo->updt_id, tc.updt_cnt = (tc.updt_cnt+ 1), tc.updt_id = reqinfo
   ->updt_id,
   tc.updt_dt_tm = cnvtdatetime(curdate,curtime3), tc.updt_task = reqinfo->updt_task, tc.updt_applctx
    = reqinfo->updt_applctx
  WHERE (tc.trans_commit_id=request->trans_commit_id)
   AND (tc.updt_cnt=request->updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "update transfusion_committee"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_chg_trans_comm_prod"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "Error updating transfusion_committee"
  GO TO exit_script
 ENDIF
 FOR (tca = 1 TO tca_cnt)
   IF ((request->qual[tca].trans_commit_assay_id != null)
    AND (request->qual[tca].trans_commit_assay_id > 0))
    UPDATE  FROM trans_commit_assay tca
     SET tca.pre_hours = request->qual[tca].pre_hours, tca.post_hours = request->qual[tca].post_hours,
      tca.all_results_ind = request->qual[tca].all_results_ind,
      tca.active_ind = request->qual[tca].active_ind, tca.active_status_cd =
      IF ((request->qual[tca].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , tca.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      tca.active_status_prsnl_id = reqinfo->updt_id, tca.updt_cnt = (tca.updt_cnt+ 1), tca.updt_id =
      reqinfo->updt_id,
      tca.updt_dt_tm = cnvtdatetime(curdate,curtime3), tca.updt_task = reqinfo->updt_task, tca
      .updt_applctx = reqinfo->updt_applctx
     WHERE (tca.trans_commit_assay_id=request->qual[tca].trans_commit_assay_id)
      AND (tca.updt_cnt=request->qual[tca].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET count1 = (count1+ 1)
     IF (count1 > 1)
      SET stat = alterlist(reply->status_data.subeventstatus,count1)
     ENDIF
     SET reply->status_data.subeventstatus[count1].operationname = "update trans_commit_assay"
     SET reply->status_data.subeventstatus[count1].operationstatus = "F"
     SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_chg_trans_comm_prod"
     SET reply->status_data.subeventstatus[count1].targetobjectvalue =
     "Error updating trans_commit_assay"
     GO TO exit_script
    ELSE
     SET reply->trans_commit_assay[tca].trans_commit_assay_id = request->qual[tca].
     trans_commit_assay_id
     SET reply->trans_commit_assay[tca].updt_cnt = (request->qual[tca].updt_cnt+ 1)
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 GO TO exit_script
#exit_script
END GO
