CREATE PROGRAM dm_content_domain_info_load:dba
 DECLARE dcdi_num_cols = i4 WITH protect, constant(23)
 DECLARE dcdi_domain_info_cnt = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE dcdi_field_name_cnt = i4 WITH protect, noconstant(0)
 DECLARE dcdi_i = i4 WITH protect, noconstant(0)
 DECLARE dcdi_err_msg = vc WITH protect, noconstant("")
 DECLARE dcdi_bypass_ind = i2 WITH protect, noconstant(0)
 DECLARE dcdi_domain_list_cnt = i4 WITH protect, noconstant(0)
 IF (validate(dcdir_initial_backfill_ind,- (99))=1)
  SET dcdi_bypass_ind = 1
 ENDIF
 FREE RECORD field_name_temp
 RECORD field_name_temp(
   1 list[*]
     2 property_id = f8
     2 field_name = vc
     2 field_value_str = vc
     2 field_value = f8
     2 status = i2
 )
 FOR (dcdi_i = 1 TO dcdi_domain_info_cnt)
   SET stat = alterlist(field_name_temp->list,(dcdi_field_name_cnt+ dcdi_num_cols))
   IF (dcdi_bypass_ind=0)
    IF (cnvtreal(requestin->list_0[dcdi_i].property_id) > 0)
     SELECT INTO "nl:"
      FROM content_property cp
      WHERE cp.property_type=0
       AND cp.property_id=cnvtreal(requestin->list_0[dcdi_i].property_id)
      WITH nocounter
     ;end select
     IF (error(dcdi_err_msg,1) > 0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
       "Failed to select from table content_property: ",dcdi_err_msg)
      GO TO exit_script
     ENDIF
     IF (curqual=0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
       "Invalid property_id found: ",requestin->list_0[dcdi_i].property_id)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DOMAIN_NAME_XML"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   domain_name_xml
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "SCRIPT_NAME"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   script_name
   IF (findstring(".LOG",cnvtupper(requestin->list_0[dcdi_i].backend_logfile_name))=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Log files must have suffix '.log'"
    GO TO exit_script
   ENDIF
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "BACKEND_LOGFILE_NAME"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   backend_logfile_name
   IF (findstring(".LOG",cnvtupper(requestin->list_0[dcdi_i].frontend_logfile_name))=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Log files must have suffix '.log'"
    GO TO exit_script
   ENDIF
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "FRONTEND_LOGFILE_NAME"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   frontend_logfile_name
   SELECT INTO "nl:"
    FROM application_task at
    WHERE at.task_number=cnvtreal(requestin->list_0[dcdi_i].task_number)
    WITH nocounter
   ;end select
   IF (error(dcdi_err_msg,1) > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "Failed to select from table application_task: ",dcdi_err_msg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Invalid task: ",requestin->
     list_0[dcdi_i].task_number," found")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM task_request_r trr
    WHERE trr.task_number=cnvtreal(requestin->list_0[dcdi_i].task_number)
     AND trr.request_number=cnvtreal(requestin->list_0[dcdi_i].request_number)
    WITH nocounter
   ;end select
   IF (error(dcdi_err_msg,1) > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
     "Failed to select from table task_request_r: ",dcdi_err_msg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Invalid task: ",requestin->
     list_0[dcdi_i].task_number," request: ",requestin->list_0[dcdi_i].request_number,
     " relationship found")
    GO TO exit_script
   ENDIF
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "TASK_NUMBER"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    task_number)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "REQUEST_NUMBER"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    request_number)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DOMAIN_PROGID"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   domain_progid
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DOMAIN_PROGID_TYPE"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    domain_progid_type)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DISPLAY_IND"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    display_ind)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "PARENT_PANEL"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
   parent_panel
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "PARENT_DISPLAY_ORDER"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    parent_display_order)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DISPLAY_ORDER"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    display_order)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "DYNAMIC_LOAD"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    dynamic_load)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "AUDIT_MODE"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    audit_mode)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "ALLOW_UPDATES"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    allow_updates)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "SHOW_UPDATE_FORM"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    show_update_form)
   SET dcdi_field_name_cnt += 1
   SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
    property_id)
   SET field_name_temp->list[dcdi_field_name_cnt].field_name = "IMPORT_BATCH_SIZE"
   SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
    import_batch_size)
   IF (validate(requestin->list_0[dcdi_i].export_lbl_name)=1)
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_LBL_NAME"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
    export_lbl_name
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_SCR_PATH"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
    export_scr_path
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_DRIVER_NAME"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value_str = requestin->list_0[dcdi_i].
    export_driver_name
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_TSK_NUMBER"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
     export_tsk_number)
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_REQ_NUMBER"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
     export_req_number)
    SET dcdi_field_name_cnt += 1
    SET field_name_temp->list[dcdi_field_name_cnt].property_id = cnvtreal(requestin->list_0[dcdi_i].
     property_id)
    SET field_name_temp->list[dcdi_field_name_cnt].field_name = "EXPORT_IMAGE_IDX"
    SET field_name_temp->list[dcdi_field_name_cnt].field_value = cnvtreal(requestin->list_0[dcdi_i].
     export_image_idx)
   ENDIF
 ENDFOR
 UPDATE  FROM content_domain_info cdi,
   (dummyt d  WITH seq = value(dcdi_field_name_cnt))
  SET cdi.field_value_str = field_name_temp->list[d.seq].field_value_str, cdi.field_value =
   field_name_temp->list[d.seq].field_value, cdi.updt_dt_tm = cnvtdatetime(sysdate),
   cdi.updt_cnt = (cdi.updt_cnt+ 1), cdi.updt_id = reqinfo->updt_id, cdi.updt_applctx = reqinfo->
   updt_applctx,
   cdi.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (cdi
   WHERE (cdi.property_id=field_name_temp->list[d.seq].property_id)
    AND (cdi.field_name=field_name_temp->list[d.seq].field_name))
  WITH nocounter, status(field_name_temp->list[d.seq].status)
 ;end update
 IF (error(dcdi_err_msg,1) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Failed to update table content_domain_info: ",dcdi_err_msg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 INSERT  FROM content_domain_info cdi,
   (dummyt d  WITH seq = value(dcdi_field_name_cnt))
  SET cdi.content_domain_info_id = seq(dm_seq,nextval), cdi.property_id = field_name_temp->list[d.seq
   ].property_id, cdi.field_name = field_name_temp->list[d.seq].field_name,
   cdi.field_value_str = field_name_temp->list[d.seq].field_value_str, cdi.field_value =
   field_name_temp->list[d.seq].field_value, cdi.updt_dt_tm = cnvtdatetime(sysdate),
   cdi.updt_cnt = 0, cdi.updt_id = reqinfo->updt_id, cdi.updt_applctx = reqinfo->updt_applctx,
   cdi.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (field_name_temp->list[d.seq].status=0))
   JOIN (cdi)
  WITH nocounter
 ;end insert
 IF (error(dcdi_err_msg,1) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Failed to insert into table content_domain_info: ",dcdi_err_msg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM content_domain_info cdi,
   (dummyt d  WITH seq = value(dcdi_field_name_cnt))
  PLAN (d)
   JOIN (cdi
   WHERE (cdi.property_id=field_name_temp->list[d.seq].property_id)
    AND (cdi.field_name=field_name_temp->list[d.seq].field_name))
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF (error(dcdi_err_msg,1) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Failed to validate data on content_domain_info: ",dcdi_err_msg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "failed to import all data from REQUESTIN structure"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue =
 "Successfully imported all data into CONTENT_DOMAIN_INFO"
#exit_script
 FREE RECORD field_name_temp
END GO
