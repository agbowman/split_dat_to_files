CREATE PROGRAM add_rxmsg_audit:dba
 RECORD internal(
   1 qual[*]
     2 status = i2
 )
 RECORD reply(
   1 audit_failure_list[*]
     2 order_id = f8
   1 audit_added_list[*]
     2 rx_identifier = c30
     2 messaging_audit_id = f8
     2 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET messaging_audit_id = 0.0
 SET msg_text_id = 0.0
 SET failures = 0
 SET added = 0
 SET audits_to_add = size(request->audit_list,5)
 SET stat = alterlist(internal->qual,audits_to_add)
 IF (audits_to_add=0)
  GO TO exit_script
 ENDIF
 FOR (knt = 1 TO audits_to_add)
   SELECT INTO "nl:"
    nextseqnum = seq(message_seq,nextval)
    FROM dual
    DETAIL
     messaging_audit_id = nextseqnum
    WITH format
   ;end select
   IF (messaging_audit_id=0.0)
    GO TO exit_script
   ENDIF
   IF ((request->audit_list[knt].msg_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      msg_text_id = nextseqnum
     WITH format
    ;end select
    IF (msg_text_id != 0.0)
     INSERT  FROM long_text lt
      SET lt.long_text_id = msg_text_id, lt.parent_entity_name = "MESSAGING_AUDIT", lt
       .parent_entity_id = messaging_audit_id,
       lt.long_text = request->audit_list[knt].msg_text, lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      GO TO exit_script
     ENDIF
    ELSE
     GO TO exit_script
    ENDIF
   ENDIF
   INSERT  FROM messaging_audit ma
    SET ma.messaging_audit_id = messaging_audit_id, ma.person_id = request->audit_list[knt].person_id,
     ma.encntr_id = request->audit_list[knt].encntr_id,
     ma.org_id = request->audit_list[knt].org_id, ma.order_id = request->audit_list[knt].order_id, ma
     .pharmacy_identifier = request->audit_list[knt].pharmacy_identifier,
     ma.action_prsnl_id = request->audit_list[knt].action_prsnl_id, ma.ordering_phys_id = request->
     audit_list[knt].ordering_phys_id, ma.status_cd = request->audit_list[knt].status_cd,
     ma.audit_type_cd = request->audit_list[knt].audit_type_cd, ma.error_cd = request->audit_list[knt
     ].error_cd, ma.contributor_system_cd = request->audit_list[knt].contributor_system_cd,
     ma.rx_identifier = request->audit_list[knt].rx_identifier, ma.msg_text_id = msg_text_id, ma
     .audit_dt_tm = cnvtdatetime(curdate,curtime3),
     ma.publish_ind = 1, ma.ref_trans_identifier = request->audit_list[knt].ref_trans_identifier, ma
     .ref_order_id = request->audit_list[knt].ref_order_id,
     ma.updt_dt_tm = cnvtdatetime(curdate,curtime3), ma.updt_id = reqinfo->updt_id, ma.updt_task =
     reqinfo->updt_task,
     ma.updt_cnt = 0, ma.updt_applctx = reqinfo->updt_applctx
    WITH nocounter, status(internal->qual[knt].status)
   ;end insert
   IF (curqual > 0)
    IF ((internal->qual[knt].status=0))
     SET failures = (failures+ 1)
     IF (failures > 0)
      SET stat = alterlist(reply->audit_failure_list,failures)
     ENDIF
     SET reply->audit_failure_list[failures].order_id = request->audit_list[knt].order_id
    ELSE
     SET added = (added+ 1)
     IF (added > 0)
      SET stat = alterlist(reply->audit_added_list,added)
     ENDIF
     SET reply->audit_added_list[added].rx_identifier = request->audit_list[knt].rx_identifier
     SET reply->audit_added_list[added].messaging_audit_id = messaging_audit_id
     SET reply->audit_added_list[added].order_id = request->audit_list[knt].order_id
    ENDIF
   ENDIF
 ENDFOR
 IF (failures=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (failures != audits_to_add)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
END GO
