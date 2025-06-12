CREATE PROGRAM bed_get_sr_detail:dba
 FREE SET reply
 RECORD reply(
   1 service_resources[*]
     2 code_value = f8
     2 assay_need_seq_ind = i2
     2 assay_need_result_type_ind = i2
     2 assay_need_alpha_ind = i2
     2 assay_need_numeric_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = size(request->service_resources,5)
 SET stat = alterlist(reply->service_resources,scnt)
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET alpha_type = 0.0
 SET numeric_type = 0.0
 SET calc_type = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.cdf_meaning IN ("8", "3", "2")
   AND cv.code_set=289
  DETAIL
   CASE (cv.cdf_meaning)
    OF "8":
     calc_type = cv.code_value
    OF "3":
     numeric_type = cv.code_value
    OF "2":
     alpha_type = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 DECLARE dta_ptr_parse = vc WITH protect, noconstant(
  "dta.task_assay_cd = ptr.task_assay_cd and dta.active_ind = 1")
 DECLARE dta_apr_parse = vc WITH protect, noconstant(
  "dta.task_assay_cd = apr.task_assay_cd and dta.active_ind = 1")
 DECLARE dacttypecd = f8 WITH protect, constant(validate(request->activity_type_cd,0))
 DECLARE dta_act_type_parse = vc WITH protect, constant(" and dta.activity_type_cd+0 = dActTypeCd")
 IF (dacttypecd > 0)
  SET dta_ptr_parse = concat(dta_ptr_parse,dta_act_type_parse)
  SET dta_apr_parse = concat(dta_apr_parse,dta_act_type_parse)
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = scnt)
  DETAIL
   reply->service_resources[d.seq].code_value = request->service_resources[d.seq].code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO scnt)
   IF ((((request->load.sequence_ind=1)) OR ((request->load.result_type_ind=1))) )
    SELECT INTO "NL:"
     FROM orc_resource_list orl,
      profile_task_r ptr,
      assay_processing_r apr,
      order_catalog oc,
      discrete_task_assay dta
     PLAN (orl
      WHERE (orl.service_resource_cd=request->service_resources[x].code_value)
       AND orl.active_ind=1)
      JOIN (ptr
      WHERE ptr.catalog_cd=orl.catalog_cd
       AND ptr.active_ind=1
       AND ptr.task_assay_cd > 0)
      JOIN (oc
      WHERE oc.catalog_cd=ptr.catalog_cd
       AND oc.active_ind=1)
      JOIN (dta
      WHERE parser(dta_ptr_parse))
      JOIN (apr
      WHERE apr.task_assay_cd=outerjoin(ptr.task_assay_cd)
       AND ((apr.active_ind+ 0)=outerjoin(1))
       AND ((apr.service_resource_cd+ 0)=outerjoin(request->service_resources[x].code_value)))
     ORDER BY orl.service_resource_cd, apr.task_assay_cd
     HEAD orl.service_resource_cd
      found_zero_seq = 0, need_result_type = 0
     HEAD apr.task_assay_cd
      IF (apr.task_assay_cd > 0)
       IF (apr.display_sequence=0)
        found_zero_seq = (found_zero_seq+ 1)
       ENDIF
       IF (apr.default_result_type_cd=0)
        need_result_type = 1
       ENDIF
      ELSE
       need_result_type = 1, found_zero_seq = 2
      ENDIF
     FOOT  orl.service_resource_cd
      IF (found_zero_seq > 1)
       reply->service_resources[x].assay_need_seq_ind = 1
      ENDIF
      IF (need_result_type > 0)
       reply->service_resources[x].assay_need_result_type_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF ((((reply->service_resources[x].assay_need_seq_ind=0)) OR ((reply->service_resources[x].
    assay_need_result_type_ind=0))) )
     SELECT INTO "NL:"
      FROM profile_task_r ptr,
       assay_processing_r apr,
       order_catalog oc,
       discrete_task_assay dta
      PLAN (apr
       WHERE (apr.service_resource_cd=request->service_resources[x].code_value)
        AND apr.active_ind=1
        AND apr.task_assay_cd > 0)
       JOIN (dta
       WHERE parser(dta_apr_parse))
       JOIN (ptr
       WHERE ptr.active_ind=1
        AND ptr.task_assay_cd=apr.task_assay_cd)
       JOIN (oc
       WHERE oc.active_ind=1
        AND oc.catalog_cd=ptr.catalog_cd
        AND oc.resource_route_lvl=2)
      ORDER BY apr.service_resource_cd, apr.task_assay_cd
      HEAD apr.service_resource_cd
       found_zero_seq = 0, need_result_type = 0
      HEAD apr.task_assay_cd
       IF (apr.display_sequence=0)
        found_zero_seq = (found_zero_seq+ 1)
       ENDIF
       IF (apr.default_result_type_cd=0)
        need_result_type = 1
       ENDIF
      FOOT  apr.service_resource_cd
       IF (found_zero_seq > 1)
        reply->service_resources[x].assay_need_seq_ind = 1
       ENDIF
       IF (need_result_type > 0)
        reply->service_resources[x].assay_need_result_type_ind = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((((request->load.numeric_ind=1)) OR ((request->load.alpha_ind=1))) )
    SELECT INTO "NL"
     FROM orc_resource_list orl,
      profile_task_r ptr,
      assay_processing_r apr,
      discrete_task_assay dta,
      order_catalog oc
     PLAN (orl
      WHERE (orl.service_resource_cd=request->service_resources[x].code_value)
       AND orl.active_ind=1)
      JOIN (ptr
      WHERE ptr.catalog_cd=orl.catalog_cd
       AND ptr.active_ind=1
       AND ptr.task_assay_cd > 0
       AND  NOT ( EXISTS (
      (SELECT
       rrf.task_assay_cd
       FROM reference_range_factor rrf
       WHERE (rrf.service_resource_cd=request->service_resources[x].code_value)
        AND rrf.active_ind=1
        AND rrf.task_assay_cd=ptr.task_assay_cd))))
      JOIN (oc
      WHERE oc.catalog_cd=ptr.catalog_cd
       AND oc.active_ind=1)
      JOIN (dta
      WHERE parser(dta_ptr_parse))
      JOIN (apr
      WHERE apr.task_assay_cd=outerjoin(ptr.task_assay_cd)
       AND ((apr.active_ind+ 0)=outerjoin(1))
       AND ((apr.service_resource_cd+ 0)=outerjoin(request->service_resources[x].code_value)))
     DETAIL
      IF (apr.task_assay_cd > 0
       AND apr.default_result_type_cd > 0
       AND apr.active_ind=1)
       IF (apr.default_result_type_cd=alpha_type
        AND ptr.item_type_flag=0)
        reply->service_resources[x].assay_need_alpha_ind = 1
       ELSE
        IF (((apr.default_result_type_cd=numeric_type) OR (apr.default_result_type_cd=calc_type)) )
         reply->service_resources[x].assay_need_numeric_ind = 1
        ENDIF
       ENDIF
      ELSE
       IF (dta.default_result_type_cd=alpha_type
        AND ptr.item_type_flag=0)
        reply->service_resources[x].assay_need_alpha_ind = 1
       ELSE
        IF (((dta.default_result_type_cd=numeric_type) OR (dta.default_result_type_cd=calc_type)) )
         reply->service_resources[x].assay_need_numeric_ind = 1
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF ((((reply->service_resources[x].assay_need_alpha_ind=0)) OR ((reply->service_resources[x].
    assay_need_numeric_ind=0))) )
     SELECT INTO "NL"
      FROM profile_task_r ptr,
       assay_processing_r apr,
       order_catalog oc,
       discrete_task_assay dta
      PLAN (apr
       WHERE (apr.service_resource_cd=request->service_resources[x].code_value)
        AND apr.active_ind=1
        AND apr.task_assay_cd > 0
        AND apr.default_result_type_cd > 0)
       JOIN (dta
       WHERE parser(dta_apr_parse))
       JOIN (ptr
       WHERE ptr.active_ind=1
        AND ptr.task_assay_cd=apr.task_assay_cd
        AND  NOT ( EXISTS (
       (SELECT
        rrf.task_assay_cd
        FROM reference_range_factor rrf
        WHERE (rrf.service_resource_cd=request->service_resources[x].code_value)
         AND rrf.active_ind=1
         AND rrf.task_assay_cd=ptr.task_assay_cd))))
       JOIN (oc
       WHERE oc.active_ind=1
        AND oc.catalog_cd=ptr.catalog_cd
        AND oc.resource_route_lvl=2)
      DETAIL
       IF (apr.default_result_type_cd=alpha_type
        AND ptr.item_type_flag=0)
        reply->service_resources[x].assay_need_alpha_ind = 1
       ELSE
        IF (((apr.default_result_type_cd=numeric_type) OR (apr.default_result_type_cd=calc_type)) )
         reply->service_resources[x].assay_need_numeric_ind = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->load.numeric_ind=1))
    IF ((reply->service_resources[x].assay_need_numeric_ind=0))
     SELECT INTO "NL"
      FROM orc_resource_list orl,
       profile_task_r ptr,
       assay_processing_r apr,
       discrete_task_assay dta,
       order_catalog oc
      PLAN (orl
       WHERE (orl.service_resource_cd=request->service_resources[x].code_value)
        AND orl.active_ind=1)
       JOIN (ptr
       WHERE ptr.catalog_cd=orl.catalog_cd
        AND ptr.active_ind=1
        AND ptr.task_assay_cd > 0
        AND  NOT ( EXISTS (
       (SELECT
        dm.task_assay_cd
        FROM data_map dm
        WHERE (dm.service_resource_cd=request->service_resources[x].code_value)
         AND dm.active_ind=1
         AND dm.data_map_type_flag=0
         AND dm.task_assay_cd=ptr.task_assay_cd))))
       JOIN (oc
       WHERE oc.catalog_cd=ptr.catalog_cd
        AND oc.active_ind=1)
       JOIN (dta
       WHERE parser(dta_ptr_parse))
       JOIN (apr
       WHERE apr.task_assay_cd=outerjoin(ptr.task_assay_cd)
        AND ((apr.active_ind+ 0)=outerjoin(1))
        AND ((apr.service_resource_cd+ 0)=outerjoin(request->service_resources[x].code_value)))
      DETAIL
       IF (apr.task_assay_cd > 0
        AND apr.default_result_type_cd > 0
        AND apr.active_ind=1)
        IF (((apr.default_result_type_cd=numeric_type) OR (apr.default_result_type_cd=calc_type)) )
         reply->service_resources[x].assay_need_numeric_ind = 1
        ENDIF
       ELSEIF (((dta.default_result_type_cd=numeric_type) OR (dta.default_result_type_cd=calc_type))
       )
        reply->service_resources[x].assay_need_numeric_ind = 1
       ENDIF
      WITH nocounter
     ;end select
     IF ((reply->service_resources[x].assay_need_numeric_ind=0))
      SELECT INTO "NL"
       FROM profile_task_r ptr,
        assay_processing_r apr,
        order_catalog oc,
        discrete_task_assay dta
       PLAN (apr
        WHERE (apr.service_resource_cd=request->service_resources[x].code_value)
         AND apr.active_ind=1)
        JOIN (dta
        WHERE parser(dta_apr_parse))
        JOIN (ptr
        WHERE ptr.active_ind=1
         AND ptr.task_assay_cd=apr.task_assay_cd
         AND  NOT ( EXISTS (
        (SELECT
         dm.task_assay_cd
         FROM data_map dm
         WHERE (dm.service_resource_cd=request->service_resources[x].code_value)
          AND dm.active_ind=1
          AND dm.data_map_type_flag=0
          AND dm.task_assay_cd=ptr.task_assay_cd))))
        JOIN (oc
        WHERE oc.active_ind=1
         AND oc.catalog_cd=ptr.catalog_cd
         AND oc.resource_route_lvl=2)
       DETAIL
        IF (apr.task_assay_cd > 0
         AND apr.default_result_type_cd > 0)
         IF (((apr.default_result_type_cd=numeric_type) OR (apr.default_result_type_cd=calc_type)) )
          reply->service_resources[x].assay_need_numeric_ind = 1
         ENDIF
        ELSEIF (((dta.default_result_type_cd=numeric_type) OR (dta.default_result_type_cd=calc_type
        )) )
         reply->service_resources[x].assay_need_numeric_ind = 1
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (scnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
