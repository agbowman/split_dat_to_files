CREATE PROGRAM cpmstartup_recache:dba
 DECLARE _scp_id = i2
 DECLARE _cclrptaudit_none = i2 WITH constant(0)
 DECLARE _cclrptaudit_full = i2 WITH constant(1)
 DECLARE _cclrptaudit_minsecs = i2 WITH constant(2)
 DECLARE _cclrptaudit_cust = i2 WITH constant(3)
 EXECUTE cpmstartup
 SET trace = skippersist
 SET trace = callecho
 IF (validate(_ccl_rpt_audit,1) != 1)
  CALL echo("declaring _ccl_rpt_audit..")
  DECLARE _ccl_rpt_audit = i4 WITH persist, noconstant(0)
 ENDIF
 SET modify maxvarlen 10000000
 DECLARE hscp = i4
 DECLARE hmsg = i4
 DECLARE hreq = i4
 DECLARE hrep = i4
 DECLARE emsgok = i2 WITH constant(0)
 DECLARE spropname = vc
 DECLARE spropvalue = vc WITH noconstant(" ")
 SET hscp = 0
 SUBROUTINE (scp_init_props(scp_id=i4) =i4)
   EXECUTE dpsrtl
   DECLARE snodename = vc
   DECLARE sstartupscript = vc
   DECLARE idx = i4 WITH noconstant(0)
   SET snodename = trim(curnode)
   SET hscp = uar_scpcreate(nullterm(snodename))
   IF (hscp=0)
    CALL echo(concat("scp_read_prop:uar_scpcreate failed. Node name= ",snodename))
    RETURN(spropvalue)
   ENDIF
   SET hmsg = uar_scpselect(hscp,scp_queryentry)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hrep = uar_srvcreatereply(hmsg)
   SET hitem = uar_srvadditem(hreq,"querylist")
   SET srvstat = uar_srvsetushort(hitem,"entryid",scp_id)
   SET srvstat = uar_srvexecute(hmsg,hreq,hrep)
 END ;Subroutine
 SUBROUTINE (scp_read_prop(scp_id=i4,scp_prop=vc) =vc)
   DECLARE sstartupscript = vc
   DECLARE idx = i4 WITH noconstant(0)
   SET spropvalue = " "
   IF (hscp=0)
    SET srvstat = scp_init_props(scp_id)
    IF (srvstat != emsgok)
     CALL echo(build("scp_read_prop:uar_srvexecute failed. status= ",srvstat))
     RETURN(spropvalue)
    ENDIF
   ENDIF
   SET nbr_entries = uar_srvgetitemcount(hrep,"entrylist")
   SET hitem = uar_srvgetitem(hrep,"entrylist",idx)
   SET nbr_prop = uar_srvgetitemcount(hitem,"proplist")
   FOR (idx2 = 0 TO (nbr_prop - 1))
     SET hpropitem = uar_srvgetitem(hitem,"proplist",idx2)
     SET spropname = uar_srvgetstringptr(hpropitem,"propname")
     IF (cnvtupper(spropname)=cnvtupper(scp_prop))
      SET spropvalue = cnvtupper(uar_srvgetstringptr(hpropitem,"propvalue"))
      CALL echo(build("scp_read_prop:",spropname,", value= ",spropvalue))
      RETURN(spropvalue)
     ENDIF
   ENDFOR
   RETURN(spropvalue)
 END ;Subroutine
 SET ccl_env = cnvtupper(logical("ENVIRONMENT_MODE"))
 IF (ccl_env="*PROD*")
  SET trace = skiprecache
 ELSE
  SET trace = noskiprecache
 ENDIF
 SET _ccl_rpt_audit = 0
 SET _scp_id = curserver
 IF (_scp_id=0)
  SET _scp_id = 79
 ENDIF
 CALL echo(build("cpmstartup_recache. check mPageAudit for server# ",_scp_id))
 SET smpageaudit = scp_read_prop(_scp_id,"MPAGEAUDIT")
 IF (((smpageaudit="N") OR (smpageaudit="0")) )
  SET _ccl_rpt_audit = _cclrptaudit_none
 ELSEIF (((smpageaudit="Y") OR (smpageaudit="1")) )
  SET _ccl_rpt_audit = _cclrptaudit_full
 ELSEIF (textlen(smpageaudit) > 0)
  DECLARE auditsecs = i4
  SET auditsecs = cnvtint(smpageaudit)
  IF (auditsecs > 0)
   SET _ccl_rpt_audit = _cclrptaudit_minsecs
   SET _min_audit_secs = auditsecs
   CALL echo(build("cpmstartup_recache: enable ccl_report_audit for _min_audit_secs = ",
     _min_audit_secs))
  ENDIF
 ENDIF
 DECLARE srvinstance = i2
 IF (cursysbit=64)
  SET srvinstance = cnvtint(substring(9,4,trim(curprcname)))
 ELSE
  SET srvinstance = cnvtint(substring(9,2,trim(curprcname)))
 ENDIF
 CALL echo(build("CURPRCNAME= ",curprcname,", instance# ",srvinstance))
 SET screatecpc = scp_read_prop(_scp_id,"CREATECPC")
 IF (((screatecpc="N") OR (screatecpc="0")) )
  SET _create_cpc = 0
  CALL echo(build("cpmstartup_recache. CreateCpc flag= ",screatecpc," for server# ",_scp_id))
 ELSEIF (((screatecpc="Y") OR (screatecpc="1")) )
  SET _create_cpc = 1
 ENDIF
 IF (_ccl_rpt_audit=_cclrptaudit_full)
  SET sinstcount = scp_read_prop(_scp_id,"AUDITINSTCOUNT")
  IF (textlen(sinstcount) > 0)
   IF (srvinstance > cnvtint(sinstcount))
    SET _ccl_rpt_audit = 0
   ELSE
    CALL echo(build("cpmstartup_recache: AuditInstCount= ",sinstcount," for server# ",_scp_id,
      "; _ccl_rpt_audit=1.."))
   ENDIF
  ENDIF
  GO TO end_script
 ENDIF
 DECLARE prgcnt = i2
 DECLARE usercnt = i2
 SELECT INTO "NL:"
  d.info_domain, d.info_name, d.info_number,
  d.info_date, d.info_char, d.updt_dt_tm
  FROM dm_info d
  WHERE d.info_domain="CCL_REPORT_AUDIT"
  HEAD REPORT
   prgcnt = 0, usercnt = 0
  DETAIL
   IF (d.info_char="CCLPROGRAM")
    prgcnt += 1, stat = alterlist(cclrptaudit_rec->programs,prgcnt), cclrptaudit_rec->programs[prgcnt
    ].script_name = cnvtupper(d.info_name)
   ELSEIF (d.info_char="USERNAME")
    usercnt += 1, stat = alterlist(cclrptaudit_rec->users,usercnt), cclrptaudit_rec->users[usercnt].
    user_name = d.info_name,
    cclrptaudit_rec->users[usercnt].prsnl_id = d.info_number
   ENDIF
  WITH nocounter
 ;end select
 IF (((prgcnt > 0) OR (usercnt > 0)) )
  SET _ccl_rpt_audit = _cclrptaudit_cust
  CALL echo(build("..ccl_rpt_audit= ",_cclrptaudit_cust," (Custom program/user-level auditing)"))
  CALL echorecord(cclrptaudit_rec)
 ENDIF
#end_script
 SET trace = rdbcomment
 SET trace = error
 IF (currdbuser="V500_MPAGE")
  CALL echo("command: rdb alter session set current_schema = v500 end")
  RDB alter session set current_schema = v500
  END ;Rdb
 ENDIF
 SET trace = nocallecho
END GO
