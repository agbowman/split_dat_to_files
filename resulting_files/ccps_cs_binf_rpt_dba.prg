CREATE PROGRAM ccps_cs_binf_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Organization" = 0,
  "Report Type" = 0
  WITH outdev, organization, rpt_type
 DECLARE ea_type_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE suspense_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"SUSPENSE")), protect
 DECLARE no_bill_item_cd = f8 WITH constant(uar_get_code_by("MEANING",13030,"NOBILLITEM")), protect
 DECLARE accommodation_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"ACCOM"))
 DECLARE appt_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"APPTTYPE"))
 DECLARE bb_antibody_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBANTIBODY"))
 DECLARE bb_antigen_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBANTIGEN"))
 DECLARE bb_modify_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBMODIFY"))
 DECLARE bb_modify_fee_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBMODIFYFEE"))
 DECLARE bb_phase_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBPHASE"))
 DECLARE bb_pool_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBPOOL"))
 DECLARE bb_pool_fee_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBPOOLFEE"))
 DECLARE bb_product_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBPRODUCT"))
 DECLARE bb_result_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBRESULT"))
 DECLARE bb_spec_test_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"BBSPECTEST"))
 DECLARE coll_act_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"COLL ACT"))
 DECLARE coll_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"COLL TYPE"))
 DECLARE him_task_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"HIMTASK"))
 DECLARE item_master_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"ITEM MASTER"))
 DECLARE manf_item_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MANF ITEM"))
 DECLARE med_def_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MED DEF"))
 DECLARE med_def_flex_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MED DEF FLEX"))
 DECLARE mic_bio_rslt_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MIC BIO RSLT"))
 DECLARE mic_sus_det_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MIC SUS DET"))
 DECLARE mic_sus_rslt_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MIC SUS RSLT"))
 DECLARE mic_task_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MIC TASK"))
 DECLARE mic_task_log_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"MIC TASK LOG"))
 DECLARE ord_cat_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"ORD CAT"))
 DECLARE ord_id_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"ORD ID"))
 DECLARE anes_record_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SAANESRECID"))
 DECLARE anes_time_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SAANESTIME"))
 DECLARE anes_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SAANESTYPE"))
 DECLARE anes_inventory_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SAINVENTORY"))
 DECLARE anes_monitor_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SAMONITOR"))
 DECLARE surgical_case_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SURG CASE"))
 DECLARE surgical_op_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SURGOP"))
 DECLARE surgical_personnel_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SURGPRSNL"))
 DECLARE sn_doc_id_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SNDOCID"))
 DECLARE specimen_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"SPECIMEN"))
 DECLARE tnf_med_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"TNF_MED"))
 DECLARE task_assay_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
 DECLARE task_id_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASK ID"))
 DECLARE task_ref_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASK REF"))
 DECLARE task_cat_cd = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASKCAT"))
 DECLARE pharm_activity_type_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE micro_activity_type_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE load_script_cnt = i4 WITH noconstant(0), public
 DECLARE load_script_total = i4 WITH noconstant(0), public
 DECLARE prompt_organization = vc WITH noconstant(" "), public
 DECLARE multi_select = vc WITH constant("Multiple Selected")
 DECLARE any_all_select = vc WITH constant("All Qualifying Records")
 DECLARE rpt_output_detail = i2 WITH constant(1), protect
 DECLARE rpt_output_summary_item = i2 WITH constant(2), protect
 DECLARE rpt_output_summary_load_script = i2 WITH constant(3), protect
 DECLARE rpt_output_type = i2 WITH noconstant(0), protect
 SET exec_date_str = concat("Execution Date/Time:  ",format(cnvtdatetime(curdate,curtime),
   "@SHORTDATETIME"))
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE index = i4 WITH noconstant(0), public
 DECLARE ld_failure_flag = i4 WITH noconstant(0), public
 DECLARE display_message = vc WITH noconstant(" "), public
 DECLARE logmsg(mymsg=vc,msglvl=i2(value,2)) = null
 DECLARE logrecord(myrecstruct=vc(ref)) = null
 DECLARE finalizemsgs(outdest=vc(value,""),recsizezflag=i4(value,1)) = null
 DECLARE catcherrors(mymsg=vc) = i2
 DECLARE getreply(null) = vc
 DECLARE geterrorcount(null) = i4
 DECLARE getcodewithcheck(type=vc,code_set=i4(value,0),expression=vc(value,""),msglvl=i2(value,2)) =
 f8
 DECLARE setreply(mystat=vc) = null
 DECLARE populatesubeventstatus(errorcnt=i4(value),operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) = i2
 DECLARE writemlgmsg(msg=vc,lvl=i2) = null
 DECLARE ccps_json = i2 WITH protect, constant(0)
 DECLARE ccps_xml = i2 WITH protect, constant(1)
 DECLARE ccps_rec_listing = i2 WITH protect, constant(2)
 DECLARE ccps_info_domain = vc WITH protect, constant("CCPS_SCRIPT_LOGGING")
 DECLARE ccps_none_ind = i2 WITH protect, constant(0)
 DECLARE ccps_file_ind = i2 WITH protect, constant(1)
 DECLARE ccps_msgview_ind = i2 WITH protect, constant(2)
 DECLARE ccps_listing_ind = i2 WITH protect, constant(3)
 DECLARE ccps_log_error = i2 WITH protect, constant(0)
 DECLARE ccps_log_audit = i2 WITH protect, constant(2)
 DECLARE ccps_error_disp = vc WITH protect, noconstant("ERROR")
 DECLARE ccps_audit_disp = vc WITH protect, noconstant("AUDIT")
 DECLARE ccps_serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ccps_ierrcode = i4 WITH protect, noconstant(error(ccps_serrmsg,1))
 EXECUTE msgrtl
 IF ( NOT (validate(debug_values)))
  RECORD debug_values(
    1 log_program_name = vc
    1 log_file_dest = vc
    1 inactive_dt_tm = vc
    1 log_level = i2
    1 log_level_override = i2
    1 logging_on = i2
    1 rec_format = i2
    1 suppress_rec = i2
    1 suppress_msg = i2
    1 debug_method = i4
  ) WITH protect
  SET debug_values->logging_on = false
  SET debug_values->log_program_name = curprog
 ENDIF
 IF ( NOT (validate(ccps_log)))
  RECORD ccps_log(
    1 ecnt = i4
    1 cnt = i4
    1 qual[*]
      2 msg = vc
      2 msg_type_id = i4
      2 msg_type_display = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL setreply("F")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=ccps_info_domain
    AND (dm.info_name=debug_values->log_program_name)
    AND dm.info_date >= cnvtdatetime(curdate,curtime3))
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0, component_cnt = 0, entity = trim(piece(dm.info_char,",",(entity_cnt+ 1),
     "Not Found"),3),
   component = fillstring(4000," ")
   WHILE (component != "Not Found")
     component_cnt = (component_cnt+ 1), component = trim(piece(entity,";",component_cnt,"Not Found"),
      3), component_head = trim(piece(cnvtlower(component),":",1,"Not Found"),3),
     component_value = trim(piece(component,":",2,"Not Found"),3)
     CASE (component_head)
      OF "program":
       debug_values->log_program_name = component_value
      OF "debug_method":
       IF (component_value="None")
        debug_values->debug_method = ccps_none_ind
       ELSEIF (component_value="File")
        debug_values->debug_method = ccps_file_ind
       ELSEIF (component_value="Message View")
        debug_values->debug_method = ccps_msgview_ind
       ELSEIF (component_value="Listing")
        debug_values->debug_method = ccps_listing_ind
       ENDIF
      OF "file_name":
       debug_values->log_file_dest = component_value
      OF "inactive_dt_tm":
       debug_values->inactive_dt_tm = component_value
      OF "rec_type":
       debug_values->rec_format = cnvtint(component_value)
      OF "suppress_rec":
       debug_values->suppress_rec = cnvtint(component_value)
      OF "suppress_msg":
       debug_values->suppress_msg = cnvtint(component_value)
     ENDCASE
   ENDWHILE
   IF ((debug_values->debug_method != ccps_none_ind))
    debug_values->logging_on = true
   ELSE
    debug_values->logging_on = false
   ENDIF
  FOOT  dm.info_name
   null
  WITH nocounter
 ;end select
 IF (validate(ccps_debug))
  IF ( NOT (validate(ccps_file)))
   SET debug_values->log_file_dest = build(debug_values->log_program_name,"_DBG.dat")
  ENDIF
  IF ( NOT (validate(ccps_rec_format)))
   IF (ccps_debug != ccps_listing_ind)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ELSE
   IF (ccps_rec_format=ccps_xml)
    SET debug_values->rec_format = ccps_xml
   ELSEIF (ccps_rec_format=ccps_json)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_rec)))
   SET debug_values->suppress_rec = false
  ELSE
   IF (ccps_suppress_rec=true)
    SET debug_values->suppress_rec = true
   ELSE
    SET debug_values->suppress_rec = false
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_msg)))
   SET debug_values->suppress_msg = false
  ELSE
   IF (ccps_suppress_msg=true)
    SET debug_values->suppress_msg = true
   ELSE
    SET debug_values->suppress_msg = false
   ENDIF
  ENDIF
  CASE (ccps_debug)
   OF ccps_none_ind:
    SET debug_values->debug_method = ccps_none_ind
    SET debug_values->logging_on = false
   OF ccps_file_ind:
    SET debug_values->debug_method = ccps_file_ind
    SET debug_values->logging_on = true
   OF ccps_msgview_ind:
    SET debug_values->debug_method = ccps_msgview_ind
    SET debug_values->logging_on = true
   OF ccps_listing_ind:
    SET debug_values->debug_method = ccps_listing_ind
    SET debug_values->logging_on = true
  ENDCASE
 ENDIF
 IF (debug_values->logging_on)
  CALL echo("****************************")
  CALL echo("*** Logging is turned ON ***")
  CALL echo("****************************")
  CASE (debug_values->debug_method)
   OF ccps_file_ind:
    CALL echo(build("*** Will write to file: ",debug_values->log_file_dest,"***"))
   OF ccps_msgview_ind:
    CALL echo("*****************************")
    CALL echo("*** Will write to MsgView ***")
    CALL echo("*****************************")
   OF ccps_listing_ind:
    CALL echo("*********************************")
    CALL echo("*** Will write to the listing ***")
    CALL echo("*********************************")
  ENDCASE
  IF ((debug_values->suppress_rec=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Rec is ON  ***")
   CALL echo("****************************")
  ENDIF
  IF ((debug_values->suppress_msg=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Msg is ON  ***")
   CALL echo("****************************")
  ENDIF
 ELSE
  CALL echo("*****************************")
  CALL echo("*** Logging is turned OFF ***")
  CALL echo("*****************************")
 ENDIF
 SUBROUTINE logmsg(mymsg,msglvl)
   DECLARE seek_retval = i4 WITH private, noconstant
   DECLARE filelen = i4 WITH private, noconstant
   DECLARE write_stat = i2 WITH private, noconstant
   DECLARE imsglvl = i2 WITH private, noconstant
   DECLARE smsglvl = vc WITH private, noconstant
   DECLARE slogtext = vc WITH private, noconstant("")
   DECLARE start_char = i4 WITH private, noconstant
   SET imsglvl = msglvl
   SET slogtext = mymsg
   IF ((((debug_values->suppress_msg=false)) OR ((debug_values->suppress_msg=true)
    AND msglvl=ccps_log_error)) )
    IF (((imsglvl=ccps_log_error) OR ((debug_values->logging_on=true))) )
     SET ccps_log->cnt = (ccps_log->cnt+ 1)
     IF (msglvl=ccps_log_error)
      SET ccps_log->ecnt = (ccps_log->ecnt+ 1)
     ENDIF
     SET stat = alterlist(ccps_log->qual,ccps_log->cnt)
     SET ccps_log->qual[ccps_log->cnt].msg = trim(mymsg,3)
     SET ccps_log->qual[ccps_log->cnt].msg_type_id = msglvl
     IF (msglvl=ccps_log_error)
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_error_disp
     ELSE
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_audit_disp
     ENDIF
    ENDIF
    CASE (imsglvl)
     OF ccps_log_error:
      SET smsglvl = "Error"
     OF ccps_log_audit:
      SET smsglvl = "Audit"
    ENDCASE
    IF (imsglvl=ccps_log_error)
     CALL writemlgmsg(slogtext,imsglvl)
     CALL populatesubeventstatus(ccps_log->ecnt,ccps_error_disp,"F",build(curprog),trim(mymsg,3))
    ENDIF
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_msgview_ind)
      AND msglvl != ccps_log_error)
      CALL writemlgmsg(slogtext,imsglvl)
     ELSEIF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsglvl,
        "}",fillstring(5," "),mymsg))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logrecord(myrecstruct)
   IF ((debug_values->suppress_rec=false))
    DECLARE smsgtype = vc WITH private, noconstant
    DECLARE write_stat = i4 WITH private, noconstant
    SET smsgtype = "Audit"
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsgtype,"}",
       fillstring(5," "))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct,debug_values->log_file_dest,1)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct,debug_values->log_file_dest,1)
      ELSE
       CALL echorecord(myrecstruct,debug_values->log_file_dest,1)
      ENDIF
      SET frec->file_buf = build(frec->file_buf,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsgtype,
        "}",fillstring(5," ")))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct)
      ELSE
       CALL echorecord(myrecstruct)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE catcherrors(mymsg)
   DECLARE ccps_ierroroccurred = i2 WITH private, noconstant(0)
   SET ccps_ierrcode = error(ccps_serrmsg,0)
   WHILE (ccps_ierrcode > 0
    AND (ccps_log->ecnt < 50))
     SET ccps_ierroroccurred = 1
     CALL logmsg(trim(build2(mymsg," -- ",trim(ccps_serrmsg,3)),3),ccps_log_error)
     SET ccps_ierrcode = error(ccps_serrmsg,1)
   ENDWHILE
   RETURN(ccps_ierroroccurred)
 END ;Subroutine
 SUBROUTINE geterrorcount(null)
   RETURN(ccps_log->ecnt)
 END ;Subroutine
 SUBROUTINE finalizemsgs(outdest,recsizezflag)
   DECLARE errcnt = i4 WITH noconstant, private
   SET stat = catcherrors("Performing final check for errors...")
   SET errcnt = geterrorcount(null)
   IF (errcnt > 0)
    CALL setreply("F")
   ELSEIF (recsizezflag=0)
    CALL setreply("Z")
   ELSE
    CALL setreply("S")
   ENDIF
   IF ((ccps_log->ecnt > 0)
    AND cnvtstring(outdest) != "")
    SELECT INTO value(outdest)
     FROM (dummyt d  WITH seq = ccps_log->cnt)
     PLAN (d
      WHERE (ccps_log->qual[d.seq].msg_type_id=ccps_log_error))
     HEAD REPORT
      CALL print(build2(
       "*** Errors have occurred in the CCL Script.  Please contact your System Administrator ",
       "and/or Cerner for assistance with resolving the issue. ***",char(13),char(10),char(13),
       char(10)))
     DETAIL
      CALL print(ccps_log->qual[d.seq].msg), row + 1
     FOOT REPORT
      null
     WITH nocounter, maxcol = 500
    ;end select
   ENDIF
   IF ((debug_values->debug_method=ccps_listing_ind))
    CALL echo("********************************")
    CALL echo("*** Printing Logging Summary ***")
    CALL echo("********************************")
    CALL logrecord(ccps_log)
    CALL logrecord(reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE setreply(mystat)
   IF (validate(reply->status_data.status)=1)
    SET reply->status_data.status = mystat
   ENDIF
 END ;Subroutine
 SUBROUTINE getreply(null)
   IF (validate(reply->status_data.status)=1)
    RETURN(reply->status_data.status)
   ELSE
    RETURN("Z")
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodewithcheck(type,code_set,expression,msglvl)
   DECLARE cki_flag = i2 WITH private, noconstant(0)
   IF (code_set=0)
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by_cki(type))
    SET cki_flag = 1
   ELSE
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by(type,code_set,expression))
   ENDIF
   IF (tmp_code_value <= 0)
    IF (cki_flag=0)
     CALL logmsg(build2("*** ! Code value from code set ",trim(cnvtstring(code_set),3)," with ",type,
       " of ",
       expression," was not found !"),msglvl)
    ELSE
     CALL logmsg(build2("*** ! Code value with CKI of ",type," was not found !"),msglvl)
    ENDIF
   ENDIF
   RETURN(tmp_code_value)
 END ;Subroutine
 SUBROUTINE populatesubeventstatus(errorcnt,operationname,operationstatus,targetobjectname,
  targetobjectvalue)
   DECLARE ccps_isubeventcnt = i4 WITH protect, noconstant(0)
   DECLARE ccps_isubeventsize = i4 WITH protect, noconstant(0)
   IF (validate(reply->ops_event)=1
    AND errorcnt=1)
    SET reply->ops_event = targetobjectvalue
   ENDIF
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET ccps_isubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (ccps_isubeventcnt > 0)
     SET ccps_isubeventsize = size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       operationname))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].operationstatus)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectname)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectvalue)))
    ENDIF
    IF (ccps_isubeventsize > 0)
     SET ccps_isubeventcnt = (ccps_isubeventcnt+ 1)
     SET iloggingstat = alter(reply->status_data.subeventstatus,ccps_isubeventcnt)
    ENDIF
    IF (ccps_isubeventcnt > 0)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationname = substring(1,25,
      operationname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationstatus = substring(1,1,
      operationstatus)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectname = substring(1,25,
      targetobjectname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectvalue = targetobjectvalue
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE writemlgmsg(msg,lvl)
   DECLARE sys_handle = i4 WITH noconstant(0), private
   DECLARE sys_status = i4 WITH noconstant(0), private
   CALL uar_syscreatehandle(sys_handle,sys_status)
   IF (sys_handle > 0)
    CALL uar_msgsetlevel(sys_handle,lvl)
    CALL uar_sysevent(sys_handle,lvl,nullterm(debug_values->log_program_name),nullterm(msg))
    CALL uar_sysdestroyhandle(sys_handle)
   ENDIF
 END ;Subroutine
 SET lastmod = "001  9/11/12   ML011047"
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(ccps_records)))
  RECORD ccps_records(
    1 cnt = i4
    1 list[*]
      2 name = vc
    1 num = i4
  ) WITH persistscript
 ENDIF
 DECLARE ispromptany(which_prompt=i2) = i2
 SUBROUTINE ispromptany(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptlist(which_prompt=i2) = i2
 SUBROUTINE ispromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptsingle(which_prompt=i2) = i2
 SUBROUTINE ispromptsingle(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptempty(which_prompt=i2) = i2
 SUBROUTINE ispromptempty(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptlist(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptlist(which_prompt,which_column,which_option)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE option_str = vc WITH noconstant(""), private
   DECLARE return_val = vc WITH noconstant("0=1"), private
   IF (which_option=list_not_in)
    SET option_str = " NOT IN ("
   ELSE
    SET option_str = " IN ("
   ENDIF
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    SET return_val = concat("(",which_column,option_str)
    FOR (item_num = 1 TO count)
     IF (mod(item_num,1000)=1
      AND item_num > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     IF (substring(1,1,reflect(parameter(which_prompt,item_num)))="C")
      SET return_val = concat(return_val,"'",value(parameter(which_prompt,item_num)),"'",",")
     ELSE
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),",")
     ENDIF
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptexpand(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptexpand(which_prompt,which_column,which_option)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (((ispromptlist(which_prompt)) OR (ispromptsingle(which_prompt))) )
    SET record_name = getpromptrecord(which_prompt,which_column)
    IF (textlen(trim(record_name,3)) > 0)
     SET return_val = createexpandparser(which_column,record_name,which_option)
    ENDIF
   ENDIF
   CALL logmsg(concat("GetPromptExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptrecord(which_prompt=i2,which_rec=vc) = vc
 SUBROUTINE getpromptrecord(which_prompt,which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH private, noconstant(0)
   DECLARE item_num = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE alias_parser = vc WITH private, noconstant(" ")
   DECLARE cnt_parser = vc WITH private, noconstant(" ")
   DECLARE alterlist_parser = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF ((( NOT (ispromptany(which_prompt))) OR ( NOT (ispromptempty(which_prompt)))) )
    SET record_name = createrecord(which_rec)
    IF (textlen(trim(record_name,3)) > 0)
     IF (ispromptlist(which_prompt))
      SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
     ELSEIF (ispromptsingle(which_prompt))
      SET count = 1
     ENDIF
     IF (count > 0)
      SET alias_parser = concat("set curalias = which_rec_alias ",record_name,"->list[idx] go")
      SET cnt_parser = build2("set ",record_name,"->cnt = ",count," go")
      SET alterlist_parser = build2("set stat = alterlist(",record_name,"->list,",record_name,
       "->cnt) go")
      SET data_type = cnvtupper(substring(1,1,reflect(parameter(which_prompt,1))))
      SET data_type_parser = concat("set ",record_name,"->data_type = '",data_type,"' go")
      CALL parser(alias_parser)
      CALL parser(cnt_parser)
      CALL parser(alterlist_parser)
      CALL parser(data_type_parser)
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alterlist_parser = ",alterlist_parser))
      CALL logmsg(concat("GetPromptRecord: data_type_parser = ",data_type_parser))
      FOR (item_num = 1 TO count)
       SET idx = (idx+ 1)
       CASE (data_type)
        OF "I":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "F":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "C":
         SET which_rec_alias->string = value(parameter(which_prompt,item_num))
       ENDCASE
      ENDFOR
      SET cnt_parser = concat(record_name,"->cnt")
      IF (validate(parser(cnt_parser),0) > 0)
       SET return_val = record_name
      ELSE
       CALL cclexception(999,"E","GetPromptRecord: failed to add the prompt values to the new record"
        )
      ENDIF
      SET alias_parser = concat("set curalias which_rec_alias off go")
      CALL parser(alias_parser)
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
     ELSE
      CALL logmsg("GetPromptRecord: zero records found")
     ENDIF
    ENDIF
   ELSE
    CALL logmsg("GetPromptRecord: prompt value is any(*) or empty")
   ENDIF
   IF (textlen(trim(record_name,3)) > 0)
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logmsg(concat("GetPromptRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in GetPromptRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createrecord(which_rec=vc(value,"")) = vc
 SUBROUTINE createrecord(which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE record_parser = vc WITH private, noconstant(" ")
   DECLARE new_record_ind = i2 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF (textlen(trim(which_rec,3)) > 0)
    IF (findstring(".",which_rec,1,0) > 0)
     SET record_name = concat("ccps_",trim(which_rec,3),"_rec")
    ELSE
     SET record_name = trim(which_rec,3)
    ENDIF
   ELSE
    SET record_name = build("ccps_temp_",(ccps_records->cnt+ 1),"_rec")
   ENDIF
   SET record_name = concat(trim(replace(record_name,concat(
       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 !"#$%&',
       "'()*+,-./:;<=>?@[\]^_`{|}~"),concat(
       "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_______",
       "__________________________"),3),3))
   CALL logmsg(concat("CreateRecord: record_name = ",record_name))
   IF ( NOT (validate(parser(record_name))))
    SET record_parser = concat("record ",record_name," (1 cnt = i4",
     " 1 list[*] 2 string = vc 2 number = f8"," 1 data_type = c1 1 num = i4)",
     " with persistscript go")
    CALL logmsg(concat("CreateRecord: record parser = ",record_parser))
    CALL parser(record_parser)
    IF (validate(parser(record_name)))
     SET return_val = record_name
     SET ccps_records->cnt = (ccps_records->cnt+ 1)
     SET stat = alterlist(ccps_records->list,ccps_records->cnt)
     SET ccps_records->list[ccps_records->cnt].name = record_name
    ELSE
     CALL cclexception(999,"E","CreateRecord: failed to create record")
    ENDIF
   ELSE
    CALL cclexception(999,"E","CreateRecord: record already exists")
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logrecord(ccps_records)
   CALL logmsg(concat("CreateRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createexpandparser(which_column=vc,which_rec=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE createexpandparser(which_column,which_rec,which_option)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE record_member = vc WITH private, noconstant(" ")
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   IF (validate(parser(which_rec)))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET data_type_parser = concat("set data_type = ",which_rec,"->data_type go")
    CALL parser(data_type_parser)
    CASE (data_type)
     OF "I":
      SET record_member = "number"
     OF "F":
      SET record_member = "number"
     OF "C":
      SET record_member = "string"
    ENDCASE
    SET return_val = build(option_str," expand(",which_rec,"->num",",",
     "1,",which_rec,"->cnt,",which_column,",",
     which_rec,"->list[",which_rec,"->num].",record_member,
     ")")
   ELSE
    CALL logmsg(concat("CreateExpandParser: ",which_rec," does not exist"))
   ENDIF
   CALL logmsg(concat("CreateExpandParser: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateExpandParser()")
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("sc_cps_get_prompt_list 007 11/02/2012 ML011047")
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ld_concept_person = i2 WITH public, constant(1)
 DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 DECLARE ld_concept_organization = i2 WITH public, constant(3)
 DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 DECLARE ld_concept_encounter = i2 WITH public, constant(6)
 DECLARE ld_concept_location = i2 WITH public, constant(7)
 DECLARE ld_concept_pft_encntr = i2 WITH public, constant(8)
 DECLARE ld_concept_billing = i2 WITH public, constant(9)
 DECLARE invalid_printer = i2 WITH public, constant(1)
 DECLARE invalid_user = i2 WITH public, constant(2)
 DECLARE invalid_ld = i2 WITH public, constant(3)
 DECLARE ops_scheduler = i4 WITH public, constant(4600)
 DECLARE ops_monitor = i4 WITH public, constant(4700)
 DECLARE ops_server = i4 WITH public, constant(4800)
 DECLARE isopsjob = i2 WITH public, constant(isopsexecution(null))
 DECLARE ismine = i2 WITH public, constant(ismine(null))
 DECLARE logical_domain_error = i4 WITH public, noconstant(0)
 DECLARE cur_logical_domain = f8 WITH public, constant(getcurrentlogicaldomain(reqinfo->updt_id))
 IF (cur_logical_domain < 0)
  SET logical_domain_error = cnvtint(abs(cur_logical_domain))
 ENDIF
 IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
  IF (ispromptsingle(1)
   AND substring(1,1,reflect(parameter(1,1)))="C")
   IF ( NOT (isprinterindomain(value(parameter(1,0)),cur_logical_domain)))
    SET logical_domain_error = invalid_printer
   ENDIF
  ENDIF
 ENDIF
 DECLARE isuserindomain(user_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isuserindomain(user_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("PRSNL","LOGICAL_DOMAIN_ID")), protect
   DECLARE user_domain_grp_id = f8 WITH noconstant(0.0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE p.person_id=user_id)
     HEAD p.person_id
      user_domain_grp_id = p.logical_domain_grp_id
      IF (user_domain_grp_id=0.0)
       IF (p.logical_domain_id=log_domain_id)
        return_val = 1
       ELSE
        return_val = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (user_domain_grp_id > 0.0)
     SELECT INTO "nl:"
      FROM logical_domain_grp_reltn ld
      PLAN (ld
       WHERE ld.logical_domain_grp_id=user_domain_grp_id
        AND ld.active_ind=1
        AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      HEAD ld.logical_domain_grp_id
       return_val = 0
      HEAD ld.logical_domain_id
       IF (ld.logical_domain_id=log_domain_id)
        return_val = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorgindomain(org_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isorgindomain(org_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      IF (o.logical_domain_id=log_domain_id)
       return_val = 1
      ELSE
       return_val = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorginuserdomain(org_id=f8,user_id=f8) = i2
 SUBROUTINE isorginuserdomain(org_id,user_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE org_domain_id = f8 WITH noconstant(0.0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      org_domain_id = o.logical_domain_id
     WITH nocounter
    ;end select
    SET return_val = isuserindomain(user_id,org_domain_id)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE islogicaldomainsactive(null) = i2
 SUBROUTINE islogicaldomainsactive(null)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("LOGICAL_DOMAIN","LOGICAL_DOMAIN_ID")),
   protect
   DECLARE ld_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.logical_domain_id > 0.0
       AND ld.active_ind=1)
     ORDER BY ld.logical_domain_id
     HEAD ld.logical_domain_id
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE column_exists(stable=vc,scolumn=vc) = i4
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE ce_temp = vc WITH noconstant(""), protect
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getcurrentlogicaldomain(user_id=f8(value,0.0)) = f8
 SUBROUTINE getcurrentlogicaldomain(user_id)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   IF (isopsjob)
    SET return_val = getopslogicaldomain(null)
   ELSE
    IF (islogicaldomainsactive(null))
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE p.person_id=user_id)
      HEAD p.person_id
       return_val = p.logical_domain_id
      WITH nocounter
     ;end select
     IF (curqual <= 0)
      SET return_val = - (2.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getCurrentLogicalDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("User ",trim(cnvtstring(
         user_id),3)," is not related to a Logical Domain.")
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getopslogicaldomain(null) = f8
 SUBROUTINE getopslogicaldomain(null)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   DECLARE last_prompt = i4 WITH noconstant(0), protect
   DECLARE ld_prompt_val = vc WITH noconstant(""), protect
   DECLARE ld_prompt_prefix = vc WITH noconstant(""), protect
   DECLARE ld_prompt_id = vc WITH noconstant(""), protect
   IF (isopsjob)
    IF (islogicaldomainsactive(null))
     WHILE (textlen(trim(reflect(parameter((last_prompt+ 1),0)),3)) > 0)
       SET last_prompt = (last_prompt+ 1)
     ENDWHILE
     IF (last_prompt > 0
      AND ispromptsingle(last_prompt)
      AND substring(1,1,reflect(parameter(last_prompt,1)))="C")
      SET ld_prompt_val = trim(check(cnvtupper(value(parameter(last_prompt,1))),char(40)),3)
      SET ld_prompt_prefix = substring(1,3,ld_prompt_val)
      IF (ld_prompt_prefix="LD:")
       SET return_val = - (3.0)
       SET ld_prompt_id = substring(4,(textlen(ld_prompt_val) - 3),ld_prompt_val)
       IF (isnumeric(ld_prompt_id))
        SELECT INTO "nl:"
         FROM logical_domain ld
         PLAN (ld
          WHERE ld.logical_domain_id=cnvtreal(ld_prompt_id)
           AND ld.active_ind=1)
         ORDER BY ld.logical_domain_id
         HEAD ld.logical_domain_id
          return_val = ld.logical_domain_id
         WITH nocounter
        ;end select
       ENDIF
       IF ((return_val=- (3.0)))
        SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Logical Domain ID ",
         ld_prompt_id," is not valid.")
       ENDIF
      ELSE
       SET return_val = - (3.0)
       SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
        "Batch Selection is Missing the ","Logical Domain Prefix, e.g., 'LD:'.")
      ENDIF
     ELSE
      SET return_val = - (3.0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
       "Batch Selection is Missing the ","Logical Domain Prefix and ID, e.g., ","'LD:1234.00'.")
     ENDIF
     IF (return_val < 0.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getOpsLogicalDomain"
     ENDIF
    ENDIF
   ELSE
    SET return_val = - (2.0)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ismine(null) = i2
 SUBROUTINE ismine(null)
   DECLARE return_val = i2 WITH noconstant(0), private
   IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
    IF (ispromptsingle(1)
     AND substring(1,1,reflect(parameter(1,1)))="C")
     IF (((cnvtupper(validate(request->qual[1].parameter,"NOT MINE"))="MINE") OR (cnvtupper(trim(
       check(value(parameter(1,1)),char(40)),3))="MINE")) )
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isprinterindomain(output_dest=vc,log_domain_id=f8) = i2
 SUBROUTINE isprinterindomain(output_dest,log_domain_id)
   DECLARE cur_printer = vc WITH constant(trim(check(output_dest,char(40)),3)), protect
   DECLARE isvalid = i2 WITH noconstant(0), protect
   IF (islogicaldomainsactive(null))
    IF (checkqueue(cur_printer))
     SELECT INTO "nl:"
      FROM output_dest od,
       device d,
       location l,
       organization o
      PLAN (od
       WHERE od.name=cur_printer)
       JOIN (d
       WHERE d.device_cd=od.device_cd)
       JOIN (l
       WHERE l.location_cd=d.location_cd
        AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND l.active_ind=1)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=log_domain_id
        AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND o.active_ind=1)
      ORDER BY o.logical_domain_id
      HEAD REPORT
       isvalid = 1
      WITH nocounter
     ;end select
     IF ( NOT (isvalid)
      AND  NOT (logical_domain_error))
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "IsPrinterInDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Printer ",cur_printer,
       " is not valid ","for Logical Domain ID ",trim(cnvtstring(log_domain_id),3),
       ".")
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE getldconceptparser(pconcept=i2,pfield=vc,plogicaldomainid=f8,pprompt=i2(value,0),poption=i2(
   value,list_in)) = vc
 SUBROUTINE getldconceptparser(pconcept,pfield,plogicaldomainid,pprompt,poption)
   DECLARE return_val = vc WITH private, noconstant("1=1")
   IF (pprompt > 0)
    IF ( NOT (ispromptempty(pprompt))
     AND  NOT (ispromptany(pprompt)))
     SET return_val = getpromptlist(pprompt,pfield,poption)
    ENDIF
   ENDIF
   CASE (pconcept)
    OF ld_concept_person:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from person p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_prsnl:
     IF (column_exists("PRSNL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from prsnl p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_organization:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from organization o_ld",
       " where o_ld.organization_id = ",
       pfield," and o_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_healthplan:
     IF (column_exists("HEALTH_PLAN","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from health_plan hp_ld",
       " where hp_ld.health_plan_id = ",
       pfield," and hp_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_alias_pool:
     IF (column_exists("ALIAS_POOL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from alias_pool ap_ld",
       " where ap_ld.alias_pool_cd = ",
       pfield," and ap_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_encounter:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from encounter e_ld, person p_ld"," where e_ld.encntr_id = ",
       pfield," and p_ld.person_id = e_ld.person_id"," and p_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_location:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from location l_ld, organization o_ld"," where l_ld.location_cd = ",
       pfield," and o_ld.organization_id = l_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_pft_encntr:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from pft_encntr pe_ld, encounter e_ld, person p_ld"," where pe_ld.pft_encntr_id = ",
       pfield," and e_ld.encntr_id = pe_ld.encntr_id"," and p_ld.person_id = e_ld.person_id",
       " and p_ld.logical_domain_id = ",plogicaldomainid,
       ")")
     ENDIF
    OF ld_concept_billing:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from billing_entity be_ld, organization o_ld"," where be_ld.billing_entity_id = ",
       pfield," and o_ld.organization_id = be_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    ELSE
     SET return_val = "0=1"
   ENDCASE
   RETURN(return_val)
 END ;Subroutine
 DECLARE isopsexecution(null) = i2
 SUBROUTINE isopsexecution(null)
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (validate(reqinfo->updt_app,- (1)) IN (ops_scheduler, ops_monitor, ops_server))
    SET return_val = true
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(cs278_facility)))
  DECLARE cs278_facility = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4977"))
 ENDIF
 IF ( NOT (validate(cs278_client)))
  DECLARE cs278_client = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4974"))
 ENDIF
 IF ( NOT (validate(ccps_org_sec_rec)))
  RECORD ccps_org_sec_rec(
    1 cnt = i4
    1 list[*]
      2 organization_id = f8
      2 logical_domain_id = f8
      2 name = vc
    1 prsnl_id = f8
    1 org_type_cd = f8
    1 num = i4
  )
 ENDIF
 DECLARE isencntrorgsecurityon(null) = i2
 SUBROUTINE isencntrorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_ORG_RELTN"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isconfidentialitysecurityon(null) = i2
 SUBROUTINE isconfidentialitysecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_confid > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_CONFID"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispersonorgsecurityon(null) = i2
 SUBROUTINE ispersonorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->person_org_sec > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="PERSON_ORG_SEC"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorglist(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorglist(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET return_val = concat("(",which_column,option_str)
    FOR (idx = 1 TO ccps_org_sec_rec->cnt)
     IF (mod(idx,1000)=1
      AND idx > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     SET return_val = build(return_val,ccps_org_sec_rec->list[idx].organization_id,",")
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgList: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgexpand(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorgexpand(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET return_val = build(option_str," expand(ccps_org_sec_rec->num,","1,","ccps_org_sec_rec->cnt,",
     which_column,
     ",","ccps_org_sec_rec->list[ccps_org_sec_rec->num].organization_id)")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgrecord(prsnl_id=f8,org_type_cd=f8(value,cs278_facility)) = i2
 SUBROUTINE getprsnlorgrecord(prsnl_id,org_type_cd)
   DECLARE return_val = i2 WITH private, noconstant(0)
   SET ccps_org_sec_rec->prsnl_id = prsnl_id
   SET ccps_org_sec_rec->org_type_cd = org_type_cd
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     organization o,
     org_type_reltn otr
    PLAN (por
     WHERE por.person_id=prsnl_id
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND o.active_ind=1)
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND ((otr.org_type_cd+ 0)=org_type_cd)
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND otr.active_ind=1)
    ORDER BY por.organization_id
    HEAD REPORT
     cnt = 0
    HEAD por.organization_id
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(ccps_org_sec_rec->list,(cnt+ 9))
     ENDIF
     ccps_org_sec_rec->list[cnt].organization_id = o.organization_id, ccps_org_sec_rec->list[cnt].
     logical_domain_id = o.logical_domain_id, ccps_org_sec_rec->list[cnt].name = trim(o.org_name,3)
    FOOT REPORT
     ccps_org_sec_rec->cnt = cnt, stat = alterlist(ccps_org_sec_rec->list,cnt)
    WITH nocounter
   ;end select
   IF ((ccps_org_sec_rec->cnt > 0))
    SET return_val = 1
   ELSE
    CALL logmsg("GetPrsnlOrgRecord: zero records qualified")
   ENDIF
   CALL logrecord(ccps_org_sec_rec)
   CALL logmsg(build("GetPrsnlOrgRecord: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("ccps_org_security 001 10/26/2012 ML011047")
 DECLARE isldactive = i2 WITH constant(islogicaldomainsactive(null)), protect
 DECLARE ld_parser = vc WITH noconstant("0=1"), protect
 DECLARE organization_parser = vc WITH noconstant("0=1"), protect
 DECLARE ld_failure_flag = i4 WITH noconstant(0), protect
 DECLARE display_message = vc WITH noconstant(" "), protect
 IF (logical_domain_error)
  SET display_message = reply->status_data.subeventstatus[1].targetobjectvalue
  SET ld_failure_flag = 1
  GO TO exit_prg
 ENDIF
 DECLARE createldorgparsers(prsnl_id=f8,ld_column=vc,org_prompt=i2,org_column=vc,which_option=i2(
   value,list_in)) = null
 SUBROUTINE createldorgparsers(prsnl_id,ld_column,org_prompt,org_column,which_option)
   DECLARE ld_mismatch = i2 WITH protect, noconstant(0)
   DECLARE org_cnt = i4 WITH protect, noconstant(0)
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (isldactive)
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o,
        logical_domain ld
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
        JOIN (ld
        WHERE ld.logical_domain_id=o.logical_domain_id
         AND ld.active_ind=1)
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0, cs_logical_domain_id = 0.0
       DETAIL
        IF (cs_logical_domain_id=0.0)
         cs_logical_domain_id = o.logical_domain_id
        ELSE
         IF (cs_logical_domain_id != o.logical_domain_id)
          ld_mismatch = 1
         ENDIF
        ENDIF
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF (ld_mismatch=1)
       SET display_message = build2(
        "Logical domains are in use. Please verify each organization ID shares ",
        "the same logical_domain_id when running from operations.")
      ELSEIF ((org_cnt != org_prompt_rec->cnt))
       SET display_message = "Please verify each organization ID is valid."
      ELSE
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ENDIF
     ENDIF
    ENDIF
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET ld_parser = build(ld_column,option_str,cur_logical_domain,")")
   ELSE
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0
       DETAIL
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF ((org_cnt=org_prompt_rec->cnt))
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ELSE
       SET display_message = "Please verify each organization ID is valid."
      ENDIF
     ENDIF
    ENDIF
    SET ld_parser = "1=1"
   ENDIF
   IF (validate(org_prompt_rec))
    CALL logrecord(org_prompt_rec)
   ENDIF
   CALL logmsg(build2("* * * ld_parser is:     ",ld_parser))
   CALL logmsg(build2("* * * ORGANIZATION_PARSER is:     ",organization_parser))
   CALL logmsg(build2("* * * display_message is:     ",display_message))
   CALL logmsg(build2("* * * is opsjob:     ",isopsjob))
 END ;Subroutine
 CALL logmsg("ccps_cs_security 000 10/26/2012 ML011047")
 CALL createldorgparsers(reqinfo->updt_id,"o.logical_domain_id",2,"c.payor_id")
 IF (((ld_parser="0=1") OR (organization_parser="0=1")) )
  SET ld_failure_flag = 1
  SET display_message = "The logical domain and/or organization security validation failed."
  GO TO exit_prg
 ENDIF
 IF (validate(org_prompt_rec->cnt,0) > 0)
  IF ((org_prompt_rec->cnt > 1))
   SET prompt_organization = multi_select
  ELSE
   SET prompt_organization = org_prompt_rec->list[1].string
  ENDIF
 ELSEIF (validate(ccps_org_sec_rec->cnt,0) > 0)
  SET prompt_organization = any_all_select
 ENDIF
 IF (reflect(parameter(3,0))="I4")
  CASE (cnvtint( $RPT_TYPE))
   OF 1:
    SET rpt_output_type = rpt_output_detail
   OF 2:
    SET rpt_output_type = rpt_output_summary_item
   OF 3:
    SET rpt_output_type = rpt_output_summary_load_script
   ELSE
    SET rpt_output_type = rpt_output_detail
  ENDCASE
 ELSE
  CASE (cnvtstring( $RPT_TYPE))
   OF "Detail":
    SET rpt_output_type = rpt_output_detail
   OF "Summary by Item":
    SET rpt_output_type = rpt_output_summary_item
   OF "Summary by Load Script":
    SET rpt_output_type = rpt_output_summary_load_script
   ELSE
    SET rpt_output_type = rpt_output_detail
  ENDCASE
 ENDIF
 FREE RECORD binf_charges
 RECORD binf_charges(
   1 bc_cnt = i4
   1 bc_detail[*]
     2 ext_i_order_active = i4
     2 ext_p_order_active = i4
     2 task_cat_flag = i4
     2 ext_i_ref_id = f8
     2 ext_i_ref_desc = vc
     2 ext_i_ref_activity_type_cd = f8
     2 ext_p_ref_id = f8
     2 ext_p_ref_desc = vc
     2 ext_p_ref_activity_type_cd = f8
     2 ext_p_ref_cont_cd = f8
     2 ext_p_ref_cont_desc = vc
     2 ext_i_ref_cont_cd = f8
     2 ext_i_ref_cont_desc = vc
     2 display_activity_type = vc
     2 load_script = vc
     2 encntr_cnt = i4
     2 encntr_detail[*]
       3 encntr_id = f8
       3 charge_item_id = f8
       3 fin = vc
 )
 FREE RECORD load_script_summary
 RECORD load_script_summary(
   1 lss_cnt = i4
   1 lss_total_cnt = i4
   1 lss_detail[*]
     2 load_script_text = vc
     2 load_script_text_cnt = i4
 )
 SELECT INTO "nl:"
  FROM charge c,
   organization o,
   charge_mod cm,
   encounter e,
   charge_event ce,
   order_catalog oc1,
   order_catalog oc2,
   order_task ot,
   order_task ot2,
   encntr_alias eafin,
   encntr_combine ec,
   encntr_alias eafin2
  PLAN (c
   WHERE c.process_flg=1
    AND c.interface_file_id=0
    AND c.active_ind=1
    AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND parser(organization_parser))
   JOIN (o
   WHERE o.organization_id=c.payor_id
    AND parser(ld_parser))
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.charge_mod_type_cd=suspense_cd
    AND cm.active_ind=1
    AND cm.field1_id=no_bill_item_cd
    AND cm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id)
   JOIN (ce
   WHERE ce.charge_event_id=c.charge_event_id)
   JOIN (oc1
   WHERE oc1.catalog_cd=outerjoin(ce.ext_i_reference_id))
   JOIN (oc2
   WHERE oc2.catalog_cd=outerjoin(ce.ext_p_reference_id))
   JOIN (ot
   WHERE ot.reference_task_id=outerjoin(ce.ext_p_reference_id))
   JOIN (ot2
   WHERE ot2.reference_task_id=outerjoin(ce.ext_i_reference_id))
   JOIN (eafin
   WHERE eafin.encntr_id=outerjoin(e.encntr_id)
    AND ((eafin.encntr_alias_type_cd+ 0)=outerjoin(ea_type_fin_cd))
    AND eafin.active_ind=outerjoin(1)
    AND eafin.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND eafin.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ec
   WHERE ec.from_encntr_id=outerjoin(c.encntr_id)
    AND ec.active_ind=outerjoin(1))
   JOIN (eafin2
   WHERE eafin2.encntr_id=outerjoin(ec.to_encntr_id)
    AND ((eafin2.encntr_alias_type_cd+ 0)=outerjoin(ea_type_fin_cd))
    AND eafin2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND eafin2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY ce.ext_i_reference_id, ce.ext_p_reference_id, c.charge_item_id,
   eafin.end_effective_dt_tm DESC, eafin2.end_effective_dt_tm DESC
  HEAD REPORT
   bc_cnt = 0
  HEAD ce.ext_i_reference_id
   null
  HEAD ce.ext_p_reference_id
   bc_cnt = (bc_cnt+ 1)
   IF (mod(bc_cnt,50)=1)
    stat = alterlist(binf_charges->bc_detail,(bc_cnt+ 49))
   ENDIF
   binf_charges->bc_detail[bc_cnt].ext_i_order_active = oc1.active_ind, binf_charges->bc_detail[
   bc_cnt].ext_p_order_active = oc2.active_ind, binf_charges->bc_detail[bc_cnt].ext_i_ref_id = ce
   .ext_i_reference_id,
   binf_charges->bc_detail[bc_cnt].ext_i_ref_desc = uar_get_code_display(ce.ext_i_reference_id),
   binf_charges->bc_detail[bc_cnt].ext_i_ref_activity_type_cd = oc1.activity_type_cd, binf_charges->
   bc_detail[bc_cnt].ext_p_ref_id = ce.ext_p_reference_id,
   binf_charges->bc_detail[bc_cnt].ext_p_ref_desc = uar_get_code_display(ce.ext_p_reference_id),
   binf_charges->bc_detail[bc_cnt].ext_p_ref_activity_type_cd = oc2.activity_type_cd, binf_charges->
   bc_detail[bc_cnt].ext_p_ref_cont_cd = ce.ext_p_reference_cont_cd,
   binf_charges->bc_detail[bc_cnt].ext_p_ref_cont_desc = uar_get_code_display(ce
    .ext_p_reference_cont_cd), binf_charges->bc_detail[bc_cnt].ext_i_ref_cont_cd = ce
   .ext_i_reference_cont_cd, binf_charges->bc_detail[bc_cnt].ext_i_ref_cont_desc =
   uar_get_code_display(ce.ext_i_reference_cont_cd)
   IF (ce.ext_i_reference_cont_cd IN (ord_cat_cd, ord_id_cd))
    IF ((binf_charges->bc_detail[bc_cnt].ext_i_order_active=1))
     binf_charges->bc_detail[bc_cnt].load_script = concat("afc_load_gen_lab ",trim(cnvtstring(oc1
        .activity_type_cd)),",1"), binf_charges->bc_detail[bc_cnt].display_activity_type =
     uar_get_code_display(oc1.activity_type_cd)
    ELSE
     binf_charges->bc_detail[bc_cnt].load_script = "log sr to swx"
    ENDIF
   ELSEIF (ce.ext_i_reference_cont_cd IN (task_assay_cd)
    AND ce.ext_p_reference_cont_cd=ord_cat_cd)
    IF ((binf_charges->bc_detail[bc_cnt].ext_p_order_active=1))
     binf_charges->bc_detail[bc_cnt].load_script = concat("afc_load_gen_lab ",trim(cnvtstring(oc2
        .activity_type_cd)),",1"), binf_charges->bc_detail[bc_cnt].display_activity_type =
     uar_get_code_display(oc2.activity_type_cd)
    ELSE
     binf_charges->bc_detail[bc_cnt].load_script = "log sr to swx"
    ENDIF
   ELSEIF (ce.ext_i_reference_cont_cd IN (manf_item_cd, med_def_cd, med_def_flex_cd))
    binf_charges->bc_detail[bc_cnt].load_script = "rxa_load_pharmacy"
   ELSEIF (ce.ext_i_reference_cont_cd=accommodation_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "afc_accommodation_setup"
   ELSEIF (ce.ext_i_reference_cont_cd=appt_type_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "sch_ins_charge_reference"
   ELSEIF (ce.ext_i_reference_cont_cd=him_task_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "him_upd_afc_tables"
   ELSEIF (ce.ext_i_reference_cont_cd=mic_task_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "afc_load_micro 1"
   ELSEIF (ce.ext_i_event_cont_cd IN (mic_bio_rslt_cd, mic_sus_det_cd, mic_sus_rslt_cd, mic_task_cd,
   mic_task_log_cd))
    binf_charges->bc_detail[bc_cnt].load_script = "afc_load_micro 1"
   ELSEIF (ce.ext_i_reference_cont_cd IN (bb_antibody_cd, bb_antigen_cd))
    binf_charges->bc_detail[bc_cnt].load_script =
    "Build Billing Database (Antigen Antibody Relationships)"
   ELSEIF (ce.ext_i_reference_cont_cd IN (bb_modify_cd, bb_modify_fee_cd))
    binf_charges->bc_detail[bc_cnt].load_script = "Build Billing Database (Modification Tool)"
   ELSEIF (ce.ext_i_reference_cont_cd=bb_product_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "Build Billing Database (Product Tool)"
   ELSEIF (ce.ext_i_reference_cont_cd IN (bb_phase_cd, bb_pool_cd, bb_pool_fee_cd, bb_result_cd,
   bb_spec_test_cd))
    binf_charges->bc_detail[bc_cnt].load_script = concat("Build Billing Database (bbdbtools.exe) - ",
     uar_get_code_display(ce.ext_i_reference_cont_cd))
   ELSEIF (ce.ext_i_reference_cont_cd IN (coll_act_cd, coll_type_cd, specimen_cd))
    binf_charges->bc_detail[bc_cnt].load_script = "afc_collection_setup"
   ELSEIF (ce.ext_i_reference_cont_cd IN (anes_record_cd, anes_time_cd, anes_type_cd,
   anes_inventory_cd, anes_monitor_cd))
    binf_charges->bc_detail[bc_cnt].load_script = "sn_load_ch_anesthesia"
   ELSEIF (ce.ext_i_reference_cont_cd=item_master_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "mm_load_item_master 2"
   ELSEIF (ce.ext_i_reference_cont_cd=surgical_case_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "sn_load_ch_surg_caselevel"
   ELSEIF (ce.ext_i_reference_cont_cd=surgical_personnel_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "sn_load_ch_surgrole"
   ELSEIF (ce.ext_i_reference_cont_cd=surgical_op_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "sn_load_ch_surgop"
   ELSEIF (ce.ext_i_reference_cont_cd=sn_doc_id_cd)
    binf_charges->bc_detail[bc_cnt].load_script = "sn_load_ch_document"
   ELSEIF (ce.ext_i_reference_cont_cd IN (task_assay_cd)
    AND ce.ext_p_reference_cont_cd=0
    AND ce.ext_p_reference_id=0)
    binf_charges->bc_detail[bc_cnt].load_script = "dcp_load_dta_for_afc"
   ELSEIF (ce.ext_i_reference_cont_cd IN (task_assay_cd)
    AND ce.ext_p_reference_cont_cd=task_cat_cd)
    binf_charges->bc_detail[bc_cnt].load_script =
    "Run AFC Update for Powerform in Parent Description column", binf_charges->bc_detail[bc_cnt].
    ext_p_ref_desc = trim(ot.task_description)
   ELSEIF (ce.ext_i_reference_cont_cd IN (task_cat_cd))
    binf_charges->bc_detail[bc_cnt].load_script = concat(
     "Open DCPTools.exe.  In Order/Task Tool, search ","for the task named:  ",trim(ot2
      .task_description,3),".    Remove and re-add the task to any orders as needed.")
   ELSE
    binf_charges->bc_detail[bc_cnt].load_script = "No Resolution Found.  Contact Solution Works."
   ENDIF
   encntr_cnt = 0
  HEAD c.charge_item_id
   encntr_cnt = (encntr_cnt+ 1)
   IF (mod(encntr_cnt,10)=1)
    stat = alterlist(binf_charges->bc_detail[bc_cnt].encntr_detail,(encntr_cnt+ 9))
   ENDIF
   binf_charges->bc_detail[bc_cnt].encntr_detail[encntr_cnt].encntr_id = c.encntr_id, binf_charges->
   bc_detail[bc_cnt].encntr_detail[encntr_cnt].charge_item_id = c.charge_item_id
   IF (textlen(trim(eafin.alias,3)) > 0)
    binf_charges->bc_detail[bc_cnt].encntr_detail[encntr_cnt].fin = cnvtalias(eafin.alias,eafin
     .alias_pool_cd)
   ELSE
    binf_charges->bc_detail[bc_cnt].encntr_detail[encntr_cnt].fin = cnvtalias(eafin2.alias,eafin2
     .alias_pool_cd)
   ENDIF
  FOOT  c.charge_item_id
   null
  FOOT  ce.ext_p_reference_id
   stat = alterlist(binf_charges->bc_detail[bc_cnt].encntr_detail,encntr_cnt), binf_charges->
   bc_detail[bc_cnt].encntr_cnt = encntr_cnt
  FOOT  ce.ext_i_reference_id
   null
  FOOT REPORT
   stat = alterlist(binf_charges->bc_detail,bc_cnt), binf_charges->bc_cnt = bc_cnt
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE nodatasection0(ncalc=i2) = f8 WITH protect
 DECLARE nodatasection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesupersummarysection0(ncalc=i2) = f8 WITH protect
 DECLARE headpagesupersummarysection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagesummarysection0(ncalc=i2) = f8 WITH protect
 DECLARE headpagesummarysection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE headpagedetailsection0(ncalc=i2) = f8 WITH protect
 DECLARE headpagedetailsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE detailsupersummarysection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsupersummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
  = f8 WITH protect
 DECLARE detailsummarysection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE detaildetailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detaildetailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE footsupersummarysection(ncalc=i2) = f8 WITH protect
 DECLARE footsupersummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE footreportsection0(ncalc=i2) = f8 WITH protect
 DECLARE footreportsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsupersummarysection = i2 WITH noconstant(0), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname4 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
 DECLARE _bcontdetailsummarysection = i2 WITH noconstant(0), protect
 DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname6 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname7 = i4 WITH noconstant(1), protect
 DECLARE _bcontdetaildetailsection = i2 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE nodatasection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = nodatasection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE nodatasection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(trim(display_message),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.031)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 9.000
    SET rptsd->m_height = 0.719
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesupersummarysection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesupersummarysection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesupersummarysection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   DECLARE __fieldname5 = vc WITH noconstant(build2(concat("Organization:  ",trim(prompt_organization
       )),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 4.990
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Summary by Load Script of Bill Item Not Found Charges",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 8.813)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 2.240
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.907),(offsetx+ 10.000),(offsety
     + 0.907))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagesummarysection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagesummarysection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagesummarysection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.950000), private
   DECLARE __fieldname10 = vc WITH noconstant(build2(concat("Organization:  ",trim(
       prompt_organization)),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.510)
    SET rptsd->m_width = 4.990
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Summary by Item Description of Bill Item Not Found Charges",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 8.781)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PARENT DESCRIPTION",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ITEM DESCRIPTION",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_P_CONT_CD",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_I_CONT_CD",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACTIVITY TYPE",char(0)))
    SET rptsd->m_y = (offsety+ 0.740)
    SET rptsd->m_x = (offsetx+ 8.125)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.886),(offsetx+ 10.000),(offsety
     + 0.886))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.271)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE headpagedetailsection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpagedetailsection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpagedetailsection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   DECLARE __fieldname8 = vc WITH noconstant(build2(concat("Organization:  ",trim(prompt_organization
       )),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 4.990
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Detail of Bill Item Not Found Charges",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 8.781)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times80)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
    SET rptsd->m_flags = 1028
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PARENT DESCRIPTION",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 3.562)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ITEM DESCRIPTION",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_P_CONT_CD",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_I_CONT_CD",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACTIVITY TYPE",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 8.375)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CHARGE_ITEM_ID",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.813),(offsetx+ 9.979),(offsety+
     0.813))
    SET rptsd->m_flags = 16
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsupersummarysection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsupersummarysectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsupersummarysectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(load_script_summary->lss_detail[i].
     load_script_text_cnt,char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(load_script_summary->lss_detail[i].
     load_script_text,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname1 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 6.188
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 2.750)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.750)
   SET rptsd->m_width = 6.188
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detailsummarysection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsummarysectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsummarysectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname4 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_p_ref_desc),
     char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_i_ref_desc),
     char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      ext_p_ref_cont_desc),char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      ext_i_ref_cont_desc),char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      display_activity_type),char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].load_script),char
     (0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
    SET _remfieldname1 = 1
    SET _remfieldname4 = 1
    SET _remfieldname5 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname0 = _remfieldname0
   IF (_remfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
        __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
    SET drawheight_fieldname0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
       _remfieldname0)+ 1),__fieldname0)))))
     SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname0 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname0)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.938)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname1 = _remfieldname1
   IF (_remfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
        __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
    SET drawheight_fieldname1 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname1 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
       _remfieldname1)+ 1),__fieldname1)))))
     SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname1 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname1)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname4 = _remfieldname4
   IF (_remfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname4,((size(
        __fieldname4) - _remfieldname4)+ 1),__fieldname4)))
    SET drawheight_fieldname4 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname4 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname4,((size(__fieldname4) -
       _remfieldname4)+ 1),__fieldname4)))))
     SET _remfieldname4 = (_remfieldname4+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname4 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname4)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname5 = _remfieldname5
   IF (_remfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
        __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
    SET drawheight_fieldname5 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
       _remfieldname5)+ 1),__fieldname5)))))
     SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname5 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname5)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = drawheight_fieldname0
   IF (ncalc=rpt_render
    AND _holdremfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size(
        __fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
   ELSE
    SET _remfieldname0 = _holdremfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 1.938)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = drawheight_fieldname1
   IF (ncalc=rpt_render
    AND _holdremfieldname1 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size(
        __fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
   ELSE
    SET _remfieldname1 = _holdremfieldname1
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.938)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 6.063)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = drawheight_fieldname4
   IF (ncalc=rpt_render
    AND _holdremfieldname4 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname4,((size(
        __fieldname4) - _holdremfieldname4)+ 1),__fieldname4)))
   ELSE
    SET _remfieldname4 = _holdremfieldname4
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.125)
   SET rptsd->m_width = 1.854
   SET rptsd->m_height = drawheight_fieldname5
   IF (ncalc=rpt_render
    AND _holdremfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size(
        __fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
   ELSE
    SET _remfieldname5 = _holdremfieldname5
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE detaildetailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detaildetailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detaildetailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname6 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname7 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(binf_charges->bc_detail[i].encntr_detail[ii].fin,
     char(0))), protect
   DECLARE __fieldname1 = vc WITH noconstant(build2(cnvtstring(binf_charges->bc_detail[i].
      encntr_detail[ii].charge_item_id),char(0))), protect
   DECLARE __fieldname2 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_p_ref_desc),
     char(0))), protect
   DECLARE __fieldname3 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_i_ref_desc),
     char(0))), protect
   DECLARE __fieldname4 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      ext_p_ref_cont_desc),char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      ext_i_ref_cont_desc),char(0))), protect
   DECLARE __fieldname6 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
      display_activity_type),char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].load_script),char
     (0))), protect
   IF (bcontinue=0)
    SET _remfieldname2 = 1
    SET _remfieldname3 = 1
    SET _remfieldname6 = 1
    SET _remfieldname7 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 1.104
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname2 = _remfieldname2
   IF (_remfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
        __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
    SET drawheight_fieldname2 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname2 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
       _remfieldname2)+ 1),__fieldname2)))))
     SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname2 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname2)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 1.104
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname3 = _remfieldname3
   IF (_remfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
        __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
    SET drawheight_fieldname3 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname3 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
       _remfieldname3)+ 1),__fieldname3)))))
     SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname3 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname3)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname6 = _remfieldname6
   IF (_remfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname6,((size(
        __fieldname6) - _remfieldname6)+ 1),__fieldname6)))
    SET drawheight_fieldname6 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname6 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname6,((size(__fieldname6) -
       _remfieldname6)+ 1),__fieldname6)))))
     SET _remfieldname6 = (_remfieldname6+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname6 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname6)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.656
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname7 = _remfieldname7
   IF (_remfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname7,((size(
        __fieldname7) - _remfieldname7)+ 1),__fieldname7)))
    SET drawheight_fieldname7 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname7 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname7,((size(__fieldname7) -
       _remfieldname7)+ 1),__fieldname7)))))
     SET _remfieldname7 = (_remfieldname7+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname7 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname7)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 1.313)
   SET rptsd->m_width = 0.990
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.375)
   SET rptsd->m_width = 1.104
   SET rptsd->m_height = drawheight_fieldname2
   IF (ncalc=rpt_render
    AND _holdremfieldname2 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size(
        __fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
   ELSE
    SET _remfieldname2 = _holdremfieldname2
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.562)
   SET rptsd->m_width = 1.104
   SET rptsd->m_height = drawheight_fieldname3
   IF (ncalc=rpt_render
    AND _holdremfieldname3 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size(
        __fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
   ELSE
    SET _remfieldname3 = _holdremfieldname3
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 4.813)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.875)
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.198
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 7.000)
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = drawheight_fieldname6
   IF (ncalc=rpt_render
    AND _holdremfieldname6 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname6,((size(
        __fieldname6) - _holdremfieldname6)+ 1),__fieldname6)))
   ELSE
    SET _remfieldname6 = _holdremfieldname6
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 8.375)
   SET rptsd->m_width = 1.656
   SET rptsd->m_height = drawheight_fieldname7
   IF (ncalc=rpt_render
    AND _holdremfieldname7 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname7,((size(
        __fieldname7) - _holdremfieldname7)+ 1),__fieldname7)))
   ELSE
    SET _remfieldname7 = _holdremfieldname7
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footsupersummarysection(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footsupersummarysectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footsupersummarysectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.750000), private
   DECLARE __fieldname2 = vc WITH noconstant(build2(load_script_summary->lss_total_cnt,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.750),(offsety+ 0.125),(offsetx+ 3.625),(offsety+
     0.125))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 3.031
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TOTAL Bill Item Not Found Charges",
      char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE footreportsection0(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = footreportsection0abs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE footreportsection0abs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.000000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 7.000
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< < End of Report > >",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CCPS_CS_BINF_RPT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 IF ((binf_charges->bc_cnt > 0))
  IF (rpt_output_type=rpt_output_summary_load_script)
   SELECT INTO "nl:"
    lss_sort = trim(substring(1,250,binf_charges->bc_detail[d.seq].load_script))
    FROM (dummyt d  WITH seq = value(binf_charges->bc_cnt))
    PLAN (d)
    ORDER BY lss_sort
    HEAD PAGE
     lss_cnt = 0, load_script_total = 0
    HEAD lss_sort
     lss_cnt = (lss_cnt+ 1), stat = alterlist(load_script_summary->lss_detail,lss_cnt),
     load_script_summary->lss_detail[lss_cnt].load_script_text = lss_sort,
     load_script_cnt = 0
    DETAIL
     load_script_cnt = (load_script_cnt+ binf_charges->bc_detail[d.seq].encntr_cnt),
     load_script_total = (load_script_total+ binf_charges->bc_detail[d.seq].encntr_cnt)
    FOOT  lss_sort
     load_script_summary->lss_detail[lss_cnt].load_script_text_cnt = load_script_cnt
    FOOT REPORT
     load_script_summary->lss_total_cnt = load_script_total, load_script_summary->lss_cnt = lss_cnt
    WITH nocounter
   ;end select
   SELECT INTO  $OUTDEV
    primary_sort = trim(substring(1,250,load_script_summary->lss_detail[d.seq].load_script_text))
    FROM (dummyt d  WITH seq = value(load_script_summary->lss_cnt))
    PLAN (d)
    ORDER BY primary_sort
    HEAD REPORT
     null
    HEAD PAGE
     d0 = headpagesupersummarysection0(rpt_render)
    DETAIL
     i = d.seq
     IF (((_yoffset+ detailsupersummarysection(rpt_calcheight,2.0,_bcontdetailsupersummarysection))
      > 7.6))
      d0 = pagebreak(0), d0 = headpagesupersummarysection0(rpt_render)
     ENDIF
     d0 = detailsupersummarysection(rpt_render,2.0,_bcontdetailsupersummarysection)
    FOOT REPORT
     IF (((_yoffset+ footsupersummarysection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesupersummarysection0(rpt_render)
     ENDIF
     d0 = footsupersummarysection(rpt_render)
     IF (((_yoffset+ footreportsection0(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesupersummarysection0(rpt_render)
     ENDIF
     d0 = footreportsection0(rpt_render)
    WITH nocounter
   ;end select
  ELSEIF (rpt_output_type=rpt_output_summary_item)
   SELECT INTO  $OUTDEV
    primary_sort = trim(substring(1,250,cnvtupper(binf_charges->bc_detail[d.seq].ext_p_ref_desc))),
    secondary_sort = trim(substring(1,250,cnvtupper(binf_charges->bc_detail[d.seq].ext_i_ref_desc)))
    FROM (dummyt d  WITH seq = value(binf_charges->bc_cnt))
    PLAN (d)
    ORDER BY primary_sort, secondary_sort
    HEAD REPORT
     null
    HEAD PAGE
     d0 = headpagesummarysection0(rpt_render)
    DETAIL
     i = d.seq
     IF (((_yoffset+ detailsummarysection(rpt_calcheight,2.0,_bcontdetailsummarysection)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesummarysection0(rpt_render)
     ENDIF
     d0 = detailsummarysection(rpt_render,2.0,_bcontdetailsummarysection)
    FOOT REPORT
     d0 = footreportsection0(rpt_render)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    primary_sort = trim(substring(1,250,cnvtupper(binf_charges->bc_detail[d.seq].ext_p_ref_desc))),
    secondary_sort = trim(substring(1,250,cnvtupper(binf_charges->bc_detail[d.seq].ext_i_ref_desc))),
    tertiary_sort = trim(substring(1,50,binf_charges->bc_detail[d.seq].encntr_detail[d1.seq].fin))
    FROM (dummyt d  WITH seq = value(binf_charges->bc_cnt)),
     (dummyt d1  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d1,binf_charges->bc_detail[d.seq].encntr_cnt))
     JOIN (d1)
    ORDER BY primary_sort, secondary_sort, tertiary_sort
    HEAD REPORT
     null
    HEAD PAGE
     d0 = headpagedetailsection0(rpt_render)
    DETAIL
     i = d.seq, ii = d1.seq
     IF (((_yoffset+ detaildetailsection(rpt_calcheight,2.0,_bcontdetaildetailsection)) > 7.6))
      d0 = pagebreak(0), d0 = headpagedetailsection0(rpt_render)
     ENDIF
     d0 = detaildetailsection(rpt_render,2.0,_bcontdetaildetailsection)
    FOOT REPORT
     d0 = footreportsection0(rpt_render)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    display_message = "There are no Bill Item Not Found charges.", d0 = nodatasection0(rpt_render)
  ;end select
 ENDIF
 SET d0 = finalizereport( $OUTDEV)
#exit_prg
 IF (ld_failure_flag=1)
  EXECUTE reportrtl
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE finalizereport(ssendreport=vc) = null WITH protect
  DECLARE nodatasection0(ncalc=i2) = f8 WITH protect
  DECLARE nodatasection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagesupersummarysection0(ncalc=i2) = f8 WITH protect
  DECLARE headpagesupersummarysection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagesummarysection0(ncalc=i2) = f8 WITH protect
  DECLARE headpagesummarysection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagedetailsection0(ncalc=i2) = f8 WITH protect
  DECLARE headpagedetailsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailsupersummarysection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
  DECLARE detailsupersummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref))
   = f8 WITH protect
  DECLARE detailsummarysection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
  DECLARE detailsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
   WITH protect
  DECLARE detaildetailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
  DECLARE detaildetailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
  WITH protect
  DECLARE footsupersummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footsupersummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footreportsection0(ncalc=i2) = f8 WITH protect
  DECLARE footreportsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = i4 WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
  DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
  DECLARE _bcontdetailsupersummarysection = i2 WITH noconstant(0), protect
  DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname1 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname4 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
  DECLARE _bcontdetailsummarysection = i2 WITH noconstant(0), protect
  DECLARE _remfieldname2 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname3 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname6 = i4 WITH noconstant(1), protect
  DECLARE _remfieldname7 = i4 WITH noconstant(1), protect
  DECLARE _bcontdetaildetailsection = i2 WITH noconstant(0), protect
  DECLARE _times8b0 = i4 WITH noconstant(0), protect
  DECLARE _times80 = i4 WITH noconstant(0), protect
  DECLARE _times10b0 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
  SUBROUTINE pagebreak(dummy)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    SET _yoffset = rptreport->m_margintop
  END ;Subroutine
  SUBROUTINE finalizereport(ssendreport)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt = (_errcnt+ 1)
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
  END ;Subroutine
  SUBROUTINE nodatasection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = nodatasection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE nodatasection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(trim(display_message),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.031)
     SET rptsd->m_x = (offsetx+ 0.500)
     SET rptsd->m_width = 9.000
     SET rptsd->m_height = 0.719
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagesupersummarysection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagesupersummarysection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagesupersummarysection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    DECLARE __fieldname5 = vc WITH noconstant(build2(concat("Organization:  ",trim(
        prompt_organization)),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.500)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Summary by Load Script of Bill Item Not Found Charges",char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.750)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 0.875
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.438)
     SET rptsd->m_x = (offsetx+ 8.813)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.438)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 3.750)
     SET rptsd->m_width = 2.240
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.907),(offsetx+ 10.000),(offsety
      + 0.907))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 2.500)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagesummarysection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagesummarysection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagesummarysection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.950000), private
    DECLARE __fieldname10 = vc WITH noconstant(build2(concat("Organization:  ",trim(
        prompt_organization)),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.510)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Summary by Item Description of Bill Item Not Found Charges",char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.375)
     SET rptsd->m_x = (offsetx+ 8.781)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.375)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 1.854
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PARENT DESCRIPTION",char(0)))
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 1.938)
     SET rptsd->m_width = 1.854
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ITEM DESCRIPTION",char(0)))
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 3.875)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_P_CONT_CD",char(0)))
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 4.938)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_I_CONT_CD",char(0)))
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 6.063)
     SET rptsd->m_width = 1.854
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACTIVITY TYPE",char(0)))
     SET rptsd->m_y = (offsety+ 0.740)
     SET rptsd->m_x = (offsetx+ 8.125)
     SET rptsd->m_width = 1.854
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.886),(offsetx+ 10.000),(offsety
      + 0.886))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 2.500)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagedetailsection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagedetailsection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagedetailsection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.880000), private
    DECLARE __fieldname8 = vc WITH noconstant(build2(concat("Organization:  ",trim(
        prompt_organization)),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 20
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.500)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Detail of Bill Item Not Found Charges",char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.781)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 1028
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 2.375)
     SET rptsd->m_width = 1.104
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PARENT DESCRIPTION",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 3.562)
     SET rptsd->m_width = 1.104
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ITEM DESCRIPTION",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 4.813)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_P_CONT_CD",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 5.875)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT_I_CONT_CD",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 7.000)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("ACTIVITY TYPE",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 8.375)
     SET rptsd->m_width = 1.854
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LOAD SCRIPT",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 0.990
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("FIN",char(0)))
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 1.313)
     SET rptsd->m_width = 0.990
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("CHARGE_ITEM_ID",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.010),(offsety+ 0.813),(offsetx+ 9.979),(offsety
      + 0.813))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.250)
     SET rptsd->m_x = (offsetx+ 2.500)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailsupersummarysection(ncalc,maxheight,bcontinue)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailsupersummarysectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailsupersummarysectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(load_script_summary->lss_detail[i].
      load_script_text_cnt,char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(load_script_summary->lss_detail[i].
      load_script_text,char(0))), protect
    IF (bcontinue=0)
     SET _remfieldname1 = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 6.188
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _holdremfieldname1 = _remfieldname1
    IF (_remfieldname1 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
         __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
     SET drawheight_fieldname1 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname1 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
        _remfieldname1)+ 1),__fieldname1)))))
      SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname1 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname1)
    ENDIF
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.750)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.750)
    SET rptsd->m_width = 6.188
    SET rptsd->m_height = drawheight_fieldname1
    IF (ncalc=rpt_render
     AND _holdremfieldname1 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size
        (__fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
    ELSE
     SET _remfieldname1 = _holdremfieldname1
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailsummarysection(ncalc,maxheight,bcontinue)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailsummarysectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailsummarysectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname1 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname4 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_p_ref_desc),
      char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_i_ref_desc),
      char(0))), protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       ext_p_ref_cont_desc),char(0))), protect
    DECLARE __fieldname3 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       ext_i_ref_cont_desc),char(0))), protect
    DECLARE __fieldname4 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       display_activity_type),char(0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].load_script),
      char(0))), protect
    IF (bcontinue=0)
     SET _remfieldname0 = 1
     SET _remfieldname1 = 1
     SET _remfieldname4 = 1
     SET _remfieldname5 = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _holdremfieldname0 = _remfieldname0
    IF (_remfieldname0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
         __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
     SET drawheight_fieldname0 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname0 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
        _remfieldname0)+ 1),__fieldname0)))))
      SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname0 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname0)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname1 = _remfieldname1
    IF (_remfieldname1 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname1,((size(
         __fieldname1) - _remfieldname1)+ 1),__fieldname1)))
     SET drawheight_fieldname1 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname1 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname1,((size(__fieldname1) -
        _remfieldname1)+ 1),__fieldname1)))))
      SET _remfieldname1 = (_remfieldname1+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname1 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname1)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname4 = _remfieldname4
    IF (_remfieldname4 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname4,((size(
         __fieldname4) - _remfieldname4)+ 1),__fieldname4)))
     SET drawheight_fieldname4 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname4 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname4,((size(__fieldname4) -
        _remfieldname4)+ 1),__fieldname4)))))
      SET _remfieldname4 = (_remfieldname4+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname4 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname4)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 8.125)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname5 = _remfieldname5
    IF (_remfieldname5 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
         __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
     SET drawheight_fieldname5 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname5 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
        _remfieldname5)+ 1),__fieldname5)))))
      SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname5 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname5)
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = drawheight_fieldname0
    IF (ncalc=rpt_render
     AND _holdremfieldname0 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size
        (__fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
    ELSE
     SET _remfieldname0 = _holdremfieldname0
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 1.938)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = drawheight_fieldname1
    IF (ncalc=rpt_render
     AND _holdremfieldname1 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname1,((size
        (__fieldname1) - _holdremfieldname1)+ 1),__fieldname1)))
    ELSE
     SET _remfieldname1 = _holdremfieldname1
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = drawheight_fieldname4
    IF (ncalc=rpt_render
     AND _holdremfieldname4 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname4,((size
        (__fieldname4) - _holdremfieldname4)+ 1),__fieldname4)))
    ELSE
     SET _remfieldname4 = _holdremfieldname4
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 8.125)
    SET rptsd->m_width = 1.854
    SET rptsd->m_height = drawheight_fieldname5
    IF (ncalc=rpt_render
     AND _holdremfieldname5 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size
        (__fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
    ELSE
     SET _remfieldname5 = _holdremfieldname5
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detaildetailsection(ncalc,maxheight,bcontinue)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detaildetailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detaildetailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE growsum = i4 WITH noconstant(0), private
    DECLARE drawheight_fieldname2 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname3 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname6 = f8 WITH noconstant(0.0), private
    DECLARE drawheight_fieldname7 = f8 WITH noconstant(0.0), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(binf_charges->bc_detail[i].encntr_detail[ii].fin,
      char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(cnvtstring(binf_charges->bc_detail[i].
       encntr_detail[ii].charge_item_id),char(0))), protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_p_ref_desc),
      char(0))), protect
    DECLARE __fieldname3 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].ext_i_ref_desc),
      char(0))), protect
    DECLARE __fieldname4 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       ext_p_ref_cont_desc),char(0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       ext_i_ref_cont_desc),char(0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].
       display_activity_type),char(0))), protect
    DECLARE __fieldname7 = vc WITH noconstant(build2(trim(binf_charges->bc_detail[i].load_script),
      char(0))), protect
    IF (bcontinue=0)
     SET _remfieldname2 = 1
     SET _remfieldname3 = 1
     SET _remfieldname6 = 1
     SET _remfieldname7 = 1
    ENDIF
    SET rptsd->m_flags = 5
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _oldfont = uar_rptsetfont(_hreport,_times80)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _holdremfieldname2 = _remfieldname2
    IF (_remfieldname2 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname2,((size(
         __fieldname2) - _remfieldname2)+ 1),__fieldname2)))
     SET drawheight_fieldname2 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname2 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname2,((size(__fieldname2) -
        _remfieldname2)+ 1),__fieldname2)))))
      SET _remfieldname2 = (_remfieldname2+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname2 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname2)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.562)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname3 = _remfieldname3
    IF (_remfieldname3 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname3,((size(
         __fieldname3) - _remfieldname3)+ 1),__fieldname3)))
     SET drawheight_fieldname3 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname3 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname3,((size(__fieldname3) -
        _remfieldname3)+ 1),__fieldname3)))))
      SET _remfieldname3 = (_remfieldname3+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname3 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname3)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname6 = _remfieldname6
    IF (_remfieldname6 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname6,((size(
         __fieldname6) - _remfieldname6)+ 1),__fieldname6)))
     SET drawheight_fieldname6 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname6 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname6,((size(__fieldname6) -
        _remfieldname6)+ 1),__fieldname6)))))
      SET _remfieldname6 = (_remfieldname6+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname6 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname6)
    ENDIF
    SET rptsd->m_flags = 5
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 8.375)
    SET rptsd->m_width = 1.656
    SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
    SET _holdremfieldname7 = _remfieldname7
    IF (_remfieldname7 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname7,((size(
         __fieldname7) - _remfieldname7)+ 1),__fieldname7)))
     SET drawheight_fieldname7 = rptsd->m_height
     IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
      SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
     ENDIF
     IF ((rptsd->m_drawlength=0))
      SET _remfieldname7 = 0
     ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname7,((size(__fieldname7) -
        _remfieldname7)+ 1),__fieldname7)))))
      SET _remfieldname7 = (_remfieldname7+ rptsd->m_drawlength)
     ELSE
      SET _remfieldname7 = 0
     ENDIF
     SET growsum = (growsum+ _remfieldname7)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.219
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 0.990
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 2.375)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = drawheight_fieldname2
    IF (ncalc=rpt_render
     AND _holdremfieldname2 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname2,((size
        (__fieldname2) - _holdremfieldname2)+ 1),__fieldname2)))
    ELSE
     SET _remfieldname2 = _holdremfieldname2
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 3.562)
    SET rptsd->m_width = 1.104
    SET rptsd->m_height = drawheight_fieldname3
    IF (ncalc=rpt_render
     AND _holdremfieldname3 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname3,((size
        (__fieldname3) - _holdremfieldname3)+ 1),__fieldname3)))
    ELSE
     SET _remfieldname3 = _holdremfieldname3
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.813)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.875)
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.198
    IF (ncalc=rpt_render
     AND bcontinue=0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 7.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = drawheight_fieldname6
    IF (ncalc=rpt_render
     AND _holdremfieldname6 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname6,((size
        (__fieldname6) - _holdremfieldname6)+ 1),__fieldname6)))
    ELSE
     SET _remfieldname6 = _holdremfieldname6
    ENDIF
    SET rptsd->m_flags = 4
    IF (bcontinue)
     SET rptsd->m_y = offsety
    ELSE
     SET rptsd->m_y = (offsety+ 0.000)
    ENDIF
    SET rptsd->m_x = (offsetx+ 8.375)
    SET rptsd->m_width = 1.656
    SET rptsd->m_height = drawheight_fieldname7
    IF (ncalc=rpt_render
     AND _holdremfieldname7 > 0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname7,((size
        (__fieldname7) - _holdremfieldname7)+ 1),__fieldname7)))
    ELSE
     SET _remfieldname7 = _holdremfieldname7
    ENDIF
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    IF (ncalc=rpt_render)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    IF (growsum > 0)
     SET bcontinue = 1
    ELSE
     SET bcontinue = 0
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footsupersummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footsupersummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footsupersummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname2 = vc WITH noconstant(build2(load_script_summary->lss_total_cnt,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.750),(offsety+ 0.125),(offsetx+ 3.625),(offsety
      + 0.125))
     SET rptsd->m_flags = 4
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 3.750)
     SET rptsd->m_width = 3.031
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("TOTAL Bill Item Not Found Charges",
       char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.188)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 0.875
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footreportsection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footreportsection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footreportsection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.750)
     SET rptsd->m_x = (offsetx+ 1.500)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< < End of Report > >",char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "CCPS_CS_BINF_RPT"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_landscape
    SET rptreport->m_marginleft = 0.50
    SET rptreport->m_marginright = 0.50
    SET rptreport->m_margintop = 0.50
    SET rptreport->m_marginbottom = 0.50
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    CALL _createfonts(0)
    CALL _createpens(0)
  END ;Subroutine
  SUBROUTINE _createfonts(dummy)
    SET rptfont->m_recsize = 50
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_bold = rpt_on
    SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET rptfont->m_bold = rpt_off
    SET _times80 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_bold = rpt_on
    SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SET d0 = initializereport(0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    d0 = nodatasection0(rpt_render)
   WITH nocounter
  ;end select
  SET d0 = finalizereport( $OUTDEV)
 ENDIF
 SET last_mod = "10/24/12 MP9098"
END GO
