CREATE PROGRAM dcp_icu_get_equation_info:dba
 RECORD reply(
   1 dta_cnt = i4
   1 dta[*]
     2 task_assay_cd = f8
     2 active_ind = i2
     2 equation_id = f8
     2 equation_description = vc
     2 equation_postfix = vc
     2 script = vc
     2 e_comp_cnt = i4
     2 e_comp[*]
       3 constant_value = f8
       3 default_value = f8
       3 included_assay_cd = f8
       3 name = vc
       3 result_req_flag = i2
       3 time_window_back_minutes = f8
       3 event_cd = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET dta_cnt = size(request->dta,5)
 SET reply->dta_cnt = size(request->dta,5)
 SET stat = alterlist(reply->dta,dta_cnt)
 CALL echo(build("dta cnt:",dta_cnt))
 SELECT INTO "nl:"
  dta.task_assay_cd, dta_exists = decode(dta.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(dta_cnt)),
   discrete_task_assay dta
  PLAN (d)
   JOIN (dta
   WHERE (dta.task_assay_cd=request->dta[d.seq].task_assay_cd)
    AND dta.active_ind=1
    AND ((dta.beg_effective_dt_tm=null) OR (dta.beg_effective_dt_tm != null
    AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((dta.end_effective_dt_tm=null) OR (dta.end_effective_dt_tm != null
    AND dta.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
  HEAD REPORT
   count1 = 0
  DETAIL
   reply->dta[d.seq].task_assay_cd = request->dta[d.seq].task_assay_cd
   IF (dta_exists="Y")
    reply->dta[d.seq].active_ind = 1
   ELSE
    reply->dta[d.seq].active_ind = 0
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET species_value = 32
 SET specimen_type_value = 16
 SET sex_value = 8
 SET age_value = 4
 SET resource_ts_value = 2
 SET resource_ts_group_value = 1
 SET pat_cond_value = 0
 SET tot_value = 0
 SET highest_tot_value = - (1)
 SELECT INTO "nl:"
  e.task_assay_cd, e.equation_id, e_exists = decode(e.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(dta_cnt)),
   equation e,
   equation_component ec,
   dummyt d1,
   discrete_task_assay dta
  PLAN (d)
   JOIN (e
   WHERE (e.task_assay_cd=reply->dta[d.seq].task_assay_cd)
    AND (reply->dta[d.seq].active_ind=1)
    AND e.active_ind=1)
   JOIN (ec
   WHERE ec.equation_id=e.equation_id)
   JOIN (d1)
   JOIN (dta
   WHERE ec.included_assay_cd=dta.task_assay_cd)
  HEAD REPORT
   cnt = 0, q_cnt = 0, e_cnt = 0,
   load_components = "N"
  HEAD e.task_assay_cd
   highest_tot_value = 0
  HEAD e.equation_id
   IF (e_exists="Y")
    e_cnt = 0, tot_value = 0
    IF ((e.species_cd=request->species_cd))
     tot_value = (tot_value+ species_value)
    ENDIF
    IF ((e.sex_cd=request->sex_cd))
     tot_value = (tot_value+ sex_value)
    ENDIF
    IF ((e.age_from_minutes <= request->age_in_min)
     AND (e.age_to_minutes >= request->age_in_min))
     tot_value = (tot_value+ age_value)
    ENDIF
    IF ((e.service_resource_cd=request->service_resource_cd))
     tot_value = (tot_value+ resource_ts_value)
    ENDIF
    IF (tot_value > highest_tot_value)
     highest_tot_value = tot_value, reply->dta[d.seq].equation_id = e.equation_id, reply->dta[d.seq].
     equation_description = e.equation_description,
     reply->dta[d.seq].equation_postfix = e.equation_postfix, reply->dta[d.seq].script = e.script,
     reply->dta[d.seq].e_comp_cnt = 0,
     load_components = "Y"
    ENDIF
   ENDIF
  DETAIL
   IF (load_components="Y")
    e_cnt = (e_cnt+ 1), stat = alterlist(reply->dta[d.seq].e_comp,e_cnt), reply->dta[d.seq].e_comp[
    e_cnt].constant_value = ec.constant_value,
    reply->dta[d.seq].e_comp[e_cnt].default_value = ec.default_value, reply->dta[d.seq].e_comp[e_cnt]
    .included_assay_cd = ec.included_assay_cd, reply->dta[d.seq].e_comp[e_cnt].name = ec.name,
    reply->dta[d.seq].e_comp[e_cnt].result_req_flag = ec.result_req_flag, reply->dta[d.seq].e_comp[
    e_cnt].time_window_back_minutes = ec.time_window_back_minutes, reply->dta[d.seq].e_comp[e_cnt].
    event_cd = dta.event_cd,
    reply->dta[d.seq].e_comp[e_cnt].description = dta.description, reply->dta[d.seq].e_comp_cnt =
    e_cnt
   ENDIF
  FOOT  e.equation_id
   load_components = "N"
  WITH nocounter, outerjoin = d1
 ;end select
#exit_script
 SET call_echo_ind = 1
 IF (call_echo_ind)
  CALL echorecord(reply)
 ENDIF
END GO
