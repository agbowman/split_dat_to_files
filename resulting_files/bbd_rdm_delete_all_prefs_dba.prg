CREATE PROGRAM bbd_rdm_delete_all_prefs:dba
 DECLARE sreadme_name = c25 WITH constant("bbd_rdm_delete_all_prefs")
 DECLARE question_code_set = i4 WITH protect, constant(1660)
 DECLARE failed_ind = i2 WITH noconstant(0)
 DECLARE inactive_status_cd = f8 WITH noconstant(0.0)
 DECLARE donor_module_cd = f8 WITH noconstant(0.0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE msg = c132 WITH noconstant(fillstring(132," "))
 DECLARE serrormsg = c255 WITH noconstant(fillstring(255," "))
 DECLARE pathnet_bbt = c11 WITH constant("PATHNET_BBT")
 DECLARE delete_all_prefs = c16 WITH constant("DELETE_ALL_PREFS")
 SET nerrorstatus = error(serrormsg,1)
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE SET dm_post_event_code
 RECORD dm_post_event_code(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 EXECUTE gm_code_value0619_def "U"
 DECLARE gm_u_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 DECLARE gm_u_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) = i2
 SUBROUTINE gm_u_code_value0619_f8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_value":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_valuef = 1
     SET gm_u_code_value0619_req->qual[iqual].code_value = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_valuew = 1
     ENDIF
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_type_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_type_cdw = 1
     ENDIF
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_cdw = 1
     ENDIF
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_prsnl_idw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_i2(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_indf = 2
     ELSE
      SET gm_u_code_value0619_req->active_indf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_i4(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_set":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_setf = 1
     SET gm_u_code_value0619_req->qual[iqual].code_set = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_setw = 1
     ENDIF
    OF "collation_seq":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->collation_seqf = 2
     ELSE
      SET gm_u_code_value0619_req->collation_seqf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].collation_seq = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->collation_seqw = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_cntf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_dq8(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->active_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmw = 1
     ENDIF
    OF "inactive_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->inactive_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_dt_tmw = 1
     ENDIF
    OF "begin_effective_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->end_effective_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->end_effective_dt_tmw = 1
     ENDIF
    OF "data_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->data_status_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE gm_u_code_value0619_vc(icol_name,ival,iqual,null_ind,wq_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningf = 2
     ELSE
      SET gm_u_code_value0619_req->cdf_meaningf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].cdf_meaning = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningw = 1
     ENDIF
    OF "display":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->displayf = 2
     ELSE
      SET gm_u_code_value0619_req->displayf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].display = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->displayw = 1
     ENDIF
    OF "display_key":
     SET gm_u_code_value0619_req->qual[iqual].display_key = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->display_keyw = 1
     ENDIF
    OF "description":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->descriptionf = 2
     ELSE
      SET gm_u_code_value0619_req->descriptionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].description = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->descriptionw = 1
     ENDIF
    OF "definition":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->definitionf = 2
     ELSE
      SET gm_u_code_value0619_req->definitionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].definition = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->definitionw = 1
     ENDIF
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->ckif = 1
     SET gm_u_code_value0619_req->qual[iqual].cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->ckiw = 1
     ENDIF
    OF "concept_cki":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->concept_ckif = 2
     ELSE
      SET gm_u_code_value0619_req->concept_ckif = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].concept_cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->concept_ckiw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 DECLARE g_dcodevalue = f8
 DECLARE __slogfilename = c30
 DECLARE e_dispmsg = i2
 DECLARE e_rdmstatus = i2
 DECLARE e_logtofile = i2
 DECLARE e_insertatstart = i2
 DECLARE e_insertbefore = i2
 DECLARE e_insertafter = i2
 DECLARE e_insertatend = i2
 SET e_insertatstart = 1
 SET e_insertbefore = 2
 SET e_insertafter = 3
 SET e_insertatend = 4
 SET e_dispmsg = 1
 SET e_rdmstatus = 2
 SET e_logtofile = 4
 RECORD recwordwrap(
   1 stempline = vc
   1 nlines = i4
   1 nmaxlng = i4
   1 qual[*]
     2 sline = vc
 )
 RECORD recstatus(
   1 sstatuschar = c1
   1 sstatusmsg = vc
 )
 SUBROUTINE __displaymsg(sstring)
   DECLARE nidx = i4
   CALL word_wrap(sstring,70)
   SET sborder = substring(1,value((recwordwrap->nmaxlng+ 6)),fillstring(130,"*"))
   SET slinetmp = fillstring(70," ")
   SET slinemsg = substring(1,value(recwordwrap->nmaxlng),slinetmp)
   CALL echo(sborder)
   FOR (nidx = 1 TO recwordwrap->nlines)
     SET slinemsg = recwordwrap->qual[nidx].sline
     SET slinemsg2 = concat("**|",slinemsg,"|**")
     CALL echo(slinemsg2)
   ENDFOR
   CALL echo(sborder)
 END ;Subroutine
 SUBROUTINE logmsg(smsg,nlog)
   DECLARE ssavemsg = vc WITH noconstant(""), private
   DECLARE ssavestatus = vc WITH noconstant(""), private
   CASE (nlog)
    OF 1:
     CALL __displaymsg(smsg)
    OF 2:
     SET ssavemsg = readme_data->message
     SET ssavestatus = readme_data->status
     SET readme_data->message = smsg
     SET readme_data->status = ""
     EXECUTE dm_readme_status
     SET readme_data->message = ssavemsg
     SET readme_data->status = ssavestatus
    OF 3:
     CALL __displaymsg(smsg)
     SET ssavemsg = readme_data->message
     SET ssavestatus = readme_data->status
     SET readme_data->message = smsg
     SET readme_data->status = ""
     EXECUTE dm_readme_status
     SET readme_data->message = ssavemsg
     SET readme_data->status = ssavestatus
    OF 4:
     CALL __logtofile(smsg,1)
    OF 5:
     CALL __displaymsg(smsg)
     CALL __logtofile(smsg,1)
    OF 6:
     SET ssavemsg = readme_data->message
     SET ssavestatus = readme_data->status
     SET readme_data->message = smsg
     SET readme_data->status = ""
     EXECUTE dm_readme_status
     SET readme_data->message = ssavemsg
     SET readme_data->status = ssavestatus
     CALL __logtofile(smsg,1)
    OF 7:
     CALL __displaymsg(smsg)
     SET ssavemsg = readme_data->message
     SET ssavestatus = readme_data->status
     SET readme_data->message = smsg
     SET readme_data->status = ""
     EXECUTE dm_readme_status
     SET readme_data->message = ssavemsg
     SET readme_data->status = ssavestatus
     CALL __logtofile(smsg,1)
    ELSE
     CALL __logtofile(build("ERROR - BAD nLOG:[",nlog,"]... for Message:",smsg))
   ENDCASE
 END ;Subroutine
 SUBROUTINE logsetstatus(smsg,sstatus)
   SET recstatus->sstatuschar = sstatus
   SET recstatus->sstatusmsg = smsg
   SET readme_data->message = smsg
   SET readme_data->status = sstatus
   CALL logmsg(build("[Status:",sstatus,"]--",smsg),e_logtofile)
 END ;Subroutine
 SUBROUTINE logstatus(smsg,sstatus)
   SET recstatus->sstatuschar = sstatus
   SET recstatus->sstatusmsg = smsg
   SET readme_data->message = smsg
   SET readme_data->status = sstatus
   EXECUTE dm_readme_status
   CALL logmsg(build("[Status:",sstatus,"]--",smsg),e_logtofile)
 END ;Subroutine
 SUBROUTINE logscriptstart(sscriptname)
   SET __slogfilename = build("cer_log:",sscriptname,".log")
   SET sdate = build("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME;;d"),"]")
   CALL logmsg(build("SCRIPT_START (",sscriptname,") - ",sdate,"..."),e_dispmsg)
   CALL __logtofile(build("SCRIPT_START (",sscriptname,") - ",sdate,"..."),0)
   CALL logsetstatus(build("Readme Failed: Starting ->",sscriptname),"F")
 END ;Subroutine
 SUBROUTINE logscriptend(sscriptname)
   SET sdate = build("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME;;d"),"]")
   CALL logmsg(build("SCRIPT_END (",sscriptname,") - ",sdate,"."),(e_dispmsg+ e_logtofile))
   CALL logstatus(recstatus->sstatusmsg,recstatus->sstatuschar)
   CALL echorecord(readme_data)
 END ;Subroutine
 SUBROUTINE __logtofile(smsg,bappend)
   CALL word_wrap(smsg,65)
   SET time_stamp = format(curtime3,"hh:mm:ss;3;m")
   DECLARE nidx = i4
   IF ((recwordwrap->nlines > 0))
    FOR (nidx = 1 TO recwordwrap->nlines)
     SET recwordwrap->stempline = trim(recwordwrap->qual[nidx].sline)
     IF (bappend=1)
      SELECT INTO value(__slogfilename)
       FROM (dummyt d  WITH seq = 1)
       DETAIL
        IF (nidx=1)
         col 1, time_stamp
        ENDIF
        col 15, recwordwrap->stempline
       WITH nocounter, append, noheading
      ;end select
     ELSE
      SELECT INTO value(__slogfilename)
       FROM (dummyt d  WITH seq = 1)
       DETAIL
        IF (nidx=1)
         col 1, time_stamp
        ENDIF
        col 15, recwordwrap->stempline
       WITH nocounter, noheading
      ;end select
      SET bappend = 1
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE addreqproc(nrequest,nsequence,spfmt,ntargetreq,ndeststep,sservice,nreprocess)
   INSERT  FROM request_processing rp
    SET rp.request_number = nrequest, rp.sequence = nsequence, rp.format_script = spfmt,
     rp.target_request_number = ntargetreq, rp.destination_step_id = ndeststep, rp.service = sservice,
     rp.reprocess_reply_ind = nreprocess, rp.active_ind = 1, rp.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     rp.updt_id = reqinfo->updt_id, rp.updt_task = reqinfo->updt_task, rp.updt_cnt = 0,
     rp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE chgreqproc(nrequest,soldpfmt,snewpfmt,ntargetreq,ndeststep,sservice,nreprocess)
   UPDATE  FROM request_processing rp
    SET rp.request_number = nrequest, rp.format_script = snewpfmt, rp.target_request_number =
     ntargetreq,
     rp.destination_step_id = ndeststep, rp.service = sservice, rp.reprocess_reply_ind = nreprocess,
     rp.active_ind = 1, rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_id = reqinfo->updt_id,
     rp.updt_task = reqinfo->updt_task, rp.updt_cnt = (rp.updt_cnt+ 1), rp.updt_applctx = reqinfo->
     updt_applctx
    WHERE rp.request_number=nrequest
     AND rp.format_script=soldpfmt
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE delreqproc(nrequest,spfmt)
   IF (spfmt="#")
    DELETE  FROM request_processing rp
     WHERE rp.request_number=nrequest
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM request_processing rp
     WHERE rp.request_number=nrequest
      AND rp.format_script=spfmt
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE cs_update_display(code_set,cdf_meaning,display,new_display)
   DECLARE cd_cnt = i4 WITH protect, noconstant(0)
   EXECUTE gm_code_value0619_def "U"
   RECORD reccd(
     1 qual[*]
       2 code_value = f8
   )
   SELECT
    IF (cdf_meaning="NULL"
     AND display="NULL")
     WHERE c.code_set=value(code_set)
      AND c.cdf_meaning=null
      AND c.display=null
    ELSEIF (cdf_meaning="NULL")
     WHERE c.code_set=value(code_set)
      AND c.cdf_meaning=null
      AND c.display=display
    ELSEIF (display="NULL")
     WHERE c.code_set=value(code_set)
      AND c.cdf_meaning=cdf_meaning
      AND c.display=null
    ELSE
     WHERE c.code_set=value(code_set)
      AND c.cdf_meaning=cdf_meaning
      AND c.display=display
    ENDIF
    INTO "nl:"
    FROM code_value c
    HEAD REPORT
     cd_cnt = 0
    DETAIL
     cd_cnt = (cd_cnt+ 1)
     IF (cd_cnt > size(reccd->qual,5))
      stat = alterlist(reccd->qual,(cd_cnt+ 9))
     ENDIF
     reccd->qual[cd_cnt].code_value = c.code_value
    FOOT REPORT
     stat = alterlist(reccd->qual,cd_cnt)
    WITH nocounter
   ;end select
   IF (cd_cnt > 0)
    SET gm_u_code_value0619_req->allow_partial_ind = 0
    SET gm_u_code_value0619_req->force_updt_ind = 1
    FOR (cd_cnt = 1 TO size(reccd->qual,5))
     SET stat = gm_u_code_value0619_f8("CODE_VALUE",reccd->qual[cd_cnt].code_value,cd_cnt,0,1)
     IF (stat=1)
      SET stat = gm_u_code_value0619_vc("DISPLAY",new_display,cd_cnt,0,0)
     ENDIF
    ENDFOR
    IF (stat=1)
     EXECUTE gm_u_code_value0619_nouar  WITH replace("REQUEST","GM_U_CODE_VALUE0619_REQ"), replace(
      "REPLY","GM_U_CODE_VALUE0619_REP")
    ENDIF
    IF ((gm_u_code_value0619_rep->status_data.status="S")
     AND (reqinfo->commit_ind=1))
     COMMIT
    ELSE
     ROLLBACK
     CALL logmsg(build("Update of Code_Value table failed for code set:",code_set),e_logtofile)
    ENDIF
   ENDIF
   FREE RECORD reccd
   FREE RECORD gm_u_code_value0619_req
   FREE RECORD gm_u_code_value0619_rep
 END ;Subroutine
 SUBROUTINE stamp_app(app_number)
   EXECUTE dm_ocd_upd_atr "APPLICATION", app_number
 END ;Subroutine
 SUBROUTINE stamp_task(task_number)
   EXECUTE dm_ocd_upd_atr "TASK", task_number
 END ;Subroutine
 SUBROUTINE stamp_req(req_number)
   EXECUTE dm_ocd_upd_atr "REQUEST", req_number
 END ;Subroutine
 SUBROUTINE word_wrap(smsg,nwraplength)
   SET recwordwrap->nlines = 0
   SET recwordwrap->nmaxlng = 0
   SET stat = alterlist(recwordwrap->qual,0)
   DECLARE nstrlen = i4
   DECLARE nendoffset = i4
   DECLARE nstartoffset = i4
   DECLARE noffset = i4
   DECLARE nreverseoffset = i4
   DECLARE nmaxlength = i4
   SET smsg = trim(smsg)
   SET nmaxlength = 0
   SET nstrlen = size(smsg,1)
   SET nstartoffset = 1
   IF (nstrlen <= nwraplength)
    SET nendoffset = nstrlen
   ELSE
    SET nendoffset = nwraplength
   ENDIF
   SET recwordwrap->nlines = 0
   WHILE (nendoffset < nstrlen)
     SET recwordwrap->nlines = (recwordwrap->nlines+ 1)
     SET stat = alterlist(recwordwrap->qual,recwordwrap->nlines)
     IF (substring(nendoffset,1,smsg) != " ")
      FOR (noffset = nstartoffset TO nendoffset)
       SET nreverseoffset = (nendoffset - (noffset - nstartoffset))
       IF (substring(nreverseoffset,1,smsg)=" ")
        SET noffset = nendoffset
        SET nendoffset = nreverseoffset
       ENDIF
      ENDFOR
     ENDIF
     SET recwordwrap->qual[recwordwrap->nlines].sline = substring(nstartoffset,((nendoffset -
      nstartoffset)+ 1),smsg)
     IF (nmaxlength < size(recwordwrap->qual[recwordwrap->nlines].sline,1))
      SET nmaxlength = size(recwordwrap->qual[recwordwrap->nlines].sline,1)
     ENDIF
     SET nstartoffset = (nendoffset+ 1)
     SET nendoffset = (nendoffset+ nwraplength)
   ENDWHILE
   IF (nendoffset >= nstrlen)
    SET nendoffset = nstrlen
    SET recwordwrap->nlines = (recwordwrap->nlines+ 1)
    SET stat = alterlist(recwordwrap->qual,recwordwrap->nlines)
    SET recwordwrap->qual[recwordwrap->nlines].sline = substring(nstartoffset,((nendoffset -
     nstartoffset)+ 1),smsg)
    IF (nmaxlength < size(recwordwrap->qual[recwordwrap->nlines].sline,1))
     SET nmaxlength = size(recwordwrap->qual[recwordwrap->nlines].sline,1)
    ENDIF
   ENDIF
   SET recwordwrap->nmaxlng = nmaxlength
 END ;Subroutine
 DECLARE get_cd_for_cdf(ncodeset,scdf) = f8
 SUBROUTINE get_cd_for_cdf(ncodeset,scdf)
   DECLARE cdf_meaning = c12
   DECLARE code_set = i4
   DECLARE code_value = f8
   SET code_value = 0.0
   SET code_set = ncodeset
   SET cdf_meaning = scdf
   EXECUTE cpm_get_cd_for_cdf
   SET g_dcodevalue = code_value
   RETURN(g_dcodevalue)
 END ;Subroutine
 SUBROUTINE post_event_code(seventsetname,seventsetdisp,seventsetdesc,seventsetdef,sstatus,sformat,
  sstorage,seventclass,seventconflvl,seventsubclass,seventcdstatus,deventcd,dparentcd,dflex1cd,
  dflex2cd,dflex3cd,dflex4cd,flex5cd)
   SET dm_post_event_code->event_set_name = seventsetname
   SET dm_post_event_code->event_cd_disp = seventsetdisp
   SET dm_post_event_code->event_cd_descr = seventsetdesc
   SET dm_post_event_code->event_cd_definition = seventsetdef
   SET dm_post_event_code->status = sstatus
   SET dm_post_event_code->format = sformat
   SET dm_post_event_code->storage = sstorage
   SET dm_post_event_code->event_class = seventclass
   SET dm_post_event_code->event_confid_level = seventconflvl
   SET dm_post_event_code->event_subclass = seventsubclass
   SET dm_post_event_code->event_code_status = seventcdstatus
   SET dm_post_event_code->event_cd = deventcd
   SET dm_post_event_code->parent_cd = dparentcd
   SET dm_post_event_code->flex1_cd = dflex1cd
   SET dm_post_event_code->flex2_cd = dflex2cd
   SET dm_post_event_code->flex3_cd = dflex3cd
   SET dm_post_event_code->flex4_cd = dflex4cd
   SET dm_post_event_code->flex5_cd = dflex5cd
   EXECUTE dm_post_event_code
 END ;Subroutine
 DECLARE findreqproc(nrequest,spfmt,nseq) = i4
 SUBROUTINE findreqproc(nrequest,spfmt,nseq)
   DECLARE ntempseq = i4
   SET ntempseq = 0
   SELECT INTO "NL:"
    FROM request_processing rp
    WHERE rp.request_number=nrequest
     AND rp.format_script=spfmt
     AND rp.sequence > nseq
    DETAIL
     IF (ntempseq=0)
      ntempseq = rp.sequence
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ntempseq)
 END ;Subroutine
 SUBROUTINE insertreqproc(nrequest,spfmt,ntargetreq,ndeststep,sservice,nreprocess,naction,srefpfmt,
  nseq)
   DECLARE nidx = i4
   DECLARE nidx2 = i4
   FREE SET recpfmt
   RECORD recpfmt(
     1 ncnt = i4
     1 qual[*]
       2 nrequest = i4
       2 spfmt = vc
       2 nseq = i4
   )
   SET recpfmt->ncnt = 0
   SELECT INTO "NL:"
    FROM request_processing rp
    WHERE rp.request_number=nrequest
    ORDER BY rp.sequence
    DETAIL
     recpfmt->ncnt = (recpfmt->ncnt+ 1), stat = alterlist(recpfmt->qual,recpfmt->ncnt), recpfmt->
     qual[recpfmt->ncnt].nrequest = rp.request_number,
     recpfmt->qual[recpfmt->ncnt].spfmt = rp.format_script, recpfmt->qual[recpfmt->ncnt].nseq = rp
     .sequence
    WITH nocounter
   ;end select
   CASE (naction)
    OF e_insertatstart:
     SET nidx = 0
     FOR (nidx = 1 TO recpfmt->ncnt)
       UPDATE  FROM request_processing rp
        SET rp.sequence = (recpfmt->qual[nidx].nseq+ 1)
        WHERE (rp.request_number=recpfmt->qual[nidx].nrequest)
         AND (rp.format_script=recpfmt->qual[nidx].spfmt)
         AND (rp.sequence=recpfmt->qual[nidx].nseq)
        WITH nocounter
       ;end update
     ENDFOR
     CALL addrecproc(nrequest,1,spfmt,ntargetreq,ndeststep,
      sservice,nreprocess)
    OF e_insertbefore:
     SET nidx2 = 0
     IF (nseq=0)
      SET nidx = findreqproc(nrequest,spfmt,0)
      IF (nidx=0)
       CALL logmsg(build("INSERT OF Format script:",spfmt," failed because reference script:",
         srefpfmt," was not found."),e_logtofile)
      ELSE
       FOR (nidx2 = nidx TO recpfmt->ncnt)
         UPDATE  FROM request_processing rp
          SET rp.sequence = (recpfmt->qual[nidx2].nseq+ 1)
          WHERE (rp.request_number=recpfmt->qual[nidx2].nrequest)
           AND (rp.format_script=recpfmt->qual[nidx2].spfmt)
           AND (rp.sequence=recpfmt->qual[nidx2].nseq)
         ;end update
       ENDFOR
       CALL addrecproc(nrequest,nidx,spfmt,ntargetreq,ndeststep,
        sservice,nreprocess)
      ENDIF
     ELSE
      SET nidx2 = findrecproc(nrequest,spfmt,(nseq - 1))
      IF (nidx=nidx2)
       FOR (nidx2 = nidx TO recpfmt->ncnt)
         UPDATE  FROM request_processing rp
          SET rp.sequence = (recpfmt->qual[nidx2].nseq+ 1)
          WHERE (rp.request_number=recpfmt->qual[nidx2].nrequest)
           AND (rp.format_script=recpfmt->qual[nidx2].spfmt)
           AND (rp.sequence=recpfmt->qual[nidx2].nseq)
         ;end update
       ENDFOR
       CALL addrecproc(nrequest,nidx,spfmt,ntargetreq,ndeststep,
        sservice,nreprocess)
      ELSE
       CALL logmsg(build("INSERT of format script:",spfmt," failed because reference nSEQ:",nseq,
         " did not match reference script: ",
         srefpfmt,"."),e_logtofile)
      ENDIF
     ENDIF
    OF e_insertafter:
     SET nidx2 = 0
     IF (nseq=0)
      SET nidx = findreqproc(nrequest,spfmt,0)
      IF (nidx=0)
       CALL logmsg(build("INSERT OF Format script:",spfmt," failed because reference script:",
         srefpfmt," was not found."),e_logtofile)
      ELSE
       IF ((nidx < recpfmt->ncnt))
        SET nidx = (nidx+ 1)
        FOR (nidx2 = nidx TO recpfmt->ncnt)
          UPDATE  FROM request_processing rp
           SET rp.sequence = (recpfmt->qual[nidx2].nseq+ 1)
           WHERE (rp.request_number=recpfmt->qual[nidx2].nrequest)
            AND (rp.format_script=recpfmt->qual[nidx2].spfmt)
            AND (rp.sequence=recpfmt->qual[nidx2].nseq)
          ;end update
        ENDFOR
       ELSE
        SET nidx = (nidx+ 1)
       ENDIF
       CALL addrecproc(nrequest,nidx,spfmt,ntargetreq,ndeststep,
        sservice,nreprocess)
      ENDIF
     ELSE
      SET nidx2 = findrecproc(nrequest,spfmt,(nseq - 1))
      IF (nidx=nidx2)
       IF ((nidx < recpfmt->ncnt))
        SET nidx = (nidx+ 1)
        FOR (nidx2 = nidx TO recpfmt->ncnt)
          UPDATE  FROM request_processing rp
           SET rp.sequence = (recpfmt->qual[nidx2].nseq+ 1)
           WHERE (rp.request_number=recpfmt->qual[nidx2].nrequest)
            AND (rp.format_script=recpfmt->qual[nidx2].spfmt)
            AND (rp.sequence=recpfmt->qual[nidx2].nseq)
          ;end update
        ENDFOR
       ELSE
        SET nidx = (nidx+ 1)
       ENDIF
       CALL addrecproc(nrequest,nidx,spfmt,ntargetreq,ndeststep,
        sservice,nreprocess)
      ELSE
       CALL logmsg(build("INSERT of format script:",spfmt," failed because reference nSEQ:",nseq,
         " did not match reference script: ",
         srefpfmt,"."),e_logtofile)
      ENDIF
     ENDIF
    OF e_insertatend:
     SET nidx = (recpfmt->qual[recpfmt->ncnt].nseq+ 1)
     CALL addrecproc(nrequest,nidx,spfmt,ntargetreq,ndeststep,
      sservice,nreprocess)
   ENDCASE
 END ;Subroutine
