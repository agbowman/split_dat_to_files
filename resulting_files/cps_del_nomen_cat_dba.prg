CREATE PROGRAM cps_del_nomen_cat:dba
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
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 qual[*]
      2 failed = i4
      2 nomen_category_id = f8
  )
 ENDIF
 SET del_knt = size(request->deleteroot,5)
 SET knt = 0
 SET stat = alterlist(reply->qual,del_knt)
 SET reply->status_data.status = "F"
 SET table_name = "NOMEN_CATEGORY"
#top_for_loop
 SET knt += 1
 FOR (knt = knt TO del_knt)
   DELETE  FROM nomen_category nc
    WHERE (nc.nomen_category_id=request->deleteroot[knt].nomen_category_id)
    WITH nocounter
   ;end delete
   IF (curqual != 1)
    ROLLBACK
    SET reply->qual[knt].failed = delete_error
    SET reply->qual[knt].nomen_category_id = request->deleteroot[knt].nomen_category_id
    GO TO top_for_loop
   ELSE
    COMMIT
    SET reqinfo->commit_ind = 1
    SET reply->qual[knt].failed = false
    SET reply->qual[knt].nomen_category_id = request->deleteroot[knt].nomen_category_id
   ENDIF
   DELETE  FROM nomen_cat_list ncl
    WHERE (((ncl.parent_category_id=request->deleteroot[knt].nomen_category_id)) OR ((ncl
    .child_category_id=request->deleteroot[knt].nomen_category_id)))
    WITH nocounter
   ;end delete
   IF (curqual != 0)
    COMMIT
    SET reqinfo->commit_ind = 1
   ENDIF
 ENDFOR
END GO
