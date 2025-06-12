CREATE PROGRAM dcp_get_plan_ids_by_phase_ids:dba
 SET modify = predeclare
 CALL echo("<------------------------------------->")
 CALL echo("<---   BEGIN: DCP_GET_PLAN_IDS_BY_PHASE_IDS   --->")
 CALL echo("<------------------------------------->")
 DECLARE dqtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(dqtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
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
 DECLARE request_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE planlistsize = i4 WITH protect, noconstant(0)
 DECLARE planlistcount = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  p.pathway_id, p.pw_group_nbr
  FROM pathway p
  WHERE expand(num,1,request_count,p.pathway_id,request->phases[num].phase_id)
  HEAD REPORT
   planlistcount = 0, planlistsize = 0
  DETAIL
   planlistcount = (planlistcount+ 1)
   IF (planlistsize < planlistcount)
    planlistsize = (planlistsize+ 10), stat = alterlist(reply->plans,planlistsize)
   ENDIF
   reply->plans[planlistcount].phase_id = p.pathway_id, reply->plans[planlistcount].plan_id = p
   .pw_group_nbr
  FOOT REPORT
   stat = alterlist(reply->plans,planlistcount)
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
    SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_GET_PLAN_IDS_BY_PHASE_IDS"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF (size(reply->plans,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("***********************************************")
 CALL echo("***   Start of internal structure cleanup   ***")
 CALL echo("***********************************************")
 FREE RECORD errors
 SET smoddate = "June 25, 2012"
 SET slastmod = "000"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),dqtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<---------------------------------->")
 CALL echo("<---   END DCP_GET_PLAN_IDS_BY_PHASE_IDS   --->")
 CALL echo("<---------------------------------->")
END GO
