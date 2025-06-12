CREATE PROGRAM dcp_get_pw_comp_id:dba
 SET modify = predeclare
 DECLARE order_create_meaning = c12 WITH protect, constant("ORDER CREATE")
 DECLARE outcome_create_meaning = c12 WITH protect, constant("OUTCOME CREA")
 DECLARE task_create_meaning = c12 WITH protect, constant("TASK CREATE")
 DECLARE plan_ref_meaning = c12 WITH protect, constant("PLAN REF")
 DECLARE plan_act_meaning = c12 WITH protect, constant("PLAN ACT")
 DECLARE problem_meaning = c12 WITH protect, constant("PROBLEM")
 DECLARE reference_seq = c12 WITH protect, constant("REF_SEQ")
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE id_count = i2 WITH protect, constant(value(request->id_count))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (((trim(request->comp_type_meaning)=trim(order_create_meaning)) OR (((trim(request->
  comp_type_meaning)=trim(outcome_create_meaning)) OR (((trim(request->comp_type_meaning)=trim(
  task_create_meaning)) OR (((trim(request->comp_type_meaning)=trim(plan_ref_meaning)) OR (((trim(
  request->comp_type_meaning)=trim(plan_act_meaning)) OR (((trim(request->comp_type_meaning)=trim(
  problem_meaning)) OR (trim(request->comp_type_meaning)=trim(reference_seq))) )) )) )) )) )) )
  SET failed = "F"
 ELSE
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 id_list[*]
      2 id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->id_list,id_count)
 FOR (x = 1 TO id_count)
  SELECT
   IF ((((request->comp_type_meaning=order_create_meaning)) OR ((request->comp_type_meaning=
   outcome_create_meaning))) )
    y = seq(order_seq,nextval)
   ELSEIF ((((request->comp_type_meaning=task_create_meaning)) OR ((request->comp_type_meaning=
   plan_act_meaning))) )
    y = seq(carenet_seq,nextval)
   ELSEIF ((((request->comp_type_meaning=plan_ref_meaning)) OR ((request->comp_type_meaning=
   reference_seq))) )
    y = seq(reference_seq,nextval)
   ELSEIF ((request->comp_type_meaning=problem_meaning))
    y = seq(problem_seq,nextval)
   ELSE
   ENDIF
   INTO "nl:"
   FROM dual
   DETAIL
    reply->id_list[x].id = y
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL report_failure("NEXTVAL","F","DCP_GET_PW_COMP_ID",
    "Failed to get a unique sequence number to identify new record")
   GO TO exit_script
  ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET failed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alter(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrcnt <= 50)
   SET lerrcnt = (lerrcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_GET_PW_COMP_ID",trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "006"
 SET mod_date = "July 20, 2011"
END GO
