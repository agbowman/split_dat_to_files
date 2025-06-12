CREATE PROGRAM cps_get_ord_cat_subact:dba
 FREE SET reply
 RECORD context(
   1 mnemonic_key_cap = vc
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
 )
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
     2 active_ind = i2
     2 activity_subtype_cd = f8
     2 orderable_type_flag = i2
     2 ref_text_mask = i4
     2 comment_template_flag = i2
     2 prep_info_flag = i2
     2 dup_checking_ind = i2
     2 cki = vc
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
 SELECT
  IF (context->mnemonic_key_cap)
   PLAN (o
    WHERE (o.mnemonic_key_cap > context->mnemonic_key_cap)
     AND (o.catalog_type_cd=context->catalog_type_cd)
     AND (o.activity_type_cd=context->activity_type_cd)
     AND (o.activity_subtype_cd=context->activity_subtype_cd)
     AND o.mnemonic_key_cap > " "
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF ((request->mnemonic_key_cap > " "))
   PLAN (o
    WHERE (o.catalog_type_cd=request->catalog_type_cd)
     AND (o.activity_type_cd=request->activity_type_cd)
     AND (o.activity_subtype_cd=request->activity_subtype_cd)
     AND (o.mnemonic_key_cap > request->mnemonic_key_cap)
     AND o.mnemonic_key_cap > " "
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSE
   PLAN (o
    WHERE (o.catalog_type_cd=request->catalog_type_cd)
     AND (o.activity_type_cd=request->activity_type_cd)
     AND (o.activity_subtype_cd=request->activity_subtype_cd)
     AND o.mnemonic_key_cap > " "
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ENDIF
  INTO "nl:"
  FROM order_catalog_synonym o,
   order_catalog oc
  HEAD REPORT
   count1 = 0
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
   mnemonic = o.mnemonic, reply->catalog_item[count1].mnemonic_type_cd = o.mnemonic_type_cd,
   reply->catalog_item[count1].active_ind = o.active_ind, reply->catalog_item[count1].
   activity_subtype_cd = o.activity_subtype_cd, reply->catalog_item[count1].orderable_type_flag = o
   .orderable_type_flag,
   reply->catalog_item[count1].ref_text_mask = oc.ref_text_mask, reply->catalog_item[count1].
   comment_template_flag = oc.comment_template_flag, reply->catalog_item[count1].prep_info_flag = oc
   .prep_info_flag,
   reply->catalog_item[count1].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[count1].
   cki = oc.cki
  FOOT REPORT
   stat = alterlist(reply->catalog_item,count1), reply->catalog_qual = count1, context->
   mnemonic_key_cap = reply->catalog_item[count1].mnemonic_key_cap,
   context->catalog_type_cd = reply->catalog_item[count1].catalog_cd, context->activity_type_cd =
   reply->catalog_item[count1].activity_type_cd, context->activity_subtype_cd = reply->catalog_item[
   count1].activity_subtype_cd
  WITH check, nocounter, maxqual(o,100)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
