CREATE PROGRAM aps_chg_request_processing:dba
 RECORD request(
   1 add_qual[*]
     2 request_number = i4
     2 sequence = i2
     2 format_script = c30
     2 target_request_number = i4
     2 destination_step_id = f8
     2 reprocess_reply_ind = i2
     2 service = c50
   1 chg_qual[*]
     2 request_number = i4
     2 format_script_old = c30
     2 format_script_new = c30
     2 target_request_number = i4
     2 destination_step_id = f8
     2 reprocess_reply_ind = i2
   1 del_qual[*]
     2 request_number = i4
     2 format_script = c30
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET add_cnt = 33
 SET stat = alterlist(request->add_qual,add_cnt)
 SET chg_cnt = 0
 SET stat = alterlist(request->chg_qual,chg_cnt)
 SET del_cnt = 0
 SET stat = alterlist(request->del_qual,del_cnt)
 SET request->add_qual[1].request_number = 200005
 SET request->add_qual[1].sequence = 1
 SET request->add_qual[1].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[1].target_request_number = 560201
 SET request->add_qual[1].destination_step_id = 560201
 SET request->add_qual[1].reprocess_reply_ind = 1
 SET request->add_qual[1].service = ""
 SET request->add_qual[2].request_number = 200005
 SET request->add_qual[2].sequence = 2
 SET request->add_qual[2].format_script = "PFMT_APS_INITIATE_SPC_PROT"
 SET request->add_qual[2].target_request_number = 0
 SET request->add_qual[2].destination_step_id = 0
 SET request->add_qual[2].reprocess_reply_ind = 0
 SET request->add_qual[2].service = ""
 SET request->add_qual[3].request_number = 200005
 SET request->add_qual[3].sequence = 3
 SET request->add_qual[3].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[3].target_request_number = 560201
 SET request->add_qual[3].destination_step_id = 560201
 SET request->add_qual[3].reprocess_reply_ind = 1
 SET request->add_qual[3].service = ""
 SET request->add_qual[4].request_number = 200005
 SET request->add_qual[4].sequence = 4
 SET request->add_qual[4].format_script = "PFMT_APS_CREATE_CASE_TO_EVENT"
 SET request->add_qual[4].target_request_number = 0
 SET request->add_qual[4].destination_step_id = 120210
 SET request->add_qual[4].reprocess_reply_ind = 0
 SET request->add_qual[4].service = ""
 SET request->add_qual[5].request_number = 200006
 SET request->add_qual[5].sequence = 1
 SET request->add_qual[5].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[5].target_request_number = 560201
 SET request->add_qual[5].destination_step_id = 560201
 SET request->add_qual[5].reprocess_reply_ind = 1
 SET request->add_qual[5].service = ""
 SET request->add_qual[6].request_number = 200006
 SET request->add_qual[6].sequence = 2
 SET request->add_qual[6].format_script = "PFMT_APS_INITIATE_SPC_PROT"
 SET request->add_qual[6].target_request_number = 0
 SET request->add_qual[6].destination_step_id = 0
 SET request->add_qual[6].reprocess_reply_ind = 0
 SET request->add_qual[6].service = ""
 SET request->add_qual[7].request_number = 200006
 SET request->add_qual[7].sequence = 3
 SET request->add_qual[7].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[7].target_request_number = 560201
 SET request->add_qual[7].destination_step_id = 560201
 SET request->add_qual[7].reprocess_reply_ind = 1
 SET request->add_qual[7].service = ""
 SET request->add_qual[8].request_number = 200011
 SET request->add_qual[8].sequence = 1
 SET request->add_qual[8].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[8].target_request_number = 560201
 SET request->add_qual[8].destination_step_id = 560201
 SET request->add_qual[8].reprocess_reply_ind = 1
 SET request->add_qual[8].service = ""
 SET request->add_qual[9].request_number = 200012
 SET request->add_qual[9].sequence = 1
 SET request->add_qual[9].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[9].target_request_number = 560201
 SET request->add_qual[9].destination_step_id = 560201
 SET request->add_qual[9].reprocess_reply_ind = 1
 SET request->add_qual[9].service = ""
 SET request->add_qual[10].request_number = 200012
 SET request->add_qual[10].sequence = 2
 SET request->add_qual[10].format_script = "PFMT_APS_CANCEL_CE_EVENT"
 SET request->add_qual[10].target_request_number = 0
 SET request->add_qual[10].destination_step_id = 120210
 SET request->add_qual[10].reprocess_reply_ind = 0
 SET request->add_qual[10].service = ""
 SET request->add_qual[11].request_number = 200014
 SET request->add_qual[11].sequence = 1
 SET request->add_qual[11].format_script = "PFMT_APS_VERIFY_RPT_EVENT"
 SET request->add_qual[11].target_request_number = 0
 SET request->add_qual[11].destination_step_id = 120210
 SET request->add_qual[11].reprocess_reply_ind = 1
 SET request->add_qual[11].service = ""
 SET request->add_qual[12].request_number = 200014
 SET request->add_qual[12].sequence = 2
 SET request->add_qual[12].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[12].target_request_number = 560201
 SET request->add_qual[12].destination_step_id = 560201
 SET request->add_qual[12].reprocess_reply_ind = 1
 SET request->add_qual[12].service = ""
 SET request->add_qual[13].request_number = 200014
 SET request->add_qual[13].sequence = 3
 SET request->add_qual[13].format_script = "PFMT_APS_SIGN_LINE"
 SET request->add_qual[13].target_request_number = 0
 SET request->add_qual[13].destination_step_id = 1000042
 SET request->add_qual[13].reprocess_reply_ind = 0
 SET request->add_qual[13].service = ""
 SET request->add_qual[14].request_number = 200014
 SET request->add_qual[14].sequence = 4
 SET request->add_qual[14].format_script = "PFMT_APS_REVIEW_FOLLOWUP"
 SET request->add_qual[14].target_request_number = 0
 SET request->add_qual[14].destination_step_id = 0
 SET request->add_qual[14].reprocess_reply_ind = 0
 SET request->add_qual[14].service = ""
 SET request->add_qual[15].request_number = 200014
 SET request->add_qual[15].sequence = 5
 SET request->add_qual[15].format_script = "PFMT_APS_ADD_AUTO_CODES"
 SET request->add_qual[15].target_request_number = 0
 SET request->add_qual[15].destination_step_id = 200061
 SET request->add_qual[15].reprocess_reply_ind = 0
 SET request->add_qual[15].service = ""
 SET request->add_qual[16].request_number = 200014
 SET request->add_qual[16].sequence = 6
 SET request->add_qual[16].format_script = "PFMT_APS_INITIATE_EXPEDITE"
 SET request->add_qual[16].target_request_number = 0
 SET request->add_qual[16].destination_step_id = 0
 SET request->add_qual[16].reprocess_reply_ind = 0
 SET request->add_qual[16].service = ""
 SET request->add_qual[17].request_number = 200019
 SET request->add_qual[17].sequence = 1
 SET request->add_qual[17].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[17].target_request_number = 560201
 SET request->add_qual[17].destination_step_id = 560201
 SET request->add_qual[17].reprocess_reply_ind = 1
 SET request->add_qual[17].service = ""
 SET request->add_qual[18].request_number = 200021
 SET request->add_qual[18].sequence = 1
 SET request->add_qual[18].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[18].target_request_number = 560201
 SET request->add_qual[18].destination_step_id = 560201
 SET request->add_qual[18].reprocess_reply_ind = 1
 SET request->add_qual[18].service = ""
 SET request->add_qual[19].request_number = 200021
 SET request->add_qual[19].sequence = 2
 SET request->add_qual[19].format_script = "PFMT_APS_CANCEL_CE_EVENT"
 SET request->add_qual[19].target_request_number = 0
 SET request->add_qual[19].destination_step_id = 120210
 SET request->add_qual[19].reprocess_reply_ind = 0
 SET request->add_qual[19].service = ""
 SET request->add_qual[20].request_number = 200118
 SET request->add_qual[20].sequence = 1
 SET request->add_qual[20].format_script = "PFMT_APS_VERIFY_RPT_EVENT"
 SET request->add_qual[20].target_request_number = 0
 SET request->add_qual[20].destination_step_id = 120210
 SET request->add_qual[20].reprocess_reply_ind = 1
 SET request->add_qual[20].service = ""
 SET request->add_qual[21].request_number = 200118
 SET request->add_qual[21].sequence = 2
 SET request->add_qual[21].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[21].target_request_number = 560201
 SET request->add_qual[21].destination_step_id = 560201
 SET request->add_qual[21].reprocess_reply_ind = 1
 SET request->add_qual[21].service = ""
 SET request->add_qual[22].request_number = 200118
 SET request->add_qual[22].sequence = 3
 SET request->add_qual[22].format_script = "PFMT_APS_SIGN_LINE"
 SET request->add_qual[22].target_request_number = 0
 SET request->add_qual[22].destination_step_id = 1000042
 SET request->add_qual[22].reprocess_reply_ind = 0
 SET request->add_qual[22].service = ""
 SET request->add_qual[23].request_number = 200118
 SET request->add_qual[23].sequence = 4
 SET request->add_qual[23].format_script = "PFMT_APS_REVIEW_FOLLOWUP"
 SET request->add_qual[23].target_request_number = 0
 SET request->add_qual[23].destination_step_id = 0
 SET request->add_qual[23].reprocess_reply_ind = 0
 SET request->add_qual[23].service = ""
 SET request->add_qual[24].request_number = 200118
 SET request->add_qual[24].sequence = 5
 SET request->add_qual[24].format_script = "PFMT_APS_ADD_AUTO_CODES"
 SET request->add_qual[24].target_request_number = 0
 SET request->add_qual[24].destination_step_id = 200061
 SET request->add_qual[24].reprocess_reply_ind = 0
 SET request->add_qual[24].service = ""
 SET request->add_qual[25].request_number = 200118
 SET request->add_qual[25].sequence = 6
 SET request->add_qual[25].format_script = "PFMT_APS_INITIATE_EXPEDITE"
 SET request->add_qual[25].target_request_number = 0
 SET request->add_qual[25].destination_step_id = 0
 SET request->add_qual[25].reprocess_reply_ind = 0
 SET request->add_qual[25].service = ""
 SET request->add_qual[26].request_number = 200118
 SET request->add_qual[26].sequence = 7
 SET request->add_qual[26].format_script = "PFMT_APS_RPT_TO_AFC"
 SET request->add_qual[26].target_request_number = 0
 SET request->add_qual[26].destination_step_id = 951060
 SET request->add_qual[26].reprocess_reply_ind = 0
 SET request->add_qual[26].service = ""
 SET request->add_qual[27].request_number = 200138
 SET request->add_qual[27].sequence = 1
 SET request->add_qual[27].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[27].target_request_number = 560201
 SET request->add_qual[27].destination_step_id = 560201
 SET request->add_qual[27].reprocess_reply_ind = 1
 SET request->add_qual[27].service = ""
 SET request->add_qual[28].request_number = 200150
 SET request->add_qual[28].sequence = 1
 SET request->add_qual[28].format_script = "PFMT_APS_PROC_TASKS_TO_ORDER"
 SET request->add_qual[28].target_request_number = 0
 SET request->add_qual[28].destination_step_id = 0
 SET request->add_qual[28].reprocess_reply_ind = 0
 SET request->add_qual[28].service = ""
 SET request->add_qual[29].request_number = 200150
 SET request->add_qual[29].sequence = 2
 SET request->add_qual[29].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[29].target_request_number = 560201
 SET request->add_qual[29].destination_step_id = 560201
 SET request->add_qual[29].reprocess_reply_ind = 1
 SET request->add_qual[29].service = ""
 SET request->add_qual[30].request_number = 200386
 SET request->add_qual[30].sequence = 1
 SET request->add_qual[30].format_script = "PFMT_APS_OPS_EXCEPTION"
 SET request->add_qual[30].target_request_number = 560201
 SET request->add_qual[30].destination_step_id = 560201
 SET request->add_qual[30].reprocess_reply_ind = 1
 SET request->add_qual[30].service = ""
 SET request->add_qual[31].request_number = 200390
 SET request->add_qual[31].sequence = 1
 SET request->add_qual[31].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[31].target_request_number = 560201
 SET request->add_qual[31].destination_step_id = 560201
 SET request->add_qual[31].reprocess_reply_ind = 1
 SET request->add_qual[31].service = ""
 SET request->add_qual[32].request_number = 200390
 SET request->add_qual[32].sequence = 2
 SET request->add_qual[32].format_script = "PFMT_APS_COMP_BILLING_TASKS"
 SET request->add_qual[32].target_request_number = 0
 SET request->add_qual[32].destination_step_id = 0
 SET request->add_qual[32].reprocess_reply_ind = 0
 SET request->add_qual[32].service = ""
 SET request->add_qual[33].request_number = 200390
 SET request->add_qual[33].sequence = 3
 SET request->add_qual[33].format_script = "PFMT_APS_PATHOLOGY_ORDER"
 SET request->add_qual[33].target_request_number = 560201
 SET request->add_qual[33].destination_step_id = 560201
 SET request->add_qual[33].reprocess_reply_ind = 1
 SET request->add_qual[33].service = ""
 DELETE  FROM request_processing rp
  WHERE rp.request_number IN (200005, 200006, 200011, 200012, 200014,
  200019, 200021, 200118, 200138, 200150,
  200386, 200390)
  WITH nocounter
 ;end delete
 IF (del_cnt > 0)
  UPDATE  FROM request_processing rp,
    (dummyt d  WITH seq = value(del_cnt))
   SET rp.active_ind = 0, rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_id = reqinfo->
    updt_id,
    rp.updt_task = reqinfo->updt_task, rp.updt_cnt = (rp.updt_cnt+ 1), rp.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (rp
    WHERE (rp.request_number=request->del_qual[d.seq].request_number)
     AND (rp.format_script=request->del_qual[d.seq].format_script))
   WITH nocounter
  ;end update
 ENDIF
 IF (add_cnt > 0)
  INSERT  FROM request_processing rp,
    (dummyt d  WITH seq = value(add_cnt))
   SET rp.request_number = request->add_qual[d.seq].request_number, rp.sequence = request->add_qual[d
    .seq].sequence, rp.format_script = request->add_qual[d.seq].format_script,
    rp.target_request_number = request->add_qual[d.seq].target_request_number, rp.destination_step_id
     = request->add_qual[d.seq].destination_step_id, rp.reprocess_reply_ind = request->add_qual[d.seq
    ].reprocess_reply_ind,
    rp.service = request->add_qual[d.seq].service, rp.active_ind = 1, rp.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    rp.updt_id = reqinfo->updt_id, rp.updt_task = reqinfo->updt_task, rp.updt_cnt = 0,
    rp.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (rp
    WHERE (rp.request_number=request->add_qual[d.seq].request_number)
     AND (rp.sequence=request->add_qual[d.seq].sequence))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
 ENDIF
 IF (chg_cnt > 0)
  UPDATE  FROM request_processing rp,
    (dummyt d  WITH seq = value(chg_cnt))
   SET rp.request_number = request->chg_qual[d.seq].request_number, rp.format_script = request->
    chg_qual[d.seq].format_script_new, rp.target_request_number = request->chg_qual[d.seq].
    target_request_number,
    rp.destination_step_id = request->chg_qual[d.seq].destination_step_id, rp.reprocess_reply_ind =
    request->chg_qual[d.seq].reprocess_reply_ind, rp.active_ind = 1,
    rp.updt_dt_tm = cnvtdatetime(curdate,curtime3), rp.updt_id = reqinfo->updt_id, rp.updt_task =
    reqinfo->updt_task,
    rp.updt_cnt = (rp.updt_cnt+ 1), rp.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (rp
    WHERE (rp.request_number=request->chg_qual[d.seq].request_number)
     AND (rp.format_script=request->chg_qual[d.seq].format_script_old))
   WITH nocounter
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
