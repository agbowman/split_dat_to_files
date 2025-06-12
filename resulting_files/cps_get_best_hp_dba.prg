CREATE PROGRAM cps_get_best_hp:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 encntr_knt = i4
   1 encntr[*]
     2 encntr_id = f8
     2 health_plan_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET best_hp_id = 0.0
 SET reply->encntr_knt = 1
 SET stat = alterlist(reply->encntr,1)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM person_plan_reltn ppr
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ppr.priority_seq, ppr.beg_effective_dt_tm DESC, ppr.health_plan_id
  HEAD REPORT
   reply->encntr[1].health_plan_id = ppr.health_plan_id, best_hp_id = ppr.health_plan_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PLAN_RELTN"
  GO TO exit_script
 ENDIF
 IF ((request->encntr_knt < 1))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(request->encntr_knt)),
   encntr_plan_reltn epr
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=request->encntr[d.seq].encntr_id)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, epr.priority_seq, epr.beg_effective_dt_tm DESC,
   epr.health_plan_id
  HEAD REPORT
   stat = alterlist(reply->encntr,(request->encntr_knt+ 1))
  HEAD d.seq
   reply->encntr[(d.seq+ 1)].encntr_id = request->encntr[d.seq].encntr_id
   IF (epr.health_plan_id < 1)
    reply->encntr[(d.seq+ 1)].health_plan_id = best_hp_id
   ELSE
    reply->encntr[(d.seq+ 1)].health_plan_id = epr.health_plan_id
   ENDIF
  FOOT REPORT
   reply->encntr_knt = (request->encntr_knt+ 1), stat = alterlist(reply->encntr,(request->encntr_knt
    + 1))
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PLAN_RELTN"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->encntr_knt < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_versoin = "002 04/28/01 SF3151"
END GO
