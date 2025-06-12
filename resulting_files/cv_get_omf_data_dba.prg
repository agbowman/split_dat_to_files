CREATE PROGRAM cv_get_omf_data:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 surg_case_id = f8
    1 surg_case_proc_id = f8
    1 proc_name_cd = f8
    1 status = i2
    1 create_dt_tm = dq8
    1 surg_case_nbr = vc
    1 surg_case_nbr_locn_cd = f8
    1 surg_area_cd = f8
    1 surg_case_nbr_yr = i4
    1 surg_case_nbr_cnt = i4
    1 accn_site_prefix = c5
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD procedure_rec(
   1 procedures[*]
     2 surg_case_id = f8
     2 surg_case_proc_id = f8
     2 proc_type_cd = f8
     2 proc_start_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
 )
 RECORD proc_abstr_data_rec(
   1 abstract[*]
     2 procedure_id = f8
     2 result_val = vc
     2 nomenclature_id = f8
     2 proc_abstr_dt_tm = dq8
     2 proc_name_cd = f8
 )
 SET proc_count = 0
 CALL echo(build("reply->surg_case_id:",reply->surg_case_id))
 SELECT INTO "nl:"
  sc.sched_start_dt_tm
  FROM surgical_case sc,
   surg_case_procedure scp
  PLAN (sc
   WHERE (sc.surg_case_id=reply->surg_case_id))
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id)
  ORDER BY sc.surg_case_id, scp.surg_case_proc_id
  HEAD REPORT
   sched_start_dt_tm_formatted = fillstring(25," "), sched_start_time_string = fillstring(4," "),
   sched_start_time = 0,
   date_diff = 0, proc_count = 0
  HEAD sc.surg_case_id
   sched_start_dt_tm_formatted = format(sc.sched_start_dt_tm,"dd-mmm-yyyy hh:mm:ss.cc;;d"),
   sched_start_time_string = concat(substring(13,02,sched_start_dt_tm_formatted),substring(16,02,
     sched_start_dt_tm_formatted))
   IF (size(trim(sched_start_time_string)) > 0)
    surgical_case_rec->sched_qty = 1, surgical_case_rec->sched_start_hour = hour(cnvtint(
      sched_start_time_string)), surgical_case_rec->sched_start_day = weekday(cnvtdatetime(
      sched_start_dt_tm_formatted)),
    surgical_case_rec->sched_start_month = month(cnvtdatetime(sched_start_dt_tm_formatted))
   ELSE
    surgical_case_rec->sched_qty = 0, surgical_case_rec->sched_start_hour = - (1), surgical_case_rec
    ->sched_start_day = - (1),
    surgical_case_rec->sched_start_month = - (1)
   ENDIF
   surgical_case_rec->case_number_formatted = reply->surg_case_nbr
  HEAD scp.surg_case_proc_id
   proc_count = (proc_count+ 1), stat = alterlist(surg_proc_rec->procedures,proc_count),
   surg_proc_rec->procedures[proc_count].surg_case_proc_id = scp.surg_case_proc_id
   IF (size(trim(sched_start_time_string)) > 0)
    surg_proc_rec->procedures[proc_count].sched_qty = 1
   ELSE
    surg_proc_rec->procedures[proc_count].sched_qty = 0
   ENDIF
   IF (scp.primary_proc_ind=1)
    surgical_case_rec->sched_anesth_type_cd = scp.sched_anesth_type_cd
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("curqual:",curqual))
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET institution_type_cd = 0
 SET department_type_cd = 0
 SET surgarea_type_cd = 0
 SELECT INTO "nl:"
  cv = cv.code_value, cdf = cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SURGAREA")
   AND cv.active_ind=1
  DETAIL
   CASE (cdf)
    OF "INSTITUTION":
     institution_type_cd = cv
    OF "DEPARTMENT":
     department_type_cd = cv
    OF "SURGAREA":
     surgarea_type_cd = cv
   ENDCASE
  WITH nocounter
 ;end select
 CALL echo(build("department_type_cd = ",department_type_cd))
 CALL echo(build("institution_type_cd = ",institution_type_cd))
 SET surgical_case_rec->dept_cd = get_res_parent(request->surg_area_cd,department_type_cd)
 SET surgical_case_rec->inst_cd = get_res_parent(surgical_case_rec->dept_cd,institution_type_cd)
 FOR (x = 1 TO size(surg_proc_rec->procedures,5))
  SET surg_proc_rec->procedures[x].inst_cd = surgical_case_rec->inst_cd
  SET surg_proc_rec->procedures[x].dept_cd = surgical_case_rec->dept_cd
 ENDFOR
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM surgical_case sc
  SET sc.inst_cd = surgical_case_rec->inst_cd, sc.dept_cd = surgical_case_rec->dept_cd, sc
   .surg_case_nbr_formatted = surgical_case_rec->case_number_formatted,
   sc.sched_qty = surgical_case_rec->sched_qty, sc.sched_start_hour = surgical_case_rec->
   sched_start_hour, sc.sched_start_day = surgical_case_rec->sched_start_day,
   sc.sched_start_month = surgical_case_rec->sched_start_month, sc.sched_anesth_type_cd =
   surgical_case_rec->sched_anesth_type_cd
  WHERE (sc.surg_case_id=reply->surg_case_id)
  WITH nocounter
 ;end update
 CALL echo(build("inst cd:",surgical_case_rec->inst_cd))
 CALL echo(build("dept cd:",surgical_case_rec->dept_cd))
 CALL echo(build("case number:",surgical_case_rec->case_number_formatted))
 CALL echo(build("sched qty:",surgical_case_rec->sched_qty))
 CALL echo(build("sched start hour:",surgical_case_rec->sched_start_hour))
 CALL echo(build("sched start day:",surgical_case_rec->sched_start_day))
 CALL echo(build("sched start month:",surgical_case_rec->sched_start_month))
 CALL echo(build("sched anesth type cd:",surgical_case_rec->sched_anesth_type_cd))
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM surg_case_procedure scp,
   (dummyt d1  WITH seq = value(proc_count))
  SET scp.inst_cd = surg_proc_rec->procedures[d1.seq].inst_cd, scp.dept_cd = surg_proc_rec->
   procedures[d1.seq].dept_cd, scp.sched_qty = surg_proc_rec->procedures[d1.seq].sched_qty
  PLAN (d1)
   JOIN (scp
   WHERE (scp.surg_case_proc_id=surg_proc_rec->procedures[d1.seq].surg_case_proc_id))
  WITH nocounter
 ;end update
 GO TO exit_script
 SUBROUTINE get_res_parent(is1_child,is1_resource_type)
   SET parent_cd = 0
   SELECT INTO "nl:"
    rg.parent_service_resource_cd
    FROM resource_group rg
    WHERE rg.child_service_resource_cd=is1_child
     AND rg.resource_group_type_cd=is1_resource_type
     AND rg.active_ind=1
    DETAIL
     parent_cd = rg.parent_service_resource_cd
    WITH nocounter
   ;end select
   RETURN(parent_cd)
 END ;Subroutine
#exit_script
END GO
