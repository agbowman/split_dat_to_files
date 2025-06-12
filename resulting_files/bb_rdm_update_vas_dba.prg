CREATE PROGRAM bb_rdm_update_vas:dba
 DECLARE readme_name = c17 WITH constant("BB_RDM_UPDATE_VAS")
 DECLARE msg = c132 WITH noconstant(fillstring(132," "))
 DECLARE failed_ind = i2 WITH noconstant(0)
 DECLARE valid_state_cnt = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE process_mean_cs = i4 WITH constant(1664)
 DECLARE assign_process_mean = c12 WITH constant("ASSIGN")
 DECLARE crossmatch_process_mean = c12 WITH constant("CROSSMATCH")
 DECLARE dispense_process_mean = c12 WITH constant("DISPENSE")
 DECLARE dispose_process_mean = c12 WITH constant("DISPOSE")
 DECLARE manipulate_process_mean = c12 WITH constant("MANIPULATE")
 DECLARE quarantine_process_mean = c12 WITH constant("QUARANTINE")
 DECLARE transfer_process_mean = c12 WITH constant("TRANSFER")
 DECLARE transfuse_process_mean = c12 WITH constant("TRANSFUSE")
 DECLARE verify_process_mean = c12 WITH constant("VERIFY")
 DECLARE xm_reinstate_process_mean = c12 WITH constant("XM REINSTATE")
 DECLARE assign_process_cd = f8 WITH noconstant(0.0)
 DECLARE crossmatch_process_cd = f8 WITH noconstant(0.0)
 DECLARE dispense_process_cd = f8 WITH noconstant(0.0)
 DECLARE dispose_process_cd = f8 WITH noconstant(0.0)
 DECLARE manipulate_process_cd = f8 WITH noconstant(0.0)
 DECLARE quarantine_process_cd = f8 WITH noconstant(0.0)
 DECLARE transfer_process_cd = f8 WITH noconstant(0.0)
 DECLARE transfuse_process_cd = f8 WITH noconstant(0.0)
 DECLARE verify_process_cd = f8 WITH noconstant(0.0)
 DECLARE xm_reinstate_process_cd = f8 WITH noconstant(0.0)
 DECLARE inventory_states_cs = i4 WITH constant(1610)
 DECLARE assigned_event_mean = c12 WITH constant("1")
 DECLARE autologous_event_mean = c12 WITH constant("10")
 DECLARE directed_event_mean = c12 WITH constant("11")
 DECLARE available_event_mean = c12 WITH constant("12")
 DECLARE received_event_mean = c12 WITH constant("13")
 DECLARE destroyed_event_mean = c12 WITH constant("14")
 DECLARE shipped_event_mean = c12 WITH constant("15")
 DECLARE in_progress_event_mean = c12 WITH constant("16")
 DECLARE pooled_event_mean = c12 WITH constant("17")
 DECLARE pooled_product_event_mean = c12 WITH constant("18")
 DECLARE confirmed_event_mean = c12 WITH constant("19")
 DECLARE quarantine_event_mean = c12 WITH constant("2")
 DECLARE drawn_event_mean = c12 WITH constant("20")
 DECLARE tested_event_mean = c12 WITH constant("21")
 DECLARE shipment_in_proc_event_mean = c12 WITH constant("22")
 DECLARE verified_event_mean = c12 WITH constant("23")
 DECLARE modified_product_event_mean = c12 WITH constant("24")
 DECLARE crossmatched_event_mean = c12 WITH constant("3")
 DECLARE dispensed_event_mean = c12 WITH constant("4")
 DECLARE disposed_event_mean = c12 WITH constant("5")
 DECLARE transferred_event_mean = c12 WITH constant("6")
 DECLARE transfused_event_mean = c12 WITH constant("7")
 DECLARE modified_event_mean = c12 WITH constant("8")
 DECLARE unconfirmed_event_mean = c12 WITH constant("9")
 DECLARE assigned_event_cd = f8 WITH noconstant(0.0)
 DECLARE autologous_event_cd = f8 WITH noconstant(0.0)
 DECLARE directed_event_cd = f8 WITH noconstant(0.0)
 DECLARE available_event_cd = f8 WITH noconstant(0.0)
 DECLARE received_event_cd = f8 WITH noconstant(0.0)
 DECLARE destroyed_event_cd = f8 WITH noconstant(0.0)
 DECLARE shipped_event_cd = f8 WITH noconstant(0.0)
 DECLARE in_progress_event_cd = f8 WITH noconstant(0.0)
 DECLARE pooled_event_cd = f8 WITH noconstant(0.0)
 DECLARE pooled_product_event_cd = f8 WITH noconstant(0.0)
 DECLARE confirmed_event_cd = f8 WITH noconstant(0.0)
 DECLARE quarantine_event_cd = f8 WITH noconstant(0.0)
 DECLARE drawn_event_cd = f8 WITH noconstant(0.0)
 DECLARE tested_event_cd = f8 WITH noconstant(0.0)
 DECLARE shipment_in_proc_event_cd = f8 WITH noconstant(0.0)
 DECLARE verified_event_cd = f8 WITH noconstant(0.0)
 DECLARE modified_product_event_cd = f8 WITH noconstant(0.0)
 DECLARE crossmatched_event_cd = f8 WITH noconstant(0.0)
 DECLARE dispensed_event_cd = f8 WITH noconstant(0.0)
 DECLARE disposed_event_cd = f8 WITH noconstant(0.0)
 DECLARE transferred_event_cd = f8 WITH noconstant(0.0)
 DECLARE transfused_event_cd = f8 WITH noconstant(0.0)
 DECLARE modified_event_cd = f8 WITH noconstant(0.0)
 DECLARE unconfirmed_event_cd = f8 WITH noconstant(0.0)
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
 CALL logscriptstart(readme_name)
 RECORD valid_state(
   1 valid_state_rows[*]
     2 process_cd = f8
     2 state_cd = f8
     2 category_cd = f8
 )
 SELECT INTO "nl:"
  *
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=process_mean_cs
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.cdf_meaning)
    OF assign_process_mean:
     assign_process_cd = cv.code_value
    OF crossmatch_process_mean:
     crossmatch_process_cd = cv.code_value
    OF dispense_process_mean:
     dispense_process_cd = cv.code_value
    OF dispose_process_mean:
     dispose_process_cd = cv.code_value
    OF manipulate_process_mean:
     manipulate_process_cd = cv.code_value
    OF quarantine_process_mean:
     quarantine_process_cd = cv.code_value
    OF transfer_process_mean:
     transfer_process_cd = cv.code_value
    OF transfuse_process_mean:
     transfuse_process_cd = cv.code_value
    OF verify_process_mean:
     verify_process_cd = cv.code_value
    OF xm_reinstate_process_mean:
     xm_reinstate_process_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (assign_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive ASSIGN process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (crossmatch_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive CROSSMATCH process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (dispense_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DISPENSE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (dispose_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DISPOSE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (manipulate_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive MANIPULATE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (quarantine_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive QUARANTINE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (transfer_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive TRANSFER process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (transfuse_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive TRANSFUSE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (verify_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive VERIFY process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (xm_reinstate_process_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive CROSSMATCH REINSTATE process code value from code set 1664."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=inventory_states_cs)
  DETAIL
   CASE (cv.cdf_meaning)
    OF assigned_event_mean:
     assigned_event_cd = cv.code_value
    OF autologous_event_mean:
     autologous_event_cd = cv.code_value
    OF directed_event_mean:
     directed_event_cd = cv.code_value
    OF available_event_mean:
     available_event_cd = cv.code_value
    OF received_event_mean:
     received_event_cd = cv.code_value
    OF destroyed_event_mean:
     destroyed_event_cd = cv.code_value
    OF shipped_event_mean:
     shipped_event_cd = cv.code_value
    OF in_progress_event_mean:
     in_progress_event_cd = cv.code_value
    OF pooled_event_mean:
     pooled_event_cd = cv.code_value
    OF pooled_product_event_mean:
     pooled_product_event_cd = cv.code_value
    OF confirmed_event_mean:
     confirmed_event_cd = cv.code_value
    OF quarantine_event_mean:
     quarantine_event_cd = cv.code_value
    OF drawn_event_mean:
     drawn_event_cd = cv.code_value
    OF tested_event_mean:
     tested_event_cd = cv.code_value
    OF shipment_in_proc_event_mean:
     shipment_in_proc_event_cd = cv.code_value
    OF verified_event_mean:
     verified_event_cd = cv.code_value
    OF modified_product_event_mean:
     modified_product_event_cd = cv.code_value
    OF crossmatched_event_mean:
     crossmatched_event_cd = cv.code_value
    OF dispensed_event_mean:
     dispensed_event_cd = cv.code_value
    OF disposed_event_mean:
     disposed_event_cd = cv.code_value
    OF transferred_event_mean:
     transferred_event_cd = cv.code_value
    OF transfused_event_mean:
     transfused_event_cd = cv.code_value
    OF modified_event_mean:
     modified_event_cd = cv.code_value
    OF unconfirmed_event_mean:
     unconfirmed_event_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (assigned_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive ASSIGNED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (autologous_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive AUTOLOGOUS event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (directed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DIRECTED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (available_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive AVAILABLE event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (received_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive RECEIVED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (destroyed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DESTROYED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (shipped_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive SHIPPED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (in_progress_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive IN PROGRESS event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (pooled_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive POOLED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (pooled_product_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive POOLED PRODUCT event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (confirmed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive CONFIRMED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (quarantine_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive QUARANTINE event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (drawn_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DRAWN event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (tested_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive TESTED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (shipment_in_proc_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive SHIPMENT IN PROCESS event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (verified_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive VERIFIED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (modified_product_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive MODIFIED PRODUCT event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (crossmatched_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive CROSSMATCHED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (dispensed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DISPENSED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (disposed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive DISPOSED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (transferred_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive TRANSFERRED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (transfused_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive TRANSFUSED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (modified_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive MODIFIED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSEIF (unconfirmed_event_cd=0)
  SET failed_ind = 1
  SET msg = "Missing or inactive UNCONFIRMED event code value from code set 1610."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM valid_state vs
  PLAN (vs
   WHERE vs.active_ind=1)
  HEAD REPORT
   valid_state_cnt = 0
  DETAIL
   CASE (vs.process_cd)
    OF assign_process_cd:
     IF (vs.state_cd IN (autologous_event_cd, confirmed_event_cd, directed_event_cd,
     in_progress_event_cd, modified_event_cd,
     modified_product_event_cd, pooled_event_cd, pooled_product_event_cd, received_event_cd,
     drawn_event_cd,
     verified_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF crossmatch_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, modified_event_cd, modified_product_event_cd,
     pooled_event_cd, pooled_product_event_cd,
     received_event_cd, drawn_event_cd, tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF dispense_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, drawn_event_cd, modified_event_cd,
     modified_product_event_cd, pooled_event_cd,
     pooled_product_event_cd, received_event_cd, shipment_in_proc_event_cd, shipped_event_cd,
     tested_event_cd,
     transferred_event_cd, verified_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF dispose_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, in_progress_event_cd, modified_event_cd,
     modified_product_event_cd, pooled_event_cd,
     pooled_product_event_cd, received_event_cd, drawn_event_cd, tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF manipulate_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, destroyed_event_cd, dispensed_event_cd,
     disposed_event_cd, modified_event_cd,
     modified_product_event_cd, pooled_event_cd, pooled_product_event_cd, received_event_cd,
     shipment_in_proc_event_cd,
     shipped_event_cd, transferred_event_cd, transfused_event_cd, drawn_event_cd, tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF quarantine_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, modified_event_cd, modified_product_event_cd,
     pooled_event_cd, pooled_product_event_cd,
     received_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF transfer_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, modified_event_cd, modified_product_event_cd,
     pooled_event_cd, pooled_product_event_cd,
     received_event_cd, drawn_event_cd, tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF transfuse_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, drawn_event_cd, in_progress_event_cd, modified_event_cd,
     modified_product_event_cd,
     pooled_event_cd, pooled_product_event_cd, received_event_cd, shipment_in_proc_event_cd,
     shipped_event_cd,
     tested_event_cd, verified_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF verify_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, destroyed_event_cd, dispensed_event_cd,
     disposed_event_cd, modified_event_cd,
     modified_product_event_cd, pooled_event_cd, pooled_product_event_cd, received_event_cd,
     shipment_in_proc_event_cd,
     shipped_event_cd, transferred_event_cd, transfused_event_cd, drawn_event_cd, verified_event_cd,
     tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
    OF xm_reinstate_process_cd:
     IF (vs.state_cd IN (confirmed_event_cd, modified_event_cd, modified_product_event_cd,
     pooled_event_cd, pooled_product_event_cd,
     received_event_cd, dispensed_event_cd, disposed_event_cd, destroyed_event_cd,
     transfused_event_cd,
     shipped_event_cd, shipment_in_proc_event_cd, drawn_event_cd, tested_event_cd))
      valid_state_cnt = (valid_state_cnt+ 1)
      IF (mod(valid_state_cnt,10)=1)
       stat = alterlist(valid_state->valid_state_rows,(valid_state_cnt+ 9))
      ENDIF
      valid_state->valid_state_rows[valid_state_cnt].process_cd = vs.process_cd, valid_state->
      valid_state_rows[valid_state_cnt].state_cd = vs.state_cd, valid_state->valid_state_rows[
      valid_state_cnt].category_cd = vs.category_cd
     ENDIF
   ENDCASE
  FOOT REPORT
   stat = alterlist(valid_state->valid_state_rows,valid_state_cnt)
  WITH nocounter
 ;end select
 IF (valid_state_cnt=0)
  SET msg = "No valid state rows to update."
  CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
  GO TO exit_script
 ELSE
  FOR (count = 1 TO valid_state_cnt)
    SELECT INTO "nl:"
     *
     FROM valid_state vs
     PLAN (vs
      WHERE (vs.process_cd=valid_state->valid_state_rows[count].process_cd)
       AND (vs.state_cd=valid_state->valid_state_rows[count].state_cd)
       AND (vs.category_cd=valid_state->valid_state_rows[count].category_cd)
       AND vs.active_ind=1)
     WITH nocounter, forupdate(vs)
    ;end select
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     CALL logmsg("VALID_STATE table row lock FAILED.",((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ENDIF
    UPDATE  FROM valid_state vs
     SET vs.active_ind = 0, vs.updt_applctx = reqinfo->updt_applctx, vs.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      vs.updt_id = reqinfo->updt_id, vs.updt_cnt = (vs.updt_cnt+ 1), vs.updt_task = reqinfo->
      updt_task
     WHERE (vs.process_cd=valid_state->valid_state_rows[count].process_cd)
      AND (vs.state_cd=valid_state->valid_state_rows[count].state_cd)
      AND (vs.category_cd=valid_state->valid_state_rows[count].category_cd)
      AND vs.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed_ind = 1
     ROLLBACK
     SET msg = build("VALID_STATE table update FAILED for PROCESS_CD = ",valid_state->
      valid_state_rows[count].process_cd," and STATE_CD = ",valid_state->valid_state_rows[count].
      state_cd," and CATEGORY_CD = ",
      valid_state->valid_state_rows[count].category_cd)
     CALL logmsg(msg,((e_rdmstatus+ e_dispmsg)+ e_logtofile))
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed_ind=0)
  COMMIT
  CALL logstatus("Execution Successful.","S")
 ELSE
  ROLLBACK
  CALL logstatus("Execution Failed","F")
 ENDIF
 FREE RECORD valid_state
 CALL logscriptend(readme_name)
END GO
