CREATE PROGRAM cdi_upd_cover_page_tmps:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD tempfields
 RECORD tempfields(
   1 fieldstoupdate[*]
     2 cover_page_template_id = f8
     2 cover_page_name_key = vc
     2 cover_page_name = vc
     2 cover_page_text = vc
   1 fieldstodelete[*]
     2 cover_page_template_id = f8
   1 fieldstoadd[*]
     2 cover_page_template_id = f8
     2 long_text_id = f8
     2 cover_page_name_key = vc
     2 cover_page_name = vc
     2 cover_page_text = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE req_size = i4 WITH protect, constant(size(request->templates,5))
 DECLARE dactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE updtcnt = i4 WITH protect, noconstant(1)
 DECLARE addcnt = i4 WITH protect, noconstant(1)
 DECLARE delcnt = i4 WITH protect, noconstant(1)
 DECLARE ltcnt = i4 WITH protect, noconstant(1)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE rowstoupdate = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 FOR (lcnt = 1 TO req_size)
   IF ((request->templates[lcnt].delete_ind=0)
    AND (request->templates[lcnt].cover_page_template_id=0))
    SET stat = alterlist(tempfields->fieldstoadd,addcnt)
    SET tempfields->fieldstoadd[addcnt].cover_page_name = request->templates[lcnt].cover_page_name
    SET tempfields->fieldstoadd[addcnt].cover_page_name_key = request->templates[lcnt].
    cover_page_name_key
    SET tempfields->fieldstoadd[addcnt].cover_page_text = request->templates[lcnt].cover_page_text
    SET tempfields->fieldstoadd[addcnt].cover_page_template_id = 0
    SET tempfields->fieldstoadd[addcnt].long_text_id = 0
    SET addcnt = (addcnt+ 1)
   ELSEIF ((request->templates[lcnt].delete_ind=1)
    AND (request->templates[lcnt].cover_page_template_id > 0))
    SET stat = alterlist(tempfields->fieldstodelete,delcnt)
    SET tempfields->fieldstodelete[delcnt].cover_page_template_id = request->templates[lcnt].
    cover_page_template_id
    SET delcnt = (delcnt+ 1)
   ELSEIF ((request->templates[lcnt].cover_page_template_id > 0))
    SET stat = alterlist(tempfields->fieldstoupdate,updtcnt)
    SET tempfields->fieldstoupdate[updtcnt].cover_page_template_id = request->templates[lcnt].
    cover_page_template_id
    SET tempfields->fieldstoupdate[updtcnt].cover_page_name = request->templates[lcnt].
    cover_page_name
    SET tempfields->fieldstoupdate[updtcnt].cover_page_name_key = request->templates[lcnt].
    cover_page_name_key
    SET tempfields->fieldstoupdate[updtcnt].cover_page_text = request->templates[lcnt].
    cover_page_text
    SET updtcnt = (updtcnt+ 1)
   ENDIF
 ENDFOR
 SET updtcnt = (updtcnt - 1)
 SET addcnt = (addcnt - 1)
 SET delcnt = (delcnt - 1)
 SET reply->status_data.status = "F"
 IF (req_size > 0)
  IF (updtcnt > 0)
   SELECT INTO "nl:"
    FROM cdi_cover_page_template cp
    WHERE expand(num,1,updtcnt,cp.cdi_cover_page_template_id,tempfields->fieldstoupdate[num].
     cover_page_template_id)
    DETAIL
     rowstoupdate = (rowstoupdate+ 1)
    WITH nocounter, forupdatewait(cp)
   ;end select
   IF (rowstoupdate > 0)
    UPDATE  FROM cdi_cover_page_template cp,
      (dummyt d  WITH seq = updtcnt)
     SET cp.template_name = tempfields->fieldstoupdate[d.seq].cover_page_name, cp.template_name_key
       = tempfields->fieldstoupdate[d.seq].cover_page_name_key, cp.updt_applctx = reqinfo->
      updt_applctx,
      cp.updt_cnt = (cp.updt_cnt+ 1), cp.updt_dt_tm = cnvtdatetime(curdate,curtime3), cp.updt_id =
      reqinfo->updt_id,
      cp.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (cp
      WHERE (cp.cdi_cover_page_template_id=tempfields->fieldstoupdate[d.seq].cover_page_template_id))
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual != updtcnt)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_COVER_PAGE_TEMPLATE"
    GO TO exit_script
   ENDIF
   SET rowstoupdate = 0
   SELECT INTO "nl:"
    FROM long_text_reference lt
    WHERE expand(num,1,updtcnt,lt.parent_entity_id,tempfields->fieldstoupdate[num].
     cover_page_template_id)
     AND lt.parent_entity_name="CDI_COVER_PAGE_TEMPLATE"
    DETAIL
     rowstoupdate = (rowstoupdate+ 1)
    WITH nocounter, forupdatewait(lt)
   ;end select
   IF (rowstoupdate > 0)
    UPDATE  FROM long_text_reference lt,
      (dummyt d  WITH seq = updtcnt)
     SET lt.long_text = tempfields->fieldstoupdate[d.seq].cover_page_text, lt.updt_cnt = (lt.updt_cnt
      + 1), lt.updt_applctx = reqinfo->updt_applctx,
      lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
      reqinfo->updt_task
     PLAN (d)
      JOIN (lt
      WHERE (lt.parent_entity_id=tempfields->fieldstoupdate[d.seq].cover_page_template_id)
       AND lt.parent_entity_name="CDI_COVER_PAGE_TEMPLATE")
     WITH nocounter
    ;end update
   ENDIF
   IF (curqual != updtcnt)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT_REFERENCE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (delcnt > 0)
   DELETE  FROM cdi_cover_page_template cp
    WHERE expand(num,1,delcnt,cp.cdi_cover_page_template_id,tempfields->fieldstodelete[num].
     cover_page_template_id)
   ;end delete
   IF (curqual != delcnt)
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_COVER_PAGE_TEMPLATE"
    GO TO exit_script
   ENDIF
   DELETE  FROM long_text_reference lt
    WHERE expand(num,1,delcnt,lt.parent_entity_id,tempfields->fieldstodelete[num].
     cover_page_template_id)
     AND lt.parent_entity_name="CDI_COVER_PAGE_TEMPLATE"
   ;end delete
   IF (curqual != delcnt)
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT_REFERENCE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (addcnt > 0)
   EXECUTE dm2_dar_get_bulk_seq "tempFields->fieldsToAdd", addcnt, "long_text_id",
   1, "LONG_DATA_SEQ"
   EXECUTE dm2_dar_get_bulk_seq "tempFields->fieldsToAdd", addcnt, "cover_page_template_id",
   1, "CDI_SEQ"
   INSERT  FROM long_text_reference lt,
     (dummyt d  WITH seq = addcnt)
    SET lt.long_text_id = tempfields->fieldstoadd[d.seq].long_text_id, lt.long_text = tempfields->
     fieldstoadd[d.seq].cover_page_text, lt.active_ind = 1,
     lt.active_status_cd = dactive, lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt
     .active_status_prsnl_id = reqinfo->updt_id,
     lt.parent_entity_id = tempfields->fieldstoadd[d.seq].cover_page_template_id, lt
     .parent_entity_name = "CDI_COVER_PAGE_TEMPLATE", lt.updt_applctx = reqinfo->updt_applctx,
     lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (lt)
    WITH nocounter
   ;end insert
   IF (curqual != addcnt)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT_REFERENCE"
    GO TO exit_script
   ENDIF
   INSERT  FROM cdi_cover_page_template cp,
     (dummyt d  WITH seq = addcnt)
    SET cp.cdi_cover_page_template_id = tempfields->fieldstoadd[d.seq].cover_page_template_id, cp
     .long_text_id = tempfields->fieldstoadd[d.seq].long_text_id, cp.template_name = tempfields->
     fieldstoadd[d.seq].cover_page_name,
     cp.template_name_key = tempfields->fieldstoadd[d.seq].cover_page_name_key, cp.updt_applctx =
     reqinfo->updt_applctx, cp.updt_cnt = 0,
     cp.updt_dt_tm = cnvtdatetime(curdate,curtime3), cp.updt_id = reqinfo->updt_id, cp.updt_task =
     reqinfo->updt_task
    PLAN (d)
     JOIN (cp)
    WITH nocounter
   ;end insert
   IF (curqual != addcnt)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_COVER_PAGE_TEMPLATE"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
