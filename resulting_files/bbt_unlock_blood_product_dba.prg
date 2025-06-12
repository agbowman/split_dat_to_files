CREATE PROGRAM bbt_unlock_blood_product:dba
 RECORD reply(
   1 results[*]
     2 ccl_status = i2
     2 status = c1
     2 product_id = f8
     2 product_updt_cnt = i4
     2 product_updt_dt_tm = dq8
     2 product_updt_id = f8
     2 product_updt_task = i4
     2 product_updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET nbr_to_unlock = cnvtint(size(request->productlist,5))
 SET stat = alterlist(reply->results,nbr_to_unlock)
 SET product_count = 0
 SET success_cnt = 0
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET failed = "F"
 SET select_ok_ind = 0
 SET count1 = 0
 SET select_ok_ind = 0
 SELECT INTO "nl:"
  p.product_id
  FROM (dummyt d  WITH seq = value(nbr_to_unlock)),
   product p
  PLAN (d)
   JOIN (p
   WHERE (p.product_id=request->productlist[d.seq].product_id))
  DETAIL
   cur_updt_cnt = p.updt_cnt, reply->results[d.seq].product_id = request->productlist[d.seq].
   product_id, reply->results[d.seq].product_updt_cnt = (cur_updt_cnt+ 1),
   reply->results[d.seq].product_updt_dt_tm = cnvtdatetime(sysdate), reply->results[d.seq].
   product_updt_id = reqinfo->updt_id, reply->results[d.seq].product_updt_task = reqinfo->updt_task,
   reply->results[d.seq].product_updt_applctx = reqinfo->updt_applctx
  FOOT REPORT
   select_ok_ind = 1
  WITH nocounter, forupdate(p), nullreport
 ;end select
 IF (select_ok_ind=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "lock product forupdate"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_unlock_blood_product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "lock product forupdate failed"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM product p,
   (dummyt d  WITH seq = value(nbr_to_unlock))
  SET p.locked_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(sysdate),
   p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (reply->results[d.seq].product_id > 0))
   JOIN (p
   WHERE (p.product_id=request->productlist[d.seq].product_id)
    AND (p.updt_cnt=request->productlist[d.seq].updt_cnt)
    AND p.locked_ind=1)
  WITH nocounter, status(reply->results[d.seq].ccl_status)
 ;end update
 SET select_ok_ind = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(nbr_to_unlock))
  DETAIL
   IF ((reply->results[d.seq].ccl_status=1))
    success_cnt += 1, reply->results[d.seq].status = "S"
   ELSE
    reply->results[d.seq].status = "F"
   ENDIF
  FOOT REPORT
   select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 IF (select_ok_ind=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "update reply->results[]status"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_unlock_blood_product"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Select to update reply->results[]->status failed"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 GO TO exit_script
#exit_script
 IF (select_ok_ind=1
  AND failed="F")
  SET reqinfo->commit_ind = 1
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "unlock product"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_unlock_blood_product"
  IF (success_cnt=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "WARNING:  Zero products unlocked"
  ELSEIF (success_cnt < nbr_to_unlock)
   SET reply->status_data.status = "P"
   SET reply->status_data.subeventstatus[1].operationstatus = "P"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "WARNING:  Not all products unlocked"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationstatus = "P"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "All requested products unlocked"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "P"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Script Failure"
 ENDIF
END GO
