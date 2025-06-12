CREATE PROGRAM aps_get_db_reports:dba
 RECORD reply(
   1 rept_cntr = i4
   1 qual[*]
     2 catalog_cd = f8
     2 description = vc
     2 mnemonic = vc
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
 DECLARE dactivitysubtype = f8 WITH protect, constant(uar_get_code_by("MEANING",5801,"APREPORT"))
 DECLARE dgyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"GYN"))
 DECLARE dngyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"NGYN"))
 DECLARE ddefaultresulttype = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"2"))
 DECLARE nrepcnt = i4
 SET nrepcnt = 0
 IF ((reqinfo->updt_app=200031))
  SELECT DISTINCT INTO "nl:"
   o_catalog_disp = uar_get_code_display(o.catalog_cd), o.primary_mnemonic, o.description
   FROM prefix_report_r p,
    ap_prefix a,
    order_catalog o,
    profile_task_r ptr,
    discrete_task_assay dta
   PLAN (a
    WHERE a.case_type_cd IN (dgyn, dngyn)
     AND a.active_ind=1)
    JOIN (p
    WHERE a.prefix_id=p.prefix_id)
    JOIN (o
    WHERE o.catalog_cd=p.catalog_cd
     AND o.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1
     AND ptr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ptr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND ptr.active_ind=1
     AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND dta.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND dta.default_result_type_cd=ddefaultresulttype)
   DETAIL
    nrepcnt = (nrepcnt+ 1)
    IF (nrepcnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(nrepcnt+ 9))
    ENDIF
    reply->qual[nrepcnt].catalog_cd = o.catalog_cd, reply->qual[nrepcnt].description = o.description,
    reply->qual[nrepcnt].mnemonic = o.primary_mnemonic,
    reply->rept_cntr = nrepcnt
   FOOT REPORT
    stat = alterlist(reply->qual,nrepcnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   oc.catalog_cd, oc.primary_mnemonic, oc.description
   FROM order_catalog oc
   WHERE oc.activity_subtype_cd=dactivitysubtype
    AND oc.activity_subtype_cd != 0
    AND oc.active_ind=1
   DETAIL
    nrepcnt = (nrepcnt+ 1)
    IF (nrepcnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(nrepcnt+ 9))
    ENDIF
    reply->qual[nrepcnt].catalog_cd = oc.catalog_cd, reply->qual[nrepcnt].description = oc
    .description, reply->qual[nrepcnt].mnemonic = oc.primary_mnemonic,
    reply->rept_cntr = nrepcnt
   FOOT REPORT
    stat = alterlist(reply->qual,reply->rept_cntr)
   WITH nocounter
  ;end select
 ENDIF
 IF (nrepcnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
