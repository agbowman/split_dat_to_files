CREATE PROGRAM dm_get_history_item:dba
 RECORD reply(
   1 qual[*]
     2 beg_effective = dq8
     2 end_effective = dq8
     2 encntr_type_cd = f8
     2 event_cd = f8
     2 retention_days = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET index = 0
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->criteriatype="A"))
   WHERE (drc.organization_id=request->org_id)
    AND drc.encntr_type_cd > 0
    AND (drc.criteria_type_cd=request->criteria_type_cd)
  ELSEIF ((request->criteriatype="P"))
   WHERE (drc.organization_id=request->org_id)
    AND drc.event_cd > 0
    AND (drc.criteria_type_cd=request->criteria_type_cd)
  ELSE
  ENDIF
  INTO "nl:"
  drc.beg_effective_dt_tm, drc.end_effective_dt_tm, drc.encntr_type_cd,
  drc.event_cd, drc.retention_days
  FROM dm_retention_criteria drc
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].beg_effective = drc
   .beg_effective_dt_tm,
   reply->qual[index].end_effective = drc.end_effective_dt_tm, reply->qual[index].encntr_type_cd =
   drc.encntr_type_cd, reply->qual[index].event_cd = drc.event_cd,
   reply->qual[index].retention_days = drc.retention_days
  WITH nocounter
 ;end select
 IF (index > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
