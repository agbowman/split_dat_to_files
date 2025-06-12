CREATE PROGRAM bed_get_rel_assay_sr:dba
 FREE SET reply
 RECORD reply(
   1 rel_list[*]
     2 sr_code_value = f8
     2 dta_code_value = f8
     2 dta_display = c40
     2 result_type_code_value = f8
     2 result_type_display = vc
     2 sequence = i4
     2 upload_alias = vc
     2 download_alias = vc
     2 download_ind = i2
     2 sr_display = vc
     2 sr_description = vc
     2 result_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET count = 0
 SET rec_cnt = size(request->sr_list,5)
 SET dta_cnt = size(request->assays,5)
 SET stat = alterlist(reply->rel_list,50)
 IF (rec_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = rec_cnt),
    assay_processing_r apr,
    code_value cv,
    profile_task_r ptr,
    order_catalog oc,
    orc_resource_list orl
   PLAN (d)
    JOIN (apr
    WHERE (apr.service_resource_cd=request->sr_list[d.seq].code_value)
     AND ((apr.active_ind=1) OR (apr.active_ind=0
     AND (request->include_inactive_child_ind=1))) )
    JOIN (cv
    WHERE cv.code_set=14003
     AND cv.code_value=apr.task_assay_cd
     AND cv.active_ind=1)
    JOIN (ptr
    WHERE ptr.active_ind=1
     AND ptr.task_assay_cd=apr.task_assay_cd)
    JOIN (oc
    WHERE oc.active_ind=1
     AND oc.catalog_cd=ptr.catalog_cd
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.active_ind=1
     AND orl.catalog_cd=ptr.catalog_cd
     AND (orl.service_resource_cd=request->sr_list[d.seq].code_value))
   ORDER BY apr.service_resource_cd, apr.display_sequence
   HEAD apr.task_assay_cd
    tot_count = (tot_count+ 1), count = (count+ 1)
    IF (count > 50)
     stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
    ENDIF
    reply->rel_list[tot_count].sr_code_value = request->sr_list[d.seq].code_value, reply->rel_list[
    tot_count].dta_code_value = apr.task_assay_cd, reply->rel_list[tot_count].result_type_code_value
     = apr.default_result_type_cd,
    reply->rel_list[tot_count].sequence = apr.display_sequence, reply->status_data.status = "S"
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = rec_cnt),
    assay_processing_r apr,
    code_value cv,
    profile_task_r ptr,
    order_catalog oc
   PLAN (d)
    JOIN (apr
    WHERE (apr.service_resource_cd=request->sr_list[d.seq].code_value)
     AND ((apr.active_ind=1) OR (apr.active_ind=0
     AND (request->include_inactive_child_ind=1))) )
    JOIN (cv
    WHERE cv.code_set=14003
     AND cv.code_value=apr.task_assay_cd
     AND cv.active_ind=1)
    JOIN (ptr
    WHERE ptr.active_ind=1
     AND ptr.task_assay_cd=apr.task_assay_cd)
    JOIN (oc
    WHERE oc.active_ind=1
     AND oc.catalog_cd=ptr.catalog_cd
     AND oc.resource_route_lvl=2)
   ORDER BY apr.service_resource_cd, apr.display_sequence
   HEAD apr.task_assay_cd
    found = 0
    FOR (i = 1 TO tot_count)
      IF ((reply->rel_list[i].sr_code_value=request->sr_list[d.seq].code_value)
       AND (reply->rel_list[i].dta_code_value=apr.task_assay_cd))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
     ENDIF
     reply->rel_list[tot_count].sr_code_value = request->sr_list[d.seq].code_value, reply->rel_list[
     tot_count].dta_code_value = apr.task_assay_cd, reply->rel_list[tot_count].result_type_code_value
      = apr.default_result_type_cd,
     reply->rel_list[tot_count].sequence = apr.display_sequence, reply->status_data.status = "S"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (dta_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = dta_cnt),
    assay_processing_r apr,
    code_value cv
   PLAN (d)
    JOIN (apr
    WHERE (apr.task_assay_cd=request->assays[d.seq].code_value)
     AND ((apr.active_ind=1) OR (apr.active_ind=0
     AND (request->include_inactive_child_ind=1))) )
    JOIN (cv
    WHERE cv.active_ind=1
     AND cv.code_value=apr.service_resource_cd)
   ORDER BY apr.service_resource_cd, apr.display_sequence
   DETAIL
    tot_count = (tot_count+ 1), count = (count+ 1)
    IF (count > 50)
     stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
    ENDIF
    reply->rel_list[tot_count].sr_code_value = apr.service_resource_cd, reply->rel_list[tot_count].
    dta_code_value = apr.task_assay_cd, reply->rel_list[tot_count].result_type_code_value = apr
    .default_result_type_cd,
    reply->rel_list[tot_count].sequence = apr.display_sequence, reply->status_data.status = "S"
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->rel_list,tot_count)
 IF (tot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->rel_list[d.seq].sr_code_value > 0))
    JOIN (cv
    WHERE cv.active_ind=1
     AND (cv.code_value=reply->rel_list[d.seq].sr_code_value))
   DETAIL
    reply->rel_list[d.seq].sr_display = cv.display, reply->rel_list[d.seq].sr_description = cv
    .description
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->rel_list[d.seq].result_type_code_value > 0))
    JOIN (cv
    WHERE cv.active_ind=1
     AND (cv.code_value=reply->rel_list[d.seq].result_type_code_value))
   DETAIL
    reply->rel_list[d.seq].result_type_display = cv.display, reply->rel_list[d.seq].result_type_mean
     = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    discrete_task_assay dta
   PLAN (d
    WHERE (reply->rel_list[d.seq].result_type_code_value > 0))
    JOIN (dta
    WHERE dta.active_ind=1
     AND (dta.task_assay_cd=reply->rel_list[d.seq].dta_code_value))
   DETAIL
    reply->rel_list[d.seq].dta_display = dta.mnemonic
   WITH nocounter
  ;end select
 ENDIF
#enditnow
 CALL echorecord(reply)
END GO
