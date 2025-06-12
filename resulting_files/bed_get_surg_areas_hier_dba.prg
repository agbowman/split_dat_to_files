CREATE PROGRAM bed_get_surg_areas_hier:dba
 FREE SET reply
 RECORD reply(
   1 institutions[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 departments[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 surgical_areas[*]
         4 code_value = f8
         4 display = vc
         4 description = vc
         4 staging_areas[*]
           5 code_value = f8
           5 display = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 500
 ENDIF
 DECLARE stageareaparse = vc
 SET stageareaparse = " cv3.active_ind = 1"
 IF ((request->search_string > " "))
  DECLARE search_txt = vc
  IF ((request->search_type_flag="S"))
   SET search_txt = build('"',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
  ELSE
   SET search_txt = build('"*',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
  ENDIF
  SET search_txt = cnvtupper(search_txt)
  SET stageareaparse = build(stageareaparse," and cv3.display_key = ",search_txt)
 ENDIF
 DECLARE instparse = vc
 SET instparse = " cv.active_ind = 1"
 IF ((request->institution_code_value > 0))
  SET instparse = build(instparse," and cv.code_value = ",trim(cnvtstring(request->
     institution_code_value)))
 ENDIF
 SET tot_stage_areas = 0
 SET icnt = 0
 SET dcnt = 0
 SET acnt = 0
 SET scnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   resource_group rg1,
   code_value cv1,
   resource_group rg2,
   code_value cv2,
   resource_group rg3,
   code_value cv3
  PLAN (cv
   WHERE parser(instparse)
    AND cv.code_set=221
    AND cv.cdf_meaning="INSTITUTION")
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
   WHERE parser(stageareaparse)
    AND cv3.code_value=rg3.child_service_resource_cd
    AND cv3.cdf_meaning="SURGSTAGE")
  ORDER BY cv.code_value, cv1.code_value, cv2.code_value
  HEAD cv.code_value
   icnt = (icnt+ 1), stat = alterlist(reply->institutions,icnt), reply->institutions[icnt].code_value
    = cv.code_value,
   reply->institutions[icnt].display = cv.display, reply->institutions[icnt].description = cv
   .description, dcnt = 0
  HEAD cv1.code_value
   dcnt = (dcnt+ 1), stat = alterlist(reply->institutions[icnt].departments,dcnt), reply->
   institutions[icnt].departments[dcnt].code_value = cv1.code_value,
   reply->institutions[icnt].departments[dcnt].display = cv1.display, reply->institutions[icnt].
   departments[dcnt].description = cv1.description, acnt = 0
  HEAD cv2.code_value
   acnt = (acnt+ 1), stat = alterlist(reply->institutions[icnt].departments[dcnt].surgical_areas,acnt
    ), reply->institutions[icnt].departments[dcnt].surgical_areas[acnt].code_value = cv2.code_value,
   reply->institutions[icnt].departments[dcnt].surgical_areas[acnt].display = cv2.display, reply->
   institutions[icnt].departments[dcnt].surgical_areas[acnt].description = cv2.description, scnt = 0
  DETAIL
   tot_stage_areas = (tot_stage_areas+ 1), scnt = (scnt+ 1), stat = alterlist(reply->institutions[
    icnt].departments[dcnt].surgical_areas[acnt].staging_areas,scnt),
   reply->institutions[icnt].departments[dcnt].surgical_areas[acnt].staging_areas[scnt].code_value =
   cv3.code_value, reply->institutions[icnt].departments[dcnt].surgical_areas[acnt].staging_areas[
   scnt].display = cv3.display, reply->institutions[icnt].departments[dcnt].surgical_areas[acnt].
   staging_areas[scnt].description = cv3.description
  WITH nocounter
 ;end select
 IF (tot_stage_areas > max_cnt)
  SET reply->too_many_results_ind = 1
  SET stat = alterlist(reply->institutions,0)
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
