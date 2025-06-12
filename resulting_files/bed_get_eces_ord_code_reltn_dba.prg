CREATE PROGRAM bed_get_eces_ord_code_reltn:dba
 FREE SET reply
 RECORD reply(
   1 assays[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 event_code
       3 code_value = f8
       3 display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET pc_activity_types
 RECORD pc_activity_types(
   1 activity_types[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET glb_cat_code_value = 0.0
 SET rad_cat_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning IN ("GENERAL LAB", "RADIOLOGY")
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="GENERAL LAB")
    glb_cat_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="RADIOLOGY")
    rad_cat_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET ap_act_code_value = 0.0
 SET glb_act_code_value = 0.0
 SET micro_act_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cnvtupper(cv.definition)="GENERAL LAB"
   AND cv.cdf_meaning IN ("AP", "GLB", "MICROBIOLOGY")
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="AP")
    ap_act_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="GLB")
    glb_act_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="MICROBIOLOGY")
    micro_act_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET rad_act_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cnvtupper(cv.definition)="RADIOLOGY"
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   rad_act_code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pc_cat_code_value = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="NURS"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   pc_cat_code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE search_parse = vc
 DECLARE search_string1 = vc
 DECLARE search_string2 = vc
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_string1 = concat('"',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
   SET search_string2 = concat('"',trim(cnvtupper(request->search_string)),'*"')
  ELSE
   SET search_string1 = concat('"*',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
   SET search_string2 = concat('"*',trim(cnvtupper(request->search_string)),'*"')
  ENDIF
  SET search_string1 = cnvtupper(search_string1)
  SET search_string2 = cnvtupper(search_string2)
 ELSE
  SET search_string1 = "'*'"
  SET search_string2 = "'*'"
 ENDIF
 SET search_dta_parse = concat(" ( vec.event_cd_disp_key = ",search_string1,
  " ) or ( dta.mnemonic_key_cap = ",search_string2," ) ")
 SET search_ord_parse = concat(" ( vec.event_cd_disp_key = ",search_string1,
  " ) or ( ocs.mnemonic_key_cap = ",search_string2," ) ")
 SET search_cv_parse = concat(" ( vec.event_cd_disp_key = ",search_string1,
  " ) or ( cv.display_key_cap = ",search_string1," ) ")
 IF ((request->activity_type_code_value IN (rad_act_code_value, ap_act_code_value, glb_act_code_value,
 pc_cat_code_value)))
  DECLARE dta_parse = vc
  IF ((request->activity_type_code_value=ap_act_code_value))
   SET subap_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=5801
     AND cv.cdf_meaning="APREPORT"
    DETAIL
     subap_code_value = cv.code_value
    WITH nocounter
   ;end select
  ELSEIF ((request->activity_type_code_value=rad_act_code_value))
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
   SET rad_bill_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=289
     AND cv.cdf_meaning="17"
     AND cv.active_ind=1
    DETAIL
     rad_bill_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET dta_parse = build("dta.activity_type_cd+0 = ",request->activity_type_code_value,
    " and dta.default_result_type_cd != ",rad_bill_code_value," and dta.default_result_type_cd != ",
    rad_exam_code_value)
  ELSEIF ((request->activity_type_code_value=pc_cat_code_value))
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
   SET dta_parse = build("expand(num,",1,",size(pc_activity_types->activity_types,",5,"),",
    "dta.activity_type_cd,pc_activity_types->activity_types[num].code_value)")
  ELSE
   SET glb_bill_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=289
     AND cv.cdf_meaning="17"
     AND cv.active_ind=1
    DETAIL
     glb_bill_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET dta_parse = build("dta.activity_type_cd+0 = ",request->activity_type_code_value,
    " and dta.default_result_type_cd != ",glb_bill_code_value)
  ENDIF
  IF ((request->activity_type_code_value IN (glb_act_code_value, rad_act_code_value)))
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     code_value_event_r cvr,
     code_value cv,
     v500_event_code vec
    PLAN (cv
     WHERE cv.active_ind=1
      AND cv.code_set=72)
     JOIN (cvr
     WHERE cvr.event_cd=cv.code_value)
     JOIN (vec
     WHERE vec.event_cd=cvr.event_cd)
     JOIN (dta
     WHERE dta.task_assay_cd=cvr.parent_cd
      AND parser(dta_parse)
      AND parser(search_dta_parse))
    HEAD REPORT
     cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
     reply->assays[cnt].description = dta.description,
     reply->assays[cnt].event_code.code_value = cvr.event_cd, reply->assays[cnt].event_code.display
      = vec.event_cd_disp
    FOOT REPORT
     stat = alterlist(reply->assays,cnt)
    WITH nocounter
   ;end select
  ELSEIF ((request->activity_type_code_value=pc_cat_code_value))
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     code_value cv,
     v500_event_code vec
    PLAN (cv
     WHERE cv.code_set=72
      AND cv.active_ind=1)
     JOIN (dta
     WHERE dta.event_cd=cv.code_value
      AND parser(dta_parse))
     JOIN (vec
     WHERE vec.event_cd=dta.event_cd
      AND parser(search_dta_parse))
    HEAD REPORT
     cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
     reply->assays[cnt].description = dta.description,
     reply->assays[cnt].event_code.code_value = dta.event_cd, reply->assays[cnt].event_code.display
      = vec.event_cd_disp
    FOOT REPORT
     stat = alterlist(reply->assays,cnt)
    WITH nocounter
   ;end select
  ELSEIF ((request->activity_type_code_value=ap_act_code_value))
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     profile_task_r ptr,
     order_catalog oc,
     code_value_event_r cvr,
     code_value cv,
     v500_event_code vec
    PLAN (cv
     WHERE cv.code_set=72
      AND cv.active_ind=1)
     JOIN (cvr
     WHERE cvr.event_cd=cv.code_value)
     JOIN (vec
     WHERE vec.event_cd=cvr.event_cd)
     JOIN (dta
     WHERE dta.task_assay_cd=cvr.parent_cd
      AND parser(search_dta_parse))
     JOIN (ptr
     WHERE ptr.task_assay_cd=dta.task_assay_cd)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.activity_subtype_cd=subap_code_value)
    HEAD REPORT
     cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->assays[cnt].code_value = dta.task_assay_cd, reply->assays[cnt].display = dta.mnemonic,
     reply->assays[cnt].description = dta.description,
     reply->assays[cnt].event_code.code_value = cvr.event_cd, reply->assays[cnt].event_code.display
      = vec.event_cd_disp
    FOOT REPORT
     stat = alterlist(reply->assays,cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->activity_type_code_value IN (rad_act_code_value, ap_act_code_value,
 micro_act_code_value)))
  DECLARE ord_parse = vc
  IF ((request->activity_type_code_value=ap_act_code_value))
   SET subap_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=5801
     AND cv.cdf_meaning="APREPORT"
    DETAIL
     subap_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET ord_parse = build("oc.catalog_type_cd+0 = ",request->catalog_type_code_value,
    " and oc.activity_subtype_cd+0 = ",subap_code_value)
  ELSE
   SET ord_parse = build("oc.catalog_type_cd+0 = ",request->catalog_type_code_value,
    " and oc.activity_type_cd+0 = ",request->activity_type_code_value)
  ENDIF
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    code_value cv,
    code_value_event_r cvr,
    code_value cv2,
    v500_event_code vec
   PLAN (cv2
    WHERE cv2.code_set=72
     AND cv2.active_ind=1)
    JOIN (cvr
    WHERE cvr.event_cd=cv2.code_value)
    JOIN (vec
    WHERE vec.event_cd=cvr.event_cd)
    JOIN (oc
    WHERE oc.catalog_cd=cvr.parent_cd
     AND parser(ord_parse))
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND parser(search_ord_parse))
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
    reply->assays[cnt].event_code.code_value = vec.event_cd, reply->assays[cnt].event_code.display =
    vec.event_cd_disp
   FOOT REPORT
    stat = alterlist(reply->assays,cnt)
   WITH nocounter
  ;end select
  IF ((request->activity_type_code_value=micro_act_code_value))
   SELECT INTO "nl:"
    FROM code_value cv,
     code_value_event_r cvr,
     code_value cv2,
     v500_event_code vec
    PLAN (cv2
     WHERE cv2.code_set=72
      AND cv2.active_ind=1)
     JOIN (cvr
     WHERE cvr.event_cd=cv2.code_value)
     JOIN (vec
     WHERE vec.event_cd=cvr.event_cd)
     JOIN (cv
     WHERE cv.code_value=cvr.parent_cd
      AND parser(search_cv_parse)
      AND cv.code_set=1000)
    HEAD REPORT
     cnt = size(reply->assays,5), list_cnt = 0, stat = alterlist(reply->assays,(cnt+ 100))
    DETAIL
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->assays,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->assays[cnt].code_value = cv.code_value, reply->assays[cnt].display = cv.display, reply->
     assays[cnt].description = cv.description,
     reply->assays[cnt].event_code.code_value = vec.event_cd, reply->assays[cnt].event_code.display
      = vec.event_cd_disp
    FOOT REPORT
     stat = alterlist(reply->assays,cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET xcnt = size(reply->assays,5)
#exit_script
 IF ((xcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET reply->too_many_results_ind = 1
  SET stat = alterlist(reply->assays,0)
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
