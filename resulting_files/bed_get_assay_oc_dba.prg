CREATE PROGRAM bed_get_assay_oc:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 display = c40
     2 description = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->assays,50)
 SET alist_count = 0
 SET tot_alist = 0
 SELECT INTO "NL:"
  FROM profile_task_r ptr,
   discrete_task_assay dta,
   order_catalog oc
  PLAN (oc
   WHERE oc.active_ind=1
    AND (oc.activity_type_cd=request->activity_type_code_value))
   JOIN (ptr
   WHERE ptr.active_ind=1
    AND ptr.catalog_cd=oc.catalog_cd)
   JOIN (dta
   WHERE dta.active_ind=1
    AND dta.task_assay_cd=ptr.task_assay_cd)
  ORDER BY dta.task_assay_cd
  HEAD dta.task_assay_cd
   alist_count = (alist_count+ 1), tot_alist = (tot_alist+ 1)
   IF (alist_count > 50)
    stat = alterlist(reply->assays,(tot_alist+ 50))
   ENDIF
   reply->assays[tot_alist].code_value = dta.task_assay_cd, reply->assays[tot_alist].display = dta
   .mnemonic, reply->assays[tot_alist].description = dta.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->assays,tot_alist)
#enditnow
 IF (tot_alist > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
