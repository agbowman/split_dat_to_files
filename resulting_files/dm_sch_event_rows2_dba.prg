CREATE PROGRAM dm_sch_event_rows2:dba
 FREE SET t_recur_rec
 RECORD t_recur_rec(
   1 purge_dt_tm = dq8
   1 qual_cnt = i4
   1 qual[*]
     2 sch_event_id = f8
     2 row_id = vc
     2 child_qual_cnt = i4
     2 child_qual[*]
       3 sch_event_id = f8
       3 row_id = vc
 )
 FREE SET t_prot_rec
 RECORD t_prot_rec(
   1 purge_dt_tm = dq8
   1 qual_cnt = i4
   1 qual[*]
     2 protocol_parent_id = f8
     2 sch_event_id = f8
     2 row_id = vc
     2 child_qual_cnt = i4
     2 child_qual[*]
       3 protocol_parent_id = f8
       3 sch_event_id = f8
       3 row_id = vc
 )
 FREE SET t_events_rec
 RECORD t_events_rec(
   1 qual_cnt = i4
   1 qual[*]
     2 sch_event_id = f8
 )
 DECLARE g_minimum_keep_days = f8 WITH constant(60.0)
 DECLARE g_rows_between_commit = f8 WITH constant(1.0)
 DECLARE v_days_to_keep = f8 WITH noconstant(- (1.0))
 DECLARE v_row_cnt = i4 WITH noconstant(0)
 DECLARE v_single_row_cnt = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE v_last_event_read = i4 WITH noconstant(0)
 DECLARE iforcount = i4 WITH noconstant(0)
 DECLARE iqualmaxrows = i4 WITH noconstant(0)
 DECLARE purge_script_choosen2 = i4 WITH protect, noconstant(0)
 DECLARE over_max_event_limit = i2 WITH protect, noconstant(0)
 DECLARE v_row_qualifies_ind = i2 WITH noconstant(1)
 DECLARE v_continue_rate = f8 WITH constant(0.5)
 SET dm_sch_event_rows2_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(dm_sch_event_rows2_request->tokens,5))
   IF ((dm_sch_event_rows2_request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(dm_sch_event_rows2_request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < g_minimum_keep_days)
  SET dm_sch_event_rows2_reply->err_code = - (1)
  SET dm_sch_event_rows2_reply->err_msg = uar_i18nbuildmessage(i18nhandle,"KEEPDAYS",
   "%1 %2 %3 %4","ssss","You must keep at least ",
   nullterm(trim(cnvtstring(g_minimum_keep_days),3))," days worth of data.  You entered ",nullterm(
    trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
  GO TO exit_script
 ENDIF
 SET dm_sch_event_rows2_reply->table_name = "SCH_EVENT"
 SET dm_sch_event_rows2_reply->rows_between_commit = g_rows_between_commit
 SET t_recur_rec->purge_dt_tm = cnvtdatetime((curdate - v_days_to_keep),curtime3)
 SET t_recur_rec->qual_cnt = 0
 SET stat = alterlist(t_recur_rec->qual,0)
 SET t_prot_rec->purge_dt_tm = cnvtdatetime((curdate - v_days_to_keep),curtime3)
 SET t_prot_rec->qual_cnt = 0
 SET stat = alterlist(t_prot_rec->qual,0)
 SET v_single_row_cnt = 0
 SET iqualmaxrows = (dm_sch_event_rows2_request->max_rows * 4)
 SET t_events_rec->qual_cnt = 0
 SELECT INTO "nl:"
  se.sch_event_id
  FROM sch_booking sb,
   sch_appt sa,
   sch_event se
  PLAN (sb
   WHERE sb.beg_dt_tm < cnvtdatetime(t_recur_rec->purge_dt_tm)
    AND ((sb.booking_id+ 0) > 0)
    AND sb.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sa
   WHERE sa.booking_id=sb.booking_id
    AND ((sa.sch_event_id+ 0) > v_last_event_read)
    AND sa.state_meaning != "RESCHEDULED"
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND (se.recur_type_flag != (2+ 0))
    AND (se.protocol_type_flag != (1+ 0))
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   t_events_rec->qual_cnt = (t_events_rec->qual_cnt+ 1)
   IF (mod(t_events_rec->qual_cnt,100)=1)
    stat = alterlist(t_events_rec->qual,(t_events_rec->qual_cnt+ 99))
   ENDIF
   t_events_rec->qual[t_events_rec->qual_cnt].sch_event_id = se.sch_event_id
  WITH nocounter, maxqual(sb,value(iqualmaxrows))
 ;end select
 CALL echo(t_events_rec->qual_cnt)
 IF ((t_events_rec->qual_cnt <= 0))
  GO TO exit_script
 ENDIF
 DECLARE idx3 = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(100)
 DECLARE nstart = i4
 SET ntotal2 = t_events_rec->qual_cnt
 IF (mod(ntotal2,nsize) > 0)
  SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 ELSE
  SET ntotal = ntotal2
 ENDIF
 SET stat = alterlist(t_events_rec->qual,ntotal)
 SET nstart = 1
 FOR (idx3 = (ntotal2+ 1) TO ntotal)
   SET t_events_rec->qual[idx3].sch_event_id = t_events_rec->qual[ntotal2].sch_event_id
 ENDFOR
 SET num1 = 0
 SELECT INTO "nl:"
  se.sch_event_id, index = locateval(num1,1,ntotal2,se.sch_event_id,t_events_rec->qual[num1].
   sch_event_id)
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   sch_event se
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (se
   WHERE expand(idx3,nstart,(nstart+ (nsize - 1)),se.sch_event_id,t_events_rec->qual[idx3].
    sch_event_id))
  ORDER BY se.sch_event_id
  HEAD se.sch_event_id
   v_last_event_read = se.sch_event_id
   IF (se.recur_parent_id=0
    AND se.protocol_parent_id=0
    AND se.protocol_type_flag != 3)
    v_row_cnt = (v_row_cnt+ 1), v_single_row_cnt = (v_single_row_cnt+ 1)
    IF (mod(v_row_cnt,100)=1)
     stat = alterlist(dm_sch_event_rows2_reply->rows,(v_row_cnt+ 99))
    ENDIF
    dm_sch_event_rows2_reply->rows[v_row_cnt].row_id = se.rowid
   ELSEIF (se.recur_type_flag=1)
    t_recur_rec->qual_cnt = (t_recur_rec->qual_cnt+ 1)
    IF (mod(t_recur_rec->qual_cnt,100)=1)
     stat = alterlist(t_recur_rec->qual,(t_recur_rec->qual_cnt+ 99))
    ENDIF
    t_recur_rec->qual[t_recur_rec->qual_cnt].sch_event_id = se.sch_event_id, t_recur_rec->qual[
    t_recur_rec->qual_cnt].row_id = se.rowid
   ELSEIF (se.protocol_type_flag=3)
    FOR (iforcount = 1 TO t_prot_rec->qual_cnt)
      IF ((t_prot_rec->qual[iforcount].protocol_parent_id=se.protocol_parent_id))
       iforcount = (t_prot_rec->qual_cnt+ 1)
      ENDIF
    ENDFOR
    IF ((iforcount < (t_prot_rec->qual_cnt+ 2)))
     t_prot_rec->qual_cnt = (t_prot_rec->qual_cnt+ 1)
     IF (mod(t_prot_rec->qual_cnt,100)=1)
      stat = alterlist(t_prot_rec->qual,(t_prot_rec->qual_cnt+ 99))
     ENDIF
     t_prot_rec->qual[t_prot_rec->qual_cnt].protocol_parent_id = se.protocol_parent_id
    ENDIF
   ENDIF
  WITH nocounter, maxqual(sb,value(iqualmaxrows))
 ;end select
 IF ((v_row_cnt >= dm_sch_event_rows2_request->max_rows))
  SET over_max_event_limit = 1
  SET v_row_cnt = dm_sch_event_rows2_request->max_rows
  SET stat = alterlist(dm_sch_event_rows2_reply->rows,v_row_cnt)
  GO TO exit_script
 ENDIF
 IF ((((v_single_row_cnt+ t_recur_rec->qual_cnt)+ t_prot_rec->qual_cnt)=0))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(t_recur_rec->qual,t_recur_rec->qual_cnt)
 SET stat = alterlist(t_prot_rec->qual,t_prot_rec->qual_cnt)
 DECLARE idx = i4
 SET ntotal2 = size(t_recur_rec->qual,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(t_recur_rec->qual,ntotal)
 SET nstart = 1
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET t_recur_rec->qual[idx].sch_event_id = t_recur_rec->qual[ntotal2].sch_event_id
 ENDFOR
 SET num1 = 0
 IF ((t_recur_rec->qual_cnt > 0))
  SELECT INTO "nl:"
   se.sch_event_id, index = locateval(num1,1,ntotal2,se.recur_parent_id,t_recur_rec->qual[num1].
    sch_event_id)
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    sch_event se,
    sch_appt sa
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (se
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),se.recur_parent_id,t_recur_rec->qual[idx].
     sch_event_id)
     AND ((se.recur_type_flag+ 0)=2)
     AND ((se.protocol_parent_id+ 0)=0)
     AND ((se.sch_event_id+ 0) > 0)
     AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (sa
    WHERE sa.sch_event_id=se.sch_event_id
     AND sa.state_meaning != "RESCHEDULED"
     AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY index, se.sch_event_id
   HEAD index
    v_row_qualifies_ind = 1
   HEAD se.sch_event_id
    IF (((sa.beg_dt_tm >= cnvtdatetime(t_recur_rec->purge_dt_tm)) OR ((((v_row_cnt+ t_recur_rec->
    qual[index].child_qual_cnt)+ 1) >= dm_sch_event_rows2_request->max_rows))) )
     v_row_qualifies_ind = 0
    ELSE
     t_recur_rec->qual[index].child_qual_cnt = (t_recur_rec->qual[index].child_qual_cnt+ 1)
     IF (mod(t_recur_rec->qual[index].child_qual_cnt,10)=1)
      stat = alterlist(t_recur_rec->qual[index].child_qual,(t_recur_rec->qual[index].child_qual_cnt+
       9))
     ENDIF
     t_recur_rec->qual[index].child_qual[t_recur_rec->qual[index].child_qual_cnt].sch_event_id = se
     .sch_event_id, t_recur_rec->qual[index].child_qual[t_recur_rec->qual[index].child_qual_cnt].
     row_id = se.rowid
    ENDIF
   FOOT  index
    stat = alterlist(t_recur_rec->qual[index].child_qual,t_recur_rec->qual[index].child_qual_cnt)
    IF (v_row_qualifies_ind=1)
     v_row_cnt = (v_row_cnt+ 1)
     IF (mod(v_row_cnt,100)=1)
      stat = alterlist(dm_sch_event_rows2_reply->rows,(v_row_cnt+ 99))
     ENDIF
     dm_sch_event_rows2_reply->rows[v_row_cnt].row_id = t_recur_rec->qual[index].row_id
     FOR (child_ndx = 1 TO t_recur_rec->qual[index].child_qual_cnt)
       v_row_cnt = (v_row_cnt+ 1)
       IF (mod(v_row_cnt,100)=1)
        stat = alterlist(dm_sch_event_rows2_reply->rows,(v_row_cnt+ 99))
       ENDIF
       dm_sch_event_rows2_reply->rows[v_row_cnt].row_id = t_recur_rec->qual[index].child_qual[
       child_ndx].row_id
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((v_row_cnt >= dm_sch_event_rows2_request->max_rows))
  SET over_max_event_limit = 1
  SET v_row_cnt = dm_sch_event_rows2_request->max_rows
  SET stat = alterlist(dm_sch_event_rows2_reply->rows,v_row_cnt)
  GO TO exit_script
 ENDIF
 DECLARE idx2 = i4
 SET ntotal2 = size(t_prot_rec->qual,5)
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(t_prot_rec->qual,ntotal)
 SET nstart = 1
 FOR (idx2 = (ntotal2+ 1) TO ntotal)
   SET t_prot_rec->qual[idx2].protocol_parent_id = t_prot_rec->qual[ntotal2].protocol_parent_id
 ENDFOR
 SET num1 = 0
 IF ((t_prot_rec->qual_cnt > 0))
  SELECT INTO "nl:"
   se2.sch_event_id, index = locateval(num1,1,ntotal2,se2.sch_event_id,t_prot_rec->qual[num1].
    protocol_parent_id)
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    sch_event se2,
    sch_event se,
    sch_appt sa
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (se2
    WHERE expand(idx2,nstart,(nstart+ (nsize - 1)),se2.sch_event_id,t_prot_rec->qual[idx2].
     protocol_parent_id)
     AND ((se2.protocol_type_flag+ 0)=1)
     AND ((se2.recur_parent_id+ 0)=0)
     AND se2.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (se
    WHERE se.protocol_parent_id=se2.sch_event_id
     AND ((se.protocol_type_flag+ 0)=3)
     AND ((se.recur_parent_id+ 0)=0)
     AND ((se.sch_event_id+ 0) > 0)
     AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (sa
    WHERE sa.sch_event_id=se.sch_event_id
     AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   ORDER BY se2.sch_event_id, se.sch_event_id
   HEAD se2.sch_event_id
    v_row_qualifies_ind = 1, t_prot_rec->qual[index].sch_event_id = se2.sch_event_id, t_prot_rec->
    qual[index].row_id = se2.rowid
   HEAD se.sch_event_id
    IF (((sa.beg_dt_tm >= cnvtdatetime(t_prot_rec->purge_dt_tm)) OR ((((v_row_cnt+ t_prot_rec->qual[
    index].child_qual_cnt)+ 1) >= dm_sch_event_rows2_request->max_rows))) )
     v_row_qualifies_ind = 0
    ELSE
     t_prot_rec->qual[index].child_qual_cnt = (t_prot_rec->qual[index].child_qual_cnt+ 1)
     IF (mod(t_prot_rec->qual[index].child_qual_cnt,10)=1)
      stat = alterlist(t_prot_rec->qual[index].child_qual,(t_prot_rec->qual[index].child_qual_cnt+ 9)
       )
     ENDIF
     t_prot_rec->qual[index].child_qual[t_prot_rec->qual[index].child_qual_cnt].protocol_parent_id =
     se.protocol_parent_id, t_prot_rec->qual[index].child_qual[t_prot_rec->qual[index].child_qual_cnt
     ].sch_event_id = se.sch_event_id, t_prot_rec->qual[index].child_qual[t_prot_rec->qual[index].
     child_qual_cnt].row_id = se.rowid
    ENDIF
   FOOT  se2.sch_event_id
    stat = alterlist(t_prot_rec->qual[index].child_qual,t_prot_rec->qual[index].child_qual_cnt)
    IF (v_row_qualifies_ind=1)
     v_row_cnt = (v_row_cnt+ 1)
     IF (mod(v_row_cnt,100)=1)
      stat = alterlist(dm_sch_event_rows2_reply->rows,(v_row_cnt+ 99))
     ENDIF
     dm_sch_event_rows2_reply->rows[v_row_cnt].row_id = t_prot_rec->qual[index].row_id
     FOR (child_ndx = 1 TO t_prot_rec->qual[index].child_qual_cnt)
       v_row_cnt = (v_row_cnt+ 1)
       IF (mod(v_row_cnt,100)=1)
        stat = alterlist(dm_sch_event_rows2_reply->rows,(v_row_cnt+ 99))
       ENDIF
       dm_sch_event_rows2_reply->rows[v_row_cnt].row_id = t_prot_rec->qual[index].child_qual[
       child_ndx].row_id
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((v_row_cnt >= dm_sch_event_rows2_request->max_rows))
  SET over_max_event_limit = 1
 ENDIF
#exit_script
 IF (over_max_event_limit=1)
  SELECT INTO "nl:"
   a.updt_cnt
   FROM sch_pref a
   PLAN (a
    WHERE a.pref_type_meaning="EVTPURGSWTCH"
     AND a.parent_table="SYSTEM"
     AND a.parent_id=0.0
     AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    purge_script_choosen2 = a.pref_value
   WITH nocounter
  ;end select
  IF (purge_script_choosen2=1)
   EXECUTE sch_utl_system_pref "EVTPURGSWTCH", 0
  ENDIF
 ENDIF
 SET stat = alterlist(t_recur_rec->qual,t_recur_rec->qual_cnt)
 SET stat = alterlist(t_prot_rec->qual,t_prot_rec->qual_cnt)
 SET stat = alterlist(dm_sch_event_rows2_reply->rows,v_row_cnt)
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET dm_sch_event_rows2_reply->status_data.status = "S"
 ELSE
  SET dm_sch_event_rows2_reply->err_code = v_err_code2
  SET dm_sch_event_rows2_reply->err_msg = v_errmsg2
 ENDIF
END GO
