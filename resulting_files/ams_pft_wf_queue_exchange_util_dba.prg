CREATE PROGRAM ams_pft_wf_queue_exchange_util:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Criteria:" = 0,
  "Queues:" = 0,
  "Specifier:" = 0,
  "Search for existing user:" = "",
  "Existing user:" = 0,
  "Search for new user:" = "",
  "New user:" = 0
  WITH outdev, entitytypecd, entitystatuscd,
  queueassignid, oldusersearch, olduserid,
  newusersearch, newuserid
 EXECUTE ams_define_toolkit_common
 DECLARE populaterequest(null) = null WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_PFT_WF_QUEUE_EXCHANGE_UTIL")
 DECLARE queuecnt = i4 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE amsuser = i2 WITH protect
 DECLARE newusername = vc WITH protect
 DECLARE listcheck = c1 WITH protect
 DECLARE listcnt = i4 WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE currrow = i4 WITH protect
 DECLARE prevtask = i4 WITH protect
 IF (validate(debug,0)=0)
  DECLARE debug = i2 WITH protect, noconstant(0)
 ENDIF
 RECORD input_queues(
   1 list_sz = i4
   1 list[*]
     2 pft_queue_assignment_id = f8
 ) WITH protect
 RECORD queues(
   1 list[*]
     2 pft_queue_assignment_id = f8
     2 assigned_prsnl_id = f8
     2 old_user_name_full_formatted = vc
     2 pft_entity_type_cd = f8
     2 pft_entity_status_cd = f8
     2 assigned_prsnl_group_id = f8
     2 contributor_system_cd = f8
     2 value_specifier_cd = f8
     2 value_text = vc
     2 value_display_txt = vc
     2 value_range_txt = vc
     2 level = i2
     2 sequence = i2
 ) WITH protect
 RECORD pft_request(
   1 action = vc
   1 queue_data[*]
     2 contributor_system_cd = f8
     2 pft_queue_assignment_id = f8
     2 pft_entity_type_cd = f8
     2 pft_entity_status_cd = f8
     2 value_specifier_cd = f8
     2 person_id = f8
     2 assigned_prsnl_group_id = f8
     2 value_txt = vc
     2 value_display_txt = vc
     2 value_range_txt = vc
     2 level = i2
     2 sequence = i2
 ) WITH protect
 RECORD pft_reply(
   1 queue_data[*]
     2 contributor_system_cd = f8
     2 pft_queue_assignment_id = f8
     2 pft_entity_type_cd = f8
     2 pft_entity_status_cd = f8
     2 value_specifier_cd = f8
     2 person_id = f8
     2 contributor_system_disp = vc
     2 person_name = vc
     2 value_txt = vc
     2 value_display_txt = vc
     2 value_range_txt = vc
     2 level = i2
     2 sequence = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (debug=1)
  CALL echo(build2("*** Beginning ",script_name," ***"))
 ENDIF
 IF (isamsuser(reqinfo->updt_id)=0)
  SET amsuser = 0
  GO TO exit_script
 ELSE
  SET amsuser = 1
 ENDIF
 SET listcnt = 0
 SET listcheck = substring(1,1,reflect(parameter(4,0)))
 IF (debug=1)
  CALL echo("Determining if specifiers list box was multi-selected")
  CALL echo(build2("listCheck =  ",listcheck))
 ENDIF
 IF (listcheck="L")
  WHILE (listcheck > " ")
    SET listcnt = (listcnt+ 1)
    SET listcheck = substring(1,1,reflect(parameter(4,listcnt)))
    IF (listcheck="F")
     SET input_queues->list_sz = (input_queues->list_sz+ 1)
     SET stat = alterlist(input_queues->list,input_queues->list_sz)
     SET input_queues->list[input_queues->list_sz].pft_queue_assignment_id = parameter(4,listcnt)
    ENDIF
  ENDWHILE
 ELSEIF (parameter(4,0) > 0.0)
  SET input_queues->list_sz = 1
  SET stat = alterlist(input_queues->list,input_queues->list_sz)
  SET input_queues->list[input_queues->list_sz].pft_queue_assignment_id =  $QUEUEASSIGNID
 ENDIF
 IF (debug=1)
  CALL echorecord(input_queues)
 ENDIF
 SELECT
  IF (( $QUEUEASSIGNID=0.0))
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
    JOIN (pqa
    WHERE pqa.logical_domain_id=p.logical_domain_id
     AND (pqa.pft_entity_type_cd= $ENTITYTYPECD)
     AND (((pqa.pft_entity_status_cd= $ENTITYSTATUSCD)) OR (( $ENTITYSTATUSCD=0.0)))
     AND (pqa.assigned_prsnl_id= $OLDUSERID)
     AND ( $OLDUSERID != 0.0))
    JOIN (pqa2
    WHERE pqa2.pft_queue_assignment_id=pqa.pft_queue_assignment_id)
    JOIN (p2
    WHERE p2.person_id=pqa2.assigned_prsnl_id)
  ELSEIF ((input_queues->list_sz=1))
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
    JOIN (pqa
    WHERE pqa.logical_domain_id=p.logical_domain_id
     AND (pqa.pft_entity_type_cd= $ENTITYTYPECD)
     AND (((pqa.pft_entity_status_cd= $ENTITYSTATUSCD)) OR (( $ENTITYSTATUSCD=0.0)))
     AND (pqa.pft_queue_assignment_id= $QUEUEASSIGNID)
     AND (pqa.assigned_prsnl_id !=  $NEWUSERID))
    JOIN (pqa2
    WHERE pqa2.pft_entity_type_cd=pqa.pft_entity_type_cd
     AND pqa2.pft_entity_status_cd=pqa.pft_entity_status_cd
     AND pqa2.value_specifier_cd=pqa.value_specifier_cd
     AND pqa2.level_nbr=pqa.level_nbr
     AND pqa2.sequence_nbr=pqa.sequence_nbr
     AND pqa2.assigned_prsnl_id=pqa.assigned_prsnl_id
     AND pqa2.contributor_system_cd=pqa.contributor_system_cd
     AND pqa2.assigned_prsnl_group_id=pqa.assigned_prsnl_group_id)
    JOIN (p2
    WHERE p2.person_id=pqa2.assigned_prsnl_id)
  ELSE
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id))
    JOIN (pqa
    WHERE pqa.logical_domain_id=p.logical_domain_id
     AND (pqa.pft_entity_type_cd= $ENTITYTYPECD)
     AND (((pqa.pft_entity_status_cd= $ENTITYSTATUSCD)) OR (( $ENTITYSTATUSCD=0.0)))
     AND expand(i,1,input_queues->list_sz,pqa.pft_queue_assignment_id,input_queues->list[i].
     pft_queue_assignment_id)
     AND (pqa.assigned_prsnl_id !=  $NEWUSERID))
    JOIN (pqa2
    WHERE pqa2.pft_entity_type_cd=pqa.pft_entity_type_cd
     AND pqa2.pft_entity_status_cd=pqa.pft_entity_status_cd
     AND pqa2.value_specifier_cd=pqa.value_specifier_cd
     AND pqa2.level_nbr=pqa.level_nbr
     AND pqa2.sequence_nbr=pqa.sequence_nbr
     AND pqa2.assigned_prsnl_id=pqa.assigned_prsnl_id
     AND pqa2.contributor_system_cd=pqa.contributor_system_cd
     AND pqa2.assigned_prsnl_group_id=pqa.assigned_prsnl_group_id)
    JOIN (p2
    WHERE p2.person_id=pqa2.assigned_prsnl_id)
  ENDIF
  INTO "nl:"
  pqa.pft_queue_assignment_id
  FROM prsnl p,
   pft_queue_assignment pqa,
   pft_queue_assignment pqa2,
   prsnl p2
  ORDER BY pqa2.level_nbr, pqa2.value_specifier_cd, pqa2.sequence_nbr
  DETAIL
   queuecnt = (queuecnt+ 1)
   IF (mod(queuecnt,10)=1)
    stat = alterlist(queues->list,(queuecnt+ 9))
   ENDIF
   queues->list[queuecnt].pft_queue_assignment_id = pqa2.pft_queue_assignment_id, queues->list[
   queuecnt].assigned_prsnl_id = pqa2.assigned_prsnl_id, queues->list[queuecnt].
   old_user_name_full_formatted = p2.name_full_formatted,
   queues->list[queuecnt].assigned_prsnl_group_id = pqa2.assigned_prsnl_group_id, queues->list[
   queuecnt].contributor_system_cd = pqa2.contributor_system_cd, queues->list[queuecnt].
   pft_entity_type_cd = pqa2.pft_entity_type_cd,
   queues->list[queuecnt].pft_entity_status_cd = pqa2.pft_entity_status_cd, queues->list[queuecnt].
   value_specifier_cd = pqa2.value_specifier_cd, queues->list[queuecnt].value_text = pqa2.value_txt,
   queues->list[queuecnt].value_display_txt = pqa2.value_display_txt, queues->list[queuecnt].
   value_range_txt = pqa2.value_range_txt, queues->list[queuecnt].level = pqa2.level_nbr,
   queues->list[queuecnt].sequence = pqa2.sequence_nbr
  FOOT REPORT
   IF (mod(queuecnt,10) != 0)
    stat = alterlist(queues->list,queuecnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (debug=1)
  CALL echo(build2("queueCnt = ",queuecnt))
  CALL echorecord(queues)
 ENDIF
 IF (queuecnt > 0)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id= $NEWUSERID))
   DETAIL
    newusername = p.name_full_formatted
   WITH nocounter
  ;end select
  CALL populaterequest(null)
  SET prevtask = reqinfo->updt_task
  SET reqinfo->updt_task = - (3070001)
  EXECUTE pft_wf_queue_assignment  WITH replace("REQUEST",pft_request), replace("REPLY",pft_reply)
  SET reqinfo->updt_task = prevtask
  IF (debug=1)
   CALL echorecord(pft_reply)
  ENDIF
  CALL updtdminfo(script_name,cnvtreal(queuecnt))
  IF ((pft_reply->status_data.status="S"))
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
#exit_script
 SET currrow = 1
 SELECT INTO  $OUTDEV
  FROM dummyt d
  DETAIL
   row currrow,
   CALL center("Queue Exchange Report",0,100), currrow = (currrow+ 3)
   IF (amsuser=0)
    col 5, row currrow, "ERROR: You are not recognized as an AMS associate."
   ELSEIF (( $QUEUEASSIGNID=0.0)
    AND ( $OLDUSERID=0.0))
    col 5, row currrow, "ERROR: You must select a specifier or an existing user to swap out."
   ELSEIF (queuecnt=0)
    col 5, row currrow, "No queues found needing update."
   ELSEIF ((pft_reply->status_data.status="S"))
    IF (queuecnt=1)
     tempstr = build2("Successfully assigned ",trim(cnvtstring(queuecnt))," queue to {B}",newusername
      )
    ELSE
     tempstr = build2("Successfully assigned ",trim(cnvtstring(queuecnt))," queues to {B}",
      newusername)
    ENDIF
    col 5, row currrow, tempstr,
    currrow = (currrow+ 3), col 5, row currrow,
    "Queue", col 60, row currrow,
    "Existing User", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1), tempstr = substring(1,100,uar_get_code_display( $ENTITYTYPECD)), col 5,
    row currrow, tempstr, currrow = (currrow+ 1)
    FOR (queuecnt = 1 TO size(pft_reply->queue_data,5))
     IF (((queuecnt=1) OR ((pft_reply->queue_data[queuecnt].pft_entity_status_cd != pft_reply->
     queue_data[(queuecnt - 1)].pft_entity_status_cd))) )
      tempstr = uar_get_code_display(pft_reply->queue_data[queuecnt].pft_entity_status_cd), col 10,
      row currrow,
      tempstr
      IF ((pft_reply->queue_data[queuecnt].value_specifier_cd=0.0))
       tempstr = queues->list[queuecnt].old_user_name_full_formatted, col 60, row currrow,
       tempstr
      ENDIF
      currrow = (currrow+ 1)
     ENDIF
     ,
     IF ((pft_reply->queue_data[queuecnt].value_specifier_cd > 0.0))
      tempstr = build2(trim(uar_get_code_display(pft_reply->queue_data[queuecnt].value_specifier_cd)),
       ": ",pft_reply->queue_data[queuecnt].value_display_txt), col 15, row currrow,
      tempstr, tempstr = queues->list[queuecnt].old_user_name_full_formatted, col 60,
      row currrow, tempstr, currrow = (currrow+ 1)
     ENDIF
    ENDFOR
   ELSE
    col 5, row currrow, "ERROR: Script failed to complete successfully.",
    currrow = (currrow+ 3), col 5, row currrow,
    pft_reply->status_data.subeventstatus.operationname, currrow = (currrow+ 1), col 5,
    row currrow, pft_reply->status_data.subeventstatus.operationstatus, currrow = (currrow+ 1),
    col 5, row currrow, pft_reply->status_data.subeventstatus.targetobjectname,
    currrow = (currrow+ 1), col 5, row currrow,
    pft_reply->status_data.subeventstatus.targetobjectvalue
   ENDIF
  WITH nocounter, dio = 8, maxcol = 100
 ;end select
 IF (debug=1)
  CALL echo(build2("*** Ending ",script_name," ***"))
 ENDIF
 SUBROUTINE populaterequest(null)
   SET stat = alterlist(pft_request->queue_data,size(queues->list,5))
   SET pft_request->action = "UPDATE"
   IF (debug=1)
    CALL echorecord(pft_request)
   ENDIF
   FOR (i = 1 TO size(queues->list,5))
     SET pft_request->queue_data[i].contributor_system_cd = queues->list[i].contributor_system_cd
     SET pft_request->queue_data[i].pft_queue_assignment_id = queues->list[i].pft_queue_assignment_id
     SET pft_request->queue_data[i].pft_entity_type_cd = queues->list[i].pft_entity_type_cd
     SET pft_request->queue_data[i].pft_entity_status_cd = queues->list[i].pft_entity_status_cd
     SET pft_request->queue_data[i].value_specifier_cd = queues->list[i].value_specifier_cd
     SET pft_request->queue_data[i].person_id =  $NEWUSERID
     SET pft_request->queue_data[i].assigned_prsnl_group_id = queues->list[i].assigned_prsnl_group_id
     SET pft_request->queue_data[i].value_txt = queues->list[i].value_text
     SET pft_request->queue_data[i].value_display_txt = queues->list[i].value_display_txt
     SET pft_request->queue_data[i].value_range_txt = queues->list[i].value_range_txt
     SET pft_request->queue_data[i].level = queues->list[i].level
     SET pft_request->queue_data[i].sequence = queues->list[i].sequence
   ENDFOR
 END ;Subroutine
 SET last_mod = "000"
END GO
