CREATE PROGRAM bed_get_loinc_by_assay:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 task_assay_cd = f8
     2 task_assay_disp = vc
     2 sr_spec_list[*]
       3 service_resource_cd = f8
       3 service_resource_disp = vc
       3 specimen_type_cd = f8
       3 specimen_type_disp = vc
       3 loinc_code = vc
       3 ignore_ind = i2
       3 concept_identifier_dta_id = f8
       3 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET check_existing
 RECORD check_existing(
   1 list[*]
     2 task_assay_cd = f8
     2 service_resource_cd = f8
     2 specimen_type_cd = f8
     2 cnt_idx1 = i4
     2 cnt_idx2 = i4
 )
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE count2 = i4 WITH public, noconstant(0)
 DECLARE glb_code = f8 WITH public, noconstant(0.0)
 DECLARE hlx_code = f8 WITH public, noconstant(0.0)
 DECLARE bench_code = f8 WITH public, noconstant(0.0)
 DECLARE inst_code = f8 WITH public, noconstant(0.0)
 DECLARE ss_code = f8 WITH public, noconstant(0.0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE retrievehelixsrs(dummy=i2) = i2
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(106,"GLB",1,glb_code)
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 SET stat = uar_get_meaning_by_codeset(223,"BENCH",1,bench_code)
 SET stat = uar_get_meaning_by_codeset(223,"INSTRUMENT",1,inst_code)
 SET stat = uar_get_meaning_by_codeset(223,"SUBSECTION",1,ss_code)
 IF (validate(request->activity_type_cd,0.0)=hlx_code)
  SET stat = retrievehelixsrs(0)
 ELSE
  SET cur_size = size(request->assays,5)
  IF (cur_size < 100)
   SET batch_size = cur_size
  ELSE
   SET batch_size = 100
  ENDIF
  SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
  SET new_size = (loop_cnt * batch_size)
  SET nstart = 1
  SET stat = alterlist(request->assays,new_size)
  FOR (idx = (cur_size+ 1) TO new_size)
    SET request->assays[idx].code_value = request->assays[cur_size].code_value
  ENDFOR
  SET count = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_cnt)),
    assay_processing_r apr,
    discrete_task_assay dta,
    service_resource sr,
    profile_task_r ptr,
    collection_info_qualifiers ciq,
    concept_identifier_dta cid
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (apr
    WHERE expand(expand_idx,nstart,((nstart+ batch_size) - 1),apr.task_assay_cd,request->assays[
     expand_idx].code_value)
     AND apr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=apr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=glb_code)
     AND dta.active_ind=1)
    JOIN (sr
    WHERE (sr.service_resource_cd=(apr.service_resource_cd+ 0))
     AND sr.active_ind=1
     AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code, ss_code)))
    JOIN (ptr
    WHERE ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1)
    JOIN (ciq
    WHERE ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd=apr.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
    JOIN (cid
    WHERE ((cid.service_resource_cd=apr.service_resource_cd
     AND cid.task_assay_cd=apr.task_assay_cd
     AND cid.specimen_type_cd=ciq.specimen_type_cd
     AND (cid.concept_type_flag=request->code_type_ind)
     AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
     AND cid.active_ind=1) OR (cid.task_assay_cd=0.0
     AND cid.specimen_type_cd=0.0
     AND cid.service_resource_cd=0.0)) )
   ORDER BY apr.task_assay_cd, apr.service_resource_cd, ciq.specimen_type_cd,
    cid.concept_identifier_dta_id
   HEAD apr.task_assay_cd
    count2 = 0, count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->codes,(count+ 9))
    ENDIF
    reply->codes[count].task_assay_cd = apr.task_assay_cd
   HEAD apr.service_resource_cd
    row + 0
   HEAD ciq.specimen_type_cd
    count2 = (count2+ 1)
    IF (mod(count2,5)=1)
     stat = alterlist(reply->codes[count].sr_spec_list,(count2+ 4))
    ENDIF
    reply->codes[count].sr_spec_list[count2].service_resource_cd = apr.service_resource_cd, reply->
    codes[count].sr_spec_list[count2].specimen_type_cd = ciq.specimen_type_cd
   HEAD cid.concept_identifier_dta_id
    IF (cid.concept_identifier_dta_id > 1)
     IF ((request->code_type_ind IN (1, 2)))
      reply->codes[count].sr_spec_list[count2].loinc_code = replace(cid.concept_cki,"LOINC!","",1)
     ENDIF
     reply->codes[count].sr_spec_list[count2].concept_cki = cid.concept_cki, reply->codes[count].
     sr_spec_list[count2].ignore_ind = cid.ignore_ind, reply->codes[count].sr_spec_list[count2].
     concept_identifier_dta_id = cid.concept_identifier_dta_id
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
    stat = alterlist(reply->codes[count].sr_spec_list,count2)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->codes,count)
 SUBROUTINE retrievehelixsrs(dummy)
   CALL echo("IN RetrieveHelixSRs")
   SET count = size(reply->codes,5)
   SET idx = 0
   SELECT INTO "nl:"
    task_assay_cd = apr.task_assay_cd, service_resource_cd = apr.service_resource_cd,
    specimen_type_cd = ciq.specimen_type_cd
    FROM assay_processing_r apr,
     discrete_task_assay dta,
     service_resource sr,
     profile_task_r ptr,
     collection_info_qualifiers ciq
    WHERE expand(expand_idx,1,size(request->assays,5),apr.task_assay_cd,request->assays[expand_idx].
     code_value)
     AND apr.active_ind=1
     AND dta.task_assay_cd=apr.task_assay_cd
     AND ((dta.activity_type_cd+ 0)=request->activity_type_cd)
     AND dta.active_ind=1
     AND (sr.service_resource_cd=(apr.service_resource_cd+ 0))
     AND sr.active_ind=1
     AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code))
     AND ptr.task_assay_cd=dta.task_assay_cd
     AND ptr.active_ind=1
     AND ciq.catalog_cd=ptr.catalog_cd
     AND ((ciq.service_resource_cd IN (apr.service_resource_cd, 0.0)) UNION (
    (SELECT INTO "nl:"
     task_assay_cd = apr.task_assay_cd, service_resource_cd = apr.service_resource_cd,
     specimen_type_cd = ciq.specimen_type_cd
     FROM assay_processing_r apr,
      discrete_task_assay dta,
      service_resource sr,
      profile_task_r ptr,
      ucmr_case_step ucs,
      ucmr_workup_criteria uwc,
      collection_info_qualifiers ciq
     WHERE expand(expand_idx,1,size(request->assays,5),apr.task_assay_cd,request->assays[expand_idx].
      code_value)
      AND apr.active_ind=1
      AND dta.task_assay_cd=apr.task_assay_cd
      AND ((dta.activity_type_cd+ 0)=request->activity_type_cd)
      AND dta.active_ind=1
      AND (sr.service_resource_cd=(apr.service_resource_cd+ 0))
      AND sr.active_ind=1
      AND ((sr.service_resource_type_cd+ 0) IN (inst_code, bench_code))
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
    ORDER BY task_assay_cd, service_resource_cd, specimen_type_cd
    HEAD task_assay_cd
     count2 = 0, count = (count+ 1)
     IF (mod(count,10)=1)
      stat = alterlist(reply->codes,(count+ 9))
     ENDIF
     reply->codes[count].task_assay_cd = apr.task_assay_cd
    HEAD service_resource_cd
     row + 0
    HEAD specimen_type_cd
     count2 = (count2+ 1)
     IF (mod(count2,5)=1)
      stat = alterlist(reply->codes[count].sr_spec_list,(count2+ 4))
     ENDIF
     reply->codes[count].sr_spec_list[count2].service_resource_cd = apr.service_resource_cd, reply->
     codes[count].sr_spec_list[count2].specimen_type_cd = ciq.specimen_type_cd, idx = (idx+ 1)
     IF (idx > size(check_existing->list,5))
      stat = alterlist(check_existing->list,(idx+ 9))
     ENDIF
     check_existing->list[idx].task_assay_cd = apr.task_assay_cd, check_existing->list[idx].
     service_resource_cd = apr.service_resource_cd, check_existing->list[idx].specimen_type_cd = ciq
     .specimen_type_cd,
     check_existing->list[idx].cnt_idx1 = count, check_existing->list[idx].cnt_idx2 = count2
    DETAIL
     row + 0
    FOOT  specimen_type_cd
     row + 0
    FOOT  service_resource_cd
     row + 0
    FOOT  task_assay_cd
     stat = alterlist(reply->codes[count].sr_spec_list,count2)
    WITH nocounter, rdbunion
   ;end select
   SET stat = alterlist(check_existing->list,idx)
   SET stat = alterlist(reply->codes,count)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(idx)),
     concept_identifier_dta cid
    PLAN (d
     WHERE (check_existing->list[d.seq].service_resource_cd > 0.0))
     JOIN (cid
     WHERE (cid.service_resource_cd=check_existing->list[d.seq].service_resource_cd)
      AND (cid.task_assay_cd=check_existing->list[d.seq].task_assay_cd)
      AND (cid.specimen_type_cd=check_existing->list[d.seq].specimen_type_cd)
      AND (cid.concept_type_flag=request->code_type_ind)
      AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
      AND cid.active_ind=1)
    DETAIL
     IF (cid.concept_identifier_dta_id > 1)
      count = check_existing->list[d.seq].cnt_idx1, count2 = check_existing->list[d.seq].cnt_idx2
      IF ((request->code_type_ind IN (1, 2)))
       reply->codes[count].sr_spec_list[count2].loinc_code = replace(cid.concept_cki,"LOINC!","",1)
      ENDIF
      reply->codes[count].sr_spec_list[count2].concept_cki = cid.concept_cki, reply->codes[count].
      sr_spec_list[count2].ignore_ind = cid.ignore_ind, reply->codes[count].sr_spec_list[count2].
      concept_identifier_dta_id = cid.concept_identifier_dta_id
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
 FREE RECORD check_existing
END GO
