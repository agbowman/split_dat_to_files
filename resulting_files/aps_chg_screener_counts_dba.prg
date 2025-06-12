CREATE PROGRAM aps_chg_screener_counts:dba
 RECORD reply(
   1 dcc_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD dtemp(
   1 beg_of_day = dq8
   1 end_of_day = dq8
   1 beg_of_day_abs = dq8
   1 end_of_day_abs = dq8
   1 beg_of_month = dq8
   1 end_of_month = dq8
   1 beg_of_month_abs = dq8
   1 end_of_month_abs = dq8
 )
 SUBROUTINE change_times(start_date,end_date)
  CALL getstartofday(start_date,0)
  CALL getendofday(end_date,0)
 END ;Subroutine
 SUBROUTINE getstartofdayabs(date_time,date_offset)
  CALL getstartofday(date_time,date_offset)
  SET dtemp->beg_of_day_abs = cnvtdatetimeutc(dtemp->beg_of_day,2)
 END ;Subroutine
 SUBROUTINE getstartofday(date_time,date_offset)
   SET dtemp->beg_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),0)
 END ;Subroutine
 SUBROUTINE getendofdayabs(date_time,date_offset)
  CALL getendofday(date_time,date_offset)
  SET dtemp->end_of_day_abs = cnvtdatetimeutc(dtemp->end_of_day,2)
 END ;Subroutine
 SUBROUTINE getendofday(date_time,date_offset)
   SET dtemp->end_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),235959)
 END ;Subroutine
 SUBROUTINE getstartofmonthabs(date_time,month_offset)
  CALL getstartofmonth(date_time,month_offset)
  SET dtemp->beg_of_month_abs = cnvtdatetimeutc(dtemp->beg_of_month,2)
 END ;Subroutine
 SUBROUTINE getstartofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) <= 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = (((month(date_time)+ month_offset) - 1)/ 12)
    SET nmonthremainder = mod((month(date_time)+ month_offset),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->beg_of_month = cnvtdatetime(cnvtdate2(date_string,"ddmmyyyy"),0)
 END ;Subroutine
 SUBROUTINE getendofmonthabs(date_time,month_offset)
  CALL getendofmonth(date_time,month_offset)
  SET dtemp->end_of_month_abs = cnvtdatetimeutc(dtemp->end_of_month,2)
 END ;Subroutine
 SUBROUTINE getendofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) < 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = ((month(date_time)+ month_offset)/ 12)
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->end_of_month = cnvtdatetime((cnvtdate2(date_string,"ddmmyyyy") - 1),235959)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET failed = "F"
 SET error_cnt = 0
 CALL getstartofdayabs(request->screening_date,0)
 CALL getstartofmonthabs(request->screening_date,0)
 IF ((request->action="A"))
  INSERT  FROM daily_cytology_counts dcc
   SET dcc.prsnl_id = request->prsnl_id, dcc.record_dt_tm = cnvtdatetime(dtemp->beg_of_day_abs), dcc
    .outside_hours = request->outside_hours,
    dcc.screen_hours = request->screen_hours, dcc.gyn_slides_is = request->gyn_slides_is, dcc
    .gyn_slides_rs = request->gyn_slides_rs,
    dcc.ngyn_slides_is = request->ngyn_slides_is, dcc.ngyn_slides_rs = request->ngyn_slides_rs, dcc
    .comments = trim(request->count_comment),
    dcc.outside_gyn_is = request->outside_gyn_is, dcc.outside_gyn_rs = request->outside_gyn_rs, dcc
    .outside_ngyn_is = request->outside_ngyn_is,
    dcc.outside_ngyn_rs = request->outside_ngyn_rs, dcc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    dcc.updt_id = reqinfo->updt_id,
    dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL handle_errors("INSERT","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action="C"))
  SELECT INTO "nl:"
   dcc.*
   FROM daily_cytology_counts dcc
   WHERE (dcc.prsnl_id=request->prsnl_id)
    AND dcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_day_abs)
   DETAIL
    cur_updt_cnt = dcc.updt_cnt
   WITH forupdate(dcc)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   CALL handle_errors("SELECT","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  IF ((request->dcc_updt_cnt != cur_updt_cnt))
   SET failed = "T"
   CALL handle_errors("LOCK","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  SET reply->dcc_updt_cnt = cur_updt_cnt
  UPDATE  FROM daily_cytology_counts dcc
   SET dcc.prsnl_id = request->prsnl_id, dcc.record_dt_tm = cnvtdatetime(dtemp->beg_of_day_abs), dcc
    .outside_hours = request->outside_hours,
    dcc.screen_hours = request->screen_hours, dcc.gyn_slides_is = request->gyn_slides_is, dcc
    .gyn_slides_rs = request->gyn_slides_rs,
    dcc.ngyn_slides_is = request->ngyn_slides_is, dcc.ngyn_slides_rs = request->ngyn_slides_rs, dcc
    .comments = trim(request->count_comment),
    dcc.outside_gyn_is = request->outside_gyn_is, dcc.outside_gyn_rs = request->outside_gyn_rs, dcc
    .outside_ngyn_is = request->outside_ngyn_is,
    dcc.outside_ngyn_rs = request->outside_ngyn_rs, dcc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    dcc.updt_id = reqinfo->updt_id,
    dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt =
    cur_updt_cnt
   WHERE (dcc.prsnl_id=request->prsnl_id)
    AND dcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_day_abs)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL handle_errors("UPDATE","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  mcc.*
  FROM monthly_cytology_counts mcc
  WHERE (mcc.prsnl_id=request->prsnl_id)
   AND mcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_month_abs)
  WITH forupdate(mcc)
 ;end select
 IF (curqual=0
  AND (request->action="C"))
  SET failed = "T"
  CALL handle_errors("SELECT","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  INSERT  FROM monthly_cytology_counts mcc
   SET mcc.prsnl_id = request->prsnl_id, mcc.record_dt_tm = cnvtdatetime(dtemp->beg_of_month_abs),
    mcc.outside_hours = request->diff_outside_hours,
    mcc.screen_hours = request->diff_screen_hours, mcc.gyn_slides_is = request->diff_gyn_slides_is,
    mcc.gyn_slides_rs = request->diff_gyn_slides_rs,
    mcc.ngyn_slides_is = request->diff_ngyn_slides_is, mcc.ngyn_slides_rs = request->
    diff_ngyn_slides_rs, mcc.outside_gyn_is = request->diff_outside_gyn_is,
    mcc.outside_gyn_rs = request->diff_outside_gyn_rs, mcc.outside_ngyn_is = request->
    diff_outside_ngyn_is, mcc.outside_ngyn_rs = request->diff_outside_ngyn_rs,
    mcc.updt_dt_tm = cnvtdatetime(curdate,curtime3), mcc.updt_id = reqinfo->updt_id, mcc.updt_task =
    reqinfo->updt_task,
    mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   CALL handle_errors("INSERT","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ELSE
  UPDATE  FROM monthly_cytology_counts mcc
   SET mcc.prsnl_id = request->prsnl_id, mcc.outside_hours = (mcc.outside_hours+ request->
    diff_outside_hours), mcc.screen_hours = (mcc.screen_hours+ request->diff_screen_hours),
    mcc.gyn_slides_is = (mcc.gyn_slides_is+ request->diff_gyn_slides_is), mcc.gyn_slides_rs = (mcc
    .gyn_slides_rs+ request->diff_gyn_slides_rs), mcc.ngyn_slides_is = (mcc.ngyn_slides_is+ request->
    diff_ngyn_slides_is),
    mcc.ngyn_slides_rs = (mcc.ngyn_slides_rs+ request->diff_ngyn_slides_rs), mcc.outside_gyn_is = (
    mcc.outside_gyn_is+ request->diff_outside_gyn_is), mcc.outside_gyn_rs = (mcc.outside_gyn_rs+
    request->diff_outside_gyn_rs),
    mcc.outside_ngyn_is = (mcc.outside_ngyn_is+ request->diff_outside_ngyn_is), mcc.outside_ngyn_rs
     = (mcc.outside_ngyn_rs+ request->diff_outside_ngyn_rs), mcc.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    mcc.updt_id = reqinfo->updt_id, mcc.updt_task = reqinfo->updt_task, mcc.updt_applctx = reqinfo->
    updt_applctx
   WHERE (mcc.prsnl_id=request->prsnl_id)
    AND mcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_month_abs)
  ;end update
  IF (curqual=0)
   SET failed = "T"
   CALL handle_errors("UPDATE","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 GO TO end_of_program
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_program
END GO
