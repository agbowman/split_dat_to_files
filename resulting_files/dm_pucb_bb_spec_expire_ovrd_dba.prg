CREATE PROGRAM dm_pucb_bb_spec_expire_ovrd:dba
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
 FREE SET rspecovrdlist
 RECORD rspecovrdlist(
   1 qual[*]
     2 bb_spec_expire_ovrd_id = f8
 )
 DECLARE bbstat = i4 WITH protect, noconstant(0)
 DECLARE speccount = i4 WITH protect, noconstant(0)
 DECLARE specidx = i4 WITH protect, noconstant(0)
 DECLARE failscriptind = i2 WITH protect, noconstant(0)
 DECLARE ordersrunorder = i4 WITH protect, noconstant(0)
 DECLARE bbspecexpireovrdrunorder = i4 WITH protect, constant(2)
 DECLARE curdttm = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ucberrmsg = vc WITH protect, noconstant(" ")
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET bbstat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "BB_SPEC_EXPIRE_OVRD"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_BB_SPEC_EXPIRE_OVRD"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = bbspecexpireovrdrunorder
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  dce.*
  FROM dm_cmb_exception dce
  WHERE dce.child_entity="ORDERS"
   AND dce.operation_type="UNCOMBINE"
   AND dce.parent_entity="PERSON"
  DETAIL
   ordersrunorder = dce.script_run_order
  WITH nocounter
 ;end select
 IF (bbspecexpireovrdrunorder <= ordersrunorder)
  SET failed = data_error
  SET request->error_message = substring(1,132,
   "Orders uncombine run order is not before bb_spec_expire_ovrd.")
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  FROM bb_spec_expire_ovrd bseo,
   container c,
   order_container_r ocr,
   orders o
  PLAN (bseo
   WHERE (bseo.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id))
   JOIN (c
   WHERE c.specimen_id=bseo.specimen_id)
   JOIN (ocr
   WHERE ocr.container_id=c.container_id)
   JOIN (o
   WHERE o.order_id=ocr.order_id
    AND ((o.person_id+ 0) != bseo.person_id))
  DETAIL
   IF ((o.person_id != request->xxx_uncombine[ucb_cnt].to_xxx_id))
    failscriptind = 1
   ENDIF
   speccount += 1
   IF (speccount > size(rspecovrdlist->qual,5))
    bbstat = alterlist(rspecovrdlist->qual,(speccount+ 9))
   ENDIF
   rspecovrdlist->qual[speccount].bb_spec_expire_ovrd_id = bseo.bb_spec_expire_ovrd_id
  WITH nocounter
 ;end select
 SET bbstat = alterlist(rspecovrdlist->qual,speccount)
 IF (failscriptind=1)
  SET ucb_failed = data_error
  SET error_table = "BB_SPEC_EXPIRE_OVRD"
  GO TO exit_sub
 ENDIF
 FOR (specidx = 1 TO speccount)
   UPDATE  FROM bb_spec_expire_ovrd bseo
    SET bseo.person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, bseo.updt_id = reqinfo->updt_id,
     bseo.updt_dt_tm = cnvtdatetime(curdttm),
     bseo.updt_applctx = reqinfo->updt_applctx, bseo.updt_cnt = (bseo.updt_cnt+ 1), bseo.updt_task =
     reqinfo->updt_task
    WHERE (bseo.bb_spec_expire_ovrd_id=rspecovrdlist->qual[specidx].bb_spec_expire_ovrd_id)
    WITH nocounter
   ;end update
   IF (error(ucberrmsg,0) != 0)
    SET ucb_failed = update_error
    SET error_table = "BB_SPEC_EXPIRE_OVRD"
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 ENDFOR
#exit_sub
 FREE SET rspecovrdlist
END GO
