CREATE PROGRAM dcp_get_task_form_reltn:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 task_cnt = i4
   1 dcp_forms_ref_id = f8
   1 form_description = vc
   1 agent_cnt = i4
   1 agent_qual[*]
     2 ref_id = f8
     2 description = vc
     2 agent_cd = f8
     2 entity_id = f8
     2 entity_name = vc
     2 agent_identifier = vc
   1 cdf_meaning = vc
   1 task_qual[*]
     2 reference_task_id = f8
     2 task_description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD temp_agent
 RECORD temp_agent(
   1 cnt = i4
   1 qual[*]
     2 agent_cd = f8
     2 entity_id = f8
     2 entity_name = vc
     2 agent_identifier = vc
 )
 DECLARE task_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_cnt = i4 WITH protect, noconstant(0)
 DECLARE forms_agent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",255090,"POWERFORM"))
 DECLARE docset_agent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",255090,"DOCSET"))
 DECLARE apache_agent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",255090,"APACHE"))
 DECLARE tcs_agent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",255090,"TASKCOMPSERV"))
 DECLARE agent_error_flag = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 IF ((request->charting_agent_entity_id > 0))
  SELECT INTO "nl:"
   FROM task_charting_agent_r tca,
    order_task ot
   PLAN (tca
    WHERE (tca.charting_agent_entity_id=request->charting_agent_entity_id))
    JOIN (ot
    WHERE ot.reference_task_id=tca.reference_task_id)
   HEAD REPORT
    task_cnt = 0, reply->cdf_meaning = uar_get_code_meaning(ot.task_type_cd)
   DETAIL
    task_cnt = (task_cnt+ 1)
    IF (task_cnt > size(reply->task_qual,5))
     stat = alterlist(reply->task_qual,(task_cnt+ 5))
    ENDIF
    reply->task_qual[task_cnt].reference_task_id = ot.reference_task_id, reply->task_qual[task_cnt].
    task_description = ot.task_description
   WITH nocounter
  ;end select
  SET reply->task_cnt = task_cnt
  SET stat = alterlist(reply->task_qual,task_cnt)
 ELSEIF ((request->reference_task_id > 0))
  SELECT INTO "nl:"
   FROM task_charting_agent_r tca
   WHERE (tca.reference_task_id=request->reference_task_id)
   HEAD REPORT
    temp_cnt = 0
   DETAIL
    temp_cnt = (temp_cnt+ 1)
    IF (temp_cnt > size(temp_agent->qual,5))
     stat = alterlist(temp_agent->qual,(temp_cnt+ 1))
    ENDIF
    temp_agent->qual[temp_cnt].agent_cd = tca.charting_agent_cd, temp_agent->qual[temp_cnt].entity_id
     = tca.charting_agent_entity_id, temp_agent->qual[temp_cnt].entity_name = tca
    .charting_agent_entity_name,
    temp_agent->qual[temp_cnt].agent_identifier = tca.charting_agent_identifier
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->agent_qual,temp_cnt)
  IF (temp_cnt=0)
   SET agent_error_flag = 1
   CALL fillsubeventstatus("dcp_get_task_form_reltn","Z","SELECT",
    "Nothing found for the given reference_task_id.")
  ENDIF
  FOR (cnt = 1 TO temp_cnt)
    IF ((temp_agent->qual[cnt].agent_cd=docset_agent_cd))
     SELECT INTO "nl:"
      FROM doc_set_ref dsr
      WHERE (dsr.doc_set_ref_id=temp_agent->qual[cnt].entity_id)
      DETAIL
       reply->agent_qual[cnt].description = dsr.doc_set_description, reply->agent_qual[cnt].ref_id =
       dsr.doc_set_ref_id, reply->agent_qual[cnt].agent_cd = temp_agent->qual[cnt].agent_cd,
       reply->agent_qual[cnt].entity_id = temp_agent->qual[cnt].entity_id, reply->agent_qual[cnt].
       entity_name = temp_agent->qual[cnt].entity_name, reply->agent_qual[cnt].agent_identifier =
       temp_agent->qual[cnt].agent_identifier
      WITH nocounter
     ;end select
    ELSEIF ((temp_agent->qual[cnt].agent_cd=forms_agent_cd))
     SELECT INTO "nl:"
      FROM order_task ot,
       dcp_forms_ref dfr
      PLAN (ot
       WHERE (ot.reference_task_id=request->reference_task_id))
       JOIN (dfr
       WHERE dfr.dcp_forms_ref_id=ot.dcp_forms_ref_id)
      DETAIL
       reply->agent_qual[cnt].ref_id = dfr.dcp_forms_ref_id, reply->agent_qual[cnt].description = dfr
       .description, reply->dcp_forms_ref_id = dfr.dcp_forms_ref_id,
       reply->form_description = dfr.description, reply->agent_qual[cnt].agent_cd = temp_agent->qual[
       cnt].agent_cd, reply->agent_qual[cnt].entity_id = temp_agent->qual[cnt].entity_id,
       reply->agent_qual[cnt].entity_name = temp_agent->qual[cnt].entity_name, reply->agent_qual[cnt]
       .agent_identifier = temp_agent->qual[cnt].agent_identifier
      WITH nocounter
     ;end select
    ELSEIF ((((temp_agent->qual[cnt].agent_cd=apache_agent_cd)) OR ((temp_agent->qual[cnt].agent_cd=
    tcs_agent_cd))) )
     SET reply->dcp_forms_ref_id = temp_agent->qual[cnt].entity_id
     SET reply->form_description = uar_get_code_display(temp_agent->qual[cnt].entity_id)
    ELSE
     SET agent_error_flag = 1
     CALL fillsubeventstatus("dcp_get_task_form_reltn","Z","SELECT",build("Unknown agent_cd=",
       temp_agent->qual[cnt].agent_cd))
    ENDIF
  ENDFOR
  SET reply->agent_cnt = temp_cnt
 ENDIF
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","dcp_get_task_form_reltn",serrormsg)
 ELSEIF (((curqual=0) OR (agent_error_flag=1)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("MOD 002 - 05/16/2011")
 SET modify = nopredeclare
END GO
