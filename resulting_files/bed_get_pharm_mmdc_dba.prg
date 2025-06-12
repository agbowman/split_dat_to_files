CREATE PROGRAM bed_get_pharm_mmdc:dba
 FREE SET reply
 RECORD reply(
   1 products[*]
     2 display = vc
     2 client
       3 item_id = f8
       3 display = vc
       3 mmdc = vc
     2 multum
       3 display = vc
       3 mmdc = vc
     2 ignore_ind = i2
     2 inpatient_ind = i2
     2 retail_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_client
 RECORD temp_client(
   1 items[*]
     2 item_id = f8
     2 ndc = vc
     2 mmdc = vc
     2 ignore_ind = i2
     2 inpatient_ind = i2
     2 retail_ind = i2
 )
 SET reply->status_data.status = "F"
 SET ndc_code_value = 0.0
 SET generic_name_code_value = 0.0
 SET trade_name_code_value = 0.0
 SET mul_code_value = 0.0
 SET desc_code_value = 0.0
 SET cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning="NDC"
   AND cv.active_ind=1
  DETAIL
   ndc_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning="GENERIC_NAME"
   AND cv.active_ind=1
  DETAIL
   generic_name_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning="TRADE_NAME"
   AND cv.active_ind=1
  DETAIL
   trade_name_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning="DESC"
   AND cv.active_ind=1
  DETAIL
   desc_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="MUL.MMDC"
   AND cv.active_ind=1
  DETAIL
   mul_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET system_code_value = 0.0
 SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET retail_code_value = 0.0
 SET retail_code_value = uar_get_code_by("MEANING",4500,"RETAIL")
 SET inpatient_code_value = 0.0
 SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET medproduct_code_value = 0.0
 SET medproduct_code_value = uar_get_code_by("MEANING",4063,"MEDPRODUCT")
 SET req_ign_ind = 1
 IF (validate(request->return_ignored_ind))
  SET req_ign_ind = request->return_ignored_ind
 ENDIF
 SELECT INTO "nl:"
  FROM med_identifier mi,
   medication_definition md,
   br_name_value b,
   med_def_flex mdf,
   med_flex_object_idx mfoi
  PLAN (md
   WHERE md.item_id > 0)
   JOIN (mdf
   WHERE (mdf.item_id=(md.item_id+ 0))
    AND mdf.flex_type_cd=system_code_value
    AND ((mdf.pharmacy_type_cd+ 0) IN (inpatient_code_value, retail_code_value))
    AND ((mdf.sequence+ 0)=0)
    AND ((mdf.med_def_flex_id+ 0) != 0)
    AND ((mdf.active_ind+ 0)=1))
   JOIN (mfoi
   WHERE (mfoi.med_def_flex_id=(mdf.med_def_flex_id+ 0))
    AND mfoi.flex_object_type_cd=medproduct_code_value
    AND trim(mfoi.parent_entity_name)="MED_PRODUCT"
    AND ((mfoi.sequence+ 0)=1)
    AND ((mfoi.active_ind+ 0)=1))
   JOIN (mi
   WHERE ((mi.med_identifier_type_cd+ 0)=ndc_code_value)
    AND ((mi.active_ind+ 0)=1)
    AND ((mi.pharmacy_type_cd+ 0)=mdf.pharmacy_type_cd)
    AND ((mi.med_product_id+ 0)=mfoi.parent_entity_id)
    AND ((mi.primary_ind+ 0)=1)
    AND ((mi.flex_type_cd+ 0)=mdf.flex_type_cd)
    AND mi.item_id=md.item_id)
   JOIN (b
   WHERE cnvtreal(trim(b.br_value))=outerjoin(md.item_id)
    AND b.br_nv_key1=outerjoin("MLTM_MMDC_IGN"))
  ORDER BY md.item_id, mdf.pharmacy_type_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_client->items,100)
  HEAD mi.item_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (tot_cnt > 100)
    stat = alterlist(temp_client->items,(cnt+ 100)), tot_cnt = 1
   ENDIF
   temp_client->items[cnt].item_id = md.item_id, len = textlen(md.cki), temp_client->items[cnt].mmdc
    = substring(12,len,md.cki)
   IF (b.br_name_value_id > 0)
    temp_client->items[cnt].ignore_ind = 1
   ENDIF
   IF (mdf.pharmacy_type_cd=inpatient_code_value)
    temp_client->items[cnt].ndc = mi.value_key, temp_client->items[cnt].inpatient_ind = 1
   ELSE
    temp_client->items[cnt].retail_ind = 1
    IF ((temp_client->items[cnt].inpatient_ind=0))
     temp_client->items[cnt].ndc = mi.value_key
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_client->items,cnt)
  WITH nocoutner
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    mltm_ndc_core_description m
   PLAN (d
    WHERE (temp_client->items[d.seq].ignore_ind IN (0, req_ign_ind)))
    JOIN (m
    WHERE (m.ndc_code=temp_client->items[d.seq].ndc)
     AND (cnvtstring(m.main_multum_drug_code) != temp_client->items[d.seq].mmdc))
   ORDER BY d.seq
   HEAD REPORT
    list_cnt = 0, tot_cnt = 0, stat = alterlist(reply->products,100)
   DETAIL
    list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (tot_cnt > 100)
     stat = alterlist(reply->products,(list_cnt+ 100)), tot_cnt = 1
    ENDIF
    reply->products[list_cnt].client.item_id = temp_client->items[d.seq].item_id, reply->products[
    list_cnt].client.mmdc = temp_client->items[d.seq].mmdc, reply->products[list_cnt].multum.mmdc =
    cnvtstring(m.main_multum_drug_code),
    reply->products[list_cnt].ignore_ind = temp_client->items[d.seq].ignore_ind, reply->products[
    list_cnt].inpatient_ind = temp_client->items[d.seq].inpatient_ind, reply->products[list_cnt].
    retail_ind = temp_client->items[d.seq].retail_ind
   FOOT REPORT
    stat = alterlist(reply->products,list_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (list_cnt > 0)
  SET stat = alterlist(reply->products,list_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = list_cnt),
    med_identifier m
   PLAN (d)
    JOIN (m
    WHERE (m.item_id=reply->products[d.seq].client.item_id)
     AND m.med_identifier_type_cd=desc_code_value
     AND m.med_product_id=0
     AND m.primary_ind=1)
   ORDER BY d.seq
   DETAIL
    reply->products[d.seq].display = m.value
   WITH nocoutner
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = list_cnt),
    medication_definition m,
    nomenclature n
   PLAN (d)
    JOIN (m
    WHERE (m.item_id=reply->products[d.seq].client.item_id))
    JOIN (n
    WHERE n.nomenclature_id=m.mdx_gfc_nomen_id)
   ORDER BY d.seq
   HEAD d.seq
    reply->products[d.seq].client.display = n.source_string
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = list_cnt),
    nomenclature n
   PLAN (d)
    JOIN (n
    WHERE (n.source_identifier=reply->products[d.seq].multum.mmdc)
     AND n.source_vocabulary_cd=mul_code_value
     AND n.primary_vterm_ind=1
     AND n.active_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq
   DETAIL
    reply->products[d.seq].multum.display = n.source_string
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (list_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
