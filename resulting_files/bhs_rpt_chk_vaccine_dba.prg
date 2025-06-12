CREATE PROGRAM bhs_rpt_chk_vaccine:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Current BEGINNING of flu season:" = "",
  "Current END of flu season:" = "",
  "Enter the beginning month of the flu season:" = "SEPTEMBER",
  "Enter the end month of the flu season:" = "APRIL"
  WITH outdev, s_current_beg, s_current_end,
  s_beg_month, s_end_month
 DECLARE ms_beg_month = vc WITH protect, noconstant( $S_BEG_MONTH)
 DECLARE ms_end_month = vc WITH protect, noconstant( $S_END_MONTH)
 UPDATE  FROM dm_info d
  SET d.info_char = ms_beg_month, d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
  WHERE d.info_domain="BHS_FLU_SEASON"
   AND d.info_name="BEGIN"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info d
   SET d.info_domain = "BHS_FLU_SEASON", d.info_name = "BEGIN", d.info_char = ms_beg_month,
    d.info_date = sysdate, d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ENDIF
 UPDATE  FROM dm_info d
  SET d.info_char = ms_end_month, d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
  WHERE d.info_domain="BHS_FLU_SEASON"
   AND d.info_name="END"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info d
   SET d.info_domain = "BHS_FLU_SEASON", d.info_name = "END", d.info_char = ms_end_month,
    d.info_date = sysdate, d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  HEAD REPORT
   text = build2("The current Flu season is set to begin on ",ms_beg_month," and end on ",
    ms_end_month), col 1, row 0,
   text
  WITH nocounter, maxcol = 32000
 ;end select
#end_script
END GO
