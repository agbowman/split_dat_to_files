CREATE PROGRAM bed_rpt_rli_no_client_orders:dba
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE supplier_flag = i4
 DECLARE supplier_disp = vc
 SET supplier_flag = 2
 SET error_flag = "F"
 SET ordercnt = 0
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE brs.supplier_flag=supplier_flag)
  DETAIL
   supplier_disp = brs.supplier_name
  WITH nocounter
 ;end select
 SELECT
  FROM br_rli_client_orders b,
   br_auto_rli_order baro,
   dummyt d
  PLAN (b
   WHERE b.supplier_flag=supplier_flag
    AND b.active_ind=1
    AND b.status_flag=1)
   JOIN (d)
   JOIN (baro
   WHERE baro.alias_name=b.alias
    AND baro.supplier_flag=supplier_flag)
  HEAD REPORT
   row + 1, col 0, "Bedrock Report - Client Bid Sheet Orders Not in Autobuild",
   row + 1
  HEAD PAGE
   row + 1, col 0, "Reference Lab",
   col + 5, "Bid Sheet Alias Value", row + 1,
   col 0, "-------------", col + 5,
   "---------------------", row + 1
  DETAIL
   row + 1, col 0, supplier_disp,
   col 18, b.alias
  WITH outerjoin = d, dontexist, nocounter
 ;end select
#exit_script
END GO
