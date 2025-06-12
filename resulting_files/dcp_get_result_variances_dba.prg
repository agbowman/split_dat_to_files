CREATE PROGRAM dcp_get_result_variances:dba
 SET modify = predeclare
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 variancelist[*]
      2 variance_reltn_id = f8
      2 parent_entity_name = c32
      2 parent_entity_id = f8
      2 pathway_id = f8
      2 event_id = f8
      2 variance_type_cd = f8
      2 variance_type_disp = c40
      2 variance_type_mean = c12
      2 action_cd = f8
      2 action_disp = c40
      2 action_mean = c12
      2 action_text_id = f8
      2 action_text = vc
      2 action_text_updt_cnt = i4
      2 reason_cd = f8
      2 reason_disp = c40
      2 reason_mean = c12
      2 reason_text_id = f8
      2 reason_text = vc
      2 reason_text_updt_cnt = i4
      2 variance_updt_cnt = i4
      2 active_ind = i2
      2 note_text_id = f8
      2 note_text = vc
      2 note_text_updt_cnt = i4
      2 chart_prsnl_name = vc
      2 chart_dt_tm = dq8
      2 chart_prsnl_id = f8
      2 unchart_prsnl_name = vc
      2 unchart_dt_tm = dq8
      2 unchart_prsnl_id = f8
      2 chart_tz = i4
      2 unchart_tz = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_RESULT_VARIANCES request")
  CALL echorecord(request)
 ENDIF
 RECORD person(
   1 personlist[*]
     2 person_id = f8
     2 person_name = vc
     2 idxlist[*]
       3 var_idx = i4
       3 chart_ind = i2
       3 unchart_ind = i2
 )
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE variance_idx = i4
 DECLARE note_total = i4 WITH noconstant(0)
 DECLARE reason_total = i4 WITH noconstant(0)
 DECLARE action_total = i4 WITH noconstant(0)
 DECLARE variance_cnt = i4 WITH noconstant(0)
 DECLARE person_cnt = i4 WITH noconstant(0)
 DECLARE p_idx = i4 WITH noconstant(0)
 DECLARE idxcnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE list_idx = i4 WITH noconstant(0)
 DECLARE pvr_where = vc
 DECLARE current_idx = i4 WITH noconstant(0)
 DECLARE add_person_index(person_idx=i4,var_idx=i4,list_idx=i4,idx_list_size=i4,chart_ind=i2,
  unchart_ind=i2) = null
 DECLARE add_new_person(person_idx=i4,var_idx=i4,list_idx=i4,idx_list_size=i4,chart_ind=i2,
  unchart_ind=i2) = null
 IF ((request->load_inactive_ind=0)
  AND (request->load_latest_ind=0))
  SET pvr_where = concat("expand(num,start,stop,pvr.event_id ,request->eventList[num]->event_id)",
   " AND (pvr.active_ind = 1)")
 ELSE
  SET pvr_where = "expand(num,start,stop,pvr.event_id ,request->eventList[num]->event_id)"
 ENDIF
 IF ((request->act_pw_comp_id > 0))
  SET pvr_where = concat(pvr_where," AND (pvr.parent_entity_id = request->act_pw_comp_id)")
  SET pvr_where = concat(pvr_where," AND (pvr.parent_entity_name = 'ACT_PW_COMP')")
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo(build("Where clause: ",pvr_where))
 ENDIF
 IF (value(size(request->eventlist,5)) > 0)
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(request->eventlist,5))
  IF (high <= 100)
   SET stop = high
  ELSE
   SET stop = 100
  ENDIF
  SET person_cnt = 0
  WHILE (start <= stop)
    SELECT INTO "nl:"
     FROM pw_variance_reltn pvr
     PLAN (pvr
      WHERE parser(trim(pvr_where)))
     ORDER BY pvr.event_id, pvr.updt_dt_tm DESC
     HEAD pvr.event_id
      IF ((request->load_latest_ind=1))
       variance_cnt = (variance_cnt+ 1)
       IF (variance_cnt > size(reply->variancelist,5))
        stat = alterlist(reply->variancelist,(variance_cnt+ 5))
       ENDIF
       reply->variancelist[variance_cnt].variance_reltn_id = pvr.pw_variance_reltn_id, reply->
       variancelist[variance_cnt].parent_entity_name = pvr.parent_entity_name, reply->variancelist[
       variance_cnt].parent_entity_id = pvr.parent_entity_id,
       reply->variancelist[variance_cnt].pathway_id = pvr.pathway_id, reply->variancelist[
       variance_cnt].event_id = pvr.event_id, reply->variancelist[variance_cnt].variance_type_cd =
       pvr.variance_type_cd,
       reply->variancelist[variance_cnt].action_cd = pvr.action_cd, reply->variancelist[variance_cnt]
       .action_text_id = pvr.action_text_id, reply->variancelist[variance_cnt].reason_cd = pvr
       .reason_cd,
       reply->variancelist[variance_cnt].reason_text_id = pvr.reason_text_id, reply->variancelist[
       variance_cnt].variance_updt_cnt = pvr.updt_cnt, reply->variancelist[variance_cnt].active_ind
        = pvr.active_ind,
       reply->variancelist[variance_cnt].note_text_id = pvr.note_text_id, reply->variancelist[
       variance_cnt].chart_dt_tm = cnvtdatetime(pvr.chart_dt_tm), reply->variancelist[variance_cnt].
       chart_prsnl_id = pvr.chart_prsnl_id,
       reply->variancelist[variance_cnt].unchart_dt_tm = cnvtdatetime(pvr.unchart_dt_tm), reply->
       variancelist[variance_cnt].unchart_prsnl_id = pvr.unchart_prsnl_id, reply->variancelist[
       variance_cnt].chart_tz = pvr.chart_tz,
       reply->variancelist[variance_cnt].unchart_tz = pvr.unchart_tz
       IF ((reply->variancelist[variance_cnt].chart_prsnl_id != 0))
        IF (person_cnt=0)
         person_cnt = 1,
         CALL add_new_person(person_cnt,variance_cnt,1,1,1,0)
        ELSE
         idx = locateval(idx,1,size(person->personlist,5),pvr.chart_prsnl_id,person->personlist[idx].
          person_id)
         IF (idx > 0)
          idxcnt = size(person->personlist[idx].idxlist,5), current_idx = locateval(current_idx,1,
           idxcnt,variance_cnt,person->personlist[idx].idxlist[current_idx].var_idx)
          IF (current_idx > 0)
           person->personlist[idx].idxlist[current_idx].chart_ind = 1
          ELSE
           idxcnt = (idxcnt+ 1),
           CALL add_person_index(idx,variance_cnt,idxcnt,idxcnt,1,0)
          ENDIF
         ELSE
          person_cnt = (person_cnt+ 1),
          CALL add_new_person(person_cnt,variance_cnt,1,1,1,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((reply->variancelist[variance_cnt].unchart_prsnl_id != 0))
        IF (person_cnt=0)
         person_cnt = 1,
         CALL add_new_person(person_cnt,variance_cnt,1,1,0,1)
        ELSE
         idx = locateval(idx,1,size(person->personlist,5),pvr.unchart_prsnl_id,person->personlist[idx
          ].person_id)
         IF (idx > 0)
          idxcnt = size(person->personlist[idx].idxlist,5), current_idx = locateval(current_idx,1,
           idxcnt,variance_cnt,person->personlist[idx].idxlist[current_idx].var_idx)
          IF (current_idx > 0)
           person->personlist[idx].idxlist[current_idx].unchart_ind = 1
          ELSE
           idxcnt = (idxcnt+ 1),
           CALL add_person_index(idx,variance_cnt,idxcnt,idxcnt,0,1)
          ENDIF
         ELSE
          person_cnt = (person_cnt+ 1),
          CALL add_new_person(person_cnt,variance_cnt,1,1,0,1)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     DETAIL
      IF ((request->load_latest_ind=0))
       variance_cnt = (variance_cnt+ 1)
       IF (variance_cnt > size(reply->variancelist,5))
        stat = alterlist(reply->variancelist,(variance_cnt+ 5))
       ENDIF
       reply->variancelist[variance_cnt].variance_reltn_id = pvr.pw_variance_reltn_id, reply->
       variancelist[variance_cnt].parent_entity_name = pvr.parent_entity_name, reply->variancelist[
       variance_cnt].parent_entity_id = pvr.parent_entity_id,
       reply->variancelist[variance_cnt].pathway_id = pvr.pathway_id, reply->variancelist[
       variance_cnt].event_id = pvr.event_id, reply->variancelist[variance_cnt].variance_type_cd =
       pvr.variance_type_cd,
       reply->variancelist[variance_cnt].action_cd = pvr.action_cd, reply->variancelist[variance_cnt]
       .action_text_id = pvr.action_text_id, reply->variancelist[variance_cnt].reason_cd = pvr
       .reason_cd,
       reply->variancelist[variance_cnt].reason_text_id = pvr.reason_text_id, reply->variancelist[
       variance_cnt].variance_updt_cnt = pvr.updt_cnt, reply->variancelist[variance_cnt].active_ind
        = pvr.active_ind,
       reply->variancelist[variance_cnt].note_text_id = pvr.note_text_id, reply->variancelist[
       variance_cnt].chart_dt_tm = cnvtdatetime(pvr.chart_dt_tm), reply->variancelist[variance_cnt].
       chart_prsnl_id = pvr.chart_prsnl_id,
       reply->variancelist[variance_cnt].unchart_dt_tm = cnvtdatetime(pvr.unchart_dt_tm), reply->
       variancelist[variance_cnt].unchart_prsnl_id = pvr.unchart_prsnl_id, reply->variancelist[
       variance_cnt].chart_tz = pvr.chart_tz,
       reply->variancelist[variance_cnt].unchart_tz = pvr.unchart_tz
       IF ((reply->variancelist[variance_cnt].chart_prsnl_id != 0))
        IF (person_cnt=0)
         person_cnt = 1,
         CALL add_new_person(person_cnt,variance_cnt,1,1,1,0)
        ELSE
         idx = locateval(idx,1,size(person->personlist,5),pvr.chart_prsnl_id,person->personlist[idx].
          person_id)
         IF (idx > 0)
          idxcnt = size(person->personlist[idx].idxlist,5), current_idx = locateval(current_idx,1,
           idxcnt,variance_cnt,person->personlist[idx].idxlist[current_idx].var_idx)
          IF (current_idx > 0)
           person->personlist[idx].idxlist[current_idx].chart_ind = 1
          ELSE
           idxcnt = (idxcnt+ 1),
           CALL add_person_index(idx,variance_cnt,idxcnt,idxcnt,1,0)
          ENDIF
         ELSE
          person_cnt = (person_cnt+ 1),
          CALL add_new_person(person_cnt,variance_cnt,1,1,1,0)
         ENDIF
        ENDIF
       ENDIF
       IF ((reply->variancelist[variance_cnt].unchart_prsnl_id != 0))
        IF (person_cnt=0)
         person_cnt = 1,
         CALL add_new_person(person_cnt,variance_cnt,1,1,0,1)
        ELSE
         idx = locateval(idx,1,size(person->personlist,5),pvr.unchart_prsnl_id,person->personlist[idx
          ].person_id)
         IF (idx > 0)
          idxcnt = size(person->personlist[idx].idxlist,5), current_idx = locateval(current_idx,1,
           idxcnt,variance_cnt,person->personlist[idx].idxlist[current_idx].var_idx)
          IF (current_idx > 0)
           person->personlist[idx].idxlist[current_idx].unchart_ind = 1
          ELSE
           idxcnt = (idxcnt+ 1),
           CALL add_person_index(idx,variance_cnt,idxcnt,idxcnt,0,1)
          ENDIF
         ELSE
          person_cnt = (person_cnt+ 1),
          CALL add_new_person(person_cnt,variance_cnt,1,1,0,1)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET start = (stop+ 1)
    IF ((high <= (stop+ 100)))
     SET stop = high
    ELSE
     SET stop = (stop+ 100)
    ENDIF
  ENDWHILE
  SET stat = alterlist(person->personlist,person_cnt)
  SET stat = alterlist(reply->variancelist[variance_cnt],variance_cnt)
  IF (variance_cnt > 0)
   IF (person_cnt > 0)
    SELECT INTO "nl:"
     FROM prsnl pr,
      (dummyt d  WITH seq = value(person_cnt))
     PLAN (d)
      JOIN (pr
      WHERE (pr.person_id=person->personlist[d.seq].person_id))
     DETAIL
      person->personlist[d.seq].person_name = pr.name_full_formatted
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL report_failure("SELECT","F","DCP_GET_RESULT_VARIANCES",
      "Failed to find the chart and unchart names in the PRSNL table.")
     GO TO exit_script
    ENDIF
    FOR (p_idx = 1 TO person_cnt)
      FOR (list_idx = 1 TO value(size(person->personlist[p_idx].idxlist,5)))
        SET idx = person->personlist[p_idx].idxlist[list_idx].var_idx
        IF ((person->personlist[p_idx].idxlist[list_idx].chart_ind=1))
         SET reply->variancelist[idx].chart_prsnl_name = person->personlist[p_idx].person_name
        ENDIF
        IF ((person->personlist[p_idx].idxlist[list_idx].unchart_ind=1))
         SET reply->variancelist[idx].unchart_prsnl_name = person->personlist[p_idx].person_name
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   FREE RECORD person
   IF (value(size(reply->variancelist,5)) > 0)
    RECORD rec(
      1 notes[*]
        2 id = f8
        2 idx = i4
      1 actions[*]
        2 id = f8
        2 idx = i4
      1 reasons[*]
        2 id = f8
        2 idx = i4
    )
    FOR (variance_idx = 1 TO value(size(reply->variancelist,5)))
      IF ((reply->variancelist[variance_idx].note_text_id > 0.0))
       SET note_total = (note_total+ 1)
       IF (note_total > value(size(rec->notes,5)))
        SET stat = alterlist(rec->notes,(note_total+ 100))
       ENDIF
       SET rec->notes[note_total].id = reply->variancelist[variance_idx].note_text_id
       SET rec->notes[note_total].idx = variance_idx
      ENDIF
      IF ((reply->variancelist[variance_idx].action_text_id > 0.0))
       SET action_total = (action_total+ 1)
       IF (action_total > value(size(rec->actions,5)))
        SET stat = alterlist(rec->actions,(action_total+ 100))
       ENDIF
       SET rec->actions[action_total].id = reply->variancelist[variance_idx].action_text_id
       SET rec->actions[action_total].idx = variance_idx
      ENDIF
      IF ((reply->variancelist[variance_idx].reason_text_id > 0.0))
       SET reason_total = (reason_total+ 1)
       IF (reason_total > value(size(rec->reasons,5)))
        SET stat = alterlist(rec->reasons,(reason_total+ 100))
       ENDIF
       SET rec->reasons[reason_total].id = reply->variancelist[variance_idx].reason_text_id
       SET rec->reasons[reason_total].idx = variance_idx
      ENDIF
    ENDFOR
    SET stat = alterlist(rec->notes,note_total)
    SET stat = alterlist(rec->actions,action_total)
    SET stat = alterlist(rec->reasons,reason_total)
    SET num = 0
    SET max = 0
    SET start = 1
    SET high = value(size(rec->notes,5))
    IF (high <= 100)
     SET stop = high
    ELSE
     SET stop = 100
    ENDIF
    WHILE (start <= stop)
      SELECT INTO "nl:"
       FROM long_text lt
       PLAN (lt
        WHERE expand(num,start,stop,lt.long_text_id,rec->notes[num].id))
       HEAD REPORT
        idx = 0
       DETAIL
        idx = locateval(idx,start,stop,lt.long_text_id,rec->notes[idx].id)
        IF (idx > 0)
         list_idx = rec->notes[idx].idx, reply->variancelist[list_idx].note_text = trim(lt.long_text),
         reply->variancelist[list_idx].note_text_updt_cnt = lt.updt_cnt
        ENDIF
       FOOT REPORT
        idx = 0
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL report_failure("SELECT","F","DCP_GET_RESULT_VARIANCES",
        "Failed to find the note text in the LONG_TEXT table.")
       GO TO exit_script
      ENDIF
      SET start = (stop+ 1)
      IF ((high <= (stop+ 100)))
       SET stop = high
      ELSE
       SET stop = (stop+ 100)
      ENDIF
    ENDWHILE
    SET num = 0
    SET max = 0
    SET start = 1
    SET high = value(size(rec->actions,5))
    IF (high <= 100)
     SET stop = high
    ELSE
     SET stop = 100
    ENDIF
    WHILE (start <= stop)
      SELECT INTO "nl:"
       FROM long_text lt
       PLAN (lt
        WHERE expand(num,start,stop,lt.long_text_id,rec->actions[num].id))
       HEAD REPORT
        idx = 0
       DETAIL
        idx = locateval(idx,start,stop,lt.long_text_id,rec->actions[idx].id)
        IF (idx > 0)
         list_idx = rec->actions[idx].idx, reply->variancelist[list_idx].action_text = trim(lt
          .long_text), reply->variancelist[list_idx].action_text_updt_cnt = lt.updt_cnt
        ENDIF
       FOOT REPORT
        idx = 0
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL report_failure("SELECT","F","DCP_GET_RESULT_VARIANCES",
        "Failed to find the actions text in the LONG_TEXT table.")
       GO TO exit_script
      ENDIF
      SET start = (stop+ 1)
      IF ((high <= (stop+ 100)))
       SET stop = high
      ELSE
       SET stop = (stop+ 100)
      ENDIF
    ENDWHILE
    SET num = 0
    SET max = 0
    SET start = 1
    SET high = value(size(rec->reasons,5))
    IF (high <= 100)
     SET stop = high
    ELSE
     SET stop = 100
    ENDIF
    WHILE (start <= stop)
      SELECT INTO "nl:"
       FROM long_text lt
       PLAN (lt
        WHERE expand(num,start,stop,lt.long_text_id,rec->reasons[num].id))
       HEAD REPORT
        idx = 0
       DETAIL
        idx = locateval(idx,start,stop,lt.long_text_id,rec->reasons[idx].id)
        IF (idx > 0)
         list_idx = rec->reasons[idx].idx, reply->variancelist[list_idx].reason_text = trim(lt
          .long_text), reply->variancelist[list_idx].reason_text_updt_cnt = lt.updt_cnt
        ENDIF
       FOOT REPORT
        idx = 0
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL report_failure("SELECT","F","DCP_GET_RESULT_VARIANCES",
        "Failed to find the reasons text in the LONG_TEXT table.")
       GO TO exit_script
      ENDIF
      SET start = (stop+ 1)
      IF ((high <= (stop+ 100)))
       SET stop = high
      ELSE
       SET stop = (stop+ 100)
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
 ENDIF
 FREE RECORD rec
 SUBROUTINE add_person_index(person_idx,var_idx,list_idx,idx_list_size,chart_ind,unchart_ind)
   SET stat = alterlist(person->personlist[person_idx].idxlist,idx_list_size)
   IF (chart_ind=1)
    SET person->personlist[person_idx].person_id = reply->variancelist[var_idx].chart_prsnl_id
   ELSEIF (unchart_ind=1)
    SET person->personlist[person_idx].person_id = reply->variancelist[var_idx].unchart_prsnl_id
   ENDIF
   SET person->personlist[person_idx].idxlist[list_idx].var_idx = var_idx
   SET person->personlist[person_idx].idxlist[list_idx].chart_ind = chart_ind
   SET person->personlist[person_idx].idxlist[list_idx].unchart_ind = unchart_ind
 END ;Subroutine
 SUBROUTINE add_new_person(person_idx,var_idx,list_idx,idx_list_size,chart_ind,unchart_ind)
   IF (person_idx > size(person->personlist,5))
    SET stat = alterlist(person->personlist,(person_idx+ 5))
   ENDIF
   IF (chart_ind=1)
    SET person->personlist[person_idx].person_id = reply->variancelist[var_idx].chart_prsnl_id
   ELSEIF (unchart_ind=1)
    SET person->personlist[person_idx].person_id = reply->variancelist[var_idx].unchart_prsnl_id
   ENDIF
   SET stat = alterlist(person->personlist[person_idx].idxlist,idx_list_size)
   SET person->personlist[person_idx].idxlist[list_idx].var_idx = var_idx
   SET person->personlist[person_idx].idxlist[list_idx].chart_ind = chart_ind
   SET person->personlist[person_idx].idxlist[list_idx].unchart_ind = unchart_ind
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_RESULT_VARIANCES reply")
  CALL echorecord(reply)
 ENDIF
END GO
