CREATE PROGRAM afc_rpt_description_exception:dba
 SELECT
  *
  FROM bill_item b,
   order_catalog o
  WHERE b.ext_child_reference_id=0
   AND b.ext_parent_reference_id=o.catalog_cd
   AND b.ext_short_desc != o.primary_mnemonic
   AND b.active_ind=1
  ORDER BY b.ext_parent_reference_id, b.ext_child_reference_id
  HEAD PAGE
   CALL center("* * *   B I L L   I T E M   D E S C R I P T I O N   E X C E P T I O N   * * *",5,119),
   row + 2, col 5,
   "Report Name: AFC_RPT_DESCRIPTION_EXCEPTION", row + 1, col 5,
   curdate"MM/DD/YY;;D", col + 1, curtime"HH:MM;;M",
   row + 1, line = fillstring(115,"=")
  DETAIL
   row + 1, col 5, "Bill Item Id :",
   col + 1, b.bill_item_id, row + 1,
   col + 5, line, row + 1,
   col 5, "LONG DESCRIPTION", col 30,
   b.ext_description
   "###############################################################################################",
   row + 1, col 5,
   "SHORT DESCRIPTION", col 30, b.ext_short_desc
   "################################################################################################",
   row + 1, col 5, "PRIMARY MNEMONIC",
   col 30, o.primary_mnemonic
   "##############################################################################################",
   row + 1
  FOOT PAGE
   col 117, "PAGE:", col + 1,
   curpage"###"
  FOOT REPORT
   row + 2, col + 5, "Total Number Of Bill Items =",
   count(b.bill_item_id)
 ;end select
END GO
