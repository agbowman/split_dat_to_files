CREATE PROGRAM cmn_mie_del_import_info:dba
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
 IF ( NOT (validate(cmn_mie_del_imp_act_functions)))
  EXECUTE cmn_mie_del_imp_act_functions
  DECLARE cmn_mie_del_imp_act_functions = i2 WITH protect
 ENDIF
 IF ( NOT (validate(cmn_mie_del_import_info_reply)))
  RECORD cmn_mie_del_import_info_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(import_activity_list)))
  RECORD import_activity_list(
    1 list[*]
      2 cmn_import_activity_id = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(viewpoints)))
  RECORD viewpoints(
    1 list[*]
      2 mp_viewpoint_id = f8
      2 viewpoint_name = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::process_delete_list(null) = null WITH protect
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   SET cmn_mie_del_import_info_reply->status_data.status = "F"
   CALL process_delete_list(null)
   CALL exit_with_status("S",curprog,"S","","",
    cmn_mie_del_import_info_reply)
 END ;Subroutine
 SUBROUTINE PUBLIC::process_delete_list(null)
  DECLARE view_cnt = i4 WITH protect, noconstant(0)
  FOR (view_cnt = 1 TO size(cmn_mie_del_import_info_request->views,5))
    CALL perform_delete(cmn_mie_del_import_info_request->views[view_cnt].br_datamart_category_id)
  ENDFOR
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(cmn_mie_del_import_info_reply)
 ENDIF
END GO
