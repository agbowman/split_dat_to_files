CREATE PROGRAM afc_get_tiermatrix_depend:dba
 RECORD reply(
   1 tmd_qual = i4
   1 qual[*]
     2 tier_cell_id = f8
     2 tier_group_cd = f8
     2 tier_group_disp = c40
     2 tier_cell_type_cd = f8
     2 updt_cnt = i4
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
 SET count1 = 0
 SET count2 = 0
 SET number_to_check = size(request->qual,5)
 CALL echo(build("Number of Columns to update: ",number_to_check))
 SET stat = alterlist(reply->qual,number_to_check)
 SELECT INTO "nl:"
  t.*
  FROM tier_matrix t,
   (dummyt d1  WITH seq = value(number_to_check))
  PLAN (d1)
   JOIN (t
   WHERE (t.tier_cell_type_cd=request->qual[d1.seq].code_value)
    AND t.active_ind=1)
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].tier_cell_id = t
   .tier_cell_id,
   CALL echo(build("Tier Cell Id: ",reply->qual[count1].tier_cell_id)), reply->qual[count1].
   tier_group_cd = t.tier_group_cd, reply->qual[count1].tier_cell_type_cd = t.tier_cell_type_cd,
   reply->qual[count1].updt_cnt = t.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET reply->tmd_qual = count1
 CALL echo(build("Number of Tier MAtrix rows affected by update: ",reply->tmd_qual))
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "TIER_MATRIX"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
