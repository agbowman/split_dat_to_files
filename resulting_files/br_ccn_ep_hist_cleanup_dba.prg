CREATE PROGRAM br_ccn_ep_hist_cleanup:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script br_ccn_ep_hist_cleanup..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE ccn_cnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE errorcheck(failmsg=vc) = i2
 FREE RECORD ccn_ids
 RECORD ccn_ids(
   1 ccns[*]
     2 ccn_id = f8
 )
 FREE RECORD ccn_reltns
 RECORD ccn_reltns(
   1 reltns[*]
     2 reltn_id = f8
 )
 UPDATE  FROM br_ccn bc
  SET bc.orig_br_ccn_id = bc.br_ccn_id, bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   bc.updt_id = reqinfo->updt_id, bc.updt_task = reqinfo->updt_task, bc.updt_applctx = reqinfo->
   updt_applctx
  WHERE bc.br_ccn_id > 0
   AND bc.active_ind=0
   AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND bc.orig_br_ccn_id=0.0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail1")
 SELECT INTO "nl:"
  FROM br_ccn bc
  WHERE bc.orig_br_ccn_id > 0
   AND bc.br_ccn_id > 0
   AND ((bc.active_ind=0) OR (bc.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  DETAIL
   ccn_cnt = (ccn_cnt+ 1), stat = alterlist(ccn_ids->ccns,ccn_cnt), ccn_ids->ccns[ccn_cnt].ccn_id =
   bc.br_ccn_id
  WITH nocounter
 ;end select
 CALL errorcheck("Fail2")
 IF (ccn_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(ccn_ids->ccns,5)),
    br_ccn_loc_reltn br
   PLAN (d)
    JOIN (br
    WHERE (br.br_ccn_id=ccn_ids->ccns[d.seq].ccn_id)
     AND br.br_ccn_loc_reltn_id > 0)
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(ccn_reltns->reltns,rcnt), ccn_reltns->reltns[rcnt].reltn_id =
    br.br_ccn_loc_reltn_id
   WITH nocounter
  ;end select
  CALL errorcheck("Fail3")
  CALL echo("********************************")
  CALL echo("Deleting CCNs and relations")
  CALL echo("********************************")
  FOR (j = 1 TO size(ccn_reltns->reltns,5))
    DELETE  FROM br_ccn_loc_ptsvc_reltn r
     WHERE (r.br_ccn_loc_reltn_id=ccn_reltns->reltns[j].reltn_id)
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail4")
    DELETE  FROM br_ccn_loc_reltn r
     WHERE (r.br_ccn_loc_reltn_id=ccn_reltns->reltns[j].reltn_id)
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail5")
  ENDFOR
  FOR (k = 1 TO size(ccn_ids->ccns,5))
    DELETE  FROM lh_cqm_meas_svc_entity_r lr
     WHERE (lr.parent_entity_id=ccn_ids->ccns[k].ccn_id)
      AND lr.parent_entity_name="BR_CCN"
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail55")
    DELETE  FROM br_svc_entity_report_reltn br
     WHERE (br.parent_entity_id=ccn_ids->ccns[k].ccn_id)
      AND br.parent_entity_name="BR_CCN"
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail6")
    DELETE  FROM br_ccn
     WHERE (orig_br_ccn_id=ccn_ids->ccns[k].ccn_id)
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail7")
    DELETE  FROM br_ccn
     WHERE (br_ccn_id=ccn_ids->ccns[k].ccn_id)
     WITH nocounter
    ;end delete
    CALL errorcheck("Fail8")
  ENDFOR
 ENDIF
 DECLARE epcnt = i4 WITH protect, noconstant(0)
 FREE RECORD epids
 RECORD epids(
   1 list[*]
     2 epid = f8
 )
 UPDATE  FROM br_eligible_provider bc
  SET bc.orig_br_eligible_provider_id = bc.br_eligible_provider_id, bc.updt_cnt = (bc.updt_cnt+ 1),
   bc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   bc.updt_id = reqinfo->updt_id, bc.updt_task = reqinfo->updt_task, bc.updt_applctx = reqinfo->
   updt_applctx
  WHERE bc.br_eligible_provider_id > 0
   AND bc.active_ind=0
   AND bc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND bc.orig_br_eligible_provider_id=0.0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail9")
 SELECT INTO "nl:"
  FROM br_eligible_provider ep
  WHERE ep.orig_br_eligible_provider_id > 0
   AND ep.br_eligible_provider_id > 0
   AND ((ep.active_ind=0) OR (ep.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  DETAIL
   epcnt = (epcnt+ 1), stat = alterlist(epids->list,epcnt), epids->list[epcnt].epid = ep
   .br_eligible_provider_id
  WITH nocounter
 ;end select
 CALL errorcheck("Fail10")
 CALL echo("********************************")
 CALL echo("Deleting EPs and relations")
 CALL echo("********************************")
 FOR (e = 1 TO epcnt)
   DELETE  FROM br_elig_prov_meas_reltn
    WHERE (br_eligible_provider_id=epids->list[e].epid)
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail11")
   DELETE  FROM lh_cqm_meas_svc_entity_r lr
    WHERE (lr.parent_entity_id=epids->list[e].epid)
     AND lr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail12")
   DELETE  FROM br_pqrs_meas_provider_reltn
    WHERE (br_eligible_provider_id=epids->list[e].epid)
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail13")
   DELETE  FROM br_group_reltn bgr
    WHERE (bgr.parent_entity_id=epids->list[e].epid)
     AND bgr.parent_entity_name="BR_ELIGIBLE_PROVIDER"
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail14")
   DELETE  FROM br_svc_entity_report_reltn br
    WHERE (br.parent_entity_id=epids->list[e].epid)
     AND br.parent_entity_name="BR_ELIGIBLE_PROVIDER"
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail15")
   DELETE  FROM br_eligible_provider r
    WHERE (r.orig_br_eligible_provider_id=epids->list[e].epid)
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail16")
   DELETE  FROM br_eligible_provider r
    WHERE (r.br_eligible_provider_id=epids->list[e].epid)
    WITH nocounter
   ;end delete
   CALL errorcheck("Fail17")
 ENDFOR
 CALL echo("********************************")
 CALL echo("Catch All")
 CALL echo("********************************")
 UPDATE  FROM lh_cqm_meas_svc_entity_r
  SET orig_lh_cqm_meas_svcent_r_id = lh_cqm_meas_svc_entity_r_id, updt_cnt = (updt_cnt+ 1),
   updt_dt_tm = cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WHERE active_ind=0
   AND end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND orig_lh_cqm_meas_svcent_r_id=0.0
   AND lh_cqm_meas_svc_entity_r_id > 0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail18")
 DELETE  FROM lh_cqm_meas_svc_entity_r lr
  WHERE lr.orig_lh_cqm_meas_svcent_r_id > 0
   AND lr.lh_cqm_meas_svc_entity_r_id > 0
   AND ((lr.active_ind=0) OR (lr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end delete
 CALL errorcheck("Fail19")
 UPDATE  FROM br_pqrs_meas_provider_reltn
  SET orig_br_pqrs_meas_prov_r_id = br_pqrs_meas_provider_reltn_id, updt_cnt = (updt_cnt+ 1),
   updt_dt_tm = cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WHERE active_ind=0
   AND end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND orig_br_pqrs_meas_prov_r_id=0.0
   AND br_pqrs_meas_provider_reltn_id > 0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail20")
 DELETE  FROM br_pqrs_meas_provider_reltn pr
  WHERE pr.orig_br_pqrs_meas_prov_r_id > 0
   AND pr.br_pqrs_meas_provider_reltn_id > 0
   AND ((pr.active_ind=0) OR (pr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end delete
 CALL errorcheck("Fail21")
 UPDATE  FROM br_svc_entity_report_reltn
  SET orig_br_svc_entity_report_r_id = br_svc_entity_report_reltn_id, updt_cnt = (updt_cnt+ 1),
   updt_dt_tm = cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WHERE active_ind=0
   AND end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND orig_br_svc_entity_report_r_id=0.0
   AND br_svc_entity_report_reltn_id > 0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail211")
 DELETE  FROM br_svc_entity_report_reltn ser
  WHERE ser.orig_br_svc_entity_report_r_id > 0
   AND ser.br_svc_entity_report_reltn_id > 0
   AND ((ser.active_ind=0) OR (ser.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end delete
 CALL errorcheck("Fail22")
 UPDATE  FROM br_elig_prov_meas_reltn
  SET orig_br_elig_prov_meas_r_id = br_elig_prov_meas_reltn_id, updt_cnt = (updt_cnt+ 1), updt_dt_tm
    = cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WHERE active_ind=0
   AND end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND orig_br_elig_prov_meas_r_id=0.0
   AND br_elig_prov_meas_reltn_id > 0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail23")
 DELETE  FROM br_elig_prov_meas_reltn pmr
  WHERE pmr.orig_br_elig_prov_meas_r_id > 0
   AND pmr.br_elig_prov_meas_reltn_id > 0
   AND ((pmr.active_ind=0) OR (pmr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end delete
 CALL errorcheck("Fail24")
 UPDATE  FROM br_ccn_loc_reltn
  SET orig_br_ccn_loc_reltn_id = br_ccn_loc_reltn_id, updt_cnt = (updt_cnt+ 1), updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
  WHERE active_ind=0
   AND end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND orig_br_ccn_loc_reltn_id=0.0
   AND br_ccn_loc_reltn_id > 0
  WITH nocounter
 ;end update
 CALL errorcheck("Fail27")
 DELETE  FROM br_ccn_loc_ptsvc_reltn ptr
  WHERE ptr.br_ccn_loc_reltn_id IN (
  (SELECT
   br_ccn_loc_reltn_id
   FROM br_ccn_loc_reltn
   WHERE orig_br_ccn_loc_reltn_id > 0
    AND br_ccn_loc_reltn_id > 0
    AND ((active_ind=0) OR (end_effective_dt_tm < cnvtdatetime(curdate,curtime3))) ))
  WITH nocounter
 ;end delete
 DELETE  FROM br_ccn_loc_reltn locr
  WHERE locr.orig_br_ccn_loc_reltn_id > 0
   AND locr.br_ccn_loc_reltn_id > 0
   AND ((locr.active_ind=0) OR (locr.end_effective_dt_tm < cnvtdatetime(curdate,curtime3)))
  WITH nocounter
 ;end delete
 CALL errorcheck("Fail28")
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 FREE SET url_reltn
 RECORD url_reltn(
   1 reltn[*]
     2 br_prtl_url_se_r_cd_r_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
 )
 SELECT INTO "nl:"
  FROM br_prtl_url_se_r_cd_r r
  PLAN (r
   WHERE r.active_ind=0
    AND r.br_prtl_url_se_r_cd_r_id > 0
    AND r.orig_prtl_url_se_r_cd_r_id > 0
    AND r.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(url_reltn->reltn,pcnt), url_reltn->reltn[pcnt].
   br_prtl_url_se_r_cd_r_id = r.br_prtl_url_se_r_cd_r_id,
   url_reltn->reltn[pcnt].beg_effective_dt_tm = r.beg_effective_dt_tm
   IF (r.end_effective_dt_tm < cnvtdatetime(curdate,curtime3))
    url_reltn->reltn[pcnt].end_effective_dt_tm = r.end_effective_dt_tm
   ELSE
    url_reltn->reltn[pcnt].end_effective_dt_tm = r.beg_effective_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 CALL errorcheck("Fail29")
 FOR (prtl = 1 TO pcnt)
   UPDATE  FROM br_prtl_url_se_r_cd_r
    SET beg_effective_dt_tm = cnvtdatetime(url_reltn->reltn[prtl].beg_effective_dt_tm), updt_cnt = (
     updt_cnt+ 1), updt_dt_tm = cnvtdatetime(curdate,curtime3),
     updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_applctx = reqinfo->updt_applctx
    WHERE (orig_prtl_url_se_r_cd_r_id=url_reltn->reltn[prtl].br_prtl_url_se_r_cd_r_id)
     AND active_ind=1
    WITH nocounter
   ;end update
   CALL errorcheck("Fail30")
   UPDATE  FROM br_prtl_url_se_r_cd_r
    SET end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), beg_effective_dt_tm =
     cnvtdatetime(url_reltn->reltn[prtl].end_effective_dt_tm), updt_cnt = (updt_cnt+ 1),
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = reqinfo->updt_id, updt_task = reqinfo->
     updt_task,
     updt_applctx = reqinfo->updt_applctx
    WHERE (orig_prtl_url_se_r_cd_r_id=url_reltn->reltn[prtl].br_prtl_url_se_r_cd_r_id)
     AND active_ind=0
    WITH nocounter
   ;end update
   CALL errorcheck("Fail31")
 ENDFOR
 FREE RECORD ccn_ids
 FREE RECORD ccn_reltns
 FREE RECORD epids
 SUBROUTINE errorcheck(failmsg)
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(failmsg,":",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
