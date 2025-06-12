CREATE PROGRAM dcp_get_outcome_results
 SET modify = predeclare
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_RESULTS request")
  CALL echorecord(request)
 ENDIF
 RECORD temp(
   1 list[*]
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
     2 nomenstringflag = i2
 )
 RECORD prsnl(
   1 list[*]
     2 id = f8
     2 idxlist[*]
       3 idx = i4
 )
 RECORD coded(
   1 list[*]
     2 eventid = f8
     2 idx = i4
 )
 RECORD dynamic_label(
   1 list[*]
     2 cedynamiclabelid = f8
     2 labelname = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE cdcnt = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE i = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE prsnlidx = i4 WITH noconstant(0)
 DECLARE prsnlhigh = i4 WITH noconstant(0)
 DECLARE eventcnt = i4 WITH noconstant(0)
 DECLARE resultcnt = i4 WITH noconstant(0)
 DECLARE codedtotal = i4 WITH noconstant(0)
 DECLARE preveventcd = f8 WITH noconstant(0.0)
 DECLARE ndynamiclabelcnt = i4 WITH noconstant(0)
 DECLARE nindex = i4 WITH noconstant(0)
 DECLARE endoftime = q8 WITH constant(cnvtdatetime("31-DEC-2100"))
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
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d  WITH seq = value(size(request->events,5)))
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=request->personid)
    AND (ce.event_cd=request->events[d.seq].eventcd)
    AND ce.event_end_dt_tm >= cnvtdatetime(request->events[d.seq].startdttm)
    AND ce.event_end_dt_tm <= cnvtdatetime(request->events[d.seq].enddttm))
  ORDER BY ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   cnt = 0, codedcnt = 0, ndynamiclabelcnt = 0
  DETAIL
   IF (((((ce.result_status_cd=auth) OR (((ce.result_status_cd=altered) OR (ce.result_status_cd=
   modified)) )) ) OR (ce.result_status_cd=inerror
    AND (request->loadinactiveresultsind=1)))
    AND ce.valid_until_dt_tm=endoftime)
    cnt += 1
    IF (cnt > size(temp->list,5))
     stat = alterlist(temp->list,(cnt+ 100))
    ENDIF
    temp->list[cnt].eventcd = ce.event_cd, temp->list[cnt].clinicaleventid = ce.clinical_event_id,
    temp->list[cnt].eventid = ce.event_id,
    temp->list[cnt].encntrid = ce.encntr_id, temp->list[cnt].resultval = trim(ce.result_val), temp->
    list[cnt].resultunitscd = ce.result_units_cd,
    temp->list[cnt].resultunitsdisp = trim(uar_get_code_display(ce.result_units_cd)), temp->list[cnt]
    .eventenddttm = cnvtdatetime(ce.event_end_dt_tm), temp->list[cnt].resultstatuscd = ce
    .result_status_cd,
    temp->list[cnt].performdttm = cnvtdatetime(ce.performed_dt_tm), temp->list[cnt].performprsnlid =
    ce.performed_prsnl_id, temp->list[cnt].updtcnt = ce.updt_cnt,
    temp->list[cnt].entrymodecd = ce.entry_mode_cd, temp->list[cnt].accessionnbr = ce.accession_nbr,
    temp->list[cnt].code = btest(ce.subtable_bit_map,15),
    temp->list[cnt].viewlevel = ce.view_level, temp->list[cnt].eventendtz = ce.event_end_tz, temp->
    list[cnt].performtz = ce.performed_tz,
    temp->list[cnt].nomenstringflag = ce.nomen_string_flag
    IF (ce.ce_dynamic_label_id > 0.0)
     temp->list[cnt].cedynamiclabelid = ce.ce_dynamic_label_id, nindex = 0
     IF (size(dynamic_label->list,5))
      nindex = locateval(nindex,1,ndynamiclabelcnt,ce.ce_dynamic_label_id,dynamic_label->list[nindex]
       .cedynamiclabelid)
     ENDIF
     IF (nindex < 1)
      ndynamiclabelcnt += 1
      IF (ndynamiclabelcnt > size(dynamic_label->list,5))
       stat = alterlist(dynamic_label->list,(ndynamiclabelcnt+ 50))
      ENDIF
      dynamic_label->list[ndynamiclabelcnt].cedynamiclabelid = ce.ce_dynamic_label_id
     ENDIF
    ENDIF
    IF ((temp->list[cnt].code=1))
     codedcnt += 1
     IF (codedcnt > size(coded->list,5))
      stat = alterlist(coded->list,(codedcnt+ 100))
     ENDIF
     coded->list[codedcnt].eventid = temp->list[cnt].eventid, coded->list[codedcnt].idx = cnt
    ENDIF
    prsnlhigh = size(prsnl->list,5), prsnlidx = 0, prsnlidx = locateval(prsnlidx,1,prsnlhigh,temp->
     list[cnt].performprsnlid,prsnl->list[prsnlidx].id)
    IF (prsnlidx > 0)
     curcnt = size(prsnl->list[prsnlidx].idxlist,5), stat = alterlist(prsnl->list[prsnlidx].idxlist,(
      curcnt+ 1)), prsnl->list[prsnlidx].idxlist[(curcnt+ 1)].idx = cnt
    ELSE
     curcnt = size(prsnl->list,5), stat = alterlist(prsnl->list,(curcnt+ 1)), prsnl->list[(curcnt+ 1)
     ].id = temp->list[cnt].performprsnlid,
     stat = alterlist(prsnl->list[(curcnt+ 1)].idxlist,1), prsnl->list[(curcnt+ 1)].idxlist[1].idx =
     cnt
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->list,cnt), stat = alterlist(coded->list,codedcnt), stat = alterlist(
    dynamic_label->list,ndynamiclabelcnt)
  WITH nocounter, orahintcbo("INDEX(ce XIE9CLINICAL_EVENT)")
 ;end select
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
 SET num = 0
 SET max = 0
 SET start = 1
 SET high = value(size(coded->list,5))
 IF (high <= 100)
  SET stop = high
 ELSE
  SET stop = 100
 ENDIF
 WHILE (start <= stop)
   SELECT INTO "nl:"
    cd.event_id
    FROM ce_coded_result cd
    PLAN (cd
     WHERE expand(num,start,stop,cd.event_id,coded->list[num].eventid))
    ORDER BY cd.event_id, cd.sequence_nbr
    HEAD REPORT
     idx = 0
    HEAD cd.event_id
     cnt = 0, idx2 = 0, idx = locateval(idx,start,stop,cd.event_id,coded->list[idx].eventid)
     IF (idx > 0)
      idx2 = coded->list[idx].idx
     ENDIF
    DETAIL
     IF (cd.valid_until_dt_tm=endoftime
      AND idx2 > 0)
      cnt += 1
      IF (cnt > size(temp->list[idx2].coded,5))
       stat = alterlist(temp->list[idx2].coded,(cnt+ 5))
      ENDIF
      temp->list[idx2].coded[cnt].nomenclatureid = cd.nomenclature_id, temp->list[idx2].coded[cnt].
      sequencenbr = cd.sequence_nbr
     ENDIF
    FOOT  cd.event_id
     stat = alterlist(temp->list[idx2].coded,cnt)
    FOOT REPORT
     cnt = cnt
    WITH nocounter
   ;end select
   SET start = (stop+ 1)
   IF ((high <= (stop+ 100)))
    SET stop = high
   ELSE
    SET stop += 100
   ENDIF
 ENDWHILE
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
 SET preveventcd = 0
 SET eventcnt = 0
 SET resultcnt = 0
 FOR (i = 1 TO value(size(temp->list,5)))
   IF ((preveventcd != temp->list[i].eventcd))
    SET preveventcd = temp->list[i].eventcd
    IF (eventcnt > 0)
     SET stat = alterlist(reply->events[eventcnt].results,resultcnt)
    ENDIF
    SET eventcnt += 1
    IF (eventcnt > size(reply->events,5))
     SET stat = alterlist(reply->events,(eventcnt+ 20))
    ENDIF
    SET reply->events[eventcnt].eventcd = temp->list[i].eventcd
    SET resultcnt = 0
   ENDIF
   SET resultcnt += 1
   IF (resultcnt > size(reply->events[eventcnt].results,5))
    SET stat = alterlist(reply->events[eventcnt].results,(resultcnt+ 20))
   ENDIF
   SET reply->events[eventcnt].results[resultcnt].clinicaleventid = temp->list[i].clinicaleventid
   SET reply->events[eventcnt].results[resultcnt].eventid = temp->list[i].eventid
   SET reply->events[eventcnt].results[resultcnt].encntrid = temp->list[i].encntrid
   SET reply->events[eventcnt].results[resultcnt].resultval = temp->list[i].resultval
   SET reply->events[eventcnt].results[resultcnt].resultunitscd = temp->list[i].resultunitscd
   SET reply->events[eventcnt].results[resultcnt].resultunitsdisp = temp->list[i].resultunitsdisp
   SET reply->events[eventcnt].results[resultcnt].eventenddttm = cnvtdatetime(temp->list[i].
    eventenddttm)
   SET reply->events[eventcnt].results[resultcnt].resultstatuscd = temp->list[i].resultstatuscd
   SET reply->events[eventcnt].results[resultcnt].performdttm = cnvtdatetime(temp->list[i].
    performdttm)
   SET reply->events[eventcnt].results[resultcnt].performprsnlname = temp->list[i].performprsnlname
   SET reply->events[eventcnt].results[resultcnt].updtcnt = temp->list[i].updtcnt
   SET reply->events[eventcnt].results[resultcnt].entrymodecd = temp->list[i].entrymodecd
   SET reply->events[eventcnt].results[resultcnt].accessionnbr = temp->list[i].accessionnbr
   SET reply->events[eventcnt].results[resultcnt].code = temp->list[i].code
   SET reply->events[eventcnt].results[resultcnt].viewlevel = temp->list[i].viewlevel
   SET reply->events[eventcnt].results[resultcnt].eventendtz = temp->list[i].eventendtz
   SET reply->events[eventcnt].results[resultcnt].performtz = temp->list[i].performtz
   SET reply->events[eventcnt].results[resultcnt].nomenstringflag = temp->list[i].nomenstringflag
   SET reply->events[eventcnt].results[resultcnt].performprsnlid = temp->list[i].performprsnlid
   SET codedtotal = value(size(temp->list[i].coded,5))
   SET stat = alterlist(reply->events[eventcnt].results[resultcnt].coded,codedtotal)
   FOR (j = 1 TO codedtotal)
    SET reply->events[eventcnt].results[resultcnt].coded[j].nomenclatureid = temp->list[i].coded[j].
    nomenclatureid
    SET reply->events[eventcnt].results[resultcnt].coded[j].sequencenbr = temp->list[i].coded[j].
    sequencenbr
   ENDFOR
   IF ((temp->list[i].cedynamiclabelid > 0.0))
    SET nindex = locateval(nindex,1,ndynamiclabelcnt,temp->list[i].cedynamiclabelid,dynamic_label->
     list[nindex].cedynamiclabelid)
    IF (nindex > 0)
     SET reply->events[eventcnt].results[resultcnt].cedynamiclabelid = temp->list[i].cedynamiclabelid
     SET reply->events[eventcnt].results[resultcnt].labelname = dynamic_label->list[nindex].labelname
    ENDIF
   ENDIF
 ENDFOR
 IF (resultcnt > 0)
  SET stat = alterlist(reply->events[eventcnt].results,resultcnt)
 ENDIF
 IF (eventcnt > 0)
  SET stat = alterlist(reply->events,eventcnt)
 ENDIF
 FREE RECORD temp
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   SET cfailed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#endscript
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_RESULTS reply")
  CALL echorecord(reply)
 ENDIF
END GO
