CREATE PROGRAM ce_get_dynamic_label_by_person:dba
 RECORD reply(
   1 reply_list[*]
     2 ce_dynamic_label_id = f8
     2 label_template_id = f8
     2 label_name = vc
     2 label_prsnl_id = f8
     2 label_status_cd = f8
     2 person_id = f8
     2 valid_from_dt_tm = dq8
     2 label_seq_nbr = i4
     2 create_dt_tm = dq8
     2 label_comment = vc
     2 updt_dt_tm = dq8
     2 valid_until_dt_tm = dq8
   1 error_code = f8
   1 error_msg = vc
 )
 DECLARE person_size = i4 WITH constant(size(request->person_list,5))
 DECLARE status_size = i4 WITH constant(size(request->status_list,5))
 DECLARE label_size = i4 WITH constant(size(request->label_list,5))
 DECLARE person_ndx = i4 WITH noconstant(1)
 DECLARE status_ndx = i4 WITH noconstant(1)
 DECLARE label_ndx = i4 WITH noconstant(1)
 DECLARE person_nstart = i4 WITH protect, noconstant(1)
 DECLARE status_nstart = i4 WITH protect, noconstant(1)
 DECLARE label_nstart = i4 WITH protect, noconstant(1)
 DECLARE loop_person_cnt = i4 WITH noconstant(0)
 DECLARE loop_status_cnt = i4 WITH noconstant(0)
 DECLARE loop_label_cnt = i4 WITH noconstant(0)
 DECLARE configure_filters(null) = null
 DECLARE pad_arrays(null) = null
 DECLARE ndx = i4 WITH noconstant(0)
 DECLARE label_list_nsize = i2 WITH constant(25)
 DECLARE list_nsize = i2 WITH constant(5)
 DECLARE person_filter = vc WITH noconstant("(0=0)")
 DECLARE label_filter = vc WITH noconstant("(0=0)")
 DECLARE status_filter = vc WITH noconstant("(0=0)")
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 IF (person_size=0
  AND label_size=0)
  GO TO exit_script
 ENDIF
 CALL pad_arrays(null)
 CALL configure_filters(null)
 IF (person_size)
  SET loop_person_cnt = ceil((cnvtreal(person_size)/ list_nsize))
 ENDIF
 IF (status_size)
  SET loop_status_cnt = ceil((cnvtreal(status_size)/ list_nsize))
 ENDIF
 IF (label_size)
  SET loop_label_cnt = ceil((cnvtreal(label_size)/ label_list_nsize))
 ENDIF
 SELECT
  IF (person_size > 0
   AND status_size > 0
   AND label_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dperson  WITH seq = person_size),
    (dummyt dstatus  WITH seq = status_size),
    (dummyt dlabel  WITH seq = value(loop_label_cnt))
   PLAN (dperson)
    JOIN (dstatus)
    JOIN (dlabel
    WHERE assign(label_nstart,evaluate(dlabel.seq,1,1,(label_nstart+ label_list_nsize))))
    JOIN (t
    WHERE (((t.person_id=request->person_list[dperson.seq].person_id)
     AND (t.label_status_cd=request->status_list[dstatus.seq].label_status_cd)
     AND t.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")) OR (parser(label_filter))) )
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSEIF (person_size > 0
   AND status_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dperson  WITH seq = value(loop_person_cnt)),
    (dummyt dstatus  WITH seq = value(loop_status_cnt))
   PLAN (dperson
    WHERE assign(person_nstart,evaluate(dperson.seq,1,1,(person_nstart+ list_nsize))))
    JOIN (dstatus
    WHERE assign(status_nstart,evaluate(dstatus.seq,1,1,(status_nstart+ list_nsize))))
    JOIN (t
    WHERE parser(person_filter)
     AND parser(status_filter)
     AND t.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSEIF (label_size > 0
   AND status_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dstatus  WITH seq = value(loop_status_cnt)),
    (dummyt dlabel  WITH seq = value(loop_label_cnt))
   PLAN (dstatus
    WHERE assign(status_nstart,evaluate(dstatus.seq,1,1,(status_nstart+ list_nsize))))
    JOIN (dlabel
    WHERE assign(label_nstart,evaluate(dlabel.seq,1,1,(label_nstart+ label_list_nsize))))
    JOIN (t
    WHERE parser(label_filter)
     AND parser(status_filter))
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSEIF (person_size > 0
   AND label_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dperson  WITH seq = person_size),
    (dummyt dlabel  WITH seq = value(loop_label_cnt))
   PLAN (dperson)
    JOIN (dlabel
    WHERE assign(label_nstart,evaluate(dlabel.seq,1,1,(label_nstart+ label_list_nsize))))
    JOIN (t
    WHERE (((t.person_id=request->person_list[dperson.seq].person_id)
     AND t.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")) OR (parser(label_filter))) )
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSEIF (label_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dlabel  WITH seq = value(loop_label_cnt))
   PLAN (dlabel
    WHERE assign(label_nstart,evaluate(dlabel.seq,1,1,(label_nstart+ label_list_nsize))))
    JOIN (t
    WHERE parser(label_filter))
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSEIF (person_size > 0)
   FROM ce_dynamic_label t,
    long_text lt,
    (dummyt dperson  WITH seq = value(loop_person_cnt))
   PLAN (dperson
    WHERE assign(person_nstart,evaluate(dperson.seq,1,1,(person_nstart+ list_nsize))))
    JOIN (t
    WHERE parser(person_filter)
     AND t.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (lt
    WHERE t.long_text_id=lt.long_text_id)
  ELSE
  ENDIF
  INTO "nl"
  ORDER BY t.label_template_id, t.label_seq_nbr
  HEAD t.ce_dynamic_label_id
   ndx += 1
   IF (mod(ndx,10)=1)
    stat = alterlist(reply->reply_list,(ndx+ 9))
   ENDIF
   reply->reply_list[ndx].ce_dynamic_label_id = t.ce_dynamic_label_id, reply->reply_list[ndx].
   label_template_id = t.label_template_id, reply->reply_list[ndx].label_name = t.label_name,
   reply->reply_list[ndx].label_prsnl_id = t.label_prsnl_id, reply->reply_list[ndx].label_status_cd
    = t.label_status_cd, reply->reply_list[ndx].person_id = t.person_id,
   reply->reply_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm, reply->reply_list[ndx].label_seq_nbr
    = t.label_seq_nbr, reply->reply_list[ndx].create_dt_tm = t.create_dt_tm,
   reply->reply_list[ndx].label_comment = lt.long_text, reply->reply_list[ndx].updt_dt_tm = t
   .updt_dt_tm, reply->reply_list[ndx].valid_until_dt_tm = t.valid_until_dt_tm
  FOOT REPORT
   stat = alterlist(reply->reply_list,ndx)
  WITH nocounter
 ;end select
 GO TO exit_script
 SUBROUTINE pad_arrays(null)
   DECLARE loop_count = i4
   DECLARE new_size = i4
   IF (person_size > 0)
    SET loop_count = ceil((cnvtreal(person_size)/ list_nsize))
    SET new_size = (loop_count * list_nsize)
    IF (new_size > person_size)
     SET stat = alterlist(request->person_list,new_size)
     FOR (i = (person_size+ 1) TO new_size)
       SET request->person_list[i].person_id = request->person_list[person_size].person_id
     ENDFOR
    ENDIF
   ENDIF
   IF (status_size > 0)
    SET loop_count = ceil((cnvtreal(status_size)/ list_nsize))
    SET new_size = (loop_count * list_nsize)
    IF (new_size > status_size)
     SET stat = alterlist(request->status_list,new_size)
     FOR (i = (status_size+ 1) TO new_size)
       SET request->status_list[i].label_status_cd = request->status_list[status_size].
       label_status_cd
     ENDFOR
    ENDIF
   ENDIF
   IF (label_size > 0)
    SET loop_count = ceil((cnvtreal(label_size)/ label_list_nsize))
    SET new_size = (loop_count * label_list_nsize)
    IF (new_size > label_size)
     SET stat = alterlist(request->label_list,new_size)
     FOR (i = (label_size+ 1) TO new_size)
       SET request->label_list[i].ce_dynamic_label_id = request->label_list[label_size].
       ce_dynamic_label_id
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE configure_filters(null)
   IF (person_size > 0)
    SET person_filter = concat(
     "expand (person_ndx, person_nstart, person_nstart+LIST_NSIZE-1, t.person_id, ",
     " request->person_list[person_ndx]->person_id)")
   ENDIF
   IF (status_size > 0)
    SET status_filter = concat(
     "expand (status_ndx, status_nstart, status_nstart+LIST_NSIZE-1, t.label_status_cd, ",
     " request->status_list[status_ndx]->label_status_cd)")
   ENDIF
   IF (label_size > 0)
    SET label_filter = concat(
     "expand (label_ndx, label_nstart, label_nstart+LABEL_LIST_NSIZE-1, t.ce_dynamic_label_id, ",
     " request->label_list[label_ndx]->ce_dynamic_label_id)")
   ENDIF
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
