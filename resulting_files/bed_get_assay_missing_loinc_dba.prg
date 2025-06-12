CREATE PROGRAM bed_get_assay_missing_loinc:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 missing_code_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET unique_assays
 RECORD unique_assays(
   1 assays[*]
     2 task_assay_cd = f8
     2 sr_spec_cnt = i4
 )
 FREE SET check_assays
 RECORD check_assays(
   1 list[*]
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 specimen_type_cd = f8
     2 unique_assay_ptr = i4
 )
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE bench_code = f8 WITH protect, noconstant(0.0)
 DECLARE inst_code = f8 WITH protect, noconstant(0.0)
 DECLARE ss_code = f8 WITH public, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
 DECLARE retrievehelixassays(dummy=i2) = i2
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(223,"BENCH",1,bench_code)
 SET stat = uar_get_meaning_by_codeset(223,"INSTRUMENT",1,inst_code)
 SET stat = uar_get_meaning_by_codeset(223,"SUBSECTION",1,ss_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 IF ((request->activity_type_code_value=hlx_code))
  SET stat = retrievehelixassays(0)
 ELSE
  SET count = 0
  SELECT INTO "nl:"
   FROM discrete_task_assay dta,
    assay_processing_r apr,
    service_resource sr,
    profile_task_r ptr,
    order_catalog oc,
    collection_info_qualifiers ciq,
    concept_identifier_dta cid
   PLAN (dta
    WHERE (dta.activity_type_cd=request->activity_type_code_value)
     AND dta.active_ind=1)
    JOIN (ptr
    WHERE ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ptr.catalog_cd
     AND (((oc.activity_subtype_cd=request->subactivity_type_code_value)) OR ((request->
    subactivity_type_code_value=- (1.0)))) )
    JOIN (apr
    WHERE apr.task_assay_cd=dta.task_assay_cd
     AND apr.active_ind=1)
    JOIN (sr
    WHERE sr.service_resource_cd=apr.service_resource_cd
     AND sr.active_ind=1
     AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code, ss_code)))
    JOIN (ciq
    WHERE ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd=apr.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
    JOIN (cid
    WHERE ((cid.service_resource_cd=apr.service_resource_cd
     AND cid.task_assay_cd=apr.task_assay_cd
     AND cid.specimen_type_cd=ciq.specimen_type_cd
     AND (cid.concept_type_flag=request->code_type_ind)
     AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
     AND cid.active_ind=1) OR (cid.service_resource_cd=0.0
     AND cid.task_assay_cd=0.0
     AND cid.specimen_type_cd=0.0)) )
   ORDER BY apr.task_assay_cd, apr.service_resource_cd, ciq.specimen_type_cd,
    cid.concept_identifier_dta_id
   HEAD apr.task_assay_cd
    ciq_cntr = 0, cid_cntr = 0, count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->assays,(count+ 9))
    ENDIF
    reply->assays[count].task_assay_cd = apr.task_assay_cd
   HEAD apr.service_resource_cd
    row + 0
   HEAD ciq.specimen_type_cd
    ciq_cntr = (ciq_cntr+ 1)
   HEAD cid.concept_identifier_dta_id
    IF (cid.concept_identifier_dta_id > 0.0)
     cid_cntr = (cid_cntr+ 1)
    ENDIF
   DETAIL
    row + 0
   FOOT  cid.concept_identifier_dta_id
    row + 0
   FOOT  ciq.specimen_type_cd
    row + 0
   FOOT  apr.service_resource_cd
    row + 0
   FOOT  apr.task_assay_cd
    IF (cid_cntr=ciq_cntr)
     reply->assays[count].missing_code_ind = 0
    ELSE
     reply->assays[count].missing_code_ind = 1
    ENDIF
   WITH counter
  ;end select
  SET stat = alterlist(reply->assays,count)
 ENDIF
 SUBROUTINE retrievehelixassays(dummy)
   DECLARE check_cnt = i4 WITH protect, noconstant(0)
   DECLARE count2 = i4 WITH protect, noconstant(0)
   SET count = 0
   SELECT INTO "nl:"
    task_assay_cd = apr.task_assay_cd, service_resource_cd = apr.service_resource_cd,
    specimen_type_cd = ciq.specimen_type_cd,
    catalog_cd = ciq.catalog_cd
    FROM discrete_task_assay dta,
     assay_processing_r apr,
     service_resource sr,
     profile_task_r ptr,
     collection_info_qualifiers ciq
    WHERE (dta.activity_type_cd=request->activity_type_code_value)
     AND dta.active_ind=1
     AND ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1
     AND apr.task_assay_cd=dta.task_assay_cd
     AND apr.active_ind=1
     AND sr.service_resource_cd=apr.service_resource_cd
     AND sr.active_ind=1
     AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code))
     AND ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd IN (apr.service_resource_cd, 0.0)) UNION (
    (SELECT INTO "nl:"
     task_assay_cd = apr.task_assay_cd, service_resource_cd = apr.service_resource_cd,
     specimen_type_cd = ciq.specimen_type_cd,
     catalog_cd = ciq.catalog_cd
     FROM discrete_task_assay dta,
      assay_processing_r apr,
      service_resource sr,
      profile_task_r ptr,
      ucmr_case_step ucs,
      ucmr_workup_criteria uwc,
      collection_info_qualifiers ciq
     WHERE (dta.activity_type_cd=request->activity_type_code_value)
      AND dta.active_ind=1
      AND ptr.task_assay_cd=dta.task_assay_cd
      AND ptr.active_ind=1
      AND apr.task_assay_cd=dta.task_assay_cd
      AND apr.active_ind=1
      AND sr.service_resource_cd=apr.service_resource_cd
      AND sr.active_ind=1
      AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code))
      AND ucs.case_step_cat_cd=ptr.catalog_cd
      AND ucs.active_ind=1
      AND ucs.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND uwc.ucmr_case_workup_id=ucs.ucmr_case_workup_id
      AND uwc.active_ind=1
      AND uwc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ciq.catalog_cd=uwc.catalog_cd
      AND ciq.service_resource_cd IN (apr.service_resource_cd, 0.0))))
    ORDER BY task_assay_cd, service_resource_cd, specimen_type_cd
    HEAD task_assay_cd
     count = (count+ 1), count2 = 0
     IF (count > size(unique_assays->assays,5))
      stat = alterlist(unique_assays->assays,(count+ 9)), stat = alterlist(reply->assays,(count+ 9))
     ENDIF
     unique_assays->assays[count].task_assay_cd = task_assay_cd, reply->assays[count].task_assay_cd
      = task_assay_cd, reply->assays[count].missing_code_ind = 1
    HEAD service_resource_cd
     row + 0
    HEAD specimen_type_cd
     row + 0
    DETAIL
     row + 0
    FOOT  specimen_type_cd
     check_cnt = (check_cnt+ 1)
     IF (check_cnt > size(check_assays->list,5))
      stat = alterlist(check_assays->list,(check_cnt+ 9))
     ENDIF
     check_assays->list[check_cnt].task_assay_cd = task_assay_cd, check_assays->list[check_cnt].
     service_resource_cd = service_resource_cd, check_assays->list[check_cnt].specimen_type_cd =
     specimen_type_cd,
     check_assays->list[check_cnt].unique_assay_ptr = count, count2 = (count2+ 1)
    FOOT  service_resource_cd
     row + 0
    FOOT  task_assay_cd
     unique_assays->assays[count].sr_spec_cnt = count2
    WITH nocounter, rdbunion
   ;end select
   SET stat = alterlist(check_assays->list,check_cnt)
   SET stat = alterlist(unique_assays->assays,count)
   SET stat = alterlist(reply->assays,count)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = check_cnt),
     concept_identifier_dta cid
    PLAN (d
     WHERE (check_assays->list[d.seq].task_assay_cd > 0.0))
     JOIN (cid
     WHERE (cid.service_resource_cd=check_assays->list[d.seq].service_resource_cd)
      AND (cid.task_assay_cd=check_assays->list[d.seq].task_assay_cd)
      AND (cid.specimen_type_cd=check_assays->list[d.seq].specimen_type_cd)
      AND (cid.concept_type_flag=request->code_type_ind)
      AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
      AND cid.active_ind=1)
    ORDER BY cid.task_assay_cd, cid.service_resource_cd, cid.specimen_type_cd,
     cid.concept_identifier_dta_id
    HEAD cid.task_assay_cd
     count = 0
    HEAD cid.service_resource_cd
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
    FOOT  cid.service_resource_cd
     row + 0
    FOOT  cid.task_assay_cd
     IF ((unique_assays->assays[check_assays->list[d.seq].unique_assay_ptr].sr_spec_cnt=count))
      reply->assays[check_assays->list[d.seq].unique_assay_ptr].missing_code_ind = 0
     ELSE
      reply->assays[check_assays->list[d.seq].unique_assay_ptr].missing_code_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
#exit_script
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 FREE RECORD check_assays
 FREE RECORD unique_assays
END GO
