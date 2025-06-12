CREATE PROGRAM dm_stat_gather_sou:dba
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
 SET start_time = sysdate
 SET start_time2 = sysdate
 DECLARE stat = i4
 DECLARE rad_qual_cnt = i4
 DECLARE rad_tot_cnt = i4
 DECLARE rad_tot_can_cnt = i4
 DECLARE ystartdate = q8
 DECLARE last_day_last_month = q8
 DECLARE error_msg = vc
 DECLARE mn_debug_ind = i2
 DECLARE md_start_timer = dq8
 DECLARE md_end_timer = dq8
 DECLARE md_start_total_timer = dq8
 DECLARE md_end_total_timer = dq8
 DECLARE sbr_debug_timer(ms_input_mode=vc,ms_input_str=vc) = null
 DECLARE sbr_check_debug(null) = null
 CALL sbr_check_debug(null)
 CALL sbr_debug_timer("START_TOTAL","DM_STAT_GATHER_SOU")
 IF (month(curdate)=1)
  SET ystartdate = cnvtdatetime(concat("01-JAN-",trim(cnvtstring((year(curdate) - 1)),3)," 00:00:00")
   )
 ELSE
  SET ystartdate = cnvtdatetime(concat("01-JAN-",trim(cnvtstring(year(curdate)),3)," 00:00:00"))
 ENDIF
 SET last_day_last_month = cnvtdatetime(datetimeadd(cnvtdatetime(datetimefind(cnvtdatetime(curdate,0),
     "M","B","E")),- (1)))
 SET stat = alterlist(dsr->qual,1)
 SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(last_day_last_month)
 SET dsr->qual[1].snapshot_type = "MONTHLY_VOLUME"
 SET stat = alterlist(dsr->qual[1].qual,5)
 SET dsr->qual[1].qual[1].stat_name = "DISTINCT_PWRCHRT_USERS"
 SET dsr->qual[1].qual[1].stat_type = 1
 SET dsr->qual[1].qual[2].stat_name = "DISTINCT_CARENET_USERS"
 SET dsr->qual[1].qual[2].stat_type = 1
 SET dsr->qual[1].qual[3].stat_name = "DISTINCT_PCO_USERS"
 SET dsr->qual[1].qual[3].stat_type = 1
 SET dsr->qual[1].qual[4].stat_name = "DISTINCT_PWRVISION_USERS"
 SET dsr->qual[1].qual[4].stat_type = 1
 SET dsr->qual[1].qual[5].stat_name = "DISTINCT_PROFILE_USERS"
 SET dsr->qual[1].qual[5].stat_type = 1
 CALL sbr_debug_timer("START","FIRST QUERY")
 SELECT INTO "nl:"
  num_users = count(DISTINCT oac.person_id)
  FROM omf_app_ctx_day_st oac
  PLAN (oac
   WHERE oac.person_id > 0
    AND oac.application_number IN (600005, 950001, 1120000, 1120014, 1120016,
   1120033, 961000)
    AND oac.start_day >= cnvtdatetime(ystartdate)
    AND oac.start_day <= cnvtdatetime(last_day_last_month))
  GROUP BY oac.application_number
  DETAIL
   CASE (oac.application_number)
    OF 600005:
     dsr->qual[1].qual[1].stat_number_val = num_users,dsr->qual[1].qual[2].stat_number_val =
     num_users
    OF 950001:
     dsr->qual[1].qual[4].stat_number_val = num_users
    OF 961000:
     dsr->qual[1].qual[3].stat_number_val = num_users
    ELSE
     dsr->qual[1].qual[5].stat_number_val = (dsr->qual[1].qual[5].stat_number_val+ num_users)
   ENDCASE
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","FIRST QUERY")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 SET del_cd = uar_get_code_by("MEANING",6004,"DELETED")
 SET can_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 CALL sbr_debug_timer("START","SECOND QUERY")
 SELECT INTO "nl:"
  num_rows = count(*), actdisp = uar_get_code_display(o.activity_type_cd), actcdf =
  uar_get_code_meaning(o.activity_type_cd),
  o.activity_type_cd
  FROM order_radiology orad,
   orders o
  PLAN (orad
   WHERE orad.request_dt_tm >= cnvtdatetime(ystartdate)
    AND orad.request_dt_tm <= cnvtdatetime(last_day_last_month))
   JOIN (o
   WHERE o.order_id=orad.order_id)
  GROUP BY o.activity_type_cd, o.order_status_cd
  ORDER BY o.activity_type_cd
  HEAD REPORT
   rad_qual_cnt = 0, rad_tot_cnt = 0, rad_tot_can_cnt = 0
  HEAD o.activity_type_cd
   rad_qual_cnt = (rad_qual_cnt+ 2)
   IF (mod(rad_qual_cnt,20)=2)
    stat = alterlist(dsr->qual[1].qual,(rad_qual_cnt+ 25))
   ENDIF
   dsr->qual[1].qual[(rad_qual_cnt+ 4)].stat_name = concat("RADNET_",trim(actdisp),"_",trim(actcdf),
    "_TOTAL"), dsr->qual[1].qual[(rad_qual_cnt+ 4)].stat_type = 1, dsr->qual[1].qual[(rad_qual_cnt+ 5
   )].stat_name = concat("RADNET_",trim(actdisp),"_",trim(actcdf),"_CANCEL"),
   dsr->qual[1].qual[(rad_qual_cnt+ 5)].stat_type = 1
  DETAIL
   dsr->qual[1].qual[(rad_qual_cnt+ 4)].stat_number_val = (dsr->qual[1].qual[(rad_qual_cnt+ 4)].
   stat_number_val+ num_rows), rad_tot_cnt = (rad_tot_cnt+ num_rows)
   IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
    dsr->qual[1].qual[(rad_qual_cnt+ 5)].stat_number_val = (dsr->qual[1].qual[(rad_qual_cnt+ 5)].
    stat_number_val+ num_rows), rad_tot_can_cnt = (rad_tot_can_cnt+ num_rows)
   ENDIF
  FOOT  o.activity_type_cd
   row + 0
  FOOT REPORT
   rad_qual_cnt = (rad_qual_cnt+ 2), stat = alterlist(dsr->qual[1].qual,(rad_qual_cnt+ 5)), dsr->
   qual[1].qual[(rad_qual_cnt+ 4)].stat_name = concat("RADNET_TOTAL"),
   dsr->qual[1].qual[(rad_qual_cnt+ 4)].stat_type = 1, dsr->qual[1].qual[(rad_qual_cnt+ 4)].
   stat_number_val = rad_tot_cnt, dsr->qual[1].qual[(rad_qual_cnt+ 5)].stat_name = concat(
    "RADNET_TOTAL_CANCEL"),
   dsr->qual[1].qual[(rad_qual_cnt+ 5)].stat_type = 1, dsr->qual[1].qual[(rad_qual_cnt+ 5)].
   stat_number_val = rad_tot_can_cnt
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","SECOND QUERY")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 SET qual_size = (size(dsr->qual[1].qual,5)+ 4)
 SET stat = alterlist(dsr->qual[1].qual,qual_size)
 SET dsr->qual[1].qual[(qual_size - 3)].stat_name = concat("PHARMNET_TOTAL_INPATIENT")
 SET dsr->qual[1].qual[(qual_size - 3)].stat_type = 1
 SET dsr->qual[1].qual[(qual_size - 2)].stat_name = concat("PHARMNET_CANCEL_INPATIENT")
 SET dsr->qual[1].qual[(qual_size - 2)].stat_type = 1
 SET dsr->qual[1].qual[(qual_size - 1)].stat_name = concat("PHARMNET_TOTAL_RETAIL")
 SET dsr->qual[1].qual[(qual_size - 1)].stat_type = 1
 SET dsr->qual[1].qual[qual_size].stat_name = concat("PHARMNET_CANCEL_RETAIL")
 SET dsr->qual[1].qual[qual_size].stat_type = 1
 CALL sbr_debug_timer("START","THIRD QUERY")
 SELECT INTO "nl:"
  num_rows = count(*)
  FROM order_dispense od,
   orders o
  PLAN (od
   WHERE od.updt_dt_tm >= cnvtdatetime(ystartdate))
   JOIN (o
   WHERE o.order_id=od.order_id
    AND o.orig_ord_as_flag IN (0, 1, 4)
    AND o.orig_order_dt_tm >= cnvtdatetime(ystartdate)
    AND o.orig_order_dt_tm <= cnvtdatetime(last_day_last_month))
  GROUP BY o.orig_ord_as_flag, o.order_status_cd
  DETAIL
   IF (o.orig_ord_as_flag IN (0, 4))
    dsr->qual[1].qual[(qual_size - 3)].stat_number_val = (dsr->qual[1].qual[(qual_size - 3)].
    stat_number_val+ num_rows)
    IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
     dsr->qual[1].qual[(qual_size - 2)].stat_number_val = (dsr->qual[1].qual[(qual_size - 2)].
     stat_number_val+ num_rows)
    ENDIF
   ENDIF
   IF (o.orig_ord_as_flag=1)
    dsr->qual[1].qual[(qual_size - 1)].stat_number_val = (dsr->qual[1].qual[(qual_size - 1)].
    stat_number_val+ num_rows)
    IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
     dsr->qual[1].qual[qual_size].stat_number_val = (dsr->qual[1].qual[qual_size].stat_number_val+
     num_rows)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","THIRD QUERY")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 CALL sbr_debug_timer("START","FOURTH")
 SELECT INTO "nl:"
  num_rows = count(*), actdisp = uar_get_code_display(o.activity_type_cd), actcdf =
  uar_get_code_meaning(o.activity_type_cd),
  o.activity_type_cd
  FROM order_laboratory ol,
   orders o
  PLAN (ol
   WHERE ol.updt_dt_tm >= cnvtdatetime(ystartdate)
    AND ol.updt_dt_tm <= cnvtdatetime(last_day_last_month))
   JOIN (o
   WHERE o.order_id=ol.order_id)
  GROUP BY o.activity_type_cd, o.order_status_cd
  ORDER BY o.activity_type_cd
  HEAD REPORT
   qual_size = size(dsr->qual[1].qual,5), lab_total_ord_cnt = 0, lab_total_can_cnt = 0
  HEAD o.activity_type_cd
   qual_size = (qual_size+ 2)
   IF (qual_size > size(dsr->qual[1].qual,5))
    stat = alterlist(dsr->qual[1].qual,(qual_size+ 18))
   ENDIF
   dsr->qual[1].qual[(qual_size - 1)].stat_name = concat("PATHNET_TOTAL_",trim(actdisp),"_",trim(
     actcdf)), dsr->qual[1].qual[(qual_size - 1)].stat_type = 1, dsr->qual[1].qual[qual_size].
   stat_name = concat("PATHNET_CANCEL_",trim(actdisp),"_",trim(actcdf)),
   dsr->qual[1].qual[qual_size].stat_type = 1
  DETAIL
   dsr->qual[1].qual[(qual_size - 1)].stat_number_val = (dsr->qual[1].qual[(qual_size - 1)].
   stat_number_val+ num_rows), lab_total_ord_cnt = (lab_total_ord_cnt+ num_rows)
   IF (((o.order_status_cd=can_cd) OR (o.order_status_cd=del_cd)) )
    dsr->qual[1].qual[qual_size].stat_number_val = (dsr->qual[1].qual[qual_size].stat_number_val+
    num_rows), lab_total_can_cnt = (lab_total_can_cnt+ num_rows)
   ENDIF
  FOOT  o.activity_type_cd
   row + 0
  FOOT REPORT
   qual_size = (qual_size+ 2), stat = alterlist(dsr->qual[1].qual,qual_size), dsr->qual[1].qual[(
   qual_size - 1)].stat_name = concat("PATHNET_TOTAL"),
   dsr->qual[1].qual[(qual_size - 1)].stat_type = 1, dsr->qual[1].qual[(qual_size - 1)].
   stat_number_val = lab_total_ord_cnt, dsr->qual[1].qual[qual_size].stat_name = concat(
    "PATHNET_TOTAL_CANCEL"),
   dsr->qual[1].qual[qual_size].stat_type = 1, dsr->qual[1].qual[qual_size].stat_number_val =
   lab_total_can_cnt
  WITH nocounter
 ;end select
 CALL sbr_debug_timer("END","FOURTH QUERY")
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 EXECUTE dm_stat_snaps_load
 CALL sbr_debug_timer("END_TOTAL","DM_STAT_GATHER_SOU")
 CALL echorecord(dsr)
 SUBROUTINE sbr_debug_timer(ms_input_mode,ms_input_str)
   IF (mn_debug_ind=1)
    CASE (ms_input_mode)
     OF "START":
      SET md_start_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END":
      SET md_end_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Ending timer for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_timer,md_start_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_timer = 0
      SET md_end_timer = 0
     OF "START_TOTAL":
      SET md_start_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" Starting total timer for: ",ms_input_str))
      CALL echo(" Initial memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
     OF "END_TOTAL":
      SET md_end_total_timer = sysdate
      CALL echo(">>>>>>>>")
      CALL echo(build(" TOTAL execution time for: ",ms_input_str))
      CALL echo(build(" Elapsed time: ",datetimediff(md_end_total_timer,md_start_total_timer,5)))
      CALL echo(" Ending memory usage: ")
      CALL trace(7)
      CALL echo("<<<<<<<<")
      SET md_start_total_timer = 0
      SET md_end_total_timer = 0
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_check_debug(null)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DM_STAT_GATHER_SOU"
     AND di.info_name="DEBUG_IND"
    DETAIL
     mn_debug_ind = di.info_number
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_number = 0, di.info_domain = "DM_STAT_GATHER_SOU", di.info_name = "DEBUG_IND"
     WITH nocounter
    ;end insert
    COMMIT
    SET mn_debug_ind = 0
   ENDIF
   IF (error(error_msg,0) > 0)
    ROLLBACK
    CALL esmerror(concat("Error: CHECK_DEBUG ",error_msg),esmreturn)
   ENDIF
 END ;Subroutine
END GO
