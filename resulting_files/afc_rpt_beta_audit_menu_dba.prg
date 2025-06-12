CREATE PROGRAM afc_rpt_beta_audit_menu:dba
 PAINT
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = 1111
 SET reqinfo->updt_applctx = 12
#menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,132)
 CALL text(2,1,"Account For Care Beta Implementation Audits",w)
 CALL text(06,20,"  1)   Different Owner Code Report")
 CALL text(08,20,"  2)   Order Catalog Items Don't Exist In Bill Item Table Report")
 CALL text(10,20,"  3)   Task Assay Items Don't Exist In Bill Item Table Report")
 CALL text(12,20,"  4)   Micro Task Items Don't Exist In Bill Item Table Report")
 CALL text(14,20,"  5)   Bill Item With No Active Order Catalog Item Report")
 CALL text(16,20,"  6)   Bill Item With No Active Task Assay Items Report")
 CALL text(18,20,"  7)   Bill Item With No Active Micro Task Items Report")
 CALL text(20,20,"  8)   ")
 CALL video(r)
 CALL text(20,25,"  Exit")
 CALL video(n)
 CALL text(24,2,"Select Option (1,2,3,4,5,6,7,8...)")
 CALL accept(24,36,"9;",8
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_diff_owner_code
  OF 2:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noexist_order_catalog
  OF 3:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noexist_task_assay
  OF 4:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noexist_mic_task
  OF 5:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noactive_order_catalog
  OF 6:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noactive_task_assay
  OF 7:
   CALL text(24,2,"Processing...")
   EXECUTE afc_rpt_noactive_mic_task
  OF 8:
   GO TO the_end
  ELSE
   GO TO the_end
 ENDCASE
 GO TO menu
#the_end
END GO
