CREATE PROGRAM dm_stat_rev_cycle:dba
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE pqi_row_cnt = f8 WITH noconstant(0)
 SELECT INTO "nl:"
  ut.num_rows
  FROM user_tables ut
  WHERE ut.table_name="PFT_QUEUE_ITEM"
  DETAIL
   pqi_row_cnt = ut.num_rows
  WITH nocounter
 ;end select
 DECLARE dsvm_error(msg=vc) = null
 DECLARE rc_snapshot_type = vc WITH protect, constant("REV_CYC_PARENT.4")
 DECLARE ds_domain_begin_snapshot = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE ds_domain_end_snapshot = dq8 WITH constant(cnvtdatetime((curdate - 1),235959))
 DECLARE a_r_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",18736,"A/R"))
 DECLARE tech_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"TECHDENIAL"))
 DECLARE credit_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"CREDITBAL"))
 DECLARE dem_mod_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"DEMOMODS"))
 DECLARE com_w_error_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",23372,"COMP W ERR"))
 DECLARE error_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",20569,"IN-ERROR"))
 DECLARE lock_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",20569,"ERRLOCK"))
 DECLARE unassind_sp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"UNASSINDSP"))
 DECLARE unassind_ins_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"UNASSIGNDINS")
  )
 DECLARE pastdue_sp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"PASTDUESP"))
 DECLARE pastdue_ins_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"PASTDUE"))
 DECLARE atrisk_ins_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"ATRISKCLAIM"))
 DECLARE edit_fail_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"EDITFAILURE"))
 DECLARE rtb_sp_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"READYTOBILLS"))
 DECLARE rtb_ins_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29321,"READYTOBILL"))
 DECLARE ins_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29320,"INSURANCE"))
 DECLARE encntr_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29320,"PFTENCNTR"))
 DECLARE selfpay_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",29320,"SELFPAY"))
 DECLARE jobcomplete_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",460,"COMPLETE"))
 DECLARE 1450_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",21749,"HCFA_1450"))
 DECLARE 1500_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",21749,"HCFA_1500"))
 DECLARE statement_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",21749,"PATIENT_STMT"))
 DECLARE 222_facility = f8 WITH public, noconstant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE cs18935_submitted_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!491009")),
 protect
 DECLARE cs18935_transmitted_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3260138")),
 protect
 DECLARE cs18935_transxovrpay_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3260238")),
 protect
 DECLARE cs18649_payment_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!30346")), protect
 DECLARE cs18935_canceled_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!491011")), protect
 DECLARE cs4002034_ime_billing = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!723879803")),
 protect
 DECLARE cs29904_technical_denial = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3304147")),
 protect
 DECLARE cs354_selfpay_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",354,"SELFPAY"))
 DECLARE cs13028_debit_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3776")), protect
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE inum = i4 WITH protect, noconstant(0)
 DECLARE stat_name = vc
 DECLARE day_cnt = i4 WITH protect, noconstant(0)
 DECLARE guarantor_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",20849,"GUARANTOR"))
 DECLARE client_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",20849,"CLIENT"))
 DECLARE research_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",20849,"RESEARCH"))
 FREE RECORD run_dates
 RECORD run_dates(
   1 qual[*]
     2 date = dq8
     2 re_run = i2
 )
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="REV_CYC_PARENT.*"
    AND di.info_name="RE_RUN"
    AND di.updt_cnt=0)
  ORDER BY di.info_date DESC
  HEAD REPORT
   cnt = 0
  HEAD di.info_date
   cnt = (cnt+ 1), stat = alterlist(run_dates->qual,cnt), run_dates->qual[cnt].date = di.info_date,
   run_dates->qual[cnt].re_run = 1
  WITH nocounter
 ;end select
 SET day_cnt = size(run_dates->qual,5)
 SET day_cnt = (day_cnt+ 1)
 SET stat = alterlist(run_dates->qual,day_cnt)
 SET run_dates->qual[day_cnt].date = cnvtdatetime((curdate - 1),125959)
 CALL echorecord(run_dates)
 DECLARE tz_cnt = i2 WITH noconstant(0)
 DECLARE uar_datesettimezone(p1=vc(ref)) = i4 WITH image_axp = "datertl", image_aix =
 "libdate.a(libdate.o)", uar = "DateSetTimeZone"
 FREE RECORD rec_tz
 RECORD rec_tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz = c64
 )
 FREE RECORD time_zones
 RECORD time_zones(
   1 tz_cnt = i4
   1 qual[*]
     2 tz_idx = i4
     2 tz_name = vc
 )
 DECLARE logfile = c100 WITH protect
 DECLARE debug_msg_ind = i2
 SET logfile = build("DM_STAT_REV_CYCLE_",curnode,"_",day(curdate),".txt")
 SET qualcnt = 0
 CALL getdebugrow("x")
 CALL log_msg("BeginSession",logfile)
 CALL log_msg(build2("Current Timezone: ",curtimezone),logfile)
 DECLARE sessiontimezone = vc WITH constant(curtimezone)
 DECLARE hasrun = i2 WITH noconstant(0)
 DECLARE opsfinished = i2 WITH noconstant(1)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=rc_snapshot_type
   AND di.info_name IN ("LAST_RUN_TIME")
  HEAD REPORT
   hasrun = 0
  DETAIL
   IF (di.info_date >= cnvtdatetime(curdate,0))
    hasrun = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  DELETE  FROM dm_info di
   WHERE di.info_domain="REV_CYCLE_PARENT.*"
  ;end delete
  INSERT  FROM dm_info di
   SET di.info_domain = rc_snapshot_type, di.info_name = "LAST_RUN_TIME", di.info_date = cnvtdatetime
    ("01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  SET hasrun = 0
  COMMIT
 ENDIF
 IF (hasrun=0
  AND hour(cnvtdatetime(curdate,curtime3)) > 2)
  SET table_exists = checkdic("OPS2_SCHED_JOB","T",0)
  IF (table_exists=2)
   DECLARE ops_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    ld.mnemonic, status = substring(1,10,uar_get_code_display(ost.status_cd)), actual_start = format(
     ost.actual_start_dt_tm,"mm/dd/yy hh:mm;;d"),
    actual_end = format(ost.actual_end_dt_tm,"mm/dd/yy hh:mm;;d"), schedule = format(ost
     .schedule_date_dt_tm,"mm/dd/yy hh:mm;;d"), ost.ops2_job_id
    FROM ops2_sched_job ost,
     ops2_job_sched ot,
     ops2_step osp,
     pft_event pe,
     logical_domain ld
    PLAN (ost
     WHERE ost.active_ind=1
      AND ost.schedule_date_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1
      ),235959)
      AND ost.status_cd=jobcomplete_cd
      AND ost.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ost.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ot
     WHERE ot.ops2_job_id=ost.ops2_job_id
      AND ot.active_ind=1
      AND ot.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ot.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (osp
     WHERE osp.ops2_job_id=ot.ops2_job_id
      AND osp.active_ind=1
      AND osp.request_name IN ("pft_extract_entities", "pft_load_datawharehouse")
      AND osp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND osp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (pe
     WHERE pe.pft_event_id=outerjoin(cnvtreal(trim(osp.batch_selection_txt)))
      AND pe.active_ind=outerjoin(1))
     JOIN (ld
     WHERE ld.logical_domain_id=outerjoin(pe.logical_domain_id))
    ORDER BY ost.ops2_job_id
    HEAD REPORT
     ops_cnt = 0
    HEAD ost.ops2_job_id
     ops_cnt = (ops_cnt+ 1)
    WITH nocounter
   ;end select
   CALL echo(build("previous day ops count",ops_cnt))
   IF (curqual=0)
    CALL echo("2018 table found NO ROWS")
    SELECT INTO "nl:"
     ld.logical_domain_id, job_name = ojs.step_name, status = uar_get_code_display(ost.status_cd)
     FROM ops_schedule_task ost,
      ops_task ot,
      ops_schedule_param osp,
      ops_job_step ojs,
      pft_event pe,
      logical_domain ld
     PLAN (ost
      WHERE ost.active_ind=1
       AND ost.status_cd != jobcomplete_cd)
      JOIN (ot
      WHERE ost.ops_task_id=ot.ops_task_id
       AND ot.active_ind=1)
      JOIN (osp
      WHERE ot.ops_task_id=osp.ops_task_id
       AND osp.active_ind=1)
      JOIN (ojs
      WHERE osp.ops_job_step_id=ojs.ops_job_step_id
       AND ojs.active_ind=1
       AND ojs.step_name IN ("pft_extract_entities", "pft_load_datawharehouse")
       AND ost.active_status_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,235959))
      JOIN (pe
      WHERE outerjoin(cnvtreal(trim(ojs.batch_selection)))=pe.pft_event_id
       AND pe.active_ind=outerjoin(1))
      JOIN (ld
      WHERE outerjoin(pe.logical_domain_id)=ld.logical_domain_id)
     DETAIL
      opsfinished = 0
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    ld.mnemonic, status = substring(1,10,uar_get_code_display(ost.status_cd)), actual_start = format(
     ost.actual_start_dt_tm,"mm/dd/yy hh:mm;;d"),
    actual_end = format(ost.actual_end_dt_tm,"mm/dd/yy hh:mm;;d"), schedule = format(ost
     .schedule_date_dt_tm,"mm/dd/yy hh:mm;;d"), ost.ops2_job_id
    FROM ops2_sched_job ost,
     ops2_job_sched ot,
     ops2_step osp,
     pft_event pe,
     logical_domain ld
    PLAN (ost
     WHERE ost.active_ind=1
      AND ost.schedule_date_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,235959)
      AND ost.status_cd=jobcomplete_cd
      AND ost.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ost.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ot
     WHERE ot.ops2_job_id=ost.ops2_job_id
      AND ot.active_ind=1
      AND ot.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ot.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (osp
     WHERE osp.ops2_job_id=ot.ops2_job_id
      AND osp.active_ind=1
      AND osp.request_name IN ("pft_extract_entities", "pft_load_datawharehouse")
      AND osp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND osp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (pe
     WHERE pe.pft_event_id=outerjoin(cnvtreal(trim(osp.batch_selection_txt)))
      AND pe.active_ind=outerjoin(1))
     JOIN (ld
     WHERE ld.logical_domain_id=outerjoin(pe.logical_domain_id))
    ORDER BY ost.ops2_job_id
    HEAD REPORT
     cnt = 0
    HEAD ost.ops2_job_id
     cnt = (cnt+ 1)
    DETAIL
     null
    FOOT  ost.ops2_job_id
     null
    FOOT REPORT
     IF (cnt < ops_cnt)
      opsfinished = 0
     ENDIF
     CALL echo(build("today ops count",cnt))
    WITH nocounter
   ;end select
   IF (curqual=0
    AND ops_cnt > 0)
    CALL echo("today ops count = 0 and yesterday had value")
    SET opsfinished = 0
   ENDIF
  ELSE
   SELECT INTO "nl:"
    ld.logical_domain_id, job_name = ojs.step_name, status = uar_get_code_display(ost.status_cd)
    FROM ops_schedule_task ost,
     ops_task ot,
     ops_schedule_param osp,
     ops_job_step ojs,
     pft_event pe,
     logical_domain ld
    PLAN (ost
     WHERE ost.active_ind=1
      AND ost.status_cd != jobcomplete_cd)
     JOIN (ot
     WHERE ost.ops_task_id=ot.ops_task_id
      AND ot.active_ind=1)
     JOIN (osp
     WHERE ot.ops_task_id=osp.ops_task_id
      AND osp.active_ind=1)
     JOIN (ojs
     WHERE osp.ops_job_step_id=ojs.ops_job_step_id
      AND ojs.active_ind=1
      AND ojs.step_name IN ("pft_extract_entities", "pft_load_datawharehouse")
      AND ost.active_status_dt_tm BETWEEN cnvtdatetime(curdate,0) AND cnvtdatetime(curdate,235959))
     JOIN (pe
     WHERE outerjoin(cnvtreal(trim(ojs.batch_selection)))=pe.pft_event_id
      AND pe.active_ind=outerjoin(1))
     JOIN (ld
     WHERE outerjoin(pe.logical_domain_id)=ld.logical_domain_id)
    DETAIL
     opsfinished = 0
    WITH nocounter
   ;end select
  ENDIF
  IF (opsfinished=1)
   CALL log_msg("Running Main Logic",logfile)
   UPDATE  FROM dm_info di
    SET di.info_date = cnvtdatetime(curdate,curtime3)
    WHERE di.info_domain=rc_snapshot_type
     AND di.info_name="LAST_RUN_TIME"
    WITH nocounter
   ;end update
   COMMIT
   FREE RECORD facility
   RECORD facility(
     1 qual[*]
       2 facility_cd = f8
       2 display = vc
       2 description = vc
   )
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.active_ind=1)
    ORDER BY cv.display
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(facility->qual,cnt), facility->qual[cnt].description = cv
     .description,
     facility->qual[cnt].display = trim(cnvtupper(cv.display)), facility->qual[cnt].facility_cd = cv
     .code_value
    WITH nocounter
   ;end select
   SET ds_cnt = 1
   SET ds_cnt2 = 0
   SELECT DISTINCT INTO "nl:"
    FROM billing_entity b,
     location l,
     time_zone_r tzr
    PLAN (b
     WHERE b.active_ind=true
      AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (l
     WHERE l.organization_id=b.organization_id
      AND l.location_type_cd=222_facility
      AND l.active_ind=true
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (tzr
     WHERE tzr.parent_entity_id=l.location_cd
      AND tzr.parent_entity_name="LOCATION")
    ORDER BY tzr.time_zone
    HEAD REPORT
     tz_cnt = 0
    HEAD tzr.time_zone
     tz_cnt = (tz_cnt+ 1)
     IF (mod(tz_cnt,10)=1)
      stat = alterlist(time_zones->qual,(tz_cnt+ 9))
     ENDIF
     time_zones->qual[tz_cnt].tz_idx = datetimezonebyname(trim(tzr.time_zone,3)), time_zones->qual[
     tz_cnt].tz_name = trim(tzr.time_zone,3)
    FOOT REPORT
     time_zones->tz_cnt = tz_cnt, stat = alterlist(time_zones->qual,time_zones->tz_cnt)
    WITH nocounter
   ;end select
   IF (tz_cnt=0)
    SET time_zones->tz_cnt = 1
    SET stat = alterlist(time_zones->qual,1)
    SET time_zones->qual[1].tz_idx = 999
   ENDIF
   SET stat_seq = 0
   CALL log_msg("Starting Multi-Tennant Loops",logfile)
   FOR (d = 1 TO size(run_dates->qual,5))
     CALL echo(build("DATE RUNNING FOR ",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")))
     SET re_run = run_dates->qual[d].re_run
     CALL echo(build("re-run=",re_run))
     SET date_n = format(run_dates->qual[d].date,"DD-MMM-YYYY;;d")
     SET date_nbr = cnvtreal(cnvtdate2(date_n,"DD-MMM_YYYY"))
     IF (d > 1)
      SET ds_cnt = size(dsr->qual[1].qual,5)
      SET e = (10 - mod(ds_cnt,10))
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ e))
     ENDIF
     SELECT INTO "nl:"
      be_name = substring(1,50,be.be_name), be_id = be.billing_entity_id, parent_be_id = be
      .parent_be_id,
      logical_domain_id = o.logical_domain_id, cnt = count(1)
      FROM billing_entity be,
       organization o
      PLAN (be
       WHERE be.active_ind=1)
       JOIN (o
       WHERE be.organization_id=o.organization_id)
      GROUP BY be.be_name, be.billing_entity_id, be.parent_be_id,
       o.logical_domain_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
        dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("BE_INFO","}|",format(run_dates->qual[d].
         date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = build(be_name,"}|",
        be_id,"}|",parent_be_id,
        "}|",logical_domain_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (ds_cnt2=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("BE_INFO","}|",format(run_dates->qual[d].
          date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->
        qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
        ds_cnt = (ds_cnt+ 1)
       ENDIF
      WITH nullreport, nocounter
     ;end select
     CALL dsvm_error("BE_INFO")
     SET ds_cnt2 = 0
     FOR (tz_idx = 1 TO time_zones->tz_cnt)
       IF (curutc
        AND (time_zones->qual[tz_idx].tz_idx != 999))
        SET rec_tz->m_id = concat(trim(time_zones->qual[tz_idx].tz_name),char(0))
        SET stat = uar_datesettimezone(rec_tz)
        DECLARE ds_begin_snapshot = dq8 WITH noconstant(cnvtdatetime(concat(format(run_dates->qual[d]
            .date,"dd-mmm-yyyy;;d")," 00:00:00")))
        DECLARE ds_end_snapshot = dq8 WITH noconstant(cnvtdatetime(concat(format(run_dates->qual[d].
            date,"dd-mmm-yyyy;;d")," 23:59:59")))
        SET date_n = format(run_dates->qual[d].date,"DD-MMM-YYYY;;d")
        CALL echo(date_n)
        SET date_nbr = cnvtreal(cnvtdate2(date_n,"DD-MMM_YYYY"))
        CALL echo(date_nbr)
        CALL echo(format(ds_begin_snapshot,"mm/dd/yy hh:mm;;d"))
        CALL echo(format(ds_end_snapshot,"mm/dd/yy hh:mm;;d"))
        CALL echo(build("AVG_DAILY_REV",curtime))
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), avg_daily_rev = sqlpassthru(
          "round(sum(case when dab.chrg_dr_cr_flag=2 then(dab.charge_amount*-1.0)else dab.charge_amount end),2)",
          0), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.activity_dt_tm >= cnvtlookbehind("89,D",ds_begin_snapshot)
          AND dab.active_status_dt_tm <= cnvtlookbehind("0,D",ds_end_snapshot)
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
          AND be.billing_entity_id IN (
         (SELECT
          be1.billing_entity_id
          FROM billing_entity be1,
           location l,
           time_zone_r tzr
          WHERE be1.active_ind=true
           AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND l.organization_id=be1.organization_id
           AND l.location_type_cd=222_facility
           AND l.active_ind=true
           AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND tzr.parent_entity_id=l.location_cd
           AND tzr.parent_entity_name="LOCATION"
           AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name)))
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|-1}|}|}|",avg_daily_rev), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
             qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         avg_daily_rev = sqlpassthru(
          "round(sum(case when deb.chrg_dr_cr_flag=2 then(deb.charge_amount*-1.0)else deb.charge_amount end),2)",
          0), cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          account a,
          encounter e,
          billing_entity be
         PLAN (deb
          WHERE deb.activity_dt_tm >= cnvtlookbehind("89,D",ds_begin_snapshot)
           AND deb.active_status_dt_tm <= cnvtlookbehind("0,D",ds_end_snapshot))
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND ((pe.active_ind=1) OR (pe.active_ind=0
           AND pe.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND ((e.active_ind=1) OR (e.active_ind=0
           AND e.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.billing_entity_id IN (
          (SELECT
           be1.billing_entity_id
           FROM billing_entity be1,
            location l,
            time_zone_r tzr
           WHERE be1.active_ind=true
            AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND l.organization_id=be1.organization_id
            AND l.location_type_cd=222_facility
            AND l.active_ind=true
            AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND tzr.parent_entity_id=l.location_cd
            AND tzr.parent_entity_name="LOCATION"
            AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",avg_daily_rev), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
             qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = time_zones->qual[tz_idx].tz_name, stat_seq
            = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("AVG_DAILY_REV")
        CALL echo(build("A_R_BAL",curtime))
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), a_r_bal = round(sum(evaluate(dab.end_dr_cr_flag,2,(dab
            .end_balance * - (1.0)),dab.end_balance)),2), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
          AND dab.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
          AND ((dab.end_balance != 0) OR (dab.end_balance=0
          AND dab.activity_dt_tm=cnvtdatetime(ds_begin_snapshot)))
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
          AND be.billing_entity_id IN (
         (SELECT
          be1.billing_entity_id
          FROM billing_entity be1,
           location l,
           time_zone_r tzr
          WHERE be1.active_ind=true
           AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND l.organization_id=be1.organization_id
           AND l.location_type_cd=222_facility
           AND l.active_ind=true
           AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND tzr.parent_entity_id=l.location_cd
           AND tzr.parent_entity_name="LOCATION"
           AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name)))
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d].
            date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
           "}|-1}|}|}|",a_r_bal), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d]
             .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
           dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         a_r_bal = round(sum(evaluate(deb.end_dr_cr_flag,2,(deb.end_balance * - (1.0)),deb
            .end_balance)),2), cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          account a,
          encounter e,
          billing_entity be
         PLAN (deb
          WHERE deb.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
           AND deb.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
           AND ((deb.end_balance != 0) OR (deb.end_balance=0
           AND deb.activity_dt_tm=cnvtdatetime(ds_begin_snapshot))) )
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND pe.active_ind=1
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=1
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, client_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND be.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND be.billing_entity_id IN (
          (SELECT
           be1.billing_entity_id
           FROM billing_entity be1,
            location l,
            time_zone_r tzr
           WHERE be1.active_ind=true
            AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND l.organization_id=be1.organization_id
            AND l.location_type_cd=222_facility
            AND l.active_ind=true
            AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND tzr.parent_entity_id=l.location_cd
            AND tzr.parent_entity_name="LOCATION"
            AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d].
            date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
           "}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",a_r_bal), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d]
             .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
           dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = time_zones->qual[tz_idx].tz_name, stat_seq
            = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("A_R_BAL")
        SET ds_cnt2 = 0
        CALL echo(build("CHARGES_PAY_ADJ",curtime))
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), charges = round(sum(evaluate(dab.chrg_dr_cr_flag,2,(
            dab.charge_amount * - (1.0)),dab.charge_amount)),2), payments = round(sum(evaluate(dab
            .pay_dr_cr_flag,2,(dab.payment_amount * - (1.0)),dab.payment_amount)),2),
         adjustments = round(sum(evaluate(dab.adj_dr_cr_flag,2,(dab.adjustment_amount * - (1.0)),dab
            .adjustment_amount)),2), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
          AND dab.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
          AND dab.activity_dt_tm=cnvtdatetime(ds_begin_snapshot)
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
          AND be.billing_entity_id IN (
         (SELECT
          be1.billing_entity_id
          FROM billing_entity be1,
           location l,
           time_zone_r tzr
          WHERE be1.active_ind=true
           AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND l.organization_id=be1.organization_id
           AND l.location_type_cd=222_facility
           AND l.active_ind=true
           AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND tzr.parent_entity_id=l.location_cd
           AND tzr.parent_entity_name="LOCATION"
           AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name)))
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
           dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|-1}|}|}|",charges,"}|",payments,
           "}|",adjustments), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         charges = round(sum(evaluate(deb.chrg_dr_cr_flag,2,(deb.charge_amount * - (1.0)),deb
            .charge_amount)),2), payments = round(sum(evaluate(deb.pay_dr_cr_flag,2,(deb
            .payment_amount * - (1.0)),deb.payment_amount)),2), adjustments = round(sum(evaluate(deb
            .adj_dr_cr_flag,2,(deb.adjustment_amount * - (1.0)),deb.adjustment_amount)),2),
         cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          encounter e,
          account a,
          billing_entity be
         PLAN (deb
          WHERE deb.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
           AND deb.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
           AND deb.activity_dt_tm=cnvtdatetime(ds_begin_snapshot))
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND ((pe.active_ind=1) OR (pe.active_ind=0
           AND pe.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND ((e.active_ind=1) OR (e.active_ind=0
           AND e.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.active_ind=1
           AND be.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND be.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
           AND be.billing_entity_id IN (
          (SELECT
           be1.billing_entity_id
           FROM billing_entity be1,
            location l,
            time_zone_r tzr
           WHERE be1.active_ind=true
            AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND l.organization_id=be1.organization_id
            AND l.location_type_cd=222_facility
            AND l.active_ind=true
            AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND tzr.parent_entity_id=l.location_cd
            AND tzr.parent_entity_name="LOCATION"
            AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
           dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",charges,"}|",
           payments,"}|",adjustments), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = time_zones->qual[tz_idx].tz_name, stat_seq
            = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("CHARGES_PAY_ADJ")
       ELSE
        DECLARE ds_begin_snapshot = dq8 WITH noconstant(cnvtdatetime(concat(format(run_dates->qual[d]
            .date,"dd-mmm-yyyy;;d")," 00:00:00")))
        DECLARE ds_end_snapshot = dq8 WITH noconstant(cnvtdatetime(concat(format(run_dates->qual[d].
            date,"dd-mmm-yyyy;;d")," 23:59:59")))
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), avg_daily_rev = sqlpassthru(
          "round(sum(case when dab.chrg_dr_cr_flag=2 then(dab.charge_amount*-1.0)else dab.charge_amount end),2)",
          0), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.activity_dt_tm >= cnvtlookbehind("89,D",ds_begin_snapshot)
          AND dab.active_status_dt_tm <= cnvtlookbehind("0,D",ds_end_snapshot)
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|-1}|}|}|",avg_daily_rev), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
             qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         avg_daily_rev = sqlpassthru(
          "round(sum(case when deb.chrg_dr_cr_flag=2 then(deb.charge_amount*-1.0)else deb.charge_amount end),2)",
          0), cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          account a,
          encounter e,
          billing_entity be
         PLAN (deb
          WHERE deb.activity_dt_tm >= cnvtlookbehind("89,D",ds_begin_snapshot)
           AND deb.active_status_dt_tm <= cnvtlookbehind("0,D",ds_end_snapshot))
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND ((pe.active_ind=1) OR (pe.active_ind=0
           AND pe.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND ((e.active_ind=1) OR (e.active_ind=0
           AND e.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.active_ind=1
           AND be.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND be.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",avg_daily_rev), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AVG_DAILY_REV","}|",format(run_dates->
             qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("AVG_DAILY_REV")
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), a_r_bal = round(sum(evaluate(dab.end_dr_cr_flag,2,(dab
            .end_balance * - (1.0)),dab.end_balance)),2), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
          AND dab.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
          AND ((dab.end_balance != 0) OR (dab.end_balance=0
          AND dab.activity_dt_tm=cnvtdatetime(ds_begin_snapshot)))
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d].
            date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
           "}|-1}|}|}|",a_r_bal), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d]
             .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
           dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         a_r_bal = round(sum(evaluate(deb.end_dr_cr_flag,2,(deb.end_balance * - (1.0)),deb
            .end_balance)),2), cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          account a,
          encounter e,
          billing_entity be
         PLAN (deb
          WHERE deb.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
           AND deb.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
           AND ((deb.end_balance != 0) OR (deb.end_balance=0
           AND deb.activity_dt_tm=cnvtdatetime(ds_begin_snapshot))) )
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND pe.active_ind=1
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND e.active_ind=1
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, client_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND be.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           snapshot_type = rc_snapshot_type,
           dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d].
            date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
           "}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",a_r_bal), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_BAL","}|",format(run_dates->qual[d]
             .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
           dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("A_R_BAL")
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), charges = round(sum(evaluate(dab.chrg_dr_cr_flag,2,(
            dab.charge_amount * - (1.0)),dab.charge_amount)),2), payments = round(sum(evaluate(dab
            .pay_dr_cr_flag,2,(dab.payment_amount * - (1.0)),dab.payment_amount)),2),
         adjustments = round(sum(evaluate(dab.adj_dr_cr_flag,2,(dab.adjustment_amount * - (1.0)),dab
            .adjustment_amount)),2), cnt = count(1)
         FROM daily_acct_bal dab,
          account a,
          billing_entity be
         WHERE dab.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
          AND dab.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
          AND dab.activity_dt_tm=cnvtdatetime(ds_begin_snapshot)
          AND dab.acct_id=a.acct_id
          AND a.acct_type_cd=a_r_cd
          AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
          AND be.billing_entity_id=dab.billing_entity_id
         GROUP BY be.be_name
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
           dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|-1}|}|}|",charges,"}|",payments,
           "}|",adjustments), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        SET ds_cnt2 = 0
        SELECT INTO "nl:"
         be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
         fac_desc = uar_get_code_description(e.loc_facility_cd),
         charges = round(sum(evaluate(deb.chrg_dr_cr_flag,2,(deb.charge_amount * - (1.0)),deb
            .charge_amount)),2), payments = round(sum(evaluate(deb.pay_dr_cr_flag,2,(deb
            .payment_amount * - (1.0)),deb.payment_amount)),2), adjustments = round(sum(evaluate(deb
            .adj_dr_cr_flag,2,(deb.adjustment_amount * - (1.0)),deb.adjustment_amount)),2),
         cnt = count(1)
         FROM daily_encntr_bal deb,
          pft_encntr pe,
          encounter e,
          account a,
          billing_entity be
         PLAN (deb
          WHERE deb.beg_effective_dt_tm <= cnvtdatetime(ds_begin_snapshot)
           AND deb.end_effective_dt_tm >= cnvtdatetime(ds_end_snapshot)
           AND deb.activity_dt_tm=cnvtdatetime(ds_begin_snapshot))
          JOIN (pe
          WHERE pe.pft_encntr_id=deb.pft_encntr_id
           AND ((pe.active_ind=1) OR (pe.active_ind=0
           AND pe.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (a
          WHERE a.acct_id=pe.acct_id
           AND a.acct_type_cd=a_r_cd
           AND  NOT (a.acct_sub_type_cd IN (guarantor_cd, research_cd))
           AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (e
          WHERE e.encntr_id=pe.encntr_id
           AND ((e.active_ind=1) OR (e.active_ind=0
           AND e.active_status_dt_tm >= cnvtdatetime(ds_begin_snapshot)))
           AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          JOIN (be
          WHERE be.billing_entity_id=deb.billing_entity_id
           AND be.active_ind=1
           AND be.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           AND be.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
         GROUP BY be.be_name, e.loc_facility_cd
         HEAD REPORT
          IF (ds_cnt=1)
           qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
           stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
           dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
          ENDIF
         DETAIL
          IF (mod(ds_cnt,10)=1)
           stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
          ENDIF
          dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates->
            qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
           be_name,"}|",e.loc_facility_cd,"}|",fac_name,
           "}|",fac_desc,"}|",charges,"}|",
           payments,"}|",adjustments), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
          dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
          stat_seq, ds_cnt = (ds_cnt+ 1),
          ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
         FOOT REPORT
          IF (ds_cnt2=0)
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGES_PAY_ADJ","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
           "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
          ENDIF
         WITH nullreport, nocounter
        ;end select
        CALL dsvm_error("CHARGES_PAY_ADJ")
       ENDIF
     ENDFOR
     IF ((run_dates->qual[d].re_run=1))
      CALL echo("POPULATE NO NEW DATA")
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 14))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_1_30_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_31_60_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_61_90_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_91_120_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_121_150_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_151_180_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_181_210_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_211_240_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_241_270_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_271_300_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_301_330_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_331_365_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ATB_366_BAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = cnvtupper(trim(sdl.facility,3)), a_r_90_days
        = round(sum(r.total_balance_amt),2),
       cnt = count(1)
       FROM rc_f_patient_ar_bal_smry r,
        rc_d_balance_type rd,
        rc_d_age_category ra,
        rc_d_billing_entity rbe,
        billing_entity be,
        shr_d_location sdl
       PLAN (r
        WHERE r.activity_dt_nbr=value(date_nbr))
        JOIN (rbe
        WHERE r.rc_d_billing_entity_id=rbe.rc_d_billing_entity_id)
        JOIN (be
        WHERE rbe.mill_billing_entity_id=be.billing_entity_id)
        JOIN (rd
        WHERE r.rc_d_balance_type_id=rd.rc_d_balance_type_id
         AND rd.balance_type != "Bad Debt")
        JOIN (ra
        WHERE r.rc_d_discharge_age_id=ra.rc_d_age_category_id
         AND ra.category_description IN ("91-120", "121-150", "151-180", "181-210", "211-240",
        "241-270", "271-300", "301-330", "331-365", "366+"))
        JOIN (sdl
        WHERE sdl.shr_d_location_id=r.shr_d_location_id)
       GROUP BY be.be_name, sdl.facility
       ORDER BY be.be_name, sdl.facility
       HEAD REPORT
        null
       DETAIL
        ipos = locateval(inum,1,size(facility->qual,5),trim(fac_name,3),facility->qual[inum].display)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_90_DAYS","}|",format(run_dates->qual[d
          ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",facility->qual[ipos].facility_cd,"}|",fac_name,
         "}|",facility->qual[ipos].description,"}|",a_r_90_days), dsr->qual[qualcnt].qual[ds_cnt].
        stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("A_R_90_DAYS","}|",format(run_dates->qual[
           d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
     ELSE
      CALL echo(date_nbr)
      SET ds_cnt2_1_30 = 0
      SET ds_cnt2_31_60 = 0
      SET ds_cnt2_61_90 = 0
      SET ds_cnt2_91_120 = 0
      SET ds_cnt2_121_150 = 0
      SET ds_cnt2_151_180 = 0
      SET ds_cnt2_181_210 = 0
      SET ds_cnt2_211_240 = 0
      SET ds_cnt2_241_270 = 0
      SET ds_cnt2_271_300 = 0
      SET ds_cnt2_301_330 = 0
      SET ds_cnt2_331_365 = 0
      SET ds_cnt2_366 = 0
      SET ds_cnt2_over90 = 0
      SET over_90 = 0.00
      CALL echo(build("ATB_BALANCES",curtime))
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = cnvtupper(trim(sdl.facility,3)), ra
       .category_description,
       atb_bal = round(sum((r.total_balance_amt - r.total_unbilled_balance_amt)),2), a_r_bal = round(
        sum(r.total_balance_amt),2), cnt = count(1)
       FROM rc_f_patient_ar_bal_smry r,
        rc_d_balance_type rd,
        rc_d_age_category ra,
        rc_d_billing_entity rbe,
        billing_entity be,
        shr_d_location sdl
       PLAN (r
        WHERE r.activity_dt_nbr=value(date_nbr))
        JOIN (rbe
        WHERE r.rc_d_billing_entity_id=rbe.rc_d_billing_entity_id)
        JOIN (be
        WHERE rbe.mill_billing_entity_id=be.billing_entity_id)
        JOIN (rd
        WHERE r.rc_d_balance_type_id=rd.rc_d_balance_type_id
         AND rd.balance_type != "Bad Debt")
        JOIN (ra
        WHERE r.rc_d_discharge_age_id=ra.rc_d_age_category_id
         AND ra.category_description != "In-house")
        JOIN (sdl
        WHERE sdl.shr_d_location_id=r.shr_d_location_id)
       GROUP BY be.be_name, sdl.facility, ra.category_description
       ORDER BY be.be_name, sdl.facility, ra.category_description
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         snapshot_type = rc_snapshot_type,
         dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
        ENDIF
        a_r_90_days = "N"
       HEAD be_name
        null
       HEAD fac_name
        over_90 = 0.00, ipos = locateval(inum,1,size(facility->qual,5),trim(fac_name,3),facility->
         qual[inum].display)
       DETAIL
        CASE (ra.category_description)
         OF "1-30":
          stat_name = "ATB_1_30_BAL",ds_cnt2_1_30 = (ds_cnt2_1_30+ 1)
         OF "31-60":
          stat_name = "ATB_31_60_BAL",ds_cnt2_31_60 = (ds_cnt2_31_60+ 1)
         OF "61-90":
          stat_name = "ATB_61_90_BAL",ds_cnt2_61_90 = (ds_cnt2_61_90+ 1)
         OF "91-120":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_91_120_BAL",ds_cnt2_91_120 = (ds_cnt2_91_120
          + 1)
         OF "121-150":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_121_150_BAL",ds_cnt2_121_150 = (
          ds_cnt2_121_150+ 1)
         OF "151-180":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_151_180_BAL",ds_cnt2_151_180 = (
          ds_cnt2_151_180+ 1)
         OF "181-210":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_181_210_BAL",ds_cnt2_181_210 = (
          ds_cnt2_181_210+ 1)
         OF "211-240":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_211_240_BAL",ds_cnt2_211_240 = (
          ds_cnt2_211_240+ 1)
         OF "241-270":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_241_270_BAL",ds_cnt2_241_270 = (
          ds_cnt2_241_270+ 1)
         OF "271-300":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_271_300_BAL",ds_cnt2_271_300 = (
          ds_cnt2_271_300+ 1)
         OF "301-330":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_301_330_BAL",ds_cnt2_301_330 = (
          ds_cnt2_301_330+ 1)
         OF "331-365":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_331_365_BAL",ds_cnt2_331_365 = (
          ds_cnt2_331_365+ 1)
         OF "366+":
          over_90 = (over_90+ a_r_bal),stat_name = "ATB_366_BAL",ds_cnt2_366 = (ds_cnt2_366+ 1)
        ENDCASE
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build(stat_name,"}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[
        qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",facility->qual[ipos].facility_cd,
         "}|",fac_name,
         "}|",facility->qual[ipos].description,"}|",atb_bal),
        dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
        stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
        ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
       FOOT  fac_name
        IF ( NOT (over_90=0))
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("A_R_90_DAYS","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
         qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",facility->qual[ipos].
          facility_cd,"}|",fac_name,
          "}|",facility->qual[ipos].description,"}|",over_90),
         dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
         stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1), a_r_90_days = "Y"
        ENDIF
       FOOT  be_name
        null
       FOOT REPORT
        IF (ds_cnt2_1_30=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_1_30_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr
         ->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_31_60=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_31_60_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr
         ->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_61_90=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_61_90_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr
         ->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_91_120=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_91_120_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_121_150=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_121_150_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_151_180=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_151_180_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_181_210=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_181_210_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_211_240=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_211_240_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_241_270=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_241_270_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_271_300=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_271_300_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_301_330=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_301_330_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_331_365=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_331_365_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (ds_cnt2_366=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("ATB_366_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
         qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
        IF (a_r_90_days="N")
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("A_R_90_DAYS","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
         qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("ATB BALANCES")
     ENDIF
     CALL echo(build("DNFB ALL TYPES",curtime))
     SET ds_cnt2_bsb = 0
     SET ds_cnt2_crb = 0
     SET ds_cnt2_cbncb = 0
     SET ds_cnt2_hisb = 0
     SET ds_cnt2_rtbb = 0
     SET ds_cnt2_sdb = 0
     SET ds_cnt2_wfcb = 0
     SET ds_cnt2_dnfb = 0
     SELECT INTO "nl:"
      be_name = substring(1,50,be.be_name), fac_name = substring(1,50,sdl.facility), rds.dnfb_status,
      dnfb_bal = round(sum(r.total_unbilled_balance_amt),2), cnt = count(1)
      FROM rc_f_patient_ar_bal_smry r,
       rc_d_balance_type rd,
       rc_d_dnfb_status rds,
       rc_d_billing_entity rbe,
       billing_entity be,
       shr_d_location sdl
      PLAN (r
       WHERE r.activity_dt_nbr=value(date_nbr))
       JOIN (rbe
       WHERE r.rc_d_billing_entity_id=rbe.rc_d_billing_entity_id)
       JOIN (be
       WHERE rbe.mill_billing_entity_id=be.billing_entity_id)
       JOIN (rd
       WHERE r.rc_d_balance_type_id=rd.rc_d_balance_type_id
        AND rd.balance_type != "Bad Debt")
       JOIN (rds
       WHERE r.rc_d_dnfb_status_id=rds.rc_d_dnfb_status_id
        AND rds.rc_d_dnfb_status_id > 0.00
        AND ((rds.dnfb_status != "Ready to Bill") OR (rds.dnfb_reason != "Late Charge")) )
       JOIN (sdl
       WHERE sdl.shr_d_location_id=r.shr_d_location_id)
      GROUP BY be.be_name, sdl.facility, rds.dnfb_status
      ORDER BY be.be_name, sdl.facility, rds.dnfb_status
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].snapshot_type
         = rc_snapshot_type,
        dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
       ENDIF
      HEAD be_name
       null
      HEAD fac_name
       ipos = locateval(inum,1,size(facility->qual,5),cnvtupper(trim(fac_name,3)),facility->qual[inum
        ].display), dnfb_bal_all = 0.00
      DETAIL
       CASE (rds.dnfb_status)
        OF "Bill Suppression Hold":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_BILL_SUPRESSION_BAL",ds_cnt2_bsb
          = (ds_cnt2_bsb+ 1)
        OF "Correction Required":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_CORRECTION_REQUIRED_BAL",
         ds_cnt2_crb = (ds_cnt2_crb+ 1)
        OF "Credit Balance - No Charges":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_CREDIT_BAL_NO_CHARGE_BAL",
         ds_cnt2_cbncb = (ds_cnt2_cbncb+ 1)
        OF "Held in Scrubber-Submitted not transmitted":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_HELD_IN_SCRUBBER_BAL",ds_cnt2_hisb
          = (ds_cnt2_hisb+ 1)
        OF "Ready to Bill":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_READY_TO_BILL_BAL_BAL",
         ds_cnt2_rtbb = (ds_cnt2_rtbb+ 1)
        OF "Standard Delay":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_STANDARD_DELAY_BAL",ds_cnt2_sdb =
         (ds_cnt2_sdb+ 1)
        OF "Waiting for Coding":
         dnfb_bal_all = (dnfb_bal_all+ dnfb_bal),stat_name = "DNFB_WFC_BAL",ds_cnt2_wfcb = (
         ds_cnt2_wfcb+ 1)
       ENDCASE
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
       stat_name = build(stat_name,"}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[
       qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",facility->qual[ipos].facility_cd,"}|",
        fac_name,
        "}|",facility->qual[ipos].description,"}|",dnfb_bal),
       dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
       stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
       ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1)
      FOOT  fac_name
       IF (dnfb_bal_all > 0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
        qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",facility->qual[ipos].
         facility_cd,"}|",fac_name,
         "}|",facility->qual[ipos].description,"}|",dnfb_bal_all),
        dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
        stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
        ds_cnt = (ds_cnt+ 1), ds_cnt2_dnfb = (ds_cnt2_dnfb+ 1), stat_seq = (stat_seq+ 1)
       ENDIF
      FOOT  be_name
       null
      FOOT REPORT
       IF (ds_cnt2_dnfb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
        qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_bsb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_BILL_SUPRESSION_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_crb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_CORRECTION_REQUIRED_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_cbncb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_CREDIT_BAL_NO_CHARGE_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_hisb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_HELD_IN_SCRUBBER_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_rtbb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_READY_TO_BILL_BAL_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_sdb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_STANDARD_DELAY_BAL","}|",format(run_dates->qual[d].date,
          "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
       IF (ds_cnt2_wfcb=0)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("DNFB_WFC_BAL","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
        qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
        ds_cnt+ 1)
       ENDIF
      WITH nullreport, nocounter
     ;end select
     CALL dsvm_error("DNFB_BAL")
     IF (((pqi_row_cnt > 10000000.00) OR ((run_dates->qual[d].re_run=1))) )
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("TECH_DENIAL","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET ds_cnt = (ds_cnt+ 1)
      SET stat_seq = (stat_seq+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CREDIT_BAL","}|",format(run_dates->qual[
        d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ENCNTR_MOD","}|",format(run_dates->qual[
        d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_SP","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_INS","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_SP","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_INS","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AT_RISK_INS","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("EDIT_FAILURE","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt = (ds_cnt+ 1)
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       tech_denial = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (1
         )))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=tech_cd
         AND pqi.pft_entity_type_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         snapshot_type = rc_snapshot_type,
         dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("TECH_DENIAL","}|",format(run_dates->qual[d
          ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",tech_denial), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("TECH_DENIAL","}|",format(run_dates->qual[
           d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("TECH_DENAIL")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       credit_bal = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (1)
         ))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=credit_cd
         AND pqi.pft_entity_type_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         snapshot_type = rc_snapshot_type,
         dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CREDIT_BAL","}|",format(run_dates->qual[d]
          .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",
         e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",credit_bal), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CREDIT_BAL","}|",format(run_dates->qual[d
           ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("CREDIT_BAL")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       encntr_mod_bal = sum(evaluate(pe.dr_cr_flag,1,pe.balance,(pe.balance * - (1)))),
       encntr_mod_cnt = count(pqi.pft_queue_item_id)
       FROM pft_queue_item pqi,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=dem_mod_cd
         AND pqi.pft_entity_type_cd=encntr_cd
         AND pqi.active_ind=1)
        JOIN (pe
        WHERE pqi.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ENCNTR_MOD","}|",format(run_dates->qual[d]
          .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",
         e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",encntr_mod_bal,"}|",
         encntr_mod_cnt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = encntr_mod_cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("ENCNTR_MOD","}|",format(run_dates->qual[d
           ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("ENCNTR_MOD")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       unassigned_sp = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due *
         - (1)))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=unassind_sp_cd
         AND pqi.pft_entity_type_cd=selfpay_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_SP","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
         be_name,"}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",unassigned_sp), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_SP","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
         "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("UNASSIGNED_SP")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       unassigned_ins = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due *
         - (1)))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=unassind_ins_cd
         AND pqi.pft_entity_status_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_INS","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
         be_name,"}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",unassigned_ins), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("UNASSIGNED_INS","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
         "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("UNASSIGNED_INS")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       past_due_sp = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (1
         )))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=pastdue_sp_cd
         AND pqi.pft_entity_type_cd=selfpay_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_SP","}|",format(run_dates->qual[d
          ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",past_due_sp), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_SP","}|",format(run_dates->qual[
           d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("PAST_DUE_SP")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       past_due_ins = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (
         1)))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=pastdue_ins_cd
         AND pqi.pft_entity_type_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_INS","}|",format(run_dates->qual[
          d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",past_due_ins), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("PAST_DUE_INS","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
         "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("PAST_DUE_INS")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       at_risk_ins = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (1
         )))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=atrisk_ins_cd
         AND pqi.pft_entity_type_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AT_RISK_INS","}|",format(run_dates->qual[d
          ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",at_risk_ins), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("AT_RISK_INS","}|",format(run_dates->qual[
           d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("AT_RISK_INS")
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       edit_failure = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due * - (
         1)))), cnt = count(1)
       FROM pft_queue_item pqi,
        bo_hp_reltn bhp,
        pft_proration pp,
        benefit_order bo,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (pqi
        WHERE pqi.pft_entity_status_cd=edit_fail_cd
         AND pqi.pft_entity_type_cd=ins_cd
         AND pqi.active_ind=1)
        JOIN (bhp
        WHERE pqi.bo_hp_reltn_id=bhp.bo_hp_reltn_id)
        JOIN (pp
        WHERE bhp.bo_hp_reltn_id=pp.bo_hp_reltn_id
         AND pp.active_ind=1)
        JOIN (bo
        WHERE bhp.benefit_order_id=bo.benefit_order_id)
        JOIN (pe
        WHERE bo.pft_encntr_id=pe.pft_encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("EDIT_FAILURE","}|",format(run_dates->qual[
          d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|",e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",edit_failure), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ELSE
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("EDIT_FAILURE","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
         "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
     ENDIF
     CALL dsvm_error("EDIT_FAILURE")
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("SUS_CHRG","}|",format(run_dates->qual[d]
        .date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("835_STATS","}|",format(run_dates->qual[d
        ].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = be.be_name, fac_name = uar_get_code_display(e.loc_facility_cd), fac_desc =
       uar_get_code_description(e.loc_facility_cd),
       sus_chrg = sum(c.item_extended_price), cnt = count(1)
       FROM charge c,
        pft_encntr pe,
        billing_entity be,
        encounter e
       PLAN (c
        WHERE c.process_flg=1
         AND c.active_ind=1)
        JOIN (pe
        WHERE c.encntr_id=pe.encntr_id)
        JOIN (be
        WHERE pe.billing_entity_id=be.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         snapshot_type = rc_snapshot_type,
         dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("SUS_CHRG","}|",format(run_dates->qual[d].
          date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",
         e.loc_facility_cd,"}|",fac_name,
         "}|",fac_desc,"}|",sus_chrg), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("SUS_CHRG","}|",format(run_dates->qual[d].
           date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA", dsr
         ->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("SUS_CHRG")
      CALL echo(build("835_STATS",curtime))
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), unposted_amt = sum(btf.trans_total_amount), batch_count
        = count(bt.batch_trans_id)
       FROM batch_trans bt,
        batch_trans_file btf,
        billing_entity be
       PLAN (bt
        WHERE bt.batch_status_cd=com_w_error_cd
         AND bt.batch_type_flag=3.0)
        JOIN (btf
        WHERE bt.batch_trans_id=btf.batch_trans_id
         AND btf.active_ind=1
         AND btf.nontrans_flag=1
         AND btf.error_status_cd IN (error_cd, lock_cd, 0.00))
        JOIN (be
        WHERE bt.billing_entity_id=be.billing_entity_id)
       GROUP BY be.be_name
       HEAD REPORT
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ELSE
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("835_STATS","}|",format(run_dates->qual[d].
          date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,
         "}|-1}|}|}|",unposted_amt,"}|",batch_count), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val
         = batch_count,
        dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
        stat_seq, ds_cnt = (ds_cnt+ 1),
        ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         IF (mod(ds_cnt,10)=1)
          stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
         ENDIF
         dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("835_STATS","}|",format(run_dates->qual[d]
           .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
         stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("835_STATS")
      SET ds_cnt2 = 0
     ENDIF
     FOR (tz_idx = 1 TO time_zones->tz_cnt)
       IF (curutc
        AND (time_zones->qual[tz_idx].tz_idx != 999))
        SET rec_tz->m_id = concat(trim(time_zones->qual[tz_idx].tz_name),char(0))
        SET stat = uar_datesettimezone(rec_tz)
        SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
        SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
        IF (((pqi_row_cnt > 10000000.00) OR ((run_dates->qual[d].re_run=1))) )
         SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
         SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("RTB_24_HOUR","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
        ELSE
         SET ds_cnt2 = 0
         SELECT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd),
          rtb_24_hour = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due *
            - (1)))), cnt = count(1)
          FROM pft_queue_item pqi,
           bo_hp_reltn bh,
           pft_proration pp,
           benefit_order bo,
           pft_encntr pe,
           billing_entity be,
           encounter e
          PLAN (pqi
           WHERE pqi.pft_entity_status_cd IN (rtb_sp_cd, rtb_ins_cd)
            AND pqi.pft_entity_type_cd IN (ins_cd, selfpay_cd)
            AND pqi.active_ind=1
            AND datetimediff(cnvtdatetime(ds_begin_snapshot),pqi.beg_effective_dt_tm) > 1)
           JOIN (bh
           WHERE pqi.bo_hp_reltn_id=bh.bo_hp_reltn_id)
           JOIN (pp
           WHERE bh.bo_hp_reltn_id=pp.bo_hp_reltn_id
            AND pp.active_ind=1)
           JOIN (bo
           WHERE bh.benefit_order_id=bo.benefit_order_id)
           JOIN (pe
           WHERE bo.pft_encntr_id=pe.pft_encntr_id)
           JOIN (be
           WHERE pe.billing_entity_id=be.billing_entity_id
            AND be.billing_entity_id IN (
           (SELECT
            be1.billing_entity_id
            FROM billing_entity be1,
             location l,
             time_zone_r tzr
            WHERE be1.active_ind=true
             AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND l.organization_id=be1.organization_id
             AND l.location_type_cd=222_facility
             AND l.active_ind=true
             AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND tzr.parent_entity_id=l.location_cd
             AND tzr.parent_entity_name="LOCATION"
             AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id
            AND e.active_ind=1
            AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          GROUP BY be.be_name, e.loc_facility_cd
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          DETAIL
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("RTB_24_HOUR","}|",format(run_dates->
             qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
            be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",rtb_24_hour), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("RTB_24_HOUR","}|",format(run_dates->
              qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("RTB_24_HOUR")
        ENDIF
        IF ((run_dates->qual[d].re_run=1))
         SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
         SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 4))
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLM_GEN_90_DAY","}|",format(run_dates
           ->qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(
           run_dates->qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGE_LAG","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("POS_COLL","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
        ELSE
         SET ds_cnt2 = 0
         SELECT DISTINCT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd)
          FROM bill_rec br,
           billing_entity be,
           bill_reltn brl,
           bo_hp_reltn bhp,
           benefit_order bo,
           pft_encntr pe,
           encounter e
          PLAN (br
           WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
            "0,D",ds_end_snapshot)
            AND br.bill_type_cd IN (1450_cd, 1500_cd)
            AND br.active_ind=1)
           JOIN (be
           WHERE be.billing_entity_id=br.billing_entity_id
            AND be.billing_entity_id IN (
           (SELECT
            be1.billing_entity_id
            FROM billing_entity be1,
             location l,
             time_zone_r tzr
            WHERE be1.active_ind=true
             AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND l.organization_id=be1.organization_id
             AND l.location_type_cd=222_facility
             AND l.active_ind=true
             AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND tzr.parent_entity_id=l.location_cd
             AND tzr.parent_entity_name="LOCATION"
             AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
           JOIN (brl
           WHERE brl.corsp_activity_id=br.corsp_activity_id
            AND brl.bill_vrsn_nbr IS NOT null)
           JOIN (bhp
           WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
            AND brl.parent_entity_name="BO_HP_RELTN")
           JOIN (bo
           WHERE bo.benefit_order_id=bhp.benefit_order_id)
           JOIN (pe
           WHERE pe.pft_encntr_id=bo.pft_encntr_id)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id)
          ORDER BY be.be_name, e.loc_facility_cd, br.corsp_activity_id
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          HEAD e.loc_facility_cd
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
          DETAIL
           null
          FOOT  e.loc_facility_cd
           CASE (br.balance_dr_cr_flag)
            OF 2:
             clm_gen_avg_bal = round(sum((br.balance * - (1.0))),2)
            OF 1:
             clm_gen_avg_bal = round(sum(br.balance),2)
           ENDCASE
           cnt = count(br.corsp_activity_id), dsr->qual[qualcnt].qual[ds_cnt].stat_name = build(
            "CLM_GEN_90_DAY","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt
           ].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",clm_gen_avg_bal),
           dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
           stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           ds_cnt = (ds_cnt+ 1), ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLM_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("CLM_GEN_90_DAY")
         SET ds_cnt2 = 0
         SELECT INTO "nl:"
          be_name = substring(1,50,be.be_name), stmt_gen_avg_cnt = sqlpassthru(
           "round(count(br.corsp_activity_id),2)",0), stmt_gen_avg_amt = sqlpassthru(
           "round(sum(case when br.balance_dr_cr_flag=2 then(br.balance*-1.0) else br.balance end),2)",
           0),
          cnt = count(1)
          FROM bill_rec br,
           billing_entity be
          WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
           "0,D",ds_end_snapshot)
           AND br.bill_type_cd=statement_cd
           AND br.active_ind=1
           AND br.billing_entity_id=be.billing_entity_id
           AND be.billing_entity_id IN (
          (SELECT
           be1.billing_entity_id
           FROM billing_entity be1,
            location l,
            time_zone_r tzr
           WHERE be1.active_ind=true
            AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND l.organization_id=be1.organization_id
            AND l.location_type_cd=222_facility
            AND l.active_ind=true
            AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
            AND tzr.parent_entity_id=l.location_cd
            AND tzr.parent_entity_name="LOCATION"
            AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name)))
          GROUP BY be.be_name
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          DETAIL
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
            be_name,"}|-1}|}|}|",stmt_gen_avg_amt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val
            = stmt_gen_avg_cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         SET ds_cnt2 = 0
         SELECT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd),
          stmt_gen_avg_amt = sqlpassthru(
           "round(sum(case when br.balance_dr_cr_flag=2 then(br.balance*-1.0) else br.balance end),2)",
           0), cnt = count(1)
          FROM bill_rec br,
           billing_entity be,
           bill_reltn brl,
           bo_hp_reltn bhp,
           benefit_order bo,
           pft_encntr pe,
           encounter e
          PLAN (br
           WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
            "0,D",ds_end_snapshot)
            AND br.bill_type_cd=statement_cd
            AND br.active_ind=1)
           JOIN (be
           WHERE be.billing_entity_id=br.billing_entity_id
            AND be.billing_entity_id IN (
           (SELECT
            be1.billing_entity_id
            FROM billing_entity be1,
             location l,
             time_zone_r tzr
            WHERE be1.active_ind=true
             AND be1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND l.organization_id=be1.organization_id
             AND l.location_type_cd=222_facility
             AND l.active_ind=true
             AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
             AND tzr.parent_entity_id=l.location_cd
             AND tzr.parent_entity_name="LOCATION"
             AND (tzr.time_zone=time_zones->qual[tz_idx].tz_name))))
           JOIN (brl
           WHERE brl.corsp_activity_id=br.corsp_activity_id
            AND brl.bill_vrsn_nbr IS NOT null
            AND brl.active_ind=1
            AND brl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND brl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (bhp
           WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
            AND brl.parent_entity_name="BO_HP_RELTN"
            AND bhp.active_ind=1
            AND bhp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND bhp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (bo
           WHERE bo.benefit_order_id=bhp.benefit_order_id
            AND bo.active_ind=1
            AND bo.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND bo.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (pe
           WHERE pe.pft_encntr_id=bo.pft_encntr_id
            AND pe.active_ind=1
            AND pe.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND pe.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id
            AND e.active_ind=1
            AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          GROUP BY be.be_name, e.loc_facility_cd
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          DETAIL
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
            be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",stmt_gen_avg_amt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val =
           cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("STMT_GEN_90_DAY")
        ENDIF
       ELSE
        IF (((pqi_row_cnt > 10000000.00) OR ((run_dates->qual[d].re_run=1))) )
         SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
         SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("RTB_24_HOUR","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
        ELSE
         SET ds_cnt2 = 0
         SELECT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd),
          rtb_24_hour = sum(evaluate(pp.curr_amount_dr_cr_flag,1,pp.curr_amt_due,(pp.curr_amt_due *
            - (1)))), cnt = count(1)
          FROM pft_queue_item pqi,
           bo_hp_reltn bh,
           pft_proration pp,
           benefit_order bo,
           pft_encntr pe,
           billing_entity be,
           encounter e
          PLAN (pqi
           WHERE pqi.pft_entity_status_cd IN (rtb_sp_cd, rtb_ins_cd)
            AND pqi.pft_entity_type_cd IN (ins_cd, selfpay_cd)
            AND pqi.active_ind=1
            AND datetimediff(cnvtdatetime(ds_begin_snapshot),pqi.beg_effective_dt_tm) > 1)
           JOIN (bh
           WHERE pqi.bo_hp_reltn_id=bh.bo_hp_reltn_id)
           JOIN (pp
           WHERE bh.bo_hp_reltn_id=pp.bo_hp_reltn_id
            AND pp.active_ind=1)
           JOIN (bo
           WHERE bh.benefit_order_id=bo.benefit_order_id)
           JOIN (pe
           WHERE bo.pft_encntr_id=pe.pft_encntr_id)
           JOIN (be
           WHERE pe.billing_entity_id=be.billing_entity_id)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id
            AND e.active_ind=1
            AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
            AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
          GROUP BY be.be_name, e.loc_facility_cd
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          DETAIL
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = "RTB_24_HOUR", dsr->qual[qualcnt].qual[ds_cnt]
           .stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",rtb_24_hour), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = "RTB_24_HOUR", dsr->qual[qualcnt].qual[ds_cnt
            ].stat_clob_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("RTB_24_HOUR")
        ENDIF
        IF ((run_dates->qual[d].re_run=1))
         SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
         SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 4))
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLM_GEN_90_DAY","}|",format(run_dates
           ->qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(
           run_dates->qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGE_LAG","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("POS_COLL","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
        ELSE
         SET ds_cnt2 = 0
         SELECT DISTINCT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd)
          FROM bill_rec br,
           billing_entity be,
           bill_reltn brl,
           bo_hp_reltn bhp,
           benefit_order bo,
           pft_encntr pe,
           encounter e
          PLAN (br
           WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
            "0,D",ds_end_snapshot)
            AND br.bill_type_cd IN (1450_cd, 1500_cd)
            AND br.active_ind=1)
           JOIN (be
           WHERE be.billing_entity_id=br.billing_entity_id)
           JOIN (brl
           WHERE brl.corsp_activity_id=br.corsp_activity_id
            AND brl.bill_vrsn_nbr IS NOT null)
           JOIN (bhp
           WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
            AND brl.parent_entity_name="BO_HP_RELTN")
           JOIN (bo
           WHERE bo.benefit_order_id=bhp.benefit_order_id)
           JOIN (pe
           WHERE pe.pft_encntr_id=bo.pft_encntr_id)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id)
          ORDER BY be.be_name, e.loc_facility_cd, br.corsp_activity_id
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          HEAD e.loc_facility_cd
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
          DETAIL
           null
          FOOT  e.loc_facility_cd
           CASE (br.balance_dr_cr_flag)
            OF 2:
             clm_gen_avg_bal = round(sum((br.balance * - (1.0))),2)
            OF 1:
             clm_gen_avg_bal = round(sum(br.balance),2)
           ENDCASE
           cnt = count(br.corsp_activity_id), dsr->qual[qualcnt].qual[ds_cnt].stat_name = build(
            "CLM_GEN_90_DAY","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt
           ].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",clm_gen_avg_bal),
           dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].
           stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
           ds_cnt = (ds_cnt+ 1), ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLM_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("CLM_GEN_90_DAY")
         CALL echo(build("STMT_GEN_90_DAY",curtime))
         SET ds_cnt2 = 0
         SELECT INTO "nl:"
          be_name = substring(1,50,be.be_name), stmt_gen_avg_cnt = sqlpassthru(
           "round(count(br.corsp_activity_id),2)",0), stmt_gen_avg_amt = sqlpassthru(
           "round(sum(case when br.balance_dr_cr_flag=2 then(br.balance*-1.0) else br.balance end),2)",
           0),
          cnt = count(1)
          FROM bill_rec br,
           billing_entity be
          WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
           "0,D",ds_end_snapshot)
           AND br.bill_type_cd=statement_cd
           AND br.active_ind=1
           AND br.billing_entity_id=be.billing_entity_id
          GROUP BY be.be_name
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          DETAIL
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
            be_name,"}|-1}|}|}|",stmt_gen_avg_amt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val
            = stmt_gen_avg_cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         SET ds_cnt2 = 0
         SELECT DISTINCT INTO "nl:"
          be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
          fac_desc = uar_get_code_description(e.loc_facility_cd)
          FROM bill_rec br,
           billing_entity be,
           bill_reltn brl,
           bo_hp_reltn bhp,
           benefit_order bo,
           pft_encntr pe,
           encounter e
          PLAN (br
           WHERE br.gen_dt_tm BETWEEN cnvtlookbehind("89,D",ds_begin_snapshot) AND cnvtlookbehind(
            "0,D",ds_end_snapshot)
            AND br.bill_type_cd=statement_cd
            AND br.active_ind=1)
           JOIN (be
           WHERE be.billing_entity_id=br.billing_entity_id)
           JOIN (brl
           WHERE brl.corsp_activity_id=br.corsp_activity_id
            AND brl.bill_vrsn_nbr IS NOT null)
           JOIN (bhp
           WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
            AND brl.parent_entity_name="BO_HP_RELTN")
           JOIN (bo
           WHERE bo.benefit_order_id=bhp.benefit_order_id
            AND bo.active_ind=1)
           JOIN (pe
           WHERE pe.pft_encntr_id=bo.pft_encntr_id)
           JOIN (e
           WHERE e.encntr_id=pe.encntr_id)
          ORDER BY be.be_name, e.loc_facility_cd, br.corsp_activity_id
          HEAD REPORT
           IF (ds_cnt=1)
            qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
            stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
            dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
           ENDIF
          HEAD e.loc_facility_cd
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ELSE
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
           ENDIF
          DETAIL
           null
          FOOT  e.loc_facility_cd
           CASE (br.balance_dr_cr_flag)
            OF 2:
             stmt_gen_avg_amt = round(sum((br.balance * - (1.0))),2)
            OF 1:
             stmt_gen_avg_amt = round(sum(br.balance),2)
           ENDCASE
           cnt = count(br.corsp_activity_id),
           CALL echo(build(be.be_name,"|",uar_get_code_display(e.loc_building_cd),"|",
            stmt_gen_avg_amt,
            "|",cnt))
           IF (mod(ds_cnt,10)=1)
            stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
           ENDIF
           dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
             ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
            be_name,"}|",e.loc_facility_cd,"}|",fac_name,
            "}|",fac_desc,"}|",stmt_gen_avg_amt), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val =
           cnt,
           dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
           stat_seq, ds_cnt = (ds_cnt+ 1),
           ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
          FOOT REPORT
           IF (ds_cnt2=0)
            IF (mod(ds_cnt,10)=1)
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
            ELSE
             stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
            ENDIF
            dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("STMT_GEN_90_DAY","}|",format(run_dates
              ->qual[d].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val =
            "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
            stat_seq = (stat_seq+ 1), ds_cnt = (ds_cnt+ 1)
           ENDIF
          WITH nullreport, nocounter
         ;end select
         CALL dsvm_error("STMT_GEN_90_DAY")
        ENDIF
       ENDIF
     ENDFOR
     CALL log_msg("Done with Multi Loop",logfile)
     CALL log_msg("Setting session timezone back to original value",logfile)
     SET stat = uar_datesettimezone(sessiontimezone)
     SET ds_cnt2 = 0
     SELECT INTO "nl:"
      ld.logical_domain_id, minutes = round(datetimediff(ost.end_effective_dt_tm,ost
        .beg_effective_dt_tm,4),0), job_name = ojs.step_name
      FROM ops_schedule_task ost,
       ops_task ot,
       ops_schedule_param osp,
       ops_job_step ojs,
       pft_event pe,
       logical_domain ld
      PLAN (ost
       WHERE ost.active_ind=1)
       JOIN (ot
       WHERE ost.ops_task_id=ot.ops_task_id
        AND ot.active_ind=1)
       JOIN (osp
       WHERE ot.ops_task_id=osp.ops_task_id
        AND osp.active_ind=1)
       JOIN (ojs
       WHERE osp.ops_job_step_id=ojs.ops_job_step_id
        AND ojs.active_ind=1
        AND ojs.step_name IN ("pft_extract_entities", "pft_load_datawharehouse",
       "pft_rel_pe_hold_event", "pft_process_crossover_claims", "pft_clm_gen_submit",
       "pft_wf_state_evaluation", "pft_post_to_rev", "pft_post_remittance_batch",
       "pft_process_gl_translog", "pft_gl_interface",
       "pft_stm_generation")
        AND ost.beg_effective_dt_tm >= cnvtdatetime(ds_begin_snapshot)
        AND ost.end_effective_dt_tm <= cnvtdatetime(ds_end_snapshot))
       JOIN (pe
       WHERE outerjoin(cnvtreal(trim(ojs.batch_selection)))=pe.pft_event_id
        AND pe.active_ind=outerjoin(1))
       JOIN (ld
       WHERE outerjoin(pe.logical_domain_id)=ld.logical_domain_id)
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
        dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
       ENDIF
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("OPS_JOB_AVG","}|",format(run_dates->qual[d]
         .date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(ld
        .logical_domain_id,"}|",minutes,"}|",job_name), dsr->qual[qualcnt].qual[ds_cnt].
       stat_number_val = ds_cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (ds_cnt2=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("OPS_JOB_AVG","}|",format(run_dates->qual[d
          ].date,"mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
        ds_cnt = (ds_cnt+ 1)
       ENDIF
      WITH nullreport, nocounter
     ;end select
     CALL dsvm_error("OPS_JOB_AVG")
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLAIM_AMT_CNT","}|",format(run_dates->
        qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       claim_amt = sum(evaluate(br.balance_dr_cr_flag,1,br.balance,2,(br.balance * - (1)),
         0.0)), claim_cnt = count(1)
       FROM bill_rec br,
        billing_entity be,
        bill_reltn brl,
        bo_hp_reltn bhp,
        benefit_order bo,
        pft_encntr pe,
        encounter e
       PLAN (br
        WHERE br.submit_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND br.bill_status_cd IN (cs18935_submitted_cd, cs18935_transmitted_cd,
        cs18935_transxovrpay_cd)
         AND br.bill_type_cd IN (1450_cd, 1500_cd)
         AND br.active_ind=1)
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.bill_vrsn_nbr IS NOT null
         AND brl.active_ind=1
         AND brl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND brl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        JOIN (bhp
        WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
         AND brl.parent_entity_name="BO_HP_RELTN")
        JOIN (bo
        WHERE bo.benefit_order_id=bhp.benefit_order_id)
        JOIN (pe
        WHERE pe.pft_encntr_id=bo.pft_encntr_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
        stat_name = build("CLAIM_AMT_CNT","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr
        ->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         fac_name,
         "}|",fac_desc,"}|",claim_amt),
        dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr->qual[qualcnt].qual[ds_cnt].
        stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
        ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq+ 1), ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("CLAIM_AMT_CNT","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr
         ->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("CLAIM_AMT_CNT")
      RECORD queryresults(
        1 bill_ent[*]
          2 bill_name = vc
          2 facility_cd = f8
          2 pos = f8
          2 tc = f8
          2 entries[*]
            3 financialencounterid = f8
            3 encdischdttm = dq8
            3 activityid = f8
            3 activitydttm = dq8
            3 ptrdrcrflag = i2
            3 billingentityid = f8
            3 transactionamt = f8
            3 pfttransreltnid = f8
            3 servicedttm = dq8
      ) WITH protect
      SELECT INTO "nl:"
       FROM pft_trans_reltn ptr,
        bo_hp_reltn bhr,
        pft_encntr pe,
        encounter e,
        billing_entity be
       PLAN (ptr
        WHERE ptr.beg_effective_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND ptr.trans_type_cd=cs18649_payment_cd
         AND trim(ptr.parent_entity_name,3)="PFTENCNTR"
         AND ptr.active_ind=true)
        JOIN (bhr
        WHERE bhr.bo_hp_reltn_id=ptr.benefit_order_id
         AND bhr.fin_class_cd=cs354_selfpay_cd)
        JOIN (pe
        WHERE pe.pft_encntr_id=ptr.parent_entity_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
        JOIN (be
        WHERE be.billing_entity_id=pe.billing_entity_id)
       ORDER BY be.billing_entity_id, e.loc_facility_cd, ptr.activity_id
       HEAD REPORT
        ds_cnt2 = 0, bcnt = 0
       HEAD e.loc_facility_cd
        sum_amount = 0.0, bcnt = (bcnt+ 1), stat = alterlist(queryresults->bill_ent,bcnt),
        queryresults->bill_ent[bcnt].bill_name = be.be_name, queryresults->bill_ent[bcnt].facility_cd
         = e.loc_facility_cd, entrycnt = 0
       HEAD ptr.activity_id
        entrycnt = (entrycnt+ 1), stat = alterlist(queryresults->bill_ent[bcnt].entries,entrycnt),
        queryresults->bill_ent[bcnt].entries[entrycnt].financialencounterid = pe.pft_encntr_id,
        queryresults->bill_ent[bcnt].entries[entrycnt].activitydttm = ptr.beg_effective_dt_tm,
        queryresults->bill_ent[bcnt].entries[entrycnt].ptrdrcrflag = ptr.dr_cr_flag, queryresults->
        bill_ent[bcnt].entries[entrycnt].transactionamt = ptr.amount,
        queryresults->bill_ent[bcnt].entries[entrycnt].encdischdttm = e.disch_dt_tm, queryresults->
        bill_ent[bcnt].entries[entrycnt].pfttransreltnid = ptr.pft_trans_reltn_id, queryresults->
        bill_ent[bcnt].entries[entrycnt].activityid = ptr.activity_id,
        ptr_amt = evaluate(ptr.dr_cr_flag,2,(ptr.amount * - (1)),ptr.amount), sum_amount = (
        sum_amount+ ptr_amt)
       FOOT  e.loc_facility_cd
        queryresults->bill_ent[bcnt].tc = sum_amount
       FOOT REPORT
        null
       WITH nocounter
      ;end select
      FOR (b = 1 TO size(queryresults->bill_ent,5))
        SET sum_amount = 0.0
        SELECT INTO "nl:"
         servicedttm = c.service_dt_tm
         FROM pft_trans_reltn ptr,
          pft_encntr pe,
          pft_charge pc,
          charge c
         PLAN (ptr
          WHERE expand(idx,1,size(queryresults->bill_ent[b].entries,5),ptr.activity_id,queryresults->
           bill_ent[b].entries[idx].activityid))
          JOIN (pe
          WHERE pe.pft_encntr_id=ptr.parent_entity_id)
          JOIN (pc
          WHERE pc.pft_encntr_id=pe.pft_encntr_id)
          JOIN (c
          WHERE c.charge_item_id=pc.charge_item_id
           AND c.active_ind=true
           AND c.charge_type_cd=cs13028_debit_cd
           AND c.offset_charge_item_id=0.0)
         ORDER BY ptr.activity_id, c.service_dt_tm DESC
         HEAD ptr.activity_id
          pos = locateval(idx,1,size(queryresults->bill_ent[b].entries,5),ptr.activity_id,
           queryresults->bill_ent[b].entries[idx].activityid), queryresults->bill_ent[b].entries[pos]
          .servicedttm = c.service_dt_tm, basedate = cnvtdate(datetimeadd(ds_begin_snapshot,- (7)))
          IF (((cnvtdatetime(basedate,0) <= cnvtdatetime(cnvtdate(c.service_dt_tm),0)
           AND c.service_dt_tm > 0) OR (((servicedttm=0
           AND (queryresults->bill_ent[b].entries[pos].encdischdttm >= cnvtdatetime(ds_begin_snapshot,
           0))
           AND (queryresults->bill_ent[b].entries[pos].encdischdttm >= cnvtdatetime(basedate,0))) OR
          ((queryresults->bill_ent[b].entries[pos].servicedttm=0)
           AND (queryresults->bill_ent[b].entries[pos].encdischdttm=0))) )) )
           amount = evaluate(queryresults->bill_ent[b].entries[pos].ptrdrcrflag,2,(queryresults->
            bill_ent[b].entries[pos].transactionamt * - (1)),queryresults->bill_ent[b].entries[pos].
            transactionamt), sum_amount = (sum_amount+ amount)
          ENDIF
         WITH nocounter, expand = 1
        ;end select
        SET queryresults->bill_ent[b].pos = sum_amount
        IF (ds_cnt=1)
         SET qualcnt = (qualcnt+ 1)
         SET stat = alterlist(dsr->qual,qualcnt)
         SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot)
         SET dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
        SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
        SET pos_coll = ((queryresults->bill_ent[b].pos/ queryresults->bill_ent[b].tc) * 100)
        SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("POS_COLL","}|",format(run_dates->qual[
          d].date,"mm/dd/yyyy;;d"))
        SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(queryresults->bill_ent[b].bill_name,
         "}|",queryresults->bill_ent[b].facility_cd,"}|",uar_get_code_display(queryresults->bill_ent[
          b].facility_cd),
         "}|",uar_get_code_description(queryresults->bill_ent[b].facility_cd),"}|",queryresults->
         bill_ent[b].pos,"}|",
         queryresults->bill_ent[b].tc)
        SET dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1
        SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
        SET ds_cnt = (ds_cnt+ 1)
        SET ds_cnt2 = (ds_cnt2+ 1)
        SET stat_seq = (stat_seq+ 1)
        IF (ds_cnt2=0)
         SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("POS_COLL","}|",format(run_dates->
           qual[d].date,"mm/dd/yyyy;;d"))
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
         SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
         SET stat_seq = (stat_seq+ 1)
         SET ds_cnt = (ds_cnt+ 1)
        ENDIF
      ENDFOR
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd)
       FROM charge c,
        pft_charge pc,
        billing_entity be,
        encounter e
       PLAN (c
        WHERE c.posted_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
         )
         AND c.posted_cd IS NOT null)
        JOIN (pc
        WHERE pc.charge_item_id=c.charge_item_id)
        JOIN (be
        WHERE be.billing_entity_id=pc.billing_entity_id)
        JOIN (e
        WHERE e.encntr_id=c.encntr_id
         AND e.active_ind=1
         AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       ORDER BY be.billing_entity_id, e.loc_facility_cd, c.charge_item_id
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       HEAD e.loc_facility_cd
        charge_lag = 0.00, sum_min = 0.00, ccnt = 0
       HEAD c.charge_item_id
        minutes = datetimediff(c.posted_dt_tm,c.service_dt_tm,4), sum_min = (sum_min+ minutes), ccnt
         = (ccnt+ 1)
       FOOT  e.loc_facility_cd
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), charge_lag = ((sum_min/ ccnt)/ 1440),
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CHARGE_LAG","}|",format(run_dates->qual[d]
          .date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         uar_get_code_display(e.loc_facility_cd),
         "}|",uar_get_code_description(e.loc_facility_cd),"}|",sum_min,"}|",
         ccnt), dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = stat_seq,
        ds_cnt = (ds_cnt+ 1), ds_cnt2 = (ds_cnt2+ 1), stat_seq = (stat_seq+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("CHARGE_LAG","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")), dsr->
         qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("CHARGE_LAG")
      SET ds_cnt2 = 0
     ENDIF
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_SUBMITTED_CLAIM_COUNT",
       "}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), claim_cnt = count(br.corsp_activity_id)
       FROM bill_rec br,
        billing_entity be
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.submit_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
         )
         AND br.bill_type_cd IN (1450_cd, 1500_cd)
         AND br.active_ind=1)
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
       GROUP BY be.be_name
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_SUBMITTED_CLAIM_COUNT","}|",format(
          run_dates->qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|-1}|}|}|",count), dsr->qual[
        qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_type
         = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("NON_CANCELLED_SUBMITTED_CLAIM_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       claim_cnt = count(br.corsp_activity_id)
       FROM bill_rec br,
        billing_entity be,
        bill_reltn brl,
        bo_hp_reltn bhp,
        benefit_order bo,
        pft_encntr pe,
        encounter e
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.submit_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot
         )
         AND br.bill_type_cd IN (1450_cd, 1500_cd)
         AND br.active_ind=1)
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.bill_vrsn_nbr IS NOT null
         AND brl.active_ind=1
         AND brl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND brl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        JOIN (bhp
        WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
         AND brl.parent_entity_name="BO_HP_RELTN")
        JOIN (bo
        WHERE bo.benefit_order_id=bhp.benefit_order_id)
        JOIN (pe
        WHERE pe.pft_encntr_id=bo.pft_encntr_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_SUBMITTED_CLAIM_COUNT","}|",format(
          run_dates->qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         fac_name,
         "}|",fac_desc,"}|",count), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr
        ->qual[qualcnt].qual[ds_cnt].stat_type = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("NON_CANCELLED_SUBMITTED_CLAIM_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("NON_CANCELLED_SUBMITTED_CLAIM_COUNT")
     ENDIF
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("CLEAN_CLAIM_COUNT","}|",format(run_dates
        ->qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT
       be_name = substring(1,50,be.be_name), claim_cnt = count(br2.corsp_activity_id)
       FROM bill_rec br,
        bill_reltn brl,
        bill_rec br2,
        billing_entity be
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.submit_dt_tm != null
         AND br.bill_type_cd IN (1450_cd, 1500_cd)
         AND br.active_ind=1
         AND br.transmission_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot))
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN")
        JOIN (br2
        WHERE br2.corsp_activity_id=brl.corsp_activity_id
         AND (br2.submit_dt_tm=
        (SELECT
         min(subbr.submit_dt_tm)
         FROM bill_rec subbr,
          bill_reltn subbrl
         WHERE subbrl.parent_entity_id=brl.parent_entity_id
          AND subbrl.corsp_activity_id=subbr.corsp_activity_id
         GROUP BY subbrl.parent_entity_id)))
        JOIN (be
        WHERE be.billing_entity_id=br2.billing_entity_id)
       GROUP BY be.be_name
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("CLEAN_CLAIM_COUNT","}|",format(run_dates->qual[d].
          date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|-1}|}|}|",count), dsr->qual[
        qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_type
         = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("CLEAN_CLAIM_COUNT","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      SET ds_cnt2 = 0
      SELECT
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       claim_cnt = count(br2.corsp_activity_id)
       FROM bill_rec br,
        bill_reltn brl,
        bill_rec br2,
        billing_entity be,
        bo_hp_reltn bhp,
        benefit_order bo,
        pft_encntr pe,
        encounter e
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.submit_dt_tm != null
         AND br.bill_type_cd IN (1450_cd, 1500_cd)
         AND br.active_ind=1
         AND br.transmission_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot))
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN")
        JOIN (br2
        WHERE br2.corsp_activity_id=brl.corsp_activity_id
         AND (br2.submit_dt_tm=
        (SELECT
         min(subbr.submit_dt_tm)
         FROM bill_rec subbr,
          bill_reltn subbrl
         WHERE subbrl.parent_entity_id=brl.parent_entity_id
          AND subbrl.corsp_activity_id=subbr.corsp_activity_id
         GROUP BY subbrl.parent_entity_id)))
        JOIN (be
        WHERE be.billing_entity_id=br2.billing_entity_id)
        JOIN (bhp
        WHERE bhp.bo_hp_reltn_id=brl.parent_entity_id
         AND brl.parent_entity_name="BO_HP_RELTN")
        JOIN (bo
        WHERE bo.benefit_order_id=bhp.benefit_order_id)
        JOIN (pe
        WHERE pe.pft_encntr_id=bo.pft_encntr_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("CLEAN_CLAIM_COUNT","}|",format(run_dates->qual[d].
          date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         fac_name,
         "}|",fac_desc,"}|",count), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr
        ->qual[qualcnt].qual[ds_cnt].stat_type = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("CLEAN_CLAIM_COUNT","}|",format(run_dates->qual[d].date,"mm/dd/yyyy;;d")),
         dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("CLEAN_CLAIM_COUNT")
     ENDIF
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_CLAIM_COUNT","}|",format(
        run_dates->qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), claim_cnt = count(DISTINCT br.corsp_activity_id)
       FROM bill_rec br,
        bill_reltn brl,
        bo_hp_reltn bhr,
        batch_trans_file btf,
        batch_trans bt,
        billing_entity be
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.active_ind=1)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN"
         AND brl.active_ind=1)
        JOIN (bhr
        WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
         AND  NOT (bhr.reltn_type_cd IN (cs4002034_ime_billing)))
        JOIN (btf
        WHERE btf.corsp_activity_id=br.corsp_activity_id
         AND btf.active_ind=1)
        JOIN (bt
        WHERE bt.batch_trans_id=btf.batch_trans_id
         AND bt.submitted_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND bt.active_ind=1
         AND (bt.submitted_dt_tm=
        (SELECT
         min(subbt.submitted_dt_tm)
         FROM batch_trans subbt,
          batch_trans_file subbtf
         WHERE subbtf.corsp_activity_id=btf.corsp_activity_id
          AND subbtf.batch_trans_id=subbt.batch_trans_id
          AND subbt.submitted_dt_tm <= cnvtdatetime(ds_end_snapshot)
          AND subbt.active_ind=1)))
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
       GROUP BY be.be_name
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_CLAIM_COUNT","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|-1}|}|}|",count), dsr->qual[
        qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_type
         = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("NON_CANCELLED_CLAIM_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       claim_cnt = count(DISTINCT br.corsp_activity_id)
       FROM bill_rec br,
        bill_reltn brl,
        bo_hp_reltn bhr,
        batch_trans_file btf,
        batch_trans bt,
        billing_entity be,
        benefit_order bo,
        pft_encntr pe,
        encounter e
       PLAN (br
        WHERE  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.active_ind=1)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN"
         AND brl.active_ind=1)
        JOIN (bhr
        WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
         AND  NOT (bhr.reltn_type_cd IN (cs4002034_ime_billing)))
        JOIN (btf
        WHERE btf.corsp_activity_id=br.corsp_activity_id
         AND btf.active_ind=1)
        JOIN (bt
        WHERE bt.batch_trans_id=btf.batch_trans_id
         AND bt.submitted_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND bt.active_ind=1
         AND (bt.submitted_dt_tm=
        (SELECT
         min(subbt.submitted_dt_tm)
         FROM batch_trans subbt,
          batch_trans_file subbtf
         WHERE subbtf.corsp_activity_id=btf.corsp_activity_id
          AND subbtf.batch_trans_id=subbt.batch_trans_id
          AND subbt.submitted_dt_tm <= cnvtdatetime(ds_end_snapshot)
          AND subbt.active_ind=1)))
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
        JOIN (bo
        WHERE bo.benefit_order_id=bhr.benefit_order_id)
        JOIN (pe
        WHERE pe.pft_encntr_id=bo.pft_encntr_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(claim_cnt), dsr->qual[
        qualcnt].qual[ds_cnt].stat_name = build("NON_CANCELLED_CLAIM_COUNT","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         fac_name,
         "}|",fac_desc,"}|",count), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = claim_cnt, dsr
        ->qual[qualcnt].qual[ds_cnt].stat_type = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("NON_CANCELLED_CLAIM_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("NON_CANCELLED_CLAIM_COUNT")
     ENDIF
     IF ((run_dates->qual[d].re_run=1))
      SET ds_cnt = size(dsr->qual[qualcnt].qual,5)
      SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2))
      SET ds_cnt = (ds_cnt+ 1)
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = build("TECHNICAL_DENIAL_COUNT","}|",format(
        run_dates->qual[d].date,"mm/dd/yyyy;;d"))
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA"
      SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
      SET stat_seq = (stat_seq+ 1)
      SET ds_cnt = (ds_cnt+ 1)
     ELSE
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), denial_cnt = count(DISTINCT d.corsp_activity_id)
       FROM denial d,
        bill_rec br,
        bill_reltn brl,
        bo_hp_reltn bhr,
        billing_entity be
       PLAN (d
        WHERE d.denial_type_cd IN (cs29904_technical_denial)
         AND d.beg_effective_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND d.active_ind=1)
        JOIN (br
        WHERE br.corsp_activity_id=d.corsp_activity_id
         AND  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.active_ind=1)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN"
         AND brl.active_ind=1)
        JOIN (bhr
        WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
         AND  NOT (bhr.reltn_type_cd IN (cs4002034_ime_billing)))
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
       GROUP BY be.be_name
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(denial_cnt), dsr->
        qual[qualcnt].qual[ds_cnt].stat_name = build("TECHNICAL_DENIAL_COUNT","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|-1}|}|}|",count), dsr->qual[
        qualcnt].qual[ds_cnt].stat_number_val = denial_cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_type
         = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("TECHNICAL_DENIAL_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      SET ds_cnt2 = 0
      SELECT INTO "nl:"
       be_name = substring(1,50,be.be_name), fac_name = uar_get_code_display(e.loc_facility_cd),
       fac_desc = uar_get_code_description(e.loc_facility_cd),
       denial_cnt = count(DISTINCT d.corsp_activity_id)
       FROM denial d,
        bill_rec br,
        bill_reltn brl,
        bo_hp_reltn bhr,
        billing_entity be,
        benefit_order bo,
        pft_encntr pe,
        encounter e
       PLAN (d
        WHERE d.denial_type_cd IN (cs29904_technical_denial)
         AND d.beg_effective_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(
         ds_end_snapshot)
         AND d.active_ind=1)
        JOIN (br
        WHERE br.corsp_activity_id=d.corsp_activity_id
         AND  NOT (br.bill_status_cd IN (cs18935_canceled_cd))
         AND br.active_ind=1)
        JOIN (brl
        WHERE brl.corsp_activity_id=br.corsp_activity_id
         AND brl.parent_entity_name="BO_HP_RELTN"
         AND brl.active_ind=1)
        JOIN (bhr
        WHERE bhr.bo_hp_reltn_id=brl.parent_entity_id
         AND  NOT (bhr.reltn_type_cd IN (cs4002034_ime_billing)))
        JOIN (be
        WHERE be.billing_entity_id=br.billing_entity_id)
        JOIN (bo
        WHERE bo.benefit_order_id=bhr.benefit_order_id)
        JOIN (pe
        WHERE pe.pft_encntr_id=bo.pft_encntr_id)
        JOIN (e
        WHERE e.encntr_id=pe.encntr_id)
       GROUP BY be.be_name, e.loc_facility_cd
       HEAD REPORT
        ds_cnt2 = 0
        IF (ds_cnt=1)
         qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
         stat_snap_dt_tm = cnvtdatetime(ds_domain_begin_snapshot),
         dsr->qual[qualcnt].snapshot_type = rc_snapshot_type
        ENDIF
       DETAIL
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1)), count = cnvtint(denial_cnt), dsr->
        qual[qualcnt].qual[ds_cnt].stat_name = build("TECHNICAL_DENIAL_COUNT","}|",format(run_dates->
          qual[d].date,"mm/dd/yyyy;;d")),
        dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(be_name,"}|",e.loc_facility_cd,"}|",
         fac_name,
         "}|",fac_desc,"}|",count), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = denial_cnt, dsr
        ->qual[qualcnt].qual[ds_cnt].stat_type = 1,
        dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (
        stat_seq+ 1),
        ds_cnt2 = (ds_cnt2+ 1)
       FOOT REPORT
        IF (ds_cnt2=0)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 2)), dsr->qual[qualcnt].qual[ds_cnt].
         stat_name = build("TECHNICAL_DENIAL_COUNT","}|",format(run_dates->qual[d].date,
           "mm/dd/yyyy;;d")), dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = "NO_NEW_DATA",
         dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, stat_seq = (stat_seq+ 1), ds_cnt = (
         ds_cnt+ 1)
        ENDIF
       WITH nullreport, nocounter
      ;end select
      CALL dsvm_error("TECHNICAL_DENIAL_COUNT")
     ENDIF
     IF ((run_dates->qual[d].re_run=1))
      CALL echo("update rerun")
      CALL echo(run_dates->qual[d].date)
      CALL echo(cnvtdate(run_dates->qual[d].date))
      CALL echo(format(run_dates->qual[d].date,"mm/dd/yyyy;;d"))
      UPDATE  FROM dm_info di
       SET di.updt_cnt = 1
       WHERE di.info_date=cnvtdatetime(run_dates->qual[d].date)
        AND di.info_name="RE_RUN"
        AND di.info_domain="REV_CYC_PARENT*"
       WITH nocounter
      ;end update
      COMMIT
     ENDIF
   ENDFOR
   CALL log_msg("Running Load Script",logfile)
   EXECUTE dm_stat_snaps_load
   CALL log_msg("Running Export",logfile)
   EXECUTE dm_stat_export_snapshot rc_snapshot_type, 133
   CALL log_msg("Finished Export",logfile)
   SET qualcnt = 0
   CALL log_msg("End Main Logic",logfile)
  ELSE
   CALL log_msg("Ops Job Not Done",logfile)
  ENDIF
 ELSE
  CALL log_msg("Already Ran",logfile)
 ENDIF
 CALL log_msg("EndSession",logfile)
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
  ENDIF
 END ;Subroutine
 SUBROUTINE getdebugrow(x)
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE info_domain="DM_STAT_REV_CYC_DEBUG"
    AND info_name="DEBUG_IND"
   DETAIL
    debug_msg_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_domain = "DM_STAT_REV_CYC_DEBUG", info_name = "DEBUG_IND", info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
   SET debug_msg_ind = 0
   CALL log_msg("Creating DM_INFO row",logfile)
  ENDIF
 END ;Subroutine
 SUBROUTINE log_msg(logmsg,sbr_dlogfile)
   IF (debug_msg_ind=1)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1,
      dm_eproc_length = textlen(logmsg)
     DETAIL
      IF (logmsg="BeginSession")
       row + 1, "Script Begins:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSEIF (logmsg="EndSession")
       row + 1, "Script Ends:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSE
       dm_txt = substring(beg_pos,end_pos,logmsg)
       WHILE (not_done=1)
         row + 1, col 0, dm_txt,
         row + 1, curdate"mm/dd/yyyy;;d", " ",
         curtime3"hh:mm:ss;3;m"
         IF (end_pos > dm_eproc_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,logmsg)
         ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
   ENDIF
 END ;Subroutine
#exit_program
END GO
