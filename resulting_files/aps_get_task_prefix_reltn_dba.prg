CREATE PROGRAM aps_get_task_prefix_reltn:dba
 RECORD reply(
   1 association_list[*]
     2 ap_prefix_task_r_id = f8
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = c60
     2 task_assay_mean = c12
     2 prefix_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE current_dt_tm_hold = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE ncount = i4 WITH protect, noconstant(0)
 DECLARE task_type_indicator = i2 WITH noconstant(0)
 DECLARE task_type_cd = f8 WITH noconstant(0.0)
 SET task_type_indicator = validate(request->task_type_ind,- (1))
 IF (task_type_indicator=1)
  SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,task_type_cd)
 ELSE
  SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,task_type_cd)
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  apptr.catalog_cd, oc.catalog_cd
  FROM ap_prefix_task_r apptr,
   order_catalog oc,
   profile_task_r ptr
  PLAN (apptr
   WHERE (apptr.prefix_id=request->prefix_id))
   JOIN (oc
   WHERE oc.catalog_cd=apptr.catalog_cd
    AND oc.activity_subtype_cd=task_type_cd
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1
    AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
  DETAIL
   ncount = (ncount+ 1)
   IF (ncount > size(reply->association_list,5))
    stat = alterlist(reply->association_list,(ncount+ 9))
   ENDIF
   reply->association_list[ncount].ap_prefix_task_r_id = apptr.ap_prefix_task_r_id, reply->
   association_list[ncount].task_assay_cd = ptr.task_assay_cd, reply->association_list[ncount].
   prefix_id = apptr.prefix_id
  FOOT REPORT
   stat = alterlist(reply->association_list,ncount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_TASK_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
