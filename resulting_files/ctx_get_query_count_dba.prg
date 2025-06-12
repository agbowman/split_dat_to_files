CREATE PROGRAM ctx_get_query_count:dba
 RECORD reply(
   1 querycount = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE ctx_get_querycount parser(
  IF ((request->optactive=1)) "0=0"
  ELSEIF ((request->optactive=2)) "a.end_dt_tm = null"
  ELSEIF ((request->optactive=3)) "a.end_dt_tm != null"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF ((request->application_number > 0)) "a.application_number = request->application_number"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF ((request->appctxid > 0)) "a.app_ctx_id = request->appctxid"
  ELSE "0=0"
  ENDIF
  ),
 parser(
  IF ((request->optauth=1)) "0=0"
  ELSEIF ((request->optauth=2)) "a.authorization_ind = 1"
  ELSEIF ((request->optauth=3)) "a.authorization_ind = 0"
  ELSE "0=0"
  ENDIF
  ), parser(
  IF ((request->person_id > 0)) "a.person_id = request->person_id"
  ELSE "0=0"
  ENDIF
  )
END GO
