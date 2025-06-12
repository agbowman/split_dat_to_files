CREATE PROGRAM dm_pcmb_hm_recommendation:dba
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
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 expect_id = f8
     2 step_id = f8
     2 expectation_ftdesc = c255
     2 recommendation_actions[*]
       3 recommendation_action_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 expect_id = f8
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE to_recommendation_id = f8 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "HM_RECOMMENDATION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_HM_RECOMMENDATION"
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
  FROM hm_recommendation frm
  WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
   AND ((frm.expect_id > 0) OR (frm.expect_id=0
   AND frm.expectation_ftdesc != null))
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.recommendation_id, rreclist->from_rec[
   v_cust_count1].expect_id = frm.expect_id, rreclist->from_rec[v_cust_count1].step_id = frm.step_id,
   rreclist->from_rec[v_cust_count1].expectation_ftdesc = frm.expectation_ftdesc
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM hm_recommendation tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.expect_id > 0
   ORDER BY tu.expect_id
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.recommendation_id, rreclist->to_rec[v_cust_count2].
    expect_id = tu.expect_id
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].expectation_ftdesc != null))
     CALL upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id)
    ELSEIF ((rreclist->from_rec[v_cust_loopcount].expect_id > 0))
     SET pos = locatevalsort(num,1,v_cust_count2,rreclist->from_rec[v_cust_loopcount].expect_id,
      rreclist->to_rec[num].expect_id)
     IF (pos > 0)
      SET to_recommendation_id = rreclist->to_rec[pos].to_id
     ELSE
      SET to_recommendation_id = create_recommendation(v_cust_loopcount)
     ENDIF
     SET stat = combine_recommendation_actions(rreclist->from_rec[v_cust_loopcount].from_id,
      to_recommendation_id)
     SET stat = update_recommendation_status(rreclist->from_rec[v_cust_loopcount].from_id)
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM hm_recommendation frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id
    WHERE frm.recommendation_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "HM_RECOMMENDATION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (combine_recommendation_actions(s_cra_from_recommendation_id=f8,
  s_cra_to_recommendation_id=f8) =null)
   SELECT INTO "nl:"
    hra.recommendation_action_id
    FROM hm_recommendation_action hra
    WHERE hra.recommendation_id=s_cra_from_recommendation_id
     AND  NOT (hra.action_flag IN (21, 22))
    DETAIL
     icombinedet += 1, stat = alterlist(request->xxx_combine_det,icombinedet), request->
     xxx_combine_det[icombinedet].combine_action_cd = upt,
     request->xxx_combine_det[icombinedet].entity_id = hra.recommendation_action_id, request->
     xxx_combine_det[icombinedet].entity_name = "HM_RECOMMENDATION_ACTION", request->xxx_combine_det[
     icombinedet].attribute_name = "PERSON_ID"
    WITH forupdatewait(hra)
   ;end select
   UPDATE  FROM hm_recommendation_action hra
    SET hra.updt_cnt = (hra.updt_cnt+ 1), hra.updt_id = reqinfo->updt_id, hra.updt_applctx = reqinfo
     ->updt_applctx,
     hra.updt_task = reqinfo->updt_task, hra.updt_dt_tm = cnvtdatetime(sysdate), hra
     .recommendation_id = s_cra_to_recommendation_id
    WHERE hra.recommendation_id=s_cra_from_recommendation_id
     AND  NOT (hra.action_flag IN (21, 22))
    WITH nocounter
   ;end update
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (create_recommendation(s_cr_from_index_pos=i4) =f8)
   DECLARE recommendation_id = f8
   SELECT INTO "nl:"
    rec_id = seq(pco_seq,nextval)
    FROM dual
    DETAIL
     recommendation_id = cnvtreal(rec_id)
    WITH nocounter
   ;end select
   IF (recommendation_id=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,
     "Could not insert recommendation, value from sequence was 0")
    RETURN(0)
   ENDIF
   INSERT  FROM hm_recommendation h
    SET h.person_id = request->xxx_combine[icombine].to_xxx_id, h.expect_id = rreclist->from_rec[
     s_cr_from_index_pos].expect_id, h.step_id = rreclist->from_rec[s_cr_from_index_pos].step_id,
     h.recommendation_id = recommendation_id, h.status_flag = 0, h.updt_cnt = 0,
     h.updt_dt_tm = cnvtdatetime(sysdate), h.updt_task = reqinfo->updt_task, h.updt_id = reqinfo->
     updt_id,
     h.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = substring(1,132,build("Could not insert recommendation for person=",
      request->xxx_combine[icombine].to_xxx_id))
    RETURN(0)
   ENDIF
   RETURN(recommendation_id)
 END ;Subroutine
 SUBROUTINE (update_recommendation_status(s_urs_recommendation_id=f8) =null)
   UPDATE  FROM hm_recommendation hr
    SET hr.updt_cnt = (hr.updt_cnt+ 1), hr.updt_id = reqinfo->updt_id, hr.updt_applctx = reqinfo->
     updt_applctx,
     hr.updt_task = reqinfo->updt_task, hr.updt_dt_tm = cnvtdatetime(sysdate), hr.status_flag = 0
    WHERE hr.recommendation_id=s_urs_recommendation_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build(
      "Could not update recommendation status on recommendation=",s_urs_recommendation_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
