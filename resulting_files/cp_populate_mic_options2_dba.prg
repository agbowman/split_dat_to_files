CREATE PROGRAM cp_populate_mic_options2:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE cmo_table_exists_ind = i2
 DECLARE cmo2_table_exists_ind = i2
 DECLARE status_readme = c1
 DECLARE status_message = vc
 DECLARE highest_option_flag = i4
 DECLARE active_status_cd = f8
 DECLARE inactive_status_cd = f8
 DECLARE old_table_rows_cnt = i4
 DECLARE new_table_rows_cnt = i4
 DECLARE error_code = f8
 SET errmsg = fillstring(132," ")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
   AND cv.active_ind=1
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_status_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_status_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET status_readme = "F"
 SET status_message = "Script Not Complete"
 FREE RECORD old_options_rec
 RECORD old_options_rec(
   1 qual[*]
     2 option_flag = i2
     2 option_name = vc
     2 active_ind = i2
     2 option_value = vc
     2 updt_id = f8
     2 updt_dt_tm = dq8
 )
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  WHERE d.object_name IN ("CHART_MIC_OPTIONS", "CHART_MIC_OPTIONS2")
   AND d.object="T"
  HEAD REPORT
   do_nothing = 0
  DETAIL
   IF (d.object_name="CHART_MIC_OPTIONS")
    cmo_table_exists_ind = 1
   ELSE
    cmo2_table_exists_ind = 1
   ENDIF
  WITH counter
 ;end select
 CALL echo(build("CMO_table_exists_ind = ",cmo_table_exists_ind))
 CALL echo(build("CMO2_table_exists_ind = ",cmo2_table_exists_ind))
 IF (cmo2_table_exists_ind=0)
  SET status_readme = "F"
  SET status_message = "CHART_MIC_OPTIONS2 table does not exist."
  GO TO exit_script
 ENDIF
 IF (cmo_table_exists_ind=1)
  SET highest_option_flag = 0
  SELECT INTO "nl:"
   c2.*
   FROM chart_mic_options2 c2
   ORDER BY c2.chart_mic_options_id DESC
   HEAD REPORT
    highest_option_flag = c2.chart_mic_options_id
   WITH nocounter
  ;end select
  CALL echo(build("highest_option_flag = ",highest_option_flag))
  IF (highest_option_flag=0)
   SELECT INTO "nl:"
    cmo.*
    FROM chart_mic_options cmo
    ORDER BY cmo.option_flag
    HEAD REPORT
     o_cnt = 0, old_table_rows_cnt = 0
    DETAIL
     o_cnt += 1
     IF (mod(o_cnt,10)=1)
      stat = alterlist(old_options_rec->qual,(o_cnt+ 9))
     ENDIF
     old_options_rec->qual[o_cnt].option_flag = cmo.option_flag, old_options_rec->qual[o_cnt].
     option_name = cmo.option_name, old_options_rec->qual[o_cnt].active_ind = cmo.active_ind,
     old_options_rec->qual[o_cnt].option_value = cmo.option_value, old_options_rec->qual[o_cnt].
     updt_id = cmo.updt_id, old_options_rec->qual[o_cnt].updt_dt_tm = cmo.updt_dt_tm
    FOOT REPORT
     stat = alterlist(old_options_rec->qual,o_cnt), old_table_rows_cnt = o_cnt
    WITH counter
   ;end select
   CALL echo(build("old_table_rows_cnt = ",old_table_rows_cnt))
   IF (size(old_options_rec->qual,5) > 0)
    INSERT  FROM chart_mic_options2 c2,
      (dummyt d  WITH seq = value(size(old_options_rec->qual,5)))
     SET c2.chart_mic_options_id = old_options_rec->qual[d.seq].option_flag, c2.option_name =
      old_options_rec->qual[d.seq].option_name, c2.updt_id = old_options_rec->qual[d.seq].updt_id,
      c2.updt_dt_tm = cnvtdatetime(old_options_rec->qual[d.seq].updt_dt_tm), c2
      .active_status_prsnl_id = old_options_rec->qual[d.seq].updt_id, c2.active_status_dt_tm =
      cnvtdatetime(old_options_rec->qual[d.seq].updt_dt_tm),
      c2.active_status_cd =
      IF ((old_options_rec->qual[d.seq].active_ind=1)) active_status_cd
      ELSE inactive_status_cd
      ENDIF
      , c2.active_ind = old_options_rec->qual[d.seq].active_ind, c2.option_value = old_options_rec->
      qual[d.seq].option_value,
      c2.updt_applctx = 0, c2.updt_task = 0
     PLAN (d)
      JOIN (c2)
     WITH nocounter
    ;end insert
   ENDIF
  ENDIF
  SET error_code = error(errmsg,0)
  IF (error_code != 0)
   SET status_readme = "F"
   SET status_message = errmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET highest_option_flag = 0
 SELECT INTO "nl:"
  c2.*
  FROM chart_mic_options2 c2
  ORDER BY c2.chart_mic_options_id DESC
  HEAD REPORT
   highest_option_flag = c2.chart_mic_options_id
  WITH nocounter
 ;end select
 CALL echo(build("highest_option_flag = ",highest_option_flag))
 FREE RECORD option_name_rec
 RECORD option_name_rec(
   1 qual[58]
     2 option_name = vc
 )
 SET option_name_rec->qual[1].option_name = "Microbiology Options"
 SET option_name_rec->qual[2].option_name = "Font Size"
 SET option_name_rec->qual[3].option_name = "Dosage"
 SET option_name_rec->qual[4].option_name = "Tradename"
 SET option_name_rec->qual[5].option_name = "Max Number of Organisms Horizontally"
 SET option_name_rec->qual[6].option_name = "Corrected Symbol"
 SET option_name_rec->qual[7].option_name = "Legend #1"
 SET option_name_rec->qual[8].option_name = ""
 SET option_name_rec->qual[9].option_name = "Organism Location"
 SET option_name_rec->qual[10].option_name = "Cost Per Dosage"
 SET option_name_rec->qual[11].option_name = "Corrected Results Location"
 SET option_name_rec->qual[12].option_name = "Bolding"
 SET option_name_rec->qual[13].option_name = "Organism Name"
 SET option_name_rec->qual[14].option_name = "Paper Size"
 SET option_name_rec->qual[15].option_name = "Susceptibility Method Header"
 SET option_name_rec->qual[16].option_name = "Verified Date/Time"
 SET option_name_rec->qual[17].option_name = "Legend Justification"
 SET option_name_rec->qual[18].option_name = "Legend #2"
 SET option_name_rec->qual[19].option_name = ""
 SET option_name_rec->qual[20].option_name = "Underline Susceptibility Headings"
 SET option_name_rec->qual[21].option_name = "Smart Captions"
 SET option_name_rec->qual[22].option_name = "Show Procedure"
 SET option_name_rec->qual[23].option_name = "Procedure Caption"
 SET option_name_rec->qual[24].option_name = "Show Source"
 SET option_name_rec->qual[25].option_name = "Source Caption"
 SET option_name_rec->qual[26].option_name = "Show Body Site"
 SET option_name_rec->qual[27].option_name = "Body Site Caption"
 SET option_name_rec->qual[28].option_name = "Show Freetext Source"
 SET option_name_rec->qual[29].option_name = "Freetext Source Caption"
 SET option_name_rec->qual[30].option_name = "Show Suspected Pathogen"
 SET option_name_rec->qual[31].option_name = "Suspected Pathogen Caption"
 SET option_name_rec->qual[32].option_name = "Show Collected Date/Time"
 SET option_name_rec->qual[33].option_name = "Collected Date/Time Caption"
 SET option_name_rec->qual[34].option_name = "Show Started Date/Time"
 SET option_name_rec->qual[35].option_name = "Started Date/Time Caption"
 SET option_name_rec->qual[36].option_name = "Show Accession Number"
 SET option_name_rec->qual[37].option_name = "Accession Number Caption"
 SET option_name_rec->qual[38].option_name = "Preliminary Report Caption"
 SET option_name_rec->qual[39].option_name = "Final Report Caption"
 SET option_name_rec->qual[40].option_name = "Amended Report Caption"
 SET option_name_rec->qual[41].option_name = "Stain Report Caption"
 SET option_name_rec->qual[42].option_name = "Global Report Caption"
 SET option_name_rec->qual[43].option_name = "Footnotes Caption"
 SET option_name_rec->qual[44].option_name = "Interpretive Results Caption"
 SET option_name_rec->qual[45].option_name = "Order Comments Caption"
 SET option_name_rec->qual[46].option_name = "Susceptibility Results Caption"
 SET option_name_rec->qual[47].option_name = "Dosage Caption"
 SET option_name_rec->qual[48].option_name = "Cost Per Dosage Caption"
 SET option_name_rec->qual[49].option_name = "Tradename Caption"
 SET option_name_rec->qual[50].option_name = "Date Format"
 SET option_name_rec->qual[51].option_name = "Time Format"
 SET option_name_rec->qual[52].option_name = "Interpretation Column Width"
 SET option_name_rec->qual[53].option_name = "Dilution/Zone Column Width"
 SET option_name_rec->qual[54].option_name = "Dosage Column Width"
 SET option_name_rec->qual[55].option_name = "Cost/Dosage Column Width"
 SET option_name_rec->qual[56].option_name = "Tradename Column Width"
 SET option_name_rec->qual[57].option_name = "Legend"
 SET option_name_rec->qual[58].option_name = "Accession Sorting"
 FOR (x = 1 TO 58)
   IF (x > highest_option_flag)
    CALL echo(build("INSERTING OPTION_FLAG = ",x))
    INSERT  FROM chart_mic_options2 c2
     SET c2.chart_mic_options_id = x, c2.option_name = option_name_rec->qual[x].option_name, c2
      .active_ind = 0,
      c2.option_value = "", c2.updt_id = 0, c2.updt_dt_tm = cnvtdatetime(sysdate),
      c2.active_status_prsnl_id = 0, c2.active_status_dt_tm = cnvtdatetime(sysdate), c2
      .active_status_cd = inactive_status_cd,
      c2.updt_applctx = 0, c2.updt_task = 0
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SET error_code = error(errmsg,0)
 IF (error_code != 0)
  SET status_readme = "F"
  SET status_message = errmsg
  GO TO exit_script
 ENDIF
 SET highest_option_flag = 0
 SELECT INTO "nl:"
  c2.chart_mic_options_id
  FROM chart_mic_options2 c2
  ORDER BY c2.chart_mic_options_id DESC
  HEAD REPORT
   highest_option_flag = c2.chart_mic_options_id
  WITH nocounter
 ;end select
 IF (highest_option_flag=58)
  SET status_readme = "S"
  SET status_message =
  "SUCCESS - The CHART_MIC_OPTIONS2 table was successfully created and populated."
 ENDIF
#exit_script
 SET error_code = error(errmsg,0)
 IF (error_code != 0)
  SET status_readme = "F"
  SET status_message = errmsg
 ENDIF
 IF (status_readme != "F")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echo(build("STATUS_README = ",status_readme))
 CALL echo(build("STATUS_MESSAGE = ",status_message))
 SET readme_data->message = status_message
 SET readme_data->status = status_readme
 EXECUTE dm_readme_status
END GO
