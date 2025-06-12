CREATE PROGRAM afc_fix_bill_item_modifier:dba
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
 UPDATE  FROM bill_item_modifier bm
  SET bm.key1_entity_name = "BILL_ITEM", bm.key2_entity_name = "CODE_VALUE", bm.key3_entity_name =
   " ",
   bm.key4_entity_name = " ", bm.key5_entity_name = " "
  WHERE bm.bill_item_type_cd=addon
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item_modifier bm
  SET bm.key1_entity_name = "CODE_VALUE", bm.key2_entity_name = " ", bm.key3_entity_name =
   "NOMENCLATURE",
   bm.key4_entity_name = " ", bm.key5_entity_name = " "
  WHERE bm.bill_item_type_cd=bill_code
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item_modifier bm
  SET bm.key1_entity_name = "CODE_VALUE", bm.key2_entity_name = "CODE_VALUE", bm.key3_entity_name =
   " ",
   bm.key4_entity_name = "CODE_VALUE", bm.key5_entity_name = " "
  WHERE bm.bill_item_type_cd=charge_point
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item_modifier bm
  SET bm.key1_entity_name = "CODE_VALUE", bm.key2_entity_name = "CODE_VALUE", bm.key3_entity_name =
   "WORKLOAD_CODE",
   bm.key4_entity_name = " ", bm.key5_entity_name = " "
  WHERE bm.bill_item_type_cd=workload
  WITH nocounter
 ;end update
 UPDATE  FROM bill_item_modifier bm
  SET bm.key1_entity_name = "CODE_VALUE", bm.key2_entity_name = " ", bm.key3_entity_name = " ",
   bm.key4_entity_name = " ", bm.key5_entity_name = " "
  WHERE bm.bill_item_type_cd=barcode
  WITH nocounter
 ;end update
 COMMIT
END GO
