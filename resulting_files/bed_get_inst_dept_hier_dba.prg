CREATE PROGRAM bed_get_inst_dept_hier:dba
 FREE SET reply
 RECORD reply(
   1 institutions[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
     2 departments[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
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
 SET alterlist_icnt = 0
 SET stat = alterlist(reply->institutions,50)
 SELECT INTO "nl:"
  FROM code_value cv1,
   resource_group rg,
   code_value cv2,
   service_resource sr
  PLAN (cv1
   WHERE cv1.code_set=221
    AND cv1.cdf_meaning="INSTITUTION"
    AND cv1.active_ind=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=cv1.code_value
    AND rg.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=rg.child_service_resource_cd
    AND cv2.cdf_meaning="DEPARTMENT"
    AND cv2.active_ind=1)
   JOIN (sr
   WHERE sr.service_resource_cd=rg.child_service_resource_cd
    AND (sr.discipline_type_cd=request->catalog_type_code_value)
    AND sr.active_ind=1)
  ORDER BY cv1.code_value
  HEAD cv1.code_value
   icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
   IF (alterlist_icnt > 50)
    stat = alterlist(reply->institutions,(icnt+ 50)), alterlist_icnt = 1
   ENDIF
   reply->institutions[icnt].code_value = cv1.code_value, reply->institutions[icnt].display = cv1
   .display, reply->institutions[icnt].description = cv1.description,
   dcnt = 0, alterlist_dcnt = 0, stat = alterlist(reply->institutions[icnt].departments,50)
  DETAIL
   dcnt = (dcnt+ 1), alterlist_dcnt = (alterlist_dcnt+ 1)
   IF (alterlist_dcnt > 50)
    stat = alterlist(reply->institutions[icnt].departments,(dcnt+ 50)), alterlist_dcnt = 1
   ENDIF
   reply->institutions[icnt].departments[dcnt].code_value = cv2.code_value, reply->institutions[icnt]
   .departments[dcnt].display = cv2.display, reply->institutions[icnt].departments[dcnt].description
    = cv2.description
  FOOT  cv1.code_value
   stat = alterlist(reply->institutions[icnt].departments,dcnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->institutions,icnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
