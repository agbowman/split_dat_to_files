CREATE PROGRAM cps_get_alt_sel_cat:dba
 RECORD context(
   1 alt_sel_cat_id = f8
   1 sequence = i4
   1 synonym_id = f8
 )
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
     2 child_order_count = i4
     2 child_order_cat[*]
       3 child_sequence = i4
       3 child_alt_sel_cat_id = f8
       3 child_synonym_id = f8
       3 child_list_type = i4
       3 child_short_description = vc
       3 child_long_description = vc
       3 child_child_cat_ind = i2
       3 child_owner_id = f8
       3 child_security_flag = i2
     2 synonym_count = i4
     2 synonym[*]
       3 synonym_id = f8
       3 order_sentence_id = f8
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 oe_format_id = f8
       3 activity_type_cd = f8
       3 mnemonic = vc
       3 mnemonic_key_cap = vc
       3 mnemonic_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET count1 = 0
 SET count2 = 0
 SET stat = alterlist(reply->ord_cat,10)
 SET reply->ord_cat_qual = 0
 IF ((((request->alt_sel_list[1].get_alt_sel_cat > 0)) OR ((request->cont_alt_sel_cat_id > 0))) )
  SELECT
   IF ((request->cont_alt_sel_cat_id=1))
    PLAN (ac
     WHERE (ac.alt_sel_category_id > context->alt_sel_cat_id)
      AND ac.ahfs_ind IN (0, null)
      AND ac.adhoc_ind IN (0, null))
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (al
     WHERE ac.alt_sel_category_id=al.alt_sel_category_id
      AND al.synonym_id=0
      AND al.list_type=1)
     JOIN (d
     WHERE d.seq=1)
   ELSEIF ((request->alt_sel_list[1].alt_sel_cat_id=0))
    PLAN (d)
     JOIN (ac
     WHERE (ac.alt_sel_category_id > request->alt_sel_list[d.seq].alt_sel_cat_id)
      AND ac.ahfs_ind IN (0, null)
      AND ac.adhoc_ind IN (0, null))
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (al
     WHERE ac.alt_sel_category_id=al.alt_sel_category_id
      AND al.synonym_id=0
      AND al.list_type=1)
   ELSEIF ((request->alt_sel_list[1].alt_sel_cat_id > 0))
    PLAN (d)
     JOIN (ac
     WHERE (ac.alt_sel_category_id=request->alt_sel_list[d.seq].alt_sel_cat_id)
      AND ac.ahfs_ind IN (0, null)
      AND ac.adhoc_ind IN (0, null))
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (al
     WHERE ac.alt_sel_category_id=al.alt_sel_category_id
      AND al.synonym_id=0
      AND al.list_type=1)
   ELSE
   ENDIF
   INTO "NL:"
   FROM alt_sel_cat ac,
    alt_sel_list al,
    (dummyt d  WITH seq = value(request->alt_sel_qual)),
    (dummyt d2  WITH seq = 1)
   ORDER BY ac.alt_sel_category_id
   DETAIL
    count1 += 1
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(reply->ord_cat,(count1+ 9))
    ENDIF
    reply->ord_cat[count1].alt_sel_cat_id = ac.alt_sel_category_id, reply->ord_cat[count1].
    short_description = ac.short_description, reply->ord_cat[count1].long_description = ac
    .long_description,
    reply->ord_cat[count1].updt_cnt = ac.updt_cnt
    IF (al.list_type=1)
     reply->ord_cat[count1].child_cat_ind = 1
    ELSE
     reply->ord_cat[count1].child_cat_ind = 0
    ENDIF
    reply->ord_cat[count1].owner_id = ac.owner_id, reply->ord_cat[count1].security_flag = ac
    .security_flag
   FOOT REPORT
    stat = alterlist(reply->ord_cat,count1), reply->ord_cat_qual = count1,
    CALL echo(build("orders = ",count1),1)
   WITH check, nocounter, maxqual(ac,100),
    maxqual(al,1), outerjoin = d2
  ;end select
 ELSE
  SET stat = alterlist(reply->ord_cat,1)
  SET reply->ord_cat_qual = 1
 ENDIF
 IF ((request->alt_sel_list[1].alt_sel_cat_id != 0)
  AND (request->get_child_cat=1))
  SET count1 = 0
  SET count2 = 0
  SELECT INTO "NL:"
   alt_sel_id = request->alt_sel_list[1].alt_sel_cat_id
   FROM alt_sel_list al,
    alt_sel_cat ac2,
    alt_sel_list al2,
    (dummyt d  WITH seq = 1)
   PLAN (al
    WHERE (request->alt_sel_list[1].alt_sel_cat_id=al.alt_sel_category_id)
     AND al.synonym_id=0
     AND al.list_type=1)
    JOIN (ac2
    WHERE al.child_alt_sel_cat_id=ac2.alt_sel_category_id
     AND ac2.ahfs_ind IN (0, null)
     AND ac2.adhoc_ind IN (0, null))
    JOIN (d
    WHERE d.seq=1)
    JOIN (al2
    WHERE ac2.alt_sel_category_id=al2.alt_sel_category_id
     AND al2.synonym_id=0
     AND al2.list_type=1)
   ORDER BY ac2.alt_sel_category_id
   HEAD alt_sel_id
    count1 += 1
   DETAIL
    count2 += 1
    IF (count2 > size(reply->ord_cat[count1].child_order_cat,5))
     stat = alterlist(reply->ord_cat[count1].child_order_cat,(count2+ 9))
    ENDIF
    reply->ord_cat[count1].child_order_cat[count2].child_sequence = al.sequence, reply->ord_cat[
    count1].child_order_cat[count2].child_alt_sel_cat_id = al.child_alt_sel_cat_id, reply->ord_cat[
    count1].child_order_cat[count2].child_list_type = al.list_type,
    reply->ord_cat[count1].child_order_cat[count2].child_synonym_id = al.synonym_id, reply->ord_cat[
    count1].child_order_cat[count2].child_short_description = ac2.short_description, reply->ord_cat[
    count1].child_order_cat[count2].child_long_description = ac2.long_description,
    reply->ord_cat[count1].child_order_cat[count2].updt_cnt = ac2.updt_cnt,
    CALL echo(" ",1),
    CALL echo(build("Child_short Description = ",ac2.short_description),1),
    CALL echo(build("Alt List type = ",al2.list_type),1)
    IF (al2.list_type=1)
     reply->ord_cat[count1].child_order_cat[count2].child_child_cat_ind = 1
    ELSE
     reply->ord_cat[count1].child_order_cat[count2].child_child_cat_ind = 0
    ENDIF
    CALL echo(build("Child Cat Ind = ",reply->ord_cat[count1].child_order_cat[count2].
     child_child_cat_ind),1), reply->ord_cat[count1].child_order_cat[count2].child_owner_id = ac2
    .owner_id, reply->ord_cat[count1].child_order_cat[count2].child_security_flag = ac2.security_flag,
    row + 1
   FOOT REPORT
    reply->ord_cat[count1].child_order_count = count2, stat = alterlist(reply->ord_cat[count1].
     child_order_cat,count2)
   WITH check, outerjoin = d, maxqual(al2,1)
  ;end select
  CALL echo(build("children = ",count2),1)
 ENDIF
 SET context->alt_sel_cat_id = reply->ord_cat[reply->ord_cat_qual].alt_sel_cat_id
 SET context->sequence = reply->ord_cat[count1].child_order_cat[count2].child_sequence
 CALL echo(build("Context Alt_sel_cat_id = ",context->alt_sel_cat_id),1)
 CALL echo(build("Context Sequence = ",context->sequence),1)
 IF ((request->alt_sel_list[1].alt_sel_cat_id != 0)
  AND (request->get_synon=1))
  SET stat = alterlist(reply->ord_cat[1].synonym,10)
  SET count1 = 0
  SET count2 = 0
  SELECT
   IF ((request->cont_synon=1))
    PLAN (al
     WHERE (reqeust->alt_sel_list[1].alt_sel_cat_id=al.alt_sel_category_id)
      AND al.synonym_id > 0
      AND al.list_type=2)
     JOIN (os
     WHERE (context->synonym_id > os.synonym_id))
   ELSE
    PLAN (al
     WHERE (request->alt_sel_list[1].alt_sel_cat_id=al.alt_sel_category_id)
      AND al.synonym_id > 0
      AND al.list_type=2)
     JOIN (os
     WHERE al.synonym_id=os.synonym_id)
   ENDIF
   INTO "NL:"
   alt_sel_id = request->alt_sel_list[1].alt_sel_cat_id
   FROM alt_sel_list al,
    order_catalog_synonym os
   ORDER BY al.alt_sel_category_id
   HEAD alt_sel_id
    count1 += 1
   DETAIL
    count2 += 1
    IF (count2 > size(reply->ord_cat[count1].synonym,5))
     stat = alterlist(reply->ord_cat[count1].synonym,(count2+ 9))
    ENDIF
    reply->ord_cat[count1].synonym[count2].synonym_id = os.synonym_id, reply->ord_cat[count1].
    synonym[count2].order_sentence_id = os.order_sentence_id, reply->ord_cat[count1].synonym[count2].
    catalog_cd = os.catalog_cd,
    reply->ord_cat[count1].synonym[count2].catalog_type_cd = os.catalog_type_cd, reply->ord_cat[
    count1].synonym[count2].oe_format_id = os.oe_format_id, reply->ord_cat[count1].synonym[count2].
    activity_type_cd = os.activity_type_cd,
    reply->ord_cat[count1].synonym[count2].mnemonic = os.mnemonic, reply->ord_cat[count1].synonym[
    count2].mnemonic_key_cap = os.mnemonic_key_cap, reply->ord_cat[count1].synonym[count2].
    mnemonic_type_cd = os.mnemonic_type_cd,
    row + 1
   FOOT REPORT
    reply->ord_cat[count1].synonym_count = count2, stat = alterlist(reply->ord_cat[count1].synonym,
     count2),
    CALL echo(build("sysnonyms = ",count2),1)
   WITH check, nocounter, maxqual(os,100)
  ;end select
 ENDIF
 SET context->synonym_id = reply->ord_cat[reply->ord_cat_qual].synonym[count2].synonym_id
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
