CREATE PROGRAM ce_retrieve_paged_events:dba
 DECLARE stat_i4 = i4 WITH protect, noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 DECLARE record_status_deleted = f8 WITH noconstant(0.0), protect
 DECLARE record_status_draft = f8 WITH noconstant(0.0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE encntrlistcnt = i4 WITH noconstant(0), protect
 DECLARE encntrtypeclasscnt = i4 WITH noconstant(0), protect
 DECLARE encntrtypecnt = i4 WITH noconstant(0), protect
 DECLARE nsize = i4 WITH constant(50), protect
 DECLARE ntotal = i4 WITH noconstant(0), protect
 DECLARE ntotal2 = i4 WITH noconstant(0), protect
 DECLARE nstart_order = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE idx_order = i4 WITH noconstant(0), protect
 DECLARE error_msg = vc WITH noconstant(" "), protect
 DECLARE error_code = i4 WITH noconstant(0), protect
 DECLARE esmall_query = i4 WITH constant(32768), protect
 DECLARE eall_sts = i4 WITH constant(32), protect
 DECLARE etreat_order_ids_as_parents = i4 WITH constant(268435456), protect
 DECLARE eexp = i4 WITH constant(3), protect
 DECLARE eevent = i4 WITH constant(4), protect
 DECLARE eexp_mult = i4 WITH constant(5), protect
 DECLARE epublished = i4 WITH constant(0), protect
 DECLARE eprelim_published = i4 WITH constant(2), protect
 DECLARE eascending = i4 WITH constant(1), protect
 DECLARE edescending = i4 WITH constant(0), protect
 DECLARE orderdir_ascend = i4 WITH constant(0), protect
 DECLARE orderdir_desc = i4 WITH constant(1), protect
 DECLARE not_empty = i2 WITH constant(0), protect
 DECLARE empty = i2 WITH constant(1), protect
 DECLARE max_date = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00")), protect
 DECLARE min_date = q8 WITH constant(cnvtdatetime("01-JAN-1800 00:00:00")), protect
 DECLARE gquerymode = i4 WITH constant(request->query_mode), protect
 DECLARE gquerytype = i4 WITH constant(context->query_type), protect
 DECLARE gnonpublishflag = i4 WITH constant(request->non_publish_flag), protect
 DECLARE gsearchstartdttmind = i4 WITH constant(request->search_start_dt_tm_ind), protect
 DECLARE gsearchenddttmind = i4 WITH constant(request->search_end_dt_tm_ind), protect
 DECLARE gdirectionflag = i4 WITH constant(request->direction_flag), protect
 DECLARE gdateflag = i4 WITH constant(request->date_flag), protect
 DECLARE gwheredatefield = c25 WITH noconstant(""), protect
 DECLARE gorderdatefield = c25 WITH noconstant(""), protect
 DECLARE geventstofetch = i4 WITH constant(request->events_to_fetch), protect
 DECLARE encntrlistsize = i4 WITH noconstant(size(request->encntr_id_list,5)), protect
 DECLARE encntrtypeclasssize = i4 WITH constant(size(request->encntr_type_class_cd_list,5)), protect
 DECLARE encntrtypesize = i4 WITH constant(size(request->encntr_type_cd_list,5)), protect
 DECLARE resultstatuslistsize = i4 WITH constant(size(request->result_status_list,5)), protect
 DECLARE resultstatusidx = i4 WITH noconstant(0), protect
 DECLARE performprsnllistsize = i4 WITH constant(size(request->perform_prsnl_list,5)), protect
 DECLARE performprsnlidx = i4 WITH noconstant(0), protect
 DECLARE thisdate = c8 WITH noconstant(""), protect
 DECLARE lastdate = c8 WITH noconstant(""), protect
 DECLARE replysize = i4 WITH noconstant(0), protect
 FREE RECORD daterange
 RECORD daterange(
   1 final_date = dq8
   1 start_date = dq8
   1 end_date = dq8
 )
 DECLARE inserteventcodes(null) = i4
 DECLARE insertencounterids(null) = i4
 DECLARE selectfinaldate(null) = null
 DECLARE determineadjustedenddate(null) = null
 DECLARE withinrange(null) = i4
 DECLARE buildselectexpression(null) = null
 DECLARE buildfromclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE buildstandarddetailclause(null) = null
 DECLARE buildorderbyclause(null) = null
 DECLARE buildorahints(null) = null
 DECLARE setupsearchdates(null) = null
 DECLARE createdaterangeclause(null) = vc
 DECLARE setupeventrowversionclause(null) = null
 DECLARE setupincludeexplodejoin(null) = null
 DECLARE setuplongtextjoin(null) = null
 DECLARE setupencntrtypeclassjoin(null) = null
 DECLARE setupresultstatusexpand(null) = null
 DECLARE setupperformprsnlexpand(null) = null
 DECLARE myparser(my_str=vc) = null
 DECLARE checkerrors(operation=vc) = null
 IF ( NOT (band(gquerymode,eall_sts)))
  SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 ENDIF
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
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
   SET reply->error_code = 1.0
   SET reply->error_msg = build("Invalid date_flag (",gdateflag,")")
   GO TO exit_script
 ENDCASE
 IF ((((request->search_start_dt_tm=0)) OR (gsearchstartdttmind=empty)) )
  IF ((request->direction_flag=edescending))
   SET request->search_start_dt_tm = max_date
  ELSE
   SET request->search_start_dt_tm = min_date
  ENDIF
 ENDIF
 IF ((((request->search_end_dt_tm=0)) OR (gsearchenddttmind=empty)) )
  IF ((request->direction_flag=edescending))
   SET request->search_end_dt_tm = min_date
  ELSE
   SET request->search_end_dt_tm = max_date
  ENDIF
 ENDIF
 SET daterange->start_date = request->search_start_dt_tm
 SET daterange->end_date = request->search_end_dt_tm
 CALL inserteventcodes(null)
 CALL insertencounterids(null)
 WHILE (cnt < geventstofetch
  AND withinrange(null)=true)
   CALL determineadjustedenddate(null)
   CALL buildselectexpression(null)
   CALL buildfromclause(null)
   CALL buildwhereclause(null)
   CALL buildorderbyclause(null)
   CALL buildstandarddetailclause(null)
   CALL parser(" with memsort ")
   CALL buildorahints(null)
   CALL parser(" go ")
   IF (gdirectionflag=eascending)
    SET daterange->start_date = cnvtlookahead("1,S",daterange->end_date)
   ELSE
    SET daterange->start_date = cnvtlookbehind("1,S",daterange->end_date)
   ENDIF
   SET daterange->end_date = request->search_end_dt_tm
 ENDWHILE
 SET stat_i4 = alterlist(reply->event_list,cnt)
 GO TO exit_script
 SUBROUTINE withinrange(null)
  IF (gdirectionflag=eascending)
   IF ((daterange->start_date <= daterange->end_date))
    RETURN(true)
   ENDIF
  ELSE
   IF ((daterange->start_date >= daterange->end_date))
    RETURN(true)
   ENDIF
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE insertencounterids(null)
   IF (encntrlistsize=0)
    RETURN(0)
   ENDIF
   IF ((request->encntrfilter=0))
    SET encntrlistsize += 1
    SET stat_i4 = alterlist(request->encntr_id_list,encntrlistsize)
    SET request->encntr_id_list[encntrlistsize].encntr_id = 0.0
   ENDIF
   RDB delete from encntr_id_gtmp where ( 1 = 1 )
   END ;Rdb
   DECLARE ec_nsize = i4 WITH protect, noconstant(getbatchsize(encntrlistsize,40))
   DECLARE ec_loop_cnt = i4 WITH protect, noconstant((padencounterarray(ec_nsize)/ ec_nsize))
   DECLARE ec_nstart = i4 WITH protect, noconstant(1)
   DECLARE encntrididx = i4 WITH protect, noconstant(1)
   DECLARE qual = i4 WITH protect, noconstant(0)
   WHILE (ec_loop_cnt > 0)
     SET encntrididx = 1
     INSERT  FROM encntr_id_gtmp etmp
      (etmp.encntr_id)(SELECT DISTINCT
       e.encntr_id
       FROM encounter e
       WHERE expand(encntrididx,ec_nstart,((ec_nstart+ ec_nsize) - 1),e.encntr_id,request->
        encntr_id_list[encntrididx].encntr_id))
      WITH nocounter
     ;end insert
     SET qual += curqual
     CALL checkforerrors("InsertEncounterIds")
     SET ec_nstart += ec_nsize
     SET ec_loop_cnt -= 1
   ENDWHILE
   RETURN(qual)
 END ;Subroutine
 SUBROUTINE inserteventcodes(null)
   DECLARE eventsetcd = f8 WITH noconstant(0.0), protect
   SET eventsetcd = request->event_set_cd_include_list[1].event_set_cd
   RDB delete from event_cd_gtmp where ( 1 = 1 )
   END ;Rdb
   DECLARE ec = i4 WITH protect, noconstant(0)
   DECLARE eventsetidx = i4 WITH protect, noconstant(0)
   DECLARE esexcludesize = i4 WITH noconstant(0), protect
   SET esexcludesize = size(request->event_set_cd_exclude_list,5)
   INSERT  FROM event_cd_gtmp
    (event_cd)(SELECT DISTINCT
     ex1.event_cd
     FROM v500_event_set_explode ex1,
      clinical_event ce
     WHERE ex1.event_set_cd=eventsetcd
      AND  NOT (ex1.event_cd IN (
     (SELECT DISTINCT
      ex2.event_cd
      FROM v500_event_set_explode ex2
      WHERE expand(eventsetidx,1,esexcludesize,ex2.event_set_cd,request->event_set_cd_exclude_list[
       eventsetidx].event_set_cd)
      WITH orahintcbo("USE_NL(ex2)"))))
      AND (ce.person_id=request->person_id)
      AND parser(createdaterangeclause(null))
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
      AND (ce.event_cd=(ex1.event_cd+ 0))
     WITH orahintcbo("LEADING(ex1)","USE_NL(ce ex1)","INDEX(ex1 XIE2V500_EVENT_SET_EXPLODE)",
       "INDEX(ce XIE9CLINICAL_EVENT)"))
    WITH nocounter
   ;end insert
   SET ec = curqual
   CALL checkforerrors("InsertEventCodes")
   IF (ec=0)
    GO TO exit_script
   ENDIF
   RETURN(ec)
 END ;Subroutine
 SUBROUTINE determineadjustedenddate(null)
   DECLARE orderbydirection = i4 WITH noconstant(0)
   DECLARE minmaxvalue = c8 WITH noconstant("")
   DECLARE dateformat = vc WITH noconstant("")
   DECLARE timeformat = i4 WITH noconstant(0)
   IF (gdirectionflag=eascending)
    SET orderbydirection = orderdir_ascend
    SET minmaxvalue = "max"
    SET dateformat = "DD-MMM-YYYY 23:59:59 ZZZ"
    SET timeformat = 235959
   ELSE
    SET orderbydirection = orderdir_desc
    SET minmaxvalue = "min"
    SET dateformat = "DD-MMM-YYYY 00:00:00 ZZZ"
    SET timeformat = 0
   ENDIF
   CALL parser(build(" select into 'nl:' end_date =",minmaxvalue,"(x.adjusted_end_date) "))
   CALL parser(" from ")
   CALL parser(build(" ((select adjusted_end_date =",gwheredatefield,", "))
   CALL parser(build("          dr = row_number() over(order by ORDERDIR(",gwheredatefield,", ",
     orderbydirection,")) "))
   CALL parser(" from  clinical_event ce ")
   CALL parser(" , event_cd_gtmp ect")
   CALL parser(" where ")
   CALL parser(" ect.event_cd = ce.event_cd and ")
   CALL setupsearchdates(null)
   CALL parser("  ce.person_id = request->person_id ")
   IF ((request->valid_from_dt_tm_ind=empty))
    CALL parser("  and ce.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ")
   ENDIF
   CALL parser(" with sqltype('dq8', 'i4') ")
   CALL parser(" , orahintcbo('LEADING(ect ce)', 'USE_NL(ect ce)', 'INDEX(ce XIE9CLINICAL_EVENT)')")
   CALL parser(" ) x) ")
   CALL parser(" where ")
   CALL parser(" x.dr between 1 and ")
   CALL parser(build(geventstofetch))
   CALL parser(" detail ")
   CALL parser("      dateRange->end_date = end_date ")
   CALL parser(" go ")
   IF (((curqual=0) OR ((daterange->end_date=null))) )
    GO TO exit_script
   ENDIF
   IF (curutc
    AND request->end_of_day_tz)
    SET daterange->end_date = cnvtdatetimeutc(datetimezoneformat(daterange->end_date,request->
      end_of_day_tz,dateformat),1,request->end_of_day_tz)
   ELSE
    SET daterange->end_date = cnvtdatetimeutc(datetimezoneformat(daterange->end_date,curtimezonedef,
      dateformat),0)
   ENDIF
   IF (gdirectionflag=eascending)
    IF ((daterange->end_date > request->search_end_dt_tm))
     SET daterange->end_date = request->search_end_dt_tm
    ENDIF
   ELSE
    IF ((daterange->end_date < request->search_end_dt_tm))
     SET daterange->end_date = request->search_end_dt_tm
    ENDIF
   ENDIF
 END ;Subroutine
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
   CALL parser(" clinical_event ce, ")
   CALL parser(" event_cd_gtmp ect, ")
   IF (encntrlistsize > 0)
    CALL parser(" encntr_id_gtmp eit, ")
   ENDIF
   CALL parser(" long_text lt ")
   IF (((encntrtypeclasssize) OR (encntrtypesize)) )
    CALL parser(" , encounter e ")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildwhereclause(null)
   CALL parser(" where ce.person_id = request->person_id and ")
   CALL parser(" ce.event_cd = ect.event_cd and ")
   IF (encntrlistsize > 0)
    CALL parser(" ce.encntr_id = eit.encntr_id and ")
   ENDIF
   CALL setupsearchdates(null)
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
   IF (request->encntr_financial_id)
    CALL parser(" ce.encntr_financial_id = request->encntr_financial_id and ")
   ENDIF
   CALL setupeventrowversionclause(null)
   IF (resultstatuslistsize)
    CALL setupresultstatusexpand(null)
   ENDIF
   IF (performprsnllistsize)
    CALL setupperformprsnlexpand(null)
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
    CALL parser(" expand( eventSetIncludeCnt, 1, eventSetIncludeSize, ex.event_set_cd,       ")
    CALL parser("         request->event_set_cd_include_list[eventSetIncludeCnt].event_set_cd ) ")
   ELSEIF (eventsetincludesize=1)
    CALL parser(" ex.event_set_cd = request->event_set_cd_include_list[1].event_set_cd ")
   ENDIF
 END ;Subroutine
 SUBROUTINE setuplongtextjoin(null)
   CALL parser(" and ce.modifier_long_text_id = lt.long_text_id ")
 END ;Subroutine
 SUBROUTINE setupencntrtypeclassjoin(null)
   CALL parser(" and ")
   IF (encntrtypeclasssize > 200)
    SET error_msg = build(" Exceeded encntr_type_class_cd_list limit of 200. ")
    GO TO exit_script
   ELSEIF (encntrtypeclasssize > 1)
    CALL parser(" expand( encntrTypeClassCnt, 1, encntrTypeClassSize, e.encntr_type_class_cd , ")
    CALL parser(
     "         request->encntr_type_class_cd_list[encntrTypeClassCnt].encntr_type_class_cd )   ")
   ELSEIF (encntrtypeclasssize=1)
    CALL parser(
     " e.encntr_type_class_cd = request->encntr_type_class_cd_list[1].encntr_type_class_cd ")
   ENDIF
   IF (encntrtypeclasssize > 0
    AND encntrtypesize > 0)
    CALL parser(" and ")
   ENDIF
   IF (encntrtypesize > 1)
    CALL parser(" expand( encntrTypeCnt, 1, encntrTypeSize, e.encntr_type_cd , ")
    CALL parser("         request->encntr_type_cd_list[encntrTypeCnt].encntr_type_cd )   ")
   ELSEIF (encntrtypesize=1)
    CALL parser(" e.encntr_type_cd = request->encntr_type_cd_list[1].encntr_type_cd ")
   ENDIF
   CALL parser(" and e.encntr_id = ce.encntr_id ")
   CALL parser(" and e.active_ind = 1 ")
 END ;Subroutine
 SUBROUTINE setupsearchdates(null)
   IF (gdirectionflag=eascending)
    CALL parser(gwheredatefield)
    CALL parser(" >= cnvtdatetimeutc(dateRange->start_date) and ")
    CALL parser(gwheredatefield)
    CALL parser(" <= cnvtdatetimeutc(dateRange->end_date) and ")
   ELSE
    CALL parser(gwheredatefield)
    CALL parser(" <= cnvtdatetimeutc(dateRange->start_date) and ")
    CALL parser(gwheredatefield)
    CALL parser(" >= cnvtdatetimeutc(dateRange->end_date) and ")
   ENDIF
 END ;Subroutine
 SUBROUTINE createdaterangeclause(null)
   DECLARE query = vc WITH private, noconstant("")
   IF (gdirectionflag=eascending)
    SET query = concat(gwheredatefield," >= cnvtdatetimeutc(dateRange->start_date) ")
    SET query = concat(query," and ",gwheredatefield," <= cnvtdatetimeutc(dateRange->end_date) ")
   ELSE
    SET query = concat(gwheredatefield," <= cnvtdatetimeutc(dateRange->start_date) ")
    SET query = concat(query," and ",gwheredatefield," >= cnvtdatetimeutc(dateRange->end_date) ")
   ENDIF
   RETURN(query)
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
   SET fieldname = "ce.result_status_cd"
   CALL parser(concat(" and expand (resultStatusIdx, 1, resultStatusListSize, ",fieldname,
     ", request->result_status_list[resultStatusIdx].result_status_cd)"))
  ELSE
   CALL parser(" and ce.result_status_cd = request->result_status_list[1].result_status_cd ")
  ENDIF
 END ;Subroutine
 SUBROUTINE setupperformprsnlexpand(null)
  DECLARE fieldname = vc WITH noconstant(""), protect
  IF (performprsnllistsize > 1)
   SET fieldname = "ce.performed_prsnl_id"
   CALL parser(concat(" and expand (performPrsnlIdx, 1, performPrsnlListSize, ",fieldname,
     ", request->perform_prsnl_list[performPrsnlIdx].perform_prsnl_id)"))
  ELSE
   CALL parser(" and ce.performed_prsnl_id = request->perform_prsnl_list[1].perform_prsnl_id")
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
  CALL parser(", orahintcbo('leading(ect ce eit)','USE_NL(ect ce)','USE_MERGE(eit)',")
  CALL parser("  'index(ce XIE9CLINICAL_EVENT)')")
 END ;Subroutine
 SUBROUTINE buildstandarddetailclause(null)
   CALL parser("  head ce.event_id  ")
   CALL parser("  bPopulateEvent = TRUE ")
   IF (geventstofetch)
    CALL parser(" if (cnt > gEventsToFetch) ")
    CALL parser("    if (curutc and request->end_of_day_tz)")
    CALL parser(build("   lastDate = datetimezoneformat( context->last_event_dt_tm, ",
      "request->end_of_day_tz, 'MMddyyyy;;D')"))
    CALL parser(build("   thisDate = datetimezoneformat(",gorderdatefield,
      ", request->end_of_day_tz, ","'MMddyyyy;;D')"))
    CALL parser("    else")
    CALL parser(build("   lastDate = datetimezoneformat( context->last_event_dt_tm, ",
      "CURTIMEZONEDEF, 'MMddyyyy;;D')"))
    CALL parser(build("   thisDate = datetimezoneformat(",gorderdatefield,", CURTIMEZONEDEF, ",
      "'MMddyyyy;;D')"))
    CALL parser("    endif")
    CALL parser("    if ( thisDate = lastDate)   ")
    CALL parser("         bPopulateEvent = TRUE ")
    CALL parser("    else ")
    CALL parser("         bPopulateEvent = FALSE ")
    CALL parser("    endif ")
    CALL parser(" endif ")
   ENDIF
   CALL parser(" if (bPopulateEvent = TRUE) ")
   CALL parser("  cnt = cnt + 1  ")
   CALL parser("  if ( mod(cnt,100) = 1 )                          ")
   CALL parser("    stat_i4 = alterlist( reply->event_list, cnt + 99 )  ")
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
   CALL parser(" reply->event_list[cnt].normalcy_cd = ce.normalcy_cd, ")
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
   CALL parser(" reply->event_list[cnt].person_id = ce.person_id, ")
   CALL parser(" reply->event_list[cnt].nomen_string_flag = ce.nomen_string_flag, ")
   CALL parser(" reply->event_list[cnt].ce_dynamic_label_id = ce.ce_dynamic_label_id, ")
   CALL parser(" reply->event_list[cnt].updt_id = ce.updt_id ")
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
    CALL parser(" reply->event_list[cnt].updt_task = ce.updt_task, ")
    CALL parser(" reply->event_list[cnt].updt_task_ind = updt_task_ind, ")
    CALL parser(" reply->event_list[cnt].updt_cnt = ce.updt_cnt, ")
    CALL parser(" reply->event_list[cnt].updt_cnt_ind = updt_cnt_ind, ")
    CALL parser(" reply->event_list[cnt].updt_applctx = ce.updt_applctx, ")
    CALL parser(" reply->event_list[cnt].updt_applctx_ind = updt_applctx_ind, ")
    CALL parser(" reply->event_list[cnt].event_tag_set_flag = ce.event_tag_set_flag ")
    CALL parser(" reply->event_list[cnt].device_free_txt = ce.device_free_txt ")
   ENDIF
   CALL parser(build(" context->last_event_dt_tm = ",gorderdatefield))
   CALL parser(" context->last_event_dt_tm_ind = 0 ")
   CALL parser(" endif ")
 END ;Subroutine
 SUBROUTINE (getbatchsize(listsize=i4,maxsize=i4) =i4)
   DECLARE batchsize = i4 WITH noconstant
   SET batchsize = ((listsize+ 19) - mod((listsize - 1),20))
   IF (batchsize > maxsize)
    SET batchsize = maxsize
   ENDIF
   RETURN(batchsize)
 END ;Subroutine
 SUBROUTINE (padencounterarray(nsize=i4) =i4)
   DECLARE orig_size = i4 WITH protect, constant(size(request->encntr_id_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   SET new_size = (loop_cnt * nsize)
   IF (new_size > orig_size)
    SET stat_i4 = alterlist(request->encntr_id_list,new_size)
    FOR (i = (orig_size+ 1) TO new_size)
      SET request->encntr_id_list[i].encntr_id = request->encntr_id_list[orig_size].encntr_id
    ENDFOR
   ENDIF
   RETURN(new_size)
 END ;Subroutine
 SUBROUTINE (checkforerrors(errorlocation=vc) =null)
   SET error_code = error(error_msg,0)
   SET reply->error_code = error_code
   IF (error_code > 0)
    SET reply->error_msg = error_msg
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET stat_i4 = alterlist(reply->event_list,cnt)
 SET error_code = error(error_msg,0)
 IF (error_code > 0)
  SET reply->error_code = error_code
  SET reply->error_msg = error_msg
 ENDIF
END GO
