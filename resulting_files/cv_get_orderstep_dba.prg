CREATE PROGRAM cv_get_orderstep:dba
 SET modify = predeclare
 FREE RECORD reply
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderstep_list[*]
      2 cv_step_id = f8
      2 cv_proc_id = f8
      2 task_assay_cd = f8
      2 step_status_cd = f8
      2 event_id = f8
      2 sequence = i4
      2 cv_step_sched_list[*]
        3 arrive_dt_tm = dq8
        3 arrive_ind = i2
        3 sched_loc_cd = f8
        3 sched_phys_id = f8
        3 sched_start_dt_tm = dq8
        3 sched_stop_dt_tm = dq8
        3 perf_loc_cd = f8
        3 perf_phys_id = f8
        3 perf_start_dt_tm = dq8
        3 perf_stop_dt_tm = dq8
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE cvidlistsize = i4 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE criteriasearch(no_param=i2(value)) = i2
 SET cvidlistsize = size(request->cv_step_id_list,5)
 SET stat = alterlist(reply->orderstep_list,10)
 IF (cvidlistsize > 0
  AND (request->load_sched_ind=0))
  SELECT INTO "nl:"
   *
   FROM cv_step cvs
   WHERE expand(num,1,cvidlistsize,cvs.cv_step_id,request->cv_step_id_list[num].cv_step_id)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count > 1)
     stat = alterlist(reply->orderstep_list,(count+ 9))
    ENDIF
    reply->orderstep_list[count].cv_step_id = cvs.cv_step_id, reply->orderstep_list[count].cv_proc_id
     = cvs.cv_proc_id, reply->orderstep_list[count].task_assay_cd = cvs.task_assay_cd,
    reply->orderstep_list[count].step_status_cd = cvs.step_status_cd, reply->orderstep_list[count].
    event_id = cvs.event_id, reply->orderstep_list[count].sequence = cvs.sequence,
    reply->orderstep_list[count].updt_cnt = cvs.updt_cnt
   WITH nocounter
  ;end select
  SET failed = 1
 ELSE
  IF (cvidlistsize=0)
   IF (((cnvtdatetime(request->sched_req_begin_dt_tm) <= 0) OR (cnvtdatetime(request->
    sched_req_end_dt_tm) <= 0)) )
    GO TO exit_script
   ENDIF
  ENDIF
  CALL criteriasearch(0)
  SET failed = 1
 ENDIF
