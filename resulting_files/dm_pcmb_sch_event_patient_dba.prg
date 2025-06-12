CREATE PROGRAM dm_pcmb_sch_event_patient:dba
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
     2 candidate_id = f8
     2 updt_cnt = i4
     2 status = i2
 )
 SET count1 = 0
 SET cmb_dummy = 0
 SET loopcount = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "SCH_EVENT_PATIENT"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_SCH_EVENT_PATIENT"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->xxx_combine[icombine].encntr_id=0))
   WHERE (a.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
  ELSE
   WHERE (a.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND (a.encntr_id=request->xxx_combine[icombine].encntr_id)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
  ENDIF
  INTO "nl:"
  a.*
  FROM sch_event_patient a
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].candidate_id = a.candidate_id, rreclist->from_rec[count1].updt_cnt = a
   .updt_cnt, icombinedet += 1,
   stat = alterlist(request->xxx_combine_det,icombinedet), request->xxx_combine_det[icombinedet].
   combine_action_cd = upt, request->xxx_combine_det[icombinedet].entity_id = a.candidate_id,
   request->xxx_combine_det[icombinedet].entity_name = "SCH_EVENT_PATIENT", request->xxx_combine_det[
   icombinedet].attribute_name = "PERSON_ID"
  WITH forupdatewait(a)
 ;end select
 IF (count1)
  UPDATE  FROM sch_event_patient t,
    (dummyt d  WITH seq = value(count1))
   SET t.person_id = request->xxx_combine[icombine].to_xxx_id, t.updt_dt_tm = cnvtdatetime(sysdate),
    t.updt_applctx = reqinfo->updt_applctx,
    t.updt_id = reqinfo->updt_id, t.updt_cnt = (t.updt_cnt+ 1), t.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (t
    WHERE (t.candidate_id=rreclist->from_rec[d.seq].candidate_id))
   WITH nocounter, status(rreclist->from_rec[d.seq].status)
  ;end update
  FOR (loopcount = 1 TO count1)
    IF ((rreclist->from_rec[loopcount].status != true))
     SET failed = update_error
     SET request->error_message = concat(build("Error updating candidate_id (",rreclist->from_rec[
       loopcount].candidate_id,") to person_id (",request->xxx_combine[icombine].to_xxx_id,
       ")--status(",
       rreclist->from_rec[loopcount].status,")"))
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
  SET request->error_message = emsg
 ENDIF
#exit_script
 FREE SET rreclist
END GO
