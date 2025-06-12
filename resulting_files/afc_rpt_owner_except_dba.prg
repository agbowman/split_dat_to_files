CREATE PROGRAM afc_rpt_owner_except:dba
 IF (validate(file_name,"XXX")="XXX")
  SET file_name = "MINE"
 ENDIF
 SELECT INTO value(file_name)
  *
  FROM bill_item b,
   code_value cv
  WHERE b.ext_owner_cd=cv.code_value
   AND cv.code_set != 106
   AND b.active_ind=1
  ORDER BY b.ext_parent_reference_id, b.ext_child_reference_id
  HEAD PAGE
   CALL center("* * *   E X T E R N A L   O W N E R   C O D E   E X C E P T I O N   * * *",5,119),
   row + 2, col 5,
   "Report Name: AFC_RPT_OWNER_EXCEPT", row + 2, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   col 46, "External Owner", row + 1,
   col 5, "Bill Item Long Description", col 48,
   "Code Value", col 77, "Code Set",
   col 104, "Bill Item Id", row + 1,
   line = fillstring(115,"="), col 5, line,
   row + 1
  DETAIL
   IF (b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id=0)
    row + 1, col 5, b.ext_description"########################################"
   ELSEIF (b.ext_parent_reference_id != 0
    AND b.ext_child_reference_id != 0)
    col 10, b.ext_description"#######################################"
   ELSEIF (b.ext_parent_reference_id=0
    AND b.ext_child_reference_id != 0)
    col 10, b.ext_description"#######################################"
   ENDIF
   col 35, b.ext_owner_cd"###################", col 70,
   cv.code_set, col 100, b.bill_item_id,
   row + 1
  FOOT PAGE
   col 117, "PAGE:", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col + 5, "Total Number Of Bill Items =",
   count(b.bill_item_id)
 ;end select
END GO
