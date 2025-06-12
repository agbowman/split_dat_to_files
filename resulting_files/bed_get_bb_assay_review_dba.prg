CREATE PROGRAM bed_get_bb_assay_review:dba
 FREE SET reply
 RECORD reply(
   1 assays_checked[*]
     2 assay_code_value = f8
     2 review_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 assays[*]
     2 code_value = f8
     2 service_resources[*]
       3 code_value = f8
       3 reviewed_ind = i2
 )
 SET reply->status_data.status = "F"
 SET acnt = size(request->assays_to_check,5)
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->assays_checked,acnt)
 SET stat = alterlist(temp->assays,acnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = acnt)
  DETAIL
   reply->assays_checked[d.seq].assay_code_value = request->assays_to_check[d.seq].assay_code_value,
   reply->assays_checked[d.seq].review_ind = 0, temp->assays[d.seq].code_value = request->
   assays_to_check[d.seq].assay_code_value
  WITH nocounter
 ;end select
 FOR (a = 1 TO acnt)
   SET scnt = 0
   SELECT INTO "NL:"
    FROM discrete_task_assay dta,
     profile_task_r ptr,
     orc_resource_list orl,
     order_catalog oc
    PLAN (dta
     WHERE (dta.task_assay_cd=temp->assays[a].code_value))
     JOIN (ptr
     WHERE ptr.task_assay_cd=dta.task_assay_cd
      AND ptr.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1)
     JOIN (orl
     WHERE orl.catalog_cd=ptr.catalog_cd
      AND orl.service_resource_cd > 0
      AND orl.active_ind=1)
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(temp->assays[a].service_resources,scnt), temp->assays[a].
     service_resources[scnt].code_value = orl.service_resource_cd,
     temp->assays[a].service_resources[scnt].reviewed_ind = 0
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM discrete_task_assay dta,
     profile_task_r ptr,
     order_catalog oc,
     assay_processing_r apr
    PLAN (dta
     WHERE (dta.task_assay_cd=temp->assays[a].code_value))
     JOIN (ptr
     WHERE ptr.task_assay_cd=dta.task_assay_cd
      AND ptr.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.resource_route_lvl=2
      AND oc.active_ind=1)
     JOIN (apr
     WHERE apr.task_assay_cd=dta.task_assay_cd
      AND apr.service_resource_cd > 0
      AND apr.active_ind=1)
    DETAIL
     found = 0
     FOR (s = 1 TO scnt)
       IF ((temp->assays[a].service_resources[s].code_value=apr.service_resource_cd))
        found = 1, s = (scnt+ 1)
       ENDIF
     ENDFOR
     IF (found=0)
      scnt = (scnt+ 1), stat = alterlist(temp->assays[a].service_resources,scnt), temp->assays[a].
      service_resources[scnt].code_value = apr.service_resource_cd,
      temp->assays[a].service_resources[scnt].reviewed_ind = 0
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = acnt),
   reference_range_factor rrf
  PLAN (d)
   JOIN (rrf
   WHERE (rrf.task_assay_cd=temp->assays[d.seq].code_value)
    AND rrf.service_resource_cd=0
    AND rrf.active_ind=1)
  DETAIL
   reply->assays_checked[d.seq].review_ind = 1
  WITH nocounter
 ;end select
 FOR (a = 1 TO acnt)
   IF ((reply->assays_checked[a].review_ind=0))
    SET scnt = size(temp->assays[a].service_resources,5)
    IF (scnt > 0)
     IF ((request->is_numeric_review_ind=1))
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = scnt),
        reference_range_factor rrf,
        data_map dm
       PLAN (d)
        JOIN (rrf
        WHERE (rrf.task_assay_cd=temp->assays[a].code_value)
         AND (rrf.service_resource_cd=temp->assays[a].service_resources[d.seq].code_value)
         AND rrf.active_ind=1)
        JOIN (dm
        WHERE (dm.task_assay_cd=temp->assays[a].code_value)
         AND (dm.service_resource_cd=temp->assays[a].service_resources[d.seq].code_value)
         AND dm.data_map_type_flag=0
         AND dm.active_ind=1)
       DETAIL
        temp->assays[a].service_resources[d.seq].reviewed_ind = 1
       WITH nocounter
      ;end select
     ELSEIF ((request->is_numeric_review_ind=0))
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = scnt),
        reference_range_factor rrf,
        alpha_responses ar
       PLAN (d)
        JOIN (rrf
        WHERE (rrf.task_assay_cd=temp->assays[a].code_value)
         AND (rrf.service_resource_cd=temp->assays[a].service_resources[d.seq].code_value)
         AND rrf.active_ind=1)
        JOIN (ar
        WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
         AND ar.active_ind=1)
       DETAIL
        temp->assays[a].service_resources[d.seq].reviewed_ind = 1
       WITH nocounter
      ;end select
     ENDIF
     SET all_reviewed_ind = 1
     FOR (s = 1 TO scnt)
       IF ((temp->assays[a].service_resources[s].reviewed_ind=0))
        SET all_reviewed_ind = 0
        SET s = (scnt+ 1)
       ENDIF
     ENDFOR
     IF (all_reviewed_ind=1)
      SET reply->assays_checked[a].review_ind = 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
