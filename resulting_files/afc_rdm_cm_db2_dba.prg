CREATE PROGRAM afc_rdm_cm_db2:dba
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
 FREE RECORD charge_mod_rec
 RECORD charge_mod_rec(
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 field3_id = f8
 )
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM charge_mod cm
  WHERE (cm.charge_mod_type_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13019
    AND cv.cdf_meaning="BILL CODE"))
   AND (cm.field1_id=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="HCPCS"))
   AND cm.field3_id > 0
  DETAIL
   count += 1, stat = alterlist(charge_mod_rec->charge_mod,count), charge_mod_rec->charge_mod[count].
   charge_mod_id = cm.charge_mod_id,
   charge_mod_rec->charge_mod[count].field3_id = cm.field3_id
  WITH nocounter
 ;end select
 UPDATE  FROM charge_mod cm,
   (dummyt d  WITH seq = value(size(charge_mod_rec->charge_mod,5)))
  SET cm.cm1_nbr = charge_mod_rec->charge_mod[d.seq].field3_id, cm.field3_id = 0
  PLAN (d)
   JOIN (cm
   WHERE (cm.charge_mod_id=charge_mod_rec->charge_mod[d.seq].charge_mod_id))
  WITH nocounter
 ;end update
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  ROLLBACK
  SET readme_data->message = concat("Update failed: ",rdm_errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET create_trig = concat("	create or replace trigger TRG_CHARGE_MOD_QCF",
  "		before insert or update of field3_id on CHARGE_MOD","		for each row",
  "		declare code_value_1 number; code_value_2 number;","	 begin",
  "		select c.code_value into code_value_1 from code_value c where c.code_set = 13019 and c.cdf_meaning = 'BILL CODE';",
  "		select c.code_value into code_value_2 from code_value c where c.code_set = 14002 and c.cdf_meaning = 'HCPCS';",
  "		if (:new.charge_mod_type_cd = code_value_1 AND :new.field1_id = code_value_2 AND :new.cm1_nbr = 0) then",
  "			 :new.cm1_nbr := :new.field3_id;","		end if;",
  "    end;")
 CALL parser(concat("RDB ASIS (^",create_trig,"^) go"))
 IF (error(rdm_errmsg,1) != 0)
  SET readme_data->message = concat("Trigger failed: ",rdm_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "updated successfully"
 CALL echo("Status is Successful")
#exit_script
 CALL echo("end of program")
 EXECUTE dm_readme_status
 FREE SET charge_mod_rec
END GO
