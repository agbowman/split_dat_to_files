CREATE PROGRAM cod_calculator:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order_ID:" = 0
  WITH outdev, thaorderid
 SET debug = 1
 SET trace = rdbbind
 SET trace = rdbdebug
 SET message = information
 SET trace = callecho
 DECLARE program_version = vc WITH private, constant("001")
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("COD_CALCULATOR")
 DECLARE failed_ind = i2 WITH protect, noconstant(0)
 DECLARE orderid = f8
 DECLARE encntrid = f8
 DECLARE personid = f8
 DECLARE wrong_domain_ind = i2 WITH protect, noconstant(0)
 SET orderid =  $THAORDERID
 DECLARE cs_order_ind = i2 WITH protect, noconstant(0)
 DECLARE template_order_flag = i2
 DECLARE child_order_ind = i2 WITH protect, noconstant(0)
 DECLARE prn_ind = i2
 DECLARE constant_ind = i2
 DECLARE unsched_ind = i2 WITH protect, noconstant(0)
 DECLARE auto_cancel_ind = i2 WITH protect, noconstant(0)
 DECLARE current_start_dttm = dq8
 DECLARE cancel_ind = i2 WITH protect, noconstant(0)
 DECLARE orc_cancel_ind = i2 WITH protect, noconstant(0)
 DECLARE clean_dttm = dq8
 DECLARE start_check_time = dq8
 DECLARE check_start_ind = i2 WITH protect, noconstant(0)
 DECLARE order_name = c100
 DECLARE orig_ord_as_flag = i4 WITH protect, noconstant(0)
 DECLARE order_cancel_dttm = dq8
 DECLARE no_order_status_ind = i2 WITH protect, noconstant(0)
 DECLARE no_order_action_rows = i2 WITH protect, noconstant(0)
 DECLARE parent_dc_type_cd = vc
 DECLARE template_order_id = f8
 DECLARE orig_order_dt_tm = dq8
 DECLARE cur_order_status_cd = f8
 SELECT INTO "nl:"
  o.order_id, e.encntr_id, oc.catalog_cd,
  ord.discontinue_type_cd, o.template_order_id
  FROM encounter e,
   orders o,
   order_catalog oc,
   orders ord
  PLAN (o
   WHERE o.order_id=orderid)
   JOIN (e
   WHERE o.encntr_id=e.encntr_id)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (ord
   WHERE ord.order_id=outerjoin(o.template_order_id))
  DETAIL
   orderid = o.order_id, personid = o.person_id, encntrid = o.encntr_id
   IF (o.cs_flag IN (1, 3, 4, 6))
    cs_order_ind = 1
   ENDIF
   current_start_dttm = o.current_start_dt_tm, template_order_flag = o.template_order_flag,
   auto_cancel_ind = oc.auto_cancel_ind,
   order_name = o.hna_order_mnemonic, prn_ind = o.prn_ind, constant_ind = o.constant_ind,
   orig_ord_as_flag = o.orig_ord_as_flag, orig_order_dt_tm = o.orig_order_dt_tm, cur_order_status_cd
    = o.order_status_cd
   IF (o.freq_type_flag=5)
    unsched_ind = 1
   ENDIF
   IF (o.template_order_id > 0)
    child_order_ind = 1, template_order_id = o.template_order_id
   ENDIF
   IF (ord.discontinue_type_cd > 0)
    parent_dc_type_cd = uar_get_code_meaning(ord.discontinue_type_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed_ind = 1
  SET wrong_domain_ind = 1
  GO TO exit_script
 ENDIF
 CALL echo(build2("***   orderID: ",orderid))
 CALL echo(build2("***   parent_dc_type_cd: ",parent_dc_type_cd))
 DECLARE inpatient = i2 WITH protect, noconstant(0)
 DECLARE disch_dttm = dq8
 DECLARE disch_action_dttm = dq8
 DECLARE nodc_ind = i2 WITH protect, noconstant(0)
 DECLARE cantcomparedc_ind = i2 WITH protect, noconstant(0)
 DECLARE encntr_hist_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  e.disch_dt_tm, e.encntr_type_class_cd, elh.activity_dt_tm
  FROM encounter e,
   orders o,
   encntr_loc_hist elh
  WHERE o.order_id=orderid
   AND o.encntr_id=e.encntr_id
   AND e.encntr_id=elh.encntr_id
   AND elh.depart_dt_tm=e.disch_dt_tm
  ORDER BY elh.activity_dt_tm
  DETAIL
   disch_dttm = cnvtdatetime(e.disch_dt_tm), inpatient = evaluate(uar_get_code_meaning(e
     .encntr_type_class_cd),"INPATIENT",1,0), disch_action_dttm = cnvtdatetime(elh.activity_dt_tm)
  WITH maxrec = 1, nocounter
 ;end select
 CALL echo(build2("***   disch_dttm: ",disch_dttm))
 CALL echo(build2("***   inpatient: ",inpatient))
 CALL echo(build2("***   disch_action_dttm: ",disch_dttm))
 CALL echo(build2("***   encntr_hist_ind: ",encntr_hist_ind))
 IF (((disch_dttm > cnvtdatetime(curdate,curtime3)) OR (disch_dttm=null)) )
  SET failed_ind = 1
  SET nodc_ind = 1
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET failed_ind = 1
  SET cantcomparedc_ind = 1
  GO TO exit_script
 ENDIF
 DECLARE backdt_ind = i2 WITH protect, noconstant(0)
 IF (disch_action_dttm > disch_dttm)
  IF (datetimediff(disch_action_dttm,disch_dttm,1) > 1)
   SET backdt_ind = 1
  ENDIF
 ENDIF
 CALL echo(build2("***   backdt_ind: ",backdt_ind))
 DECLARE dsch_flag = vc
 DECLARE dsch_hrs = f8
 DECLARE clean_hrs = f8
 DECLARE dcpcnclunsch_ind = i2 WITH protect, noconstant(0)
 DECLARE dcpcnclprn_ind = i2 WITH protect, noconstant(0)
 DECLARE check_clean_ind = i2 WITH protect, noconstant(0)
 DECLARE start_plus_hrs = f8
 DECLARE greater_than_thingy = vc
 IF (inpatient=1)
  SELECT INTO "nl:"
   cp.config_name, cp.config_value
   FROM config_prefs cp
   WHERE cp.config_name IN ("INDSCH_FLAG", "INDSCH_HRS", "INCLEAN_HRS", "DCPCNCLUNSCH", "DCPCNCLPRN")
   DETAIL
    IF (cp.config_name="DCPCNCLUNSCH"
     AND cp.config_value="1")
     dcpcnclunsch_ind = 1
    ELSEIF (cp.config_name="DCPCNCLPRN"
     AND cp.config_value="1")
     dcpcnclprn_ind = 1
    ELSEIF (cp.config_name="INDSCH_HRS")
     dsch_hrs = cnvtreal(trim(cp.config_value))
    ELSEIF (cp.config_name="INCLEAN_HRS")
     clean_hrs = cnvtreal(trim(cp.config_value))
    ELSEIF (cp.config_name="INDSCH_FLAG")
     dsch_flag = cp.config_value
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT
   cp.config_name, cp.config_value
   FROM config_prefs cp
   WHERE cp.config_name IN ("OUTDSCH_FLAG", "OUTDSCH_HRS", "OUTCLEAN_HRS", "DCPCNCLUNSCH",
   "DCPCNCLPRN")
   DETAIL
    IF (cp.config_name="DCPCNCLUNSCH"
     AND cp.config_value="1")
     dcpcnclunsch_ind = 1
    ELSEIF (cp.config_name="DCPCNCLPRN"
     AND cp.config_value="1")
     dcpcnclprn_ind = 1
    ELSEIF (cp.config_name="OUTDSCH_HRS")
     dsch_hrs = cnvtreal(trim(cp.config_value))
    ELSEIF (cp.config_name="OUTCLEAN_HRS")
     clean_hrs = cnvtreal(trim(cp.config_value))
    ELSEIF (cp.config_name="OUTDSCH_FLAG")
     dsch_flag = cp.config_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (dsch_flag IN ("ALL>*", "ORD>*"))
  SET greater_than_thingy = substring(5,1,trim(dsch_flag))
 ENDIF
 IF (greater_than_thingy > " ")
  SET start_plus_hrs = dsch_hrs
  IF (start_plus_hrs >= 0)
   SET check_start_ind = 1
  ENDIF
 ENDIF
 CALL echo(build2("***   dsch_hrs: ",dsch_hrs))
 CALL echo(build2("***   clean_hrs: ",clean_hrs))
 CALL echo(build2("***   dsch_flag: ",dsch_flag))
 CALL echo(build2("***   greater_than_thingy: ",greater_than_thingy))
 DECLARE clean_days = i4 WITH protect, noconstant(0)
 DECLARE dsch_days = i4 WITH protect, noconstant(0)
 IF (dsch_hrs > 0)
  SET dsch_days = (dsch_hrs/ 24)
 ENDIF
 IF (clean_hrs > 0)
  SET clean_days = (clean_hrs/ 24)
  SET check_clean_ind = 1
 ENDIF
 DECLARE start_qualify = dq8
 DECLARE stop_qualify = dq8
 SET start_qualify = cnvtdatetime(datetimeadd(disch_dttm,dsch_days))
 SET stop_qualify = cnvtdatetime(datetimeadd(disch_dttm,(2+ evaluate(clean_days,0,dsch_days,
    clean_days))))
 DECLARE order_status = f8 WITH protect, noconstant(0.00)
 DECLARE dept_status = f8 WITH protect, noconstant(0.00)
 DECLARE oa_qual = i4 WITH protect
 DECLARE oa2_qual = i4 WITH protect
 DECLARE oa3_qual = i4 WITH protect
 SELECT INTO "nl:"
  oa.order_status_cd, oa.dept_status_cd, oa.action_dt_tm
  FROM order_action oa
  WHERE oa.order_id=orderid
   AND oa.action_dt_tm < cnvtdatetime(disch_action_dttm)
  ORDER BY oa.action_sequence
  FOOT REPORT
   order_status = oa.order_status_cd, dept_status = oa.dept_status_cd, oa_qual = curqual
  WITH maxrec = 1, nocounter
 ;end select
 IF (oa_qual > 0
  AND order_status < 1)
  SET failed_ind = 1
  SET no_order_status_ind = 1
  GO TO exit_script
 ENDIF
 IF (oa_qual=0)
  SELECT INTO "nl:"
   oa.order_status_cd, oa.dept_status_cd, oa.action_dt_tm
   FROM order_action oa
   WHERE oa.order_id=orderid
    AND oa.action_dt_tm < cnvtdatetime(stop_qualify)
   ORDER BY oa.action_sequence
   FOOT REPORT
    order_status = oa.order_status_cd, dept_status = oa.dept_status_cd, oa2_qual = curqual
   WITH maxrec = 1, nocounter
  ;end select
  IF (oa2_qual > 0
   AND order_status < 1)
   SET failed_ind = 1
   SET no_order_status_ind = 1
   GO TO exit_script
  ENDIF
  IF (oa2_qual=0)
   SELECT INTO "nl:"
    oa.order_status_cd, oa.dept_status_cd, oa.action_dt_tm
    FROM order_action oa
    WHERE oa.order_id=orderid
     AND oa.order_status_cd IN (
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=6004
      AND cdf_meaning IN ("ORDERED", "INPROCESS", "INCOMPLETE", "MEDSTUDENT", "SUSPENDED")))
    ORDER BY oa.action_sequence
    FOOT REPORT
     order_status = oa.order_status_cd, dept_status = oa.dept_status_cd, oa3_qual = curqual
    WITH maxrec = 1, nocounter
   ;end select
   IF (oa3_qual > 0
    AND order_status < 1)
    SET failed_ind = 1
    SET no_order_status_ind = 1
    GO TO exit_script
   ENDIF
   IF (oa3_qual=0
    AND order_status < 1)
    SET failed_ind = 1
    SET no_order_action_rows = 1
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 DECLARE dept_allow_cancel_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  WHERE cve.code_value=dept_status
   AND cve.code_set=14281.00
   AND cve.field_name="DCP_ALLOW_CANCEL_IND"
  DETAIL
   dept_allow_cancel_ind = cnvtint(trim(cve.field_value))
  WITH nocounter
 ;end select
 DECLARE cancelondischargebitmaskstatus = i4 WITH protect, noconstant(0)
 DECLARE ebackdatedout = i4 WITH protect, constant((2** 0))
 DECLARE eorderstatus = i4 WITH protect, constant((2** 1))
 DECLARE eordertype = i4 WITH protect, constant((2** 2))
 DECLARE ecareset = i4 WITH protect, constant((2** 3))
 DECLARE edeptallowcancel = i4 WITH protect, constant((2** 4))
 DECLARE echeckstart = i4 WITH protect, constant((2** 5))
 DECLARE echeckclean = i4 WITH protect, constant((2** 6))
 DECLARE etemplaterelatedorder = i4 WITH protect, constant((2** 7))
 DECLARE estartafterstartcheck = i4 WITH protect, constant((2** 8))
 DECLARE econtinuingorunscheduled = i4 WITH protect, constant((2** 9))
 DECLARE edcpcnclprn = i4 WITH protect, constant((2** 10))
 DECLARE eprn = i4 WITH protect, constant((2** 11))
 DECLARE edcpcnclunsch = i4 WITH protect, constant((2** 12))
 DECLARE eunsch = i4 WITH protect, constant((2** 13))
 DECLARE eonetimeautocancelind = i4 WITH protect, constant((2** 14))
 IF (substring(1,3,trim(dsch_flag))="ALL")
  SET cancel_ind = 0
  IF (orig_ord_as_flag IN (0, 5))
   SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eordertype)
   IF (cs_order_ind=1)
    SET cancel_ind = 0
    SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,ecareset)
   ELSE
    SET cancel_ind = 0
    IF (dept_allow_cancel_ind=1)
     SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edeptallowcancel)
     IF (check_start_ind=1)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,echeckstart)
      SET start_check_time = cnvtdatetime(datetimeadd(disch_dttm,dsch_days))
      IF (current_start_dttm > start_check_time
       AND template_order_flag IN (0, 1, 2, 6))
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,etemplaterelatedorder)
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,estartafterstartcheck)
       SET cancel_ind = 1
      ELSE
       IF (check_clean_ind=1)
        SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,echeckclean)
        SET clean_dttm = cnvtdatetime(datetimeadd(disch_dttm,(clean_hrs/ 24.0)))
        SET cancel_ind = 1
       ENDIF
      ENDIF
     ELSE
      SET cancel_ind = 1
     ENDIF
    ENDIF
    IF (((template_order_flag=1) OR (((prn_ind=1) OR (((constant_ind=1) OR (unsched_ind=1)) )) )) )
     SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,econtinuingorunscheduled
      )
     IF (prn_ind=1
      AND dcpcnclprn_ind=1)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edcpcnclprn)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eprn)
      IF (dept_allow_cancel_ind=1)
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edeptallowcancel)
       SET cancel_ind = 1
      ENDIF
     ELSEIF (unsched_ind=1
      AND dcpcnclunsch_ind=1)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edcpcnclunsch)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eunsch)
      IF (dept_allow_cancel_ind=1)
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edeptallowcancel)
       SET cancel_ind = 1
      ENDIF
     ELSE
      SET cancel_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (cancel_ind=1)
    IF (((template_order_flag=1) OR (((prn_ind=1) OR (((constant_ind=1) OR (unsched_ind=1)) )) )) )
     IF (backdt_ind=1)
      SET order_cancel_dttm = disch_action_dttm
     ELSE
      SET order_cancel_dttm = disch_dttm
     ENDIF
    ELSE
     IF (check_start_ind=1)
      IF (check_clean_ind=1)
       SET order_cancel_dttm = clean_dttm
      ELSE
       SET order_cancel_dttm = start_check_time
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (((substring(1,3,trim(dsch_flag))="ORD") OR (dsch_flag=null)) )
  SET cancel_ind = 0
  IF (orig_ord_as_flag IN (0, 5))
   SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eordertype)
   IF (cs_order_ind=1)
    SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,ecareset)
    SET cancel_ind = 0
   ELSE
    SET cancel_ind = 0
    IF (dept_allow_cancel_ind=1)
     SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,edeptallowcancel)
     IF (check_start_ind=1)
      SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,echeckstart)
      SET start_check_time = cnvtdatetime(datetimeadd(disch_dttm,(start_plus_hrs/ 24.0)))
      IF (current_start_dttm > start_check_time
       AND template_order_flag IN (0, 1, 2, 6))
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,etemplaterelatedorder)
       SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,estartafterstartcheck)
       SET cancel_ind = 1
      ELSE
       IF (check_clean_ind=1)
        SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,echeckclean)
        SET clean_dttm = cnvtdatetime(datetimeadd(disch_dttm,(clean_hrs/ 24.0)))
        SET cancel_ind = 1
       ENDIF
      ENDIF
     ELSE
      SET cancel_ind = 1
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build2("***   start_plus_hrs: ",start_plus_hrs))
   CALL echo(build2("***   start_check_time: ",start_check_time))
   CALL echo(build2("***   clean_dttm: ",clean_dttm))
   SET orc_cancel_ind = 0
   IF (((template_order_flag=1) OR (((prn_ind=1) OR (((constant_ind=1) OR (((auto_cancel_ind=1) OR (
   unsched_ind=1)) )) )) )) )
    SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,econtinuingorunscheduled)
    IF (template_order_flag=0
     AND prn_ind=0
     AND constant_ind=0
     AND unsched_ind=0
     AND auto_cancel_ind=1)
     SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eonetimeautocancelind)
    ENDIF
    SET orc_cancel_ind = 1
    IF (((template_order_flag=1) OR (((prn_ind=1) OR (((constant_ind=1) OR (unsched_ind=1)) )) )) )
     IF (((prn_ind=1
      AND dcpcnclprn_ind=1) OR (unsched_ind=1
      AND dcpcnclunsch_ind=1)) )
      IF (dept_allow_cancel_ind=1)
       SET cancel_ind = 1
      ENDIF
     ELSE
      SET cancel_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (cancel_ind=1
    AND orc_cancel_ind=1)
    IF (((template_order_flag=1) OR (((prn_ind=1) OR (((constant_ind=1) OR (unsched_ind=1)) )) )) )
     IF (backdt_ind=1)
      SET order_cancel_dttm = disch_action_dttm
     ELSE
      SET order_cancel_dttm = disch_dttm
     ENDIF
    ELSE
     IF (check_start_ind=1)
      IF (check_clean_ind=1)
       SET order_cancel_dttm = clean_dttm
      ELSE
       SET order_cancel_dttm = start_check_time
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 CALL echo(build2("***   order_cancel_dttm: ",order_cancel_dttm))
 CALL echo(build2("***   clean_dttm: ",clean_dttm))
 CALL echo(build2("***   start_check_time: ",start_check_time))
 CALL echo(build2("***   disch_dttm: ",disch_dttm))
 CALL echo(build2("***   disch_action_dttm: ",disch_action_dttm))
 RECORD opsjob(
   1 jobs[*]
     2 status_cd = vc
     2 schedule_dt_tm = vc
     2 beg_effective_dt_tm = vc
     2 end_effective_dt_tm = vc
 )
 DECLARE batch = vc
 DECLARE job_didnt_run_ind = i2 WITH protect, noconstant(0)
 DECLARE job_data_purged_ind = i2 WITH protect, noconstant(0)
 DECLARE total_job_cnt = i4 WITH protect, noconstant(0)
 IF (inpatient=1)
  SET batch = "DCP_OPS_INP_DC_DORDS"
 ELSE
  SET batch = "DCP_OPS_OUTP_DC_DORDS"
 ENDIF
 SELECT INTO "nl:"
  ost.status_cd, ost.schedule_dt_tm, ost.beg_effective_dt_tm,
  ost.end_effective_dt_tm
  FROM ops_schedule_task ost,
   ops_schedule_param osp
  PLAN (osp
   WHERE osp.batch_selection=batch)
   JOIN (ost
   WHERE ost.ops_task_id=osp.ops_task_id
    AND ost.beg_effective_dt_tm > cnvtdatetime(start_qualify)
    AND ost.beg_effective_dt_tm < cnvtdatetime(stop_qualify))
  ORDER BY ost.schedule_dt_tm, ost.beg_effective_dt_tm, ost.end_effective_dt_tm
  HEAD REPORT
   job_cnt = 0
  DETAIL
   job_cnt = (job_cnt+ 1)
   IF (mod(job_cnt,10)=1)
    stat = alterlist(opsjob->jobs,(job_cnt+ 9))
   ENDIF
   opsjob->jobs[job_cnt].status_cd = uar_get_code_display(ost.status_cd), opsjob->jobs[job_cnt].
   schedule_dt_tm = format(ost.schedule_dt_tm,";;q"), opsjob->jobs[job_cnt].beg_effective_dt_tm =
   format(ost.beg_effective_dt_tm,";;q"),
   opsjob->jobs[job_cnt].end_effective_dt_tm = format(ost.end_effective_dt_tm,";;q")
  FOOT REPORT
   stat = alterlist(opsjob->jobs,job_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(opsjob)
 IF (size(opsjob->jobs,5)=0)
  SELECT INTO "nl:"
   all_job_cnt = count(ost2.ops_schedule_task_id)
   FROM ops_schedule_task ost2
   PLAN (ost2
    WHERE ost2.ops_task_id > 0.00
     AND ost2.beg_effective_dt_tm > cnvtdatetime(start_qualify)
     AND ost2.beg_effective_dt_tm < cnvtdatetime(stop_qualify))
   DETAIL
    total_job_cnt = all_job_cnt
    IF (total_job_cnt=0)
     job_data_purged_ind = 1
    ELSE
     job_didnt_run_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build2("***   job_data_purged_ind: ",job_data_purged_ind))
 CALL echo(build2("***   job_didnt_run_ind: ",job_didnt_run_ind))
 DECLARE backdtd_out_of_range = i2 WITH protect, noconstant(0)
 DECLARE ordered_after_stop = i2 WITH protect, noconstant(0)
 IF (disch_action_dttm > stop_qualify)
  SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,ebackdatedout)
  SET backdtd_out_of_range = 1
 ENDIF
 IF (orig_order_dt_tm > stop_qualify)
  SET ordered_after_stop = 1
  SET cancelondischargebitmaskstatus = bor(cancelondischargebitmaskstatus,eorderedafterstopqualify)
 ENDIF
 DECLARE inpt_display = vc
 DECLARE ord_type_disp = vc
 DECLARE backdt_y_n_disp = vc
 DECLARE mrn = c200
 DECLARE fin = c200
 DECLARE pt_name = c100
 DECLARE order_status_disp = vc
 DECLARE prn_disp = vc
 DECLARE constant_disp = vc
 DECLARE template_disp = vc
 DECLARE backdt_out_y_n = vc
 DECLARE unsched_disp = vc
 DECLARE cancel_disp = vc
 DECLARE cancel_disp2 = vc
 DECLARE auto_cancel_disp = vc
 DECLARE disch_dttm_disp = vc
 DECLARE disch_action_dttm_disp = vc
 DECLARE current_start_dttm_disp = vc
 DECLARE order_cancel_dttm_disp = vc
 DECLARE start_qualify_disp = vc
 DECLARE stop_qualify_disp = vc
 DECLARE which_dsch_flag = vc
 DECLARE which_dsch_hrs = vc
 DECLARE which_clean_hrs = vc
 DECLARE dcpcnclunsch_disp = vc
 DECLARE dcpcnclunsch_value_disp = vc
 DECLARE dcpcnclprn_disp = vc
 DECLARE dcpcnclprn_value_disp = vc
 DECLARE check_auto_cancel_disp = vc
 DECLARE job_ran_disp = vc
 DECLARE job_data_purged_disp = vc
 DECLARE need_auto_cancel_ind_disp = vc
 DECLARE order_cancel_dttm_disp_sent = vc
 DECLARE backdt_days = vc
 DECLARE child_no_dc_ind = i2 WITH protect, noconstant(0)
 SET disch_dttm_disp = format(disch_dttm,";;q")
 SET disch_action_dttm_disp = format(disch_action_dttm,";;q")
 SET current_start_dttm_disp = format(current_start_dttm,";;q")
 SET order_cancel_dttm_disp = format(order_cancel_dttm,";;q")
 SET backdt_days = trim(cnvtstring(datetimecmp(stop_qualify,start_qualify)))
 CALL echo(build2("***   order_cancel_dttm_disp: ",order_cancel_dttm_disp))
 CALL echo(build2("***   backdt_days: ",backdt_days))
 SET start_qualify_disp = format(start_qualify,";;q")
 SET stop_qualify_disp = format(stop_qualify,";;q")
 CALL echo(build2("***   start_qualify: ",start_qualify_disp))
 CALL echo(build2("***   stop_qualify: ",stop_qualify_disp))
 SET order_cancel_dttm_disp_sent = build2("With the first execution of the ops job after ",
  order_cancel_dttm_disp,".")
 IF (job_didnt_run_ind=1)
  SET job_ran_disp = "No. Go to the next page to see if the job failed."
 ELSE
  SET job_ran_disp =
  "Yes. Go to the next page to view the times that the ops job ran during the encounter qualification timeframe."
 ENDIF
 IF (job_data_purged_ind=1)
  SET job_data_purged_disp = build2("This cannot be deduced. Ops job execution data written before ",
   format(stop_qualify,"DD-MMM-YYYY;;D")," has been purged.***")
 ENDIF
 IF (inpatient=1)
  SET which_dsch_flag = "INDSCH_FLAG:"
  SET which_dsch_hrs = "INDSCH_HRS:"
  SET which_clean_hrs = "INCLEAN_HRS:"
 ELSE
  SET which_dsch_flag = "OUTDSCH_FLAG:"
  SET which_dsch_hrs = "OUTDSCH_HRS:"
  SET which_clean_hrs = "OUTCLEAN_HRS:"
 ENDIF
 SET dcpcnclunsch_disp = "DCPCNCLUNSCH:"
 IF (dcpcnclunsch_ind=1)
  SET dcpcnclunsch_value_disp = cnvtreal(dcpcnclunsch_ind)
 ENDIF
 SET dcpcnclprn_disp = "DCPCNCLPRN:"
 IF (dcpcnclprn_ind=1)
  SET dcpcnclprn_value_disp = cnvtreal(dcpcnclprn_ind)
 ENDIF
 SELECT INTO "nl:"
  pa.alias, per.name_full_formatted
  FROM person_alias pa,
   person per
  WHERE pa.person_id=personid
   AND pa.person_alias_type_cd=value(uar_get_code_by("MEANING",4,"MRN"))
   AND pa.active_ind=1
   AND per.person_id=pa.person_id
   AND per.active_ind=1
  DETAIL
   mrn = pa.alias, pt_name = per.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ea.alias
  FROM encntr_alias ea
  WHERE ea.encntr_id=encntrid
   AND ea.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR"))
   AND ea.active_ind=1
  DETAIL
   fin = ea.alias
  WITH nocounter
 ;end select
 IF (backdt_ind=1)
  SET backdt_y_n_disp = "Yes"
 ELSE
  SET backdt_y_n_disp = "No"
 ENDIF
 SET inpt_display = evaluate(inpatient,1,"Inpatient",0,"Outpatient")
 SET order_status_disp = uar_get_code_display(order_status)
 SET prn_disp = evaluate(prn_ind,1,"Yes",0,"No")
 SET constant_disp = evaluate(constant_ind,1,"Yes",0,"No")
 SET unsched_disp = evaluate(unsched_ind,1,"Yes",0,"No")
 SET backdt_out_y_n = evaluate(backdtd_out_of_range,1,"Yes",0,"No")
 SET auto_cancel_disp = evaluate(auto_cancel_ind,1,"Yes",0,"No")
 IF (template_order_flag=0)
  IF (child_order_ind=1)
   SET template_disp = "Child order"
  ELSE
   SET template_disp = "One-time order (without a frequency)"
  ENDIF
 ELSEIF (template_order_flag=1)
  SET template_disp = "Normal order with frequency"
 ELSEIF (template_order_flag=2)
  IF (child_order_ind=1)
   SET template_disp = "Child order: Order Based Instance"
  ELSE
   SET template_disp = "Order Based Instance"
  ENDIF
 ELSEIF (template_order_flag=3)
  IF (child_order_ind=1)
   SET template_disp = "Child Order: Task Based Instance"
  ELSE
   SET template_disp = "Task Based Instance"
  ENDIF
 ELSEIF (template_order_flag=4)
  IF (child_order_ind=1)
   SET template_disp = "Child order: Rx Based Instance"
  ELSE
   SET template_disp = "Rx Based Instance"
  ENDIF
 ELSEIF (template_order_flag=5)
  SET template_disp = "Future Recurring Order"
 ELSEIF (template_order_flag=6)
  IF (child_order_ind=1)
   SET template_disp = "Child order: Future Recurring Instance"
  ELSE
   SET template_disp = "Future Recurring Instance"
  ENDIF
 ELSEIF (template_order_flag=7)
  SET template_disp = "Protocol Order"
 ENDIF
 CASE (orig_ord_as_flag)
  OF 0:
   SET ord_type_disp = "Normal Order"
  OF 1:
   SET ord_type_disp = "Prescription"
  OF 2:
   SET ord_type_disp = "Documented Med"
  OF 3:
   SET ord_type_disp = "Patient Owns Meds"
  OF 4:
   SET ord_type_disp = "Pharmacy Charge Only"
  OF 5:
   SET ord_type_disp = "Superbill"
 ENDCASE
 IF (child_order_ind=1
  AND parent_dc_type_cd="SYSTEMDISCH"
  AND  NOT (cur_order_status_cd IN (
 SELECT
  cv5.code_value
  FROM code_value cv5
  WHERE cv5.code_set=6004
   AND  NOT (cv5.cdf_meaning IN ("CANCELED", "DISCONTINUED"))
 ;end select
 )))
  SET child_no_dc_ind = 1
 ENDIF
 CALL echo(build2("***   child_order_ind: ",child_order_ind))
 CALL echo(build2("***   child_no_dc_ind: ",child_no_dc_ind))
 IF (job_didnt_run_ind=0)
  IF (((substring(1,3,trim(dsch_flag))="ORD") OR (dsch_flag=null)) )
   IF (cancel_ind=1
    AND orc_cancel_ind=1)
    IF (backdtd_out_of_range=1)
     SET cancel_disp = build2(
      "No. The encounter did not qualify the ops job's logic. It's discharge was performed after ",
      stop_qualify_disp)
     SET cancel_disp2 = build2("and the discharge date and time was back-dated more than ",
      backdt_days," days.")
    ELSEIF (ordered_after_stop=1)
     SET cancel_disp =
     "No. The order was placed after the encounter stopped qualifying for the ops job."
    ELSE
     SET cancel_disp = "Yes. The order should have cancelled due to discharge."
    ENDIF
   ELSEIF (cancel_ind=1
    AND orc_cancel_ind=0)
    IF (child_order_ind=1)
     SET cancel_disp = build2("No. This is a child order. Its parent order (Order_ID:",
      template_order_id,") qualified for cancellation due to discharge,")
     SET cancel_disp2 = build2(
      "but this order didn't because it doesn't have the Cancel on Discharge indicator checked in the Order Catalog Tool."
      )
    ELSE
     SET cancel_disp = "No. This order should not have qualified for cancellation due to discharge."
    ENDIF
   ELSEIF (cancel_ind=0
    AND orc_cancel_ind=1)
    SET cancel_disp = "No. This order should not have qualified for cancellation due to discharge."
   ELSEIF (cancel_ind=0
    AND orc_cancel_ind=0)
    SET cancel_disp = "No. This order should not have qualified for cancellation due to discharge."
   ENDIF
  ELSEIF (substring(1,3,trim(dsch_flag))="ALL")
   IF (cancel_ind=1)
    IF (backdtd_out_of_range=1)
     SET cancel_disp = build2(
      "No. The encounter did not qualify the ops job's logic. It's discharge was performed after ",
      stop_qualify_disp)
     SET cancel_disp2 = build2("and the discharge date and time was back-dated more than ",
      backdt_days," days.")
    ELSE
     SET cancel_disp = "Yes. The order should have cancelled due to discharge."
    ENDIF
   ELSEIF (orig_order_dt_tm > stop_qualify)
    SET cancel_disp =
    "No. The order was placed after the encounter stopped qualifying for the ops job."
   ELSE
    SET cancel_disp = "No. This order should not have qualified for cancellation due to discharge."
   ENDIF
  ENDIF
 ELSE
  SET cancel_disp =
  "No, because the ops job wasn't running during the encounter qualification period."
 ENDIF
 CALL echo(build2("***   cancel_disp: ",cancel_disp))
 CALL echo(build2("***   cancel_disp2: ",cancel_disp2))
 IF (inpatient=1)
  IF (((substring(1,3,trim(dsch_flag))="ORD") OR (dsch_flag=null)) )
   IF (((template_order_flag=1) OR (((prn_ind=1) OR (constant_ind=1)) )) )
    SET check_auto_cancel_disp =
    "No. The INDSCH_FLAG is set to 'ORD*', but the order is not a one-time order."
   ELSE
    SET check_auto_cancel_disp =
    "Yes. The INDSCH_FLAG is set to 'ORD*' and the order is a one-time order."
   ENDIF
  ELSEIF (substring(1,3,trim(dsch_flag))="ALL")
   SET check_auto_cancel_disp = "No. The INDSCH_FLAG is set to 'ALL*'."
  ENDIF
 ELSE
  IF (((substring(1,3,trim(dsch_flag))="ORD") OR (dsch_flag=null)) )
   IF (((template_order_flag=1) OR (((prn_ind=1) OR (constant_ind=1)) )) )
    SET check_auto_cancel_disp =
    "No. The OUTDSCH_FLAG is set to 'ORD*', but the order is not a one-time order."
   ELSE
    SET check_auto_cancel_disp =
    "Yes. The OUTDSCH_FLAG is set to 'ORD*' and the order is a one-time order."
   ENDIF
  ELSEIF (substring(1,3,trim(dsch_flag))="ALL")
   SET check_auto_cancel_disp = "No. The OUTDSCH_FLAG is set to 'ALL*'."
  ENDIF
 ENDIF
 IF (constant_ind != 1
  AND prn_ind != 1
  AND template_order_flag != 1
  AND unsched_ind != 1
  AND substring(1,3,trim(dsch_flag))="ORD")
  SET need_auto_cancel_ind_disp = "Yes"
 ELSE
  SET need_auto_cancel_ind_disp = "No"
 ENDIF
 CALL echo(build2("***   cancel_ind: ",cancel_ind))
 CALL echo(build2("***   orc_cancel_ind: ",orc_cancel_ind))
 CALL updtdminfo(script_name,1.0)
 EXECUTE cod_calculator_lyt  $OUTDEV
