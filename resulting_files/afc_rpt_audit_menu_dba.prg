CREATE PROGRAM afc_rpt_audit_menu:dba
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
 CALL text(2,1,"Account For Care Reference Audits",w)
 CALL text(06,20,"  1)   Bill Items With Prices Report")
 CALL text(08,20,"  2)   Default Pricing Report")
 CALL text(10,20,"  3)   Bill Item References Report")
 CALL text(12,20,"  4)   Exception Reports")
 CALL text(14,20,"  5)   ")
 CALL video(r)
 CALL text(14,25,"  Exit")
 CALL video(n)
 CALL text(24,2,"Select Option (1,2,3,4,5...)")
 CALL accept(24,36,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   CALL clear(1,1)
   EXECUTE afc_rpt_priced_bill_items
  OF 2:
   EXECUTE afc_rpt_default_pricing
  OF 3:
   CALL clear(1,1)
   EXECUTE afc_rpt_bill_item_references
  OF 4:
   GO TO expand_menu
  OF 5:
   GO TO the_end
  ELSE
   GO TO the_end
 ENDCASE
 GO TO menu
#expand_menu
 CALL box(5,60,16,97)
 CALL text(6,63,"Exception Reports")
 CALL text(7,61,"____________________________________")
 CALL text(8,65," 1) External Owner Exception")
 CALL text(9,65," 2) Description Exception")
 CALL text(10,65," 3) Bill Code Exception")
 CALL text(11,65," 4) Price Exception")
 CALL text(12,65," 5) Exit")
 CALL text(14,63,"Select Option (1,2,3,4,5...)")
 CALL accept(14,95,"9;",5
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   CALL text(14,63,"                                 ")
   CALL text(14,63,"Loading Data...")
   EXECUTE afc_rpt_owner_except
  OF 2:
   CALL text(14,63,"                                 ")
   CALL text(14,63,"Loading Data...")
   EXECUTE afc_rpt_description_exception
  OF 3:
   CALL text(14,63,"                                 ")
   CALL text(14,63,"Loading Data...")
   EXECUTE afc_rpt_bill_code_exception
  OF 4:
   CALL text(14,63,"                                 ")
   CALL text(14,63,"Loading Data...")
   EXECUTE afc_rpt_price_exception
  OF 5:
   GO TO menu
  ELSE
   GO TO menu
 ENDCASE
 GO TO menu
#the_end
END GO
