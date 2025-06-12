CREATE PROGRAM ce_fix_event_tag_utc:dba
 EXECUTE cclseclogin
 RECORD recordstatus(
   1 rdm_current_status = c1
 )
 SET rdm_current_status = "F"
 RECORD eventidlist(
   1 eidlist[*]
     2 event_id = f8
 )
 RECORD failedeventidlist(
   1 feidlist[*]
     2 fevent_id = f8
 )
 IF (curutc)
  DECLARE eid_cnt = i4
  SET eid_cnt = 0
  SELECT INTO "nl:"
   cedr.event_id, ce.event_id
   FROM ce_date_result cedr,
    clinical_event ce
   PLAN (cedr
    WHERE cedr.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    JOIN (ce
    WHERE ce.event_id=cedr.event_id
     AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
     AND  EXISTS (
    (SELECT
     ce2.event_id
     FROM clinical_event ce2
     WHERE ce2.event_id=ce.parent_event_id)))
   ORDER BY cedr.event_id
   DETAIL
    eid_cnt += 1
    IF (mod(eid_cnt,500)=1)
     stat = alterlist(eventidlist->eidlist,(eid_cnt+ 500))
    ENDIF
    eventidlist->eidlist[eid_cnt].event_id = cedr.event_id
   WITH nocounter
  ;end select
  SET stat = alterlist(eventidlist->eidlist,eid_cnt)
  DECLARE applicationid = i4
  DECLARE happ = i4
  DECLARE iret = i4
  DECLARE htask = i4
  DECLARE taskid = i4
  DECLARE hstep = i4
  DECLARE requestid = i4
  DECLARE numsrvitemsadded = i4
  DECLARE numitemstoadd = i4
  DECLARE lastsuccesseventid = i4
  DECLARE arraysize = i4
  DECLARE failedarrayidx = i4
  SET applicationid = 1000069
  SET taskid = 1000069
  SET requestid = 1000069
  CALL echo("****Start Fix Event Tag CE Readme")
  SET iret = uar_crmbeginapp(applicationid,happ)
  IF (iret != 0)
   CALL echo(build("App error: ",iret))
   RETURN
  ENDIF
  SET iret = uar_crmbegintask(happ,taskid,htask)
  IF (iret != 0)
   CALL echo(build("Task error: ",iret))
   RETURN
  ENDIF
  SET numsrvitemsadded = 0
  SET arraysize = size(eventidlist->eidlist,5)
  SET failedarrayidx = 0
  WHILE (numsrvitemsadded < arraysize)
    SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
    IF (iret != 0)
     CALL echo(build("Request Error: ",iret))
     RETURN
    ENDIF
    SET hreq = uar_crmgetrequest(hstep)
    SET numitemstoadd = (arraysize - numsrvitemsadded)
    IF (numitemstoadd >= 100)
     FOR (cnt1 = (numsrvitemsadded+ 1) TO (numsrvitemsadded+ 100))
       SET hitem = uar_srvadditem(hreq,"event_list")
       SET srvstat = uar_srvsetdouble(hitem,"event_id",eventidlist->eidlist[cnt1].event_id)
       CALL echo(build("event_id: ",eventidlist->eidlist[cnt1].event_id))
     ENDFOR
     SET iret = uar_crmperform(hstep)
     CALL echo(build("uar_CrmPerform returned:",iret))
     CALL echo(build("****End Fix Event Tag CE Readme, Return Code: ",iret))
     CALL uar_crmendreq(hstep)
     IF (iret != 0)
      CALL echo(build(" step failed - last successful event_id:  ",lastsuccesseventid))
      FOR (cntsingle = (numsrvitemsadded+ 1) TO (numsrvitemsadded+ 100))
        SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
        IF (iret != 0)
         CALL echo(build("Request Error: ",iret))
         RETURN
        ENDIF
        SET hreq = uar_crmgetrequest(hstep)
        SET hitem = uar_srvadditem(hreq,"event_list")
        SET srvstat = uar_srvsetdouble(hitem,"event_id",eventidlist->eidlist[cntsingle].event_id)
        SET iret = uar_crmperform(hstep)
        CALL echo(build("uar_CrmPerform returned:",iret))
        CALL echo(build("****End Fix Event Tag CE Readme, Return Code: ",iret))
        IF (iret != 0)
         SET failedarrayidx += 1
         IF (mod(failedarrayidx,100)=1)
          SET stat = alterlist(failedeventidlist->feidlist,(failedarrayidx+ 100))
         ENDIF
         SET failedeventidlist->feidlist[failedarrayidx].fevent_id = eventidlist->eidlist[cntsingle].
         event_id
         CALL echo(build("Event_id skipped: ",eventidlist->eidlist[cntsingle].event_id))
        ENDIF
        CALL uar_crmendreq(hstep)
      ENDFOR
     ELSE
      SET lastsuccesseventid = eventidlist->eidlist[numsrvitemsadded].event_id
      CALL echo(build("last successful event_id:  ",lastsuccesseventid))
     ENDIF
     SET numsrvitemsadded += 100
    ELSE
     FOR (cnt2 = (numsrvitemsadded+ 1) TO (numsrvitemsadded+ numitemstoadd))
      SET hitem = uar_srvadditem(hreq,"event_list")
      SET srvstat = uar_srvsetdouble(hitem,"event_id",eventidlist->eidlist[cnt2].event_id)
     ENDFOR
     SET iret = uar_crmperform(hstep)
     CALL echo(build("uar_CrmPerform returned:",iret))
     CALL echo(build("****End Fix Event Tag CE Readme, Return Code: ",iret))
     CALL uar_crmendreq(hstep)
     IF (iret != 0)
      CALL echo(build(" step failed - last successful event_id:  ",lastsuccesseventid))
      FOR (cnt2single = (numsrvitemsadded+ 1) TO (numsrvitemsadded+ numitemstoadd))
        SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
        IF (iret != 0)
         CALL echo(build("Request Error: ",iret))
         RETURN
        ENDIF
        SET hreq = uar_crmgetrequest(hstep)
        SET hitem = uar_srvadditem(hreq,"event_list")
        SET srvstat = uar_srvsetdouble(hitem,"event_id",eventidlist->eidlist[cnt2single].event_id)
        SET iret = uar_crmperform(hstep)
        CALL echo(build("uar_CrmPerform returned:",iret))
        CALL echo(build("****End Fix Event Tag CE Readme, Return Code: ",iret))
        IF (iret != 0)
         SET failedarrayidx += 1
         IF (mod(failedarrayidx,100)=1)
          SET stat = alterlist(failedeventidlist->feidlist,(failedarrayidx+ 100))
         ENDIF
         SET failedeventidlist->feidlist[failedarrayidx].fevent_id = eventidlist->eidlist[cnt2single]
         .event_id
         CALL echo(build("Event_id skipped: ",eventidlist->eidlist[cnt2single].event_id))
        ENDIF
        CALL uar_crmendreq(hstep)
      ENDFOR
     ELSE
      SET lastsuccesseventid = eventidlist->eidlist[numsrvitemsadded].event_id
      CALL echo(build("last successful event_id:  ",lastsuccesseventid))
     ENDIF
     SET numsrvitemsadded += numitemstoadd
    ENDIF
  ENDWHILE
  SET stat = alterlist(failedeventidlist->feidlist,failedarrayidx)
  SELECT INTO "ce_utc_event_id.txt"
   cedr.event_id
   FROM ce_date_result cedr,
    (dummyt d  WITH seq = value(size(failedeventidlist->feidlist,5)))
   PLAN (d)
    JOIN (cedr
    WHERE (cedr.event_id=failedeventidlist->feidlist[d.seq].fevent_id))
   ORDER BY cedr.event_id
  ;end select
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
 ENDIF
 IF (curutc)
  CALL echo(build("UTC is ON:  ",curutc))
 ELSE
  CALL echo(build("UTC is OFF:  ",curutc))
 ENDIF
 SET recordstatus->rdm_current_status = "S"
END GO
