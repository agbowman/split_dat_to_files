CREATE PROGRAM afc_rdm_cea_db2:dba
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
 DECLARE max_charge_event_act_id = f8
 DECLARE min_charge_event_act_id = f8
 DECLARE start_value = f8 WITH protect, noconstant(0.0)
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  max_id = max(cea.charge_event_act_id), min_id = min(cea.charge_event_act_id)
  FROM charge_event_act cea
  WHERE cea.charge_event_act_id > 0
  DETAIL
   max_charge_event_act_id = max_id, min_charge_event_act_id = min_id
  WITH nocounter
 ;end select
 SET start_value = min_charge_event_act_id
 SET end_value = (start_value+ 5000)
 WHILE (start_value <= max_charge_event_act_id)
   UPDATE  FROM charge_event_act cea
    SET cea.item_ext_price = cea.cea_misc2_id, cea.item_price = cea.cea_misc4_id, cea.item_copay =
     cea.cea_misc5_id,
     cea.item_reimbursement = cea.cea_misc6_id, cea.discount_amount = cea.cea_misc7_id
    WHERE cea.charge_event_act_id >= start_value
     AND cea.charge_event_act_id <= end_value
    WITH nocounter
   ;end update
   SET errcode = error(rdm_errmsg,0)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = concat("Update failed: ",rdm_errmsg)
    GO TO exit_script
   ENDIF
   COMMIT
   SET start_value = (end_value+ 1)
   IF (((start_value+ 5000) <= max_charge_event_act_id))
    SET end_value = (start_value+ 5000)
   ELSE
    SET end_value = max_charge_event_act_id
   ENDIF
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Updated Successfully"
 CALL echo("Status is Successful")
#exit_script
 CALL echo("end of program")
 EXECUTE dm_readme_status
END GO
