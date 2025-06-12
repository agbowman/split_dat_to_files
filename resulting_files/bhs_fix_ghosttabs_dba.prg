CREATE PROGRAM bhs_fix_ghosttabs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Prsnl ID:" = 0
  WITH outdev, prompt2
 DECLARE pname = vc
 DECLARE msg = vc
 SET userid = reqinfo->updt_id
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id= $PROMPT2)
   AND p.end_effective_dt_tm > sysdate
   AND p.active_ind=1
  DETAIL
   pname = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET msg = build("Person ID = ", $PROMPT2," qualified for muliple users. No changes made.")
  GO TO end_script
 ELSEIF (curqual=0)
  SET msg = build("No user qualified for person ID =", $PROMPT2,". No changes made.")
  GO TO end_script
 ELSEIF (curqual=1)
  SET msg = build2("PATLISTVIEW is removed for ",pname)
 ENDIF
 FREE SET request
 RECORD request(
   1 prsnl_id = f8
   1 viewname = vc
 )
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 updt_task = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = userid
 SET reqinfo->updt_task = 500017
 SET request->prsnl_id =  $PROMPT2
 SET request->viewname = "PATLISTVIEW"
 EXECUTE dcp_del_viewname_prefs
 COMMIT
#end_script
 SELECT INTO  $1
  FROM dummyt d
  HEAD REPORT
   col 10, msg, row + 1
  WITH nocounter
 ;end select
END GO
