CREATE PROGRAM bed_rec_erm_contacts:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM pm_flx_prompt p
  PLAN (p
   WHERE p.field="PERSON.NOK.*"
    AND p.parent_entity_name="PM_FLX_CONVERSATION"
    AND p.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    p2.prompt_id
    FROM pm_flx_prompt p2
    WHERE p2.parent_entity_id=p.parent_entity_id
     AND p2.field="PERSON.NOK.FREE_TEXT_PERSON_IND"
     AND p2.parent_entity_name="PM_FLX_CONVERSATION"
     AND p2.active_ind=1))))
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM pm_flx_prompt p
   PLAN (p
    WHERE p.field="PERSON.EMC.*"
     AND p.parent_entity_name="PM_FLX_CONVERSATION"
     AND p.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     p2.prompt_id
     FROM pm_flx_prompt p2
     WHERE p2.parent_entity_id=p.parent_entity_id
      AND p2.field="PERSON.EMC.FREE_TEXT_PERSON_IND"
      AND p2.parent_entity_name="PM_FLX_CONVERSATION"
      AND p2.active_ind=1))))
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
