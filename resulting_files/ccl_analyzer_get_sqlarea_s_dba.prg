CREATE PROGRAM ccl_analyzer_get_sqlarea_s:dba
 RECORD reply(
   1 qual[*]
     2 program_name = c30
     2 avgbufgets = c11
     2 buffer_gets = c11
     2 disk_reads = c10
     2 executions = c10
     2 users_executing = c7
     2 parse_calls = c10
     2 loads = c10
     2 sorts = c7
     2 parsing_user_id = c5
     2 first_load_time = c19
     2 query = vc
     2 rnum = i4
     2 qnum = i4
     2 sql_text = vc
     2 hash_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET var
 FREE DEFINE var
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 DECLARE program_name = vc
 SET program_name = request->program_name
 IF ( NOT (program_name > " "))
  SET var = "*"
 ELSE
  SET var = concat("*+ *CCL<",cnvtupper(trim(program_name)),"*")
 ENDIF
 SELECT INTO "nl:"
  s.sql_text, s.buffer_gets, s.disk_reads,
  s.parse_calls, s.loads, s.executions,
  s.users_executing, s.sorts, s.first_load_time,
  s.parsing_user_id, buf_gets_per_exec =
  IF (s.executions > 0) (s.buffer_gets/ s.executions)
  ELSE 0
  ENDIF
  FROM v$sqlarea s
  WHERE s.sql_text=patstring(value(var))
   AND s.parsing_user_id != 0
   AND (s.buffer_gets >= request->buffer_gets)
   AND (s.disk_reads >= request->disk_reads)
   AND (s.executions >= request->executions)
   AND (s.users_executing >= request->users_executing)
   AND (s.parse_calls >= request->parse_calls)
   AND (s.loads >= request->loads)
   AND (s.sorts >= request->sorts)
   AND (s.parsing_user_id >= request->parsing_user_id)
  ORDER BY buf_gets_per_exec DESC
  HEAD REPORT
   stat = alterlist(reply->qual,10), end_pos = 0, start_pos = 0,
   prog_name = fillstring(30," ")
  DETAIL
   IF ((cnt < request->top_offenders))
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->qual,(cnt+ 10))
    ENDIF
    start_pos = findstring("CCL<",s.sql_text,1,0)
    IF (start_pos > 0)
     start_pos = (start_pos+ 4), end_pos = findstring(":S",s.sql_text,start_pos,0)
     IF (end_pos <= start_pos)
      end_pos = findstring("*/",s.sql_text,start_pos,0)
     ENDIF
    ELSE
     start_pos = 1
    ENDIF
    IF (end_pos > start_pos)
     prog_name = substring(start_pos,(end_pos - start_pos),s.sql_text)
    ELSE
     prog_name = substring(1,30,s.sql_text)
    ENDIF
    av = (s.buffer_gets/ s.executions), reply->qual[cnt].avgbufgets = format(av,"###########;p "),
    reply->qual[cnt].program_name = prog_name,
    reply->qual[cnt].buffer_gets = format(s.buffer_gets,"###########;p "), reply->qual[cnt].
    disk_reads = format(s.disk_reads,"#########;p "), reply->qual[cnt].executions = format(s
     .executions,"########;p "),
    reply->qual[cnt].users_executing = format(s.users_executing,"#######;p "), reply->qual[cnt].
    parse_calls = format(s.parse_calls,"##########;p "), reply->qual[cnt].loads = format(s.loads,
     "#####;p "),
    reply->qual[cnt].sorts = format(s.sorts,"#####;p "), reply->qual[cnt].parsing_user_id = format(s
     .parsing_user_id,"#####;p "), reply->qual[cnt].first_load_time = s.first_load_time,
    reply->qual[cnt].query = s.sql_text, reply->qual[cnt].sql_text = s.sql_text, reply->qual[cnt].
    hash_value = s.hash_value
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 DECLARE tempquery = vc WITH protect
 SET cntx = 0
 SELECT INTO "nl:"
  t.sql_text, d1seq = d1.seq, exec = reply->qual[d1.seq].executions
  FROM v$sqltext t,
   (dummyt d1  WITH seq = size(reply->qual,5))
  PLAN (d1
   WHERE size(reply->qual,5) > 0
    AND (reply->qual[d1.seq].sql_text=patstring(value(var))))
   JOIN (t
   WHERE outerjoin(reply->qual[d1.seq].hash_value)=t.hash_value)
  ORDER BY exec DESC, t.address, t.hash_value,
   t.piece
  HEAD REPORT
   cntx = 0
  HEAD t.address
   IF (t.sql_text > " ")
    reply->qual[d1.seq].query = " "
   ENDIF
  DETAIL
   cntx = (cntx+ 1), reply->qual[d1.seq].query = concat(trim(reply->qual[d1.seq].query),trim(t
     .sql_text))
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   CALL echo(build("program_name:",reply->qual[i].program_name))
   CALL echo(build("AvgBufGets:",reply->qual[i].avgbufgets))
   CALL echo(build("buffer_gets:",reply->qual[i].buffer_gets))
   CALL echo(build("disk_reads:",reply->qual[i].disk_reads))
   CALL echo(build("executions:",reply->qual[i].executions))
   CALL echo(build("users_executing:",reply->qual[i].users_executing))
   CALL echo(build("parse_calls:",reply->qual[i].parse_calls))
   CALL echo(build("loads:",reply->qual[i].loads))
   CALL echo(build("sorts:",reply->qual[i].sorts))
   CALL echo(build("parsing_user_id:",reply->qual[i].parsing_user_id))
   CALL echo(build("first_load_time:",reply->qual[i].first_load_time))
   CALL echo(build(reply->qual[i].query))
   CALL echo(build(reply->qual[i].sql_text))
 ENDFOR
 SET failed = "F"
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_analyzer_get_sqlarea"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
#endit
 CALL echo(build("failed=",failed),1,10)
END GO
