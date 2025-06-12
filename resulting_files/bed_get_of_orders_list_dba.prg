CREATE PROGRAM bed_get_of_orders_list:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 synonym_id = f8
     2 synonym_name = c100
     2 type_ind = c1
     2 catalog_code_value = f8
     2 catalog_display = c40
     2 catalog_cdf_mean = c12
     2 mnemonic_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 subactivity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 clinical_category
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 10000
 ENDIF
 SET primary_cd = 0
 SET dcp_cd = 0
 SET brandname_cd = 0
 SET dispdrug_cd = 0
 SET ivname_cd = 0
 SET generictop_cd = 0
 SET tradetop_cd = 0
 SET genericprod_cd = 0
 SET tradeprod_cd = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning IN ("PRIMARY", "DCP", "BRANDNAME", "DISPDRUG", "IVNAME",
  "GENERICTOP", "TRADETOP", "GENERICPROD", "TRADEPROD")
  DETAIL
   IF (cv.cdf_meaning="PRIMARY")
    primary_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BRANDNAME")
    brandname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICPROD")
    genericprod_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADEPROD")
    tradeprod_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->component_flag=1))
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1
   DETAIL
    request->catalog_type_code_value = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 DECLARE search_string = vc
 DECLARE ocs_parse = vc
 SET search_string = " "
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_string = concat('"',trim(request->search_string),'*"')
  ELSE
   SET search_string = concat('"*',trim(request->search_string),'*"')
  ENDIF
 ENDIF
 SET ocs_parse = " ocs.active_ind = 1 "
 IF (search_string > " ")
  SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_key_cap = ",cnvtupper(search_string))
 ENDIF
 IF ((request->catalog_type_code_value > 0))
  SET ocs_parse = build(ocs_parse," and ocs.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET ocs_parse = build(ocs_parse," and ocs.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->activity_subtype_code_value > 0))
  SET ocs_parse = build(ocs_parse," and ocs.activity_subtype_cd = ",request->
   activity_subtype_code_value)
 ENDIF
 IF ((request->clin_cat_code_value > 0))
  SET ocs_parse = build(ocs_parse," and ocs.dcp_clin_cat_cd = ",request->clin_cat_code_value)
 ENDIF
 IF ((request->component_flag=1))
  SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (primary_cd, brandname_cd, ",
   "dispdrug_cd, ivname_cd, generictop_cd, tradetop_cd, ","genericprod_cd, tradeprod_cd)")
 ELSEIF ((request->component_flag=2))
  SET ocs_parse = concat(ocs_parse," and ocs.mnemonic_type_cd in (primary_cd, dcp_cd, brandname_cd, ",
   "dispdrug_cd, ivname_cd, generictop_cd, tradetop_cd)")
 ENDIF
 CALL echo(ocs_parse)
 SET stat = alterlist(reply->slist,100)
 SET scnt = 0
 SET alterlist_scnt = 0
 SELECT INTO "NL:"
  FROM order_catalog_synonym ocs,
   code_value cv,
   code_value cv_mnem,
   code_value cv_cat,
   code_value cv_act,
   code_value cv_sub,
   code_value cv_clin
  PLAN (ocs
   WHERE parser(ocs_parse))
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd)
   JOIN (cv_mnem
   WHERE cv_mnem.code_value=ocs.mnemonic_type_cd
    AND cv_mnem.active_ind=1)
   JOIN (cv_cat
   WHERE cv_cat.code_value=ocs.catalog_type_cd
    AND cv_cat.active_ind=1)
   JOIN (cv_act
   WHERE cv_act.code_value=ocs.activity_type_cd
    AND cv_act.active_ind=1)
   JOIN (cv_sub
   WHERE cv_sub.code_value=outerjoin(ocs.activity_subtype_cd)
    AND cv_sub.active_ind=outerjoin(1))
   JOIN (cv_clin
   WHERE cv_clin.code_value=outerjoin(ocs.dcp_clin_cat_cd)
    AND cv_clin.active_ind=outerjoin(1))
  ORDER BY ocs.mnemonic
  DETAIL
   alterlist_scnt = (alterlist_scnt+ 1)
   IF (alterlist_scnt > 100)
    stat = alterlist(reply->slist,(scnt+ 100)), alterlist_scnt = 1
   ENDIF
   scnt = (scnt+ 1), reply->slist[scnt].synonym_id = ocs.synonym_id, reply->slist[scnt].synonym_name
    = ocs.mnemonic
   IF (ocs.orderable_type_flag IN (2, 6))
    reply->slist[scnt].type_ind = "C"
   ELSE
    reply->slist[scnt].type_ind = "S"
   ENDIF
   reply->slist[scnt].catalog_code_value = cv.code_value, reply->slist[scnt].catalog_display = cv
   .display, reply->slist[scnt].catalog_cdf_mean = cv.cdf_meaning,
   reply->slist[scnt].mnemonic_type.code_value = cv_mnem.code_value, reply->slist[scnt].mnemonic_type
   .display = cv_mnem.display, reply->slist[scnt].mnemonic_type.mean = cv_mnem.cdf_meaning,
   reply->slist[scnt].catalog_type.code_value = cv_cat.code_value, reply->slist[scnt].catalog_type.
   display = cv_cat.display, reply->slist[scnt].catalog_type.mean = cv_cat.cdf_meaning,
   reply->slist[scnt].activity_type.code_value = cv_act.code_value, reply->slist[scnt].activity_type.
   display = cv_act.display, reply->slist[scnt].activity_type.mean = cv_act.cdf_meaning,
   reply->slist[scnt].subactivity_type.code_value = cv_sub.code_value, reply->slist[scnt].
   subactivity_type.display = cv_sub.display, reply->slist[scnt].subactivity_type.mean = cv_sub
   .cdf_meaning,
   reply->slist[scnt].clinical_category.code_value = cv_clin.code_value, reply->slist[scnt].
   clinical_category.display = cv_clin.display, reply->slist[scnt].clinical_category.mean = cv_clin
   .cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,scnt)
 IF (scnt > max_cnt)
  SET stat = alterlist(reply->slist,max_cnt)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
