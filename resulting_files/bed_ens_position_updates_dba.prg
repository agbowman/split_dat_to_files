CREATE PROGRAM bed_ens_position_updates:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prefs_to_delete(
   1 prefs[*]
     2 pref_id = f8
     2 pref_table = vc
 )
 RECORD temp_vp(
   1 prefs[*]
     2 application_number = f8
     2 prsnl_id = f8
     2 frame_type = vc
     2 view_name = vc
     2 view_seq = i4
 )
 RECORD temp_vcp(
   1 prefs[*]
     2 application_number = f8
     2 prsnl_id = f8
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
 )
 RECORD temp_dp(
   1 prefs[*]
     2 application_number = f8
     2 prsnl_id = f8
     2 person_id = f8
     2 view_name = vc
     2 view_seq = i4
     2 comp_name = vc
     2 comp_seq = i4
 )
 RECORD temp_ap(
   1 prefs[*]
     2 application_number = f8
     2 prsnl_id = f8
 )
 RECORD priv_locs(
   1 ids[*]
     2 priv_loc_reltn_id = f8
 )
 RECORD privs(
   1 ids[*]
     2 privilege_id = f8
 )
 RECORD task_tabs(
   1 qual_tab[*]
     2 tl_tab_id = f8
 )
 RECORD request_tv(
   1 from_person_id = f8
   1 to_person_id = f8
   1 from_position_cd = f8
   1 to_position_cd = f8
 )
 RECORD pal(
   1 loclist[*]
     2 loc_cd = f8
     2 pip_id = f8
 )
 RECORD request_pal(
   1 copy_from_position_code_value = f8
   1 copy_from_location_code_value = f8
   1 copy_to[*]
     2 position_code_value = f8
     2 location_code_value = f8
   1 always_delete_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pcnt = size(request->positions,5)
 FOR (p = 1 TO pcnt)
   IF ((request->positions[p].copy_app_grp_rel_ind=1))
    DELETE  FROM application_group ag
     WHERE (ag.position_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    INSERT  FROM application_group
     (application_group_id, position_cd, person_id,
     app_group_cd, beg_effective_dt_tm, end_effective_dt_tm,
     updt_dt_tm, updt_id, updt_task,
     updt_cnt, updt_applctx)(SELECT
      seq(reference_seq,nextval), request->positions[p].copy_to_code_value, 0,
      ag.app_group_cd, cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100"),
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM application_group ag
      WHERE (ag.position_cd=request->positions[p].copy_from_code_value))
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_prefs_ind=1))
    SET prefcnt = 0
    SELECT DISTINCT INTO "NL:"
     FROM view_prefs p
     WHERE (p.position_cd=request->positions[p].copy_to_code_value)
      AND p.active_ind=1
     DETAIL
      prefcnt = (prefcnt+ 1), stat = alterlist(prefs_to_delete->prefs,prefcnt), prefs_to_delete->
      prefs[prefcnt].pref_id = p.view_prefs_id,
      prefs_to_delete->prefs[prefcnt].pref_table = "VIEW_PREFS"
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "NL:"
     FROM view_comp_prefs p
     WHERE (p.position_cd=request->positions[p].copy_to_code_value)
      AND p.active_ind=1
     DETAIL
      prefcnt = (prefcnt+ 1), stat = alterlist(prefs_to_delete->prefs,prefcnt), prefs_to_delete->
      prefs[prefcnt].pref_id = p.view_comp_prefs_id,
      prefs_to_delete->prefs[prefcnt].pref_table = "VIEW_COMP_PREFS"
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "NL:"
     FROM detail_prefs p
     WHERE (p.position_cd=request->positions[p].copy_to_code_value)
      AND p.active_ind=1
     DETAIL
      prefcnt = (prefcnt+ 1), stat = alterlist(prefs_to_delete->prefs,prefcnt), prefs_to_delete->
      prefs[prefcnt].pref_id = p.detail_prefs_id,
      prefs_to_delete->prefs[prefcnt].pref_table = "DETAIL_PREFS"
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "NL:"
     FROM app_prefs p
     WHERE (p.position_cd=request->positions[p].copy_to_code_value)
      AND p.active_ind=1
     DETAIL
      prefcnt = (prefcnt+ 1), stat = alterlist(prefs_to_delete->prefs,prefcnt), prefs_to_delete->
      prefs[prefcnt].pref_id = p.app_prefs_id,
      prefs_to_delete->prefs[prefcnt].pref_table = "APP_PREFS"
     WITH nocounter
    ;end select
    IF (prefcnt > 0)
     DELETE  FROM view_prefs p,
       (dummyt d  WITH seq = prefcnt)
      SET p.seq = 1
      PLAN (d
       WHERE (prefs_to_delete->prefs[d.seq].pref_table="VIEW_PREFS"))
       JOIN (p
       WHERE (p.view_prefs_id=prefs_to_delete->prefs[d.seq].pref_id))
      WITH nocounter
     ;end delete
     DELETE  FROM view_comp_prefs p,
       (dummyt d  WITH seq = prefcnt)
      SET p.seq = 1
      PLAN (d
       WHERE (prefs_to_delete->prefs[d.seq].pref_table="VIEW_COMP_PREFS"))
       JOIN (p
       WHERE (p.view_comp_prefs_id=prefs_to_delete->prefs[d.seq].pref_id))
      WITH nocounter
     ;end delete
     DELETE  FROM detail_prefs p,
       (dummyt d  WITH seq = prefcnt)
      SET p.seq = 1
      PLAN (d
       WHERE (prefs_to_delete->prefs[d.seq].pref_table="DETAIL_PREFS"))
       JOIN (p
       WHERE (p.detail_prefs_id=prefs_to_delete->prefs[d.seq].pref_id))
      WITH nocounter
     ;end delete
     DELETE  FROM app_prefs p,
       (dummyt d  WITH seq = prefcnt)
      SET p.seq = 1
      PLAN (d
       WHERE (prefs_to_delete->prefs[d.seq].pref_table="APP_PREFS"))
       JOIN (p
       WHERE (p.app_prefs_id=prefs_to_delete->prefs[d.seq].pref_id))
      WITH nocounter
     ;end delete
     DELETE  FROM name_value_prefs p,
       (dummyt d  WITH seq = prefcnt)
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.parent_entity_id=prefs_to_delete->prefs[d.seq].pref_id)
        AND (p.parent_entity_name=prefs_to_delete->prefs[d.seq].pref_table))
      WITH nocounter
     ;end delete
    ENDIF
    SET vp_count = 0
    SELECT DISTINCT INTO "NL:"
     vp.application_number, vp.prsnl_id, vp.frame_type,
     vp.view_name, vp.view_seq
     FROM view_prefs vp
     WHERE (vp.position_cd=request->positions[p].copy_from_code_value)
      AND vp.active_ind=1
     ORDER BY vp.application_number, vp.prsnl_id, vp.frame_type,
      vp.view_name, vp.view_seq
     DETAIL
      vp_count = (vp_count+ 1), stat = alterlist(temp_vp->prefs,vp_count), temp_vp->prefs[vp_count].
      application_number = vp.application_number,
      temp_vp->prefs[vp_count].prsnl_id = vp.prsnl_id, temp_vp->prefs[vp_count].frame_type = vp
      .frame_type, temp_vp->prefs[vp_count].view_name = vp.view_name,
      temp_vp->prefs[vp_count].view_seq = vp.view_seq
     WITH nocounter
    ;end select
    IF (vp_count > 0)
     INSERT  FROM view_prefs vp,
       (dummyt d  WITH seq = vp_count)
      SET vp.view_prefs_id = seq(carenet_seq,nextval), vp.application_number = temp_vp->prefs[d.seq].
       application_number, vp.position_cd = request->positions[p].copy_to_code_value,
       vp.prsnl_id = temp_vp->prefs[d.seq].prsnl_id, vp.frame_type = temp_vp->prefs[d.seq].frame_type,
       vp.view_name = temp_vp->prefs[d.seq].view_name,
       vp.view_seq = temp_vp->prefs[d.seq].view_seq, vp.active_ind = 1, vp.updt_id = reqinfo->updt_id,
       vp.updt_cnt = 0, vp.updt_task = reqinfo->updt_task, vp.updt_applctx = reqinfo->updt_applctx,
       vp.updt_dt_tm = cnvtdatetime(curdate,curtime)
      PLAN (d)
       JOIN (vp)
      WITH nocounter
     ;end insert
    ENDIF
    SET vcp_count = 0
    SELECT DISTINCT INTO "NL:"
     vcp.application_number, vcp.prsnl_id, vcp.view_name,
     vcp.view_seq, vcp.comp_name, vcp.comp_seq
     FROM view_comp_prefs vcp
     WHERE (vcp.position_cd=request->positions[p].copy_from_code_value)
      AND vcp.active_ind=1
     ORDER BY vcp.application_number, vcp.prsnl_id, vcp.view_name,
      vcp.view_seq, vcp.comp_name, vcp.comp_seq
     DETAIL
      vcp_count = (vcp_count+ 1), stat = alterlist(temp_vcp->prefs,vcp_count), temp_vcp->prefs[
      vcp_count].application_number = vcp.application_number,
      temp_vcp->prefs[vcp_count].prsnl_id = vcp.prsnl_id, temp_vcp->prefs[vcp_count].view_name = vcp
      .view_name, temp_vcp->prefs[vcp_count].view_seq = vcp.view_seq,
      temp_vcp->prefs[vcp_count].comp_name = vcp.comp_name, temp_vcp->prefs[vcp_count].comp_seq = vcp
      .comp_seq
     WITH nocounter
    ;end select
    IF (vcp_count > 0)
     INSERT  FROM view_comp_prefs vcp,
       (dummyt d  WITH seq = vcp_count)
      SET vcp.view_comp_prefs_id = seq(carenet_seq,nextval), vcp.application_number = temp_vcp->
       prefs[d.seq].application_number, vcp.position_cd = request->positions[p].copy_to_code_value,
       vcp.prsnl_id = temp_vcp->prefs[d.seq].prsnl_id, vcp.view_name = temp_vcp->prefs[d.seq].
       view_name, vcp.view_seq = temp_vcp->prefs[d.seq].view_seq,
       vcp.comp_name = temp_vcp->prefs[d.seq].comp_name, vcp.comp_seq = temp_vcp->prefs[d.seq].
       comp_seq, vcp.active_ind = 1,
       vcp.updt_id = reqinfo->updt_id, vcp.updt_cnt = 0, vcp.updt_task = reqinfo->updt_task,
       vcp.updt_applctx = reqinfo->updt_applctx, vcp.updt_dt_tm = cnvtdatetime(curdate,curtime)
      PLAN (d)
       JOIN (vcp)
      WITH nocounter
     ;end insert
    ENDIF
    SET dp_count = 0
    SELECT DISTINCT INTO "NL:"
     dp.application_number, dp.prsnl_id, dp.person_id,
     dp.view_name, dp.view_seq, dp.comp_name,
     dp.comp_seq
     FROM detail_prefs dp
     WHERE (dp.position_cd=request->positions[p].copy_from_code_value)
      AND dp.active_ind=1
     ORDER BY dp.application_number, dp.prsnl_id, dp.person_id,
      dp.view_name, dp.view_seq, dp.comp_name,
      dp.comp_seq
     DETAIL
      dp_count = (dp_count+ 1), stat = alterlist(temp_dp->prefs,dp_count), temp_dp->prefs[dp_count].
      application_number = dp.application_number,
      temp_dp->prefs[dp_count].prsnl_id = dp.prsnl_id, temp_dp->prefs[dp_count].person_id = dp
      .person_id, temp_dp->prefs[dp_count].view_name = dp.view_name,
      temp_dp->prefs[dp_count].view_seq = dp.view_seq, temp_dp->prefs[dp_count].comp_name = dp
      .comp_name, temp_dp->prefs[dp_count].comp_seq = dp.comp_seq
     WITH nocounter
    ;end select
    IF (dp_count > 0)
     INSERT  FROM detail_prefs dp,
       (dummyt d  WITH seq = dp_count)
      SET dp.detail_prefs_id = seq(carenet_seq,nextval), dp.application_number = temp_dp->prefs[d.seq
       ].application_number, dp.position_cd = request->positions[p].copy_to_code_value,
       dp.prsnl_id = temp_dp->prefs[d.seq].prsnl_id, dp.person_id = temp_dp->prefs[d.seq].person_id,
       dp.view_name = temp_dp->prefs[d.seq].view_name,
       dp.view_seq = temp_dp->prefs[d.seq].view_seq, dp.comp_name = temp_dp->prefs[d.seq].comp_name,
       dp.comp_seq = temp_dp->prefs[d.seq].comp_seq,
       dp.active_ind = 1, dp.updt_id = reqinfo->updt_id, dp.updt_cnt = 0,
       dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->updt_applctx, dp.updt_dt_tm =
       cnvtdatetime(curdate,curtime)
      PLAN (d)
       JOIN (dp)
      WITH nocounter
     ;end insert
    ENDIF
    SET ap_count = 0
    SELECT DISTINCT INTO "NL:"
     ap.application_number, ap.prsnl_id
     FROM app_prefs ap
     WHERE (ap.position_cd=request->positions[p].copy_from_code_value)
      AND ap.active_ind=1
     ORDER BY ap.application_number, ap.prsnl_id
     DETAIL
      ap_count = (ap_count+ 1), stat = alterlist(temp_ap->prefs,ap_count), temp_ap->prefs[ap_count].
      application_number = ap.application_number,
      temp_ap->prefs[ap_count].prsnl_id = ap.prsnl_id
     WITH nocounter
    ;end select
    IF (ap_count > 0)
     INSERT  FROM app_prefs ap,
       (dummyt d  WITH seq = ap_count)
      SET ap.app_prefs_id = seq(carenet_seq,nextval), ap.application_number = temp_ap->prefs[d.seq].
       application_number, ap.position_cd = request->positions[p].copy_to_code_value,
       ap.prsnl_id = temp_ap->prefs[d.seq].prsnl_id, ap.active_ind = 1, ap.updt_id = reqinfo->updt_id,
       ap.updt_cnt = 0, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx,
       ap.updt_dt_tm = cnvtdatetime(curdate,curtime)
      PLAN (d)
       JOIN (ap)
      WITH nocounter
     ;end insert
    ENDIF
    INSERT  FROM name_value_prefs
     (name_value_prefs_id, parent_entity_name, parent_entity_id,
     pvc_name, pvc_value, merge_name,
     merge_id, sequence, active_ind,
     updt_dt_tm, updt_id, updt_task,
     updt_cnt, updt_applctx)(SELECT
      seq(carenet_seq,nextval), nvp.parent_entity_name, t2.view_prefs_id,
      nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
      nvp.merge_id, nvp.sequence, nvp.active_ind,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM name_value_prefs nvp,
       view_prefs t1,
       view_prefs t2
      WHERE (t1.position_cd=request->positions[p].copy_from_code_value)
       AND t2.application_number=t1.application_number
       AND (t2.position_cd=request->positions[p].copy_to_code_value)
       AND t2.prsnl_id=t1.prsnl_id
       AND t2.frame_type=t1.frame_type
       AND t2.view_name=t1.view_name
       AND t2.view_seq=t1.view_seq
       AND t2.active_ind=t1.active_ind
       AND nvp.parent_entity_name="VIEW_PREFS"
       AND nvp.parent_entity_id=t1.view_prefs_id)
     WITH nocounter
    ;end insert
    INSERT  FROM name_value_prefs nvp1
     (nvp1.name_value_prefs_id, nvp1.parent_entity_name, nvp1.parent_entity_id,
     nvp1.pvc_name, nvp1.pvc_value, nvp1.merge_name,
     nvp1.merge_id, nvp1.sequence, nvp1.active_ind,
     nvp1.updt_dt_tm, nvp1.updt_id, nvp1.updt_task,
     nvp1.updt_cnt, nvp1.updt_applctx)(SELECT
      seq(carenet_seq,nextval), nvp.parent_entity_name, t2.view_comp_prefs_id,
      nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
      nvp.merge_id, nvp.sequence, nvp.active_ind,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM name_value_prefs nvp,
       view_comp_prefs t1,
       view_comp_prefs t2
      WHERE (t1.position_cd=request->positions[p].copy_from_code_value)
       AND t2.application_number=t1.application_number
       AND (t2.position_cd=request->positions[p].copy_to_code_value)
       AND t2.prsnl_id=t1.prsnl_id
       AND t2.view_name=t1.view_name
       AND t2.view_seq=t1.view_seq
       AND t2.comp_name=t1.comp_name
       AND t2.comp_seq=t1.comp_seq
       AND t2.active_ind=t1.active_ind
       AND nvp.parent_entity_id=t1.view_comp_prefs_id
       AND nvp.parent_entity_name="VIEW_COMP_PREFS")
     WITH nocounter
    ;end insert
    INSERT  FROM name_value_prefs
     (name_value_prefs_id, parent_entity_name, parent_entity_id,
     pvc_name, pvc_value, merge_name,
     merge_id, sequence, active_ind,
     updt_dt_tm, updt_id, updt_task,
     updt_cnt, updt_applctx)(SELECT
      seq(carenet_seq,nextval), nvp.parent_entity_name, t2.detail_prefs_id,
      nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
      nvp.merge_id, nvp.sequence, nvp.active_ind,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM name_value_prefs nvp,
       detail_prefs t1,
       detail_prefs t2
      WHERE (t1.position_cd=request->positions[p].copy_from_code_value)
       AND t2.application_number=t1.application_number
       AND (t2.position_cd=request->positions[p].copy_to_code_value)
       AND t2.prsnl_id=t1.prsnl_id
       AND t2.person_id=t1.person_id
       AND t2.view_name=t1.view_name
       AND t2.view_seq=t1.view_seq
       AND t2.comp_name=t1.comp_name
       AND t2.comp_seq=t1.comp_seq
       AND t2.active_ind=t1.active_ind
       AND nvp.parent_entity_id=t1.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS")
     WITH nocounter
    ;end insert
    INSERT  FROM name_value_prefs
     (name_value_prefs_id, parent_entity_name, parent_entity_id,
     pvc_name, pvc_value, merge_name,
     merge_id, sequence, active_ind,
     updt_dt_tm, updt_id, updt_task,
     updt_cnt, updt_applctx)(SELECT
      seq(carenet_seq,nextval), nvp.parent_entity_name, t2.app_prefs_id,
      nvp.pvc_name, nvp.pvc_value, nvp.merge_name,
      nvp.merge_id, nvp.sequence, nvp.active_ind,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM name_value_prefs nvp,
       app_prefs t1,
       app_prefs t2
      WHERE (t1.position_cd=request->positions[p].copy_from_code_value)
       AND t2.application_number=t1.application_number
       AND (t2.position_cd=request->positions[p].copy_to_code_value)
       AND t2.prsnl_id=t1.prsnl_id
       AND t2.active_ind=t1.active_ind
       AND nvp.parent_entity_id=t1.app_prefs_id
       AND nvp.parent_entity_name="APP_PREFS")
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_privs_ind=1))
    SET stat = initrec(priv_locs)
    SET privloc_cnt = 0
    SELECT INTO "NL:"
     FROM priv_loc_reltn plr
     WHERE plr.person_id=0.0
      AND (plr.position_cd=request->positions[p].copy_to_code_value)
      AND plr.ppr_cd=0.0
      AND plr.location_cd=0.0
     DETAIL
      privloc_cnt = (privloc_cnt+ 1), stat = alterlist(priv_locs->ids,privloc_cnt), priv_locs->ids[
      privloc_cnt].priv_loc_reltn_id = plr.priv_loc_reltn_id
     WITH nocounter
    ;end select
    IF (privloc_cnt > 0)
     SET stat = initrec(privs)
     SET priv_cnt = 0
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = privloc_cnt),
       privilege p
      PLAN (d)
       JOIN (p
       WHERE (p.priv_loc_reltn_id=priv_locs->ids[d.seq].priv_loc_reltn_id))
      DETAIL
       priv_cnt = (priv_cnt+ 1), stat = alterlist(privs->ids,priv_cnt), privs->ids[priv_cnt].
       privilege_id = p.privilege_id
      WITH nocounter
     ;end select
     DELETE  FROM priv_loc_reltn p,
       (dummyt d  WITH seq = privloc_cnt)
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.priv_loc_reltn_id=priv_locs->ids[d.seq].priv_loc_reltn_id))
      WITH nocounter
     ;end delete
     DELETE  FROM privilege p,
       (dummyt d  WITH seq = privloc_cnt)
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.priv_loc_reltn_id=priv_locs->ids[d.seq].priv_loc_reltn_id))
      WITH nocounter
     ;end delete
     IF (priv_cnt > 0)
      DELETE  FROM privilege_exception p,
        (dummyt d  WITH seq = priv_cnt)
       SET p.seq = 1
       PLAN (d)
        JOIN (p
        WHERE (p.privilege_id=privs->ids[d.seq].privilege_id))
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
    SET new_priv_loc_reltn_id = 0.0
    SELECT INTO "nl:"
     z = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      new_priv_loc_reltn_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    INSERT  FROM priv_loc_reltn plr
     SET plr.priv_loc_reltn_id = new_priv_loc_reltn_id, plr.person_id = 0.0, plr.position_cd =
      request->positions[p].copy_to_code_value,
      plr.ppr_cd = 0.0, plr.location_cd = 0.0, plr.updt_cnt = 0,
      plr.updt_dt_tm = cnvtdatetime(curdate,curtime), plr.updt_id = reqinfo->updt_id, plr.updt_task
       = reqinfo->updt_task,
      plr.updt_applctx = reqinfo->updt_applctx, plr.active_ind = 1, plr.active_status_cd = active_cd,
      plr.active_status_dt_tm = cnvtdatetime(curdate,curtime), plr.active_status_prsnl_id = reqinfo->
      updt_id, plr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
      plr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     WITH nocounter
    ;end insert
    SET stat = initrec(priv_locs)
    SET privloc_cnt = 0
    SELECT INTO "NL:"
     FROM priv_loc_reltn plr
     WHERE plr.person_id=0.0
      AND (plr.position_cd=request->positions[p].copy_from_code_value)
      AND plr.ppr_cd=0.0
      AND plr.location_cd=0.0
     DETAIL
      privloc_cnt = (privloc_cnt+ 1), stat = alterlist(priv_locs->ids,privloc_cnt), priv_locs->ids[
      privloc_cnt].priv_loc_reltn_id = plr.priv_loc_reltn_id
     WITH nocounter
    ;end select
    FOR (t = 1 TO privloc_cnt)
     INSERT  FROM privilege
      (privilege_id, priv_loc_reltn_id, privilege_cd,
      priv_value_cd, updt_cnt, updt_dt_tm,
      updt_id, updt_task, updt_applctx,
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, restr_method_cd, log_grouping_cd)(SELECT
       seq(reference_seq,nextval), new_priv_loc_reltn_id, p.privilege_cd,
       p.priv_value_cd, 0, cnvtdatetime(curdate,curtime),
       reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
       p.active_ind, p.active_status_cd, p.active_status_dt_tm,
       p.active_status_prsnl_id, p.restr_method_cd, p.log_grouping_cd
       FROM privilege p
       WHERE (p.priv_loc_reltn_id=priv_locs->ids[t].priv_loc_reltn_id)
        AND p.active_ind=1)
      WITH nocounter
     ;end insert
     INSERT  FROM privilege_exception
      (privilege_exception_id, privilege_id, exception_type_cd,
      exception_id, updt_cnt, updt_dt_tm,
      updt_id, updt_task, updt_applctx,
      active_ind, active_status_cd, active_status_dt_tm,
      active_status_prsnl_id, exception_entity_name, event_set_name)(SELECT
       seq(reference_seq,nextval), t2.privilege_id, pe.exception_type_cd,
       pe.exception_id, 0, cnvtdatetime(curdate,curtime),
       reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx,
       pe.active_ind, pe.active_status_cd, pe.active_status_dt_tm,
       pe.active_status_prsnl_id, pe.exception_entity_name, pe.event_set_name
       FROM privilege_exception pe,
        privilege t1,
        privilege t2
       WHERE (t1.priv_loc_reltn_id=priv_locs->ids[t].priv_loc_reltn_id)
        AND t2.priv_loc_reltn_id=new_priv_loc_reltn_id
        AND t2.privilege_cd=t1.privilege_cd
        AND t2.priv_value_cd=t1.priv_value_cd
        AND t2.active_ind=t1.active_ind
        AND pe.privilege_id=t1.privilege_id)
      WITH nocounter
     ;end insert
    ENDFOR
   ENDIF
   IF ((request->positions[p].copy_prov_rel_ind=1))
    DELETE  FROM psn_ppr_reltn ppr
     WHERE (ppr.position_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    INSERT  FROM psn_ppr_reltn
     (position_cd, ppr_cd, updt_cnt,
     updt_dt_tm, updt_id, updt_task,
     updt_applctx, active_ind, active_status_cd,
     active_status_dt_tm, active_status_prsnl_id, beg_effective_dt_tm,
     end_effective_dt_tm)(SELECT
      request->positions[p].copy_to_code_value, ppr.ppr_cd, 0,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      reqinfo->updt_applctx, ppr.active_ind, ppr.active_status_cd,
      ppr.active_status_dt_tm, ppr.active_status_prsnl_id, cnvtdatetime(curdate,curtime3),
      cnvtdatetime("31-DEC-2100")
      FROM psn_ppr_reltn ppr
      WHERE (ppr.position_cd=request->positions[p].copy_from_code_value)
       AND ppr.active_ind=1)
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_task_list_views_ind=1))
    SET tabcnt = 0
    SELECT INTO "NL:"
     FROM tl_tab_position_xref t
     WHERE (t.position_cd=request->positions[p].copy_to_code_value)
     DETAIL
      tabcnt = (tabcnt+ 1), stat = alterlist(task_tabs->qual_tab,tabcnt), task_tabs->qual_tab[tabcnt]
      .tl_tab_id = t.tl_tab_id
     WITH nocounter
    ;end select
    DELETE  FROM tl_tab_position_xref t
     WHERE (t.position_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM tl_multipatient_xref t
     WHERE (t.parent_entity_id=request->positions[p].copy_to_code_value)
      AND t.multipatient_ind=1
     WITH nocounter
    ;end delete
    DELETE  FROM tl_multpat_col_content t
     WHERE (t.parent_entity_id=request->positions[p].copy_to_code_value)
      AND t.multipatient_ind=1
     WITH nocounter
    ;end delete
    IF (tabcnt > 0)
     DELETE  FROM tl_tab_content t,
       (dummyt d  WITH seq = tabcnt)
      SET t.seq = 1
      PLAN (d)
       JOIN (t
       WHERE (t.tl_tab_id=task_tabs->qual_tab[d.seq].tl_tab_id))
      WITH nocounter
     ;end delete
     DELETE  FROM tl_column_content t,
       (dummyt d  WITH seq = tabcnt)
      SET t.seq = 1
      PLAN (d)
       JOIN (t
       WHERE (t.tl_tab_id=task_tabs->qual_tab[d.seq].tl_tab_id))
      WITH nocounter
     ;end delete
     DELETE  FROM tl_eligible_task_code t,
       (dummyt d  WITH seq = tabcnt)
      SET t.seq = 1
      PLAN (d)
       JOIN (t
       WHERE (t.tl_tab_id=task_tabs->qual_tab[d.seq].tl_tab_id))
      WITH nocounter
     ;end delete
     DELETE  FROM tl_eligible_task_code t,
       (dummyt d  WITH seq = tabcnt)
      SET t.seq = 1
      PLAN (d)
       JOIN (t
       WHERE (t.tl_tab_id=task_tabs->qual_tab[d.seq].tl_tab_id))
      WITH nocounter
     ;end delete
     DELETE  FROM tl_tab_medication t,
       (dummyt d  WITH seq = tabcnt)
      SET t.seq = 1
      PLAN (d)
       JOIN (t
       WHERE (t.tl_tab_id=task_tabs->qual_tab[d.seq].tl_tab_id))
      WITH nocounter
     ;end delete
    ENDIF
    SET request_tv->from_person_id = 0
    SET request_tv->to_person_id = 0
    SET request_tv->from_position_cd = request->positions[p].copy_from_code_value
    SET request_tv->to_position_cd = request->positions[p].copy_to_code_value
    SET trace = recpersist
    FREE SET internal_tabs
    EXECUTE tsk_add_copy_task_list  WITH replace("REQUEST",request_tv), replace("REPLY",reply_tv)
    SET trace = norecpersist
   ENDIF
   IF ((request->positions[p].copy_task_reltn_ind=1))
    DELETE  FROM order_task_position_xref otpx
     WHERE (otpx.position_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    INSERT  FROM order_task_position_xref
     (position_cd, reference_task_id, updt_cnt,
     updt_dt_tm, updt_id, updt_task,
     updt_applctx)(SELECT
      request->positions[p].copy_to_code_value, otpx.reference_task_id, 0,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      reqinfo->updt_applctx
      FROM order_task_position_xref otpx
      WHERE (otpx.position_cd=request->positions[p].copy_from_code_value))
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_note_type_reltn_ind=1))
    DELETE  FROM note_type_list ntl
     WHERE (ntl.role_type_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    INSERT  FROM note_type_list
     (note_type_list_id, note_type_id, role_type_cd,
     prsnl_id, seq_num, updt_cnt,
     updt_dt_tm, updt_id, updt_task,
     updt_applctx)(SELECT
      seq(reference_seq,nextval), ntl.note_type_id, request->positions[p].copy_to_code_value,
      ntl.prsnl_id, ntl.seq_num, 0,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      reqinfo->updt_applctx
      FROM note_type_list ntl
      WHERE (ntl.role_type_cd=request->positions[p].copy_from_code_value))
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_time_frame_reltn_ind=1))
    DELETE  FROM tl_tf_position_xref ttpx
     WHERE (ttpx.position_cd=request->positions[p].copy_to_code_value)
     WITH nocounter
    ;end delete
    INSERT  FROM tl_tf_position_xref
     (tl_time_frame_id, position_cd, updt_cnt,
     updt_dt_tm, updt_id, updt_task,
     updt_applctx)(SELECT
      ttpx.tl_time_frame_id, request->positions[p].copy_to_code_value, 0,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      reqinfo->updt_applctx
      FROM tl_tf_position_xref ttpx
      WHERE (ttpx.position_cd=request->positions[p].copy_from_code_value))
     WITH nocounter
    ;end insert
   ENDIF
   IF ((request->positions[p].copy_pal_psn_views_ind=1))
    SET request_pal->copy_from_position_code_value = request->positions[p].copy_from_code_value
    SET request_pal->copy_from_location_code_value = 0
    SET stat = alterlist(request_pal->copy_to,1)
    SET request_pal->copy_to[1].position_code_value = request->positions[p].copy_to_code_value
    SET request_pal->copy_to[1].location_code_value = 0
    SET request_pal->always_delete_ind = 1
    SET trace = recpersist
    EXECUTE bed_copy_pal_settings  WITH replace("REQUEST",request_pal), replace("REPLY",reply_pal)
    SET trace = norecpersist
   ENDIF
   IF ((request->positions[p].copy_pal_psn_loc_views_ind=1))
    RECORD del_view(
      1 qual[*]
        2 id = f8
    )
    SET dv_cnt = 0
    SELECT INTO "nl:"
     FROM pip p
     WHERE (p.position_cd=request->positions[p].copy_to_code_value)
      AND p.location_cd > 0
      AND p.prsnl_id=0
     DETAIL
      dv_cnt = (dv_cnt+ 1), stat = alterlist(del_view->qual,dv_cnt), del_view->qual[dv_cnt].id = p
      .pip_id
     WITH nocounter
    ;end select
    IF (dv_cnt > 0)
     FOR (dv = 1 TO dv_cnt)
       FREE SET del_sect
       RECORD del_sect(
         1 qual[*]
           2 id = f8
           2 cd = f8
       )
       SET ds_cnt = 0
       SELECT INTO "nl:"
        FROM pip_section s
        PLAN (s
         WHERE (s.pip_id=del_view->qual[dv].id))
        DETAIL
         ds_cnt = (ds_cnt+ 1), stat = alterlist(del_sect->qual,ds_cnt), del_sect->qual[ds_cnt].id = s
         .pip_section_id,
         del_sect->qual[ds_cnt].cd = s.section_type_cd
        WITH nocounter
       ;end select
       IF (ds_cnt > 0)
        FOR (ds = 1 TO ds_cnt)
          DELETE  FROM pip_prefs p
           WHERE p.parent_entity_name="PIP_SECTION"
            AND (p.parent_entity_id=del_sect->qual[ds].id)
            AND p.prsnl_id=0
           WITH nocounter
          ;end delete
          FREE SET del_col
          RECORD del_col(
            1 qual[*]
              2 id = f8
          )
          SET dc_cnt = 0
          SELECT INTO "nl:"
           FROM pip_column c
           PLAN (c
            WHERE (c.pip_section_id=del_sect->qual[ds].id)
             AND c.prsnl_id=0)
           DETAIL
            dc_cnt = (dc_cnt+ 1), stat = alterlist(del_col->qual,dc_cnt), del_col->qual[dc_cnt].id =
            c.pip_column_id
           WITH nocounter
          ;end select
          IF (dc_cnt > 0)
           DELETE  FROM pip_prefs p,
             (dummyt d  WITH seq = value(dc_cnt))
            SET p.seq = 1
            PLAN (d)
             JOIN (p
             WHERE p.parent_entity_name="PIP_COLUMN"
              AND (p.parent_entity_id=del_col->qual[d.seq].id)
              AND p.prsnl_id=0)
            WITH nocounter
           ;end delete
          ENDIF
          DELETE  FROM pip_column c
           WHERE (c.pip_section_id=del_sect->qual[ds].id)
            AND c.prsnl_id=0
           WITH nocounter
          ;end delete
        ENDFOR
        DELETE  FROM pip_section s
         WHERE (s.pip_id=del_view->qual[dv].id)
         WITH nocounter
        ;end delete
       ENDIF
     ENDFOR
     DELETE  FROM pip p,
       (dummyt d  WITH seq = value(dv_cnt))
      SET p.seq = 1
      PLAN (d)
       JOIN (p
       WHERE (p.pip_id=del_view->qual[d.seq].id))
      WITH nocounter
     ;end delete
    ENDIF
    SET stat = initrec(pal)
    SET pal_loc_cnt = 0
    SELECT INTO "NL:"
     FROM pip p
     PLAN (p
      WHERE (p.position_cd=request->positions[p].copy_from_code_value)
       AND p.prsnl_id=0
       AND p.location_cd > 0)
     DETAIL
      pal_loc_cnt = (pal_loc_cnt+ 1), stat = alterlist(pal->loclist,pal_loc_cnt), pal->loclist[
      pal_loc_cnt].loc_cd = p.location_cd
     WITH nocounter
    ;end select
    FOR (l = 1 TO pal_loc_cnt)
      SET request_pal->copy_from_position_code_value = request->positions[p].copy_from_code_value
      SET request_pal->copy_from_location_code_value = pal->loclist[l].loc_cd
      SET stat = alterlist(request_pal->copy_to,1)
      SET request_pal->copy_to[1].position_code_value = request->positions[p].copy_to_code_value
      SET request_pal->copy_to[1].location_code_value = pal->loclist[l].loc_cd
      SET request_pal->always_delete_ind = 1
      SET trace = recpersist
      EXECUTE bed_copy_pal_settings  WITH replace("REQUEST",request_pal), replace("REPLY",reply_pal)
      SET trace = norecpersist
    ENDFOR
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
