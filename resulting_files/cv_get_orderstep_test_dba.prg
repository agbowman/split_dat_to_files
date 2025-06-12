CREATE PROGRAM cv_get_orderstep_test:dba
 SET modify = predeclare
 FREE RECORD reply
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderstep_list[*]
      2 cv_step_id = f8
      2 sched_req_dt_tm = dq8
      2 proc_id = f8
      2 task_assay_cd = f8
      2 sps_description = vc
      2 service_resource_cd = f8
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
 DECLARE cvidlistsize = i4 WITH public, noconstant(0)
 DECLARE failed = i2 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE criteriasearch(no_param=i2(value)) = i2
 SET cvidlistsize = size(request->cv_step_id_list,5)
 SET stat = alterlist(reply->orderstep_list,10)
 IF (cvidlistsize=0)
  IF (((cnvtdatetime(request->sched_req_begin_dt_tm) <= 0) OR (cnvtdatetime(request->
   sched_req_end_dt_tm) <= 0)) )
   CALL echo("In the failed section.")
   GO TO exit_script
  ELSE
   CALL criteriasearch(0)
   SET failed = 1
  ENDIF
 ELSE
  SELECT INTO "n1:"
   *
   FROM cv_steps cvs,
    discrete_task_assay dta
   PLAN (cvs
    WHERE expand(num,1,cvidlistsize,cvs.cv_step_id,request->cv_step_id_list[num].cv_step_id))
    JOIN (dta
    WHERE dta.task_assay_cd=cvs.task_assay_cd)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count > 1)
     stat = alterlist(reply->orderstep_list,(count+ 9))
    ENDIF
    reply->orderstep_list[count].cv_step_id = cvs.cv_step_id, reply->orderstep_list[count].
    sched_req_dt_tm = cvs.start_dt_tm, reply->orderstep_list[count].proc_id = cvs.proc_id,
    reply->orderstep_list[count].task_assay_cd = cvs.task_assay_cd, reply->orderstep_list[count].
    service_resource_cd = cvs.service_resource_cd, reply->orderstep_list[count].updt_cnt = cvs
    .updt_cnt,
    reply->orderstep_list[count].sps_description = dta.description
   WITH nocounter
  ;end select
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
   DECLARE serreslistsize = i4 WITH public, noconstant(0)
   DECLARE patientsize = i2 WITH public, noconstant(0)
   DECLARE buffer[55] = c150 WITH noconstant(""), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE iterate = i4 WITH noconstant(0), private
   SET serreslistsize = size(request->service_resource_list,5)
   SET patientsize = size(request->patient_list,5)
   SELECT INTO "nl:"
    FROM cv_steps cvs,
     discrete_task_assay dta,
     cv_proc cv_proc,
     order_catalog order_cat,
     code_value_alias cva,
     prsnl prsnl,
     person_name pn,
     code_value cv
    PLAN (cvs
     WHERE cvs.start_dt_tm BETWEEN cnvtdatetime(request->sched_req_begin_dt_tm) AND cnvtdatetime(
      request->sched_req_end_dt_tm)
      AND expand(num,1,serreslistsize,cvs.service_resource_cd,request->service_resource_list[num].
      service_resource_cd))
     JOIN (dta
     WHERE dta.task_assay_cd=cvs.task_assay_cd
      AND (dta.description=request->sps_description))
     JOIN (cv_proc
     WHERE cv_proc.proc_id=cvs.proc_id
      AND expand(num,1,patientsize,cv_proc.person_id,request->patient_list[num].person_id))
     JOIN (prsnl
     WHERE prsnl.person_id=cv_proc.perf_physician_id
      AND prsnl.active_ind=1
      AND prsnl.name_last_key=patstring(request->sched_perf_physician_name_last)
      AND prsnl.name_first_key=patstring(request->sched_perf_physician_name_first))
     JOIN (pn
     WHERE pn.person_id=prsnl.person_id
      AND pn.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=pn.name_type_cd
      AND ((cv.code_set+ 0)=213)
      AND cv.cdf_meaning="CURRENT")
     JOIN (order_cat
     WHERE order_cat.catalog_cd=cv_proc.catalog_cd
      AND (order_cat.description=request->req_proc_desc))
     JOIN (cva
     WHERE (cva.code_value=(order_cat.activity_subtype_cd+ 0))
      AND (cva.alias=request->modality))
    DETAIL
     count = (count+ 1)
     IF (mod(count,10)=1
      AND count > 1)
      stat = alterlist(reply->orderstep_list,(count+ 9))
     ENDIF
     reply->orderstep_list[count].cv_step_id = cvs.cv_step_id, reply->orderstep_list[count].
     sched_req_dt_tm = cvs.start_dt_tm, reply->orderstep_list[count].proc_id = cvs.proc_id,
     reply->orderstep_list[count].task_assay_cd = cvs.task_assay_cd, reply->orderstep_list[count].
     service_resource_cd = cvs.service_resource_cd, reply->orderstep_list[count].updt_cnt = cvs
     .updt_cnt,
     reply->orderstep_list[count].sps_description = dta.description
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
