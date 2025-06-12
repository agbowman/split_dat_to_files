CREATE PROGRAM dcp_get_outcome_results2:dba
 SET modify = predeclare
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_RESULTS2 request")
  CALL echorecord(request)
 ENDIF
 RECORD searchlist(
   1 events[*]
     2 eventcd = f8
     2 markdttm = dq8
     2 outcomestartdttm = dq8
     2 outcomeactid = f8
     2 foundresult = i2
     2 loadstatus = c12
 )
 RECORD temp(
   1 list[*]
     2 outcomeactid = f8
     2 eventcd = f8
     2 clinicaleventid = f8
     2 eventid = f8
     2 encntrid = f8
     2 resultval = vc
     2 resultunitscd = f8
     2 resultunitsdisp = c40
     2 eventenddttm = dq8
     2 resultstatuscd = f8
     2 performdttm = dq8
     2 performprsnlid = f8
     2 performprsnlname = vc
     2 updtcnt = i4
     2 entrymodecd = f8
     2 accessionnbr = c20
     2 code = i2
     2 viewlevel = i2
     2 eventendtz = i4
     2 performtz = i4
     2 coded[*]
       3 nomenclatureid = f8
       3 sequencenbr = i4
     2 cedynamiclabelid = f8
     2 labelname = vc
     2 nomenstringflag = i2
 )
 RECORD prsnl(
   1 list[*]
     2 id = f8
     2 idxlist[*]
       3 idx = i4
 )
 RECORD coded(
   1 eventlist[*]
     2 eventcd = f8
     2 resltlist[*]
       3 eventid = f8
       3 indexlist[*]
         4 idx = i4
 )
 RECORD dynamic_label(
   1 list[*]
     2 cedynamiclabelid = f8
     2 labelname = vc
 )
 DECLARE done = c1 WITH noconstant("N")
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE loopcnt = i4 WITH noconstant(0)
 DECLARE workcnt = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idxtotal = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE eventcnt = i4 WITH noconstant(value(size(request->events,5)))
 DECLARE resultcnt = i4 WITH noconstant(0)
 DECLARE codedtotal = i4 WITH noconstant(0)
 DECLARE preveventcd = f8 WITH noconstant(0.0)
 DECLARE ndynamiclabelcnt = i4 WITH noconstant(0)
 DECLARE nindex = i4 WITH noconstant(0)
 DECLARE endoftime = q8 WITH constant(cnvtdatetime("31-DEC-2100"))
 DECLARE lookbackincrement = i4 WITH noconstant(request->lookbackrangenbr)
 IF (lookbackincrement <= 0)
  SET lookbackincrement = 7
 ENDIF
 DECLARE maxresultcnt = i4 WITH noconstant(request->maxresultcnt)
 IF (maxresultcnt <= 0)
  SET lookbackincrement = 35
 ENDIF
 DECLARE auth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 IF ((auth=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE","Failed to load code value for AUTH from codeset 8"
   )
  GO TO endscript
 ENDIF
 DECLARE modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 IF ((modified=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE",
   "Failed to load code value for MODIFIED from codeset 8")
  GO TO endscript
 ENDIF
 DECLARE altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 IF ((altered=- (1)))
  CALL report_failure("VALIDATE","F","CODE_VALUE",
   "Failed to load code value for ALTERED from codeset 8")
  GO TO endscript
 ENDIF
 DECLARE inerror = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 SET stat = alterlist(searchlist->events,eventcnt)
 FOR (i = 1 TO eventcnt)
   SET searchlist->events[i].eventcd = request->events[i].eventcd
   SET searchlist->events[i].outcomeactid = request->events[i].outcomeactid
   SET searchlist->events[i].markdttm = cnvtdatetime(request->events[i].markdttm)
   SET searchlist->events[i].outcomestartdttm = cnvtdatetime(request->events[i].outcomestartdttm)
   SET searchlist->events[i].foundresult = 0
   SET searchlist->events[i].loadstatus = ""
 ENDFOR
 WHILE (done != "Y")
   RECORD worklist(
     1 events[*]
       2 eventcd = f8
       2 upperdttm = dq8
       2 lowerdttm = dq8
       2 outcomeactid = f8
       2 loadstatus = c12
       2 foundresult = i2
       2 maxresultreached = i2
       2 idx = i4
   )
   SET loopcnt += 1
   SET workcnt = 0
   SET stat = alterlist(worklist->events,eventcnt)
   FOR (i = 1 TO eventcnt)
     IF ((searchlist->events[i].foundresult=0)
      AND (searchlist->events[i].loadstatus != "COMPLETE"))
      SET workcnt += 1
      SET worklist->events[workcnt].eventcd = searchlist->events[i].eventcd
      SET worklist->events[workcnt].outcomeactid = searchlist->events[i].outcomeactid
      SET worklist->events[workcnt].upperdttm = cnvtdatetime(searchlist->events[i].markdttm)
      IF (loopcnt < 5)
       SET worklist->events[workcnt].lowerdttm = cnvtdatetime((cnvtdate(worklist->events[workcnt].
         upperdttm) - (loopcnt * lookbackincrement)),0)
       IF ((worklist->events[workcnt].lowerdttm < searchlist->events[i].outcomestartdttm))
        SET worklist->events[workcnt].lowerdttm = cnvtdatetime(searchlist->events[i].outcomestartdttm
         )
       ENDIF
      ELSE
       SET worklist->events[workcnt].lowerdttm = cnvtdatetime(searchlist->events[i].outcomestartdttm)
      ENDIF
      SET worklist->events[workcnt].foundresult = 0
      SET worklist->events[workcnt].maxresultreached = 0
      SET worklist->events[workcnt].idx = i
     ENDIF
   ENDFOR
   SET stat = alterlist(worklist->events,workcnt)
   IF (value(size(worklist->events,5)) <= 0)
    SET done = "Y"
   ENDIF
   IF (done != "Y")
    SELECT INTO "nl:"
     outcomeactid = worklist->events[d.seq].outcomeactid
     FROM clinical_event ce,
      (dummyt d  WITH seq = value(size(worklist->events,5)))
     PLAN (d)
      JOIN (ce
      WHERE (ce.person_id=request->personid)
       AND (ce.event_cd=worklist->events[d.seq].eventcd)
       AND ce.event_end_dt_tm >= cnvtdatetime(worklist->events[d.seq].lowerdttm)
       AND ce.event_end_dt_tm <= cnvtdatetime(worklist->events[d.seq].upperdttm))
     ORDER BY ce.event_cd, outcomeactid, ce.event_end_dt_tm DESC
     HEAD REPORT
      cnt = size(temp->list,5), ndynamiclabelcnt = 0
     HEAD ce.event_cd
      cnt = cnt
     HEAD outcomeactid
      found = 0, rescnt = 0, maxresultind = 0,
      markdttm = cnvtdatetime(sysdate)
     DETAIL
      IF (((((ce.result_status_cd=auth) OR (((ce.result_status_cd=altered) OR (ce.result_status_cd=
      modified)) )) ) OR (ce.result_status_cd=inerror
       AND (request->loadinactiveresultsind=1)))
       AND ce.valid_until_dt_tm=endoftime
       AND ((maxresultind=0) OR (maxresultind=1
       AND cnvtdatetime(markdttm)=cnvtdatetime(ce.event_end_dt_tm))) )
       rescnt += 1
       IF (rescnt=maxresultcnt)
        maxresultind = 1
       ENDIF
       cnt += 1
       IF (cnt > size(temp->list,5))
        stat = alterlist(temp->list,(cnt+ 100))
       ENDIF
       temp->list[cnt].outcomeactid = outcomeactid, temp->list[cnt].eventcd = ce.event_cd, temp->
       list[cnt].clinicaleventid = ce.clinical_event_id,
       temp->list[cnt].eventid = ce.event_id, temp->list[cnt].encntrid = ce.encntr_id, temp->list[cnt
       ].resultval = trim(ce.result_val),
       temp->list[cnt].resultunitscd = ce.result_units_cd, temp->list[cnt].resultunitsdisp = trim(
        uar_get_code_display(ce.result_units_cd)), temp->list[cnt].eventenddttm = cnvtdatetime(ce
        .event_end_dt_tm),
       temp->list[cnt].resultstatuscd = ce.result_status_cd, temp->list[cnt].performdttm =
       cnvtdatetime(ce.performed_dt_tm), temp->list[cnt].performprsnlid = ce.performed_prsnl_id,
       temp->list[cnt].updtcnt = ce.updt_cnt, temp->list[cnt].entrymodecd = ce.entry_mode_cd, temp->
       list[cnt].accessionnbr = ce.accession_nbr,
       temp->list[cnt].code = btest(ce.subtable_bit_map,15), temp->list[cnt].viewlevel = ce
       .view_level, temp->list[cnt].eventendtz = ce.event_end_tz,
       temp->list[cnt].performtz = ce.performed_tz, temp->list[cnt].nomenstringflag = ce
       .nomen_string_flag
       IF (ce.ce_dynamic_label_id > 0.0)
        temp->list[cnt].cedynamiclabelid = ce.ce_dynamic_label_id, nindex = 0
        IF (size(dynamic_label->list,5))
         nindex = locateval(nindex,1,ndynamiclabelcnt,ce.ce_dynamic_label_id,dynamic_label->list[
          nindex].cedynamiclabelid)
        ENDIF
        IF (nindex < 1)
         ndynamiclabelcnt += 1
         IF (ndynamiclabelcnt > size(dynamic_label->list,5))
          stat = alterlist(dynamic_label->list,(ndynamiclabelcnt+ 50))
         ENDIF
         dynamic_label->list[ndynamiclabelcnt].cedynamiclabelid = ce.ce_dynamic_label_id
        ENDIF
       ENDIF
       markdttm = cnvtdatetime(ce.event_end_dt_tm), prsnlhigh = size(prsnl->list,5), prsnlidx = 0,
       prsnlidx = locateval(prsnlidx,1,prsnlhigh,temp->list[cnt].performprsnlid,prsnl->list[prsnlidx]
        .id)
       IF (prsnlidx > 0)
        curcnt = size(prsnl->list[prsnlidx].idxlist,5), stat = alterlist(prsnl->list[prsnlidx].
         idxlist,(curcnt+ 1)), prsnl->list[prsnlidx].idxlist[(curcnt+ 1)].idx = cnt
       ELSE
        curcnt = size(prsnl->list,5), stat = alterlist(prsnl->list,(curcnt+ 1)), prsnl->list[(curcnt
        + 1)].id = temp->list[cnt].performprsnlid,
        stat = alterlist(prsnl->list[(curcnt+ 1)].idxlist,1), prsnl->list[(curcnt+ 1)].idxlist[1].idx
         = cnt
       ENDIF
       IF (found=0)
        found = 1
       ENDIF
      ENDIF
     FOOT  outcomeactid
      worklist->events[d.seq].foundresult = found, worklist->events[d.seq].maxresultreached =
      maxresultind
      IF (maxresultind=1)
       worklist->events[d.seq].lowerdttm = cnvtdatetime(markdttm)
      ENDIF
     FOOT  ce.event_cd
      cnt = cnt
     FOOT REPORT
      stat = alterlist(temp->list,cnt)
      IF (ndynamiclabelcnt > 0)
       stat = alterlist(dynamic_label->list,ndynamiclabelcnt)
      ENDIF
     WITH nocounter, orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")
    ;end select
    FOR (i = 1 TO value(size(worklist->events,5)))
     SET idx = worklist->events[i].idx
     IF ((worklist->events[i].foundresult=1))
      SET searchlist->events[idx].foundresult = 1
      IF ((worklist->events[i].lowerdttm > searchlist->events[idx].outcomestartdttm))
       SET searchlist->events[idx].loadstatus = "PARTIAL"
       SET searchlist->events[idx].markdttm = cnvtdatetime(worklist->events[i].lowerdttm)
      ELSE
       SET searchlist->events[idx].loadstatus = "COMPLETE"
      ENDIF
     ELSE
      IF ((worklist->events[i].lowerdttm <= searchlist->events[idx].outcomestartdttm))
       SET searchlist->events[idx].loadstatus = "COMPLETE"
      ELSE
       SET searchlist->events[idx].markdttm = cnvtdatetime(worklist->events[i].lowerdttm)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   FREE RECORD worklist
 ENDWHILE
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_RESULTS2 temp")
  CALL echorecord(temp)
 ENDIF
 IF (value(size(temp->list,5)) <= 0)
  GO TO endscript
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p,
   (dummyt d  WITH seq = value(size(prsnl->list,5)))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=prsnl->list[d.seq].id))
  HEAD REPORT
   cnt = 0
  DETAIL
   FOR (i = 1 TO size(prsnl->list[d.seq].idxlist,5))
    curidx = prsnl->list[d.seq].idxlist[i].idx,temp->list[curidx].performprsnlname = trim(p
     .name_full_formatted)
   ENDFOR
  FOOT REPORT
   cnt = cnt
  WITH nocounter
 ;end select
 FREE RECORD prsnl
 SET preveventcd = 0
 SET eventcnt = 0
 SET resultcnt = 0
 FOR (i = 1 TO value(size(temp->list,5)))
   IF ((preveventcd != temp->list[i].eventcd))
    SET preveventcd = temp->list[i].eventcd
    IF (eventcnt > 0)
     SET stat = alterlist(coded->eventlist[eventcnt].resltlist,resultcnt)
    ENDIF
    SET eventcnt += 1
    IF (eventcnt > size(coded->eventlist,5))
     SET stat = alterlist(coded->eventlist,(eventcnt+ 20))
    ENDIF
    SET coded->eventlist[eventcnt].eventcd = temp->list[i].eventcd
    SET resultcnt = 0
   ENDIF
   SET idx = locateval(idx,1,resultcnt,temp->list[i].eventid,coded->eventlist[eventcnt].resltlist[idx
    ].eventid)
   IF (idx=0)
    SET resultcnt += 1
    IF (resultcnt > size(coded->eventlist[eventcnt].resltlist,5))
     SET stat = alterlist(coded->eventlist[eventcnt].resltlist,(resultcnt+ 20))
    ENDIF
    SET coded->eventlist[eventcnt].resltlist[resultcnt].eventid = temp->list[i].eventid
    SET stat = alterlist(coded->eventlist[eventcnt].resltlist[resultcnt].indexlist,1)
    SET coded->eventlist[eventcnt].resltlist[resultcnt].indexlist[1].idx = i
   ELSE
    SET idxtotal = value(size(coded->eventlist[eventcnt].resltlist[idx].indexlist,5))
    SET stat = alterlist(coded->eventlist[eventcnt].resltlist[idx].indexlist,(idxtotal+ 1))
    SET coded->eventlist[eventcnt].resltlist[idx].indexlist[(idxtotal+ 1)].idx = i
   ENDIF
 ENDFOR
 IF (resultcnt > 0)
  SET stat = alterlist(coded->eventlist[eventcnt].resltlist,resultcnt)
 ENDIF
 IF (eventcnt > 0)
  SET stat = alterlist(coded->eventlist,eventcnt)
 ENDIF
 FOR (i = 1 TO value(size(coded->eventlist,5)))
   SET num = 0
   SET max = 0
   SET start = 1
   SET high = value(size(coded->eventlist[i].resltlist,5))
   IF (high <= 150)
    SET stop = high
   ELSE
    SET stop = 150
   ENDIF
   SET loopcnt = 0
   WHILE (start <= stop)
     SELECT INTO "nl:"
      cd.event_id
      FROM ce_coded_result cd
      PLAN (cd
       WHERE expand(num,start,stop,cd.event_id,coded->eventlist[i].resltlist[num].eventid))
      ORDER BY cd.event_id, cd.sequence_nbr
      HEAD REPORT
       idx = 0
      HEAD cd.event_id
       cnt = 0, idx = locateval(idx,start,stop,cd.event_id,coded->eventlist[i].resltlist[idx].eventid
        )
      DETAIL
       IF (cd.valid_until_dt_tm=endoftime
        AND idx > 0)
        cnt += 1
        FOR (j = 1 TO size(coded->eventlist[i].resltlist[idx].indexlist,5))
          idx2 = coded->eventlist[i].resltlist[idx].indexlist[j].idx
          IF (cnt > size(temp->list[idx2].coded,5))
           stat = alterlist(temp->list[idx2].coded,(cnt+ 5))
          ENDIF
          temp->list[idx2].coded[cnt].nomenclatureid = cd.nomenclature_id, temp->list[idx2].coded[cnt
          ].sequencenbr = cd.sequence_nbr
        ENDFOR
       ENDIF
      FOOT  cd.event_id
       FOR (j = 1 TO size(coded->eventlist[i].resltlist[idx].indexlist,5))
        idx2 = coded->eventlist[i].resltlist[idx].indexlist[j].idx,stat = alterlist(temp->list[idx2].
         coded,cnt)
       ENDFOR
      FOOT REPORT
       cnt = cnt
      WITH nocounter
     ;end select
     SET start = (stop+ 1)
     IF ((high <= (stop+ 150)))
      SET stop = high
     ELSE
      SET stop += 150
     ENDIF
   ENDWHILE
 ENDFOR
 FREE RECORD coded
 SET ndynamiclabelcnt = value(size(dynamic_label->list,5))
 SET num = 0
 SET max = 0
 SET start = 1
 SET high = ndynamiclabelcnt
 IF (high <= 100)
  SET stop = high
 ELSE
  SET stop = 100
 ENDIF
 WHILE (start <= stop)
   SELECT INTO "nl:"
    FROM ce_dynamic_label cdl
    PLAN (cdl
     WHERE expand(num,start,stop,cdl.ce_dynamic_label_id,dynamic_label->list[num].cedynamiclabelid))
    HEAD REPORT
     nindex = 0
    DETAIL
     nindex = locateval(nindex,start,stop,cdl.ce_dynamic_label_id,dynamic_label->list[nindex].
      cedynamiclabelid)
     IF (nindex > 0)
      dynamic_label->list[nindex].labelname = cdl.label_name
     ENDIF
    FOOT REPORT
     nindex = 0
    WITH nocounter
   ;end select
   SET start = (stop+ 1)
   IF ((high <= (stop+ 100)))
    SET stop = high
   ELSE
    SET stop += 100
   ENDIF
 ENDWHILE
