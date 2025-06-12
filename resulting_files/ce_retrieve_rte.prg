CREATE PROGRAM ce_retrieve_rte
 FREE RECORD rte_prsnl_reltns_reply
 RECORD rte_prsnl_reltns_reply(
   1 reply_list[*]
     2 prsnl_id = f8
     2 event_list[*]
       3 event_id = f8
       3 event_class_cd = f8
       3 event_class_cd_disp = vc
       3 event_class_cd_mean = vc
       3 event_tag = vc
       3 result_status_cd = f8
       3 result_status_cd_disp = vc
       3 result_status_cd_mean = vc
       3 person_id = f8
       3 name_full_formatted = vc
       3 clinsig_updt_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 event_cd = f8
       3 normalcy_cd = f8
       3 event_title_text = vc
       3 encntr_class_type_cd = f8
       3 encntr_type_cd = f8
       3 parent_event_id = f8
       3 parent_event_class_cd = f8
       3 prsnl_id = f8
       3 prsnl_name = vc
       3 action_prsnl_group_id = f8
       3 action_prsnl_group_name = vc
       3 assign_prsnl_id = f8
       3 assign_prsnl_name = vc
       3 encntr_id = f8
       3 reltn_type_cd = f8
       3 endorse_status_cd = f8
       3 last_comment_txt = vc
       3 multiple_comment_ind = i2
       3 multiple_comment_prsnl_ind = i2
       3 last_saved_prsnl_id = f8
       3 originating_provider_id = f8
       3 rte_prsnl_reltns_list[*]
         4 action_prsnl_id = f8
         4 reltn_type_cd = f8
       3 order_id = f8
     2 action_prsnl_group_id = f8
 )
 DECLARE eventslistsize = i4 WITH constant(size(request->event_list,5))
 DECLARE eventssetincludesize = i4 WITH constant(size(request->event_set_include_list,5))
 DECLARE eventssetexcludesize = i4 WITH constant(size(request->event_set_exclude_list,5))
 DECLARE encntrtypesclasssize = i4 WITH constant(size(request->encntr_class_type_list,5))
 DECLARE encntrtypessize = i4 WITH constant(size(request->encntr_type_list,5))
 DECLARE prsnlslistsize = i4 WITH constant(size(request->prsnl_list,5))
 DECLARE endorsestatuseslistsize = i4 WITH constant(size(request->endorse_status_list,5))
 DECLARE eventlistcount = i4 WITH noconstant(0)
 DECLARE eventsetincludecount = i4 WITH noconstant(0)
 DECLARE eventsetexcludecount = i4 WITH noconstant(0)
 DECLARE encntrtypeclasscount = i4 WITH noconstant(0)
 DECLARE encntrtypecount = i4 WITH noconstant(0)
 DECLARE endorsestatuslistcount = i4 WITH noconstant(0)
 DECLARE prsnl_count = i4 WITH noconstant(0)
 DECLARE events_count = i4 WITH noconstant(0)
 DECLARE rltn_count = i4 WITH noconstant(0)
 DECLARE batchsize = i4 WITH noconstant(10)
 DECLARE paddedlistsize = i4 WITH noconstant(0)
 DECLARE listsize = i4 WITH noconstant(0)
 DECLARE startindex = i4 WITH noconstant(0)
 DECLARE idx1 = i4 WITH noconstant(0)
 DECLARE tmptableidx1 = i4 WITH noconstant(0)
 DECLARE tmpstart = i4 WITH noconstant(0)
 DECLARE maxloopcnt = i4 WITH noconstant(0)
 DECLARE loopcnt = i4 WITH noconstant(0)
 DECLARE actiontype_order = f8 WITH noconstant(0.0)
 DECLARE listitemsidx1 = i4 WITH noconstant(0)
 DECLARE firstelement = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE l = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE pos1 = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE locatestartprsnl = i4 WITH noconstant(1)
 DECLARE locatestartevent = i4 WITH noconstant(1)
 DECLARE locateendprsnl = i4 WITH noconstant(1)
 DECLARE locateendevent = i4 WITH noconstant(1)
 DECLARE event_cnt_merge = i4 WITH noconstant(0)
 DECLARE prsnl_count_merge = i4 WITH noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE orderidexists = i1 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(21,"ORDER",1,actiontype_order)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0.0
 EXECUTE ce_get_events_to_endorse_new
 IF ((reply->error_code > 0.0))
  GO TO exit_script
 ENDIF
 IF (prsnlslistsize)
  SET paddedlistsize = (ceil((cnvtreal(prsnlslistsize)/ batchsize)) * batchsize)
  SET stat = alterlist(request->prsnl_list,paddedlistsize)
  FOR (tmptableidx1 = (prsnlslistsize+ 1) TO paddedlistsize)
    SET request->prsnl_list[tmptableidx1].action_prsnl_id = request->prsnl_list[prsnlslistsize].
    action_prsnl_id
  ENDFOR
  SET tmptableidx1 = 0
  SET tmpstart = 1
  SET maxloopcnt = (paddedlistsize/ batchsize)
 ENDIF
 FOR (loopcnt = 1 TO maxloopcnt)
  INSERT  FROM shared_list_gttd slg
   (slg.source_entity_value)(SELECT DISTINCT INTO "nl:"
    crpr.action_prsnl_id
    FROM ce_rte_prsnl_reltn crpr
    WHERE expand(tmptableidx1,tmpstart,(tmpstart+ (batchsize - 1)),crpr.action_prsnl_id,request->
     prsnl_list[tmptableidx1].action_prsnl_id))
   WITH nocounter
  ;end insert
  SET tmpstart += batchsize
 ENDFOR
 IF (eventslistsize)
  SET listsize = eventslistsize
  SET paddedlistsize = (ceil((cnvtreal(listsize)/ batchsize)) * batchsize)
  SET stat = alterlist(request->event_list,paddedlistsize)
  FOR (idx1 = (listsize+ 1) TO paddedlistsize)
    SET request->event_list[idx1].event_id = request->event_list[listsize].event_id
  ENDFOR
  SET idx1 = 0
  SET startindex = 1
 ENDIF
 IF (size(reply->reply_list,5) > 0)
  IF (size(reply->reply_list[0].event_list,5) > 0)
   SET orderidexists = validate(reply->reply_list[0].event_list[0].order_id)
  ENDIF
 ENDIF
 CALL parser(" select into 'nl:'")
 CALL parser(" from ")
 CALL parser("    ce_event_action cea, ")
 CALL parser("    shared_list_gttd t, ")
 CALL parser("    person p, ")
 CALL parser("    prsnl psl, ")
 CALL parser("    prsnl_group pg, ")
 CALL parser("    prsnl psl2 ,")
 CALL parser("    ce_rte_prsnl_reltn crpr, ")
 CALL parser("    clinical_event ce ")
 IF (eventslistsize=0)
  CALL parser(" , encounter e ")
 ENDIF
 IF (eventssetincludesize)
  CALL parser(" , v500_event_set_explode ex1 ")
 ENDIF
 IF (eventslistsize)
  CALL parser(" , (dummyt d2 with seq = value(1+((paddedListSize-1)/batchSize))) ")
 ENDIF
 CALL parser(" plan t  ")
 CALL parser("join crpr where crpr.action_prsnl_id=t.SOURCE_ENTITY_VALUE")
 IF (eventslistsize)
  CALL parser(" join d2 where initarray(startIndex, evaluate(d2.seq,1,1,startIndex+batchSize)) ")
 ENDIF
 CALL parser(" join cea where ")
 CALL parser("      cea.ce_event_action_id = crpr.ce_event_action_id ")
 CALL parser("   and   cea.action_type_cd = ACTIONTYPE_ORDER ")
 IF ((request->date_ind=1))
  CALL parser("   and cea.updt_dt_tm > cnvtdatetimeutc(request->min_date) ")
  CALL parser("   and cea.updt_dt_tm < cnvtdatetimeutc(request->max_date) ")
 ENDIF
 IF ((request->person_id > 0))
  CALL parser("   and cea.person_id = request->person_id ")
 ENDIF
 IF (eventslistsize)
  CALL parser("   and expand( idx1, startIndex, startIndex+(batchSize-1), cea.event_id, ")
  CALL parser("               request->event_list[idx1].event_id ) ")
 ENDIF
 IF (endorsestatuseslistsize)
  CALL parser(
   "   and expand( endorseStatusListCount, 1, endorseStatusesListSize, cea.endorse_status_cd, ")
  CALL parser(
   "               request->endorse_status_list[endorseStatusListCount].endorse_status_cd ) ")
 ENDIF
 IF (eventssetexcludesize)
  CALL parser(" and NOT EXISTS( select 'x' from v500_event_set_explode ex where ")
  CALL parser(" cea.event_cd = ex.event_cd ")
  CALL parser(" and ( ex.event_set_cd  in ( ")
  SET listitemsidx1 = 0
  SET firstelement = 1
  FOR (eventsetexcludecount = 1 TO eventssetexcludesize)
    SET listitemsidx1 += 1
    IF (listitemsidx1=250)
     CALL parser(" ) or ")
     CALL parser(" ex.event_set_cd  in ( ")
     SET listitemsidx1 = 0
     SET firstelement = 1
    ENDIF
    IF (firstelement=0)
     CALL parser(", ")
    ELSE
     SET firstelement = 0
    ENDIF
    CALL parser(build(request->event_set_exclude_list[eventsetexcludecount].event_set_cd))
  ENDFOR
  CALL parser(" ) ) ) ")
 ENDIF
 CALL parser(" join p where ")
 CALL parser("      p.person_id = cea.person_id and ")
 CALL parser("      p.active_ind = 1 ")
 IF (eventslistsize=0)
  CALL parser(" join e where ")
  IF (encntrtypesclasssize)
   CALL parser(" expand( encntrTypeClassCount, 1, encntrTypesClassSize, e.encntr_type_class_cd , ")
   CALL parser(
    "         request->encntr_class_type_list[encntrTypeClassCount].encntr_class_type_cd )   ")
   CALL parser(" and ")
  ENDIF
  IF (encntrtypessize)
   CALL parser(" expand( encntrTypeCount, 1, encntrTypesSize, e.encntr_type_cd , ")
   CALL parser("         request->encntr_type_list[encntrTypeCount].encntr_type_cd )   ")
   CALL parser(" and ")
  ENDIF
  CALL parser(" e.encntr_id = cea.encntr_id and")
  CALL parser(" (e.active_ind = 1 or e.encntr_id = 0)")
 ENDIF
 IF (eventssetincludesize)
  CALL parser(" join ex1 where ")
  CALL parser(" ex1.event_cd = cea.event_cd ")
  CALL parser(" and expand( eventSetIncludeCount, 1, eventsSetIncludeSize, ex1.event_set_cd , ")
  CALL parser("         request->event_set_include_list[eventSetIncludeCount].event_set_cd )   ")
 ENDIF
 CALL parser(" join psl where ")
 CALL parser("      psl.person_id = cea.action_prsnl_id")
 CALL parser(" join pg where ")
 CALL parser("      pg.prsnl_group_id = cea.action_prsnl_group_id")
 CALL parser(" join psl2 where ")
 CALL parser("      psl2.person_id = cea.assign_prsnl_id")
 CALL parser(" join ce where ")
 CALL parser("      ce.event_id = cea.event_id")
 CALL parser(" order by crpr.action_prsnl_id, cea.event_id, cea.action_prsnl_id, crpr.reltn_type_cd "
  )
 CALL parser(" head report ")
 CALL parser(" prsnl_count = 0")
 CALL parser(" head crpr.action_prsnl_id ")
 CALL parser("  events_count=0 ")
 CALL parser(" prsnl_count = prsnl_count + 1 ")
 CALL parser("  if (prsnl_count > size(rte_prsnl_reltns_reply->reply_list,5)) ")
 CALL parser(" stat = alterlist(rte_prsnl_reltns_reply->reply_list, prsnl_count + 10) ")
 CALL parser("   endif ")
 CALL parser(" rte_prsnl_reltns_reply->reply_list[prsnl_count].prsnl_id = crpr.action_prsnl_id ")
 CALL parser(" stat = alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list, 1) ")
 CALL parser(" head cea.event_id ")
 CALL parser("  rltn_count=0 ")
 CALL parser(" detail ")
 CALL parser(
  " if(( rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_id  != cea.event_id) "
  )
 CALL parser(
  " or (( rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_id  = cea.event_id) "
  )
 CALL parser(
  " and ( rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].prsnl_id != cea.action_prsnl_id)))"
  )
 CALL parser(
  " if(( rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_id  = cea.event_id) "
  )
 CALL parser(
  " and ( rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].prsnl_id  != cea.action_prsnl_id))"
  )
 CALL parser(
  " stat=alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list,rltn_count)"
  )
 CALL parser("  rltn_count=0 ")
 CALL parser("  endif ")
 CALL parser(" events_count = events_count + 1 ")
 CALL parser(
  " if (events_count > size(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list,5)) ")
 CALL parser(
  " stat = alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list, events_count + 10) "
  )
 CALL parser(" endif ")
 CALL parser(" rltn_count = rltn_count + 1 ")
 CALL parser(
  " if (rltn_count > size(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list,5))"
  )
 CALL parser(
  "stat=alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list,rltn_count + 10)"
  )
 CALL parser("   endif ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_id              = cea.event_id "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_class_cd        = cea.event_class_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_class_cd_disp = "
  )
 CALL parser("  uar_get_code_display(cea.event_class_cd)")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_class_cd_mean   =  "
  )
 CALL parser("  uar_get_code_meaning(cea.event_class_cd)")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_tag             = trim(cea.event_tag) "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].result_status_cd      = cea.result_status_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].result_status_cd_disp =  "
  )
 CALL parser("  uar_get_code_display(cea.result_status_cd) ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].result_status_cd_mean =  "
  )
 CALL parser("  uar_get_code_meaning(cea.result_status_cd) ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].person_id   = cea.person_id "
  )
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].name_full_formatted = trim(p.name_full_formatted)"
  )
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].clinsig_updt_dt_tm    = cea.clinsig_updt_dt_tm "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].updt_dt_tm            = cea.updt_dt_tm "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].event_cd              = cea.event_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].normalcy_cd           = cea.normalcy_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->event_title_text     = cea.event_title_text "
  )
 CALL parser("if(orderIdExists) ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].order_id = ce.order_id "
  )
 CALL parser("endif ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].prsnl_id              = cea.action_prsnl_id "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].prsnl_name    = trim(psl.name_full_formatted) "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].action_prsnl_group_id =cea.action_prsnl_group_id "
  )
 CALL parser("  if (cea.action_prsnl_group_id > 0) ")
 CALL parser(
  "     rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].action_prsnl_group_name =pg.prsnl_group_name "
  )
 CALL parser("  endif ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].assign_prsnl_id = cea.assign_prsnl_id "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].assign_prsnl_name = trim(psl2.name_full_formatted) "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].encntr_id = cea.encntr_id "
  )
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list[rltn_count].reltn_type_cd ="
  )
 CALL parser(" crpr.reltn_type_cd ")
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list[rltn_count].action_prsnl_id ="
  )
 CALL parser(" crpr.action_prsnl_id ")
 IF (eventslistsize=0)
  CALL parser(
   "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->encntr_class_type_cd = e.encntr_type_class_cd "
   )
  CALL parser(
   "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->encntr_type_cd = e.encntr_type_cd "
   )
 ENDIF
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->parent_event_id       = cea.parent_event_id "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->parent_event_class_cd = cea.parent_event_class_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->endorse_status_cd = cea.endorse_status_cd "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->last_comment_txt = cea.last_comment_txt "
  )
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->multiple_comment_ind = cea.multiple_comment_ind "
  )
 CALL parser(
  " rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->multiple_comment_prsnl_ind= "
  )
 CALL parser(" cea.multiple_comment_prsnl_ind ")
 CALL parser(
  "  rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->last_saved_prsnl_id = cea.last_saved_prsnl_id "
  )
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count]->originating_provider_id=cea.originating_provider_id"
  )
 CALL parser(" else ")
 CALL parser(
" if((rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list[rltn_count].	reltn_ty\
pe_cd != crpr.reltn_type_cd) or (rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].	rte_prsnl_relt\
ns_list[rltn_count].action_prsnl_id != crpr.action_prsnl_id )) \
")
 CALL parser(" rltn_count = rltn_count +1 ")
 CALL parser(
  "  if (rltn_count > size(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list,5)) "
  )
 CALL parser(
  " stat = alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list, "
  )
 CALL parser(" rltn_count + 10) ")
 CALL parser("   endif ")
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list[rltn_count].reltn_type_cd="
  )
 CALL parser("  crpr.reltn_type_cd ")
 CALL parser(
  "rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list[rltn_count].action_prsnl_id = "
  )
 CALL parser("crpr.action_prsnl_id ")
 CALL parser("   endif ")
 CALL parser("   endif ")
 CALL parser(" foot cea.event_id ")
 CALL parser(
  "stat=alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list[events_count].rte_prsnl_reltns_list,rltn_count) "
  )
 CALL parser(" foot crpr.action_prsnl_id ")
 CALL parser(
  " stat = alterlist(rte_prsnl_reltns_reply->reply_list[prsnl_count]->event_list, events_count) ")
 CALL parser(" foot report ")
 CALL parser(" stat = alterlist(rte_prsnl_reltns_reply->reply_list, prsnl_count) ")
 CALL parser(
  " with nocounter, orahintcbo('INDEX(crpr XAK1CE_RTE_PRSNL_RELTN )','USE_NL(t crpr cea)','LEADING(t crpr cea)') go "
  )
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 IF ((reply->error_code > 0.0))
  GO TO exit_script
 ENDIF
 SET locateendprsnl = size(reply->reply_list,5)
 FOR (i = 1 TO size(rte_prsnl_reltns_reply->reply_list,5))
   SET pos = locatevalsort(num,locatestartprsnl,locateendprsnl,rte_prsnl_reltns_reply->reply_list[i].
    prsnl_id,reply->reply_list[num].prsnl_id)
   SET locatestartevent = 1
   IF (pos > 0)
    SET locatestartprsnl = (pos+ 1)
    SET locateendevent = size(reply->reply_list[pos].event_list,5)
    FOR (j = 1 TO size(rte_prsnl_reltns_reply->reply_list[i].event_list,5))
     SET pos1 = locatevalsort(num,locatestartevent,locateendevent,rte_prsnl_reltns_reply->reply_list[
      i].event_list[j].event_id,reply->reply_list[pos].event_list[num].event_id)
     IF (pos1 <= 0)
      SET event_cnt_merge = (size(reply->reply_list[pos].event_list,5)+ 1)
      SET stat = alterlist(reply->reply_list[pos].event_list,event_cnt_merge)
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].event_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[j].event_class_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd_disp =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_class_cd_disp
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd_mean =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_class_cd_mean
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_tag = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].event_tag
      SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd_disp =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd_disp
      SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd_mean =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd_mean
      SET reply->reply_list[pos].event_list[event_cnt_merge].person_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].person_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].name_full_formatted =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].name_full_formatted
      SET reply->reply_list[pos].event_list[event_cnt_merge].clinsig_updt_dt_tm =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].clinsig_updt_dt_tm
      SET reply->reply_list[pos].event_list[event_cnt_merge].updt_dt_tm = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].updt_dt_tm
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_cd = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].event_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].normalcy_cd = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].normalcy_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].event_title_text =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_title_text
      SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_class_type_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].encntr_class_type_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_type_cd = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[j].encntr_type_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].parent_event_id = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[j].parent_event_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].parent_event_class_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].parent_event_class_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].prsnl_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].prsnl_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].prsnl_name = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].prsnl_name
      SET reply->reply_list[pos].event_list[event_cnt_merge].action_prsnl_group_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].action_prsnl_group_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].action_prsnl_group_name =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].action_prsnl_group_name
      SET reply->reply_list[pos].event_list[event_cnt_merge].assign_prsnl_id = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[j].assign_prsnl_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].assign_prsnl_name =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].assign_prsnl_name
      SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[j].encntr_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].endorse_status_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].endorse_status_cd
      SET reply->reply_list[pos].event_list[event_cnt_merge].last_comment_txt =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].last_comment_txt
      SET reply->reply_list[pos].event_list[event_cnt_merge].multiple_comment_ind =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].multiple_comment_ind
      SET reply->reply_list[pos].event_list[event_cnt_merge].multiple_comment_prsnl_ind =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].multiple_comment_prsnl_ind
      SET reply->reply_list[pos].event_list[event_cnt_merge].last_saved_prsnl_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].last_saved_prsnl_id
      SET reply->reply_list[pos].event_list[event_cnt_merge].originating_provider_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[j].originating_provider_id
      IF (orderidexists)
       SET reply->reply_list[pos].event_list[event_cnt_merge].order_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].order_id
      ENDIF
      SET stat = alterlist(reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list,
       size(rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5))
      FOR (l = 1 TO size(rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5)
       )
       SET reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list[l].
       action_prsnl_id = rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l]
       .action_prsnl_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list[l].reltn_type_cd
        = rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l].reltn_type_cd
      ENDFOR
     ELSE
      IF ((rte_prsnl_reltns_reply->reply_list[i].event_list[j].prsnl_id=reply->reply_list[pos].
      event_list[pos1].prsnl_id))
       SET locatestartevent = (pos1+ 1)
       SET stat = alterlist(reply->reply_list[pos].event_list[pos1].rte_prsnl_reltns_list,size(
         rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5))
       FOR (l = 1 TO size(rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5
        ))
        SET reply->reply_list[pos].event_list[pos1].rte_prsnl_reltns_list[l].action_prsnl_id =
        rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l].action_prsnl_id
        SET reply->reply_list[pos].event_list[pos1].rte_prsnl_reltns_list[l].reltn_type_cd =
        rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l].reltn_type_cd
       ENDFOR
      ELSE
       IF ((rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_id != rte_prsnl_reltns_reply->
       reply_list[i].event_list[(j - 1)].event_id))
        SET locatestartevent = (pos1+ 1)
       ENDIF
       SET event_cnt_merge = (size(reply->reply_list[pos].event_list,5)+ 1)
       SET stat = alterlist(reply->reply_list[pos].event_list,event_cnt_merge)
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].event_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd = rte_prsnl_reltns_reply
       ->reply_list[i].event_list[j].event_class_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd_disp =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_class_cd_disp
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_class_cd_mean =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_class_cd_mean
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_tag = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].event_tag
       SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd_disp =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd_disp
       SET reply->reply_list[pos].event_list[event_cnt_merge].result_status_cd_mean =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].result_status_cd_mean
       SET reply->reply_list[pos].event_list[event_cnt_merge].person_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].person_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].name_full_formatted =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].name_full_formatted
       SET reply->reply_list[pos].event_list[event_cnt_merge].clinsig_updt_dt_tm =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].clinsig_updt_dt_tm
       SET reply->reply_list[pos].event_list[event_cnt_merge].updt_dt_tm = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].updt_dt_tm
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_cd = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].event_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].normalcy_cd = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].normalcy_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].event_title_text =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].event_title_text
       SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_class_type_cd =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].encntr_class_type_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_type_cd = rte_prsnl_reltns_reply
       ->reply_list[i].event_list[j].encntr_type_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].parent_event_id =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].parent_event_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].parent_event_class_cd =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].parent_event_class_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].prsnl_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].prsnl_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].prsnl_name = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].prsnl_name
       SET reply->reply_list[pos].event_list[event_cnt_merge].action_prsnl_group_id =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].action_prsnl_group_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].action_prsnl_group_name =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].action_prsnl_group_name
       SET reply->reply_list[pos].event_list[event_cnt_merge].assign_prsnl_id =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].assign_prsnl_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].assign_prsnl_name =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].assign_prsnl_name
       SET reply->reply_list[pos].event_list[event_cnt_merge].encntr_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[j].encntr_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].endorse_status_cd =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].endorse_status_cd
       SET reply->reply_list[pos].event_list[event_cnt_merge].last_comment_txt =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].last_comment_txt
       SET reply->reply_list[pos].event_list[event_cnt_merge].multiple_comment_ind =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].multiple_comment_ind
       SET reply->reply_list[pos].event_list[event_cnt_merge].multiple_comment_prsnl_ind =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].multiple_comment_prsnl_ind
       SET reply->reply_list[pos].event_list[event_cnt_merge].last_saved_prsnl_id =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].last_saved_prsnl_id
       SET reply->reply_list[pos].event_list[event_cnt_merge].originating_provider_id =
       rte_prsnl_reltns_reply->reply_list[i].event_list[j].originating_provider_id
       IF (orderidexists)
        SET reply->reply_list[pos].event_list[event_cnt_merge].order_id = rte_prsnl_reltns_reply->
        reply_list[i].event_list[j].order_id
       ENDIF
       SET stat = alterlist(reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list,
        size(rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5))
       FOR (l = 1 TO size(rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list,5
        ))
        SET reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list[l].
        action_prsnl_id = rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l
        ].action_prsnl_id
        SET reply->reply_list[pos].event_list[event_cnt_merge].rte_prsnl_reltns_list[l].reltn_type_cd
         = rte_prsnl_reltns_reply->reply_list[i].event_list[j].rte_prsnl_reltns_list[l].reltn_type_cd
       ENDFOR
      ENDIF
     ENDIF
    ENDFOR
   ELSE
    SET prsnl_count_merge = (size(reply->reply_list,5)+ 1)
    SET stat = alterlist(reply->reply_list,prsnl_count_merge)
    SET reply->reply_list[prsnl_count_merge].prsnl_id = rte_prsnl_reltns_reply->reply_list[i].
    prsnl_id
    SET reply->reply_list[prsnl_count_merge].action_prsnl_group_id = rte_prsnl_reltns_reply->
    reply_list[i].action_prsnl_group_id
    SET event_cnt_merge = size(rte_prsnl_reltns_reply->reply_list[i].event_list,5)
    SET stat = alterlist(reply->reply_list[prsnl_count_merge].event_list,event_cnt_merge)
    FOR (k = 1 TO event_cnt_merge)
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].event_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_class_cd = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[k].event_class_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_class_cd_disp =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].event_class_cd_disp
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_class_cd_mean =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].event_class_cd_mean
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_tag = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].event_tag
      SET reply->reply_list[prsnl_count_merge].event_list[k].result_status_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].result_status_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].result_status_cd_disp =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].result_status_cd_disp
      SET reply->reply_list[prsnl_count_merge].event_list[k].result_status_cd_mean =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].result_status_cd_mean
      SET reply->reply_list[prsnl_count_merge].event_list[k].person_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].person_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].name_full_formatted =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].name_full_formatted
      SET reply->reply_list[prsnl_count_merge].event_list[k].clinsig_updt_dt_tm =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].clinsig_updt_dt_tm
      SET reply->reply_list[prsnl_count_merge].event_list[k].updt_dt_tm = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].updt_dt_tm
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_cd = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].event_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].normalcy_cd = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].normalcy_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].event_title_text =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].event_title_text
      SET reply->reply_list[prsnl_count_merge].event_list[k].encntr_class_type_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].encntr_class_type_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].encntr_type_cd = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[k].encntr_type_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].parent_event_id = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[k].parent_event_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].parent_event_class_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].parent_event_class_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].prsnl_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].prsnl_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].prsnl_name = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].prsnl_name
      SET reply->reply_list[prsnl_count_merge].event_list[k].action_prsnl_group_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].action_prsnl_group_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].action_prsnl_group_name =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].action_prsnl_group_name
      SET reply->reply_list[prsnl_count_merge].event_list[k].assign_prsnl_id = rte_prsnl_reltns_reply
      ->reply_list[i].event_list[k].assign_prsnl_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].assign_prsnl_name =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].assign_prsnl_name
      SET reply->reply_list[prsnl_count_merge].event_list[k].encntr_id = rte_prsnl_reltns_reply->
      reply_list[i].event_list[k].encntr_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].endorse_status_cd =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].endorse_status_cd
      SET reply->reply_list[prsnl_count_merge].event_list[k].last_comment_txt =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].last_comment_txt
      SET reply->reply_list[prsnl_count_merge].event_list[k].multiple_comment_ind =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].multiple_comment_ind
      SET reply->reply_list[prsnl_count_merge].event_list[k].multiple_comment_prsnl_ind =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].multiple_comment_prsnl_ind
      SET reply->reply_list[prsnl_count_merge].event_list[k].last_saved_prsnl_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].last_saved_prsnl_id
      SET reply->reply_list[prsnl_count_merge].event_list[k].originating_provider_id =
      rte_prsnl_reltns_reply->reply_list[i].event_list[k].originating_provider_id
      IF (orderidexists)
       SET reply->reply_list[prsnl_count_merge].event_list[k].order_id = rte_prsnl_reltns_reply->
       reply_list[i].event_list[k].order_id
      ENDIF
      SET stat = alterlist(reply->reply_list[prsnl_count_merge].event_list[k].rte_prsnl_reltns_list,
       size(rte_prsnl_reltns_reply->reply_list[i].event_list[k].rte_prsnl_reltns_list,5))
      FOR (l = 1 TO size(rte_prsnl_reltns_reply->reply_list[i].event_list[k].rte_prsnl_reltns_list,5)
       )
       SET reply->reply_list[prsnl_count_merge].event_list[k].rte_prsnl_reltns_list[l].
       action_prsnl_id = rte_prsnl_reltns_reply->reply_list[i].event_list[k].rte_prsnl_reltns_list[l]
       .action_prsnl_id
       SET reply->reply_list[prsnl_count_merge].event_list[k].rte_prsnl_reltns_list[l].reltn_type_cd
        = rte_prsnl_reltns_reply->reply_list[i].event_list[k].rte_prsnl_reltns_list[l].reltn_type_cd
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 IF ((reply->error_code > 0.0))
  GO TO exit_script
 ENDIF
#exit_script
END GO
