CREATE PROGRAM bed_get_order_cat_by_serv_res:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 catalog_disp = vc
     2 sources[*]
       3 source_cd = f8
       3 source_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cat_cnt = i4 WITH protect, noconstant(0)
 DECLARE source_cnt = i4 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE general_lab = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 SET reply->status_data.status = "F"
 IF (size(request->resources,5) > 0)
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    orc_resource_list orl,
    collection_info_qualifiers ciq
   PLAN (oc
    WHERE oc.catalog_type_cd=general_lab
     AND (oc.activity_type_cd=request->activity_type_cd)
     AND oc.resource_route_lvl=1
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.mnemonic_type_cd=primary
     AND ocs.active_ind=1)
    JOIN (orl
    WHERE orl.catalog_cd=ocs.catalog_cd
     AND expand(idx,1,size(request->resources,5),orl.service_resource_cd,request->resources[idx].
     service_resource_cd)
     AND orl.active_ind=1
     AND orl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND orl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ciq
    WHERE ciq.catalog_cd=orl.catalog_cd
     AND ((ciq.service_resource_cd=orl.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
   ORDER BY oc.catalog_cd, ciq.specimen_type_cd
   HEAD oc.catalog_cd
    source_cnt = 0, cat_cnt = (cat_cnt+ 1)
    IF (mod(cat_cnt,10)=1)
     stat = alterlist(reply->qual,(cat_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].catalog_cd = oc.catalog_cd
   HEAD ciq.specimen_type_cd
    source_cnt = (source_cnt+ 1)
    IF (mod(source_cnt,10)=1)
     stat = alterlist(reply->qual[cat_cnt].sources,(source_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].sources[source_cnt].source_cd = ciq.specimen_type_cd
   DETAIL
    row + 0
   FOOT  ciq.specimen_type_cd
    row + 0
   FOOT  oc.catalog_cd
    stat = alterlist(reply->qual[cat_cnt].sources,source_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    profile_task_r ptr,
    assay_resource_list arl,
    collection_info_qualifiers ciq
   PLAN (oc
    WHERE oc.catalog_type_cd=general_lab
     AND (oc.activity_type_cd=request->activity_type_cd)
     AND oc.resource_route_lvl=2
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.mnemonic_type_cd=primary
     AND ocs.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=ocs.catalog_cd
     AND ptr.active_ind=1
     AND ptr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (arl
    WHERE arl.task_assay_cd=ptr.task_assay_cd
     AND expand(idx,1,size(request->resources,5),arl.service_resource_cd,request->resources[idx].
     service_resource_cd)
     AND arl.active_ind=1
     AND arl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND arl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (ciq
    WHERE ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd=arl.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
   ORDER BY oc.catalog_cd, ciq.specimen_type_cd
   HEAD oc.catalog_cd
    source_cnt = 0, cat_cnt = (cat_cnt+ 1)
    IF (mod(cat_cnt,10)=1)
     stat = alterlist(reply->qual,(cat_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].catalog_cd = oc.catalog_cd
   HEAD ciq.specimen_type_cd
    source_cnt = (source_cnt+ 1)
    IF (mod(source_cnt,10)=1)
     stat = alterlist(reply->qual[cat_cnt].sources,(source_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].sources[source_cnt].source_cd = ciq.specimen_type_cd
   DETAIL
    row + 0
   FOOT  ciq.specimen_type_cd
    row + 0
   FOOT  oc.catalog_cd
    stat = alterlist(reply->qual[cat_cnt].sources,source_cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    collection_info_qualifiers ciq
   PLAN (oc
    WHERE oc.catalog_type_cd=general_lab
     AND (oc.activity_type_cd=request->activity_type_cd)
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.mnemonic_type_cd=primary
     AND ocs.active_ind=1)
    JOIN (ciq
    WHERE ciq.catalog_cd=ocs.catalog_cd)
   ORDER BY oc.catalog_cd, ciq.specimen_type_cd
   HEAD oc.catalog_cd
    source_cnt = 0, cat_cnt = (cat_cnt+ 1)
    IF (mod(cat_cnt,10)=1)
     stat = alterlist(reply->qual,(cat_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].catalog_cd = oc.catalog_cd
   HEAD ciq.specimen_type_cd
    source_cnt = (source_cnt+ 1)
    IF (mod(source_cnt,10)=1)
     stat = alterlist(reply->qual[cat_cnt].sources,(source_cnt+ 9))
    ENDIF
    reply->qual[cat_cnt].sources[source_cnt].source_cd = ciq.specimen_type_cd
   DETAIL
    row + 0
   FOOT  ciq.specimen_type_cd
    row + 0
   FOOT  oc.catalog_cd
    stat = alterlist(reply->qual[cat_cnt].sources,source_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->qual,cat_cnt)
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO
