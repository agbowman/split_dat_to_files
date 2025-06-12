CREATE PROGRAM dcp_update_order_iv_info:dba
 DECLARE program_version = vc WITH private, constant("001")
 DECLARE program_name = vc WITH protect, constant("dcp_update_order_iv_info")
 SET modify = predeclare
 DECLARE tracerbegin(programname=vc,version=vc) = null
 SUBROUTINE tracerbegin(programname,version)
  CALL echo("BEGIN",0)
  CALL printnameversion(programname,version)
 END ;Subroutine
 DECLARE tracerend(programname=vc,version=vc) = null
 SUBROUTINE tracerend(programname,version)
  CALL echo("END",0)
  CALL printnameversion(programname,version)
 END ;Subroutine
 DECLARE printnameversion(programname=vc,version=vc) = null
 SUBROUTINE printnameversion(programname,version)
   CALL echo(build(" [",programname,"]"),0)
   CALL echo(" v",0)
   CALL echo(version,0)
   CALL echo(" @",0)
   CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 END ;Subroutine
 DECLARE checkerrors(programname=vc) = i1
 SUBROUTINE checkerrors(programname)
   DECLARE errormessage = vc WITH private, noconstant("")
   DECLARE numberoferrors = i4 WITH private, noconstant(0)
   DECLARE errorcode = i1 WITH private, noconstant(error(errormessage,0))
   IF (errorcode > 0)
    CALL echo("")
    CALL echo(build("Errors encountered while running program [",programname,"]"))
    SET reply->status_data.status = "F"
    WHILE (errorcode != 0
     AND numberoferrors < 20)
      SET numberoferrors = (numberoferrors+ 1)
      CALL echo(errormessage)
      CALL addsubeventstatus(programname,"F","CCL ERROR",errormessage)
      SET errorcode = error(errormessage,0)
    ENDWHILE
   ENDIF
   IF (numberoferrors > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE addsubeventstatus(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) = null
 SUBROUTINE addsubeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE stataddsubevent = i4 WITH private, noconstant(0)
   DECLARE subeventstatussize = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5)
    )
   IF (((size(trim(reply->status_data.subeventstatus[subeventstatussize].operationname),1) > 0) OR (
   ((size(trim(reply->status_data.subeventstatus[subeventstatussize].operationstatus),1) > 0) OR (((
   size(trim(reply->status_data.subeventstatus[subeventstatussize].targetobjectname),1) > 0) OR (size
   (trim(reply->status_data.subeventstatus[subeventstatussize].targetobjectvalue),1) > 0)) )) )) )
    SET subeventstatussize = (subeventstatussize+ 1)
    SET stataddsubevent = alter(reply->status_data.subeventstatus,subeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[subeventstatussize].operationname = substring(0,25,
    operationname)
   SET reply->status_data.subeventstatus[subeventstatussize].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[subeventstatussize].targetobjectname = substring(0,25,
    targetobjectname)
   SET reply->status_data.subeventstatus[subeventstatussize].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET stat = alterlist(reply->status_data.subeventstatus,1)
 SET reply->status_data.status = "F"
 DECLARE iv_orders_count = i4 WITH private, constant(size(request->iv_orders,5))
 IF (iv_orders_count <= 0)
  CALL addsubeventstatus(program_name,"F","Invalid Request",
   "At least one iv_orders item must be provided.")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO iv_orders_count)
   IF ((request->iv_orders[idx].order_id <= 0.0))
    CALL addsubeventstatus(program_name,"F","Invalid Request",
     "All order IDs must be greater than zero.")
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE bags_given_bit_mask = i4 WITH private, constant(2)
 UPDATE  FROM order_iv_info oii,
   (dummyt d  WITH seq = value(iv_orders_count))
  SET oii.applicable_fields_bit = band(oii.applicable_fields_bit,bnot(value(bags_given_bit_mask))),
   oii.finished_bags_cnt = 0, oii.updt_cnt = (oii.updt_cnt+ 1),
   oii.updt_id = reqinfo->updt_id, oii.updt_task = reqinfo->updt_task, oii.updt_applctx = reqinfo->
   updt_applctx,
   oii.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (oii
   WHERE (oii.order_id=request->iv_orders[d.seq].order_id))
  WITH nocounter
 ;end update
 IF (curqual != iv_orders_count)
  CALL addsubeventstatus(program_name,"F","Update failed",build2((value(iv_orders_count) - curqual),
    " rows could not be updated."))
  ROLLBACK
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
