CREATE PROGRAM aps_add_chg_diag_corr_events:dba
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
 RECORD temp(
   1 comment_qual[*]
     2 comment_id = f8
     2 comment = vc
   1 prsnl_add_qual[*]
     2 event_id = f8
     2 prsnl_group_id = f8
     2 prsnl_id = f8
   1 prsnl_chg_qual[*]
     2 event_id = f8
     2 prsnl_group_id = f8
     2 prsnl_id = f8
   1 prsnl_del_qual[*]
     2 event_id = f8
     2 prsnl_group_id = f8
     2 prsnl_id = f8
   1 counts_qual[*]
     2 apply_id = f8
     2 apply_day = dq8
     2 apply_month = dq8
     2 apply_count = f8
     2 null_daily_slide_cnts_ind = i2
     2 null_monthly_slide_cnts_ind = i2
 )
#script
 DECLARE x = i2
 DECLARE y = i2
 DECLARE z = i2
 DECLARE event_cnt = i2
 DECLARE found_ind = i2
 DECLARE error_cnt = i2
 DECLARE cnt = i2
 DECLARE add_cnt = i2 WITH private, noconstant(0)
 DECLARE chg_cnt = i2 WITH private, noconstant(0)
 DECLARE del_cnt = i2 WITH private, noconstant(0)
 DECLARE apply_qual_idx = i2 WITH private, noconstant(0)
 DECLARE apply_counts_prsnl_id = f8
 DECLARE curr_complete_prsnl_id = f8
 DECLARE apply_slide_counts_cnt = i2
 DECLARE prsnl_is_pathologist_ind = i2
 DECLARE prsnl_add_cnt = i2
 DECLARE prsnl_chg_cnt = i2
 DECLARE prsnl_del_cnt = i2
 DECLARE updt_cnt_err = i2
 DECLARE curr_event_id = f8 WITH protect, noconstant(0.0)
 SET error_cnt = 0
 SET reqinfo->commit_ind = 0
 IF (validate(req200402->called_from_script_ind,- (1)) != 1)
  RECORD reply(
    1 event_qual[*]
      2 event_id = f8
      2 long_text_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET event_cnt = cnvtint(size(request->event_qual,5))
  SET stat = alterlist(reply->event_qual,event_cnt)
  SET curalias request_corr_events request->event_qual[x]
  SET curalias request_corr_events_seq request->event_qual[d.seq]
  SET curalias reply_corr_events reply->event_qual[x]
  SET curalias reply_corr_events_seq reply->event_qual[d.seq]
  SET curalias reply_status reply->status_data
 ELSE
  SET event_cnt = cnvtint(size(req200402->event_qual,5))
  SET stat = alterlist(reply200402->event_qual,event_cnt)
  SET curalias request_corr_events req200402->event_qual[x]
  SET curalias request_corr_events_seq req200402->event_qual[d.seq]
  SET curalias reply_corr_events reply200402->event_qual[x]
  SET curalias reply_corr_events_seq reply200402->event_qual[d.seq]
  SET curalias reply_status reply200402->status_data
 ENDIF
 SET reply_status->status = "F"
 SET stat = alterlist(temp->comment_qual,event_cnt)
 SET apply_slide_counts_cnt = 0
 FOR (x = 1 TO event_cnt)
   SET curr_complete_prsnl_id = 0.0
   SET curr_event_id = 0.0
   CALL getstartofdayabs(request_corr_events->complete_dt_tm,0)
   SET request_corr_events->complete_day_dt_tm = dtemp->beg_of_day_abs
   IF ((request_corr_events->add_ind != 0))
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      curr_event_id = seq_nbr
     WITH format, counter
    ;end select
    IF (curqual=0)
     CALL handle_errors("SEQ_FAILED","F","SEQUENCE","PATHNET_SEQ")
     GO TO exit_script
    ENDIF
    SET reply_corr_events->event_id = curr_event_id
    SET add_cnt = (add_cnt+ 1)
   ELSEIF ((request_corr_events->upd_ind != 0))
    SET reply_corr_events->event_id = request_corr_events->event_id
    SET curr_event_id = reply_corr_events->event_id
    SET chg_cnt = (chg_cnt+ 1)
    IF ((request_corr_events->complete_prsnl_id != 0))
     SELECT INTO "nl:"
      ade.complete_prsnl_id
      FROM ap_dc_event ade
      PLAN (ade
       WHERE ade.event_id=curr_event_id)
      DETAIL
       curr_complete_prsnl_id = ade.complete_prsnl_id
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF ((request_corr_events->del_ind != 0))
    SET reply_corr_events->event_id = request_corr_events->event_id
    SET curr_event_id = reply_corr_events->event_id
    SET del_cnt = (del_cnt+ 1)
    IF ((request_corr_events->complete_prsnl_id != 0))
     SELECT INTO "nl:"
      ade.complete_prsnl_id
      FROM ap_dc_event ade
      PLAN (ade
       WHERE ade.event_id=curr_event_id)
      DETAIL
       curr_complete_prsnl_id = ade.complete_prsnl_id
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (curr_event_id != 0)
    FOR (y = 1 TO cnvtint(size(request_corr_events->prsnl_qual,5)))
      SET request_corr_events->prsnl_qual[y].temp_ind = 1
    ENDFOR
    IF ((request_corr_events->complete_prsnl_id != 0)
     AND (request_corr_events->slide_counts != 0)
     AND curr_complete_prsnl_id=0)
     SET apply_counts_prsnl_id = request_corr_events->prsnl_qual[1].prsnl_id
     SET apply_qual_idx = 0
     SET prsnl_is_pathologist_ind = 0
     FOR (z = 1 TO apply_slide_counts_cnt)
       IF ((temp->counts_qual[z].apply_day=request_corr_events->complete_day_dt_tm)
        AND (temp->counts_qual[z].apply_id=apply_counts_prsnl_id))
        SET apply_qual_idx = z
       ENDIF
     ENDFOR
     IF (apply_qual_idx=0)
      SELECT INTO "nl:"
       c.display, pgr.prsnl_group_reltn_id
       FROM code_value c,
        prsnl_group pg,
        prsnl_group_reltn pgr
       PLAN (c
        WHERE 357=c.code_set
         AND c.cdf_meaning IN ("PATHOLOGIST")
         AND c.active_ind=1)
        JOIN (pg
        WHERE c.code_value=pg.prsnl_group_type_cd
         AND pg.active_ind=1
         AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
         AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
        JOIN (pgr
        WHERE pg.prsnl_group_id=pgr.prsnl_group_id
         AND pgr.person_id=apply_counts_prsnl_id
         AND 1=pgr.active_ind)
       DETAIL
        prsnl_is_pathologist_ind = 1
       WITH nocounter
      ;end select
      IF (prsnl_is_pathologist_ind=0)
       SET apply_slide_counts_cnt = (apply_slide_counts_cnt+ 1)
       SET stat = alterlist(temp->counts_qual,apply_slide_counts_cnt)
       SET apply_qual_idx = apply_slide_counts_cnt
       SET temp->counts_qual[apply_qual_idx].apply_id = apply_counts_prsnl_id
       SET temp->counts_qual[apply_qual_idx].apply_day = request_corr_events->complete_day_dt_tm
       CALL getstartofmonthabs(request_corr_events->complete_dt_tm,0)
       SET temp->counts_qual[apply_qual_idx].apply_month = dtemp->beg_of_month_abs
       SET temp->counts_qual[apply_qual_idx].apply_count = 0
      ENDIF
     ENDIF
     IF (prsnl_is_pathologist_ind=0)
      SET temp->counts_qual[apply_qual_idx].apply_count = (temp->counts_qual[apply_qual_idx].
      apply_count+ request_corr_events->slide_counts)
      SET temp->counts_qual[apply_qual_idx].null_daily_slide_cnts_ind = 0
      SET temp->counts_qual[apply_qual_idx].null_monthly_slide_cnts_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF ((((request_corr_events->upd_ind != 0)) OR ((request_corr_events->del_ind != 0))) )
    SET prsnl_chg_cnt = 0
    SET stat = alterlist(temp->prsnl_chg_qual,0)
    SELECT INTO "nl:"
     adep.event_id
     FROM ap_dc_event_prsnl adep
     PLAN (adep
      WHERE adep.event_id=curr_event_id
       AND adep.event_id != 0.0
       AND adep.prsnl_id != 0.0)
     HEAD REPORT
      prsnl_chg_cnt = 0
     DETAIL
      prsnl_chg_cnt = (prsnl_chg_cnt+ 1)
      IF (mod(prsnl_chg_cnt,10)=1)
       stat = alterlist(temp->prsnl_chg_qual,(prsnl_chg_cnt+ 10))
      ENDIF
      temp->prsnl_chg_qual[prsnl_chg_cnt].event_id = adep.event_id, temp->prsnl_chg_qual[
      prsnl_chg_cnt].prsnl_group_id = adep.prsnl_group_id, temp->prsnl_chg_qual[prsnl_chg_cnt].
      prsnl_id = adep.prsnl_id
     WITH nocounter
    ;end select
    FOR (y = 1 TO prsnl_chg_cnt)
      SET found_ind = 0
      FOR (z = 1 TO cnvtint(size(request_corr_events->prsnl_qual,5)))
        IF ((request_corr_events->prsnl_qual[z].prsnl_id=temp->prsnl_chg_qual[y].prsnl_id)
         AND (request_corr_events->prsnl_group_id=temp->prsnl_chg_qual[y].prsnl_group_id)
         AND (request_corr_events->del_ind=0))
         SET request_corr_events->prsnl_qual[z].temp_ind = 0
         SET found_ind = 1
        ENDIF
      ENDFOR
      IF (found_ind=0)
       SET prsnl_del_cnt = (prsnl_del_cnt+ 1)
       IF (mod(prsnl_del_cnt,10)=1)
        SET stat = alterlist(temp->prsnl_del_qual,(prsnl_del_cnt+ 10))
       ENDIF
       SET temp->prsnl_del_qual[prsnl_del_cnt].event_id = curr_event_id
       SET temp->prsnl_del_qual[prsnl_del_cnt].prsnl_group_id = temp->prsnl_chg_qual[y].
       prsnl_group_id
       SET temp->prsnl_del_qual[prsnl_del_cnt].prsnl_id = temp->prsnl_chg_qual[y].prsnl_id
      ENDIF
    ENDFOR
    SET stat = alterlist(temp->prsnl_chg_qual,0)
   ENDIF
   FOR (y = 1 TO cnvtint(size(request_corr_events->prsnl_qual,5)))
     IF ((request_corr_events->prsnl_qual[y].temp_ind=1)
      AND (request_corr_events->del_ind=0))
      SET prsnl_add_cnt = (prsnl_add_cnt+ 1)
      IF (mod(prsnl_add_cnt,10)=1)
       SET stat = alterlist(temp->prsnl_add_qual,(prsnl_add_cnt+ 10))
      ENDIF
      SET temp->prsnl_add_qual[prsnl_add_cnt].event_id = reply_corr_events->event_id
      SET temp->prsnl_add_qual[prsnl_add_cnt].prsnl_group_id = request_corr_events->prsnl_group_id
      SET temp->prsnl_add_qual[prsnl_add_cnt].prsnl_id = request_corr_events->prsnl_qual[y].prsnl_id
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(temp->prsnl_add_qual,prsnl_add_cnt)
 SET stat = alterlist(temp->prsnl_del_qual,prsnl_del_cnt)
 SELECT INTO "nl:"
  ade.event_id
  FROM ap_dc_event ade,
   (dummyt d  WITH seq = value(event_cnt))
  PLAN (d)
   JOIN (ade
   WHERE (ade.event_id=reply_corr_events_seq->event_id)
    AND ade.event_id != 0.0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (ade.long_text_id != 0.0)
    temp->comment_qual[d.seq].comment_id = ade.long_text_id
   ENDIF
   IF ((ade.updt_cnt != request_corr_events_seq->updt_cnt))
    updt_cnt_err = 1
   ENDIF
  WITH nocounter, forupdate(ade)
 ;end select
 IF ((cnt != (chg_cnt+ del_cnt)))
  CALL handle_errors("LOCK","F","TABLE","AP_DC_EVENT")
  GO TO exit_script
 ENDIF
 IF (updt_cnt_err=1)
  CALL handle_errors("COUNTS","F","TABLE","AP_DC_EVENT")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d  WITH seq = value(event_cnt)),
   long_text lt
  PLAN (d)
   JOIN (lt
   WHERE (lt.long_text_id=temp->comment_qual[d.seq].comment_id)
    AND (temp->comment_qual[d.seq].comment_id != 0.0))
  DETAIL
   temp->comment_qual[d.seq].comment = lt.long_text
  WITH nocounter
 ;end select
 FOR (x = 1 TO event_cnt)
   IF ((reply_corr_events->event_id != 0))
    IF ((request_corr_events->long_text_id != 0.0)
     AND (((request_corr_events->comment="")) OR ((request_corr_events->del_ind != 0))) )
     SET temp->comment_qual[x].comment_id = 0.0
    ELSEIF ((request_corr_events->comment != "")
     AND (temp->comment_qual[x].comment_id=0.0)
     AND (request_corr_events->del_ind=0))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       temp->comment_qual[x].comment_id = seq_nbr
      WITH format, counter
     ;end select
     IF (curqual=0)
      CALL handle_errors("NEXTVAL","F","SEQ","LONG_DATA_SEQ")
      GO TO exit_script
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = temp->comment_qual[x].comment_id, lt.long_text = request_corr_events->
       comment, lt.parent_entity_name = "AP_DC_EVENT",
       lt.parent_entity_id = reply_corr_events->event_id, lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 1)
      CALL handle_errors("INSERT","F","TABLE","LONG_TEXT")
      GO TO exit_script
     ENDIF
    ELSEIF ((request_corr_events->comment != "")
     AND (request_corr_events->comment != temp->comment_qual[x].comment))
     UPDATE  FROM long_text lt
      SET lt.long_text = request_corr_events->comment, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
       .updt_cnt+ 1)
      WHERE (lt.long_text_id=temp->comment_qual[x].comment_id)
       AND lt.long_text_id != 0.0
      WITH nocounter
     ;end update
     IF (curqual != 1)
      CALL handle_errors("UPDATE","F","TABLE","LONG_TEXT")
      GO TO exit_script
     ENDIF
    ENDIF
    SET reply_corr_events->long_text_id = temp->comment_qual[x].comment_id
   ENDIF
 ENDFOR
 IF (apply_slide_counts_cnt != 0)
  INSERT  FROM daily_cytology_counts dcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   SET dcc.prsnl_id = temp->counts_qual[d.seq].apply_id, dcc.record_dt_tm = cnvtdatetime(temp->
     counts_qual[d.seq].apply_day), dcc.outside_hours = 0,
    dcc.screen_hours = 0, dcc.gyn_slides_is = 0, dcc.gyn_slides_rs = 0,
    dcc.ngyn_slides_is = 0, dcc.ngyn_slides_rs = 0, dcc.comments = "",
    dcc.outside_gyn_is = 0, dcc.outside_gyn_rs = 0, dcc.outside_ngyn_is = 0,
    dcc.outside_ngyn_rs = 0, dcc.updt_dt_tm = cnvtdatetime(curdate,curtime), dcc.updt_id = reqinfo->
    updt_id,
    dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = 0
   PLAN (d)
    JOIN (dcc
    WHERE (dcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND dcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_day))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  SET cnt = 0
  SELECT INTO "nl:"
   dcc.prsnl_id
   FROM daily_cytology_counts dcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   PLAN (d)
    JOIN (dcc
    WHERE (dcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND dcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_day))
   DETAIL
    cnt = (cnt+ 1)
    IF (dcc.qa_slides=null)
     temp->counts_qual[d.seq].null_daily_slide_cnts_ind = 1
    ENDIF
   WITH nocounter, forupdate(dcc)
  ;end select
  IF (cnt != apply_slide_counts_cnt)
   CALL handle_errors("LOCK","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  UPDATE  FROM daily_cytology_counts dcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   SET dcc.qa_slides =
    IF ((temp->counts_qual[d.seq].null_daily_slide_cnts_ind=1)) temp->counts_qual[d.seq].apply_count
    ELSE (dcc.qa_slides+ temp->counts_qual[d.seq].apply_count)
    ENDIF
    , dcc.updt_dt_tm = cnvtdatetime(curdate,curtime), dcc.updt_id = reqinfo->updt_id,
    dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx, dcc.updt_cnt = 0
   PLAN (d)
    JOIN (dcc
    WHERE (dcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND dcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_day))
   WITH nocounter
  ;end update
  IF (curqual != apply_slide_counts_cnt)
   CALL handle_errors("UPDATE","F","TABLE","DAILY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  INSERT  FROM monthly_cytology_counts mcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   SET mcc.prsnl_id = temp->counts_qual[d.seq].apply_id, mcc.record_dt_tm = cnvtdatetime(temp->
     counts_qual[d.seq].apply_month), mcc.outside_hours = 0,
    mcc.screen_hours = 0, mcc.gyn_slides_is = 0, mcc.gyn_slides_rs = 0,
    mcc.ngyn_slides_is = 0, mcc.ngyn_slides_rs = 0, mcc.outside_gyn_is = 0,
    mcc.outside_gyn_rs = 0, mcc.outside_ngyn_is = 0, mcc.outside_ngyn_rs = 0,
    mcc.updt_dt_tm = cnvtdatetime(curdate,curtime), mcc.updt_id = reqinfo->updt_id, mcc.updt_task =
    reqinfo->updt_task,
    mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = 0
   PLAN (d)
    JOIN (mcc
    WHERE (mcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND mcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_month))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  SET cnt = 0
  SELECT INTO "nl:"
   mcc.prsnl_id
   FROM monthly_cytology_counts mcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   PLAN (d)
    JOIN (mcc
    WHERE (mcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND mcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_month))
   DETAIL
    cnt = (cnt+ 1)
    IF (mcc.qa_slides=null)
     temp->counts_qual[d.seq].null_monthly_slide_cnts_ind = 1
    ENDIF
   WITH nocounter, forupdate(mcc)
  ;end select
  IF (cnt != apply_slide_counts_cnt)
   CALL handle_errors("LOCK","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
  UPDATE  FROM monthly_cytology_counts mcc,
    (dummyt d  WITH seq = value(apply_slide_counts_cnt))
   SET mcc.qa_slides =
    IF ((temp->counts_qual[d.seq].null_monthly_slide_cnts_ind=1)) temp->counts_qual[d.seq].
     apply_count
    ELSE (mcc.qa_slides+ temp->counts_qual[d.seq].apply_count)
    ENDIF
    , mcc.updt_dt_tm = cnvtdatetime(curdate,curtime), mcc.updt_id = reqinfo->updt_id,
    mcc.updt_task = reqinfo->updt_task, mcc.updt_applctx = reqinfo->updt_applctx, mcc.updt_cnt = 0
   PLAN (d)
    JOIN (mcc
    WHERE (mcc.prsnl_id=temp->counts_qual[d.seq].apply_id)
     AND mcc.record_dt_tm=cnvtdatetime(temp->counts_qual[d.seq].apply_month))
   WITH nocounter
  ;end update
  IF (curqual != apply_slide_counts_cnt)
   CALL handle_errors("UPDATE","F","TABLE","MONTHLY_CYTOLOGY_COUNTS")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (prsnl_del_cnt > 0)
  DELETE  FROM ap_dc_event_prsnl adep,
    (dummyt d  WITH seq = value(prsnl_del_cnt))
   SET adep.event_id = temp->prsnl_del_qual[d.seq].event_id
   PLAN (d)
    JOIN (adep
    WHERE (adep.event_id=temp->prsnl_del_qual[d.seq].event_id)
     AND (adep.prsnl_group_id=temp->prsnl_del_qual[d.seq].prsnl_group_id)
     AND (adep.prsnl_id=temp->prsnl_del_qual[d.seq].prsnl_id))
   WITH nocounter
  ;end delete
  IF (curqual != prsnl_del_cnt)
   CALL handle_errors("DELETE","F","TABLE","AP_DC_EVENT_PRSNL")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (del_cnt > 0)
  DELETE  FROM ap_dc_event ade,
    (dummyt d  WITH seq = value(event_cnt))
   SET ade.event_id = reply_corr_events_seq->event_id
   PLAN (d
    WHERE (request_corr_events_seq->del_ind=1))
    JOIN (ade
    WHERE (ade.event_id=reply_corr_events_seq->event_id))
   WITH nocounter
  ;end delete
  IF (curqual != del_cnt)
   CALL handle_errors("DELETE","F","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (add_cnt > 0)
  INSERT  FROM ap_dc_event ade,
    (dummyt d  WITH seq = value(event_cnt))
   SET ade.event_id = reply_corr_events_seq->event_id, ade.study_id = request_corr_events_seq->
    study_id, ade.case_id = request_corr_events_seq->case_id,
    ade.correlate_case_id = request_corr_events_seq->correlate_case_id, ade.sys_corr_id =
    request_corr_events_seq->sys_corr_id, ade.init_eval_term_id = request_corr_events_seq->
    init_eval_term_id,
    ade.init_discrep_term_id = request_corr_events_seq->init_discrep_term_id, ade.disagree_reason_cd
     = request_corr_events_seq->disagree_reason_cd, ade.investigation_cd = request_corr_events_seq->
    investigation_cd,
    ade.resolution_cd = request_corr_events_seq->resolution_cd, ade.final_eval_term_id =
    request_corr_events_seq->final_eval_term_id, ade.final_discrep_term_id = request_corr_events_seq
    ->final_discrep_term_id,
    ade.initiated_prsnl_id = request_corr_events_seq->initiated_prsnl_id, ade.initiated_dt_tm =
    cnvtdatetime(request_corr_events_seq->initiated_dt_tm), ade.complete_prsnl_id =
    request_corr_events_seq->complete_prsnl_id,
    ade.complete_dt_tm =
    IF ((request_corr_events_seq->complete_prsnl_id != 0)) cnvtdatetime(request_corr_events_seq->
      complete_dt_tm)
    ELSE null
    ENDIF
    , ade.cancel_prsnl_id = request_corr_events_seq->cancel_prsnl_id, ade.cancel_dt_tm =
    IF ((request_corr_events_seq->cancel_prsnl_id != 0)) cnvtdatetime(request_corr_events_seq->
      cancel_dt_tm)
    ELSE null
    ENDIF
    ,
    ade.report_issued_by_prsnl_id = request_corr_events_seq->report_issued_by_prsnl_id, ade
    .slide_counts = request_corr_events_seq->slide_counts, ade.long_text_id = temp->comment_qual[d
    .seq].comment_id,
    ade.assign_to_group_ind = request_corr_events_seq->assign_to_group_ind, ade.prsnl_group_id =
    request_corr_events_seq->prsnl_group_id, ade.updt_dt_tm = cnvtdatetime(curdate,curtime),
    ade.updt_id = reqinfo->updt_id, ade.updt_task = reqinfo->updt_task, ade.updt_applctx = reqinfo->
    updt_applctx,
    ade.updt_cnt = 1
   PLAN (d
    WHERE (request_corr_events_seq->add_ind=1))
    JOIN (ade
    WHERE (ade.event_id=reply_corr_events_seq->event_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != add_cnt)
   CALL handle_errors("INSERT","F","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (prsnl_add_cnt > 0)
  INSERT  FROM ap_dc_event_prsnl adep,
    (dummyt d  WITH seq = value(prsnl_add_cnt))
   SET adep.event_id = temp->prsnl_add_qual[d.seq].event_id, adep.prsnl_group_id = temp->
    prsnl_add_qual[d.seq].prsnl_group_id, adep.prsnl_id = temp->prsnl_add_qual[d.seq].prsnl_id,
    adep.updt_dt_tm = cnvtdatetime(curdate,curtime), adep.updt_id = reqinfo->updt_id, adep.updt_task
     = reqinfo->updt_task,
    adep.updt_applctx = reqinfo->updt_applctx, adep.updt_cnt = 0
   PLAN (d)
    JOIN (adep
    WHERE (adep.event_id=temp->prsnl_add_qual[d.seq].event_id)
     AND (adep.prsnl_group_id=temp->prsnl_add_qual[d.seq].prsnl_group_id)
     AND (adep.prsnl_id=temp->prsnl_add_qual[d.seq].prsnl_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != prsnl_add_cnt)
   CALL handle_errors("INSERT","F","TABLE","AP_DC_EVENT_PRSNL")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (chg_cnt > 0)
  UPDATE  FROM ap_dc_event ade,
    (dummyt d  WITH seq = value(event_cnt))
   SET ade.study_id = request_corr_events_seq->study_id, ade.case_id = request_corr_events_seq->
    case_id, ade.correlate_case_id = request_corr_events_seq->correlate_case_id,
    ade.sys_corr_id = request_corr_events_seq->sys_corr_id, ade.init_eval_term_id =
    request_corr_events_seq->init_eval_term_id, ade.init_discrep_term_id = request_corr_events_seq->
    init_discrep_term_id,
    ade.disagree_reason_cd = request_corr_events_seq->disagree_reason_cd, ade.investigation_cd =
    request_corr_events_seq->investigation_cd, ade.resolution_cd = request_corr_events_seq->
    resolution_cd,
    ade.final_eval_term_id = request_corr_events_seq->final_eval_term_id, ade.final_discrep_term_id
     = request_corr_events_seq->final_discrep_term_id, ade.initiated_prsnl_id =
    request_corr_events_seq->initiated_prsnl_id,
    ade.initiated_dt_tm = cnvtdatetime(request_corr_events_seq->initiated_dt_tm), ade
    .complete_prsnl_id = request_corr_events_seq->complete_prsnl_id, ade.complete_dt_tm =
    IF ((request_corr_events_seq->complete_prsnl_id != 0)) cnvtdatetime(request_corr_events_seq->
      complete_dt_tm)
    ELSE null
    ENDIF
    ,
    ade.cancel_prsnl_id = request_corr_events_seq->cancel_prsnl_id, ade.cancel_dt_tm =
    IF ((request_corr_events_seq->cancel_prsnl_id != 0)) cnvtdatetime(request_corr_events_seq->
      cancel_dt_tm)
    ELSE null
    ENDIF
    , ade.report_issued_by_prsnl_id = request_corr_events_seq->report_issued_by_prsnl_id,
    ade.slide_counts = request_corr_events_seq->slide_counts, ade.long_text_id =
    IF ((request_corr_events_seq->comment != "")) temp->comment_qual[d.seq].comment_id
    ELSE 0.0
    ENDIF
    , ade.assign_to_group_ind = request_corr_events_seq->assign_to_group_ind,
    ade.prsnl_group_id = request_corr_events_seq->prsnl_group_id, ade.updt_dt_tm = cnvtdatetime(
     curdate,curtime), ade.updt_id = reqinfo->updt_id,
    ade.updt_task = reqinfo->updt_task, ade.updt_applctx = reqinfo->updt_applctx, ade.updt_cnt = (ade
    .updt_cnt+ 1)
   PLAN (d
    WHERE (request_corr_events_seq->upd_ind=1))
    JOIN (ade
    WHERE (ade.event_id=reply_corr_events_seq->event_id))
   WITH nocounter
  ;end update
  IF (curqual != chg_cnt)
   CALL handle_errors("UPDATE","F","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (x = 1 TO event_cnt)
   IF ((reply_corr_events->event_id != 0))
    IF ((request_corr_events->long_text_id != 0.0)
     AND (((request_corr_events->comment="")) OR ((request_corr_events->del_ind != 0))) )
     DELETE  FROM long_text lt
      SET lt.long_text_id = request_corr_events->long_text_id
      PLAN (lt
       WHERE (lt.long_text_id=request_corr_events->long_text_id)
        AND lt.long_text_id != 0.0)
      WITH nocounter
     ;end delete
     IF (curqual != 1)
      CALL handle_errors("DELETE","F","TABLE","LONG_TEXT")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
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
  SET reqinfo->commit_ind = 0
  SET reply_status->status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply_status->status = "S"
 ENDIF
 SET curalias request_corr_events off
 SET curalias request_corr_events_seq off
 SET curalias reply_corr_events off
 SET curalias reply_corr_events_seq off
 SET curalias reply_status off
END GO
