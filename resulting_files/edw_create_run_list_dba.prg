CREATE PROGRAM edw_create_run_list:dba
 DECLARE stat = i4 WITH protect
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE printdebugstatement(debug_message=vc) = null WITH public
 DECLARE printlogmsg(message=vc) = null WITH public
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 DECLARE current_date = dq8 WITH protect
 DECLARE output_cnt = i4 WITH protect, noconstant(0)
 DECLARE output_file = vc WITH protect, noconstant("cer_extract:edw_file_run_list.txt")
 DECLARE input_file = vc WITH protect, noconstant("CER_INSTALL:EDW_MTA_INFO.CSV")
 DECLARE log_filename = vc WITH protect, noconstant("")
 DECLARE metadata_cnt = i4 WITH protect, noconstant(0)
 DECLARE par = vc WITH protect, noconstant(" ")
 DECLARE debug = vc WITH protect
 DECLARE from_clause = vc WITH protect, noconstant("")
 DECLARE stand_by_ind = vc WITH protect, noconstant("")
 DECLARE historic_start_dt_tm = dq8 WITH protect
 DECLARE historic_stop_dt_tm = dq8 WITH protect
 DECLARE historic_days_to_extract = i4 WITH protect
 DECLARE rtl2_defined = i2 WITH private, noconstant(0)
 SET debug = evaluate(textlen(trim(reflect(parameter(1,0)),3)),0,"N",parameter(1,0))
 RECORD output(
   1 qual[*]
     2 file_type = vc
     2 script = vc
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD metadata(
   1 qual[*]
     2 file_type = vc
     2 script = vc
     2 indicator = vc
     2 active_ind = vc
 )
 CALL printdebugstatement("Looking for file")
 FREE DEFINE rtl2
 IF (findfile(trim(input_file),4)=1)
  CALL printdebugstatement("Found file, defining record structure")
  DEFINE rtl2 trim(input_file)
  CALL printdebugstatement("record structure defined")
  SET rtl2_defined = 1
  CALL printdebugstatement("rtl12_defined=1")
 ENDIF
 IF (rtl2_defined=1)
  SELECT INTO "nl:"
   FROM rtl2t t
   HEAD REPORT
    metadata_cnt = 0, pipe_loc = 0, line_length = 0
   DETAIL
    pipe_loc = findstring(",",t.line,1,0), pipe_loc_2 = findstring(",",t.line,(pipe_loc+ 1),0),
    line_length = textlen(trim(t.line))
    IF (line_length > 0
     AND pipe_loc > 1
     AND pipe_loc_2 > 1)
     metadata_cnt = (metadata_cnt+ 1)
     IF (mod(metadata_cnt,10)=1)
      stat = alterlist(metadata->qual,(metadata_cnt+ 9))
     ENDIF
     metadata->qual[metadata_cnt].indicator = substring(1,(pipe_loc - 1),t.line), metadata->qual[
     metadata_cnt].file_type = substring((pipe_loc+ 1),((pipe_loc_2 - pipe_loc) - 1),t.line),
     metadata->qual[metadata_cnt].script = substring((pipe_loc_2+ 1),(line_length - pipe_loc_2),t
      .line),
     metadata->qual[metadata_cnt].active_ind = "N"
    ENDIF
   FOOT REPORT
    stat = alterlist(metadata->qual,metadata_cnt)
   WITH nocounter, maxcol = 2000
  ;end select
 ENDIF
 SELECT INTO "nl"
  FROM dm_info di
  WHERE di.info_domain="PI EDW SYSTEMS CONFIGURATION|STANDBY"
   AND di.info_name="STAND_BY_IND|FT"
  DETAIL
   stand_by_ind = substring(1,(findstring("|",di.info_char,1) - 1),di.info_char)
  WITH nocounter
 ;end select
 IF (stand_by_ind="N")
  SET trace = noskipreconnect
 ENDIF
 IF (((stand_by_ind="L") OR (stand_by_ind="")) )
  SELECT INTO "nl"
   FROM dba_db_links
   WHERE db_link="PI_MILL_DB_LINK.WORLD"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET from_clause = "dm_info@pi_mill_db_link"
   SET stand_by_ind = "L"
  ELSE
   CALL printdebugstatement(
    "Stand by is on and the PI_MILL_DB_LINK does not exist on the stand by node.")
   CALL printdebugstatement(" ")
   CALL printdebugstatement("Create the PI_MILL_DB_LINK and re-run the extract.")
   GO TO end_program
  ENDIF
 ELSE
  SET from_clause = "dm_info"
 ENDIF
 SELECT INTO "nl:"
  q_info_name = substring(1,(findstring("|",di.info_name,1) - 1),di.info_name), q_info_char =
  substring(1,(findstring("|",di.info_char,1) - 1),di.info_char)
  FROM (parser(from_clause) di)
  WHERE di.info_domain="PI EDW SYSTEMS CONFIGURATION|DIRECTORIES"
  DETAIL
   CASE (q_info_name)
    OF "ARCHIVE_DIR":
     log_filename = concat(trim(q_info_char),"/edw_create_run_list_log_",format(sysdate,"MMDDYY;;D"),
      "_",format(sysdate,"HHMMSS;;M"),
      ".log"),
     CALL printdebugstatement(concat("EDW UPDATE CONFIG LOG FILENAME: ",log_filename))
    OF "EXTRACT_DIR":
     output_file = concat(trim(q_info_char),"/edw_cont_run_list.txt"),
     CALL printdebugstatement(concat("OUTPUT FILENAME: ",output_file))
   ENDCASE
  WITH nocounter
 ;end select
 CALL printlogmsg("##### EDW_CREATE_RUN_LIST #####")
 CALL printlogmsg(concat("Start: ",format(sysdate,"DD-MMM-YYYY HH:MM:SS;;D")))
 SELECT INTO "NL:"
  FROM (parser(from_clause) di)
  WHERE di.info_domain="PI EDW OPERATIONS|*"
  DETAIL
   q_info_name = substring(1,(findstring("|",di.info_name,1) - 1),di.info_name), q_info_char =
   substring(1,(findstring("|",di.info_char,1) - 1),di.info_char), q_info_domain = substring((
    findstring("|",di.info_domain,1)+ 1),(size(di.info_domain,1) - findstring("|",di.info_domain,1)),
    di.info_domain)
   CASE (q_info_name)
    OF "HISTORIC_START_DT_TM":
     IF (cnvtdatetime(q_info_char) != null)
      historic_start_dt_tm = cnvtdatetime(q_info_char)
     ENDIF
    OF "HISTORIC_DAYS_TO_EXTRACT":
     historic_days_to_extract = cnvtint(q_info_char)
    OF "HISTORIC_STOP_DT_TM":
     IF (cnvtdatetime(q_info_char) != null)
      historic_stop_dt_tm = cnvtdatetime(q_info_char)
     ENDIF
   ENDCASE
  WITH check
 ;end select
 SELECT INTO "nl:"
  FROM (parser(from_clause) di),
   (dummyt d  WITH seq = size(metadata->qual,5))
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="PI EDW Subject Area|Historic*"
    AND operator(di.info_name,"LIKE",notrim(patstring(build("HIST_",metadata->qual[d.seq].indicator,
       "*"),1))))
  DETAIL
   metadata->qual[d.seq].active_ind = substring(1,(findstring("|",di.info_char,1) - 1),di.info_char)
  WITH nocounter
 ;end select
 IF (historic_days_to_extract > 0)
  SET current_dt_tm = historic_start_dt_tm
  CALL printlogmsg(concat("HISTORIC_START_DT_TM: ",format(historic_start_dt_tm,
     "MM/DD/YYYY HH:MM:SS;;Q")))
  CALL printlogmsg(concat("HISTORIC_STOP_DT_TM: ",format(historic_stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;Q"
     )))
  CALL printlogmsg(build("Days to extract: ",historic_days_to_extract))
  WHILE (current_dt_tm < historic_stop_dt_tm)
    CALL printlogmsg(concat("Creating records for ",format(current_dt_tm,"MM/DD/YYYY HH:MM:SS;;Q"),
      " to ",format(datetimeadd(current_dt_tm,abs(historic_days_to_extract)),"MM/DD/YYYY HH:MM:SS;;Q"
       )))
    FOR (i = 1 TO size(metadata->qual,5))
      IF ((metadata->qual[i].active_ind="Y"))
       SET output_cnt = (output_cnt+ 1)
       IF (mod(output_cnt,100)=1)
        SET stat = alterlist(output->qual,(output_cnt+ 99))
       ENDIF
       SET output->qual[output_cnt].file_type = metadata->qual[i].file_type
       SET output->qual[output_cnt].script = metadata->qual[i].script
       SET output->qual[output_cnt].start_dt_tm = current_dt_tm
       SET output->qual[output_cnt].end_dt_tm = minval(datetimeadd(current_dt_tm,
         historic_days_to_extract),historic_stop_dt_tm)
      ENDIF
    ENDFOR
    SET current_dt_tm = datetimeadd(current_dt_tm,historic_days_to_extract)
  ENDWHILE
 ELSEIF (historic_days_to_extract < 0)
  SET current_dt_tm = historic_stop_dt_tm
  CALL printlogmsg(concat("HISTORIC_START_DT_TM: ",format(historic_start_dt_tm,
     "MM/DD/YYYY HH:MM:SS;;Q")))
  CALL printlogmsg(concat("HISTORIC_STOP_DT_TM: ",format(historic_stop_dt_tm,"MM/DD/YYYY HH:MM:SS;;Q"
     )))
  CALL printlogmsg(build("Days to extract: ",historic_days_to_extract))
  WHILE (current_dt_tm > historic_start_dt_tm)
    CALL printlogmsg(concat("Creating records for ",format(current_dt_tm,"MM/DD/YYYY HH:MM:SS;;Q"),
      " to ",format(datetimeadd(current_dt_tm,(0 - abs(historic_days_to_extract))),
       "MM/DD/YYYY HH:MM:SS;;Q")))
    FOR (i = 1 TO size(metadata->qual,5))
      IF ((metadata->qual[i].active_ind="Y"))
       SET output_cnt = (output_cnt+ 1)
       IF (mod(output_cnt,100)=1)
        SET stat = alterlist(output->qual,(output_cnt+ 99))
       ENDIF
       SET output->qual[output_cnt].file_type = metadata->qual[i].file_type
       SET output->qual[output_cnt].script = metadata->qual[i].script
       SET output->qual[output_cnt].start_dt_tm = maxval(datetimeadd(current_dt_tm,
         historic_days_to_extract),historic_start_dt_tm)
       SET output->qual[output_cnt].end_dt_tm = current_dt_tm
      ENDIF
    ENDFOR
    SET current_dt_tm = datetimeadd(current_dt_tm,(0 - abs(historic_days_to_extract)))
  ENDWHILE
 ENDIF
 SELECT DISTINCT INTO value(output_file)
  output->qual[d.seq].file_type
  FROM (dummyt d  WITH seq = value(output_cnt))
  PLAN (d
   WHERE output_cnt > 0)
  DETAIL
   col 0,
   CALL print(trim(output->qual[d.seq].file_type)),
   CALL print(" "),
   CALL print(trim(output->qual[d.seq].script)),
   CALL print(" "),
   CALL print(format(output->qual[d.seq].start_dt_tm,"dd-mmm-yyyy_hh:mm:ss;;d")),
   CALL print(" "),
   CALL print(format(output->qual[d.seq].end_dt_tm,"dd-mmm-yyyy_hh:mm:ss;;d")), row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 SUBROUTINE printdebugstatement(debug_message)
   IF (debug="Y")
    CALL echo(debug_message)
   ENDIF
 END ;Subroutine
 SUBROUTINE printlogmsg(message)
   SELECT INTO value(log_filename)
    FROM (dummyt d  WITH seq = value(1))
    DETAIL
     col 0,
     CALL print(message), row + 1
    WITH noheading, nocounter, format = lfstream,
     maxcol = 1999, maxrow = 1, append
   ;end select
 END ;Subroutine
#end_program
 SET script_version = "001 02/27/12 RP019504"
END GO
