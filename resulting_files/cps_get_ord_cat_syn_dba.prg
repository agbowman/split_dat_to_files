CREATE PROGRAM cps_get_ord_cat_syn:dba
 FREE SET reply
 RECORD reply(
   1 catalog_qual = i4
   1 catalog_item[*]
     2 synonym_id = f8
     2 order_sentence_id = f8
     2 catalog_cd = f8
     2 catalog_disp = c40
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = c40
     2 mnemonic = vc
     2 generic_mnemonic = vc
     2 mnemonic_type_cd = f8
     2 ref_text_mask = i4
     2 comment_template_flag = i2
     2 prep_info_flag = i2
     2 dup_checking_ind = i2
     2 orderable_type_flag = i2
     2 cki = vc
     2 synonym_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET reply->status_data[1].status = "F"
 SET reply->catalog_qual = 0
 SET context_ind = 0
 SET count1 = 0
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET context_ind = 1
 ELSE
  FREE SET context
  IF ((request->search_string > " "))
   SET target = cnvtupper(trim(request->search_string))
  ELSE
   SET target = " "
  ENDIF
  RECORD context(
    1 context_ind = i4
    1 mnemonic_key_cap = vc
    1 catalog_type_cd = f8
    1 activity_type_cd = f8
    1 activity_subtype_cd = f8
  )
 ENDIF
 IF (context_ind != 1
  AND (request->exact_ind=1))
  SELECT
   IF ((request->catalog_type_cd < 1)
    AND (request->activity_type_cd < 1)
    AND (request->activity_subtype_cd < 1))
    PLAN (o
     WHERE o.mnemonic_key_cap >= target
      AND o.active_ind=1
      AND o.hide_flag IN (0, null)
      AND o.orderable_type_flag IN (0, 1, 2, 6))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
   ELSEIF ((request->catalog_type_cd > 0)
    AND (request->activity_type_cd < 1)
    AND (request->activity_subtype_cd < 1))
    PLAN (o
     WHERE (o.catalog_type_cd=request->catalog_type_cd)
      AND o.mnemonic_key_cap >= target
      AND o.active_ind=1
      AND o.hide_flag IN (0, null)
      AND o.orderable_type_flag IN (0, 1, 2, 6))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
   ELSEIF ((request->catalog_type_cd > 0)
    AND (request->activity_type_cd > 0)
    AND (request->activity_subtype_cd < 1))
    PLAN (o
     WHERE (o.catalog_type_cd=request->catalog_type_cd)
      AND (o.activity_type_cd=request->activity_type_cd)
      AND o.mnemonic_key_cap >= target
      AND o.active_ind=1
      AND o.hide_flag IN (0, null)
      AND o.orderable_type_flag IN (0, 1, 2, 6))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
   ELSEIF ((request->catalog_type_cd > 0)
    AND (request->activity_type_cd > 0)
    AND (request->activity_subtype_cd > 0))
    PLAN (o
     WHERE (o.catalog_type_cd=request->catalog_type_cd)
      AND (o.activity_type_cd=request->activity_type_cd)
      AND (o.activity_subtype_cd=request->activity_subtype_cd)
      AND o.mnemonic_key_cap >= target
      AND o.active_ind=1
      AND o.hide_flag IN (0, null)
      AND o.orderable_type_flag IN (0, 1, 2, 6))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
   ELSE
    PLAN (o
     WHERE (o.synonym_id=- (7521)))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
   ENDIF
   INTO "nl:"
   FROM order_catalog_synonym o,
    order_catalog oc
   DETAIL
    count1 = 1, stat = alterlist(reply->catalog_item,count1), reply->catalog_item[count1].synonym_id
     = o.synonym_id,
    reply->catalog_item[count1].order_sentence_id = o.order_sentence_id, reply->catalog_item[count1].
    catalog_cd = o.catalog_cd, reply->catalog_item[count1].oe_format_id = o.oe_format_id,
    reply->catalog_item[count1].catalog_type_cd = o.catalog_type_cd, reply->catalog_item[count1].
    activity_type_cd = o.activity_type_cd, reply->catalog_item[count1].activity_subtype_cd = o
    .activity_subtype_cd,
    reply->catalog_item[count1].mnemonic = o.mnemonic, reply->catalog_item[count1].generic_mnemonic
     = oc.description, reply->catalog_item[count1].mnemonic_type_cd = o.mnemonic_type_cd,
    reply->catalog_item[count1].ref_text_mask = oc.ref_text_mask, reply->catalog_item[count1].
    comment_template_flag = oc.comment_template_flag, reply->catalog_item[count1].prep_info_flag = oc
    .prep_info_flag,
    reply->catalog_item[count1].dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[count1].
    orderable_type_flag = o.orderable_type_flag, reply->catalog_item[count1].cki = oc.cki,
    reply->catalog_item[count1].synonym_cki = o.cki, context->context_ind += 1, context->
    mnemonic_key_cap = o.mnemonic_key_cap,
    context->catalog_type_cd = request->catalog_type_cd, context->activity_type_cd = request->
    activity_type_cd, context->activity_subtype_cd = request->activity_subtype_cd,
    reply->catalog_qual = count1
   WITH check, maxqual(o,1), nocounter
  ;end select
  IF (curqual=0)
   SET context->context_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   GO TO exit_program
  ENDIF
 ENDIF
 SELECT
  IF (context_ind=1
   AND (context->catalog_type_cd < 1)
   AND (context->activity_type_cd < 1)
   AND (context->activity_subtype_cd < 1))
   PLAN (o
    WHERE (o.mnemonic_key_cap > context->mnemonic_key_cap)
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind=1
   AND (context->catalog_type_cd > 0)
   AND (context->activity_type_cd < 1)
   AND (context->activity_subtype_cd < 1))
   PLAN (o
    WHERE (o.catalog_type_cd=context->catalog_type_cd)
     AND (o.mnemonic_key_cap > context->mnemonic_key_cap)
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind=1
   AND (context->catalog_type_cd > 0)
   AND (context->activity_type_cd > 0)
   AND (context->activity_subtype_cd < 1))
   PLAN (o
    WHERE (o.catalog_type_cd=context->catalog_type_cd)
     AND (o.activity_type_cd=context->activity_type_cd)
     AND (o.mnemonic_key_cap > context->mnemonic_key_cap)
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind=1
   AND (context->catalog_type_cd > 0)
   AND (context->activity_type_cd > 0)
   AND (context->activity_subtype_cd > 0))
   PLAN (o
    WHERE (o.catalog_type_cd=context->catalog_type_cd)
     AND (o.activity_type_cd=context->activity_type_cd)
     AND (o.activity_subtype_cd=context->activity_subtype_cd)
     AND (o.mnemonic_key_cap > context->mnemonic_key_cap)
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind != 1
   AND (request->catalog_type_cd < 1)
   AND (request->activity_type_cd < 1)
   AND (request->activity_subtype_cd < 1))
   PLAN (o
    WHERE o.mnemonic_key_cap >= target
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind != 1
   AND (request->catalog_type_cd > 0)
   AND (request->activity_type_cd < 1)
   AND (request->activity_subtype_cd < 1))
   PLAN (o
    WHERE (o.catalog_type_cd=request->catalog_type_cd)
     AND o.mnemonic_key_cap >= target
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind != 1
   AND (request->catalog_type_cd > 0)
   AND (request->activity_type_cd > 0)
   AND (request->activity_subtype_cd < 1))
   PLAN (o
    WHERE (o.catalog_type_cd=request->catalog_type_cd)
     AND (o.activity_type_cd=request->activity_type_cd)
     AND o.mnemonic_key_cap >= target
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSEIF (context_ind != 1
   AND (request->catalog_type_cd > 0)
   AND (request->activity_type_cd > 0)
   AND (request->activity_subtype_cd > 0))
   PLAN (o
    WHERE (o.catalog_type_cd=request->catalog_type_cd)
     AND (o.activity_type_cd=request->activity_type_cd)
     AND (o.activity_subtype_cd=request->activity_subtype_cd)
     AND o.mnemonic_key_cap >= target
     AND o.active_ind=1
     AND o.hide_flag IN (0, null)
     AND o.orderable_type_flag IN (0, 1, 2, 6))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ELSE
   PLAN (o
    WHERE (o.synonym_id=- (7521)))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
  ENDIF
  INTO "nl:"
  FROM order_catalog_synonym o,
   order_catalog oc
  ORDER BY o.mnemonic_key_cap
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->catalog_item,10)
  DETAIL
   count1 += 1
   IF (count1 > size(reply->catalog_item,5))
    stat = alterlist(reply->catalog_item,(count1+ 9))
   ENDIF
   reply->catalog_item[count1].synonym_id = o.synonym_id, reply->catalog_item[count1].
   order_sentence_id = o.order_sentence_id, reply->catalog_item[count1].catalog_cd = o.catalog_cd,
   reply->catalog_item[count1].oe_format_id = o.oe_format_id, reply->catalog_item[count1].
   catalog_type_cd = o.catalog_type_cd, reply->catalog_item[count1].activity_type_cd = o
   .activity_type_cd,
   reply->catalog_item[count1].activity_subtype_cd = o.activity_subtype_cd, reply->catalog_item[
   count1].mnemonic = o.mnemonic, reply->catalog_item[count1].generic_mnemonic = oc.description,
   reply->catalog_item[count1].mnemonic_type_cd = o.mnemonic_type_cd, reply->catalog_item[count1].
   ref_text_mask = oc.ref_text_mask, reply->catalog_item[count1].comment_template_flag = oc
   .comment_template_flag,
   reply->catalog_item[count1].prep_info_flag = oc.prep_info_flag, reply->catalog_item[count1].
   dup_checking_ind = oc.dup_checking_ind, reply->catalog_item[count1].orderable_type_flag = o
   .orderable_type_flag,
   reply->catalog_item[count1].cki = oc.cki, reply->catalog_item[count1].synonym_cki = o.cki
  FOOT REPORT
   IF (count1=100)
    context->context_ind += 1, context->mnemonic_key_cap = o.mnemonic_key_cap, context->
    catalog_type_cd = request->catalog_type_cd,
    context->activity_type_cd = request->activity_type_cd, context->activity_subtype_cd = request->
    activity_subtype_cd
   ENDIF
   stat = alterlist(reply->catalog_item,count1), reply->catalog_qual = count1
  WITH check, maxqual(o,100), nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_program
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
END GO
