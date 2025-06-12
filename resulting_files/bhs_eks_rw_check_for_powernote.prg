CREATE PROGRAM bhs_eks_rw_check_for_powernote
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter CLINICAL_EVENT_ID:" = "0.00",
  "Enter PowerNote CKI Identifiers:" = ""
  WITH outdev, clinevent_id, cki_values
 DECLARE eks_ind = i2 WITH noconstant(1)
 DECLARE cs29520_powernote_cd = f8 WITH constant(uar_get_code_by("MEANING",29520,"POWERNOTE"))
 DECLARE ce_event_id = f8
 DECLARE check_for_powernote(zero=i2) = null
 DECLARE attempt_cnt = i4
 DECLARE wait_timer = c6
 IF (validate(eksevent,"A")="A"
  AND validate(eksevent,"Z")="Z")
  DECLARE log_message = vc
  DECLARE retval = i4 WITH noconstant(- (1))
  DECLARE log_misc1 = vc
  SET eks_ind = 0
 ENDIF
 IF (substring(1,1,reflect(parameter(3,0)))="L")
  SET log_message = build2("CLINICAL_EVENT_ID: ",trim(build2(cnvtreal( $CLINEVENT_ID)),3))
  SET tmp_s = 1
  WHILE (trim(reflect(parameter(3,tmp_s)),3) > " "
   AND tmp_s < 100)
   IF (tmp_s=1)
    SET log_message = build2(log_message,' | CKI_VALUES: "',trim(build2(parameter(3,tmp_s)),3),'"')
   ELSE
    SET log_message = build2(log_message,', "',trim(build2(parameter(3,tmp_s)),3),'"')
   ENDIF
   SET tmp_s = (tmp_s+ 1)
  ENDWHILE
  FREE SET tmp_s
 ELSE
  SET log_message = build2("CLINICAL_EVENT_ID: ",trim(build2(cnvtreal( $CLINEVENT_ID)),3),
   ' | CKI_VALUE: "',trim(build2( $CKI_VALUES),3),'"')
 ENDIF
 SET retval = 0
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinical_event_id=cnvtreal( $CLINEVENT_ID)
    AND ce.entry_mode_cd=cs29520_powernote_cd)
  DETAIL
   ce_event_id = ce.event_id
  WITH nocounter
 ;end select
 IF (ce_event_id <= 0.00)
  SET log_message = build2(log_message," | Clinical Event not a PowerNote")
  GO TO exit_script
 ENDIF
 SET attempt_cnt = 1
 CALL check_for_powernote(0)
 WHILE (attempt_cnt <= 5)
   SET wait_timer = format(curtime3,"HHMMSS;;M")
   WHILE (format(curtime3,"HHMMSS;;M")=wait_timer)
     CALL pause(1)
   ENDWHILE
   SET attempt_cnt = (attempt_cnt+ 1)
   CALL check_for_powernote(0)
 ENDWHILE
 IF (attempt_cnt < 999)
  SET log_message = build2(log_message," | Maximum attempts reached. Exitting Script")
 ENDIF
 SUBROUTINE check_for_powernote(zero)
   SELECT INTO "NL:"
    FROM scd_story ss,
     scd_story_pattern ssp,
     dummyt d,
     scr_pattern sp
    PLAN (ss
     WHERE ce_event_id=ss.event_id)
     JOIN (ssp
     WHERE ss.scd_story_id=ssp.scd_story_id)
     JOIN (d)
     JOIN (sp
     WHERE ssp.scr_pattern_id=sp.scr_pattern_id
      AND (sp.cki_identifier= $CKI_VALUES))
    DETAIL
     attempt_cnt = 999, log_misc1 = trim(build2(ss.scd_story_id),3), log_message = build2(trim(
       log_message,3)," | ","SCD_STORY_ID: ",trim(build2(ss.scd_story_id),3)," | ",
      "SCR_PATTERN_ID: ",trim(build2(sp.scr_pattern_id),3))
     IF (sp.scr_pattern_id > 0.00)
      retval = 100
     ELSE
      retval = 0
     ENDIF
    WITH outerjoin = d, nocounter
   ;end select
 END ;Subroutine
#exit_script
 IF (eks_ind=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    cur_row = 0
   DETAIL
    IF (size(trim(log_message,3)) > 128)
     col 0,
     CALL print(substring(1,128,log_message)), row + 1,
     cur_row = 1
     WHILE (((size(trim(log_message,3)) - (cur_row * 128)) > 0))
       col 0,
       CALL print(substring(((cur_row * 128)+ 1),128,log_message)), row + 1,
       cur_row = (cur_row+ 1)
     ENDWHILE
    ELSE
     row + 1, col 0,
     CALL print(substring(1,128,log_message))
    ENDIF
    row + 1, col 0,
    CALL print(build2("RETVAL = ",trim(build2(retval),3)))
   WITH nocounter
  ;end select
 ENDIF
 FREE SET eks_ind
 FREE SET cs29520_powernote_cd
 FREE SET ce_event_id
 FREE SET check_for_powernote
 FREE SET attempt_cnt
 FREE SET wait_timer
END GO
