CREATE PROGRAM dm_pcmb_media_master:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
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
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
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
   1 from_rec[10]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 end_effective_dt_tm = dq8
     2 encntr_id = f8
     2 media_type_cd = f8
   1 to_rec[10]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 end_effective_dt_tm = dq8
     2 encntr_id = f8
     2 media_type_cd = f8
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "MEDIA_MASTER"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_MEDIA_MASTER"
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
  FROM media_master frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1
    AND v_cust_count1 != 1)
    stat = alter(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.media_master_id, rreclist->from_rec[v_cust_count1]
   .active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd = frm
   .active_status_cd,
   rreclist->from_rec[v_cust_count1].end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->
   from_rec[v_cust_count1].media_type_cd = frm.media_type_cd, rreclist->from_rec[v_cust_count1].
   encntr_id = frm.encntr_id
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM media_master tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.active_ind=1
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1
     AND v_cust_count2 != 1)
     stat = alter(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.media_master_id, rreclist->to_rec[v_cust_count2].
    active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].media_type_cd = tu.media_type_cd, rreclist->to_rec[v_cust_count2]
    .encntr_id = tu.encntr_id, rreclist->to_rec[v_cust_count2].end_effective_dt_tm = tu
    .end_effective_dt_tm
   WITH forupdatewait(tu)
  ;end select
  IF (v_cust_count2 > 0)
   FOR (v_cust_loopcount = 1 TO v_cust_count1)
     FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
       SET media_exists = "N"
       IF ((rreclist->from_rec[v_cust_loopcount].media_type_cd=rreclist->to_rec[v_cust_loopcount2].
       media_type_cd)
        AND (rreclist->from_rec[v_cust_loopcount].encntr_id=rreclist->to_rec[v_cust_loopcount2].
       encntr_id))
        SET media_exists = "Y"
       ENDIF
       IF ((rev_cmb_request->reverse_ind=1))
        IF (media_exists="Y")
         IF (del_from(rreclist->to_rec[v_cust_loopcount2].to_id,rreclist->to_rec[v_cust_loopcount2].
          active_ind,rreclist->to_rec[v_cust_loopcount2].active_status_cd,rreclist->to_rec[
          v_cust_loopcount2].end_effective_dt_tm)=0)
          GO TO exit_sub
         ENDIF
        ENDIF
        IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
         to_xxx_id)=0)
         GO TO exit_sub
        ENDIF
       ELSE
        IF (media_exists="Y")
         IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[
          v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd,rreclist
          ->from_rec[v_cust_loopcount].end_effective_dt_tm)=0)
          GO TO exit_sub
         ENDIF
        ELSE
         IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
          to_xxx_id)=0)
          GO TO exit_sub
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
  ELSE
   FOR (v_cust_loopcount = 1 TO v_cust_count1)
     IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id)=0)
      GO TO exit_sub
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_prev_act_ind,s_df_prev_act_status,s_ec_prev_end_eff_dt_tm)
   UPDATE  FROM media_master_alias m
    SET m.active_ind = 0, m.active_status_cd = reqdata->inactive_status_cd, m.end_effective_dt_tm =
     cnvtdatetime(sysdate),
     m.active_status_dt_tm = cnvtdatetime(sysdate), m.active_status_prsnl_id = reqinfo->updt_id, m
     .updt_dt_tm = cnvtdatetime(sysdate),
     m.updt_id = reqinfo->updt_id, m.updt_applctx = reqinfo->updt_applctx, m.updt_task = reqinfo->
     updt_task,
     m.updt_cnt = (m.updt_cnt+ 1)
    WHERE m.media_master_id=s_df_pk_id
    WITH nocounter
   ;end update
   UPDATE  FROM media_encntr_reltn mer
    SET mer.active_ind = 0, mer.updt_dt_tm = cnvtdatetime(sysdate), mer.updt_id = reqinfo->updt_id,
     mer.updt_applctx = reqinfo->updt_applctx, mer.updt_task = reqinfo->updt_task, mer.updt_cnt = (
     mer.updt_cnt+ 1)
    WHERE mer.media_master_id=s_df_pk_id
    WITH nocounter
   ;end update
   UPDATE  FROM media_master frm
    SET frm.active_ind = false, frm.active_status_cd = reqdata->inactive_status_cd, frm
     .end_effective_dt_tm = cnvtdatetime(sysdate),
     frm.active_status_dt_tm = cnvtdatetime(sysdate), frm.active_status_prsnl_id = reqinfo->updt_id,
     frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.media_master_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "MEDIA_MASTER"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = s_ec_prev_end_eff_dt_tm
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM media_master frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.media_master_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "MEDIA_MASTER"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = 1
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
