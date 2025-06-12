CREATE PROGRAM dm_ecmb_wl_activity:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 DECLARE dm_cmb_get_context(dummy=i2) = null
 DECLARE dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) = null
 SUBROUTINE dm_cmb_get_context(dummy)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE dm_cmb_exc_maint_status(s_dcems_status,s_dcems_msg,s_dcems_tname)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 wl_criteria_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 sch_appt_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 worklist_cd = f8
     2 index_key = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 wl_activity_id = f8
 )
 FREE SET mergelist
 RECORD mergelist(
   1 group_cnt = i4
   1 groups[*]
     2 cnt = i4
     2 merge_wl_activity_id = f8
     2 qual[*]
       3 from_id = f8
       3 wl_criteria_id = f8
       3 person_id = f8
       3 encntr_id = f8
       3 sch_appt_id = f8
       3 beg_effective_dt_tm = f8
       3 end_effective_dt_tm = f8
       3 worklist_cd = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 wl_activity_id = f8
 )
 FREE SET updatelist
 RECORD updatelist(
   1 cnt = i4
   1 qual[*]
     2 from_id = f8
     2 wl_criteria_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 sch_appt_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 worklist_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 wl_activity_id = f8
 )
 FREE SET temprows
 RECORD temprows(
   1 cnt = i4
   1 qual[*]
     2 from_id = f8
     2 wl_criteria_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 sch_appt_id = f8
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 worklist_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 wl_activity_id = f8
 )
 DECLARE main(null) = null
 DECLARE updt_wl_activity_detail(s_from_wl_activity_id=f8,s_to_wl_activity_id=f8) = i2
 DECLARE del_from(s_df_pk_id=f8,s_df_to_fk_id=f8,s_df_prev_act_ind=i4,s_df_prev_act_status=f8) = i2
 DECLARE upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) = i2
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE index_occur_cnt = i4
 DECLARE cur_to_id = f8
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET index_occur_cnt = 0
 SET cur_to_id = request->xxx_combine[icombine].to_xxx_id
 SUBROUTINE main(null)
   DECLARE v_new_wla_id = f8
   DECLARE v_cust_loopcount = i4
   DECLARE v_cust_loopcount2 = i4
   DECLARE merge_wl_activity_id = f8
   SET v_cust_loopcount = 0
   SET v_cust_loopcount2 = 0
   SET merge_wl_activity_id = 0
   CALL dm_cmb_get_context(0)
   IF ((dm_cmb_cust_script->exc_maint_ind=1))
    SET stat = alterlist(dcem_request->qual,1)
    SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
    SET dcem_request->qual[1].child_entity = "WL_ACTIVITY"
    SET dcem_request->qual[1].op_type = "COMBINE"
    SET dcem_request->qual[1].script_name = "DM_ECMB_WL_ACTIVITY"
    SET dcem_request->qual[1].single_encntr_ind = 0
    SET dcem_request->qual[1].script_run_order = 1
    SET dcem_request->qual[1].del_chg_id_ind = 0
    SET dcem_request->qual[1].delete_row_ind = 0
    EXECUTE dm_cmb_exception_maint
    CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
     child_entity)
    GO TO exit_sub
   ENDIF
   SELECT INTO "nl:"
    frm.*
    FROM wl_activity frm
    WHERE frm.encntr_id IN (request->xxx_combine[icombine].from_xxx_id, cur_to_id)
     AND ((frm.active_ind+ 0)=1)
    DETAIL
     v_cust_count1 = (v_cust_count1+ 1)
     IF (mod(v_cust_count1,10)=1)
      stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
     ENDIF
     rreclist->from_rec[v_cust_count1].from_id = frm.encntr_id, rreclist->from_rec[v_cust_count1].
     beg_effective_dt_tm = frm.beg_effective_dt_tm, rreclist->from_rec[v_cust_count1].person_id = frm
     .person_id,
     rreclist->from_rec[v_cust_count1].end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->
     from_rec[v_cust_count1].encntr_id = frm.encntr_id, rreclist->from_rec[v_cust_count1].sch_appt_id
      = frm.sch_appt_id,
     rreclist->from_rec[v_cust_count1].wl_criteria_id = frm.wl_criteria_id, rreclist->from_rec[
     v_cust_count1].worklist_cd = frm.worklist_cd, rreclist->from_rec[v_cust_count1].active_ind = frm
     .active_ind,
     rreclist->from_rec[v_cust_count1].active_status_cd = frm.active_status_cd, rreclist->from_rec[
     v_cust_count1].wl_activity_id = frm.wl_activity_id, rreclist->from_rec[v_cust_count1].index_key
      = build(frm.wl_criteria_id,"_",frm.person_id,"_",frm.sch_appt_id)
    FOOT REPORT
     stat = alterlist(rreclist->from_rec,v_cust_count1)
    WITH forupdatewait(frm)
   ;end select
   SELECT
    index_key = trim(substring(1,255,rreclist->from_rec[d1.seq].index_key),3)
    FROM (dummyt d1  WITH seq = size(rreclist->from_rec,5))
    ORDER BY index_key
    HEAD index_key
     index_occur_cnt = 0, stat = initrec(temprows)
    DETAIL
     index_occur_cnt = (index_occur_cnt+ 1), stat = alterlist(temprows->qual,index_occur_cnt),
     temprows->qual[index_occur_cnt].from_id = rreclist->from_rec[d1.seq].from_id,
     temprows->qual[index_occur_cnt].beg_effective_dt_tm = rreclist->from_rec[d1.seq].
     beg_effective_dt_tm, temprows->qual[index_occur_cnt].person_id = rreclist->from_rec[d1.seq].
     person_id, temprows->qual[index_occur_cnt].end_effective_dt_tm = rreclist->from_rec[d1.seq].
     end_effective_dt_tm,
     temprows->qual[index_occur_cnt].encntr_id = rreclist->from_rec[d1.seq].encntr_id, temprows->
     qual[index_occur_cnt].sch_appt_id = rreclist->from_rec[d1.seq].sch_appt_id, temprows->qual[
     index_occur_cnt].wl_criteria_id = rreclist->from_rec[d1.seq].wl_criteria_id,
     temprows->qual[index_occur_cnt].worklist_cd = rreclist->from_rec[d1.seq].worklist_cd, temprows->
     qual[index_occur_cnt].active_ind = rreclist->from_rec[d1.seq].active_ind, temprows->qual[
     index_occur_cnt].active_status_cd = rreclist->from_rec[d1.seq].active_status_cd,
     temprows->qual[index_occur_cnt].wl_activity_id = rreclist->from_rec[d1.seq].wl_activity_id
     IF ((rreclist->from_rec[d1.seq].from_id=cur_to_id))
      merge_wl_activity_id = rreclist->from_rec[d1.seq].wl_activity_id
     ENDIF
    FOOT  index_key
     IF (index_occur_cnt > 1)
      mergelist->group_cnt = (mergelist->group_cnt+ 1), stat = alterlist(mergelist->groups,mergelist
       ->group_cnt), mergelist->groups[mergelist->group_cnt].merge_wl_activity_id =
      merge_wl_activity_id,
      mergelist->groups[mergelist->group_cnt].cnt = index_occur_cnt, stat = movereclist(temprows->
       qual,mergelist->groups[mergelist->group_cnt].qual,1,0,index_occur_cnt,
       1)
     ELSE
      stat = movereclist(temprows->qual,updatelist->qual,1,updatelist->cnt,1,
       1), updatelist->cnt = (updatelist->cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   IF ((mergelist->group_cnt > 0))
    FOR (v_cust_loopcount = 1 TO mergelist->group_cnt)
      FOR (v_cust_loopcount2 = 1 TO mergelist->groups[v_cust_loopcount].cnt)
        IF ((mergelist->groups[v_cust_loopcount].qual[v_cust_loopcount2].from_id != cur_to_id))
         CALL del_from(mergelist->groups[v_cust_loopcount].qual[v_cust_loopcount2].wl_activity_id,
          mergelist->groups[v_cust_loopcount].qual[v_cust_loopcount2].from_id,mergelist->groups[
          v_cust_loopcount].qual[v_cust_loopcount2].active_ind,mergelist->groups[v_cust_loopcount].
          qual[v_cust_loopcount2].active_status_cd)
         CALL updt_wl_activity_detail(mergelist->groups[v_cust_loopcount].qual[v_cust_loopcount2].
          wl_activity_id,mergelist->groups[v_cust_loopcount].merge_wl_activity_id)
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF ((updatelist->cnt > 0))
    FOR (v_cust_loopcount = 1 TO updatelist->cnt)
      IF ((updatelist->qual[v_cust_loopcount].from_id != cur_to_id))
       CALL upt_from(updatelist->qual[v_cust_loopcount].wl_activity_id,cur_to_id)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE updt_wl_activity_detail(s_from_wl_activity_id,s_to_wl_activity_id)
   DECLARE wad_cntr = i4
   DECLARE act_cntr = i4
   DECLARE search_cntr = i4
   DECLARE lt_index = i4
   DECLARE outbuf = vc
   DECLARE totlen = i4
   DECLARE blobdatasize = i4
   SET wad_cntr = 0
   SET act_cntr = 0
   SET search_cntr = 0
   SET lt_index = 0
   SET outbuf = " "
   SET totlen = 0
   SET blobdatasize = 0
   SELECT INTO "nl:"
    FROM wl_activity_detail wad
    PLAN (wad
     WHERE wad.wl_activity_id=s_from_wl_activity_id)
    ORDER BY wad.wl_activity_detail_id
    HEAD wad.wl_activity_detail_id
     icombinedet = (icombinedet+ 1), stat = alterlist(request->xxx_combine_det,icombinedet), request
     ->xxx_combine_det[icombinedet].combine_action_cd = upt,
     request->xxx_combine_det[icombinedet].entity_id = wad.wl_activity_id, request->xxx_combine_det[
     icombinedet].entity_name = "WL_ACTIVITY", request->xxx_combine_det[icombinedet].attribute_name
      = trim(build(wad.wl_activity_detail_id),3)
    WITH nocounter
   ;end select
   UPDATE  FROM wl_activity_detail wad
    SET wad.wl_activity_id = s_to_wl_activity_id, wad.updt_cnt = (wad.updt_cnt+ 1), wad.updt_id =
     reqinfo->updt_id,
     wad.updt_applctx = reqinfo->updt_applctx, wad.updt_task = reqinfo->updt_task, wad.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE wad.wl_activity_id=s_from_wl_activity_id
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update detail rows for pk val=",
      s_from_wl_activity_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status)
   UPDATE  FROM wl_activity frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     frm.active_status_prsnl_id = reqinfo->updt_id, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id =
     reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE frm.wl_activity_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "WL_ACTIVITY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM wl_activity frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(curdate,curtime3), frm
     .encntr_id = s_uf_to_fk_id
    WHERE frm.wl_activity_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet = (icombinedet+ 1)
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "WL_ACTIVITY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 CALL main(null)
#exit_sub
 FREE SET rreclist
END GO
