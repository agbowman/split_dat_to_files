CREATE PROGRAM cp_get_order_info:dba
 RECORD reply(
   1 prsnl_person_id = f8
   1 unique_exam_nbr = vc
   1 result_code[*]
     2 result_cd = f8
     2 result_cd_disp = vc
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE chcs_cd = f8
 DECLARE total_remaining = i4
 DECLARE start_index = i4
 DECLARE occurances = i4
 DECLARE dispkeyval = c14
 SET dispkeyval = "CHCSORDERALIAS"
 SET start_index = 1
 SET occurances = 1
 SET stat = uar_get_code_list_by_dispkey(263,dispkeyval,start_index,occurances,total_remaining,
  chcs_cd)
 CALL echo(build("Stat: ",stat))
 CALL echo(build("Occurances returned: ",occurances))
 CALL echo(build("Total remaining: ",total_remaining))
 CALL echo(build("chcs_cd: ",chcs_cd))
 DECLARE activate_cd = f8
 DECLARE modify_cd = f8
 DECLARE order_cd = f8
 DECLARE renew_cd = f8
 DECLARE resume_cd = f8
 DECLARE stud_activate_cd = f8
 SET stat = uar_get_meaning_by_codeset(6003,"ACTIVATE",1,activate_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"MODIFY",1,modify_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,order_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RENEW",1,renew_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RESUME",1,resume_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"STUDACTIVATE",1,stud_activate_cd)
 SELECT INTO "nl:"
  FROM order_action oa
  PLAN (oa
   WHERE (oa.order_id=request->order_id)
    AND oa.action_type_cd IN (activate_cd, modify_cd, order_cd, renew_cd, resume_cd,
   stud_activate_cd))
  ORDER BY oa.action_sequence DESC
  HEAD REPORT
   actioncnt = 0
  DETAIL
   IF (actioncnt=0)
    actioncnt = 1, reply->prsnl_person_id = oa.order_provider_id, reply->action_dt_tm = oa
    .action_dt_tm,
    reply->action_tz = validate(oa.action_tz,0)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed = "S"
 ELSE
  SET failed = "Z"
 ENDIF
 SELECT INTO "nl:"
  pc.classification_cd
  FROM proc_classification pc
  WHERE (pc.order_id=request->order_id)
  HEAD pc.order_id
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,5)=1)
    stat = alterlist(reply->result_code,(count+ 4))
   ENDIF
   reply->result_code[count].result_cd = pc.classification_cd, reply->result_code[count].
   result_cd_disp = uar_get_code_display(pc.classification_cd)
  FOOT  pc.order_id
   stat = alterlist(reply->result_code,count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.alias
  FROM order_alias o
  PLAN (o
   WHERE (o.order_id=request->order_id)
    AND o.active_ind=1
    AND o.alias_pool_cd=chcs_cd)
  DETAIL
   reply->unique_exam_nbr = o.alias
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = failed
 CALL echorecord(reply)
END GO
