CREATE PROGRAM bed_get_srvarea_departments:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 code_value = f8
     2 disp = vc
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE department = f8 WITH public, noconstant(0.0)
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT")
  DETAIL
   department = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   radiology = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 SELECT INTO "nl:"
  FROM service_resource sr,
   code_value cv
  PLAN (sr
   WHERE (sr.organization_id=request->organization_id)
    AND sr.service_resource_type_cd=department
    AND sr.discipline_type_cd=radiology
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD sr.service_resource_cd
   cnt = (cnt+ 1), stat = alterlist(reply->departments,cnt), reply->departments[cnt].code_value = sr
   .service_resource_cd,
   reply->departments[cnt].disp = cv.display, reply->departments[cnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (size(reply->departments,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
