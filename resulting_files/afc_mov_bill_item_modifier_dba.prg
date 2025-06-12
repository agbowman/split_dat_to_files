CREATE PROGRAM afc_mov_bill_item_modifier:dba
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET addon = 0.0
 SET bill_code = 0.0
 SET charge_point = 0.0
 SET workload = 0.0
 SET barcode = 0.0
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "ADD ON"
 EXECUTE cpm_get_cd_for_cdf
 SET addon = code_value
 CALL echo(concat("ADDON: ",cnvtstring(addon)))
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bill_code = code_value
 CALL echo(concat("BILL_CODE: ",cnvtstring(bill_code)))
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET charge_point = code_value
 CALL echo(concat("CHARGE_POINT: ",cnvtstring(charge_point)))
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "WORKLOAD"
 EXECUTE cpm_get_cd_for_cdf
 SET workload = code_value
 CALL echo(concat("WORKLOAD: ",cnvtstring(workload)))
 SET code_value = 0.0
 SET code_set = 13019
 SET cdf_meaning = "BARCODE"
 EXECUTE cpm_get_cd_for_cdf
 SET barcode = code_value
 CALL echo(concat("BARCODE: ",cnvtstring(barcode)))
 CALL echo(" ")
 CALL echo("Moving key3_id to bim1_int for ADDON")
 UPDATE  FROM bill_item_modifier bm
  SET bm.bim1_int = bm.key3_id, bm.key3_id = 0
  WHERE bm.bill_item_type_cd=addon
  WITH nocounter
 ;end update
 CALL echo("Moving key2_id to bim1_int for BILL CODE")
 UPDATE  FROM bill_item_modifier bm
  SET bm.bim1_int = bm.key2_id, bm.key2_id = 0
  WHERE bm.bill_item_type_cd=bill_code
  WITH nocounter
 ;end update
 CALL echo("Moving key3_id to bim1_int for CHARGE POINT")
 UPDATE  FROM bill_item_modifier bm
  SET bm.bim1_int = bm.key3_id, bm.key3_id = 0
  WHERE bm.bill_item_type_cd=charge_point
  WITH nocounter
 ;end update
 CALL echo("Moving key5_id to bim1_int and key11_id to bim2_int")
 UPDATE  FROM bill_item_modifier bm
  SET bm.bim1_int = bm.key5_id, bm.bim2_int = bm.key11_id, bm.key5_id = 0,
   bm.key11_id = 0
  WHERE bm.bill_item_type_cd=workload
  WITH nocounter
 ;end update
 CALL echo("Moving key13_id to bim_ind")
 UPDATE  FROM bill_item_modifier bm
  SET bm.bim_ind = bm.key13_id, bm.key13_id = 0
  WHERE bm.bill_item_type_cd=barcode
  WITH nocounter
 ;end update
 COMMIT
END GO
