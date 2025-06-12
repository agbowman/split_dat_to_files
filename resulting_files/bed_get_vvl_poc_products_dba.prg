CREATE PROGRAM bed_get_vvl_poc_products:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 products[*]
       3 item_id = f8
       3 description = vc
       3 synonym_id = f8
       3 dosage_form_code_value = f8
       3 linked_products[*]
         4 item_id = f8
         4 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET rx_code_value = 0.0
 SET rx_code_value = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET orderable_code_value = 0.0
 SET orderable_code_value = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET inpatient_code_value = 0.0
 SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET sys_pkg_code_value = 0.0
 SET sys_pkg_code_value = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET system_code_value = 0.0
 SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET desc_code_value = 0.0
 SET desc_code_value = uar_get_code_by("MEANING",11000,"DESC")
 SET req_cnt = size(request->orders,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->orders,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
  ORDER BY d.seq
  DETAIL
   reply->orders[d.seq].catalog_code_value = request->orders[d.seq].catalog_code_value
  WITH nocounter
 ;end select
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog_item_r ocir,
   medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   item_definition id,
   med_identifier mi,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (ocir
   WHERE (ocir.catalog_cd=reply->orders[d.seq].catalog_code_value))
   JOIN (md
   WHERE ocir.item_id=md.item_id)
   JOIN (mdf
   WHERE md.item_id=mdf.item_id
    AND mdf.pharmacy_type_cd=inpatient_code_value
    AND mdf.flex_type_cd=sys_pkg_code_value)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND ((mfoi.flex_object_type_cd+ 0)=orderable_code_value)
    AND ((((mfoi.parent_entity_id+ 0) IN (0, request->facility_code_value))) OR ((request->
   ignore_facility_ind=1)))
    AND mfoi.active_ind=1)
   JOIN (id
   WHERE md.item_id=id.item_id
    AND ((id.active_ind+ 0)=1))
   JOIN (mi
   WHERE mi.item_id=id.item_id
    AND mi.pharmacy_type_cd=inpatient_code_value
    AND mi.med_identifier_type_cd=desc_code_value
    AND ((mi.flex_type_cd+ 0)=system_code_value)
    AND mi.primary_ind=1
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.active_ind+ 0)=1))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.item_id=mi.item_id
    AND ocs.mnemonic_type_cd=rx_code_value
    AND ocs.active_ind=1)
  ORDER BY d.seq, md.item_id
  HEAD d.seq
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[d.seq].products,100)
  HEAD md.item_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders[d.seq].products,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->orders[d.seq].products[tot_cnt].item_id = md.item_id, reply->orders[d.seq].products[tot_cnt
   ].description = mi.value, reply->orders[d.seq].products[tot_cnt].dosage_form_code_value = md
   .form_cd,
   reply->orders[d.seq].products[tot_cnt].synonym_id = ocs.synonym_id
  FOOT  d.seq
   stat = alterlist(reply->orders[d.seq].products,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
  SET pro_cnt = size(reply->orders[x].products,5)
  IF (pro_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(pro_cnt)),
     synonym_item_r sir,
     item_definition id,
     med_identifier mi
    PLAN (d)
     JOIN (sir
     WHERE (sir.synonym_id=reply->orders[x].products[d.seq].synonym_id))
     JOIN (id
     WHERE id.item_id=sir.item_id
      AND ((id.active_ind+ 0)=1))
     JOIN (mi
     WHERE mi.item_id=id.item_id
      AND mi.pharmacy_type_cd=inpatient_code_value
      AND mi.med_identifier_type_cd=desc_code_value
      AND ((mi.flex_type_cd+ 0)=system_code_value)
      AND mi.primary_ind=1
      AND ((mi.med_product_id+ 0)=0)
      AND ((mi.active_ind+ 0)=1))
    ORDER BY d.seq
    HEAD d.seq
     cnt = 0, tot_cnt = 0, stat = alterlist(reply->orders[x].products[d.seq].linked_products,10)
    DETAIL
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 10)
      stat = alterlist(reply->orders[x].products[d.seq].linked_products,(tot_cnt+ 10)), cnt = 1
     ENDIF
     reply->orders[x].products[d.seq].linked_products[tot_cnt].item_id = mi.item_id, reply->orders[x]
     .products[d.seq].linked_products[tot_cnt].description = mi.value
    FOOT  d.seq
     stat = alterlist(reply->orders[x].products[d.seq].linked_products,tot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
