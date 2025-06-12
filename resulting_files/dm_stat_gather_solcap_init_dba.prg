CREATE PROGRAM dm_stat_gather_solcap_init:dba
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hreqstruct = i4
 DECLARE happ = i4
 DECLARE iret = i2
 DECLARE idx = i4 WITH protect
 DECLARE logfile = c100
 DECLARE debug_msg_ind = i2
 DECLARE d_err_msg = c132
 SET logfile = build("DM_STAT_SOLCAP_INIT_",curnode,"_",day(curdate),".txt")
 CALL getdebugrow("x")
 CALL log_msg("BeginSession",logfile)
 FREE RECORD request
 RECORD request(
   1 capabilities[*]
     2 solcap_script = vc
     2 solcap_script_index = i4
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM_STAT_SOLCAP_SCRIPT"
   AND info_char="EOD 1 NODE"
  ORDER BY di.info_name
  HEAD REPORT
   idx = 0
  DETAIL
   idx = (idx+ 1)
   IF (mod(idx,10)=1)
    stat = alterlist(request->capabilities,(idx+ 9))
   ENDIF
   request->capabilities[idx].solcap_script = trim(di.info_name), request->capabilities[idx].
   solcap_script_index = idx, request->capabilities[idx].start_dt_tm = cnvtdatetime((curdate - 1),0),
   request->capabilities[idx].end_dt_tm = cnvtdatetime((curdate - 1),235959)
  FOOT REPORT
   stat = alterlist(request->capabilities,idx)
  WITH nocounter
 ;end select
 SET idx = 0
 WHILE (idx < size(request->capabilities,5))
   SET idx = (idx+ 1)
   CALL echo(build2("Executing solution capability script...",request->capabilities[idx].
     solcap_script))
   CALL async_exec_script(7700,7700,7701,request->capabilities[idx].solcap_script)
 ENDWHILE
 SUBROUTINE async_exec_script(appid,taskid,reqid,scriptname)
   SET happ = uar_crmgetapphandle()
   IF (happ=0)
    SET iret = uar_crmbeginapp(appid,happ)
    IF (iret != 0)
     CALL esmerror(build("Error obtaining application handle:",iret),esmreturn)
     CALL echo(build("Execution of ",scriptname," was not successful"))
     GO TO end_routine
    ENDIF
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (((iret != 0) OR (htask=0)) )
    CALL esmerror(build("Error calling CrmBeginTask:",iret),esmreturn)
    CALL echo(build("Execution of ",scriptname," was not successful"))
    GO TO end_routine
   ENDIF
   SET iret = uar_crmbeginreq(htask,0,reqid,hreq)
   IF (((iret != 0) OR (hreq=0)) )
    CALL esmerror(build("Error calling CrmBeginReq:",iret),esmreturn)
    CALL echo(build("Execution of ",scriptname," was not successful"))
    GO TO end_routine
   ENDIF
   SET hreqstruct = uar_crmgetrequest(hreq)
   SET stat = uar_srvsetstring(hreqstruct,"solcap_script",nullterm(request->capabilities[idx].
     solcap_script))
   CALL log_msg(build2("Value of SOLCAP_SCRIPT: ",nullterm(request->capabilities[idx].solcap_script)),
    logfile)
   CALL log_msg(build2("Value of stat: ",stat),logfile)
   SET stat = uar_srvsetdate(hreqstruct,"start_dt_tm",cnvtdatetime(request->capabilities[idx].
     start_dt_tm))
   CALL log_msg(build2("Value of START: ",cnvtdatetime(request->capabilities[idx].start_dt_tm)),
    logfile)
   CALL log_msg(build2("Value of stat: ",stat),logfile)
   SET stat = uar_srvsetdate(hreqstruct,"end_dt_tm",cnvtdatetime(request->capabilities[idx].end_dt_tm
     ))
   CALL log_msg(build2("Value of END TIME: ",cnvtdatetime(request->capabilities[idx].end_dt_tm)),
    logfile)
   CALL log_msg(build2("Value of stat: ",stat),logfile)
   SET stat = uar_srvsetlong(hreqstruct,"solcap_script_index",request->capabilities[idx].
    solcap_script_index)
   CALL log_msg(build2("Value of INDEX: ",request->capabilities[idx].solcap_script_index),logfile)
   CALL log_msg(build2("Value of stat: ",stat),logfile)
   SET iret = uar_crmperform(hreq)
   IF (iret != 0)
    CALL esmerror(build2("Error calling CrmPerform:",iret),esmreturn)
    CALL echo(build2("Execution of ",scriptname," was not successful"))
    GO TO end_routine
   ENDIF
   CALL echo(build2("Execution of ",scriptname," was successful"))
#end_routine
   IF (hreq > 0)
    SET iret = uar_crmendreq(hreq)
   ENDIF
   IF (htask > 0)
    SET iret = uar_crmendtask(htask)
   ENDIF
 END ;Subroutine
 SUBROUTINE log_msg(logmsg,sbr_dlogfile)
   IF (debug_msg_ind=1)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1,
      dm_eproc_length = textlen(logmsg)
     DETAIL
      IF (logmsg="BeginSession")
       row + 1, "DM_STAT_GATHER_SOLCAP_INIT Begins:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSEIF (logmsg="EndSession")
       row + 1, "DM_STAT_GATHER_SOLCAP_INIT Ends:", row + 1,
       curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm:ss;3;m"
      ELSE
       dm_txt = substring(beg_pos,end_pos,logmsg)
       WHILE (not_done=1)
         row + 1, col 0, dm_txt,
         row + 1, curdate"mm/dd/yyyy;;d", " ",
         curtime3"hh:mm:ss;3;m"
         IF (end_pos > dm_eproc_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,logmsg)
         ENDIF
       ENDWHILE
      ENDIF
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getdebugrow(x)
  SELECT INTO "nl:"
   di.info_number
   FROM dm_info di
   WHERE info_domain="DM_STAT_GATHER_SOLCAP_DEBUG"
    AND info_name="DEBUG_IND"
   DETAIL
    debug_msg_ind = di.info_number
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info
    SET info_domain = "DM_STAT_GATHER_SOLCAP_DEBUG", info_name = "DEBUG_IND", info_number = 0
    WITH nocounter
   ;end insert
   COMMIT
   SET debug_msg_ind = 0
  ENDIF
 END ;Subroutine
 CALL log_msg("EndSession",logfile)
END GO
