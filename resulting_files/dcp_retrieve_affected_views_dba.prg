CREATE PROGRAM dcp_retrieve_affected_views:dba
 PROMPT
  "Output to File/Printer/MINE (Default: MINE): " = "MINE"
  WITH outdev
 FREE RECORD view_contexts
 RECORD view_contexts(
   1 contexts[*]
     2 frame_type = c12
     2 view_name = c12
     2 application_number = i4
     2 position_cd = f8
     2 position_disp = c28
     2 prsnl_id = f8
     2 view_seq = i4
     2 view_prefs_id = f8
     2 default_view_seq = c12
 )
 FREE RECORD view_contexts_seq
 RECORD view_contexts_seq(
   1 contexts_seq[*]
     2 parent_entity_id = f8
     2 display_seq = c12
 )
 DECLARE getdisplayval(null) = null
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE rept_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE seq_cnt = i4 WITH noconstant(0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE page_nbr = i4 WITH noconstant(0)
 DECLARE desplay_seq = c12 WITH noconstant("")
 CALL getdisplayval(null)
 SELECT INTO  $1
  nvp.parent_entity_id, nvp.pvc_value
  FROM name_value_prefs nvp
  WHERE expand(indx,1,size(view_contexts->contexts,5),nvp.parent_entity_id,view_contexts->contexts[
   indx].view_prefs_id)
   AND nvp.pvc_name="DISPLAY_SEQ"
  HEAD REPORT
   seq_cnt = 0, rpt_cnt = 0
  HEAD PAGE
   page_nbr = (page_nbr+ 1), col 0, "Page: ",
   col 6, page_nbr, row + 1,
   col 0, "VIEW_PREFS_ID", col 15,
   "APP_NUMBER", col 27, "POSITION",
   col 57, "PRSNL_ID", col 72,
   "FRAME_TYPE", col 87, "VIEW_NAME",
   col 102, "DISPLAY_SEQ", col 114,
   "DEFAULT_VIEW", row + 2
  DETAIL
   seq_cnt = (seq_cnt+ 1)
   IF (seq_cnt > size(view_contexts_seq->contexts_seq,5))
    stat = alterlist(view_contexts_seq->contexts_seq,(seq_cnt+ 10))
   ENDIF
   view_contexts_seq->contexts_seq[seq_cnt].parent_entity_id = nvp.parent_entity_id,
   view_contexts_seq->contexts_seq[seq_cnt].display_seq = nvp.pvc_value
   FOR (x = 1 TO size(view_contexts->contexts,5))
     IF ((nvp.parent_entity_id=view_contexts->contexts[x].view_prefs_id))
      IF ((cnvtint(nvp.pvc_value) <= (cnvtint(view_contexts->contexts[x].default_view_seq)+ 1))
       AND cnvtint(view_contexts->contexts[x].default_view_seq) < 999)
       rpt_cnt = (rpt_cnt+ 1), desplay_seq = trim(substring(0,3,nvp.pvc_value)), col 0,
       view_contexts->contexts[x].view_prefs_id, col 15, view_contexts->contexts[x].
       application_number,
       col 27, view_contexts->contexts[x].position_disp, col 57,
       view_contexts->contexts[x].prsnl_id, col 72, view_contexts->contexts[x].frame_type,
       col 87, view_contexts->contexts[x].view_name, col 102,
       desplay_seq, col 114, view_contexts->contexts[x].default_view_seq,
       row + 1
      ENDIF
     ENDIF
   ENDFOR
  FOOT REPORT
   stat = alterlist(view_contexts_seq->contexts_seq,seq_cnt), row + 1, col 0,
   "Total default Views affected: ", col 34, rpt_cnt
  WITH nocounter
 ;end select
 GO TO exit_script
 SUBROUTINE getdisplayval(null)
  SELECT INTO "nl:"
   vp.frame_type, vp.view_name, vp.application_number,
   vp_position_disp = uar_get_code_display(vp.position_cd), vp.prsnl_id, vp.view_seq,
   nvp.pvc_value, vp.view_prefs_id
   FROM view_prefs vp,
    app_prefs ap,
    name_value_prefs nvp
   PLAN (vp
    WHERE vp.view_name IN ("PATHWAYS", "ISTRIP", "EASYSCRIPT", "MEDPROFILE", "ENCSUMMARY",
    "ENCNTRSUMM", "LVFLOWSHEET", "INBOX", "GRAPHVIEW", "CURPATHWAY",
    "NEWPATHWAY", "GROWTHCHART", "ENCOUNTER", "PROBLIST", "PROCEDURES"))
    JOIN (ap
    WHERE vp.position_cd=ap.position_cd
     AND vp.application_number=ap.application_number
     AND vp.prsnl_id=ap.prsnl_id)
    JOIN (nvp
    WHERE nvp.parent_entity_id=ap.app_prefs_id
     AND nvp.pvc_name="DEFAULT_VIEWS")
   ORDER BY vp.view_name, vp.frame_type, vp.application_number,
    vp_position_disp, vp.prsnl_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > size(view_contexts->contexts,5))
     stat = alterlist(view_contexts->contexts,(cnt+ 10))
    ENDIF
    view_contexts->contexts[cnt].application_number = vp.application_number, view_contexts->contexts[
    cnt].frame_type = vp.frame_type, view_contexts->contexts[cnt].view_name = vp.view_name,
    view_contexts->contexts[cnt].position_cd = vp.position_cd, view_contexts->contexts[cnt].
    position_disp = vp_position_disp, view_contexts->contexts[cnt].prsnl_id = vp.prsnl_id,
    view_contexts->contexts[cnt].view_seq = vp.view_seq, view_contexts->contexts[cnt].view_prefs_id
     = vp.view_prefs_id
    IF (vp.frame_type="ORG")
     view_contexts->contexts[cnt].default_view_seq = trim(substring(0,(findstring(",",nvp.pvc_value)
        - 1),nvp.pvc_value))
    ELSEIF (vp.frame_type="CHART")
     view_contexts->contexts[cnt].default_view_seq = trim(substring((findstring(",",nvp.pvc_value)+ 1
       ),4,nvp.pvc_value))
    ELSE
     view_contexts->contexts[cnt].default_view_seq = "999"
    ENDIF
   FOOT REPORT
    stat = alterlist(view_contexts->contexts,cnt)
   WITH nocounter
  ;end select
  CALL echorecord(view_contexts)
 END ;Subroutine
#exit_script
 FREE RECORD view_contexts
 FREE RECORD view_contexts_seq
END GO
