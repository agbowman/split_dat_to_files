CREATE PROGRAM dm_pcmb_he_session:dba
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
     2 knowledgebase_name = c100
     2 knowledgebase_version = c30
     2 consequents[*]
       3 active_ind = i2
       3 beg_effective_dt_tm = dq8
       3 certainty = i4
       3 consequent_name = c100
       3 consequent_value_txt = vc
       3 end_effective_dt_tm = dq8
       3 explanation = c255
       3 consequent_key = c355
       3 serialized_class = vc
       3 serialized_object = vc
   1 to_rec[*]
     2 to_id = f8
     2 knowledgebase_name = c100
     2 consequents[*]
       3 consequent_key = c355
 )
 FREE RECORD hsc_ids
 RECORD hsc_ids(
   1 ids[*]
     2 id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_consequent_index = i4 WITH protect, noconstant(0)
 DECLARE sessionnum = i4 WITH noconstant(0), public
 DECLARE consequentnum = i4 WITH noconstant(0), public
 DECLARE new_to_session_id = f8 WITH noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "HE_SESSION"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_HE_SESSION"
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
  frm.session_id, frm.knowledgebase_name, frm.knowledgebase_version
  FROM he_session frm
  WHERE (frm.parent_entity_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.parent_entity_name="PERSON"
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.session_id, rreclist->from_rec[v_cust_count1].
   knowledgebase_name = frm.knowledgebase_name, rreclist->from_rec[v_cust_count1].
   knowledgebase_version = frm.knowledgebase_version
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   textlen_hsc_consequent_value_txt = textlen(hsc.consequent_value_txt)
   FROM he_session_consequent hsc,
    (dummyt d  WITH seq = value(v_cust_count1))
   PLAN (d)
    JOIN (hsc
    WHERE (hsc.session_id=rreclist->from_rec[d.seq].from_id))
   ORDER BY hsc.session_id
   HEAD hsc.session_id
    v_consequent_index = 0
   DETAIL
    v_consequent_index += 1
    IF (mod(v_consequent_index,10)=1)
     stat = alterlist(rreclist->from_rec[d.seq].consequents,(v_consequent_index+ 9))
    ENDIF
    rreclist->from_rec[d.seq].consequents[v_consequent_index].active_ind = hsc.active_ind, rreclist->
    from_rec[d.seq].consequents[v_consequent_index].beg_effective_dt_tm = hsc.beg_effective_dt_tm,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].certainty = hsc.certainty,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].consequent_name = hsc.consequent_name,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].consequent_value_txt = notrim(substring
     (1,textlen_hsc_consequent_value_txt,hsc.consequent_value_txt)), rreclist->from_rec[d.seq].
    consequents[v_consequent_index].end_effective_dt_tm = hsc.end_effective_dt_tm,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].explanation = hsc.explanation, rreclist
    ->from_rec[d.seq].consequents[v_consequent_index].serialized_class = hsc.serialized_class,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].serialized_object = hsc
    .serialized_object,
    rreclist->from_rec[d.seq].consequents[v_consequent_index].consequent_key = build(hsc
     .consequent_name,hsc.consequent_value_txt)
   FOOT  hsc.session_id
    stat = alterlist(rreclist->from_rec[d.seq].consequents,v_consequent_index)
   WITH nocounter
  ;end select
  UPDATE  FROM he_session hs,
    (dummyt d  WITH seq = value(v_cust_count1))
   SET hs.updt_cnt = (hs.updt_cnt+ 1), hs.updt_id = reqinfo->updt_id, hs.updt_applctx = reqinfo->
    updt_applctx,
    hs.updt_task = reqinfo->updt_task, hs.updt_dt_tm = cnvtdatetime(sysdate), hs.status_flag =
    IF ((request->xxx_combine[icombine].encntr_id=0)
     AND (rreclist->from_rec[d.seq].knowledgebase_name != "INVITEACTION")) 3
    ELSE 4
    ENDIF
    ,
    hs.priority = 2
   PLAN (d)
    JOIN (hs
    WHERE (hs.session_id=rreclist->from_rec[d.seq].from_id))
   WITH nocounter
  ;end update
 ENDIF
 SELECT INTO "nl:"
  tu.session_id, tu.knowledgebase_name
  FROM he_session tu
  WHERE (tu.parent_entity_id=request->xxx_combine[icombine].to_xxx_id)
   AND tu.parent_entity_name="PERSON"
  ORDER BY tu.knowledgebase_name
  DETAIL
   v_cust_count2 += 1
   IF (mod(v_cust_count2,10)=1)
    stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
   ENDIF
   rreclist->to_rec[v_cust_count2].to_id = tu.session_id, rreclist->to_rec[v_cust_count2].
   knowledgebase_name = tu.knowledgebase_name
  FOOT REPORT
   stat = alterlist(rreclist->to_rec,v_cust_count2)
  WITH memsort, forupdatewait(tu)
 ;end select
 IF (v_cust_count2 > 0)
  SELECT INTO "nl:"
   FROM he_session_consequent hsc,
    (dummyt d  WITH seq = value(v_cust_count2))
   PLAN (d)
    JOIN (hsc
    WHERE (hsc.session_id=rreclist->to_rec[d.seq].to_id))
   ORDER BY hsc.session_id, hsc.consequent_name, hsc.consequent_value_txt
   HEAD hsc.session_id
    v_consequent_index = 0
   DETAIL
    v_consequent_index += 1
    IF (mod(v_consequent_index,10)=1)
     stat = alterlist(rreclist->to_rec[d.seq].consequents,(v_consequent_index+ 9))
    ENDIF
    rreclist->to_rec[d.seq].consequents[v_consequent_index].consequent_key = build(hsc
     .consequent_name,hsc.consequent_value_txt)
   FOOT  hsc.session_id
    stat = alterlist(rreclist->to_rec[d.seq].consequents,v_consequent_index)
   WITH memsort
  ;end select
  UPDATE  FROM he_session hs,
    (dummyt d  WITH seq = value(v_cust_count2))
   SET hs.updt_cnt = (hs.updt_cnt+ 1), hs.updt_id = reqinfo->updt_id, hs.updt_applctx = reqinfo->
    updt_applctx,
    hs.updt_task = reqinfo->updt_task, hs.updt_dt_tm = cnvtdatetime(sysdate), hs.status_flag = 4,
    hs.priority = 2
   PLAN (d)
    JOIN (hs
    WHERE (hs.session_id=rreclist->to_rec[d.seq].to_id))
   WITH nocounter
  ;end update
 ENDIF
 SET q_table_exists = checkdic("HE_CONSEQUENT_QUEUE","T",0)
 FOR (v_cust_loopcount = 1 TO v_cust_count1)
  SET pos = locatevalsort(sessionnum,1,v_cust_count2,rreclist->from_rec[v_cust_loopcount].
   knowledgebase_name,rreclist->to_rec[sessionnum].knowledgebase_name)
  IF (pos > 0)
   SET consequenttosize = size(rreclist->to_rec[pos].consequents,5)
   SET consequentfromsize = size(rreclist->from_rec[v_cust_loopcount].consequents,5)
   IF (consequenttosize=0)
    IF (consequentfromsize > 0)
     SET stat = alterlist(hsc_ids->ids,consequentfromsize)
     EXECUTE dm2_dar_get_bulk_seq "hsc_ids->ids", consequentfromsize, "id",
     1, "PCO_SEQ"
     IF ((m_dm2_seq_stat->n_status != 1))
      CALL echo(m_dm2_seq_stat->s_error_msg)
      GO TO exit_sub
     ENDIF
     INSERT  FROM he_session_consequent hsc,
       (dummyt d  WITH seq = value(consequentfromsize))
      SET hsc.session_consequent_id = hsc_ids->ids[d.seq].id, hsc.session_id = rreclist->to_rec[pos].
       to_id, hsc.active_ind = rreclist->from_rec[v_cust_loopcount].consequents[d.seq].active_ind,
       hsc.beg_effective_dt_tm = cnvtdatetime(rreclist->from_rec[v_cust_loopcount].consequents[d.seq]
        .beg_effective_dt_tm), hsc.certainty = rreclist->from_rec[v_cust_loopcount].consequents[d.seq
       ].certainty, hsc.consequent_name = rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
       consequent_name,
       hsc.consequent_value_txt = notrim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
        consequent_value_txt), hsc.end_effective_dt_tm = cnvtdatetime(rreclist->from_rec[
        v_cust_loopcount].consequents[d.seq].end_effective_dt_tm), hsc.explanation = rreclist->
       from_rec[v_cust_loopcount].consequents[d.seq].explanation,
       hsc.serialized_class =
       IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_class)) >
       0) rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_class
       ELSE null
       ENDIF
       , hsc.serialized_object =
       IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_object))
        > 0) rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_object
       ELSE null
       ENDIF
       , hsc.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].knowledgebase_name,
       hsc.updt_id = reqinfo->updt_id, hsc.updt_applctx = reqinfo->updt_applctx, hsc.updt_task =
       reqinfo->updt_task,
       hsc.updt_dt_tm = cnvtdatetime(sysdate)
      PLAN (d)
       JOIN (hsc)
      WITH nocounter
     ;end insert
     IF (q_table_exists=2
      AND consequentfromsize > 0)
      INSERT  FROM he_consequent_queue hcq,
        (dummyt d  WITH seq = value(consequentfromsize))
       SET hcq.he_consequent_queue_id = seq(pco_seq,nextval), hcq.session_consequent_id = hsc_ids->
        ids[d.seq].id, hcq.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].
        knowledgebase_name,
        hcq.updt_id = reqinfo->updt_id, hcq.updt_dt_tm = cnvtdatetime(sysdate)
       PLAN (d)
        JOIN (hcq)
       WITH nocounter
      ;end insert
     ENDIF
     IF (validate(bdebug)=0)
      DECLARE bdebug = i2 WITH protect, noconstant(false)
     ELSEIF (bdebug=true)
      CALL echorecord(hsc_ids)
     ENDIF
     SET stat = initrec(hsc_ids)
     SET stat = initrec(m_dm2_seq_stat)
    ENDIF
   ELSE
    FOR (v_consequent_index = 1 TO consequentfromsize)
     SET consequentpos = locatevalsort(consequentnum,1,consequenttosize,rreclist->from_rec[
      v_cust_loopcount].consequents[v_consequent_index].consequent_key,rreclist->to_rec[pos].
      consequents[consequentnum].consequent_key)
     IF (consequentpos <= 0)
      IF (validate(hsc_id)=0)
       DECLARE hsc_id = f8
      ENDIF
      SELECT INTO "nl:"
       y = seq(pco_seq,nextval)
       FROM dual
       DETAIL
        hsc_id = cnvtreal(y)
       WITH nocounter
      ;end select
      INSERT  FROM he_session_consequent hsc
       SET hsc.session_consequent_id = hsc_id, hsc.session_id = rreclist->to_rec[pos].to_id, hsc
        .active_ind = rreclist->from_rec[v_cust_loopcount].consequents[v_consequent_index].active_ind,
        hsc.beg_effective_dt_tm = cnvtdatetime(rreclist->from_rec[v_cust_loopcount].consequents[
         v_consequent_index].beg_effective_dt_tm), hsc.certainty = rreclist->from_rec[
        v_cust_loopcount].consequents[v_consequent_index].certainty, hsc.consequent_name = rreclist->
        from_rec[v_cust_loopcount].consequents[v_consequent_index].consequent_name,
        hsc.consequent_value_txt = notrim(rreclist->from_rec[v_cust_loopcount].consequents[
         v_consequent_index].consequent_value_txt), hsc.end_effective_dt_tm = cnvtdatetime(rreclist->
         from_rec[v_cust_loopcount].consequents[v_consequent_index].end_effective_dt_tm), hsc
        .explanation = rreclist->from_rec[v_cust_loopcount].consequents[v_consequent_index].
        explanation,
        hsc.serialized_class =
        IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[v_consequent_index].
          serialized_class)) > 0) rreclist->from_rec[v_cust_loopcount].consequents[v_consequent_index
         ].serialized_class
        ELSE null
        ENDIF
        , hsc.serialized_object =
        IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[v_consequent_index].
          serialized_object)) > 0) rreclist->from_rec[v_cust_loopcount].consequents[
         v_consequent_index].serialized_object
        ELSE null
        ENDIF
        , hsc.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].knowledgebase_name,
        hsc.updt_id = reqinfo->updt_id, hsc.updt_applctx = reqinfo->updt_applctx, hsc.updt_task =
        reqinfo->updt_task,
        hsc.updt_dt_tm = cnvtdatetime(sysdate)
       WITH nocounter
      ;end insert
      IF (q_table_exists=2)
       INSERT  FROM he_consequent_queue hcq
        SET hcq.he_consequent_queue_id = seq(pco_seq,nextval), hcq.session_consequent_id = hsc_id,
         hcq.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].knowledgebase_name,
         hcq.updt_id = reqinfo->updt_id, hcq.updt_dt_tm = cnvtdatetime(sysdate)
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
  ELSE
   DECLARE session_id = f8
   SELECT INTO "nl:"
    y = seq(pco_seq,nextval)
    FROM dual
    DETAIL
     session_id = cnvtreal(y)
    WITH nocounter
   ;end select
   INSERT  FROM he_session hs
    SET hs.session_id = session_id, hs.updt_cnt = 0, hs.updt_id = reqinfo->updt_id,
     hs.updt_applctx = reqinfo->updt_applctx, hs.updt_task = reqinfo->updt_task, hs.updt_dt_tm =
     cnvtdatetime(sysdate),
     hs.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].knowledgebase_name, hs
     .knowledgebase_version = rreclist->from_rec[v_cust_loopcount].knowledgebase_version, hs
     .parent_entity_name = "PERSON",
     hs.parent_entity_id = request->xxx_combine[icombine].to_xxx_id, hs.status_flag = 4
    WITH nocounter
   ;end insert
   SET new_to_session_id = session_id
   SET consequentfromsize = size(rreclist->from_rec[v_cust_loopcount].consequents,5)
   IF (consequentfromsize > 0)
    SET stat = alterlist(hsc_ids->ids,consequentfromsize)
    EXECUTE dm2_dar_get_bulk_seq "hsc_ids->ids", consequentfromsize, "id",
    1, "PCO_SEQ"
    IF ((m_dm2_seq_stat->n_status != 1))
     CALL echo(m_dm2_seq_stat->s_error_msg)
     GO TO exit_sub
    ENDIF
    INSERT  FROM he_session_consequent hsc,
      (dummyt d  WITH seq = value(consequentfromsize))
     SET hsc.session_consequent_id = hsc_ids->ids[d.seq].id, hsc.session_id = session_id, hsc
      .active_ind = rreclist->from_rec[v_cust_loopcount].consequents[d.seq].active_ind,
      hsc.beg_effective_dt_tm = cnvtdatetime(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
       beg_effective_dt_tm), hsc.certainty = rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
      certainty, hsc.consequent_name = rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
      consequent_name,
      hsc.consequent_value_txt = notrim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].
       consequent_value_txt), hsc.end_effective_dt_tm = cnvtdatetime(rreclist->from_rec[
       v_cust_loopcount].consequents[d.seq].end_effective_dt_tm), hsc.explanation = rreclist->
      from_rec[v_cust_loopcount].consequents[d.seq].explanation,
      hsc.serialized_class =
      IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_class)) > 0
      ) rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_class
      ELSE null
      ENDIF
      , hsc.serialized_object =
      IF (textlen(trim(rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_object)) >
      0) rreclist->from_rec[v_cust_loopcount].consequents[d.seq].serialized_object
      ELSE null
      ENDIF
      , hsc.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].knowledgebase_name,
      hsc.updt_id = reqinfo->updt_id, hsc.updt_applctx = reqinfo->updt_applctx, hsc.updt_task =
      reqinfo->updt_task,
      hsc.updt_dt_tm = cnvtdatetime(sysdate)
     PLAN (d)
      JOIN (hsc)
     WITH nocounter
    ;end insert
    IF (q_table_exists=2
     AND consequentfromsize > 0)
     INSERT  FROM he_consequent_queue hcq,
       (dummyt d  WITH seq = value(consequentfromsize))
      SET hcq.he_consequent_queue_id = seq(pco_seq,nextval), hcq.session_consequent_id = hsc_ids->
       ids[d.seq].id, hcq.knowledgebase_name = rreclist->from_rec[v_cust_loopcount].
       knowledgebase_name,
       hcq.updt_id = reqinfo->updt_id, hcq.updt_dt_tm = cnvtdatetime(sysdate)
      PLAN (d)
       JOIN (hcq)
      WITH nocounter
     ;end insert
    ENDIF
    IF (validate(bdebug)=0)
     DECLARE bdebug = i2 WITH protect, noconstant(false)
    ELSEIF (bdebug=true)
     CALL echorecord(hsc_ids)
    ENDIF
    SET stat = initrec(hsc_ids)
    SET stat = initrec(m_dm2_seq_stat)
   ENDIF
  ENDIF
 ENDFOR
 IF (((v_cust_count1 > 0) OR (v_cust_count2 > 0)) )
  SET icombinedet += 1
  SET stat = alterlist(request->xxx_combine_det,icombinedet)
  SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
  IF (new_to_session_id=0)
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->to_rec[1].to_id
  ELSE
   SET request->xxx_combine_det[icombinedet].entity_id = new_to_session_id
  ENDIF
  SET request->xxx_combine_det[icombinedet].entity_name = "HE_SESSION"
  SET request->xxx_combine_det[icombinedet].attribute_name = "PARENT_ENTITY_ID"
 ENDIF
#exit_sub
 FREE RECORD hsc_ids
 FREE RECORD m_dm2_seq_stat
 FREE SET rreclist
 SET script_version = "009 07/28/23 IS010210"
END GO
