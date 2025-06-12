CREATE PROGRAM ce_get_events_to_sum:dba
 DECLARE eventsetcnt = i4 WITH noconstant(0)
 DECLARE resultcnt = i4 WITH noconstant(0)
 DECLARE eventsetcd = f8 WITH noconstant(0.0)
 DECLARE scl = vc WITH noconstant(" ")
 DECLARE scj = vc WITH noconstant(" ")
 DECLARE scq1 = vc WITH noconstant(" ")
 DECLARE scq2 = vc WITH noconstant(" ")
 DECLARE scq = vc WITH noconstant(" ")
 DECLARE dtq = vc WITH noconstant(" ")
 DECLARE dtq2 = vc WITH noconstant(" ")
 DECLARE exq = vc WITH noconstant(" ")
 DECLARE exq1 = vc WITH noconstant("")
 DECLARE exq2 = vc WITH noconstant("")
 DECLARE exq3 = vc WITH noconstant("")
 DECLARE exq4 = vc WITH noconstant("")
 DECLARE exq5 = vc WITH noconstant("")
 DECLARE num = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE numcd = f8 WITH noconstant(0.0)
 DECLARE medcd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,numcd)
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,medcd)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 IF ((request->event_set_list_ind=1))
  SET exq1 = " ex.event_cd not in ( "
  SET exq2 = "   select ex2.event_cd from v500_event_set_explode ex2 where "
  SET exq3 = "   expand(num,1,size(request->event_set_list,5),ex2.event_set_cd,"
  SET exq4 = "   request->event_set_list[num]->prim_event_set_cd ) "
  SET exq5 = " ) and ex.event_set_level = 0 "
 ELSEIF ((request->event_set_list_ind=0))
  SET exq1 =
  " expand( num,1,size(request->event_set_list,5),ex.event_set_cd,request->event_set_list[num]->prim_event_set_cd ) "
 ENDIF
 IF (size(request->source_cd_list,5) > 0)
  IF ((request->source_cd_list_ind=1))
   SET scq = "and not "
  ELSE
   SET scq = "and "
  ENDIF
  SET scq = concat(scq,
   " expand(idx,1,size(request->source_cd_list,5),ce.source_cd,request->source_cd_list[idx]->source_cd) "
   )
 ENDIF
 IF (value(request->date_range_ind)=1)
  SET dtq = "and ce.event_end_dt_tm >= cnvtdatetime(request->start_dt_tm) "
  SET dtq2 = "and ce.event_end_dt_tm <= cnvtdatetime(request->end_dt_tm) "
 ENDIF
 CALL parser('select into "nl:" ')
 CALL parser("from ")
 CALL parser("clinical_event ce, ")
 CALL parser("v500_event_set_explode ex ")
 CALL parser(scl)
 CALL parser("plan ex where ")
 CALL parser(exq1)
 CALL parser(exq2)
 CALL parser(exq3)
 CALL parser(exq4)
 CALL parser(exq5)
 CALL parser("join ce ")
 CALL parser("where ")
 CALL parser("    ce.person_id = request->person_id ")
 CALL parser(scq)
 CALL parser("and ce.event_cd = ex.event_cd ")
 CALL parser('and ce.valid_until_dt_tm = cnvtdatetimeutc("31-dec-2100") ')
 CALL parser(dtq)
 CALL parser(dtq2)
 CALL parser("and ce.view_level+0 > 0 ")
 CALL parser("and ce.publish_flag+0 != 0 ")
 CALL parser("and ce.event_class_cd+0 in(numCd, medCd ) ")
 CALL parser("order ex.event_set_cd ")
 CALL parser("detail ")
 CALL parser("if( eventSetCd != ex.event_set_cd ) ")
 CALL parser("    eventSetCd = ex.event_set_cd ")
 CALL parser("    eventSetCnt = eventSetCnt + 1 ")
 CALL parser("    resultCnt = 0 ")
 CALL parser("endif ")
 CALL parser("resultCnt = resultCnt + 1 ")
 CALL parser("    stat = alterlist(reply->reply_list, eventSetCnt) ")
 CALL parser("    reply->reply_list[eventSetCnt]->event_set_cd = ex.event_set_cd ")
 CALL parser("    stat = alterlist(reply->reply_list[eventSetCnt]->event_list, resultCnt) ")
 CALL parser(
  "    reply->reply_list[eventSetCnt]->event_list[resultCnt]->result_val      = ce.result_val ")
 CALL parser(
  "    reply->reply_list[eventSetCnt]->event_list[resultCnt]->result_units_cd = ce.result_units_cd ")
 CALL parser(
  "    reply->reply_list[eventSetCnt]->event_list[resultCnt]->event_id        = ce.event_id ")
 CALL parser("with nocounter, orahintcbo('INDEX(ce XIE9CLINICAL_EVENT)')  go")
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
