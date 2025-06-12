CREATE PROGRAM bed_get_eces_assays:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assays[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 dta_ind = i2
      2 event_code
        3 code_value = f8
        3 display = vc
        3 meaning = vc
        3 dta_event_code_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_hier
 RECORD temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 child_code = f8
 )
 FREE SET pc_activity_types
 RECORD pc_activity_types(
   1 activity_types[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET rad_code_value = 0.0
 SET rad_code_value = uar_get_code_by("MEANING",106,"RADIOLOGY")
 SET ap_code_value = 0.0
 SET ap_code_value = uar_get_code_by("MEANING",106,"AP")
 SET glb_code_value = 0.0
 SET glb_code_value = uar_get_code_by("MEANING",106,"GLB")
 SET micro_code_value = 0.0
 SET micro_code_value = uar_get_code_by("MEANING",106,"MICROBIOLOGY")
 SET subap_code_value = 0.0
 SET subap_code_value = uar_get_code_by("MEANING",5801,"APREPORT")
 SET bill_only_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning="17"
   AND cv.active_ind=1
  DETAIL
   bill_only_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET rad_exam_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=289
   AND cv.cdf_meaning="11"
   AND cv.active_ind=1
  DETAIL
   rad_exam_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 IF ((request->activity_type_code_value IN (glb_code_value, rad_code_value)))
  DECLARE dta_parse = vc
  IF ((request->activity_type_code_value=rad_code_value))
   SET dta_parse = build("dta.activity_type_cd = ",request->activity_type_code_value,
    " and dta.default_result_type_cd != ",bill_only_code_value," and dta.default_result_type_cd != ",
    rad_exam_code_value," and dta.active_ind = 1")
  ELSE
   SET dta_parse = build("dta.activity_type_cd = ",request->activity_type_code_value,
    " and dta.default_result_type_cd != ",bill_only_code_value," and dta.active_ind = 1")
  ENDIF
  SELECT INTO "nl:"
   FROM discrete_task_assay dta,
    code_value cv
   PLAN (dta
    WHERE parser(dta_parse)
     AND  NOT ( EXISTS (
    (SELECT
     cvr.event_cd
     FROM code_value_event_r cvr
     WHERE cvr.parent_cd=dta.task_assay_cd))))
    JOIN (cv
    WHERE cv.code_value=outerjoin(dta.event_cd))
   HEAD REPORT
    cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
    reply->assays[cnt].description = dta.description,
    reply->assays[cnt].dta_ind = 1
    IF (cv.code_value > 0)
     reply->assays[cnt].event_code.code_value = cv.code_value, reply->assays[cnt].event_code.display
      = cv.display, reply->assays[cnt].event_code.meaning = cv.cdf_meaning,
     reply->assays[cnt].event_code.dta_event_code_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->assays,cnt)
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type_code_value=ap_code_value))
  SELECT INTO "nl:"
   FROM discrete_task_assay dta,
    profile_task_r ptr,
    order_catalog oc,
    code_value cv
   PLAN (oc
    WHERE oc.activity_subtype_cd=subap_code_value
     AND oc.active_ind=1
     AND  NOT (oc.orderable_type_flag IN (2, 6))
     AND ((oc.bill_only_ind=0) OR (oc.bill_only_ind=null)) )
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE ptr.task_assay_cd=dta.task_assay_cd
     AND dta.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     cvr.event_cd
     FROM code_value_event_r cvr
     WHERE cvr.parent_cd=dta.task_assay_cd))))
    JOIN (cv
    WHERE cv.code_value=outerjoin(dta.event_cd))
   HEAD REPORT
    cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
    reply->assays[cnt].description = dta.description,
    reply->assays[cnt].dta_ind = 1
    IF (cv.code_value > 0)
     reply->assays[cnt].event_code.code_value = cv.code_value, reply->assays[cnt].event_code.display
      = cv.display, reply->assays[cnt].event_code.meaning = cv.cdf_meaning,
     reply->assays[cnt].event_code.dta_event_code_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->assays,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->activity_type_code_value IN (rad_code_value, ap_code_value, micro_code_value)))
  DECLARE ord_parse = vc
  IF ((request->activity_type_code_value=ap_code_value))
   SET ord_parse = build("oc.catalog_type_cd = ",request->catalog_type_code_value,
    " and oc.activity_subtype_cd = ",subap_code_value," and oc.active_ind = 1")
  ELSE
   SET ord_parse = build("oc.catalog_type_cd = ",request->catalog_type_code_value,
    " and oc.activity_type_cd = ",request->activity_type_code_value," and oc.active_ind = 1")
  ENDIF
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (oc
    WHERE parser(ord_parse)
     AND  NOT ( EXISTS (
    (SELECT
     cvr.event_cd
     FROM code_value_event_r cvr
     WHERE cvr.parent_cd=oc.catalog_cd))))
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.active_ind=1
     AND  NOT (oc.orderable_type_flag IN (2, 6))
     AND ((oc.bill_only_ind=0) OR (oc.bill_only_ind=null)) )
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.code_set=6011
     AND cv.cdf_meaning="PRIMARY"
     AND cv.active_ind=1)
   HEAD REPORT
    cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->assays[cnt].code_value = ocs.catalog_cd, reply->assays[cnt].display = ocs.mnemonic, reply
    ->assays[cnt].description = oc.description,
    reply->assays[cnt].dta_ind = 0
   FOOT REPORT
    stat = alterlist(reply->assays,cnt)
   WITH nocounter
  ;end select
  IF ((request->activity_type_code_value=micro_code_value))
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=1000
      AND cv.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      cvr.event_cd
      FROM code_value_event_r cvr
      WHERE cvr.parent_cd=cv.code_value))))
    HEAD REPORT
     cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->assays[cnt].code_value = cv.code_value, reply->assays[cnt].display = cv.display, reply->
     assays[cnt].description = cv.description,
     reply->assays[cnt].dta_ind = 0
    FOOT REPORT
     stat = alterlist(reply->assays,cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 DECLARE pc_code_value = f8
 SET pc_code_value = uar_get_code_by("MEANING",6000,"NURS")
 IF ((request->catalog_type_code_value=pc_code_value)
  AND (request->activity_type_code_value=pc_code_value))
  SET stat = alterlist(pc_activity_types->activity_types,0)
  SET activity_types_cnt = 0
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=106
    AND cv.definition="NURS"
   DETAIL
    activity_types_cnt = (activity_types_cnt+ 1), stat = alterlist(pc_activity_types->activity_types,
     activity_types_cnt), pc_activity_types->activity_types[activity_types_cnt].code_value = cv
    .code_value
   WITH nocounter
  ;end select
  DECLARE num = i4
  SELECT INTO "nl:"
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE expand(num,1,size(pc_activity_types->activity_types,5),dta.activity_type_cd,
     pc_activity_types->activity_types[num].code_value)
     AND dta.default_result_type_cd != bill_only_code_value
     AND dta.active_ind=1
     AND dta.event_cd=0
     AND  NOT ( EXISTS (
    (SELECT
     cvr.event_cd
     FROM code_value_event_r cvr
     WHERE cvr.parent_cd=dta.task_assay_cd))))
   HEAD REPORT
    cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
    reply->assays[cnt].description = dta.description,
    reply->assays[cnt].dta_ind = 1
   FOOT REPORT
    stat = alterlist(reply->assays,cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
