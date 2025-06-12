CREATE PROGRAM bed_get_rad_dept:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 dept_name = vc
     2 dept_cd = f8
     2 organization_id = f8
     2 facility_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE department = f8 WITH public, noconstant(0.0)
 DECLARE radexamroom = f8 WITH public, noconstant(0.0)
 DECLARE radiology = f8 WITH public, noconstant(0.0)
 DECLARE facility = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="DEPARTMENT"
    AND cv.active_ind=1)
  DETAIL
   department = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="RADEXAMROOM"
    AND cv.active_ind=1)
  DETAIL
   radexamroom = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   radiology = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1)
  DETAIL
   facility = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM service_resource sr,
   code_value cv,
   resource_group rg,
   resource_group rg2,
   resource_group rg3,
   service_resource sr2
  PLAN (sr
   WHERE sr.service_resource_type_cd=department
    AND ((sr.discipline_type_cd+ 0)=radiology)
    AND ((sr.active_ind+ 0)=1))
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=sr.service_resource_cd
    AND rg.active_ind=1)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg.child_service_resource_cd
    AND rg2.active_ind=1)
   JOIN (rg3
   WHERE rg3.parent_service_resource_cd=rg2.child_service_resource_cd
    AND rg3.active_ind=1)
   JOIN (sr2
   WHERE sr2.service_resource_cd=rg3.child_service_resource_cd
    AND ((sr2.service_resource_type_cd+ 0)=radexamroom)
    AND ((sr2.active_ind+ 0)=1))
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  HEAD sr.service_resource_cd
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].dept_name = cv.display,
   reply->qual[cnt].dept_cd = sr.service_resource_cd, reply->qual[cnt].organization_id = sr
   .organization_id
  WITH nocounter
 ;end select
 SET cnt = size(reply->qual,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    location l,
    code_value cv
   PLAN (d)
    JOIN (l
    WHERE (l.organization_id=reply->qual[d.seq].organization_id)
     AND l.location_type_cd=facility
     AND l.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->qual[d.seq].facility_name = cv.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->qual,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
