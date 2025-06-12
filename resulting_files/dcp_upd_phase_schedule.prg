CREATE PROGRAM dcp_upd_phase_schedule
 SET modify = predeclare
 FREE RECORD phase_data
 RECORD phase_data(
   1 list[*]
     2 pathway_id = f8
     2 new
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 stop_dt_tm = dq8
       3 stop_tz = i4
       3 facility_cd = f8
       3 nursing_unit_cd = f8
       3 updt_cnt = i4
       3 pathway_action_sequence = i4
     2 old
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 end_dt_tm = dq8
       3 end_tz = i4
       3 pw_status_cd = f8
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 start_estimated_ind = i2
       3 calc_end_estimated_ind = i2
       3 updt_cnt = i4
       3 pathway_action_sequence = i4
 )
 DECLARE l_phase_count = i4 WITH protect, constant(value(size(request->phase_list,5)))
 DECLARE l_batch_size = i4 WITH protect, constant(20)
 DECLARE l_loop_count = i4 WITH protect, constant(value(ceil((cnvtreal(l_phase_count)/ cnvtreal(
     l_batch_size)))))
 DECLARE l_phase_size = i4 WITH protect, constant(value((l_batch_size * l_loop_count)))
 DECLARE action_type_modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "SCHEDMODIFY"))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, noconstant(1)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE lactiontz = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_phase_count < 1)
  CALL set_script_status("Z","BEGIN","Z","dcp_upd_phase_schedule","The phase_list was empty.")
  GO TO exit_script
 ENDIF
 IF (curutc=1)
  SET lactiontz = curtimezonesys
 ENDIF
 SET stat = alterlist(phase_data->list,l_phase_size)
 FOR (idx = 1 TO l_phase_count)
   SET phase_data->list[idx].pathway_id = request->phase_list[idx].pathway_id
   SET phase_data->list[idx].new.start_dt_tm = cnvtdatetime(request->phase_list[idx].start_dt_tm)
   SET phase_data->list[idx].new.start_tz = request->phase_list[idx].start_tz
   SET phase_data->list[idx].new.stop_dt_tm = cnvtdatetime(request->phase_list[idx].stop_dt_tm)
   SET phase_data->list[idx].new.stop_tz = request->phase_list[idx].stop_tz
   SET phase_data->list[idx].new.facility_cd = request->phase_list[idx].facility_cd
   SET phase_data->list[idx].new.nursing_unit_cd = request->phase_list[idx].nursing_unit_cd
 ENDFOR
 FOR (idx = (l_phase_count+ 1) TO l_phase_size)
   SET phase_data->list[idx].pathway_id = phase_data->list[l_phase_count].pathway_id
 ENDFOR
 SET lstart = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(l_loop_count)),
   pathway pw,
   pathway_action pa
  PLAN (d
   WHERE initarray(lstart,evaluate(d.seq,1,1,(lstart+ l_batch_size))))
   JOIN (pw
   WHERE expand(idx,lstart,(lstart+ (l_batch_size - 1)),pw.pathway_id,phase_data->list[idx].
    pathway_id))
   JOIN (pa
   WHERE pw.pathway_id=pa.pathway_id)
  ORDER BY pw.pathway_id
  HEAD REPORT
   idx = 0
  HEAD pw.pathway_id
   idx = locateval(idx,1,l_phase_count,pw.pathway_id,phase_data->list[idx].pathway_id)
   IF (idx > 0)
    phase_data->list[idx].old.updt_cnt = pw.updt_cnt, phase_data->list[idx].old.duration_qty = pw
    .duration_qty, phase_data->list[idx].old.duration_unit_cd = pw.duration_unit_cd,
    phase_data->list[idx].old.start_dt_tm = cnvtdatetime(pw.start_dt_tm), phase_data->list[idx].old.
    start_tz = pw.start_tz, phase_data->list[idx].old.start_estimated_ind = pw.start_estimated_ind,
    phase_data->list[idx].old.end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm), phase_data->list[idx].old.
    end_tz = pw.calc_end_tz, phase_data->list[idx].old.calc_end_estimated_ind = pw
    .calc_end_estimated_ind,
    phase_data->list[idx].old.pw_status_cd = pw.pw_status_cd
   ENDIF
  DETAIL
   IF (idx > 0)
    phase_data->list[idx].old.pathway_action_sequence = (phase_data->list[idx].old.
    pathway_action_sequence+ 1)
   ENDIF
  FOOT  pw.pathway_id
   IF (idx > 0)
    phase_data->list[idx].new.pathway_action_sequence = (phase_data->list[idx].old.
    pathway_action_sequence+ 1), phase_data->list[idx].new.updt_cnt = (phase_data->list[idx].old.
    updt_cnt+ 1)
   ENDIF
  WITH forupdatewait(pw), nocounter
 ;end select
 IF (curqual=0)
  CALL set_script_status("F","SELECT","F","dcp_upd_phase_schedule",
   "Failed to lock rows on the pathway table.")
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(l_phase_count)),
   pathway pw
  SET pw.start_dt_tm = cnvtdatetime(phase_data->list[d.seq].new.start_dt_tm), pw.start_tz =
   phase_data->list[d.seq].new.start_tz, pw.start_estimated_ind = 0,
   pw.calc_end_dt_tm = cnvtdatetime(phase_data->list[d.seq].new.stop_dt_tm), pw.calc_end_tz =
   phase_data->list[d.seq].new.stop_tz, pw.calc_end_estimated_ind = 0,
   pw.future_location_facility_cd = phase_data->list[d.seq].new.facility_cd, pw
   .future_location_nurse_unit_cd = phase_data->list[d.seq].new.nursing_unit_cd, pw.last_action_seq
    = phase_data->list[d.seq].new.pathway_action_sequence,
   pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_id = request->personnel_id, pw.updt_task
    = 601500,
   pw.updt_cnt = (pw.updt_cnt+ 1), pw.updt_applctx = 600005
  PLAN (d)
   JOIN (pw
   WHERE (pw.pathway_id=phase_data->list[d.seq].pathway_id))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL set_script_status("F","UPDATE","F","dcp_upd_phase_schedule",
   "Failed to update rows on the pathway table.")
  GO TO exit_script
 ENDIF
 INSERT  FROM (dummyt d  WITH seq = value(l_phase_count)),
   pathway_action pa
  SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = phase_data->list[d.seq].
   pathway_id, pa.pw_action_seq = phase_data->list[d.seq].new.pathway_action_sequence,
   pa.pw_status_cd = phase_data->list[d.seq].old.pw_status_cd, pa.action_type_cd =
   action_type_modify_cd, pa.action_dt_tm = cnvtdatetime(curdate,curtime3),
   pa.action_prsnl_id = request->personnel_id, pa.duration_qty = phase_data->list[d.seq].old.
   duration_qty, pa.duration_unit_cd = phase_data->list[d.seq].old.duration_unit_cd,
   pa.start_dt_tm = cnvtdatetime(phase_data->list[d.seq].old.start_dt_tm), pa.start_tz = phase_data->
   list[d.seq].old.start_tz, pa.start_estimated_ind = phase_data->list[d.seq].old.start_estimated_ind,
   pa.end_dt_tm = cnvtdatetime(phase_data->list[d.seq].old.end_dt_tm), pa.end_tz = phase_data->list[d
   .seq].old.end_tz, pa.end_estimated_ind = phase_data->list[d.seq].old.calc_end_estimated_ind,
   pa.action_tz = lactiontz, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = request->
   personnel_id,
   pa.updt_task = 601500, pa.updt_cnt = phase_data->list[d.seq].new.updt_cnt, pa.updt_applctx =
   600005
  PLAN (d)
   JOIN (pa
   WHERE (pa.pathway_id=phase_data->list[d.seq].pathway_id))
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL set_script_status("F","INSERT","F","dcp_upd_phase_schedule",
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
   CALL set_script_status("F","CCL ERROR","F","dcp_upd_phase_schedule",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 FREE RECORD phase_data
 SET last_mod = "003"
 SET mod_date = "July 20, 2011"
END GO
