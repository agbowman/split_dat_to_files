CREATE PROGRAM afc_mov_bill_item_mod_back:dba
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
 CALL echo("Moving bim1_int back to key3_id for ADDON")
 UPDATE  FROM bill_item_modifier bm
  SET bm.key3_id = bm.bim1_int, bm.bim1_int = 0
  WHERE bm.bill_item_type_cd=addon
   AND bm.bim1_int > 0
  WITH nocounter
 ;end update
 CALL echo("Moving bim1_int back to key2_id for BILL CODE")
 UPDATE  FROM bill_item_modifier bm
  SET bm.key2_id = bm.bim1_int, bm.bim1_int = 0
  WHERE bm.bill_item_type_cd=bill_code
   AND bm.bim1_int > 0
  WITH nocounter
 ;end update
 CALL echo("Moving bim1_int back to key3_id for CHARGE POINT")
 UPDATE  FROM bill_item_modifier bm
  SET bm.key3_id = bm.bim1_int, bm.bim1_int = 0
  WHERE bm.bill_item_type_cd=charge_point
   AND bm.bim1_int > 0
  WITH nocounter
 ;end update
 CALL echo("Moving bim1_int back to key5_id and bim2_int back to key11_id for WORKLOAD")
 UPDATE  FROM bill_item_modifier bm
  SET bm.key5_id = bm.bim1_int, bm.bim1_int = 0
  WHERE bm.bill_item_type_cd=workload
   AND bm.bim1_int > 0
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item_modifier bm
  SET bm.key11_id = bm.bim2_int, bm.bim2_int = 0
  WHERE bm.bill_item_type_cd=workload
   AND bm.bim2_int > 0
  WITH nocounter
 ;end update
 CALL echo("Moving bim_ind back to key13_id for BARCODE")
 UPDATE  FROM bill_item_modifier bm
  SET bm.key13_id = bm.bim_ind, bm.bim_ind = 0
  WHERE bm.bill_item_type_cd=barcode
   AND m.bim_ind > 0
  WITH nocounter
 ;end update
 COMMIT
END GO
