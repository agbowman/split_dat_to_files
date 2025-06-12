CREATE PROGRAM ct_rn_ops_data_extract:dba
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
   1 prots[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
     2 primary_mnemonic = vc
     2 qual[*]
       3 person_id = f8
 )
 RECORD data_extract_request(
   1 study_name = vc
   1 qual[*]
     2 person_id = f8
 )
 RECORD data_extract_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE prev_ct_rn_prot_run_id = f8 WITH protect, noconstant(0.0)
 DECLARE data_ex_max_val = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE pt_cnt = i2 WITH protect, noconstant(0)
 DECLARE pidx = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE send_status = i2 WITH protect, noconstant(0)
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE log_str = vc WITH protect, noconstant("")
 DECLARE log_filename = vc WITH protect, noconstant(concat("cer_temp:ct_rn_extract",trim(cnvtstring(
     run_group_id)),".txt"))
 CALL echo(build("ct_run_ops_data_extract:run_group_id = ",run_group_id))
 SET status_reply->status_data.status = "S"
 SET pref_request->pref_entry = "rn_data_extraction_max"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET data_ex_max_val = cnvtint(pref_reply->pref_value)
 CALL echo(build("data_ex_max_val pref value: ",data_ex_max_val))
 IF (data_ex_max_val=0)
  CALL echo("ct_run_ops_data_extract::Unable to retrieve the max data extract preference value.")
  SET data_ex_max_val = 25000
 ENDIF
 SELECT INTO "nl:"
  FROM ct_rn_prot_run pr,
   ct_rn_run_activity ra,
   code_value cv,
   prot_master pm,
   ct_rn_prot_config pc,
   pt_prot_prescreen pps
  PLAN (pr
   WHERE pr.run_group_id=run_group_id)
   JOIN (ra
   WHERE ra.ct_rn_prot_run_id=pr.ct_rn_prot_run_id
    AND ra.status_flag=rn_screen_compl)
   JOIN (pc
   WHERE pc.prot_master_id=pr.prot_master_id
    AND pc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=pc.rn_protocol_cd
    AND cv.cdf_meaning="DATAEXTR")
   JOIN (pm
   WHERE pm.prot_master_id=pr.prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pps
   WHERE pps.prot_master_id=pr.prot_master_id
    AND pps.screening_status_cd=pending_cd)
  ORDER BY pps.prot_master_id
  HEAD REPORT
   prot_cnt = 0
  HEAD pps.prot_master_id
   pt_cnt = 0, prot_cnt = (prot_cnt+ 1)
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(protocols->prots,(prot_cnt+ 9))
   ENDIF
   protocols->prots[prot_cnt].ct_rn_prot_run_id = pr.ct_rn_prot_run_id, protocols->prots[prot_cnt].
   primary_mnemonic = pm.primary_mnemonic, protocols->prots[prot_cnt].prot_master_id = pm
   .prot_master_id
  DETAIL
   pt_cnt = (pt_cnt+ 1)
   IF (mod(pt_cnt,10)=1)
    stat = alterlist(protocols->prots[prot_cnt].qual,(pt_cnt+ 9))
   ENDIF
   protocols->prots[prot_cnt].qual[pt_cnt].person_id = pps.person_id
   IF ((pt_cnt > (data_ex_max_val - 1)))
    stat = alterlist(protocols->prots[prot_cnt].qual,pt_cnt), pt_cnt = 0, prot_cnt = (prot_cnt+ 1)
    IF (mod(prot_cnt,10)=1)
     stat = alterlist(protocols->prots,(prot_cnt+ 9))
    ENDIF
    protocols->prots[prot_cnt].ct_rn_prot_run_id = pr.ct_rn_prot_run_id, protocols->prots[prot_cnt].
    primary_mnemonic = pm.primary_mnemonic, protocols->prots[prot_cnt].prot_master_id = pm
    .prot_master_id
   ENDIF
  FOOT  pps.prot_master_id
   stat = alterlist(protocols->prots[prot_cnt].qual,pt_cnt)
  FOOT REPORT
   IF (pt_cnt=0)
    prot_cnt = (prot_cnt - 1)
   ELSE
    stat = alterlist(protocols->prots,prot_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (prot_cnt=0)
  CALL echo("ct_run_ops_data_extract::No protocols that are ready to be processed.")
  GO TO exit_script
 ENDIF
 CALL echorecord(protocols)
 SET log_str = " "
 SET prot_cnt = size(protocols->prots,5)
 FOR (idx = 1 TO prot_cnt)
   SET tempstr = ""
   IF (prev_ct_rn_prot_run_id=0)
    SET prev_ct_rn_prot_run_id = protocols->prots[idx].ct_rn_prot_run_id
    SET send_status = 1
   ENDIF
   IF ((prev_ct_rn_prot_run_id != protocols->prots[idx].ct_rn_prot_run_id))
    IF (send_status=1)
     CALL echo("INSERT RUN ACTIVITY - SUCCESS")
     SET stat = insertrnrunactivity(prev_ct_rn_prot_run_id,rn_data_ext_success)
    ELSE
     CALL echo("INSERT RUN ACTIVITY - FAILURE")
     SET stat = insertrnrunactivity(prev_ct_rn_prot_run_id,rn_data_ext_fail)
    ENDIF
    SET prev_ct_rn_prot_run_id = protocols->prots[idx].ct_rn_prot_run_id
    SET send_status = 1
   ENDIF
   SET pt_cnt = size(protocols->prots[idx].qual,5)
   SET stat = alterlist(data_extract_request->qual,pt_cnt)
   SET data_extract_request->study_name = protocols->prots[idx].primary_mnemonic
   SET tempstr = concat("primary_mnemonic: ",protocols->prots[idx].primary_mnemonic)
   FOR (pidx = 1 TO pt_cnt)
    SET data_extract_request->qual[pidx].person_id = protocols->prots[idx].qual[pidx].person_id
    SET tempstr = concat(tempstr,char(13),char(10),"  person_id[",trim(cnvtstring(pidx)),
     "] = ",trim(cnvtstring(protocols->prots[idx].qual[pidx].person_id)))
   ENDFOR
   CALL echorecord(data_extract_request)
   EXECUTE edw_research_network_extract  WITH replace("REQUEST","DATA_EXTRACT_REQUEST"), replace(
    "REPLY","DATA_EXTRACT_REPLY")
   CALL echorecord(data_extract_reply)
   IF ((data_extract_reply->status_data.status != "S"))
    CALL echo(concat("edw_research_network_extract failed for ",protocols->prots[idx].
      primary_mnemonic))
    SET send_status = 0
   ENDIF
   IF (send_status=1)
    SET log_str = concat(log_str,char(13),char(10),
     "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",char(13),
     char(10),"Group ",trim(cnvtstring(idx)),tempstr)
   ELSE
    SET log_str = concat(log_str,char(13),char(10),
     "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",char(13),
     char(10),"Group ",trim(cnvtstring(idx))," - Call failed to send patient list to script.")
   ENDIF
   IF (prot_cnt=idx)
    IF (send_status=1)
     CALL echo("INSERT RUN ACTIVITY (Last record) - SUCCESS")
     SET stat = insertrnrunactivity(protocols->prots[idx].ct_rn_prot_run_id,rn_data_ext_success)
    ELSE
     CALL echo("INSERT RUN ACTIVITY (Last record) - FAILURE")
     SET stat = insertrnrunactivity(protocols->prots[idx].ct_rn_prot_run_id,rn_data_ext_fail)
    ENDIF
   ENDIF
 ENDFOR
 IF (log_str != "")
  SELECT INTO value(log_filename)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    col 1, log_str
   WITH noheading, nocounter, format = lfstream,
    maxcol = 35000, maxrow = 1
  ;end select
 ENDIF
 COMMIT
#exit_script
 SET last_mod = "000"
 SET mod_date = "July 21, 2009"
END GO
