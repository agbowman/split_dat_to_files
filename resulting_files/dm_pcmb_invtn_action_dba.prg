CREATE PROGRAM dm_pcmb_invtn_action:dba
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
     2 trigger_entity_name = c30
     2 trigger_entity_id = f8
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "INVTN_INVITATION_ACTION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_invtn_action"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  iia.invitation_action_id, iia.trigger_entity_name, iia.trigger_entity_id
  FROM invtn_invitation_action iia
  WHERE (iia.person_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = iia.invitation_action_id, rreclist->from_rec[
   v_cust_count1].trigger_entity_name = iia.trigger_entity_name, rreclist->from_rec[v_cust_count1].
   trigger_entity_id = iia.trigger_entity_id
  WITH nocounter
 ;end select
 IF (v_cust_count1 > 0)
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF (move_invitation_action(v_cust_loopcount))
     CALL upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id)
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id)
   UPDATE  FROM invtn_invitation_action
    SET updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(sysdate), person_id = s_uf_to_fk_id
    WHERE invitation_action_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "INVTN_INVITATION_ACTION"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (move_invitation_action(s_mia_pos=i4) =i2)
   IF ((request->xxx_combine[icombine].encntr_id=0))
    RETURN(true)
   ENDIF
   SET moveaction = false
   IF ((rreclist->from_rec[s_mia_pos].trigger_entity_name="HM_RECOMMENDATION_ACTION"))
    SELECT INTO "nl:"
     hra.recommendation_action_id
     FROM hm_recommendation_action hra
     WHERE (hra.recommendation_action_id=rreclist->from_rec[s_mia_pos].trigger_entity_id)
      AND hra.action_flag=6
      AND ((hra.satisfaction_source="CLINICAL_EVENT"
      AND  EXISTS (
     (SELECT
      1
      FROM clinical_event ce
      WHERE hra.satisfaction_id=ce.event_id
       AND (ce.encntr_id=request->xxx_combine[icombine].encntr_id)))) OR (((hra.satisfaction_source=
     "PROCEDURE"
      AND  EXISTS (
     (SELECT
      1
      FROM procedure p
      WHERE hra.satisfaction_id=p.procedure_id
       AND (p.encntr_id=request->xxx_combine[icombine].encntr_id)))) OR (hra.satisfaction_source=
     "ORDERS"
      AND  EXISTS (
     (SELECT
      1
      FROM orders o
      WHERE hra.satisfaction_id=o.order_id
       AND (o.encntr_id=request->xxx_combine[icombine].encntr_id))))) ))
     DETAIL
      moveaction = true
     WITH nocounter
    ;end select
   ENDIF
   RETURN(moveaction)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
