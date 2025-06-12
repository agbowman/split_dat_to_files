CREATE PROGRAM ce_get_events_to_endorse_new:dba
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE eventlistcnt = i4 WITH noconstant(0)
 DECLARE eventsetincludecnt = i4 WITH noconstant(0)
 DECLARE eventsetexcludecnt = i4 WITH noconstant(0)
 DECLARE encntrtypeclasscnt = i4 WITH noconstant(0)
 DECLARE encntrtypecnt = i4 WITH noconstant(0)
 DECLARE prsnllistcnt = i4 WITH noconstant(0)
 DECLARE prsnlgrouplistcnt = i4 WITH noconstant(0)
 DECLARE endorsestatuslistcnt = i4 WITH noconstant(0)
 DECLARE prsnl_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE eventlistsize = i4 WITH constant(size(request->event_list,5))
 DECLARE eventsetincludesize = i4 WITH constant(size(request->event_set_include_list,5))
 DECLARE eventsetexcludesize = i4 WITH constant(size(request->event_set_exclude_list,5))
 DECLARE encntrtypeclasssize = i4 WITH constant(size(request->encntr_class_type_list,5))
 DECLARE encntrtypesize = i4 WITH constant(size(request->encntr_type_list,5))
 DECLARE prsnllistsize = i4 WITH constant(size(request->prsnl_list,5))
 DECLARE prsnlgrouplistsize = i4 WITH constant(size(request->prsnl_group_list,5))
 DECLARE endorsestatuslistsize = i4 WITH constant(size(request->endorse_status_list,5))
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE action_type_order = f8 WITH noconstant(0.0)
 DECLARE listitemsidx = i4 WITH noconstant(0)
 DECLARE firstitem = i4 WITH noconstant(0)
 DECLARE cboindex = vc WITH noconstant(" ")
 DECLARE prsnlgroupidcounter = i4 WITH noconstant(0), protect
 DECLARE replylistidx = i4 WITH noconstant(0), protect
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 RECORD tempprsnllist(
   1 prsnlgroupids[*]
     2 groupid = f8
 )
 SET stat = uar_get_meaning_by_codeset(21,"ORDER",1,action_type_order)
 IF (eventlistsize)
  SET ntotal2 = eventlistsize
  SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
  SET stat = alterlist(request->event_list,ntotal)
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
  ENDFOR
  SET idx = 0
  SET nstart = 1
 ENDIF
 CALL parser(" select distinct into 'nl:' cea.event_id ")
 CALL parser(" from ")
 CALL parser("    ce_event_action cea, ")
 CALL parser("    person p, ")
 CALL parser("    prsnl psl, ")
 CALL parser("    prsnl psl2, ")
 CALL parser("    clinical_event ce ")
 IF (eventlistsize=0)
  CALL parser(" , encounter e ")
 ENDIF
 IF (eventsetincludesize)
  CALL parser(" , v500_event_set_explode ex1 ")
 ENDIF
 IF (prsnllistsize)
  CALL parser(" , (dummyt d with seq = value(size(request->prsnl_list,5))) ")
 ELSEIF (prsnlgrouplistsize)
  CALL parser(" , (dummyt d with seq = value(size(request->prsnl_group_list,5))) ")
 ELSE
  SET error_msg = build("No prsnl_id or prsnl_group_id supplied. ")
  GO TO exit_script
 ENDIF
 IF (eventlistsize)
  CALL parser(" , (dummyt d2 with seq = value(1+((ntotal-1)/nsize))) ")
 ENDIF
 CALL parser(" plan d ")
 IF (eventlistsize)
  CALL parser(" join d2 where initarray(nstart, evaluate(d2.seq,1,1,nstart+nsize)) ")
 ENDIF
 CALL parser(" join cea where ")
 CALL parser("      cea.action_type_cd = ACTION_TYPE_ORDER ")
 IF ((request->date_ind=1))
  IF (eventlistsize)
   CALL parser("   and cea.updt_dt_tm+0 > cnvtdatetimeutc(request->min_date) ")
   CALL parser("   and cea.updt_dt_tm+0 < cnvtdatetimeutc(request->max_date) ")
   SET cboindex = "INDEX(cea XAK1CE_EVENT_ACTION )"
  ELSE
   CALL parser("   and cea.updt_dt_tm > cnvtdatetimeutc(request->min_date) ")
   CALL parser("   and cea.updt_dt_tm < cnvtdatetimeutc(request->max_date) ")
  ENDIF
 ENDIF
 IF ((request->person_id > 0))
  CALL parser("   and cea.person_id = request->person_id ")
 ENDIF
 IF (eventlistsize
  AND prsnllistsize)
  CALL parser("   and cea.action_prsnl_id+0=request->prsnl_list[d.seq].action_prsnl_id ")
  CALL parser("   and (request->prsnl_list[d.seq].pool_routed_ind=0 or ")
  CALL parser(
   "       (request->prsnl_list[d.seq].pool_routed_ind=1 and cea.action_prsnl_group_id+0=0.0) )")
  SET cboindex = "INDEX(cea XAK1CE_EVENT_ACTION )"
 ELSEIF (prsnllistsize
  AND (request->person_id > 0))
  CALL parser("   and cea.action_prsnl_id+0=request->prsnl_list[d.seq].action_prsnl_id ")
  CALL parser("   and (request->prsnl_list[d.seq].pool_routed_ind=0 or ")
  CALL parser(
   "       (request->prsnl_list[d.seq].pool_routed_ind=1 and cea.action_prsnl_group_id+0=0.0) )")
  SET cboindex = "INDEX(cea XIE8CE_EVENT_ACTION )"
 ELSEIF (prsnllistsize
  AND (request->person_id=0))
  CALL parser("   and cea.action_prsnl_id=request->prsnl_list[d.seq].action_prsnl_id ")
  CALL parser("   and (request->prsnl_list[d.seq].pool_routed_ind=0 or ")
  CALL parser(
   "       (request->prsnl_list[d.seq].pool_routed_ind=1 and cea.action_prsnl_group_id+0=0.0) )")
  SET cboindex = "INDEX(cea XIE3CE_EVENT_ACTION )"
 ELSEIF (eventlistsize
  AND prsnlgrouplistsize)
  CALL parser(
   "   and cea.action_prsnl_group_id+0=request->prsnl_group_list[d.seq].action_prsnl_group_id ")
  CALL parser("   and (request->prsnl_group_list[d.seq].assign_prsnl_id = 0 or ")
  CALL parser("       (request->prsnl_group_list[d.seq].assign_prsnl_id > 0 and ")
  CALL parser("        cea.assign_prsnl_id+0 = request->prsnl_group_list[d.seq].assign_prsnl_id) ) ")
  SET cboindex = "INDEX(cea XAK1CE_EVENT_ACTION )"
 ELSEIF ((request->person_id > 0)
  AND prsnlgrouplistsize)
  CALL parser(
   "   and cea.action_prsnl_group_id+0=request->prsnl_group_list[d.seq].action_prsnl_group_id ")
  CALL parser("   and (request->prsnl_group_list[d.seq].assign_prsnl_id = 0 or ")
  CALL parser("       (request->prsnl_group_list[d.seq].assign_prsnl_id > 0 and ")
  CALL parser("        cea.assign_prsnl_id+0 = request->prsnl_group_list[d.seq].assign_prsnl_id) ) ")
  SET cboindex = "INDEX(cea XIE8CE_EVENT_ACTION )"
 ELSE
  CALL parser(
   "   and cea.action_prsnl_group_id=request->prsnl_group_list[d.seq].action_prsnl_group_id ")
  CALL parser("   and (request->prsnl_group_list[d.seq].assign_prsnl_id = 0 or ")
  CALL parser("       (request->prsnl_group_list[d.seq].assign_prsnl_id > 0 and ")
  CALL parser("        cea.assign_prsnl_id+0 = request->prsnl_group_list[d.seq].assign_prsnl_id) )")
  SET cboindex = "INDEX(cea XIE4CE_EVENT_ACTION )"
 ENDIF
 IF (eventlistsize)
  CALL parser("   and expand( idx, nstart, nstart+(nsize-1), cea.event_id, ")
  CALL parser("               request->event_list[idx].event_id ) ")
 ENDIF
 IF (endorsestatuslistsize)
  CALL parser(
   "   and expand( endorseStatusListCnt, 1, endorseStatusListSize, cea.endorse_status_cd, ")
  CALL parser(
   "               request->endorse_status_list[endorseStatusListCnt].endorse_status_cd ) ")
 ENDIF
 IF (eventsetexcludesize)
  CALL parser(" and NOT EXISTS( select 'x' from v500_event_set_explode ex where ")
  CALL parser(" cea.event_cd = ex.event_cd ")
  CALL parser(" and ( ex.event_set_cd +0 in ( ")
  SET listitemsidx = 0
  SET firstitem = 1
  FOR (eventsetexcludecnt = 1 TO eventsetexcludesize)
    SET listitemsidx += 1
    IF (listitemsidx=250)
     CALL parser(" ) or ")
     CALL parser(" ex.event_set_cd +0 in ( ")
     SET listitemsidx = 0
     SET firstitem = 1
    ENDIF
    IF (firstitem=0)
     CALL parser(", ")
    ELSE
     SET firstitem = 0
    ENDIF
    CALL parser(build(request->event_set_exclude_list[eventsetexcludecnt].event_set_cd))
  ENDFOR
  CALL parser(" ) ) ) ")
 ENDIF
 CALL parser(" join p where ")
 CALL parser("      p.person_id = cea.person_id and ")
 CALL parser("      p.active_ind = 1 ")
 IF (eventlistsize=0)
  CALL parser(" join e where ")
  IF (encntrtypeclasssize)
   CALL parser(" expand( encntrTypeClassCnt, 1, encntrTypeClassSize, e.encntr_type_class_cd+0 , ")
   CALL parser(
    "         request->encntr_class_type_list[encntrTypeClassCnt].encntr_class_type_cd )   ")
   CALL parser(" and ")
  ENDIF
  IF (encntrtypesize)
   CALL parser(" expand( encntrTypeCnt, 1, encntrTypeSize, e.encntr_type_cd+0 , ")
   CALL parser("         request->encntr_type_list[encntrTypeCnt].encntr_type_cd )   ")
   CALL parser(" and ")
  ENDIF
  CALL parser(" e.encntr_id = cea.encntr_id and")
  CALL parser(" (e.active_ind = 1 or e.encntr_id = 0)")
 ENDIF
 IF (eventsetincludesize)
  CALL parser(" join ex1 where ")
  CALL parser(" ex1.event_cd = cea.event_cd ")
  CALL parser(" and expand( eventSetIncludeCnt, 1, eventSetIncludeSize, ex1.event_set_cd+0 , ")
  CALL parser("         request->event_set_include_list[eventSetIncludeCnt].event_set_cd )   ")
 ENDIF
 CALL parser(" join psl where ")
 CALL parser("      psl.person_id = cea.action_prsnl_id")
 CALL parser(" join psl2 where ")
 CALL parser("      psl2.person_id = cea.assign_prsnl_id")
 CALL parser(" join ce where ")
 CALL parser("      ce.event_id = cea.event_id")
 IF (prsnllistsize)
  CALL parser(" order by cea.action_prsnl_id, cea.event_id ")
 ELSE
  CALL parser(" order by cea.action_prsnl_group_id, cea.event_id ")
 ENDIF
 CALL parser(" head report ")
 CALL parser("prsnlGroupCnt = 0")
 CALL parser("     prsnl_cnt = prsnl_cnt + 1 ")
 CALL parser("     stat = alterlist( reply->reply_list, prsnl_cnt ) ")
 CALL parser("head cea.action_prsnl_group_id")
 CALL parser("if(cea.action_prsnl_group_id > 0)")
 CALL parser("prsnlGroupCnt = prsnlGroupCnt + 1")
 CALL parser("     stat = alterlist( tempPrsnlList->prsnlGroupIds, prsnlGroupCnt ) ")
 CALL parser("endif")
 CALL parser(" detail ")
 CALL parser("  cnt = cnt + 1 ")
 IF (prsnllistsize)
  CALL parser("  if ( cea.action_prsnl_id != reply->reply_list[prsnl_cnt]->prsnl_id ) ")
 ELSE
  CALL parser(
   "  if ( cea.action_prsnl_group_id != reply->reply_list[prsnl_cnt]->action_prsnl_group_id ) ")
 ENDIF
 CALL parser("     if ( cnt > 1 ) ")
 CALL parser("        stat = alterlist(reply->reply_list[prsnl_cnt]->event_list, cnt-1) ")
 CALL parser("        cnt = 1 ")
 CALL parser("        prsnl_cnt = prsnl_cnt + 1 ")
 CALL parser("        stat = alterlist(reply->reply_list, prsnl_cnt) ")
 CALL parser("     endif ")
 IF (prsnllistsize)
  CALL parser("     reply->reply_list[prsnl_cnt].prsnl_id = cea.action_prsnl_id ")
 ELSE
  CALL parser("     reply->reply_list[prsnl_cnt].action_prsnl_group_id = cea.action_prsnl_group_id ")
 ENDIF
 CALL parser("  endif ")
 CALL parser("  if ( mod(cnt,10) = 1 ) ")
 CALL parser("     stat = alterlist( reply->reply_list[prsnl_cnt]->event_list, cnt + 9 ) ")
 CALL parser("  endif ")
 CALL parser("  reply->reply_list[prsnl_cnt]->event_list[cnt].event_id              = cea.event_id ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].event_class_cd        = cea.event_class_cd ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].event_class_cd_disp   = uar_get_code_display(cea.event_class_cd) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].event_class_cd_mean   = uar_get_code_meaning(cea.event_class_cd) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].event_tag             = trim(cea.event_tag) ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].result_status_cd      = cea.result_status_cd ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].result_status_cd_disp = uar_get_code_display(cea.result_status_cd) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].result_status_cd_mean = uar_get_code_meaning(cea.result_status_cd) "
  )
 CALL parser("  reply->reply_list[prsnl_cnt]->event_list[cnt].person_id             = cea.person_id "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].name_full_formatted   = trim(p.name_full_formatted) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].clinsig_updt_dt_tm    = cea.clinsig_updt_dt_tm ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].updt_dt_tm            = cea.updt_dt_tm ")
 CALL parser("  reply->reply_list[prsnl_cnt]->event_list[cnt].event_cd              = cea.event_cd ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].normalcy_cd           = cea.normalcy_cd ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->event_title_text     = cea.event_title_text ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].prsnl_id              = cea.action_prsnl_id ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].prsnl_name            = trim(psl.name_full_formatted) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].action_prsnl_group_id = cea.action_prsnl_group_id "
  )
 CALL parser(
  "  stat_f8 = assign(validate(reply->reply_list[prsnl_cnt]->event_list[cnt].order_id, 0), ce.order_id) "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].assign_prsnl_id       = cea.assign_prsnl_id ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt].assign_prsnl_name     = trim(psl2.name_full_formatted) "
  )
 CALL parser("  reply->reply_list[prsnl_cnt]->event_list[cnt].encntr_id             = cea.encntr_id "
  )
 CALL parser("lPos = 0 ")
 CALL parser(" if(cea.action_prsnl_group_id > 0) ")
 CALL parser(" if(locateval(lPos, lPos + 1, size(tempPrsnlList->prsnlGroupIds, 5), ")
 CALL parser(" cea.action_prsnl_group_id, tempPrsnlList->prsnlGroupIds[lPos].groupId ) = 0)")
 CALL parser(" tempPrsnlList->prsnlGroupIds[prsnlGroupCnt].groupId = cea.action_prsnl_group_id ")
 CALL parser(" endif ")
 CALL parser("  endif ")
 IF (eventlistsize=0)
  CALL parser(
   "  reply->reply_list[prsnl_cnt]->event_list[cnt]->encntr_class_type_cd = e.encntr_type_class_cd ")
  CALL parser("  reply->reply_list[prsnl_cnt]->event_list[cnt]->encntr_type_cd = e.encntr_type_cd ")
 ENDIF
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->parent_event_id       = cea.parent_event_id ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->parent_event_class_cd = cea.parent_event_class_cd "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->endorse_status_cd = cea.endorse_status_cd ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->last_comment_txt = cea.last_comment_txt ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->multiple_comment_ind = cea.multiple_comment_ind "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->multiple_comment_prsnl_ind = cea.multiple_comment_prsnl_ind "
  )
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->last_saved_prsnl_id = cea.last_saved_prsnl_id ")
 CALL parser(
  "  reply->reply_list[prsnl_cnt]->event_list[cnt]->originating_provider_id = cea.originating_provider_id "
  )
 CALL parser(build(" with nocounter, orahintcbo('",cboindex,
   "','LEADING(cea psl psl2)','USE_NL(cea psl psl2 p e ex1)') go "))
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 IF (cnt > 0)
  SET stat = alterlist(reply->reply_list[prsnl_cnt].event_list,cnt)
 ENDIF
 IF (prsnlgrouplistsize)
  SET prsnlgroupididx = 0
  SELECT INTO "nl:"
   FROM prsnl_group pg
   WHERE expand(prsnlgroupididx,1,size(tempprsnllist->prsnlgroupids,5),pg.prsnl_group_id,
    tempprsnllist->prsnlgroupids[prsnlgroupididx].groupid)
   DETAIL
    lpos = 0
    FOR (replylistidx = 1 TO size(reply->reply_list,5))
     WHILE (assign(lpos,locateval(lpos,(lpos+ 1),size(reply->reply_list[replylistidx].event_list,5),
       pg.prsnl_group_id,reply->reply_list[replylistidx].event_list[lpos].action_prsnl_group_id)))
       reply->reply_list[replylistidx].event_list[lpos].action_prsnl_group_name = pg.prsnl_group_name
     ENDWHILE
     ,lpos = 0
    ENDFOR
   WITH nocounter, expand = 1
  ;end select
 ENDIF
#exit_script
END GO
