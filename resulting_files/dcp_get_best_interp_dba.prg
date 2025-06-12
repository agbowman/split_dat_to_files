CREATE PROGRAM dcp_get_best_interp:dba
 RECORD reply(
   1 dcp_interp_id = f8
   1 components[*]
     2 component_assay_cd = f8
     2 component_seq = i4
     2 description = vc
     2 flags = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE interp_id = f8 WITH public, noconstant(0)
 SET max_score = - (1)
 SET score = 0
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_interp i
  WHERE (i.task_assay_cd=request->task_assay_cd)
  DETAIL
   score = 0
   IF ((i.sex_cd=request->sex_cd))
    score = (score+ 8)
   ENDIF
   IF ((i.age_from_minutes <= request->age)
    AND (i.age_to_minutes >= request->age))
    score = (score+ 4)
   ENDIF
   IF ((i.service_resource_cd=request->service_resource_cd))
    score = (score+ 2)
   ENDIF
   IF (score > max_score)
    max_score = score, interp_id = i.dcp_interp_id
   ENDIF
  WITH nocounter
 ;end select
 SET reply->dcp_interp_id = interp_id
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_interp_component c
  WHERE c.dcp_interp_id=interp_id
  ORDER BY c.component_sequence
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->components,5))
    stat = alterlist(reply->components,(cnt+ 10))
   ENDIF
   reply->components[cnt].component_assay_cd = c.component_assay_cd, reply->components[cnt].
   component_seq = c.component_sequence, reply->components[cnt].description = c.description,
   reply->components[cnt].flags = c.flags
  WITH nocounter
 ;end select
 IF (interp_id=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->components,cnt)
END GO
