CREATE PROGRAM bbt_rdm_add_mod_options:dba
 DECLARE sreadme_name = c25 WITH constant("BBT_RDM_ADD_MOD_OPTIONS")
 DECLARE failed_ind = i2 WITH noconstant(0)
 DECLARE active_status_cd = f8 WITH noconstant(0.0)
 DECLARE inactive_status_cd = f8 WITH noconstant(0.0)
 DECLARE pooled_cd = f8 WITH noconstant(0.0)
 DECLARE display_key = vc WITH noconstant(" ")
 DECLARE mo_cnt = i4 WITH noconstant(0)
 DECLARE op_cnt = i4 WITH noconstant(0)
 DECLARE np_cnt = i4 WITH noconstant(0)
 DECLARE mst_cnt = i4 WITH noconstant(0)
 DECLARE md_cnt = i4 WITH noconstant(0)
 DECLARE pn_cnt = i4 WITH noconstant(0)
 DECLARE p_cnt = i4 WITH noconstant(0)
 DECLARE e_cnt = i4 WITH noconstant(0)
 DECLARE m_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE next_code = f8 WITH noconstant(0.0)
 DECLARE msg = c132 WITH noconstant(fillstring(132," "))
 DECLARE version_nbr = i4 WITH noconstant(0)
 DECLARE key_unique_ind = i2 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE hold_billitem_id = f8 WITH protect, noconstant(0.0)
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
 FREE RECORD mod
 FREE RECORD pool
 FREE RECORD modification_table
 RECORD mod(
   1 options[*]
     2 option_id = f8
     2 new_option_id = f8
     2 display = vc
     2 display_key = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 new_product_ind = i2
     2 split_ind = i2
     2 ad_hoc_ind = i2
     2 change_attribute_ind = i2
     2 crossover_ind = i2
     2 pool_product_ind = i2
     2 generate_prod_nbr_ind = i2
     2 prod_nbr_prefix = c10
     2 prod_nbr_ccyy_ind = i2
     2 prod_nbr_starting_nbr = i4
     2 dispose_orig_ind = i2
     2 chg_orig_exp_dt_ind = i2
     2 orig_nbr_days_exp = f8
     2 orig_nbr_hrs_exp = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 orig_prods[*]
       3 orig_product_cd = f8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
     2 new_prods[*]
       3 mod_new_prod_id = f8
       3 orig_product_cd = f8
       3 new_product_cd = f8
       3 quantity = f8
       3 default_sub_id_flag = i2
       3 max_prep_hrs = f8
       3 default_orig_exp_ind = i2
       3 calc_exp_drawn_ind = i2
       3 default_exp_days = f8
       3 default_exp_hrs = f8
       3 allow_extend_exp_ind = i2
       3 default_orig_vol_ind = i2
       3 default_volume = f8
       3 calc_vol_ind = i2
       3 prompt_vol_ind = i2
       3 validate_vol_ind = i2
       3 default_unit_of_meas_cd = f8
       3 synonym_id = f8
       3 require_assign_ind = i2
       3 bag_type_cd = f8
       3 crossover_reason_cd = f8
       3 allow_no_aborh_ind = i2
       3 default_supplier_id = f8
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 spec_testings[*]
         4 special_testing_cd = f8
         4 updt_cnt = i4
         4 updt_dt_tm = dq8
         4 updt_id = f8
     2 devices[*]
       3 device_type_cd = f8
       3 default_ind = i2
       3 max_capacity = i2
       3 start_stop_time_ind = i2
       3 modification_duration = i2
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
     2 pool_nbrs[*]
       3 mod_pool_nbr_id = f8
       3 prefix = c10
       3 year = i2
       3 seq_nbr = i4
       3 updt_cnt = i4
       3 updt_dt_tm = dq8
       3 updt_id = f8
 )
 RECORD pool(
   1 products[*]
     2 pooled_product_id = f8
     2 new_option_id = f8
     2 events[*]
       3 product_event_id = f8
       3 product_id = f8
       3 orig_expire_dt_tm = dq8
       3 orig_volume = i4
       3 orig_unit_meas_cd = f8
       3 cur_expire_dt_tm = dq8
 )
 RECORD modification_table(
   1 events[*]
     2 product_event_id = f8
     2 option_id = f8
     2 new_option_id = f8
 )
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   active_status_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed_ind = 1
  SET msg = "Missing required code value for cdf_meaning = ACTIVE on code set 48"
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ENDIF
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
   WHERE cv.code_set=1610
    AND cv.cdf_meaning="17"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   pooled_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed_ind = 1
  SET msg = "Missing required code value for cdf_meaning = 17 on code set 1610"
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ENDIF
 SET mo_cnt = 0
 SELECT INTO "nl:"
  mo.option_id, np.new_product_cd
  FROM modify_option mo,
   new_product np
  PLAN (mo
   WHERE mo.option_id > 0.0
    AND mo.division_type_flag IN (1, 2, 4))
   JOIN (np
   WHERE np.option_id=mo.option_id)
  ORDER BY mo.option_id, np.active_ind DESC
  HEAD REPORT
   np_cnt = 0, migrate_active_np_ind = 0
  HEAD mo.option_id
   mo_cnt = (mo_cnt+ 1)
   IF (mod(mo_cnt,10)=1)
    stat = alterlist(mod->options,(mo_cnt+ 9))
   ENDIF
   mod->options[mo_cnt].option_id = mo.option_id, mod->options[mo_cnt].display = mo.description, mod
   ->options[mo_cnt].display_key = cnvtupper(cnvtalphanum(mo.description))
   IF (mo.active_ind=1)
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99")
   ELSE
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime(mo.updt_dt_tm)
   ENDIF
   mod->options[mo_cnt].new_product_ind = 0, mod->options[mo_cnt].split_ind = 0, mod->options[mo_cnt]
   .change_attribute_ind = 0,
   mod->options[mo_cnt].crossover_ind = 0, mod->options[mo_cnt].pool_product_ind = 0, mod->options[
   mo_cnt].generate_prod_nbr_ind = 0,
   mod->options[mo_cnt].prod_nbr_prefix = fillstring(10," "), mod->options[mo_cnt].prod_nbr_ccyy_ind
    = 0, mod->options[mo_cnt].prod_nbr_starting_nbr = 0,
   mod->options[mo_cnt].dispose_orig_ind = mo.dispose_orig_ind, mod->options[mo_cnt].
   chg_orig_exp_dt_ind = mo.chg_orig_exp_dt_ind, mod->options[mo_cnt].orig_nbr_days_exp = mo
   .orig_nbr_days_exp,
   mod->options[mo_cnt].orig_nbr_hrs_exp = mo.orig_nbr_hrs_exp, mod->options[mo_cnt].active_ind = mo
   .active_ind
   IF (mo.active_ind=1)
    mod->options[mo_cnt].active_status_cd = active_status_cd
   ELSE
    mod->options[mo_cnt].active_status_cd = inactive_status_cd
   ENDIF
   mod->options[mo_cnt].active_status_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
   mo_cnt].active_status_prsnl_id = mo.active_status_prsnl_id, mod->options[mo_cnt].updt_cnt = mo
   .updt_cnt,
   mod->options[mo_cnt].updt_dt_tm = cnvtdatetime(mo.updt_dt_tm), mod->options[mo_cnt].updt_id = mo
   .updt_id, stat = alterlist(mod->options[mo_cnt].orig_prods,1),
   mod->options[mo_cnt].orig_prods[1].orig_product_cd = mo.orig_product_cd, mod->options[mo_cnt].
   orig_prods[1].updt_cnt = 0, mod->options[mo_cnt].orig_prods[1].updt_dt_tm = cnvtdatetime(mo
    .updt_dt_tm),
   mod->options[mo_cnt].orig_prods[1].updt_id = mo.updt_id, np_cnt = 0, migrate_active_np_ind = 0
  DETAIL
   IF (migrate_active_np_ind=0)
    IF (np.active_ind=1)
     migrate_active_np_ind = 1
    ELSE
     migrate_active_np_ind = 0, mod->options[mo_cnt].active_ind = 0, mod->options[mo_cnt].
     active_status_cd = inactive_status_cd
    ENDIF
   ENDIF
   IF (((migrate_active_np_ind=1
    AND np.active_ind=1) OR (migrate_active_np_ind=0
    AND np.active_ind=0)) )
    np_cnt = (np_cnt+ 1)
    IF (mod(np_cnt,10)=1)
     stat = alterlist(mod->options[mo_cnt].new_prods,(np_cnt+ 9))
    ENDIF
    CASE (mo.division_type_flag)
     OF 1:
      IF (np.new_product_cd != mo.orig_product_cd)
       mod->options[mo_cnt].new_product_ind = 1
      ENDIF
      ,
      IF (((np.new_product_cd=mo.orig_product_cd) OR (np_cnt > 1)) )
       mod->options[mo_cnt].split_ind = 1
      ENDIF
     OF 2:
      mod->options[mo_cnt].split_ind = 1
     OF 4:
      mod->options[mo_cnt].crossover_ind = 1
    ENDCASE
    mod->options[mo_cnt].new_prods[np_cnt].orig_product_cd = mo.orig_product_cd, mod->options[mo_cnt]
    .new_prods[np_cnt].new_product_cd = np.new_product_cd, mod->options[mo_cnt].new_prods[np_cnt].
    quantity = np.quantity
    CASE (np.sub_prod_id_flag)
     OF 1:
      mod->options[mo_cnt].new_prods[np_cnt].default_sub_id_flag = 1
     OF 2:
      mod->options[mo_cnt].new_prods[np_cnt].default_sub_id_flag = 2
     OF 3:
      mod->options[mo_cnt].new_prods[np_cnt].default_sub_id_flag = 3
     ELSE
      mod->options[mo_cnt].new_prods[np_cnt].default_sub_id_flag = 0
    ENDCASE
    mod->options[mo_cnt].new_prods[np_cnt].max_prep_hrs = np.max_prep_hrs
    IF (np.default_exp_days=0
     AND np.default_exp_hrs=0)
     mod->options[mo_cnt].new_prods[np_cnt].default_orig_exp_ind = 1
    ELSE
     mod->options[mo_cnt].new_prods[np_cnt].default_orig_exp_ind = 0
    ENDIF
    mod->options[mo_cnt].new_prods[np_cnt].calc_exp_drawn_ind = mo.calc_exp_drawn_ind, mod->options[
    mo_cnt].new_prods[np_cnt].default_exp_days = np.default_exp_days, mod->options[mo_cnt].new_prods[
    np_cnt].default_exp_hrs = np.default_exp_hrs,
    mod->options[mo_cnt].new_prods[np_cnt].allow_extend_exp_ind = mo.allow_extend_exp_ind, mod->
    options[mo_cnt].new_prods[np_cnt].default_orig_vol_ind = np.dflt_orig_volume_ind, mod->options[
    mo_cnt].new_prods[np_cnt].default_volume = np.default_volume,
    mod->options[mo_cnt].new_prods[np_cnt].calc_vol_ind = 0, mod->options[mo_cnt].new_prods[np_cnt].
    prompt_vol_ind = 0, mod->options[mo_cnt].new_prods[np_cnt].validate_vol_ind = mo.validate_vol_ind,
    mod->options[mo_cnt].new_prods[np_cnt].default_unit_of_meas_cd = np.default_unit_measure_cd, mod
    ->options[mo_cnt].new_prods[np_cnt].synonym_id = np.synonym_id, mod->options[mo_cnt].new_prods[
    np_cnt].require_assign_ind = 0,
    mod->options[mo_cnt].new_prods[np_cnt].bag_type_cd = mo.bag_type_cd, mod->options[mo_cnt].
    new_prods[np_cnt].crossover_reason_cd = mo.crossover_reason_cd, mod->options[mo_cnt].new_prods[
    np_cnt].allow_no_aborh_ind = 0,
    mod->options[mo_cnt].new_prods[np_cnt].default_supplier_id = 0.0, mod->options[mo_cnt].new_prods[
    np_cnt].updt_cnt = np.updt_cnt, mod->options[mo_cnt].new_prods[np_cnt].updt_dt_tm = cnvtdatetime(
     np.updt_dt_tm),
    mod->options[mo_cnt].new_prods[np_cnt].updt_id = np.updt_id
   ENDIF
  FOOT  mo.option_id
   stat = alterlist(mod->options[mo_cnt].new_prods,np_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  mo.option_id, mot.new_product_cd, mot.special_testing_cd
  FROM modify_option mo,
   modify_option_testing mot
  PLAN (mo
   WHERE mo.option_id > 0.0
    AND mo.division_type_flag=3)
   JOIN (mot
   WHERE mot.option_id=mo.option_id)
  ORDER BY mo.option_id, mot.active_ind DESC, mot.new_product_cd
  HEAD REPORT
   np_cnt = 0, mst_cnt = 0, migrate_active_np_ind = 0
  HEAD mo.option_id
   mo_cnt = (mo_cnt+ 1)
   IF (mod(mo_cnt,10)=1)
    stat = alterlist(mod->options,(mo_cnt+ 9))
   ENDIF
   mod->options[mo_cnt].option_id = mo.option_id, mod->options[mo_cnt].display = mo.description, mod
   ->options[mo_cnt].display_key = cnvtupper(cnvtalphanum(mo.description))
   IF (mo.active_ind=1)
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99")
   ELSE
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime(mo.updt_dt_tm)
   ENDIF
   mod->options[mo_cnt].new_product_ind = 0, mod->options[mo_cnt].split_ind = 0, mod->options[mo_cnt]
   .change_attribute_ind = 0,
   mod->options[mo_cnt].crossover_ind = 0, mod->options[mo_cnt].pool_product_ind = 0, mod->options[
   mo_cnt].generate_prod_nbr_ind = 0,
   mod->options[mo_cnt].prod_nbr_prefix = fillstring(10," "), mod->options[mo_cnt].prod_nbr_ccyy_ind
    = 0, mod->options[mo_cnt].prod_nbr_starting_nbr = 0,
   mod->options[mo_cnt].dispose_orig_ind = mo.dispose_orig_ind, mod->options[mo_cnt].
   chg_orig_exp_dt_ind = mo.chg_orig_exp_dt_ind, mod->options[mo_cnt].orig_nbr_days_exp = mo
   .orig_nbr_days_exp,
   mod->options[mo_cnt].orig_nbr_hrs_exp = mo.orig_nbr_hrs_exp, mod->options[mo_cnt].active_ind = mo
   .active_ind
   IF (mo.active_ind=1)
    mod->options[mo_cnt].active_status_cd = active_status_cd
   ELSE
    mod->options[mo_cnt].active_status_cd = inactive_status_cd
   ENDIF
   mod->options[mo_cnt].active_status_dt_tm = cnvtdatetime(mo.active_status_dt_tm), mod->options[
   mo_cnt].active_status_prsnl_id = mo.active_status_prsnl_id, mod->options[mo_cnt].updt_cnt = mo
   .updt_cnt,
   mod->options[mo_cnt].updt_dt_tm = cnvtdatetime(mo.updt_dt_tm), mod->options[mo_cnt].updt_id = mo
   .updt_id, stat = alterlist(mod->options[mo_cnt].orig_prods,1),
   mod->options[mo_cnt].orig_prods[1].orig_product_cd = mo.orig_product_cd, mod->options[mo_cnt].
   orig_prods[1].updt_cnt = 0, mod->options[mo_cnt].orig_prods[1].updt_dt_tm = cnvtdatetime(mo
    .updt_dt_tm),
   mod->options[mo_cnt].orig_prods[1].updt_id = mo.updt_id, np_cnt = 0, migrate_active_np_ind = 0
  HEAD mot.new_product_cd
   IF (migrate_active_np_ind=0)
    IF (mot.active_ind=1)
     migrate_active_np_ind = 1
    ELSE
     migrate_active_np_ind = 0, mod->options[mo_cnt].active_ind = 0, mod->options[mo_cnt].
     active_status_cd = inactive_status_cd
    ENDIF
   ENDIF
   IF (((migrate_active_np_ind=1
    AND mot.active_ind=1) OR (migrate_active_np_ind=0
    AND mot.active_ind=0)) )
    np_cnt = (np_cnt+ 1)
    IF (mod(np_cnt,10)=1)
     stat = alterlist(mod->options[mo_cnt].new_prods,(np_cnt+ 9))
    ENDIF
    mod->options[mo_cnt].change_attribute_ind = 1
    IF (mot.new_product_cd != mo.orig_product_cd)
     mod->options[mo_cnt].new_product_ind = 1
    ENDIF
    mod->options[mo_cnt].new_prods[np_cnt].orig_product_cd = mo.orig_product_cd, mod->options[mo_cnt]
    .new_prods[np_cnt].new_product_cd = mot.new_product_cd, mod->options[mo_cnt].new_prods[np_cnt].
    quantity = 1,
    mod->options[mo_cnt].new_prods[np_cnt].default_sub_id_flag = 0, mod->options[mo_cnt].new_prods[
    np_cnt].max_prep_hrs = mot.max_prep_hrs
    IF (mot.default_exp_days=0
     AND mot.default_exp_hrs=0)
     mod->options[mo_cnt].new_prods[np_cnt].default_orig_exp_ind = 1
    ELSE
     mod->options[mo_cnt].new_prods[np_cnt].default_orig_exp_ind = 0
    ENDIF
    mod->options[mo_cnt].new_prods[np_cnt].calc_exp_drawn_ind = mo.calc_exp_drawn_ind, mod->options[
    mo_cnt].new_prods[np_cnt].default_exp_days = mot.default_exp_days, mod->options[mo_cnt].
    new_prods[np_cnt].default_exp_hrs = mot.default_exp_hrs,
    mod->options[mo_cnt].new_prods[np_cnt].allow_extend_exp_ind = mo.allow_extend_exp_ind, mod->
    options[mo_cnt].new_prods[np_cnt].default_orig_vol_ind = 1, mod->options[mo_cnt].new_prods[np_cnt
    ].default_volume = 0,
    mod->options[mo_cnt].new_prods[np_cnt].calc_vol_ind = 0, mod->options[mo_cnt].new_prods[np_cnt].
    prompt_vol_ind = 0, mod->options[mo_cnt].new_prods[np_cnt].validate_vol_ind = mo.validate_vol_ind,
    mod->options[mo_cnt].new_prods[np_cnt].default_unit_of_meas_cd = 0.0, mod->options[mo_cnt].
    new_prods[np_cnt].synonym_id = 0.0, mod->options[mo_cnt].new_prods[np_cnt].require_assign_ind = 0,
    mod->options[mo_cnt].new_prods[np_cnt].bag_type_cd = mo.bag_type_cd, mod->options[mo_cnt].
    new_prods[np_cnt].crossover_reason_cd = 0.0, mod->options[mo_cnt].new_prods[np_cnt].
    allow_no_aborh_ind = 0,
    mod->options[mo_cnt].new_prods[np_cnt].default_supplier_id = 0.0, mod->options[mo_cnt].new_prods[
    np_cnt].updt_cnt = mot.updt_cnt, mod->options[mo_cnt].new_prods[np_cnt].updt_dt_tm = cnvtdatetime
    (mot.updt_dt_tm),
    mod->options[mo_cnt].new_prods[np_cnt].updt_id = mot.updt_id, mst_cnt = 0
   ENDIF
  DETAIL
   IF (((migrate_active_np_ind=1
    AND mot.active_ind=1) OR (migrate_active_np_ind=0
    AND mot.active_ind=0)) )
    mst_cnt = (mst_cnt+ 1)
    IF (mod(mst_cnt,10)=1)
     stat = alterlist(mod->options[mo_cnt].new_prods[np_cnt].spec_testings,(mst_cnt+ 9))
    ENDIF
    mod->options[mo_cnt].new_prods[np_cnt].spec_testings[mst_cnt].special_testing_cd = mot
    .special_testing_cd, mod->options[mo_cnt].new_prods[np_cnt].spec_testings[mst_cnt].updt_cnt = mot
    .updt_cnt, mod->options[mo_cnt].new_prods[np_cnt].spec_testings[mst_cnt].updt_dt_tm =
    cnvtdatetime(mot.updt_dt_tm),
    mod->options[mo_cnt].new_prods[np_cnt].spec_testings[mst_cnt].updt_id = mot.updt_id
   ENDIF
  FOOT  mot.new_product_cd
   IF (mst_cnt > 0)
    stat = alterlist(mod->options[mo_cnt].new_prods[np_cnt].spec_testings,mst_cnt)
   ENDIF
  FOOT  mo.option_id
   stat = alterlist(mod->options[mo_cnt].new_prods,np_cnt)
  WITH nocounter
 ;end select
 IF (mo_cnt=0)
  GO TO load_pool_options
 ENDIF
 SELECT INTO "nl:"
  d.seq, mod.option_device_id
  FROM (dummyt d  WITH seq = value(mo_cnt)),
   modify_option_device mod
  PLAN (d
   WHERE d.seq <= mo_cnt)
   JOIN (mod
   WHERE (mod.option_id=mod->options[d.seq].option_id)
    AND mod.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, md_cnt = 0
  HEAD d.seq
   cnt = d.seq, md_cnt = 0
  DETAIL
   md_cnt = (md_cnt+ 1)
   IF (mod(md_cnt,10)=1)
    stat = alterlist(mod->options[cnt].devices,(md_cnt+ 9))
   ENDIF
   mod->options[cnt].devices[md_cnt].device_type_cd = mod.device_type_cd
   IF (md_cnt=1)
    mod->options[cnt].devices[md_cnt].default_ind = 1
   ELSE
    mod->options[cnt].devices[md_cnt].default_ind = 0
   ENDIF
   mod->options[cnt].devices[md_cnt].max_capacity = mod.nbr_of_device, mod->options[cnt].devices[
   md_cnt].start_stop_time_ind = 0, mod->options[cnt].devices[md_cnt].modification_duration = 0,
   mod->options[cnt].devices[md_cnt].updt_cnt = mod.updt_cnt, mod->options[cnt].devices[md_cnt].
   updt_dt_tm = cnvtdatetime(mod.updt_dt_tm), mod->options[cnt].devices[md_cnt].updt_id = mod.updt_id
  FOOT  d.seq
   stat = alterlist(mod->options[cnt].devices,md_cnt)
  WITH nocounter
 ;end select
#load_pool_options
 SELECT INTO "nl:"
  po.option_id, c.product_cd
  FROM pool_option po,
   component c
  PLAN (po
   WHERE po.option_id > 0.0)
   JOIN (c
   WHERE c.option_id=po.option_id
    AND c.active_ind=1)
  ORDER BY po.option_id
  HEAD REPORT
   op_cnt = 0
  HEAD po.option_id
   mo_cnt = (mo_cnt+ 1)
   IF (mod(mo_cnt,10)=1)
    stat = alterlist(mod->options,(mo_cnt+ 9))
   ENDIF
   mod->options[mo_cnt].option_id = po.option_id, mod->options[mo_cnt].display = po.description, mod
   ->options[mo_cnt].display_key = cnvtupper(cnvtalphanum(po.description))
   IF (po.active_ind=1)
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(po.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99")
   ELSE
    mod->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(po.active_status_dt_tm), mod->options[
    mo_cnt].end_effective_dt_tm = cnvtdatetime(po.updt_dt_tm)
   ENDIF
   mod->options[mo_cnt].new_product_ind = 0, mod->options[mo_cnt].split_ind = 0, mod->options[mo_cnt]
   .change_attribute_ind = 0,
   mod->options[mo_cnt].crossover_ind = 0, mod->options[mo_cnt].pool_product_ind = 1, mod->options[
   mo_cnt].generate_prod_nbr_ind = po.generate_prod_nbr_ind,
   mod->options[mo_cnt].prod_nbr_prefix = po.product_nbr_prefix, mod->options[mo_cnt].
   prod_nbr_ccyy_ind = 0, mod->options[mo_cnt].prod_nbr_starting_nbr = 0,
   mod->options[mo_cnt].dispose_orig_ind = 1, mod->options[mo_cnt].chg_orig_exp_dt_ind = 0, mod->
   options[mo_cnt].orig_nbr_days_exp = 0,
   mod->options[mo_cnt].orig_nbr_hrs_exp = 0, mod->options[mo_cnt].active_ind = po.active_ind
   IF (po.active_ind=1)
    mod->options[mo_cnt].active_status_cd = active_status_cd
   ELSE
    mod->options[mo_cnt].active_status_cd = inactive_status_cd
   ENDIF
   mod->options[mo_cnt].active_status_dt_tm = cnvtdatetime(po.active_status_dt_tm), mod->options[
   mo_cnt].active_status_prsnl_id = po.active_status_prsnl_id, mod->options[mo_cnt].updt_cnt = po
   .updt_cnt,
   mod->options[mo_cnt].updt_dt_tm = cnvtdatetime(po.updt_dt_tm), mod->options[mo_cnt].updt_id = po
   .updt_id, stat = alterlist(mod->options[mo_cnt].new_prods,1),
   mod->options[mo_cnt].new_prods[1].orig_product_cd = 0.0, mod->options[mo_cnt].new_prods[1].
   new_product_cd = po.new_product_cd, mod->options[mo_cnt].new_prods[1].quantity = 1,
   mod->options[mo_cnt].new_prods[1].default_sub_id_flag = 0, mod->options[mo_cnt].new_prods[1].
   max_prep_hrs = 0, mod->options[mo_cnt].new_prods[1].default_orig_exp_ind = 0,
   mod->options[mo_cnt].new_prods[1].calc_exp_drawn_ind = 0, mod->options[mo_cnt].new_prods[1].
   default_exp_days = 0, mod->options[mo_cnt].new_prods[1].default_exp_hrs = po.default_exp_hrs,
   mod->options[mo_cnt].new_prods[1].allow_extend_exp_ind = 0, mod->options[mo_cnt].new_prods[1].
   default_orig_vol_ind = 0, mod->options[mo_cnt].new_prods[1].default_volume = 0,
   mod->options[mo_cnt].new_prods[1].calc_vol_ind = po.calculate_vol_ind, mod->options[mo_cnt].
   new_prods[1].prompt_vol_ind = 0, mod->options[mo_cnt].new_prods[1].validate_vol_ind = 0,
   mod->options[mo_cnt].new_prods[1].default_unit_of_meas_cd = 0.0, mod->options[mo_cnt].new_prods[1]
   .synonym_id = 0.0, mod->options[mo_cnt].new_prods[1].require_assign_ind = po.require_assign_ind,
   mod->options[mo_cnt].new_prods[1].bag_type_cd = 0.0, mod->options[mo_cnt].new_prods[1].
   crossover_reason_cd = 0.0, mod->options[mo_cnt].new_prods[1].allow_no_aborh_ind = po
   .allow_no_aborh_ind,
   mod->options[mo_cnt].new_prods[1].default_supplier_id = po.default_supplier_id, mod->options[
   mo_cnt].new_prods[1].updt_cnt = po.updt_cnt, mod->options[mo_cnt].new_prods[1].updt_dt_tm =
   cnvtdatetime(po.updt_dt_tm),
   mod->options[mo_cnt].new_prods[1].updt_id = po.updt_id, op_cnt = 0
  DETAIL
   op_cnt = (op_cnt+ 1)
   IF (mod(op_cnt,10)=1)
    stat = alterlist(mod->options[mo_cnt].orig_prods,(op_cnt+ 9))
   ENDIF
   mod->options[mo_cnt].orig_prods[op_cnt].orig_product_cd = c.product_cd, mod->options[mo_cnt].
   orig_prods[op_cnt].updt_cnt = c.updt_cnt, mod->options[mo_cnt].orig_prods[op_cnt].updt_dt_tm =
   cnvtdatetime(c.updt_dt_tm),
   mod->options[mo_cnt].orig_prods[op_cnt].updt_id = c.updt_id
  FOOT  po.option_id
   stat = alterlist(mod->options[mo_cnt].orig_prods,op_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(mod->options,mo_cnt)
 IF (mo_cnt=0)
  SET failed_ind = 0
  CALL logmsg("No modify/pool options found for migration.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, pp.pool_option_id
  FROM (dummyt d  WITH seq = value(mo_cnt)),
   pooled_product pp
  PLAN (d
   WHERE d.seq <= mo_cnt
    AND (mod->options[d.seq].pool_product_ind=1))
   JOIN (pp
   WHERE (pp.pool_option_id=mod->options[d.seq].option_id)
    AND pp.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, pn_cnt = 0, yr = 0,
   digits = 0, highest_yr = 0, nbr_digits = 0,
   starting_nbr = 0
  HEAD d.seq
   cnt = d.seq, pn_cnt = 0, yr = 0,
   digits = 0, highest_yr = 0, nbr_digits = 0,
   starting_nbr = 0
  DETAIL
   pn_cnt = (pn_cnt+ 1)
   IF (mod(pn_cnt,10)=1)
    stat = alterlist(mod->options[cnt].pool_nbrs,(pn_cnt+ 9))
   ENDIF
   mod->options[cnt].pool_nbrs[pn_cnt].prefix = mod->options[cnt].prod_nbr_prefix
   IF (pp.year < 80)
    yr = (2000+ pp.year), digits = 2
   ELSEIF (pp.year < 100)
    yr = (1900+ pp.year), digits = 2
   ELSE
    yr = pp.year, digits = 4
   ENDIF
   IF (yr > highest_yr)
    highest_yr = yr, nbr_digits = digits, starting_nbr = pp.pool_nbr
   ENDIF
   mod->options[cnt].pool_nbrs[pn_cnt].year = yr, mod->options[cnt].pool_nbrs[pn_cnt].seq_nbr = pp
   .pool_nbr, mod->options[cnt].pool_nbrs[pn_cnt].updt_cnt = pp.updt_cnt,
   mod->options[cnt].pool_nbrs[pn_cnt].updt_dt_tm = cnvtdatetime(pp.updt_dt_tm), mod->options[cnt].
   pool_nbrs[pn_cnt].updt_id = pp.updt_id
  FOOT  d.seq
   IF (nbr_digits=4)
    mod->options[cnt].prod_nbr_ccyy_ind = 1
   ELSE
    mod->options[cnt].prod_nbr_ccyy_ind = 0
   ENDIF
   mod->options[cnt].prod_nbr_starting_nbr = starting_nbr, stat = alterlist(mod->options[cnt].
    pool_nbrs,pn_cnt)
  WITH nocounter
 ;end select
 FOR (cnt = 1 TO mo_cnt)
  SET version_nbr = 1
  FOR (x = (cnt+ 1) TO mo_cnt)
    IF ((mod->options[x].display_key=mod->options[cnt].display_key))
     SET key_unique_ind = 0
     WHILE (key_unique_ind=0)
       SET version_nbr = (version_nbr+ 1)
       SET display_key = build(mod->options[x].display_key,version_nbr)
       SET key_unique_ind = 1
       FOR (y = 1 TO mo_cnt)
         IF ((display_key=mod->options[y].display_key)
          AND y != x)
          SET key_unique_ind = 0
         ENDIF
       ENDFOR
     ENDWHILE
     SET mod->options[x].display = concat(mod->options[x].display," (",build(version_nbr),")")
     SET mod->options[x].display_key = build(mod->options[x].display_key,version_nbr)
    ENDIF
  ENDFOR
 ENDFOR
 FOR (cnt = 1 TO mo_cnt)
  SELECT INTO "nl:"
   mo.display_key
   FROM bb_mod_option mo
   PLAN (mo
    WHERE (mo.display_key=mod->options[cnt].display_key))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET next_code = 0.0
   EXECUTE cpm_next_code
   IF (next_code=0.0)
    SET failed_ind = 1
    ROLLBACK
    CALL logmsg("Unable to generate a new reference sequence id",((e_rdmstatus+ e_dispmsg)+
     e_logtofile))
    GO TO exit_script
   ENDIF
   SET mod->options[cnt].new_option_id = next_code
   INSERT  FROM bb_mod_option mo
    SET mo.option_id = mod->options[cnt].new_option_id, mo.display = mod->options[cnt].display, mo
     .display_key = cnvtupper(cnvtalphanum(mod->options[cnt].display)),
     mo.beg_effective_dt_tm = cnvtdatetime(mod->options[cnt].beg_effective_dt_tm), mo
     .end_effective_dt_tm = cnvtdatetime(mod->options[cnt].end_effective_dt_tm), mo.new_product_ind
      = mod->options[cnt].new_product_ind,
     mo.split_ind = mod->options[cnt].split_ind, mo.ad_hoc_ind = mod->options[cnt].ad_hoc_ind, mo
     .change_attribute_ind = mod->options[cnt].change_attribute_ind,
     mo.crossover_ind = mod->options[cnt].crossover_ind, mo.pool_product_ind = mod->options[cnt].
     pool_product_ind, mo.generate_prod_nbr_ind = mod->options[cnt].generate_prod_nbr_ind,
     mo.prod_nbr_prefix = mod->options[cnt].prod_nbr_prefix, mo.prod_nbr_ccyy_ind = mod->options[cnt]
     .prod_nbr_ccyy_ind, mo.prod_nbr_starting_nbr = mod->options[cnt].prod_nbr_starting_nbr,
     mo.dispose_orig_ind = mod->options[cnt].dispose_orig_ind, mo.chg_orig_exp_dt_ind = mod->options[
     cnt].chg_orig_exp_dt_ind, mo.orig_nbr_days_exp = mod->options[cnt].orig_nbr_days_exp,
     mo.orig_nbr_hrs_exp = mod->options[cnt].orig_nbr_hrs_exp, mo.active_ind = mod->options[cnt].
     active_ind, mo.active_status_cd = mod->options[cnt].active_status_cd,
     mo.active_status_dt_tm = cnvtdatetime(mod->options[cnt].active_status_dt_tm), mo
     .active_status_prsnl_id = mod->options[cnt].active_status_prsnl_id, mo.updt_applctx = 0,
     mo.updt_task = reqinfo->updt_task, mo.updt_cnt = mod->options[cnt].updt_cnt, mo.updt_dt_tm =
     cnvtdatetime(mod->options[cnt].updt_dt_tm),
     mo.updt_id = mod->options[cnt].updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed_ind = 1
    ROLLBACK
    SET msg = build("BB_MOD_OPTION table insert FAILED for option =",mod->options[cnt].display)
    CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
    GO TO exit_script
   ENDIF
   IF (size(mod->options[cnt].orig_prods,5) > 0)
    FOR (op_cnt = 1 TO size(mod->options[cnt].orig_prods,5))
     INSERT  FROM bb_mod_orig_product mop
      SET mop.option_id = mod->options[cnt].new_option_id, mop.orig_product_cd = mod->options[cnt].
       orig_prods[op_cnt].orig_product_cd, mop.updt_applctx = 0,
       mop.updt_task = reqinfo->updt_task, mop.updt_cnt = mod->options[cnt].orig_prods[op_cnt].
       updt_cnt, mop.updt_dt_tm = cnvtdatetime(mod->options[cnt].orig_prods[op_cnt].updt_dt_tm),
       mop.updt_id = mod->options[cnt].orig_prods[op_cnt].updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed_ind = 1
      ROLLBACK
      SET msg = build("BB_MOD_ORIG_PRODUCT table insert FAILED for option =",mod->options[cnt].
       display)
      CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
      GO TO exit_script
     ENDIF
    ENDFOR
   ENDIF
   IF (size(mod->options[cnt].new_prods,5) > 0)
    FOR (np_cnt = 1 TO size(mod->options[cnt].new_prods,5))
      SET next_code = 0.0
      EXECUTE cpm_next_code
      IF (next_code=0.0)
       SET failed_ind = 1
       ROLLBACK
       CALL logmsg("Unable to generate a new reference sequence id",((e_rdmstatus+ e_dispmsg)+
        e_logtofile))
       GO TO exit_script
      ENDIF
      SET mod->options[cnt].new_prods[np_cnt].mod_new_prod_id = next_code
      INSERT  FROM bb_mod_new_product mnp
       SET mnp.mod_new_prod_id = mod->options[cnt].new_prods[np_cnt].mod_new_prod_id, mnp.option_id
         = mod->options[cnt].new_option_id, mnp.orig_product_cd = mod->options[cnt].new_prods[np_cnt]
        .orig_product_cd,
        mnp.new_product_cd = mod->options[cnt].new_prods[np_cnt].new_product_cd, mnp.quantity = mod->
        options[cnt].new_prods[np_cnt].quantity, mnp.default_sub_id_flag = mod->options[cnt].
        new_prods[np_cnt].default_sub_id_flag,
        mnp.max_prep_hrs = mod->options[cnt].new_prods[np_cnt].max_prep_hrs, mnp.default_orig_exp_ind
         = mod->options[cnt].new_prods[np_cnt].default_orig_exp_ind, mnp.calc_exp_drawn_ind = mod->
        options[cnt].new_prods[np_cnt].calc_exp_drawn_ind,
        mnp.default_exp_days = mod->options[cnt].new_prods[np_cnt].default_exp_days, mnp
        .default_exp_hrs = mod->options[cnt].new_prods[np_cnt].default_exp_hrs, mnp
        .allow_extend_exp_ind = mod->options[cnt].new_prods[np_cnt].allow_extend_exp_ind,
        mnp.default_orig_vol_ind = mod->options[cnt].new_prods[np_cnt].default_orig_vol_ind, mnp
        .default_volume = mod->options[cnt].new_prods[np_cnt].default_volume, mnp.calc_vol_ind = mod
        ->options[cnt].new_prods[np_cnt].calc_vol_ind,
        mnp.prompt_vol_ind = mod->options[cnt].new_prods[np_cnt].prompt_vol_ind, mnp.validate_vol_ind
         = mod->options[cnt].new_prods[np_cnt].validate_vol_ind, mnp.default_unit_of_meas_cd = mod->
        options[cnt].new_prods[np_cnt].default_unit_of_meas_cd,
        mnp.synonym_id = mod->options[cnt].new_prods[np_cnt].synonym_id, mnp.require_assign_ind = mod
        ->options[cnt].new_prods[np_cnt].require_assign_ind, mnp.bag_type_cd = mod->options[cnt].
        new_prods[np_cnt].bag_type_cd,
        mnp.crossover_reason_cd = mod->options[cnt].new_prods[np_cnt].crossover_reason_cd, mnp
        .allow_no_aborh_ind = mod->options[cnt].new_prods[np_cnt].allow_no_aborh_ind, mnp
        .default_supplier_id = mod->options[cnt].new_prods[np_cnt].default_supplier_id,
        mnp.updt_applctx = 0, mnp.updt_task = reqinfo->updt_task, mnp.updt_cnt = mod->options[cnt].
        new_prods[np_cnt].updt_cnt,
        mnp.updt_dt_tm = cnvtdatetime(mod->options[cnt].new_prods[np_cnt].updt_dt_tm), mnp.updt_id =
        mod->options[cnt].new_prods[np_cnt].updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed_ind = 1
       ROLLBACK
       SET msg = build("BB_MOD_NEW_PRODUCT table insert FAILED for option =",mod->options[cnt].
        display)
       CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
       GO TO exit_script
      ENDIF
      IF (size(mod->options[cnt].new_prods[np_cnt].spec_testings,5) > 0)
       FOR (mst_cnt = 1 TO size(mod->options[cnt].new_prods[np_cnt].spec_testings,5))
        INSERT  FROM bb_mod_special_testing mst
         SET mst.mod_new_prod_id = mod->options[cnt].new_prods[np_cnt].mod_new_prod_id, mst
          .special_testing_cd = mod->options[cnt].new_prods[np_cnt].spec_testings[mst_cnt].
          special_testing_cd, mst.updt_applctx = 0,
          mst.updt_task = reqinfo->updt_task, mst.updt_cnt = mod->options[cnt].new_prods[np_cnt].
          spec_testings[mst_cnt].updt_cnt, mst.updt_dt_tm = cnvtdatetime(mod->options[cnt].new_prods[
           np_cnt].spec_testings[mst_cnt].updt_dt_tm),
          mst.updt_id = mod->options[cnt].new_prods[np_cnt].spec_testings[mst_cnt].updt_id
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET failed_ind = 1
         ROLLBACK
         SET msg = build("BB_MOD_SPECIAL_TESTING table insert FAILED for option =",mod->options[cnt].
          display)
         CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
         GO TO exit_script
        ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   IF (size(mod->options[cnt].devices,5) > 0)
    FOR (md_cnt = 1 TO size(mod->options[cnt].devices,5))
     INSERT  FROM bb_mod_device md
      SET md.option_id = mod->options[cnt].new_option_id, md.device_type_cd = mod->options[cnt].
       devices[md_cnt].device_type_cd, md.default_ind = mod->options[cnt].devices[md_cnt].default_ind,
       md.max_capacity = mod->options[cnt].devices[md_cnt].max_capacity, md.start_stop_time_ind = mod
       ->options[cnt].devices[md_cnt].start_stop_time_ind, md.modification_duration = mod->options[
       cnt].devices[md_cnt].modification_duration,
       md.updt_applctx = 0, md.updt_task = reqinfo->updt_task, md.updt_cnt = mod->options[cnt].
       devices[md_cnt].updt_cnt,
       md.updt_dt_tm = cnvtdatetime(mod->options[cnt].devices[md_cnt].updt_dt_tm), md.updt_id = mod->
       options[cnt].devices[md_cnt].updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed_ind = 1
      ROLLBACK
      SET msg = build("BB_MOD_DEVICE table insert FAILED for option =",mod->options[cnt].display)
      CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
      GO TO exit_script
     ENDIF
    ENDFOR
   ENDIF
   IF (size(mod->options[cnt].pool_nbrs,5) > 0)
    FOR (pn_cnt = 1 TO size(mod->options[cnt].pool_nbrs,5))
      SET next_code = 0.0
      EXECUTE cpm_next_code
      IF (next_code=0.0)
       SET failed_ind = 1
       ROLLBACK
       CALL logmsg("Unable to generate a new reference sequence id",((e_rdmstatus+ e_dispmsg)+
        e_logtofile))
       GO TO exit_script
      ENDIF
      SET mod->options[cnt].pool_nbrs[pn_cnt].mod_pool_nbr_id = next_code
      INSERT  FROM bb_mod_pool_nbr pn
       SET pn.mod_pool_nbr_id = mod->options[cnt].pool_nbrs[pn_cnt].mod_pool_nbr_id, pn.option_id =
        mod->options[cnt].new_option_id, pn.prefix = mod->options[cnt].pool_nbrs[pn_cnt].prefix,
        pn.year = mod->options[cnt].pool_nbrs[pn_cnt].year, pn.seq_nbr = mod->options[cnt].pool_nbrs[
        pn_cnt].seq_nbr, pn.updt_applctx = 0,
        pn.updt_task = reqinfo->updt_task, pn.updt_cnt = mod->options[cnt].pool_nbrs[pn_cnt].updt_cnt,
        pn.updt_dt_tm = cnvtdatetime(mod->options[cnt].pool_nbrs[pn_cnt].updt_dt_tm),
        pn.updt_id = mod->options[cnt].pool_nbrs[pn_cnt].updt_id
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed_ind = 1
       ROLLBACK
       SET msg = build("BB_MOD_POOL_NBR table insert FAILED for option =",mod->options[cnt].display)
       CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    bi.bill_item_id
    FROM bill_item bi
    WHERE (bi.ext_parent_reference_id=mod->options[cnt].option_id)
     AND bi.active_ind=1
    DETAIL
     hold_billitem_id = bi.bill_item_id
    WITH forupdate(bi)
   ;end select
   IF (hold_billitem_id > 0.0)
    UPDATE  FROM bill_item bi
     SET bi.ext_parent_reference_id = mod->options[cnt].new_option_id, bi.updt_task = reqinfo->
      updt_task
     WHERE bi.bill_item_id=hold_billitem_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     SET msg = build("BILL_ITEM table update FAILED for bill_item_id =",hold_billitem_id)
     CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 COMMIT
 CALL logmsg("Reference Data Migration Successful.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
 SET p_cnt = 0
 SET e_cnt = 0
 SELECT INTO "nl:"
  p.product_id, p2.pooled_product_id, bp.product_id,
  pe.product_event_id
  FROM product p,
   product p2,
   blood_product bp,
   product_event pe
  PLAN (p
   WHERE p.pool_option_id > 0.0)
   JOIN (p2
   WHERE p2.pooled_product_id=p.product_id)
   JOIN (bp
   WHERE bp.product_id=p2.product_id)
   JOIN (pe
   WHERE pe.product_id=p2.product_id
    AND ((pe.event_type_cd+ 0)=pooled_cd))
  ORDER BY p.product_id, pe.product_event_id
  HEAD REPORT
   p_cnt = 0, e_cnt = 0, updt_prod_ind = 0
  HEAD p.product_id
   updt_prod_ind = 0
   FOR (cnt = 1 TO mo_cnt)
     IF ((mod->options[cnt].option_id=p.pool_option_id))
      updt_prod_ind = 1, p_cnt = (p_cnt+ 1)
      IF (mod(p_cnt,10)=1)
       stat = alterlist(pool->products,(p_cnt+ 9))
      ENDIF
      pool->products[p_cnt].pooled_product_id = p.product_id, pool->products[p_cnt].new_option_id =
      mod->options[cnt].new_option_id
     ENDIF
   ENDFOR
   e_cnt = 0
  DETAIL
   IF (updt_prod_ind=1)
    e_cnt = (e_cnt+ 1)
    IF (mod(e_cnt,10)=1)
     stat = alterlist(pool->products[p_cnt].events,(e_cnt+ 9))
    ENDIF
    pool->products[p_cnt].events[e_cnt].product_event_id = pe.product_event_id, pool->products[p_cnt]
    .events[e_cnt].product_id = pe.product_id, pool->products[p_cnt].events[e_cnt].orig_expire_dt_tm
     = cnvtdatetime(bp.orig_expire_dt_tm),
    pool->products[p_cnt].events[e_cnt].orig_volume = bp.orig_volume, pool->products[p_cnt].events[
    e_cnt].orig_unit_meas_cd = p2.orig_unit_meas_cd, pool->products[p_cnt].events[e_cnt].
    cur_expire_dt_tm = cnvtdatetime(p2.cur_expire_dt_tm)
   ENDIF
  FOOT  p.product_id
   IF (updt_prod_ind=1)
    stat = alterlist(pool->products[p_cnt].events,e_cnt)
   ENDIF
  FOOT REPORT
   stat = alterlist(pool->products,p_cnt)
  WITH nocounter
 ;end select
 IF (p_cnt > 0)
  FOR (cnt = 1 TO p_cnt)
    SELECT INTO "nl:"
     p.product_id
     FROM product p
     WHERE (p.product_id=pool->products[cnt].pooled_product_id)
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     CALL logmsg("PRODUCT table row lock Failed.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
    UPDATE  FROM product p
     SET p.pool_option_id = pool->products[cnt].new_option_id, p.updt_task = reqinfo->updt_task
     WHERE (p.product_id=pool->products[cnt].pooled_product_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     SET msg = build("PRODUCT table update FAILED for product_id =",pool->products[cnt].
      pooled_product_id)
     CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
    IF (size(pool->products[cnt].events,5) > 0)
     FOR (e_cnt = 1 TO size(pool->products[cnt].events,5))
      INSERT  FROM modification m
       SET m.product_event_id = pool->products[cnt].events[e_cnt].product_event_id, m.product_id =
        pool->products[cnt].events[e_cnt].product_id, m.orig_expire_dt_tm = cnvtdatetime(pool->
         products[cnt].events[e_cnt].orig_expire_dt_tm),
        m.orig_volume = pool->products[cnt].events[e_cnt].orig_volume, m.orig_unit_meas_cd = pool->
        products[cnt].events[e_cnt].orig_unit_meas_cd, m.cur_expire_dt_tm = cnvtdatetime(pool->
         products[cnt].events[e_cnt].cur_expire_dt_tm),
        m.cur_volume = 0, m.cur_unit_meas_cd = 0.0, m.modified_qty = 0,
        m.option_id = pool->products[cnt].new_option_id, m.crossover_reason_cd = 0.0, m.active_ind =
        1,
        m.active_status_cd = active_status_cd, m.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        m.active_status_prsnl_id = 0.0,
        m.updt_applctx = 0, m.updt_task = reqinfo->updt_task, m.updt_cnt = 0,
        m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id = 0.0
       WHERE (m.product_event_id=pool->products[cnt].events[e_cnt].product_event_id)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed_ind = 1
       ROLLBACK
       SET msg = build("MODIFICATION table insert FAILED for product_event_id =",pool->products[cnt].
        events[e_cnt].product_event_id)
       CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
       GO TO exit_script
      ENDIF
     ENDFOR
    ENDIF
    COMMIT
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  m.option_id
  FROM modification m
  PLAN (m
   WHERE m.product_event_id > 0.0)
  HEAD REPORT
   m_cnt = 0
  DETAIL
   FOR (cnt = 1 TO mo_cnt)
     IF ((mod->options[cnt].option_id=m.option_id))
      m_cnt = (m_cnt+ 1)
      IF (mod(m_cnt,100)=1)
       stat = alterlist(modification_table->events,(m_cnt+ 99))
      ENDIF
      modification_table->events[m_cnt].product_event_id = m.product_event_id, modification_table->
      events[m_cnt].option_id = m.option_id, modification_table->events[m_cnt].new_option_id = mod->
      options[cnt].new_option_id,
      cnt = mo_cnt
     ENDIF
   ENDFOR
  FOOT REPORT
   stat = alterlist(modification_table->events,m_cnt)
  WITH nocounter
 ;end select
 IF (m_cnt > 0)
  FOR (cnt = 1 TO m_cnt)
    SELECT INTO "nl:"
     m.option_id
     FROM modification m
     WHERE (m.product_event_id=modification_table->events[cnt].product_event_id)
      AND (m.option_id=modification_table->events[cnt].option_id)
     WITH nocounter, forupdate(m)
    ;end select
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     CALL logmsg("MODIFICATION table row lock Failed.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
    UPDATE  FROM modification m
     SET m.option_id = modification_table->events[cnt].new_option_id, m.updt_task = reqinfo->
      updt_task
     WHERE (m.product_event_id=modification_table->events[cnt].product_event_id)
      AND (m.option_id=modification_table->events[cnt].option_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     COMMIT
    ELSE
     SET failed_ind = 1
     ROLLBACK
     SET msg = build("MODIFICATION table update FAILED for product_event_id =",modification_table->
      events[cnt].product_event_id)
     CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 CALL logmsg("Activity Data Update Successful.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
#exit_script
 IF (failed_ind=0)
  COMMIT
  CALL logstatus("Execution Successful.","S")
 ELSE
  ROLLBACK
  CALL logstatus("Execution Failed","F")
 ENDIF
 FREE RECORD mod
 FREE RECORD pool
 FREE RECORD modification_table
 CALL logscriptend(sreadme_name)
END GO
