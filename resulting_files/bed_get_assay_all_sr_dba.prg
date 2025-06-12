CREATE PROGRAM bed_get_assay_all_sr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assays[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = null
 DECLARE dta_parse = vc WITH protect, noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE tot_count = i4 WITH protect, noconstant(0)
 DECLARE max_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 10000
 ENDIF
 SET stat = alterlist(reply->assays,100)
 SET dta_parse = build("dta.active_ind = 1 and"," dta.activity_type_cd = ",request->
  activity_type_code_value)
 IF (validate(request->search_text,"") > " ")
  CALL populateparsestringbasedonrequest(0)
 ENDIF
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   profile_task_r ptr,
   orc_resource_list orl,
   order_catalog oc,
   data_map dm,
   alpha_responses ar
  PLAN (dta
   WHERE parser(dta_parse))
   JOIN (rrf
   WHERE rrf.active_ind=1
    AND rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.service_resource_cd=0)
   JOIN (dm
   WHERE dm.service_resource_cd=outerjoin(rrf.service_resource_cd)
    AND dm.task_assay_cd=outerjoin(rrf.task_assay_cd))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id))
   JOIN (ptr
   WHERE ptr.active_ind=1
    AND ptr.task_assay_cd=dta.task_assay_cd)
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=ptr.catalog_cd)
   JOIN (orl
   WHERE orl.active_ind=1
    AND orl.catalog_cd=ptr.catalog_cd
    AND orl.service_resource_cd > 0)
  ORDER BY dta.task_assay_cd
  HEAD dta.task_assay_cd
   IF (rrf.organism_cd=0
    AND rrf.gestational_ind=0
    AND rrf.unknown_age_ind=0
    AND rrf.sex_cd=0
    AND rrf.age_from_minutes=0
    AND rrf.age_to_minutes=78840000
    AND rrf.review_ind=0
    AND rrf.specimen_type_cd=0
    AND rrf.sensitive_ind=0
    AND rrf.normal_ind=0
    AND rrf.critical_ind=0
    AND rrf.units_cd=0
    AND rrf.def_result_ind=0
    AND rrf.linear_ind=0
    AND rrf.feasible_ind=0
    AND rrf.dilute_ind=0
    AND dm.task_assay_cd=0
    AND ar.reference_range_factor_id=0)
    count = count
   ELSE
    count = (count+ 1), tot_count = (tot_count+ 1)
    IF (count > 100)
     stat = alterlist(reply->assays,(tot_count+ 100)), count = 1
    ENDIF
    reply->assays[tot_count].code_value = dta.task_assay_cd, reply->assays[tot_count].display = dta
    .mnemonic, reply->assays[tot_count].description = dta.description
   ENDIF
  WITH maxqual(p,value((max_cnt+ 2))), nocounter
 ;end select
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   profile_task_r ptr,
   order_catalog oc,
   data_map dm,
   alpha_responses ar,
   assay_processing_r apr
  PLAN (dta
   WHERE parser(dta_parse))
   JOIN (ptr
   WHERE ptr.active_ind=1
    AND ptr.task_assay_cd=dta.task_assay_cd)
   JOIN (rrf
   WHERE rrf.active_ind=1
    AND rrf.task_assay_cd=dta.task_assay_cd
    AND rrf.service_resource_cd=0)
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=ptr.catalog_cd
    AND oc.resource_route_lvl=2)
   JOIN (apr
   WHERE apr.active_ind=1
    AND apr.task_assay_cd=dta.task_assay_cd
    AND apr.service_resource_cd > 0)
   JOIN (dm
   WHERE dm.service_resource_cd=outerjoin(rrf.service_resource_cd)
    AND dm.task_assay_cd=outerjoin(rrf.task_assay_cd))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(rrf.reference_range_factor_id))
  ORDER BY dta.task_assay_cd
  HEAD dta.task_assay_cd
   IF (rrf.organism_cd=0
    AND rrf.gestational_ind=0
    AND rrf.unknown_age_ind=0
    AND rrf.sex_cd=0
    AND rrf.age_from_minutes=0
    AND rrf.age_to_minutes=78840000
    AND rrf.review_ind=0
    AND rrf.specimen_type_cd=0
    AND rrf.sensitive_ind=0
    AND rrf.normal_ind=0
    AND rrf.critical_ind=0
    AND rrf.units_cd=0
    AND rrf.def_result_ind=0
    AND rrf.linear_ind=0
    AND rrf.feasible_ind=0
    AND rrf.dilute_ind=0
    AND dm.task_assay_cd=0
    AND ar.reference_range_factor_id=0)
    tot_count = tot_count
   ELSE
    found = 0
    FOR (i = 1 TO tot_count)
      IF ((reply->assays[i].code_value=dta.task_assay_cd))
       found = 1, i = tot_count
      ENDIF
    ENDFOR
    IF (found=0)
     tot_count = (tot_count+ 1), stat = alterlist(reply->assays,tot_count), reply->assays[tot_count].
     code_value = dta.task_assay_cd,
     reply->assays[tot_count].display = dta.mnemonic, reply->assays[tot_count].description = dta
     .description
    ENDIF
   ENDIF
  WITH maxqual(p,value((max_cnt+ 2))), nocounter
 ;end select
 IF (tot_count > max_cnt)
  SET stat = alterlist(reply->assays,0)
  SET reply->too_many_results_ind = 1
 ELSE
  SET stat = alterlist(reply->assays,tot_count)
 ENDIF
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   IF (validate(request->search_text,"") > " ")
    IF (validate(request->search_type,"") > " ")
     IF ((request->search_type IN ("S", "s"))
      AND (request->search_text > " "))
      SET dta_parse = concat(dta_parse," and cnvtupper(dta.mnemonic) = '",cnvtupper(trim(request->
         search_text)),"*'")
     ELSEIF ((request->search_type IN ("C", "c"))
      AND (request->search_text > " "))
      SET dta_parse = concat(dta_parse," and cnvtupper(dta.mnemonic) = '*",cnvtupper(trim(request->
         search_text)),"*'")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
