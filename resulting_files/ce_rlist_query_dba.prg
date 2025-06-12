CREATE PROGRAM ce_rlist_query:dba
 DECLARE srvstat = i4
 DECLARE hitem = i4 WITH protect, noconstant(0)
 DECLARE determine_date_ranges(null) = null
 DECLARE configure_filters(null) = null
 DECLARE pad_encounter_array(null) = null
 DECLARE fetch_events(null) = null
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 DECLARE result_status_unauth = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,result_status_unauth)
 DECLARE result_status_auth = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,result_status_auth)
 DECLARE result_status_modified = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,result_status_modified)
 DECLARE result_status_transcribed = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,result_status_transcribed)
 DECLARE result_status_dictated = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"DICTATED",1,result_status_dictated)
 DECLARE result_status_altered = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,result_status_altered)
 DECLARE search_not_empty = i4 WITH constant(1), protect
 DECLARE search_descending = i4 WITH constant(0), protect
 DECLARE event_nsize = i2 WITH constant(20), protect
 DECLARE encntr_nsize = i2 WITH constant(50), protect
 DECLARE pos = i4
 DECLARE num = i4
 DECLARE result_count = i4 WITH noconstant(0), protect
 DECLARE eascending = i4 WITH constant(1), protect
 DECLARE edescending = i4 WITH constant(0), protect
 DECLARE incomplete_filter = vc WITH noconstant("(0=0)"), protect
 DECLARE incomplete_filter_inner = vc WITH noconstant("(0=0)"), protect
 DECLARE order_filter = vc WITH noconstant("(0=0)"), protect
 DECLARE order_filter_inner = vc WITH noconstant("(0=0)"), protect
 DECLARE encounter_filter = vc WITH noconstant("(0=0)"), protect
 DECLARE encounter_filter_inner = vc WITH noconstant("(0=0)"), protect
 DECLARE label_filter = vc WITH noconstant("(0=0)"), protect
 DECLARE label_filter_inner = vc WITH noconstant("(0=0)"), protect
 CALL pad_encounter_array(null)
 CALL configure_filters(null)
 CALL determine_date_ranges(null)
 CALL fetch_events(null)
 GO TO exit_script
 SUBROUTINE fetch_events(null)
   DECLARE event_cd_ndx = i4 WITH noconstant(1), protect
   DECLARE min_date = dq8
   DECLARE max_date = dq8
   WHILE (event_cd_ndx <= size(request->event_cd_list,5))
     SET result_count = 0
     IF ((request->event_cd_list[event_cd_ndx].event_cd_count > 0))
      SET min_date = request->event_cd_list[event_cd_ndx].min_date
      SET max_date = request->event_cd_list[event_cd_ndx].max_date
      SET result_count = creeping_fetch(request->event_cd_list[event_cd_ndx].event_cd,min_date,
       max_date)
      IF (result_count=0
       AND max_date != min_date)
       SET result_count = fetch_data(request->event_cd_list[event_cd_ndx].event_cd,min_date,max_date)
      ENDIF
     ENDIF
     SET event_cd_ndx += 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE pad_encounter_array(null)
   DECLARE nsize = i4 WITH protect, noconstant(encntr_nsize)
   DECLARE orig_size = i4 WITH protect, constant(size(request->encntr_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   SET new_size = (loop_cnt * nsize)
   IF (new_size > orig_size)
    SET stat = alterlist(request->encntr_list,new_size)
    FOR (i = (orig_size+ 1) TO new_size)
      SET request->encntr_list[i].encntr_id = request->encntr_list[orig_size].encntr_id
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE configure_filters(null)
   IF ((request->incomplete_ind=0))
    SET incomplete_filter = concat("t.result_status_cd+0 in (RESULT_STATUS_UNAUTH,",
     "RESULT_STATUS_AUTH,RESULT_STATUS_MODIFIED,","RESULT_STATUS_TRANSCRIBED,RESULT_STATUS_DICTATED,",
     "RESULT_STATUS_ALTERED) ")
    SET incomplete_filter_inner = concat("ce.result_status_cd+0 in (RESULT_STATUS_UNAUTH,",
     "RESULT_STATUS_AUTH,RESULT_STATUS_MODIFIED,","RESULT_STATUS_TRANSCRIBED,RESULT_STATUS_DICTATED,",
     "RESULT_STATUS_ALTERED) ")
   ENDIF
   IF ((request->order_id > 0.0))
    SET order_filter = concat("exists (select ol.order_id from ce_event_order_link ol ",
     "        where ol.event_id = t.event_id ","          and ol.order_id = request->order_id ",
     "          and ol.valid_until_dt_tm = cnvtdatetimeutc('31-DEC-2100'))")
    SET order_filter_inner = concat("exists (select ol.order_id from ce_event_order_link ol ",
     "        where ol.event_id = ce.event_id ","          and ol.order_id = request->order_id ",
     "          and ol.valid_until_dt_tm = cnvtdatetimeutc('31-DEC-2100'))")
   ENDIF
   IF (size(request->encntr_list,5))
    SET encounter_filter = concat("expand (encntr_id_ndx, nstart, nstart+nsize-1, t.encntr_id+0, ",
     " request->encntr_list[encntr_id_ndx]->encntr_id)")
    SET encounter_filter_inner = concat(
     "expand (encntr_id_ndx, nstart, nstart+nsize-1, ce.encntr_id+0, ",
     " request->encntr_list[encntr_id_ndx]->encntr_id)")
   ENDIF
   IF ((request->ce_dynamic_label_id > 0))
    SET label_filter = "t.ce_dynamic_label_id = request->ce_dynamic_label_id"
    SET label_filter_inner = "ce.ce_dynamic_label_id = request->ce_dynamic_label_id"
   ELSE
    SET label_filter = "t.ce_dynamic_label_id+0 = 0"
    SET label_filter_inner = "ce.ce_dynamic_label_id+0 = 0"
   ENDIF
 END ;Subroutine
 SUBROUTINE determine_date_ranges(null)
   DECLARE ndx = i4 WITH noconstant(1), protect
   DECLARE nsize = i4 WITH protect, noconstant(event_nsize)
   DECLARE orig_size = i4 WITH protect, constant(size(request->event_cd_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE min_date = dq8 WITH protect
   DECLARE max_date = dq8 WITH protect
   IF ((request->direction_flag=search_descending))
    IF ((request->search_begin_dt_tm_ind=search_not_empty))
     SET max_date = request->search_begin_dt_tm
    ELSE
     SET max_date = cnvtdatetimeutc("31-DEC-2100")
    ENDIF
    IF ((request->search_end_dt_tm_ind=search_not_empty))
     SET min_date = request->search_end_dt_tm
    ELSE
     SET min_date = cnvtdatetimeutc("1-JAN-1850")
    ENDIF
   ELSE
    IF ((request->search_begin_dt_tm_ind=search_not_empty))
     SET min_date = request->search_begin_dt_tm
    ELSE
     SET min_date = cnvtdatetimeutc("31-DEC-2100")
    ENDIF
    IF ((request->search_end_dt_tm_ind=search_not_empty))
     SET max_date = request->search_end_dt_tm
    ELSE
     SET max_date = cnvtdatetimeutc("1-JAN-1850")
    ENDIF
   ENDIF
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   SET new_size = (loop_cnt * nsize)
   IF (new_size > orig_size)
    SET stat = alterlist(request->event_cd_list,new_size)
    FOR (i = (orig_size+ 1) TO new_size)
      SET request->event_cd_list[i].event_cd = request->event_cd_list[orig_size].event_cd
    ENDFOR
   ENDIF
   SELECT INTO "nl"
    a.event_cd, a.event_cd_count, a.select_min_date,
    a.select_max_date
    FROM (
     (
     (SELECT
      ce.event_cd, event_cd_count = count(*), select_min_date = min(ce.event_end_dt_tm),
      select_max_date = max(ce.event_end_dt_tm)
      FROM clinical_event ce
      WHERE (ce.person_id=request->person_id)
       AND expand(ndx,nstart,((nstart+ nsize) - 1),ce.event_cd,request->event_cd_list[ndx].event_cd)
       AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
      GROUP BY ce.event_cd
      WITH sqltype("f8","f8","dq8","dq8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
     a),
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (a
     WHERE a.event_cd_count > 0)
    ORDER BY a.event_cd_count DESC
    DETAIL
     pos = locateval(num,1,size(request->event_cd_list,5),a.event_cd,request->event_cd_list[num].
      event_cd)
     IF (pos > 0)
      request->event_cd_list[pos].event_cd_count = a.event_cd_count, request->event_cd_list[pos].
      min_date = cnvtdatetimeutc(a.select_min_date), request->event_cd_list[pos].max_date =
      cnvtdatetimeutc(a.select_max_date)
     ENDIF
    WITH nocounter
   ;end select
   IF (new_size > orig_size)
    SET stat = alterlist(request->event_cd_list,orig_size)
   ENDIF
 END ;Subroutine
 SUBROUTINE (creeping_fetch(event_cd=f8,event_min_date=dq8(ref),event_max_date=dq8(ref)) =i4)
   DECLARE iteration = i4 WITH noconstant(0), protect
   DECLARE min_date = dq8 WITH protect, noconstant(event_min_date)
   DECLARE max_date = dq8 WITH protect, noconstant(event_max_date)
   DECLARE not_done = i2 WITH protect, noconstant(1)
   DECLARE result_count = i2 WITH protect
   DECLARE date_found = i2 WITH protect, noconstant(1)
   DECLARE range_str = vc WITH protect
   DECLARE range_val = i4 WITH protect
   WHILE (not_done
    AND iteration < 20)
     IF (iteration < 5)
      SET range_val = (2** iteration)
     ELSE
      SET range_val = 30
     ENDIF
     SET range_str = build(range_val,",D")
     IF ((request->direction_flag=search_descending))
      SET min_date = cnvtlookbehind(range_str,event_max_date)
      IF (min_date < event_min_date)
       SET min_date = event_min_date
      ENDIF
      SET result_count = fetch_data(event_cd,min_date,event_max_date)
      IF (result_count=0)
       SET date_found = 0
       SET event_max_date = cnvtlookbehind("1,S",min_date)
       IF (event_max_date > event_min_date)
        SELECT INTO "nl"
         a.select_max_date
         FROM (
          (
          (SELECT
           select_max_date = max(ce.event_end_dt_tm)
           FROM clinical_event ce
           WHERE (ce.person_id=request->person_id)
            AND ce.event_cd=event_cd
            AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(event_min_date) AND cnvtdatetimeutc(
            event_max_date)
            AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
           WITH sqltype("dq8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
          a)
         WHERE a.select_max_date > cnvtdatetimeutc("1-Jan-1850")
         DETAIL
          date_found = 1, event_max_date = a.select_max_date
         WITH nocounter
        ;end select
       ENDIF
       IF (date_found=0)
        SET not_done = 0
       ENDIF
      ELSE
       SET not_done = 0
      ENDIF
     ELSE
      SET max_date = cnvtlookahead(range_str,event_min_date)
      IF (max_date > event_max_date)
       SET max_date = event_max_date
      ENDIF
      SET result_count = fetch_data(event_cd,event_min_date,max_date)
      IF (result_count=0)
       SET date_found = 0
       SET event_min_date = cnvtlookahead("1,S",max_date)
       IF (event_min_date < event_max_date)
        SELECT INTO "nl"
         a.select_min_date
         FROM (
          (
          (SELECT
           select_min_date = min(ce.event_end_dt_tm)
           FROM clinical_event ce
           WHERE (ce.person_id=request->person_id)
            AND ce.event_cd=event_cd
            AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(event_min_date) AND cnvtdatetimeutc(
            event_max_date)
            AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
           WITH sqltype("dq8"), orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")))
          a)
         WHERE a.select_min_date > cnvtdatetimeutc("1-Jan-1850")
         DETAIL
          date_found = 1, event_min_date = a.select_min_date
         WITH nocounter
        ;end select
       ENDIF
       IF (date_found=0)
        SET not_done = 0
       ENDIF
      ELSE
       SET not_done = 0
      ENDIF
     ENDIF
     SET iteration += 1
   ENDWHILE
   IF (result_count=0
    AND date_found=0)
    SET event_max_date = event_min_date
   ENDIF
   RETURN(result_count)
 END ;Subroutine
 SUBROUTINE (fetch_data(event_cd=f8,min_date=dq8,max_date=dq8) =i4)
   DECLARE encntr_id_ndx = i4 WITH noconstant(1), protect
   DECLARE nsize = i4 WITH protect, constant(encntr_nsize), protect
   DECLARE orig_size = i4 WITH protect, constant(size(request->encntr_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   DECLARE ndx = i4 WITH noconstant(0), protect
   DECLARE result_count = i4 WITH noconstant(0), protect
   DECLARE stat = i4 WITH protect
   DECLARE ocrq_fd_index = vc WITH protect, noconstant(" ")
   IF ((request->ce_dynamic_label_id > 0))
    SET ocrq_fd_index = "INDEX(ce XIE22CLINICAL_EVENT)"
   ELSE
    SET ocrq_fd_index = "INDEX(ce XIE9CLINICAL_EVENT)"
   ENDIF
   SET ndx = size(reply->rb_list,5)
   SELECT
    IF ((request->direction_flag=search_descending))
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (t
      WHERE (t.person_id=request->person_id)
       AND t.event_cd=event_cd
       AND parser(incomplete_filter)
       AND parser(label_filter)
       AND parser(order_filter)
       AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
       AND t.event_class_cd != event_class_placeholder
       AND parser(encounter_filter)
       AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
       AND (t.event_end_dt_tm=
      (SELECT
       max(ce.event_end_dt_tm)
       FROM clinical_event ce
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=event_cd
        AND parser(encounter_filter_inner)
        AND parser(incomplete_filter_inner)
        AND parser(order_filter_inner)
        AND parser(label_filter_inner)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
       WITH orahintcbo("LEADING(ce)",value(ocrq_fd_index),"USE_NL(ol)"))))
     ORDER BY t.event_end_dt_tm DESC
    ELSE
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (t
      WHERE (t.person_id=request->person_id)
       AND t.event_cd=event_cd
       AND parser(incomplete_filter)
       AND parser(label_filter)
       AND parser(order_filter)
       AND  NOT (t.record_status_cd IN (record_status_deleted, record_status_draft))
       AND t.event_class_cd != event_class_placeholder
       AND parser(encounter_filter)
       AND t.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
       AND (t.event_end_dt_tm=
      (SELECT
       min(ce.event_end_dt_tm)
       FROM clinical_event ce
       WHERE (ce.person_id=request->person_id)
        AND ce.event_cd=event_cd
        AND parser(encounter_filter_inner)
        AND parser(incomplete_filter_inner)
        AND parser(order_filter_inner)
        AND parser(label_filter_inner)
        AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
        AND ce.event_class_cd != event_class_placeholder
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
        AND ce.event_end_dt_tm BETWEEN cnvtdatetimeutc(min_date) AND cnvtdatetimeutc(max_date)
       WITH orahintcbo("LEADING(ce)",value(ocrq_fd_index),"USE_NL(ol)"))))
     ORDER BY t.event_end_dt_tm
    ENDIF
    INTO "nl"
    FROM clinical_event t,
     (dummyt d  WITH seq = value(loop_cnt))
    HEAD REPORT
     firstdttm = cnvtdatetimeutc(t.event_end_dt_tm)
    DETAIL
     IF (cnvtdatetimeutc(t.event_end_dt_tm)=firstdttm)
      ndx += 1, stat = alterlist(reply->rb_list,ndx), reply->rb_list[ndx].person_id = t.person_id,
      reply->rb_list[ndx].event_id = t.event_id, reply->rb_list[ndx].event_cd = t.event_cd, reply->
      rb_list[ndx].event_start_dt_tm_ind = nullind(t.event_start_dt_tm),
      reply->rb_list[ndx].event_start_dt_tm = t.event_start_dt_tm, reply->rb_list[ndx].
      event_end_dt_tm_ind = nullind(t.event_end_dt_tm), reply->rb_list[ndx].event_end_dt_tm = t
      .event_end_dt_tm,
      reply->rb_list[ndx].event_end_dt_tm_os_ind = nullind(t.event_end_dt_tm_os), reply->rb_list[ndx]
      .event_end_dt_tm_os = t.event_end_dt_tm_os, reply->rb_list[ndx].event_class_cd = t
      .event_class_cd,
      reply->rb_list[ndx].event_tag = trim(t.event_tag), reply->rb_list[ndx].record_status_cd = t
      .record_status_cd, reply->rb_list[ndx].result_status_cd = t.result_status_cd,
      reply->rb_list[ndx].publish_flag = t.publish_flag, reply->rb_list[ndx].normalcy_cd = t
      .normalcy_cd, reply->rb_list[ndx].updt_dt_tm_ind = nullind(t.updt_dt_tm),
      reply->rb_list[ndx].updt_dt_tm = t.updt_dt_tm, reply->rb_list[ndx].subtable_bit_map = t
      .subtable_bit_map, reply->rb_list[ndx].encntr_id = t.encntr_id,
      reply->rb_list[ndx].encntr_financial_id = t.encntr_financial_id, reply->rb_list[ndx].
      accession_nbr = trim(t.accession_nbr), reply->rb_list[ndx].contributor_system_cd = t
      .contributor_system_cd,
      reply->rb_list[ndx].inquire_security_cd = t.inquire_security_cd, reply->rb_list[ndx].view_level
       = t.view_level, reply->rb_list[ndx].order_id = t.order_id,
      reply->rb_list[ndx].catalog_cd = t.catalog_cd, reply->rb_list[ndx].parent_event_id = t
      .parent_event_id, reply->rb_list[ndx].task_assay_cd = t.task_assay_cd,
      reply->rb_list[ndx].event_title_text = trim(t.event_title_text), reply->rb_list[ndx].result_val
       = trim(t.result_val), reply->rb_list[ndx].result_units_cd = t.result_units_cd,
      reply->rb_list[ndx].result_time_units_cd = t.result_time_units_cd, reply->rb_list[ndx].
      verified_dt_tm_ind = nullind(t.verified_dt_tm), reply->rb_list[ndx].verified_dt_tm = t
      .verified_dt_tm,
      reply->rb_list[ndx].verified_prsnl_id = t.verified_prsnl_id, reply->rb_list[ndx].
      performed_dt_tm_ind = nullind(t.performed_dt_tm), reply->rb_list[ndx].performed_dt_tm = t
      .performed_dt_tm,
      reply->rb_list[ndx].performed_prsnl_id = t.performed_prsnl_id, reply->rb_list[ndx].normal_low
       = trim(t.normal_low), reply->rb_list[ndx].normal_high = trim(t.normal_high),
      reply->rb_list[ndx].critical_low = trim(t.critical_low), reply->rb_list[ndx].critical_high =
      trim(t.critical_high), reply->rb_list[ndx].expiration_dt_tm_ind = nullind(t.expiration_dt_tm),
      reply->rb_list[ndx].expiration_dt_tm = t.expiration_dt_tm, reply->rb_list[ndx].
      note_importance_bit_map = t.note_importance_bit_map, reply->rb_list[ndx].updt_cnt = t.updt_cnt,
      reply->rb_list[ndx].collating_seq = trim(t.collating_seq), reply->rb_list[ndx].
      order_action_sequence = t.order_action_sequence, reply->rb_list[ndx].entry_mode_cd = t
      .entry_mode_cd,
      reply->rb_list[ndx].source_cd = t.source_cd, reply->rb_list[ndx].clinical_seq = trim(t
       .clinical_seq), reply->rb_list[ndx].event_start_tz = t.event_start_tz,
      reply->rb_list[ndx].event_end_tz = t.event_end_tz, reply->rb_list[ndx].verified_tz = t
      .verified_tz, reply->rb_list[ndx].performed_tz = t.performed_tz,
      reply->rb_list[ndx].valid_from_dt_tm = t.valid_from_dt_tm, reply->rb_list[ndx].
      nomen_string_flag = t.nomen_string_flag, reply->rb_list[ndx].ce_dynamic_label_id = t
      .ce_dynamic_label_id,
      result_count += 1
     ENDIF
    WITH nocounter, memsort, orahintcbo("INDEX(t XIE9CLINICAL_EVENT)","USE_NL(ol)")
   ;end select
   RETURN(result_count)
 END ;Subroutine
#exit_script
END GO
