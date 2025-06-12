CREATE PROGRAM bed_get_assay_expand_sr:dba
 FREE SET reply
 RECORD reply(
   1 service_resources[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET tot_count = 0
 IF ((request->assay.code_value=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM profile_task_r ptr,
   order_catalog oc,
   orc_resource_list orl,
   code_value cv
  PLAN (ptr
   WHERE ptr.active_ind=1
    AND (ptr.task_assay_cd=request->assay.code_value))
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1)
   JOIN (orl
   WHERE orl.active_ind=1
    AND orl.catalog_cd=ptr.catalog_cd
    AND orl.service_resource_cd > 0)
   JOIN (cv
   WHERE cv.code_value=orl.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY orl.service_resource_cd
  HEAD REPORT
   stat = alterlist(reply->service_resources,100)
  HEAD orl.service_resource_cd
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 100)
    stat = alterlist(reply->service_resources,(tot_count+ 100)), count = 1
   ENDIF
   reply->service_resources[tot_count].code_value = orl.service_resource_cd, reply->
   service_resources[tot_count].display = cv.display, reply->service_resources[tot_count].description
    = cv.description
  FOOT REPORT
   stat = alterlist(reply->service_resources,tot_count)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM profile_task_r ptr,
   order_catalog oc,
   assay_processing_r apr,
   code_value cv
  PLAN (ptr
   WHERE ptr.active_ind=1
    AND (ptr.task_assay_cd=request->assay.code_value))
   JOIN (oc
   WHERE oc.catalog_cd=ptr.catalog_cd
    AND oc.active_ind=1
    AND oc.resource_route_lvl=2)
   JOIN (apr
   WHERE apr.active_ind=1
    AND (apr.task_assay_cd=request->assay.code_value)
    AND apr.service_resource_cd > 0)
   JOIN (cv
   WHERE cv.code_value=apr.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY apr.service_resource_cd
  HEAD apr.service_resource_cd
   found = 0
   FOR (i = 1 TO tot_count)
     IF ((reply->service_resources[i].code_value=apr.service_resource_cd))
      found = 1, i = tot_count
     ENDIF
   ENDFOR
   IF (found=0)
    tot_count = (tot_count+ 1), stat = alterlist(reply->service_resources,tot_count), reply->
    service_resources[tot_count].code_value = apr.service_resource_cd,
    reply->service_resources[tot_count].display = cv.display, reply->service_resources[tot_count].
    description = cv.description
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
