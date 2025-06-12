CREATE PROGRAM dcp_get_active_plans_by_cat_id:dba
 FREE RECORD completion_request
 RECORD completion_request(
   1 phaselist[*]
     2 pathwayid = f8
 )
 FREE RECORD completion_reply
 RECORD completion_reply(
   1 phaselist[*]
     2 pathway_id = f8
     2 pw_status_cd = f8
     2 calc_status_cd = f8
     2 updt_cnt = i4
     2 pw_comp_dt_tm = dq8
     2 pw_comp_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD qual_pathway
 RECORD qual_pathway(
   1 plan_count = i4
   1 plans[*]
     2 pw_group_nbr = f8
     2 order_dt_tm = dq8
     2 phase_count = i4
     2 add_to_reply_ind = i2
     2 phases[*]
       3 pathway_id = f8
       3 start_dt_tm = dq8
       3 stop_dt_tm = dq8
       3 check_completion = i2
       3 do_not_use_dt_tm_ind = i2
       3 future_ind = i2
 )
 DECLARE time_unit_cd_days = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"DAYS"))
 DECLARE time_unit_cd_hours = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"HOURS"))
 DECLARE time_unit_cd_minutes = f8 WITH protect, constant(uar_get_code_by("MEANING",340,"MINUTES"))
 DECLARE pw_status_cd_initiated = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITIATED"))
 DECLARE pw_status_cd_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "COMPLETED"))
 DECLARE pw_status_cd_planned = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE pw_status_cd_void = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"VOID"))
 DECLARE pw_status_cd_future = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE pw_status_cd_excluded = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"EXCLUDED"
   ))
 DECLARE d_patient_id_request = f8 WITH protect, constant(pp_request->patient_id)
 DECLARE l_plan_count_request = i4 WITH protect, constant(value(size(pp_request->plans,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE plan_idx = i4 WITH protect, noconstant(0)
 DECLARE phase_idx = i4 WITH protect, noconstant(0)
 DECLARE find_idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(pp_reply->status_data.
    subeventstatus,5)))
 DECLARE reply_plan_count = i4 WITH protect, noconstant(0)
 DECLARE reply_plan_size = i4 WITH protect, noconstant(0)
 DECLARE completion_reply_count = i4 WITH protect, noconstant(0)
 DECLARE bplanstopdttmfinal = i2 WITH protect, noconstant(0)
 DECLARE plan_start_dt_tm = dq8 WITH protect, noconstant(null)
 DECLARE plan_stop_dt_tm = dq8 WITH protect, noconstant(null)
 DECLARE phase_start_dt_tm = dq8 WITH protect, noconstant(null)
 DECLARE phase_stop_dt_tm = dq8 WITH protect, noconstant(null)
 DECLARE process_completion(plan_idx=i4,phase_idx=i4,completion_reply_count=i4) = null
 DECLARE process_phase_completion_results(completion_reply_count=i4) = null
 DECLARE add_plan_to_reply(plan_idx=i4) = null
 DECLARE calculate_date_time_from_phase(plan_idx=i4,phase_idx=i4) = null
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET pp_reply->status_data.status = "S"
 IF (d_patient_id_request <= 0.0)
  CALL set_script_status("Z","BEGIN","Z","dcp_get_active_plans_by_cat_id",
   "The patient_id was not valid.")
  GO TO exit_script
 ENDIF
 IF (l_plan_count_request < 1)
  CALL set_script_status("Z","BEGIN","Z","dcp_get_active_plans_by_cat_id","The plan list was empty.")
  GO TO exit_script
 ENDIF
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_plan_count_request)/
    cnvtreal(l_batch_size)))))
 DECLARE l_plan_size = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 IF (l_plan_size > 0)
  SET stat = alterlist(pp_request->plans,l_plan_size)
 ENDIF
 FOR (idx = (l_plan_count_request+ 1) TO l_plan_size)
   SET pp_request->plans[idx].pathway_catalog_id = pp_request->plans[l_plan_count_request].
   pathway_catalog_id
 ENDFOR
 SET lstart = 1
 SELECT INTO "nl:"
  p.pw_group_nbr, p.order_dt_tm, pwc2.version,
  pwc2.pathway_catalog_id
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway_catalog pwc,
   pathway_catalog pwc2,
   pathway p
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pwc
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pwc.pathway_catalog_id,pp_request->plans[idx]
    .pathway_catalog_id))
   JOIN (pwc2
   WHERE pwc2.version_pw_cat_id=pwc.version_pw_cat_id
    AND pwc2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=d_patient_id_request
    AND p.pw_cat_group_id=pwc2.pathway_catalog_id
    AND trim(p.type_mean) IN ("CAREPLAN", "PHASE"))
  ORDER BY p.pw_group_nbr, p.order_dt_tm
  HEAD REPORT
   complete_check_count = 0, complete_check_size = 0, plan_count = 0,
   plan_size = 0, phase_count = 0, phase_size = 0
  HEAD p.pw_group_nbr
   plan_count = (plan_count+ 1)
   IF (plan_count > plan_size)
    plan_size = (plan_size+ 20), stat = alterlist(qual_pathway->plans,plan_size)
   ENDIF
   qual_pathway->plans[plan_count].pw_group_nbr = p.pw_group_nbr, qual_pathway->plans[plan_count].
   order_dt_tm = p.order_dt_tm, phase_count = 0,
   phase_size = 0
  DETAIL
   phase_count = (phase_count+ 1)
   IF (phase_count > phase_size)
    phase_size = (phase_size+ 20), stat = alterlist(qual_pathway->plans[plan_count].phases,phase_size
     )
   ENDIF
   qual_pathway->plans[plan_count].phases[phase_count].pathway_id = p.pathway_id
   IF (((p.pw_status_cd IN (pw_status_cd_void, pw_status_cd_excluded)) OR (p.pw_status_cd !=
   pw_status_cd_planned
    AND p.pw_status_cd != pw_status_cd_future
    AND p.started_ind=0)) )
    qual_pathway->plans[plan_count].phases[phase_count].do_not_use_dt_tm_ind = 1
   ELSE
    qual_pathway->plans[plan_count].add_to_reply_ind = 1, qual_pathway->plans[plan_count].phases[
    phase_count].start_dt_tm = cnvtdatetime(p.start_dt_tm), qual_pathway->plans[plan_count].phases[
    phase_count].stop_dt_tm = cnvtdatetime(p.calc_end_dt_tm)
    IF (p.pw_status_cd=pw_status_cd_future)
     qual_pathway->plans[plan_count].phases[phase_count].future_ind = 1
    ENDIF
    IF (p.pw_status_cd IN (pw_status_cd_initiated, pw_status_cd_future))
     complete_check_count = (complete_check_count+ 1)
     IF (complete_check_count > complete_check_size)
      complete_check_size = (complete_check_size+ 20), stat = alterlist(completion_request->phaselist,
       complete_check_size)
     ENDIF
     completion_request->phaselist[complete_check_count].pathwayid = p.pathway_id, qual_pathway->
     plans[plan_count].phases[phase_count].check_completion = 1
    ENDIF
   ENDIF
  FOOT  p.pw_group_nbr
   qual_pathway->plans[plan_count].phase_count = phase_count
   IF (phase_count > 0
    AND phase_count < phase_size)
    stat = alterlist(qual_pathway->plans[plan_count].phases,phase_count)
   ENDIF
  FOOT REPORT
   IF (complete_check_count > 0
    AND complete_check_count < complete_check_size)
    stat = alterlist(completion_request->phaselist,complete_check_count)
   ENDIF
   qual_pathway->plan_count = plan_count
   IF (plan_count > 0
    AND plan_count < plan_size)
    stat = alterlist(qual_pathway->plans,plan_count)
   ENDIF
  WITH nocounter
 ;end select
 IF (((curqual=0) OR ((qual_pathway->plan_count < 1))) )
  CALL set_script_status("Z","SELECT","Z","dcp_get_active_plans_by_cat_id",
   "Did not find any rows on the pathway table.")
  GO TO exit_script
 ENDIF
 IF (size(completion_request->phaselist,5) > 0)
  EXECUTE dcp_check_phase_completion  WITH replace("REQUEST","COMPLETION_REQUEST"), replace("REPLY",
   "COMPLETION_REPLY")
  CALL process_phase_completion_results(value(size(completion_reply->phaselist,5)))
 ENDIF
 FOR (plan_idx = 1 TO qual_pathway->plan_count)
   IF ((qual_pathway->plans[plan_idx].add_to_reply_ind=1))
    CALL add_plan_to_reply(plan_idx)
   ENDIF
 ENDFOR
 IF (reply_plan_count > 0)
  IF (reply_plan_count < reply_plan_size)
   SET reply_plan_size = reply_plan_count
   SET stat = alterlist(pp_reply->plans,reply_plan_count)
  ENDIF
 ELSE
  CALL set_script_status("Z","POPULATE REPLY","Z","dcp_get_active_plans_by_cat_id",
   "Nothing to add to the reply.")
  GO TO exit_script
 ENDIF
 SUBROUTINE add_plan_to_reply(plan_idx)
   SET reply_plan_count = (reply_plan_count+ 1)
   IF (reply_plan_count > reply_plan_size)
    SET reply_plan_size = (reply_plan_size+ 20)
    SET stat = alterlist(pp_reply->plans,reply_plan_size)
   ENDIF
   SET reply_phase_count = 0
   SET reply_phase_size = 0
   SET bplanstopdttmfinal = 0
   SET plan_start_dt_tm = cnvtdatetime(pp_reply->plans[reply_plan_count].start_dt_tm)
   SET plan_stop_dt_tm = cnvtdatetime(pp_reply->plans[reply_plan_count].stop_dt_tm)
   FOR (phase_idx = 1 TO qual_pathway->plans[plan_idx].phase_count)
     CALL calculate_date_time_from_phase(plan_idx,phase_idx)
   ENDFOR
   SET pp_reply->plans[reply_plan_count].start_dt_tm = cnvtdatetime(plan_start_dt_tm)
   SET pp_reply->plans[reply_plan_count].stop_dt_tm = cnvtdatetime(plan_stop_dt_tm)
   SET pp_reply->plans[reply_plan_count].order_dt_tm = cnvtdatetime(qual_pathway->plans[plan_idx].
    order_dt_tm)
   SET pp_reply->plans[reply_plan_count].pw_group_nbr = qual_pathway->plans[plan_idx].pw_group_nbr
   IF (reply_phase_count > 0
    AND reply_phase_count < reply_phase_size)
    SET reply_phase_size = reply_phase_count
    SET stat = alterlist(pp_reply->plans[reply_plan_count].phases,reply_phase_count)
   ENDIF
 END ;Subroutine
 SUBROUTINE calculate_date_time_from_phase(plan_idx,phase_idx)
   IF ((qual_pathway->plans[plan_idx].phases[phase_idx].do_not_use_dt_tm_ind=0))
    IF ((qual_pathway->plans[plan_idx].phases[phase_idx].future_ind=1))
     SET phase_start_dt_tm = null
     SET phase_stop_dt_tm = null
    ELSE
     SET phase_start_dt_tm = cnvtdatetime(qual_pathway->plans[plan_idx].phases[phase_idx].start_dt_tm
      )
     SET phase_stop_dt_tm = cnvtdatetime(qual_pathway->plans[plan_idx].phases[phase_idx].stop_dt_tm)
    ENDIF
    IF (phase_start_dt_tm != null)
     IF (plan_start_dt_tm=null)
      SET plan_start_dt_tm = cnvtdatetime(phase_start_dt_tm)
     ELSEIF (cnvtdatetime(plan_start_dt_tm) > cnvtdatetime(phase_start_dt_tm))
      SET plan_start_dt_tm = cnvtdatetime(phase_start_dt_tm)
     ENDIF
    ENDIF
    IF (bplanstopdttmfinal=0)
     IF (phase_stop_dt_tm=null)
      SET bplanstopdttmfinal = 1
      SET plan_stop_dt_tm = cnvtdatetime(phase_stop_dt_tm)
     ELSEIF (plan_stop_dt_tm=null)
      SET plan_stop_dt_tm = cnvtdatetime(phase_stop_dt_tm)
     ELSEIF (cnvtdatetime(plan_stop_dt_tm) < cnvtdatetime(phase_stop_dt_tm))
      SET plan_stop_dt_tm = cnvtdatetime(phase_stop_dt_tm)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE process_completion(plan_idx,phase_idx,completion_reply_count)
   IF (((plan_idx < 1) OR (((phase_idx < 1) OR (completion_reply_count < 1)) )) )
    RETURN
   ENDIF
   SET idx = locateval(idx,1,completion_reply_count,qual_pathway->plans[plan_idx].phases[phase_idx].
    pathway_id,completion_reply->phaselist[idx].pathway_id)
   IF (idx > 0)
    IF ((completion_reply->phaselist[idx].calc_status_cd=pw_status_cd_completed))
     SET qual_pathway->plans[plan_idx].phases[phase_idx].stop_dt_tm = cnvtdatetime(completion_reply->
      phaselist[idx].pw_comp_dt_tm)
     SET qual_pathway->plans[plan_idx].phases[phase_idx].future_ind = 0
     RETURN
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE process_phase_completion_results(completion_reply_count)
   IF (completion_reply_count > 0)
    FOR (plan_idx = 1 TO qual_pathway->plan_count)
      IF ((qual_pathway->plans[plan_idx].add_to_reply_ind=1))
       SET phase_idx = 0
       SET phase_idx = locateval(find_idx,(phase_idx+ 1),qual_pathway->plans[plan_idx].phase_count,1,
        qual_pathway->plans[plan_idx].phases[find_idx].check_completion)
       WHILE (phase_idx > 0)
        CALL process_completion(plan_idx,phase_idx,completion_reply_count)
        SET phase_idx = locateval(find_idx,(phase_idx+ 1),qual_pathway->plans[plan_idx].phase_count,1,
         qual_pathway->plans[plan_idx].phases[find_idx].check_completion)
       ENDWHILE
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   IF ((pp_reply->status_data.status="S"))
    SET pp_reply->status_data.status = cstatus
   ELSEIF (cstatus="F")
    SET pp_reply->status_data.status = cstatus
   ENDIF
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(pp_reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET pp_reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim
    (soperationname))
   SET pp_reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET pp_reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,
    trim(stargetobjectname))
   SET pp_reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 FREE RECORD qual_pathway
 FREE RECORD completion_request
 FREE RECORD completion_reply
END GO
