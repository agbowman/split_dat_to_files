CREATE PROGRAM ccl_rpt_audit_summary:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Enter program name (*):" = "*",
  "Begin date, mmddyy (curdate):" = curdate,
  "End date, mmddyy (curdate):" = curdate,
  "Source Application (*):" = "*",
  "Request Source:" = 3050002,
  "Select User (*):" = "*"
  WITH outdev, prog_name, begin_date,
  end_date, appnumber, req_source,
  username
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
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
 FREE RECORD detail_rec
 RECORD detail_rec(
   1 list[*]
     2 status = c12
     2 updt_dt_tm = dq8
     2 name_full_formatted = vc
 )
 DECLARE qualparser = vc
 DECLARE qualprogram = vc
 DECLARE startdate = c8
 DECLARE enddate = c8
 DECLARE textdate = vc
 DECLARE elapsed_time = c50
 DECLARE i18nhandle = i4
 DECLARE i18n_title = vc
 DECLARE i18n_startdate = vc
 DECLARE i18n_enddate = vc
 DECLARE i18n_page = vc
 DECLARE i18n_object = vc
 DECLARE i18n_totalexec = vc
 DECLARE i18n_subsec = vc
 DECLARE i18n_seconds = vc
 DECLARE i18n_minutes = vc
 DECLARE i18n_avgelapsed = vc
 DECLARE i18n_lastexec = vc
 DECLARE i18n_lastmod = vc
 DECLARE i18n_failed_active = vc
 DECLARE i18n_allsuccess = vc
 DECLARE i18n_user = vc
 DECLARE i18n_application_name = vc
 DECLARE i18n_all_applications = vc
 DECLARE user_flag = i2
 DECLARE user_value = vc
 DECLARE ccl_check_date_sub(date_param) = c6
 DECLARE app_num_flag = i2
 DECLARE app_num_count = i4
 DECLARE app_num_value = i4
 DECLARE req_num_parser = vc
 DECLARE count = i4
 SET count = 0
 RECORD userids(
   1 ids[*]
     2 person_id = f8
 )
 SET qualprogram = cnvtupper( $2)
 IF (findstring("CCL_RPT",qualprogram) > 0)
  SET qualparser = "C.OBJECT_NAME > ^^"
 ELSE
  SET qualparser = "C.OBJECT_NAME != ^CCL_RPT_*^ "
 ENDIF
 SET startdate = ccl_check_date_sub( $3)
 SET enddate = ccl_check_date_sub( $4)
 SET i18nhandle = 0
 IF (textlen( $USERNAME) != 1)
  SET user_flag = 1
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
 SET startdate = ccl_check_date_sub( $BEGIN_DATE)
 SET enddate = ccl_check_date_sub( $END_DATE)
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET i18n_title = uar_i18ngetmessage(i18nhandle,"KeyGet1","DISCERN EXPLORER REPORT SUMMARY")
 SET i18n_startdate = uar_i18ngetmessage(i18nhandle,"KeyGet2","Audit start date:")
 SET i18n_enddate = uar_i18ngetmessage(i18nhandle,"KeyGet3","Audit end date:")
 SET i18n_page = uar_i18ngetmessage(i18nhandle,"KeyGet4","PAGE:")
 SET i18n_object = uar_i18ngetmessage(i18nhandle,"KeyGet5","Report/Query Name:")
 SET i18n_totalexec = uar_i18ngetmessage(i18nhandle,"KeyGet6","Total executions:")
 SET i18n_subsec = uar_i18ngetmessage(i18nhandle,"KeyGet7","< 1 Second")
 SET i18n_seconds = uar_i18ngetmessage(i18nhandle,"KeyGet8","Second(s)")
 SET i18n_minutes = uar_i18ngetmessage(i18nhandle,"KeyGet9","Minute(s)")
 SET i18n_avgelapsed = uar_i18ngetmessage(i18nhandle,"KeyGet10","Average elapsed:")
 SET i18n_lastexec = uar_i18ngetmessage(i18nhandle,"KeyGet11","Last execute date/time:")
 SET i18n_lastmod = uar_i18ngetmessage(i18nhandle,"KeyGet12","Last modified:")
 SET i18n_failed_active = uar_i18ngetmessage(i18nhandle,"KeyGet13","Failed/active instances:")
 SET i18n_allsuccess = uar_i18ngetmessage(i18nhandle,"KeyGet14","ALL SUCCESSFUL")
 SET i18n_user = uar_i18ngetmessage(i18nhandle,"KeyGet15","User:")
 SET i18n_application_name = uar_i18ngetmessage(i18nhandle,"KeyGet16","Application Name:")
 SET i18n_all_applications = uar_i18ngetmessage(i18nhandle,"KeyGet17","All Applications")
 SELECT INTO  $1
  c.object_name, c.begin_time, c.end_time,
  c.updt_dt_tm, elapsedseconds = datetimediff(c.end_dt_tm,c.begin_dt_tm,5), c.status,
  p.name_full_formatted, date_stamp = format(cnvtdatetime(dp.datestamp,dp.timestamp),
   "@MEDIUMDATETIME")
  FROM ccl_report_audit c,
   person p,
   dprotect dp,
   application a,
   dummyt d1
  PLAN (c
   WHERE c.object_name=patstring(cnvtupper( $2))
    AND parser(qualparser)
    AND c.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000000) AND cnvtdatetime(
    cnvtdate2(enddate,"YYYYMMDD"),235959)
    AND ((expand(count,1,size(userids->ids,5),c.updt_id,userids->ids[count].person_id)) OR (user_flag
   =0))
    AND ((app_num_flag=0) OR (c.application_nbr=app_num_value))
    AND parser(req_num_parser))
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
   JOIN (d1)
   JOIN (dp
   WHERE "P"=dp.object
    AND c.object_name=dp.object_name)
  ORDER BY a.description, c.object_name, c.updt_dt_tm
  HEAD REPORT
   row 1, col 49, i18n_title,
   displaystartdate = format(cnvtdatetime(cnvtdate2(startdate,"YYYYMMDD"),000000),"@MEDIUMDATETIME"),
   displayenddate = format(cnvtdatetime(cnvtdate2(enddate,"YYYYMMDD"),235959),"@MEDIUMDATETIME"), row
    2,
   col 2, i18n_startdate, row 2,
   col 20, displaystartdate, row 3,
   col 2, i18n_enddate, row 3,
   col 20, displayenddate
   IF (( $REQ_SOURCE > 0))
    row + 1, req_source_string = cnvtstring( $REQ_SOURCE), col 2,
    "Request Number:", col 18, req_source_string
   ENDIF
   IF (( $USERNAME != "\*"))
    row + 1, user_value = trim( $USERNAME,3), col 2,
    "User Name:", col 14, user_value
   ENDIF
   totalelapsed = 0, totalcount = 0, failactiveind = 0,
   lastexecutename = "", row + 1
  HEAD PAGE
   row + 1, col 112, i18n_page,
   col 120, curpage"####"
  HEAD c.object_name
   IF (((row+ 6) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 2, i18n_application_name,
   col 20, a.description, row + 1,
   col 2, i18n_object, objectname = substring(1,30,c.object_name),
   col 23, objectname, row + 1,
   stat = alterlist(detail_rec->list,10), cnt = 0
  DETAIL
   IF (cnvtupper(c.status) != "SUCCESS")
    cnt += 1
    IF (mod(cnt,10)=1
     AND cnt > 1)
     stat = alterlist(detail_rec->list,(cnt+ 9))
    ENDIF
    detail_rec->list[cnt].status = c.status, detail_rec->list[cnt].updt_dt_tm = c.updt_dt_tm,
    detail_rec->list[cnt].name_full_formatted = p.name_full_formatted,
    failactiveind = 1
   ENDIF
  FOOT  c.object_name
   totalcount = count(c.object_name), col 20, i18n_totalexec,
   col 40, totalcount"#####", row + 1,
   totalelapsed = sum(elapsedseconds), averagesecs = (totalelapsed/ totalcount)
   IF (averagesecs=1)
    elapsed_time = i18n_subsec
   ELSEIF (averagesecs >= 60)
    totalminelapsed = (averagesecs/ 60), totalsecelapsed = mod(averagesecs,60), elapsed_time = concat
    (build(totalminelapsed)," ",i18n_minutes,"   ",build(totalsecelapsed),
     " ",i18n_seconds)
   ELSE
    elapsed_time = concat(build(averagesecs)," ",i18n_seconds)
   ENDIF
   col 20, i18n_avgelapsed, col 40,
   elapsed_time, row + 1, lastexecutedate = format(c.updt_dt_tm,"@MEDIUMDATETIME"),
   col 20, i18n_lastexec, col 45,
   lastexecutedate, col 70, i18n_user,
   "  ", p.name_full_formatted, row + 1,
   col 20, i18n_lastmod, lastmodified = date_stamp,
   col 40, lastmodified, row + 1,
   col 20, i18n_failed_active
   IF (failactiveind=0)
    col 50, i18n_allsuccess
   ELSE
    FOR (count = 1 TO cnt)
      row + 1, col 30, detail_rec->list[count].status,
      nonsuccessdate = format(detail_rec->list[count].updt_dt_tm,"@MEDIUMDATETIME"), col 40,
      nonsuccessdate,
      col 70, i18n_user, "  ",
      detail_rec->list[count].name_full_formatted
    ENDFOR
   ENDIF
   failactiveind = 0, row + 1
  WITH maxcol = 500, maxrow = 65, nullreport,
   noheading, format = variable, outerjoin = d1
 ;end select
END GO
