CREATE PROGRAM bed_get_srv_res_missing_loinc:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 service_resources[*]
     2 code_value = f8
     2 missing_code_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET unique_resources
 RECORD unique_resources(
   1 service_resources[*]
     2 code_value = f8
     2 sr_spec_cnt = i4
 )
 RECORD check_resources(
   1 list[*]
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 specimen_type_cd = f8
     2 unique_resource_ptr = i4
 )
 DECLARE index = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE glb_code = f8 WITH public, noconstant(0.0)
 DECLARE hlx_code = f8 WITH public, noconstant(0.0)
 DECLARE error_check = i2 WITH public, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE retrievehelixsrs(dummy=i2) = i2
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(106,"GLB",1,glb_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 IF (validate(request->activity_type_cd,0.0)=hlx_code)
  SET stat = retrievehelixsrs(0)
 ELSE
  SET cur_size = size(request->service_resources,5)
  IF (cur_size < 50)
   SET batch_size = cur_size
  ELSE
   SET batch_size = 50
  ENDIF
  SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
  SET new_size = (loop_cnt * batch_size)
  SET nstart = 1
  SET stat = alterlist(request->service_resources,new_size)
  FOR (idx = (cur_size+ 1) TO new_size)
    SET request->service_resources[idx].code_value = request->service_resources[cur_size].code_value
  ENDFOR
  SET count = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    assay_processing_r apr,
    discrete_task_assay dta,
    profile_task_r ptr,
    collection_info_qualifiers ciq,
    concept_identifier_dta cid
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (apr
    WHERE expand(expand_idx,nstart,((nstart+ batch_size) - 1),apr.service_resource_cd,request->
     service_resources[expand_idx].code_value)
     AND apr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=apr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=glb_code)
     AND dta.active_ind=1)
    JOIN (ptr
    WHERE ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1)
    JOIN (ciq
    WHERE ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd=apr.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
    JOIN (cid
    WHERE ((cid.task_assay_cd=apr.task_assay_cd
     AND cid.specimen_type_cd=ciq.specimen_type_cd
     AND cid.service_resource_cd=apr.service_resource_cd
     AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
     AND (cid.concept_type_flag=request->code_type_ind)
     AND cid.active_ind=1) OR (cid.task_assay_cd=0.0
     AND cid.specimen_type_cd=0.0
     AND cid.service_resource_cd=0.0)) )
   ORDER BY apr.service_resource_cd, apr.task_assay_cd, ciq.specimen_type_cd,
    cid.concept_identifier_dta_id
   HEAD apr.service_resource_cd
    ciq_cntr = 0, cid_cntr = 0, count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->service_resources,(count+ 9))
    ENDIF
    reply->service_resources[count].code_value = apr.service_resource_cd
   HEAD apr.task_assay_cd
    row + 0
   HEAD ciq.specimen_type_cd
    ciq_cntr = (ciq_cntr+ 1)
   HEAD cid.concept_identifier_dta_id
    IF (cid.concept_identifier_dta_id > 0)
     cid_cntr = (cid_cntr+ 1)
    ENDIF
   DETAIL
    row + 0
   FOOT  cid.concept_identifier_dta_id
    row + 0
   FOOT  ciq.specimen_type_cd
    row + 0
   FOOT  apr.task_assay_cd
    row + 0
   FOOT  apr.service_resource_cd
    IF (cid_cntr=ciq_cntr)
     reply->service_resources[count].missing_code_ind = 0
    ELSE
     reply->service_resources[count].missing_code_ind = 1
    ENDIF
   WITH counter
  ;end select
  SET stat = alterlist(reply->service_resources,count)
 ENDIF
 SUBROUTINE retrievehelixsrs(dummy)
   DECLARE check_cnt = i4 WITH protect, noconstant(0)
   DECLARE count2 = i4 WITH protect, noconstant(0)
   CALL echo("*** IN RetrieveHelixSRs ***")
   SELECT INTO "nl:"
    service_resource_cd = apr.service_resource_cd, task_assay_cd = apr.task_assay_cd,
    specimen_type_cd = ciq.specimen_type_cd
    FROM assay_processing_r apr,
     discrete_task_assay dta,
     profile_task_r ptr,
     collection_info_qualifiers ciq
    WHERE expand(expand_idx,1,size(request->service_resources,5),apr.service_resource_cd,request->
     service_resources[expand_idx].code_value)
     AND apr.active_ind=1
     AND dta.task_assay_cd=apr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=request->activity_type_cd)
     AND dta.active_ind=1
     AND ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1
     AND ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd IN (apr.service_resource_cd, 0.0)) UNION (
    (SELECT INTO "nl:"
     service_resource_cd = apr.service_resource_cd, task_assay_cd = apr.task_assay_cd,
     specimen_type_cd = ciq.specimen_type_cd
     FROM assay_processing_r apr,
      discrete_task_assay dta,
      profile_task_r ptr,
      collection_info_qualifiers ciq,
      ucmr_case_step ucs,
      ucmr_workup_criteria uwc
     WHERE expand(expand_idx,1,size(request->service_resources,5),apr.service_resource_cd,request->
      service_resources[expand_idx].code_value)
      AND apr.active_ind=1
      AND dta.task_assay_cd=apr.task_assay_cd
      AND ((dta.activity_type_cd+ 0)=request->activity_type_cd)
      AND dta.active_ind=1
      AND ptr.task_assay_cd=dta.task_assay_cd
      AND ptr.active_ind=1
      AND ucs.case_step_cat_cd=ptr.catalog_cd
      AND ucs.active_ind=1
      AND ucs.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND uwc.ucmr_case_workup_id=ucs.ucmr_case_workup_id
      AND uwc.active_ind=1
      AND uwc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ciq.catalog_cd=uwc.catalog_cd
      AND ciq.service_resource_cd IN (apr.service_resource_cd, 0.0))))
    ORDER BY service_resource_cd, task_assay_cd, specimen_type_cd
    HEAD service_resource_cd
     count = (count+ 1), count2 = 0
     IF (count > size(unique_resources->service_resources,5))
      stat = alterlist(unique_resources->service_resources,(count+ 9)), stat = alterlist(reply->
       service_resources,(count+ 9))
     ENDIF
     unique_resources->service_resources[count].code_value = service_resource_cd, reply->
     service_resources[count].code_value = service_resource_cd, reply->service_resources[count].
     missing_code_ind = 1
    HEAD task_assay_cd
     row + 0
    HEAD specimen_type_cd
     row + 0
    DETAIL
     row + 0
    FOOT  specimen_type_cd
     check_cnt = (check_cnt+ 1)
     IF (check_cnt > size(check_resources->list,5))
      stat = alterlist(check_resources->list,(check_cnt+ 9))
     ENDIF
     check_resources->list[check_cnt].task_assay_cd = task_assay_cd, check_resources->list[check_cnt]
     .service_resource_cd = service_resource_cd, check_resources->list[check_cnt].specimen_type_cd =
     specimen_type_cd,
     check_resources->list[check_cnt].unique_resource_ptr = count, count2 = (count2+ 1)
    FOOT  task_assay_cd
     row + 0
    FOOT  service_resource_cd
     unique_resources->service_resources[count].sr_spec_cnt = count2
    WITH nocounter, rdbunion
   ;end select
   SET stat = alterlist(check_resources->list,check_cnt)
   SET stat = alterlist(unique_resources->service_resources,count)
   SET stat = alterlist(reply->service_resources,count)
   CALL echorecord(check_resources)
   CALL echorecord(unique_resources)
   CALL echorecord(reply)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = check_cnt),
     concept_identifier_dta cid
    PLAN (d
     WHERE (check_resources->list[d.seq].service_resource_cd > 0.0))
     JOIN (cid
     WHERE (cid.service_resource_cd=check_resources->list[d.seq].service_resource_cd)
      AND (cid.task_assay_cd=check_resources->list[d.seq].task_assay_cd)
      AND (cid.specimen_type_cd=check_resources->list[d.seq].specimen_type_cd)
      AND (cid.concept_type_flag=request->code_type_ind)
      AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
      AND cid.active_ind=1)
    ORDER BY cid.service_resource_cd, cid.task_assay_cd, cid.specimen_type_cd,
     cid.concept_identifier_dta_id
    HEAD cid.service_resource_cd
     count = 0
    HEAD cid.task_assay_cd
     row + 0
    HEAD cid.specimen_type_cd
     row + 0
    HEAD cid.concept_identifier_dta_id
     IF (cid.concept_identifier_dta_id > 0.0)
      count = (count+ 1)
     ENDIF
    DETAIL
     row + 0
    FOOT  cid.concept_identifier_dta_id
     row + 0
    FOOT  cid.specimen_type_cd
     row + 0
    FOOT  cid.task_assay_cd
     row + 0
    FOOT  cid.service_resource_cd
     IF ((unique_resources->service_resources[check_resources->list[d.seq].unique_resource_ptr].
     sr_spec_cnt=count))
      reply->service_resources[check_resources->list[d.seq].unique_resource_ptr].missing_code_ind = 0
     ELSE
      reply->service_resources[check_resources->list[d.seq].unique_resource_ptr].missing_code_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
