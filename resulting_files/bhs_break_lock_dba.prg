CREATE PROGRAM bhs_break_lock:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Personnel Person ID:" = 0,
  "Patient Cerner PID:" = 0
  WITH outdev, prompt2, prompt3
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
  SET msg = concat("Break Lock for ",pname)
 ENDIF
 UPDATE  FROM scd_story
  SET update_lock_dt_tm = null, update_lock_user_id = 0
  WHERE (update_lock_user_id= $2)
   AND (person_id= $3)
 ;end update
 COMMIT
#end_script
 SELECT INTO  $1
  FROM dummyt d
  HEAD REPORT
   col 10, msg, row + 1
  WITH nocounter
 ;end select
END GO
