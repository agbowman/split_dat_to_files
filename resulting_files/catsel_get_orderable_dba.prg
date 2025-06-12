CREATE PROGRAM catsel_get_orderable:dba
 RECORD reply(
   1 synonym_id = f8
   1 catalog_cd = f8
   1 catalog_type_cd = f8
   1 mnemonic = vc
   1 mnemonic_type_cd = f8
   1 oe_format_id = f8
   1 order_sentence_id = f8
   1 order_sentence_display_line = vc
   1 active_ind = i2
   1 activity_type_cd = f8
   1 orderable_type_flag = i2
   1 multiple_ord_sent_ind = i2
   1 clin_cat_cd = f8
   1 rx_mask = i4
   1 ref_text_mask = i4
   1 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SELECT INTO "NL:"
  ocs.synonym_id, ocs.order_sentence_id, ocs.catalog_cd,
  ocs.catalog_type_cd, ocs.mnemonic, ocs.oe_format_id,
  ocs.activity_type_cd, ocs.mnemonic_type_cd, ocs.orderable_type_flag,
  os.order_sentence_id, os.order_sentence_display_line, oc.order_catalog_cd,
  oc.cki
  FROM order_catalog_synonym ocs,
   dummyt d,
   order_sentence os,
   order_catalog oc
  PLAN (ocs
   WHERE (ocs.synonym_id=request->synonymid))
   JOIN (d)
   JOIN (os
   WHERE os.order_sentence_id=ocs.order_sentence_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  DETAIL
   reply->synonym_id = ocs.synonym_id, reply->active_ind = ocs.active_ind, reply->catalog_cd = ocs
   .catalog_cd,
   reply->oe_format_id = ocs.oe_format_id, reply->catalog_type_cd = ocs.catalog_type_cd, reply->
   order_sentence_id = ocs.order_sentence_id,
   reply->mnemonic = ocs.mnemonic, reply->mnemonic_type_cd = ocs.mnemonic_type_cd, reply->
   activity_type_cd = ocs.activity_type_cd,
   reply->order_sentence_display_line = os.order_sentence_display_line, reply->orderable_type_flag =
   ocs.orderable_type_flag, reply->multiple_ord_sent_ind = ocs.multiple_ord_sent_ind,
   reply->clin_cat_cd = ocs.dcp_clin_cat_cd, reply->rx_mask = ocs.rx_mask, reply->ref_text_mask = ocs
   .ref_text_mask,
   reply->cki = oc.cki
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG_SYNONYM"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
