CREATE PROGRAM bhs_rad_rrd_audit_report
 PROMPT
  "Enter <A>ll,<C>ancel,<E>rrored,<T>rans,<Q>ueued,<U>ntrans:  " = "E",
  "Enter Mine/Printer/File: " = mine
 SET pline = fillstring(95," ")
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mn_start_pos = i2 WITH protect, noconstant(0)
 DECLARE mn_end_pos = i2 WITH protect, noconstant(0)
 DECLARE mn_len_val = i2 WITH protect, noconstant(0)
 DECLARE ms_pat_name = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_acc_num = vc WITH protect, noconstant(" ")
 FREE RECORD pat_data
 RECORD encntr_data(
   1 encntrs[*]
     2 mf_handle_id = f8
     2 ms_pat_fin = vc
     2 ms_error_val = vc
 ) WITH protect
 IF (( $1="A"))
  SET pline = 'X.CDF_MEANING = "*"'
 ELSEIF (( $1="T"))
  SET pline = 'X.CDF_MEANING = "XMITTED"'
 ELSEIF (( $1="U"))
  SET pline = 'X.CDF_MEANING = "UNXMITTED"'
 ELSEIF (( $1="E"))
  SET pline = 'X.CDF_MEANING = "ERROR"'
 ELSEIF (( $1="Q"))
  SET pline = 'X.CDF_MEANING = "QUEUED"'
 ELSEIF (( $1="C"))
  SET pline = 'X.CDF_MEANING = "CANCELLED"'
 ELSE
  GO TO exit_prg
 ENDIF
 SELECT DISTINCT INTO  $2
  st.description, x.display, req.*,
  rep.*, sx.session_num
  FROM station st,
   code_value x,
   cr_report_request cr,
   encounter e,
   person p,
   outputctx req,
   report_queue rep,
   session_xref sx,
   prsnl ep,
   (dummyt d  WITH seq = 1)
  PLAN (rep
   WHERE (rep.original_dt_tm > (sysdate - 1)))
   JOIN (req
   WHERE rep.output_handle_id=req.handle_id
    AND req.report_name > " ")
   JOIN (st
   WHERE req.output_dest_cd=st.output_dest_cd)
   JOIN (x
   WHERE x.code_set=2209
    AND rep.transmission_status_cd=x.code_value
    AND x.cdf_meaning="ERROR")
   JOIN (d)
   JOIN (cr
   WHERE cr.output_dest_cd=st.output_dest_cd)
   JOIN (ep
   WHERE ep.person_id=cr.provider_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=cr.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
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
    "Errored Radiology Faxes"
   ELSEIF (( $1="Q"))
    "Queued Reports Only"
   ELSEIF (( $1="C"))
    "Canceled Reports Only"
   ENDIF
   row + 1, col 0, "* Indicates Disabled Station",
   row + 2, col 108, col 199,
   "Last", row + 1, col 0,
   "Transmit DT/TM", col 19, "Station",
   col 38, "Provider", col 60,
   "Report Title", col 88, "Phone Number",
   col 103, "Patient Name", col 128,
   "Session", col 140, "Converted File Name",
   col 200, "Original Date/Time", col 250,
   "Accession Number", row + 1, col 0,
   "-----------------------------------------", col 41, "----------------------------------------",
   col 81, "----------------------------------------", col 121,
   "----------------------------------------", col 161, "----------------------------------------",
   col 201, "----------------------------------------", col 241,
   "-------------------------------------------------"
  HEAD rep.output_handle_id
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
   IF (((req.adhoc_country_access > " ") OR (((req.adhoc_area_code > " ") OR (((req.adhoc_exchange >
   " ") OR (req.adhoc_phone_suffix > " ")) )) )) )
    phone = concat(trim(req.adhoc_country_access),trim(req.adhoc_area_code),trim(req.adhoc_exchange),
     trim(req.adhoc_phone_suffix))
   ELSE
    phone = "ON FILE"
   ENDIF
   col 0, rep.transmit_dt_tm"MM/DD/YY HH:MM:SS", col 18,
   disable, col 20, st.description,
   col 37, ep.name_full_formatted, col 55,
   CALL print(substring(1,30,req.report_name)), ms_pat_name = p.name_full_formatted, ms_acc_num =
   cnvtacc(cr.accession_nbr),
   col 87, phone, col 100,
   ms_pat_name
   IF (sx.session_num=0)
    sess = "N/A"
   ELSE
    sess = cnvtstring(sx.session_num)
   ENDIF
   col 130, sess, col 140,
   CALL print(trim(rep.converted_file_name)), col 200, rep.original_dt_tm"MM/DD/YY HH:MM:SS",
   col 250, ms_acc_num, row + 1
  DETAIL
   col 0
  WITH maxcol = 700, landscape, filesort,
   noheading, format = variable, outerjoin = d
 ;end select
#exit_prg
END GO
