CREATE PROGRAM ccl_analyzer_get_plan_query_s:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 rep_line = vc
   1 query_qual[*]
     2 rep_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET zzreqct = size(request->lines,5)
 SET line = fillstring(132," ")
 SET cnt = 0
 SET zzct = 0
 SET plan_cnt = 0
 SET pos = 0
 SET found = 0
 SET rdbplan_found = 0
 SET filename = cnvtlower(build(char(34),"ccluserdir:mnu",curuser,curtime2,char(34)))
 SET filename1 = cnvtlower(build("ccluserdir:mnu",curuser,curtime2))
 FOR (zzct = 1 TO zzreqct)
   SET line = request->lines[zzct].sql_line
   SET pos = findstring(" DISTINCT ",cnvtupper(line))
   IF (found=0
    AND pos > 0)
    SET request->lines[zzct].sql_line = concat(substring(1,(pos+ 8),line)," into ",filename,substring
     ((pos+ 9),999,line))
    SET found = 1
    CALL echo("Found DISTINCT, adding into filename",1,10)
   ENDIF
   IF (rdbplan_found=0)
    SET rdbplan_found = findstring("RDBPLAN",cnvtupper(line))
   ENDIF
 ENDFOR
 IF (found=0)
  FOR (zzct = 1 TO zzreqct)
    SET line = request->lines[zzct].sql_line
    SET pos = findstring("SELECT",cnvtupper(line))
    IF (pos > 0)
     SET request->lines[zzct].sql_line = concat(substring(1,(pos+ 5),line)," into ",filename,
      substring((pos+ 6),999,line))
     SET found = 1
     SET zzct = zzreqct
     CALL echo("Found Select, adding into filename",1,10)
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("request-> SQL Query lines for debugging",1,10)
 FOR (zzct = 1 TO zzreqct)
   CALL echo(request->lines[zzct].sql_line,1,10)
 ENDFOR
 IF (found=0)
  SET errcode = error(errmsg,1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FOR (zzct = 1 TO zzreqct)
   CALL parser(request->lines[zzct].sql_line)
 ENDFOR
 SET errcode = error(errmsg,1)
 CALL echo(build("****** errcode:",errcode),1,10)
 IF (((errcode=296) OR (errcode=284)) )
  SET errcode = error(errmsg,0)
  SET errcode = error(errmsg,0)
 ENDIF
 IF (errcode > 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (rdbplan_found=0)
  GO TO queryoutput
 ENDIF
 CALL oraplan("S")
 SET plan_cnt = cnt
 CALL oraplan("D")
#queryoutput
 FREE DEFINE rtl2
 FREE SET file_loc
 SET logical file_loc value(build(filename1,".DAT"))
 DEFINE rtl2 "file_loc"
 SELECT INTO "nl:"
  *
  FROM rtl2t
  WITH nocounter, maxrec = 1
 ;end select
 SET cnt = 0
 IF (curqual > 0)
  SELECT INTO "nl:"
   new_line = r.line
   FROM rtl2t r
   HEAD REPORT
    stat = alterlist(reply->query_qual,10)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alterlist(reply->query_qual,(cnt+ 9))
    ENDIF
    reply->query_qual[cnt].rep_line = new_line
   FOOT REPORT
    reply->status_data.status = "S", stat = alterlist(reply->query_qual,cnt)
   WITH nocounter
  ;end select
 ELSE
  SET cnt = 1
  SET stat = alterlist(reply->query_qual,1)
  SET reply->query_qual[1] = "Nothing qualified."
 ENDIF
 CALL echo("ccloraplan...")
 FOR (i = 1 TO plan_cnt)
   CALL echo(reply->qual[i].rep_line,1,10)
 ENDFOR
 CALL echo("Query Output...")
 FOR (i = 1 TO cnt)
   CALL echo(reply->query_qual[i].rep_line,1,10)
 ENDFOR
 CALL echo(build("plan_cnt = ",plan_cnt),1,10)
 SET errcode = error(errmsg,1)
 IF (rdbplan_found > 0)
  IF (plan_cnt > 0)
   SET failed = "F"
   GO TO exit_script
  ELSE
   SET failed = "T"
  ENDIF
 ELSEIF (errcode > 0)
  SET failed = "T"
  GO TO exit_script
 ELSE
  SET failed = "F"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo(concat("failed:",failed),1,10)
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "query"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_analyzer_get_plan_query"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO endit
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  GO TO endit
 ENDIF
 SUBROUTINE oraplan(sel_or_del)
   IF (sel_or_del="D")
    DELETE  FROM plan_table p
     WHERE p.statement_id=patstring(concat(curuser,"*"))
    ;end delete
   ELSE
    SELECT DISTINCT INTO "nl:"
     p.statement_id, p.id, p.parent_id,
     operation = substring(1,20,p.operation), options = substring(1,15,p.options), object_name = p
     .object_name,
     i.index_name, column_name = substring(1,15,c.column_name), c.column_position
     FROM plan_table p,
      all_indexes i,
      all_ind_columns c,
      (dummyt d  WITH seq = 1)
     PLAN (p
      WHERE p.statement_id=patstring(concat(curuser,"*")))
      JOIN (d)
      JOIN (i
      WHERE p.object_name=i.index_name)
      JOIN (c
      WHERE i.index_name=c.index_name)
     ORDER BY p.statement_id, p.id, p.parent_id,
      p.operation, p.options, p.object_name,
      c.column_position, c.column_name
     HEAD REPORT
      desc = "Oracle Plan", stat = alterlist(reply->qual,10), uline = fillstring(102,"-"),
      spaces = fillstring(20," "), indent = 0, cnt = (cnt+ 1),
      reply->qual[cnt].rep_line = concat(substring(1,(((102/ 2) - (size(desc)/ 2)) - 1),uline)," ",
       desc," ",substring(1,(((102/ 2) - (size(desc)/ 2)) - 1),uline))
     DETAIL
      IF (p.parent_id BETWEEN 0 AND 10)
       indent = (2 * p.parent_id)
      ELSE
       indent = 1
      ENDIF
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->qual,(cnt+ 10))
      ENDIF
      reply->qual[cnt].rep_line = concat(format(p.id,"#####;p ")," ",substring(1,indent,spaces),
       format(p.parent_id,"####;P "),"  ",
       operation," ",options," ",object_name,
       " ",column_name," ")
     FOOT REPORT
      stat = alterlist(reply->qual,cnt), reply->status_data.status = "S"
     WITH nocounter, maxrow = 1, noformfeed,
      maxcol = 250, outerjoin = d
    ;end select
   ENDIF
 END ;Subroutine
#endit
END GO
