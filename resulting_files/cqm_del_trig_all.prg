CREATE PROGRAM cqm_del_trig_all
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET table_name = fillstring(80," ")
 SET parse_buffer = fillstring(256," ")
 SET stat = memalloc(ext_list,10,"C15")
 SET count1 = 0
 SET incr = 10
 SELECT DISTINCT INTO "nl:"
  l.listener_trigger_table_ext
  FROM cqm_listener_config l
  WHERE l.application_name=trim(value(request->app_name))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (count1=incr)
    incr += 10, stat = memrealloc(ext_list,(count1+ 10),"C15")
   ENDIF
   ext_list[count1] = l.listener_trigger_table_ext
  WITH nocounter
 ;end select
 SET x = 1
 FOR (x = x TO count1)
   SET table_name = concat("CQM_",trim(request->app_name),"_TR_",trim(cnvtstring(ext_list[x])))
   SET parse_buffer = concat("rdb delete ",trim(table_name)," go")
   CALL echo(parse_buffer)
   CALL parser(parse_buffer)
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF (validate(reqinfo->commit_ind,0) != 0)
  SET reqinfo->commit_ind = 1
 ELSE
  COMMIT
 ENDIF
END GO
