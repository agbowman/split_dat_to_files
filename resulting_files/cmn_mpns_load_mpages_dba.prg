CREATE PROGRAM cmn_mpns_load_mpages:dba
 PROMPT
  "Outdev : " = "MINE",
  "process_guid: " = ""
  WITH outdev, process_guid
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
 DECLARE import_type_mpage = vc WITH protect, constant("MPAGE")
 DECLARE import_type_viewpoint = vc WITH protect, constant("VIEWPOINT")
 DECLARE parent_entity_mpage = vc WITH protect, constant("BR_DATAMART_CATEGORY")
 DECLARE parent_entity_viewpoint = vc WITH protect, constant("MP_VIEWPOINT")
 DECLARE activity_status_in_progress = vc WITH protect, constant("IN_PROGRESS")
 DECLARE activity_status_success = vc WITH protect, constant("SUCCESS")
 DECLARE activity_status_failed = vc WITH protect, constant("FAILED")
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 IF ( NOT (validate(cmn_string_utils_imported)))
  EXECUTE cmn_string_utils
 ENDIF
 DECLARE date_format = vc WITH protect, constant("dd-mmm-yyyy hh:mm")
 RECORD reply(
   1 viewpoints[*]
     2 viewpoint_name = vc
     2 created_names[*]
       3 process_guid = vc
       3 created_name = vc
       3 imported_by_user = vc
       3 import_dt_tm = vc
       3 last_nameswap_user = vc
       3 last_nameswap_dt_tm = dq8
       3 name_change_ind = i2
       3 previous_nameswap_ind = i2
       3 mpages[*]
         4 requested_name = vc
         4 requested_meaning = vc
         4 created_name = vc
         4 created_meaning = vc
         4 previous_nameswap_ind = i2
   1 mpages[*]
     2 category_name = vc
     2 category_meaning = vc
     2 layout_flag = i4
     2 created_names[*]
       3 created_name = vc
       3 created_meaning = vc
       3 imported_by_user = vc
       3 import_dt_tm = vc
       3 last_nameswap_user = vc
       3 last_nameswap_dt_tm = dq8
       3 previous_nameswap_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD tmp_rec(
   1 viewpoints[*]
     2 viewpoint_name = vc
     2 created_names[*]
       3 process_guid = vc
       3 created_name = vc
       3 imported_by_user = vc
       3 import_dt_tm = vc
       3 last_nameswap_user = vc
       3 last_nameswap_dt_tm = dq8
       3 created_name_qual_flag = i2
       3 previous_nameswap_ind = i2
       3 mpages[*]
         4 requested_name = vc
         4 requested_meaning = vc
         4 created_name = vc
         4 created_meaning = vc
         4 previous_nameswap_ind = i2
 ) WITH protect
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::load_viewpoints_for_name_swap(null) = null WITH protect
 DECLARE PUBLIC::load_mpages_for_name_swap(null) = null WITH protect
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   SET reply->status_data.status = "F"
   CALL load_viewpoints_for_name_swap(null)
   CALL load_mpages_for_name_swap(null)
   CALL exit_with_status("S",curprog,"S","","",
    reply)
 END ;Subroutine
 SUBROUTINE PUBLIC::load_viewpoints_for_name_swap(null)
   DECLARE created_name_cnt = i4 WITH protect, noconstant(0)
   DECLARE viewpoint_created_name_cnt = i4 WITH protect, noconstant(0)
   DECLARE mpage_cnt = i4 WITH protect, noconstant(0)
   DECLARE viewpoint_cnt = i4 WITH protect, noconstant(0)
   DECLARE mpage_name_swap_cnt = i4 WITH protect, noconstant(0)
   DECLARE viewpoint_import_name_changed = i2 WITH protect, noconstant(false)
   DECLARE mpage_import_name_changed = i2 WITH protect, noconstant(false)
   SELECT INTO "nl:"
    FROM cmn_import_activity cia_v,
     mp_viewpoint mv_rp,
     mp_viewpoint mv_rq,
     prsnl pr_ia_v,
     cmn_name_swap_activity cnsa_v,
     prsnl pr_ns_v,
     mp_viewpoint_reltn mvr,
     cmn_import_activity cia_m,
     br_datamart_category bdc_rp,
     br_datamart_category bdc_rq,
     cmn_name_swap_activity cnsa_m
    PLAN (cia_v
     WHERE cia_v.cmn_import_type=import_type_viewpoint
      AND cia_v.repl_parent_entity_name=parent_entity_viewpoint
      AND (cia_v.process_guid=
     IF (cmnisnotblank( $PROCESS_GUID))  $PROCESS_GUID
     ELSE cia_v.process_guid
     ENDIF
     ))
     JOIN (mv_rp
     WHERE mv_rp.mp_viewpoint_id=cia_v.repl_parent_entity_id
      AND mv_rp.active_ind=true)
     JOIN (mv_rq
     WHERE mv_rq.viewpoint_name=cia_v.requested_name
      AND mv_rq.active_ind=true)
     JOIN (pr_ia_v
     WHERE pr_ia_v.person_id=outerjoin(cia_v.performing_prsnl_id))
     JOIN (cnsa_v
     WHERE cnsa_v.cmn_import_activity_id=outerjoin(cia_v.cmn_import_activity_id))
     JOIN (pr_ns_v
     WHERE pr_ns_v.person_id=outerjoin(cnsa_v.performing_prsnl_id))
     JOIN (mvr
     WHERE mvr.mp_viewpoint_id=cia_v.repl_parent_entity_id)
     JOIN (cia_m
     WHERE cia_m.repl_parent_entity_id=mvr.br_datamart_category_id
      AND cia_m.cmn_import_type=import_type_mpage
      AND cia_m.repl_parent_entity_name=parent_entity_mpage
      AND (cia_m.process_guid=
     IF (cmnisnotblank( $PROCESS_GUID))  $PROCESS_GUID
     ELSE cia_m.process_guid
     ENDIF
     ))
     JOIN (bdc_rp
     WHERE bdc_rp.category_mean=cia_m.replacement_name)
     JOIN (bdc_rq
     WHERE bdc_rq.category_mean=cia_m.requested_name)
     JOIN (cnsa_m
     WHERE cnsa_m.cmn_import_activity_id=outerjoin(cia_m.cmn_import_activity_id))
    ORDER BY cia_v.requested_name, cia_v.replacement_name, cia_m.cmn_import_activity_id,
     cnsa_m.cmn_name_swap_activity_id, cnsa_v.cmn_name_swap_activity_id
    HEAD cia_v.requested_name
     stat = initrec(tmp_rec), viewpoint_import_name_changed = false, mpage_import_name_changed =
     false,
     created_name_cnt = 0, viewpoint_created_name_cnt = 0, stat = alterlist(tmp_rec->viewpoints,1),
     tmp_rec->viewpoints[1].viewpoint_name = cia_v.requested_name
    HEAD cia_v.replacement_name
     mpage_cnt = 0, created_name_cnt = (created_name_cnt+ 1), stat = alterlist(tmp_rec->viewpoints[1]
      .created_names,created_name_cnt),
     tmp_rec->viewpoints[1].created_names[created_name_cnt].created_name_qual_flag = false
     IF (cia_v.requested_name != cia_v.replacement_name)
      viewpoint_import_name_changed = true, tmp_rec->viewpoints[1].created_names[created_name_cnt].
      created_name_qual_flag = true
     ENDIF
     tmp_rec->viewpoints[1].created_names[created_name_cnt].created_name = cia_v.replacement_name,
     tmp_rec->viewpoints[1].created_names[created_name_cnt].imported_by_user = pr_ia_v
     .name_full_formatted, tmp_rec->viewpoints[1].created_names[created_name_cnt].import_dt_tm =
     format(cia_v.import_dt_tm,date_format),
     tmp_rec->viewpoints[1].created_names[created_name_cnt].process_guid = cia_v.process_guid
    HEAD cia_m.cmn_import_activity_id
     mpage_name_swap_cnt = 0
     IF (cia_m.requested_name != cia_m.replacement_name)
      mpage_import_name_changed = true, tmp_rec->viewpoints[1].created_names[created_name_cnt].
      created_name_qual_flag = true
     ENDIF
     mpage_cnt = (mpage_cnt+ 1), stat = alterlist(tmp_rec->viewpoints[1].created_names[
      created_name_cnt].mpages,mpage_cnt), tmp_rec->viewpoints[1].created_names[created_name_cnt].
     mpages[mpage_cnt].requested_name = bdc_rq.category_name,
     tmp_rec->viewpoints[1].created_names[created_name_cnt].mpages[mpage_cnt].requested_meaning =
     bdc_rq.category_mean, tmp_rec->viewpoints[1].created_names[created_name_cnt].mpages[mpage_cnt].
     created_name = bdc_rp.category_name, tmp_rec->viewpoints[1].created_names[created_name_cnt].
     mpages[mpage_cnt].created_meaning = bdc_rp.category_mean
    HEAD cnsa_m.cmn_name_swap_activity_id
     IF (cnsa_m.cmn_name_swap_activity_id != 0.0)
      mpage_name_swap_cnt = (mpage_name_swap_cnt+ 1)
     ENDIF
    FOOT  cia_v.requested_name
     IF (((viewpoint_import_name_changed) OR (mpage_import_name_changed)) )
      viewpoint_cnt = (viewpoint_cnt+ 1), stat = alterlist(reply->viewpoints,viewpoint_cnt), reply->
      viewpoints[viewpoint_cnt].viewpoint_name = tmp_rec->viewpoints[1].viewpoint_name
      FOR (created_name_idx = 1 TO size(tmp_rec->viewpoints[1].created_names,5))
        IF ((tmp_rec->viewpoints[1].created_names[created_name_idx].created_name_qual_flag=true))
         viewpoint_created_name_cnt = (viewpoint_created_name_cnt+ 1), stat = alterlist(reply->
          viewpoints[viewpoint_cnt].created_names,viewpoint_created_name_cnt), reply->viewpoints[
         viewpoint_cnt].created_names[viewpoint_created_name_cnt].created_name = tmp_rec->viewpoints[
         1].created_names[created_name_idx].created_name,
         reply->viewpoints[viewpoint_cnt].created_names[viewpoint_created_name_cnt].process_guid =
         tmp_rec->viewpoints[1].created_names[created_name_idx].process_guid, reply->viewpoints[
         viewpoint_cnt].created_names[viewpoint_created_name_cnt].imported_by_user = tmp_rec->
         viewpoints[1].created_names[created_name_idx].imported_by_user, reply->viewpoints[
         viewpoint_cnt].created_names[viewpoint_created_name_cnt].import_dt_tm = tmp_rec->viewpoints[
         1].created_names[created_name_idx].import_dt_tm,
         reply->viewpoints[viewpoint_cnt].created_names[viewpoint_created_name_cnt].
         last_nameswap_dt_tm = tmp_rec->viewpoints[1].created_names[created_name_idx].
         last_nameswap_dt_tm, reply->viewpoints[viewpoint_cnt].created_names[
         viewpoint_created_name_cnt].last_nameswap_user = tmp_rec->viewpoints[1].created_names[
         created_name_idx].last_nameswap_user, reply->viewpoints[viewpoint_cnt].created_names[
         viewpoint_created_name_cnt].name_change_ind = viewpoint_import_name_changed,
         reply->viewpoints[viewpoint_cnt].created_names[viewpoint_created_name_cnt].
         previous_nameswap_ind = tmp_rec->viewpoints[1].created_names[created_name_idx].
         previous_nameswap_ind
         IF (size(tmp_rec->viewpoints[1].created_names[created_name_idx].mpages,5) > 0)
          FOR (mpage_idx = 1 TO size(tmp_rec->viewpoints[1].created_names[created_name_idx].mpages,5)
           )
            stat = alterlist(reply->viewpoints[viewpoint_cnt].created_names[
             viewpoint_created_name_cnt].mpages,mpage_idx), reply->viewpoints[viewpoint_cnt].
            created_names[viewpoint_created_name_cnt].mpages[mpage_idx].requested_name = tmp_rec->
            viewpoints[1].created_names[created_name_idx].mpages[mpage_idx].requested_name, reply->
            viewpoints[viewpoint_cnt].created_names[viewpoint_created_name_cnt].mpages[mpage_idx].
            requested_meaning = tmp_rec->viewpoints[1].created_names[created_name_idx].mpages[
            mpage_idx].requested_meaning,
            reply->viewpoints[viewpoint_cnt].created_names[viewpoint_created_name_cnt].mpages[
            mpage_idx].created_name = tmp_rec->viewpoints[1].created_names[created_name_idx].mpages[
            mpage_idx].created_name, reply->viewpoints[viewpoint_cnt].created_names[
            viewpoint_created_name_cnt].mpages[mpage_idx].created_meaning = tmp_rec->viewpoints[1].
            created_names[created_name_idx].mpages[mpage_idx].created_meaning, reply->viewpoints[
            viewpoint_cnt].created_names[viewpoint_created_name_cnt].mpages[mpage_idx].
            previous_nameswap_ind = tmp_rec->viewpoints[1].created_names[created_name_idx].mpages[
            mpage_idx].previous_nameswap_ind
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
    FOOT  cia_v.replacement_name
     tmp_rec->viewpoints[1].created_names[created_name_cnt].last_nameswap_user = pr_ns_v
     .name_full_formatted, tmp_rec->viewpoints[1].created_names[created_name_cnt].last_nameswap_dt_tm
      = cnsa_v.name_swap_dt_tm
     IF (cnsa_v.cmn_name_swap_activity_id != 0.0)
      tmp_rec->viewpoints[1].created_names[created_name_cnt].previous_nameswap_ind = true
     ELSE
      tmp_rec->viewpoints[1].created_names[created_name_cnt].previous_nameswap_ind = false
     ENDIF
    FOOT  cia_m.cmn_import_activity_id
     IF (cia_m.requested_name != cia_m.replacement_name)
      IF (mpage_name_swap_cnt > 0)
       tmp_rec->viewpoints[1].created_names[created_name_cnt].mpages[mpage_cnt].previous_nameswap_ind
        = true
      ELSE
       tmp_rec->viewpoints[1].created_names[created_name_cnt].mpages[mpage_cnt].previous_nameswap_ind
        = false
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL errorcheck(reply,"Load_Viewpoints_For_Name_Swap select")
 END ;Subroutine
 SUBROUTINE PUBLIC::load_mpages_for_name_swap(null)
   DECLARE mpage_cnt = i4 WITH protect, noconstant(0)
   DECLARE created_name_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cmn_import_activity cia,
     prsnl pr_ia,
     br_datamart_category bdc_rp,
     br_datamart_category bdc_rq,
     cmn_name_swap_activity cnsa,
     prsnl pr_ns
    PLAN (cia
     WHERE cia.cmn_import_type=import_type_mpage
      AND cia.repl_parent_entity_name=parent_entity_mpage
      AND cia.replacement_name != cia.requested_name
      AND (cia.process_guid=
     IF (cmnisnotblank( $PROCESS_GUID))  $PROCESS_GUID
     ELSE cia.process_guid
     ENDIF
     ))
     JOIN (pr_ia
     WHERE pr_ia.person_id=outerjoin(cia.performing_prsnl_id))
     JOIN (bdc_rp
     WHERE bdc_rp.category_mean=cia.replacement_name)
     JOIN (bdc_rq
     WHERE bdc_rq.category_mean=cia.requested_name)
     JOIN (cnsa
     WHERE cnsa.cmn_import_activity_id=outerjoin(cia.cmn_import_activity_id))
     JOIN (pr_ns
     WHERE pr_ns.person_id=outerjoin(cnsa.performing_prsnl_id))
    ORDER BY cia.requested_name, cia.replacement_name, cnsa.cmn_name_swap_activity_id
    HEAD cia.requested_name
     created_name_cnt = 0, mpage_cnt = (mpage_cnt+ 1), stat = alterlist(reply->mpages,mpage_cnt),
     reply->mpages[mpage_cnt].category_name = bdc_rq.category_name, reply->mpages[mpage_cnt].
     category_meaning = bdc_rq.category_mean, reply->mpages[mpage_cnt].layout_flag = bdc_rq
     .layout_flag
    HEAD cia.replacement_name
     created_name_cnt = (created_name_cnt+ 1), stat = alterlist(reply->mpages[mpage_cnt].
      created_names,created_name_cnt), reply->mpages[mpage_cnt].created_names[created_name_cnt].
     created_name = bdc_rp.category_name,
     reply->mpages[mpage_cnt].created_names[created_name_cnt].created_meaning = cia.replacement_name,
     reply->mpages[mpage_cnt].created_names[created_name_cnt].imported_by_user = pr_ia
     .name_full_formatted, reply->mpages[mpage_cnt].created_names[created_name_cnt].import_dt_tm =
     format(cia.import_dt_tm,date_format)
    HEAD cnsa.cmn_name_swap_activity_id
     IF (cnsa.cmn_name_swap_activity_id != 0.0)
      reply->mpages[mpage_cnt].created_names[created_name_cnt].previous_nameswap_ind = true
     ELSE
      reply->mpages[mpage_cnt].created_names[created_name_cnt].previous_nameswap_ind = false
     ENDIF
    FOOT  cia.replacement_name
     reply->mpages[mpage_cnt].created_names[created_name_cnt].last_nameswap_user = pr_ns
     .name_full_formatted, reply->mpages[mpage_cnt].created_names[created_name_cnt].
     last_nameswap_dt_tm = cnsa.name_swap_dt_tm
    WITH nocounter
   ;end select
   CALL errorcheck(reply,"Load_MPages_For_Name_Swap select")
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(reply)
 ENDIF
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(reply)
 ENDIF
END GO
