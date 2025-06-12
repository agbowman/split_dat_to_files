CREATE PROGRAM bed_get_os_details:dba
 FREE SET reply
 RECORD reply(
   1 description = vc
   1 hide_ind = i2
   1 catalog_type
     2 code_value = f8
     2 display = vc
     2 meaning = vc
   1 activity_type
     2 code_value = f8
     2 display = vc
     2 meaning = vc
   1 subactivity_type
     2 code_value = f8
     2 display = vc
     2 meaning = vc
   1 clinical_category
     2 code_value = f8
     2 display = vc
     2 meaning = vc
   1 os_synonyms[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 active_ind = i2
     2 mnemonic_type
       3 code_value = f8
       3 display = vc
       3 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (oc
   WHERE (oc.catalog_cd=request->order_set_code_value))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(oc.catalog_type_cd))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(oc.activity_type_cd))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.activity_subtype_cd))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(oc.dcp_clin_cat_cd))
  DETAIL
   reply->description = oc.description, reply->catalog_type.code_value = oc.catalog_type_cd, reply->
   catalog_type.display = cv1.display,
   reply->catalog_type.meaning = cv1.cdf_meaning, reply->activity_type.code_value = oc
   .activity_type_cd, reply->activity_type.display = cv2.display,
   reply->activity_type.meaning = cv2.cdf_meaning, reply->subactivity_type.code_value = oc
   .activity_subtype_cd, reply->subactivity_type.display = cv3.display,
   reply->subactivity_type.meaning = cv3.cdf_meaning, reply->clinical_category.code_value = oc
   .dcp_clin_cat_cd, reply->clinical_category.display = cv4.display,
   reply->clinical_category.meaning = cv4.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   code_value cv
  PLAN (ocs
   WHERE (ocs.catalog_cd=request->order_set_code_value))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd)
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->os_synonyms,10)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(reply->os_synonyms,(cnt+ 10)), list_cnt = 1
   ENDIF
   reply->os_synonyms[cnt].mnemonic = ocs.mnemonic, reply->os_synonyms[cnt].synonym_id = ocs
   .synonym_id, reply->os_synonyms[cnt].active_ind = ocs.active_ind,
   reply->os_synonyms[cnt].mnemonic_type.code_value = ocs.mnemonic_type_cd, reply->os_synonyms[cnt].
   mnemonic_type.display = cv.display, reply->os_synonyms[cnt].mnemonic_type.meaning = cv.cdf_meaning,
   reply->hide_ind = ocs.hide_flag
  FOOT REPORT
   stat = alterlist(reply->os_synonyms,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
