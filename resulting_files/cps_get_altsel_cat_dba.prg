CREATE PROGRAM cps_get_altsel_cat:dba
 FREE SET reply
 RECORD reply(
   1 ord_cat_qual = i4
   1 ord_cat[*]
     2 alt_sel_cat_id = f8
     2 short_description = vc
     2 long_description = vc
     2 child_cat_ind = i2
     2 owner_id = f8
     2 security_flag = i2
     2 updt_cnt = i4
   1 more_syn = i2
   1 synonym_count = i4
   1 synonym[*]
     2 synonym_id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 mnemonic = vc
     2 mnemonic_key_cap = vc
     2 mnemonic_type_cd = f8
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 orderable_type_flag = i2
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
 SET stat = alterlist(reply->ord_cat,10)
 SET reply->ord_cat_qual = 0
 IF ((request->max_qual > 0))
  SET max_qual = (request->max_qual+ 1)
 ELSE
  SET max_qual = 101
 ENDIF
 SET count1 = 0
 SET dvar = 0
 IF (validate(context->sequence,0) != 0)
  SET context->alt_sel_cat_id = request->cat_list[1].alt_sel_cat_id
 ELSE
  FREE SET context
  RECORD context(
    1 alt_sel_cat_id = f8
    1 sequence = i4
  )
  SET context->alt_sel_cat_id = request->cat_list[1].alt_sel_cat_id
 ENDIF
 IF ((context->sequence > 0))
  CALL get_items(dvar)
 ELSEIF ((request->get_ind=0))
  CALL get_top_level(dvar)
 ELSEIF ((request->get_ind=1))
  CALL get_children(dvar)
  CALL get_items(dvar)
 ELSE
  CALL get_items(dvar)
 ENDIF
 GO TO end_program
 SUBROUTINE get_top_level(lvar)
  SELECT
   IF ((request->cat_list[1].alt_sel_cat_id=0))
    PLAN (d)
     JOIN (ac
     WHERE (ac.alt_sel_category_id > request->cat_list[d.seq].alt_sel_cat_id)
      AND ac.ahfs_ind IN (0, null)
      AND ac.adhoc_ind IN (0, null))
   ELSE
    PLAN (d)
     JOIN (ac
     WHERE (ac.alt_sel_category_id=request->cat_list[d.seq].alt_sel_cat_id)
      AND ac.ahfs_ind IN (0, null)
      AND ac.adhoc_ind IN (0, null))
   ENDIF
   INTO "nl:"
   ac.alt_sel_catageory
   FROM alt_sel_cat ac,
    (dummyt d  WITH seq = value(request->cat_list_qual))
   ORDER BY ac.alt_sel_category_id
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->ord_cat,10)
   DETAIL
    count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(reply->ord_cat,(count1+ 9))
    ENDIF
    reply->ord_cat[count1].alt_sel_cat_id = ac.alt_sel_category_id, reply->ord_cat[count1].
    short_description = ac.short_description, reply->ord_cat[count1].long_description = ac
    .long_description,
    reply->ord_cat[count1].child_cat_ind = ac.child_cat_ind, reply->ord_cat[count1].owner_id = ac
    .owner_id, reply->ord_cat[count1].security_flag = ac.security_flag,
    reply->ord_cat[count1].updt_cnt = ac.updt_cnt
   FOOT REPORT
    reply->ord_cat_qual = count1, stat = alterlist(reply->ord_cat,count1)
   WITH check, nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_children(lvar)
  SELECT INTO "nl:"
   al.alt_sel_category_id
   FROM alt_sel_list al,
    alt_sel_cat ac
   PLAN (al
    WHERE (al.alt_sel_category_id=request->cat_list[1].alt_sel_cat_id)
     AND al.list_type=1
     AND al.synonym_id < 1)
    JOIN (ac
    WHERE al.child_alt_sel_cat_id=ac.alt_sel_category_id
     AND ac.ahfs_ind IN (0, null)
     AND ac.adhoc_ind IN (0, null))
   ORDER BY al.alt_sel_category_id, al.sequence
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->ord_cat,10)
   DETAIL
    count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(reply->ord_cat,(count1+ 9))
    ENDIF
    reply->ord_cat[count1].alt_sel_cat_id = ac.alt_sel_category_id, reply->ord_cat[count1].
    short_description = ac.short_description, reply->ord_cat[count1].long_description = ac
    .long_description,
    reply->ord_cat[count1].child_cat_ind = ac.child_cat_ind, reply->ord_cat[count1].owner_id = ac
    .owner_id, reply->ord_cat[count1].security_flag = ac.security_flag,
    reply->ord_cat[count1].updt_cnt = ac.updt_cnt
   FOOT REPORT
    reply->ord_cat_qual = count1, stat = alterlist(reply->ord_cat,count1)
   WITH check, nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 END ;Subroutine
 SUBROUTINE get_items(lvar)
  SELECT
   IF ((context->sequence > 0))
    PLAN (al
     WHERE (al.alt_sel_category_id=context->alt_sel_cat_id)
      AND (al.sequence > context->sequence)
      AND al.list_type=2
      AND al.synonym_id > 0)
     JOIN (os
     WHERE os.synonym_id=al.synonym_id)
     JOIN (oc
     WHERE os.catalog_cd=oc.catalog_cd)
   ELSE
    PLAN (al
     WHERE (al.alt_sel_category_id=request->cat_list[1].alt_sel_cat_id)
      AND (al.sequence > request->cat_list[1].sequence)
      AND al.list_type=2
      AND al.synonym_id > 0)
     JOIN (os
     WHERE os.synonym_id=al.synonym_id)
     JOIN (oc
     WHERE os.catalog_cd=oc.catalog_cd)
   ENDIF
   INTO "nl:"
   al.alt_sel_category_id, al.sequence
   FROM alt_sel_list al,
    order_catalog_synonym os,
    order_catalog oc
   ORDER BY al.alt_sel_category_id, al.sequence
   HEAD REPORT
    count1 = 0, stat = alterlist(reply->synonym,10)
   DETAIL
    count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(reply->synonym,(count1+ 9))
    ENDIF
    reply->synonym[count1].synonym_id = os.synonym_id, reply->synonym[count1].sequence = al.sequence,
    reply->synonym[count1].order_sentence_id = os.order_sentence_id,
    reply->synonym[count1].catalog_cd = os.catalog_cd, reply->synonym[count1].catalog_type_cd = os
    .catalog_type_cd, reply->synonym[count1].oe_format_id = os.oe_format_id,
    reply->synonym[count1].activity_type_cd = os.activity_type_cd, reply->synonym[count1].mnemonic =
    os.mnemonic, reply->synonym[count1].mnemonic_key_cap = os.mnemonic_key_cap,
    reply->synonym[count1].mnemonic_type_cd = os.mnemonic_type_cd, reply->synonym[count1].
    ref_text_mask = os.ref_text_mask, reply->synonym[count1].prep_info_flag = oc.prep_info_flag,
    reply->synonym[count1].orderable_type_flag = oc.orderable_type_flag
   FOOT REPORT
    IF (count1 >= max_qual)
     reply->more_syn = 1, reply->synonym_count = (count1 - 1), stat = alterlist(reply->synonym,(
      count1 - 1)),
     context->sequence = reply->synonym[(count1 - 1)].sequence
    ELSE
     reply->more_syn = 0, reply->synonym_count = count1, stat = alterlist(reply->synonym,count1),
     context->sequence = reply->synonym[(count1 - 1)].sequence
    ENDIF
   WITH nocounter, maxqual(al,value(max_qual))
  ;end select
  IF ((reply->status_data.status != "S"))
   IF (curqual > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 END ;Subroutine
#end_program
END GO
