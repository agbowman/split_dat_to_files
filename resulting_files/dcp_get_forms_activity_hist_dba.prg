CREATE PROGRAM dcp_get_forms_activity_hist:dba
 RECORD reply(
   1 qual[*]
     2 contributor_prsnl_id = f8
     2 contributor_prsnl_name = vc
     2 contributor_proxy_id = f8
     2 contributor_proxy_name = vc
     2 activity_dt_tm = dq8
     2 activity_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_forms_activity_prsnl fap,
   prsnl p
  PLAN (fap
   WHERE (fap.dcp_forms_activity_id=request->dcp_forms_activity_id))
   JOIN (p
   WHERE p.person_id=outerjoin(fap.proxy_id))
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].contributor_prsnl_id = fap.prsnl_id, reply->qual[cnt].contributor_prsnl_name =
   fap.prsnl_ft, reply->qual[cnt].contributor_proxy_id = fap.proxy_id,
   reply->qual[cnt].activity_dt_tm = fap.activity_dt_tm, reply->qual[cnt].activity_tz = fap
   .activity_tz, reply->qual[cnt].contributor_proxy_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (curqual)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
