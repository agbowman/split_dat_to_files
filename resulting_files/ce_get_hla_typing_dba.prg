CREATE PROGRAM ce_get_hla_typing:dba
 DECLARE event_idx = i4
 DECLARE replycount = i4
 DECLARE cnt = i4
 DECLARE prevevent = f8
 DECLARE addind = i4
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE result_cnt = i4 WITH protect, noconstant(0)
 DECLARE hlasortorder1 = vc WITH noconstant("ce1.order_id")
 DECLARE hlasortorder2 = vc WITH noconstant("ce1.performed_dt_tm")
 SET prevevent = 0.0
 SET cnt = 1
 SET replycount = 0
 IF ((request->sort_order_ind=1))
  SET hlasortorder1 = "ce1.performed_dt_tm"
  SET hlasortorder2 = "ce1.order_id"
 ENDIF
 SELECT INTO "nl:"
  ce1.person_id, ce1.event_id, ce1.event_cd,
  ce1.result_val, ce1.event_end_dt_tm, ce1.performed_dt_tm,
  ce1.order_id, ce1.event_end_tz, precedence_number = decode(hdp.seq,hdp.precedence_nbr,0)
  FROM clinical_event ce1,
   hla_display_precedence hdp,
   dummyt d
  PLAN (ce1
   WHERE ce1.parent_event_id IN (
   (SELECT
    ce2.event_id
    FROM clinical_event ce2
    WHERE expand(event_idx,1,size(request->event_list,5),ce2.parent_event_id,request->event_list[
     event_idx].event_id)
     AND ce2.valid_until_dt_tm=cnvtdatetime("31-dec-2100")
     AND ce2.event_id != ce2.parent_event_id))
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-dec-2100"))
   JOIN (d)
   JOIN (hdp
   WHERE hdp.task_assay_cd=ce1.task_assay_cd
    AND hdp.precedence_type_flag=2)
  ORDER BY ce1.person_id DESC, ce1.event_cd DESC, precedence_number DESC,
   ce1.event_end_dt_tm DESC, parser(hlasortorder1) DESC, parser(hlasortorder2) DESC
  HEAD ce1.event_cd
   result_cnt = 0, curr_prec_nbr = 0
  HEAD ce1.event_end_dt_tm
   result_cnt = 0, curr_prec_nbr = 0
  DETAIL
   add_ind = 1, result_cnt += 1
   IF (result_cnt <= 2)
    FOR (x = 1 TO replycount)
      IF ((reply->reply_list[x].event_cd=ce1.event_cd)
       AND (reply->reply_list[x].person_id=ce1.person_id)
       AND (((reply->reply_list[x].order_id != ce1.order_id)) OR (((curr_prec_nbr !=
      precedence_number) OR ((reply->reply_list[x].event_end_dt_tm != ce1.event_end_dt_tm))) )) )
       add_ind = 0, x = (replycount+ 1)
      ENDIF
    ENDFOR
   ELSE
    add_ind = 0
   ENDIF
   IF (add_ind=1)
    IF (mod(replycount,10)=0)
     stat = alterlist(reply->reply_list,(replycount+ 10))
    ENDIF
    replycount += 1, reply->reply_list[replycount].person_id = ce1.person_id, reply->reply_list[
    replycount].event_id = ce1.event_id,
    reply->reply_list[replycount].event_cd = ce1.event_cd, reply->reply_list[replycount].result_val
     = ce1.result_val, reply->reply_list[replycount].event_end_dt_tm = ce1.event_end_dt_tm,
    reply->reply_list[replycount].performed_dt_tm = ce1.performed_dt_tm, reply->reply_list[replycount
    ].order_id = ce1.order_id, reply->reply_list[replycount].event_end_tz = ce1.event_end_tz,
    curr_prec_nbr = precedence_number
   ENDIF
  FOOT REPORT
   IF (replycount > 0)
    stat = alterlist(reply->reply_list,replycount)
   ENDIF
  WITH outerjoin = d
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
