CREATE PROGRAM bbt_get_trans_comm_prod:dba
 RECORD reply(
   1 trans_commit_id = f8
   1 single_trans_ind = i2
   1 single_pre_hours = i4
   1 single_post_hours = i4
   1 active_ind = i2
   1 updt_cnt = i4
   1 qual[*]
     2 trans_commit_assay_id = f8
     2 task_assay_cd = f8
     2 task_assay_cd_disp = vc
     2 pre_hours = i4
     2 post_hours = i4
     2 all_results_ind = i2
     2 active_ind = i2
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
 SET tc_cnt = 0
 SET tca_cnt = 0
 SELECT INTO "nl:"
  tc.trans_commit_id, tc.single_trans_ind, tc.single_pre_hours,
  tc.single_post_hours, tc.active_ind, tc.updt_cnt,
  tca.trans_commit_assay_id, tca.task_assay_cd, tca.pre_hours,
  tca.post_hours, tca.all_results_ind, tca.active_ind,
  tca.updt_cnt, nullindicator = nullind(tca.trans_commit_id)
  FROM transfusion_committee tc,
   trans_commit_assay tca
  PLAN (tc
   WHERE (tc.product_cd=request->product_cd))
   JOIN (tca
   WHERE tca.trans_commit_id=outerjoin(tc.trans_commit_id))
  ORDER BY tc.trans_commit_id
  HEAD REPORT
   tc_cnt = 0
  HEAD tc.trans_commit_id
   tc_cnt = (tc_cnt+ 1), tca_cnt = 0, stat = alterlist(reply->qual,5),
   reply->trans_commit_id = tc.trans_commit_id, reply->single_trans_ind = tc.single_trans_ind, reply
   ->single_pre_hours = tc.single_pre_hours,
   reply->single_post_hours = tc.single_post_hours, reply->active_ind = tc.active_ind, reply->
   updt_cnt = tc.updt_cnt
  DETAIL
   IF (nullindicator=0)
    tca_cnt = (tca_cnt+ 1)
    IF (mod(tca_cnt,5)=1
     AND tca_cnt != 1)
     stat = alterlist(reply->qual,(tca_cnt+ 4))
    ENDIF
    reply->qual[tca_cnt].trans_commit_assay_id = tca.trans_commit_assay_id, reply->qual[tca_cnt].
    task_assay_cd = tca.task_assay_cd, reply->qual[tca_cnt].pre_hours = tca.pre_hours,
    reply->qual[tca_cnt].post_hours = tca.post_hours, reply->qual[tca_cnt].all_results_ind = tca
    .all_results_ind, reply->qual[tca_cnt].active_ind = tca.active_ind,
    reply->qual[tca_cnt].updt_cnt = tca.updt_cnt
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,tca_cnt)
 IF (curqual != 0)
  IF (tc_cnt=1)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
   SET count1 = (count1+ 1)
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname =
   "get transfusion_committee/trans_commit_assay rows"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_trans_comm_prod"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "Multiple transfusion_committee rows for product_cd, cannot retrieve data"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
