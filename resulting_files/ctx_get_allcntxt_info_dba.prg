CREATE PROGRAM ctx_get_allcntxt_info:dba
 CALL echo(build("ctx_get_allcntxt_info called...",format(curtime3,"hh:mm:ss.cc;;m")))
 RECORD reply(
   1 qual[1]
     2 app_ctx_id = f8
     2 application_number = i4
     2 name = vc
     2 username = vc
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 application_image = c32
     2 authorization_ind = i2
     2 client_tz = i4
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET optactive = 0
 SET username = fillstring(50," ")
 SET application_number = 0
 SET appctxid = 0
 SET optauth = 0
 SET context_ind = 0
 SET application_context_id = 0
 SET maxrows = 0
 SET person_id = 0
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET context_ind = 1
  SET optactive = context->optactive
  SET username = context->username
  SET application_number = context->application_number
  SET appctxid = context->appctxid
  SET optauth = context->optauth
  SET maxrows = context->maxrows
  SET application_context_id = context->application_context_id
  SET person_id = context->person_id
 ELSE
  SET optactive = request->optactive
  SET username = request->username
  SET application_number = request->application_number
  SET appctxid = request->appctxid
  SET optauth = request->optauth
  SET maxrows = request->maxrows
  SET application_context_id = 0
  SET person_id = request->person_id
  RECORD context(
    1 context_ind = i2
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 optactive = i2
    1 username = c50
    1 application_number = f8
    1 appctxid = f8
    1 optauth = i2
    1 maxrows = i4
    1 application_context_id = f8
    1 person_id = f8
  )
  SET context->start_dt_tm = request->start_dt_tm
  SET context->end_dt_tm = request->end_dt_tm
  SET context->optactive = request->optactive
  SET context->username = request->username
  SET context->application_number = request->application_number
  SET context->appctxid = request->appctxid
  SET context->optauth = request->optauth
  SET context->person_id = request->person_id
 ENDIF
 IF (maxrows <= 0)
  SET maxrows = 100
 ENDIF
 SET stat = alter(reply->qual,maxrows)
 SET context->maxrows = maxrows
 EXECUTE ctx_get_all_cntxt_info parser(
  IF (context_ind=1)
   "(a.start_dt_tm >= cnvtdatetime(context->start_dt_tm) and a.start_dt_tm <= cnvtdatetime(context->end_dt_tm))"
  ELSE
   "(a.start_dt_tm >= cnvtdatetime(request->start_dt_tm) and a.start_dt_tm <= cnvtdatetime(request->end_dt_tm))"
  ENDIF
  ), parser(
  IF (optactive=1) "0=0"
  ELSEIF (optactive=2) "a.end_dt_tm = null"
  ELSEIF (optactive=3) "a.end_dt_tm != null"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF (application_number > 0) "a.application_number = application_number"
  ELSE "0=0"
  ENDIF
  ),
 parser(
  IF (appctxid > 0) "a.app_ctx_id = appctxid"
  ELSE "a.applctx > application_context_id"
  ENDIF
  ), parser(
  IF (optauth=1) "0=0"
  ELSEIF (optauth=2) "a.authorization_ind = 1"
  ELSEIF (optauth=3) "a.authorization_ind = 0"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF (person_id > 0) "a.person_id = person_id"
  ELSE "0=0"
  ENDIF
  )
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET stat = alter(reply->qual,1)
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 CALL echo(build("ctx_get_allcntxt_info ended...",format(curtime3,"hh:mm:ss.cc;;m")))
END GO
