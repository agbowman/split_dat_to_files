CREATE PROGRAM aps_get_db_processing_tasks:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = vc
     2 create_inventory_flag = i2
     2 task_type_flag = i2
     2 slide_origin_flag = i2
     2 stain_ind = i2
     2 half_slide_ind = i2
     2 print_label_ind = i2
     2 record_ind = i2
     2 date_of_service_cd = f8
     2 date_of_service_disp = vc
     2 updt_cnt = i4
     2 autoverify_workflow_cd = f8
     2 autoverify_workflow_disp = c40
     2 task_assay_type_cd = f8
     2 task_assay_type_disp = c40
     2 task_assay_type_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET process_cnt = 0
 SET type_where = fillstring(100," ")
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 0
 SET lab_catalog_type_cd = 0.0
 SET ap_activity_type_cd = 0.0
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 EXECUTE cpm_get_cd_for_cdf
 SET lab_catalog_type_cd = code_value
 SET code_set = 106
 SET cdf_meaning = "AP"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_activity_type_cd = code_value
 IF ((request->task_type_ind=0))
  SET type_where = " cv.cdf_meaning = 'APPROCESS'"
 ELSEIF ((request->task_type_ind=1))
  SET type_where = " cv.cdf_meaning = 'APBILLING'"
 ELSEIF ((request->task_type_ind=2))
  SET type_where = " cv.cdf_meaning = 'APPROCESS' or cv.cdf_meaning = 'APBILLING'"
 ENDIF
 SET stat = alterlist(reply->qual,1)
 SELECT INTO "nl:"
  dta.task_assay_cd
  FROM code_value cv,
   order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta,
   ap_task_assay_addl ataa
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.active_ind=1
    AND parser(type_where))
   JOIN (oc
   WHERE oc.catalog_type_cd=lab_catalog_type_cd
    AND oc.activity_type_cd=ap_activity_type_cd
    AND oc.activity_subtype_cd=cv.code_value
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
   JOIN (ataa
   WHERE (ataa.task_assay_cd= Outerjoin(dta.task_assay_cd)) )
  HEAD REPORT
   process_cnt = 0
  DETAIL
   process_cnt += 1, stat = alterlist(reply->qual,process_cnt), reply->qual[process_cnt].
   task_assay_cd = dta.task_assay_cd
   IF (ataa.task_assay_cd > 0.0)
    reply->qual[process_cnt].record_ind = 1
   ELSE
    reply->qual[process_cnt].record_ind = 0
   ENDIF
   reply->qual[process_cnt].print_label_ind = ataa.print_label_ind, reply->qual[process_cnt].
   create_inventory_flag = ataa.create_inventory_flag, reply->qual[process_cnt].task_type_flag = ataa
   .task_type_flag,
   reply->qual[process_cnt].slide_origin_flag = ataa.slide_origin_flag, reply->qual[process_cnt].
   stain_ind = ataa.stain_ind, reply->qual[process_cnt].half_slide_ind = ataa.half_slide_ind,
   reply->qual[process_cnt].date_of_service_cd = ataa.date_of_service_cd, reply->qual[process_cnt].
   updt_cnt = ataa.updt_cnt, reply->qual[process_cnt].autoverify_workflow_cd = ataa
   .autoverify_workflow_cd,
   reply->qual[process_cnt].task_assay_type_cd = ataa.task_assay_type_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,process_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DISCRETE_TASK_ASSAY"
  SET reply->status_data.status = "Z"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