#exit_script
 IF (failed_ind=1)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    IF (nodc_ind=1)
     col 0, "Check the disch_dt_tm. It's either NULL or in the future.", row + 1,
     "You can't cancel an order due to discharge if the patient hasn't been discharged yet."
    ELSEIF (wrong_domain_ind=1)
     col 0,
     "Seriously?! This is kind of awkward, but the order_id you provided doesn't exist on the ORDERS table in this domain."
    ELSEIF (no_order_status_ind=1)
     col 0, "Woah. That's weird.", row + 1,
     "This order didn't have a status on ORDER_ACTION at the time of discharge,which keeps us from ever being able to cancel it."
    ELSEIF (no_order_action_rows=1)
     col 0, "Woah. That's weird.", row + 1,
     "This order doesn't have rows on ORDER_ACTION in this domain."
    ELSEIF (cantcomparedc_ind=1)
     col 0,
     "We can't actually see when the discharge action was performed because Registration 'History' isn't enabled.",
     row + 1,
     "To enabled it, set the 'Option' CODE_VALUE_EXTENSION equal to '1' for the HISTORY code value on codeset 20790.",
     row + 2, "Then cache the codeset."
    ENDIF
   WITH maxcol = 132
  ;end select
 ENDIF
 COMMIT
END GO
