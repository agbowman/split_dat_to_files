CREATE PROGRAM aps_chg_system_prefs:dba
 SET message = window
 SET width = 132
 DECLARE event_date_time_override_ind = i2 WITH noconstant(0)
 DECLARE transcription_activity_ind = i2 WITH noconstant(0)
 DECLARE snomed_not_clinsig_ind = i2 WITH noconstant(0)
 DECLARE suppress_non_primitive_events_ind = i2 WITH noconstant(0)
 DECLARE chars_per_line = i2 WITH noconstant(0)
 DECLARE print_cassette_label_ind = i2 WITH noconstant(0)
 CALL prefs_display_screen(1,1,24,80)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="EVENT DATE TIME OVERRIDE"
  DETAIL
   event_date_time_override_ind = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="SNOMED NOT CLINSIG"
  DETAIL
   snomed_not_clinsig_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="SUPPRESS NON-PRIMITIVE EVENTS"
  DETAIL
   suppress_non_primitive_events_ind = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="TRANSCRIPTION ACTIVITY"
  DETAIL
   transcription_activity_ind = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="TRANSCRIPTION CHARS PER LINE"
  DETAIL
   chars_per_line = di.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
   AND di.info_name="PRINT CASSETTE LABELS"
  DETAIL
   print_cassette_label_ind = di.info_number
  WITH nocounter
 ;end select
