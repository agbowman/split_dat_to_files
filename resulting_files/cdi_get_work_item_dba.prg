CREATE PROGRAM cdi_get_work_item:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 qual[*]
      2 work_item_id = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 qual[*]
      2 qual_status = c1
      2 qual_status_reason = vc
      2 work_item_id = f8
      2 clarify_reason = vc
      2 clarify_reason_cd = f8
      2 comments = vc
      2 comment_id = f8
      2 create_dt_tm = dq8
      2 owner_prsnl_name = vc
      2 owner_prsnl_id = f8
      2 owner_username = vc
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 priority = vc
      2 priority_cd = f8
      2 status = vc
      2 status_cd = f8
      2 encntr_id = f8
      2 person_id = f8
      2 blob_handle = vc
      2 document_type = vc
      2 document_type_alias = vc
      2 event_cd = f8
      2 clinicalind = i2
      2 doc_parent_entity_name = vc
      2 doc_parent_entity_id = f8
      2 batch_class = vc
      2 capture_location = vc
      2 service_dt_tm = dq8
      2 subject = vc
      2 batch_create_dt_tm = dq8
      2 batch_name = vc
      2 sending_location = vc
      2 patient_name = vc
      2 free_text[*]
        3 display_cd_val = f8
        3 value = vc
      2 scan_dt_tm = dq8
      2 updt_cnt = i4
      2 category = vc
      2 category_cd = f8
      2 ordering_provider = vc
      2 ordering_provider_id = f8
      2 location_cd = f8
      2 work_item_action[*]
        3 work_item_action_id = f8
        3 action_prsnl_id = f8
        3 action_prsnl_name = vc
        3 comment = vc
        3 work_item_action_type_flag = i2
        3 work_item_action_dt_tm = dq8
        3 fax_status = vc
        3 fax_status_cd = f8
        3 predefined_comment_cd = f8
        3 predefined_comment_display = vc
        3 follow_up_dt_tm = dq8
      2 code_attribute[*]
        3 attribute_type_code = f8
        3 code_attribute_value[*]
          4 attribute_type_value = f8
          4 attribute_type_display = vc
      2 auto_dial_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
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
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE attrcount = i4 WITH protect, noconstant(0)
 DECLARE actioncount = i4 WITH protect, noconstant(0)
 DECLARE actionsloaded = i2 WITH protect, noconstant(false)
 DECLARE codeattrcount = i4 WITH protect, noconstant(0)
 DECLARE codeattrvaluecount = i4 WITH protect, noconstant(0)
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_GET_WORK_ITEM **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->qual,lreq_size)
 FOR (lidx = 1 TO lreq_size)
   SET reply->qual[lidx].work_item_id = request->qual[lidx].work_item_id
   SET reply->qual[lidx].qual_status = "F"
   SET reply->qual[lidx].qual_status_reason = "Invalid work_item_id"
 ENDFOR
 SELECT INTO "nl:"
  FROM cdi_work_item wi,
   (left JOIN cdi_work_item_attribute attr ON attr.cdi_work_item_id=wi.cdi_work_item_id),
   (left JOIN long_text lt ON lt.long_text_id=wi.comment_id),
   (left JOIN cdi_work_item_action action ON action.cdi_work_item_id=wi.cdi_work_item_id),
   (left JOIN long_text actioncomment ON actioncomment.long_text_id=action.long_text_id),
   (left JOIN prsnl p ON p.person_id=wi.owner_prsnl_id),
   (left JOIN prsnl pro ON pro.person_id=wi.ordering_provider_id),
   (left JOIN prsnl actionprsnl ON actionprsnl.person_id=action.action_prsnl_id),
   (left JOIN cdi_pending_document cpd ON cpd.cdi_pending_document_id=wi.parent_entity_id
    AND wi.parent_entity_name="CDI_PENDING_DOCUMENT"),
   (left JOIN cdi_doc_entity_reltn dereltn ON dereltn.cdi_pending_document_id=cpd
   .cdi_pending_document_id
    AND dereltn.cdi_doc_entity_reltn_id > 0),
   (left JOIN cdi_pending_batch cpb ON cpb.cdi_pending_batch_id=cpd.cdi_pending_batch_id
    AND cpb.cdi_pending_batch_id > 0),
   (left JOIN cdi_ac_batchclass cab ON cab.cdi_ac_batchclass_id=cpb.cdi_ac_batchclass_id
    AND cab.cdi_ac_batchclass_id > 0),
   (left JOIN device d ON cpd.capture_loc_name=d.name),
   (left JOIN code_value cv ON d.location_cd=cv.code_value
    AND cv.active_ind=1),
   (left JOIN report_queue rq ON action.outputctx_handle_id=rq.output_handle_id
    AND action.outputctx_handle_id > 0)
  PLAN (wi
   WHERE expand(lidx,1,lreq_size,wi.cdi_work_item_id,request->qual[lidx].work_item_id)
    AND wi.cdi_work_item_id > 0)
   JOIN (attr)
   JOIN (lt)
   JOIN (action)
   JOIN (actioncomment)
   JOIN (p)
   JOIN (pro)
   JOIN (actionprsnl)
   JOIN (cpd)
   JOIN (dereltn)
   JOIN (cpb)
   JOIN (cab)
   JOIN (d)
   JOIN (cv)
   JOIN (rq)
  ORDER BY wi.cdi_work_item_id, attr.attribute_cd, attr.cdi_work_item_attribute_id,
   action.action_dt_tm
  HEAD wi.cdi_work_item_id
   actionsloaded = false, lpos = locateval(lidx,1,lreq_size,wi.cdi_work_item_id,reply->qual[lidx].
    work_item_id)
   IF (lpos > 0)
    lscnt += 1, reply->qual[lidx].qual_status = "S", reply->qual[lidx].qual_status_reason = "",
    reply->qual[lpos].work_item_id = wi.cdi_work_item_id, reply->qual[lpos].clarify_reason =
    uar_get_code_display(wi.clarify_reason_cd), reply->qual[lpos].clarify_reason_cd = wi
    .clarify_reason_cd
    IF (lt.long_text_id > 0)
     reply->qual[lpos].comments = lt.long_text, reply->qual[lpos].comment_id = lt.long_text_id
    ENDIF
    reply->qual[lpos].create_dt_tm = wi.create_dt_tm
    IF (p.person_id > 0)
     reply->qual[lpos].owner_prsnl_name = p.name_full_formatted, reply->qual[lpos].owner_prsnl_id = p
     .person_id, reply->qual[lpos].owner_username = p.username
    ENDIF
    reply->qual[lpos].parent_entity_id = wi.parent_entity_id, reply->qual[lpos].parent_entity_name =
    wi.parent_entity_name, reply->qual[lpos].priority = uar_get_code_display(wi.priority_cd),
    reply->qual[lpos].priority_cd = wi.priority_cd, reply->qual[lpos].status = uar_get_code_display(
     wi.status_cd), reply->qual[lpos].status_cd = wi.status_cd,
    reply->qual[lpos].updt_cnt = wi.updt_cnt, reply->qual[lpos].category = uar_get_code_display(wi
     .category_cd), reply->qual[lpos].category_cd = wi.category_cd,
    reply->qual[lpos].auto_dial_ind = wi.auto_dial_ind
    IF (pro.person_id > 0)
     reply->qual[lpos].ordering_provider = pro.name_full_formatted, reply->qual[lpos].
     ordering_provider_id = pro.person_id
    ENDIF
    IF (cpd.cdi_pending_document_id > 0)
     reply->qual[lpos].encntr_id = cpd.encntr_id, reply->qual[lpos].person_id = cpd.person_id, reply
     ->qual[lpos].blob_handle = cpd.blob_handle,
     reply->qual[lpos].document_type = cpd.doc_type_name, reply->qual[lpos].document_type_alias = cpd
     .doc_type_alias, reply->qual[lpos].capture_location = cpd.capture_loc_name,
     reply->qual[lpos].scan_dt_tm = cpd.scan_dt_tm, reply->qual[lpos].service_dt_tm = cpd
     .service_dt_tm, reply->qual[lpos].subject = cpd.subject_text,
     reply->qual[lpos].patient_name = cpd.patient_name, reply->qual[lpos].event_cd = cpd.event_cd
     IF (cpd.event_codeset=72)
      reply->qual[lpos].clinicalind = 1
     ELSE
      reply->qual[lpos].clinicalind = 0
     ENDIF
     IF (dereltn.cdi_pending_document_id > 0)
      reply->qual[lpos].doc_parent_entity_name = dereltn.parent_entity_name, reply->qual[lpos].
      doc_parent_entity_id = dereltn.parent_entity_id
     ENDIF
     IF (cpb.cdi_pending_batch_id > 0)
      reply->qual[lpos].batch_create_dt_tm = cpb.batch_create_dt_tm, reply->qual[lpos].batch_name =
      cpb.batch_name
     ENDIF
     IF (cab.cdi_ac_batchclass_id > 0)
      reply->qual[lpos].batch_class = cab.batchclass_name
     ENDIF
     IF (cpd.location_cd > 0)
      reply->qual[lpos].location_cd = cpd.location_cd, reply->qual[lpos].sending_location =
      uar_get_code_display(cpd.location_cd)
     ELSE
      reply->qual[lpos].location_cd = d.location_cd, reply->qual[lpos].sending_location =
      uar_get_code_display(d.location_cd)
     ENDIF
    ENDIF
    sscriptstatus = "S"
   ENDIF
   attrcount = 0, actioncount = 0, codeattrcount = 0,
   codeattrvaluecount = 0
  HEAD attr.attribute_cd
   IF (attr.attr_value_cd > 0)
    codeattrcount += 1
    IF (mod(codeattrcount,10)=1)
     dstat = alterlist(reply->qual[lpos].code_attribute,(codeattrcount+ 9))
    ENDIF
    codeattrvaluecount = 0, reply->qual[lpos].code_attribute[codeattrcount].attribute_type_code =
    attr.attribute_cd
   ENDIF
  HEAD attr.cdi_work_item_attribute_id
   IF (attr.cdi_work_item_attribute_id > 0)
    IF (attr.attr_value_cd=0)
     attrcount += 1
     IF (mod(attrcount,10)=1)
      dstat = alterlist(reply->qual[lpos].free_text,(attrcount+ 9))
     ENDIF
     reply->qual[lpos].free_text[attrcount].display_cd_val = attr.attribute_cd, reply->qual[lpos].
     free_text[attrcount].value = attr.attr_value_txt
    ELSE
     codeattrvaluecount += 1
     IF (mod(codeattrvaluecount,10)=1)
      dstat = alterlist(reply->qual[lpos].code_attribute[codeattrcount].code_attribute_value,(
       codeattrvaluecount+ 9))
     ENDIF
     reply->qual[lpos].code_attribute[codeattrcount].code_attribute_value[codeattrvaluecount].
     attribute_type_value = attr.attr_value_cd, reply->qual[lpos].code_attribute[codeattrcount].
     code_attribute_value[codeattrvaluecount].attribute_type_display = uar_get_code_display(attr
      .attr_value_cd)
    ENDIF
   ENDIF
  DETAIL
   IF (action.cdi_work_item_action_id > 0
    AND actionsloaded=false)
    actioncount += 1
    IF (mod(actioncount,10)=1)
     dstat = alterlist(reply->qual[lpos].work_item_action,(actioncount+ 9))
    ENDIF
    reply->qual[lpos].work_item_action[actioncount].work_item_action_id = action
    .cdi_work_item_action_id, reply->qual[lpos].work_item_action[actioncount].action_prsnl_id =
    action.action_prsnl_id, reply->qual[lpos].work_item_action[actioncount].action_prsnl_name =
    actionprsnl.name_full_formatted
    IF (actioncomment.long_text_id > 0)
     reply->qual[lpos].work_item_action[actioncount].comment = actioncomment.long_text
    ENDIF
    reply->qual[lpos].work_item_action[actioncount].work_item_action_type_flag = action
    .action_type_flag, reply->qual[lpos].work_item_action[actioncount].work_item_action_dt_tm =
    action.action_dt_tm, reply->qual[lpos].work_item_action[actioncount].fax_status_cd = rq
    .transmission_status_cd,
    reply->qual[lpos].work_item_action[actioncount].fax_status = uar_get_code_display(rq
     .transmission_status_cd), reply->qual[lpos].work_item_action[actioncount].predefined_comment_cd
     = action.comment_cd, reply->qual[lpos].work_item_action[actioncount].predefined_comment_display
     = uar_get_code_display(action.comment_cd),
    reply->qual[lpos].work_item_action[actioncount].follow_up_dt_tm = action.follow_up_dt_tm
   ENDIF
  FOOT  attr.cdi_work_item_attribute_id
   actionsloaded = true, dstat = alterlist(reply->qual[lpos].work_item_action,actioncount)
  FOOT  attr.attribute_cd
   IF (codeattrcount > 0)
    dstat = alterlist(reply->qual[lpos].code_attribute[codeattrcount].code_attribute_value,
     codeattrvaluecount)
   ENDIF
  FOOT  wi.cdi_work_item_id
   dstat = alterlist(reply->qual[lpos].code_attribute,codeattrcount), dstat = alterlist(reply->qual[
    lpos].free_text,attrcount)
  WITH nocounter
 ;end select
 IF (lscnt=size(reply->qual,5))
  SET sscriptstatus = "S"
  SET sscriptmsg = "All work items were found"
 ELSEIF (lscnt > 0)
  SET sscriptstatus = "S"
  SET sscriptmsg = "Some work items were not found, check individual status"
 ELSE
  SET sscriptstatus = "Z"
  SET sscriptmsg = "All work items were not found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 CALL alterlist(reply->subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_GET_WORK_ITEM"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 11/11/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_WORK_ITEM **********")
 CALL echo(sline)
END GO
