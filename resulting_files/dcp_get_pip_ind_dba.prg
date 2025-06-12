CREATE PROGRAM dcp_get_pip_ind:dba
 SET modify = predeclare
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 problem_ind = i2
     2 sch_appt_ind = i2
     2 allergy_ind = i2
     2 sticky_notes_ind = i2
     2 assign_notes_ind = i2
     2 roundnote_ind = i2
     2 diagnosis_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE person_cnt = i4 WITH protect, constant(size(request->person_list,5))
 DECLARE active_life_cycle_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE canceled_reaction_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"CANCELED")
  )
 DECLARE shiftnote_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14122,"ASGMTNOTE"))
 DECLARE powerchart_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14122,"POWERCHART"))
 DECLARE roundnote_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14122,"ROUNDNOTE"))
 DECLARE 3m = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M"))
 DECLARE 3m_aus = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-AUS"))
 DECLARE 3m_can = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"3M-CAN"))
 DECLARE kodip = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"KODIP"))
 DECLARE profile = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"PROFILE"))
 DECLARE ncoder = f8 WITH protect, constant(uar_get_code_by("MEANING",89,"NCODER"))
 DECLARE ind_all_reviewed = i2 WITH protect, constant(2)
 DECLARE ind_needs_review = i2 WITH protect, constant(1)
 DECLARE ind_nothing = i2 WITH protect, constant(0)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE totalproblems = i4 WITH protect, noconstant(0)
 DECLARE totalreviews = i4 WITH protect, noconstant(0)
 DECLARE totaldiagnosis = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE person_idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(false)
 DECLARE error_code = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE dscriptstarttime = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE dactionstarttime = dq8 WITH protect, noconstant(0)
 DECLARE start_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,0))
 DECLARE now = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE nkma_source_string = vc WITH protect, constant("No Known Medication Allergies")
 DECLARE nkma_concept_cki = vc WITH protect, noconstant("")
 DECLARE nkadocumented = i2 WITH protect, noconstant(0)
 DECLARE nkmadocumented = i2 WITH protect, noconstant(0)
 DECLARE allergydocumented = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  n.concept_cki
  FROM nomenclature n
  WHERE n.source_string=nkma_source_string
  DETAIL
   nkma_concept_cki = n.concept_cki
  WITH nocounter
 ;end select
 DECLARE script_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET script_debug_ind = request->debug_ind
 ENDIF
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->person_list,person_cnt)
 FOR (num = 1 TO person_cnt)
   SET reply->person_list[num].person_id = request->person_list[num].person_id
 ENDFOR
 SET dactionstarttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  p.problem_instance_id
  FROM problem p,
   (left JOIN problem_action pa ON pa.problem_instance_id=p.problem_instance_id
    AND (pa.prsnl_id=reqinfo->updt_id)
    AND pa.problem_instance_id > 0
    AND pa.action_dt_tm >= p.beg_effective_dt_tm
    AND pa.action_dt_tm >= p.updt_dt_tm
    AND pa.action_type_mean="REVIEW")
  PLAN (p
   WHERE expand(idx,1,person_cnt,p.person_id,request->person_list[idx].person_id)
    AND p.person_id > 0.0
    AND p.active_ind=1
    AND  NOT (p.contributor_system_cd IN (3m, profile, ncoder))
    AND p.life_cycle_status_cd=active_life_cycle_cd
    AND p.beg_effective_dt_tm <= cnvtdatetime(now)
    AND p.end_effective_dt_tm >= cnvtdatetime(now))
   JOIN (pa)
  ORDER BY p.person_id, p.problem_instance_id
  HEAD p.person_id
   person_idx = locateval(idx2,1,size(reply->person_list,5),p.person_id,reply->person_list[idx2].
    person_id), totalproblems = 0, totalreviews = 0
  HEAD p.problem_instance_id
   totalproblems += 1
   IF (pa.problem_action_id > 0)
    totalreviews += 1
   ENDIF
  FOOT  p.person_id
   IF (totalproblems=totalreviews
    AND totalproblems > 0)
    reply->person_list[person_idx].problem_ind = ind_all_reviewed
   ELSEIF (totalproblems > 0)
    reply->person_list[person_idx].problem_ind = ind_needs_review
   ELSE
    reply->person_list[person_idx].problem_ind = ind_nothing
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((script_debug_ind=1) OR (script_debug_ind=6)) )
  SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from Problems and Problem_Action = ",delapsedtime))
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  dia.diagnosis_id
  FROM diagnosis dia,
   (left JOIN diagnosis_action da ON da.diagnosis_id=dia.diagnosis_id
    AND (da.prsnl_id=reqinfo->updt_id)
    AND da.diagnosis_id > 0
    AND da.action_dt_tm >= dia.beg_effective_dt_tm
    AND da.action_dt_tm >= dia.updt_dt_tm
    AND da.action_type_mean="REVIEW")
  PLAN (dia
   WHERE expand(idx,1,person_cnt,dia.person_id,request->person_list[idx].person_id,
    dia.encntr_id,request->person_list[idx].encntr_id)
    AND dia.person_id > 0.0
    AND dia.encntr_id > 0.0
    AND dia.active_ind=1
    AND  NOT (dia.contributor_system_cd IN (3m, 3m_aus, 3m_can, kodip, profile))
    AND dia.diagnosis_group > 0.0
    AND dia.beg_effective_dt_tm <= cnvtdatetime(now)
    AND dia.end_effective_dt_tm >= cnvtdatetime(now))
   JOIN (da)
  ORDER BY dia.person_id, dia.diagnosis_id
  HEAD dia.person_id
   person_idx = locateval(idx2,1,size(reply->person_list,5),dia.person_id,reply->person_list[idx2].
    person_id), totaldiagnosis = 0, totalreviews = 0
  HEAD dia.diagnosis_id
   totaldiagnosis += 1
   IF (da.diagnosis_action_id > 0)
    totalreviews += 1
   ENDIF
  FOOT  dia.person_id
   IF (totaldiagnosis=totalreviews
    AND totaldiagnosis > 0)
    reply->person_list[person_idx].diagnosis_ind = ind_all_reviewed
   ELSEIF (totaldiagnosis > 0)
    reply->person_list[person_idx].diagnosis_ind = ind_needs_review
   ELSE
    reply->person_list[person_idx].diagnosis_ind = ind_nothing
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((script_debug_ind=2) OR (script_debug_ind=6)) )
  SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from Diagnosis and Diagnosis_Action = ",delapsedtime))
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  sa.sch_appt_id
  FROM sch_appt sa
  PLAN (sa
   WHERE expand(idx,1,person_cnt,sa.person_id,request->person_list[idx].person_id)
    AND sa.end_dt_tm >= cnvtdatetime(start_dt_tm)
    AND sa.active_ind=1
    AND sa.role_meaning="PATIENT"
    AND sa.beg_effective_dt_tm <= cnvtdatetime(now)
    AND sa.end_effective_dt_tm >= cnvtdatetime(now))
  HEAD sa.person_id
   person_idx = locateval(idx2,1,size(reply->person_list,5),sa.person_id,reply->person_list[idx2].
    person_id), reply->person_list[person_idx].sch_appt_ind = 0
  DETAIL
   IF (sa.sch_appt_id > 0)
    reply->person_list[person_idx].sch_appt_ind = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((script_debug_ind=3) OR (script_debug_ind=6)) )
  SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from SCH_APPT = ",delapsedtime))
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  a.allergy_id
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE expand(idx,1,person_cnt,a.person_id,request->person_list[idx].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(now)
    AND a.end_effective_dt_tm >= cnvtdatetime(now)
    AND a.reaction_status_cd != canceled_reaction_cd)
   JOIN (n
   WHERE a.substance_nom_id=n.nomenclature_id)
  ORDER BY a.person_id, a.allergy_instance_id
  HEAD a.person_id
   person_idx = locateval(idx2,1,size(reply->person_list,5),a.person_id,reply->person_list[idx2].
    person_id), reply->person_list[person_idx].allergy_ind = 0, nkadocumented = 0,
   nkmadocumented = 0, allergydocumented = 0
  HEAD a.allergy_instance_id
   IF (a.allergy_instance_id > 0)
    IF (n.mnemonic="NKA")
     nkadocumented = 1
    ELSEIF (n.concept_cki=nkma_concept_cki)
     nkmadocumented = 1
    ELSE
     allergydocumented = 1
    ENDIF
   ENDIF
  DETAIL
   IF (nkadocumented)
    reply->person_list[person_idx].allergy_ind = 1
   ELSEIF (allergydocumented)
    reply->person_list[person_idx].allergy_ind = 2
   ELSEIF (nkmadocumented)
    reply->person_list[person_idx].allergy_ind = 3
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((script_debug_ind=4) OR (script_debug_ind=6)) )
  SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from Allergy and Nomenclature = ",delapsedtime))
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 SET dactionstarttime = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  check = decode(sn.seq,"s","z")
  FROM sticky_note sn
  PLAN (sn
   WHERE expand(idx,1,person_cnt,sn.parent_entity_id,request->person_list[idx].person_id)
    AND sn.parent_entity_name="PERSON"
    AND sn.sticky_note_type_cd IN (powerchart_cd, shiftnote_cd, roundnote_cd)
    AND sn.beg_effective_dt_tm <= cnvtdatetime(now)
    AND sn.end_effective_dt_tm > cnvtdatetime(now))
  HEAD sn.parent_entity_id
   person_idx = locateval(idx2,1,size(reply->person_list,5),sn.parent_entity_id,reply->person_list[
    idx2].person_id), reply->person_list[person_idx].sticky_notes_ind = 0, reply->person_list[
   person_idx].assign_notes_ind = 0,
   reply->person_list[person_idx].roundnote_ind = 0
  DETAIL
   IF (check="s")
    IF (sn.sticky_note_type_cd=powerchart_cd)
     reply->person_list[person_idx].sticky_notes_ind = 1
    ELSEIF (sn.sticky_note_type_cd=shiftnote_cd)
     reply->person_list[person_idx].assign_notes_ind = 1
    ELSEIF (sn.sticky_note_type_cd=roundnote_cd)
     IF (((sn.public_ind=1) OR ((sn.updt_id=reqinfo->updt_id))) )
      reply->person_list[person_idx].roundnote_ind = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (((script_debug_ind=5) OR (script_debug_ind=6)) )
  SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dactionstarttime,5)
  CALL echo("*******************************************************")
  CALL echo(build("select from Sticky_note = ",delapsedtime))
  CALL echo("-------------------------------------------------------")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_pip_ind",error_msg)
 ELSEIF (person_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET delapsedtime = datetimediff(cnvtdatetime(sysdate),dscriptstarttime,5)
 CALL fillsubeventstatus("SELECT","S","dcp_get_pip_ind",build("Total time = ",delapsedtime))
 IF (script_debug_ind > 0)
  CALL echo("*******************************************************")
  CALL echo("dcp_get_pip_ind Last Modified = 004 14/NOV/13")
  CALL echo(build("dcp_get_pip_ind Total Time = ",delapsedtime))
  CALL echo("*******************************************************")
  CALL echorecord(reply)
 ENDIF
 SET modify = nopredeclare
END GO
