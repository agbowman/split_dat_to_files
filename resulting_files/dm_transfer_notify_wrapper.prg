CREATE PROGRAM dm_transfer_notify_wrapper
 SET trace = rdbdebug
 SET trace = rdbbind
 CALL echo("...")
 CALL echo("dm_transfer_notify_wrapper")
 CALL echo("...")
 DECLARE serrormessage = vc WITH protect, noconstant("")
 IF (validate(cmb_notify_events->events,"NONE")="NONE")
  FREE RECORD cmb_notify_events
  RECORD cmb_notify_events(
    1 events[*]
      2 event_type = c12
      2 primary_ind = i2
      2 combine_id = f8
      2 parent_table = c50
      2 from_xxx_id = f8
      2 to_xxx_id = f8
      2 encntr_id = f8
  ) WITH protect
 ENDIF
 SUBROUTINE (cmb_notify(cmb_notify_req=vc(ref)) =null)
   IF (size(cmb_notify_req->events,5) > 0)
    DECLARE ireqid = i4 WITH protect, constant(50002)
    SET stat = tdbexecute(reqinfo->updt_app,reqinfo->updt_task,ireqid,"REC",cmb_notify_req,
     "REC",replyout)
    IF (stat != 0)
     SET serrormessage = "tdbexecute"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(stat,10)
    ENDIF
   ELSE
    SET serrormessage = "cmb_notify_req list size is zero."
   ENDIF
   IF (textlen(trim(serrormessage,3)) > 0)
    SET reply->status_data.subeventstatus[1].operationname = trim(serrormessage)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   ENDIF
   SET stat = initrec(cmb_notify_req)
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE (transfer_notify_data(seventtype=c12,bprimaryind=i2,dcombineid=f8,sparenttable=c50,
  dfromid=f8,dtoid=f8,dencntrid=f8,cmb_notify_req=vc(ref)) =null)
   DECLARE lcount = i4 WITH noconstant(0), protect
   DECLARE listsize = i4 WITH noconstant(0), protect
   SET listsize = size(cmb_notify_req->events,5)
   IF ( NOT (locateval(lcount,1,listsize,dcombineid,cmb_notify_req->events[lcount].combine_id,
    sparenttable,cmb_notify_req->events[lcount].parent_table)))
    SET listsize += 1
    SET stat = alterlist(cmb_notify_req->events,listsize)
    SET cmb_notify_req->events[listsize].event_type = seventtype
    SET cmb_notify_req->events[listsize].primary_ind = bprimaryind
    SET cmb_notify_req->events[listsize].combine_id = dcombineid
    SET cmb_notify_req->events[listsize].parent_table = sparenttable
    SET cmb_notify_req->events[listsize].from_xxx_id = dfromid
    SET cmb_notify_req->events[listsize].to_xxx_id = dtoid
    SET cmb_notify_req->events[listsize].encntr_id = dencntrid
   ENDIF
 END ;Subroutine
 IF (validate(m_sevent_type,"NONE")="NONE")
  DECLARE sevent_type = c12 WITH noconstant(""), protect
  DECLARE bprimary_ind = i2 WITH noconstant(0), protect
  DECLARE dcombine_id = f8 WITH noconstant(0.0), protect
  DECLARE sparent_table = c50 WITH noconstant(""), protect
  DECLARE dfrom_id = f8 WITH noconstant(0.0), protect
  DECLARE dto_id = f8 WITH noconstant(0.0), protect
  DECLARE dencntr_id = f8 WITH noconstant(0.0), protect
 ENDIF
 CALL transfer_notify_data(sevent_type,bprimary_ind,dcombine_id,sparent_table,dfrom_id,
  dto_id,dencntr_id,cmb_notify_events)
 SET trace = nordbdebug
 SET trace = nordbbind
END GO
