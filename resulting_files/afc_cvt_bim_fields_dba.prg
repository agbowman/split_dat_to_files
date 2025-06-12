CREATE PROGRAM afc_cvt_bim_fields:dba
 SET addon = 0.0
 SET billcode = 0.0
 SET chargepoint = 0.0
 SET workload = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 13019
 SET code_value = 0.0
 SET cdf_meaning = "ADD ON"
 EXECUTE cpm_get_cd_for_cdf
 SET addon = code_value
 SET code_value = 0.0
 SET cdf_meaning = "BILL CODE"
 EXECUTE cpm_get_cd_for_cdf
 SET billcode = code_value
 SET code_value = 0.0
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 SET chargepoint = code_value
 SET code_value = 0.0
 SET cdf_meaning = "WORKLOAD"
 EXECUTE cpm_get_cd_for_cdf
 SET workload = code_value
 CALL echo("ADDON: ",0)
 CALL echo(addon)
 CALL echo("BILLCODE: ",0)
 CALL echo(billcode)
 CALL echo("CHARGEPOINT: ",0)
 CALL echo(chargepoint)
 CALL echo("WORKLOAD: ",0)
 CALL echo(workload)
 CALL echo("MOVING KEY3_ID TO BIM1_INT FOR ADD ON, BILL CODE AND CHARGE POINT...")
 UPDATE  FROM bill_item_modifier b
  SET b.bim1_int = b.key3_id
  WHERE b.bill_item_type_cd IN (addon, billcode, chargepoint)
   AND b.active_ind=1
   AND b.bim1_int=0
   AND b.key3_id != 0
  WITH nocounter
 ;end update
 CALL echo(build(curqual," RECORDS UPDATED"))
 CALL echo("MOVING KEY13_ID TO BIM_IND FOR WORKLOAD...")
 UPDATE  FROM bill_item_modifier b
  SET b.bim_ind = b.key13_id
  WHERE b.bill_item_type_cd=workload
   AND b.active_ind=1
   AND b.bim_ind=0
   AND b.key13_id != 0
  WITH nocounter
 ;end update
 CALL echo(build(curqual," RECORDS UPDATED"))
 CALL echo("MOVING KEY5_ID TO BIM1_NBR FOR WORKLOAD...")
 UPDATE  FROM bill_item_modifier b
  SET b.bim1_nbr = b.key5_id
  WHERE b.bill_item_type_cd=workload
   AND b.active_ind=1
   AND b.bim1_nbr=0
   AND b.key5_id != 0
  WITH nocounter
 ;end update
 CALL echo(build(curqual," RECORDS UPDATED"))
 CALL echo("MOVING KEY11_ID TO BIM2_INT FOR WORKLOAD...")
 UPDATE  FROM bill_item_modifier b
  SET b.bim2_int = b.key11_id
  WHERE b.bill_item_type_cd=workload
   AND b.active_ind=1
   AND b.bim2_int=0
   AND b.key11_id != 0
  WITH nocounter
 ;end update
 CALL echo(build(curqual," RECORDS UPDATED"))
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  CALL echo("Commit")
  COMMIT
 ELSE
  CALL echo("Type 'commit go' to commit changes")
 ENDIF
END GO
