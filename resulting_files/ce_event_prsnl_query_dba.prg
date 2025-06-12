CREATE PROGRAM ce_event_prsnl_query:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SET edigital_signature_mode = 1073741824
 SET esrv_not_del = 2
 DECLARE action_status_deleted = f8 WITH constant(uar_get_code_by("MEANING",103,"DELETED"))
 DECLARE action_status_completed = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE name_type_current = f8 WITH constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 SET max_date = cnvtdatetime("31-DEC-2100 00:00:00")
 DECLARE not_empty = i2
 DECLARE empty = i2
 SET not_empty = 0
 SET empty = 1
 DECLARE buildcursorone(null) = i2
 DECLARE buildcursortwo(null) = i2
 DECLARE buildcursorthree(null) = i2
 DECLARE buildcursorfour(null) = i2
 DECLARE setupstandarddetailclause(null) = i2
 DECLARE setupcursorextradetailclause(null) = i2
 DECLARE setupprsnlrowversionclause(null) = i2
 DECLARE setupeventrowversionclause(null) = i2
 DECLARE setupblobrowversionclause(null) = i2
 DECLARE setupactionstatuscdflags(null) = i2
 DECLARE setupactionstatuscdfilter(null) = i2
 DECLARE setupselectfields(null) = i2
 DECLARE fetchblobresultdata(null) = i2
 DECLARE fetcheventsetcode(null) = f8
 SET bdigitalsignaturemode = band(request->query_mode,edigital_signature_mode)
 SET bsrvnotdeletemode = band(request->query_mode,esrv_not_del)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE list_index = i4 WITH noconstant(0)
 DECLARE bactionstatuscd = i4 WITH noconstant(false)
 DECLARE bactionstatuscdcompl = i4 WITH noconstant(false)
 DECLARE actionstatuslistcount = i4 WITH noconstant(0)
 DECLARE actionprsnlgroupind = i2 WITH constant(validate(request->action_prsnl_group_id))
 DECLARE event_set_cd = f8 WITH constant(fetcheventsetcode(null))
 IF ((context->query_type=1))
  SET breturn = buildcursorone(null)
 ELSEIF ((context->query_type=2))
  SET breturn = buildcursortwo(null)
 ELSEIF ((context->query_type=3))
  SET breturn = buildcursorthree(null)
 ELSEIF ((context->query_type >= 4))
  SET breturn = setupactionstatuscdflags(null)
  SET breturn = buildcursorfour(null)
 ENDIF
 SET stat = alterlist(reply->reply_list,cnt)
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 GO TO exit_script
 SUBROUTINE buildcursorone(null)
   CALL parser("  select into 'nl:'  ")
   CALL parser("  ep.event_prsnl_id  ")
   CALL parser("  from           ")
   CALL parser("  ce_event_prsnl ep  ")
   CALL parser("  where          ")
   CALL parser("  ep.event_prsnl_id = request->event_prsnl_id and  ")
   SET breturn = setupprsnlrowversionclause(null)
   SET breturn = setupstandarddetailclause(null)
   CALL parser("with nocounter go")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE buildcursortwo(null)
   DECLARE eventidlistcnt = i4 WITH noconstant(0)
   DECLARE eventidlistsize = i4 WITH constant(size(request->event_id_list,5))
   CALL parser("  select into 'nl:'  ")
   CALL parser("  ep.event_prsnl_id  ")
   CALL parser("  from           ")
   CALL parser("  ce_event_prsnl ep  ")
   CALL parser("  where          ")
   IF ((request->event_id != 0))
    CALL parser("  ep.event_id = request->event_id  ")
   ELSE
    CALL parser("   expand( eventIdListCnt, 1, eventIdListSize, ep.event_id, ")
    CALL parser("               request->event_id_list[eventIdListCnt].event_id ) ")
   ENDIF
   IF (request->action_prsnl_id)
    CALL parser("  and ep.action_prsnl_id = request->action_prsnl_id ")
   ENDIF
   IF (actionprsnlgroupind)
    IF (request->action_prsnl_group_id)
     CALL parser("  and ep.action_prsnl_group_id = request->action_prsnl_group_id ")
    ENDIF
   ENDIF
   SET breturn = setupactionstatuscdfilter(null)
   IF (request->action_type_cd)
    CALL parser(" and ep.action_type_cd = request->action_type_cd ")
   ENDIF
   IF (request->long_text_id)
    CALL parser(" and ep.long_text_id = request->long_text_id ")
   ENDIF
   CALL parser(" and ")
   SET breturn = setupprsnlrowversionclause(null)
   CALL parser(" order by ep.action_type_cd ")
   SET breturn = setupstandarddetailclause(null)
   CALL parser(" with nocounter go ")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE buildcursorthree(null)
   CALL parser(" select distinct into 'nl:'  ")
   SET breturn = setupselectfields(null)
   CALL parser("  from               ")
   IF (event_set_cd)
    CALL parser(" v500_event_set_explode ese, ")
   ENDIF
   CALL parser(" clinical_event ce, ")
   CALL parser(" ce_event_prsnl ep ")
   CALL parser(" where ep.person_id = request->person_id  ")
   IF (request->action_prsnl_id)
    CALL parser("  and ep.action_prsnl_id = request->action_prsnl_id ")
   ENDIF
   IF (actionprsnlgroupind)
    IF (request->action_prsnl_group_id)
     CALL parser("  and ep.action_prsnl_group_id = request->action_prsnl_group_id ")
    ENDIF
   ENDIF
   IF ( NOT (context->null_action_dt_tm_ind))
    CALL parser(" and (ep.action_dt_tm is null or (")
   ELSE
    CALL parser(" and (( ")
   ENDIF
   CALL parser("ep.action_dt_tm ")
   IF (request->direction_flag)
    CALL parser(" >= ")
   ELSE
    CALL parser(" <= ")
   ENDIF
   CALL parser(" cnvtdatetime(request->search_start_dt_tm) ")
   IF ((request->search_end_dt_tm_ind=not_empty))
    CALL parser(" and ep.action_dt_tm ")
    IF (request->direction_flag)
     CALL parser(" <= ")
    ELSE
     CALL parser(" >= ")
    ENDIF
    CALL parser(" cnvtdatetime(request->search_end_dt_tm) ))")
   ELSE
    CALL parser("))")
   ENDIF
   SET breturn = setupactionstatuscdfilter(null)
   IF (request->action_type_cd)
    CALL parser(" and ep.action_type_cd = request->action_type_cd ")
   ENDIF
   IF (request->long_text_id)
    CALL parser(" and ep.long_text_id = request->long_text_id ")
   ENDIF
   CALL parser(" and ")
   SET breturn = setupprsnlrowversionclause(null)
   CALL parser(" and ce.event_id = ep.event_id ")
   CALL parser(" and ce.record_status_cd != RECORD_STATUS_DRAFT ")
   CALL parser(" and ")
   SET breturn = setupeventrowversionclause(null)
   IF (event_set_cd)
    CALL parser("  and ese.event_cd = ce.event_cd ")
    CALL parser("  and ese.event_set_cd = event_set_cd ")
   ENDIF
   CALL parser(" order by ")
   IF (request->direction_flag)
    CALL parser(" ep.action_dt_tm, ")
   ELSE
    CALL parser(" ep.action_dt_tm desc, ")
   ENDIF
   CALL parser(" ep.event_prsnl_id ")
   SET breturn = setupstandarddetailclause(null)
   CALL parser(" with nocounter go ")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE buildcursorfour(null)
   CALL parser(" select distinct into 'nl:'  ")
   SET breturn = setupselectfields(null)
   CALL parser(" from               ")
   IF (event_set_cd)
    CALL parser(" v500_event_set_explode ese, ")
   ENDIF
   CALL parser("   clinical_event ce, ")
   CALL parser("   ce_event_prsnl ep, ")
   CALL parser("   person p,        ")
   CALL parser("   person_name pn   ")
   CALL parser(" where ")
   CALL parser("        ep.action_prsnl_id = request->action_prsnl_id ")
   IF (actionprsnlgroupind)
    IF (request->action_prsnl_group_id)
     CALL parser("  and ep.action_prsnl_group_id = request->action_prsnl_group_id ")
    ENDIF
   ENDIF
   IF ( NOT (context->null_action_dt_tm_ind))
    CALL parser(" and (ep.action_dt_tm is null or (")
   ELSE
    CALL parser(" and (( ")
   ENDIF
   CALL parser("ep.action_dt_tm ")
   IF (request->direction_flag)
    CALL parser(" >= ")
   ELSE
    CALL parser(" <= ")
   ENDIF
   CALL parser(" cnvtdatetime(request->search_start_dt_tm) ")
   IF ((request->search_end_dt_tm_ind=not_empty))
    CALL parser(" and ep.action_dt_tm ")
    IF (request->direction_flag)
     CALL parser(" <= ")
    ELSE
     CALL parser(" >= ")
    ENDIF
    CALL parser(" cnvtdatetime(request->search_end_dt_tm) ))")
   ELSE
    CALL parser("))")
   ENDIF
   SET breturn = setupactionstatuscdfilter(null)
   IF (request->action_type_cd)
    CALL parser(" and ep.action_type_cd = request->action_type_cd ")
   ENDIF
   IF ( NOT (request->action_type_cd)
    AND bactionstatuscd
    AND request->no_anchor_dt_flag
    AND  NOT (bactionstatuscdcompl))
    CALL parser(" and ep.action_type_cd != 0 ")
   ENDIF
   IF (request->long_text_id)
    CALL parser(" and ep.long_text_id = request->long_text_id ")
   ENDIF
   CALL parser("    and ")
   SET breturn = setupprsnlrowversionclause(null)
   CALL parser("    and ce.event_id = ep.event_id ")
   CALL parser("    and ")
   SET breturn = setupeventrowversionclause(null)
   IF (event_set_cd)
    CALL parser("  and ese.event_cd = ce.event_cd ")
    CALL parser("  and ese.event_set_cd = event_set_cd ")
   ENDIF
   CALL parser("   and ce.record_status_cd != RECORD_STATUS_DRAFT ")
   CALL parser("   and p.person_id = ep.person_id ")
   CALL parser("   and pn.person_id = p.person_id ")
   CALL parser("   and pn.active_ind = 1 ")
   CALL parser("   and pn.name_type_cd = name_type_current ")
   CALL parser(" order by ")
   IF (request->direction_flag)
    CALL parser(" ep.action_dt_tm, ")
   ELSE
    CALL parser(" ep.action_dt_tm desc, ")
   ENDIF
   CALL parser(" ep.event_prsnl_id ")
   SET breturn = setupstandarddetailclause(null)
   IF ( NOT (bactionstatuscdcompl))
    CALL parser(
     " with nocounter, orahintcbo( 'INDEX(EP XIE4CE_EVENT_PRSNL)', 'USE_NL(EP CE P PN)', 'LEADING(EP)' ) go "
     )
   ELSE
    CALL parser(
     " with nocounter, orahintcbo( 'INDEX(EP XIE3CE_EVENT_PRSNL)', 'USE_NL(EP CE P PN)', 'LEADING(EP)' ) go "
     )
   ENDIF
   IF ((context->query_type=5)
    AND size(reply->reply_list,5) > 0)
    SET breturn = fetchblobresultdata(null)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE fetcheventsetcode(null)
   DECLARE eventsetcd = f8 WITH noconstant(0.0)
   IF ( NOT ((request->event_set_name="")))
    SELECT INTO "nl:"
     esc.event_set_cd
     FROM v500_event_set_code esc
     WHERE (esc.event_set_name=request->event_set_name)
     DETAIL
      eventsetcd = esc.event_set_cd
     WITH nocounter
    ;end select
   ELSEIF (request->event_set_cd)
    SET eventsetcd = request->event_set_cd
   ENDIF
   RETURN(eventsetcd)
 END ;Subroutine
 SUBROUTINE fetchblobresultdata(null)
   RECORD blobresults(
     1 rec[*]
       2 rownum = i4
       2 event_id = f8
   )
   DECLARE reccnt = i2 WITH noconstant(0)
   DECLARE nstart = i2 WITH noconstant(1)
   DECLARE nsize = i2 WITH constant(40)
   DECLARE resultcount = i2 WITH constant(size(reply->reply_list,5))
   DECLARE blobrowversion = vc
   DECLARE blob_ndx = i2
   DECLARE blob_cnt = i2
   DECLARE ce_blob_result = i2 WITH constant(256)
   IF ((request->valid_from_dt_tm_ind=empty))
    SET blobrowversion = "  br.valid_until_dt_tm = cnvtdatetime(MAX_DATE) "
   ELSE
    SET blobrowversion = concat(
     " ( br.valid_from_dt_tm <= cnvtdatetime(request->valid_from_dt_tm) and  ",
     "   br.valid_until_dt_tm >= cnvtdatetime(request->valid_from_dt_tm) )")
   ENDIF
   SET reccnt = 0
   SELECT INTO "nl:"
    d.seq, event_id = reply->reply_list[d.seq].event_id
    FROM (dummyt d  WITH seq = value(resultcount))
    PLAN (d)
    ORDER BY event_id, d.seq
    HEAD REPORT
     ndx = 0, bandval = 0
    DETAIL
     bandval = band(reply->reply_list[d.seq].subtable_bit_map,ce_blob_result)
     IF (bandval)
      reccnt += 1
      IF (mod(reccnt,nsize)=1)
       stat = alterlist(blobresults->rec,(reccnt+ (nsize - 1)))
      ENDIF
      blobresults->rec[reccnt].rownum = d.seq, blobresults->rec[reccnt].event_id = event_id
     ENDIF
    FOOT REPORT
     ndx = reccnt
     WHILE (ndx < size(blobresults->rec,5))
       ndx += 1, blobresults->rec[ndx].rownum = blobresults->rec[reccnt].rownum, blobresults->rec[ndx
       ].event_id = blobresults->rec[reccnt].event_id
     ENDWHILE
    WITH nocounter, memsort
   ;end select
   SET blob_cnt = size(blobresults->rec,5)
   IF (reccnt)
    SET nstart = 1
    SELECT DISTINCT INTO "nl:"
     br.event_id, br.storage_cd
     FROM ce_blob_result br,
      (dummyt d  WITH seq = value((size(blobresults->rec,5)/ nsize)))
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (br
      WHERE expand(blob_ndx,nstart,((nstart+ nsize) - 1),br.event_id,blobresults->rec[blob_ndx].
       event_id,
       40)
       AND parser(blobrowversion))
     ORDER BY br.event_id
     HEAD REPORT
      lastpos = 1, newpos = 0
     DETAIL
      newpos = locateval(newpos,lastpos,reccnt,br.event_id,blobresults->rec[newpos].event_id)
      WHILE (newpos)
        reply->reply_list[blobresults->rec[newpos].rownum].storage_cd = br.storage_cd, lastpos =
        newpos
        IF (newpos < reccnt)
         newpos += 1
         IF ((reply->reply_list[blobresults->rec[newpos].rownum].event_id != br.event_id))
          newpos = 0
         ENDIF
        ELSE
         newpos = 0
        ENDIF
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(blobresults->rec,0)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setupprsnlrowversionclause(null)
  IF ((request->valid_from_dt_tm_ind=empty))
   CALL parser("  ep.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ")
  ELSE
   CALL parser(" ( ep.valid_from_dt_tm <= cnvtdatetime(request->valid_from_dt_tm) and  ")
   CALL parser(" ep.valid_until_dt_tm >= cnvtdatetime(request->valid_from_dt_tm) )   ")
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE setupeventrowversionclause(null)
  IF ((request->valid_from_dt_tm_ind=empty))
   CALL parser("  ce.valid_until_dt_tm = cnvtdatetime(MAX_DATE) ")
  ELSE
   CALL parser(" ( ce.valid_from_dt_tm <= cnvtdatetime(request->valid_from_dt_tm) and  ")
   CALL parser(" ce.valid_until_dt_tm >= cnvtdatetime(request->valid_from_dt_tm) )   ")
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE setupblobrowversionclause(null)
  IF ((request->valid_from_dt_tm_ind=empty))
   CALL parser("  br.valid_until_dt_tm = outerjoin(cnvtdatetime(MAX_DATE)) ")
  ELSE
   CALL parser(" ( br.valid_from_dt_tm <= outerjoin(cnvtdatetime(request->valid_from_dt_tm)) and  ")
   CALL parser(" br.valid_until_dt_tm >= outerjoin(cnvtdatetime(request->valid_from_dt_tm)) )   ")
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE setupactionstatuscdflags(null)
   SET actionstatuslistcount = size(request->action_status_cd_list_ext,5)
   FOR (loopcnt = 1 TO actionstatuslistcount)
    SET bactionstatuscd = true
    IF ((request->action_status_cd_list_ext[loopcnt].action_status_cd=action_status_completed))
     SET bactionstatuscdcompl = true
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setupactionstatuscdfilter(null)
  IF (actionstatuslistcount)
   IF ((context->query_type >= 4)
    AND request->no_anchor_dt_flag
    AND  NOT (bactionstatuscdcompl))
    CALL parser(" and ep.action_status_cd in ( ")
   ELSE
    CALL parser(" and ep.action_status_cd +0 in ( ")
   ENDIF
   FOR (loopcnt = 1 TO actionstatuslistcount)
    IF (loopcnt != 1)
     CALL parser(", ")
    ENDIF
    CALL parser(build(request->action_status_cd_list_ext[loopcnt].action_status_cd))
   ENDFOR
   CALL parser(" )")
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE setupstandarddetailclause(null)
   CALL parser("  detail  ")
   IF (bsrvnotdeletemode)
    CALL parser(" if ( NOT(ep.action_status_cd = ACTION_STATUS_DELETED) ) ")
   ENDIF
   CALL parser(" cnt = cnt + 1  ")
   IF ((context->query_type >= 3)
    AND request->events_to_fetch)
    CALL parser(" bSameDay = FALSE ")
    CALL parser(" if (   (YEAR(context->last_action_dt_tm) = YEAR(ep.action_dt_tm))   ")
    CALL parser("    AND (MONTH(context->last_action_dt_tm) = MONTH(ep.action_dt_tm)) ")
    CALL parser("    AND (DAY(context->last_action_dt_tm) = DAY(ep.action_dt_tm)) )   ")
    CALL parser("    bSameDay = TRUE ")
    CALL parser(" endif ")
    CALL parser(" if ( (cnt > request->events_to_fetch) AND NOT(bSameDay) ) ")
    CALL parser("     cnt = cnt - 1 ")
    CALL parser(" else ")
   ENDIF
   CALL parser("  if ( mod(cnt,10) = 1 )                          ")
   CALL parser("    stat = alterlist( reply->reply_list, cnt + 9 )  ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].action_dt_tm = ep.action_dt_tm          ")
   CALL parser(" reply->reply_list[cnt].event_prsnl_id = ep.event_prsnl_id           ")
   CALL parser(" reply->reply_list[cnt].person_id = ep.person_id                      ")
   CALL parser(" reply->reply_list[cnt].event_id = ep.event_id                        ")
   CALL parser(" reply->reply_list[cnt].valid_from_dt_tm = ep.valid_from_dt_tm  ")
   CALL parser(" if (ep.valid_from_dt_tm <= 0) ")
   CALL parser("   reply->reply_list[cnt].valid_from_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].valid_until_dt_tm = ep.valid_until_dt_tm      ")
   CALL parser(" if (ep.valid_until_dt_tm <= 0) ")
   CALL parser("   reply->reply_list[cnt].valid_until_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].action_type_cd = ep.action_type_cd      ")
   CALL parser(" reply->reply_list[cnt].request_dt_tm = ep.request_dt_tm        ")
   CALL parser(" if (ep.request_dt_tm <= 0) ")
   CALL parser("   reply->reply_list[cnt].request_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].request_tz = ep.request_tz              ")
   CALL parser(" reply->reply_list[cnt].request_prsnl_id = ep.request_prsnl_id  ")
   CALL parser(" reply->reply_list[cnt].request_prsnl_ft = ep.request_prsnl_ft  ")
   CALL parser(" reply->reply_list[cnt].request_comment = ep.request_comment    ")
   CALL parser(" if (ep.action_dt_tm <= 0) ")
   CALL parser("   reply->reply_list[cnt].action_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].action_tz = ep.action_tz                ")
   CALL parser(" reply->reply_list[cnt].action_prsnl_id = ep.action_prsnl_id    ")
   CALL parser(" reply->reply_list[cnt].action_prsnl_ft = ep.action_prsnl_ft    ")
   CALL parser(" reply->reply_list[cnt].proxy_prsnl_id = ep.proxy_prsnl_id      ")
   CALL parser(" reply->reply_list[cnt].proxy_prsnl_ft = ep.proxy_prsnl_ft      ")
   CALL parser(" reply->reply_list[cnt].action_status_cd = ep.action_status_cd  ")
   CALL parser(" reply->reply_list[cnt].action_comment = ep.action_comment      ")
   CALL parser(" reply->reply_list[cnt].change_since_action_flag = ep.change_since_action_flag    ")
   CALL parser(" reply->reply_list[cnt].updt_dt_tm = ep.updt_dt_tm  ")
   CALL parser(" if (ep.updt_dt_tm <= 0) ")
   CALL parser("   reply->reply_list[cnt].updt_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].updt_task = ep.updt_task               ")
   CALL parser(" if (ep.updt_task <= 0) ")
   CALL parser("   reply->reply_list[cnt].updt_task_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].updt_cnt = ep.updt_cnt                  ")
   CALL parser(" if (ep.updt_cnt <= 0) ")
   CALL parser("   reply->reply_list[cnt].updt_cnt_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].updt_id = ep.updt_id                    ")
   CALL parser(" reply->reply_list[cnt].long_text_id = ep.long_text_id          ")
   CALL parser(" reply->reply_list[cnt].linked_event_id = ep.linked_event_id    ")
   CALL parser(" reply->reply_list[cnt].receiving_person_id = ep.receiving_person_id  ")
   CALL parser(" reply->reply_list[cnt].receiving_person_ft = ep.receiving_person_ft   ")
   IF (actionprsnlgroupind)
    CALL parser(" reply->reply_list[cnt].action_prsnl_group_id = ep.action_prsnl_group_id    ")
    CALL parser(" reply->reply_list[cnt].request_prsnl_group_id = ep.request_prsnl_group_id   ")
   ENDIF
   IF (bdigitalsignaturemode)
    CALL parser(" reply->reply_list[cnt].digital_signature_ident = ep.digital_signature_ident  ")
   ENDIF
   IF ((context->query_type >= 3))
    SET breturn = setupcursorextradetailclause(null)
    CALL parser(" context->last_action_dt_tm = ep.action_dt_tm ")
    CALL parser(" context->last_action_dt_tm_ind = 0 ")
    CALL parser(" context->last_event_prsnl_id = ep.event_prsnl_id ")
    CALL parser(" if (ep.action_dt_tm <= 0) ")
    CALL parser("    context->null_action_dt_tm_ind = 1 ")
    CALL parser(" endif ")
   ENDIF
   IF ((context->query_type >= 3)
    AND request->events_to_fetch)
    CALL parser(" endif ")
   ENDIF
   IF (bsrvnotdeletemode)
    CALL parser(" endif ")
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setupcursorextradetailclause(null)
   CALL parser(" reply->reply_list[cnt].encntr_id = ce.encntr_id     ")
   CALL parser(" reply->reply_list[cnt].encntr_financial_id = ce.encntr_financial_id     ")
   CALL parser(" reply->reply_list[cnt].order_id = ce.order_id     ")
   CALL parser(" reply->reply_list[cnt].order_action_sequence = ce.order_action_sequence     ")
   CALL parser(" reply->reply_list[cnt].accession_nbr = ce.accession_nbr     ")
   CALL parser(" reply->reply_list[cnt].contributor_system_cd = ce.contributor_system_cd     ")
   CALL parser(" reply->reply_list[cnt].reference_nbr = ce.reference_nbr     ")
   CALL parser(" reply->reply_list[cnt].parent_event_id = ce.parent_event_id     ")
   CALL parser(" reply->reply_list[cnt].event_class_cd = ce.event_class_cd     ")
   CALL parser(" reply->reply_list[cnt].event_cd = ce.event_cd     ")
   CALL parser(" reply->reply_list[cnt].event_tag = ce.event_tag     ")
   CALL parser(" reply->reply_list[cnt].event_start_dt_tm = ce.event_start_dt_tm     ")
   CALL parser(" if (ce.event_start_dt_tm <= 0) ")
   CALL parser("    reply->reply_list[cnt].event_start_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].event_start_tz = ce.event_start_tz     ")
   CALL parser(" reply->reply_list[cnt].event_end_dt_tm = ce.event_end_dt_tm    ")
   CALL parser(" if (ce.event_end_dt_tm <= 0) ")
   CALL parser("    reply->reply_list[cnt].event_end_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].event_end_dt_tm_os = ce.event_end_dt_tm_os     ")
   CALL parser(" if (ce.event_end_dt_tm_os <= 0) ")
   CALL parser("    reply->reply_list[cnt].event_end_dt_tm_os_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].event_end_tz = ce.event_end_tz     ")
   CALL parser(" reply->reply_list[cnt].catalog_cd = ce.catalog_cd     ")
   CALL parser(" reply->reply_list[cnt].record_status_cd = ce.record_status_cd     ")
   CALL parser(" reply->reply_list[cnt].result_status_cd = ce.result_status_cd     ")
   CALL parser(" reply->reply_list[cnt].authentic_flag = ce.authentic_flag     ")
   CALL parser(" reply->reply_list[cnt].publish_flag = ce.publish_flag     ")
   CALL parser(" reply->reply_list[cnt].qc_review_cd = ce.qc_review_cd     ")
   CALL parser(" reply->reply_list[cnt].normalcy_cd = ce.normalcy_cd     ")
   CALL parser(" reply->reply_list[cnt].normalcy_method_cd = ce.normalcy_method_cd     ")
   CALL parser(" reply->reply_list[cnt].inquire_security_cd = ce.inquire_security_cd     ")
   CALL parser(" reply->reply_list[cnt].resource_group_cd = ce.resource_group_cd     ")
   CALL parser(" reply->reply_list[cnt].resource_cd = ce.resource_cd     ")
   CALL parser(" reply->reply_list[cnt].subtable_bit_map = ce.subtable_bit_map     ")
   CALL parser(" reply->reply_list[cnt].result_val = ce.result_val     ")
   CALL parser(" reply->reply_list[cnt].result_units_cd = ce.result_units_cd     ")
   CALL parser(" reply->reply_list[cnt].result_time_units_cd = ce.result_time_units_cd     ")
   CALL parser(" reply->reply_list[cnt].verified_dt_tm = ce.verified_dt_tm     ")
   CALL parser(" if (ce.verified_dt_tm <= 0) ")
   CALL parser("    reply->reply_list[cnt].verified_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].verified_tz = ce.verified_tz     ")
   CALL parser(" reply->reply_list[cnt].verified_prsnl_id = ce.verified_prsnl_id     ")
   CALL parser(" reply->reply_list[cnt].performed_dt_tm = ce.performed_dt_tm     ")
   CALL parser(" if (ce.performed_dt_tm <= 0) ")
   CALL parser("    reply->reply_list[cnt].performed_dt_tm_ind = 1 ")
   CALL parser(" endif ")
   CALL parser(" reply->reply_list[cnt].performed_tz = ce.performed_tz     ")
   CALL parser(" reply->reply_list[cnt].performed_prsnl_id = ce.performed_prsnl_id     ")
   CALL parser(" reply->reply_list[cnt].event_title_text = ce.event_title_text     ")
   CALL parser(" reply->reply_list[cnt].clinical_updt_cnt = ce.updt_cnt     ")
   CALL parser(" reply->reply_list[cnt].entry_mode_cd = ce.entry_mode_cd     ")
   CALL parser(" reply->reply_list[cnt].source_cd = ce.source_cd    ")
   IF ((context->query_type >= 4))
    CALL parser(" reply->reply_list[cnt].name_last = pn.name_last      ")
    CALL parser(" reply->reply_list[cnt].name_first = pn.name_first    ")
    CALL parser(" reply->reply_list[cnt].name_middle = pn.name_middle  ")
    CALL parser(" reply->reply_list[cnt].name_suffix = pn.name_suffix  ")
    CALL parser(" reply->reply_list[cnt].name_title = pn.name_title    ")
    CALL parser(" reply->reply_list[cnt].name_degree = pn.name_degree  ")
    CALL parser(" reply->reply_list[cnt].sex_cd = p.sex_cd             ")
    CALL parser(" reply->reply_list[cnt].birth_dt_tm = p.birth_dt_tm   ")
    CALL parser(" if (p.birth_dt_tm <= 0) ")
    CALL parser("    reply->reply_list[cnt].birth_dt_tm_ind = 1 ")
    CALL parser(" endif ")
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE setupselectfields(null)
   CALL parser(" EP.EVENT_ID, ")
   CALL parser(" EP.VALID_UNTIL_DT_TM, ")
   CALL parser(" EP.EVENT_PRSNL_ID, ")
   CALL parser(" EP.PERSON_ID, ")
   CALL parser(" EP.VALID_FROM_DT_TM, ")
   CALL parser(" EP.ACTION_TYPE_CD, ")
   CALL parser(" EP.REQUEST_DT_TM, ")
   CALL parser(" EP.REQUEST_PRSNL_ID, ")
   CALL parser(" EP.REQUEST_PRSNL_FT, ")
   CALL parser(" EP.REQUEST_COMMENT, ")
   CALL parser(" EP.ACTION_DT_TM, ")
   CALL parser(" EP.ACTION_PRSNL_ID, ")
   CALL parser(" EP.ACTION_PRSNL_FT, ")
   CALL parser(" EP.PROXY_PRSNL_ID, ")
   CALL parser(" EP.PROXY_PRSNL_FT, ")
   CALL parser(" EP.ACTION_STATUS_CD, ")
   CALL parser(" EP.ACTION_COMMENT, ")
   CALL parser(" EP.CHANGE_SINCE_ACTION_FLAG, ")
   CALL parser(" EP.UPDT_DT_TM, ")
   CALL parser(" EP.UPDT_ID, ")
   CALL parser(" EP.UPDT_TASK, ")
   CALL parser(" EP.UPDT_CNT, ")
   CALL parser(" EP.LONG_TEXT_ID, ")
   CALL parser(" EP.ACTION_TZ, ")
   CALL parser(" EP.REQUEST_TZ, ")
   CALL parser(" EP.LINKED_EVENT_ID, ")
   CALL parser(" EP.RECEIVING_PERSON_ID, ")
   CALL parser(" EP.RECEIVING_PERSON_FT ")
   IF (actionprsnlgroupind)
    CALL parser(", EP.ACTION_PRSNL_GROUP_ID, ")
    CALL parser(" EP.REQUEST_PRSNL_GROUP_ID ")
   ENDIF
   IF (bdigitalsignaturemode)
    CALL parser(", EP.DIGITAL_SIGNATURE_IDENT ")
   ENDIF
   IF ((context->query_type >= 3))
    CALL parser(", CE.ENCNTR_ID, ")
    CALL parser(" CE.EVENT_START_DT_TM, ")
    CALL parser(" CE.ENCNTR_FINANCIAL_ID, ")
    CALL parser(" CE.EVENT_TITLE_TEXT, ")
    CALL parser(" CE.ORDER_ID, ")
    CALL parser(" CE.CATALOG_CD, ")
    CALL parser(" CE.ACCESSION_NBR, ")
    CALL parser(" CE.CONTRIBUTOR_SYSTEM_CD, ")
    CALL parser(" CE.REFERENCE_NBR, ")
    CALL parser(" CE.PARENT_EVENT_ID, ")
    CALL parser(" CE.EVENT_CLASS_CD, ")
    CALL parser(" CE.EVENT_CD, ")
    CALL parser(" CE.EVENT_TAG, ")
    CALL parser(" CE.EVENT_END_DT_TM, ")
    CALL parser(" CE.EVENT_END_DT_TM_OS, ")
    CALL parser(" CE.RESULT_VAL, ")
    CALL parser(" CE.RESULT_UNITS_CD, ")
    CALL parser(" CE.RESULT_TIME_UNITS_CD, ")
    CALL parser(" CE.RECORD_STATUS_CD, ")
    CALL parser(" CE.RESULT_STATUS_CD, ")
    CALL parser(" CE.AUTHENTIC_FLAG, ")
    CALL parser(" CE.PUBLISH_FLAG, ")
    CALL parser(" CE.QC_REVIEW_CD, ")
    CALL parser(" CE.NORMALCY_CD, ")
    CALL parser(" CE.NORMALCY_METHOD_CD, ")
    CALL parser(" CE.INQUIRE_SECURITY_CD, ")
    CALL parser(" CE.RESOURCE_GROUP_CD, ")
    CALL parser(" CE.RESOURCE_CD, ")
    CALL parser(" CE.SUBTABLE_BIT_MAP, ")
    CALL parser(" CE.VERIFIED_DT_TM, ")
    CALL parser(" CE.VERIFIED_PRSNL_ID, ")
    CALL parser(" CE.PERFORMED_DT_TM, ")
    CALL parser(" CE.PERFORMED_PRSNL_ID, ")
    CALL parser(" CE.UPDT_CNT, ")
    CALL parser(" CE.ORDER_ACTION_SEQUENCE, ")
    CALL parser(" CE.ENTRY_MODE_CD, ")
    CALL parser(" CE.SOURCE_CD, ")
    CALL parser(" CE.EVENT_END_TZ, ")
    CALL parser(" CE.EVENT_START_TZ, ")
    CALL parser(" CE.PERFORMED_TZ, ")
    CALL parser(" CE.VERIFIED_TZ ")
   ENDIF
   IF ((context->query_type >= 4))
    CALL parser(", P.BIRTH_DT_TM, ")
    CALL parser(" P.SEX_CD,       ")
    CALL parser(" PN.NAME_FIRST,  ")
    CALL parser(" PN.NAME_MIDDLE, ")
    CALL parser(" PN.NAME_LAST,   ")
    CALL parser(" PN.NAME_DEGREE, ")
    CALL parser(" PN.NAME_TITLE,  ")
    CALL parser(" PN.NAME_SUFFIX  ")
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
END GO
