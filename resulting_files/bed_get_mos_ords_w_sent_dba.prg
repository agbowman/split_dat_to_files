CREATE PROGRAM bed_get_mos_ords_w_sent:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 description = vc
      2 primary_mnemonic = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 DECLARE pharm_at = vc
 SET pharm_at = ""
 SET count = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
  HEAD REPORT
   pharm_at = "(oc.activity_type_cd = "
  DETAIL
   count = (count+ 1)
   IF (count=1)
    pharm_at = concat(pharm_at,cnvtstring(cv.code_value))
   ELSE
    pharm_at = concat(pharm_at," or oc.activity_type_cd = ",cnvtstring(cv.code_value))
   ENDIF
  FOOT REPORT
   pharm_at = concat(pharm_at,")")
  WITH nocounter
 ;end select
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET y_code_value = 0.0
 SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
 SET z_code_value = 0.0
 SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
 DECLARE search_txt = vc
 DECLARE oc_parse = vc
 SET oc_parse = concat("oc.catalog_type_cd = pharm_ct and oc.orderable_type_flag in (0,1,null)",
  " and oc.active_ind = 1 and ",pharm_at)
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_string = concat('"',cnvtupper(trim(request->search_string)),'*"')
  ELSE
   SET search_string = concat('"*',cnvtupper(trim(request->search_string)),'*"')
  ENDIF
  SET oc_parse = concat(oc_parse," and cnvtupper(oc.primary_mnemonic) = ",search_string)
 ENDIF
 DECLARE ocs_parse = vc
 IF ((request->usage_flag=2))
  SET ocs_parse = concat(
   "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
   "c_code_value, e_code_value, m_code_value, n_code_value, y_code_value, z_code_value)")
 ELSE
  SET ocs_parse = concat(
   "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
   "c_code_value, e_code_value, m_code_value, n_code_value)")
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND parser(ocs_parse)
    AND ocs.active_ind=1
    AND ocs.hide_flag IN (0, null))
   JOIN (ocsr
   WHERE ocsr.synonym_id=ocs.synonym_id
    AND ocsr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND (os.usage_flag=request->usage_flag))
  ORDER BY oc.catalog_cd
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->orders,100)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->orders[tcnt].catalog_code_value = oc.catalog_cd, reply->orders[tcnt].description = oc
   .description, reply->orders[tcnt].primary_mnemonic = oc.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->orders,tcnt)
  WITH nocounter
 ;end select
 IF ((tcnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = alterlist(reply->orders,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