#endscript
 SELECT INTO "nl:"
  outcomeactid = searchlist->events[d1.seq].outcomeactid, eventenddttm = cnvtdatetime(temp->list[d2
   .seq].eventenddttm), eventid = temp->list[d2.seq].eventid
  FROM (dummyt d1  WITH seq = value(size(searchlist->events,5))),
   (dummyt d2  WITH seq = value(size(temp->list,5)))
  PLAN (d1)
   JOIN (d2
   WHERE (temp->list[d2.seq].outcomeactid=searchlist->events[d1.seq].outcomeactid))
  ORDER BY outcomeactid, eventenddttm
  HEAD REPORT
   eventcnt = 0
  HEAD outcomeactid
   eventcnt += 1
   IF (eventcnt > size(reply->events,5))
    stat = alterlist(reply->events,(eventcnt+ 20))
   ENDIF
   reply->events[eventcnt].eventcd = searchlist->events[d1.seq].eventcd, reply->events[eventcnt].
   outcomeactid = searchlist->events[d1.seq].outcomeactid, reply->events[eventcnt].loadstatus =
   searchlist->events[d1.seq].loadstatus,
   reply->events[eventcnt].markdttm = cnvtdatetime(searchlist->events[d1.seq].markdttm), resultcnt =
   0
  DETAIL
   IF (d2.seq > 0)
    resultcnt += 1
    IF (resultcnt > size(reply->events[eventcnt].results,5))
     stat = alterlist(reply->events[eventcnt].results,(resultcnt+ 20))
    ENDIF
    reply->events[eventcnt].results[resultcnt].clinicaleventid = temp->list[d2.seq].clinicaleventid,
    reply->events[eventcnt].results[resultcnt].eventid = temp->list[d2.seq].eventid, reply->events[
    eventcnt].results[resultcnt].encntrid = temp->list[d2.seq].encntrid,
    reply->events[eventcnt].results[resultcnt].resultval = temp->list[d2.seq].resultval, reply->
    events[eventcnt].results[resultcnt].resultunitscd = temp->list[d2.seq].resultunitscd, reply->
    events[eventcnt].results[resultcnt].resultunitsdisp = temp->list[d2.seq].resultunitsdisp,
    reply->events[eventcnt].results[resultcnt].eventenddttm = cnvtdatetime(temp->list[d2.seq].
     eventenddttm), reply->events[eventcnt].results[resultcnt].resultstatuscd = temp->list[d2.seq].
    resultstatuscd, reply->events[eventcnt].results[resultcnt].performdttm = cnvtdatetime(temp->list[
     d2.seq].performdttm),
    reply->events[eventcnt].results[resultcnt].performprsnlname = temp->list[d2.seq].performprsnlname,
    reply->events[eventcnt].results[resultcnt].updtcnt = temp->list[d2.seq].updtcnt, reply->events[
    eventcnt].results[resultcnt].entrymodecd = temp->list[d2.seq].entrymodecd,
    reply->events[eventcnt].results[resultcnt].accessionnbr = temp->list[d2.seq].accessionnbr, reply
    ->events[eventcnt].results[resultcnt].code = temp->list[d2.seq].code, reply->events[eventcnt].
    results[resultcnt].viewlevel = temp->list[d2.seq].viewlevel,
    reply->events[eventcnt].results[resultcnt].eventendtz = temp->list[d2.seq].eventendtz, reply->
    events[eventcnt].results[resultcnt].performtz = temp->list[d2.seq].performtz, reply->events[
    eventcnt].results[resultcnt].nomenstringflag = temp->list[d2.seq].nomenstringflag,
    reply->events[eventcnt].results[resultcnt].performprsnlid = temp->list[d2.seq].performprsnlid,
    codedtotal = size(temp->list[d2.seq].coded,5), stat = alterlist(reply->events[eventcnt].results[
     resultcnt].coded,codedtotal)
    FOR (j = 1 TO codedtotal)
     reply->events[eventcnt].results[resultcnt].coded[j].nomenclatureid = temp->list[d2.seq].coded[j]
     .nomenclatureid,reply->events[eventcnt].results[resultcnt].coded[j].sequencenbr = temp->list[d2
     .seq].coded[j].sequencenbr
    ENDFOR
    IF ((temp->list[d2.seq].cedynamiclabelid > 0.0)
     AND ndynamiclabelcnt > 0)
     nindex = locateval(nindex,1,ndynamiclabelcnt,temp->list[d2.seq].cedynamiclabelid,dynamic_label->
      list[nindex].cedynamiclabelid)
     IF (nindex > 0)
      reply->events[eventcnt].results[resultcnt].cedynamiclabelid = dynamic_label->list[nindex].
      cedynamiclabelid, reply->events[eventcnt].results[resultcnt].labelname = dynamic_label->list[
      nindex].labelname
     ENDIF
    ENDIF
   ENDIF
  FOOT  outcomeactid
   stat = alterlist(reply->events[eventcnt].results,resultcnt)
  FOOT REPORT
   stat = alterlist(reply->events,eventcnt)
  WITH nocounter, outerjoin = d1
 ;end select
 FREE RECORD temp
 FREE RECORD searchlist
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   SET failed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_RESULTS2 reply")
  CALL echorecord(reply)
 ENDIF
END GO
