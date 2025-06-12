CREATE PROGRAM aps_chg_omf_ta_reporting:dba
 SET message = window
 SET width = 132
 SET transcription_activity_ind = 0
 SET chars_per_line = 0
 CALL omf_display_screen(1,1,24,80)
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
#omf_capture
 SET accept = change
 SET home = off
 CALL clear(04,43,37)
 IF (transcription_activity_ind=0)
  CALL text(04,43,"N")
 ELSE
  CALL text(04,43,"Y")
 ENDIF
 CALL accept(04,43,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET transcription_activity_ind = 1
  GO TO omf_chars_per_line
 ELSEIF (curaccept="N")
  SET transcription_activity_ind = 0
  CALL clear(08,47,33)
  GO TO omf_correct
 ELSE
  GO TO omf_capture
 ENDIF
#omf_chars_per_line
 SET accept = change
 SET home = off
 CALL clear(08,47,33)
 IF (chars_per_line > 0)
  CALL text(08,47,cnvtstring(chars_per_line))
 ELSE
  CALL text(08,47,"75")
 ENDIF
 CALL accept(08,47,"999")
 IF (curaccept > 0)
  SET chars_per_line = curaccept
  GO TO omf_correct
 ELSE
  GO TO omf_chars_per_line
 ENDIF
#omf_correct
 SET accept = change
 SET home = off
 CALL clear(14,18,62)
 CALL accept(14,18,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(14,18,62)
 IF (curaccept="Y")
  GO TO omf_upd_dm_info_table
 ELSEIF (curaccept="N")
  GO TO omf_capture
 ELSE
  GO TO omf_correct
 ENDIF
#omf_upd_dm_info_table
 SET home = off
 CALL clear(24,1,80)
 CALL video(ib)
 CALL text(24,01,"*** Updating DM Info Table ***")
 CALL video(n)
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="TRANSCRIPTION ACTIVITY"
 ;end delete
 DELETE  FROM dm_info
  WHERE info_domain="ANATOMIC PATHOLOGY"
   AND info_name="TRANSCRIPTION CHARS PER LINE"
 ;end delete
 INSERT  FROM dm_info
  SET info_domain = "ANATOMIC PATHOLOGY", info_name = "TRANSCRIPTION ACTIVITY", info_number =
   transcription_activity_ind,
   updt_id = 0, updt_task = 0, updt_cnt = 0,
   updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 INSERT  FROM dm_info
  SET info_domain = "ANATOMIC PATHOLOGY", info_name = "TRANSCRIPTION CHARS PER LINE", info_number =
   chars_per_line,
   updt_id = 0, updt_task = 0, updt_cnt = 0,
   updt_applctx = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 COMMIT
 CALL clear(24,01,80)
 CALL text(24,01,"*** Updated DM Info Table ***")
 GO TO end_program
 SUBROUTINE omf_display_screen(is1_beg_row,is1_beg_col,is1_nbr_rows,is1_nbr_cols)
   IF (is1_beg_row=1
    AND is1_beg_col=1)
    SET accept = video(n)
    CALL video(n)
    CALL clear(1,1)
    CALL video(i)
    CALL box(01,01,23,80)
    CALL line(03,01,80,"XH")
    CALL text(02,03,"PathNet Anatomic Pathology - Transcription Statistics")
    CALL text(04,03,"Capture transcription statistics? (Y/N)")
    CALL text(06,03," Note: The capability to capture transcription statistics is not retroactive.")
    CALL text(08,03,"How many characters equal one line of text?")
    CALL text(10,03," Note: The number of characters per line calculation does not impact data")
    CALL text(11,03,"       storage. Once statistics are captured, you may adjust this parameter")
    CALL text(12,03,"       and re-run reports using the new value.")
    CALL text(14,03,"Correct? (Y/N)")
    CALL text(22,67,"(PF3 to exit)")
   ENDIF
 END ;Subroutine
 SUBROUTINE omf_clear_screen(is7_beg_row,is7_end_row,is7_beg_col,is7_length)
   FOR (x = is7_beg_row TO is7_end_row)
     CALL clear(x,is7_beg_col,is7_length)
   ENDFOR
 END ;Subroutine
#end_program
END GO
