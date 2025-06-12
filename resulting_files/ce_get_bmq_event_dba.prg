CREATE PROGRAM ce_get_bmq_event:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE idx2 = i4
 DECLARE loopcnt = i4
 DECLARE listsize = i4
 DECLARE encntrlistsize = i4
 DECLARE eventsetlistsize = i4
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE encntr_where_clause = vc WITH public, noconstant(" ")
 DECLARE eventset_where_clause = vc WITH public, noconstant(" ")
 SET encntr_where_clause = "0=0"
 SET eventset_where_clause = "0=0"
 SET listsize = value(size(request->person_list,5))
 SET encntrlistsize = value(size(request->encntr_type_class_list,5))
 SET eventsetlistsize = value(size(request->event_set_list,5))
 IF (encntrlistsize)
  SET encntr_where_clause = concat("  expand(idx, 1, encntrListSize, e.encntr_type_class_cd+0 , ",
   " request->encntr_type_class_list[idx].encntr_type_class_cd )")
 ENDIF
 IF (eventsetlistsize)
  SET eventset_where_clause = concat("  not exists "," ( select 'x' from v500_event_set_explode ex2 ",
   "  where expand(idx2, 1 ,eventSetListSize , ex2.event_set_cd , ",
   "  request->event_set_list[idx2].event_set_cd) ","  and ex2.event_cd = ce.event_cd ) ")
 ENDIF
 CALL parser(" select distinct")
 CALL parser("  into 'nl:'")
 CALL parser("    ce.event_id")
 CALL parser("  from")
 IF (encntrlistsize)
  CALL parser("  encounter e,")
 ENDIF
 CALL parser("    clinical_event ce,")
 IF (eventsetlistsize)
  CALL parser("v500_event_set_explode ex,")
 ENDIF
 CALL parser("    (dummyt d with seq = listSize)")
 CALL parser(" plan d")
 CALL parser(" join ce")
 CALL parser("  where")
 CALL parser("    ce.person_id = request->person_list[d.seq]->person_id")
 CALL parser("    and ce.updt_dt_tm > cnvtdatetimeutc(request->person_list[d.seq]->updt_dt_tm)")
 CALL parser(
  "    and ce.clinsig_updt_dt_tm+0 > cnvtdatetimeutc(request->person_list[d.seq]->updt_dt_tm)")
 CALL parser("    and ce.valid_until_dt_tm+0 = cnvtdatetimeutc('31-DEC-2100')")
 CALL parser("    and ce.view_level+0 > 0")
 CALL parser("    and ce.publish_flag+0 != 0")
 CALL parser("    and")
 CALL parser(eventset_where_clause)
 IF (encntrlistsize)
  CALL parser(" join e")
  CALL parser("  where")
  CALL parser("    ce.encntr_id+0 = e.encntr_id")
  CALL parser("    and e.active_ind = 1")
  CALL parser("    and")
  CALL parser(encntr_where_clause)
 ENDIF
 IF (eventsetlistsize)
  CALL parser(" join ex")
  CALL parser("  where")
  CALL parser("    ce.event_cd+0 = ex.event_cd")
 ENDIF
 CALL parser("   detail")
 CALL parser("    cnt = cnt + 1")
 CALL parser("    if ( mod(cnt, 10) = 1 )")
 CALL parser("       stat = alterlist( reply->reply_list, cnt + 9 )")
 CALL parser("    endif")
 CALL parser("    reply->reply_list[cnt].event_cd = ce.event_cd")
 CALL parser("    reply->reply_list[cnt].event_id = ce.event_id")
 CALL parser("    reply->reply_list[cnt].normalcy_cd = ce.normalcy_cd")
 CALL parser("    reply->reply_list[cnt].result_status_cd = ce.result_status_cd")
 CALL parser("    reply->reply_list[cnt].person_id = ce.person_id")
 IF ((request->query_mode=1))
  CALL parser(" with nocounter go")
 ELSE
  CALL parser(" with maxqual(ce,1) go")
 ENDIF
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
