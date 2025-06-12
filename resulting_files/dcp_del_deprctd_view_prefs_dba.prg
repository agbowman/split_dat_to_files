CREATE PROGRAM dcp_del_deprctd_view_prefs:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE"
  WITH outdev
 FREE RECORD view_contexts
 RECORD view_contexts(
   1 contexts[*]
     2 frame_type = c12
     2 view_name = c12
     2 views[*]
       3 application_number = i4
       3 position_cd = f8
       3 prsnl_id = f8
       3 view_seq = i4
 )
 FREE RECORD views_to_delete
 RECORD views_to_delete(
   1 views[*]
     2 view_prefs_id = f8
 )
 FREE RECORD details_to_delete
 RECORD details_to_delete(
   1 details[*]
     2 detail_prefs_id = f8
 )
 FREE RECORD viewcomps_to_delete
 RECORD viewcomps_to_delete(
   1 viewcomps[*]
     2 view_comp_prefs_id = f8
 )
 DECLARE getdeprecatedviews(null) = null
 DECLARE getdetailprefs(null) = null
 DECLARE deletedetailprefs(null) = null
 DECLARE getviewcompprefs(null) = null
 DECLARE deleteviewcompprefs(null) = null
 DECLARE deleteviewprefs(null) = null
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE temp = i4 WITH noconstant(0)
 DECLARE seq = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE context_cnt = i4 WITH noconstant(0)
 DECLARE context_views_cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant
 DECLARE script_status = vc
 DECLARE script_message = vc
 SET script_status = "Z"
 SET script_message = "dcp_del_deprctd_view_prefs: No Obsolete Views Found in Domain"
 CALL echo("Searching for Obsolete Views...")
 CALL getdeprecatedviews(null)
 CALL echo(build("Number of Obsolete Views Found: ",size(views_to_delete->views,5)))
 CALL getdetailprefs(null)
 IF (size(details_to_delete->details,5) > 0)
  CALL echo(build("Removing ",size(details_to_delete->details,5),
    " DETAIL_PREFS rows associated with Obsolete Views..."))
  CALL deletedetailprefs(null)
 ENDIF
 CALL getviewcompprefs(null)
 IF (size(viewcomps_to_delete->viewcomps,5) > 0)
  CALL echo(build("Removing ",size(viewcomps_to_delete->viewcomps,5),
    " VIEW_COMP_PREFS rows associated with Obsolete Views..."))
  CALL deleteviewcompprefs(null)
 ENDIF
 CALL echo("Removing Obsolete Views...")
 CALL deleteviewprefs(null)
 SET script_status = "S"
 SET script_message = "dcp_del_deprctd_view_prefs:  Obsolete Views Removed Successfully"
 GO TO exit_script
 SUBROUTINE getdeprecatedviews(null)
   SELECT INTO "nl:"
    vp.view_prefs_id, vp.prsnl_id, vp.position_cd,
    vp.application_number, vp.frame_type, vp.view_name,
    vp.view_seq
    FROM view_prefs vp
    WHERE vp.view_name IN ("PATHWAYS", "ISTRIP", "EASYSCRIPT", "MEDPROFILE", "ENCSUMMARY",
    "ENCNTRSUMM", "LVFLOWSHEET", "INBOX", "GRAPHVIEW", "CURPATHWAY",
    "NEWPATHWAY", "GROWTHCHART", "ENCOUNTER", "PROBLIST", "PROCEDURES")
    ORDER BY vp.view_prefs_id
    HEAD REPORT
     cnt = 0, context_cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > size(views_to_delete->views,5))
      stat = alterlist(views_to_delete->views,(cnt+ 10))
     ENDIF
     views_to_delete->views[cnt].view_prefs_id = vp.view_prefs_id, bfound = 0
     IF (context_cnt != 0)
      FOR (x = 1 TO context_cnt)
        IF ((view_contexts->contexts[x].frame_type=vp.frame_type)
         AND (view_contexts->contexts[x].view_name=vp.view_name))
         context_views_cnt = (size(view_contexts->contexts[x].views,5)+ 1), stat = alterlist(
          view_contexts->contexts[x].views,context_views_cnt), view_contexts->contexts[x].views[
         context_views_cnt].prsnl_id = vp.prsnl_id,
         view_contexts->contexts[x].views[context_views_cnt].position_cd = vp.position_cd,
         view_contexts->contexts[x].views[context_views_cnt].application_number = vp
         .application_number, view_contexts->contexts[x].views[context_views_cnt].view_seq = vp
         .view_seq,
         bfound = 1, BREAK
        ENDIF
      ENDFOR
     ENDIF
     IF (bfound=0)
      context_cnt = (context_cnt+ 1)
      IF (context_cnt > size(view_contexts->contexts,5))
       stat = alterlist(view_contexts->contexts,(context_cnt+ 10))
      ENDIF
      view_contexts->contexts[context_cnt].view_name = vp.view_name, view_contexts->contexts[
      context_cnt].frame_type = vp.frame_type, stat = alterlist(view_contexts->contexts[context_cnt].
       views,1),
      view_contexts->contexts[context_cnt].views[1].prsnl_id = vp.prsnl_id, view_contexts->contexts[
      context_cnt].views[1].position_cd = vp.position_cd, view_contexts->contexts[context_cnt].views[
      1].application_number = vp.application_number,
      view_contexts->contexts[context_cnt].views[1].view_seq = vp.view_seq
     ENDIF
    FOOT REPORT
     stat = alterlist(views_to_delete->views,cnt), stat = alterlist(view_contexts->contexts,
      context_cnt)
    WITH nocounter
   ;end select
   IF (size(views_to_delete->views,5)=0)
    GO TO exit_script
   ENDIF
   FOR (x = 1 TO size(view_contexts->contexts,5))
    SET temp = size(view_contexts->contexts[x].views,5)
    IF (x=1)
     SET cur_list_size = temp
    ELSE
     IF (cur_list_size < temp)
      SET cur_list_size = temp
     ENDIF
    ENDIF
   ENDFOR
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   FOR (x = 1 TO size(view_contexts->contexts,5))
     SET context_cnt = size(view_contexts->contexts[x].views,5)
     SET stat = alterlist(view_contexts->contexts[x].views,new_list_size)
     FOR (idx = (context_cnt+ 1) TO new_list_size)
       SET view_contexts->contexts[x].views[idx].prsnl_id = view_contexts->contexts[x].views[
       context_cnt].prsnl_id
       SET view_contexts->contexts[x].views[idx].position_cd = view_contexts->contexts[x].views[
       context_cnt].position_cd
       SET view_contexts->contexts[x].views[idx].application_number = view_contexts->contexts[x].
       views[context_cnt].application_number
       SET view_contexts->contexts[x].views[idx].view_seq = view_contexts->contexts[x].views[
       context_cnt].view_seq
     ENDFOR
   ENDFOR
   IF (error(error_msg,1) != 0)
    SET script_status = "F"
    SET script_message = concat("GetDeprecatedViews: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getdetailprefs(null)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(view_contexts->contexts,5))),
    (dummyt d1  WITH seq = value(loop_cnt)),
    detail_prefs dp
   PLAN (d)
    JOIN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (dp
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),(dp.prsnl_id+ 0),view_contexts->contexts[d.seq
     ].views[idx].prsnl_id,
     dp.position_cd,view_contexts->contexts[d.seq].views[idx].position_cd,(dp.application_number+ 0),
     view_contexts->contexts[d.seq].views[idx].application_number,dp.view_seq,
     view_contexts->contexts[d.seq].views[idx].view_seq)
     AND dp.view_name IN (view_contexts->contexts[d.seq].view_name, view_contexts->contexts[d.seq].
    frame_type))
   ORDER BY dp.detail_prefs_id
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (dp.detail_prefs_id > 0.0)
     pos = locateval(num,nstart,size(details_to_delete->details,5),dp.detail_prefs_id,
      details_to_delete->details[num].detail_prefs_id)
     IF (pos <= 0)
      cnt = (cnt+ 1)
      IF (cnt > size(details_to_delete->details,5))
       stat = alterlist(details_to_delete->details,(cnt+ 10))
      ENDIF
      details_to_delete->details[cnt].detail_prefs_id = dp.detail_prefs_id
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(details_to_delete->details,cnt)
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   SET script_status = "F"
   SET script_message = concat("GetDetailPrefs: ",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE deletedetailprefs(null)
   DELETE  FROM name_value_prefs nvp,
     (dummyt d  WITH seq = value(size(details_to_delete->details,5)))
    SET nvp.seq = 1
    PLAN (d)
     JOIN (nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=details_to_delete->details[d.seq].detail_prefs_id))
    WITH nocounter
   ;end delete
   DELETE  FROM detail_prefs dp,
     (dummyt d  WITH seq = value(size(details_to_delete->details,5)))
    SET dp.seq = 1
    PLAN (d)
     JOIN (dp
     WHERE (dp.detail_prefs_id=details_to_delete->details[d.seq].detail_prefs_id))
    WITH nocounter
   ;end delete
   IF (error(error_msg,1) != 0)
    SET script_status = "F"
    SET script_message = concat("DeleteDetailPrefs: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getviewcompprefs(null)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(view_contexts->contexts,5))),
    (dummyt d1  WITH seq = value(loop_cnt)),
    view_comp_prefs vcp
   PLAN (d)
    JOIN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (vcp
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),(vcp.prsnl_id+ 0),view_contexts->contexts[d
     .seq].views[idx].prsnl_id,
     vcp.position_cd,view_contexts->contexts[d.seq].views[idx].position_cd,(vcp.application_number+ 0
     ),view_contexts->contexts[d.seq].views[idx].application_number,vcp.view_seq,
     view_contexts->contexts[d.seq].views[idx].view_seq)
     AND vcp.view_name IN (view_contexts->contexts[d.seq].view_name, view_contexts->contexts[d.seq].
    frame_type))
   ORDER BY vcp.view_comp_prefs_id
   HEAD REPORT
    cnt = 0
   DETAIL
    IF (vcp.view_comp_prefs_id > 0.0)
     pos = locateval(num,nstart,size(viewcomps_to_delete->viewcomps,5),vcp.view_comp_prefs_id,
      viewcomps_to_delete->viewcomps[num].view_comp_prefs_id)
     IF (pos <= 0)
      cnt = (cnt+ 1)
      IF (cnt > size(viewcomps_to_delete->viewcomps,5))
       stat = alterlist(viewcomps_to_delete->viewcomps,(cnt+ 10))
      ENDIF
      viewcomps_to_delete->viewcomps[cnt].view_comp_prefs_id = vcp.view_comp_prefs_id
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(viewcomps_to_delete->viewcomps,cnt)
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   SET script_status = "F"
   SET script_message = concat("GetViewCompPrefs: ",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteviewcompprefs(null)
   DELETE  FROM name_value_prefs nvp,
     (dummyt d  WITH seq = value(size(viewcomps_to_delete->viewcomps,5)))
    SET nvp.seq = 1
    PLAN (d)
     JOIN (nvp
     WHERE nvp.parent_entity_name="VIEW_COMP_PREFS"
      AND (nvp.parent_entity_id=viewcomps_to_delete->viewcomps[d.seq].view_comp_prefs_id))
    WITH nocounter
   ;end delete
   DELETE  FROM view_comp_prefs vcp,
     (dummyt d  WITH seq = value(size(viewcomps_to_delete->viewcomps,5)))
    SET vcp.seq = 1
    PLAN (d)
     JOIN (vcp
     WHERE (vcp.view_comp_prefs_id=viewcomps_to_delete->viewcomps[d.seq].view_comp_prefs_id))
    WITH nocounter
   ;end delete
   IF (error(error_msg,1) != 0)
    SET script_status = "F"
    SET script_message = concat("DeleteViewCompPrefs: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteviewprefs(null)
   DELETE  FROM name_value_prefs nvp,
     (dummyt d  WITH seq = value(size(views_to_delete->views,5)))
    SET nvp.seq = 1
    PLAN (d)
     JOIN (nvp
     WHERE nvp.parent_entity_name="VIEW_PREFS"
      AND (nvp.parent_entity_id=views_to_delete->views[d.seq].view_prefs_id))
    WITH nocounter
   ;end delete
   DELETE  FROM view_prefs vp,
     (dummyt d  WITH seq = value(size(views_to_delete->views,5)))
    SET vp.seq = 1
    PLAN (d)
     JOIN (vp
     WHERE (vp.view_prefs_id=views_to_delete->views[d.seq].view_prefs_id))
    WITH nocounter
   ;end delete
   IF (error(error_msg,1) != 0)
    SET script_status = "F"
    SET script_message = concat("DeleteViewPrefs: ",error_msg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (script_status="S")
  CALL echo("Committing Deletions...")
  COMMIT
 ELSEIF (script_status != "Z")
  CALL echo("Error Encountered: Rolling Back Deletions")
  ROLLBACK
 ENDIF
 SELECT INTO  $1
  FROM dummyt d
  DETAIL
   CALL print(script_message)
  WITH nocounter
 ;end select
 FREE RECORD details_to_delete
 FREE RECORD viewcomps_to_delete
 FREE RECORD views_to_delete
 FREE RECORD view_contexts
END GO
