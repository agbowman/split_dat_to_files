CREATE PROGRAM afc_convert_qcf_value:dba
 RECORD bim(
   1 bim_qual = i4
   1 bim_struct[*]
     2 bill_item_mod_id = f8
 )
 DECLARE bill_code = f8
 SET bill_code = 0.0
 SET count1 = 0
 SET stat = alterlist(bim->bim_struct,count1)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="BILL CODE"
   AND cv.active_ind=1
  DETAIL
   bill_code = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bill_item_modifier bim
  WHERE bim.bill_item_type_cd=bill_code
   AND (bim.key1_id=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="HCPCS"
    AND cv.active_ind=1))
   AND bim.key5_id IN (0, null)
   AND bim.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(bim->bim_struct,count1), bim->bim_struct[count1].
   bill_item_mod_id = bim.bill_item_mod_id
  WITH nocounter
 ;end select
 SET bim->bim_qual = count1
 CALL echo(build("NUMBER THAT QUALIFIED: ",count1))
 SET action_begin = 1
 SET action_end = bim->bim_qual
 FOR (x = action_begin TO action_end)
   UPDATE  FROM bill_item_modifier bim
    SET bim.key5_id = 1
    WHERE (bim.bill_item_mod_id=bim->bim_struct[x].bill_item_mod_id)
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
END GO
