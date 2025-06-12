CREATE PROGRAM ct_rn_ops_prerun:dba
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
 SUBROUTINE (insertrnrunactivity(ct_rn_prot_run_id=f8,rn_status=i4) =i2)
   DECLARE _stat = i4 WITH private, noconstant(0)
   IF (hmsg=0)
    CALL uar_syscreatehandle(hmsg,_stat)
   ENDIF
   INSERT  FROM ct_rn_run_activity ra
    SET ra.ct_rn_run_activity_id = seq(protocol_def_seq,nextval), ra.ct_rn_prot_run_id =
     ct_rn_prot_run_id, ra.status_flag = rn_status,
     ra.updt_dt_tm = cnvtdatetime(sysdate), ra.updt_id = reqinfo->updt_id, ra.updt_applctx = reqinfo
     ->updt_applctx,
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
 RECORD new_run(
   1 protocols[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
     2 data_extraction_ind = i2
 )
 RECORD end_runs(
   1 protocols[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
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
 RECORD ps_request(
   1 pt_prot_prescreen_id = f8
   1 status_cd = f8
   1 status_comment_text = vc
   1 qual[*]
     2 pt_prot_prescreen_id = f8
     2 status_cd = f8
     2 status_comment_text = vc
 )
 RECORD ps_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE expiry_time = f8 WITH protect, noconstant(0)
 DECLARE lookback = vc WITH protect, noconstant("")
 DECLARE retval = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE pscnt = i2 WITH protect, noconstant(0)
 CALL echo(build("ct_rn_ops_prerun:run_group_id = ",run_group_id))
 SET pref_request->pref_entry = "rn_expiry_time"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET expiry_time = pref_reply->pref_value
 CALL echorecord(pref_reply)
 SET lookback = concat(cnvtstring(expiry_time),",D")
 SELECT INTO "nl:"
  rpr.*
  FROM ct_rn_prot_run rpr,
   ct_rn_run_activity rra
  PLAN (rpr
   WHERE rpr.ct_rn_prot_run_id != run_group_id
    AND rpr.completed_flag=0
    AND rpr.run_group_id > 0)
   JOIN (rra
   WHERE rra.ct_rn_prot_run_id=rpr.ct_rn_prot_run_id
    AND rra.status_flag=rn_screen_start
    AND rra.updt_dt_tm < cnvtlookbehind(lookback,cnvtdatetime(sysdate)))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(end_runs->protocols,(cnt+ 9))
   ENDIF
   end_runs->protocols[cnt].ct_rn_prot_run_id = rpr.ct_rn_prot_run_id, end_runs->protocols[cnt].
   prot_master_id = rpr.prot_master_id
  FOOT REPORT
   stat = alterlist(end_runs->protocols,cnt)
  WITH nocounter
 ;end select
 FOR (idx = 1 TO cnt)
   SET retval = insertrnrunactivity(end_runs->protocols[idx].ct_rn_prot_run_id,rn_forced_compl)
   IF (retval=0)
    SET status_reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET retval = insertrnrunactivity(end_runs->protocols[idx].ct_rn_prot_run_id,rn_completed)
   IF (retval=0)
    SET status_reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   UPDATE  FROM ct_rn_prot_run rpr
    SET rpr.completed_flag = 2, rpr.updt_dt_tm = cnvtdatetime(sysdate), rpr.updt_id = reqinfo->
     updt_id,
     rpr.updt_applctx = reqinfo->updt_applctx, rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = (
     rpr.updt_cnt+ 1)
    WHERE (rpr.ct_rn_prot_run_id=end_runs->protocols[idx].ct_rn_prot_run_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET status_reply->status_data.status = "F"
    SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
    "ct_rn_ops_prerun:Error updating ct_rn_prot_run record for stuck run."
    GO TO exit_script
   ENDIF
   INSERT  FROM ct_rn_prot_run rpr
    SET rpr.ct_rn_prot_run_id = seq(protocol_def_seq,nextval), rpr.prot_master_id = end_runs->
     protocols[idx].prot_master_id, rpr.run_group_id = 0,
     rpr.next_run_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00"), rpr.pt_sent_nbr = 0, rpr
     .completed_flag = 0,
     rpr.updt_dt_tm = cnvtdatetime(sysdate), rpr.updt_id = reqinfo->updt_id, rpr.updt_applctx =
     reqinfo->updt_applctx,
     rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET status_reply->status_data.status = "F"
    SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
    "ct_rn_ops_prerun:Error inserting ct_rn_prot_run record."
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  pm.primary_mnemonic, pm.prot_master_id, rpr.ct_rn_prot_run_id
  FROM ct_rn_prot_run rpr,
   ct_rn_prot_config rpc,
   code_value cv,
   prot_master pm
  PLAN (rpr
   WHERE rpr.ct_rn_prot_run_id > 0
    AND rpr.completed_flag=0
    AND rpr.run_group_id=0
    AND rpr.next_run_dt_tm < cnvtdatetime(sysdate))
   JOIN (rpc
   WHERE rpc.prot_master_id=rpr.prot_master_id
    AND rpc.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND rpc.stop_dt_tm > cnvtdatetime(sysdate))
   JOIN (cv
   WHERE cv.code_value=rpc.rn_protocol_cd
    AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND cv.active_ind=1)
   JOIN (pm
   WHERE pm.prot_master_id=rpr.prot_master_id
    AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND pm.network_flag=2)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(new_run->protocols,(cnt+ 9))
   ENDIF
   new_run->protocols[cnt].ct_rn_prot_run_id = rpr.ct_rn_prot_run_id, new_run->protocols[cnt].
   prot_master_id = rpr.prot_master_id
   IF (cv.cdf_meaning="DATAEXTR")
    new_run->protocols[cnt].data_extraction_ind = 1
   ELSE
    new_run->protocols[cnt].data_extraction_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(new_run->protocols,cnt)
  WITH nocounter, forupdate(rpr)
 ;end select
 CALL echorecord(new_run)
 FOR (idx = 1 TO cnt)
  UPDATE  FROM ct_rn_prot_run rpr
   SET rpr.run_group_id = run_group_id, rpr.updt_dt_tm = cnvtdatetime(sysdate), rpr.updt_id = reqinfo
    ->updt_id,
    rpr.updt_applctx = reqinfo->updt_applctx, rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = (rpr
    .updt_cnt+ 1)
   WHERE (rpr.ct_rn_prot_run_id=new_run->protocols[idx].ct_rn_prot_run_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET status_reply->status_data.status = "F"
   SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
   "ct_rn_ops_prerun:Error updating ct_rn_prot_run record for new run."
   GO TO exit_script
  ENDIF
 ENDFOR
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pt_prot_prescreen pps,
   (dummyt d  WITH seq = value(size(new_run->protocols,5)))
  PLAN (d)
   JOIN (pps
   WHERE (pps.prot_master_id=new_run->protocols[d.seq].prot_master_id)
    AND pps.screening_status_cd=pending_cd)
  HEAD REPORT
   pscnt = 0
  DETAIL
   pscnt += 1
   IF (mod(pscnt,10)=1)
    stat = alterlist(ps_request->qual,(pscnt+ 9))
   ENDIF
   ps_request->qual[pscnt].pt_prot_prescreen_id = pps.pt_prot_prescreen_id, ps_request->qual[pscnt].
   status_cd = syscancel_cd, ps_request->qual[pscnt].status_comment_text =
   "Research Network System Cancelled"
  FOOT REPORT
   stat = alterlist(ps_request->qual,pscnt)
  WITH nocounter
 ;end select
 CALL echorecord(ps_request)
 IF (pscnt > 0)
  EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","PS_REQUEST"), replace("REPLY","PS_REPLY")
  IF ((ps_reply->status_data.status="F"))
   SET status_reply->status_data.status = "F"
   SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
   "ct_rn_ops_prerun:Error clearing pending prescreened patients for new run."
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 SET last_mod = "001"
 SET mod_date = "July 21, 2009"
END GO
