CREATE PROGRAM dm_get_retention_day:dba
 RECORD reply(
   1 qual[*]
     2 criteria_type_cd = f8
     2 retention_days = i4
     2 encntr_type_cd = f8
     2 event_cd = f8
     2 apply_ind = i2
     2 last_apply_dt_tm = dq8
     2 parent_ret_criteria_id = f8
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
   WHERE (dr.organization_id=request->org_id)
    AND dr.encntr_type_cd > 0
    AND dr.active_ind=1
  ELSEIF ((request->criteriatype="P"))
   WHERE (dr.organization_id=request->org_id)
    AND dr.event_cd > 0
    AND dr.active_ind=1
  ELSE
  ENDIF
  INTO "nl:"
  dr.criteria_type_cd, dr.retention_days, dr.encntr_type_cd,
  dr.event_cd, dr.apply_ind, dr.last_apply_dt_tm,
  dr.parent_ret_criteria_id
  FROM dm_retention_criteria dr
  DETAIL
   index = (index+ 1), stat = alterlist(reply->qual,index), reply->qual[index].criteria_type_cd = dr
   .criteria_type_cd,
   reply->qual[index].retention_days = dr.retention_days, reply->qual[index].encntr_type_cd = dr
   .encntr_type_cd, reply->qual[index].event_cd = dr.event_cd,
   reply->qual[index].apply_ind = dr.apply_ind, reply->qual[index].last_apply_dt_tm = dr
   .last_apply_dt_tm, reply->qual[index].parent_ret_criteria_id = dr.parent_ret_criteria_id
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
