CREATE PROGRAM ce_get_paging_range:dba
 DECLARE initglobals(null) = null
 DECLARE insertencounterids(null) = i4
 DECLARE fetcheventids(null) = null
 DECLARE insertaccessioneventcodes(null) = i4
 DECLARE inserteventcodes(null) = i4
 DECLARE creep_up(null) = i2
 DECLARE generateselectce(null) = vc
 DECLARE get_row_sort_order(null) = vc
 DECLARE perform_prsnl_list(null) = vc
 DECLARE result_status_list(null) = vc
 DECLARE published_cond(null) = vc
 DECLARE begin_end_criteria(null) = vc
 DECLARE createdaterangeclause(null) = vc
 DECLARE generate_select_accession(null) = vc
 DECLARE pad_event_set_array(nsize=i4) = i4
 DECLARE setupeventrowversionclause(null) = vc
 DECLARE generatedetailstructure(null) = vc
 DECLARE executemodifierlongtextquery(null) = null
 DECLARE stat_i4 = i4 WITH protect, noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 DECLARE descending = i2 WITH protect, constant(1)
 DECLARE ascending = i2 WITH protect, constant(0)
 DECLARE nl = vc WITH protect, constant(concat(char(10),char(13)))
 DECLARE cr = vc WITH protect, constant(char(13))
 DECLARE page_size = i4 WITH protect, constant((request->page_event_count+ 1))
 DECLARE g_startdate = q8 WITH protect
 DECLARE g_enddate = q8 WITH protect
 DECLARE g_datefield = vc WITH protect, noconstant(" ")
 DECLARE g_resultcount = i4 WITH protect, noconstant(0)
 DECLARE g_hasmoreresults = i2 WITH protect, noconstant(0)
 DECLARE g_resultstofind = i4 WITH protect, noconstant(0)
 DECLARE g_sortdirection = i2 WITH protect, noconstant(0)
 DECLARE g_ranksortdirection = i2 WITH protect, noconstant(0)
 DECLARE g_creepdirection = i2 WITH protect, noconstant(0)
 DECLARE last_event_dt_tm = q8 WITH protect
 DECLARE last_event_cd = q8 WITH protect
 DECLARE last_encntr_id = q8 WITH protect
 DECLARE last_event_id = q8 WITH protect
 DECLARE event_month_ndx = i2 WITH protect, noconstant(0)
 DECLARE event_month_count = i2 WITH protect, noconstant(0)
 DECLARE event_day_ndx = i2 WITH protect, noconstant(0)
 DECLARE event_day_count = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE long_text_size = i4 WITH protect, noconstant(0)
 DECLARE empty = i2 WITH constant(1)
 DECLARE eall_sts = i4 WITH constant(32)
 DECLARE max_date = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE iec_index_use = vc WITH protect, noconstant(" ")
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 IF (record_status_draft <= 0)
  SET error_msg = "-E-UAR Error retrieving value 'DRAFT' from code set 48."
  GO TO exit_script
 ENDIF
 IF ( NOT (band(request->query_mode,eall_sts)))
  SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
  IF (record_status_deleted <= 0)
   SET error_msg = "-E-UAR Error retrieving value 'DELETED' from code set 48."
   GO TO exit_script
  ENDIF
 ENDIF
 RECORD event_months(
   1 qual[*]
     2 start_date = dq8
     2 end_date = dq8
     2 count = f8
 )
 RECORD event_days(
   1 qual[*]
     2 start_date = dq8
     2 end_date = dq8
     2 count = f8
 )
 FREE SET modifier
 RECORD modifier(
   1 long_text_id_list[*]
     2 long_text_id = f8
     2 reply_index = i2
 )
 RDB delete from encntr_id_gtmp where ( 1 = 1 )
 END ;Rdb
 RDB delete from event_cd_gtmp where ( 1 = 1 )
 END ;Rdb
 CALL initglobals(null)
 CALL insertencounterids(null)
 SET g_startdate = request->search_begin_dt_tm
 SET g_enddate = request->search_end_dt_tm
 CALL inserteventcodes(null)
 SET g_resultstofind = page_size
 IF (size(request->accession_nbr) > 0)
  CALL fetcheventids(null)
 ELSE
  CALL analyze_date_range(g_startdate,g_enddate,0)
  IF (event_month_count)
   SET g_hasmoreresults = 1
   WHILE (g_hasmoreresults
    AND g_resultstofind > 0)
    SET g_hasmoreresults = creep_up(null)
    IF (g_hasmoreresults)
     CALL fetcheventids(null)
     SET g_resultstofind = (page_size - g_resultcount)
     IF (g_creepdirection < 0)
      SET g_startdate = cnvtlookbehind("1,S",g_enddate)
     ELSE
      SET g_startdate = cnvtlookahead("1,S",g_enddate)
     ENDIF
    ENDIF
   ENDWHILE
  ENDIF
 ENDIF
 CALL checkforerrors("End of Script")
 GO TO exit_script
 SUBROUTINE insertencounterids(null)
   DECLARE ec_nsize = i4 WITH protect, noconstant(getbatchsize(size(request->encntr_list,5),40))
   DECLARE ec_loop_cnt = i4 WITH protect, noconstant((padencounterarray(ec_nsize)/ ec_nsize))
   DECLARE ec_nstart = i4 WITH protect, noconstant(1)
   DECLARE encntrididx = i4 WITH protect, noconstant(1)
   WHILE (ec_loop_cnt > 0)
     SET encntrididx = 1
     INSERT  FROM encntr_id_gtmp ect
      (ect.encntr_id)(SELECT DISTINCT
       e.encntr_id
       FROM encounter e
       WHERE expand(encntrididx,ec_nstart,((ec_nstart+ ec_nsize) - 1),e.encntr_id,request->
        encntr_list[encntrididx].encntr_id))
      WITH nocounter
     ;end insert
     CALL checkforerrors("InsertEncounterIds")
     SET ec_nstart += ec_nsize
     SET ec_loop_cnt -= 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (padencounterarray(nsize=i4) =i4)
   DECLARE orig_size = i4 WITH protect, constant(size(request->encntr_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   SET new_size = (loop_cnt * nsize)
   IF (new_size > orig_size)
    SET stat_i4 = alterlist(request->encntr_list,new_size)
    FOR (i = (orig_size+ 1) TO new_size)
      SET request->encntr_list[i].encntr_id = request->encntr_list[orig_size].encntr_id
    ENDFOR
   ENDIF
   RETURN(new_size)
 END ;Subroutine
 SUBROUTINE padeventsetarray(nsize)
   DECLARE orig_size = i4 WITH protect, constant(size(request->event_set_list,5))
   DECLARE loop_cnt = i4
   DECLARE new_size = i4
   DECLARE nstart = i4 WITH protect, noconstant(1)
   SET loop_cnt = ceil((cnvtreal(orig_size)/ nsize))
   SET new_size = (loop_cnt * nsize)
   IF (new_size > orig_size)
    SET stat_i4 = alterlist(request->event_set_list,new_size)
    FOR (i = (orig_size+ 1) TO new_size)
      SET request->event_set_list[i].event_set_cd = request->event_set_list[orig_size].event_set_cd
    ENDFOR
   ENDIF
   RETURN(new_size)
 END ;Subroutine
 SUBROUTINE inserteventcodes(null)
   DECLARE ec = i4 WITH protect, noconstant(0)
   DECLARE eventsetidx = i4 WITH protect, noconstant(0)
   DECLARE es_loop_cnt = i2 WITH noconstant(1), protect
   DECLARE es_nstart = i2 WITH noconstant(0), protect
   DECLARE es_nsize = i2 WITH noconstant(20), protect
   SET es_nsize = getbatchsize(size(request->event_set_list,5),100)
   SET es_loop_cnt = (padeventsetarray(es_nsize)/ es_nsize)
   SET es_nstart = 1
   WHILE (es_loop_cnt > 0)
     INSERT  FROM event_cd_gtmp
      (event_cd)(SELECT DISTINCT
       ex.event_cd
       FROM clinical_event ce,
        v500_event_set_explode ex
       WHERE expand(eventsetidx,es_nstart,((es_nstart+ es_nsize) - 1),ex.event_set_cd,request->
        event_set_list[eventsetidx].event_set_cd)
        AND (ce.person_id=request->person_id)
        AND parser(createdaterangeclause(null))
        AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
        AND (ce.event_cd=(ex.event_cd+ 0))
       WITH orahintcbo("LEADING(ex)","USE_NL(ex ce)","INDEX(ex XIE2V500_EVENT_SET_EXPLODE)",value(
          iec_index_use)))
      WITH nocounter
     ;end insert
     SET es_loop_cnt -= 1
     SET es_nstart += es_nsize
     SET ec += curqual
     CALL checkforerrors("InsertEventCodes")
   ENDWHILE
   IF (ec=0)
    GO TO exit_script
   ENDIF
   RETURN(ec)
 END ;Subroutine
 SUBROUTINE (analyze_date_range(sd=q8,ed=q8,countbyday=i2) =null)
   DECLARE date_filter = vc WITH protect, noconstant("")
   DECLARE day_string = vc WITH protect, noconstant("MM")
   DECLARE event_count = i4 WITH protect, noconstant(0)
   DECLARE date_range_clause = vc WITH protect, noconstant("")
   IF (sd > ed)
    SET date_range_clause = concat("ce.",g_datefield," between cnvtdatetimeutc(ed)",
     "  and cnvtdatetimeutc(sd)")
   ELSE
    SET date_range_clause = concat("ce.",g_datefield," between cnvtdatetimeutc(sd)",
     "  and cnvtdatetimeutc(ed)")
   ENDIF
   IF (countbyday)
    SET day_string = "J"
   ENDIF
   SET date_filter = concat("trunc(ce.",g_datefield,", '",day_string,"')")
   SELECT
    IF (g_creepdirection < 0)
     ORDER BY a.event_dt DESC
    ELSE
     ORDER BY a.event_dt
    ENDIF
    INTO "nl"
    a.*
    FROM (
     (
     (SELECT
      event_dt = sqlpassthru(date_filter), event_cnt = count(*)
      FROM clinical_event ce,
       event_cd_gtmp ect
      WHERE (ce.person_id=request->person_id)
       AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
       AND ce.event_cd=ect.event_cd
       AND parser(date_range_clause)
      GROUP BY sqlpassthru(date_filter)
      WITH sqltype("dq8","i4"), orahintcbo("LEADING(ect)","USE_NL(ect ce)",value(iec_index_use))))
     a)
    WHERE a.event_cnt > 0
    HEAD REPORT
     groups_found = 0
     IF (countbyday)
      daymonthflag = "D"
     ELSE
      daymonthflag = "M"
     ENDIF
     event_count = 0
    HEAD a.event_dt
     event_count += 1
     IF (countbyday=0)
      IF (mod(event_count,12)=1)
       stat_i4 = alterlist(event_months->qual,(event_count+ 11))
      ENDIF
      IF (g_creepdirection < 0)
       event_months->qual[event_count].start_date = cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a
          .event_dt,1),daymonthflag,"E","E"),2), event_months->qual[event_count].end_date =
       cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a.event_dt,1),daymonthflag,"B","B"),2)
      ELSE
       event_months->qual[event_count].start_date = cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a
          .event_dt,1),daymonthflag,"B","B"),2), event_months->qual[event_count].end_date =
       cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a.event_dt,1),daymonthflag,"E","E"),2)
      ENDIF
     ELSE
      IF (mod(event_count,7)=1)
       stat_i4 = alterlist(event_days->qual,(event_count+ 6))
      ENDIF
      IF (g_creepdirection < 0)
       event_days->qual[event_count].start_date = cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a
          .event_dt,1),daymonthflag,"E","E"),2), event_days->qual[event_count].end_date =
       cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a.event_dt,1),daymonthflag,"B","B"),2)
      ELSE
       event_days->qual[event_count].start_date = cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a
          .event_dt,1),daymonthflag,"B","B"),2), event_days->qual[event_count].end_date =
       cnvtdatetimeutc(datetimefind(cnvtdatetimeutc(a.event_dt,1),daymonthflag,"E","E"),2)
      ENDIF
     ENDIF
    DETAIL
     IF (countbyday=0)
      event_months->qual[event_count].count += a.event_cnt
     ELSE
      event_days->qual[event_count].count += a.event_cnt
     ENDIF
    FOOT REPORT
     IF (countbyday=0)
      stat_i4 = alterlist(event_months->qual,event_count), event_month_count = event_count
     ELSE
      stat_i4 = alterlist(event_days->qual,event_count), event_day_count = event_count
     ENDIF
    WITH nocounter
   ;end select
   CALL checkforerrors("analyze_date_range")
   IF (event_count > 0)
    IF (countbyday=0)
     IF (g_creepdirection < 0)
      IF ((event_months->qual[1].start_date > sd))
       SET event_months->qual[1].start_date = sd
      ENDIF
      IF ((event_months->qual[event_count].end_date < ed))
       SET event_months->qual[event_count].end_date = ed
      ENDIF
     ELSE
      IF ((event_months->qual[1].start_date < sd))
       SET event_months->qual[1].start_date = sd
      ENDIF
      IF ((event_months->qual[event_count].end_date > ed))
       SET event_months->qual[event_count].end_date = ed
      ENDIF
     ENDIF
    ELSE
     IF (g_creepdirection < 0)
      IF ((event_days->qual[1].start_date > sd))
       SET event_days->qual[1].start_date = sd
      ENDIF
      IF ((event_days->qual[event_count].end_date < ed))
       SET event_days->qual[event_count].end_date = ed
      ENDIF
     ELSE
      IF ((event_days->qual[1].start_date < sd))
       SET event_days->qual[1].start_date = sd
      ENDIF
      IF ((event_days->qual[event_count].end_date > ed))
       SET event_days->qual[event_count].end_date = ed
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE creep_up(null)
   DECLARE result_count = i4 WITH protect, noconstant(0)
   DECLARE max_events = i4 WITH protect, constant(ceil((request->page_event_count * 1.25)))
   WHILE (((event_month_ndx < event_month_count) OR (event_day_ndx < event_day_count))
    AND (result_count <= request->page_event_count))
     IF (event_day_ndx < event_day_count)
      SET event_day_ndx += 1
      IF (result_count=0)
       SET g_startdate = cnvtdatetime(event_days->qual[event_day_ndx].start_date)
      ENDIF
      SET result_count += event_days->qual[event_day_ndx].count
      SET g_enddate = cnvtdatetime(event_days->qual[event_day_ndx].end_date)
     ELSE
      SET event_day_ndx = 0
      SET event_day_count = 0
      SET event_month_ndx += 1
      IF (result_count=0)
       SET g_startdate = cnvtdatetime(event_months->qual[event_month_ndx].start_date)
      ENDIF
      IF (((((result_count+ event_months->qual[event_month_ndx].count) < max_events)) OR ((
      event_months->qual[event_month_ndx].count < 50))) )
       SET result_count += event_months->qual[event_month_ndx].count
       SET g_enddate = cnvtdatetime(event_months->qual[event_month_ndx].end_date)
      ELSE
       CALL analyze_date_range(event_months->qual[event_month_ndx].start_date,event_months->qual[
        event_month_ndx].end_date,1)
      ENDIF
     ENDIF
   ENDWHILE
   IF (result_count > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE initglobals(null)
   SET stat_i4 = alterlist(reply->event_list,page_size)
   IF ((request->date_flag=2))
    SET g_datefield = "clinsig_updt_dt_tm"
    SET iec_index_use = "INDEX(ce XIE24CLINICAL_EVENT)"
   ELSE
    SET g_datefield = "event_end_dt_tm"
    SET iec_index_use = "INDEX(ce XIE9CLINICAL_EVENT)"
   ENDIF
   IF ((request->search_begin_dt_tm > request->search_end_dt_tm))
    SET g_sortdirection = descending
    SET g_ranksortdirection = descending
    SET g_creepdirection = - (1)
   ELSE
    SET g_sortdirection = ascending
    SET g_ranksortdirection = ascending
    SET g_creepdirection = 1
   ENDIF
   IF (request->is_continuation)
    IF ((request->paging_mode=0))
     SET request->search_begin_dt_tm = request->continuation_context.last_event_dt_tm
     IF (g_sortdirection=descending)
      SET g_creepdirection = - (1)
     ELSE
      SET g_creepdirection = 1
     ENDIF
     SET last_event_dt_tm = request->continuation_context.last_event_dt_tm
     SET last_event_cd = request->continuation_context.last_event_cd
     SET last_encntr_id = request->continuation_context.last_encntr_id
     SET last_event_id = request->continuation_context.last_event_id
    ELSEIF ((request->paging_mode=1))
     SET request->search_end_dt_tm = request->search_begin_dt_tm
     SET request->search_begin_dt_tm = request->continuation_context.first_event_dt_tm
     IF (g_sortdirection=ascending)
      SET g_ranksortdirection = descending
      SET g_sortdirection = descending
      SET g_creepdirection = - (1)
     ELSE
      SET g_ranksortdirection = ascending
      SET g_sortdirection = ascending
      SET g_creepdirection = 1
     ENDIF
     SET last_event_dt_tm = request->continuation_context.first_event_dt_tm
     SET last_event_cd = request->continuation_context.first_event_cd
     SET last_encntr_id = request->continuation_context.first_encntr_id
     SET last_event_id = request->continuation_context.first_event_id
    ELSEIF ((request->paging_mode=2))
     SET request->search_begin_dt_tm = request->continuation_context.first_event_dt_tm
     IF (g_sortdirection=descending)
      SET g_creepdirection = - (1)
     ELSE
      SET g_creepdirection = 1
     ENDIF
     SET last_event_dt_tm = request->continuation_context.first_event_dt_tm
     SET last_event_cd = request->continuation_context.first_event_cd
     SET last_encntr_id = request->continuation_context.first_encntr_id
     SET last_event_id = request->continuation_context.first_event_id
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE fetcheventids(null)
   DECLARE query = vc WITH private, noconstant("")
   DECLARE batch_size = i4 WITH protect, noconstant(0)
   DECLARE perform_prsnl_idx = i4 WITH protect, noconstant(1)
   DECLARE result_status_idx = i4 WITH protect, noconstant(1)
   DECLARE event_list_size = i4 WITH protect, noconstant(0)
   DECLARE long_text_size = i4 WITH protect, noconstant(0)
   SET batch_size = g_resultstofind
   IF (size(request->accession_nbr) > 0)
    SET query = generate_select_accession(null)
   ELSE
    SET query = generateselectce(null)
   ENDIF
   CALL parser(query)
   IF (size(reply->event_list) > 0)
    SET event_list_size = size(reply->event_list,5)
    FOR (i = 1 TO event_list_size)
      IF ((reply->event_list[i].modifier_long_text_id > 0))
       SET long_text_size += 1
       SET stat_i4 = alterlist(modifier->long_text_id_list,long_text_size)
       SET modifier->long_text_id_list[long_text_size].long_text_id = reply->event_list[i].
       modifier_long_text_id
       SET modifier->long_text_id_list[long_text_size].reply_index = i
      ENDIF
    ENDFOR
   ENDIF
   CALL executemodifierlongtextquery(null)
   CALL checkforerrors("FetchEventIds")
 END ;Subroutine
 SUBROUTINE generateselectce(null)
   DECLARE query = vc WITH private
   DECLARE encounter_count = i4 WITH protect, constant(size(request->encntr_list,5))
   SET query = concat("select distinct into 'nl:'",nl,"    a.event_end_dt_tm, ",nl,
    "    a.clinsig_updt_dt_tm, ",
    nl,get_fields_order("a")," ,",nl,"    valid_until_dt_tm_ind = nullind(a.valid_until_dt_tm), ",
    nl,"    view_level_ind = nullind(a.view_level), ",nl,
    "    clinsig_updt_dt_tm_ind = nullind(a.clinsig_updt_dt_tm), ",nl,
    "    valid_from_dt_tm_ind = nullind(a.valid_from_dt_tm), ",nl,
    "    event_start_dt_tm_ind = nullind(a.event_start_dt_tm), ",nl,
    "    event_end_dt_tm_ind = nullind(a.event_end_dt_tm), ",
    nl,"    publish_flag_ind = nullind(a.publish_flag), ",nl,
    "    subtable_bit_map_ind = nullind(a.subtable_bit_map), ",nl,
    "    verified_dt_tm_ind = nullind(a.verified_dt_tm), ",nl,
    "    performed_dt_tm_ind = nullind(a.performed_dt_tm), ",nl,
    "    expiration_dt_tm_ind = nullind(a.expiration_dt_tm), ",
    nl,"    updt_dt_tm_ind = nullind(a.updt_dt_tm), ",nl,"    updt_task_ind = nullind(a.updt_task), ",
    nl,
    "    updt_cnt_ind = nullind(a.updt_cnt), ",nl,"    updt_applctx_ind = nullind(a.updt_applctx) ",
    nl,"from ",
    nl,"    ((select pn_rank = dense_rank () over (",get_row_sort_order(null),"), ",nl,
    "             ce.",g_datefield,",",nl,get_fields_order("ce"),
    ",",nl)
   IF ((request->date_flag=2))
    SET query = concat(query,"			 ce.event_end_dt_tm ",nl)
   ELSE
    SET query = concat(query,"			 ce.clinsig_updt_dt_tm ",nl)
   ENDIF
   SET query = concat(query,"      from ",nl)
   IF (encounter_count)
    SET query = concat(query,"           encntr_id_gtmp ect2, ",nl)
   ENDIF
   SET query = concat(query,"           clinical_event ce, ",nl,"           event_cd_gtmp ect ",nl,
    "      where ce.person_id = request->person_id ",nl,perform_prsnl_list(null),result_status_list(
     null),"        and ce.view_level > request->view_level",
    nl,setupeventrowversionclause(null),published_cond(null),begin_end_criteria(null),
    "        and ce.record_status_cd != RECORD_STATUS_DRAFT  ",
    nl,"        and ce.event_cd = ect.event_cd ",nl)
   IF (record_status_deleted)
    SET query = concat(query,"		and ce.record_status_cd != RECORD_STATUS_DELETED ",nl)
   ENDIF
   IF (encounter_count)
    SET query = concat(query,"        and ce.encntr_id = ect2.encntr_id",nl)
   ENDIF
   SET query = concat(query,
"       with sqltype ('f8','dq8', 'f8', 'f8', 'dq8', 'i4', 'f8', 'i4', 'f8', 'vc100', 'f8', 'f8', 'f8', 'c20', 'f8', 'vc100\
', 'f8', 'dq8', 'f8', 'f8', 'vc255', 'i2', 'c40', 'f8', 'dq8', 'i4', 'i4', 'f8', 'f8', 'f8', 'i2', 'i2', 'f8', 'f8', 'f8',\
 'f8', 'f8', 'f8', 'i4', 'vc255', 'vc255', 'f8', 'f8', 'dq8', 'i4', 'f8', 'dq8', 'i4', 'f8', 'c20', 'c20', 'c20', 'c20', '\
dq8', 'dq8', 'f8', 'i4', 'i4', 'f8', 'i4', 'f8', 'f8', 'c40', 'f8', 'f8', 'f8', 'dq8', 'i2','f8', 'vc255', 'i4', 'vc2000',\
 'f8', 'i4', 'dq8'), orahintcbo('LEADING(ect ce)','USE_NL(ect ce)','USE_MERGE(ect2)','\
",iec_index_use,"')) a ) ",nl,
    "where a.pn_rank <= batch_size  ",nl,get_where_sort_order("a"),"detail ",nl,
    "      g_resultCount = g_resultCount + 1 ",nl,generatedetailstructure(null),nl,
    " WITH RDBCBOPLUSZERO ",
    nl)
   SET query = concat(query,"go")
   RETURN(query)
 END ;Subroutine
 SUBROUTINE generate_select_accession(null)
   DECLARE query = vc WITH private, noconstant("")
   DECLARE encounter_count = i4 WITH protect, constant(size(request->encntr_list,5))
   SET query = concat("select distinct into 'nl:'",nl,"    a.event_end_dt_tm, ",nl,
    "    a.clinsig_updt_dt_tm, ",
    nl,get_fields_order("a")," ,",nl,"    valid_until_dt_tm_ind = nullind(a.valid_until_dt_tm), ",
    nl,"    view_level_ind = nullind(a.view_level), ",nl,
    "    clinsig_updt_dt_tm_ind = nullind(a.clinsig_updt_dt_tm), ",nl,
    "    valid_from_dt_tm_ind = nullind(a.valid_from_dt_tm), ",nl,
    "    event_start_dt_tm_ind = nullind(a.event_start_dt_tm), ",nl,
    "    event_end_dt_tm_ind = nullind(a.event_end_dt_tm), ",
    nl,"    publish_flag_ind = nullind(a.publish_flag), ",nl,
    "    subtable_bit_map_ind = nullind(a.subtable_bit_map), ",nl,
    "    verified_dt_tm_ind = nullind(a.verified_dt_tm), ",nl,
    "    performed_dt_tm_ind = nullind(a.performed_dt_tm), ",nl,
    "    expiration_dt_tm_ind = nullind(a.expiration_dt_tm), ",
    nl,"    updt_dt_tm_ind = nullind(a.updt_dt_tm), ",nl,"    updt_task_ind = nullind(a.updt_task), ",
    nl,
    "    updt_cnt_ind = nullind(a.updt_cnt), ",nl,"    updt_applctx_ind = nullind(a.updt_applctx) ",
    nl,"from ",
    nl,"    ((select pn_rank = dense_rank () over (",get_row_sort_order(null),"), ",nl,
    "             ce.",g_datefield,",",nl,get_fields_order("ce"),
    ",",nl)
   IF ((request->date_flag=2))
    SET query = concat(query,"			 ce.event_end_dt_tm ",nl)
   ELSE
    SET query = concat(query,"			 ce.clinsig_updt_dt_tm ",nl)
   ENDIF
   SET query = concat(query,"      from ",nl,"           clinical_event ce ",nl,
    "      where ce.accession_nbr = request->accession_nbr ",nl,
    "        and ce.person_id = request->person_id ",nl,perform_prsnl_list(null),
    result_status_list(null),"        and ce.view_level > request->view_level",nl,
    setupeventrowversionclause(null),published_cond(null),
    begin_end_criteria(null),"        and ce.record_status_cd != RECORD_STATUS_DRAFT ",nl,
    "        and exists (select 'x' from event_cd_gtmp ect ",nl,
    "                    where ect.event_cd = ce.event_cd ",nl,
    "                      and rownum < 2 )",nl)
   IF (record_status_deleted)
    SET query = concat(query,"		and ce.record_status_cd != RECORD_STATUS_DELETED ",nl)
   ENDIF
   IF (encounter_count)
    SET query = concat(query,"        and exists (select 'x' from encntr_id_gtmp ect2 ",nl,
     "                    where ect2.encntr_id = ce.encntr_id ",nl,
     "                      and rownum < 2) ",nl)
   ENDIF
   SET query = concat(query,
"       with sqltype ('f8','dq8', 'f8', 'f8', 'dq8', 'i4', 'f8', 'i4', 'f8', 'vc100', 'f8', 'f8', 'f8', 'c20', 'f8', 'vc100\
', 'f8', 'dq8', 'f8', 'f8', 'vc255', 'i2', 'c40', 'f8', 'dq8', 'i4', 'i4', 'f8', 'f8', 'f8', 'i2', 'i2', 'f8', 'f8', 'f8',\
 'f8', 'f8', 'f8', 'i4', 'vc255', 'vc255', 'f8', 'f8', 'dq8', 'i4', 'f8', 'dq8', 'i4', 'f8', 'c20', 'c20', 'c20', 'c20', '\
dq8', 'dq8', 'f8', 'i4', 'i4', 'f8', 'i4', 'f8', 'f8', 'c40', 'f8', 'f8', 'f8', 'dq8', 'i2','f8', 'vc255', 'i4', 'vc2000',\
 'f8', 'i4', 'dq8'), orahintcbo('INDEX(ce XIE6CLINICAL_EVENT)')) a ) \
",nl,"where a.pn_rank <= batch_size  ",nl,
    get_where_sort_order("a"),"detail ",nl,"      g_resultCount = g_resultCount + 1 ",nl,
    generatedetailstructure(null),nl," WITH RDBCBOPLUSZERO ",nl)
   SET query = concat(query,"go")
   RETURN(query)
 END ;Subroutine
 SUBROUTINE get_row_sort_order(null)
   DECLARE direction = vc WITH protect
   DECLARE order_str = vc WITH protect
   IF (g_ranksortdirection=descending)
    SET direction = " desc "
   ELSE
    SET direction = " "
   ENDIF
   SET order_str = concat("order by ce.",g_datefield," ",direction," ,ce.event_cd ",
    direction," ,ce.encntr_id ",direction," ,ce.event_id ",direction,
    nl)
   RETURN(order_str)
 END ;Subroutine
 SUBROUTINE (get_where_sort_order(tablename=vc) =vc)
   DECLARE direction = vc WITH protect
   DECLARE order_str = vc WITH protect
   IF (g_sortdirection=descending)
    SET direction = " desc "
   ELSE
    SET direction = " "
   ENDIF
   SET order_str = concat("order by ",tablename,".",g_datefield,direction,
    " ,",tablename,".event_cd ",direction," ,",
    tablename,".encntr_id ",direction," ,",tablename,
    ".event_id ",direction,nl)
   RETURN(order_str)
 END ;Subroutine
 SUBROUTINE perform_prsnl_list(null)
   DECLARE query = vc WITH private, noconstant(cr)
   IF (size(request->perform_prsnl_list,5))
    SET query = concat(
     "        and (expand (perform_prsnl_idx, 1, size (request->perform_prsnl_list, 5), ",nl,
     "                     ce.performed_prsnl_id+0, request->perform_prsnl_list[perform_prsnl_idx]->perform_prsnl_id)) ",
     nl)
   ENDIF
   RETURN(query)
 END ;Subroutine
 SUBROUTINE result_status_list(null)
   DECLARE query = vc WITH private, noconstant(cr)
   IF (size(request->result_status_list,5))
    SET query = concat(
     "        and (expand (result_status_idx, 1, size (request->result_status_list, 5), ",nl,
     "                     ce.result_status_cd, request->result_status_list[result_status_idx]->result_status_cd)) ",
     nl)
   ENDIF
   RETURN(query)
 END ;Subroutine
 SUBROUTINE published_cond(null)
   DECLARE query = vc WITH private, noconstant(cr)
   IF ((request->non_publish_flag=0))
    SET query = concat("        and ce.publish_flag = 1",nl)
   ELSEIF ((request->non_publish_flag=1))
    SET query = cr
   ELSEIF ((request->non_publish_flag=2))
    SET query = nl("        and ce.publish_flag != 0",nl)
   ENDIF
   RETURN(query)
 END ;Subroutine
 SUBROUTINE view_level_cond(null)
   DECLARE query = vc WITH private, noconstant(cr)
   SET query = concat("        and ce.view_level > request->view_level",nl)
   RETURN(query)
 END ;Subroutine
 SUBROUTINE setupeventrowversionclause(null)
   DECLARE query = vc WITH protect
   SET query = concat("        and ce.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ",nl)
   RETURN(query)
 END ;Subroutine
 SUBROUTINE begin_end_criteria(null)
   DECLARE temp_date = q8 WITH protect
   DECLARE query = vc WITH private, noconstant(cr)
   DECLARE comp1 = vc WITH protect
   DECLARE comp2 = vc WITH protect
   SET query = concat("and ",createdaterangeclause(null))
   IF (request->is_continuation)
    IF ((g_creepdirection=- (1)))
     SET comp1 = "<"
     IF ((request->paging_mode != 2))
      SET comp2 = "<"
     ELSE
      SET comp2 = "<="
     ENDIF
    ELSE
     SET comp1 = ">"
     IF ((request->paging_mode != 2))
      SET comp2 = ">"
     ELSE
      SET comp2 = ">="
     ENDIF
    ENDIF
    SET query = concat(query,"        and (    (ce.",g_datefield,
     " = cnvtdatetimeutc(last_event_dt_tm) and",nl,
     "                  ce.event_cd = ",build(last_event_cd)," and",nl,
     "                  ce.encntr_id = ",
     build(last_encntr_id)," and",nl,"                  ce.event_id ",comp2,
     build(last_event_id),")",nl,"             or  (ce.",g_datefield,
     "  = cnvtdatetimeutc(last_event_dt_tm) and",nl,"                  ce.event_cd = ",build(
      last_event_cd)," and",
     nl,"                  ce.encntr_id ",comp1,build(last_encntr_id),")",
     nl,"             or  (ce.",g_datefield,"  = cnvtdatetimeutc(last_event_dt_tm) and",nl,
     "                  ce.event_cd ",comp1,build(last_event_cd),")",nl,
     "             or  (ce.",g_datefield," ",comp1," cnvtdatetimeutc(last_event_dt_tm)))",
     nl)
   ENDIF
   RETURN(query)
 END ;Subroutine
 SUBROUTINE createdaterangeclause(null)
   DECLARE query = vc WITH private, noconstant(cr)
   DECLARE comp1 = vc WITH protect
   DECLARE comp2 = vc WITH protect
   IF (g_startdate > g_enddate)
    SET query = concat("ce.",g_datefield," between cnvtdatetimeutc(g_endDate)",
     "  and cnvtdatetimeutc(g_startDate)",nl)
   ELSE
    SET query = concat("ce.",g_datefield," between cnvtdatetimeutc(g_startDate)",
     "  and cnvtdatetimeutc(g_endDate)",nl)
   ENDIF
   RETURN(query)
 END ;Subroutine
 SUBROUTINE (getbatchsize(listsize=i4,maxsize=i4) =i4)
   DECLARE batchsize = i4 WITH noconstant
   SET batchsize = ((listsize+ 19) - mod((listsize - 1),20))
   IF (batchsize > maxsize)
    SET batchsize = maxsize
   ENDIF
   RETURN(batchsize)
 END ;Subroutine
 SUBROUTINE (get_fields_order(tablename=vc) =vc)
   DECLARE order_str = vc WITH protect
   SET order_str = concat(tablename,".clinical_event_id "," ,",tablename,".event_id ",
    " ,",tablename,".valid_until_dt_tm "," ,",tablename,
    ".view_level "," ,",tablename,".order_id "," ,",
    tablename,".order_action_sequence "," ,",tablename,".catalog_cd ",
    " ,",tablename,".series_ref_nbr "," ,",tablename,
    ".person_id "," ,",tablename,".encntr_id "," ,",
    tablename,".encntr_financial_id "," ,",tablename,".accession_nbr ",
    " ,",tablename,".contributor_system_cd "," ,",tablename,
    ".reference_nbr "," ,",tablename,".parent_event_id "," ,",
    tablename,".valid_from_dt_tm "," ,",tablename,".event_class_cd ",
    " ,",tablename,".event_cd "," ,",tablename,
    ".event_tag "," ,",tablename,".event_tag_set_flag "," ,",
    tablename,".collating_seq "," ,",tablename,".event_reltn_cd ",
    " ,",tablename,".event_start_dt_tm "," ,",tablename,
    ".event_start_tz "," ,",tablename,".event_end_tz "," ,",
    tablename,".task_assay_cd "," ,",tablename,".record_status_cd ",
    " ,",tablename,".result_status_cd "," ,",tablename,
    ".authentic_flag "," ,",tablename,".publish_flag "," ,",
    tablename,".qc_review_cd "," ,",tablename,".normalcy_cd ",
    " ,",tablename,".normalcy_method_cd "," ,",tablename,
    ".inquire_security_cd "," ,",tablename,".resource_group_cd "," ,",
    tablename,".resource_cd "," ,",tablename,".subtable_bit_map ",
    " ,",tablename,".event_title_text "," ,",tablename,
    ".result_val "," ,",tablename,".result_units_cd "," ,",
    tablename,".result_time_units_cd "," ,",tablename,".verified_dt_tm ",
    " ,",tablename,".verified_tz "," ,",tablename,
    ".verified_prsnl_id "," ,",tablename,".performed_dt_tm "," ,",
    tablename,".performed_tz "," ,",tablename,".performed_prsnl_id ",
    " ,",tablename,".normal_low "," ,",tablename,
    ".normal_high "," ,",tablename,".critical_low "," ,",
    tablename,".critical_high "," ,",tablename,".expiration_dt_tm ",
    " ,",tablename,".updt_dt_tm "," ,",tablename,
    ".updt_id "," ,",tablename,".updt_task "," ,",
    tablename,".updt_cnt "," ,",tablename,".updt_applctx ",
    " ,",tablename,".note_importance_bit_map "," ,",tablename,
    ".entry_mode_cd "," ,",tablename,".source_cd "," ,",
    tablename,".clinical_seq "," ,",tablename,".task_assay_version_nbr ",
    " ,",tablename,".modifier_long_text_id "," ,",tablename,
    ".src_event_id "," ,",tablename,".src_clinsig_updt_dt_tm "," ,",
    tablename,".nomen_string_flag "," ,",tablename,".ce_dynamic_label_id ",
    " ,",tablename,".device_free_txt "," ,",tablename,
    ".trait_bit_map "," ,",tablename,".normal_ref_range_txt "," ,",
    tablename,".ce_grouping_id "," ,",tablename,".subtable_bit_map2 ",
    nl)
   RETURN(order_str)
 END ;Subroutine
 SUBROUTINE generatedetailstructure(null)
   DECLARE replyfields = vc WITH protect
   SET replyfields = concat(
    "      reply->event_list[g_resultCount]->clinical_event_id = a.clinical_event_id ",nl,
    "      reply->event_list[g_resultCount]->event_id = a.event_id ",nl,
    "      reply->event_list[g_resultCount]->valid_until_dt_tm = a.valid_until_dt_tm ",
    nl,"      reply->event_list[g_resultCount]->valid_until_dt_tm_ind = valid_until_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->view_level = a.view_level ",nl,
    "      reply->event_list[g_resultCount]->view_level_ind = view_level_ind ",nl,
    "      reply->event_list[g_resultCount]->clinsig_updt_dt_tm = a.clinsig_updt_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->clinsig_updt_dt_tm_ind = clinsig_updt_dt_tm_ind ",
    nl,"      reply->event_list[g_resultCount]->order_id = a.order_id ",nl,
    "      reply->event_list[g_resultCount]->order_action_sequence = a.order_action_sequence ",nl,
    "      reply->event_list[g_resultCount]->catalog_cd = a.catalog_cd ",nl,
    "      reply->event_list[g_resultCount]->series_ref_nbr = a.series_ref_nbr ",nl,
    "      reply->event_list[g_resultCount]->person_id = a.person_id ",
    nl,"      reply->event_list[g_resultCount]->encntr_id = a.encntr_id ",nl,
    "      reply->event_list[g_resultCount]->encntr_financial_id = a.encntr_financial_id ",nl,
    "      reply->event_list[g_resultCount]->accession_nbr = a.accession_nbr ",nl,
    "      reply->event_list[g_resultCount]->contributor_system_cd = a.contributor_system_cd ",nl,
    "      reply->event_list[g_resultCount]->reference_nbr = a.reference_nbr ",
    nl,"      reply->event_list[g_resultCount]->parent_event_id = a.parent_event_id ",nl,
    "      reply->event_list[g_resultCount]->valid_from_dt_tm = a.valid_from_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->valid_from_dt_tm_ind = valid_from_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->event_class_cd = a.event_class_cd ",nl,
    "      reply->event_list[g_resultCount]->event_cd = a.event_cd ",
    nl,"      reply->event_list[g_resultCount]->event_tag = a.event_tag ",nl,
    "      reply->event_list[g_resultCount]->event_tag_set_flag = a.event_tag_set_flag ",nl,
    "      reply->event_list[g_resultCount]->collating_seq = a.collating_seq ",nl,
    "      reply->event_list[g_resultCount]->event_reltn_cd = a.event_reltn_cd ",nl,
    "      reply->event_list[g_resultCount]->event_start_dt_tm = a.event_start_dt_tm ",
    nl,"      reply->event_list[g_resultCount]->event_start_dt_tm_ind = event_start_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->event_start_tz = a.event_start_tz ",nl,
    "      reply->event_list[g_resultCount]->event_end_dt_tm = a.event_end_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->event_end_dt_tm_ind = event_end_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->event_end_tz = a.event_end_tz ",
    nl,"      reply->event_list[g_resultCount]->task_assay_cd = a.task_assay_cd ",nl,
    "      reply->event_list[g_resultCount]->record_status_cd = a.record_status_cd ",nl,
    "      reply->event_list[g_resultCount]->result_status_cd = a.result_status_cd ",nl,
    "      reply->event_list[g_resultCount]->authentic_flag = a.authentic_flag ",nl,
    "      reply->event_list[g_resultCount]->publish_flag = a.publish_flag ",
    nl,"      reply->event_list[g_resultCount]->publish_flag_ind = publish_flag_ind ",nl,
    "      reply->event_list[g_resultCount]->qc_review_cd = a.qc_review_cd ",nl,
    "      reply->event_list[g_resultCount]->normalcy_cd = a.normalcy_cd ",nl,
    "      reply->event_list[g_resultCount]->normalcy_method_cd = a.normalcy_method_cd ",nl,
    "      reply->event_list[g_resultCount]->inquire_security_cd = a.inquire_security_cd ",
    nl,"      reply->event_list[g_resultCount]->resource_group_cd = a.resource_group_cd ",nl,
    "      reply->event_list[g_resultCount]->resource_cd = a.resource_cd ",nl,
    "      reply->event_list[g_resultCount]->subtable_bit_map = a.subtable_bit_map ",nl,
    "      reply->event_list[g_resultCount]->subtable_bit_map_ind = subtable_bit_map_ind ",nl,
    "      reply->event_list[g_resultCount]->event_title_text = a.event_title_text ",
    nl,"      reply->event_list[g_resultCount]->result_val = a.result_val ",nl,
    "      reply->event_list[g_resultCount]->result_units_cd = a.result_units_cd ",nl,
    "      reply->event_list[g_resultCount]->result_time_units_cd = a.result_time_units_cd ",nl,
    "      reply->event_list[g_resultCount]->verified_dt_tm = a.verified_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->verified_dt_tm_ind = verified_dt_tm_ind ",
    nl,"      reply->event_list[g_resultCount]->verified_tz = a.verified_tz ",nl,
    "      reply->event_list[g_resultCount]->verified_prsnl_id = a.verified_prsnl_id ",nl,
    "      reply->event_list[g_resultCount]->performed_dt_tm = a.performed_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->performed_dt_tm_ind =performed_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->performed_tz = a.performed_tz ",
    nl,"      reply->event_list[g_resultCount]->performed_prsnl_id = a.performed_prsnl_id ",nl,
    "      reply->event_list[g_resultCount]->normal_low = a.normal_low ",nl,
    "      reply->event_list[g_resultCount]->normal_high = a.normal_high ",nl,
    "      reply->event_list[g_resultCount]->critical_low = a.critical_low ",nl,
    "      reply->event_list[g_resultCount]->critical_high = a.critical_high ",
    nl,"      reply->event_list[g_resultCount]->expiration_dt_tm = a.expiration_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->expiration_dt_tm_ind = expiration_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->updt_dt_tm = a.updt_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->updt_dt_tm_ind = updt_dt_tm_ind ",nl,
    "      reply->event_list[g_resultCount]->updt_id = a.updt_id ",
    nl,"      reply->event_list[g_resultCount]->updt_task = a.updt_task ",nl,
    "      reply->event_list[g_resultCount]->updt_task_ind = updt_task_ind ",nl,
    "      reply->event_list[g_resultCount]->updt_cnt = a.updt_cnt ",nl,
    "      reply->event_list[g_resultCount]->updt_cnt_ind = updt_cnt_ind ",nl,
    "      reply->event_list[g_resultCount]->updt_applctx_ind = updt_applctx_ind ",
    nl,"      reply->event_list[g_resultCount]->note_importance_bit_map = a.note_importance_bit_map ",
    nl,"      reply->event_list[g_resultCount]->entry_mode_cd = a.entry_mode_cd ",nl,
    "      reply->event_list[g_resultCount]->source_cd = a.source_cd ",nl,
    "      reply->event_list[g_resultCount]->clinical_seq = a.clinical_seq ",nl,
    "      reply->event_list[g_resultCount]->task_assay_version_nbr = a.task_assay_version_nbr ",
    nl,"      reply->event_list[g_resultCount]->modifier_long_text_id = a.modifier_long_text_id ",nl,
    "      reply->event_list[g_resultCount]->src_event_id = a.src_event_id ",nl,
    "      reply->event_list[g_resultCount]->src_clinsig_updt_dt_tm = a.src_clinsig_updt_dt_tm ",nl,
    "      reply->event_list[g_resultCount]->nomen_string_flag = a.nomen_string_flag ",nl,
    "      reply->event_list[g_resultCount]->ce_dynamic_label_id = a.ce_dynamic_label_id ",
    nl,"      reply->event_list[g_resultCount]->device_free_txt = a.device_free_txt ",nl,
    "      reply->event_list[g_resultCount]->trait_bit_map = a.trait_bit_map ",nl,
    "      stat_vc = assign(validate(reply->event_list[g_resultCount]->normal_ref_range_txt,",'"','"',
    "),","a.normal_ref_range_txt) ",
    nl,
    "      stat_f8 = assign(validate(reply->event_list[g_resultCount]->ce_grouping_id, 0), a.ce_grouping_id) ",
    nl,
    "      stat_i4 = assign(validate(reply->event_list[g_resultCount]->subtable_bit_map2, 0), a.subtable_bit_map2) ",
    nl)
   RETURN(replyfields)
 END ;Subroutine
 SUBROUTINE executemodifierlongtextquery(null)
   DECLARE long_text_size = i2 WITH protect, noconstant(size(modifier->long_text_id_list,5))
   IF (long_text_size=0)
    RETURN
   ENDIF
   DECLARE batch_size = i2 WITH protect, noconstant(getbatchsize(long_text_size,100))
   DECLARE lloopcnt = i2 WITH protect, noconstant(ceil((cnvtreal(long_text_size)/ batch_size)))
   DECLARE lnewsize = i2 WITH protect, noconstant((lloopcnt * batch_size))
   DECLARE ltcount = i2 WITH protect, noconstant(0)
   DECLARE index_var = i2 WITH protect, noconstant(0)
   SET stat_i4 = alterlist(modifier->long_text_id_list,lnewsize)
   FOR (i = (long_text_size+ 1) TO lnewsize)
     SET modifier->long_text_id_list[i].long_text_id = modifier->long_text_id_list[long_text_size].
     long_text_id
   ENDFOR
   SET g_nstart = 1
   SELECT DISTINCT INTO "nl:"
    lt.long_text
    FROM (dummyt d  WITH seq = value(lloopcnt)),
     long_text lt
    PLAN (d
     WHERE initarray(g_nstart,evaluate(d.seq,1,1,(g_nstart+ batch_size))))
     JOIN (lt
     WHERE expand(ltcount,g_nstart,(g_nstart+ (batch_size - 1)),lt.long_text_id,modifier->
      long_text_id_list[ltcount].long_text_id))
    ORDER BY lt.long_text_id
    HEAD REPORT
     mod_index = 0, rep_index = 0
    HEAD lt.long_text_id
     mod_index = locateval(index_var,1,long_text_size,lt.long_text_id,modifier->long_text_id_list[
      index_var].long_text_id)
     WHILE (mod_index > 0)
       rep_index = modifier->long_text_id_list[mod_index].reply_index, reply->event_list[rep_index].
       modifier_long_text = lt.long_text, mod_index = locateval(index_var,(mod_index+ 1),
        long_text_size,lt.long_text_id,modifier->long_text_id_list[index_var].long_text_id)
     ENDWHILE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkforerrors(errorlocation=vc) =null)
   SET error_code = error(error_msg,0)
   SET reply->error_code = error_code
   IF (error_code > 0)
    SET reply->error_msg = error_msg
    CALL echo(concat("*******",errorlocation,"*********"))
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (g_resultcount=page_size)
  SET reply->more_ind = 1
  SET stat_i4 = alterlist(reply->event_list,(g_resultcount - 1))
 ELSE
  SET reply->more_ind = 0
  SET stat_i4 = alterlist(reply->event_list,g_resultcount)
 ENDIF
 SET stat_i4 = alterlist(event_months->qual,0)
 SET stat_i4 = alterlist(event_days->qual,0)
 IF ((reply->error_code=0))
  SET error_code = error(error_msg,0)
  SET reply->error_code = error_code
  SET reply->error_msg = error_msg
 ENDIF
END GO
