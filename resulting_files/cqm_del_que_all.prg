CREATE PROGRAM cqm_del_que_all
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
 SET table_name = concat("CQM_",trim(request->app_name),"_QUE")
 SET parse_buffer = concat("rdb delete ",trim(table_name)," go")
 CALL parser(parse_buffer)
#exit_script
 SET reply->status_data.status = "S"
 IF (validate(reqinfo->commit_ind,0) != 0)
  SET reqinfo->commit_ind = 1
 ELSE
  COMMIT
 ENDIF
END GO
