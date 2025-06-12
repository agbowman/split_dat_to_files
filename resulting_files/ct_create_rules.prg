CREATE PROGRAM ct_create_rules
 PAINT
 SET fuser = 0.0
 SET cuser = curuser
 SELECT INTO "NL:"
  p.person_id
  FROM prsnl p
  WHERE ((p.email=cuser) OR (p.username=cuser))
  DETAIL
   fuser = p.person_id
  WITH nocounter
 ;end select
 IF (fuser=0)
  SET reqinfo->updt_id = 999999
 ELSE
  SET reqinfo->updt_id = fuser
 ENDIF
 SET reqinfo->updt_applctx = 0
 SET reqinfo->updt_task = 0
 SET v_name = fillstring(50," ")
 SET v_duration = 0.0
 SET v_beg_date = cnvtdatetime(curdate,curtime)
 SET v_end_date = cnvtdatetime("31-dec-2100 23:59")
 SET v_rule_type = 0.0
 SET v_rule_id = 0.0
 SET v_org_id = 0.0
 SET v_priority = 0
 SET v_healthplan_id = 0.0
 SET v_finclass_cd = 0.0
 SET v_encntrtype_cd = 0.0
 SET v_ruleset_cd = 0.0
 SET v_ruleset_id = 0.0
 SET v_org_name = fillstring(15," ")
#menu
 CALL clear(1,1)
 CALL text(1,1,"Charge Transformation",w)
 CALL box(3,1,15,80)
 CALL text(4,10,"1)  Rule ")
 CALL text(6,10,"2)  Ruleset (use CRMCode32.exe)")
 CALL text(8,10,"3)  Tier ")
 CALL text(10,10,"4)  Exit")
 CALL text(14,10,"Enter Choice:  ")
 CALL accept(14,24,"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CALL clear(16,1)
 CASE (curaccept)
  OF 1:
   GO TO ct_rule
  OF 2:
   EXECUTE FROM ct_ruleset TO ct_ruleset_end
  OF 3:
   EXECUTE ct_build_ruleset_tier
  OF 4:
   GO TO end_prg
 ENDCASE
 GO TO menu
#ct_rule
 CALL clear(1,1)
 CALL box(1,1,15,70)
 CALL text(2,8,"1) Rule ")
 CALL text(4,8,"2) Ruleset Rule Relation ")
 CALL text(6,8,"3) Create Rule Script ")
 CALL text(8,8,"4) Main Menu ")
 CALL text(10,8," Enter Choice:  ")
 CALL accept(10,23,"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CALL clear(16,1)
 CASE (curaccept)
  OF 1:
   EXECUTE ct_build_detail
  OF 2:
   EXECUTE ct_build_ruleset_rule
  OF 3:
   EXECUTE ct_create_script
  OF 4:
   GO TO menu
 ENDCASE
 GO TO ct_rule
#ct_ruleset
 EXECUTE afc_ccl_msgbox
 "Please use the front end tool CrmCode32.exe to create a new ruleset code value.", "", "OK"
#ct_ruleset_end
#end_prg
END GO
