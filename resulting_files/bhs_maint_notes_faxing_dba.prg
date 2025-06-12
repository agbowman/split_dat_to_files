CREATE PROGRAM bhs_maint_notes_faxing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Fax Mode:" = "APC",
  "Action:" = "ADD",
  "Search:" = "",
  "Select Note:" = 0
  WITH outdev, s_mode, s_action,
  s_search, f_note_id
 DECLARE ms_output = vc WITH protect, constant(trim( $OUTDEV))
 DECLARE ms_mode = vc WITH protect, constant(trim(cnvtupper( $S_MODE)))
 DECLARE ms_action = vc WITH protect, constant(trim(cnvtupper( $S_ACTION)))
 DECLARE ms_search = vc WITH protect, constant(trim(cnvtupper( $S_SEARCH)))
 DECLARE mf_note_id = f8 WITH protect, constant(cnvtreal( $F_NOTE_ID))
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE mc_status = c1 WITH protect, noconstant("F")
 DECLARE mf_row_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_note_disp = vc WITH protect, noconstant(" ")
 IF (mf_note_id=0.0)
  SET ms_msg = "No note selected."
  GO TO exit_script
 ELSE
  SELECT INTO "nl:"
   FROM scr_pattern sp
   WHERE sp.scr_pattern_id=mf_note_id
   HEAD sp.scr_pattern_id
    ms_note_disp = sp.display
   WITH nocounter
  ;end select
 ENDIF
 IF (ms_action="ADD")
  SELECT INTO "nl:"
   FROM bhs_event_cd_list b
   WHERE b.event_cd=mf_note_id
    AND b.listkey="NOTES FAXING"
    AND b.grouper=ms_mode
    AND b.active_ind=0
   HEAD b.event_cd
    mf_row_id = b.event_cd_list_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM bhs_event_cd_list b
    SET b.active_ind = 1
    WHERE b.event_cd_list_id=mf_row_id
    WITH nocounter
   ;end update
   SET ms_msg = "Existing inactive list item was reactivated"
   CALL echo(ms_msg)
  ELSE
   INSERT  FROM bhs_event_cd_list b
    SET b.active_ind = 1, b.event_cd = mf_note_id, b.event_cd_list_id = seq(bhs_eks_seq,nextval),
     b.grouper = ms_mode, b.grouper_id = 1, b.list = "NOTES FAXING",
     b.listkey = "NOTES FAXING", b.updt_id = reqinfo->updt_id, b.updt_dt_tm = sysdate
    WITH nocounter
   ;end insert
   SET ms_msg = "New row added"
   CALL echo(ms_msg)
  ENDIF
 ELSEIF (ms_action="REMOVE")
  UPDATE  FROM bhs_event_cd_list b
   SET b.active_ind = 0, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = sysdate
   WHERE b.event_cd=mf_note_id
    AND b.listkey="NOTES FAXING"
    AND b.grouper=ms_mode
    AND b.active_ind=1
   WITH nocounter
  ;end update
  SET ms_msg = "Row inactivated"
  CALL echo(ms_msg)
 ENDIF
 SET mc_status = "S"
#exit_script
 IF (mc_status="F")
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "FAIL: No Actions Performed", row + 1,
    col 0, ms_msg
   WITH nocounter
  ;end select
 ELSEIF (mc_status="S")
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "SUCCESS: ", ms_note_disp,
    col 0, row + 1, ms_msg
   WITH nocounter
  ;end select
 ENDIF
END GO
