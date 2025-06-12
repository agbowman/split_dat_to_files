CREATE PROGRAM bed_get_coll_check_all_rows:dba
 FREE SET reply
 RECORD reply(
   1 ord_with_only_all_rows_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ords(
   1 orderables[*]
     2 code_value = f8
     2 spectypes[*]
       3 code_value = f8
     2 servres[*]
       3 code_value = f8
 )
 RECORD coll(
   1 reqs[*]
     2 service_resource_cd = f8
 )
 SET reply->status_data.status = "F"
 SET reply->ord_with_only_all_rows_ind = 0
 SET ancillary_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ANCILLARY"
   AND cv.code_set=6011
   AND cv.active_ind=1
  DETAIL
   ancillary_cd = cv.code_value
  WITH nocounter
 ;end select
 SET glb_catalog_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="GENERAL LAB"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   glb_catalog_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET glb_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="GLB"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   glb_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ap_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="AP"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   ap_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET hla_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="HLA"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   hla_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(ords->orderables,50)
 SET alterlist_cnt = 0
 SET ocnt = 0
 IF ((request->activity_type="GLB"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=glb_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=glb_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="MICROBIOLOGY"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv,
    order_catalog_synonym ocs
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
     AND ocs.mnemonic_type_cd=outerjoin(ancillary_cd))
   ORDER BY oc.catalog_cd, ocs.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv,
    order_catalog_synonym ocs
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
     AND ocs.mnemonic_type_cd=outerjoin(ancillary_cd))
   ORDER BY oc.catalog_cd, ocs.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="AP"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=ap_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=ap_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="BB"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="HLA"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=hla_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_subtype_cd=request->activity_cd)
     AND oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=hla_activity_type_cd
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(ords->orderables,(ocnt+ 50)), alterlist_cnt = 1
    ENDIF
    ocnt = (ocnt+ 1), ords->orderables[ocnt].code_value = oc.catalog_cd
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_script
 ENDIF
 SET stat = alterlist(ords->orderables,ocnt)
 IF (ocnt=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ocnt),
   procedure_specimen_type pst,
   code_value cv
  PLAN (d)
   JOIN (pst
   WHERE (pst.catalog_cd=ords->orderables[d.seq].code_value))
   JOIN (cv
   WHERE cv.code_set=2052
    AND cv.code_value=pst.specimen_type_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   spcnt = 0
  DETAIL
   spcnt = (spcnt+ 1), stat = alterlist(ords->orderables[d.seq].spectypes,spcnt), ords->orderables[d
   .seq].spectypes[spcnt].code_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (o = 1 TO ocnt)
  SET spcnt = size(ords->orderables[o].spectypes,5)
  FOR (s = 1 TO spcnt)
    SET stat = alterlist(coll->reqs,50)
    SET alterlist_cnt = 0
    SET ccnt = 0
    SELECT INTO "NL:"
     FROM collection_info_qualifiers ciq
     WHERE (ciq.catalog_cd=ords->orderables[o].code_value)
      AND (ciq.specimen_type_cd=ords->orderables[o].spectypes[s].code_value)
     DETAIL
      alterlist_cnt = (alterlist_cnt+ 1)
      IF (alterlist_cnt > 50)
       stat = alterlist(coll->reqs,(ccnt+ 50)), alterlist_cnt = 1
      ENDIF
      ccnt = (ccnt+ 1), coll->reqs[ccnt].service_resource_cd = ciq.service_resource_cd
     WITH nocounter
    ;end select
    SET stat = alterlist(coll->reqs,ccnt)
    IF (ccnt > 0)
     SET non_all_row_found = 0
     FOR (c = 1 TO ccnt)
       IF ((coll->reqs[c].service_resource_cd > 0))
        SET non_all_row_found = 1
        SET c = (ccnt+ 1)
       ENDIF
     ENDFOR
     IF (non_all_row_found=0)
      SET reply->ord_with_only_all_rows_ind = 1
      SET reply->status_data.status = "S"
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
