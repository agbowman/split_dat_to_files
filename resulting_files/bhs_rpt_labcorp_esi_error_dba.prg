CREATE PROGRAM bhs_rpt_labcorp_esi_error:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_start_dt, s_stop_dt
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs89_labcorpamb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,
   "LABCORPAMB"))
 DECLARE mf_cs89_labcorpambunmatch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,
   "LABCORPAMBUNMATCH"))
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
        5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_start_dt = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
 IF (cnvtupper(trim( $3,3))="CURDATE*")
  SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
  SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
  SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
        0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
 ELSE
  SET mf_stop_dt = cnvtdatetime(concat(trim( $3,3)," 23:59:59"))
 ENDIF
 SELECT INTO  $OUTDEV
  sending_system = trim(uar_get_code_display(e.contributor_system_cd),3), create_date = format(e
   .create_dt_tm,";;q"), req_id =
  IF (findstring("TXA|",o.msg_text,1,0) > 0) trim(piece(substring(findstring("TXA|",o.msg_text,1,0),
      500,o.msg_text),"|",16,"Unknown"),3)
  ELSE trim(piece(substring(findstring("OBR|",o.msg_text,1,0),500,o.msg_text),"|",3,"Unknown"))
  ENDIF
  ,
  pat_name = trim(cnvtupper(e.name_full_formatted),3), location = trim(uar_get_code_description(enc
    .loc_facility_cd),3), time = format(e.create_dt_tm,"YYYY-MM-DD HH:MM:SS;;d"),
  error_text = trim(e.error_text), hl7_entity_code = trim(e.hl7_entity_code,3)
  FROM esi_log e,
   oen_txlog o,
   encounter enc
  WHERE e.tx_key=o.tx_key
   AND e.error_stat="ESI_STAT_FAILURE"
   AND e.contributor_system_cd IN (mf_cs89_labcorpamb_cd, mf_cs89_labcorpambunmatch_cd)
   AND e.create_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
   AND e.encntr_id=enc.encntr_id
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
