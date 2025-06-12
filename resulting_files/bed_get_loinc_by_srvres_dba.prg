CREATE PROGRAM bed_get_loinc_by_srvres:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 specimen_type_cd = f8
     2 specimen_type_disp = vc
     2 loinc_code = vc
     2 ignore_ind = i2
     2 concept_identifier_dta_id = f8
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE glb_code = f8 WITH protect, noconstant(0.0)
 DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE retrievehelixsrs(dummy=i2) = i2
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(106,"GLB",1,glb_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 IF (validate(request->activity_type_cd,0.0)=hlx_code)
  SET stat = retrievehelixsrs(0)
 ELSE
  SET count = 0
  SELECT INTO "nl:"
   FROM assay_processing_r apr,
    discrete_task_assay dta,
    profile_task_r ptr,
    collection_info_qualifiers ciq,
    concept_identifier_dta cid
   PLAN (apr
    WHERE (apr.service_resource_cd=request->service_resource_code_value)
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
    row + 0
   HEAD apr.task_assay_cd
    row + 0
   HEAD ciq.specimen_type_cd
    count = (count+ 1)
    IF (mod(count,100)=1)
     stat = alterlist(reply->codes,(count+ 99))
    ENDIF
    reply->codes[count].task_assay_cd = apr.task_assay_cd, reply->codes[count].specimen_type_cd = ciq
    .specimen_type_cd
   HEAD cid.concept_identifier_dta_id
    IF (cid.concept_identifier_dta_id > 0.0)
     IF ((request->code_type_ind IN (1, 2)))
      reply->codes[count].loinc_code = replace(cid.concept_cki,"LOINC!","",1)
     ENDIF
     reply->codes[count].concept_cki = cid.concept_cki, reply->codes[count].ignore_ind = cid
     .ignore_ind, reply->codes[count].concept_identifier_dta_id = cid.concept_identifier_dta_id
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
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->codes,count)
 SUBROUTINE retrievehelixsrs(dummy)
   CALL echo("IN RetrieveHelixSRs")
   SET count = 0
   SELECT INTO "nl:"
    service_resource_cd = apr.service_resource_cd, task_assay_cd = apr.task_assay_cd,
    specimen_type_cd = ciq.specimen_type_cd
    FROM assay_processing_r apr,
     discrete_task_assay dta,
     profile_task_r ptr,
     collection_info_qualifiers ciq
    WHERE (apr.service_resource_cd=request->service_resource_code_value)
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
      ucmr_case_step ucs,
      ucmr_workup_criteria uwc,
      collection_info_qualifiers ciq
     WHERE (apr.service_resource_cd=request->service_resource_code_value)
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
     row + 0
    HEAD task_assay_cd
     row + 0
    HEAD specimen_type_cd
     count = (count+ 1)
     IF (mod(count,100)=1)
      stat = alterlist(reply->codes,(count+ 99))
     ENDIF
     reply->codes[count].task_assay_cd = task_assay_cd, reply->codes[count].specimen_type_cd =
     specimen_type_cd
    DETAIL
     row + 0
    FOOT  specimen_type_cd
     row + 0
    FOOT  task_assay_cd
     row + 0
    FOOT  service_resource_cd
     row + 0
    WITH nocounter, rdbunion
   ;end select
   SET stat = alterlist(reply->codes,count)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(count)),
     concept_identifier_dta cid
    PLAN (d
     WHERE (reply->codes[d.seq].task_assay_cd > 0.0))
     JOIN (cid
     WHERE (cid.service_resource_cd=request->service_resource_code_value)
      AND (cid.task_assay_cd=reply->codes[d.seq].task_assay_cd)
      AND (cid.specimen_type_cd=reply->codes[d.seq].specimen_type_cd)
      AND (cid.concept_type_flag=request->code_type_ind)
      AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
      AND cid.active_ind=1)
    DETAIL
     IF (cid.concept_identifier_dta_id > 1)
      IF ((request->code_type_ind IN (1, 2)))
       reply->codes[d.seq].loinc_code = replace(cid.concept_cki,"LOINC!","",1)
      ENDIF
      reply->codes[d.seq].concept_cki = cid.concept_cki, reply->codes[d.seq].ignore_ind = cid
      .ignore_ind, reply->codes[d.seq].concept_identifier_dta_id = cid.concept_identifier_dta_id
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
 FREE RECORD check_existing
END GO
