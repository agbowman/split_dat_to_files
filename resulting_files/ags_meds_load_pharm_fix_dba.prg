CREATE PROGRAM ags_meds_load_pharm_fix:dba
 PROMPT
  "TASK_ID (0.0) = " = 0
  WITH dtid
 CALL echo("<===== AGS_MEDS_LOAD_PHARM_FIX Begin =====>")
 SET script_ver = "000 04/27/06"
 CALL echo(concat("MOD:",script_ver))
 EXECUTE si_srvrtl
 EXECUTE srvldaprtl
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 DECLARE uar_sisrvdump(p1=i4(ref)) = null WITH uar = "SiSrvDump", image_aix =
 "libsirtl.a(libsirtl.o)", image_axp = "sirtl"
 IF (validate(log,"!")="!")
  EXECUTE cclseclogin2
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  SET define_logging_sub = true
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  DECLARE sstatus_file_name = vc WITH public, constant(concat("AGS_MEDS_LOAD_PHARM_FIX_",format(
     cnvtdatetime(curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 FREE RECORD holdrec
 RECORD holdrec(
   1 qual_cnt = i4
   1 qual[*]
     2 gs_med_claim_id = f8
     2 pharmacy_ext_alias = vc
     2 pharmacy_identifier = vc
     2 pharmacy_name = vc
 )
 FREE RECORD srvrec
 RECORD srvrec(
   1 hmessage = i4
   1 hreq = i4
   1 hreqstruct = i4
   1 hrep = i4
   1 hrepstruct = i4
   1 hldap = i4
   1 hattrs1 = i4
   1 hattrs2 = i4
 )
 FREE RECORD ldaprec
 RECORD ldaprec(
   1 name = vc
   1 password = vc
   1 ip = vc
   1 port = i4
   1 base = vc
   1 timeout = i4
 )
 RECORD ncpdprec(
   1 qual_cnt = i4
   1 qual[*]
     2 ncpdpid = vc
     2 pharmacy_identifier = vc
     2 pharmacy_name = vc
 )
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $DTID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE hattrib = i4 WITH public, noconstant(0)
 DECLARE hentry = i4 WITH public, noconstant(0)
 DECLARE hvalue = i4 WITH public, noconstant(0)
 DECLARE sattrib = vc WITH public, noconstant(" ")
 DECLARE lretval = i4 WITH public, noconstant(0)
 DECLARE li = i4 WITH public, noconstant(0)
 DECLARE lj = i4 WITH public, noconstant(0)
 DECLARE lk = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE ldefaultbatchsize = i4 WITH public, constant(1000)
 DECLARE lkillind = i4 WITH public, noconstant(0)
 DECLARE lavgsec = i4 WITH public, noconstant(0)
 DECLARE litcount = i4 WITH public, noconstant(0)
 DECLARE lloglevel = i4 WITH public, noconstant(0)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(" ")
 DECLARE bldap = i2 WITH public, noconstant(0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE dstartid = f8 WITH public, noconstant(0.0)
 DECLARE dendid = f8 WITH public, noconstant(0.0)
 DECLARE lbatchsize = i4 WITH public, noconstant(0)
 DECLARE dtitend = dq8 WITH public, noconstant
 DECLARE dtitstart = dq8 WITH public, noconstant
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtblank = dq8 WITH public, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime3))
 DECLARE dtestcompletion = dq8 WITH public, noconstant
 DECLARE dt1b = f8 WITH public, noconstant(0.0)
 DECLARE dt1e = f8 WITH public, noconstant(0.0)
 CALL echo("***")
 CALL echo("***   AGS_TASK & AGS_JOB Lookup")
 CALL echo("***")
 CALL echo(build("ags_task_id:",dtaskid))
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  ORDER BY t.ags_task_id, j.ags_job_id
  HEAD t.ags_task_id
   dbatchstartid = t.batch_start_id, dbatchendid = t.batch_end_id
   IF (t.batch_size > 0)
    lbatchsize = t.batch_size
   ELSE
    lbatchsize = ldefaultbatchsize
   ENDIF
   lkillind = t.kill_ind, lloglevel = t.timers_flag
   IF (t.iteration_start_id > 0)
    dstartid = t.iteration_start_id
   ELSE
    dstartid = dbatchstartid
   ENDIF
  HEAD j.ags_job_id
   dagsjobid = j.ags_job_id
  FOOT REPORT
   IF (((dstartid+ lbatchsize) >= dbatchendid))
    dendid = dbatchendid
   ELSE
    dendid = ((dstartid+ lbatchsize) - 1)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel >= 1)
  SET trace = callecho
  SET trace = cost
 ELSE
  SET trace = nocallecho
  SET trace = nocost
 ENDIF
 SELECT INTO "nl:"
  d.*
  FROM dm_info d
  WHERE d.info_domain="RX_LDAP_CCL_CONFIG"
  DETAIL
   CASE (d.info_name)
    OF "ldap_name":
     ldaprec->name = d.info_char
    OF "ldap_password":
     ldaprec->password = d.info_char
    OF "ldap_ip":
     ldaprec->ip = d.info_char
    OF "ldap_port":
     ldaprec->port = cnvtint(d.info_char)
    OF "ldap_base":
     ldaprec->base = d.info_char
    OF "ldap_timeout":
     ldaprec->timeout = cnvtint(d.info_char)
   ENDCASE
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "ErrMsg :: LDAP settings not found"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel > 1)
  CALL echorecord(ldaprec)
 ENDIF
 IF (create_srvhandles(0))
  CALL echo("Create_SrvHandles() was Successful.")
 ELSE
  SET failed = exe_error
  SET table_name = "Create_SrvHandles()"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "ErrMsg :: Create_SrvHandles() Failed!!"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SET srvrec->hldap = uar_ldapsecurebind(nullterm(ldaprec->name),nullterm(ldaprec->password),nullterm(
   ldaprec->ip),ldaprec->port)
 IF ((srvrec->hldap=0))
  CALL echo("uar_LDAPSecureBind() failed!")
  SET failed = exe_error
  SET table_name = "uar_LDAPSecureBind()"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "ErrMsg :: uar_LDAPSecureBind() Failed!!"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL uar_srvsetstring(srvrec->hreqstruct,"base",nullterm(ldaprec->base))
 CALL uar_srvsetshort(srvrec->hreqstruct,"scope",2)
 CALL uar_srvsetlong(srvrec->hreqstruct,"timeout",ldaprec->timeout)
 SET stat = uar_srvsetshort(srvrec->hreqstruct,"sizelimit",1)
 SET srvrec->hattrs1 = uar_srvadditem(srvrec->hreqstruct,"attrs")
 IF (srvrec->hattrs1)
  CALL uar_srvsetstring(srvrec->hattrs1,"str_value",nullterm("cernerOrganizationId"))
 ENDIF
 SET srvrec->hattrs2 = uar_srvadditem(srvrec->hreqstruct,"attrs")
 IF (srvrec->hattrs2)
  CALL uar_srvsetstring(srvrec->hattrs2,"str_value",nullterm("cernerOrganizationName"))
 ENDIF
 IF (lloglevel > 1)
  CALL uar_sisrvdump(srvrec->hreq)
 ENDIF
 IF (dtaskid > 0)
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_start_dt_tm =
    cnvtdatetime(dtcurrent),
    t.batch_end_dt_tm = cnvtdatetime(dtblank), t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm =
    cnvtdatetime(dtcurrent)
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg)," TASK_ID :: ",staskid)
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 WHILE (dstartid <= dendid
  AND lkillind <= 0)
   SET dt1b = curtime3
   CALL echo(build("dT1b",dt1b))
   CALL echo(build("dStartId: ",dstartid))
   CALL echo(build("dEndId  : ",dendid))
   SET stat = initrec(holdrec)
   SET dtitstart = cnvtdatetime(curdate,curtime3)
   SELECT INTO "nl:"
    FROM ags_meds_data r
    WHERE r.ags_meds_data_id >= dstartid
     AND r.ags_meds_data_id <= dendid
     AND ((r.gs_med_claim_id+ 0) > 0.0)
     AND trim(r.status) != "IN ERROR"
    ORDER BY r.ags_meds_data_id
    HEAD REPORT
     lidx = 0
    DETAIL
     lidx = (lidx+ 1), holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx),
     holdrec->qual[lidx].gs_med_claim_id = r.gs_med_claim_id, holdrec->qual[lidx].pharmacy_ext_alias
      = trim(r.pharmacy_ext_alias,3)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo("***")
    CALL echo("***   LookUp PHARMACY_EXT_ALIAS")
    CALL echo("***")
    FOR (lidx = 1 TO holdrec->qual_cnt)
      SET lidx2 = 0
      SET lpos = 0
      SET lnum = 0
      SET lpos = locateval(lnum,1,ncpdprec->qual_cnt,holdrec->qual[lidx].pharmacy_ext_alias,ncpdprec
       ->qual[lnum].ncpdpid)
      IF (lpos > 0)
       SET lidx2 = lpos
      ELSE
       SET lidx2 = (ncpdprec->qual_cnt+ 1)
       SET ncpdprec->qual_cnt = lidx2
       SET stat = alterlist(ncpdprec->qual,lidx2)
       SET ncpdprec->qual[lidx2].ncpdpid = trim(holdrec->qual[lidx].pharmacy_ext_alias)
       CALL uar_srvsetstring(srvrec->hreqstruct,"filter",nullterm(concat("(ssncpdpid=",trim(ncpdprec
           ->qual[lidx2].ncpdpid),")")))
       SET srvrec->hrep = uar_ldapsearch(srvrec->hldap,srvrec->hreq,lretval)
       IF ((srvrec->hrep=0))
        CALL echo("uar_LDAPSearch() Failed!!")
        SET failed = exe_error
        SET table_name = "uar_LDAPSearch()"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = "ErrMsg :: uar_LDAPSearch() Failed!!"
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
       IF (lloglevel > 1)
        CALL uar_sisrvdump(srvrec->hrep)
       ENDIF
       SET srvrec->hrepstruct = uar_srvgetstruct(srvrec->hrep,"reply")
       FOR (li = 0 TO (uar_srvgetitemcount(srvrec->hrepstruct,"entry") - 1))
         CALL echo(build("lI:",li))
         SET hentry = uar_srvgetitem(srvrec->hrepstruct,"entry",li)
         FOR (lj = 0 TO (uar_srvgetitemcount(hentry,"attribute") - 1))
           CALL echo(build("lJ:",lj))
           SET hattrib = uar_srvgetitem(hentry,"attribute",lj)
           SET sattrib = cnvtupper(uar_srvgetstringptr(hattrib,"name"))
           IF (((sattrib="CERNERORGANIZATIONID") OR (sattrib="CERNERORGANIZATIONNAME")) )
            FOR (lk = 0 TO (uar_srvgetitemcount(hattrib,"value") - 1))
              CALL echo(build("lK:",lk))
              SET hvalue = uar_srvgetitem(hattrib,"value",lk)
              CASE (sattrib)
               OF "CERNERORGANIZATIONID":
                SET ncpdprec->qual[lidx2].pharmacy_identifier = substring(1,uar_srvgetlong(hvalue,
                  "bv_len"),uar_srvgetasisptr(hvalue,"bv_val"))
               OF "CERNERORGANIZATIONNAME":
                SET ncpdprec->qual[lidx2].pharmacy_name = substring(1,uar_srvgetlong(hvalue,"bv_len"),
                 uar_srvgetasisptr(hvalue,"bv_val"))
              ENDCASE
            ENDFOR
           ENDIF
         ENDFOR
       ENDFOR
       CALL uar_srvdestroyinstance(srvrec->hrep)
      ENDIF
      SET holdrec->qual[lidx].pharmacy_identifier = ncpdprec->qual[lidx2].pharmacy_identifier
      SET holdrec->qual[lidx].pharmacy_name = ncpdprec->qual[lidx2].pharmacy_name
    ENDFOR
    IF (lloglevel > 1)
     CALL echorecord(ncpdprec)
     CALL echorecord(holdrec)
    ENDIF
    CALL echo("***")
    CALL echo("***   Update GS_MED_CLAIM")
    CALL echo("***")
    UPDATE  FROM gs_med_claim g,
      (dummyt d  WITH seq = value(holdrec->qual_cnt))
     SET g.pharmacy_name = holdrec->qual[d.seq].pharmacy_name, g.pharmacy_identifier = holdrec->qual[
      d.seq].pharmacy_identifier, g.updt_cnt = (g.updt_cnt+ 1),
      g.updt_dt_tm = cnvtdatetime(dtcurrent)
     PLAN (d
      WHERE size(holdrec->qual[d.seq].pharmacy_name) > 0)
      JOIN (g
      WHERE (g.gs_med_claim_id=holdrec->qual[d.seq].gs_med_claim_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "GS_MED_CLAIM"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GS_MED_CLAIM :: Update Error :: Alias :: ",trim(
       serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    SET lavgsec = 0
    SET litcount = (litcount+ 1)
    SET dtitend = cnvtdatetime(curdate,curtime3)
    IF ((holdrec->qual_cnt > 0))
     SET lavgsec = (cnvtreal(holdrec->qual_cnt)/ datetimediff(dtitend,dtitstart,5))
    ENDIF
    IF (lavgsec > 0)
     SET dtestcompletion = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((dbatchendid - dendid)+ 1)
          )/ lavgsec))),",S"),dtitend)
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_task t
     SET t.iteration_start_id = dstartid, t.iteration_end_id = dendid, t.iteration_count = litcount,
      t.iteration_start_dt_tm = cnvtdatetime(dtitstart), t.iteration_end_dt_tm = cnvtdatetime(dtitend
       ), t.iteration_average = lavgsec,
      t.est_completion_dt_tm = cnvtdatetime(dtestcompletion), t.updt_cnt = (t.updt_cnt+ 1), t
      .updt_dt_tm = cnvtdatetime(dtcurrent)
     PLAN (t
      WHERE t.ags_task_id=dtaskid)
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "UPDATE ITERATION"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("UPDATE ITERATION :: Update Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
    COMMIT
    SELECT INTO "nl:"
     FROM ags_task t
     WHERE t.ags_task_id=dtaskid
     DETAIL
      lkillind = t.kill_ind
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET KILL_IND"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("GET KILL_IND :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_knt].smsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET dstartid = (dendid+ 1)
   IF (((dstartid+ lbatchsize) > dbatchendid))
    SET dendid = dbatchendid
   ELSE
    SET dendid = ((dstartid+ lbatchsize) - 1)
   ENDIF
   SET dt1e = curtime3
   CALL echo(build("HCnt:",holdrec->qual_cnt))
   CALL echo(build("dT1b:",dt1b))
   CALL echo(build("dT1e:",dt1e))
 ENDWHILE
 IF (dtaskid > 0)
  CALL echo("Update Task Status")
  UPDATE  FROM ags_task t
   SET t.status =
    IF (lkillind > 0) "WAITING"
    ELSE "COMPLETE"
    ENDIF
    , t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_end_dt_tm = cnvtdatetime(curdate,curtime3),
    t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(dtcurrent)
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"CurQual :: ",cnvtint(
     curqual))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE create_srvhandles(dummy)
   CALL echo("Begin Create_SrvHandles()")
   SET srvrec->hmessage = uar_srvselectmessage(4299510)
   IF ((srvrec->hmessage=0))
    CALL echo("uar_SrvSelectMessage() Failed!!")
    RETURN(0)
   ENDIF
   SET srvrec->hreq = uar_srvcreaterequest(srvrec->hmessage)
   IF ((srvrec->hreq=0))
    CALL echo("uar_SrvCreateRequest() Failed!!")
    RETURN(0)
   ENDIF
   SET srvrec->hreqstruct = uar_srvgetstruct(srvrec->hreq,"request")
   IF ((srvrec->hreqstruct=0))
    CALL echo("uar_SrvGetStruct() Failed!!")
    RETURN(0)
   ENDIF
   CALL echo("End Create_SrvHandles()")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE destroy_srvhandles(dummy1)
   CALL echo("Begin Destroy_SrvHandles()")
   IF (srvrec->hreq)
    CALL uar_srvdestroyinstance(srvrec->hreq)
   ENDIF
   IF (srvrec->hrep)
    CALL uar_srvdestroyinstance(srvrec->hrep)
   ENDIF
   CALL echo("End Destroy_SrvHandles()")
   RETURN(1)
 END ;Subroutine
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (exe_idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[exe_idx].smsgtype,"#######")," :: ",
           format(log->qual[exe_idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[
            exe_idx].smsg))))
        IF ((exe_idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((exe_idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("sf3151")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
#exit_script
 CALL destroy_srvhandles(0)
 IF (srvrec->hldap)
  CALL uar_ldapunbind(srvrec->hldap)
 ENDIF
 IF (failed != false)
  ROLLBACK
  CALL echorecord(log)
  IF (dtaskid > 0)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=dtaskid)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_MEDS_LOAD_PHARM_FIX"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 CALL echo("<===== AGS_MEDS_LOAD_PHARM_FIX End =====>")
END GO