#start_script
 CALL logscriptstart(sreadme_name)
 SELECT INTO "nl:"
  FROM dm_info dm
  WHERE dm.info_domain=pathnet_bbt
   AND dm.info_name=delete_all_prefs
  WITH nocounter
 ;end select
 IF (curqual=0)
  RECORD dependency(
    1 question_dependencies[*]
      2 question_cd = f8
  )
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="INACTIVE"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    inactive_status_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed_ind = 1
   SET msg = "Missing required code value for cdf_meaning = INACTIVE on code set 48"
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=question_code_set
     AND cv.cdf_meaning="BB DONOR"
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    donor_module_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed_ind = 1
   SET msg = "Missing required code value for cdf_meaning = BB DONOR on code set 1660"
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   qd.question_cd
   FROM question q,
    question_dependency qd
   PLAN (q
    WHERE q.module_cd=donor_module_cd)
    JOIN (qd
    WHERE qd.question_cd=q.question_cd)
   HEAD REPORT
    stat = alterlist(dependency->question_dependencies,3)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,3)=1)
     stat = alterlist(dependency->question_dependencies,(cnt+ 2))
    ENDIF
    dependency->question_dependencies[cnt].question_cd = qd.question_cd
   FOOT REPORT
    stat = alterlist(dependency->question_dependencies,cnt)
   WITH nocounter
  ;end select
  IF (cnt > 0)
   FOR (index = 1 TO cnt)
     DELETE  FROM question_dependency qd
      SET qd.seq = 1
      WHERE (qd.question_cd=dependency->question_dependencies[index].question_cd)
      WITH nocounter
     ;end delete
     SET serror_check = error(serrormsg,0)
     IF (nerrorstatus != 0)
      SET failed_ind = 1
      SET msg = "Could not delete question dependencies from the QUESTION_DEPENDENCY table."
      CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
      GO TO exit_script
     ENDIF
   ENDFOR
  ENDIF
  DELETE  FROM dependency d
   SET d.seq = 1
   WHERE d.module_cd=donor_module_cd
   WITH nocounter
  ;end delete
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg = "Could not delete dependencies from the DEPENDENCY table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  DELETE  FROM valid_response vr
   SET vr.seq = 1
   WHERE vr.module_cd=donor_module_cd
   WITH nocounter
  ;end delete
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg = "Could not delete questions from the VALID_RESPONSE table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  DELETE  FROM answer a
   SET a.seq = 1
   WHERE a.module_cd=donor_module_cd
   WITH nocounter
  ;end delete
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg = "Could not delete answers from the ANSWER table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  DELETE  FROM question q
   SET q.seq = 1
   WHERE q.module_cd=donor_module_cd
   WITH nocounter
  ;end delete
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg = "Could not delete questions from the QUESTION table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  UPDATE  FROM code_value c
   SET c.active_ind = 0, c.active_type_cd = inactive_status_cd, c.active_dt_tm = null,
    c.inactive_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    c.updt_id = 0,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 0, c.updt_applctx = 0
   WHERE c.code_set=1661
    AND c.cdf_meaning IN ("BBDDFLSPECS", "BBDDRIVERLIC", "BBDSPECIES", "LBLVRGENLIST", "LBLVRPRDDEMO",
   "LBLVRSUCCESS", "BBDSSN", "BBDGENDER", "BBDLAST", "BBDBIRTHDT",
   "BBDFIRST", "LBLVFY CONFS")
   WITH nocounter
  ;end update
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg = "Could not inactivate Donor preference questions in the code_value table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  UPDATE  FROM code_value c
   SET c.active_ind = 0, c.active_type_cd = inactive_status_cd, c.active_dt_tm = null,
    c.inactive_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    c.updt_id = 0,
    c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = 0, c.updt_applctx = 0
   WHERE c.code_set=1662
    AND c.cdf_meaning IN ("DONORSEARCH", "LABELVERIF")
   WITH nocounter
  ;end update
  SET serror_check = error(serrormsg,0)
  IF (nerrorstatus != 0)
   SET failed_ind = 1
   SET msg =
   "Could not inactivate Donor processes DONORSEARCH and LABELVERIF from the code_value table."
   CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
   GO TO exit_script
  ENDIF
  CALL logmsg("Activity Data Update Successful.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  INSERT  FROM dm_info dm
   SET dm.info_domain = pathnet_bbt, dm.info_name = delete_all_prefs, dm.info_date = cnvtdatetime(
     curdate,curtime),
    dm.updt_dt_tm = cnvtdatetime(curdate,curtime)
  ;end insert
  IF (curqual=0)
   SET failed_ind = 1
   SET msg = build("Unable to insert DM_INFO Row.")
   CALL logmsg(smsg,e_dispmsg)
   ROLLBACK
   GO TO exit_script
  ELSE
   SET msg = build("DM_INFO row successfully inserted.")
   CALL logmsg(smsg,e_dispmsg)
   COMMIT
  ENDIF
  CALL echorecord(dependency)
  FREE RECORD dependency
 ELSE
  CALL logmsg("Readme has already been run",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
 ENDIF
#exit_script
 IF (failed_ind=0)
  COMMIT
  CALL logstatus("Execution Successful.","S")
 ELSE
  ROLLBACK
  CALL logstatus("Execution Failed","F")
 ENDIF
 CALL logscriptend(sreadme_name)
END GO
