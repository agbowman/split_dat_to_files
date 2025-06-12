CREATE PROGRAM bed_get_inst_with_surg_areas:dba
 FREE SET reply
 RECORD reply(
   1 institutions[*]
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
 SET icnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   resource_group rg1,
   code_value cv1,
   resource_group rg2,
   code_value cv2,
   resource_group rg3,
   code_value cv3
  PLAN (cv
   WHERE cv.code_set=221
    AND cv.cdf_meaning="INSTITUTION"
    AND cv.active_ind=1)
   JOIN (rg1
   WHERE rg1.parent_service_resource_cd=cv.code_value
    AND rg1.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=rg1.child_service_resource_cd
    AND cv1.cdf_meaning="DEPARTMENT"
    AND cv1.active_ind=1)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=cv1.code_value
    AND rg2.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=rg2.child_service_resource_cd
    AND cv2.cdf_meaning="SURGAREA"
    AND cv2.active_ind=1)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=cv2.code_value
    AND rg3.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=rg3.child_service_resource_cd
    AND cv3.cdf_meaning="SURGSTAGE"
    AND cv3.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   icnt = (icnt+ 1), stat = alterlist(reply->institutions,icnt), reply->institutions[icnt].code_value
    = cv.code_value,
   reply->institutions[icnt].display = cv.display, reply->institutions[icnt].description = cv
   .description
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
