CREATE PROGRAM dm_lucb_location_generic:dba
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
 DECLARE cmb_dummy = i4 WITH public, noconstant(0)
 DECLARE pcnt = i4 WITH public, noconstant(0)
 DECLARE cust_ucb_dummy = i2 WITH public, noconstant(0)
 DECLARE loc_type_cd = f8 WITH public, noconstant(0.0)
 IF ( NOT (validate(rtoheirarchy,0)))
  RECORD rtoheirarchy(
    1 facility_cd = f8
    1 facility_mean = c12
    1 bldg_cd = f8
    1 bldg_mean = c12
    1 nurseunit_cd = f8
    1 nurseunit_mean = c12
    1 room_cd = f8
    1 room_mean = c12
    1 bed_cd = f8
    1 bed_mean = c12
    1 to_type_cd = f8
    1 to_org_id = f8
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(rcvheirarchy,0)))
  RECORD rcvheirarchy(
    1 facility_type_cd = f8
    1 bed_cd = f8
    1 room_cd = f8
    1 building_cd = f8
    1 nurse_unit_cd = f8
    1 ambulatory_cd = f8
    1 clinic_cd = f8
    1 smeaning = c12
  ) WITH persistscript
 ENDIF
 SET rcvheirarchy->smeaning = "MEANING"
 DECLARE dbl_from_id = f8
 DECLARE dbl_to_id = f8
 SET dbl_to_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
 SET pcnt = 0
 SET loc_type_cd = 0.0
 SET cust_ucb_dummy = 0
 IF ( NOT (validate(generic_get_request,0)))
  RECORD generic_get_request(
    1 to_cd = f8
    1 table_name = vc
  ) WITH persistscript
 ENDIF
 IF ( NOT (validate(generic_get_reply,0)))
  RECORD generic_get_reply(
    1 heirarchy[*]
      2 loc_type_mean = c12
    1 tableinfo[*]
      2 table_name = c30
      2 parent_table_name = vc
      2 field_parent_name = vc
      2 field_primary_name = vc
      2 field_location_name = vc
      2 field_facility_name = vc
      2 field_bldg_name = vc
      2 field_nurseunit_name = vc
      2 field_room_name = vc
      2 field_bed_name = vc
      2 parent_present_flag = i2
      2 active_fields_flag = i2
      2 orgid_field_flag = i2
    1 nbr_of_tables = i2
    1 nbr_table_index = i2
  ) WITH persistscript
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,5)
  SET dcem_request->qual[1].parent_entity = "LOCATION"
  SET dcem_request->qual[1].child_entity = "ENCOUNTER0077DRR"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_LUCB_LOCATION_GENERIC"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  SET dcem_request->qual[2].parent_entity = "LOCATION"
  SET dcem_request->qual[2].child_entity = "ENCNTR_PENDING_HIS5940DRR"
  SET dcem_request->qual[2].op_type = "UNCOMBINE"
  SET dcem_request->qual[2].script_name = "DM_LUCB_LOCATION_GENERIC"
  SET dcem_request->qual[2].single_encntr_ind = 0
  SET dcem_request->qual[2].script_run_order = 1
  SET dcem_request->qual[2].del_chg_id_ind = 0
  SET dcem_request->qual[2].delete_row_ind = 0
  SET dcem_request->qual[3].parent_entity = "LOCATION"
  SET dcem_request->qual[3].child_entity = "ENCNTR_PENDING5939DRR"
  SET dcem_request->qual[3].op_type = "UNCOMBINE"
  SET dcem_request->qual[3].script_name = "DM_LUCB_LOCATION_GENERIC"
  SET dcem_request->qual[3].single_encntr_ind = 0
  SET dcem_request->qual[3].script_run_order = 1
  SET dcem_request->qual[3].del_chg_id_ind = 0
  SET dcem_request->qual[3].delete_row_ind = 0
  SET dcem_request->qual[4].parent_entity = "LOCATION"
  SET dcem_request->qual[4].child_entity = "ENCNTR_LOC_HIST0735DRR"
  SET dcem_request->qual[4].op_type = "UNCOMBINE"
  SET dcem_request->qual[4].script_name = "DM_LUCB_LOCATION_GENERIC"
  SET dcem_request->qual[4].single_encntr_ind = 0
  SET dcem_request->qual[4].script_run_order = 1
  SET dcem_request->qual[4].del_chg_id_ind = 0
  SET dcem_request->qual[4].delete_row_ind = 0
  SET dcem_request->qual[5].parent_entity = "LOCATION"
  SET dcem_request->qual[5].child_entity = "DCP_SHIFT_ASSIGNME5819DRR"
  SET dcem_request->qual[5].op_type = "UNCOMBINE"
  SET dcem_request->qual[5].script_name = "DM_LUCB_LOCATION_GENERIC"
  SET dcem_request->qual[5].single_encntr_ind = 0
  SET dcem_request->qual[5].script_run_order = 1
  SET dcem_request->qual[5].del_chg_id_ind = 0
  SET dcem_request->qual[5].delete_row_ind = 0
  CALL echo("before dm_cmb")
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SET generic_get_request->to_cd = dbl_to_id
 SET generic_get_request->table_name = rchildren->qual1[det_cnt].entity_name
 CALL echo("before execute")
 EXECUTE dm_ppr_get_loc_cmb_schema  WITH replace("REQUEST","GENERIC_GET_REQUEST"), replace("REPLY",
  "GENERIC_GET_REPLY")
 CALL echo("after execute")
 CALL echo(build("GENERIC_GET_REPLY->nbr_table_index",generic_get_reply->nbr_table_index))
 IF ((generic_get_reply->nbr_table_index=0))
  CALL echo("exiting - table not handled in this script")
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
#exit_sub
 SUBROUTINE cust_ucb_upt(dummy)
   SET pcnt = 0
   SET loc_type_cd = 0.0
   CALL echo(concat("from_xxx_id: ",cnvtstring(request->xxx_uncombine[ucb_cnt].from_xxx_id)))
   CALL echo(concat("to_xxx_id: ",cnvtstring(dbl_to_id)))
   SET pcnt += 1
   SET p_buff[pcnt] = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name)," set")
   SET pcnt += 1
   SET p_buff[pcnt] = "updt_id = reqinfo->updt_id, "
   SET pcnt += 1
   SET p_buff[pcnt] = "updt_dt_tm = cnvtdatetime(curdate,curtime3), "
   SET pcnt += 1
   SET p_buff[pcnt] = "updt_applctx = reqinfo->updt_applctx, "
   SET pcnt += 1
   SET p_buff[pcnt] = "updt_cnt = updt_cnt + 1, "
   SET pcnt += 1
   SET p_buff[pcnt] = "updt_task = reqinfo->updt_task "
   IF ((((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag=0))
    OR ((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag=1))) )
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_location_name)," = ",dbl_to_id)
   ENDIF
   IF ((rtoheirarchy->bed_cd > 0))
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_bed_name)," = ",rtoheirarchy->bed_cd)
   ENDIF
   IF ((rtoheirarchy->room_cd > 0))
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_room_name)," = ",rtoheirarchy->room_cd)
   ENDIF
   IF ((rtoheirarchy->nurseunit_cd > 0))
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_nurseunit_name)," = ",rtoheirarchy->nurseunit_cd)
   ENDIF
   IF ((rtoheirarchy->bldg_cd > 0))
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_bldg_name)," = ",rtoheirarchy->bldg_cd)
   ENDIF
   IF ((rtoheirarchy->facility_cd > 0))
    SET pcnt += 1
    SET p_buff[pcnt] = build(", ",trim(generic_get_reply->tableinfo[generic_get_reply->
      nbr_table_index].field_facility_name)," = ",rtoheirarchy->facility_cd)
   ENDIF
   SET pcnt += 1
   SET p_buff[pcnt] = concat("where ",trim(rchildren->qual1[det_cnt].entity_pk[1].col_name),
    " = rChildren->qual1[det_cnt]->entity_pk[1]->data_number")
   SET pcnt += 1
   SET p_buff[pcnt] = "with nocounter go"
   CALL echo("update string - ")
   FOR (buf_cnt = 1 TO pcnt)
     CALL echo(p_buff[buf_cnt])
     CALL parser(p_buff[buf_cnt])
     SET p_buff[buf_cnt] = fillstring(132," ")
   ENDFOR
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
 END ;Subroutine
END GO
