CREATE PROGRAM dm_lcmb_location_generic:dba
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
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 to_rec[1]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE dcc_updt_task = i4
 SET dcc_updt_task = reqinfo->updt_task
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE loop_max_cnt = i4
 SET loop_max_cnt = 5
 DECLARE loop_cnt = i4
 SET loop_cnt = 0
 DECLARE dbl_from_id = f8
 DECLARE dbl_to_id = f8
 DECLARE from_cnt = i4
 SET from_cnt = 0
 SET dbl_from_id = request->xxx_combine[icombine].from_xxx_id
 SET dbl_to_id = request->xxx_combine[icombine].to_xxx_id
 DECLARE cmb_dummy = i4
 SET cmb_dummy = 0
 DECLARE exec_start_dt_tm = dq8
 SET exec_start_dt_tm = cnvtdatetime(sysdate)
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
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_LCMB_LOCATION_GENERIC"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  SET dcem_request->qual[2].parent_entity = "LOCATION"
  SET dcem_request->qual[2].child_entity = "ENCNTR_PENDING_HIS5940DRR"
  SET dcem_request->qual[2].op_type = "COMBINE"
  SET dcem_request->qual[2].script_name = "DM_LCMB_LOCATION_GENERIC"
  SET dcem_request->qual[2].single_encntr_ind = 0
  SET dcem_request->qual[2].script_run_order = 1
  SET dcem_request->qual[2].del_chg_id_ind = 0
  SET dcem_request->qual[2].delete_row_ind = 0
  SET dcem_request->qual[3].parent_entity = "LOCATION"
  SET dcem_request->qual[3].child_entity = "ENCNTR_PENDING5939DRR"
  SET dcem_request->qual[3].op_type = "COMBINE"
  SET dcem_request->qual[3].script_name = "DM_LCMB_LOCATION_GENERIC"
  SET dcem_request->qual[3].single_encntr_ind = 0
  SET dcem_request->qual[3].script_run_order = 1
  SET dcem_request->qual[3].del_chg_id_ind = 0
  SET dcem_request->qual[3].delete_row_ind = 0
  SET dcem_request->qual[4].parent_entity = "LOCATION"
  SET dcem_request->qual[4].child_entity = "ENCNTR_LOC_HIST0735DRR"
  SET dcem_request->qual[4].op_type = "COMBINE"
  SET dcem_request->qual[4].script_name = "DM_LCMB_LOCATION_GENERIC"
  SET dcem_request->qual[4].single_encntr_ind = 0
  SET dcem_request->qual[4].script_run_order = 1
  SET dcem_request->qual[4].del_chg_id_ind = 0
  SET dcem_request->qual[4].delete_row_ind = 0
  SET dcem_request->qual[5].parent_entity = "LOCATION"
  SET dcem_request->qual[5].child_entity = "DCP_SHIFT_ASSIGNME5819DRR"
  SET dcem_request->qual[5].op_type = "COMBINE"
  SET dcem_request->qual[5].script_name = "DM_LCMB_LOCATION_GENERIC"
  SET dcem_request->qual[5].single_encntr_ind = 0
  SET dcem_request->qual[5].script_run_order = 1
  SET dcem_request->qual[5].del_chg_id_ind = 0
  SET dcem_request->qual[5].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF (dcc_updt_task=33000)
  CALL echo("Reference data combine only - exiting from drr_lcmb_location_generic")
  GO TO exit_sub
 ENDIF
 SET generic_get_request->to_cd = dbl_to_id
 SET generic_get_request->table_name = rcmbchildren->qual2[maincount3].child_table
 CALL echo("before execute")
 EXECUTE dm_ppr_get_loc_cmb_schema  WITH replace("REQUEST","GENERIC_GET_REQUEST"), replace("REPLY",
  "GENERIC_GET_REPLY")
 CALL echo("after execute of dm_ppr_get_loc_cmb_schema")
 IF ((generic_get_reply->nbr_table_index=0))
  CALL echo("nbr_table_index = 0, table not handled in this script")
  GO TO exit_sub
 ENDIF
 IF ((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag < 2))
  CALL echo("calling select0 for parent_present_flag of 0 or 1")
  EXECUTE ppr_get_row_qual1  WITH replace("REQUEST","GENERIC_GET_REQUEST"), replace("REPLY",
   "GENERIC_GET_REPLY")
 ELSE
  IF ((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag < 4))
   CALL echo("calling select2 for parent_present_flag of 2 or 3")
   EXECUTE ppr_get_row_qual2  WITH replace("REQUEST","GENERIC_GET_REQUEST"), replace("REPLY",
    "GENERIC_GET_REPLY")
  ELSE
   CALL echo("calling select3 for parent_present_flag of 4")
   EXECUTE ppr_get_row_qual4  WITH replace("REQUEST","GENERIC_GET_REQUEST"), replace("REPLY",
    "GENERIC_GET_REPLY")
  ENDIF
 ENDIF
 CALL echo(build("from_cnt",from_cnt))
 IF ((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag=4))
  FOR (loopcount = 1 TO from_cnt)
    EXECUTE ppr_upt_location_generic4  WITH replace("REPLY","GENERIC_GET_REPLY")
  ENDFOR
 ELSE
  FOR (loopcount = 1 TO from_cnt)
    EXECUTE ppr_upt_location_generic1  WITH replace("REPLY","GENERIC_GET_REPLY")
  ENDFOR
  IF ((generic_get_reply->tableinfo[generic_get_reply->nbr_table_index].parent_present_flag=1))
   FOR (i = (generic_get_reply->nbr_table_index+ 1) TO generic_get_reply->nbr_of_tables)
     IF ((generic_get_reply->tableinfo[i].parent_present_flag=3))
      SET generic_get_request->table_name = generic_get_reply->tableinfo[i].table_name
      SET generic_get_reply->nbr_table_index = i
      FOR (loopcount = 1 TO from_cnt)
        EXECUTE ppr_upt_location_generic1  WITH replace("REPLY","GENERIC_GET_REPLY")
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 CALL echo(build(" time taken ( in minutes) to execute custom combine for  ",generic_get_request->
   table_name))
 CALL echo(datetimediff(cnvtdatetime(sysdate),exec_start_dt_tm,4))
 FREE SET rreclist
 FREE SET rcolumns
END GO
