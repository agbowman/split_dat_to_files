CREATE PROGRAM ct_rn_send_data:dba
 DECLARE rn_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_compl = i4 WITH protect, constant(300)
 DECLARE rn_data_ext_success = i4 WITH protect, constant(350)
 DECLARE rn_data_ext_fail = i4 WITH protect, constant(355)
 DECLARE rn_gather_start = i4 WITH protect, constant(400)
 DECLARE rn_gather_compl = i4 WITH protect, constant(500)
 DECLARE rn_send_start = i4 WITH protect, constant(600)
 DECLARE rn_send_compl = i4 WITH protect, constant(700)
 DECLARE rn_forced_compl = i4 WITH protect, constant(900)
 DECLARE rn_completed = i4 WITH protect, constant(1000)
 DECLARE hmsg = i4 WITH protect, constant(0)
 DECLARE insertrnrunactivity(ct_rn_prot_run_id=f8,rn_status=i4) = i2
 SUBROUTINE insertrnrunactivity(ct_rn_prot_run_id,rn_status)
   DECLARE _stat = i4 WITH private, noconstant(0)
   IF (hmsg=0)
    CALL uar_syscreatehandle(hmsg,_stat)
   ENDIF
   INSERT  FROM ct_rn_run_activity ra
    SET ra.ct_rn_run_activity_id = seq(protocol_def_seq,nextval), ra.ct_rn_prot_run_id =
     ct_rn_prot_run_id, ra.status_flag = rn_status,
     ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id, ra.updt_applctx
      = reqinfo->updt_applctx,
     ra.updt_task = reqinfo->updt_task, ra.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET stat = msgwrite(hmsg,"INSERT ACTIVTY ERROR",emsglvl_warn,"Unable to insert Run Activity")
    CALL echo(concat("Unable to insert run activity (",trim(cnvtstring(rn_status)),
      ") for ct_rn_prot_run_id = ",trim(cnvtstring(ct_rn_prot_run_id))))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF ( NOT (validate(status_reply,0)))
  RECORD status_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD protocols
 RECORD protocols(
   1 cnt = i4
   1 prots[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
 )
 DECLARE sendfilemsa(outfile=vc,statusfile=vc) = vc WITH protect
 DECLARE checkmsalogicals(null) = i2 WITH protect
 DECLARE executemsaclient(outfile=vc,statusfile=vc) = i2 WITH protect
 DECLARE checkmsastatus(null) = i2 WITH protect
 SUBROUTINE sendfilemsa(outfile,statusfile)
   DECLARE error_msg = vc WITH protect, noconstant("")
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET retval = checkmsalogicals(null)
   IF (retval=0)
    CALL echo("MSA Logicals not defined.")
    SET error_msg = "ct_msa_send.inc: MSA Logicals not defined."
    RETURN(error_msg)
   ENDIF
   SET retval = findfile(concat("cer_temp:",outfile))
   IF (retval=0)
    CALL echo(concat("Unable to locate file: ",outfile))
    SET error_msg = concat("ct_msa_send.inc: Unable to locate file - ",outfile)
    RETURN(error_msg)
   ENDIF
   SET retval = executemsaclient(outfile,statusfile)
   IF (retval=0)
    CALL echo("Error in ExecuteMSAClient.")
    SET error_msg = "ct_msa_send.inc: Error in ExecuteMSAClient."
    RETURN(error_msg)
   ENDIF
   SET retval = checkmsastatus(outfile,statusfile)
   IF (retval=0)
    CALL echo("Error in CheckMSAStatus.")
    SET error_msg = "ct_msa_send.inc:Error in CheckMSAStatus."
    RETURN(error_msg)
   ENDIF
   RETURN(error_msg)
 END ;Subroutine
 SUBROUTINE checkmsalogicals(null)
   DECLARE msa_status = i2 WITH noconstant(0)
   IF (logical("MSA_SERVER")=null)
    CALL echo("ERROR: MSA_SERVER logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (logical("CLIENT_MNEMONIC")=null)
    CALL echo("ERROR: CLIENT_MNEMONIC logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (msa_status=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE executemsaclient(outfile,statusfile)
   DECLARE dclcmd = vc WITH protect, noconstant("")
   DECLARE status = i4 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET dclcmd = concat("$cer_exe/msaclient -file ","$cer_temp/",outfile," | grep 'Status' > ",
     "$cer_temp/",
     statusfile)
   ELSE
    SET dclcmd = concat("pipe mcr cer_exe:msaclient -file ",outfile,
     " | search sys$input Status/out = ",statusfile)
   ENDIF
   CALL echo(build2("ExecuteMSAClient::dclcmd = ",dclcmd))
   CALL dcl(dclcmd,size(dclcmd),status)
   IF (status=0)
    CALL echo("ERROR: msaclient call failed")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkmsastatus(outfile,statusfile)
   DECLARE msa_status = i2 WITH protect, noconstant(0)
   IF (findfile(concat("cer_temp:",statusfile)) > 0)
    FREE DEFINE rtl2
    DEFINE rtl2 concat("cer_temp:",statusfile)
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      IF (findstring("<Code>0</Code>",trim(a.line)) > 0)
       CALL echo(concat(outfile," was sent successfully at ",format(curtime2,"##:##:##"))),
       msa_status = 1
      ENDIF
     WITH nocounter, maxrec = 1
    ;end select
   ENDIF
   IF (msa_status=1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE output_file = vc WITH protect, constant(concat("ct_rn_data",trim(cnvtstring( $1)),".xml"))
 DECLARE status_file = vc WITH protect, constant(concat("rnmsa",trim(cnvtstring( $1)),".tmp"))
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE msa_error_msg = vc WITH protect, noconstant("")
 DECLARE insertsendrunactivity(rn_status=i4) = i2 WITH protect
 CALL echo("Starting ct_rn_send_data")
 SELECT INTO "nl:"
  FROM ct_rn_prot_run pr,
   ct_rn_prot_config pc,
   prot_master pm,
   ct_rn_run_activity ra
  PLAN (pr
   WHERE pr.run_group_id=run_group_id)
   JOIN (pc
   WHERE pc.prot_master_id=pr.prot_master_id
    AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pm
   WHERE pm.prot_master_id=pr.prot_master_id)
   JOIN (ra
   WHERE ra.ct_rn_prot_run_id=pr.ct_rn_prot_run_id
    AND ra.status_flag=rn_gather_compl)
  HEAD REPORT
   prot_cnt = 0
  HEAD pr.ct_rn_prot_run_id
   prot_cnt = (prot_cnt+ 1)
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(protocols->prots,(prot_cnt+ 9))
   ENDIF
   protocols->prots[prot_cnt].prot_master_id = pr.prot_master_id, protocols->prots[prot_cnt].
   ct_rn_prot_run_id = pr.ct_rn_prot_run_id
  FOOT REPORT
   stat = alterlist(protocols->prots,prot_cnt), protocols->cnt = prot_cnt
  WITH nocounter
 ;end select
 CALL echorecord(protocols)
 IF (prot_cnt=0)
  CALL echo("No protocols that are ready to be processed.")
  SET status_reply->status_data.status = "F"
  SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
  "ct_rn_ops_postrun:Error determinging protocols to run."
  GO TO exit_script
 ENDIF
 CALL insertsendrunactivity(rn_send_start)
 CALL echo(build2("STATUS_FILE = ",status_file))
 CALL echo(build2("OUTPUT_FILE = ",output_file))
 SET msa_error_msg = sendfilemsa(output_file,status_file)
 IF (size(trim(msa_error_msg)) > 0)
  SET status_reply->status_data.status = "F"
  SET status_reply->status_data.subeventstatus[1].targetobjectvalue = msa_error_msg
 ENDIF
 CALL insertsendrunactivity(rn_send_compl)
 SUBROUTINE insertsendrunactivity(rn_status)
   DECLARE prot_cnt = i2 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET prot_cnt = size(protocols->prots,5)
   FOR (idx = 1 TO prot_cnt)
    SET retval = insertrnrunactivity(protocols->prots[idx].ct_rn_prot_run_id,rn_status)
    IF (retval=0)
     CALL echo("Failed to insert a new CT_RN_RUN_ACTIVITY record")
    ENDIF
   ENDFOR
 END ;Subroutine
 COMMIT
#exit_script
 CALL echo("Ending ct_rn_send_data")
 SET last_mod = "001"
 SET mod_date = "July 21, 2009"
END GO
