CREATE PROGRAM cps_get_ord_cat_cki:dba
 FREE SET reply
 RECORD reply(
   1 catalog_qual = i4
   1 catalog_item[*]
     2 synonym_id = f8
     2 order_sentence_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 mnemonic_key_cap = vc
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 active_ind = i2
     2 activity_subtype_cd = f8
     2 orderable_type_flag = i2
     2 hide_flag = i2
     2 source_vocab_mean = vc
     2 source_vocab_ident = vc
     2 cki = vc
     2 disable_order_comment_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET stat = alterlist(reply->catalog_item,10)
 SET reply->catalog_qual = 0
 SET cki = fillstring(100," ")
 SET count1 = 0
 IF ( NOT ((request->cki > " ")))
  SET request->cki = concat(trim(request->cki_source),"!",trim(request->cki_identifier))
 ENDIF
 SELECT
  IF ((request->cki > " "))
   PLAN (oc
    WHERE oc.cki=trim(request->cki))
    JOIN (o
    WHERE oc.catalog_cd=o.catalog_cd
     AND o.hide_flag IN (0, null)
     AND o.active_ind=1
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (c
    WHERE o.mnemonic_type_cd=c.code_value
     AND c.cdf_meaning="PRIMARY")
  ELSE
   PLAN (oc
    WHERE oc.source_vocab_ident=trim(request->cki_identifier)
     AND oc.source_vocab_mean=trim(request->cki_source))
    JOIN (o
    WHERE oc.catalog_cd=o.catalog_cd
     AND o.hide_flag IN (0, null)
     AND o.active_ind=1
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (c
    WHERE o.mnemonic_type_cd=c.code_value
     AND c.cdf_meaning="PRIMARY")
  ENDIF
  INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym o,
   code_value c
  DETAIL
   count1 += 1
   IF (count1 > size(reply->catalog_item,5))
    stat = alterlist(reply->catalog_item,(count1+ 9))
   ENDIF
   reply->catalog_item[count1].synonym_id = o.synonym_id, reply->catalog_item[count1].
   order_sentence_id = o.order_sentence_id, reply->catalog_item[count1].catalog_cd = o.catalog_cd,
   reply->catalog_item[count1].catalog_type_cd = o.catalog_type_cd, reply->catalog_item[count1].
   oe_format_id = o.oe_format_id, reply->catalog_item[count1].activity_type_cd = o.activity_type_cd,
   reply->catalog_item[count1].mnemonic_key_cap = o.mnemonic_key_cap, reply->catalog_item[count1].
   ordered_as_mnemonic = o.mnemonic, reply->catalog_item[count1].hna_order_mnemonic = oc
   .primary_mnemonic,
   reply->catalog_item[count1].mnemonic_type_cd = o.mnemonic_type_cd, reply->catalog_item[count1].
   active_ind = o.active_ind, reply->catalog_item[count1].activity_subtype_cd = o.activity_subtype_cd,
   reply->catalog_item[count1].orderable_type_flag = o.orderable_type_flag, reply->catalog_item[
   count1].hide_flag = o.hide_flag, reply->catalog_item[count1].source_vocab_mean = oc
   .source_vocab_mean,
   reply->catalog_item[count1].source_vocab_ident = oc.source_vocab_ident, reply->catalog_item[count1
   ].disable_order_comment_ind = oc.disable_order_comment_ind
   IF (o.cki > " ")
    reply->catalog_item[count1].cki = o.cki
   ELSE
    reply->catalog_item[count1].cki = request->cki
   ENDIF
  FOOT REPORT
   reply->catalog_qual = count1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->catalog_item,count1)
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "007 08/15/02 SF3151"
END GO
