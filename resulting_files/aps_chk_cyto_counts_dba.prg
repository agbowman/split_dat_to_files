CREATE PROGRAM aps_chk_cyto_counts:dba
 RECORD temp(
   1 first_day_of_month = dq8
   1 normal_percentage = i4
   1 normal_requeue_rank = i2
   1 abnormal_percentage = i4
   1 abnormal_requeue_rank = i2
   1 chr_percentage = i4
   1 chr_requeue_rank = i2
   1 atypical_percentage = i4
   1 atypical_requeue_rank = i2
   1 unsat_percentage = i4
   1 slide_limit = f8
   1 screening_hours = f8
   1 d_screen_hours = f8
   1 d_gyn_slides_is = f8
   1 d_gyn_slides_rs = f8
   1 d_ngyn_slides_is = f8
   1 d_ngyn_slides_rs = f8
   1 d_outside_hours = f8
   1 d_outside_gyn_is = f8
   1 d_outside_gyn_rs = f8
   1 d_outside_ngyn_is = f8
   1 d_outside_ngyn_rs = f8
   1 d_normal_slides = f8
   1 d_normal_slides_rq = f8
   1 d_prev_atypical_slides = f8
   1 d_prev_atypical_slides_rq = f8
   1 d_prev_abnormal_slides = f8
   1 d_prev_abnormal_slides_rq = f8
   1 d_unsat_slides = f8
   1 d_unsat_slides_rq = f8
   1 m_screen_hours = f8
   1 m_gyn_slides_is = f8
   1 m_gyn_slides_rs = f8
   1 m_ngyn_slides_is = f8
   1 m_ngyn_slides_rs = f8
   1 m_outside_hours = f8
   1 m_outside_gyn_is = f8
   1 m_outside_gyn_rs = f8
   1 m_outside_ngyn_is = f8
   1 m_outside_ngyn_rs = f8
   1 m_normal_slides = f8
   1 m_normal_slides_rq = f8
   1 m_prev_atypical_slides = f8
   1 m_prev_atypical_slides_rq = f8
   1 m_prev_abnormal_slides = f8
   1 m_prev_abnormal_slides_rq = f8
   1 m_unsat_slides = f8
   1 m_unsat_slides_rq = f8
   1 m_chr_slides = f8
   1 m_chr_slides_rq = f8
 )
 RECORD reply(
   1 qaflag_bitword = i2
   1 fail_reason = i2
   1 dserviceresourcecd = f8
   1 nprevqaflagbitword = i2
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
 SET failed = "F"
 SET error_cnt = 0
 SET reply->qaflag_bitword = 0
 SET ranking[4] = "   "
 SET monthis = format(cnvtdatetime(request->screening_date),"mmm;;d")
 SET yearis = cnvtint(year(request->screening_date))
 SET firstofmonth = build("01-",monthis,"-",yearis," 00:00:00.00")
 SET temp->first_day_of_month = cnvtdatetime(firstofmonth)
 CALL getstartofdayabs(request->screening_date,0)
 CALL getstartofmonthabs(request->screening_date,0)
 DECLARE nrowexists = i2 WITH protect, noconstant(0)
 DECLARE nfailreasonflag = i2 WITH protect, noconstant(0)
 DECLARE dserviceresourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcasetypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dnongyntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dgyntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE ninitialverify = i2 WITH protect, noconstant(0)
 DECLARE dscreenerid = f8 WITH protect, noconstant(0.0)
 DECLARE npreviousreasonexists = i2 WITH protect, noconstant(0)
 DECLARE nprevqaflags = i2 WITH protect, noconstant(0)
 DECLARE dabnormalcd = f8 WITH protect, noconstant(0.0)
 DECLARE datypicalcd = f8 WITH protect, noconstant(0.0)
 DECLARE dnormalcd = f8 WITH protect, noconstant(0.0)
 DECLARE dpersonid = f8 WITH protect, noconstant(0.0)
 SET qaflags = 0
 SET unsat = 1
 SET norm = 2
 SET abnorm = 4
 SET atyp = 8
 SET chr = 16
 SET dnongyntypecd = uar_get_code_by("MEANING",1301,"NGYN")
 IF (dnongyntypecd=0)
  CALL handle_errors("UAR","F","1301","NGYN")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET dgyntypecd = uar_get_code_by("MEANING",1301,"GYN")
 IF (dgyntypecd=0)
  CALL handle_errors("UAR","F","1301","GYN")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET dabnormalcd = uar_get_code_by("MEANING",1316,"ABNORMAL")
 IF (dabnormalcd=0)
  CALL handle_errors("UAR","F","1316","ABNORMAL")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET datypicalcd = uar_get_code_by("MEANING",1316,"ATYPICAL")
 IF (datypicalcd=0)
  CALL handle_errors("UAR","F","1316","ATYPICAL")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET dnormalcd = uar_get_code_by("MEANING",1316,"NORMAL")
 IF (dnormalcd=0)
  CALL handle_errors("UAR","F","1316","NORMAL")
  SET reply->status_data.status = "Z"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (trim(request->cdf_mean)="")
  SET request->cdf_mean = "CYTOTECH"
 ENDIF
 SELECT INTO "nl:"
  css.active_ind, css.updt_cnt, csl.sequence,
  csl.slide_limit, csl.screening_hours, csl.updt_cnt
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
    AND (((request->cdf_mean="PATHOLOGIST")) OR ((request->cdf_mean="PATHRESIDENT"))) )
   ))
  HEAD REPORT
   ntemp = initarray(ranking,"   ")
  DETAIL
   IF ((request->cdf_mean="CYTOTECH"))
    temp->normal_percentage = css.normal_percentage, temp->normal_requeue_rank = css
    .normal_requeue_rank, ranking[css.normal_requeue_rank] = "nor",
    temp->abnormal_percentage = css.abnormal_percentage, temp->abnormal_requeue_rank = css
    .abnormal_requeue_rank, ranking[css.abnormal_requeue_rank] = "abn",
    temp->chr_percentage = css.chr_percentage, temp->chr_requeue_rank = css.chr_requeue_rank, ranking
    [css.chr_requeue_rank] = "chr",
    temp->atypical_percentage = css.atypical_percentage, temp->atypical_requeue_rank = css
    .atypical_requeue_rank, ranking[css.atypical_requeue_rank] = "aty",
    temp->unsat_percentage = css.unsat_percentage, temp->slide_limit = csl.slide_limit, temp->
    screening_hours = csl.screening_hours,
    reply->requeue_flag = 1
   ELSE
    temp->slide_limit = csl1.slide_limit, temp->screening_hours = csl1.screening_hours, reply->
    requeue_flag = csl1.requeue_flag
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dcc.screen_hours, dcc.gyn_slides_is, dcc.gyn_slides_rs,
  dcc.ngyn_slides_is, dcc.ngyn_slides_rs, dcc.updt_cnt,
  mcc.gyn_slides_is
  FROM daily_cytology_counts dcc,
   monthly_cytology_counts mcc
  PLAN (dcc
   WHERE (dcc.prsnl_id=request->prsnl_id)
    AND dcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_day_abs))
   JOIN (mcc
   WHERE dcc.prsnl_id=mcc.prsnl_id
    AND mcc.record_dt_tm=cnvtdatetime(dtemp->beg_of_month_abs))
  DETAIL
   temp->d_screen_hours = dcc.screen_hours, temp->d_gyn_slides_is = dcc.gyn_slides_is, temp->
   d_gyn_slides_rs = dcc.gyn_slides_rs,
   temp->d_ngyn_slides_is = dcc.ngyn_slides_is, temp->d_ngyn_slides_rs = dcc.ngyn_slides_rs, temp->
   d_outside_hours = dcc.outside_hours,
   temp->d_outside_gyn_is = dcc.outside_gyn_is, temp->d_outside_gyn_rs = dcc.outside_gyn_rs, temp->
   d_outside_ngyn_is = dcc.outside_ngyn_is,
   temp->d_outside_ngyn_rs = dcc.outside_ngyn_rs, temp->d_normal_slides = dcc.normal_slides, temp->
   d_normal_slides_rq = dcc.normal_slides_requeued,
   temp->d_prev_atypical_slides = dcc.prev_atypical_slides, temp->d_prev_atypical_slides_rq = dcc
   .prev_atyp_slides_requeued, temp->d_prev_abnormal_slides = dcc.prev_abnormal_slides,
   temp->d_prev_abnormal_slides_rq = dcc.prev_abn_slides_requeued, temp->d_unsat_slides = dcc
   .unsat_slides, temp->d_unsat_slides_rq = dcc.unsat_slides_requeued,
   temp->m_gyn_slides_is = mcc.gyn_slides_is, temp->m_gyn_slides_rs = mcc.gyn_slides_rs, temp->
   m_ngyn_slides_is = mcc.ngyn_slides_is,
   temp->m_ngyn_slides_rs = mcc.ngyn_slides_rs, temp->m_outside_hours = mcc.outside_hours, temp->
   m_outside_gyn_is = mcc.outside_gyn_is,
   temp->m_outside_gyn_rs = mcc.outside_gyn_rs, temp->m_outside_ngyn_is = mcc.outside_ngyn_is, temp->
   m_outside_ngyn_rs = mcc.outside_ngyn_rs,
   temp->m_normal_slides = mcc.normal_slides, temp->m_normal_slides_rq = mcc.normal_slides_requeued,
   temp->m_prev_atypical_slides = mcc.prev_atypical_slides,
   temp->m_prev_atypical_slides_rq = mcc.prev_atyp_slides_requeued, temp->m_prev_abnormal_slides =
   mcc.prev_abnormal_slides, temp->m_prev_abnormal_slides_rq = mcc.prev_abn_slides_requeued,
   temp->m_unsat_slides = mcc.unsat_slides, temp->m_unsat_slides_rq = mcc.unsat_slides_requeued, temp
   ->m_chr_slides = mcc.chr_slides,
   temp->m_chr_slides_rq = mcc.chr_slides_requeued
  WITH nocounter
 ;end select
 IF (curqual=0
  AND (request->cdf_mean="CYTOTECH"))
  CALL handle_errors("SELECT","Z","TABLE","DAILY_CYTOLOGY_COUNT")
  SET reply->status_data.status = "Z"
  SET failed = "T"
 ENDIF
 SET max_slides = 0.0
 SET reply->fail_reason = 0
 SET rank = 0
 SET whereto = "   "
 SET total_slides = 0.0
 SET total_slides = (((((((temp->d_gyn_slides_is+ temp->d_gyn_slides_rs)+ temp->d_ngyn_slides_is)+
 temp->d_ngyn_slides_rs)+ temp->d_outside_gyn_is)+ temp->d_outside_gyn_rs)+ temp->d_outside_ngyn_is)
 + temp->d_outside_ngyn_rs)
 IF (curqual > 0)
  SET max_slides = cnvtreal(((cnvtreal(temp->d_screen_hours)/ cnvtreal(temp->screening_hours)) * temp
   ->slide_limit))
 ELSE
  SET max_slides = temp->slide_limit
 ENDIF
 IF ((request->case_id > 0)
  AND (request->cdf_mean="CYTOTECH"))
  SELECT INTO "nl:"
   pc.case_type_cd
   FROM pathology_case pc
   WHERE (pc.case_id=request->case_id)
   DETAIL
    dcasetypecd = pc.case_type_cd, dpersonid = pc.person_id
   WITH nocounter
  ;end select
  IF (dcasetypecd=dgyntypecd)
   SET request->norm_hist_ind = 0
   SET request->atypical_hist_ind = 0
   SET request->abnormal_hist_ind = 0
   SELECT INTO "nl:"
    qa.flag_type_cd
    FROM ap_qa_info qa,
     pathology_case pc
    PLAN (qa
     WHERE qa.person_id=dpersonid
      AND qa.active_ind=1
      AND qa.flag_type_cd IN (dabnormalcd, datypicalcd, dnormalcd))
     JOIN (pc
     WHERE pc.case_id=qa.case_id
      AND pc.case_type_cd=dgyntypecd)
    DETAIL
     CASE (qa.flag_type_cd)
      OF dabnormalcd:
       request->abnormal_hist_ind = 1
      OF datypicalcd:
       request->atypical_hist_ind = 1
      OF dnormalcd:
       request->norm_hist_ind = 1
     ENDCASE
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   cse.sequence
   FROM report_task rt,
    cyto_screening_event cse
   PLAN (rt
    WHERE (rt.report_id=request->report_id))
    JOIN (cse
    WHERE (cse.case_id=request->case_id)
     AND cse.review_reason_flag != 1
     AND cse.review_reason_flag != 8
     AND (cse.sequence=
    (SELECT
     max(cse2.sequence)
     FROM cyto_screening_event cse2
     WHERE (cse2.case_id=request->case_id)))
     AND (cse.screener_id=request->prsnl_id))
   DETAIL
    reply->fail_reason = cse.review_reason_flag
    IF ((request->report_id=0))
     reply->dserviceresourcecd = cse.service_resource_cd
    ELSE
     reply->dserviceresourcecd = rt.service_resource_cd
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   IF ((reply->fail_reason != 0))
    IF (dcasetypecd=dgyntypecd)
     IF ((request->unsat_ind=1))
      SET qaflags = (qaflags+ unsat)
     ENDIF
     IF ((request->prev_unsat_ind=1))
      SET nprevqaflags = (nprevqaflags+ unsat)
     ENDIF
     IF (qaflags > 0
      AND nprevqaflags > 0)
      GO TO exit_script
     ENDIF
     IF ((((request->norm_hist_ind IN (1, - (1)))) OR ((request->norm_hist_ind=0)
      AND (request->atypical_hist_ind=0)
      AND (request->abnormal_hist_ind=0))) )
      IF ((request->unsat_ind=0))
       SET qaflags = (qaflags+ norm)
      ENDIF
      IF ((request->prev_unsat_ind=0))
       SET nprevqaflags = (nprevqaflags+ norm)
      ENDIF
     ENDIF
     IF ((request->atypical_hist_ind IN (1, - (1))))
      IF ((request->unsat_ind=0))
       SET qaflags = (qaflags+ atyp)
      ENDIF
      IF ((request->prev_unsat_ind=0))
       SET nprevqaflags = (nprevqaflags+ atyp)
      ENDIF
     ENDIF
     IF ((request->abnormal_hist_ind IN (1, - (1))))
      IF ((request->unsat_ind=0))
       SET qaflags = (qaflags+ abnorm)
      ENDIF
      IF ((request->prev_unsat_ind=0))
       SET nprevqaflags = (nprevqaflags+ abnorm)
      ENDIF
     ENDIF
     IF ((request->chr_ind IN (1, - (1))))
      IF ((request->unsat_ind=0))
       SET qaflags = (qaflags+ chr)
      ENDIF
     ENDIF
     IF ((request->prev_chr_ind IN (1, - (1))))
      IF ((request->prev_unsat_ind=0))
       SET nprevqaflags = (nprevqaflags+ chr)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((total_slides+ request->case_slide_cnt) > max_slides))
  SET reply->fail_reason = 1
  GO TO exit_script
 ELSEIF (((dcasetypecd=dnongyntypecd) OR ((request->check_all_ind=0))) )
  GO TO exit_script
 ENDIF
 IF ((request->case_id > 0))
  SELECT INTO "nl:"
   FROM cyto_screening_event cse
   WHERE (cse.case_id=request->case_id)
   DETAIL
    nrowexists = 1
   WITH nocounter
  ;end select
  IF (nrowexists=1)
   SELECT INTO "nl:"
    cse.sequence
    FROM cyto_screening_event cse
    WHERE (cse.case_id=request->case_id)
     AND (cse.sequence=
    (SELECT
     max(cse2.sequence)
     FROM cyto_screening_event cse2
     WHERE (cse2.case_id=request->case_id)))
     AND cse.initial_screener_ind=1
    DETAIL
     IF ((cse.screener_id=request->prsnl_id))
      dscreenerid = cse.screener_id
     ENDIF
    WITH nocounter
   ;end select
   IF ((dscreenerid != request->prsnl_id))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->unsat_ind=1))
  SET qaflags = (qaflags+ unsat)
  IF ((reply->fail_reason=0)
   AND (temp->unsat_percentage != 0))
   IF ((((temp->m_unsat_slides_rq/ temp->m_unsat_slides) * 100) < temp->unsat_percentage))
    SET reply->fail_reason = 2
    GO TO exit_script
   ENDIF
   IF ((temp->unsat_percentage=100))
    SET reply->fail_reason = 2
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#checkrank
 SET rank = (rank+ 1)
 IF (rank > 4)
  GO TO exit_script
 ENDIF
 SET whereto = cnvtlower(trim(ranking[rank]))
 IF (whereto=" ")
  GO TO checkrank
 ELSE
  IF (whereto="nor")
   GO TO nor
  ELSEIF (whereto="aty")
   GO TO aty
  ELSEIF (whereto="abn")
   GO TO abn
  ELSEIF (whereto="chr")
   GO TO chr
  ENDIF
 ENDIF