#exit_script
 SET stat = alterlist(reply->orderstep_list,count)
 IF (failed=0)
  SET reply->status_data.status = "F"
 ELSE
  IF (count=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SUBROUTINE criteriasearch(no_param)
   DECLARE serreslistsize = i4 WITH protect, noconstant(0)
   DECLARE stepstatuslistsize = i4 WITH protect, noconstant(0)
   DECLARE buffer[60] = c150 WITH protect, noconstant(fillstring(150," "))
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE iterate = i4 WITH noconstant(0), private
   DECLARE powerchartcodevalue = f8 WITH noconstant(0.0), protect
   SET serreslistsize = size(request->service_resource_list,5)
   SET stepstatuslistsize = size(request->step_status_list,5)
   SET stat = alterlist(reply->orderstep_list[count].cv_step_sched_list,1)
   SET cvidlistsize = size(request->cv_step_id_list,5)
   SET powerchartcodevalue = uar_get_code_by("MEANING",73,"POWERCHART")
   SET buffer[1] = 'select into "nl:" '
   SET buffer[2] = "from cv_step cvs, cv_step_sched cvs_sched"
   SET x = 3
   IF ((request->modality != ""))
    SET buffer[x] = ", cv_step_ref cvs_ref, code_value_alias cva"
    SET x = (x+ 1)
   ENDIF
   IF ((request->sps_description != ""))
    SET buffer[x] = ", discrete_task_assay dta"
    SET x = (x+ 1)
   ENDIF
   IF ((((request->sched_perf_phys_name_last != "")) OR ((request->sched_perf_phys_name_first != "")
   )) )
    SET buffer[x] = ", prsnl prsnl"
    SET buffer[(x+ 1)] = ", person_name pn"
    SET buffer[(x+ 2)] = ", code_value cv"
    SET x = (x+ 3)
   ENDIF
   IF ((request->modality != ""))
    SET buffer[x] = "plan cva"
    SET buffer[(x+ 1)] = " where cva.alias = request->modality"
    SET buffer[(x+ 2)] = " and cva.code_set = 5801"
    SET buffer[(x+ 3)] = " and cva.contributor_source_cd = powerchartCodeValue"
    SET buffer[(x+ 4)] = ' and (trim(cva.alias_type_meaning) in ("", NULL))'
    SET buffer[(x+ 5)] = "join cvs_ref"
    SET buffer[(x+ 6)] = "  where cvs_ref.activity_subtype_cd + 0 = cva.code_value "
    SET buffer[(x+ 7)] = "join cvs_sched"
    SET buffer[(x+ 8)] = "where cvs_sched.task_assay_cd = cvs_ref.task_assay_cd"
    SET buffer[(x+ 9)] = "and "
    SET x = (x+ 10)
   ELSE
    SET buffer[x] = "plan cvs_sched where"
    SET x = (x+ 1)
   ENDIF
   IF (cvidlistsize > 0)
    SET buffer[x] =
    "expand(num,1,cvIdListSize,cvs_sched.cv_step_id,request->cv_step_id_list[num]->cv_step_id)"
    SET x = (x+ 1)
    IF (cnvtdatetime(request->sched_req_begin_dt_tm) > 0
     AND cnvtdatetime(request->sched_req_end_dt_tm) > 0)
     SET buffer[x] = "and cvs_sched.sched_start_dt_tm "
     SET buffer[(x+ 1)] = "  between cnvtdatetime(request->sched_req_begin_dt_tm) "
     SET buffer[(x+ 2)] = "       and cnvtdatetime(request->sched_req_end_dt_tm)"
     SET x = (x+ 3)
    ENDIF
   ELSE
    SET buffer[x] = "cvs_sched.sched_start_dt_tm "
    SET buffer[(x+ 1)] = "  between cnvtdatetime(request->sched_req_begin_dt_tm) "
    SET buffer[(x+ 2)] = "       and cnvtdatetime(request->sched_req_end_dt_tm)"
    SET x = (x+ 3)
   ENDIF
   IF (serreslistsize > 0)
    SET buffer[x] =
    "and expand(num,1,serResListSize,cvs_sched.sched_loc_cd,request->service_resource_list[num]->service_resource_cd)"
    SET x = (x+ 1)
   ENDIF
   IF ((((request->sched_perf_phys_name_last != "")) OR ((request->sched_perf_phys_name_first != "")
   )) )
    SET buffer[x] = "join prsnl"
    SET buffer[(x+ 1)] = "	where prsnl.person_id = cvs_sched.sched_phys_id "
    SET buffer[(x+ 2)] = "	and prsnl.active_ind = 1"
    SET x = (x+ 3)
    IF ((request->sched_perf_phys_name_last != ""))
     SET buffer[x] =
     "	and prsnl.name_last_key = patstring(CNVTUPPER(request->sched_perf_phys_name_last))"
     SET x = (x+ 1)
    ENDIF
    IF ((request->sched_perf_phys_name_first != ""))
     SET buffer[x] =
     "	and prsnl.name_first_key = patstring(CNVTUPPER(request->sched_perf_phys_name_first))"
     SET x = (x+ 1)
    ENDIF
    SET buffer[x] = "join pn"
    SET buffer[(x+ 1)] = "	where pn.person_id = prsnl.person_id "
    SET buffer[(x+ 2)] = "	and pn.active_ind = 1"
    SET buffer[(x+ 3)] = "join cv"
    SET buffer[(x+ 4)] = "	where cv.code_value = pn.name_type_cd"
    SET buffer[(x+ 5)] = "	and cv.code_set + 0 = 213"
    SET buffer[(x+ 6)] = '	and cv.cdf_meaning = "CURRENT"'
    SET x = (x+ 7)
   ENDIF
   SET buffer[x] = "join cvs"
   SET buffer[(x+ 1)] = "  where cvs_sched.cv_step_id = cvs.cv_step_id"
   SET x = (x+ 2)
   IF (stepstatuslistsize > 0)
    SET buffer[x] =
    "and expand(num,1,stepStatusListSize,cvs.step_status_cd,request->step_status_list[num]->step_status_cd)"
    SET x = (x+ 1)
   ENDIF
   IF ((request->sps_description != ""))
    SET buffer[x] = "join dta"
    SET buffer[(x+ 1)] = "  where cvs.task_assay_cd = dta.task_assay_cd"
    SET buffer[(x+ 2)] =
    "  and cnvtupper(dta.description) = patstring(cnvtupper(request->sps_description))"
    SET x = (x+ 3)
   ENDIF
   SET buffer[x] = "detail"
   SET buffer[(x+ 1)] = "  count = count + 1"
   SET buffer[(x+ 2)] = "  if (mod(count, 10) = 1 and (count > 1)) "
   SET buffer[(x+ 3)] = "    stat = alterlist(reply->orderStep_list, count + 9) "
   SET buffer[(x+ 4)] = "  endif"
   SET buffer[(x+ 5)] = "  reply->orderStep_list[count]->cv_step_id = cvs.cv_step_id"
   SET buffer[(x+ 6)] = "  reply->orderStep_list[count]->cv_proc_id = cvs.cv_proc_id"
   SET buffer[(x+ 7)] = "  reply->orderStep_list[count]->task_assay_cd = cvs.task_assay_cd"
   SET buffer[(x+ 8)] = "  reply->orderStep_list[count]->step_status_cd = cvs.step_status_cd"
   SET buffer[(x+ 9)] = "  reply->orderStep_list[count]->event_id = cvs.event_id"
   SET buffer[(x+ 10)] = "  reply->orderStep_list[count]->sequence = cvs.sequence"
   SET buffer[(x+ 11)] = "  stat = alterlist(reply->orderStep_list[count]->cv_step_sched_list, 1) "
   SET buffer[(x+ 12)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->arrive_dt_tm = cvs_sched.arrive_dt_tm"
   SET buffer[(x+ 13)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->arrive_ind = cvs_sched.arrive_ind"
   SET buffer[(x+ 14)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->sched_loc_cd = cvs_sched.sched_loc_cd"
   SET buffer[(x+ 15)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->sched_phys_id = cvs_sched.sched_phys_id"
   SET buffer[(x+ 16)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->sched_start_dt_tm = cvs_sched.sched_start_dt_tm"
   SET buffer[(x+ 17)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->sched_stop_dt_tm = cvs_sched.sched_stop_dt_tm"
   SET buffer[(x+ 18)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->perf_loc_cd = cvs_sched.perf_loc_cd"
   SET buffer[(x+ 19)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->perf_phys_id = cvs_sched.perf_phys_id"
   SET buffer[(x+ 20)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->perf_start_dt_tm = cvs_sched.perf_start_dt_tm"
   SET buffer[(x+ 21)] =
   "  reply->orderStep_list[count]->cv_step_sched_list[1]->perf_stop_dt_tm = cvs_sched.perf_stop_dt_tm"
   SET buffer[(x+ 22)] = "  reply->orderStep_list[count]->updt_cnt = cvs.updt_cnt"
   SET buffer[(x+ 23)] = "with nocounter go"
   SET x = (x+ 24)
   SET iterate = 1
   WHILE (iterate < x)
     CALL echo(buffer[iterate])
     CALL parser(buffer[iterate])
     SET iterate = (iterate+ 1)
   ENDWHILE
 END ;Subroutine
END GO
