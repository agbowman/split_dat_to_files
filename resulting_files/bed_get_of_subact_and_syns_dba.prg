CREATE PROGRAM bed_get_of_subact_and_syns:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 synonym_id = f8
     2 synonym_name = c100
     2 type_ind = c1
     2 catalog_code_value = f8
     2 catalog_display = c40
     2 catalog_cdf_mean = c12
   1 alist[*]
     2 activity_subtype_code_value = f8
     2 activity_subtype_display = c40
     2 activity_subtype_cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE oc_parse = vc
 IF ((request->clin_cat_code_value > 0))
  SET oc_parse = build("ocs.activity_subtype_cd = 0.0 and ocs.active_ind = 1",
   " and ocs.activity_type_cd = ",request->activity_type_code_value," and ocs.dcp_clin_cat_cd = ",
   request->clin_cat_code_value)
 ELSE
  SET oc_parse = build("ocs.activity_subtype_cd = 0.0 and ocs.active_ind = 1",
   " and ocs.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 SET scnt = 0
 SET alterlist_scnt = 0
 SELECT INTO "NL:"
  FROM order_catalog_synonym ocs,
   code_value cv
  PLAN (ocs
   WHERE parser(oc_parse))
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd)
  ORDER BY ocs.mnemonic
  HEAD REPORT
   stat = alterlist(reply->slist,50)
  DETAIL
   scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
   IF (alterlist_scnt > 50)
    stat = alterlist(reply->slist,(scnt+ 50)), alterlist_scnt = 0
   ENDIF
   reply->slist[scnt].synonym_id = ocs.synonym_id, reply->slist[scnt].synonym_name = ocs.mnemonic
   IF (ocs.orderable_type_flag IN (2, 6))
    reply->slist[scnt].type_ind = "C"
   ELSE
    reply->slist[scnt].type_ind = "S"
   ENDIF
   reply->slist[scnt].catalog_code_value = cv.code_value, reply->slist[scnt].catalog_display = cv
   .display, reply->slist[scnt].catalog_cdf_mean = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->slist,scnt)
  WITH nocounter
 ;end select
 IF ((request->clin_cat_code_value > 0))
  SET oc_parse = build("oc.active_ind = 1"," and oc.activity_type_cd = ",request->
   activity_type_code_value," and oc.dcp_clin_cat_cd = ",request->clin_cat_code_value)
 ELSE
  SET oc_parse = build("oc.active_ind = 1"," and oc.activity_type_cd = ",request->
   activity_type_code_value)
 ENDIF
 SET acnt = 0
 SET alterlist_acnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   code_value cv
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (cv
   WHERE oc.activity_subtype_cd=cv.code_value
    AND cv.active_ind=1
    AND cv.code_value > 0)
  ORDER BY cv.display
  HEAD REPORT
   stat = alterlist(reply->alist,50)
  DETAIL
   acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
   IF (alterlist_acnt > 50)
    stat = alterlist(reply->alist,(acnt+ 50)), alterlist_acnt = 0
   ENDIF
   reply->alist[acnt].activity_subtype_code_value = oc.activity_subtype_cd, reply->alist[acnt].
   activity_subtype_display = cv.display, reply->alist[acnt].activity_subtype_cdf_meaning = cv
   .cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->alist,acnt)
  WITH nocounter
 ;end select
 IF (acnt=0
  AND scnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
