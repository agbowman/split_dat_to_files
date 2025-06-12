CREATE PROGRAM bhs_health_maint_security:dba
 EXECUTE ccl_prompt_api_dataset "noautoset"
 SET person_id = reqinfo->updt_id
 SET permission = 0
 IF (person_id IN (18380196, 749878, 589854))
  SET permission = 1
 ELSE
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.person_id=person_id
    AND p.position_cd IN (
   (SELECT
    c.code_value
    FROM code_value c
    WHERE c.code_value=p.position_cd
     AND c.display_key="*DBA*"
     AND c.active_ind=1))
   DETAIL
    permission = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (permission=0)
  SET stat = setvalidation(0)
  SET stat = setmessageboxex("You do NOT have sufficient privileges to run this program",
   "Permissions",mb_error)
 ELSE
  SET stat = setvalidation(1)
 ENDIF
END GO
