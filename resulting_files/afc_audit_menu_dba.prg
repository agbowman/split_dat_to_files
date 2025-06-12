CREATE PROGRAM afc_audit_menu:dba
 PAINT
#menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Account For Care Charge Event Exception Audits",w)
 CALL text(06,20," 1)  Orders Audit")
 CALL text(08,20," 2)  Results Audit")
 CALL text(10,20," 3)  Micro Results Audit")
 CALL text(12,20," 4)  Blood Bank Transfusions Audit")
 CALL text(14,20," 5)  Specimen Collections Audit")
 CALL text(16,20," 6)  Duplicate Charges Report")
 CALL text(18,20," 7)  AFC Master")
 CALL text(20,20," 8)  ")
 CALL video(r)
 CALL text(20,25,"Exit")
 CALL video(n)
 CALL text(24,2,"Select Option (1,2,3...)")
 CALL accept(24,36,"9;",8
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8))
 CALL clear(24,1)
 CALL clear(1,1)
 CASE (curaccept)
  OF 1:
   EXECUTE afc_rpt_audit_orders
  OF 2:
   EXECUTE afc_rpt_audit_results
  OF 3:
   EXECUTE afc_rpt_audit_mic_results
  OF 4:
   EXECUTE afc_rpt_audit_bb_trans
  OF 5:
   EXECUTE afc_rpt_audit_spec_coll
  OF 6:
   EXECUTE afc_get_dup_charges
  OF 7:
   EXECUTE afc_master
  OF 8:
   GO TO the_end
  ELSE
   GO TO the_end
 ENDCASE
 GO TO menu
#the_end
END GO
