CREATE PROGRAM cmn_mie_del_imp_act_functions:dba
 DECLARE PUBLIC::perform_delete(br_datamart_category_id=f8) = null WITH copy, protect
 DECLARE PUBLIC::delete_import_activity(null) = null WITH copy, protect
 DECLARE PUBLIC::get_import_activity_list(import_name=vc) = null WITH copy, protect
 SUBROUTINE PUBLIC::perform_delete(br_datamart_category_id)
   DECLARE br_datamart_category_name = vc WITH protect, noconstant("")
   DECLARE viewpoint_idx = i4 WITH protect, noconstant(0)
   DECLARE viewpoint_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category bdc
    PLAN (bdc
     WHERE bdc.br_datamart_category_id=br_datamart_category_id)
    DETAIL
     br_datamart_category_name = bdc.category_mean
    WITH nocounter
   ;end select
   CALL errorcheck(cmn_mie_del_import_info_reply,"Perform_Delete")
   IF (curqual > 0)
    CALL get_import_activity_list(br_datamart_category_name)
    CALL delete_import_activity(null)
    SELECT INTO "nl:"
     FROM mp_viewpoint_reltn mvr,
      mp_viewpoint mvp
     PLAN (mvr
      WHERE mvr.br_datamart_category_id=br_datamart_category_id)
      JOIN (mvp
      WHERE mvp.mp_viewpoint_id=mvr.mp_viewpoint_id
       AND mvp.active_ind=true)
     HEAD mvr.mp_viewpoint_id
      viewpoint_cnt = (viewpoint_cnt+ 1), stat = alterlist(viewpoints->list,viewpoint_cnt),
      viewpoints->list[viewpoint_cnt].mp_viewpoint_id = mvr.mp_viewpoint_id,
      viewpoints->list[viewpoint_cnt].viewpoint_name = mvp.viewpoint_name
     WITH nocounter
    ;end select
    CALL errorcheck(cmn_mie_del_import_info_reply,"Select_Viewpoints")
    FOR (viewpoint_idx = 1 TO size(viewpoints->list,5))
      SELECT INTO "nl:"
       FROM mp_viewpoint_reltn mvr
       PLAN (mvr
        WHERE (mvr.mp_viewpoint_id=viewpoints->list[viewpoint_idx].mp_viewpoint_id))
       WITH nocounter
      ;end select
      CALL errorcheck(cmn_mie_del_import_info_reply,"Viewpoint_Reltns")
      IF (curqual=1)
       CALL get_import_activity_list(viewpoints->list[viewpoint_idx].viewpoint_name)
       CALL delete_import_activity(null)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::delete_import_activity(null)
   IF (size(import_activity_list->list,5) > 0)
    DELETE  FROM cmn_name_swap_activity cnsa,
      (dummyt d  WITH seq = value(size(import_activity_list->list,5)))
     SET cnsa.seq = 1
     PLAN (d)
      JOIN (cnsa
      WHERE (cnsa.cmn_import_activity_id=import_activity_list->list[d.seq].cmn_import_activity_id))
     WITH nocounter
    ;end delete
    CALL errorcheck(cmn_mie_del_import_info_reply,"Delete_Import_Activity_cmn_name_swap_activity")
    DELETE  FROM cmn_import_activity cia,
      (dummyt d  WITH seq = value(size(import_activity_list->list,5)))
     SET cia.seq = 1
     PLAN (d)
      JOIN (cia
      WHERE (cia.cmn_import_activity_id=import_activity_list->list[d.seq].cmn_import_activity_id))
     WITH nocounter
    ;end delete
    CALL errorcheck(cmn_mie_del_import_info_reply,"Delete_Import_Activity_cmn_import_activity")
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::get_import_activity_list(import_name)
   DECLARE import_activity_count = i4 WITH protect, noconstant(0)
   SET stat = initrec(import_activity_list)
   SELECT INTO "nl:"
    FROM cmn_import_activity cia
    PLAN (cia
     WHERE ((cia.requested_name=import_name) OR (cia.replacement_name=import_name)) )
    DETAIL
     import_activity_count = (import_activity_count+ 1), stat = alterlist(import_activity_list->list,
      import_activity_count), import_activity_list->list[import_activity_count].
     cmn_import_activity_id = cia.cmn_import_activity_id
    WITH nocounter
   ;end select
   CALL errorcheck(cmn_mie_del_import_info_reply,"Get_Import_Activity_List")
 END ;Subroutine
END GO
