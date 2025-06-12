CREATE PROGRAM bbd_get_person_donor:dba
 RECORD reply(
   1 updt_cnt = i4
   1 lock_ind = i2
   1 eligibility_type_cd = f8
   1 eligibility_type_cd_disp = vc
   1 eligibility_type_cd_mean = vc
   1 currently_deferred = i2
   1 defer_until_dt_tm = di8
   1 elig_for_reinstate_ind = i2
   1 reinstated_ind = i2
   1 reinstated_dt_tm = di8
   1 watch_ind = i2
   1 watch_reason_cd = f8
   1 watch_reason_cd_mean = vc
   1 watch_reason_cd_disp = vc
   1 last_donation_dt_tm = di8
   1 updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  DETAIL
   reply->updt_cnt = p.updt_cnt, reply->lock_ind = p.lock_ind, reply->eligibility_type_cd = p
   .eligibility_type_cd
   IF (cnvtdatetime(curdate,curtime3) < p.defer_until_dt_tm)
    reply->currently_deferred = 1
   ELSE
    reply->currently_deferred = 0
   ENDIF
   reply->defer_until_dt_tm = p.defer_until_dt_tm, reply->elig_for_reinstate_ind = p
   .elig_for_reinstate_ind, reply->reinstated_ind = p.reinstated_ind,
   reply->reinstated_dt_tm = p.reinstated_dt_tm, reply->watch_ind = p.watch_ind, reply->
   watch_reason_cd = p.watch_reason_cd,
   reply->last_donation_dt_tm = p.last_donation_dt_tm, reply->updt_applctx = p.updt_applctx
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
