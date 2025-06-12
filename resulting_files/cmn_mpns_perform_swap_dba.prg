CREATE PROGRAM cmn_mpns_perform_swap:dba
 PROMPT
  "swap_attribute_1: " = "",
  "swap_attribute_2: " = ""
  WITH swap_attribute_1, swap_attribute_2
 DECLARE import_type_mpage = vc WITH protect, constant("MPAGE")
 DECLARE import_type_viewpoint = vc WITH protect, constant("VIEWPOINT")
 DECLARE parent_entity_mpage = vc WITH protect, constant("BR_DATAMART_CATEGORY")
 DECLARE parent_entity_viewpoint = vc WITH protect, constant("MP_VIEWPOINT")
 DECLARE activity_status_in_progress = vc WITH protect, constant("IN_PROGRESS")
 DECLARE activity_status_success = vc WITH protect, constant("SUCCESS")
 DECLARE activity_status_failed = vc WITH protect, constant("FAILED")
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 IF ( NOT (validate(swap_operation_reply)))
  RECORD swap_operation_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::check_if_valid_category_import(requested_category_name=vc,replacement_category_name=
  vc) = f8 WITH protect
 DECLARE PUBLIC::check_if_category_exists_in_bedrock(category_name=vc(ref),category_meaning=vc,
  category_id=f8(ref)) = null WITH protect
 DECLARE PUBLIC::check_if_viewpoint_exists(viewpoint_name=vc,viewpoint_name_key=vc(ref),
  mp_viewpoint_id=f8(ref)) = null WITH protect
 DECLARE PUBLIC::insert_name_swap_activity(cmn_import_activity_id=f8) = null WITH protect
 DECLARE PUBLIC::update_category_in_bedrock(from_category_name=vc,to_category_name=vc,
  to_category_meaning=vc,category_id=f8) = null WITH protect
 DECLARE PUBLIC::update_viewpoint(from_viewpoint_name=vc,to_viewpoint_name=vc,to_viewpoint_name_key=
  vc,mp_viewpoint_id=f8) = null WITH protect
 DECLARE PUBLIC::get_temp_key(import_type=vc) = vc WITH protect
 DECLARE cmn_import_type = vc WITH protect, noconstant("")
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   DECLARE cmn_import_activity_id = f8 WITH protect, noconstant(0.0)
   DECLARE category_id_1 = f8 WITH protect, noconstant(0.0)
   DECLARE category_id_2 = f8 WITH protect, noconstant(0.0)
   DECLARE category_name_1 = vc WITH protect, noconstant("")
   DECLARE category_name_2 = vc WITH protect, noconstant("")
   DECLARE mp_viewpoint_id_1 = f8 WITH protect, noconstant(0.0)
   DECLARE mp_viewpoint_id_2 = f8 WITH protect, noconstant(0.0)
   DECLARE viewpoint_name_key_1 = vc WITH protect, noconstant("")
   DECLARE viewpoint_name_key_2 = vc WITH protect, noconstant("")
   DECLARE temp_key = vc WITH protect, noconstant("")
   SET swap_operation_reply->status_data.status = "F"
   IF (( $SWAP_ATTRIBUTE_1= $SWAP_ATTRIBUTE_2))
    CALL exit_with_status("S",curprog,"S","Main","Cannot perform swap on attributes with same name.",
     swap_operation_reply)
   ENDIF
   SET cmn_import_activity_id = check_if_valid_category_import( $SWAP_ATTRIBUTE_1, $SWAP_ATTRIBUTE_2)
   SET temp_key = get_temp_key(cmn_import_type)
   IF (cmn_import_type=import_type_mpage)
    CALL check_if_category_exists_in_bedrock(category_name_1, $SWAP_ATTRIBUTE_1,category_id_1)
    CALL check_if_category_exists_in_bedrock(category_name_2, $SWAP_ATTRIBUTE_2,category_id_2)
    CALL update_category_in_bedrock(category_name_1,temp_key,temp_key,category_id_1)
    CALL update_category_in_bedrock(category_name_2,category_name_1, $SWAP_ATTRIBUTE_1,category_id_2)
    CALL update_category_in_bedrock(temp_key,category_name_2, $SWAP_ATTRIBUTE_2,category_id_1)
   ELSEIF (cmn_import_type=import_type_viewpoint)
    CALL check_if_viewpoint_exists( $SWAP_ATTRIBUTE_1,viewpoint_name_key_1,mp_viewpoint_id_1)
    CALL check_if_viewpoint_exists( $SWAP_ATTRIBUTE_2,viewpoint_name_key_2,mp_viewpoint_id_2)
    CALL update_viewpoint( $SWAP_ATTRIBUTE_1,temp_key,cnvtalphanum(temp_key),mp_viewpoint_id_1)
    CALL update_viewpoint( $SWAP_ATTRIBUTE_2, $SWAP_ATTRIBUTE_1,viewpoint_name_key_1,
     mp_viewpoint_id_2)
    CALL update_viewpoint(temp_key, $SWAP_ATTRIBUTE_2,viewpoint_name_key_2,mp_viewpoint_id_1)
   ENDIF
   CALL insert_name_swap_activity(cmn_import_activity_id)
   CALL exit_with_status("S",curprog,"S","","",
    swap_operation_reply)
 END ;Subroutine
 SUBROUTINE PUBLIC::check_if_valid_category_import(requested_category_name,replacement_category_name)
   SELECT INTO "nl:"
    FROM cmn_import_activity cia
    PLAN (cia
     WHERE ((cia.requested_name=requested_category_name
      AND cia.replacement_name=replacement_category_name) OR (cia.requested_name=
     replacement_category_name
      AND cia.replacement_name=requested_category_name
      AND ((cia.repl_parent_entity_id IN (
     (SELECT
      bdc.br_datamart_category_id
      FROM br_datamart_category bdc
      WHERE bdc.br_datamart_category_id=cia.repl_parent_entity_id))) OR (cia.repl_parent_entity_id
      IN (
     (SELECT
      mv.mp_viewpoint_id
      FROM mp_viewpoint mv
      WHERE mv.mp_viewpoint_id=cia.repl_parent_entity_id)))) )) )
    DETAIL
     cmn_import_activity_id = cia.cmn_import_activity_id, cmn_import_type = cia.cmn_import_type
    WITH nocounter
   ;end select
   CALL errorcheck(swap_operation_reply,"Validate Category Import")
   IF (curqual=0)
    CALL exit_with_status("F",curprog,"F","Validate Category Import",
     "No import record found for the requested and replacement name in cmn_import_activity",
     swap_operation_reply)
   ENDIF
   RETURN(cmn_import_activity_id)
 END ;Subroutine
 SUBROUTINE PUBLIC::check_if_category_exists_in_bedrock(category_name,category_meaning,category_id)
   SELECT INTO "nl:"
    FROM br_datamart_category bdc
    PLAN (bdc
     WHERE bdc.category_mean=category_meaning
      AND bdc.layout_flag IN (0, 1, 2, 3))
    DETAIL
     category_name = bdc.category_name, category_id = bdc.br_datamart_category_id
    WITH nocounter
   ;end select
   CALL errorcheck(swap_operation_reply,"Validate Bedrock Category")
   IF (curqual=0)
    CALL exit_with_status("F",curprog,"F","Validate Bedrock Category",concat(
      "No record found in bedrock for the category meaning",notrim(" "),category_meaning),
     swap_operation_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::check_if_viewpoint_exists(viewpoint_name,viewpoint_name_key,mp_viewpoint_id)
   SELECT INTO "nl:"
    FROM mp_viewpoint mv
    PLAN (mv
     WHERE mv.viewpoint_name=viewpoint_name
      AND mv.active_ind=true)
    DETAIL
     viewpoint_name_key = mv.viewpoint_name_key, mp_viewpoint_id = mv.mp_viewpoint_id
    WITH nocounter
   ;end select
   CALL errorcheck(swap_operation_reply,"Validate MP_ViewPoint")
   IF (curqual=0)
    CALL exit_with_status("F",curprog,"F","Validate MP_ViewPoint",concat(
      "No record found in mp_viewpoint for the view point name",notrim(" "),viewpoint_name),
     swap_operation_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::update_category_in_bedrock(from_category_name,to_category_name,
  to_category_meaning,category_id)
   UPDATE  FROM br_datamart_category bdc
    SET bdc.category_name = to_category_name, bdc.category_mean = to_category_meaning, bdc.updt_cnt
      = (bdc.updt_cnt+ 1),
     bdc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bdc.updt_id = reqinfo->updt_id, bdc.updt_task
      = reqinfo->updt_task,
     bdc.updt_applctx = reqinfo->updt_applctx
    WHERE bdc.br_datamart_category_id=category_id
     AND bdc.category_name=from_category_name
    WITH nocounter
   ;end update
   CALL errorcheck(swap_operation_reply,"Update_Category")
   IF ( NOT (curqual=1))
    CALL exit_with_status("F",curprog,"F","Update_Category",build2(
      "Error occurred while updating category name",notrim(" "),from_category_name," to ",
      to_category_name),
     swap_operation_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::get_temp_key(import_type)
   DECLARE tmp_name = vc WITH protect, constant("TMP")
   DECLARE temp_key = vc WITH protect, noconstant("TMP")
   DECLARE temp_key_found = i2 WITH protect, noconstant(false)
   DECLARE temp_counter = i4 WITH protect, noconstant(0)
   IF (import_type=import_type_mpage)
    WHILE ( NOT (temp_key_found))
     SELECT INTO "nl:"
      FROM br_datamart_category bdc
      PLAN (bdc
       WHERE bdc.category_mean=temp_key)
      WITH nocounter
     ;end select
     IF (curqual > 0)
      SET temp_counter = (temp_counter+ 1)
      SET temp_key = build(tmp_name,cnvtstring(temp_counter))
     ELSE
      SET temp_key_found = true
     ENDIF
    ENDWHILE
   ELSE
    IF (import_type=import_type_viewpoint)
     WHILE ( NOT (temp_key_found))
      SELECT INTO "nl:"
       FROM mp_viewpoint vp
       PLAN (vp
        WHERE vp.viewpoint_name=temp_key
         AND vp.active_ind=true)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       SET temp_counter = (temp_counter+ 1)
       SET temp_key = build(tmp_name,cnvtstring(temp_counter))
      ELSE
       SET temp_key_found = true
      ENDIF
     ENDWHILE
    ENDIF
   ENDIF
   CALL errorcheck(swap_operation_reply,"Get_Temp_Key")
   RETURN(temp_key)
 END ;Subroutine
 SUBROUTINE PUBLIC::update_viewpoint(from_viewpoint_name,to_viewpoint_name,to_viewpoint_name_key,
  mp_viewpoint_id)
   UPDATE  FROM mp_viewpoint mv
    SET mv.viewpoint_name = to_viewpoint_name, mv.viewpoint_name_key = to_viewpoint_name_key, mv
     .updt_cnt = (mv.updt_cnt+ 1),
     mv.updt_dt_tm = cnvtdatetime(curdate,curtime3), mv.updt_id = reqinfo->updt_id, mv.updt_task =
     reqinfo->updt_task,
     mv.updt_applctx = reqinfo->updt_applctx
    WHERE mv.mp_viewpoint_id=mp_viewpoint_id
     AND mv.viewpoint_name=from_viewpoint_name
    WITH nocounter
   ;end update
   CALL errorcheck(swap_operation_reply,"Update_Viewpoint")
   IF ( NOT (curqual=1))
    CALL exit_with_status("F",curprog,"F","Update_Viewpoint",build2(
      "Error occurred while updating view point",notrim(" "),from_viewpoint_name," to ",
      to_viewpoint_name),
     swap_operation_reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::insert_name_swap_activity(cmn_import_activity_id)
  INSERT  FROM cmn_name_swap_activity cnsa
   SET cnsa.cmn_name_swap_activity_id = seq(activity_seq,nextval), cnsa.cmn_import_activity_id =
    cmn_import_activity_id, cnsa.performing_prsnl_id = reqinfo->updt_id,
    cnsa.updt_id = reqinfo->updt_id, cnsa.updt_dt_tm = cnvtdatetime(curdate,curtime3), cnsa
    .name_swap_dt_tm = cnvtdatetime(curdate,curtime3),
    cnsa.updt_task = reqinfo->updt_task, cnsa.updt_applctx = reqinfo->updt_applctx, cnsa.updt_cnt = 0
   WITH nocounter
  ;end insert
  CALL errorcheck(swap_operation_reply,"Insert_Name_Swap_Activity")
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(swap_operation_reply)
 ENDIF
END GO
