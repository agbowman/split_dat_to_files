CREATE PROGRAM djh_dcp_chrt_acc_by_prv2cp:dba
 PROMPT
  "Output to File/Printer/MINE" = "cisard@bhs.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 SET lncnt = 0
 DECLARE page_num = i2 WITH noconstant(1)
 DECLARE chart_cd = f8 WITH constant(uar_get_code_by("MEANING",104,"CHARTACCESS"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE output_string = vc
 DECLARE xnodename = vc
 SET xnodename = curnode
 IF (curtime < 1200)
  SET target_date = (curdate - 1)
 ELSE
  SET target_date = curdate
 ENDIF
 SELECT INTO value(output_dest)
  p.name_full_formatted, pl.name_full_formatted, ppa.ppa_type_cd,
  pa.alias, ppa.ppa_first_dt_tm
  FROM person_prsnl_activity ppa,
   person p,
   prsnl pl,
   person_alias pa
  PLAN (ppa
   WHERE ppa.ppa_type_cd=chart_cd
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime(target_date,0000) AND cnvtdatetime(target_date,2400)
   )
   JOIN (p
   WHERE p.person_id=ppa.person_id)
   JOIN (pl
   WHERE pl.person_id=ppa.prsnl_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY pl.name_full_formatted, p.name_full_formatted, ppa.ppa_first_dt_tm
  HEAD REPORT
   col 1, ",", "Node",
   ",", "Staff-Name", ",",
   "Pat-Name", ",", "M-R-N",
   ",", "Date", ",",
   "Time", ",", row + 1
  HEAD pl.name_full_formatted
   person_name = substring(1,40,p.name_full_formatted)
  DETAIL
   person_name = substring(1,40,p.name_full_formatted), dr_name = substring(1,40,pl
    .name_full_formatted), med_rec_num = substring(1,15,pa.alias),
   ppa_date = format(ppa.ppa_first_dt_tm,"YYYY-MM-DD ;;D"), ppa_time = format(ppa.ppa_first_dt_tm,
    "HH:MM:SS ;;M"), output_string = build(',"',xnodename,'","',dr_name,'","',
    person_name,'","',med_rec_num,'","',ppa_date,
    '","',ppa_time,'",'),
   col 1, output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxcol = 1000,
   maxrec = 10
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"_OCFReport_",xnodename,".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(xnodename,"-",curprog,"-V1.0 - OCFReport")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
