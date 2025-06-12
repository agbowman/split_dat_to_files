CREATE PROGRAM ce_event_query:dba
 DECLARE stat_i4 = i4 WITH protect, noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE eventsetincludecnt = i4 WITH noconstant(0)
 DECLARE eventsetexcludecnt = i4 WITH noconstant(0)
 DECLARE encntrlistcnt = i4 WITH noconstant(0)
 DECLARE encntrtypeclasscnt = i4 WITH noconstant(0)
 DECLARE encntrtypecnt = i4 WITH noconstant(0)
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE nstart_order = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx_order = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE esmall_query = i4 WITH constant(32768)
 DECLARE eall_sts = i4 WITH constant(32)
 DECLARE etreat_order_ids_as_parents = i4 WITH constant(268435456)
 DECLARE eexp = i4 WITH constant(3)
 DECLARE eevent = i4 WITH constant(4)
 DECLARE eexp_mult = i4 WITH constant(5)
 DECLARE epublished = i4 WITH constant(0)
 DECLARE eprelim_published = i4 WITH constant(2)
 DECLARE eascending = i4 WITH constant(1)
 DECLARE not_empty = i2 WITH constant(0)
 DECLARE empty = i2 WITH constant(1)
 DECLARE max_date = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE gquerymode = i4 WITH constant(request->query_mode)
 DECLARE gquerytype = i4 WITH constant(context->query_type)
 DECLARE gnonpublishflag = i4 WITH constant(request->non_publish_flag)
 DECLARE gsearchstartdttmind = i4 WITH constant(request->search_start_dt_tm_ind)
 DECLARE gsearchenddttmind = i4 WITH constant(request->search_end_dt_tm_ind)
 DECLARE gdirectionflag = i4 WITH constant(request->direction_flag)
 DECLARE gdateflag = i4 WITH constant(request->date_flag)
 DECLARE gwheredatefield = c25 WITH noconstant("")
 DECLARE gorderdatefield = c25 WITH noconstant("")
 DECLARE geventstofetch = i4 WITH constant(request->events_to_fetch)
 DECLARE orderlistsize = i4 WITH constant(size(request->order_id_list,5))
 DECLARE eventsetincludesize = i4 WITH constant(size(request->event_set_cd_include_list,5))
 DECLARE eventsetexcludesize = i4 WITH constant(size(request->event_set_cd_exclude_list,5))
 DECLARE encntrlistsize = i4 WITH constant(size(request->encntr_id_list,5))
 DECLARE encntrtypeclasssize = i4 WITH constant(size(request->encntr_type_class_cd_list,5))
 DECLARE encntrtypesize = i4 WITH constant(size(request->encntr_type_cd_list,5))
 DECLARE resultstatuslistsize = i4 WITH constant(size(request->result_status_list,5))
 DECLARE resultstatusidx = i4 WITH noconstant(0), protect
 DECLARE performprsnllistsize = i4 WITH constant(size(request->perform_prsnl_list,5))
 DECLARE performprsnlidx = i4 WITH noconstant(0), protect
 DECLARE thisdate = c8 WITH noconstant("")
 DECLARE lastdate = c8 WITH noconstant("")
 DECLARE buildselectexpression(null) = null
 DECLARE buildfromclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE buildstandarddetailclause(null) = null
 DECLARE buildorderbyclause(null) = null
 DECLARE buildorahints(null) = null
 DECLARE setupeventsetincludeclause(null) = null
 DECLARE setupeventorderincludeclause(null) = null
 DECLARE setupsearchdates(null) = null
 DECLARE setupeventrowversionclause(null) = null
 DECLARE setupincludeexplodejoin(null) = null
 DECLARE setuplongtextjoin(null) = null
 DECLARE setupencntrclause(null) = null
 DECLARE setupencntrtypeclassjoin(null) = null
 DECLARE setupexcludeexplodeclause(null) = null
 DECLARE setupresultstatusexpand(null) = null
 DECLARE setupperformprsnlexpand(null) = null
 IF ( NOT (band(gquerymode,eall_sts)))
  SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 ENDIF
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 SET nstart_order = 1
 SET ntotal2 = orderlistsize
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat_i4 = alterlist(request->order_id_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->order_id_list[idx].order_id = request->order_id_list[orderlistsize].order_id
 ENDFOR
 CASE (gdateflag)
  OF 0:
   SET gwheredatefield = " ce.event_end_dt_tm"
   SET gorderdatefield = gwheredatefield
  OF 1:
   SET gwheredatefield = " ce.updt_dt_tm"
   SET gorderdatefield = gwheredatefield
  OF 2:
   SET gwheredatefield = " ce.clinsig_updt_dt_tm"
   SET gorderdatefield = " ce.event_end_dt_tm"
  ELSE
   SET error_msg = build("Invalid date_flag (",gdateflag,")")
   GO TO exit_script
 ENDCASE
 CALL buildselectexpression(null)
 CALL buildfromclause(null)
 CALL buildwhereclause(null)
 CALL buildorderbyclause(null)
 CALL buildstandarddetailclause(null)
 CALL parser(" with memsort ")
 CALL buildorahints(null)
 CALL parser(" go ")
 SET stat_i4 = alterlist(reply->event_list,cnt)
 GO TO exit_script
 SUBROUTINE buildselectexpression(null)
   CALL parser("  select into 'nl:' ce.event_id, ")
   CALL parser("  valid_until_dt_tm_ind = nullind(ce.valid_until_dt_tm), ")
   CALL parser("  clinsig_updt_dt_tm_ind = nullind(ce.clinsig_updt_dt_tm), ")
   CALL parser("  valid_from_dt_tm_ind = nullind(ce.valid_from_dt_tm), ")
   CALL parser("  event_end_dt_tm_ind = nullind(ce.event_end_dt_tm), ")
   CALL parser("  performed_dt_tm_ind = nullind(ce.performed_dt_tm), ")
   CALL parser("  updt_dt_tm_ind = nullind(ce.updt_dt_tm) ")
   IF ( NOT (band(gquerymode,esmall_query)))
    CALL parser(",  view_level_ind = nullind(ce.view_level), ")
    CALL parser("  event_start_dt_tm_ind = nullind(ce.event_start_dt_tm), ")
    CALL parser("  publish_flag_ind = nullind(ce.publish_flag), ")
    CALL parser("  subtable_bit_map_ind = nullind(ce.subtable_bit_map), ")
    CALL parser("  verified_dt_tm_ind = nullind(ce.verified_dt_tm), ")
    CALL parser("  expiration_dt_tm_ind = nullind(ce.expiration_dt_tm), ")
    CALL parser("  updt_task_ind = nullind(ce.updt_task), ")
    CALL parser("  updt_cnt_ind = nullind(ce.updt_cnt), ")
    CALL parser("  updt_applctx_ind = nullind(ce.updt_applctx) ")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildfromclause(null)
   CALL parser(" from ")
   CALL parser(" ce_event_order_link eol, ")
   CALL parser(" clinical_event ce, ")
   IF (eventsetincludesize)
    CALL parser(" v500_event_set_explode ex, ")
   ENDIF
   CALL parser(" long_text lt ")
   IF (((encntrtypeclasssize) OR (encntrtypesize)) )
    CALL parser(" , encounter e ")
   ENDIF
   IF (orderlistsize > 1)
    CALL parser(", (dummyt d1 with seq = value(1+((ntotal-1)/nsize)))")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildwhereclause(null)
   IF (orderlistsize > 1)
    CALL parser("Plan d1 where assign (nstart_order, evaluate (d1.seq,1,1,nstart_order+nsize))")
    CALL parser("Join eol where")
   ELSE
    CALL parser("Plan eol where")
   ENDIF
   CALL setupeventorderincludeclause(null)
   CALL parser("Join ce where ce.event_id = eol.event_id+0 and ")
   IF (record_status_deleted)
    CALL parser(" ce.record_status_cd != RECORD_STATUS_DELETED and ")
   ENDIF
   IF (record_status_draft)
    CALL parser(" ce.record_status_cd != RECORD_STATUS_DRAFT and ")
   ENDIF
   CALL parser(" ce.view_level > request->view_level and ")
   IF (gnonpublishflag=epublished)
    CALL parser(" ce.publish_flag = 1 and ")
   ELSEIF (gnonpublishflag=eprelim_published)
    CALL parser(" ce.publish_flag != 0 and ")
   ENDIF
   IF (gquerytype=eevent)
    CALL parser(" ce.event_cd = request->event_cd and ")
   ENDIF
   CALL parser(" ce.person_id+0 = request->person_id and ")
   IF (((gsearchenddttmind=not_empty) OR (gdateflag=2
    AND gsearchstartdttmind=not_empty)) )
    CALL setupsearchdates(null)
   ENDIF
   IF (encntrlistsize)
    CALL setupencntrclause(null)
   ENDIF
   IF (request->encntr_financial_id)
    CALL parser(" ce.encntr_financial_id = request->encntr_financial_id and ")
   ENDIF
   IF ((request->accession_nbr != ""))
    CALL parser(" Trim(ce.accession_nbr) = request->accession_nbr and ")
    IF (request->contributor_system_cd)
     CALL parser(" ce.contributor_system_cd = request->contributor_system_cd and ")
    ENDIF
   ENDIF
   CALL setupeventrowversionclause(null)
   IF (resultstatuslistsize)
    CALL setupresultstatusexpand(null)
   ENDIF
   IF (performprsnllistsize)
    CALL setupperformprsnlexpand(null)
   ENDIF
   IF (eventsetexcludesize)
    CALL setupexcludeexplodeclause(null)
   ENDIF
   IF (eventsetincludesize)
    CALL setupincludeexplodejoin(null)
   ENDIF
   CALL setuplongtextjoin(null)
   IF (((encntrtypeclasssize) OR (encntrtypesize)) )
    CALL setupencntrtypeclassjoin(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE setupeventsetincludeclause(null)
   IF (eventsetincludesize > 200)
    SET error_msg = build(" Exceeded event_set_cd_list_ext limit of 200. ")
    GO TO exit_script
   ELSEIF (eventsetincludesize > 1)
    CALL parser(" expand( eventSetIncludeCnt, 1, eventSetIncludeSize, ex.event_set_cd+0,       ")
    CALL parser("         request->event_set_cd_include_list[eventSetIncludeCnt].event_set_cd ) ")
   ELSEIF (eventsetincludesize=1)
    CALL parser(" ex.event_set_cd+0 = request->event_set_cd_include_list[1].event_set_cd ")
   ENDIF
 END ;Subroutine
 SUBROUTINE setupeventorderincludeclause(null)
   IF (orderlistsize > 1
    AND band(gquerymode,etreat_order_ids_as_parents))
    CALL parser(" expand( idx_order, nstart_order, nstart_order+nsize-1, eol.parent_order_ident,  ")
    CALL parser("         request->order_id_list[idx_order].order_id )       ")
   ELSEIF (orderlistsize > 1)
    CALL parser(" expand( idx_order, nstart_order, nstart_order+nsize-1, eol.order_id,  ")
    CALL parser("         request->order_id_list[idx_order].order_id )       ")
   ELSEIF (orderlistsize=1
    AND band(gquerymode,etreat_order_ids_as_parents))
    CALL parser(" eol.parent_order_ident = request->order_id_list[1].order_id ")
   ELSEIF (orderlistsize=1)
    CALL parser(" eol.order_id = request->order_id_list[1].order_id ")
   ENDIF
   IF (gdateflag=0)
    IF (gsearchstartdttmind=not_empty)
     IF (gdirectionflag=eascending)
      CALL parser(" and eol.event_end_dt_tm >= cnvtdatetimeutc(request->search_start_dt_tm)")
      IF (gsearchenddttmind=not_empty)
       CALL parser(" and eol.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)")
      ENDIF
     ELSE
      CALL parser(" and eol.event_end_dt_tm <= cnvtdatetimeutc(request->search_start_dt_tm)")
      IF (gsearchenddttmind=not_empty)
       CALL parser(" and eol.event_end_dt_tm >= cnvtdatetimeutc(request->search_end_dt_tm)")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL parser(" and eol.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ")
 END ;Subroutine
 SUBROUTINE setupincludeexplodejoin(null)
   CALL parser(" Join ex where ")
   CALL setupeventsetincludeclause(null)
   CALL parser(" and ex.event_cd = ce.event_cd ")
 END ;Subroutine
 SUBROUTINE setupeventsetexcludeclause(null)
   IF (eventsetexcludesize > 200)
    SET error_msg = build(" Exceeded event_set_list limit of 200. ")
    GO TO exit_script
   ELSEIF (eventsetexcludesize > 1)
    CALL parser(" expand( eventSetExcludeCnt, 1, eventSetExcludeSize, ex2.event_set_cd,         ")
    CALL parser("         request->event_set_cd_exclude_list[eventSetExcludeCnt].event_set_cd ) ")
   ELSEIF (eventsetexcludesize=1)
    CALL parser(" ex2.event_set_cd = request->event_set_cd_exclude_list[1].event_set_cd ")
   ENDIF
 END ;Subroutine
 SUBROUTINE setupexcludeexplodeclause(null)
   CALL parser(" and NOT EXISTS( select 'x' from v500_event_set_explode ex2 where ")
   CALL setupeventsetexcludeclause(null)
   CALL parser(" and ce.event_cd = ex2.event_cd ) ")
 END ;Subroutine
 SUBROUTINE setuplongtextjoin(null)
   CALL parser(" Join lt where ce.modifier_long_text_id = lt.long_text_id ")
 END ;Subroutine
 SUBROUTINE setupencntrclause(null)
   IF (encntrlistsize > 2000)
    SET error_msg = build(" Exceeded encntr_list limit of 2000. ")
    GO TO exit_script
   ELSEIF (encntrlistsize > 1)
    CALL parser(" expand( encntrListCnt, 1, encntrListSize, ce.encntr_id+0, ")
    CALL parser("         request->encntr_id_list[encntrListCnt].encntr_id ) and  ")
   ELSEIF (encntrlistsize=1)
    CALL parser(" ce.encntr_id+0 = request->encntr_id_list[1].encntr_id and ")
   ENDIF
 END ;Subroutine
 SUBROUTINE setupencntrtypeclassjoin(null)
   CALL parser(" Join e where ")
   IF (encntrtypeclasssize > 200)
    SET error_msg = build(" Exceeded encntr_type_class_cd_list limit of 200. ")
    GO TO exit_script
   ELSEIF (encntrtypeclasssize > 1)
    CALL parser(" expand( encntrTypeClassCnt, 1, encntrTypeClassSize, e.encntr_type_class_cd+0 , ")
    CALL parser(
     "         request->encntr_type_class_cd_list[encntrTypeClassCnt].encntr_type_class_cd )   ")
   ELSEIF (encntrtypeclasssize=1)
    CALL parser(
     " e.encntr_type_class_cd+0 = request->encntr_type_class_cd_list[1].encntr_type_class_cd ")
   ENDIF
   IF (encntrtypeclasssize > 0
    AND encntrtypesize > 0)
    CALL parser(" and ")
   ENDIF
   IF (encntrtypesize > 1)
    CALL parser(" expand( encntrTypeCnt, 1, encntrTypeSize, e.encntr_type_cd+0 , ")
    CALL parser("         request->encntr_type_cd_list[encntrTypeCnt].encntr_type_cd )   ")
   ELSEIF (encntrtypesize=1)
    CALL parser(" e.encntr_type_cd+0 = request->encntr_type_cd_list[1].encntr_type_cd ")
   ENDIF
   CALL parser(" and e.encntr_id = ce.encntr_id ")
   CALL parser(" and e.active_ind = 1 ")
 END ;Subroutine
 SUBROUTINE setupsearchdates(null)
   IF (gdirectionflag=eascending)
    CALL parser(gwheredatefield)
    CALL parser(" >= cnvtdatetimeutc(request->search_start_dt_tm) and ")
    IF (gsearchenddttmind=not_empty)
     CALL parser(gwheredatefield)
     CALL parser(" <= cnvtdatetimeutc(request->search_end_dt_tm) and ")
    ENDIF
    IF ((context->last_event_dt_tm_ind=not_empty)
     AND gdateflag=2)
     CALL parser(gorderdatefield)
     CALL parser(" > cnvtdatetimeutc(context->last_event_dt_tm) and ")
    ENDIF
   ELSE
    CALL parser(gwheredatefield)
    CALL parser(" <= cnvtdatetimeutc(request->search_start_dt_tm) and ")
    IF (gsearchenddttmind=not_empty)
     CALL parser(gwheredatefield)
     CALL parser(" >= cnvtdatetimeutc(request->search_end_dt_tm) and ")
    ENDIF
    IF ((context->last_event_dt_tm_ind=not_empty)
     AND gdateflag=2)
     CALL parser(gorderdatefield)
     CALL parser(" < cnvtdatetimeutc(context->last_event_dt_tm) and ")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setupeventrowversionclause(null)
   IF ((request->valid_from_dt_tm_ind=empty))
    CALL parser("  ce.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ")
   ELSE
    CALL parser(" ( ce.valid_from_dt_tm <= cnvtdatetime(request->valid_from_dt_tm) and  ")
    CALL parser(" ce.valid_until_dt_tm >= cnvtdatetime(request->valid_from_dt_tm) )   ")
   ENDIF
 END ;Subroutine
 SUBROUTINE setupresultstatusexpand(null)
  DECLARE fieldname = vc WITH noconstant(""), protect
  IF (resultstatuslistsize > 1)
   SET fieldname = "ce.result_status_cd+0"
   CALL parser(concat(" and expand (resultStatusIdx, 1, resultStatusListSize, ",fieldname,
     ", request->result_status_list[resultStatusIdx].result_status_cd)"))
  ELSE
   CALL parser(" and ce.result_status_cd+0 = request->result_status_list[1].result_status_cd ")
  ENDIF
 END ;Subroutine
 SUBROUTINE setupperformprsnlexpand(null)
  DECLARE fieldname = vc WITH noconstant(""), protect
  IF (performprsnllistsize > 1)
   SET fieldname = "ce.performed_prsnl_id+0"
   CALL parser(concat(" and expand (performPrsnlIdx, 1, performPrsnlListSize, ",fieldname,
     ", request->perform_prsnl_list[performPrsnlIdx].perform_prsnl_id)"))
  ELSE
   CALL parser(" and ce.performed_prsnl_id+0 = request->perform_prsnl_list[1].perform_prsnl_id")
  ENDIF
 END ;Subroutine
 SUBROUTINE buildorderbyclause(null)
   DECLARE sortdir = vc WITH noconstant(""), protect
   IF (gdirectionflag != eascending)
    SET sortdir = " desc "
   ENDIF
   CALL parser(build(" order by ",gorderdatefield,sortdir))
   CALL parser(", ce.event_id ")
 END ;Subroutine
 SUBROUTINE buildorahints(null)
   IF (band(gquerymode,etreat_order_ids_as_parents))
    CALL parser(
     ", orahintcbo('leading(eol ce)','index( ce XAK2CLINICAL_EVENT)', 'index(eol XIE3CE_EVENT_ORDER_LINK)'), "
     )
    CALL parser(
     " orahint('leading(eol ce)','index( ce XAK2CLINICAL_EVENT)', 'index(eol XIE3CE_EVENT_ORDER_LINK)')"
     )
   ELSE
    CALL parser(
     ", orahintcbo('leading(eol ce)','index( ce XAK2CLINICAL_EVENT)', 'index(eol XIE2CE_EVENT_ORDER_LINK)'), "
     )
    CALL parser(
     " orahint('leading(eol ce)','index( ce XAK2CLINICAL_EVENT)', 'index(eol XIE2CE_EVENT_ORDER_LINK)')"
     )
   ENDIF
 END ;Subroutine
 SUBROUTINE buildstandarddetailclause(null)
   CALL parser("  detail  ")
   CALL parser(" cnt = cnt + 1  ")
   CALL parser(" if ((cnt > 1) AND (reply->event_list[cnt-1]->event_id = ce.event_id)) ")
   CALL parser("     cnt = cnt - 1 ")
   CALL parser(" else ")
   IF (geventstofetch)
    CALL parser("if (curutc and request->end_of_day_tz)")
    CALL parser(build("   lastDate = datetimezoneformat( context->last_event_dt_tm, ",
      "request->end_of_day_tz, 'MMddyyyy;;D')"))
    CALL parser(build("   thisDate = datetimezoneformat(",gorderdatefield,
      ", request->end_of_day_tz, ","'MMddyyyy;;D')"))
    CALL parser("else")
    CALL parser("   lastDate = format(context->last_event_dt_tm, 'MMddyyyy;;D')")
    CALL parser(build("   thisDate = format(",gorderdatefield,", 'MMddyyyy;;D')"))
    CALL parser("endif")
    CALL parser(" if ( thisDate = lastDate)   ")
    CALL parser("    bSameDay = TRUE ")
    CALL parser(" else ")
    CALL parser("    bSameDay = FALSE ")
    CALL parser(" endif ")
    CALL parser(" if (cnt > gEventsToFetch AND bSameDay = 0) ")
    CALL parser("     cnt = cnt - 1 ")
    CALL parser(" else ")
   ENDIF
   CALL parser("  if ( mod(cnt,10) = 1 )                          ")
   CALL parser("    stat_i4 = alterlist( reply->event_list, cnt + 9 )  ")
   CALL parser(" endif ")
   CALL parser(" reply->event_list[cnt].clinical_event_id = ce.clinical_event_id, ")
   CALL parser(" reply->event_list[cnt].event_id = ce.event_id, ")
   CALL parser(" reply->event_list[cnt].valid_until_dt_tm = ce.valid_until_dt_tm, ")
   CALL parser(" reply->event_list[cnt].valid_until_dt_tm_ind = valid_until_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].view_level = ce.view_level, ")
   CALL parser(" reply->event_list[cnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, ")
   CALL parser(" reply->event_list[cnt].clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].order_id = ce.order_id, ")
   CALL parser(" reply->event_list[cnt].order_action_sequence = ce.order_action_sequence, ")
   CALL parser(" reply->event_list[cnt].catalog_cd = ce.catalog_cd, ")
   CALL parser(" reply->event_list[cnt].encntr_id = ce.encntr_id, ")
   CALL parser(" reply->event_list[cnt].contributor_system_cd = ce.contributor_system_cd, ")
   CALL parser(" reply->event_list[cnt].reference_nbr = ce.reference_nbr, ")
   CALL parser(" reply->event_list[cnt].parent_event_id = ce.parent_event_id, ")
   CALL parser(" reply->event_list[cnt].valid_from_dt_tm = ce.valid_from_dt_tm, ")
   CALL parser(" reply->event_list[cnt].valid_from_dt_tm_ind = valid_from_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].event_class_cd = ce.event_class_cd, ")
   CALL parser(" reply->event_list[cnt].event_cd = ce.event_cd, ")
   CALL parser(" reply->event_list[cnt].event_tag = ce.event_tag, ")
   CALL parser(" reply->event_list[cnt].collating_seq = ce.collating_seq, ")
   CALL parser(" reply->event_list[cnt].event_end_dt_tm = ce.event_end_dt_tm, ")
   CALL parser(" reply->event_list[cnt].event_end_dt_tm_ind = event_end_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].event_end_tz = ce.event_end_tz, ")
   CALL parser(" reply->event_list[cnt].task_assay_cd = ce.task_assay_cd, ")
   CALL parser(" reply->event_list[cnt].result_status_cd = ce.result_status_cd, ")
   CALL parser(" reply->event_list[cnt].publish_flag = ce.publish_flag, ")
   CALL parser(" reply->event_list[cnt].subtable_bit_map = ce.subtable_bit_map, ")
   CALL parser(" reply->event_list[cnt].event_title_text = ce.event_title_text, ")
   CALL parser(" reply->event_list[cnt].result_val = ce.result_val, ")
   CALL parser(" reply->event_list[cnt].result_units_cd = ce.result_units_cd, ")
   CALL parser(" reply->event_list[cnt].performed_dt_tm = ce.performed_dt_tm, ")
   CALL parser(" reply->event_list[cnt].performed_dt_tm_ind = performed_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].performed_tz = ce.performed_tz, ")
   CALL parser(" reply->event_list[cnt].performed_prsnl_id = ce.performed_prsnl_id, ")
   CALL parser(" reply->event_list[cnt].normal_low = ce.normal_low, ")
   CALL parser(" reply->event_list[cnt].normal_high = ce.normal_high, ")
   CALL parser(" reply->event_list[cnt].updt_dt_tm = ce.updt_dt_tm, ")
   CALL parser(" reply->event_list[cnt].updt_dt_tm_ind = updt_dt_tm_ind, ")
   CALL parser(" reply->event_list[cnt].note_importance_bit_map = ce.note_importance_bit_map, ")
   CALL parser(" reply->event_list[cnt].entry_mode_cd = ce.entry_mode_cd, ")
   CALL parser(" reply->event_list[cnt].source_cd = ce.source_cd, ")
   CALL parser(" reply->event_list[cnt].clinical_seq = ce.clinical_seq, ")
   CALL parser(" reply->event_list[cnt].task_assay_version_nbr = ce.task_assay_version_nbr, ")
   CALL parser(" reply->event_list[cnt].modifier_long_text = lt.long_text, ")
   CALL parser(" reply->event_list[cnt].modifier_long_text_id = ce.modifier_long_text_id, ")
   CALL parser(" reply->event_list[cnt].src_event_id = ce.src_event_id, ")
   CALL parser(" reply->event_list[cnt].src_clinsig_updt_dt_tm = ce.src_clinsig_updt_dt_tm, ")
   CALL parser(" reply->event_list[cnt].person_id = ce.person_id ")
   CALL parser(" reply->event_list[cnt].nomen_string_flag = ce.nomen_string_flag ")
   CALL parser(" reply->event_list[cnt].ce_dynamic_label_id = ce.ce_dynamic_label_id ")
   CALL parser(" reply->event_list[cnt].trait_bit_map = ce.trait_bit_map, ")
   CALL parser(concat("stat_vc = assign(validate(reply->event_list[cnt].normal_ref_range_txt,",'"',
     '"',"),","ce.normal_ref_range_txt),"))
   CALL parser(
    " stat_f8 = assign(validate(reply->event_list[cnt].ce_grouping_id, 0), ce.ce_grouping_id) ")
   CALL parser(
    " stat_i4 = assign(validate(reply->event_list[cnt].subtable_bit_map2, 0), ce.subtable_bit_map2)")
   IF ( NOT (band(gquerymode,esmall_query)))
    CALL parser(", reply->event_list[cnt].view_level_ind = view_level_ind, ")
    CALL parser(" reply->event_list[cnt].series_ref_nbr = ce.series_ref_nbr, ")
    CALL parser(" reply->event_list[cnt].encntr_financial_id = ce.encntr_financial_id, ")
    CALL parser(" reply->event_list[cnt].accession_nbr = ce.accession_nbr, ")
    CALL parser(" reply->event_list[cnt].event_reltn_cd = ce.event_reltn_cd, ")
    CALL parser(" reply->event_list[cnt].event_start_dt_tm = ce.event_start_dt_tm, ")
    CALL parser(" reply->event_list[cnt].event_start_dt_tm_ind = event_start_dt_tm_ind, ")
    CALL parser(" reply->event_list[cnt].event_start_tz = ce.event_start_tz, ")
    CALL parser(" reply->event_list[cnt].record_status_cd = ce.record_status_cd, ")
    CALL parser(" reply->event_list[cnt].authentic_flag = ce.authentic_flag, ")
    CALL parser(" reply->event_list[cnt].publish_flag_ind = publish_flag_ind, ")
    CALL parser(" reply->event_list[cnt].qc_review_cd = ce.qc_review_cd, ")
    CALL parser(" reply->event_list[cnt].normalcy_cd = ce.normalcy_cd, ")
    CALL parser(" reply->event_list[cnt].normalcy_method_cd = ce.normalcy_method_cd, ")
    CALL parser(" reply->event_list[cnt].inquire_security_cd = ce.inquire_security_cd, ")
    CALL parser(" reply->event_list[cnt].resource_group_cd = ce.resource_group_cd, ")
    CALL parser(" reply->event_list[cnt].resource_cd = ce.resource_cd, ")
    CALL parser(" reply->event_list[cnt].subtable_bit_map_ind = subtable_bit_map_ind, ")
    CALL parser(" reply->event_list[cnt].result_time_units_cd = ce.result_time_units_cd, ")
    CALL parser(" reply->event_list[cnt].verified_dt_tm = ce.verified_dt_tm, ")
    CALL parser(" reply->event_list[cnt].verified_dt_tm_ind = verified_dt_tm_ind, ")
    CALL parser(" reply->event_list[cnt].verified_tz = ce.verified_tz, ")
    CALL parser(" reply->event_list[cnt].verified_prsnl_id = ce.verified_prsnl_id, ")
    CALL parser(" reply->event_list[cnt].critical_low = ce.critical_low, ")
    CALL parser(" reply->event_list[cnt].critical_high = ce.critical_high, ")
    CALL parser(" reply->event_list[cnt].expiration_dt_tm = ce.expiration_dt_tm, ")
    CALL parser(" reply->event_list[cnt].expiration_dt_tm_ind = expiration_dt_tm_ind, ")
    CALL parser(" reply->event_list[cnt].updt_id = ce.updt_id, ")
    CALL parser(" reply->event_list[cnt].updt_task = ce.updt_task, ")
    CALL parser(" reply->event_list[cnt].updt_task_ind = updt_task_ind, ")
    CALL parser(" reply->event_list[cnt].updt_cnt = ce.updt_cnt, ")
    CALL parser(" reply->event_list[cnt].updt_cnt_ind = updt_cnt_ind, ")
    CALL parser(" reply->event_list[cnt].updt_applctx = ce.updt_applctx, ")
    CALL parser(" reply->event_list[cnt].updt_applctx_ind = updt_applctx_ind ")
    CALL parser(" reply->event_list[cnt].event_tag_set_flag = ce.event_tag_set_flag, ")
    CALL parser(" reply->event_list[cnt].device_free_txt = ce.device_free_txt ")
   ENDIF
   CALL parser(build(" context->last_event_dt_tm = ",gorderdatefield))
   CALL parser(" context->last_event_dt_tm_ind = 0 ")
   IF (request->events_to_fetch)
    CALL parser(" endif ")
   ENDIF
   CALL parser(" endif ")
 END ;Subroutine
#exit_script
 SET stat_i4 = alterlist(reply->event_list,cnt)
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
