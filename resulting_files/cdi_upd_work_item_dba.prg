CREATE PROGRAM cdi_upd_work_item:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 qual[*]
      2 work_item_id = f8
      2 clarify_reason_cd = f8
      2 priority_cd = f8
      2 status_cd = f8
      2 comment_id = f8
      2 comment_text = vc
      2 parent_entity_id = f8
      2 parent_entity_name = vc
      2 subject_text = vc
      2 person_name = vc
      2 free_text[*]
        3 display_cd_val = f8
        3 value = vc
      2 updt_cnt = i4
      2 category_cd = f8
      2 ordering_provider_id = f8
      2 location_cd = f8
      2 work_item_action[*]
        3 work_item_action_id = f8
        3 action_prsnl_id = f8
        3 comment = vc
        3 work_item_action_type_flag = i2
        3 work_item_action_dt_tm = dq8
        3 predefined_comment_cd = f8
        3 follow_up_dt_tm = dq8
      2 ignore_pending_doc_ind = i2
      2 attr_ind = i2
      2 code_attribute[*]
        3 attribute_type_code = f8
        3 code_attribute_value[*]
          4 attribute_type_value = f8
      2 sch_event_id = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 work_item_id = f8
      2 status = c1
      2 status_reason = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempattrlist(
   1 tempattr[*]
     2 attr_type_cd = f8
     2 attr_value_cd = f8
     2 attr_value_text = vc
 )
 RECORD temp(
   1 qual[*]
     2 work_item_id = f8
     2 beg_effective_dt_tm = dq8
     2 clarify_reason_cd = f8
     2 comment_id = f8
     2 create_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 owner_prsnl_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c30
     2 priority_cd = f8
     2 status_cd = f8
     2 updt_applctx = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 category_cd = f8
     2 ordering_provider_id = f8
     2 location_cd = vc
     2 sch_event_id = f8
 ) WITH protect
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE lreq_size = i4 WITH protect, constant(size(request->qual,5))
 DECLARE dactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dnew = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"NEW"))
 DECLARE dclarify = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"CLARIFY"))
 DECLARE dinprocess = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"INPROCESS"))
 DECLARE dstarttime = f8 WITH protect, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE dcommentid = f8 WITH protect, noconstant(0.0)
 DECLARE dpendingdocid = f8 WITH protect, noconstant(0.0)
 DECLARE scaplocname = vc WITH protect, noconstant("")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE sstatus = c1 WITH protect, noconstant("")
 DECLARE sstatusreason = vc WITH protect, noconstant("")
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE lfreetextsize = i4 WITH protect, noconstant(0)
 DECLARE tempvar = i4 WITH protect, noconstant(0)
 DECLARE lactioncommentssize = i4 WITH protect, noconstant(0)
 DECLARE lcommentid = i4 WITH protect, noconstant(0)
 DECLARE lworkitemactionid = i4 WITH protect, noconstant(0)
 DECLARE attrcount = i4 WITH protect, noconstant(0)
 DECLARE lattrtypesize = i4 WITH protect, noconstant(0)
 DECLARE lattrvalsize = i4 WITH protect, noconstant(0)
 DECLARE countvar = i4 WITH protect, noconstant(0)
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_UPD_WORK_ITEM **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(temp->qual,lreq_size)
 SET dstat = alterlist(reply->qual,lreq_size)
 SET reply->qual_cnt = lreq_size
 FOR (lcnt = 1 TO lreq_size)
   SET temp->qual[lcnt].work_item_id = request->qual[lcnt].work_item_id
   SET reply->qual[lcnt].work_item_id = request->qual[lcnt].work_item_id
   SET reply->qual[lidx].status = "F"
   SET reply->qual[lidx].status_reason = "Invalid work_item_id"
 ENDFOR
 SELECT INTO "nl:"
  FROM cdi_work_item wi,
   prsnl p,
   cdi_work_item_attribute attr
  PLAN (wi
   WHERE expand(lidx,1,lreq_size,wi.cdi_work_item_id,request->qual[lidx].work_item_id)
    AND wi.cdi_work_item_id > 0)
   JOIN (p
   WHERE p.person_id=wi.owner_prsnl_id)
   JOIN (attr
   WHERE outerjoin(wi.cdi_work_item_id)=attr.cdi_work_item_id)
  DETAIL
   lidx = locateval(lidx,1,lreq_size,wi.cdi_work_item_id,temp->qual[lidx].work_item_id)
   IF (lidx > 0)
    temp->qual[lidx].beg_effective_dt_tm = wi.beg_effective_dt_tm, temp->qual[lidx].clarify_reason_cd
     = wi.clarify_reason_cd, temp->qual[lidx].comment_id = wi.comment_id,
    temp->qual[lidx].create_dt_tm = wi.create_dt_tm, temp->qual[lidx].end_effective_dt_tm =
    cnvtdatetime(curdate,curtime3), temp->qual[lidx].owner_prsnl_id = wi.owner_prsnl_id,
    temp->qual[lidx].parent_entity_id = wi.parent_entity_id, temp->qual[lidx].parent_entity_name = wi
    .parent_entity_name, temp->qual[lidx].priority_cd = wi.priority_cd,
    temp->qual[lidx].status_cd = wi.status_cd, temp->qual[lidx].updt_applctx = wi.updt_applctx, temp
    ->qual[lidx].updt_cnt = wi.updt_cnt,
    temp->qual[lidx].updt_dt_tm = wi.updt_dt_tm, temp->qual[lidx].updt_id = wi.updt_id, temp->qual[
    lidx].updt_task = wi.updt_task,
    temp->qual[lidx].category_cd = wi.category_cd, temp->qual[lidx].ordering_provider_id = wi
    .ordering_provider_id, temp->qual[lidx].sch_event_id = wi.sch_event_id
    IF (p.person_id > 0
     AND (p.person_id != reqinfo->updt_id)
     AND wi.status_cd=dinprocess)
     reply->qual[lidx].status = "F", reply->qual[lidx].status_reason = "Work Item Locked"
    ELSEIF ((request->qual[lidx].updt_cnt < wi.updt_cnt))
     reply->qual[lidx].status = "F", reply->qual[lidx].status_reason = "WorkItem data not latest"
    ELSEIF (((textlen(request->qual[lidx].person_name) > 0) OR (textlen(request->qual[lidx].
     subject_text) > 0))
     AND wi.parent_entity_id=0.0)
     reply->qual[lidx].status = "F", reply->qual[lidx].status_reason =
     "No active pending document to update with person and subject text"
    ELSE
     reply->qual[lidx].status = "", reply->qual[lidx].status_reason = ""
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(sline)
 CALL echorecord(temp)
 CALL echo(sline)
 FOR (lcnt = 1 TO reply->qual_cnt)
   IF ((reply->qual[lcnt].status != "F"))
    SET sstatus = "S"
    SET sstatusreason = ""
    SET dcommentid = 0
    SET lactioncommentssize = size(request->qual[lcnt].work_item_action,5)
    IF (sstatus="S"
     AND lactioncommentssize > 0)
     FOR (tempvar = 1 TO lactioncommentssize)
       IF (sstatus="S"
        AND (request->qual[lcnt].work_item_action[tempvar].work_item_action_id=0))
        IF ((request->qual[lcnt].work_item_action[tempvar].comment != ""))
         INSERT  FROM long_text lt
          SET lt.long_text_id = seq(long_data_seq,nextval), lt.long_text = request->qual[lcnt].
           work_item_action[tempvar].comment, lt.parent_entity_id = seq(cdi_seq,nextval),
           lt.parent_entity_name = "CDI_WORK_ITEM_ACTION", lt.active_ind = 1, lt.active_status_cd =
           dactive,
           lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id =
           reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx,
           lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
           updt_id,
           lt.updt_task = reqinfo->updt_task
          WITH counter
         ;end insert
         IF (curqual=1)
          INSERT  FROM cdi_work_item_action a
           SET a.cdi_work_item_action_id = seq(cdi_seq,currval), a.cdi_work_item_id = request->qual[
            lcnt].work_item_id, a.comment_cd = request->qual[lcnt].work_item_action[tempvar].
            predefined_comment_cd,
            a.long_text_id = seq(long_data_seq,currval), a.outputctx_handle_id = 0, a.action_prsnl_id
             = reqinfo->updt_id,
            a.action_type_flag = request->qual[lcnt].work_item_action[tempvar].
            work_item_action_type_flag, a.action_dt_tm = cnvtdatetime(request->qual[lcnt].
             work_item_action[tempvar].work_item_action_dt_tm), a.updt_applctx = reqinfo->
            updt_applctx,
            a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->
            updt_id,
            a.updt_task = reqinfo->updt_task, a.follow_up_dt_tm = cnvtdatetime(request->qual[lcnt].
             work_item_action[tempvar].follow_up_dt_tm)
           WITH counter
          ;end insert
         ENDIF
        ELSE
         INSERT  FROM cdi_work_item_action a
          SET a.cdi_work_item_action_id = seq(cdi_seq,nextval), a.cdi_work_item_id = request->qual[
           lcnt].work_item_id, a.comment_cd = request->qual[lcnt].work_item_action[tempvar].
           predefined_comment_cd,
           a.long_text_id = 0, a.outputctx_handle_id = 0, a.action_prsnl_id = reqinfo->updt_id,
           a.action_type_flag = request->qual[lcnt].work_item_action[tempvar].
           work_item_action_type_flag, a.action_dt_tm = cnvtdatetime(request->qual[lcnt].
            work_item_action[tempvar].work_item_action_dt_tm), a.updt_applctx = reqinfo->updt_applctx,
           a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->
           updt_id,
           a.updt_task = reqinfo->updt_task, a.follow_up_dt_tm = cnvtdatetime(request->qual[lcnt].
            work_item_action[tempvar].follow_up_dt_tm)
          WITH counter
         ;end insert
        ENDIF
        IF (curqual=1)
         SET sstatus = "S"
        ELSE
         SET sstatus = "F"
         SET sstatusreason = "Insert Failure - Work Item Action"
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    SET attrcount = 0
    SET dstat = alterlist(tempattrlist->tempattr,0)
    SET lfreetextsize = size(request->qual[lcnt].free_text,5)
    IF (sstatus="S"
     AND (((request->qual[lidx].attr_ind=0)) OR (lfreetextsize=0)) )
     SELECT INTO "nl:"
      FROM cdi_work_item_attribute attr
      WHERE (attr.cdi_work_item_id=request->qual[lcnt].work_item_id)
       AND ((attr.attr_value_cd > 0
       AND (request->qual[lidx].attr_ind=0)) OR (attr.attr_value_cd=0
       AND lfreetextsize=0))
      DETAIL
       attrcount = (attrcount+ 1)
       IF (mod(attrcount,10)=1)
        dstat = alterlist(tempattrlist->tempattr,(attrcount+ 9))
       ENDIF
       tempattrlist->tempattr[attrcount].attr_type_cd = attr.attribute_cd, tempattrlist->tempattr[
       attrcount].attr_value_cd = attr.attr_value_cd, tempattrlist->tempattr[attrcount].
       attr_value_text = attr.attr_value_txt
     ;end select
    ENDIF
    FOR (tempvar = 1 TO lfreetextsize)
      SET attrcount = (attrcount+ 1)
      IF (mod(attrcount,10)=1)
       SET dstat = alterlist(tempattrlist->tempattr,(attrcount+ 9))
      ENDIF
      SET tempattrlist->tempattr[attrcount].attr_type_cd = request->qual[lidx].free_text[tempvar].
      display_cd_val
      SET tempattrlist->tempattr[attrcount].attr_value_cd = 0
      SET tempattrlist->tempattr[attrcount].attr_value_text = request->qual[lidx].free_text[tempvar].
      value
    ENDFOR
    SET lattrtypesize = size(request->qual[lcnt].code_attribute,5)
    FOR (tempvar = 1 TO lattrtypesize)
     SET lattrvalsize = size(request->qual[lcnt].code_attribute[tempvar].code_attribute_value,5)
     FOR (countvar = 1 TO lattrvalsize)
       SET attrcount = (attrcount+ 1)
       IF (mod(attrcount,10)=1)
        SET dstat = alterlist(tempattrlist->tempattr,(attrcount+ 9))
       ENDIF
       SET tempattrlist->tempattr[attrcount].attr_type_cd = request->qual[lidx].code_attribute[
       tempvar].attribute_type_code
       SET tempattrlist->tempattr[attrcount].attr_value_cd = request->qual[lidx].code_attribute[
       tempvar].code_attribute_value[countvar].attribute_type_value
       SET tempattrlist->tempattr[attrcount].attr_value_text = ""
     ENDFOR
    ENDFOR
    SET dstat = alterlist(tempattrlist->tempattr,attrcount)
    SET dpendingdocid = temp->qual[lidx].parent_entity_id
    IF (sstatus="S"
     AND (request->qual[lcnt].ignore_pending_doc_ind=0))
     SELECT INTO "n1"
      FROM cdi_pending_document pd
      WHERE pd.cdi_pending_document_id=dpendingdocid
      WITH forupdate(pd)
     ;end select
     IF (curqual=1)
      UPDATE  FROM cdi_pending_document pd
       SET pd.subject_text = request->qual[lcnt].subject_text, pd.patient_name = request->qual[lcnt].
        person_name, pd.updt_cnt = (pd.updt_cnt+ 1),
        pd.updt_task = temp->qual[lcnt].updt_task, pd.updt_dt_tm = cnvtdatetime(curdate,curtime3), pd
        .location_cd = request->qual[lcnt].location_cd
       WHERE pd.cdi_pending_document_id=dpendingdocid
       WITH counter
      ;end update
      IF (curqual=1)
       SET sstatus = "S"
      ELSE
       SET sstatus = "F"
       SET sstatusreason = "Update Failure - cdi_pending_document"
      ENDIF
     ENDIF
    ENDIF
    IF (sstatus="S")
     SELECT INTO "nl:"
      FROM cdi_work_item wi
      WHERE (wi.cdi_work_item_id=reply->qual[lcnt].work_item_id)
       AND wi.cdi_work_item_id > 0
      WITH forupdate(wi)
     ;end select
     IF (curqual=1)
      UPDATE  FROM cdi_work_item wi
       SET wi.beg_effective_dt_tm = cnvtdatetime(temp->qual[lcnt].end_effective_dt_tm), wi.comment_id
         = 0, wi.clarify_reason_cd = request->qual[lcnt].clarify_reason_cd,
        wi.owner_prsnl_id =
        IF ((request->qual[lcnt].status_cd=dnew)) 0.0
        ELSE reqinfo->updt_id
        ENDIF
        , wi.parent_entity_id =
        IF ((request->qual[lcnt].parent_entity_id > 0)) request->qual[lcnt].parent_entity_id
        ELSE wi.parent_entity_id
        ENDIF
        , wi.parent_entity_name =
        IF (textlen(trim(request->qual[lcnt].parent_entity_name,3)) > 0) request->qual[lcnt].
         parent_entity_name
        ELSE wi.parent_entity_name
        ENDIF
        ,
        wi.priority_cd =
        IF ((request->qual[lcnt].priority_cd > 0)) request->qual[lcnt].priority_cd
        ELSE wi.priority_cd
        ENDIF
        , wi.status_cd =
        IF ((request->qual[lcnt].status_cd > 0)) request->qual[lcnt].status_cd
        ELSE wi.status_cd
        ENDIF
        , wi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        wi.updt_task = reqinfo->updt_task, wi.updt_id = reqinfo->updt_id, wi.updt_applctx = reqinfo->
        updt_applctx,
        wi.updt_cnt = (wi.updt_cnt+ 1), wi.category_cd =
        IF ((request->qual[lcnt].category_cd >= 0)) request->qual[lcnt].category_cd
        ELSE wi.category_cd
        ENDIF
        , wi.ordering_provider_id = request->qual[lcnt].ordering_provider_id,
        wi.sch_event_id = request->qual[lcnt].sch_event_id
       WHERE (wi.cdi_work_item_id=reply->qual[lcnt].work_item_id)
       WITH counter
      ;end update
      IF (curqual=1)
       INSERT  FROM cdi_work_item wi
        SET wi.cdi_work_item_id = seq(cdi_seq,nextval), wi.beg_effective_dt_tm = cnvtdatetime(temp->
          qual[lcnt].beg_effective_dt_tm), wi.clarify_reason_cd = temp->qual[lcnt].clarify_reason_cd,
         wi.comment_id = temp->qual[lcnt].comment_id, wi.create_dt_tm = cnvtdatetime(temp->qual[lcnt]
          .create_dt_tm), wi.end_effective_dt_tm = cnvtdatetime(temp->qual[lcnt].end_effective_dt_tm),
         wi.owner_prsnl_id = temp->qual[lcnt].owner_prsnl_id, wi.parent_entity_id = temp->qual[lcnt].
         parent_entity_id, wi.parent_entity_name = temp->qual[lcnt].parent_entity_name,
         wi.prev_cdi_work_item_id = temp->qual[lcnt].work_item_id, wi.priority_cd = temp->qual[lcnt].
         priority_cd, wi.status_cd = temp->qual[lcnt].status_cd,
         wi.updt_applctx = temp->qual[lcnt].updt_applctx, wi.updt_cnt = temp->qual[lcnt].updt_cnt, wi
         .updt_dt_tm = cnvtdatetime(temp->qual[lcnt].updt_dt_tm),
         wi.updt_id = temp->qual[lcnt].updt_id, wi.updt_task = temp->qual[lcnt].updt_task, wi
         .category_cd = temp->qual[lcnt].category_cd,
         wi.ordering_provider_id = temp->qual[lcnt].ordering_provider_id, wi.sch_event_id = temp->
         qual[lcnt].sch_event_id
        WITH counter
       ;end insert
       IF (curqual=1)
        SET lscnt = (lscnt+ 1)
        SET sstatus = "S"
        SET sstatusreason = ""
       ELSE
        SET sstatus = "F"
        SET sstatusreason = "Insert Failure - cdi_work_item"
       ENDIF
       IF (sstatus="S")
        IF ((request->qual[lcnt].comment_id > 0))
         UPDATE  FROM long_text lt
          SET lt.parent_entity_id = seq(cdi_seq,currval), lt.active_ind = 1, lt.active_status_cd =
           dactive,
           lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id =
           reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx,
           lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id
            = reqinfo->updt_id,
           lt.updt_task = reqinfo->updt_task
          WHERE (lt.parent_entity_id=request->qual[lcnt].work_item_id)
           AND lt.parent_entity_name="CDI_WORK_ITEM"
         ;end update
         IF (curqual=1)
          SET sstatus = "S"
         ELSE
          SET sstatus = "F"
          SET sstatusreason = "Update Failure - long_text"
         ENDIF
        ENDIF
        IF (sstatus="S"
         AND textlen(request->qual[lcnt].comment_text) > 0)
         INSERT  FROM long_text lt
          SET lt.long_text_id = seq(long_data_seq,nextval), lt.parent_entity_name = "CDI_WORK_ITEM",
           lt.parent_entity_id = request->qual[lcnt].work_item_id,
           lt.long_text = request->qual[lcnt].comment_text, lt.active_ind = 1, lt.active_status_cd =
           dactive,
           lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id =
           reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx,
           lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
           updt_id,
           lt.updt_task = reqinfo->updt_task
          WITH counter
         ;end insert
         IF (curqual=1)
          UPDATE  FROM cdi_work_item wi
           SET wi.comment_id = seq(long_data_seq,currval)
           WHERE (wi.cdi_work_item_id=reply->qual[lcnt].work_item_id)
           WITH counter
          ;end update
          IF (curqual > 0)
           SET sstatus = "S"
          ELSE
           SET sstatus = "F"
           SET sstatusreason = "Update Failure - cdi_work_item"
          ENDIF
         ELSE
          SET sstatus = "F"
          SET sstatusreason = "Insert Failure - long_text"
         ENDIF
        ENDIF
       ENDIF
       IF (sstatus="S")
        SET tempvar = 0
        SELECT INTO "nl:"
         FROM cdi_work_item_attribute attr
         WHERE (attr.cdi_work_item_id=request->qual[lcnt].work_item_id)
          AND attr.cdi_work_item_id > 0
         DETAIL
          tempvar = (tempvar+ 1)
         WITH forupdate(attr)
        ;end select
        IF (curqual > 0)
         UPDATE  FROM cdi_work_item_attribute attr
          SET attr.cdi_work_item_id = seq(cdi_seq,currval), attr.updt_cnt = (updt_cnt+ 1), attr
           .updt_dt_tm = cnvtdatetime(curdate,curtime3),
           attr.updt_task = reqinfo->updt_task, attr.updt_applctx = reqinfo->updt_applctx, attr
           .updt_id = reqinfo->updt_id
          WHERE (attr.cdi_work_item_id=request->qual[lcnt].work_item_id)
         ;end update
         IF (curqual=tempvar)
          SET sstatus = "S"
         ELSE
          SET sstatus = "F"
          SET sstausreason = "Update Failure - cdi_work_item_attribute"
         ENDIF
        ENDIF
        IF (attrcount > 0
         AND sstatus="S")
         INSERT  FROM (dummyt d  WITH seq = attrcount),
           cdi_work_item_attribute attr
          SET attr.cdi_work_item_attribute_id = seq(cdi_seq,nextval), attr.attr_value_txt =
           tempattrlist->tempattr[d.seq].attr_value_text, attr.attr_value_cd = tempattrlist->
           tempattr[d.seq].attr_value_cd,
           attr.attribute_cd = tempattrlist->tempattr[d.seq].attr_type_cd, attr.cdi_work_item_id =
           request->qual[lcnt].work_item_id, attr.updt_cnt = 0,
           attr.updt_applctx = reqinfo->updt_applctx, attr.updt_id = reqinfo->updt_id, attr.updt_task
            = reqinfo->updt_task,
           attr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          PLAN (d)
           JOIN (attr)
         ;end insert
         IF (curqual=attrcount)
          SET sstatus = "S"
         ELSE
          SET sstatus = "F"
          SET sstatusreason = "Insert Failure - cdi_work_item_attribute"
         ENDIF
        ENDIF
       ENDIF
      ELSE
       SET sstatus = "F"
       SET sstatusreason = "Update Failure - cdi_work_item"
      ENDIF
     ELSE
      SET sstatus = "F"
      SET sstatusreason = "Lock Row Failure - cdi_work_item"
     ENDIF
    ENDIF
    SET reply->qual[lcnt].status = sstatus
    SET reply->qual[lcnt].status_reason = sstatusreason
    IF (sstatus="S")
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ENDIF
 ENDFOR
 IF ((lscnt=reply->qual_cnt))
  SET sscriptstatus = "S"
  SET sscriptmsg = "All work items were successfully updated"
 ELSEIF (lscnt > 0)
  SET sscriptstatus = "S"
  SET sscriptmsg = "Some work items failed to update, check individual status"
 ELSE
  SET sscriptstatus = "Z"
  SET sscriptmsg = "All work items failed to update"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_UPD_WORK_ITEM"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 FREE RECORD temp
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 11/11/2010")
 SET modify = nopredeclare
 CALL echo(sline)
 CALL echo("********** END CDI_UPD_WORK_ITEM **********")
 CALL echo(sline)
END GO