#nor
 IF ((((request->norm_hist_ind IN (1, - (1)))) OR ((request->norm_hist_ind=0)
  AND (request->atypical_hist_ind=0)
  AND (request->abnormal_hist_ind=0))) )
  SET qaflags = (qaflags+ norm)
  IF ((reply->fail_reason=0)
   AND (temp->normal_percentage != 0))
   IF ((temp->normal_percentage=100))
    SET reply->fail_reason = 3
   ELSEIF ((((temp->m_normal_slides_rq/ temp->m_normal_slides) * 100) < temp->normal_percentage))
    SET reply->fail_reason = 3
   ENDIF
  ENDIF
 ENDIF
 GO TO checkrank
#aty
 IF ((request->atypical_hist_ind IN (1, - (1))))
  SET qaflags = (qaflags+ atyp)
  IF ((reply->fail_reason=0)
   AND (temp->atypical_percentage != 0))
   IF ((temp->atypical_percentage=100))
    SET reply->fail_reason = 4
   ELSEIF ((((temp->m_prev_atypical_slides_rq/ temp->m_prev_atypical_slides) * 100) < temp->
   atypical_percentage))
    SET reply->fail_reason = 4
   ENDIF
  ENDIF
 ENDIF
 GO TO checkrank
#abn
 IF ((request->abnormal_hist_ind IN (1, - (1))))
  SET qaflags = (qaflags+ abnorm)
  IF ((reply->fail_reason=0)
   AND (temp->abnormal_percentage != 0))
   IF ((temp->abnormal_percentage=100))
    SET reply->fail_reason = 5
   ELSEIF ((((temp->m_prev_abnormal_slides_rq/ temp->m_prev_abnormal_slides) * 100) < temp->
   abnormal_percentage))
    SET reply->fail_reason = 5
   ENDIF
  ENDIF
 ENDIF
 GO TO checkrank
#chr
 IF ((request->chr_ind IN (1, - (1))))
  SET qaflags = (qaflags+ chr)
  IF ((reply->fail_reason=0)
   AND (temp->chr_percentage != 0))
   IF ((temp->chr_percentage=100))
    SET reply->fail_reason = 6
   ELSEIF ((((temp->m_chr_slides_rq/ temp->m_chr_slides) * 100) < temp->chr_percentage))
    SET reply->fail_reason = 6
   ENDIF
  ENDIF
 ENDIF
 GO TO checkrank
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
 SET reply->qaflag_bitword = qaflags
 SET reply->nprevqaflagbitword = nprevqaflags
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
END GO
