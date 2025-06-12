CREATE PROGRAM dcp_get_plans_by_pathway_group:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_get_plans_by_pathway_group")
 DECLARE l_pathway_group_count = i4 WITH protect, constant(value(size(request->pathway_groups,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_pathway_group_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"No pathway groups.")
  GO TO exit_script
 ENDIF
 SET lstart = 1
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_pathway_group_count)/
    cnvtreal(l_batch_size)))))
 DECLARE l_max_pathway_group_count = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 SET stat = alterlist(request->pathway_groups,l_max_pathway_group_count)
 FOR (idx = (l_pathway_group_count+ 1) TO l_max_pathway_group_count)
   SET request->pathway_groups[idx].pathway_group_id = request->pathway_groups[l_pathway_group_count]
   .pathway_group_id
 ENDFOR
 SELECT INTO "nl:"
  pw.pw_group_nbr, pw.pathway_group_id, parent_phase_ind = evaluate(trim(pw.type_mean),"DOT",0,1),
  pw.pathway_id, pa.pw_action_seq
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway pw,
   pathway_action pa
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pw
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pw.pathway_group_id,request->pathway_groups[
    idx].pathway_group_id))
   JOIN (pa
   WHERE pa.pathway_id=pw.pathway_id)
  ORDER BY pw.pw_group_nbr, pw.pathway_group_id, parent_phase_ind DESC,
   pw.pathway_id, pa.pw_action_seq DESC
  HEAD REPORT
   plansize = 0, planidx = 0, phasesize = 0,
   phaseidx = 0, childphasesize = 0, childphaseidx = 0
  HEAD pw.pw_group_nbr
   phasesize = 0, phaseidx = 0, childphasesize = 0,
   childphaseidx = 0, planidx = (planidx+ 1)
   IF (planidx > plansize)
    plansize = (plansize+ 10), stat = alterlist(reply->plans,plansize)
   ENDIF
   reply->plans[planidx].pw_group_nbr = pw.pw_group_nbr, reply->plans[planidx].pw_group_desc = trim(
    pw.pw_group_desc), reply->plans[planidx].cycle_nbr = pw.cycle_nbr,
   reply->plans[planidx].cycle_end_nbr = pw.cycle_end_nbr
  HEAD pw.pathway_group_id
   childphasesize = 0, childphaseidx = 0, phaseidx = (phaseidx+ 1)
   IF (phaseidx > phasesize)
    phasesize = (phasesize+ 10), stat = alterlist(reply->plans[planidx].phases,phasesize)
   ENDIF
   reply->plans[planidx].phases[phaseidx].pathway_id = pw.pathway_id, reply->plans[planidx].phases[
   phaseidx].type_mean = trim(pw.type_mean), reply->plans[planidx].phases[phaseidx].person_id = pw
   .person_id,
   reply->plans[planidx].phases[phaseidx].encntr_id = pw.encntr_id, reply->plans[planidx].phases[
   phaseidx].started_ind = pw.started_ind, reply->plans[planidx].phases[phaseidx].pw_status_cd = pw
   .pw_status_cd,
   reply->plans[planidx].phases[phaseidx].start_dt_tm = cnvtdatetime(pw.start_dt_tm), reply->plans[
   planidx].phases[phaseidx].start_estimated_ind = pw.start_estimated_ind, reply->plans[planidx].
   phases[phaseidx].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm),
   reply->plans[planidx].phases[phaseidx].calc_end_estimated_ind = pw.calc_end_estimated_ind, reply->
   plans[planidx].phases[phaseidx].duration_qty = pw.duration_qty, reply->plans[planidx].phases[
   phaseidx].duration_unit_cd = pw.duration_unit_cd,
   reply->plans[planidx].phases[phaseidx].dc_reason_cd = pw.dc_reason_cd, reply->plans[planidx].
   phases[phaseidx].provider_id = pa.provider_id, reply->plans[planidx].phases[phaseidx].
   communication_type_cd = pa.communication_type_cd
  HEAD parent_phase_ind
   dummy = 0
  HEAD pw.pathway_id
   IF ( NOT (pw.type_mean IN ("CAREPLAN", "PHASE")))
    childphaseidx = (childphaseidx+ 1)
    IF (childphaseidx > childphasesize)
     childphasesize = (childphasesize+ 10), stat = alterlist(reply->plans[planidx].phases[phaseidx].
      treatment_period_phases,childphasesize)
    ENDIF
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].pathway_id = pw
    .pathway_id, reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].
    type_mean = trim(pw.type_mean), reply->plans[planidx].phases[phaseidx].treatment_period_phases[
    childphaseidx].person_id = pw.person_id,
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].encntr_id = pw
    .encntr_id, reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].
    started_ind = pw.started_ind, reply->plans[planidx].phases[phaseidx].treatment_period_phases[
    childphaseidx].pw_status_cd = pw.pw_status_cd,
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].start_dt_tm =
    cnvtdatetime(pw.start_dt_tm), reply->plans[planidx].phases[phaseidx].treatment_period_phases[
    childphaseidx].start_estimated_ind = pw.start_estimated_ind, reply->plans[planidx].phases[
    phaseidx].treatment_period_phases[childphaseidx].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm),
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].
    calc_end_estimated_ind = pw.calc_end_estimated_ind, reply->plans[planidx].phases[phaseidx].
    treatment_period_phases[childphaseidx].duration_qty = pw.duration_qty, reply->plans[planidx].
    phases[phaseidx].treatment_period_phases[childphaseidx].duration_unit_cd = pw.duration_unit_cd,
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].updt_cnt = pw
    .updt_cnt, reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].
    dc_reason_cd = pw.dc_reason_cd, reply->plans[planidx].phases[phaseidx].treatment_period_phases[
    childphaseidx].provider_id = pa.provider_id,
    reply->plans[planidx].phases[phaseidx].treatment_period_phases[childphaseidx].
    communication_type_cd = pa.communication_type_cd
   ENDIF
  HEAD pa.pw_action_seq
   dummy = 0
  DETAIL
   dummy = 0
  FOOT  pa.pw_action_seq
   dummy = 0
  FOOT  pw.pathway_id
   dummy = 0
  FOOT  parent_phase_ind
   dummy = 0
  FOOT  pw.pathway_group_id
   IF (childphasesize > 0
    AND childphaseidx < childphasesize)
    stat = alterlist(reply->plans[planidx].phases[phaseidx].treatment_period_phases,childphaseidx)
   ENDIF
  FOOT  pw.pw_group_nbr
   IF (phasesize > 0
    AND phaseidx < phasesize)
    stat = alterlist(reply->plans[planidx].phases,phaseidx)
   ENDIF
  FOOT REPORT
   IF (plansize > 0
    AND planidx < plansize)
    stat = alterlist(reply->plans,planidx)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL set_script_status("Z","SELECT","Z",s_script_name,"No plans found.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((reply->status_data.status="S"))
    SET reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormessage = vc WITH protect, noconstant(" ")
 DECLARE lerrcnt = i4 WITH protect, noconstant(0)
 SET lerrorcode = error(serrormessage,0)
 WHILE (lerrorcode != 0
  AND lerrcnt <= 50)
   SET lerrcnt = (lerrcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,trim(serrormessage))
   SET lerrorcode = error(serrormessage,0)
 ENDWHILE
 SET last_mod = "001"
 SET mod_date = "July 20, 2011"
END GO
