CREATE PROGRAM cps_del_scd_patrn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE deleteactions(null) = null
 DECLARE retrieveactions(btermactions=i4,dscrpatternid=f8) = null
 DECLARE retrieveexprcomps(null) = null
 DECLARE removereferencedexprs(null) = null
 DECLARE para_actions = i4 WITH public, constant(0)
 DECLARE term_actions = i4 WITH public, constant(1)
 DECLARE expand_size = i4 WITH public, constant(20)
 SET reply->status_data.status = "F"
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE num_patterns = i4 WITH protect, noconstant(size(request->patterns,5))
 IF (num_patterns != 1)
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,
   "Cannot handle zero or multiple patterns, only pass one pattern at a time",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 DECLARE scr_pattern_id = f8 WITH protect, noconstant(request->patterns[1].scr_pattern_id)
 IF (scr_pattern_id=0.0)
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No pattern id",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "NL:"
  FROM scr_pattern p
  PLAN (p
   WHERE p.scr_pattern_id=scr_pattern_id)
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET failed = 1
  CALL cps_add_error(cps_inval_data,cps_script_fail,"No pattern Found",cps_inval_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM scr_term t
  SET t.active_ind = 0, t.active_status_cd = request->deleted_status_cd, t.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   t.active_status_prsnl_id = reqinfo->updt_id, t.updt_id = reqinfo->updt_id, t.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
  WHERE t.scr_term_id IN (
  (SELECT INTO "nl:"
   th.scr_term_id
   FROM scr_term_hier th
   WHERE th.scr_pattern_id=scr_pattern_id
    AND th.scr_term_hier_id=th.scr_term_id))
  WITH nocounter
 ;end update
 CALL deleteactions(null)
 DELETE  FROM scr_term_hier h
  WHERE h.scr_pattern_id=scr_pattern_id
  WITH nocounter
 ;end delete
 DELETE  FROM scr_sentence s
  WHERE s.scr_pattern_id=scr_pattern_id
  WITH nocounter
 ;end delete
 DELETE  FROM scr_paragraph p
  WHERE p.scr_pattern_id=scr_pattern_id
  WITH nocounter
 ;end delete
 IF ((request->patterns[1].action_type != "REP"))
  DELETE  FROM scr_pattern_concept pc
   WHERE pc.scr_pattern_id=scr_pattern_id
   WITH nocounter
  ;end delete
  DELETE  FROM scr_pattern p
   WHERE p.scr_pattern_id=scr_pattern_id
  ;end delete
  IF (curqual=0)
   SET failed = 1
   CALL cps_add_error(cps_delete,cps_script_fail,"Couldn't delete the pattern.",cps_delete_msg,0,
    0,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE deleteactions(null)
   FREE RECORD action_list
   RECORD action_list(
     1 actions[*]
       2 action_id = f8
       2 expr_id = f8
   )
   CALL retrieveactions(para_actions,scr_pattern_id)
   CALL retrieveactions(term_actions,scr_pattern_id)
   DECLARE num_actions = i4 WITH protect, constant(size(action_list->actions,5))
   IF (num_actions != 0)
    DECLARE expand_idx = i4 WITH protect, noconstant(0)
    DECLARE expand_start = i4 WITH protect, noconstant(1)
    DECLARE loop_count = i4 WITH protect, noconstant(ceil((cnvtreal(num_actions)/ expand_size)))
    DECLARE new_size = i4 WITH protect, noconstant((loop_count * expand_size))
    DECLARE pad_idx = i4 WITH protect, noconstant(0)
    IF (num_actions != new_size)
     SET stat = alterlist(action_list->actions,new_size)
     FOR (pad_idx = (num_actions+ 1) TO new_size)
      SET action_list->actions[pad_idx].action_id = 0.0
      SET action_list->actions[pad_idx].expr_id = 0.0
     ENDFOR
    ENDIF
    DELETE  FROM (dummyt d  WITH seq = loop_count),
      scr_action a
     SET a.seq = 1
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (a
      WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),a.scr_action_id,
       action_list->actions[expand_idx].action_id)
       AND a.scr_action_id != 0.0)
     WITH nocounter
    ;end delete
    CALL removereferencedexprs(null)
    FREE RECORD comp_list
    RECORD comp_list(
      1 expr_comps[*]
        2 comp_id = f8
    )
    CALL retrieveexprcomps(null)
    DECLARE num_comps = i4 WITH protect, noconstant(size(comp_list->expr_comps,5))
    IF (num_comps != 0)
     SET expand_idx = 0
     SET expand_start = 1
     SET loop_count = ceil((cnvtreal(num_comps)/ expand_size))
     SET new_size = (loop_count * expand_size)
     IF (num_comps != new_size)
      SET stat = alterlist(comp_list->expr_comps,new_size)
      FOR (pad_idx = (num_comps+ 1) TO new_size)
        SET comp_list->expr_comps[pad_idx].comp_id = 0.0
      ENDFOR
     ENDIF
     DELETE  FROM (dummyt d  WITH seq = value(loop_count)),
       expression_comp ec
      SET ec.seq = 1
      PLAN (d
       WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
       JOIN (ec
       WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),ec.expression_comp_id,
        comp_list->expr_comps[expand_idx].comp_id)
        AND ec.expression_comp_id != 0.0)
      WITH nocounter
     ;end delete
    ENDIF
    SET expand_idx = 0
    SET expand_start = 1
    SET loop_count = ceil((cnvtreal(num_actions)/ expand_size))
    DELETE  FROM (dummyt d  WITH seq = value(loop_count)),
      expression e
     SET e.seq = 1
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (e
      WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),e.expression_id,
       action_list->actions[expand_idx].expr_id)
       AND e.expression_id != 0.0)
     WITH nocounter
    ;end delete
    FREE RECORD comp_list
   ENDIF
   FREE RECORD action_list
 END ;Subroutine
 SUBROUTINE retrieveactions(btermactions,dscrpatternid)
  DECLARE action_idx = i4 WITH protect, noconstant(size(action_list->actions,5))
  SELECT
   IF (btermactions=para_actions)
    FROM scr_paragraph p,
     scr_action a,
     expression e
    PLAN (p
     WHERE p.scr_pattern_id=dscrpatternid)
     JOIN (a
     WHERE a.parent_entity_id=p.scr_paragraph_id
      AND a.parent_entity_name="SCR_PARAGRAPH")
     JOIN (e
     WHERE e.expression_id=a.expression_id)
   ELSE
    FROM scr_term_hier th,
     scr_action a,
     expression e
    PLAN (th
     WHERE th.scr_pattern_id=dscrpatternid)
     JOIN (a
     WHERE a.parent_entity_id=th.scr_term_hier_id
      AND a.parent_entity_name="SCR_TERM_HIER")
     JOIN (e
     WHERE e.expression_id=a.expression_id)
   ENDIF
   INTO "NL:"
   HEAD REPORT
    IF (mod(action_idx,10) != 0)
     stat = alterlist(action_list->actions,(action_idx+ 9))
    ENDIF
   DETAIL
    action_idx = (action_idx+ 1)
    IF (mod(action_idx,10)=1)
     stat = alterlist(action_list->actions,(action_idx+ 9))
    ENDIF
    action_list->actions[action_idx].action_id = a.scr_action_id, action_list->actions[action_idx].
    expr_id = a.expression_id
   FOOT REPORT
    IF (action_idx != 0)
     stat = alterlist(action_list->actions,action_idx)
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE removereferencedexprs(null)
   DECLARE num_actions = i4 WITH protect, constant(size(action_list->actions,5))
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE loop_count = i4 WITH protect, constant(ceil((cnvtreal(num_actions)/ expand_size)))
   DECLARE locate_idx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = loop_count),
     scr_action a
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (a
     WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),a.expression_id,
      action_list->actions[expand_idx].expr_id)
      AND a.expression_id != 0.0)
    ORDER BY a.expression_id
    HEAD a.expression_id
     idx = 1
     WHILE (idx > 0)
       locate_idx = 0, idx = locateval(locate_idx,idx,num_actions,a.expression_id,action_list->
        actions[locate_idx].expr_id)
       IF (idx > 0)
        action_list->actions[idx].expr_id = 0.0, idx = (idx+ 1)
       ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE retrieveexprcomps(null)
   DECLARE comp_idx = i4 WITH protect, noconstant(0)
   DECLARE num_actions = i4 WITH protect, constant(size(action_list->actions,5))
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_start = i4 WITH protect, noconstant(1)
   DECLARE loop_count = i4 WITH protect, constant(ceil((cnvtreal(num_actions)/ expand_size)))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = loop_count),
     expression_comp ec
    PLAN (d
     WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
     JOIN (ec
     WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),ec.expression_id,
      action_list->actions[expand_idx].expr_id)
      AND ec.expression_id != 0.0)
    ORDER BY ec.parent_expression_comp_id DESC
    HEAD REPORT
     comp_idx = 0
    DETAIL
     comp_idx = (comp_idx+ 1)
     IF (mod(comp_idx,10)=1)
      stat = alterlist(comp_list->expr_comps,(comp_idx+ 9))
     ENDIF
     comp_list->expr_comps[comp_idx].comp_id = ec.expression_comp_id
    FOOT REPORT
     IF (comp_idx != 0)
      stat = alterlist(comp_list->expr_comps,comp_idx)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
END GO
