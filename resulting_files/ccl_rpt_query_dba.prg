CREATE PROGRAM ccl_rpt_query:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Enter program name (*):" = "*",
  "Begin Date, mmddyy (curdate - 1):" = curdate,
  "End Date, mmddyy (curdate):" = curdate,
  "Status *(All), (A)ctive, (S)uccess, (F)ailed:" = "*",
  "Source Application (*):" = "*",
  "Request Source:" = 3050002,
  "Select User (*):" = "*",
  "Sort by (P)rogram, (E)lapsed Time, (A)pplication:" = "P"
  WITH outdev, progname, begindate,
  enddate, prog_status, appnumber,
  req_source, username, sortby
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
 DECLARE ccl_check_date_sub(date_param) = c6
 DECLARE app_num_parser = vc
 DECLARE user_name_parser = vc
 DECLARE req_num_parser = vc
 DECLARE app_num_flag = i4
 DECLARE app_num_value = i4
 DECLARE _sortby = vc
 DECLARE user_flag = i2
 DECLARE app_status = vc
 DECLARE count = i4
 SET count = 0
 SET app_status = ""
 RECORD userids(
   1 ids[*]
     2 person_id = f8
 )
 SET qualprogram = cnvtupper( $PROGNAME)
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
  CALL echo(concat("$Username = ", $USERNAME))
  SELECT DISTINCT INTO "NL:"
   p.person_id, p.username
   FROM prsnl p,
    ccl_report_audit c
   PLAN (p
    WHERE p.username=patstring( $USERNAME))
    JOIN (c
    WHERE p.person_id=c.updt_id)
   ORDER BY p.username
   DETAIL
    count += 1
    IF (mod(count,10)=1)
     stat = alterlist(userids->ids,(count+ 9))
    ENDIF
    userids->ids[count].person_id = p.person_id
   FOOT REPORT
    stat = alterlist(userids->ids,count)
   WITH nocounter
  ;end select
  SET count = 0
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
 SET startdate = ccl_check_date_sub( $3)
 SET enddate = ccl_check_date_sub( $4)
 SET _sortby = trim( $SORTBY)
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT
  IF (_sortby="P")
   ORDER BY c.object_name, c.updt_dt_tm DESC
  ELSEIF (_sortby="E")
   ORDER BY elapsed_seconds, c.updt_dt_tm DESC
  ELSEIF (_sortby="A")
   ORDER BY a.description, c.updt_dt_tm DESC
  ELSE
   ORDER BY c.updt_dt_tm DESC
  ENDIF
  INTO  $1
  c.object_name, c.object_type, c.status,
  c.object_params, elapsed_seconds = datetimediff(c.end_dt_tm,c.begin_dt_tm,5), c.begin_dt_tm
  "@MEDIUMDATETIME",
  c.end_dt_tm"@MEDIUMDATETIME", user = substring(1,30,p.name_full_formatted), c.updt_id,
  c.application_nbr, application_name = a.description, request_number = c.request_nbr,
  c.records_cnt, c.output_device, c.tempfile,
  c.active_ind, c.updt_dt_tm"@MEDIUMDATETIME", c.long_text_id
  FROM ccl_report_audit c,
   person p,
   application a
  PLAN (c
   WHERE c.object_name=patstring(cnvtupper( $2))
    AND parser(qualparser)
    AND c.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000001) AND cnvtdatetime(
    cnvtdate2(enddate,"YYYYMMDD"),235959)
    AND (((c.status= $PROG_STATUS)) OR (c.status=patstring(app_status)))
    AND ((expand(count,1,size(userids->ids,5),c.updt_id,userids->ids[count].person_id)) OR (user_flag
   =0))
    AND ((app_num_flag=0) OR (c.application_nbr=app_num_value))
    AND parser(req_num_parser))
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
  WITH time = value(maxsecs), format, skipreport = 1,
   separator = " "
 ;end select
END GO
