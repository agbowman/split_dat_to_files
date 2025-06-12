CREATE PROGRAM ccl_get_audit_log:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD audit_request(
   1 program_name = vc
   1 source_app = vc
   1 username = f8
   1 request_source = f8
   1 status = vc
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 SET json = request->blob_in
 SET jrec_ret = cnvtjsontorec(json,0,0,1)
 RECORD audit_reply(
   1 qual_cnt = f8
   1 program_name = vc
   1 qual[*]
     2 object_name = vc
     2 object_type = vc
     2 status = vc
     2 object_params = vc
     2 elapsed_seconds = f8
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 user = vc
     2 application_nbr = i4
     2 application_desc = vc
     2 records_cnt = i4
     2 output_device = vc
     2 tempfile = vc
     2 active_ind = i2
     2 updt_dt_tm = dq8
     2 request_nbr = i4
     2 user_num = f8
     2 long_text_id = f8
     2 report_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 IF (jrec_ret=0)
  SET audit_reply->status_data.status = "F"
  SET audit_reply->status_data.subeventstatus[1].operationname = "cnvtjsontorec"
  SET audit_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET audit_reply->status_data.subeventstatus[1].targetobjectname = "audit_request"
  SET audit_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Convert JSON to REC failed with status 0"
  GO TO exitscript
 ENDIF
 DECLARE user_parser = vc
 IF ((audit_request->username=0))
  SET user_parser = "(1=1)"
 ELSE
  SET user_parser = "(c.updt_id = audit_request->username )"
 ENDIF
 DECLARE req_num_parser = vc
 IF ((audit_request->request_source=3050003))
  SET req_num_parser = "(c.request_nbr = 3050002 and c.object_type = 'QUERY')"
 ELSEIF ((audit_request->request_source=0))
  SET req_num_parser = "(1 = 1)"
 ELSE
  SET req_num_parser = concat("(c.request_nbr = ",cnvtstring(audit_request->request_source),
   " and c.object_type != 'QUERY')")
 ENDIF
 IF (curutc=0)
  SET audit_request->begin_dt_tm = cnvtdatetimeutc(audit_request->begin_dt_tm,4)
  SET audit_request->end_dt_tm = cnvtdatetimeutc(audit_request->end_dt_tm,4)
 ENDIF
 SELECT INTO "NL:"
  c.object_name, c.object_type, c.status,
  c.object_params, elapsed_seconds = datetimediff(c.end_dt_tm,c.begin_dt_tm,5), c.begin_dt_tm,
  c.end_dt_tm, c.application_nbr, c.records_cnt,
  c.output_device, c.tempfile, c.active_ind,
  c.updt_dt_tm, c.updt_id
  FROM ccl_report_audit c,
   person p,
   application a
  PLAN (c
   WHERE c.updt_dt_tm BETWEEN cnvtdatetime(audit_request->begin_dt_tm) AND cnvtdatetime(audit_request
    ->end_dt_tm)
    AND cnvtupper(c.status)=patstring(cnvtupper(audit_request->status))
    AND cnvtupper(c.object_name)=patstring(cnvtupper(audit_request->program_name))
    AND parser(user_parser)
    AND parser(req_num_parser))
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number
    AND cnvtupper(a.description)=patstring(cnvtupper(audit_request->source_app)))
  ORDER BY c.object_name, a.description, c.updt_dt_tm DESC
  HEAD REPORT
   stat = alterlist(audit_reply->qual,1000), count = 0
  DETAIL
   count += 1
   IF (mod(count,1000)=1
    AND count > 1000)
    stat = alterlist(audit_reply->qual,(count+ 999))
   ENDIF
   audit_reply->qual[count].object_name = c.object_name, audit_reply->qual[count].status = c.status,
   audit_reply->qual[count].object_params = c.object_params,
   audit_reply->qual[count].elapsed_seconds = elapsed_seconds, audit_reply->qual[count].begin_dt_tm
    = c.begin_dt_tm, audit_reply->qual[count].user = p.name_full_formatted,
   audit_reply->qual[count].application_desc = a.description, audit_reply->qual[count].records_cnt =
   c.records_cnt, audit_reply->qual[count].long_text_id = c.long_text_id,
   audit_reply->qual[count].report_event_id = c.report_event_id
  FOOT REPORT
   stat = alterlist(audit_reply->qual,count), audit_reply->qual_cnt = count
  WITH nocounter
 ;end select
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET audit_reply->status_data.status = "F"
  SET audit_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET audit_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET audit_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(audit_reply,2,1)
END GO
