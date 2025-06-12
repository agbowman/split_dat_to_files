CREATE PROGRAM crmapp_endapp:dba
 CALL echorecord(request)
 IF (validate(reply,"S")="S")
  RECORD reply(
    1 status_data
      2 status = c1
  )
 ENDIF
 IF (cnvtupper( $1)="NORDBMS")
  GO TO exit_point
 ENDIF
 IF ((((request->applctx=0)) OR ((request->applctx=null))) )
  GO TO exit_point
 ENDIF
 UPDATE  FROM application_context ac
  SET ac.end_dt_tm = cnvtdatetime(sysdate), ac.updt_cnt = (ac.updt_cnt+ 1), ac.updt_dt_tm =
   cnvtdatetime(sysdate),
   ac.application_status = request->status_code
  WHERE (ac.applctx=request->applctx)
 ;end update
 COMMIT
#exit_point
 SET reply->status_data.status = "S"
END GO
