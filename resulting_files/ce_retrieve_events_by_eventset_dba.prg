CREATE PROGRAM ce_retrieve_events_by_eventset:dba
 DECLARE insertencounterids(null) = i4
 DECLARE inserteventcodes(null) = i4
 DECLARE eventsetcd = f8 WITH noconstant(0.0)
 DECLARE euseexplode = i4 WITH protect, constant(1)
 DECLARE euseperson = i4 WITH protect, constant(2)
 DECLARE euseexplodemult = i4 WITH protect, constant(4)
 DECLARE event_batch_size = i4 WITH protect, constant(200)
 DECLARE prsnl_batch_size = i4 WITH protect, constant(20)
 DECLARE eallstats = i4 WITH protect, constant(32)
 DECLARE record_status_deleted = f8 WITH protect, noconstant(0.0)
 DECLARE record_status_draft = f8 WITH protect, noconstant(0.0)
 DECLARE useencntrtmptable = i2 WITH protect, noconstant(0)
 DECLARE filterpublishflagstring = vc WITH protect, noconstant("1 = 1")
 DECLARE filterencounterstring = vc WITH protect, noconstant("1 = 1")
 DECLARE filterdatestring = vc WITH protect, noconstant("1 = 1")
 DECLARE startclause = vc WITH protect, noconstant("1 = 1")
 DECLARE endclause = vc WITH protect, noconstant("1 = 1")
 DECLARE s_error_msg = vc WITH protect, noconstant("")
 DECLARE s_error_code = i4 WITH protect, noconstant(0)
 DECLARE encntrsize = i4 WITH protect, noconstant(0)
 DECLARE max_date = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00")), protect
 DECLARE min_date = q8 WITH constant(cnvtdatetime("01-JAN-1800 00:00:00")), protect
 DECLARE eascending = i4 WITH constant(1), protect
 DECLARE stat_i4 = i4 WITH protect, noconstant(0)
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 SET s_error_msg = fillstring(132," ")
 SET s_error_code = 0
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 SET stat_i4 = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 IF (size(request->event_set_cd_include_list,5) != 1)
  SET reply->error_code = 1.0
  SET reply->error_msg = "the event_set_cd_list_ext is not supported for this query"
  GO TO exit_script
 ELSE
  SET eventsetcd = request->event_set_cd_include_list[1].event_set_cd
 ENDIF
 IF (band(request->query_mode,eallstats))
  SET recordstatuscd = 0.0
 ELSE
  SET recordstatuscd = record_status_deleted
 ENDIF
 IF ((request->non_publish_flag=0))
  SET filterpublishflagstring = "ce.publish_flag = 1"
 ELSEIF ((request->non_publish_flag=2))
  SET filterpublishflagstring = "ce.publish_flag != 0"
 ENDIF
 SET encntrsize = size(request->encntr_id_list,5)
 IF ((request->encntrfilter=0))
  IF (encntrsize > 0)
   SET encntrsize += 1
   SET stat_i4 = alterlist(request->encntr_id_list,encntrsize)
   SET request->encntr_id_list[encntrsize].encntr_id = 0.0
  ENDIF
 ENDIF
 IF (encntrsize > 0)
  RDB delete from encntr_id_gtmp where ( 1 = 1 )
  END ;Rdb
  CALL insertencounterids(null)
  SET filterencounterstring = "ce.encntr_id in (select eit.encntr_id from encntr_id_gtmp eit )"
 ENDIF
 IF ((request->direction_flag=eascending))
  IF ((request->search_start_dt_tm=0))
   SET request->search_start_dt_tm = min_date
  ENDIF
  IF ((request->search_end_dt_tm=0))
   SET request->search_end_dt_tm = max_date
  ENDIF
  SET startclause = "ce.event_end_dt_tm >= cnvtdatetimeutc(request->search_start_dt_tm)"
  SET endclause = "and ce.event_end_dt_tm <= cnvtdatetimeutc(request->search_end_dt_tm)"
 ELSE
  IF ((request->search_start_dt_tm=0))
   SET request->search_start_dt_tm = max_date
  ENDIF
  IF ((request->search_end_dt_tm=0))
   SET request->search_end_dt_tm = min_date
  ENDIF
  SET startclause = "ce.event_end_dt_tm <= cnvtdatetimeutc(request->search_start_dt_tm)"
  SET endclause = "and ce.event_end_dt_tm >= cnvtdatetimeutc(request->search_end_dt_tm)"
 ENDIF
 SET filterdatestring = concat(startclause,endclause)
 RDB delete from event_cd_gtmp where ( 1 = 1 )
 END ;Rdb
 CALL inserteventcodes(null)
 SELECT INTO "nl:"
  nullind_ce_event_end_dt_tm = nullind(ce.event_end_dt_tm), nullind_ce_performed_dt_tm = nullind(ce
   .performed_dt_tm), nullind_ce_valid_from_dt_tm = nullind(ce.valid_from_dt_tm),
  nullind_ce_valid_until_dt_tm = nullind(ce.valid_until_dt_tm), nullind_ce_updt_dt_tm = nullind(ce
   .updt_dt_tm), nullind_ce_clinsig_updt_dt_tm = nullind(ce.clinsig_updt_dt_tm)
  FROM clinical_event ce,
   long_text lt,
   event_cd_gtmp ect
  PLAN (ect)
   JOIN (ce
   WHERE ce.event_cd=ect.event_cd
    AND  NOT (ce.record_status_cd IN (recordstatuscd, record_status_draft))
    AND (ce.view_level > request->view_level)
    AND (ce.person_id=request->person_id)
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
    AND parser(filterpublishflagstring)
    AND parser(filterdatestring)
    AND parser(filterencounterstring))
   JOIN (lt
   WHERE ce.modifier_long_text_id=lt.long_text_id)
  ORDER BY ce.event_end_dt_tm DESC, ce.clinical_event_id DESC
  HEAD REPORT
   ce_batched_size = 0, cep_batched_size = 0, kk = 0,
   jj = 0
  HEAD ce.clinical_event_id
   kk += 1
   IF (kk > ce_batched_size)
    ce_batched_size += event_batch_size, stat_i4 = alterlist(reply->event_list,ce_batched_size)
   ENDIF
   reply->event_list[kk].clinical_event_id = ce.clinical_event_id, reply->event_list[kk].event_id =
   ce.event_id, reply->event_list[kk].view_level = ce.view_level,
   reply->event_list[kk].encntr_id = ce.encntr_id, reply->event_list[kk].order_id = ce.order_id,
   reply->event_list[kk].catalog_cd = ce.catalog_cd,
   reply->event_list[kk].parent_event_id = ce.parent_event_id, reply->event_list[kk].event_class_cd
    = ce.event_class_cd, reply->event_list[kk].event_cd = ce.event_cd,
   reply->event_list[kk].event_tag = ce.event_tag, reply->event_list[kk].event_end_dt_tm = ce
   .event_end_dt_tm, reply->event_list[kk].event_end_dt_tm_ind = nullind_ce_event_end_dt_tm,
   reply->event_list[kk].task_assay_cd = ce.task_assay_cd, reply->event_list[kk].result_status_cd =
   ce.result_status_cd, reply->event_list[kk].publish_flag = ce.publish_flag,
   reply->event_list[kk].normalcy_cd = ce.normalcy_cd, reply->event_list[kk].subtable_bit_map = ce
   .subtable_bit_map, reply->event_list[kk].event_title_text = ce.event_title_text,
   reply->event_list[kk].result_val = ce.result_val, reply->event_list[kk].result_units_cd = ce
   .result_units_cd, reply->event_list[kk].performed_dt_tm = ce.performed_dt_tm,
   reply->event_list[kk].performed_dt_tm_ind = nullind_ce_performed_dt_tm, reply->event_list[kk].
   performed_prsnl_id = ce.performed_prsnl_id, reply->event_list[kk].normal_low = ce.normal_low,
   reply->event_list[kk].normal_high = ce.normal_high, reply->event_list[kk].reference_nbr = ce
   .reference_nbr, reply->event_list[kk].contributor_system_cd = ce.contributor_system_cd,
   reply->event_list[kk].valid_from_dt_tm = ce.valid_from_dt_tm, reply->event_list[kk].
   valid_from_dt_tm_ind = nullind_ce_valid_from_dt_tm, reply->event_list[kk].valid_until_dt_tm = ce
   .valid_until_dt_tm,
   reply->event_list[kk].valid_until_dt_tm_ind = nullind_ce_valid_until_dt_tm, reply->event_list[kk].
   note_importance_bit_map = ce.note_importance_bit_map, reply->event_list[kk].updt_id = ce.updt_id,
   reply->event_list[kk].updt_dt_tm = ce.updt_dt_tm, reply->event_list[kk].updt_dt_tm_ind =
   nullind_ce_updt_dt_tm, reply->event_list[kk].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm,
   reply->event_list[kk].clinsig_updt_dt_tm_ind = nullind_ce_clinsig_updt_dt_tm, reply->event_list[kk
   ].collating_seq = ce.collating_seq, reply->event_list[kk].order_action_sequence = ce
   .order_action_sequence,
   reply->event_list[kk].entry_mode_cd = ce.entry_mode_cd, reply->event_list[kk].source_cd = ce
   .source_cd, reply->event_list[kk].clinical_seq = ce.clinical_seq,
   reply->event_list[kk].event_end_tz = ce.event_end_tz, reply->event_list[kk].performed_tz = ce
   .performed_tz, reply->event_list[kk].task_assay_version_nbr = ce.task_assay_version_nbr
   IF (ce.modifier_long_text_id > 0)
    reply->event_list[kk].modifier_long_text = lt.long_text
   ENDIF
   reply->event_list[kk].modifier_long_text_id = ce.modifier_long_text_id, reply->event_list[kk].
   src_event_id = ce.src_event_id, reply->event_list[kk].src_clinsig_updt_dt_tm = ce
   .src_clinsig_updt_dt_tm,
   reply->event_list[kk].person_id = ce.person_id, reply->event_list[kk].nomen_string_flag = ce
   .nomen_string_flag, reply->event_list[kk].ce_dynamic_label_id = ce.ce_dynamic_label_id,
   reply->event_list[kk].trait_bit_map = ce.trait_bit_map, stat_vc = assign(validate(reply->
     event_list[kk].normal_ref_range_txt,""),ce.normal_ref_range_txt), stat_f8 = assign(validate(
     reply->event_list[kk].ce_grouping_id,0),ce.ce_grouping_id),
   stat_i4 = assign(validate(reply->event_list[kk].subtable_bit_map2,0),ce.subtable_bit_map2)
  FOOT  ce.clinical_event_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->event_list,kk)
  WITH orahintcbo("use_nl(ect ce)","leading(ect ce)","index(ce XIE9CLINICAL_EVENT)")
 ;end select
 SET s_error_code = error(s_error_msg,0)
 SET reply->error_code = s_error_code
 SET reply->error_msg = s_error_msg
 SUBROUTINE insertencounterids(null)
   DECLARE ec_nsize = i4 WITH protect, noconstant(getbatchsize(size(request->encntr_id_list,5),40))
   DECLARE ec_loop_cnt = i4 WITH protect, noconstant((padencounterarray(ec_nsize)/ ec_nsize))
   DECLARE ec_nstart = i4 WITH protect, noconstant(1)
   DECLARE encntrididx = i4 WITH protect, noconstant(1)
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
     CALL checkforerrors("InsertEncounterIds")
     SET ec_nstart += ec_nsize
     SET ec_loop_cnt -= 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (getbatchsize(listsize=i4,maxsize=i4) =i4)
   DECLARE batchsize = i4 WITH noconstant
   SET batchsize = ((listsize+ 19) - mod((listsize - 1),20))
   IF (batchsize > maxsize)
    SET batchsize = maxsize
   ENDIF
   RETURN(batchsize)
 END ;Subroutine
 SUBROUTINE (checkforerrors(errorlocation=vc) =null)
   SET s_error_code = error(s_error_msg,0)
   SET reply->error_code = s_error_code
   IF (s_error_code > 0)
    SET reply->error_msg = s_error_msg
    GO TO exit_script
   ENDIF
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
 SUBROUTINE inserteventcodes(null)
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
       eventsetidx].event_set_cd))))
      AND (ce.person_id=request->person_id)
      AND parser(filterdatestring)
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
      AND (ce.event_cd=(ex1.event_cd+ 0))
     WITH orahintcbo("LEADING(ex1)","USE_NL(ce ex1 ex2)","INDEX(ex1 XIE2V500_EVENT_SET_EXPLODE)",
       "INDEX(ex2 XIE2V500_EVENT_SET_EXPLODE)","INDEX(ce XIE9CLINICAL_EVENT)"))
    WITH nocounter
   ;end insert
   SET ec = curqual
   CALL checkforerrors("InsertEventCodes")
   IF (ec=0)
    GO TO exit_script
   ENDIF
   RETURN(ec)
 END ;Subroutine
#exit_script
END GO
