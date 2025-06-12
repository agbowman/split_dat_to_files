CREATE PROGRAM aps_get_cyto_screener_info:dba
 RECORD reply(
   1 daily_exist = c1
   1 css_sequence = i4
   1 normal_percentage = i4
   1 abnormal_percentage = i4
   1 chr_percentage = i4
   1 atypical_percentage = i4
   1 verify_level = i4
   1 css_reviewer_id = f8
   1 css_reviewed_dt_tm = dq8
   1 css_comments = vc
   1 auto_overscreener_ind = i2
   1 over_requeue_flag = i2
   1 over_service_resource_cd = f8
   1 normal_requeue_flag = i2
   1 normal_service_resource_cd = f8
   1 chr_requeue_flag = i2
   1 chr_service_resource_cd = f8
   1 atypical_requeue_flag = i2
   1 atypical_service_resource_cd = f8
   1 abnormal_requeue_flag = i2
   1 abnormal_service_resource_cd = f8
   1 unsat_percentage = i4
   1 unsat_requeue_flag = i2
   1 unsat_service_resource_cd = f8
   1 css_updt_cnt = i4
   1 csl_sequence = i4
   1 slide_limit = f8
   1 screening_hours = f8
   1 csl_reviewer_id = f8
   1 csl_reviewed_dt_tm = dq8
   1 csl_comments = vc
   1 csl_updt_cnt = i4
   1 normal_cases = i4
   1 prev_atypical_cases = i4
   1 prev_abnormal_cases = i4
   1 record_dt_tm = dq8
   1 outside_hours = f8
   1 qa_slides = f8
   1 proficiency_slides = f8
   1 screen_hours = f8
   1 gyn_slides_is = f8
   1 gyn_slides_rs = f8
   1 ngyn_slides_is = f8
   1 ngyn_slides_rs = f8
   1 gyn_cases_is = i4
   1 gyn_cases_rs = i4
   1 ngyn_cases_is = i4
   1 ngyn_cases_rs = i4
   1 chr_cases = i4
   1 exceeded_limit_cases = i4
   1 user_preference_cases = i4
   1 dcc_updt_cnt = i4
   1 outside_gyn_is = f8
   1 outside_gyn_rs = f8
   1 outside_ngyn_is = f8
   1 outside_ngyn_rs = f8
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
 IF (trim(request->cdf_mean)="")
  SET request->cdf_mean = "CYTOTECH"
 ENDIF
 SELECT INTO "nl:"
  css.sequence, csl.sequence
  FROM dummyt d,
   cyto_screening_security css,
   cyto_screening_limits csl,
   cyto_screening_limits csl1
  PLAN (d)
   JOIN (((csl
   WHERE (request->prsnl_id=csl.prsnl_id)
    AND 1=csl.active_ind)
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id
    AND 1=css.active_ind
    AND (request->cdf_mean="CYTOTECH"))
   ) ORJOIN ((csl1
   WHERE (request->prsnl_id=csl1.prsnl_id)
    AND 1=csl1.active_ind
    AND (request->checkpathslidelmt=1)
    AND (((request->cdf_mean="PATHOLOGIST")) OR ((request->cdf_mean="PATHRESIDENT"))) )
   ))
  DETAIL
   reply->css_sequence = css.sequence, reply->normal_percentage = css.normal_percentage, reply->
   abnormal_percentage = css.abnormal_percentage,
   reply->chr_percentage = css.chr_percentage, reply->atypical_percentage = css.atypical_percentage,
   reply->verify_level = css.verify_level,
   reply->css_reviewer_id = css.reviewer_id, reply->css_reviewed_dt_tm = css.reviewed_dt_tm, reply->
   css_comments = css.comments,
   reply->auto_overscreener_ind = css.auto_overscreener_ind, reply->over_requeue_flag = css
   .over_requeue_flag, reply->over_service_resource_cd = css.over_service_resource_cd,
   reply->normal_requeue_flag = css.normal_requeue_flag, reply->normal_service_resource_cd = css
   .normal_service_resource_cd, reply->chr_requeue_flag = css.chr_requeue_flag,
   reply->chr_service_resource_cd = css.chr_service_resource_cd, reply->atypical_requeue_flag = css
   .atypical_requeue_flag, reply->atypical_service_resource_cd = css.atypical_service_resource_cd,
   reply->abnormal_requeue_flag = css.abnormal_requeue_flag, reply->abnormal_service_resource_cd =
   css.abnormal_service_resource_cd, reply->unsat_percentage = css.unsat_percentage,
   reply->unsat_requeue_flag = css.unsat_requeue_flag, reply->unsat_service_resource_cd = css
   .unsat_service_resource_cd, reply->css_updt_cnt = css.updt_cnt
   IF ((request->cdf_mean="CYTOTECH"))
    reply->csl_sequence = csl.sequence, reply->slide_limit = csl.slide_limit, reply->screening_hours
     = csl.screening_hours,
    reply->csl_reviewer_id = csl.reviewer_id, reply->csl_reviewed_dt_tm = csl.reviewed_dt_tm, reply->
    csl_comments = csl.comments,
    reply->csl_updt_cnt = csl.updt_cnt
   ELSE
    reply->csl_sequence = csl1.sequence, reply->slide_limit = csl1.slide_limit, reply->
    screening_hours = csl1.screening_hours,
    reply->csl_reviewer_id = csl1.reviewer_id, reply->csl_reviewed_dt_tm = csl1.reviewed_dt_tm, reply
    ->csl_comments = csl1.comments,
    reply->csl_updt_cnt = csl1.updt_cnt
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
  SELECT INTO "nl:"
   dcc.normal_cases
   FROM daily_cytology_counts dcc
   WHERE (request->prsnl_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   DETAIL
    reply->daily_exist = "Y", reply->normal_cases = dcc.normal_cases, reply->prev_atypical_cases =
    dcc.prev_atypical_cases,
    reply->prev_abnormal_cases = dcc.prev_abnormal_cases, reply->record_dt_tm = dcc.record_dt_tm,
    reply->outside_hours = dcc.outside_hours,
    reply->qa_slides = dcc.qa_slides, reply->proficiency_slides = dcc.proficiency_slides, reply->
    screen_hours = dcc.screen_hours,
    reply->gyn_slides_is = dcc.gyn_slides_is, reply->gyn_slides_rs = dcc.gyn_slides_rs, reply->
    ngyn_slides_is = dcc.ngyn_slides_is,
    reply->ngyn_slides_rs = dcc.ngyn_slides_rs, reply->gyn_cases_is = dcc.gyn_cases_is, reply->
    gyn_cases_rs = dcc.gyn_cases_rs,
    reply->ngyn_cases_is = dcc.ngyn_cases_is, reply->ngyn_cases_rs = dcc.ngyn_cases_rs, reply->
    chr_cases = dcc.chr_cases,
    reply->exceeded_limit_cases = dcc.exceeded_limit_cases, reply->user_preference_cases = dcc
    .user_preference_cases, reply->dcc_updt_cnt = dcc.updt_cnt,
    reply->outside_gyn_is = dcc.outside_gyn_is, reply->outside_gyn_rs = dcc.outside_gyn_rs, reply->
    outside_ngyn_is = dcc.outside_ngyn_is,
    reply->outside_ngyn_rs = dcc.outside_ngyn_rs
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
