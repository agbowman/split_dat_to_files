CREATE PROGRAM dcp_check_dup_def_name
 DECLARE exec_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 no_dup_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].operationname = "DCP_CHECK_DUP_DEF_NAME"
 DECLARE no_dup_ind = i2 WITH protect, noconstant(1)
 SELECT INTO "nl:"
  itd.total_definition_name
  FROM io_total_definition itd
  WHERE (itd.total_definition_name=request->total_definition_name)
   AND itd.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  DETAIL
   IF ((((request->io_total_definition_id=0.0)) OR ((request->io_total_definition_id != itd
   .io_total_definition_id))) )
    no_dup_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
  GO TO exit_program
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 IF (no_dup_ind=1)
  SET reply->no_dup_ind = 1
 ENDIF
#exit_program
 IF ((request->debug_ind=1))
  CALL echo("*********************")
  CALL echo("*	 THE REQUEST    *")
  CALL echo("*********************")
  CALL echorecord(request)
  CALL echo("*********************")
  CALL echo("*	  THE REPLY     *")
  CALL echo("*********************")
  CALL echorecord(reply)
  CALL echo("*********************")
  CALL echo("*	  EXEC TIME     *")
  CALL echo("*********************")
  CALL echo(build("TOTAL EXECUTION TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),
     exec_dt_tm,5)))
 ENDIF
END GO
