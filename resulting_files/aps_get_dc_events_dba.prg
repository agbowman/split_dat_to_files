CREATE PROGRAM aps_get_dc_events:dba
 RECORD reply(
   1 case_qual[10]
     2 event_id = f8
     2 eval_accession = c21
     2 corr_accession = c21
     2 group_name = vc
     2 eval_name = vc
     2 init_eval_term_disp = c15
     2 init_discrep_term_disp = c15
     2 disagree_reason_cd = f8
     2 disagree_reason_disp = c40
     2 investigation_cd = f8
     2 investigation_disp = c40
     2 resolution_cd = f8
     2 resolution_disp = c40
     2 final_eval_term_disp = c15
     2 final_discrep_term_disp = c15
     2 long_text_id = f8
     2 initiated_prsnl_name = vc
     2 initiated_dt_tm = dq8
     2 complete_prsnl_name = vc
     2 complete_dt_tm = dq8
     2 cancel_prsnl_name = vc
     2 cancel_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET case_cnt = 0
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
 CALL change_times(request->beg_value_dt_tm,request->end_value_dt_tm)
 SET request->beg_value_dt_tm = dtemp->beg_of_day
 SET request->end_value_dt_tm = dtemp->end_of_day
 SELECT INTO "nl:"
  adce.event_id
  FROM ap_dc_event adce,
   pathology_case pc1,
   pathology_case pc2,
   prsnl_group pg,
   ap_dc_event_prsnl adcp,
   prsnl pr1,
   prsnl pr2,
   prsnl pr3,
   prsnl pr4,
   ap_dc_evaluation_term adcet1,
   ap_dc_evaluation_term adcet2,
   ap_dc_discrepancy_term adcdt1,
   ap_dc_discrepancy_term adcdt2
  PLAN (adce
   WHERE (adce.study_id=request->study_id)
    AND parser(
    IF ((request->show_completed=0)) " adce.complete_prsnl_id in (0,null)"
    ELSE "0=0"
    ENDIF
    )
    AND parser(
    IF ((request->show_canceled=0)) " adce.cancel_prsnl_id in (0, null)"
    ELSE "0=0"
    ENDIF
    )
    AND adce.initiated_dt_tm BETWEEN cnvtdatetime(request->beg_value_dt_tm) AND cnvtdatetime(request
    ->end_value_dt_tm))
   JOIN (pc1
   WHERE adce.case_id=pc1.case_id)
   JOIN (pc2
   WHERE adce.correlate_case_id=pc2.case_id)
   JOIN (pg
   WHERE adce.prsnl_group_id=pg.prsnl_group_id)
   JOIN (adcp
   WHERE adce.event_id=adcp.event_id)
   JOIN (pr1
   WHERE adcp.prsnl_id=pr1.person_id)
   JOIN (adcet1
   WHERE adce.init_eval_term_id=adcet1.evaluation_term_id)
   JOIN (adcdt1
   WHERE adce.init_discrep_term_id=adcdt1.discrepancy_term_id)
   JOIN (adcet2
   WHERE adce.final_eval_term_id=adcet2.evaluation_term_id)
   JOIN (adcdt2
   WHERE adce.final_discrep_term_id=adcdt2.discrepancy_term_id)
   JOIN (pr2
   WHERE adce.initiated_prsnl_id=pr2.person_id)
   JOIN (pr3
   WHERE adce.complete_prsnl_id=pr3.person_id)
   JOIN (pr4
   WHERE adce.cancel_prsnl_id=pr4.person_id)
  ORDER BY adce.event_id
  DETAIL
   case_cnt = (case_cnt+ 1)
   IF (mod(case_cnt,10)=1
    AND case_cnt != 1)
    stat = alter(reply->case_qual,(case_cnt+ 10))
   ENDIF
   reply->case_qual[case_cnt].event_id = adce.event_id, reply->case_qual[case_cnt].eval_accession =
   pc1.accession_nbr, reply->case_qual[case_cnt].corr_accession = pc2.accession_nbr,
   reply->case_qual[case_cnt].group_name = pg.prsnl_group_name, reply->case_qual[case_cnt].eval_name
    = pr1.name_full_formatted, reply->case_qual[case_cnt].init_eval_term_disp = adcet1.display,
   reply->case_qual[case_cnt].init_discrep_term_disp = adcdt1.display, reply->case_qual[case_cnt].
   disagree_reason_cd = adce.disagree_reason_cd, reply->case_qual[case_cnt].investigation_cd = adce
   .investigation_cd,
   reply->case_qual[case_cnt].resolution_cd = adce.resolution_cd, reply->case_qual[case_cnt].
   final_eval_term_disp = adcet2.display, reply->case_qual[case_cnt].final_discrep_term_disp = adcdt2
   .display,
   reply->case_qual[case_cnt].long_text_id = adce.long_text_id, reply->case_qual[case_cnt].
   initiated_prsnl_name = pr2.name_full_formatted, reply->case_qual[case_cnt].initiated_dt_tm = adce
   .initiated_dt_tm,
   reply->case_qual[case_cnt].complete_prsnl_name = pr3.name_full_formatted, reply->case_qual[
   case_cnt].complete_dt_tm = adce.complete_dt_tm, reply->case_qual[case_cnt].cancel_prsnl_name = pr4
   .name_full_formatted,
   reply->case_qual[case_cnt].cancel_dt_tm = adce.cancel_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->case_qual,case_cnt)
END GO
