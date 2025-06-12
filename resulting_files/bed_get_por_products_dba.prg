CREATE PROGRAM bed_get_por_products:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 active_ind = i2
     2 emar_ind = i2
     2 poc_ind = i2
     2 orderable
       3 catalog_code_value = f8
       3 primary_mnemonic = vc
     2 emar_mnemonic = vc
     2 ndc_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_items
 RECORD temp_items(
   1 items[*]
     2 item_id = f8
     2 description = vc
     2 active_ind = i2
     2 emar_ind = i2
     2 poc_ind = i2
     2 orderable
       3 catalog_code_value = f8
       3 primary_mnemonic = vc
     2 emar_mnemonic = vc
     2 ndc_value = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET desc_code_value = 0.0
 SET ndc_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("DESC", "NDC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DESC")
    desc_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="NDC")
    ndc_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET sys_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning="SYSTEM"
   AND cv.active_ind=1
  DETAIL
   sys_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET parse_txt = concat("cnvtupper(mi.value) = ",'"',trim(cnvtupper(request->search_string)),'*"')
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   med_identifier mi,
   med_identifier mi2,
   item_definition i,
   order_catalog oc,
   med_identifier ndc
  PLAN (ocir)
   JOIN (i
   WHERE i.item_id=ocir.item_id
    AND ((i.active_ind=1) OR ((request->return_inactive_ind=1))) )
   JOIN (mi
   WHERE mi.item_id=i.item_id
    AND ((mi.med_product_id=0) OR ((request->ident_type_code_value=ndc_code_value)))
    AND (mi.med_identifier_type_cd=request->ident_type_code_value)
    AND ((mi.active_ind=1) OR (i.active_ind=0))
    AND mi.primary_ind=1
    AND parser(parse_txt))
   JOIN (mi2
   WHERE mi2.item_id=mi.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=desc_code_value
    AND ((mi2.active_ind=1) OR (i.active_ind=0))
    AND mi2.primary_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd
    AND oc.active_ind=1)
   JOIN (ndc
   WHERE ndc.item_id=outerjoin(mi.item_id)
    AND ndc.med_identifier_type_cd=outerjoin(ndc_code_value)
    AND ndc.primary_ind=outerjoin(1))
  ORDER BY ocir.item_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_items->items,100)
  HEAD ocir.item_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_items->items,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_items->items[tot_cnt].item_id = ocir.item_id, temp_items->items[tot_cnt].active_ind = i
   .active_ind, temp_items->items[tot_cnt].orderable.catalog_code_value = ocir.catalog_cd,
   temp_items->items[tot_cnt].orderable.primary_mnemonic = oc.primary_mnemonic, temp_items->items[
   tot_cnt].description = mi2.value, temp_items->items[tot_cnt].ndc_value = ndc.value
  FOOT REPORT
   stat = alterlist(temp_items->items,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    synonym_item_r s
   PLAN (d)
    JOIN (s
    WHERE (s.item_id=temp_items->items[d.seq].item_id))
   ORDER BY d.seq
   HEAD d.seq
    temp_items->items[d.seq].poc_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt),
    medication_definition md,
    med_def_flex mdf,
    med_flex_object_idx mfoi,
    med_oe_defaults mod,
    order_catalog_synonym o
   PLAN (d)
    JOIN (md
    WHERE (md.item_id=temp_items->items[d.seq].item_id))
    JOIN (mdf
    WHERE mdf.item_id=md.item_id
     AND mdf.flex_type_cd=sys_code_value
     AND ((mdf.active_ind=1) OR ((request->return_inactive_ind=1))) )
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.parent_entity_name="MED_OE_DEFAULTS"
     AND ((mfoi.active_ind=1) OR ((request->return_inactive_ind=1))) )
    JOIN (mod
    WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
     AND mod.ord_as_synonym_id > 0
     AND ((mod.active_ind=1) OR ((request->return_inactive_ind=1))) )
    JOIN (o
    WHERE o.synonym_id=mod.ord_as_synonym_id)
   ORDER BY d.seq
   HEAD d.seq
    temp_items->items[d.seq].emar_ind = 1, temp_items->items[d.seq].emar_mnemonic = o.mnemonic
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_cnt)
   PLAN (d
    WHERE (((temp_items->items[d.seq].poc_ind=0)
     AND (temp_items->items[d.seq].emar_ind=0)) OR ((request->return_mapped_ind=1))) )
   ORDER BY d.seq
   HEAD REPORT
    dcnt = 0, stat = alterlist(reply->items,tot_cnt)
   HEAD d.seq
    dcnt = (dcnt+ 1), reply->items[dcnt].item_id = temp_items->items[d.seq].item_id, reply->items[
    dcnt].active_ind = temp_items->items[d.seq].active_ind,
    reply->items[dcnt].orderable.catalog_code_value = temp_items->items[d.seq].orderable.
    catalog_code_value, reply->items[dcnt].orderable.primary_mnemonic = temp_items->items[d.seq].
    orderable.primary_mnemonic, reply->items[dcnt].description = temp_items->items[d.seq].description,
    reply->items[dcnt].poc_ind = temp_items->items[d.seq].poc_ind, reply->items[dcnt].emar_ind =
    temp_items->items[d.seq].emar_ind, reply->items[dcnt].emar_mnemonic = temp_items->items[d.seq].
    emar_mnemonic,
    reply->items[dcnt].ndc_value = temp_items->items[d.seq].ndc_value
   FOOT REPORT
    stat = alterlist(reply->items,dcnt)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
