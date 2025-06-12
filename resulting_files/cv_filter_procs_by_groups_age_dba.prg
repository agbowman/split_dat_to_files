CREATE PROGRAM cv_filter_procs_by_groups_age:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE g_act_start_dt_tm = dq8 WITH noconstant(validate(request->action_start_dt_tm,0.0)), protect
 DECLARE g_act_stop_dt_tm = dq8 WITH noconstant(validate(request->action_stop_dt_tm,0.0)), protect
 DECLARE all_groups = i4 WITH constant(0), protect
 DECLARE mine = i4 WITH constant(1), protect
 DECLARE mineandmygroups = i4 WITH constant(2), protect
 DECLARE groupid = i4 WITH constant(3), protect
 DECLARE age = i4 WITH noconstant(validate(request->age,- (1))), protect
 DECLARE age_group = i4 WITH noconstant(validate(request->age_group,- (1))), protect
 DECLARE age_show = i4 WITH noconstant(validate(request->age_show,- (1))), protect
 DECLARE cal_age = vc WITH protect
 DECLARE age_value = vc WITH protect
 DECLARE age_cal = i4 WITH protect
 DECLARE replycnt = i4 WITH noconstant(0), protect
 DECLARE getprocedureswithagefilter(dummy) = null WITH protect
 DECLARE getprocedureswithgroupfilter(dummy) = null WITH protect
 DECLARE getprocedureswithgroupandagefilter(dummy) = null WITH protect
 IF (validate(reply) != 1)
  RECORD reply(
    1 qual[*]
      2 cv_proc_id = f8
      2 stress_ecg_status_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ((request->my_group_id > all_groups)
  AND ((age_show=0) OR (age_show=1)) )
  CALL getprocedureswithgroupandagefilter(0)
 ELSEIF ((request->my_group_id=all_groups)
  AND ((age_show=0) OR (age_show=1)) )
  CALL getprocedureswithagefilter(0)
 ELSEIF ((request->my_group_id > all_groups)
  AND (age_show=- (1)))
  CALL echo("entering group filter")
  CALL getprocedureswithgroupfilter(0)
  CALL echo("exit group filter")
 ENDIF
 SUBROUTINE (performagefilter(filter_age=i4,convert_age=vc,proc_id=f8,stress_ecg_status_cd=f8) =null
  WITH protect)
   DECLARE filter_age_in_hrs = i4 WITH protect, noconstant(0)
   SET age_value = piece(convert_age,":",1,"")
   SET filter_age_in_hrs = calcfilterageinhours(filter_age)
   SET age_cal = cnvtint(age_value)
   IF (age_show=1)
    IF (age_group=1)
     IF (age_cal >= filter_age_in_hrs)
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ENDIF
    ELSEIF (age_group=0)
     IF (age_cal < filter_age_in_hrs)
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ENDIF
    ENDIF
   ELSEIF (age_show=0)
    IF (age_group=1)
     IF (age_cal < filter_age_in_hrs)
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ENDIF
    ELSEIF (age_group=0)
     IF (age_cal >= filter_age_in_hrs)
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprocedureswithagefilter(dummy)
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "nl:"
    FROM cv_proc p,
     person pr
    PLAN (p
     WHERE p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm))
     JOIN (pr
     WHERE p.person_id=pr.person_id)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performagefilter(age,cal_age,p.cv_proc_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "n1:"
    FROM cv_proc p,
     cv_step_sched s,
     person pr
    PLAN (s
     WHERE s.sched_start_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(
      g_act_stop_dt_tm))
     JOIN (p
     WHERE p.cv_proc_id=s.cv_proc_id)
     JOIN (pr
     WHERE p.person_id=pr.person_id)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performagefilter(age,cal_age,p.cv_proc_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "n1:"
    FROM cv_proc p,
     person pr
    PLAN (p)
     JOIN (pr
     WHERE p.person_id=pr.person_id
      AND p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm)
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM cv_step_sched s
      WHERE s.cv_proc_id=p.cv_proc_id))))
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performagefilter(age,cal_age,p.cv_proc_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (performgroupfilter(proc_id=f8,prsnl_id=f8,physician_group_id=f8,stress_ecg_status_cd=f8
  ) =null WITH protect)
   DECLARE group_indx = i4 WITH private
   DECLARE physician_group_cnt = i4 WITH private
   SET physician_group_cnt = size(request->physician_group,5)
   IF (physician_group_cnt=1
    AND (request->my_group_id=groupid))
    IF ((request->physician_group[0].physician_group_id=physician_group_id))
     SET reply->qual[replycnt].cv_proc_id = proc_id
     SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
    ENDIF
   ELSEIF ((request->my_group_id=mineandmygroups))
    IF (physician_group_cnt=0)
     IF ((request->prsnl_id=prsnl_id)
      AND physician_group_id <= 0.0)
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ENDIF
    ELSEIF (physician_group_cnt >= 1)
     IF (physician_group_id <= 0.0
      AND (request->prsnl_id=prsnl_id))
      SET reply->qual[replycnt].cv_proc_id = proc_id
      SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
     ELSEIF (physician_group_id > 0.0)
      FOR (group_indx = 1 TO physician_group_cnt)
        IF ((request->physician_group[group_indx].physician_group_id=physician_group_id))
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF ((request->my_group_id=mine)
    AND (request->prsnl_id=prsnl_id))
    SET reply->qual[replycnt].cv_proc_id = proc_id
    SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
   ENDIF
 END ;Subroutine
 SUBROUTINE (performgroupandagefilter(filter_age=i4,convert_age=vc,proc_id=f8,prsnl_id=f8,
  physician_group_id=f8,stress_ecg_status_cd=f8) =null WITH protect)
   SET age_value = piece(convert_age,":",1,"")
   SET age_cal = cnvtint(age_value)
   DECLARE group_indx = i4 WITH private
   DECLARE physician_group_cnt = i4 WITH private
   DECLARE filter_age_in_hrs = i4 WITH protect, noconstant(0)
   SET physician_group_cnt = size(request->physician_group,5)
   SET filter_age_in_hrs = calcfilterageinhours(filter_age)
   IF (physician_group_cnt=1
    AND (request->my_group_id=3))
    IF ((request->physician_group[0].physician_group_id=physician_group_id))
     IF (age_show=1)
      IF (age_group=1)
       IF (age_cal >= filter_age_in_hrs)
        SET reply->qual[replycnt].cv_proc_id = proc_id
        SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
       ENDIF
      ELSEIF (age_group=0)
       IF (age_cal < filter_age_in_hrs)
        SET replycnt += 1
        SET stat = alterlist(reply->qual,replycnt)
        SET reply->qual[replycnt].cv_proc_id = proc_id
        SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
       ENDIF
      ENDIF
     ELSEIF (age_show=0)
      IF (age_group=1)
       IF (age_cal < filter_age_in_hrs)
        SET reply->qual[replycnt].cv_proc_id = proc_id
        SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
       ENDIF
      ELSEIF (age_group=0)
       IF (age_cal >= filter_age_in_hrs)
        SET reply->qual[replycnt].cv_proc_id = proc_id
        SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF ((request->my_group_id=2))
    IF (physician_group_cnt=0)
     IF ((request->prsnl_id=prsnl_id)
      AND physician_group_id <= 0.0)
      IF (age_show=1)
       IF (age_group=1)
        IF (age_cal >= filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ELSEIF (age_group=0)
        IF (age_cal < filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ENDIF
      ELSEIF (age_show=0)
       IF (age_group=1)
        IF (age_cal < filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ELSEIF (age_group=0)
        IF (age_cal >= filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (physician_group_cnt >= 1)
     IF (physician_group_id <= 0.0
      AND (request->prsnl_id=prsnl_id))
      IF (age_show=1)
       IF (age_group=1)
        IF (age_cal >= filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ELSEIF (age_group=0)
        IF (age_cal < filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ENDIF
      ELSEIF (age_show=0)
       IF (age_group=1)
        IF (age_cal < filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ELSEIF (age_group=0)
        IF (age_cal >= filter_age_in_hrs)
         SET reply->qual[replycnt].cv_proc_id = proc_id
         SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (physician_group_id > 0.0)
      FOR (group_indx = 1 TO physician_group_cnt)
        IF ((request->physician_group[group_indx].physician_group_id=physician_group_id))
         IF (age_show=1)
          IF (age_group=1)
           IF (age_cal >= filter_age_in_hrs)
            SET reply->qual[replycnt].cv_proc_id = proc_id
            SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
           ENDIF
          ELSEIF (age_group=0)
           IF (age_cal < filter_age_in_hrs)
            SET reply->qual[replycnt].cv_proc_id = proc_id
            SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
           ENDIF
          ENDIF
         ELSEIF (age_show=0)
          IF (age_group=1)
           IF (age_cal < filter_age_in_hrs)
            SET reply->qual[replycnt].cv_proc_id = proc_id
            SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
           ENDIF
          ELSEIF (age_group=0)
           IF (age_cal >= filter_age_in_hrs)
            SET reply->qual[replycnt].cv_proc_id = proc_id
            SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF ((request->my_group_id=1)
    AND (request->prsnl_id=prsnl_id))
    IF (age_show=1)
     IF (age_group=1)
      IF (age_cal >= filter_age_in_hrs)
       SET reply->qual[replycnt].cv_proc_id = proc_id
       SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
      ENDIF
     ELSEIF (age_group=0)
      IF (age_cal < filter_age_in_hrs)
       SET reply->qual[replycnt].cv_proc_id = proc_id
       SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
      ENDIF
     ENDIF
    ELSEIF (age_show=0)
     IF (age_group=1)
      IF (age_cal < filter_age_in_hrs)
       SET reply->qual[replycnt].cv_proc_id = proc_id
       SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
      ENDIF
     ELSEIF (age_group=0)
      IF (age_cal >= filter_age_in_hrs)
       SET reply->qual[replycnt].cv_proc_id = proc_id
       SET reply->qual[replycnt].stress_ecg_status_cd = stress_ecg_status_cd
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprocedureswithgroupfilter(dummy)
   SELECT INTO "nl:"
    FROM cv_proc p
    PLAN (p
     WHERE p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm))
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     CALL performgroupfilter(p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SELECT INTO "n1:"
    FROM cv_proc p,
     cv_step_sched s
    PLAN (s
     WHERE s.sched_start_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(
      g_act_stop_dt_tm))
     JOIN (p
     WHERE p.cv_proc_id=s.cv_proc_id)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     CALL performgroupfilter(p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cv_proc p
    WHERE  NOT ( EXISTS (
    (SELECT
     1
     FROM cv_step_sched s
     WHERE s.cv_proc_id=p.cv_proc_id)))
     AND p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     CALL performgroupfilter(p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p.stress_ecg_status_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getprocedureswithgroupandagefilter(dummy)
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "nl:"
    FROM cv_proc p,
     person pr
    PLAN (p
     WHERE p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm))
     JOIN (pr
     WHERE p.person_id=pr.person_id)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performgroupandagefilter(age,cal_age,p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p
     .stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "n1:"
    FROM cv_proc p,
     cv_step_sched s,
     person pr
    PLAN (s
     WHERE s.sched_start_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(
      g_act_stop_dt_tm))
     JOIN (p
     WHERE p.cv_proc_id=s.cv_proc_id)
     JOIN (pr
     WHERE p.person_id=pr.person_id)
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performgroupandagefilter(age,cal_age,p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p
     .stress_ecg_status_cd)
    WITH nocounter
   ;end select
   SET modify = cnvtage(1318000,0,0,0)
   SELECT INTO "n1:"
    FROM cv_proc p,
     person pr
    PLAN (p)
     JOIN (pr
     WHERE p.person_id=pr.person_id
      AND p.action_dt_tm BETWEEN cnvtdatetime(g_act_start_dt_tm) AND cnvtdatetime(g_act_stop_dt_tm)
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM cv_step_sched s
      WHERE s.cv_proc_id=p.cv_proc_id))))
    HEAD REPORT
     stat = alterlist(reply->qual,(replycnt+ 100))
    DETAIL
     replycnt += 1
     IF (replycnt > 100
      AND mod(replycnt,100)=1)
      stat = alterlist(reply->qual,(99+ replycnt))
     ENDIF
     cal_age = trim(cnvtage(pr.birth_dt_tm),3),
     CALL performgroupandagefilter(age,cal_age,p.cv_proc_id,p.prim_physician_id,p.phys_group_id,p
     .stress_ecg_status_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (calcfilterageinhours(filter_age_in_years=i4) =i4 WITH protect)
   DECLARE look_behind_string = vc WITH protect, noconstant("")
   DECLARE look_up_date = dq8 WITH protect
   DECLARE age_in_hours_string = vc WITH protect, noconstant("")
   DECLARE filter_age_in_hours = i4 WITH protect, noconstant(0)
   SET look_behind_string = build(filter_age_in_years,",Y")
   SET look_up_date = cnvtlookbehind(look_behind_string,cnvtdatetime(sysdate))
   SET modify = cnvtage(1318000,0,0,0)
   SET age_in_hours_string = trim(cnvtage(look_up_date),3)
   SET filter_age_in_hours = cnvtint(piece(age_in_hours_string,":",1,""))
   RETURN(filter_age_in_hours)
 END ;Subroutine
 CALL echorecord(reply)
 IF (size(reply->qual,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="Z"))
  CALL cv_log_stat(cv_warning,"SIZE","Z",
   "REPLY FROM cv_filter_procs_by_groups_age - AGEANDGROUPFILTERING","")
 ELSEIF ((reply->status_data.status="F"))
  CALL cv_log_stat(cv_error,"VALIDATE","F",
   "REPLY FROM cv_filter_procs_by_groups_age - AGEANDGROUPFILTERING","")
 ENDIF
 CALL cv_log_msg_post("003 31/01/20 JT023123")
END GO
