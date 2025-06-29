CREATE PROGRAM ccl_rpt_audit_log
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Enter program name (*):" = "*",
  "Begin Date, mmddyy (curdate):" = curdate,
  "End Date, mmddyy (curdate):" = curdate,
  "Status *(All), (A)ctive, (S)uccess, (F)ailed:" = "*",
  "Source Application:" = "*",
  "Request Source:" = 3050002,
  "Select User (*):" = "*"
  WITH outdev, prog_name, begin_date,
  end_date, prog_status, appnumber,
  req_source, username
 DECLARE ccl_check_date_sub(date_param) = c6
 SUBROUTINE ccl_check_date_sub(param_date_val)
   SET temp = param_date_val
   DECLARE return_val = c8
   DECLARE day_val = i2
   DECLARE year_str = c4
   DECLARE datetype_flag = i2
   SET datetype_curdate = 1
   SET datetype_mmddyy = 0
   SET datetype_yyyymmdd = 2
   SET datetype_unknown = 3
   SET datetype_flag = datetype_unknown
   IF (cnvtint(temp) BETWEEN (curdate - 1) AND (curdate+ 1))
    SET datetype_flag = datetype_curdate
   ELSE
    IF (size(trim(cnvtstring(temp)))=8)
     SET datetype_flag = datetype_yyyymmdd
    ELSEIF (size(trim(cnvtstring(temp)))=6)
     SET datetype_flag = datetype_mmddyy
    ELSEIF (size(trim(cnvtstring(temp)))=5)
     SET datetype_flag = datetype_curdate
     SET day_val = cnvtint(substring(2,2,cnvtstring(temp)))
     SET year_val = cnvtint(substring(4,2,cnvtstring(temp)))
     IF (year_val > 50)
      SET year_str = build("19",year_val)
     ELSE
      SET year_str = build("20",format(year_val,"##;p0"))
     ENDIF
     IF (((cnvtint(substring(1,1,cnvtstring(temp))) IN (1, 3, 5, 7, 8)
      AND day_val <= 31) OR (cnvtint(substring(1,1,cnvtstring(temp))) IN (4, 6, 9)
      AND day_val <= 30)) )
      SET datetype_flag = datetype_mmddyy
     ELSEIF (cnvtint(substring(1,1,cnvtstring(temp)))=2)
      IF (((mod(cnvtint(year_str),4)=0
       AND ((mod(cnvtint(year_str),400)=0) OR (mod(cnvtint(year_str),100) != 0))
       AND day_val <= 29) OR (day_val <= 28)) )
       SET datetype_flag = datetype_mmddyy
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (datetype_flag=datetype_curdate)
    SET return_val = format(temp,"yyyymmdd;;d")
   ELSEIF (datetype_flag=datetype_mmddyy)
    SET return_val = format(cnvtdate(temp),"yyyymmdd;;d")
   ELSEIF (datetype_flag=datetype_yyyymmdd)
    SET return_val = format(temp,"########;p0")
   ELSE
    CALL echo("Invalid value for startdate - defaulting to curdate",1,0)
    SET return_val = format(curdate,"yyyymmdd;;d")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE qualparser = vc
 DECLARE qualprogram = vc
 DECLARE startdate = c8
 DECLARE enddate = c8
 DECLARE object_params = vc
 DECLARE object_params1 = vc
 DECLARE blongparams = i2
 DECLARE ccl_check_date_sub(date_param) = c6
 DECLARE user_flag = i2
 DECLARE user_count = i4
 DECLARE app_num_flag = i2
 DECLARE app_num_count = i4
 DECLARE app_num_value = i4
 DECLARE req_source_string = vc
 DECLARE req_num_parser = vc
 DECLARE app_status = vc
 SET app_status = ""
 RECORD userids(
   1 ids[*]
     2 person_id = f8
 )
 RECORD appnums(
   1 ids[*]
     2 app_num = i4
 )
 SET qualprogram = cnvtupper( $2)
 IF (findstring("CCL_RPT",qualprogram) > 0)
  SET qualparser = "C.OBJECT_NAME > ^^"
 ELSE
  SET qualparser = "C.OBJECT_NAME != ^CCL_RPT_*^ "
 ENDIF
 IF (textlen( $PROG_STATUS)=1)
  SET app_status = concat( $PROG_STATUS,"*")
 ENDIF
 IF (textlen( $USERNAME) != 1)
  SET user_flag = 1
  SET user_count = 0
  SELECT DISTINCT INTO "NL:"
   p.person_id
   FROM prsnl p,
    ccl_report_audit c
   PLAN (p
    WHERE p.username=patstring( $USERNAME))
    JOIN (c
    WHERE p.person_id=c.updt_id)
   ORDER BY p.person_id
   DETAIL
    user_count += 1
    IF (mod(user_count,10)=1)
     stat = alterlist(userids->ids,(user_count+ 9))
    ENDIF
    userids->ids[user_count].person_id = p.person_id
   FOOT REPORT
    stat = alterlist(userids->ids,user_count)
   WITH nocounter
  ;end select
  SET user_count = 0
 ELSE
  SET user_flag = 0
 ENDIF
 IF (textlen( $APPNUMBER)=1)
  IF (( $APPNUMBER="\*"))
   SET app_num_flag = 0
   SET app_num_value = - (1)
  ELSE
   SET app_num_flag = 1
   SET app_num_value = - (1)
  ENDIF
 ELSE
  SET app_num_flag = 1
  SET app_num_value = cnvtint(trim( $APPNUMBER,3))
 ENDIF
 IF (( $REQ_SOURCE=3050003))
  SET req_num_parser = "(c.request_nbr = 3050002 and c.object_type = 'QUERY')"
 ELSEIF (( $REQ_SOURCE=0))
  SET req_num_parser = "(1 = 1)"
 ELSE
  SET req_num_parser = concat("(c.request_nbr = ",cnvtstring( $REQ_SOURCE),
   " and c.object_type != 'QUERY')")
 ENDIF
 SET startdate = ccl_check_date_sub( $BEGIN_DATE)
 SET enddate = ccl_check_date_sub( $END_DATE)
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  c.object_name, c.object_type, c.status,
  c.object_params, elapsed_seconds = datetimediff(c.end_dt_tm,c.begin_dt_tm,5), c.begin_dt_tm,
  c.end_dt_tm"@MEDIUMDATETIME", user = substring(1,30,p.name_full_formatted), c.application_nbr,
  description = substring(1,30,a.description), c.records_cnt"#####", c.output_device,
  c.tempfile, c.active_ind, c.updt_dt_tm"@MEDIUMDATETIME"
  FROM ccl_report_audit c,
   person p,
   application a
  PLAN (c
   WHERE c.object_name=patstring(cnvtupper( $PROG_NAME))
    AND parser(qualparser)
    AND c.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000001) AND cnvtdatetime(
    cnvtdate2(enddate,"YYYYMMDD"),235959)
    AND ((c.status=cnvtupper( $PROG_STATUS)) OR (c.status=patstring(cnvtupper(app_status))))
    AND ((expand(user_count,1,size(userids->ids,5),c.updt_id,userids->ids[user_count].person_id)) OR
   (user_flag=0))
    AND ((app_num_flag=0) OR (c.application_nbr=app_num_value))
    AND parser(req_num_parser))
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
  ORDER BY c.object_name, a.description, c.updt_dt_tm DESC
  HEAD REPORT
   row 1, col 5, "Report name(s):"
   IF (textlen(qualprogram)=1)
    report_name = "ALL REPORTS"
   ELSE
    report_name = cnvtupper( $PROG_NAME)
   ENDIF
   row 1, col 21, report_name,
   row 1, col 73, "Discern Explorer Report Audit"
   IF (( $REQ_SOURCE > 0))
    row + 1, req_source_string = cnvtstring( $REQ_SOURCE), col 5,
    "Request Number:", col 21, req_source_string
   ENDIF
   row + 1, displaystartdate = format(cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000000),
    "@MEDIUMDATETIME"), displayenddate = format(cnvtdatetime(cnvtdate2(enddate,"YYYYMMDD"),235959),
    "@MEDIUMDATETIME"),
   col 5, "Start date: ", col 20,
   displaystartdate, row + 1, col 5,
   "End date: ", col 20, displayenddate,
   row + 2
  HEAD PAGE
   col 8, "Output type:", col 24,
   "Status:", col 36, "Elapsed time:",
   col 57, "Date/time:", col 76,
   "#Records:", col 88, "User:",
   col 120, "Params:", col 155,
   "Page: ", pagenum = format(curpage,"####"), col 160,
   pagenum, row + 2
  HEAD c.object_name
   IF (((row+ 2) >= maxrow))
    BREAK
   ENDIF
   col 5, "Program:", col 24,
   c.object_name, row + 1
  HEAD a.description
   col 5, "Application Name:", col 24,
   description, row + 1
  DETAIL
   object_params = trim(substring(1,150,c.object_params))
   IF (textlen(trim(object_params)) > 50)
    object_params1 = substring(1,130,object_params), blongparams = 1
   ELSE
    object_params1 = substring(1,50,c.object_params), blongparams = 0
   ENDIF
   col 8, c.object_type, col 24,
   c.status, col 36
   IF (c.status="ACTIVE")
    elapsed_time = "<In Process>"
   ELSEIF (elapsed_seconds=0)
    elapsed_time = "< 1 Second"
   ELSEIF (elapsed_seconds < 60)
    elapsed_time = concat(format(build(elapsed_seconds),"#####;RP0")," Seconds")
   ELSE
    elapsed_time = concat(format(build(datetimediff(c.end_dt_tm,c.begin_dt_tm,4)),"#####;RP0"),
     " Minutes")
   ENDIF
   elapsed_time, col 57, c.updt_dt_tm
   IF (c.object_type="QUERY")
    col 79, c.records_cnt
   ELSE
    col 81, "N/A"
   ENDIF
   col 88, user
   IF (blongparams)
    row + 1, col 13, "Params:  ",
    object_params1
   ELSE
    col 120, object_params1
   ENDIF
   row + 1
  FOOT  c.object_name
   row + 1
  WITH maxcol = 171, maxrow = 48, time = value(maxsecs),
   landscape, compress, nullreport,
   noheading, format = variable
 ;end select
END GO
