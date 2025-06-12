CREATE PROGRAM cdi_get_work_items_for_queue:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 qual[*]
      2 work_queue_id = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 qual[*]
      2 work_queue_id = f8
      2 work_item_qual[*]
        3 work_item_id = f8
        3 clarify_reason = vc
        3 comments = vc
        3 create_dt_tm = dq8
        3 owner_prsnl_id = vc
        3 priority = vc
        3 status = vc
        3 encntr_id = f8
        3 person_id = f8
        3 blob_handle = vc
        3 document_type = vc
        3 batch_class = vc
        3 capture_location = vc
        3 service_dt_tm = dq8
        3 subject = vc
        3 parent_level = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lreq_size = i4 WITH protect, constant(size(request->qual,5))
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_WORK_ITEMS_FOR_QUEUE **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Work Items Found"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->qual,lreq_size)
 FOR (lidx = 1 TO lreq_size)
   SET reply->qual[lidx].work_queue_id = request->qual[lidx].work_queue_id
 ENDFOR
 SELECT INTO "nl:"
  FROM cdi_work_queue_item_reltn cwqir,
   cdi_work_item cwi,
   (left JOIN long_text lt ON lt.long_text_id=cwi.comment_id),
   (left JOIN prsnl p ON p.person_id=cwi.owner_prsnl_id),
   (left JOIN cdi_pending_document cpd ON cpd.cdi_pending_document_id=cwi.parent_entity_id
    AND cwi.parent_entity_name="CDI_PENDING_DOCUMENT"),
   (left JOIN code_value_extension cve ON cve.code_value=cpd.event_cd),
   (left JOIN cdi_pending_batch cpb ON cpb.cdi_pending_batch_id=cpd.cdi_pending_batch_id
    AND cpb.cdi_pending_batch_id > 0),
   (left JOIN cdi_ac_batchclass cab ON cab.cdi_ac_batchclass_id=cpb.cdi_ac_batchclass_id
    AND cab.cdi_ac_batchclass_id > 0)
  PLAN (cwqir
   WHERE expand(lidx,1,lreq_size,cwqir.cdi_work_queue_id,request->qual[lidx].work_queue_id)
    AND cwqir.cdi_work_queue_id > 0
    AND cwqir.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cwi
   WHERE cwi.cdi_work_item_id=cwqir.cdi_work_item_id)
   JOIN (lt)
   JOIN (p)
   JOIN (cpd)
   JOIN (cve)
   JOIN (cpb)
   JOIN (cab)
  ORDER BY cwqir.cdi_work_queue_id, cwi.cdi_work_item_id
  HEAD cwqir.cdi_work_queue_id
   lcnt = 0, lpos = locateval(lidx,1,lreq_size,cwqir.cdi_work_queue_id,reply->qual[lidx].
    work_queue_id)
  HEAD cwi.cdi_work_item_id
   IF (lpos > 0)
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(reply->qual[lpos].work_item_qual,(lcnt+ 9))
    ENDIF
    reply->qual[lpos].work_item_qual[lcnt].work_item_id = cwi.cdi_work_item_id, reply->qual[lpos].
    work_item_qual[lcnt].clarify_reason = uar_get_code_display(cwi.clarify_reason_cd)
    IF (lt.long_text_id > 0)
     reply->qual[lpos].work_item_qual[lcnt].comments = lt.long_text
    ENDIF
    reply->qual[lpos].work_item_qual[lcnt].create_dt_tm = cwi.create_dt_tm
    IF (p.person_id > 0)
     reply->qual[lpos].work_item_qual[lcnt].owner_prsnl_id = p.name_full_formatted
    ENDIF
    reply->qual[lpos].work_item_qual[lcnt].priority = uar_get_code_display(cwi.priority_cd), reply->
    qual[lpos].work_item_qual[lcnt].status = uar_get_code_display(cwi.status_cd)
    IF (cpd.cdi_pending_document_id > 0)
     reply->qual[lpos].work_item_qual[lcnt].encntr_id = cpd.encntr_id, reply->qual[lpos].
     work_item_qual[lcnt].person_id = cpd.person_id, reply->qual[lpos].work_item_qual[lcnt].
     blob_handle = cpd.blob_handle,
     reply->qual[lpos].work_item_qual[lcnt].document_type = uar_get_code_display(cpd.event_cd), reply
     ->qual[lpos].work_item_qual[lcnt].capture_location = cpd.capture_loc_name, reply->qual[lpos].
     work_item_qual[lcnt].service_dt_tm = cpd.service_dt_tm,
     reply->qual[lpos].work_item_qual[lcnt].subject = cpd.subject_text, reply->qual[lpos].
     work_item_qual[lcnt].parent_level = cve.field_value
     IF (cab.cdi_ac_batchclass_id > 0)
      reply->qual[lpos].work_item_qual[lcnt].batch_class = cab.batchclass_name
     ENDIF
    ENDIF
    sscriptstatus = "S"
   ENDIF
  FOOT  cwi.cdi_work_item_id
   dstat = 0
  FOOT  cwqir.cdi_work_queue_id
   IF (lpos > 0)
    dstat = alterlist(reply->qual[lpos].work_item_qual,lcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (sscriptstatus="F")
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No Work Items Found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_items_for_queue"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_items_for_queue"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_work_items_for_queue"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Work Items Found"
 ENDIF
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 09/22/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_WORK_ITEMS_FOR_QUEUE **********")
 CALL echo(sline)
END GO
