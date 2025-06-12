CREATE PROGRAM dcp_upd_phase_groups:dba
 SET modify = predeclare
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE s_script_name = vc WITH protect, constant("dcp_upd_phase_groups")
 DECLARE l_phase_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE pw_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE pw_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "DISCONTINUED"))
 DECLARE pw_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE pw_futurereview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTUREREVIEW"))
 DECLARE pw_initiated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE pw_initreview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITREVIEW"))
 DECLARE pw_planned_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE pw_void_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"VOID"))
 DECLARE pw_excluded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"EXCLUDED"))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_phase_count < 1
  AND size(request->phase_groups,5) < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"No phases or phase groups to update.")
  GO TO exit_script
 ENDIF
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 RECORD phase_data(
   1 phases_count = i4
   1 phases[*]
     2 pathway_id = f8
     2 pw_status_cd = f8
     2 started_ind = i2
     2 start_dt_tm = f8
     2 start_tz = i4
     2 calc_end_dt_tm = f8
     2 calc_end_tz = i4
     2 encntr_id = f8
 )
 DECLARE l_phase_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_phase_count)/ cnvtreal
    (l_batch_size)))))
 DECLARE l_max_phase_count = i4 WITH protect, constant(value((l_batch_size * l_phase_loop_count)))
 SET stat = alterlist(request->phases,l_max_phase_count)
 FOR (idx = (l_phase_count+ 1) TO l_max_phase_count)
   SET request->phases[idx].pathway_id = request->phases[l_phase_count].pathway_id
 ENDFOR
 SET lstart = 1
 IF (l_phase_loop_count > 0)
  SELECT INTO "nl:"
   pw.pathway_group_id
   FROM (dummyt d  WITH seq = value(l_phase_loop_count)),
    pathway pw
   PLAN (d
    WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
    JOIN (pw
    WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pw.pathway_id,request->phases[idx].
     pathway_id))
   ORDER BY pw.pathway_group_id
   HEAD REPORT
    lphasegroupsize = size(request->phase_groups,5), lphasegroupindex = lphasegroupsize
   HEAD pw.pathway_group_id
    IF (pw.pathway_group_id > 0.00)
     lphasegroupindex = (lphasegroupindex+ 1)
     IF (lphasegroupindex > lphasegroupsize)
      lphasegroupsize = (lphasegroupsize+ l_batch_size), stat = alterlist(request->phase_groups,
       lphasegroupsize)
     ENDIF
     request->phase_groups[lphasegroupindex].pathway_group_id = pw.pathway_group_id
    ENDIF
   DETAIL
    dummy = 0
   FOOT REPORT
    IF (lphasegroupsize > lphasegroupindex)
     stat = alterlist(request->phase_groups,lphasegroupindex)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE l_phase_group_count = i4 WITH protect, constant(value(size(request->phase_groups,5)))
 IF (l_phase_group_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"No phase groups to update.")
  GO TO exit_script
 ENDIF
 DECLARE l_phase_group_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(
     l_phase_group_count)/ cnvtreal(l_batch_size)))))
 DECLARE l_max_phase_group_count = i4 WITH protect, constant(value((l_batch_size *
   l_phase_group_loop_count)))
 SET stat = alterlist(request->phase_groups,l_max_phase_group_count)
 FOR (idx = (l_phase_group_count+ 1) TO l_max_phase_group_count)
   SET request->phase_groups[idx].pathway_group_id = request->phase_groups[l_phase_group_count].
   pathway_group_id
 ENDFOR
 SET lstart = 1
 IF (l_phase_group_loop_count > 0)
  SELECT INTO "nl:"
   parent_phase_ind = evaluate(trim(pw.type_mean),"DOT",0,1)
   FROM (dummyt d  WITH seq = value(l_phase_group_loop_count)),
    pathway pw
   PLAN (d
    WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
    JOIN (pw
    WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pw.pathway_group_id,request->phase_groups[
     idx].pathway_group_id))
   ORDER BY pw.pathway_group_id, parent_phase_ind DESC
   HEAD REPORT
    parent_idx = 0, phase_data->phases_count = 0, bhasinitiatedphase = 0,
    bhasfuturephase = 0, bphasestatusdetermined = 0, bphasevoided = 0
   DETAIL
    IF (pw.pathway_group_id > 0.0)
     IF (parent_phase_ind=1)
      IF (pw.pw_status_cd=pw_void_cd)
       bphasevoided = 1
      ELSE
       phase_data->phases_count = (phase_data->phases_count+ 1), stat = alterlist(phase_data->phases,
        phase_data->phases_count), parent_idx = phase_data->phases_count,
       phase_data->phases[parent_idx].pathway_id = pw.pathway_id, phase_data->phases[parent_idx].
       encntr_id = pw.encntr_id, phase_data->phases[parent_idx].pw_status_cd = pw.pw_status_cd,
       bhasinitiatedphase = 0, bhasfuturephase = 0, bphasestatusdetermined = 0,
       bphasevoided = 0
      ENDIF
     ELSEIF (parent_idx > 0
      AND bphasevoided=0)
      IF (pw.started_ind=1)
       bhasinitiatedphase = 1, phase_data->phases[parent_idx].started_ind = 1
      ENDIF
      IF ((phase_data->phases[parent_idx].start_dt_tm=null))
       phase_data->phases[parent_idx].start_dt_tm = cnvtdatetime(pw.start_dt_tm), phase_data->phases[
       parent_idx].start_tz = pw.start_tz
      ELSEIF (cnvtdatetimeutc(cnvtdatetime(phase_data->phases[parent_idx].start_dt_tm),3,phase_data->
       phases[parent_idx].start_tz) > cnvtdatetimeutc(cnvtdatetime(pw.start_dt_tm),3,pw.start_tz))
       phase_data->phases[parent_idx].start_dt_tm = cnvtdatetime(pw.start_dt_tm), phase_data->phases[
       parent_idx].start_tz = pw.start_tz
      ENDIF
      IF ((phase_data->phases[parent_idx].calc_end_dt_tm=null))
       phase_data->phases[parent_idx].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm), phase_data->
       phases[parent_idx].calc_end_tz = pw.calc_end_tz
      ELSEIF (cnvtdatetimeutc(cnvtdatetime(phase_data->phases[parent_idx].calc_end_dt_tm),3,
       phase_data->phases[parent_idx].calc_end_tz) < cnvtdatetimeutc(cnvtdatetime(pw.calc_end_dt_tm),
       3,pw.calc_end_tz))
       phase_data->phases[parent_idx].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm), phase_data->
       phases[parent_idx].calc_end_tz = pw.calc_end_tz
      ENDIF
      IF (bphasestatusdetermined=0)
       IF (pw.pw_status_cd IN (pw_void_cd, pw_planned_cd, pw_initreview_cd, pw_futurereview_cd,
       pw_initiated_cd))
        bphasestatusdetermined = 1
        IF (pw.pw_status_cd=pw_initiated_cd
         AND (phase_data->phases[parent_idx].pw_status_cd=pw_future_cd))
         phase_data->phases[parent_idx].encntr_id = pw.encntr_id
        ENDIF
        phase_data->phases[parent_idx].pw_status_cd = pw.pw_status_cd
       ELSEIF (((pw.pw_status_cd=pw_future_cd) OR (((pw.pw_status_cd=pw_completed_cd) OR (pw
       .pw_status_cd=pw_discontinued_cd
        AND (phase_data->phases[parent_idx].pw_status_cd != pw_completed_cd))) )) )
        IF (pw.pw_status_cd=pw_future_cd)
         bhasfuturephase = 1
        ELSE
         phase_data->phases[parent_idx].pw_status_cd = pw.pw_status_cd
        ENDIF
        IF (bhasfuturephase=1)
         IF (bhasinitiatedphase=1)
          bphasestatusdetermined = 1, phase_data->phases[parent_idx].pw_status_cd = pw_initiated_cd
         ELSE
          phase_data->phases[parent_idx].pw_status_cd = pw_future_cd
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   WITH forupdatewait(pw), nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  CALL set_script_status("F","SELECT","F",s_script_name,"Failed to lock rows on the pathway table.")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(phase_data->phases_count)),
   pathway pw
  SET pw.pw_status_cd = phase_data->phases[d.seq].pw_status_cd, pw.encntr_id = phase_data->phases[d
   .seq].encntr_id, pw.status_dt_tm = cnvtdatetime(curdate,curtime3),
   pw.status_tz = phase_data->phases[d.seq].start_tz, pw.status_prsnl_id = reqinfo->updt_id, pw
   .started_ind = phase_data->phases[d.seq].started_ind,
   pw.start_dt_tm = cnvtdatetime(phase_data->phases[d.seq].start_dt_tm), pw.start_tz = phase_data->
   phases[d.seq].start_tz, pw.calc_end_dt_tm = cnvtdatetime(phase_data->phases[d.seq].calc_end_dt_tm),
   pw.calc_end_tz = phase_data->phases[d.seq].calc_end_tz, pw.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), pw.updt_id = reqinfo->updt_id,
   pw.updt_task = reqinfo->updt_task, pw.updt_cnt = (pw.updt_cnt+ 1), pw.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (pw
   WHERE (pw.pathway_id=phase_data->phases[d.seq].pathway_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,"Failed to update rows on the pathway table."
   )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pwpa.*
  FROM (dummyt d  WITH seq = value(phase_data->phases_count)),
   pw_processing_action pwpa
  PLAN (d)
   JOIN (pwpa
   WHERE (pwpa.pathway_id=phase_data->phases[d.seq].pathway_id))
  WITH forupdatewait(pwpa), nocounter
 ;end select
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,"Unable to lock pw_processing_action record")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(phase_data->phases_count)),
   pw_processing_action pwpa
  SET pwpa.encntr_id = phase_data->phases[d.seq].encntr_id, pwpa.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), pwpa.updt_id = reqinfo->updt_id,
   pwpa.updt_task = reqinfo->updt_task, pwpa.updt_cnt = (pwpa.updt_cnt+ 1), pwpa.updt_applctx =
   reqinfo->updt_applctx
  PLAN (d)
   JOIN (pwpa
   WHERE (pwpa.pathway_id=phase_data->phases[d.seq].pathway_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,
   "Failed to update rows on the pw_processing_action table.")
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
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL set_script_status("F","CCL ERROR","F",s_script_name,errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 FREE RECORD phase_data
 SET last_mod = "003"
 SET mod_date = "July 20, 2011"
END GO
