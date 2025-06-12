CREATE PROGRAM ccl_run_prompt_help:dba
 FREE RECORD reply
 RECORD reply(
   1 prompt_list[*]
     2 prompt_num = i2
     2 prompt_desc = c132
     2 default = c132
     2 data_type = c1
     2 control_ind = i2
     2 fieldname = vc
     2 fieldsize = i4
     2 context_startval = vc
     2 enable_more = c1
     2 cnt = i4
     2 errid = i4
     2 errmsg = vc
     2 qual[*]
       3 display_element = vc
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cclmenureply
 RECORD cclmenureply(
   1 qual[*]
     2 prompt_num = i4
     2 prompts = c132
     2 defaults = c132
     2 data_type = c1
     2 prompt_name = vc
   1 message = c132
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
 SET cnt = 0
 DECLARE stat = i4
 DECLARE promptcnt = i4
 SET prgname = request->program_name
 SET testing = 0
 DECLARE errmsg = c255
 SET stat = error(errmsg,1)
 SET reply->message = fillstring(132," ")
 CALL echo(concat("CCL_RUN_PROMPT_HELP: Get prompt info with ccl_menu_get_prompts"))
 EXECUTE ccl_menu_get_prompts  WITH replace(reply,cclmenureply)
 SET promptcnt = size(cclmenureply->qual,5)
 IF (promptcnt=0)
  SET reply->status_data.status = cclmenureply->status_data.status
  SET reply->status_data.subeventstatus[0].operationname = "run prompt help"
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = curprog
  SET reply->status_data.subeventstatus[0].targetobjectvalue = cclmenureply->message
  SET reply->message = cclmenureply->message
  GO TO end_script
 ELSE
  CALL echo(build("CCLMENUREPLY size:",promptcnt),1,0)
  SET stat = alterlist(reply->prompt_list,promptcnt)
  FOR (i = 1 TO promptcnt)
    CALL echo(concat(format(i,"###")," Prompt: '",build(cclmenureply->qual[i].prompt_num)," ",trim(
       cclmenureply->qual[i].prompts),
      "' ; default: '",trim(cclmenureply->qual[i].defaults),"' ; data_type: '",cclmenureply->qual[i].
      data_type,"'"),1,0)
    SET reply->prompt_list[i].prompt_desc = cclmenureply->qual[i].prompts
    SET reply->prompt_list[i].default = cclmenureply->qual[i].defaults
    SET reply->prompt_list[i].data_type = cclmenureply->qual[i].data_type
    SET reply->prompt_list[i].prompt_num = i
  ENDFOR
 ENDIF
 FREE RECORD cclmenureply
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[0].operationname = msg3
  SET reply->status_data.subeventstatus[0].operationstatus = "F"
  SET reply->status_data.subeventstatus[0].targetobjectname = curprog
  SET reply->status_data.subeventstatus[0].targetobjectvalue = errmsg
  CALL echo(concat("Status= F  Error= ",errmsg))
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(concat("Status= S",errmsg))
 ENDIF
#end_script
 CALL echo(concat("Message: ",reply->message))
 SET cnt = size(reply->prompt_list,5)
 FOR (i = 1 TO cnt)
   IF (testing)
    CALL echo("",1,0)
    CALL echo(concat("Prompt_list level:",format(i,"###")),1,0)
    CALL echo(concat(" Prompt_num: ",build(reply->prompt_list[i].prompt_num)),1,0)
    CALL echo(concat(" Prompt_desc: ",reply->prompt_list[i].prompt_desc),1,0)
    CALL echo(concat(" Default    : ",reply->prompt_list[i].default),1,0)
    CALL echo(concat(" Data_type  : ",reply->prompt_list[i].data_type),1,0)
   ENDIF
 ENDFOR
END GO
