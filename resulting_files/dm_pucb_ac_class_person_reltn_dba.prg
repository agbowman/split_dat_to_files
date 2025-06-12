CREATE PROGRAM dm_pucb_ac_class_person_reltn:dba
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "AC_CLASS_PERSON_RELTN"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_AC_CLASS_PERSON_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 DECLARE cust_ucb_eff(null) = null
 DECLARE cust_ucb_upt(null) = null
 FREE RECORD acpr_qual
 RECORD acpr_qual(
   1 parent_id = f8
   1 registry_id = f8
   1 org_id = f8
   1 loc_cd = f8
   1 ind_par_ind = i2
   1 reg_upd = i2
   1 new_par_id = f8
   1 qual[*]
     2 pkey = f8
 )
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(null)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
  CALL cust_ucb_eff(null)
 ELSE
  SET ucb_failed = data_error
  SET error_msg = "Invalid combine_action_cd"
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_upt(null)
   SELECT INTO "nl:"
    FROM ac_class_person_reltn acpr
    PLAN (acpr
     WHERE (acpr.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id))
    WITH nocounter, forupdatewait(acpr)
   ;end select
   SELECT INTO "nl:"
    FROM ac_class_person_reltn acpr,
     ac_class_person_reltn acpr2,
     person_combine_det pcd
    PLAN (acpr
     WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id))
     JOIN (acpr2
     WHERE acpr2.ac_class_person_reltn_id=acpr.parent_class_person_reltn_id)
     JOIN (pcd
     WHERE (pcd.entity_id= Outerjoin(acpr2.ac_class_person_reltn_id))
      AND (pcd.person_combine_id= Outerjoin(request->xxx_uncombine[ucb_cnt].xxx_combine_id)) )
    HEAD acpr2.ac_class_person_reltn_id
     IF (pcd.person_combine_det_id > 0)
      acpr_qual->parent_id = acpr2.parent_class_person_reltn_id
      IF ((rchildren->qual1[det_cnt].entity_id=pcd.entity_id)
       AND pcd.combine_action_cd=upt)
       acpr_qual->reg_upd = true
      ENDIF
     ELSE
      acpr_qual->parent_id = 0
     ENDIF
     acpr_qual->registry_id = acpr2.ac_class_def_id, acpr_qual->org_id = acpr2.organization_id,
     acpr_qual->loc_cd = acpr2.location_cd,
     acpr_qual->ind_par_ind = acpr2.independent_parent_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET ucb_failed = data_error
    SET error_msg = "Error Finding UPDATED Registry parent"
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   IF ((acpr_qual->parent_id=0))
    SELECT INTO "nl:"
     FROM person_combine_det pcd,
      ac_class_person_reltn acpr
     PLAN (pcd
      WHERE (pcd.person_combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
       AND pcd.entity_name="AC_CLASS_PERSON_RELTN"
       AND pcd.combine_action_cd=eff)
      JOIN (acpr
      WHERE acpr.ac_class_person_reltn_id=pcd.entity_id
       AND (acpr.ac_class_def_id=acpr_qual->registry_id)
       AND (acpr.organization_id=acpr_qual->org_id)
       AND (acpr.location_cd=acpr_qual->loc_cd))
     DETAIL
      acpr_qual->parent_id = acpr.ac_class_person_reltn_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET ucb_failed = data_error
     SET error_msg = "Error Finding INACTIVATED Registry parent"
     SET error_table = rchildren->qual1[det_cnt].entity_name
     GO TO exit_sub
    ENDIF
   ENDIF
   UPDATE  FROM ac_class_person_reltn acpr
    SET acpr.person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, acpr.parent_class_person_reltn_id
      = acpr_qual->parent_id, acpr.updt_applctx = reqinfo->updt_applctx,
     acpr.updt_dt_tm = cnvtdatetime(sysdate), acpr.updt_id = reqinfo->updt_id, acpr.updt_task =
     reqinfo->updt_task,
     acpr.updt_cnt = (acpr.updt_cnt+ 1)
    WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   IF ((acpr_qual->reg_upd=true))
    SELECT INTO "nl:"
     FROM ac_class_person_reltn acpr,
      ac_class_person_reltn acpr2
     PLAN (acpr
      WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id))
      JOIN (acpr2
      WHERE acpr2.parent_class_person_reltn_id=acpr.ac_class_person_reltn_id
       AND  NOT ( EXISTS (
      (SELECT
       1
       FROM person_combine_det pcd
       WHERE (pcd.person_combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
        AND pcd.entity_id=acpr2.ac_class_person_reltn_id))))
     HEAD acpr2.parent_class_person_reltn_id
      updcnt = 0
     DETAIL
      updcnt += 1
      IF (mod(updcnt,20)=1)
       stat = alterlist(acpr_qual->qual,(updcnt+ 19))
      ENDIF
      acpr_qual->qual[updcnt].pkey = acpr2.ac_class_person_reltn_id
     FOOT REPORT
      stat = alterlist(acpr_qual->qual,updcnt)
     WITH nocounter
    ;end select
    IF (size(acpr_qual->qual,5) > 0)
     SET acpr_qual->new_par_id = 0.0
     SELECT INTO "nl:"
      y = seq(health_status_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       acpr_qual->new_par_id = cnvtreal(y)
      WITH format, counter
     ;end select
     INSERT  FROM ac_class_person_reltn acpr
      SET acpr.ac_class_person_reltn_id = acpr_qual->new_par_id, acpr.person_id = request->
       xxx_uncombine[ucb_cnt].from_xxx_id, acpr.parent_class_person_reltn_id = acpr_qual->new_par_id,
       acpr.ac_class_def_id = acpr_qual->registry_id, acpr.organization_id = acpr_qual->org_id, acpr
       .location_cd = acpr_qual->loc_cd,
       acpr.active_ind = 1, acpr.independent_parent_ind = acpr_qual->ind_par_ind, acpr
       .beg_effective_dt_tm = cnvtdatetime(sysdate),
       acpr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), acpr.updt_applctx = reqinfo->
       updt_applctx, acpr.updt_dt_tm = cnvtdatetime(sysdate),
       acpr.updt_id = reqinfo->updt_id, acpr.updt_task = reqinfo->updt_task, acpr.updt_cnt = 0
      PLAN (acpr)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET ucb_failed = insert_error
      SET error_table = rchildren->qual1[det_cnt].entity_name
      GO TO exit_sub
     ENDIF
     UPDATE  FROM ac_class_person_reltn acpr,
       (dummyt d1  WITH seq = size(acpr_qual->qual,5))
      SET acpr.parent_class_person_reltn_id = acpr_qual->new_par_id, acpr.updt_applctx = reqinfo->
       updt_applctx, acpr.updt_dt_tm = cnvtdatetime(sysdate),
       acpr.updt_id = reqinfo->updt_id, acpr.updt_task = reqinfo->updt_task, acpr.updt_cnt = (acpr
       .updt_cnt+ 1)
      PLAN (d1)
       JOIN (acpr
       WHERE (acpr.ac_class_person_reltn_id=acpr_qual->qual[d1.seq].pkey))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET ucb_failed = update_error
      SET error_table = rchildren->qual1[det_cnt].entity_name
      GO TO exit_sub
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_ucb_eff(null)
  SELECT INTO "nl:"
   FROM ac_class_person_reltn acpr
   WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id)
    AND  EXISTS (
   (SELECT
    1
    FROM ac_class_person_reltn acpr2,
     ac_class_def acd
    WHERE acpr2.ac_class_person_reltn_id=acpr.parent_class_person_reltn_id
     AND acpr2.ac_class_def_id=acd.ac_class_def_id
     AND acd.active_ind=1
     AND acd.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")))
    AND  EXISTS (
   (SELECT
    1
    FROM ac_class_def acd2
    WHERE acd2.ac_class_def_id=acpr.ac_class_def_id
     AND acd2.active_ind=1
     AND acd2.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM ac_class_person_reltn acpr
    SET acpr.person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, acpr.active_ind = 1, acpr
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"),
     acpr.updt_applctx = reqinfo->updt_applctx, acpr.updt_dt_tm = cnvtdatetime(sysdate), acpr.updt_id
      = reqinfo->updt_id,
     acpr.updt_task = reqinfo->updt_task, acpr.updt_cnt = (acpr.updt_cnt+ 1)
    WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
  ELSE
   UPDATE  FROM ac_class_person_reltn acpr
    SET acpr.person_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, acpr.updt_applctx = reqinfo->
     updt_applctx, acpr.updt_dt_tm = cnvtdatetime(sysdate),
     acpr.updt_id = reqinfo->updt_id, acpr.updt_task = reqinfo->updt_task, acpr.updt_cnt = (acpr
     .updt_cnt+ 1)
    WHERE (acpr.ac_class_person_reltn_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
  ENDIF
 END ;Subroutine
#exit_sub
 IF (validate(acpr_qual))
  FREE RECORD acpr_qual
 ENDIF
END GO
