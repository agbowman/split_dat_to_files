CREATE PROGRAM bhs_rrd_audit
 PROMPT
  "Enter <A>ll,<C>ancel,<E>rrored,<T>rans,<Q>ueued,<U>ntrans:  " = "A",
  "Enter Mine/Printer/File: " = mine
 SET pline = fillstring(80," ")
 SET pline = 'X.CDF_MEANING in ( "UNXMITTED","ERROR")'
 SET error_ind = 0
 SET untransmit_ind = 0
 SELECT INTO "rrd_audit"
  t = datetimediff(cnvtdatetime(sysdate),rep.original_dt_tm,3)
  FROM station st,
   code_value x,
   outputctx req,
   report_queue rep,
   session_xref sx,
   (dummyt d  WITH seq = 1)
  PLAN (rep
   WHERE (rep.original_dt_tm > (sysdate - 1)))
   JOIN (req
   WHERE rep.output_handle_id=req.handle_id)
   JOIN (st
   WHERE req.output_dest_cd=st.output_dest_cd)
   JOIN (x
   WHERE x.code_set=2209
    AND rep.transmission_status_cd=x.code_value
    AND parser(pline))
   JOIN (d)
   JOIN (sx
   WHERE sx.output_handle_id=rep.output_handle_id)
  ORDER BY rep.transmission_status_cd, cnvtdatetime(rep.transmit_dt_tm), rep.priority_value,
   st.description, rep.output_handle_id, sx.session_num DESC
  HEAD REPORT
   sess = "     ", prev_stat = 0, prev_handle = - (1),
   col 0, " Current Date/Time:", row + 1,
   col 0, curdate, col 9,
   curtime3, row + 1, col 30
   IF (( $1="A"))
    "Reports for all statuses"
   ELSEIF (( $1="T"))
    "Transmitted Reports Only"
   ELSEIF (( $1="U"))
    "Untransmitted Reports Only"
   ELSEIF (( $1="E"))
    "Errored Reports Only"
   ELSEIF (( $1="Q"))
    "Queued Reports Only"
   ELSEIF (( $1="C"))
    "Canceled Reports Only"
   ENDIF
   row + 1, col 0, "* Indicates Disabled Station",
   row + 2, col 108, "Retries",
   col 199, "Last", row + 1,
   col 0, "Transmit Date/Time", col 20,
   "Station", col 44, "Status",
   col 54, "Pri", col 73,
   "Report Title", col 99, "Pgs",
   col 105, "Busy", col 110,
   "NoC", col 114, "Dis",
   col 119, "Handle", col 129,
   "Last Update", col 150, "Cutoff Date/Time",
   col 170, "Phone Number", col 198,
   "Session", col 210, "Converted File Name",
   col 270, "Original Date/Time", row + 1,
   col 0, "-----------------------------------------", col 41,
   "----------------------------------------", col 81, "----------------------------------------",
   col 121, "----------------------------------------", col 161,
   "----------------------------------------", col 201, "----------------------------------------",
   col 241, "-------------------------------------------------"
  HEAD rep.output_handle_id
   IF (((cnvtupper(x.display)="ERROR") OR (t > 1)) )
    IF (cnvtupper(x.display)="ERROR")
     error_ind = 1
    ELSE
     untransmit_ind = 1
    ENDIF
    IF (rep.transmission_status_cd != prev_stat)
     row + 1, prev_stat = rep.transmission_status_cd
    ENDIF
    IF (rep.converted_file_name="UNCONVERTED")
     conv_yn = "U"
    ELSEIF (substring(1,11,rep.converted_file_name)="INPROCESS=>")
     conv_yn = "I"
    ELSE
     conv_yn = "C"
    ENDIF
    disable = " "
    IF (st.disabled_ind=1)
     disable = "*"
    ENDIF
    IF (((req.adhoc_country_access > " ") OR (((req.adhoc_area_code > " ") OR (((req.adhoc_exchange
     > " ") OR (req.adhoc_phone_suffix > " ")) )) )) )
     phone = concat(trim(req.adhoc_country_access),trim(req.adhoc_area_code),trim(req.adhoc_exchange),
      trim(req.adhoc_phone_suffix))
    ELSE
     phone = "ON FILE"
    ENDIF
    col 0, rep.original_dt_tm"MM/DD/YY HH:MM:SS", col 19,
    disable, col 20, st.description,
    col 44, x.display, col 53,
    rep.priority_value"#####", col 63,
    CALL print(substring(1,35,req.report_name)),
    col 99, req.number_of_pages"###", col 103,
    conv_yn, col 105, rep.num_of_busy"##",
    col 109, rep.num_of_noconnect"##", col 113,
    rep.num_of_disconnect"##", col 117, rep.output_handle_id"##########",
    col 129, rep.updt_dt_tm"MM/DD/YY HH:MM:SS", col 150,
    t, col 170, phone
    IF (sx.session_num=0)
     sess = "N/A"
    ELSE
     sess = cnvtstring(sx.session_num)
    ENDIF
    col 200, sess, col 210,
    CALL print(trim(rep.converted_file_name)), col 270, rep.original_dt_tm"MM/DD/YY HH:MM:SS",
    row + 1
   ENDIF
  DETAIL
   col 0
  WITH nocounter, check, maxcol = 300,
   outerjoin = d, separator = " ", format
 ;end select
 IF (((error_ind=1) OR (untransmit_ind=1)) )
  EXECUTE bhs_ma_email_file
  CALL emailfile("rrd_audit.dat","rrd_audit.txt","Infosys.OSG@bhs.org ciscore@bhs.org","RRD Audit",1)
 ENDIF
#exit_prg
END GO
