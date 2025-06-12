CREATE PROGRAM bbt_get_recent_product_events:dba
 RECORD reply(
   1 eventlist[*]
     2 product_event_id = f8
     2 event_type_cd = f8
     2 event_type_disp = c40
     2 event_type_mean = c12
     2 event_dt_tm = dq8
     2 product_id = f8
     2 product_nbr = c26
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_disp = c40
     2 product_mean = c12
     2 cur_abo_cd = f8
     2 cur_abo_disp = c40
     2 cur_abo_mean = c12
     2 cur_rh_cd = f8
     2 cur_rh_disp = c40
     2 cur_rh_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET event_cnt = size(request->eventlist,5)
 SET cdf_meaning = fillstring(12," ")
 SET stat = 1
 FOR (idx = 1 TO event_cnt)
   SET code_value = 0.0
   SET cdf_meaning = request->eventlist[idx].event_type_mean
   SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,code_value)
   IF ((request->debug_ind=1))
    CALL echo(stat)
    CALL echo("1610")
    CALL echo(cdf_meaning)
    CALL echo(code_value)
    CALL echo(" ")
   ENDIF
   IF (stat=1)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "select"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_latest_product_event"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "uar select for event type codes failed"
    GO TO exit_script
   ELSE
    SET request->eventlist[idx].event_type_cd = code_value
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->eventlist,5)
 SET select_ok_ind = 0
 SELECT INTO "nl:"
  pe.event_type_cd, pe.event_dt_tm, p.product_nbr
  FROM (dummyt d  WITH seq = value(event_cnt)),
   product_event pe,
   product p,
   blood_product bp
  PLAN (d)
   JOIN (pe
   WHERE (pe.person_id=request->person_id)
    AND pe.active_ind=1
    AND (pe.event_type_cd=request->eventlist[d.seq].event_type_cd)
    AND ((pe.event_dt_tm >= cnvtdatetime(request->event_dt_tm)) OR (((pe.event_dt_tm=cnvtdatetime(" "
    )) OR (pe.event_dt_tm=null)) )) )
   JOIN (p
   WHERE p.product_id=pe.product_id)
   JOIN (bp
   WHERE bp.product_id=p.product_id)
  HEAD REPORT
   select_ok_ind = 0, qual_cnt = 0
  DETAIL
   qual_cnt += 1
   IF (mod(qual_cnt,5)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->eventlist,(qual_cnt+ 4))
   ENDIF
   reply->eventlist[qual_cnt].event_type_cd = pe.event_type_cd, reply->eventlist[qual_cnt].
   product_event_id = pe.product_event_id, reply->eventlist[qual_cnt].product_id = p.product_id,
   reply->eventlist[qual_cnt].product_nbr = p.product_nbr, reply->eventlist[qual_cnt].product_sub_nbr
    = p.product_sub_nbr, reply->eventlist[qual_cnt].event_dt_tm = cnvtdatetime(pe.event_dt_tm),
   reply->eventlist[qual_cnt].product_cd = p.product_cd, reply->eventlist[qual_cnt].cur_abo_cd = bp
   .cur_abo_cd, reply->eventlist[qual_cnt].cur_rh_cd = bp.cur_rh_cd
  FOOT REPORT
   stat = alterlist(reply->eventlist,qual_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_latest_product_event"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "product_event select failed"
 ENDIF
#exit_script
 IF ((request->debug_ind=1))
  SET item_cnt = cnvtint(size(reply->eventlist,5))
  CALL echo(build(reply->status_data.status," / "))
  FOR (item = 1 TO item_cnt)
    CALL echo(build(item,".",reply->eventlist[item].product_nbr," / ",reply->eventlist[item].
      product_sub_nbr,
      " / ",reply->eventlist[item].product_id," / ",reply->eventlist[item].product_event_id," / ",
      reply->eventlist[item].event_type_cd," / ",reply->eventlist[item].event_dt_tm," / ",reply->
      eventlist[item].product_cd,
      " / ",reply->eventlist[item].cur_abo_cd," / ",reply->eventlist[item].cur_rh_cd))
  ENDFOR
 ENDIF
END GO
