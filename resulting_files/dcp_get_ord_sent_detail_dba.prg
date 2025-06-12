CREATE PROGRAM dcp_get_ord_sent_detail:dba
 SET modify = predeclare
 CALL echo("<-------------------------------------------->")
 CALL echo("<---   BEGIN: <dcp_get_ord_sent_detail>   --->")
 CALL echo("<-------------------------------------------->")
 DECLARE qtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(qtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 RECORD reply(
   1 qual[*]
     2 sequence = i4
     2 oe_field_id = f8
     2 oe_field_value = f8
     2 oe_field_display_value = vc
     2 oe_field_meaning_id = f8
     2 oe_field_meaning = c25
     2 field_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nstatus_unknown = i2 WITH private, constant(0)
 DECLARE nsuccess = i2 WITH private, constant(1)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(2)
 DECLARE nscriptstatus = i2 WITH private, noconstant(nstatus_unknown)
 DECLARE nstat = i2 WITH private, noconstant(0)
 DECLARE slastmod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE smoddate = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 DECLARE inumberoffields = i4 WITH protect, noconstant(0)
 DECLARE inumberofallocatedfields = i4 WITH protect, noconstant(0)
 DECLARE nalterliststatus = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  o.sequence
  FROM order_sentence_detail o,
   oe_field_meaning m
  PLAN (o
   WHERE (o.order_sentence_id=request->order_sentence_id)
    AND o.order_sentence_id != 0)
   JOIN (m
   WHERE o.oe_field_meaning_id=m.oe_field_meaning_id)
  DETAIL
   inumberoffields = (inumberoffields+ 1)
   IF (inumberofallocatedfields < inumberoffields)
    inumberofallocatedfields = (inumberofallocatedfields+ 10), nalterliststatus = alterlist(reply->
     qual,inumberofallocatedfields)
   ENDIF
   reply->qual[inumberoffields].sequence = o.sequence, reply->qual[inumberoffields].oe_field_id = o
   .oe_field_id
   IF (o.field_type_flag IN (6, 8, 9, 10, 12,
   13))
    reply->qual[inumberoffields].oe_field_value = validate(o.default_parent_entity_id,o
     .oe_field_value)
   ELSE
    reply->qual[inumberoffields].oe_field_value = o.oe_field_value
   ENDIF
   reply->qual[inumberoffields].oe_field_display_value = o.oe_field_display_value, reply->qual[
   inumberoffields].oe_field_meaning_id = o.oe_field_meaning_id, reply->qual[inumberoffields].
   oe_field_meaning = m.oe_field_meaning,
   reply->qual[inumberoffields].field_type_flag = o.field_type_flag
  WITH nocounter
 ;end select
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET nstat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET nstat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_get_ord_sent_detail"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (inumberoffields <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET nalterliststatus = alterlist(reply->qual,inumberoffields)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD errors
 SET smoddate = "August 07, 2008"
 SET slastmod = "000"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<----------------------------------------->")
 CALL echo("<---   END <dcp_get_ord_sent_detail>   --->")
 CALL echo("<----------------------------------------->")
END GO
