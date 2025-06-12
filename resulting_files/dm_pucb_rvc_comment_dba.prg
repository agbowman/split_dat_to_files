CREATE PROGRAM dm_pucb_rvc_comment:dba
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
 FREE SET rcommentaggrec
 RECORD rcommentaggrec(
   1 comments_data[*]
     2 comment_text = vc
     2 user_name = vc
     2 comment_date = dq8
 )
 FREE SET rcommententitylist
 RECORD rcommententitylist(
   1 entity_list[*]
     2 parent_entity_id = f8
     2 encntr_ind = i4
 )
 DECLARE agg_comment = vc
 DECLARE date_string_date = vc
 DECLARE date_string_time = vc
 DECLARE date_string = vc
 DECLARE long_text = vc
 DECLARE v_cust_count_rvc_comment = i4
 SET v_cust_count_rvc_comment = 0
 SUBROUTINE rvc_comment_generate_aggregate_comment(null)
   SET agg_comment = null
   SET forcnt = size(rcommentaggrec->comments_data,5)
   FOR (i = 1 TO forcnt)
     SET date_string_date = format(rcommentaggrec->comments_data[i].comment_date,"mm/dd/yyyy;;q")
     SET date_string_time = format(rcommentaggrec->comments_data[i].comment_date,"hh:mm:ss;;s")
     SET date_string = concat(date_string_date," ",cnvtupper(date_string_time))
     SET agg_comment = concat(agg_comment,date_string,"  Comment by: ",rcommentaggrec->comments_data[
      i].user_name)
     SET agg_comment = concat(agg_comment,"   ",char(13),char(10))
     SET agg_comment = concat(agg_comment,rcommentaggrec->comments_data[i].comment_text,char(13),char
      (10))
     SET agg_comment = concat(agg_comment,"--------------------------------------",char(13),char(10),
      char(13),
      char(10))
   ENDFOR
   IF (agg_comment=null)
    SET agg_comment = ""
   ENDIF
   RETURN(agg_comment)
 END ;Subroutine
 SUBROUTINE rvc_comment_write_comment_for_entity(null)
  SET forcnt = size(rcommententitylist->entity_list,5)
  FOR (j = 1 TO forcnt)
    SET stat = alterlist(rcommentaggrec->comments_data,0)
    DECLARE encntr_ind = i4
    SET encntr_ind = rcommententitylist->entity_list[j].encntr_ind
    DECLARE parent_entity_id = f8
    SET parent_entity_id = rcommententitylist->entity_list[j].parent_entity_id
    IF (encntr_ind=1)
     SET parent_entity_name = "ENCOUNTER"
    ELSE
     SET parent_entity_name = "PERSON"
    ENDIF
    DECLARE general_comment_type_cd = f8
    SET general_comment_type_cd = uar_get_code_by("MEANING",4003302,"GENERAL")
    SELECT INTO "nl:"
     rvc.*
     FROM rvc_comment rvc,
      prsnl prsnl
     WHERE rvc.parent_entity_id=parent_entity_id
      AND rvc.parent_entity_name=parent_entity_name
      AND rvc.comment_type_cd=general_comment_type_cd
      AND rvc.active_ind=1
      AND (prsnl.person_id= Outerjoin(rvc.create_prsnl_id))
     ORDER BY rvc.create_dt_tm DESC, rvc.updt_dt_tm DESC
     HEAD REPORT
      v_cust_count_rvc_comment = 0
     DETAIL
      v_cust_count_rvc_comment += 1
      IF (mod(v_cust_count_rvc_comment,10)=1)
       stat = alterlist(rcommentaggrec->comments_data,(v_cust_count_rvc_comment+ 9))
      ENDIF
      rcommentaggrec->comments_data[v_cust_count_rvc_comment].comment_text = rvc.comment_text,
      rcommentaggrec->comments_data[v_cust_count_rvc_comment].user_name = prsnl.name_full_formatted,
      rcommentaggrec->comments_data[v_cust_count_rvc_comment].comment_date = rvc.create_dt_tm
     FOOT REPORT
      stat = alterlist(rcommentaggrec->comments_data,v_cust_count_rvc_comment)
     WITH nocounter
    ;end select
    SET long_text = rvc_comment_generate_aggregate_comment(null)
    DECLARE active_status_cd = f8
    SET active_status_cd = uar_get_code_by("MEANING",48,"ACTIVE")
    IF (encntr_ind=1)
     DECLARE enci_long_text_id = f8
     SET enci_long_text_id = 0
     DECLARE enci_enci_id = f8
     SET enci_enci_id = 0
     DECLARE enci_exist_ind = i2
     SET enci_exist_ind = 0
     DECLARE info_type_cd = f8
     SET info_type_cd = uar_get_code_by("MEANING",355,"COMMENT")
     SELECT INTO "nl:"
      enci.*
      FROM encntr_info enci
      WHERE enci.encntr_id=parent_entity_id
       AND enci.info_type_cd=info_type_cd
       AND enci.internal_seq=1
       AND enci.active_ind=1
      DETAIL
       enci_long_text_id = enci.long_text_id, enci_enci_id = enci.encntr_info_id, enci_exist_ind = 1
      WITH forupdatewait(enci)
     ;end select
     IF (enci_exist_ind=0)
      SELECT INTO "nl:"
       val = seq(encounter_seq,nextval)
       FROM dual
       DETAIL
        enci_enci_id = val
       WITH nocounter
      ;end select
      INSERT  FROM encntr_info enci
       SET enci.encntr_info_id = enci_enci_id, enci.encntr_id = parent_entity_id, enci.info_type_cd
         = info_type_cd,
        enci.internal_seq = 1, enci.active_ind = 1, enci.active_status_cd = active_status_cd,
        enci.active_status_dt_tm = cnvtdatetime(sysdate), enci.active_status_prsnl_id = reqinfo->
        updt_id, enci.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
        enci.beg_effective_dt_tm = cnvtdatetime(sysdate), enci.updt_cnt = 0, enci.updt_id = reqinfo->
        updt_id,
        enci.updt_applctx = reqinfo->updt_applctx, enci.updt_task = reqinfo->updt_task, enci
        .updt_dt_tm = cnvtdatetime(sysdate)
      ;end insert
     ENDIF
     DECLARE long_text_row_exist_ind = i2
     SET long_text_row_exist_ind = 0
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE lt.long_text_id=enci_long_text_id
       AND lt.active_ind=1
      DETAIL
       long_text_row_exist_ind = 1
      WITH forupdatewait(lt)
     ;end select
     IF (enci_long_text_id != 0
      AND long_text_row_exist_ind=1)
      UPDATE  FROM long_text lt
       SET lt.long_text = long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_id = reqinfo->updt_id,
        lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE lt.long_text_id=enci_long_text_id
       WITH nocounter
      ;end update
     ELSE
      SELECT INTO "nl:"
       val = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        enci_long_text_id = val
       WITH nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = enci_long_text_id, lt.long_text = long_text, lt.parent_entity_name =
        "ENCNTR_INFO",
        lt.parent_entity_id = enci_enci_id, lt.active_ind = 1, lt.active_status_cd = active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
        lt.updt_cnt = 0,
        lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task =
        reqinfo->updt_task,
        lt.updt_dt_tm = cnvtdatetime(sysdate)
      ;end insert
      UPDATE  FROM encntr_info enci
       SET enci.long_text_id = enci_long_text_id, enci.updt_cnt = (enci.updt_cnt+ 1), enci.updt_id =
        reqinfo->updt_id,
        enci.updt_applctx = reqinfo->updt_applctx, enci.updt_task = reqinfo->updt_task, enci
        .updt_dt_tm = cnvtdatetime(sysdate)
       WHERE enci.encntr_info_id=enci_enci_id
      ;end update
     ENDIF
    ELSE
     DECLARE prsn_long_text_id = f8
     SET prsn_long_text_id = 0
     DECLARE prsn_person_info_id = f8
     SET prsn_person_info_id = 0
     DECLARE prsn_info_exist_ind = i2
     SET prsn_info_exist_ind = 0
     DECLARE info_type_cd = f8
     SET info_type_cd = uar_get_code_by("MEANING",355,"COMMENT")
     SELECT INTO "nl:"
      pi.*
      FROM person_info pi
      WHERE pi.person_id=parent_entity_id
       AND pi.info_type_cd=info_type_cd
       AND pi.internal_seq=1
       AND pi.active_ind=1
      DETAIL
       prsn_long_text_id = pi.long_text_id, prsn_person_info_id = pi.person_info_id,
       prsn_info_exist_ind = 1
      WITH forupdatewait(pi)
     ;end select
     IF (prsn_info_exist_ind=0)
      SELECT INTO "nl:"
       val = seq(person_seq,nextval)
       FROM dual
       DETAIL
        prsn_person_info_id = val
       WITH nocounter
      ;end select
      INSERT  FROM person_info prsni
       SET prsni.person_info_id = prsn_person_info_id, prsni.person_id = parent_entity_id, prsni
        .info_type_cd = info_type_cd,
        prsni.internal_seq = 1, prsni.active_ind = 1, prsni.active_status_cd = active_status_cd,
        prsni.active_status_dt_tm = cnvtdatetime(sysdate), prsni.active_status_prsnl_id = reqinfo->
        updt_id, prsni.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
        prsni.beg_effective_dt_tm = cnvtdatetime(sysdate), prsni.updt_cnt = 0, prsni.updt_id =
        reqinfo->updt_id,
        prsni.updt_applctx = reqinfo->updt_applctx, prsni.updt_task = reqinfo->updt_task, prsni
        .updt_dt_tm = cnvtdatetime(sysdate)
      ;end insert
     ENDIF
     DECLARE long_text_row_exist_ind = i2
     SET long_text_row_exist_ind = 0
     SELECT INTO "nl:"
      lt.*
      FROM long_text lt
      WHERE lt.long_text_id=prsn_long_text_id
       AND lt.active_ind=1
      DETAIL
       long_text_row_exist_ind = 1
      WITH forupdatewait(lt)
     ;end select
     IF (prsn_long_text_id != 0
      AND long_text_row_exist_ind=1)
      UPDATE  FROM long_text lt
       SET lt.long_text = long_text, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_id = reqinfo->updt_id,
        lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE lt.long_text_id=prsn_long_text_id
       WITH nocounter
      ;end update
     ELSE
      SELECT INTO "nl:"
       val = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        prsn_long_text_id = val
       WITH nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = prsn_long_text_id, lt.long_text = long_text, lt.parent_entity_name =
        "PERSON_INFO",
        lt.parent_entity_id = prsn_person_info_id, lt.active_ind = 1, lt.active_status_cd =
        active_status_cd,
        lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
        lt.updt_cnt = 0,
        lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task =
        reqinfo->updt_task,
        lt.updt_dt_tm = cnvtdatetime(sysdate)
      ;end insert
      UPDATE  FROM person_info prsn
       SET prsn.long_text_id = prsn_long_text_id, prsn.updt_cnt = (prsn.updt_cnt+ 1), prsn.updt_id =
        reqinfo->updt_id,
        prsn.updt_applctx = reqinfo->updt_applctx, prsn.updt_task = reqinfo->updt_task, prsn
        .updt_dt_tm = cnvtdatetime(sysdate)
       WHERE prsn.person_info_id=prsn_person_info_id
      ;end update
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE v_hist_init_ind = i2
 DECLARE dhistid = f8
 SET v_hist_init_ind = 0
 SET dhistid = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "RVC_COMMENT"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_RVC_COMMENT"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(null)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SET stat = alterlist(rcommententitylist->entity_list,2)
 SET rcommententitylist->entity_list[1].encntr_ind = 0
 SET rcommententitylist->entity_list[1].parent_entity_id = request->xxx_uncombine[ucb_cnt].
 from_xxx_id
 SET rcommententitylist->entity_list[2].encntr_ind = 0
 SET rcommententitylist->entity_list[2].parent_entity_id = request->xxx_uncombine[ucb_cnt].to_xxx_id
 CALL rvc_comment_write_comment_for_entity(null)
 SUBROUTINE cust_ucb_upt(dummy)
   UPDATE  FROM rvc_comment
    SET updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(sysdate), parent_entity_id = request->
     xxx_uncombine[ucb_cnt].to_xxx_id
    WHERE (rvc_comment_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
END GO
