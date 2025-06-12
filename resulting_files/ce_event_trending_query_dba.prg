CREATE PROGRAM ce_event_trending_query:dba
 RDB delete from encntr_id_gtmp where ( 1 = 1 )
 END ;Rdb
 RDB delete from event_cd_gtmp where ( 1 = 1 )
 END ;Rdb
 SET modify = predeclare
 DECLARE stat_i4 = i4 WITH noconstant(0), protect
 DECLARE stat_f8 = f8 WITH noconstant(0.0), protect
 DECLARE stat_vc = vc WITH noconstant(""), protect
 DECLARE clinical_event_sec_lbl_id = i4 WITH constant(1), protect
 DECLARE error_code = f8 WITH noconstant(0.0), protect
 DECLARE error_msg = vc WITH noconstant(fillstring(132," ")), protect
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 IF (record_status_deleted <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DELETED' from code set 48."
  GO TO exit_script
 ENDIF
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 IF (record_status_draft <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DRAFT' from code set 48."
  GO TO exit_script
 ENDIF
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 IF (event_class_placeholder <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'PLACEHOLDER' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_group = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"GRP",1,event_class_group)
 IF (event_class_group <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'GRP' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_txt = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"TXT",1,event_class_txt)
 IF (event_class_txt <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'TXT' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_num = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"NUM",1,event_class_num)
 IF (event_class_num <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'NUM' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_unknown = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"UNKNOWN",1,event_class_unknown)
 IF (event_class_unknown <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'UNKNOWN' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_date = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"DATE",1,event_class_date)
 IF (event_class_date <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DATE' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_done = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"DONE",1,event_class_done)
 IF (event_class_done <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DONE' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE event_class_doc = f8 WITH noconstant(0.0)
 SET stat_i4 = uar_get_meaning_by_codeset(53,"DOC",1,event_class_doc)
 IF (event_class_doc <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DOC' from code set 53."
  GO TO exit_script
 ENDIF
 DECLARE encntr_nsize = i4 WITH protect, noconstant(0)
 DECLARE parser_filter = vc WITH noconstant("(1=1)"), protect
 DECLARE parser_filter2 = vc WITH noconstant("(1=1)"), protect
 DECLARE min_date = q8 WITH protect, noconstant(request->search_end_dt_tm)
 DECLARE max_date = q8 WITH protect, noconstant(request->search_begin_dt_tm)
 DECLARE g_nstart = i4 WITH protect, noconstant(0)
 DECLARE g_encntridx = i4 WITH protect, noconstant(0)
 DECLARE g_encntrloopcnt = i4 WITH protect, noconstant(0)
 DECLARE g_eventcdsize1 = i4 WITH protect, noconstant(0)
 DECLARE g_eventcdsize2 = i4 WITH protect, noconstant(0)
 DECLARE g_maxqualrank = i4 WITH protect, noconstant(0)
 DECLARE g_loops = i4 WITH protect, noconstant(0)
 DECLARE g_expsize = i4 WITH protect, noconstant(0)
 DECLARE fetch_events(null) = null
 DECLARE configure_constant_filters(null) = null
 DECLARE filter_event_codes1(null) = null
 DECLARE filter_event_codes2(null) = null
 DECLARE pad_result_status_array(null) = null
 DECLARE insertencounterids(null) = null
 DECLARE configureencounterfilter(null) = null
 DECLARE executemodifierlongtextquery(null) = null
 IF (size(request->result_status_list,5) > 20)
  SET reply->error_msg = "-E-Unsupported used case to filter by > 20 result status codes."
  GO TO exit_script
 ENDIF
 FREE SET modifier
 RECORD modifier(
   1 long_text_id_list[*]
     2 long_text_id = f8
     2 reply_index = i2
 )
 FREE SET ec_rank
 RECORD ec_rank(
   1 cds[*]
     2 event_cd = f8
     2 max_rank = i4
     2 result_qual = i4
 )
 FREE SET ec_rank_filtered
 RECORD ec_rank_filtered(
   1 cds[*]
     2 event_cd = f8
     2 max_rank = i4
     2 result_qual = i4
 )
 CALL fetch_events(null)
 CALL executemodifierlongtextquery(null)
 GO TO exit_script
 SUBROUTINE fetch_events(null)
   DECLARE event_cd_ndx = i2 WITH noconstant(1), protect
   DECLARE encntr_id_ndx = i4 WITH noconstant(1), protect
   DECLARE status_cd_ndx = i4 WITH noconstant(1), protect
   DECLARE encntr_size = i4 WITH protect, noconstant(size(request->encntr_list,5))
   DECLARE max_results_to_return = i4 WITH protect, noconstant(request->trending_event_count)
   DECLARE group_ind = i2 WITH private, noconstant(0)
   DECLARE begin_rank = i4 WITH protect, noconstant(0)
   DECLARE end_rank = i4 WITH protect, noconstant(max_results_to_return)
   DECLARE rank_loop = i4 WITH protect, noconstant(0)
   DECLARE keeplooping = i4 WITH protect, noconstant(1)
   IF (encntr_size > 0)
    CALL configureencounterfilter(null)
   ENDIF
   CALL configure_constant_filters(null)
   CALL filter_event_codes1(null)
   WHILE (g_eventcdsize1 > 0
    AND keeplooping > 0)
     IF (end_rank >= g_maxqualrank)
      SET keeplooping = 0
     ENDIF
     IF ((request->small_query_ind=1))
      CALL fetch_data_small(group_ind)
     ELSE
      CALL fetch_data_large(group_ind)
     ENDIF
     IF (keeplooping > 0)
      IF (rank_loop=0)
       SET stat_i4 = alterlist(ec_rank_filtered->cds,g_eventcdsize1)
      ENDIF
      SELECT INTO "nl:"
       FROM (dummyt rec  WITH seq = value(g_eventcdsize1))
       HEAD REPORT
        copy_cnt = 0, max_rank_val = 0
       DETAIL
        IF ((ec_rank->cds[rec.seq].max_rank > end_rank)
         AND (ec_rank->cds[rec.seq].result_qual < max_results_to_return))
         copy_cnt += 1, ec_rank_filtered->cds[copy_cnt].event_cd = ec_rank->cds[rec.seq].event_cd,
         ec_rank_filtered->cds[copy_cnt].max_rank = ec_rank->cds[rec.seq].max_rank,
         ec_rank_filtered->cds[copy_cnt].result_qual = ec_rank->cds[rec.seq].result_qual
         IF ((ec_rank->cds[rec.seq].max_rank > max_rank_val))
          max_rank_val = ec_rank->cds[rec.seq].max_rank
         ENDIF
        ENDIF
       FOOT REPORT
        g_maxqualrank = max_rank_val, stat_i4 = alterlist(ec_rank_filtered->cds,copy_cnt)
       WITH nocounter
      ;end select
      IF (g_maxqualrank=0)
       SET g_eventcdsize1 = 0
      ELSE
       SET g_eventcdsize1 = size(ec_rank_filtered->cds,5)
      ENDIF
      IF (g_eventcdsize1 > 0)
       SET rank_loop += 1
       SET stat_i4 = moverec(ec_rank_filtered,ec_rank)
       SET begin_rank = end_rank
       IF (rank_loop=1)
        SET end_rank += max_results_to_return
       ELSEIF (rank_loop=2)
        IF ((max_results_to_return > (g_maxqualrank - begin_rank)))
         SET end_rank = g_maxqualrank
        ELSE
         SET end_rank += ceil(((g_maxqualrank - begin_rank)/ 2))
        ENDIF
       ELSE
        SET end_rank = g_maxqualrank
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
   CALL filter_event_codes2(null)
   IF (g_eventcdsize2 > 0)
    SET group_ind = 1
    IF ((request->small_query_ind=1))
     CALL fetch_data_small(group_ind)
    ELSE
     CALL fetch_data_large(group_ind)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE executemodifierlongtextquery(null)
   DECLARE long_text_size = i2 WITH protect, noconstant(size(modifier->long_text_id_list,5))
   IF (long_text_size=0)
    RETURN
   ENDIF
   DECLARE batch_size = i2 WITH protect, noconstant(getbatchsize(long_text_size,100))
   DECLARE lloopcnt = i2 WITH protect, noconstant(ceil((cnvtreal(long_text_size)/ batch_size)))
   DECLARE lnewsize = i2 WITH protect, noconstant((lloopcnt * batch_size))
   DECLARE ltcount = i2 WITH protect, noconstant(0)
   DECLARE index_var = i2 WITH protect, noconstant(0)
   SET stat_i4 = alterlist(modifier->long_text_id_list,lnewsize)
   FOR (i = (long_text_size+ 1) TO lnewsize)
     SET modifier->long_text_id_list[i].long_text_id = modifier->long_text_id_list[long_text_size].
     long_text_id
   ENDFOR
   SET g_nstart = 1
   SELECT DISTINCT INTO "nl:"
    lt.long_text
    FROM (dummyt d  WITH seq = value(lloopcnt)),
     long_text lt
    PLAN (d
     WHERE initarray(g_nstart,evaluate(d.seq,1,1,(g_nstart+ batch_size))))
     JOIN (lt
     WHERE expand(ltcount,g_nstart,(g_nstart+ (batch_size - 1)),lt.long_text_id,modifier->
      long_text_id_list[ltcount].long_text_id))
    ORDER BY lt.long_text_id
    HEAD REPORT
     mod_index = 0, rep_index = 0
    HEAD lt.long_text_id
     mod_index = locateval(index_var,1,long_text_size,lt.long_text_id,modifier->long_text_id_list[
      index_var].long_text_id)
     WHILE (mod_index > 0)
       rep_index = modifier->long_text_id_list[mod_index].reply_index, reply->event_list[rep_index].
       modifier_long_text = lt.long_text, mod_index = locateval(index_var,(mod_index+ 1),
        long_text_size,lt.long_text_id,modifier->long_text_id_list[index_var].long_text_id)
     ENDWHILE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getbatchsize(listsize=i4,maxsize=i4) =i4)
   DECLARE batchsize = i4 WITH noconstant(0)
   IF (listsize=0)
    RETURN(20)
   ENDIF
   SET batchsize = ((listsize+ 19) - mod((listsize - 1),20))
   IF (batchsize > maxsize)
    SET batchsize = maxsize
   ENDIF
   RETURN(batchsize)
 END ;Subroutine
 SUBROUTINE pad_result_status_array(null)
   DECLARE orig_size = i4 WITH private, noconstant(size(request->result_status_list,5))
   DECLARE new_size = i4 WITH private, noconstant(20)
   SET stat_i4 = alterlist(request->result_status_list,new_size)
   FOR (i = (orig_size+ 1) TO new_size)
     SET request->result_status_list[i].result_status_cd = request->result_status_list[orig_size].
     result_status_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE configureencounterfilter(null)
   DECLARE new_size = i4 WITH private
   SET encntr_nsize = getbatchsize(encntr_size,40)
   SET g_encntrloopcnt = ceil((cnvtreal(encntr_size)/ encntr_nsize))
   SET new_size = (g_encntrloopcnt * encntr_nsize)
   SET stat_i4 = alterlist(request->encntr_list,new_size)
   FOR (i = (encntr_size+ 1) TO new_size)
     SET request->encntr_list[i].encntr_id = request->encntr_list[encntr_size].encntr_id
   ENDFOR
   CALL insertencounterids(null)
 END ;Subroutine
 SUBROUTINE configure_constant_filters(null)
  IF (size(request->result_status_list,5)=1)
   SET parser_filter = "ce.result_status_cd+0 = request->result_status_list[1].result_status_cd"
   SET parser_filter2 = "t.result_status_cd+0 = request->result_status_list[1].result_status_cd"
  ELSEIF (size(request->result_status_list,5) > 0)
   CALL pad_result_status_array(null)
   SET parser_filter = concat(
    "expand (status_cd_ndx, 1, size(request->result_status_list,5), ce.result_status_cd+0, ",
    "request->result_status_list[status_cd_ndx].result_status_cd)")
   SET parser_filter2 = concat(
    "expand (status_cd_ndx, 1, size(request->result_status_list,5), t.result_status_cd+0, ",
    "request->result_status_list[status_cd_ndx].result_status_cd)")
  ENDIF
  IF ((request->ce_dynamic_label_id > 0))
   IF (size(request->result_status_list,5) > 0)
    SET parser_filter = concat(parser_filter,
     " and ce.ce_dynamic_label_id = request->ce_dynamic_label_id")
    SET parser_filter2 = concat(parser_filter2,
     " and t.ce_dynamic_label_id = request->ce_dynamic_label_id")
   ELSE
    SET parser_filter = "ce.ce_dynamic_label_id = request->ce_dynamic_label_id"
    SET parser_filter2 = "t.ce_dynamic_label_id = request->ce_dynamic_label_id"
   ENDIF
  ELSEIF ((request->inc_dynamic_label_results_ind=0))
   IF (size(request->result_status_list,5) > 0)
    SET parser_filter = concat(parser_filter," and ce.ce_dynamic_label_id+0 = 0")
    SET parser_filter2 = concat(parser_filter2," and t.ce_dynamic_label_id+0 = 0")
   ELSE
    SET parser_filter = "ce.ce_dynamic_label_id+0 = 0"
    SET parser_filter2 = "t.ce_dynamic_label_id+0 = 0"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE filter_event_codes1(null)
   DECLARE event_nbr1 = i4 WITH private, noconstant(size(request->only_child_list,5))
   DECLARE loop_nbr = i4 WITH private, noconstant(0)
   DECLARE new_size = i4 WITH private, noconstant(0)
   DECLARE event_cd_ndx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   IF (event_nbr1 > 0)
    DECLARE filter_ec_size1 = i4 WITH protect, constant(getbatchsize(event_nbr1,100))
    SET loop_nbr = ceil((cnvtreal(event_nbr1)/ filter_ec_size1))
    SET new_size = (loop_nbr * filter_ec_size1)
    SET stat_i4 = alterlist(request->only_child_list,new_size)
    FOR (i = (event_nbr1+ 1) TO new_size)
      SET request->only_child_list[i].event_cd = request->only_child_list[event_nbr1].event_cd
    ENDFOR
    SET g_nstart = 1
    FOR (loop_cnt = 1 TO loop_nbr)
     SELECT INTO "nl:"
      FROM (
       (
       (SELECT
        event_cd = ce.event_cd, rn = rank() OVER(
        PARTITION BY ce.event_cd
        ORDER BY ce.event_end_dt_tm DESC)
        FROM clinical_event ce
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,g_nstart,((g_nstart+ filter_ec_size1) - 1),ce.event_cd,request->
         only_child_list[event_cd_ndx].event_cd)
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        WITH sqltype("f8","i4"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
       t)
      HEAD t.event_cd
       cnt += 1
       IF (mod(cnt,100)=1)
        stat_i4 = alterlist(ec_rank->cds,(cnt+ 99))
       ENDIF
       ec_rank->cds[cnt].event_cd = t.event_cd
      FOOT  t.event_cd
       ec_rank->cds[cnt].max_rank = t.rn
       IF (t.rn > g_maxqualrank)
        g_maxqualrank = t.rn
       ENDIF
      WITH nocounter
     ;end select
     SET g_nstart += filter_ec_size1
    ENDFOR
    IF (cnt > 0)
     SET stat_i4 = alterlist(ec_rank->cds,cnt)
    ENDIF
    SET g_eventcdsize1 = cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE filter_event_codes2(null)
   DECLARE event_nbr2 = i4 WITH private, noconstant(size(request->sibling_list,5))
   DECLARE loop_nbr = i4 WITH private, noconstant(0)
   DECLARE new_size = i4 WITH private, noconstant(0)
   DECLARE cnt = i4 WITH private, noconstant(0)
   DECLARE event_start = i4 WITH protect, noconstant(1)
   DECLARE event_cd_ndx = i4 WITH protect, noconstant(0)
   IF (event_nbr2 > 0)
    DECLARE filter_ec_size2 = i4 WITH protect, constant(getbatchsize(event_nbr2,100))
    SET loop_nbr = ceil((cnvtreal(event_nbr2)/ filter_ec_size2))
    SET new_size = (loop_nbr * filter_ec_size2)
    SET stat_i4 = alterlist(request->sibling_list,new_size)
    FOR (i = (event_nbr2+ 1) TO new_size)
      SET request->sibling_list[i].event_cd = request->sibling_list[event_nbr2].event_cd
    ENDFOR
    FOR (loopcnt = 1 TO loop_nbr)
      INSERT  FROM event_cd_gtmp
       (event_cd, event_set_cd)(SELECT DISTINCT
        ce.event_cd, ese.event_set_cd
        FROM clinical_event ce,
         v500_event_set_explode ese
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,event_start,((event_start+ filter_ec_size2) - 1),ce.event_cd,request
         ->sibling_list[event_cd_ndx].event_cd)
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
         AND ce.event_cd=ese.event_cd
         AND ese.event_set_level=0
        ORDER BY ce.event_cd, ese.event_set_cd
        WITH orahintcbo("LEADING(ce ese)","INDEX(ce XIE9CLINICAL_EVENT)",
          "INDEX(ese XIF50V500_EVENT_SET_EXPLODE","USE_NL(ese)"))
       WITH nocounter
      ;end insert
      SET event_start += filter_ec_size2
      SET cnt += curqual
    ENDFOR
    SET g_eventcdsize2 = cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE insertencounterids(null)
   DECLARE cnt = i4 WITH private, noconstant(0)
   DECLARE loopcnt = i4 WITH private, noconstant(0)
   SET g_nstart = 1
   SET g_encntridx = 0
   FOR (loopcnt = 1 TO g_encntrloopcnt)
     INSERT  FROM encntr_id_gtmp
      (encntr_id)(SELECT
       e.encntr_id
       FROM encounter e
       WHERE expand(g_encntridx,g_nstart,(g_nstart+ (encntr_nsize - 1)),e.encntr_id,request->
        encntr_list[g_encntridx].encntr_id))
      WITH nocounter
     ;end insert
     SET g_nstart += encntr_nsize
     SET cnt += curqual
   ENDFOR
   IF (cnt=0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (fetch_data_large(group_ind=i2) =null)
  DECLARE fdl_index_use = vc WITH protect, noconstant(" ")
  IF (group_ind=0)
   DECLARE groupzerobatchsize = i4 WITH protect, constant(getbatchsize(g_eventcdsize1,100))
   SET g_nstart = 1
   SET g_loops = ceil((cnvtreal(g_eventcdsize1)/ groupzerobatchsize))
   SET g_expsize = (g_loops * groupzerobatchsize)
   SET stat_i4 = alterlist(ec_rank->cds,g_expsize)
   FOR (i = (g_eventcdsize1+ 1) TO g_expsize)
     SET ec_rank->cds[i].event_cd = ec_rank->cds[g_eventcdsize1].event_cd
   ENDFOR
   FOR (i = 1 TO g_loops)
    SELECT
     IF (encntr_size=0)
      event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
       .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
      valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), publish_flag_ind = nullind(t.publish_flag),
      subtable_bit_map_ind = nullind(t.subtable_bit_map),
      performed_dt_tm_ind = nullind(t.performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm),
      event_start_dt_tm_ind = nullind(t.event_start_dt_tm),
      verified_dt_tm_ind = nullind(t.verified_dt_tm), expiration_dt_tm_ind = nullind(t
       .expiration_dt_tm), updt_task_ind = nullind(t.updt_task),
      updt_cnt_ind = nullind(t.updt_cnt), updt_applctx_ind = nullind(t.updt_applctx)
      FROM (
       (
       (SELECT DISTINCT
        event_rank = rank() OVER(
        PARTITION BY ce.event_cd
        ORDER BY ce.event_end_dt_tm DESC), event_end_dt_tm = ce.event_end_dt_tm, valid_until_dt_tm =
        ce.valid_until_dt_tm,
        person_id = ce.person_id, event_cd = ce.event_cd
        FROM clinical_event ce
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,g_nstart,((g_nstart+ groupzerobatchsize) - 1),ce.event_cd,ec_rank->
         cds[event_cd_ndx].event_cd)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
        WITH sqltype("i4","dq8","dq8","f8","f8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
       t2),
       clinical_event t
      PLAN (t2
       WHERE t2.event_rank > begin_rank
        AND t2.event_rank <= end_rank)
       JOIN (t
       WHERE t.person_id=t2.person_id
        AND t.event_cd=t2.event_cd
        AND t.event_end_dt_tm=t2.event_end_dt_tm
        AND t.valid_until_dt_tm=t2.valid_until_dt_tm
        AND parser(parser_filter2)
        AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
        AND t.event_class_cd != event_class_placeholder
        AND t.event_class_cd != event_class_group
        AND ((t.view_level=1) OR (((t.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (t.event_class_cd=event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=t.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) )) )
      ORDER BY t2.event_cd, t2.event_rank
     ELSE
      event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
       .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
      valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), publish_flag_ind = nullind(t.publish_flag),
      subtable_bit_map_ind = nullind(t.subtable_bit_map),
      performed_dt_tm_ind = nullind(t.performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm),
      event_start_dt_tm_ind = nullind(t.event_start_dt_tm),
      verified_dt_tm_ind = nullind(t.verified_dt_tm), expiration_dt_tm_ind = nullind(t
       .expiration_dt_tm), updt_task_ind = nullind(t.updt_task),
      updt_cnt_ind = nullind(t.updt_cnt), updt_applctx_ind = nullind(t.updt_applctx)
      FROM (
       (
       (SELECT DISTINCT
        event_rank = rank() OVER(
        PARTITION BY ce.event_cd
        ORDER BY ce.event_end_dt_tm DESC), event_end_dt_tm = ce.event_end_dt_tm, valid_until_dt_tm =
        ce.valid_until_dt_tm,
        person_id = ce.person_id, event_cd = ce.event_cd
        FROM clinical_event ce
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,g_nstart,((g_nstart+ groupzerobatchsize) - 1),ce.event_cd,ec_rank->
         cds[event_cd_ndx].event_cd)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
        WITH sqltype("i4","dq8","dq8","f8","f8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
       t2),
       clinical_event t,
       encntr_id_gtmp ctt
      PLAN (t2
       WHERE t2.event_rank > begin_rank
        AND t2.event_rank <= end_rank)
       JOIN (t
       WHERE t.person_id=t2.person_id
        AND t.event_cd=t2.event_cd
        AND t.event_end_dt_tm=t2.event_end_dt_tm
        AND t.valid_until_dt_tm=t2.valid_until_dt_tm
        AND parser(parser_filter2)
        AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
        AND t.event_class_cd != event_class_placeholder
        AND t.event_class_cd != event_class_group
        AND ((t.view_level=1) OR (((t.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (t.event_class_cd=event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=t.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) )) )
       JOIN (ctt
       WHERE ctt.encntr_id=t.encntr_id)
      ORDER BY t2.event_cd, t2.event_rank
     ENDIF
     INTO "nl"
     HEAD REPORT
      ndx = size(reply->event_list,5)
      IF (ndx > 0
       AND mod((ndx+ 1),10) != 1)
       stat_i4 = alterlist(reply->event_list,((ndx+ 10) - mod(ndx,10)))
      ENDIF
      ec_idx = 0, ec_cnt = 0, long_text_size = 0,
      keep_items = 1
     HEAD t2.event_cd
      mod_index = locateval(ec_idx,1,g_eventcdsize1,t.event_cd,ec_rank->cds[ec_idx].event_cd), ec_cnt
       = ec_rank->cds[mod_index].result_qual, keep_items = 1
     HEAD t2.event_rank
      IF (ec_cnt >= max_results_to_return)
       keep_items = 0
      ENDIF
     DETAIL
      IF (keep_items > 0)
       ec_cnt += 1, ndx += 1
       IF (mod(ndx,10)=1)
        stat_i4 = alterlist(reply->event_list,(ndx+ 9))
       ENDIF
       reply->event_list[ndx].event_cd = t.event_cd, reply->event_list[ndx].event_id = t.event_id,
       reply->event_list[ndx].event_end_dt_tm = t.event_end_dt_tm,
       reply->event_list[ndx].event_end_dt_tm_ind = event_end_dt_tm_ind, reply->event_list[ndx].
       clinical_event_id = t.clinical_event_id, reply->event_list[ndx].valid_until_dt_tm = t
       .valid_until_dt_tm,
       reply->event_list[ndx].valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->event_list[ndx].
       view_level = t.view_level, reply->event_list[ndx].clinsig_updt_dt_tm = t.clinsig_updt_dt_tm,
       reply->event_list[ndx].clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->event_list[ndx]
       .order_id = t.order_id, reply->event_list[ndx].order_action_sequence = t.order_action_sequence,
       reply->event_list[ndx].catalog_cd = t.catalog_cd, reply->event_list[ndx].encntr_id = t
       .encntr_id, reply->event_list[ndx].contributor_system_cd = t.contributor_system_cd,
       reply->event_list[ndx].reference_nbr = t.reference_nbr, reply->event_list[ndx].parent_event_id
        = t.parent_event_id, reply->event_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm,
       reply->event_list[ndx].valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->event_list[ndx].
       event_class_cd = t.event_class_cd, reply->event_list[ndx].event_tag = t.event_tag,
       reply->event_list[ndx].event_tag_set_flag = t.event_tag_set_flag, reply->event_list[ndx].
       event_end_tz = t.event_end_tz, reply->event_list[ndx].task_assay_cd = t.task_assay_cd,
       reply->event_list[ndx].result_status_cd = t.result_status_cd, reply->event_list[ndx].
       publish_flag = t.publish_flag, reply->event_list[ndx].normalcy_cd = t.normalcy_cd,
       reply->event_list[ndx].subtable_bit_map = t.subtable_bit_map, reply->event_list[ndx].
       event_title_text = t.event_title_text, reply->event_list[ndx].result_val = t.result_val,
       reply->event_list[ndx].result_units_cd = t.result_units_cd, reply->event_list[ndx].
       performed_dt_tm = t.performed_dt_tm, reply->event_list[ndx].performed_dt_tm_ind =
       performed_dt_tm_ind,
       reply->event_list[ndx].performed_tz = t.performed_tz, reply->event_list[ndx].
       performed_prsnl_id = t.performed_prsnl_id, reply->event_list[ndx].normal_low = t.normal_low,
       reply->event_list[ndx].normal_high = t.normal_high, reply->event_list[ndx].updt_dt_tm = t
       .updt_dt_tm, reply->event_list[ndx].updt_dt_tm_ind = updt_dt_tm_ind,
       reply->event_list[ndx].note_importance_bit_map = t.note_importance_bit_map, reply->event_list[
       ndx].collating_seq = t.collating_seq, reply->event_list[ndx].entry_mode_cd = t.entry_mode_cd,
       reply->event_list[ndx].source_cd = t.source_cd, reply->event_list[ndx].clinical_seq = t
       .clinical_seq, reply->event_list[ndx].task_assay_version_nbr = t.task_assay_version_nbr,
       reply->event_list[ndx].modifier_long_text_id = t.modifier_long_text_id, reply->event_list[ndx]
       .order_id = t.order_id, reply->event_list[ndx].series_ref_nbr = t.series_ref_nbr,
       reply->event_list[ndx].person_id = t.person_id, reply->event_list[ndx].encntr_financial_id = t
       .encntr_financial_id, reply->event_list[ndx].accession_nbr = t.accession_nbr,
       reply->event_list[ndx].event_reltn_cd = t.event_reltn_cd, reply->event_list[ndx].
       event_start_dt_tm = t.event_start_dt_tm, reply->event_list[ndx].event_start_dt_tm_ind =
       event_start_dt_tm_ind,
       reply->event_list[ndx].event_start_tz = t.event_start_tz, reply->event_list[ndx].
       record_status_cd = t.record_status_cd, reply->event_list[ndx].authentic_flag = t
       .authentic_flag,
       reply->event_list[ndx].publish_flag_ind = publish_flag_ind, reply->event_list[ndx].
       qc_review_cd = t.qc_review_cd, reply->event_list[ndx].normalcy_method_cd = t
       .normalcy_method_cd,
       reply->event_list[ndx].inquire_security_cd = t.inquire_security_cd, reply->event_list[ndx].
       resource_group_cd = t.resource_group_cd, reply->event_list[ndx].resource_cd = t.resource_cd,
       reply->event_list[ndx].subtable_bit_map_ind = subtable_bit_map_ind, reply->event_list[ndx].
       result_time_units_cd = t.result_time_units_cd, reply->event_list[ndx].verified_dt_tm = t
       .verified_dt_tm,
       reply->event_list[ndx].verified_dt_tm_ind = verified_dt_tm_ind, reply->event_list[ndx].
       verified_tz = t.verified_tz, reply->event_list[ndx].verified_prsnl_id = t.verified_prsnl_id,
       reply->event_list[ndx].critical_low = t.critical_low, reply->event_list[ndx].critical_high = t
       .critical_high, reply->event_list[ndx].expiration_dt_tm = t.expiration_dt_tm,
       reply->event_list[ndx].expiration_dt_tm_ind = expiration_dt_tm_ind, reply->event_list[ndx].
       updt_id = t.updt_id, reply->event_list[ndx].updt_task = t.updt_task,
       reply->event_list[ndx].updt_task_ind = updt_task_ind, reply->event_list[ndx].updt_cnt = t
       .updt_cnt, reply->event_list[ndx].updt_cnt_ind = updt_cnt_ind,
       reply->event_list[ndx].updt_applctx = t.updt_applctx, reply->event_list[ndx].updt_applctx_ind
        = updt_applctx_ind, reply->event_list[ndx].nomen_string_flag = t.nomen_string_flag,
       reply->event_list[ndx].ce_dynamic_label_id = t.ce_dynamic_label_id, reply->event_list[ndx].
       device_free_txt = t.device_free_txt, reply->event_list[ndx].trait_bit_map = t.trait_bit_map,
       stat_vc = assign(validate(reply->event_list[ndx].normal_ref_range_txt,""),t
        .normal_ref_range_txt), stat_f8 = assign(validate(reply->event_list[ndx].ce_grouping_id,0),t
        .ce_grouping_id), stat_i4 = assign(validate(reply->event_list[ndx].subtable_bit_map2,0),t
        .subtable_bit_map2)
       IF (band(t.subtable_bit_map2,clinical_event_sec_lbl_id)=clinical_event_sec_lbl_id)
        max_results_to_return += 1
       ENDIF
       IF (t.modifier_long_text_id > 0)
        long_text_size += 1, stat_i4 = alterlist(modifier->long_text_id_list,long_text_size),
        modifier->long_text_id_list[long_text_size].long_text_id = t.modifier_long_text_id,
        modifier->long_text_id_list[long_text_size].reply_index = ndx
       ENDIF
      ENDIF
     FOOT  t.event_cd
      ec_rank->cds[mod_index].result_qual = ec_cnt
     FOOT REPORT
      stat_i4 = alterlist(reply->event_list,ndx)
     WITH nocounter, memsort, orahintcbo("USE_MERGE(ctt)","INDEX(t XIE9CLINICAL_EVENT)",
       "LEADING(t2 t)","USE_NL(t)")
    ;end select
    SET g_nstart += groupzerobatchsize
   ENDFOR
  ELSE
   IF ((request->ce_dynamic_label_id > 0))
    SET fdl_index_use = "INDEX(ce XIE22CLINICAL_EVENT)"
   ELSE
    SET fdl_index_use = "INDEX(ce XIE9CLINICAL_EVENT)"
   ENDIF
   SELECT
    IF (encntr_size=0)
     event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
      .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
     valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), publish_flag_ind = nullind(t.publish_flag),
     subtable_bit_map_ind = nullind(t.subtable_bit_map),
     performed_dt_tm_ind = nullind(t.performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm),
     event_start_dt_tm_ind = nullind(t.event_start_dt_tm),
     verified_dt_tm_ind = nullind(t.verified_dt_tm), expiration_dt_tm_ind = nullind(t
      .expiration_dt_tm), updt_task_ind = nullind(t.updt_task),
     updt_cnt_ind = nullind(t.updt_cnt), updt_applctx_ind = nullind(t.updt_applctx)
     FROM (
      (
      (SELECT
       event_rank = rank() OVER(
       PARTITION BY ectlrg.event_set_cd
       ORDER BY ce.event_end_dt_tm DESC), event_id = ce.event_id, event_end_dt_tm = ce
       .event_end_dt_tm
       FROM clinical_event ce,
        event_cd_gtmp ectlrg
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=ectlrg.event_cd
        AND parser(parser_filter)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.event_class_cd != event_class_group
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        AND ((ce.view_level=1) OR (((ce.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (ce.event_class_cd=
       event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=ce.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) ))
       ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce.event_id DESC
       WITH sqltype("f8","f8","dq8"), orahintcbo("LEADING(ectlrg ce)",value(fdl_index_use),
         "USE_NL(ce)")))
      t2),
      clinical_event t
    ELSE
     event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
      .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
     valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), publish_flag_ind = nullind(t.publish_flag),
     subtable_bit_map_ind = nullind(t.subtable_bit_map),
     performed_dt_tm_ind = nullind(t.performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm),
     event_start_dt_tm_ind = nullind(t.event_start_dt_tm),
     verified_dt_tm_ind = nullind(t.verified_dt_tm), expiration_dt_tm_ind = nullind(t
      .expiration_dt_tm), updt_task_ind = nullind(t.updt_task),
     updt_cnt_ind = nullind(t.updt_cnt), updt_applctx_ind = nullind(t.updt_applctx)
     FROM (
      (
      (SELECT
       event_rank = rank() OVER(
       PARTITION BY ectlrg.event_set_cd
       ORDER BY ce.event_end_dt_tm DESC), event_id = ce.event_id, event_end_dt_tm = ce
       .event_end_dt_tm
       FROM encntr_id_gtmp ettlrg,
        clinical_event ce,
        event_cd_gtmp ectlrg
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=ectlrg.event_cd
        AND parser(parser_filter)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.event_class_cd != event_class_group
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        AND ce.encntr_id=ettlrg.encntr_id
        AND ((ce.view_level=1) OR (((ce.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (ce.event_class_cd=
       event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=ce.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) ))
       ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce.event_id DESC
       WITH sqltype("f8","f8","dq8"), orahintcbo("LEADING(ectlrg ce ettlrg)",value(fdl_index_use),
         "USE_NL(ce)","USE_MERGE(ettlrg)")))
      t2),
      clinical_event t
    ENDIF
    INTO "nl"
    PLAN (t2
     WHERE t2.event_rank <= max_results_to_return)
     JOIN (t
     WHERE t.event_id=t2.event_id
      AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
    HEAD REPORT
     ndx = size(reply->event_list,5)
     IF (ndx > 0
      AND mod((ndx+ 1),10) != 1)
      stat_i4 = alterlist(reply->event_list,((ndx+ 10) - mod(ndx,10)))
     ENDIF
     long_text_size = 0
    DETAIL
     ndx += 1
     IF (mod(ndx,10)=1)
      stat_i4 = alterlist(reply->event_list,(ndx+ 9))
     ENDIF
     reply->event_list[ndx].event_cd = t.event_cd, reply->event_list[ndx].event_id = t.event_id,
     reply->event_list[ndx].event_end_dt_tm = t.event_end_dt_tm,
     reply->event_list[ndx].event_end_dt_tm_ind = event_end_dt_tm_ind, reply->event_list[ndx].
     clinical_event_id = t.clinical_event_id, reply->event_list[ndx].valid_until_dt_tm = t
     .valid_until_dt_tm,
     reply->event_list[ndx].valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->event_list[ndx].
     view_level = t.view_level, reply->event_list[ndx].clinsig_updt_dt_tm = t.clinsig_updt_dt_tm,
     reply->event_list[ndx].clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, reply->event_list[ndx].
     order_id = t.order_id, reply->event_list[ndx].order_action_sequence = t.order_action_sequence,
     reply->event_list[ndx].catalog_cd = t.catalog_cd, reply->event_list[ndx].encntr_id = t.encntr_id,
     reply->event_list[ndx].contributor_system_cd = t.contributor_system_cd,
     reply->event_list[ndx].reference_nbr = t.reference_nbr, reply->event_list[ndx].parent_event_id
      = t.parent_event_id, reply->event_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm,
     reply->event_list[ndx].valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->event_list[ndx].
     event_class_cd = t.event_class_cd, reply->event_list[ndx].event_tag = t.event_tag,
     reply->event_list[ndx].event_tag_set_flag = t.event_tag_set_flag, reply->event_list[ndx].
     event_end_tz = t.event_end_tz, reply->event_list[ndx].task_assay_cd = t.task_assay_cd,
     reply->event_list[ndx].result_status_cd = t.result_status_cd, reply->event_list[ndx].
     publish_flag = t.publish_flag, reply->event_list[ndx].normalcy_cd = t.normalcy_cd,
     reply->event_list[ndx].subtable_bit_map = t.subtable_bit_map, reply->event_list[ndx].
     event_title_text = t.event_title_text, reply->event_list[ndx].result_val = t.result_val,
     reply->event_list[ndx].result_units_cd = t.result_units_cd, reply->event_list[ndx].
     performed_dt_tm = t.performed_dt_tm, reply->event_list[ndx].performed_dt_tm_ind =
     performed_dt_tm_ind,
     reply->event_list[ndx].performed_tz = t.performed_tz, reply->event_list[ndx].performed_prsnl_id
      = t.performed_prsnl_id, reply->event_list[ndx].normal_low = t.normal_low,
     reply->event_list[ndx].normal_high = t.normal_high, reply->event_list[ndx].updt_dt_tm = t
     .updt_dt_tm, reply->event_list[ndx].updt_dt_tm_ind = updt_dt_tm_ind,
     reply->event_list[ndx].note_importance_bit_map = t.note_importance_bit_map, reply->event_list[
     ndx].collating_seq = t.collating_seq, reply->event_list[ndx].entry_mode_cd = t.entry_mode_cd,
     reply->event_list[ndx].source_cd = t.source_cd, reply->event_list[ndx].clinical_seq = t
     .clinical_seq, reply->event_list[ndx].task_assay_version_nbr = t.task_assay_version_nbr,
     reply->event_list[ndx].modifier_long_text_id = t.modifier_long_text_id, reply->event_list[ndx].
     order_id = t.order_id, reply->event_list[ndx].series_ref_nbr = t.series_ref_nbr,
     reply->event_list[ndx].person_id = t.person_id, reply->event_list[ndx].encntr_financial_id = t
     .encntr_financial_id, reply->event_list[ndx].accession_nbr = t.accession_nbr,
     reply->event_list[ndx].event_reltn_cd = t.event_reltn_cd, reply->event_list[ndx].
     event_start_dt_tm = t.event_start_dt_tm, reply->event_list[ndx].event_start_dt_tm_ind =
     event_start_dt_tm_ind,
     reply->event_list[ndx].event_start_tz = t.event_start_tz, reply->event_list[ndx].
     record_status_cd = t.record_status_cd, reply->event_list[ndx].authentic_flag = t.authentic_flag,
     reply->event_list[ndx].publish_flag_ind = publish_flag_ind, reply->event_list[ndx].qc_review_cd
      = t.qc_review_cd, reply->event_list[ndx].normalcy_method_cd = t.normalcy_method_cd,
     reply->event_list[ndx].inquire_security_cd = t.inquire_security_cd, reply->event_list[ndx].
     resource_group_cd = t.resource_group_cd, reply->event_list[ndx].resource_cd = t.resource_cd,
     reply->event_list[ndx].subtable_bit_map_ind = subtable_bit_map_ind, reply->event_list[ndx].
     result_time_units_cd = t.result_time_units_cd, reply->event_list[ndx].verified_dt_tm = t
     .verified_dt_tm,
     reply->event_list[ndx].verified_dt_tm_ind = verified_dt_tm_ind, reply->event_list[ndx].
     verified_tz = t.verified_tz, reply->event_list[ndx].verified_prsnl_id = t.verified_prsnl_id,
     reply->event_list[ndx].critical_low = t.critical_low, reply->event_list[ndx].critical_high = t
     .critical_high, reply->event_list[ndx].expiration_dt_tm = t.expiration_dt_tm,
     reply->event_list[ndx].expiration_dt_tm_ind = expiration_dt_tm_ind, reply->event_list[ndx].
     updt_id = t.updt_id, reply->event_list[ndx].updt_task = t.updt_task,
     reply->event_list[ndx].updt_task_ind = updt_task_ind, reply->event_list[ndx].updt_cnt = t
     .updt_cnt, reply->event_list[ndx].updt_cnt_ind = updt_cnt_ind,
     reply->event_list[ndx].updt_applctx = t.updt_applctx, reply->event_list[ndx].updt_applctx_ind =
     updt_applctx_ind, reply->event_list[ndx].nomen_string_flag = t.nomen_string_flag,
     reply->event_list[ndx].ce_dynamic_label_id = t.ce_dynamic_label_id, reply->event_list[ndx].
     device_free_txt = t.device_free_txt, reply->event_list[ndx].trait_bit_map = t.trait_bit_map,
     stat_vc = assign(validate(reply->event_list[ndx].normal_ref_range_txt,""),t.normal_ref_range_txt
      ), stat_f8 = assign(validate(reply->event_list[ndx].ce_grouping_id,0),t.ce_grouping_id),
     stat_i4 = assign(validate(reply->event_list[ndx].subtable_bit_map2,0),t.subtable_bit_map2)
     IF (band(t.subtable_bit_map2,clinical_event_sec_lbl_id)=clinical_event_sec_lbl_id)
      max_results_to_return += 1
     ENDIF
     IF (t.modifier_long_text_id > 0)
      long_text_size += 1, stat_i4 = alterlist(modifier->long_text_id_list,long_text_size), modifier
      ->long_text_id_list[long_text_size].long_text_id = t.modifier_long_text_id,
      modifier->long_text_id_list[long_text_size].reply_index = ndx
     ENDIF
    FOOT REPORT
     stat_i4 = alterlist(reply->event_list,ndx)
    WITH nocounter, memsort, orahintcbo("LEADING(t2 t)","USE_NL(t)","INDEX(t XAK2CLINICAL_EVENT)")
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (fetch_data_small(group_ind=i2) =null)
  DECLARE fds_index_use = vc WITH protect, noconstant(" ")
  IF (group_ind=0)
   DECLARE groupzerobatchsize = i4 WITH protect, constant(getbatchsize(g_eventcdsize1,100))
   SET g_nstart = 1
   SET g_loops = ceil((cnvtreal(g_eventcdsize1)/ groupzerobatchsize))
   SET g_expsize = (g_loops * groupzerobatchsize)
   SET stat_i4 = alterlist(ec_rank->cds,g_expsize)
   FOR (i = (g_eventcdsize1+ 1) TO g_expsize)
     SET ec_rank->cds[i].event_cd = ec_rank->cds[g_eventcdsize1].event_cd
   ENDFOR
   FOR (i = 1 TO g_loops)
    SELECT
     IF (encntr_size=0)
      event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
       .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
      valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), performed_dt_tm_ind = nullind(t
       .performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm)
      FROM (
       (
       (SELECT DISTINCT
        event_rank = rank() OVER(
        PARTITION BY ce.event_cd
        ORDER BY ce.event_end_dt_tm DESC), event_end_dt_tm = ce.event_end_dt_tm, valid_until_dt_tm =
        ce.valid_until_dt_tm,
        person_id = ce.person_id, event_cd = ce.event_cd
        FROM clinical_event ce
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,g_nstart,((g_nstart+ groupzerobatchsize) - 1),ce.event_cd,ec_rank->
         cds[event_cd_ndx].event_cd)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
        WITH sqltype("i4","dq8","dq8","f8","f8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
       t2),
       clinical_event t
      PLAN (t2
       WHERE t2.event_rank > begin_rank
        AND t2.event_rank <= end_rank)
       JOIN (t
       WHERE t.person_id=t2.person_id
        AND t.event_cd=t2.event_cd
        AND t.event_end_dt_tm=t2.event_end_dt_tm
        AND t.valid_until_dt_tm=t2.valid_until_dt_tm
        AND parser(parser_filter2)
        AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
        AND t.event_class_cd != event_class_placeholder
        AND t.event_class_cd != event_class_group
        AND ((t.view_level=1) OR (((t.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (t.event_class_cd=event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=t.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) )) )
      ORDER BY t2.event_cd, t2.event_rank
     ELSE
      event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
       .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
      valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), performed_dt_tm_ind = nullind(t
       .performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm)
      FROM (
       (
       (SELECT DISTINCT
        event_rank = rank() OVER(
        PARTITION BY ce.event_cd
        ORDER BY ce.event_end_dt_tm DESC), event_end_dt_tm = ce.event_end_dt_tm, valid_until_dt_tm =
        ce.valid_until_dt_tm,
        person_id = ce.person_id, event_cd = ce.event_cd
        FROM clinical_event ce
        WHERE (ce.person_id=request->person_id)
         AND expand(event_cd_ndx,g_nstart,((g_nstart+ groupzerobatchsize) - 1),ce.event_cd,ec_rank->
         cds[event_cd_ndx].event_cd)
         AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
         AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
        WITH sqltype("i4","dq8","dq8","f8","f8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
       t2),
       clinical_event t,
       encntr_id_gtmp ctt
      PLAN (t2
       WHERE t2.event_rank > begin_rank
        AND t2.event_rank <= end_rank)
       JOIN (t
       WHERE t.person_id=t2.person_id
        AND t.event_cd=t2.event_cd
        AND t.event_end_dt_tm=t2.event_end_dt_tm
        AND t.valid_until_dt_tm=t2.valid_until_dt_tm
        AND parser(parser_filter2)
        AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
        AND t.event_class_cd != event_class_placeholder
        AND t.event_class_cd != event_class_group
        AND ((t.view_level=1) OR (((t.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (t.event_class_cd=event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=t.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) )) )
       JOIN (ctt
       WHERE ctt.encntr_id=t.encntr_id)
      ORDER BY t2.event_cd, t2.event_rank
     ENDIF
     INTO "nl"
     HEAD REPORT
      ndx = size(reply->event_list,5)
      IF (ndx > 0
       AND mod((ndx+ 1),10) != 1)
       stat_i4 = alterlist(reply->event_list,((ndx+ 10) - mod(ndx,10)))
      ENDIF
      ec_idx = 0, ec_cnt = 0, long_text_size = 0,
      keep_items = 1
     HEAD t2.event_cd
      mod_index = locateval(ec_idx,1,g_eventcdsize1,t.event_cd,ec_rank->cds[ec_idx].event_cd), ec_cnt
       = ec_rank->cds[mod_index].result_qual, keep_items = 1
     HEAD t2.event_rank
      IF (ec_cnt >= max_results_to_return)
       keep_items = 0
      ENDIF
     DETAIL
      IF (keep_items > 0)
       ec_cnt += 1, ndx += 1
       IF (mod(ndx,10)=1)
        stat_i4 = alterlist(reply->event_list,(ndx+ 9))
       ENDIF
       reply->event_list[ndx].event_cd = t.event_cd, reply->event_list[ndx].event_id = t.event_id,
       reply->event_list[ndx].event_end_dt_tm = t.event_end_dt_tm,
       reply->event_list[ndx].result_val = t.result_val, reply->event_list[ndx].encntr_id = t
       .encntr_id, reply->event_list[ndx].event_end_dt_tm_ind = event_end_dt_tm_ind,
       reply->event_list[ndx].clinical_event_id = t.clinical_event_id, reply->event_list[ndx].
       valid_until_dt_tm = t.valid_until_dt_tm, reply->event_list[ndx].valid_until_dt_tm_ind =
       valid_until_dt_tm_ind,
       reply->event_list[ndx].view_level = t.view_level, reply->event_list[ndx].clinsig_updt_dt_tm =
       t.clinsig_updt_dt_tm, reply->event_list[ndx].clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind,
       reply->event_list[ndx].order_id = t.order_id, reply->event_list[ndx].order_action_sequence = t
       .order_action_sequence, reply->event_list[ndx].catalog_cd = t.catalog_cd,
       reply->event_list[ndx].contributor_system_cd = t.contributor_system_cd, reply->event_list[ndx]
       .reference_nbr = t.reference_nbr, reply->event_list[ndx].parent_event_id = t.parent_event_id,
       reply->event_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm, reply->event_list[ndx].
       valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->event_list[ndx].event_class_cd = t
       .event_class_cd,
       reply->event_list[ndx].event_tag = t.event_tag, reply->event_list[ndx].event_end_tz = t
       .event_end_tz, reply->event_list[ndx].task_assay_cd = t.task_assay_cd,
       reply->event_list[ndx].result_status_cd = t.result_status_cd, reply->event_list[ndx].
       publish_flag = t.publish_flag, reply->event_list[ndx].normalcy_cd = t.normalcy_cd,
       reply->event_list[ndx].subtable_bit_map = t.subtable_bit_map, reply->event_list[ndx].
       event_title_text = t.event_title_text, reply->event_list[ndx].result_val = t.result_val,
       reply->event_list[ndx].result_units_cd = t.result_units_cd, reply->event_list[ndx].
       performed_dt_tm = t.performed_dt_tm, reply->event_list[ndx].performed_dt_tm_ind =
       performed_dt_tm_ind,
       reply->event_list[ndx].performed_tz = t.performed_tz, reply->event_list[ndx].
       performed_prsnl_id = t.performed_prsnl_id, reply->event_list[ndx].normal_low = t.normal_low,
       reply->event_list[ndx].normal_high = t.normal_high, reply->event_list[ndx].updt_dt_tm = t
       .updt_dt_tm, reply->event_list[ndx].updt_dt_tm_ind = updt_dt_tm_ind,
       reply->event_list[ndx].note_importance_bit_map = t.note_importance_bit_map, reply->event_list[
       ndx].collating_seq = t.collating_seq, reply->event_list[ndx].entry_mode_cd = t.entry_mode_cd,
       reply->event_list[ndx].source_cd = t.source_cd, reply->event_list[ndx].clinical_seq = t
       .clinical_seq, reply->event_list[ndx].task_assay_version_nbr = t.task_assay_version_nbr,
       reply->event_list[ndx].modifier_long_text_id = t.modifier_long_text_id, reply->event_list[ndx]
       .order_id = t.order_id, reply->event_list[ndx].nomen_string_flag = t.nomen_string_flag,
       reply->event_list[ndx].ce_dynamic_label_id = t.ce_dynamic_label_id, reply->event_list[ndx].
       trait_bit_map = t.trait_bit_map, stat_vc = assign(validate(reply->event_list[ndx].
         normal_ref_range_txt,""),t.normal_ref_range_txt),
       stat_f8 = assign(validate(reply->event_list[ndx].ce_grouping_id,0),t.ce_grouping_id), stat_i4
        = assign(validate(reply->event_list[ndx].subtable_bit_map2,0),t.subtable_bit_map2)
       IF (band(t.subtable_bit_map2,clinical_event_sec_lbl_id)=clinical_event_sec_lbl_id)
        max_results_to_return += 1
       ENDIF
       IF (t.modifier_long_text_id > 0)
        long_text_size += 1, stat_i4 = alterlist(modifier->long_text_id_list,long_text_size),
        modifier->long_text_id_list[long_text_size].long_text_id = t.modifier_long_text_id,
        modifier->long_text_id_list[long_text_size].reply_index = ndx
       ENDIF
      ENDIF
     FOOT  t.event_cd
      ec_rank->cds[mod_index].result_qual = ec_cnt
     FOOT REPORT
      stat_i4 = alterlist(reply->event_list,ndx)
     WITH nocounter, memsort, orahintcbo("USE_MERGE(ctt)","INDEX(t XIE9CLINICAL_EVENT)",
       "LEADING(t2 t)","USE_NL(t)")
    ;end select
    SET g_nstart += groupzerobatchsize
   ENDFOR
  ELSE
   IF ((request->ce_dynamic_label_id > 0))
    SET fds_index_use = "INDEX(ce XIE22CLINICAL_EVENT)"
   ELSE
    SET fds_index_use = "INDEX(ce XIE9CLINICAL_EVENT)"
   ENDIF
   SELECT
    IF (encntr_size=0)
     event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
      .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
     valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), performed_dt_tm_ind = nullind(t
      .performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm)
     FROM (
      (
      (SELECT
       event_rank = rank() OVER(
       PARTITION BY ectsml.event_set_cd
       ORDER BY ce.event_end_dt_tm DESC), event_id = ce.event_id, event_end_dt_tm = ce
       .event_end_dt_tm
       FROM clinical_event ce,
        event_cd_gtmp ectsml
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=ectsml.event_cd
        AND parser(parser_filter)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.event_class_cd != event_class_group
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        AND ((ce.view_level=1) OR (((ce.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (ce.event_class_cd=
       event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=ce.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) ))
       ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce.event_id DESC
       WITH sqltype("f8","f8","dq8"), orahintcbo("LEADING(ectsml ce)",value(fds_index_use),
         "USE_NL(ce)")))
      t2),
      clinical_event t
    ELSE
     event_end_dt_tm_ind = nullind(t.event_end_dt_tm), valid_until_dt_tm_ind = nullind(t
      .valid_until_dt_tm), clinsig_updt_dt_tm_ind = nullind(t.clinsig_updt_dt_tm),
     valid_from_dt_tm_ind = nullind(t.valid_from_dt_tm), performed_dt_tm_ind = nullind(t
      .performed_dt_tm), updt_dt_tm_ind = nullind(t.updt_dt_tm)
     FROM (
      (
      (SELECT
       event_rank = rank() OVER(
       PARTITION BY ectsml.event_set_cd
       ORDER BY ce.event_end_dt_tm DESC), event_id = ce.event_id, event_end_dt_tm = ce
       .event_end_dt_tm
       FROM encntr_id_gtmp ettsml,
        clinical_event ce,
        event_cd_gtmp ectsml
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=ectsml.event_cd
        AND parser(parser_filter)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.event_class_cd != event_class_group
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
        AND ce.encntr_id=ettsml.encntr_id
        AND ((ce.view_level=1) OR (((ce.event_class_cd IN (event_class_txt, event_class_num,
       event_class_unknown, event_class_date, event_class_done)) OR (ce.event_class_cd=
       event_class_doc
        AND  EXISTS (
       (SELECT
        ce2.event_id
        FROM clinical_event ce2
        WHERE ce2.event_id=ce.parent_event_id
         AND ce2.event_class_cd=event_class_group)))) ))
       ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce.event_id DESC
       WITH sqltype("f8","f8","dq8"), orahintcbo("LEADING(ectsml ce ettsml)",value(fds_index_use),
         "USE_NL(ce)","USE_MERGE(ettsml)")))
      t2),
      clinical_event t
    ENDIF
    INTO "nl"
    PLAN (t2
     WHERE t2.event_rank <= max_results_to_return)
     JOIN (t
     WHERE t.event_id=t2.event_id
      AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
    HEAD REPORT
     ndx = size(reply->event_list,5)
     IF (ndx > 0
      AND mod((ndx+ 1),10) != 1)
      stat_i4 = alterlist(reply->event_list,((ndx+ 10) - mod(ndx,10)))
     ENDIF
     long_text_size = 0
    DETAIL
     ndx += 1
     IF (mod(ndx,10)=1)
      stat_i4 = alterlist(reply->event_list,(ndx+ 9))
     ENDIF
     reply->event_list[ndx].event_cd = t.event_cd, reply->event_list[ndx].event_id = t.event_id,
     reply->event_list[ndx].event_end_dt_tm = t.event_end_dt_tm,
     reply->event_list[ndx].result_val = t.result_val, reply->event_list[ndx].encntr_id = t.encntr_id,
     reply->event_list[ndx].event_end_dt_tm_ind = event_end_dt_tm_ind,
     reply->event_list[ndx].clinical_event_id = t.clinical_event_id, reply->event_list[ndx].
     valid_until_dt_tm = t.valid_until_dt_tm, reply->event_list[ndx].valid_until_dt_tm_ind =
     valid_until_dt_tm_ind,
     reply->event_list[ndx].view_level = t.view_level, reply->event_list[ndx].clinsig_updt_dt_tm = t
     .clinsig_updt_dt_tm, reply->event_list[ndx].clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind,
     reply->event_list[ndx].order_id = t.order_id, reply->event_list[ndx].order_action_sequence = t
     .order_action_sequence, reply->event_list[ndx].catalog_cd = t.catalog_cd,
     reply->event_list[ndx].contributor_system_cd = t.contributor_system_cd, reply->event_list[ndx].
     reference_nbr = t.reference_nbr, reply->event_list[ndx].parent_event_id = t.parent_event_id,
     reply->event_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm, reply->event_list[ndx].
     valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->event_list[ndx].event_class_cd = t
     .event_class_cd,
     reply->event_list[ndx].event_tag = t.event_tag, reply->event_list[ndx].event_end_tz = t
     .event_end_tz, reply->event_list[ndx].task_assay_cd = t.task_assay_cd,
     reply->event_list[ndx].result_status_cd = t.result_status_cd, reply->event_list[ndx].
     publish_flag = t.publish_flag, reply->event_list[ndx].normalcy_cd = t.normalcy_cd,
     reply->event_list[ndx].subtable_bit_map = t.subtable_bit_map, reply->event_list[ndx].
     event_title_text = t.event_title_text, reply->event_list[ndx].result_val = t.result_val,
     reply->event_list[ndx].result_units_cd = t.result_units_cd, reply->event_list[ndx].
     performed_dt_tm = t.performed_dt_tm, reply->event_list[ndx].performed_dt_tm_ind =
     performed_dt_tm_ind,
     reply->event_list[ndx].performed_tz = t.performed_tz, reply->event_list[ndx].performed_prsnl_id
      = t.performed_prsnl_id, reply->event_list[ndx].normal_low = t.normal_low,
     reply->event_list[ndx].normal_high = t.normal_high, reply->event_list[ndx].updt_dt_tm = t
     .updt_dt_tm, reply->event_list[ndx].updt_dt_tm_ind = updt_dt_tm_ind,
     reply->event_list[ndx].note_importance_bit_map = t.note_importance_bit_map, reply->event_list[
     ndx].collating_seq = t.collating_seq, reply->event_list[ndx].entry_mode_cd = t.entry_mode_cd,
     reply->event_list[ndx].source_cd = t.source_cd, reply->event_list[ndx].clinical_seq = t
     .clinical_seq, reply->event_list[ndx].task_assay_version_nbr = t.task_assay_version_nbr,
     reply->event_list[ndx].modifier_long_text_id = t.modifier_long_text_id, reply->event_list[ndx].
     order_id = t.order_id, reply->event_list[ndx].nomen_string_flag = t.nomen_string_flag,
     reply->event_list[ndx].ce_dynamic_label_id = t.ce_dynamic_label_id, reply->event_list[ndx].
     trait_bit_map = t.trait_bit_map, stat_vc = assign(validate(reply->event_list[ndx].
       normal_ref_range_txt,""),t.normal_ref_range_txt),
     stat_f8 = assign(validate(reply->event_list[ndx].ce_grouping_id,0),t.ce_grouping_id), stat_i4 =
     assign(validate(reply->event_list[ndx].subtable_bit_map2,0),t.subtable_bit_map2)
     IF (band(t.subtable_bit_map2,clinical_event_sec_lbl_id)=clinical_event_sec_lbl_id)
      max_results_to_return += 1
     ENDIF
     IF (t.modifier_long_text_id > 0)
      long_text_size += 1, stat_i4 = alterlist(modifier->long_text_id_list,long_text_size), modifier
      ->long_text_id_list[long_text_size].long_text_id = t.modifier_long_text_id,
      modifier->long_text_id_list[long_text_size].reply_index = ndx
     ENDIF
    FOOT REPORT
     stat_i4 = alterlist(reply->event_list,ndx)
    WITH nocounter, memsort, orahintcbo("LEADING(t2 t)","USE_NL(t)","INDEX(t XAK2CLINICAL_EVENT)")
   ;end select
  ENDIF
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET modify = nopredeclare
END GO
