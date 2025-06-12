CREATE PROGRAM cv_upd_display_grid:dba
 PROMPT
  "Display Grid Section Description [ACC v3 Lesion/Devices]" = "ACC v3 Lesion/Devices",
  "Display Grid Control Description [LESION]" = "LESION",
  "Popup Grid Section Description [ACC v3 Lesion Data]" = "ACC v3 Lesion Data",
  "Do update on ICDevice Grid event_cds[N]" = "N"
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE grid_ec_disp = vc WITH noconstant("AC03 IC Device Grid"), protect
 DECLARE row_ec_disp = vc WITH noconstant("AC03 IC Device Row"), protect
 DECLARE grid_ec_pvc_name = vc WITH noconstant("grid_event_cd"), protect
 DECLARE row_ec_pvc_name = vc WITH noconstant("row_event_cd"), protect
 DECLARE devgrid_dir_desc = vc WITH noconstant("IC_DEV"), protect
 DECLARE display_grid_module_name = vc WITH constant("CVFormCtrls"), protect
 DECLARE devrow_ec = f8 WITH protect
 DECLARE devgrid_ec = f8 WITH protect
 DECLARE devgrid_dir_id = f8 WITH protect
 DECLARE display_grid_input_desc = vc WITH protect
 DECLARE display_grid_section_desc = vc WITH protect
 DECLARE popup_section_desc = vc WITH protect
 DECLARE module = vc WITH protect
 DECLARE lesion_dir = f8 WITH protect
 DECLARE popup_section = f8 WITH protect
 DECLARE old_popup_section = f8 WITH protect
 DECLARE popup_nvp_id = f8 WITH protect
 DECLARE index = i4 WITH protect
 DECLARE temp_task_description = vc WITH protect
 DECLARE temp_event_cd = f8 WITH protect
 DECLARE upd_grid_event_cds_ind = i2 WITH protect
 DECLARE e_row = i4 WITH constant(2), protect
 DECLARE e_grid = i4 WITH constant(1), protect
 FREE RECORD placeholder
 RECORD placeholder(
   1 qual[2]
     2 xref_internal_name = vc
     2 pvc_name = vc
     2 pref_id = f8
     2 pref_ec = f8
     2 xref_ec = f8
     2 xref_id = f8
     2 event_cd = f8
     2 event_disp = vc
     2 event_type_mean = vc
     2 sub_event_type_mean = vc
 )
 SET placeholder->qual[e_grid].xref_internal_name = "ACC03_DEVGRDEC"
 SET placeholder->qual[e_grid].pvc_name = grid_ec_pvc_name
 SET placeholder->qual[e_grid].event_disp = grid_ec_disp
 SET placeholder->qual[e_row].xref_internal_name = "ACC03_DEVROWEC"
 SET placeholder->qual[e_row].pvc_name = row_ec_pvc_name
 SET placeholder->qual[e_row].event_disp = row_ec_disp
 SET display_grid_section_desc =  $1
 SET display_grid_input_desc =  $2
 SET popup_section_desc =  $3
 IF (cnvtupper( $4)=patstring("Y*"))
  SET upd_grid_event_cds_ind = 1
 ENDIF
 SELECT INTO "NL:"
  dir.dcp_input_ref_id, dir.module
  FROM dcp_section_ref dsr,
   dcp_input_ref dir
  PLAN (dsr
   WHERE dsr.description=display_grid_section_desc
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.description=display_grid_input_desc)
  DETAIL
   lesion_dir = dir.dcp_input_ref_id, module = dir.module
  WITH nocounter
 ;end select
 IF (lesion_dir=0.0)
  CALL cv_log_message("Failed to find dcp_input_ref of DisplayGrid")
  GO TO exit_script
 ENDIF
 CALL cv_log_message(concat("Lesion input_ref_id = ",cnvtstring(lesion_dir)))
 IF (module != display_grid_module_name)
  CALL cv_log_message(concat(module,":",display_grid_module_name,":"))
  CALL cv_log_message("Incorrect or missing module name, updating")
  UPDATE  FROM dcp_input_ref dir
   SET dir.module = display_grid_module_name, dir.updt_cnt = (dir.updt_cnt+ 1), dir.updt_dt_tm =
    cnvtdatetime(curdate,curtime3)
   WHERE dir.dcp_input_ref_id=lesion_dir
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL cv_log_message("dir.module update failed")
  ELSE
   CALL cv_log_message("dir.module update succeeded")
  ENDIF
 ELSE
  CALL cv_log_message("dir.module verified correct")
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_section_ref dsr
  WHERE dsr.description=popup_section_desc
   AND dsr.active_ind=1
  DETAIL
   popup_section = dsr.dcp_section_ref_id
  WITH nocounter
 ;end select
 IF (popup_section=0.0)
  CALL cv_log_message(concat("Failed to find dcp_section_ref for popup:",popup_section_desc,":"))
  GO TO exit_script
 ENDIF
 CALL cv_log_message(concat("Popup section = ",cnvtstring(popup_section)))
 SELECT INTO "nl:"
  pref_id = nvp.name_value_prefs_id, merge_id = nvp.merge_id
  FROM name_value_prefs nvp
  WHERE ((nvp.parent_entity_id+ 0)=lesion_dir)
   AND nvp.parent_entity_name="DCP_INPUT_REF"
   AND nvp.pvc_name="popup_section"
   AND nvp.active_ind=1
  DETAIL
   popup_nvp_id = pref_id, old_popup_section = merge_id
  WITH nocounter
 ;end select
 IF (popup_nvp_id=0.0)
  CALL cv_log_message("Inserting new popup_section pref")
  INSERT  FROM name_value_prefs nvp
   SET nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_name = "DCP_INPUT_REF",
    nvp.parent_entity_id = lesion_dir,
    nvp.pvc_name = "popup_section", nvp.pvc_value = "", nvp.merge_name = "DCP_SECTION_REF",
    nvp.merge_id = popup_section, nvp.sequence = 0, nvp.active_ind = 1,
    nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
    reqinfo->updt_task,
    nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL cv_log_message("Insert Failed")
  ELSE
   CALL cv_log_message("Insert Succeeded")
  ENDIF
 ELSE
  CALL cv_log_message(concat("Found name_value_prefs_id = ",cnvtstring(popup_nvp_id)))
  IF (old_popup_section=popup_section)
   CALL cv_log_message("Correct popup_section pref found, No action taken")
  ELSE
   UPDATE  FROM name_value_prefs nvp
    SET nvp.merge_id = popup_section, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_cnt
      = (nvp.updt_cnt+ 1),
     nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task, nvp.updt_applctx = reqinfo->
     updt_applctx
    WHERE name_value_prefs_id=popup_nvp_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL cv_log_message(concat("FAILED to update popup_section pref ",cnvtstring(popup_nvp_id),
      " with dcp_section_ref ",cnvtstring(popup_section)))
   ELSE
    CALL cv_log_message(concat("UPDATED popup_section pref ",cnvtstring(popup_nvp_id),
      " with dcp_section_ref ",cnvtstring(popup_section)))
   ENDIF
  ENDIF
 ENDIF
 SET placeholder->qual[e_grid].event_cd = uar_get_code_by("DISPLAY",72,placeholder->qual[e_grid].
  event_disp)
 SET placeholder->qual[e_row].event_cd = uar_get_code_by("DISPLAY",72,placeholder->qual[e_row].
  event_disp)
 SELECT INTO "nl:"
  dir.dcp_input_ref_id, nvp.merge_id
  FROM dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (dsr
   WHERE dsr.dcp_section_ref_id=popup_section
    AND dsr.active_ind=1)
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.description=devgrid_dir_desc
    AND dir.active_ind=1)
   JOIN (nvp
   WHERE ((nvp.parent_entity_id+ 0)=dir.dcp_input_ref_id)
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND nvp.active_ind=1
    AND expand(index,1,2,nvp.pvc_name,placeholder->qual[index].pvc_name))
  HEAD REPORT
   devgrid_dir_id = dir.dcp_input_ref_id
  DETAIL
   CASE (nvp.pvc_name)
    OF placeholder->qual[e_row].pvc_name:
     placeholder->qual[e_row].pref_ec = nvp.merge_id,placeholder->qual[e_row].pref_id = nvp
     .name_value_prefs_id
    OF placeholder->qual[e_grid].pvc_name:
     placeholder->qual[e_grid].pref_ec = nvp.merge_id,placeholder->qual[e_grid].pref_id = nvp
     .name_value_prefs_id
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(placeholder->qual,5))),
   cv_xref x
  PLAN (d)
   JOIN (x
   WHERE (x.xref_internal_name=placeholder->qual[d.seq].xref_internal_name))
  DETAIL
   placeholder->qual[d.seq].xref_ec = x.event_cd, placeholder->qual[d.seq].xref_id = x.xref_id,
   placeholder->qual[d.seq].event_type_mean = uar_get_code_meaning(x.event_type_cd),
   placeholder->qual[d.seq].sub_event_type_mean = uar_get_code_meaning(x.sub_event_type_cd)
  WITH nocounter
 ;end select
 CALL echorecord(placeholder)
 FOR (index = 1 TO 2)
  IF ((placeholder->qual[index].event_cd < 1.0))
   CALL cv_log_message(concat("UAR failed for ",placeholder->qual[index].event_disp))
   SET temp_task_description = placeholder->qual[index].event_disp
   SET temp_event_cd = 0.0
   EXECUTE tsk_post_event_code
   SET placeholder->qual[index].event_cd = temp_event_cd
  ENDIF
  IF ((placeholder->qual[index].event_cd <= 0.0))
   CALL cv_log_message(concat("Unable to find or create event_cd for ",placeholder->qual.event_disp))
  ELSE
   IF ((placeholder->qual[index].pref_id < 1.0))
    CALL cv_log_message(concat(placeholder->qual[index].pvc_name," pref not found"))
   ELSEIF ((placeholder->qual[index].pref_ec=placeholder->qual[index].event_cd))
    CALL cv_log_message(concat(placeholder->qual[index].pvc_name," pref has correct event_cd=",
      cnvtstring(placeholder->qual[index].pref_ec)))
   ELSEIF (upd_grid_event_cds_ind=0)
    CALL cv_log_message(concat(placeholder->qual[index].pvc_name," update NOT attempted. pref_ec=",
      cnvtstring(placeholder->qual[index].pref_ec),"  event_cd=",cnvtstring(placeholder->qual[index].
       event_cd)))
   ELSE
    UPDATE  FROM name_value_prefs nvp
     SET nvp.merge_id = placeholder->qual[index].event_cd
     WHERE (nvp.name_value_prefs_id=placeholder->qual[index].pref_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL cv_log_message(concat("FAILED update of ",placeholder->qual[index].pvc_name,"==>",
       cnvtstring(placeholder->qual[index].event_cd)))
    ELSE
     CALL cv_log_message(concat("UPDATED ",placeholder->qual[index].pvc_name,"==>",cnvtstring(
        placeholder->qual[index].event_cd)))
    ENDIF
   ENDIF
   IF ((placeholder->qual[index].xref_id=0.0))
    CALL cv_log_message(concat(placeholder->qual[index].xref_internal_name," xref not found"))
   ELSEIF ((placeholder->qual[index].xref_ec=placeholder->qual[index].event_cd))
    CALL cv_log_message(concat(placeholder->qual[index].xref_internal_name," has correct event_cd= ",
      cnvtstring(placeholder->qual[index].xref_ec)))
   ELSE
    UPDATE  FROM cv_xref cx
     SET cx.event_cd = placeholder->qual[index].event_cd
     WHERE (cx.xref_internal_name=placeholder->qual[index].xref_internal_name)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL cv_log_message(concat("FAILED update of ",placeholder->qual[index].xref_internal_name,
       " event_cd to ",cnvtstring(placeholder->qual[index].event_cd)))
    ELSE
     CALL cv_log_message(concat("UPDATED ",placeholder->qual[index].xref_internal_name,
       " event_cd to ",cnvtstring(placeholder->qual[index].event_cd)))
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 CALL cv_log_message("'Commit go' to keep any changes made")
 SET modify = nopredeclare
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
 DECLARE cv_upd_display_grid_vrsn = vc WITH private, constant("001 MH9140 05/08/2007")
END GO
