CREATE PROGRAM dcp_get_encntrid_from_alias:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   (dummyt d  WITH seq = size(request->qual,5))
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias_pool_cd=request->qual[d.seq].alias_pool_cd)
    AND (ea.alias=request->alias)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].person_id = e.person_id, reply->qual[count].encntr_id = ea.encntr_id
  WITH nocounter
 ;end select
 SET reply->status_data.status = "Z"
 SET stat = alterlist(reply->qual,count)
END GO
