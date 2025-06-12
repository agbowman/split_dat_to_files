CREATE PROGRAM bhs_rpt_rrd_tat
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 session = i4
     2 station = vc
     2 sessionlog = vc
     2 t1 = dq8
     2 t2 = dq8
     2 tat = i2
 )
 SELECT INTO "nl:"
  s_message_disp = uar_get_code_display(s.message_cd), s.message_text, s.qualifier,
  s.rowid, s.session_num, s.sess_dt_tm,
  s.sess_level, s.updt_applctx, s.updt_cnt,
  s.updt_dt_tm, s.updt_id, s.updt_task
  FROM session_log s
  WHERE s.sess_dt_tm BETWEEN cnvtdatetime(cnvtdate(011409),0) AND cnvtdatetime(cnvtdate(01212009),
   2359)
  ORDER BY s.session_num, s.qualifier
  HEAD s.session_num
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].station
    = s.message_text,
   temp->qual[temp->cnt].session = s.session_num, temp->qual[temp->cnt].t1 = s.sess_dt_tm
  DETAIL
   temp->qual[temp->cnt].t2 = s.sess_dt_tm, temp->qual[temp->cnt].sessionlog = build(
    uar_get_code_display(s.message_cd),":",s.message_text)
  FOOT  s.session_num
   temp->qual[temp->cnt].tat = datetimediff(temp->qual[temp->cnt].t2,temp->qual[temp->cnt].t1,5)
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 DECLARE station = vc
 DECLARE tat = vc
 SELECT INTO  $1
  station = temp->qual[d.seq].station, tat = cnvtstring(temp->qual[d.seq].tat)
  FROM (dummyt d  WITH seq = value(temp->cnt))
  WITH nocounter, format
 ;end select
END GO
