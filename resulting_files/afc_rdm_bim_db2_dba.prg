CREATE PROGRAM afc_rdm_bim_db2:dba
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
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD bill_item_rec
 RECORD bill_item_rec(
   1 bill_item_mod[*]
     2 bill_item_mod_id = f8
     2 key5_id = f8
 )
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM bill_item_modifier bim
  WHERE (bim.bill_item_type_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13019
    AND cv.cdf_meaning="BILL CODE"))
   AND (bim.key1_id=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="HCPCS"))
   AND bim.key5_id > 0
  DETAIL
   count += 1, stat = alterlist(bill_item_rec->bill_item_mod,count), bill_item_rec->bill_item_mod[
   count].bill_item_mod_id = bim.bill_item_mod_id,
   bill_item_rec->bill_item_mod[count].key5_id = bim.key5_id
  WITH nocounter
 ;end select
 UPDATE  FROM bill_item_modifier bim,
   (dummyt d  WITH seq = value(size(bill_item_rec->bill_item_mod,5)))
  SET bim.bim1_nbr = bill_item_rec->bill_item_mod[d.seq].key5_id
  PLAN (d)
   JOIN (bim
   WHERE (bim.bill_item_mod_id=bill_item_rec->bill_item_mod[d.seq].bill_item_mod_id))
  WITH nocounter
 ;end update
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->message = concat("Update failed: ",rdm_errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Updated Successfully"
 CALL echo("Status is Successful")
#exit_script
 CALL echo("end of program")
 EXECUTE dm_readme_status
 FREE SET bill_item_rec
END GO
