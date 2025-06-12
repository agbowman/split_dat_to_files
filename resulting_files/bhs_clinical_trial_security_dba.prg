CREATE PROGRAM bhs_clinical_trial_security:dba
 SET person_id = reqinfo->updt_id
 SET permission = "0"
 SELECT INTO "nl:"
  FROM prsnl p,
   code_value c
  PLAN (p
   WHERE p.person_id=person_id)
   JOIN (c
   WHERE c.code_value=p.position_cd
    AND c.active_ind=1)
  DETAIL
   IF (c.display_key IN ("*DBA*", "BHSRNSUPV"))
    permission = "1"
   ELSEIF (((c.display_key="BHSIRB") OR (p.username="EN44280")) )
    permission = "2"
   ELSE
    permission = "3"
   ENDIF
  WITH nocounter
 ;end select
 SET ccl_prompt_api_disable = 1
 SET ccl_prompt_api_misc = 1
 EXECUTE ccl_prompt_api_dataset "misc"
 SET stat = setmiscsize(_out_,1)
 SET stat = setmiscrecord(_out_,1,permission)
 SET stat = setstatus("s")
END GO
