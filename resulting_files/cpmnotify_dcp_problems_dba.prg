CREATE PROGRAM cpmnotify_dcp_problems:dba
 SET modify = predeclare
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 problem_ind = i2
       3 diagnosis_list[*]
         4 encntr_id = f8
         4 review_ind = i2
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
 DECLARE active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE 3m = f8 WITH public, constant(uar_get_code_by("MEANING",89,"3M"))
 DECLARE profile = f8 WITH public, constant(uar_get_code_by("MEANING",89,"PROFILE"))
 DECLARE ncoder = f8 WITH public, constant(uar_get_code_by("MEANING",89,"NCODER"))
 DECLARE 3m_aus = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-AUS"))
 DECLARE 3m_can = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-CAN"))
 DECLARE kodip = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"KODIP"))
 DECLARE expand_size = i4 WITH protect, constant(50)
 DECLARE ind_all_reviewed = i2 WITH protect, constant(2)
 DECLARE ind_needs_review = i2 WITH protect, constant(1)
 DECLARE ind_nothing = i2 WITH protect, constant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE person_idx = i4 WITH protect, noconstant(0)
 DECLARE diagnosis_idx = i4 WITH protect, noconstant(0)
 DECLARE reply_person_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_total = i4 WITH protect, noconstant(0)
 DECLARE valuecnt = i4 WITH protect, noconstant(size(request->entity_list,5))
 DECLARE diagnosiscnt = i4 WITH protect, noconstant(0)
 DECLARE totalproblems = i4 WITH protect, noconstant(0)
 DECLARE totalreviews = i4 WITH protect, noconstant(0)
 DECLARE failure_ind = i2 WITH protect, noconstant(0)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE dscriptstarttime = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE start_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,0))
 DECLARE script_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET script_debug_ind = request->debug_ind
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->overlay_ind = 1
 IF (valuecnt=0)
  SET failure_ind = 1
  GO TO failure
 ENDIF
 SELECT INTO "nl:"
  person_id = request->entity_list[d.seq].entity_id
  FROM (dummyt d  WITH seq = value(size(request->entity_list,5)))
  ORDER BY person_id
  HEAD REPORT
   reply_person_cnt = 0
  HEAD person_id
   reply_person_cnt = (reply_person_cnt+ 1)
   IF (mod(reply_person_cnt,10)=1)
    stat = alterlist(reply->entity_list,(reply_person_cnt+ 9))
   ENDIF
   reply->entity_list[reply_person_cnt].entity_id = person_id, stat = alterlist(reply->entity_list[
    reply_person_cnt].datalist,1), reply->entity_list[reply_person_cnt].datalist[1].problem_ind =
   ind_nothing
  FOOT REPORT
   stat = alterlist(reply->entity_list,reply_person_cnt)
 ;end select
 SELECT INTO "nl:"
  p.problem_instance_id
  FROM problem p,
   (left JOIN problem_action pa ON pa.problem_instance_id=p.problem_instance_id
    AND (pa.prsnl_id=request->user_id)
    AND pa.problem_instance_id > 0
    AND pa.action_dt_tm >= p.beg_effective_dt_tm
    AND pa.action_dt_tm >= p.updt_dt_tm
    AND pa.action_type_mean="REVIEW")
  PLAN (p
   WHERE expand(idx,1,reply_person_cnt,p.person_id,reply->entity_list[idx].entity_id)
    AND p.person_id > 0.0
    AND p.active_ind=1
    AND  NOT (p.contributor_system_cd IN (3m, profile, ncoder))
    AND p.life_cycle_status_cd=active_life_cycle_cd
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pa)
  ORDER BY p.person_id, p.problem_instance_id
  HEAD p.person_id
   person_idx = locateval(idx2,1,reply_person_cnt,p.person_id,reply->entity_list[idx2].entity_id),
   totalproblems = 0, totalreviews = 0
  HEAD p.problem_instance_id
   totalproblems = (totalproblems+ 1)
   IF (pa.problem_action_id > 0)
    totalreviews = (totalreviews+ 1)
   ENDIF
  FOOT  p.person_id
   IF (totalproblems=totalreviews
    AND totalproblems > 0)
    reply->entity_list[person_idx].datalist[1].problem_ind = ind_all_reviewed
   ELSEIF (totalproblems > 0)
    reply->entity_list[person_idx].datalist[1].problem_ind = ind_needs_review
   ELSE
    reply->entity_list[person_idx].datalist[1].problem_ind = ind_nothing
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  dia.diagnosis_id
  FROM diagnosis dia,
   (left JOIN diagnosis_action da ON da.diagnosis_id=dia.diagnosis_id
    AND (da.prsnl_id=request->user_id)
    AND da.diagnosis_id > 0
    AND da.action_dt_tm >= dia.beg_effective_dt_tm
    AND da.action_dt_tm >= dia.updt_dt_tm
    AND da.action_type_mean="REVIEW")
  PLAN (dia
   WHERE expand(idx,1,reply_person_cnt,dia.person_id,reply->entity_list[idx].entity_id)
    AND dia.person_id > 0.0
    AND dia.active_ind=1
    AND  NOT (dia.contributor_system_cd IN (3m, 3m_aus, 3m_can, kodip, profile))
    AND dia.diagnosis_group > 0.0
    AND dia.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND dia.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (da)
  ORDER BY dia.person_id, dia.diagnosis_id
  HEAD dia.person_id
   person_idx = locateval(idx2,1,reply_person_cnt,dia.person_id,reply->entity_list[idx2].entity_id),
   diagnosis_idx = 0, diagnosiscnt = 0
  HEAD dia.diagnosis_id
   diagnosis_idx = (diagnosis_idx+ 1), diagnosiscnt = (diagnosiscnt+ 1)
   IF (diagnosiscnt >= size(reply->entity_list[person_idx].datalist[1].diagnosis_list,5))
    stat = alterlist(reply->entity_list[person_idx].datalist[1].diagnosis_list,(diagnosiscnt+ 9))
   ENDIF
   reply->entity_list[person_idx].datalist[1].diagnosis_list[diagnosis_idx].encntr_id = dia.encntr_id
   IF (da.diagnosis_action_id > 0)
    reply->entity_list[person_idx].datalist[1].diagnosis_list[diagnosis_idx].review_ind = 1
   ELSE
    reply->entity_list[person_idx].datalist[1].diagnosis_list[diagnosis_idx].review_ind = 0
   ENDIF
  FOOT  dia.person_id
   stat = alterlist(reply->entity_list[person_idx].datalist[1].diagnosis_list,diagnosiscnt)
  WITH nocounter, expand = 1
 ;end select
#failure
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","cpmnotify_dcp_problems",error_msg)
 ELSEIF (failure_ind=1)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (script_debug_ind > 0)
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("-------------------------------------------------------")
  CALL echo(build("request->user_id = ",request->user_id))
  SET delapsedtime = datetimediff(cnvtdatetime(curdate,curtime3),dscriptstarttime,5)
  CALL echo("*******************************************************")
  CALL echo("cpmnotify_dcp_problems Last Modified = 001 5/02/11")
  CALL echo(build("cpmnotify_dcp_problems Total Time = ",delapsedtime))
  CALL echo("*******************************************************")
 ENDIF
 SET modify = nopredeclare
END GO
