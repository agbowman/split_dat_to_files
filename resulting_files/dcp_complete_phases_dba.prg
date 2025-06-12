CREATE PROGRAM dcp_complete_phases:dba
 SET modify = predeclare
 DECLARE s_script_name = vc WITH protect, constant("dcp_complete_phases")
 DECLARE l_phase_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE phase_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE phase_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,"COMPLETE"))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE nfailed = i2 WITH protext, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_phase_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The phase list was empty.")
  GO TO exit_script
 ENDIF
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_phase_count)/ cnvtreal(
     l_batch_size)))))
 DECLARE l_max_phase_count = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 SET stat = alterlist(request->phases,l_max_phase_count)
 FOR (idx = (l_phase_count+ 1) TO l_max_phase_count)
   SET request->phases[idx].pathway_id = request->phases[l_phase_count].pathway_id
 ENDFOR
 DECLARE dq8_current_date_time = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 RECORD phase_data(
   1 phases_count = i4
   1 phases[*]
     2 pathway_id = f8
     2 pw_action_seq = i4
     2 updt_cnt = i4
     2 new
       3 encntr_tz = i4
       3 calc_end_dt_tm = dq8
     2 old
       3 pw_status_cd = f8
       3 action_type_cd = f8
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_prsnl_id = f8
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 start_estimated_ind = i2
       3 end_dt_tm = dq8
       3 end_tz = i4
       3 end_estimated_ind = i2
 )
 SET lstart = 1
 SET nfailed = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway pw,
   pathway_action pa
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pw
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pw.pathway_id,request->phases[idx].pathway_id
    ))
   JOIN (pa
   WHERE pw.pathway_id=pa.pathway_id)
  ORDER BY pw.pathway_id
  HEAD REPORT
   idx = 0, lphaseactioncount = 0, lphaseactionsize = 0
  HEAD pw.pathway_id
   idx = locateval(idx,1,l_phase_count,pw.pathway_id,request->phases[idx].pathway_id)
   IF (idx > 0)
    IF ((pw.updt_cnt != request->phases[idx].updt_cnt))
     stat = alterlist(phase_data->phases,0),
     CALL cancel(1)
    ENDIF
    lphaseactioncount = (lphaseactioncount+ 1)
    IF (lphaseactionsize < lphaseactioncount)
     lphaseactionsize = (lphaseactionsize+ 20), stat = alterlist(phase_data->phases,lphaseactionsize)
    ENDIF
    phase_data->phases[lphaseactioncount].pathway_id = pw.pathway_id, phase_data->phases[
    lphaseactioncount].updt_cnt = (pw.updt_cnt+ 1), phase_data->phases[lphaseactioncount].new.
    encntr_tz = request->phases[idx].encntr_tz,
    phase_data->phases[lphaseactioncount].new.calc_end_dt_tm = cnvtdatetime(request->phases[idx].
     calc_end_dt_tm), phase_data->phases[lphaseactioncount].old.pw_status_cd = pw.pw_status_cd,
    phase_data->phases[lphaseactioncount].old.action_type_cd = phase_action_cd,
    phase_data->phases[lphaseactioncount].old.action_dt_tm = cnvtdatetime(dq8_current_date_time),
    phase_data->phases[lphaseactioncount].old.action_tz = request->user_tz, phase_data->phases[
    lphaseactioncount].old.action_prsnl_id = reqinfo->updt_id,
    phase_data->phases[lphaseactioncount].old.duration_qty = pw.duration_qty, phase_data->phases[
    lphaseactioncount].old.duration_unit_cd = pw.duration_unit_cd, phase_data->phases[
    lphaseactioncount].old.start_dt_tm = cnvtdatetime(pw.start_dt_tm),
    phase_data->phases[lphaseactioncount].old.start_tz = pw.start_tz, phase_data->phases[
    lphaseactioncount].old.start_estimated_ind = pw.start_estimated_ind, phase_data->phases[
    lphaseactioncount].old.end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm),
    phase_data->phases[lphaseactioncount].old.end_tz = pw.calc_end_tz, phase_data->phases[
    lphaseactioncount].old.end_estimated_ind = pw.calc_end_estimated_ind
   ENDIF
  DETAIL
   IF (idx > 0)
    phase_data->phases[lphaseactioncount].pw_action_seq = (phase_data->phases[lphaseactioncount].
    pw_action_seq+ 1)
   ENDIF
  FOOT  pw.pathway_id
   IF (idx > 0)
    phase_data->phases[lphaseactioncount].pw_action_seq = (phase_data->phases[lphaseactioncount].
    pw_action_seq+ 1)
   ENDIF
  FOOT REPORT
   phase_data->phases_count = lphaseactioncount
   IF (lphaseactioncount > 0)
    nfailed = 0
    IF (lphaseactioncount < lphaseactionsize)
     stat = alterlist(phase_data->phases,lphaseactioncount)
    ENDIF
   ENDIF
  WITH forupdate(pw), nocounter
 ;end select
 IF (nfailed=1)
  CALL set_script_status("F","SELECT","F",s_script_name,"Failed to lock rows on the pathway table.")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(phase_data->phases_count)),
   pathway pw
  SET pw.pw_status_cd = phase_status_cd, pw.status_dt_tm = cnvtdatetime(dq8_current_date_time), pw
   .status_tz = phase_data->phases[d.seq].new.encntr_tz,
   pw.status_prsnl_id = reqinfo->updt_id, pw.calc_end_dt_tm =
   IF ((phase_data->phases[d.seq].new.calc_end_dt_tm != null)) cnvtdatetime(phase_data->phases[d.seq]
     .new.calc_end_dt_tm)
   ELSE cnvtdatetime(dq8_current_date_time)
   ENDIF
   , pw.calc_end_tz = phase_data->phases[d.seq].new.encntr_tz,
   pw.calc_end_estimated_ind = 0, pw.last_action_seq = phase_data->phases[d.seq].pw_action_seq, pw
   .updt_dt_tm = cnvtdatetime(dq8_current_date_time),
   pw.updt_id = reqinfo->updt_id, pw.updt_task = reqinfo->updt_task, pw.updt_cnt = phase_data->
   phases[d.seq].updt_cnt,
   pw.updt_applctx = reqinfo->updt_applctx
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
 INSERT  FROM (dummyt d  WITH seq = value(phase_data->phases_count)),
   pathway_action pa
  SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = phase_data->phases[d.seq].
   pathway_id, pa.pw_action_seq = phase_data->phases[d.seq].pw_action_seq,
   pa.pw_status_cd = phase_status_cd, pa.action_type_cd = phase_action_cd, pa.action_dt_tm =
   cnvtdatetime(dq8_current_date_time),
   pa.action_tz = phase_data->phases[d.seq].old.action_tz, pa.action_prsnl_id = phase_data->phases[d
   .seq].old.action_prsnl_id, pa.duration_qty = phase_data->phases[d.seq].old.duration_qty,
   pa.duration_unit_cd = phase_data->phases[d.seq].old.duration_unit_cd, pa.start_dt_tm =
   cnvtdatetime(phase_data->phases[d.seq].old.start_dt_tm), pa.start_tz = phase_data->phases[d.seq].
   old.start_tz,
   pa.start_estimated_ind = phase_data->phases[d.seq].old.start_estimated_ind, pa.end_dt_tm =
   cnvtdatetime(phase_data->phases[d.seq].old.end_dt_tm), pa.end_tz = phase_data->phases[d.seq].old.
   end_tz,
   pa.end_estimated_ind = phase_data->phases[d.seq].old.end_estimated_ind, pa.updt_dt_tm =
   cnvtdatetime(dq8_current_date_time), pa.updt_id = reqinfo->updt_id,
   pa.updt_task = reqinfo->updt_task, pa.updt_cnt = phase_data->phases[d.seq].updt_cnt, pa
   .updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (pa
   WHERE (pa.pathway_id=phase_data->phases[d.seq].pathway_id))
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F",s_script_name,
   "Failed to insert rows into the pathway_action table.")
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
 SET last_mod = "002"
 SET mod_date = "July 20, 2011"
END GO
