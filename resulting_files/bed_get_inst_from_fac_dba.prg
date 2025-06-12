CREATE PROGRAM bed_get_inst_from_fac:dba
 FREE SET reply
 RECORD reply(
   1 institution_list[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET inst_count = 0
 SET inst_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=223
    AND c.cdf_meaning="INSTITUTION")
  DETAIL
   inst_cd = c.code_value
  WITH nocounter
 ;end select
 SET org_id = 0
 SELECT INTO "nl:"
  FROM location l
  PLAN (l
   WHERE (l.location_cd=request->facility_code_value)
    AND l.active_ind=1)
  DETAIL
   org_id = l.organization_id
  WITH nocounter
 ;end select
 IF (inst_cd > 0
  AND org_id > 0)
  SELECT INTO "nl:"
   FROM service_resource s,
    code_value cv
   PLAN (s
    WHERE s.service_resource_type_cd=inst_cd
     AND s.organization_id=org_id
     AND s.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1)
   DETAIL
    inst_count = (inst_count+ 1), stat = alterlist(reply->institution_list,inst_count), reply->
    institution_list[inst_count].code_value = s.service_resource_cd,
    reply->institution_list[inst_count].display = cv.display, reply->institution_list[inst_count].
    description = cv.description
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
