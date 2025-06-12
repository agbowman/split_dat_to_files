CREATE PROGRAM edw_date_time_import:dba
 DECLARE edw_write_to_msg_log(script_name=vc,severity=i2,message=vc,updttask=vc) = i2 WITH public
 SUBROUTINE edw_write_to_msg_log(script_name,severity,message,updttask)
   IF (((script_name=null) OR (((((severity > 3) OR (severity < 1)) ) OR (message=null)) )) )
    CALL echo("The parameters to write_to_msg_log() are incorrect")
    RETURN(1)
   ELSE
    INSERT  FROM wh_oth_process_msg_log msg_log
     SET msg_log.object_name = script_name, msg_log.severity_flg = severity, msg_log.message_text =
      message,
      msg_log.process_dt_tm = cnvtdatetime(curdate,curtime3), msg_log.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), msg_log.updt_task = updttask,
      msg_log.updt_user = "CCL"
     WITH nocounter
    ;end insert
    COMMIT
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD date_rec
 RECORD date_rec(
   1 qual[73049]
     2 date_id = f8
     2 date_string = c10
     2 day_in_week = i4
     2 day_of_week = c10
     2 day_of_month = i4
     2 week_in_year = i4
     2 day_in_year = i4
     2 year = i4
     2 quarter = i2
     2 month = i4
     2 month_of_year = c20
     2 week_day_ind = i2
     2 last_day_of_month_ind = i2
     2 full_date = c20
     2 update_dt_tm = dq8
     2 update_source = c30
     2 update_user = c20
     2 date_string_disp = c10
     2 sql_dt_tm = dq8
     2 holiday_ind = i2
     2 work_day_ind = i2
     2 updt_tz_id = f8
     2 updt_utc_dt_tm = dq8
     2 dw_exist_flg = i4
 )
 FREE RECORD time_rec
 RECORD time_rec(
   1 qual[1440]
     2 time_id = f8
     2 time_of_day = c10
     2 minute_of_day = i4
     2 minute_of_hour = i4
     2 half_hour = c20
     2 hour_of_day = c20
     2 hour_nbr = i4
     2 half_hour_nbr = i4
     2 update_dt_tm = dq8
     2 update_source = c30
     2 update_user = c20
     2 updt_tz_id = f8
     2 updt_utc_dt_tm = dq8
     2 dw_exist_flg = i4
 )
 DECLARE date_seq = i4
 DECLARE time_seq = i4
 DECLARE exist_cnt = i4 WITH noconstant(0)
 DECLARE nbr_of_values = i4 WITH constant(73049)
 DECLARE leap_yr_ind = i2
 DECLARE current_date = dq8
 DECLARE ending_date = dq8
 DECLARE current_time = i2
 DECLARE ending_time = i2
 DECLARE current_min = i2
 DECLARE time_hr = vc
 DECLARE half_hr_nbr = i2
 DECLARE week_cntr = i2
 DECLARE weekofyear = i2
 DECLARE days = i4
 DECLARE start_int = i4
 DECLARE end_int = i4
 DECLARE errmsg = vc
 SET start_int = cnvtdate(03011900)
 SET end_int = cnvtdate(02282100)
 SET readme_data->status = "F"
 SET readme_data->message = "Staring EDW_DATE_TIME_IMPORT"
 SET date_seq = 1
 SET weekofyear = 9
 SET week_cntr = 3
 FOR (days = start_int TO end_int)
   SET current_date = cnvtdatetime(days,0)
   SET date_rec->qual[date_seq].date_id = date_seq
   SET date_rec->qual[date_seq].date_string = format(current_date,"MM/DD/YYYY;;D")
   SET date_rec->qual[date_seq].day_in_week = (weekday(current_date)+ 1)
   CASE (date_rec->qual[date_seq].day_in_week)
    OF 1:
     SET date_rec->qual[date_seq].day_of_week = "SUN"
    OF 2:
     SET date_rec->qual[date_seq].day_of_week = "MON"
    OF 3:
     SET date_rec->qual[date_seq].day_of_week = "TUE"
    OF 4:
     SET date_rec->qual[date_seq].day_of_week = "WED"
    OF 5:
     SET date_rec->qual[date_seq].day_of_week = "THU"
    OF 6:
     SET date_rec->qual[date_seq].day_of_week = "FRI"
    OF 7:
     SET date_rec->qual[date_seq].day_of_week = "SAT"
   ENDCASE
   SET date_rec->qual[date_seq].day_of_month = day(current_date)
   SET date_rec->qual[date_seq].month = month(current_date)
   SET date_rec->qual[date_seq].year = year(current_date)
   CASE (month(current_date))
    OF 1:
     SET date_rec->qual[date_seq].month_of_year = "JAN"
    OF 2:
     SET date_rec->qual[date_seq].month_of_year = "FEB"
    OF 3:
     SET date_rec->qual[date_seq].month_of_year = "MAR"
    OF 4:
     SET date_rec->qual[date_seq].month_of_year = "APR"
    OF 5:
     SET date_rec->qual[date_seq].month_of_year = "MAY"
    OF 6:
     SET date_rec->qual[date_seq].month_of_year = "JUN"
    OF 7:
     SET date_rec->qual[date_seq].month_of_year = "JUL"
    OF 8:
     SET date_rec->qual[date_seq].month_of_year = "AUG"
    OF 9:
     SET date_rec->qual[date_seq].month_of_year = "SEP"
    OF 10:
     SET date_rec->qual[date_seq].month_of_year = "OCT"
    OF 11:
     SET date_rec->qual[date_seq].month_of_year = "NOV"
    OF 12:
     SET date_rec->qual[date_seq].month_of_year = "DEC"
   ENDCASE
   IF (mod(date_rec->qual[date_seq].year,4)=0)
    SET leap_year_ind = 1
    IF (mod(date_rec->qual[date_seq].year,100)=0
     AND mod(date_rec->qual[date_seq].year,400) != 0)
     SET leap_year_ind = 0
    ENDIF
   ENDIF
   IF ((((date_rec->qual[date_seq].month IN (1, 3, 5, 7, 8,
   10, 12))
    AND (date_rec->qual[date_seq].day_of_month=31)) OR ((((date_rec->qual[date_seq].month IN (4, 6, 9,
   11))
    AND (date_rec->qual[date_seq].day_of_month=30)) OR ((date_rec->qual[date_seq].month=2)
    AND (( NOT (leap_year_ind)
    AND (date_rec->qual[date_seq].day_of_month=28)) OR (leap_year_ind
    AND (date_rec->qual[date_seq].day_of_month=29))) )) )) )
    SET date_rec->qual[date_seq].last_day_of_month_ind = 1
   ELSE
    SET date_rec->qual[date_seq].last_day_of_month_ind = 0
   ENDIF
   IF ((date_rec->qual[date_seq].month IN (1, 2, 3)))
    SET date_rec->qual[date_seq].quarter = 1
   ELSEIF ((date_rec->qual[date_seq].month IN (4, 5, 6)))
    SET date_rec->qual[date_seq].quarter = 2
   ELSEIF ((date_rec->qual[date_seq].month IN (7, 8, 9)))
    SET date_rec->qual[date_seq].quarter = 3
   ELSE
    SET date_rec->qual[date_seq].quarter = 4
   ENDIF
   IF ((date_rec->qual[date_seq].year=1900))
    SET date_rec->qual[date_seq].day_in_year = (julian(current_date) - 1)
   ELSE
    SET date_rec->qual[date_seq].day_in_year = julian(current_date)
   ENDIF
   SET date_rec->qual[date_seq].full_date = format(current_date,"MMM DD YYYY;;D")
   SET date_rec->qual[date_seq].update_dt_tm = cnvtdatetime(curdate,curtime3)
   SET date_rec->qual[date_seq].update_source = "edw_date_time_import"
   SET date_rec->qual[date_seq].update_user = " "
   SET date_rec->qual[date_seq].date_string_disp = format(current_date,"MM/DD/YYYY;;D")
   SET date_rec->qual[date_seq].sql_dt_tm = current_date
   IF ((date_rec->qual[date_seq].month=1)
    AND (date_rec->qual[date_seq].day_of_month=1))
    SET weekofyear = 1
    SET week_cntr = abs((date_rec->qual[date_seq].day_in_week - 8))
   ENDIF
   SET date_rec->qual[date_seq].week_in_year = weekofyear
   SET week_cntr = (week_cntr - 1)
   IF (week_cntr=0)
    SET weekofyear = (weekofyear+ 1)
    SET week_cntr = 7
   ENDIF
   SET date_seq = (date_seq+ 1)
 ENDFOR
 SET exist_cnt = 0
 SELECT INTO "nl:"
  FROM edw_oth_date dw
  DETAIL
   IF (dw.date_id > 0)
    exist_cnt = (exist_cnt+ 1), index = dw.date_id, date_rec->qual[index].dw_exist_flg = 1
   ENDIF
  WITH nocounter
 ;end select
 WHILE (error(errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to find date on edw_oth_date: ",errmsg)
   GO TO exit_script
 ENDWHILE
 INSERT  FROM (dummyt d  WITH seq = size(date_rec->qual,5)),
   edw_oth_date dw
  SET dw.date_id = date_rec->qual[d.seq].date_id, dw.date_string = date_rec->qual[d.seq].date_string,
   dw.day_of_week = date_rec->qual[d.seq].day_of_week,
   dw.day_of_month = date_rec->qual[d.seq].day_of_month, dw.week_in_year = ceil(date_rec->qual[d.seq]
    .week_in_year), dw.day_in_year = date_rec->qual[d.seq].day_in_year,
   dw.month = date_rec->qual[d.seq].month, dw.quarter = date_rec->qual[d.seq].quarter, dw.year =
   date_rec->qual[d.seq].year,
   dw.last_day_of_month_ind = date_rec->qual[d.seq].last_day_of_month_ind, dw.update_user = date_rec
   ->qual[d.seq].update_user, dw.update_source = date_rec->qual[d.seq].update_source,
   dw.date_string_disp = date_rec->qual[d.seq].date_string_disp, dw.sql_dt_tm = cnvtdatetimeutc(
    date_rec->qual[d.seq].sql_dt_tm,2), dw.update_dt_tm = cnvtdatetime(date_rec->qual[d.seq].
    update_dt_tm),
   dw.day_in_week = date_rec->qual[d.seq].day_in_week, dw.month_of_year = date_rec->qual[d.seq].
   month_of_year, dw.full_date = date_rec->qual[d.seq].full_date
  PLAN (d
   WHERE (date_rec->qual[d.seq].dw_exist_flg=0))
   JOIN (dw)
  WITH nocounter
 ;end insert
 WHILE (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert the date values: ",errmsg)
   GO TO exit_script
 ENDWHILE
 IF ((curqual != (nbr_of_values - exist_cnt)))
  ROLLBACK
  CALL edw_write_to_msg_log("edw_date_time_import",3,"EDW_OTH_DATE insert failed","INSTALL")
  SET readme_data->status = "F"
  SET readme_data->message = "EDW_DATE_TIME_IMPORT insert into EDW_OTH_DATE failed"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = size(date_rec->qual,5)),
   edw_oth_date dw
  SET dw.date_id = date_rec->qual[d.seq].date_id, dw.date_string = date_rec->qual[d.seq].date_string,
   dw.day_of_week = date_rec->qual[d.seq].day_of_week,
   dw.day_of_month = date_rec->qual[d.seq].day_of_month, dw.week_in_year = ceil(date_rec->qual[d.seq]
    .week_in_year), dw.day_in_year = date_rec->qual[d.seq].day_in_year,
   dw.month = date_rec->qual[d.seq].month, dw.quarter = date_rec->qual[d.seq].quarter, dw.year =
   date_rec->qual[d.seq].year,
   dw.last_day_of_month_ind = date_rec->qual[d.seq].last_day_of_month_ind, dw.update_user = date_rec
   ->qual[d.seq].update_user, dw.update_source = date_rec->qual[d.seq].update_source,
   dw.date_string_disp = date_rec->qual[d.seq].date_string_disp, dw.sql_dt_tm = cnvtdatetimeutc(
    date_rec->qual[d.seq].sql_dt_tm,2), dw.update_dt_tm = cnvtdatetime(date_rec->qual[d.seq].
    update_dt_tm),
   dw.day_in_week = date_rec->qual[d.seq].day_in_week, dw.month_of_year = date_rec->qual[d.seq].
   month_of_year, dw.full_date = date_rec->qual[d.seq].full_date
  PLAN (d
   WHERE (date_rec->qual[d.seq].dw_exist_flg=1))
   JOIN (dw
   WHERE (dw.date_id=date_rec->qual[d.seq].date_id))
  WITH nocounter
 ;end update
 WHILE (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to update the date values: ",errmsg)
   GO TO exit_script
 ENDWHILE
 COMMIT
 FREE RECORD date_rec
 SET half_hr_nbr = 0
 SET time_seq = 0
 FOR (i = 0000 TO 1439)
   SET time_seq = (i+ 1)
   SET current_min = i
   SET current_time = cnvttime(current_min)
   SET time_hr = format(current_time,"HH;;M")
   SET time_rec->qual[time_seq].time_id = time_seq
   SET time_rec->qual[time_seq].time_of_day = format(current_time,"HH:MM;;M")
   SET time_rec->qual[time_seq].minute_of_day = current_min
   SET time_rec->qual[time_seq].minute_of_hour = minute(current_time)
   IF (minute(current_time) < 30)
    SET time_rec->qual[time_seq].half_hour = build(time_hr,":00 - ","",time_hr,":29")
   ELSE
    SET time_rec->qual[time_seq].half_hour = build(time_hr,":30 - ","",time_hr,":59")
   ENDIF
   IF (((minute(current_time)=30) OR (hour(current_time) != 00
    AND minute(current_time)=00)) )
    SET half_hr_nbr = (half_hr_nbr+ 1)
   ENDIF
   SET time_rec->qual[time_seq].half_hour_nbr = half_hr_nbr
   SET time_rec->qual[time_seq].hour_of_day = build(time_hr,":00 - ","",hour(current_time),":59")
   SET time_rec->qual[time_seq].hour_nbr = hour(current_time)
   SET time_rec->qual[time_seq].update_dt_tm = cnvtdatetime(curdate,curtime3)
   SET time_rec->qual[time_seq].update_source = "edw_date_time_import"
   SET time_rec->qual[time_seq].update_user = ""
 ENDFOR
 SET exist_cnt = 0
 SELECT INTO "nl:"
  FROM edw_oth_time tm
  DETAIL
   IF (tm.time_id > 0)
    exist_cnt = (exist_cnt+ 1), index = tm.time_id, time_rec->qual[index].dw_exist_flg = 1
   ENDIF
  WITH nocounter
 ;end select
 WHILE (error(errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to find time_of_day on edw_oth_time: ",errmsg)
   GO TO exit_script
 ENDWHILE
 INSERT  FROM (dummyt d  WITH seq = size(time_rec->qual,5)),
   edw_oth_time tm
  SET tm.time_id = time_rec->qual[d.seq].time_id, tm.time_of_day = time_rec->qual[d.seq].time_of_day,
   tm.minute_of_day = time_rec->qual[d.seq].minute_of_day,
   tm.minute_of_hour = time_rec->qual[d.seq].minute_of_hour, tm.half_hour = time_rec->qual[d.seq].
   half_hour, tm.hour_of_day = time_rec->qual[d.seq].hour_of_day,
   tm.hour_nbr = time_rec->qual[d.seq].hour_nbr, tm.half_hour_nbr = time_rec->qual[d.seq].
   half_hour_nbr, tm.update_dt_tm = cnvtdatetime(time_rec->qual[d.seq].update_dt_tm),
   tm.update_source = time_rec->qual[d.seq].update_source, tm.update_user = time_rec->qual[d.seq].
   update_user
  PLAN (d
   WHERE (time_rec->qual[d.seq].dw_exist_flg=0))
   JOIN (tm)
  WITH nocounter
 ;end insert
 WHILE (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert the time values: ",errmsg)
   GO TO exit_script
 ENDWHILE
 IF ((curqual != (time_seq - exist_cnt)))
  ROLLBACK
  CALL edw_write_to_msg_log("edw_date_time_import",3,"EDW_OTH_TIME insert failed","INSTALL")
  SET readme_data->status = "F"
  SET readme_data->message = "EDW_DATE_TIME_IMPORT insert into EDW_OTH_TIME failed"
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = size(time_rec->qual,5)),
   edw_oth_time tm
  SET tm.time_id = time_rec->qual[d.seq].time_id, tm.time_of_day = time_rec->qual[d.seq].time_of_day,
   tm.minute_of_day = time_rec->qual[d.seq].minute_of_day,
   tm.minute_of_hour = time_rec->qual[d.seq].minute_of_hour, tm.half_hour = time_rec->qual[d.seq].
   half_hour, tm.hour_of_day = time_rec->qual[d.seq].hour_of_day,
   tm.hour_nbr = time_rec->qual[d.seq].hour_nbr, tm.half_hour_nbr = time_rec->qual[d.seq].
   half_hour_nbr, tm.update_dt_tm = cnvtdatetime(time_rec->qual[d.seq].update_dt_tm),
   tm.update_source = time_rec->qual[d.seq].update_source, tm.update_user = time_rec->qual[d.seq].
   update_user
  PLAN (d
   WHERE (time_rec->qual[d.seq].dw_exist_flg=1))
   JOIN (tm
   WHERE (tm.time_id=time_rec->qual[d.seq].time_id))
  WITH nocounter
 ;end update
 WHILE (error(errmsg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to udpate the time values: ",errmsg)
   GO TO exit_script
 ENDWHILE
 COMMIT
 FREE RECORD time_seq
 SET readme_data->status = "S"
 SET readme_data->message = "EDW_DATE_TIME_IMPORT succeeded"
#exit_script
 SET script_version = "002 01/27/11 RP019504"
END GO
