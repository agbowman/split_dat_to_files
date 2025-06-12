CREATE PROGRAM aps_get_screener_counts:dba
 RECORD reply(
   1 daily_exist = c1
   1 slide_limit = f8
   1 screening_hours = f8
   1 screen_hours = f8
   1 gyn_slides_is = f8
   1 gyn_slides_rs = f8
   1 ngyn_slides_is = f8
   1 ngyn_slides_rs = f8
   1 outside_hours = f8
   1 outside_gyn_is = f8
   1 outside_gyn_rs = f8
   1 outside_ngyn_is = f8
   1 outside_ngyn_rs = f8
   1 count_comment = vc
   1 dcc_updt_cnt = i4
   1 requeue_flag = i2
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
#script
 SET reply->status_data.status = "F"
 SET reply->daily_exist = "N"
 CALL getstartofdayabs(request->screening_date,0)
 SET flag = 0
 IF (trim(request->cdf_mean)="")
  SET request->cdf_mean = "CYTOTECH"
 ENDIF
 SELECT INTO "nl:"
  css.active_ind, css.updt_cnt, csl.sequence,
  csl.slide_limit, csl.screening_hours, csl.updt_cnt
  FROM dummyt d,
   cyto_screening_limits csl,
   cyto_screening_security css,
   cyto_screening_limits csl1
  PLAN (d)
   JOIN (((csl
   WHERE (request->prsnl_id=csl.prsnl_id)
    AND 1=csl.active_ind
    AND (request->cdf_mean="CYTOTECH"))
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id
    AND 1=css.active_ind)
   ) ORJOIN ((csl1
   WHERE (request->prsnl_id=csl1.prsnl_id)
    AND 1=csl1.active_ind
    AND (request->checkpathslidelmt=1)
    AND (((request->cdf_mean="PATHOLOGIST")) OR ((request->cdf_mean="PATHRESIDENT"))) )
   ))
  DETAIL
   IF ((request->cdf_mean="CYTOTECH"))
    reply->slide_limit = csl.slide_limit, reply->screening_hours = csl.screening_hours, reply->
    requeue_flag = csl.requeue_flag
   ELSE
    reply->slide_limit = csl1.slide_limit, reply->screening_hours = csl1.screening_hours, reply->
    requeue_flag = csl1.requeue_flag
   ENDIF
   reply->status_data.status = "S"
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF ((request->cdf_mean="CYTOTECH"))
   SET reply->status_data.status = "Z"
  ELSEIF ((((request->cdf_mean="PATHOLOGIST")) OR ((request->cdf_mean="PATHRESIDENT")))
   AND (request->checkpathslidelmt=0))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  SELECT
   dcc.screen_hours, dcc.gyn_slides_is, dcc.gyn_slides_rs,
   dcc.ngyn_slides_is, dcc.ngyn_slides_rs, dcc.updt_cnt
   FROM daily_cytology_counts dcc
   WHERE (dcc.prsnl_id=request->prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   DETAIL
    reply->daily_exist = "Y", reply->screen_hours = dcc.screen_hours, reply->gyn_slides_is = dcc
    .gyn_slides_is,
    reply->gyn_slides_rs = dcc.gyn_slides_rs, reply->ngyn_slides_is = dcc.ngyn_slides_is, reply->
    ngyn_slides_rs = dcc.ngyn_slides_rs,
    reply->outside_hours = dcc.outside_hours, reply->outside_gyn_is = dcc.outside_gyn_is, reply->
    outside_gyn_rs = dcc.outside_gyn_rs,
    reply->outside_ngyn_is = dcc.outside_ngyn_is, reply->outside_ngyn_rs = dcc.outside_ngyn_rs, reply
    ->count_comment = trim(dcc.comments),
    reply->dcc_updt_cnt = dcc.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
#troubleshooting
#end_script
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CYTOLOGY SCREENER SECURITY/LIMITS"
 ENDIF
END GO
