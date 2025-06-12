CREATE PROGRAM ct_rn_ops_postrun:dba
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
     2 next_run_dt_tm = dq8
     2 rn_protocol_cd = f8
 )
 FREE RECORD core_request
 RECORD core_request(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD core_reply
 RECORD core_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE notfound = vc WITH protect, constant("<not_found>")
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE rerun_dt_time = vc WITH protect, noconstant("")
 DECLARE rerun_dt_unit = vc WITH protect, noconstant("")
 DECLARE data = vc WITH protect, noconstant("")
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE cd_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE num = i2 WITH protect, noconstant(0)
 CALL echo(build("Starting ct_rn_ops_postrun:",run_group_id))
 SELECT INTO "nl:"
  FROM ct_rn_prot_run pr,
   ct_rn_prot_config pc,
   prot_master pm,
   ct_rn_run_activity ra
  PLAN (pr
   WHERE pr.run_group_id=run_group_id)
   JOIN (pc
   WHERE pc.prot_master_id=pr.prot_master_id
    AND pc.end_effective_dt_tm >= cnvtdatetime(script_date))
   JOIN (pm
   WHERE pm.prot_master_id=pr.prot_master_id)
   JOIN (ra
   WHERE ra.ct_rn_prot_run_id=pr.ct_rn_prot_run_id
    AND ra.status_flag=rn_send_compl)
  HEAD REPORT
   prot_cnt = 0
  HEAD pr.ct_rn_prot_run_id
   start_dt_time = "", start_dt_unit = "", data = "",
   prot_cnt = (prot_cnt+ 1)
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(protocols->prots,(prot_cnt+ 9))
   ENDIF
   protocols->prots[prot_cnt].prot_master_id = pr.prot_master_id, protocols->prots[prot_cnt].
   ct_rn_prot_run_id = pr.ct_rn_prot_run_id, protocols->prots[prot_cnt].rn_protocol_cd = pc
   .rn_protocol_cd,
   num = 1, tempstr = "", data = pc.config_info,
   CALL echo(build("pc.config_info =",pc.config_info))
   WHILE (tempstr != notfound
    AND num < 1000)
     tempstr = piece(data,"|",num,notfound),
     CALL echo(build("piece",num,"=",tempstr))
     CASE (num)
      OF 2:
       rerun_dt_time = tempstr
      OF 3:
       rerun_dt_unit = tempstr
     ENDCASE
     num = (num+ 1)
   ENDWHILE
   CALL echo(build2("rerun_dt_time = ",rerun_dt_time)),
   CALL echo(build2("rerun_dt_unit = ",rerun_dt_unit)), nextrundttm = concat("'",rerun_dt_time,",",
    rerun_dt_unit,"'"),
   protocols->prots[prot_cnt].next_run_dt_tm = cnvtlookahead(build(nextrundttm),cnvtdatetime(curdate,
     curtime3))
  FOOT REPORT
   stat = alterlist(protocols->prots,prot_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(protocols)
 IF (prot_cnt=0)
  CALL echo("ct_rn_ops_postrun::No protocols that are ready to be processed.")
  GO TO exit_script
 ENDIF
 SET cd_cnt = 0
 FOR (idx = 1 TO prot_cnt)
   CALL insertrnrunactivity(protocols->prots[idx].ct_rn_prot_run_id,rn_completed)
   UPDATE  FROM ct_rn_prot_run rpr
    SET rpr.completed_flag = 1, rpr.updt_dt_tm = cnvtdatetime(script_date), rpr.updt_id = reqinfo->
     updt_id,
     rpr.updt_applctx = reqinfo->updt_applctx, rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = (
     rpr.updt_cnt+ 1)
    WHERE (rpr.ct_rn_prot_run_id=protocols->prots[idx].ct_rn_prot_run_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET status_reply->status_data.status = "F"
    SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
    "ct_rn_ops_prerun:Error updating ct_rn_prot_run record."
    GO TO exit_script
   ENDIF
   INSERT  FROM ct_rn_prot_run rpr
    SET rpr.ct_rn_prot_run_id = seq(protocol_def_seq,nextval), rpr.prot_master_id = protocols->prots[
     idx].prot_master_id, rpr.run_group_id = 0,
     rpr.next_run_dt_tm = cnvtdatetime(protocols->prots[idx].next_run_dt_tm), rpr.pt_sent_nbr = 0,
     rpr.completed_flag = 0,
     rpr.updt_dt_tm = cnvtdatetime(script_date), rpr.updt_id = reqinfo->updt_id, rpr.updt_applctx =
     reqinfo->updt_applctx,
     rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET status_reply->status_data.status = "F"
    SET status_reply->status_data.subeventstatus[1].targetobjectvalue =
    "ct_rn_ops_prerun:Error inserting ct_rn_prot_run record."
    GO TO exit_script
   ENDIF
   CALL echo(build2("protocols->prots[prot_cnt].rn_protocol_cd = ",protocols->prots[idx].
     rn_protocol_cd))
   CALL echo(build2("uar_get_code_meaning(protocols->prots[idx].rn_protocol_cd) = ",
     uar_get_code_meaning(protocols->prots[idx].rn_protocol_cd)))
   IF (uar_get_code_meaning(protocols->prots[idx].rn_protocol_cd)="DATAEXTR")
    SELECT INTO "nl:"
     FROM code_value cv,
      ct_rn_prot_run pr,
      ct_rn_run_activity ra
     PLAN (pr
      WHERE (pr.ct_rn_prot_run_id=protocols->prots[idx].ct_rn_prot_run_id))
      JOIN (ra
      WHERE ra.ct_rn_prot_run_id=pr.ct_rn_prot_run_id
       AND ra.status_flag=rn_data_ext_success)
      JOIN (cv
      WHERE (cv.code_value=protocols->prots[idx].rn_protocol_cd))
     DETAIL
      cd_cnt = (cd_cnt+ 1)
      IF (mod(cd_cnt,10)=1)
       stat = alterlist(core_request->cd_value_list,(cd_cnt+ 9))
      ENDIF
      core_request->cd_value_list[cd_cnt].action_type_flag = 2, core_request->cd_value_list[cd_cnt].
      cki = cv.cki, core_request->cd_value_list[cd_cnt].code_set = cv.code_set,
      core_request->cd_value_list[cd_cnt].code_value = protocols->prots[idx].rn_protocol_cd,
      core_request->cd_value_list[cd_cnt].collation_seq = cv.collation_seq, core_request->
      cd_value_list[cd_cnt].concept_cki = cv.concept_cki,
      core_request->cd_value_list[cd_cnt].definition = cv.definition, core_request->cd_value_list[
      cd_cnt].description = cv.description, core_request->cd_value_list[cd_cnt].display = cv.display,
      core_request->cd_value_list[cd_cnt].begin_effective_dt_tm = cnvtdatetime(script_date),
      core_request->cd_value_list[cd_cnt].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
      core_request->cd_value_list[cd_cnt].display_key = cv.display_key,
      core_request->cd_value_list[cd_cnt].active_ind = 0, core_request->cd_value_list[cd_cnt].
      cdf_meaning = cv.cdf_meaning
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(core_request->cd_value_list,cd_cnt)
 CALL echorecord(core_request)
 IF (cd_cnt > 0)
  EXECUTE core_ens_cd_value  WITH replace("REQUEST",core_request), replace("REPLY","CORE_REPLY")
 ENDIF
 COMMIT
#exit_script
 SET last_mod = "001"
 SET mod_date = "July 21, 2009"
END GO
