CREATE PROGRAM afc_get_sched_dependencies:dba
 RECORD reply(
   1 sched_qual = i4
   1 tier_qual = i4
   1 sched_bill_item_qual[*]
     2 bill_item_id = f8
     2 ext_description = vc
   1 tier_matrix_qual[*]
     2 tier_col_num = i4
     2 tier_row_num = i4
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_group_desc = c60
     2 tier_group_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
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
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE priceschedmeaning = f8
 DECLARE schedcnt = i4
 SET code_set = 13036
 SET cdf_meaning = "PRICESCHED"
 SET schedcnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,schedcnt,priceschedmeaning)
 SET count1 = 0
 SET stat = alterlist(reply->sched_bill_item_qual,10)
 SELECT INTO "nl:"
  p.price_sched_id, b.ext_description
  FROM price_sched_items p,
   bill_item b
  PLAN (p
   WHERE (p.price_sched_id=request->price_sched_id)
    AND p.active_ind=1
    AND cnvtdatetime(curdate,curtime) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
   JOIN (b
   WHERE b.bill_item_id=p.bill_item_id)
  DETAIL
   count1 += 1, stat = alterlist(reply->sched_bill_item_qual,count1), reply->sched_bill_item_qual.
   bill_item_id = b.bill_item_id,
   reply->sched_bill_item_qual.ext_description = b.ext_description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sched_bill_item_qual,count1)
 SET reply->sched_qual = curqual
 SET count1 = 0
 SET stat = alterlist(reply->tier_matrix_qual,10)
 SELECT INTO "nl:"
  t.tier_cell_value
  FROM tier_matrix t
  WHERE (t.tier_cell_value=request->price_sched_id)
   AND t.tier_cell_type_cd=priceschedmeaning
   AND t.active_ind=1
   AND cnvtdatetime(curdate,curtime) BETWEEN t.beg_effective_dt_tm AND t.end_effective_dt_tm
  DETAIL
   count1 += 1, stat = alterlist(reply->tier_matrix_qual,count1), reply->tier_matrix_qual[count1].
   tier_col_num = t.tier_col_num,
   reply->tier_matrix_qual[count1].tier_row_num = t.tier_row_num, reply->tier_matrix_qual[count1].
   tier_group_cd = t.tier_group_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->tier_matrix_qual,count1)
 SET reply->tier_qual = curqual
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRICE_SCHED_ITEMS"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