#prefs_capture
 SET accept = change
 SET home = off
 CALL clear(04,74,37)
 IF (event_date_time_override_ind=0)
  CALL text(04,74,"N")
 ELSE
  CALL text(04,74,"Y")
 ENDIF
 CALL accept(04,74,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET event_date_time_override_ind = 1
  GO TO prefs_snomed_clinsig
 ELSEIF (curaccept="N")
  SET event_date_time_override_ind = 0
  GO TO prefs_snomed_clinsig
 ELSE
  GO TO prefs_capture
 ENDIF
#prefs_snomed_clinsig
 SET accept = change
 SET home = off
 CALL clear(06,61,37)
 IF (snomed_not_clinsig_ind=0)
  CALL text(06,61,"Y")
 ELSE
  CALL text(06,61,"N")
 ENDIF
 CALL accept(06,61,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET snomed_not_clinsig_ind = 0
  GO TO prefs_suppress_non_prim_events
 ELSEIF (curaccept="N")
  SET snomed_not_clinsig_ind = 1
  GO TO prefs_suppress_non_prim_events
 ELSE
  GO TO prefs_capture
 ENDIF
#prefs_suppress_non_prim_events
 SET accept = change
 SET home = off
 CALL clear(08,77,37)
 IF (suppress_non_primitive_events_ind=0)
  CALL text(08,77,"N")
 ELSE
  CALL text(08,77,"Y")
 ENDIF
 CALL accept(08,77,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET suppress_non_primitive_events_ind = 1
  GO TO prefs_transcription_activity
 ELSEIF (curaccept="N")
  SET suppress_non_primitive_events_ind = 0
  GO TO prefs_transcription_activity
 ELSE
  GO TO prefs_capture
 ENDIF
#prefs_transcription_activity
 SET accept = change
 SET home = off
 CALL clear(10,43,37)
 IF (transcription_activity_ind=0)
  CALL text(10,43,"N")
 ELSE
  CALL text(10,43,"Y")
 ENDIF
 CALL accept(10,43,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET transcription_activity_ind = 1
  GO TO prefs_chars_per_line
 ELSEIF (curaccept="N")
  SET transcription_activity_ind = 0
  CALL clear(13,47,33)
  GO TO prefs_print_cassette_labels
 ELSE
  GO TO prefs_capture
 ENDIF
#prefs_chars_per_line
 SET accept = change
 SET home = off
 CALL clear(13,47,33)
 IF (chars_per_line > 0)
  CALL text(13,47,cnvtstring(chars_per_line))
 ELSE
  CALL text(13,47,"75")
 ENDIF
 CALL accept(13,47,"999")
 IF (curaccept > 0)
  SET chars_per_line = curaccept
  GO TO prefs_print_cassette_labels
 ELSE
  GO TO prefs_chars_per_line
 ENDIF
#prefs_print_cassette_labels
 SET accept = change
 SET home = off
 CALL clear(18,32,37)
 IF (print_cassette_label_ind=0)
  CALL text(18,32,"N")
 ELSE
  CALL text(18,32,"Y")
 ENDIF
 CALL accept(18,32,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET print_cassette_label_ind = 1
  GO TO prefs_correct
 ELSEIF (curaccept="N")
  SET print_cassette_label_ind = 0
  GO TO prefs_correct
 ELSE
  GO TO prefs_print_cassette_labels
 ENDIF
#prefs_correct
 SET accept = change
 SET home = off
 CALL clear(20,18,62)
 CALL accept(20,18,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(20,18,62)
 IF (curaccept="Y")
  GO TO prefs_upd_dm_info_table
 ELSEIF (curaccept="N")
  GO TO prefs_capture
 ELSE
  GO TO prefs_correct
 ENDIF
#prefs_upd_dm_info_table
 SET home = off
 CALL clear(24,1,80)
 CALL video(ib)
 CALL text(24,01,"*** Updating DM Info Table ***")
 CALL video(n)
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="EVENT DATE TIME OVERRIDE"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="SNOMED NOT CLINSIG"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="SUPPRESS NON-PRIMITIVE EVENTS"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="TRANSCRIPTION ACTIVITY"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="TRANSCRIPTION CHARS PER LINE"
  WITH nocounter
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="PRINT CASSETTE LABELS"
  WITH nocounter
 ;end delete
 IF (event_date_time_override_ind=1)
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "EVENT DATE TIME OVERRIDE", info_number =
    event_date_time_override_ind,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 IF (snomed_not_clinsig_ind=1)
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "SNOMED NOT CLINSIG", info_number =
    snomed_not_clinsig_ind,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 IF (suppress_non_primitive_events_ind=1)
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "SUPPRESS NON-PRIMITIVE EVENTS", info_number
     = suppress_non_primitive_events_ind,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 IF (transcription_activity_ind=1)
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "TRANSCRIPTION ACTIVITY", info_number =
    transcription_activity_ind,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "TRANSCRIPTION CHARS PER LINE", info_number =
    chars_per_line,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 IF (print_cassette_label_ind=1)
  INSERT  FROM dm_info
   SET info_domain = "ANATOMIC PATHOLOGY", info_name = "PRINT CASSETTE LABELS", info_number =
    print_cassette_label_ind,
    updt_id = 0, updt_task = 0, updt_cnt = 0,
    updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
 CALL clear(24,01,80)
 CALL text(24,01,"*** Updated DM Info Table ***")
 GO TO end_program
 SUBROUTINE prefs_display_screen(is1_beg_row,is1_beg_col,is1_nbr_rows,is1_nbr_cols)
   IF (is1_beg_row=1
    AND is1_beg_col=1)
    SET accept = video(n)
    CALL video(n)
    CALL clear(1,1)
    CALL video(i)
    CALL box(01,01,23,80)
    CALL line(03,01,80,"XH")
    CALL text(02,03,"PathNet Anatomic Pathology - System Preferences")
    CALL text(04,03,"Post case collection date for report event start/end date times? (Y/N)")
    CALL text(06,03,"Are changes to snomed codes clinically significant? (Y/N)")
    CALL text(08,03,"Suppress display of events not associated to a primitive event set? (Y/N)")
    CALL text(10,03,"Capture transcription statistics? (Y/N)")
    CALL text(11,03," Note: The capability to capture transcription statistics is not retroactive.")
    CALL text(13,03,"How many characters equal one line of text?")
    CALL text(14,03," Note: The number of characters per line calculation does not impact data")
    CALL text(15,03,"       storage. Once statistics are captured, you may adjust this parameter")
    CALL text(16,03,"       and re-run reports using the new value.")
    CALL text(18,03,"Print cassette labels? (Y/N)")
    CALL text(20,03,"Correct? (Y/N)")
    CALL text(22,67,"(PF3 to exit)")
   ENDIF
 END ;Subroutine
 SUBROUTINE prefs_clear_screen(is7_beg_row,is7_end_row,is7_beg_col,is7_length)
   FOR (x = is7_beg_row TO is7_end_row)
     CALL clear(x,is7_beg_col,is7_length)
   ENDFOR
 END ;Subroutine
#end_program
END GO
