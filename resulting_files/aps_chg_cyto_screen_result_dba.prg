CREATE PROGRAM aps_chg_cyto_screen_result:dba
 RECORD reply(
   1 status_cd = f8
   1 status_disp = c40
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
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET count = 0
 SET cur_updt_cnt = 0
 SET review_reason_flag = 0
 SET monthis = format(cnvtdatetime(request->screen_dt_tm),"mmm;;d")
 SET yearis = cnvtint(year(request->screen_dt_tm))
 SET firstofmonth = build("01-",monthis,"-",yearis," 00:00:00.00")
 SET first_day_of_month = cnvtdatetime(firstofmonth)
 SET gyn_cases_is = 0
 SET gyn_cases_rs = 0
 SET gyn_slides_is = 0.0
 SET gyn_slides_rs = 0.0
 SET ngyn_slides_is = 0.0
 SET ngyn_slides_rs = 0.0
 SET ngyn_cases_is = 0
 SET ngyn_cases_rs = 0
 SET normal_cases = 0
 SET normal_slides = 0.0
 SET normal_slides_requeued = 0.0
 SET chr_cases = 0
 SET chr_slides = 0.0
 SET chr_slides_requeued = 0.0
 SET prev_atypical_cases = 0
 SET prev_atypical_slides = 0.0
 SET prev_atyp_slides_requeued = 0.0
 SET prev_abnormal_cases = 0
 SET prev_abnormal_slides = 0.0
 SET prev_abn_slides_requeued = 0.0
 SET unsat_cases = 0
 SET unsat_slides = 0.0
 SET unsat_slides_requeued = 0.0
 SET exceeded_limit_cases = 0
 SET exceeded_limit_slides = 0.0
 SET user_preference_cases = 0.0
 SET user_preference_slides = 0.0
 CALL getstartofdayabs(request->screen_dt_tm,0)
 CALL getstartofmonthabs(request->screen_dt_tm,0)
 SET qaflags = 0
 SET unsat = 1
 SET norm = 2
 SET abnorm = 4
 SET atyp = 8
 SET chr = 16
 SET qaflags = request->qaflag_bitword
 SELECT INTO "nl:"
  cse.*
  FROM cyto_screening_event cse
  WHERE (request->case_id=cse.case_id)
   AND (request->sequence=cse.sequence)
   AND (request->screener_id=cse.screener_id)
  DETAIL
   cur_updt_cnt = cse.updt_cnt, review_reason_flag = cse.review_reason_flag
  WITH forupdate(cse), nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","CYTO_SCREENING_EVENT")
  GO TO exit_script
 ELSE
  IF ((request->updt_cnt != cur_updt_cnt))
   CALL handle_errors("LOCK","F","TABLE","CYTO_SCREENING_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (review_reason_flag=7)
  SET qaflags = 0
 ENDIF
 UPDATE  FROM cyto_screening_event cse
  SET cse.active_ind = 0, cse.updt_dt_tm = cnvtdatetime(curdate,curtime), cse.updt_id = reqinfo->
   updt_id,
   cse.updt_task = reqinfo->updt_task, cse.updt_applctx = reqinfo->updt_applctx, cse.updt_cnt = (
   cur_updt_cnt+ 1)
  WHERE (request->case_id=cse.case_id)
   AND (request->sequence=cse.sequence)
   AND (request->screener_id=cse.screener_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","F","TABLE","CYTO_SCREENING_EVENT")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dcc.*
  FROM daily_cytology_counts dcc
  WHERE (request->screener_id=dcc.prsnl_id)
   AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
  DETAIL
   gyn_cases_is = dcc.gyn_cases_is, gyn_cases_rs = dcc.gyn_cases_rs, gyn_slides_is = dcc
   .gyn_slides_is,
   gyn_slides_rs = dcc.gyn_slides_rs, ngyn_slides_is = dcc.ngyn_slides_is, ngyn_slides_rs = dcc
   .ngyn_slides_rs,
   ngyn_cases_is = dcc.ngyn_cases_is, ngyn_cases_rs = dcc.ngyn_cases_rs, normal_cases = dcc
   .normal_cases,
   normal_slides = dcc.normal_slides, normal_slides_requeued = dcc.normal_slides_requeued, chr_cases
    = dcc.chr_cases,
   chr_slides = dcc.chr_slides, chr_slides_requeued = dcc.chr_slides_requeued, prev_atypical_cases =
   dcc.prev_atypical_cases,
   prev_atypical_slides = dcc.prev_atypical_slides, prev_atyp_slides_requeued = dcc
   .prev_atyp_slides_requeued, prev_abnormal_cases = dcc.prev_abnormal_cases,
   prev_abnormal_slides = dcc.prev_abnormal_slides, prev_abn_slides_requeued = dcc
   .prev_abn_slides_requeued, unsat_cases = dcc.unsat_cases,
   unsat_slides = dcc.unsat_slides, unsat_slides_requeued = dcc.unsat_slides_requeued,
   exceeded_limit_cases = dcc.exceeded_limit_cases,
   exceeded_limit_slides = dcc.exceeded_limit_slides, user_preference_cases = dcc
   .user_preference_cases, user_preference_slides = dcc.user_preference_slides,
   cur_updt_cnt = dcc.updt_cnt
  WITH nocounter, forupdate(dcc)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","DAILY_CYTOLOGY_COUNTS")
  GO TO exit_script
 ENDIF
 IF ((request->slide_cnt > 0))
  UPDATE  FROM daily_cytology_counts dcc
   SET dcc.gyn_cases_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)) (gyn_cases_is - 1)
    ELSE dcc.gyn_cases_is
    ENDIF
    , dcc.gyn_slides_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)) (gyn_slides_is - request->slide_cnt)
    ELSE gyn_slides_is
    ENDIF
    , dcc.gyn_cases_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)) (gyn_cases_rs - 1)
    ELSE dcc.gyn_cases_rs
    ENDIF
    ,
    dcc.gyn_slides_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)) (gyn_slides_rs - request->slide_cnt)
    ELSE gyn_slides_rs
    ENDIF
    , dcc.ngyn_cases_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)) (ngyn_cases_is - 1)
    ELSE dcc.ngyn_cases_is
    ENDIF
    , dcc.ngyn_slides_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)) (ngyn_slides_is - request->slide_cnt)
    ELSE ngyn_slides_is
    ENDIF
    ,
    dcc.ngyn_cases_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)) (ngyn_cases_rs - 1)
    ELSE dcc.ngyn_cases_rs
    ENDIF
    , dcc.ngyn_slides_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)) (ngyn_slides_rs - request->slide_cnt)
    ELSE ngyn_slides_rs
    ENDIF
    , dcc.exceeded_limit_cases =
    IF (review_reason_flag=1) (exceeded_limit_cases - 1)
    ELSE dcc.exceeded_limit_cases
    ENDIF
    ,
    dcc.exceeded_limit_slides =
    IF (review_reason_flag=1) (exceeded_limit_slides - request->slide_cnt)
    ELSE dcc.exceeded_limit_slides
    ENDIF
    , dcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases - 1)
    ELSE dcc.unsat_cases
    ENDIF
    , dcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides - request->slide_cnt)
    ELSE dcc.unsat_slides
    ENDIF
    ,
    dcc.unsat_slides_requeued =
    IF (review_reason_flag=2) (unsat_slides_requeued - request->slide_cnt)
    ELSE dcc.unsat_slides_requeued
    ENDIF
    , dcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases - 1)
    ELSE dcc.normal_cases
    ENDIF
    , dcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides - request->slide_cnt)
    ELSE dcc.normal_slides
    ENDIF
    ,
    dcc.normal_slides_requeued =
    IF (review_reason_flag=3) (normal_slides_requeued - request->slide_cnt)
    ELSE dcc.normal_slides_requeued
    ENDIF
    , dcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases - 1)
    ELSE dcc.prev_atypical_cases
    ENDIF
    , dcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides - request->slide_cnt)
    ELSE dcc.prev_atypical_slides
    ENDIF
    ,
    dcc.prev_atyp_slides_requeued =
    IF (review_reason_flag=4) (prev_atyp_slides_requeued - request->slide_cnt)
    ELSE dcc.prev_atyp_slides_requeued
    ENDIF
    , dcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases - 1)
    ELSE dcc.prev_abnormal_cases
    ENDIF
    , dcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides - request->slide_cnt)
    ELSE dcc.prev_abnormal_slides
    ENDIF
    ,
    dcc.prev_abn_slides_requeued =
    IF (review_reason_flag=5) (prev_abn_slides_requeued - request->slide_cnt)
    ELSE dcc.prev_abn_slides_requeued
    ENDIF
    , dcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases - 1)
    ELSE dcc.chr_cases
    ENDIF
    , dcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides - request->slide_cnt)
    ELSE dcc.chr_slides
    ENDIF
    ,
    dcc.chr_slides_requeued =
    IF (review_reason_flag=6) (chr_slides_requeued - request->slide_cnt)
    ELSE dcc.chr_slides_requeued
    ENDIF
    , dcc.user_preference_cases =
    IF (review_reason_flag=8) (user_preference_cases - 1)
    ELSE dcc.user_preference_cases
    ENDIF
    , dcc.user_preference_slides =
    IF (review_reason_flag=8) (user_preference_slides - request->slide_cnt)
    ELSE dcc.user_preference_slides
    ENDIF
    ,
    dcc.updt_dt_tm = cnvtdatetime(curdate,curtime), dcc.updt_id = reqinfo->updt_id, dcc.updt_task =
    reqinfo->updt_task,
    dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->qa_slide_cnt > 0))
  UPDATE  FROM daily_cytology_counts dcc
   SET dcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases - 1)
    ELSE dcc.unsat_cases
    ENDIF
    , dcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides - request->qa_slide_cnt)
    ELSE dcc.unsat_slides
    ENDIF
    , dcc.unsat_slides_requeued =
    IF (review_reason_flag=2) (unsat_slides_requeued - request->qa_slide_cnt)
    ELSE dcc.unsat_slides_requeued
    ENDIF
    ,
    dcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases - 1)
    ELSE dcc.normal_cases
    ENDIF
    , dcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides - request->qa_slide_cnt)
    ELSE dcc.normal_slides
    ENDIF
    , dcc.normal_slides_requeued =
    IF (review_reason_flag=3) (normal_slides_requeued - request->qa_slide_cnt)
    ELSE dcc.normal_slides_requeued
    ENDIF
    ,
    dcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases - 1)
    ELSE dcc.prev_atypical_cases
    ENDIF
    , dcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides - request->qa_slide_cnt)
    ELSE dcc.prev_atypical_slides
    ENDIF
    , dcc.prev_atyp_slides_requeued =
    IF (review_reason_flag=4) (prev_atyp_slides_requeued - request->qa_slide_cnt)
    ELSE dcc.prev_atyp_slides_requeued
    ENDIF
    ,
    dcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases - 1)
    ELSE dcc.prev_abnormal_cases
    ENDIF
    , dcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides - request->qa_slide_cnt)
    ELSE dcc.prev_abnormal_slides
    ENDIF
    , dcc.prev_abn_slides_requeued =
    IF (review_reason_flag=5) (prev_abn_slides_requeued - request->qa_slide_cnt)
    ELSE dcc.prev_abn_slides_requeued
    ENDIF
    ,
    dcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases - 1)
    ELSE dcc.chr_cases
    ENDIF
    , dcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides - request->qa_slide_cnt)
    ELSE dcc.chr_slides
    ENDIF
    , dcc.chr_slides_requeued =
    IF (review_reason_flag=6) (chr_slides_requeued - request->qa_slide_cnt)
    ELSE dcc.chr_slides_requeued
    ENDIF
    ,
    dcc.user_preference_cases =
    IF (review_reason_flag=8) (user_preference_cases - 1)
    ELSE dcc.user_preference_cases
    ENDIF
    , dcc.user_preference_slides =
    IF (review_reason_flag=8) (user_preference_slides - request->qa_slide_cnt)
    ELSE dcc.user_preference_slides
    ENDIF
    , dcc.updt_dt_tm = cnvtdatetime(curdate,curtime),
    dcc.updt_id = reqinfo->updt_id, dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->
    updt_applctx,
    dcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=dcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_day_abs)=dcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  mcc.*
  FROM monthly_cytology_counts mcc
  WHERE (request->screener_id=mcc.prsnl_id)
   AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
  DETAIL
   gyn_cases_is = mcc.gyn_cases_is, gyn_cases_rs = mcc.gyn_cases_rs, gyn_slides_is = mcc
   .gyn_slides_is,
   gyn_slides_rs = mcc.gyn_slides_rs, ngyn_slides_is = mcc.ngyn_slides_is, ngyn_slides_rs = mcc
   .ngyn_slides_rs,
   ngyn_cases_is = mcc.ngyn_cases_is, ngyn_cases_rs = mcc.ngyn_cases_rs, normal_cases = mcc
   .normal_cases,
   normal_slides = mcc.normal_slides, normal_slides_requeued = mcc.normal_slides_requeued, chr_cases
    = mcc.chr_cases,
   chr_slides = mcc.chr_slides, chr_slides_requeued = mcc.chr_slides_requeued, prev_atypical_cases =
   mcc.prev_atypical_cases,
   prev_atypical_slides = mcc.prev_atypical_slides, prev_atyp_slides_requeued = mcc
   .prev_atyp_slides_requeued, prev_abnormal_cases = mcc.prev_abnormal_cases,
   prev_abnormal_slides = mcc.prev_abnormal_slides, prev_abn_slides_requeued = mcc
   .prev_abn_slides_requeued, unsat_cases = mcc.unsat_cases,
   unsat_slides = mcc.unsat_slides, unsat_slides_requeued = mcc.unsat_slides_requeued,
   exceeded_limit_cases = mcc.exceeded_limit_cases,
   exceeded_limit_slides = mcc.exceeded_limit_slides, user_preference_cases = mcc
   .user_preference_cases, user_preference_slides = mcc.user_preference_slides,
   cur_updt_cnt = mcc.updt_cnt
  WITH nocounter, forupdate(mcc)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
  GO TO exit_script
 ENDIF
 IF ((request->slide_cnt > 0))
  UPDATE  FROM monthly_cytology_counts mcc
   SET mcc.gyn_cases_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)) (gyn_cases_is - 1)
    ELSE mcc.gyn_cases_is
    ENDIF
    , mcc.gyn_slides_is =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=1)) (gyn_slides_is - request->slide_cnt)
    ELSE gyn_slides_is
    ENDIF
    , mcc.gyn_cases_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)) (gyn_cases_rs - 1)
    ELSE mcc.gyn_cases_rs
    ENDIF
    ,
    mcc.gyn_slides_rs =
    IF ((request->case_type_ind=1)
     AND (request->initial_ind=0)) (gyn_slides_rs - request->slide_cnt)
    ELSE gyn_slides_rs
    ENDIF
    , mcc.ngyn_cases_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)) (ngyn_cases_is - 1)
    ELSE mcc.ngyn_cases_is
    ENDIF
    , mcc.ngyn_slides_is =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=1)) (ngyn_slides_is - request->slide_cnt)
    ELSE ngyn_slides_is
    ENDIF
    ,
    mcc.ngyn_cases_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)) (ngyn_cases_rs - 1)
    ELSE mcc.ngyn_cases_rs
    ENDIF
    , mcc.ngyn_slides_rs =
    IF ((request->case_type_ind=0)
     AND (request->initial_ind=0)) (ngyn_slides_rs - request->slide_cnt)
    ELSE ngyn_slides_rs
    ENDIF
    , mcc.exceeded_limit_cases =
    IF (review_reason_flag=1) (exceeded_limit_cases - 1)
    ELSE mcc.exceeded_limit_cases
    ENDIF
    ,
    mcc.exceeded_limit_slides =
    IF (review_reason_flag=1) (exceeded_limit_slides - request->slide_cnt)
    ELSE mcc.exceeded_limit_slides
    ENDIF
    , mcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases - 1)
    ELSE mcc.unsat_cases
    ENDIF
    , mcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides - request->slide_cnt)
    ELSE mcc.unsat_slides
    ENDIF
    ,
    mcc.unsat_slides_requeued =
    IF (review_reason_flag=2) (unsat_slides_requeued - request->slide_cnt)
    ELSE mcc.unsat_slides_requeued
    ENDIF
    , mcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases - 1)
    ELSE mcc.normal_cases
    ENDIF
    , mcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides - request->slide_cnt)
    ELSE mcc.normal_slides
    ENDIF
    ,
    mcc.normal_slides_requeued =
    IF (review_reason_flag=3) (normal_slides_requeued - request->slide_cnt)
    ELSE mcc.normal_slides_requeued
    ENDIF
    , mcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases - 1)
    ELSE mcc.prev_atypical_cases
    ENDIF
    , mcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides - request->slide_cnt)
    ELSE mcc.prev_atypical_slides
    ENDIF
    ,
    mcc.prev_atyp_slides_requeued =
    IF (review_reason_flag=4) (prev_atyp_slides_requeued - request->slide_cnt)
    ELSE mcc.prev_atyp_slides_requeued
    ENDIF
    , mcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases - 1)
    ELSE mcc.prev_abnormal_cases
    ENDIF
    , mcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides - request->slide_cnt)
    ELSE mcc.prev_abnormal_slides
    ENDIF
    ,
    mcc.prev_abn_slides_requeued =
    IF (review_reason_flag=5) (prev_abn_slides_requeued - request->slide_cnt)
    ELSE mcc.prev_abn_slides_requeued
    ENDIF
    , mcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases - 1)
    ELSE mcc.chr_cases
    ENDIF
    , mcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides - request->slide_cnt)
    ELSE mcc.chr_slides
    ENDIF
    ,
    mcc.chr_slides_requeued =
    IF (review_reason_flag=6) (chr_slides_requeued - request->slide_cnt)
    ELSE mcc.chr_slides_requeued
    ENDIF
    , mcc.user_preference_cases =
    IF (review_reason_flag=8) (user_preference_cases - 1)
    ELSE mcc.user_preference_cases
    ENDIF
    , mcc.user_preference_slides =
    IF (review_reason_flag=8) (user_preference_slides - request->slide_cnt)
    ELSE mcc.user_preference_slides
    ENDIF
    ,
    mcc.updt_dt_tm = cnvtdatetime(curdate,curtime), mcc.updt_id = reqinfo->updt_id, mcc.updt_task =
    reqinfo->updt_task,
    mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=mcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ELSEIF ((request->qa_slide_cnt > 0))
  UPDATE  FROM monthly_cytology_counts mcc
   SET mcc.unsat_cases =
    IF (band(qaflags,unsat)=unsat) (unsat_cases - 1)
    ELSE mcc.unsat_cases
    ENDIF
    , mcc.unsat_slides =
    IF (band(qaflags,unsat)=unsat) (unsat_slides - request->qa_slide_cnt)
    ELSE mcc.unsat_slides
    ENDIF
    , mcc.unsat_slides_requeued =
    IF (review_reason_flag=2) (unsat_slides_requeued - request->qa_slide_cnt)
    ELSE mcc.unsat_slides_requeued
    ENDIF
    ,
    mcc.normal_cases =
    IF (band(qaflags,norm)=norm) (normal_cases - 1)
    ELSE mcc.normal_cases
    ENDIF
    , mcc.normal_slides =
    IF (band(qaflags,norm)=norm) (normal_slides - request->qa_slide_cnt)
    ELSE mcc.normal_slides
    ENDIF
    , mcc.normal_slides_requeued =
    IF (review_reason_flag=3) (normal_slides_requeued - request->qa_slide_cnt)
    ELSE mcc.normal_slides_requeued
    ENDIF
    ,
    mcc.prev_atypical_cases =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_cases - 1)
    ELSE mcc.prev_atypical_cases
    ENDIF
    , mcc.prev_atypical_slides =
    IF (band(qaflags,atyp)=atyp) (prev_atypical_slides - request->qa_slide_cnt)
    ELSE mcc.prev_atypical_slides
    ENDIF
    , mcc.prev_atyp_slides_requeued =
    IF (review_reason_flag=4) (prev_atyp_slides_requeued - request->qa_slide_cnt)
    ELSE mcc.prev_atyp_slides_requeued
    ENDIF
    ,
    mcc.prev_abnormal_cases =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_cases - 1)
    ELSE mcc.prev_abnormal_cases
    ENDIF
    , mcc.prev_abnormal_slides =
    IF (band(qaflags,abnorm)=abnorm) (prev_abnormal_slides - request->qa_slide_cnt)
    ELSE mcc.prev_abnormal_slides
    ENDIF
    , mcc.prev_abn_slides_requeued =
    IF (review_reason_flag=5) (prev_abn_slides_requeued - request->qa_slide_cnt)
    ELSE mcc.prev_abn_slides_requeued
    ENDIF
    ,
    mcc.chr_cases =
    IF (band(qaflags,chr)=chr) (chr_cases - 1)
    ELSE mcc.chr_cases
    ENDIF
    , mcc.chr_slides =
    IF (band(qaflags,chr)=chr) (chr_slides - request->qa_slide_cnt)
    ELSE mcc.chr_slides
    ENDIF
    , mcc.chr_slides_requeued =
    IF (review_reason_flag=6) (chr_slides_requeued - request->qa_slide_cnt)
    ELSE mcc.chr_slides_requeued
    ENDIF
    ,
    mcc.user_preference_cases =
    IF (review_reason_flag=8) (user_preference_cases - 1)
    ELSE mcc.user_preference_cases
    ENDIF
    , mcc.user_preference_slides =
    IF (review_reason_flag=8) (user_preference_slides - request->qa_slide_cnt)
    ELSE mcc.user_preference_slides
    ENDIF
    , mcc.updt_dt_tm = cnvtdatetime(curdate,curtime),
    mcc.updt_id = reqinfo->updt_id, mcc.updt_task = reqinfo->updt_task, mcc.updt_applctx = reqinfo->
    updt_applctx,
    mcc.updt_cnt = (cur_updt_cnt+ 1)
   WHERE (request->screener_id=mcc.prsnl_id)
    AND cnvtdatetime(dtemp->beg_of_month_abs)=mcc.record_dt_tm
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
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
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_of_program
END GO
