CREATE PROGRAM acm_get_last_cmb_activity:dba
 RECORD reply(
   1 last_activity_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET table_name = curprog
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  pc.updt_dt_tm
  FROM person_combine pc
  WHERE (((pc.to_person_id=request->person_id)) OR ((pc.from_person_id=request->person_id)))
  FOOT REPORT
   reply->last_activity_dt_tm = cnvtdatetime(max(pc.updt_dt_tm))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ec.updt_dt_tm
  FROM encounter e,
   encntr_combine ec
  PLAN (e
   WHERE (e.person_id=request->person_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ec
   WHERE ec.to_encntr_id=e.encntr_id)
  FOOT REPORT
   reply->last_activity_dt_tm = maxval(reply->last_activity_dt_tm,cnvtdatetime(max(ec.updt_dt_tm)))
  WITH nocounter
 ;end select
 IF ((reply->last_activity_dt_tm=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
