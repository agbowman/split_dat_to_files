CREATE PROGRAM bbd_get_org_quota:dba
 RECORD reply(
   1 qual[*]
     2 beg_effective_dt_tm = di8
     2 end_effective_dt_tm = di8
     2 inhouse = i4
     2 mobile = i4
     2 quota = i4
     2 updt_cnt = i4
     2 org_quota_id = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,20)
 SET reply->status_data.status = "F"
 SET quota_count = 0
 SELECT INTO "nl:"
  q.*
  FROM bbd_org_quota q
  WHERE (q.organization_id=request->organization_id)
   AND q.active_ind=1
  DETAIL
   quota_count = (quota_count+ 1)
   IF (mod(quota_count,20)=1
    AND quota_count != 1)
    stat = alterlist(reply->qual,(quota_count+ 20))
   ENDIF
   stat = alterlist(reply->qual,quota_count), reply->qual[quota_count].beg_effective_dt_tm = q
   .beg_effective_dt_tm, reply->qual[quota_count].end_effective_dt_tm = q.end_effective_dt_tm,
   reply->qual[quota_count].inhouse = q.inhouse, reply->qual[quota_count].mobile = q.mobile, reply->
   qual[quota_count].quota = q.quota,
   reply->qual[quota_count].updt_cnt = q.updt_cnt, reply->qual[quota_count].org_quota_id = q
   .org_quota_id, reply->qual[quota_count].active_ind = q.active_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,quota_count)
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
