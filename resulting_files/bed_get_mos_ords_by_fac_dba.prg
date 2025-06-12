CREATE PROGRAM bed_get_mos_ords_by_fac:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 description = vc
      2 primary_mnemonic = vc
      2 orderable_type_flag = i4
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_cat
 RECORD temp_cat(
   1 cats[*]
     2 catalog_code_value = f8
     2 desc = vc
     2 p_m = vc
     2 orderable_type_flag = i4
 )
 SET reply->status_data.status = "F"
 DECLARE pharm_ct = f8 WITH protect
 DECLARE primary_code_value = f8 WITH protect
 DECLARE brand_code_value = f8 WITH protect
 DECLARE dcp_code_value = f8 WITH protect
 DECLARE c_code_value = f8 WITH protect
 DECLARE e_code_value = f8 WITH protect
 DECLARE m_code_value = f8 WITH protect
 DECLARE n_code_value = f8 WITH protect
 DECLARE y_code_value = f8 WITH protect
 DECLARE z_code_value = f8 WITH protect
 DECLARE count = i2 WITH protect
 DECLARE search_string = vc WITH protect
 DECLARE tot_cnt = i2 WITH protect
 DECLARE cnt = i2 WITH protect
 DECLARE replycount = i2 WITH protect
 DECLARE setreplydata(catalogcd=f8,description=vc,mnemonic=vc,orderabletype=i2) = null
 SET pharm_ct = 0.0
 SET replycount = 1
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 DECLARE pharm_at = vc
 SET pharm_at = ""
 SET count = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
  HEAD REPORT
   pharm_at = "(o.activity_type_cd = "
  DETAIL
   count = (count+ 1)
   IF (count=1)
    pharm_at = concat(pharm_at,cnvtstring(cv.code_value))
   ELSE
    pharm_at = concat(pharm_at," or o.activity_type_cd = ",cnvtstring(cv.code_value))
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
 SET oc_parse = concat("o.catalog_type_cd = pharm_ct and o.orderable_type_flag in (0,1,2,6)",
  " and o.active_ind = 1 and ",pharm_at)
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_string = concat('"',cnvtupper(trim(request->search_string)),'*"')
  ELSE
   SET search_string = concat('"*',cnvtupper(trim(request->search_string)),'*"')
  ENDIF
  SET oc_parse = concat(oc_parse," and cnvtupper(o.primary_mnemonic) = ",search_string)
 ENDIF
 DECLARE ocs_parse = vc
 IF (validate(request->prescription_ind))
  IF ((request->prescription_ind=1))
   SET ocs_parse = concat(
    "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
    "c_code_value, e_code_value, m_code_value, n_code_value, y_code_value, z_code_value)")
  ELSE
   SET ocs_parse = concat(
    "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
    "c_code_value, e_code_value, m_code_value, n_code_value)")
  ENDIF
 ELSE
  SET ocs_parse = concat(
   "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
   "c_code_value, e_code_value, m_code_value, n_code_value)")
 ENDIF
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE parser(oc_parse))
  ORDER BY o.catalog_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_cat->cats,100)
  HEAD o.catalog_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_cat->cats,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_cat->cats[tot_cnt].catalog_code_value = o.catalog_cd, temp_cat->cats[tot_cnt].desc = o
   .description, temp_cat->cats[tot_cnt].p_m = o.primary_mnemonic,
   temp_cat->cats[tot_cnt].orderable_type_flag = o.orderable_type_flag
  FOOT REPORT
   stat = alterlist(temp_cat->cats,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_cnt)),
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.catalog_cd=temp_cat->cats[d.seq].catalog_code_value)
    AND parser(ocs_parse)
    AND ocs.active_ind=1)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id)
    AND ofr.facility_cd=outerjoin(request->facility_code_value))
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->orders,tot_cnt)
  HEAD d.seq
   load_ind = 0
  DETAIL
   IF (((ofr.synonym_id > 0) OR ((request->ignore_facility_ind=1))) )
    load_ind = 1
   ENDIF
  FOOT  d.seq
   IF (load_ind=1)
    cnt = (cnt+ 1),
    CALL setreplydata(temp_cat->cats[d.seq].catalog_code_value,temp_cat->cats[d.seq].desc,temp_cat->
    cats[d.seq].p_m,temp_cat->cats[d.seq].orderable_type_flag)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->orders,cnt)
  WITH nocounter
 ;end select
 IF ((request->facility_code_value != 0.0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tot_cnt)),
    order_catalog_synonym ocs,
    ocs_facility_r ofr,
    filter_entity_reltn fer,
    order_sentence os
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=temp_cat->cats[d.seq].catalog_code_value)
     AND parser(ocs_parse)
     AND ocs.active_ind=1)
    JOIN (ofr
    WHERE ofr.synonym_id=outerjoin(ocs.synonym_id)
     AND ofr.facility_cd=0.0)
    JOIN (fer
    WHERE (fer.filter_entity1_id=request->facility_code_value)
     AND fer.parent_entity_name="ORDER_SENTENCE"
     AND fer.filter_entity1_name="LOCATION")
    JOIN (os
    WHERE os.parent_entity_id=ofr.synonym_id
     AND os.order_sentence_id=fer.parent_entity_id
     AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
   ORDER BY d.seq
   HEAD REPORT
    stat = alterlist(reply->orders,tot_cnt)
   HEAD d.seq
    load_ind1 = 0
   DETAIL
    IF (((ofr.synonym_id > 0) OR ((request->ignore_facility_ind=1))) )
     load_ind1 = 1
    ENDIF
   FOOT  d.seq
    IF (load_ind1=1)
     cnt = (cnt+ 1),
     CALL setreplydata(temp_cat->cats[d.seq].catalog_code_value,temp_cat->cats[d.seq].desc,temp_cat->
     cats[d.seq].p_m,temp_cat->cats[d.seq].orderable_type_flag)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->orders,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((cnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = initrec(reply)
  SET reply->too_many_results_ind = 1
 ENDIF
 SUBROUTINE setreplydata(catalogcd,description,mnemonic,orderabletype)
   SET stat = alterlist(reply->orders,replycount)
   SET reply->orders[replycount].catalog_code_value = catalogcd
   SET reply->orders[replycount].description = description
   SET reply->orders[replycount].primary_mnemonic = mnemonic
   SET reply->orders[replycount].orderable_type_flag = orderabletype
   SET replycount = (replycount+ 1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
