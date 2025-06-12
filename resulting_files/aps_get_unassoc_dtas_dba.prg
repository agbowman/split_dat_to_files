CREATE PROGRAM aps_get_unassoc_dtas:dba
 RECORD reply(
   1 task_qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE nprefixcnt = i2 WITH protect, noconstant(0)
 DECLARE dap = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"AP"))
 DECLARE dactivestatus = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dalphacode = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"2"))
 DECLARE nordercatalogexists = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.task_assay_disp, oc.catalog_cd,
  ptr.catalog_cd, order_catalog_exists = evaluate(nullind(oc.catalog_cd),1,0,1)
  FROM discrete_task_assay dta,
   profile_task_r ptr,
   order_catalog oc
  PLAN (dta
   WHERE dta.activity_type_cd=dap
    AND dta.default_result_type_cd=dalphacode
    AND dta.active_ind=1
    AND dta.active_status_cd=dactivestatus)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.active_ind=1
    AND ptr.active_status_cd=dactivestatus)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(ptr.catalog_cd)
    AND oc.catalog_cd != outerjoin(0)
    AND oc.active_ind=outerjoin(1))
  ORDER BY ptr.task_assay_cd
  HEAD ptr.task_assay_cd
   nordercatalogexists = 0
  DETAIL
   IF (order_catalog_exists=1)
    nordercatalogexists = 1
   ENDIF
  FOOT  ptr.task_assay_cd
   IF (nordercatalogexists=0)
    nprefixcnt = (nprefixcnt+ 1)
    IF (nprefixcnt > size(reply->task_qual,5))
     stat = alterlist(reply->task_qual,(nprefixcnt+ 9))
    ENDIF
    reply->task_qual[nprefixcnt].task_assay_cd = dta.task_assay_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->task_qual,nprefixcnt)
  WITH nocounter
 ;end select
 IF (nprefixcnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "discrete_task_assay"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
