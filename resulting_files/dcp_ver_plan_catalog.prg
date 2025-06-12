CREATE PROGRAM dcp_ver_plan_catalog
 SET modify = predeclare
 RECORD ids(
   1 list[*]
     2 old = f8
     2 new = f8
 )
 RECORD pw(
   1 list[*]
     2 pathway_catalog_id = f8
     2 description = vc
     2 long_text_id = f8
     2 version = i4
     2 beg_effective_dt_tm = dq8
     2 restrict_comp_add_ind = i2
     2 cross_encntr_ind = i2
     2 type_mean = c12
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 display_method_cd = f8
 )
 RECORD pwreltn(
   1 list[*]
     2 pw_cat_s_id = f8
     2 pw_cat_t_id = f8
     2 type_mean = c12
     2 offset_qty = i4
     2 offset_unit_cd = f8
 )
 RECORD lt(
   1 list[*]
     2 long_text_id = f8
     2 long_text = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
 )
 RECORD comp(
   1 list[*]
     2 pathway_comp_id = f8
     2 pathway_catalog_id = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 required_ind = i2
     2 include_ind = i2
     2 linked_to_tf_ind = i2
     2 persistent_ind = i2
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 target_type_cd = f8
     2 expand_qty = i4
     2 expand_unit_cd = f8
 )
 RECORD composreltn(
   1 list[*]
     2 order_sentence_id = f8
     2 order_sentence_seq = i4
     2 pathway_comp_id = f8
     2 os_display = vc
 )
 RECORD compreltn(
   1 list[*]
     2 pw_comp_s_id = f8
     2 pw_comp_t_id = f8
     2 type_mean = c12
     2 offset_quantity = f8
     2 offset_unit_cd = f8
 )
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE high = i4 WITH protect, noconstant(0)
 DECLARE phasecnt = i4 WITH protect, noconstant(0)
 DECLARE reltncnt = i4 WITH protect, noconstant(0)
 DECLARE compcnt = i4 WITH protect, noconstant(0)
 DECLARE ltcnt = i4 WITH protect, noconstant(0)
 DECLARE idcnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE stop = i4 WITH protect, noconstant(0)
 DECLARE pw_id = f8 WITH protect, noconstant(0.0)
 DECLARE comp_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_id = f8 WITH protect, noconstant(0.0)
 DECLARE source_id = f8 WITH protect, noconstant(0.0)
 DECLARE target_id = f8 WITH protect, noconstant(0.0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE order_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE outcome_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE note_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"NOTE"))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 RECORD comp_request(
   1 id_count = i2
   1 comp_type_meaning = c12
 )
 RECORD comp_reply(
   1 id_list[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM pathway_catalog pwc,
   long_text lt
  PLAN (pwc
   WHERE (pwc.pathway_catalog_id=request->parent_cat_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(pwc.long_text_id))
  DETAIL
   stat = alterlist(pw->list,1), pw->list[1].pathway_catalog_id = pwc.pathway_catalog_id, pw->list[1]
   .description = pwc.description,
   pw->list[1].long_text_id = pwc.long_text_id, pw->list[1].version = 0, reply->version = pwc.version,
   reply->parent_id = pwc.pathway_catalog_id, pw->list[1].beg_effective_dt_tm = pwc
   .beg_effective_dt_tm, pw->list[1].restrict_comp_add_ind = pwc.restrict_comp_add_ind,
   pw->list[1].cross_encntr_ind = pwc.cross_encntr_ind, pw->list[1].type_mean = pwc.type_mean, pw->
   list[1].duration_qty = pwc.duration_qty,
   pw->list[1].duration_unit_cd = pwc.duration_unit_cd, pw->list[1].pathway_type_cd = pwc
   .pathway_type_cd, pw->list[1].pathway_class_cd = pwc.pathway_class_cd,
   pw->list[1].display_method_cd = pwc.display_method_cd
   IF (lt.long_text_id > 0)
    stat = alterlist(lt->list,1), lt->list[1].long_text = trim(lt.long_text), lt->list[1].
    parent_entity_name = lt.parent_entity_name,
    lt->list[1].parent_entity_id = lt.parent_entity_id, lt->list[1].active_status_cd = lt
    .active_status_cd, lt->list[1].active_status_dt_tm = lt.active_status_dt_tm,
    lt->list[1].active_status_prsnl_id = lt.active_status_prsnl_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_VER_PLAN_CATALOG",build(
    "Unable to find the plan.  pathway_catalog_id=",request->parent_cat_id))
  GO TO exit_script
 ENDIF
 IF ((pw->list[1].type_mean="PATHWAY"))
  SELECT INTO "nl:"
   pcr1.pw_cat_t_id, pwc.pathway_catalog_id, pcr2.pw_cat_t_id
   FROM pathway_catalog pwc,
    pw_cat_reltn pcr1,
    pw_cat_reltn pcr2
   PLAN (pcr1
    WHERE (pcr1.pw_cat_s_id=pw->list[1].pathway_catalog_id)
     AND pcr1.type_mean="GROUP")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pcr1.pw_cat_t_id
     AND pwc.active_ind=1)
    JOIN (pcr2
    WHERE pcr2.pw_cat_s_id=outerjoin(pwc.pathway_catalog_id))
   ORDER BY pcr1.pw_cat_t_id, pcr2.pw_cat_t_id
   HEAD REPORT
    phasecnt = 1, reltncnt = 0
   HEAD pcr1.pw_cat_t_id
    phasecnt = (phasecnt+ 1)
    IF (phasecnt > value(size(pw->list,5)))
     stat = alterlist(pw->list,(phasecnt+ 10))
    ENDIF
    pw->list[phasecnt].pathway_catalog_id = pwc.pathway_catalog_id, pw->list[phasecnt].description =
    pwc.description, pw->list[phasecnt].long_text_id = pwc.long_text_id,
    pw->list[phasecnt].version = pwc.version, pw->list[phasecnt].beg_effective_dt_tm = pwc
    .beg_effective_dt_tm, pw->list[phasecnt].restrict_comp_add_ind = pwc.restrict_comp_add_ind,
    pw->list[phasecnt].cross_encntr_ind = pwc.cross_encntr_ind, pw->list[phasecnt].type_mean = pwc
    .type_mean, pw->list[phasecnt].duration_qty = pwc.duration_qty,
    pw->list[phasecnt].duration_unit_cd = pwc.duration_unit_cd, pw->list[phasecnt].pathway_type_cd =
    pwc.pathway_type_cd, pw->list[phasecnt].pathway_class_cd = pwc.pathway_class_cd,
    pw->list[phasecnt].display_method_cd = pwc.display_method_cd, reltncnt = (reltncnt+ 1)
    IF (phasecnt > value(size(pwreltn->list,5)))
     stat = alterlist(pwreltn->list,(reltncnt+ 10))
    ENDIF
    pwreltn->list[reltncnt].pw_cat_s_id = pcr1.pw_cat_s_id, pwreltn->list[reltncnt].pw_cat_t_id =
    pcr1.pw_cat_t_id, pwreltn->list[reltncnt].type_mean = pcr1.type_mean,
    pwreltn->list[reltncnt].offset_qty = pcr1.offset_qty, pwreltn->list[reltncnt].offset_unit_cd =
    pcr1.offset_unit_cd
   HEAD pcr2.pw_cat_t_id
    IF (pcr2.pw_cat_s_id > 0)
     reltncnt = (reltncnt+ 1)
     IF (reltncnt > value(size(pwreltn->list,5)))
      stat = alterlist(pwreltn->list,(reltncnt+ 10))
     ENDIF
     pwreltn->list[reltncnt].pw_cat_s_id = pcr2.pw_cat_s_id, pwreltn->list[reltncnt].pw_cat_t_id =
     pcr2.pw_cat_t_id, pwreltn->list[reltncnt].type_mean = pcr2.type_mean,
     pwreltn->list[reltncnt].offset_qty = pcr2.offset_qty, pwreltn->list[reltncnt].offset_unit_cd =
     pcr2.offset_unit_cd
    ENDIF
   DETAIL
    dummy = 0
   FOOT  pcr2.pw_cat_t_id
    dummy = 0
   FOOT  pcr1.pw_cat_t_id
    stat = alterlist(pwreltn->list,reltncnt)
   FOOT REPORT
    stat = alterlist(pw->list,phasecnt)
   WITH nocounter
  ;end select
 ENDIF
 SET high = value(size(pw->list,5))
 IF (high > 0)
  SELECT INTO "nl:"
   FROM pathway_comp pwc,
    pw_comp_os_reltn pcor
   PLAN (pwc
    WHERE expand(num,1,high,pwc.pathway_catalog_id,pw->list[num].pathway_catalog_id)
     AND pwc.comp_type_cd IN (order_comp_cd, outcome_comp_cd)
     AND pwc.active_ind=1)
    JOIN (pcor
    WHERE pcor.pathway_comp_id=outerjoin(pwc.pathway_comp_id))
   ORDER BY pwc.pathway_comp_id, pcor.order_sentence_seq
   HEAD REPORT
    compcnt = 0, reltncnt = 0
   HEAD pwc.pathway_comp_id
    compcnt = (compcnt+ 1)
    IF (compcnt > value(size(comp->list,5)))
     stat = alterlist(comp->list,(compcnt+ 10))
    ENDIF
    comp->list[compcnt].pathway_comp_id = pwc.pathway_comp_id, comp->list[compcnt].pathway_catalog_id
     = pwc.pathway_catalog_id, comp->list[compcnt].sequence = pwc.sequence,
    comp->list[compcnt].comp_type_cd = pwc.comp_type_cd, comp->list[compcnt].parent_entity_name = pwc
    .parent_entity_name, comp->list[compcnt].parent_entity_id = pwc.parent_entity_id,
    comp->list[compcnt].dcp_clin_cat_cd = pwc.dcp_clin_cat_cd, comp->list[compcnt].
    dcp_clin_sub_cat_cd = pwc.dcp_clin_sub_cat_cd, comp->list[compcnt].required_ind = pwc
    .required_ind,
    comp->list[compcnt].include_ind = pwc.include_ind, comp->list[compcnt].linked_to_tf_ind = pwc
    .linked_to_tf_ind, comp->list[compcnt].persistent_ind = pwc.persistent_ind,
    comp->list[compcnt].duration_qty = pwc.duration_qty, comp->list[compcnt].duration_unit_cd = pwc
    .duration_unit_cd, comp->list[compcnt].target_type_cd = pwc.target_type_cd,
    comp->list[compcnt].expand_qty = pwc.expand_qty, comp->list[compcnt].expand_unit_cd = pwc
    .expand_unit_cd
   DETAIL
    IF (pcor.order_sentence_id > 0)
     reltncnt = (reltncnt+ 1)
     IF (reltncnt > value(size(composreltn->list,5)))
      stat = alterlist(composreltn->list,(reltncnt+ 10))
     ENDIF
     composreltn->list[reltncnt].order_sentence_id = pcor.order_sentence_id, composreltn->list[
     reltncnt].order_sentence_seq = pcor.order_sentence_seq, composreltn->list[reltncnt].
     pathway_comp_id = pcor.pathway_comp_id
    ENDIF
   FOOT  pwc.pathway_comp_id
    dummy = 0
   FOOT REPORT
    IF (reltncnt > 0)
     stat = alterlist(composreltn->list,reltncnt)
    ENDIF
    IF (compcnt > 0)
     stat = alterlist(comp->list,compcnt)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pathway_comp pwc,
    long_text lt
   PLAN (pwc
    WHERE expand(num,1,high,pwc.pathway_catalog_id,pw->list[num].pathway_catalog_id)
     AND pwc.comp_type_cd=note_comp_cd
     AND pwc.active_ind=1)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(pwc.parent_entity_id))
   ORDER BY pwc.pathway_comp_id
   HEAD REPORT
    compcnt = value(size(comp->list,5)), ltcnt = value(size(lt->list,5))
   HEAD pwc.pathway_comp_id
    compcnt = (compcnt+ 1)
    IF (compcnt > value(size(comp->list,5)))
     stat = alterlist(comp->list,(compcnt+ 10))
    ENDIF
    comp->list[compcnt].pathway_comp_id = pwc.pathway_comp_id, comp->list[compcnt].pathway_catalog_id
     = pwc.pathway_catalog_id, comp->list[compcnt].sequence = pwc.sequence,
    comp->list[compcnt].comp_type_cd = pwc.comp_type_cd, comp->list[compcnt].parent_entity_name = pwc
    .parent_entity_name, comp->list[compcnt].parent_entity_id = pwc.parent_entity_id,
    comp->list[compcnt].dcp_clin_cat_cd = pwc.dcp_clin_cat_cd, comp->list[compcnt].
    dcp_clin_sub_cat_cd = pwc.dcp_clin_sub_cat_cd, comp->list[compcnt].required_ind = pwc
    .required_ind,
    comp->list[compcnt].include_ind = pwc.include_ind, comp->list[compcnt].linked_to_tf_ind = pwc
    .linked_to_tf_ind, comp->list[compcnt].persistent_ind = pwc.persistent_ind,
    comp->list[compcnt].duration_qty = pwc.duration_qty, comp->list[compcnt].duration_unit_cd = pwc
    .duration_unit_cd, comp->list[compcnt].target_type_cd = pwc.target_type_cd,
    comp->list[compcnt].expand_qty = pwc.expand_qty, comp->list[compcnt].expand_unit_cd = pwc
    .expand_unit_cd
   DETAIL
    IF (lt.long_text_id > 0)
     ltcnt = (ltcnt+ 1)
     IF (ltcnt > value(size(lt->list,5)))
      stat = alterlist(lt->list,(ltcnt+ 10))
     ENDIF
     lt->list[ltcnt].long_text = trim(lt.long_text), lt->list[ltcnt].parent_entity_name = lt
     .parent_entity_name, lt->list[ltcnt].parent_entity_id = lt.parent_entity_id,
     lt->list[ltcnt].active_status_cd = lt.active_status_cd, lt->list[ltcnt].active_status_dt_tm = lt
     .active_status_dt_tm, lt->list[ltcnt].active_status_prsnl_id = lt.active_status_prsnl_id
    ENDIF
   FOOT  pwc.pathway_comp_id
    dummy = 0
   FOOT REPORT
    IF (ltcnt > 0)
     stat = alterlist(lt->list,ltcnt)
    ENDIF
    IF (compcnt > 0)
     stat = alterlist(comp->list,compcnt)
    ENDIF
   WITH nocounter
  ;end select
  SET high = value(size(comp->list,5))
  SET num = 0
  SELECT INTO "nl:"
   FROM pw_comp_reltn pcr
   PLAN (pcr
    WHERE expand(num,1,high,pcr.pathway_comp_s_id,comp->list[num].pathway_comp_id))
   ORDER BY pcr.pathway_comp_s_id, pcr.pathway_comp_t_id
   HEAD REPORT
    reltncnt = 0
   DETAIL
    reltncnt = (reltncnt+ 1)
    IF (reltncnt > value(size(compreltn->list,5)))
     stat = alterlist(compreltn->list,(reltncnt+ 10))
    ENDIF
    compreltn->list[reltncnt].pw_comp_s_id = pcr.pathway_comp_s_id, compreltn->list[reltncnt].
    pw_comp_t_id = pcr.pathway_comp_t_id, compreltn->list[reltncnt].type_mean = pcr.type_mean,
    compreltn->list[reltncnt].offset_quantity = pcr.offset_quantity, compreltn->list[reltncnt].
    offset_unit_cd = pcr.offset_unit_cd
   FOOT REPORT
    IF (reltncnt > 0)
     stat = alterlist(compreltn->list,reltncnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET phasecnt = value(size(pw->list,5))
 SET stat = alterlist(ids->list,phasecnt)
 FOR (num = 1 TO phasecnt)
   SET ids->list[num].old = pw->list[num].pathway_catalog_id
 ENDFOR
 SET compcnt = value(size(comp->list,5))
 SET stat = alterlist(ids->list,(phasecnt+ compcnt))
 FOR (num = 1 TO compcnt)
   SET ids->list[(phasecnt+ num)].old = comp->list[num].pathway_comp_id
 ENDFOR
 SET idcnt = value(size(ids->list,5))
 SET comp_request->id_count = idcnt
 SET modify = nopredeclare
 SET comp_request->comp_type_meaning = "PLAN REF"
 EXECUTE dcp_get_pw_comp_id  WITH replace("REQUEST","COMP_REQUEST"), replace("REPLY","COMP_REPLY")
 SET modify = predeclare
 FOR (num = 1 TO idcnt)
   SET ids->list[num].new = comp_reply->id_list[num].id
 ENDFOR
 SET num = 0
 SET idx = locateval(num,1,idcnt,reply->parent_id,ids->list[num].old)
 SET reply->parent_id = ids->list[idx].new
 SET ltcnt = value(size(lt->list,5))
 FOR (i = 1 TO ltcnt)
   SET lt->list[i].long_text_id = 0
   SET num = 0
   SET idx = locateval(num,1,idcnt,lt->list[i].parent_entity_id,ids->list[num].old)
   SET lt->list[i].parent_entity_id = ids->list[idx].new
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     lt->list[i].long_text_id = nextseqnum
    WITH nocounter
   ;end select
   IF ((lt->list[i].long_text_id=0.0))
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",
     "Unable to generate new long_text_id for pathway note")
    GO TO exit_script
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = lt->list[i].long_text_id, lt.parent_entity_name = lt->list[i].
     parent_entity_name, lt.parent_entity_id = lt->list[i].parent_entity_id,
     lt.long_text = lt->list[i].long_text, lt.active_ind = 1, lt.active_status_cd = lt->list[i].
     active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(lt->list[i].active_status_dt_tm), lt
     .active_status_prsnl_id = lt->list[i].active_status_prsnl_id, lt.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",
     "Unable to insert pathway note into LONG_TEXT")
    GO TO exit_script
   ENDIF
 ENDFOR
 SET phasecnt = value(size(pw->list,5))
 FOR (i = 1 TO phasecnt)
   SET num = 0
   SET idx = locateval(num,1,idcnt,pw->list[i].pathway_catalog_id,ids->list[num].old)
   SET pw_id = ids->list[idx].new
   SET num = 0
   SET idx = locateval(num,1,value(size(lt->list,5)),pw_id,lt->list[num].parent_entity_id)
   IF (idx > 0)
    SET long_text_id = lt->list[idx].long_text_id
   ELSE
    SET long_text_id = 0.0
   ENDIF
   INSERT  FROM pathway_catalog pc
    SET pc.pathway_catalog_id = pw_id, pc.type_mean = pw->list[i].type_mean, pc.active_ind =
     IF ((pw->list[i].type_mean="PHASE")) 1
     ELSE 0
     ENDIF
     ,
     pc.cross_encntr_ind = pw->list[i].cross_encntr_ind, pc.description = trim(pw->list[i].
      description), pc.description_key = trim(cnvtupper(pw->list[i].description)),
     pc.long_text_id = long_text_id, pc.version = pw->list[i].version, pc.version_pw_cat_id = pw->
     list[i].pathway_catalog_id,
     pc.beg_effective_dt_tm = cnvtdatetime(pw->list[i].beg_effective_dt_tm), pc.end_effective_dt_tm
      = cnvtdatetime(curdate,curtime3), pc.duration_qty = pw->list[i].duration_qty,
     pc.duration_unit_cd = pw->list[i].duration_unit_cd, pc.pathway_type_cd = pw->list[i].
     pathway_type_cd, pc.pathway_class_cd = pw->list[i].pathway_class_cd,
     pc.display_method_cd = pw->list[i].display_method_cd, pc.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), pc.updt_id = reqinfo->updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",build(
      "Unable to insert into PATHWAY_CATALOG",".  New ID=",pw_id,", old ID=",pw->list[i].
      pathway_catalog_id))
    GO TO exit_script
   ENDIF
 ENDFOR
 SET compcnt = value(size(comp->list,5))
 FOR (i = 1 TO compcnt)
   SET num = 0
   SET idx = locateval(num,1,idcnt,comp->list[i].pathway_comp_id,ids->list[num].old)
   SET comp_id = ids->list[idx].new
   SET num = 0
   SET idx = locateval(num,1,idcnt,comp->list[i].pathway_catalog_id,ids->list[num].old)
   SET pw_id = ids->list[idx].new
   IF ((comp->list[i].comp_type_cd=note_comp_cd))
    SET num = 0
    SET idx = locateval(num,1,value(size(lt->list,5)),comp_id,lt->list[num].parent_entity_id)
    IF (idx > 0)
     SET parent_id = lt->list[idx].long_text_id
    ELSE
     SET parent_id = 0.0
    ENDIF
   ENDIF
   INSERT  FROM pathway_comp pwc
    SET pwc.pathway_comp_id = comp_id, pwc.pathway_catalog_id = pw_id, pwc.sequence = comp->list[i].
     sequence,
     pwc.active_ind = 1, pwc.comp_type_cd = comp->list[i].comp_type_cd, pwc.parent_entity_name = comp
     ->list[i].parent_entity_name,
     pwc.parent_entity_id =
     IF ((comp->list[i].comp_type_cd=note_comp_cd)) parent_id
     ELSE comp->list[i].parent_entity_id
     ENDIF
     , pwc.dcp_clin_cat_cd = comp->list[i].dcp_clin_cat_cd, pwc.dcp_clin_sub_cat_cd = comp->list[i].
     dcp_clin_sub_cat_cd,
     pwc.required_ind = comp->list[i].required_ind, pwc.include_ind = comp->list[i].include_ind, pwc
     .linked_to_tf_ind = comp->list[i].linked_to_tf_ind,
     pwc.persistent_ind = comp->list[i].persistent_ind, pwc.duration_qty = comp->list[i].duration_qty,
     pwc.duration_unit_cd = comp->list[i].duration_unit_cd,
     pwc.target_type_cd = comp->list[i].target_type_cd, pwc.expand_qty = comp->list[i].expand_qty,
     pwc.expand_unit_cd = comp->list[i].expand_unit_cd,
     pwc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pwc.updt_id = reqinfo->updt_id, pwc.updt_task
      = reqinfo->updt_task,
     pwc.updt_applctx = reqinfo->updt_applctx, pwc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",build(
      "Unable to insert into PATHWAY_COMP",".  New ID=",comp_id,", old ID=",comp->list[i].
      pathway_comp_id))
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reltncnt = value(size(composreltn->list,5))
 SET start = 1
 SET stop = reltncnt
 SELECT INTO "nl:"
  FROM order_sentence os
  PLAN (os
   WHERE expand(num,1,reltncnt,os.order_sentence_id,composreltn->list[num].order_sentence_id))
  HEAD REPORT
   idx = 0
  DETAIL
   idx = locateval(idx,start,stop,os.order_sentence_id,composreltn->list[idx].order_sentence_id),
   composreltn->list[idx].os_display = trim(os.order_sentence_display_line), idx2 = idx
   WHILE (idx != 0)
    idx2 = locateval(idx2,(idx+ 1),stop,os.order_sentence_id,composreltn->list[idx2].
     order_sentence_id),
    IF (idx2 != 0)
     idx = idx2, composreltn->list[idx].os_display = trim(os.order_sentence_display_line)
    ELSE
     idx = idx2
    ENDIF
   ENDWHILE
  FOOT REPORT
   idx = 0
  WITH nocounter
 ;end select
 FOR (i = 1 TO reltncnt)
   SET num = 0
   SET idx = locateval(num,1,idcnt,composreltn->list[i].pathway_comp_id,ids->list[num].old)
   SET parent_id = ids->list[idx].new
   INSERT  FROM pw_comp_os_reltn pcor
    SET pcor.order_sentence_id = composreltn->list[i].order_sentence_id, pcor.order_sentence_seq =
     composreltn->list[i].order_sentence_seq, pcor.pathway_comp_id = parent_id,
     pcor.os_display_line = trim(composreltn->list[i].os_display), pcor.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), pcor.updt_id = reqinfo->updt_id,
     pcor.updt_task = reqinfo->updt_task, pcor.updt_applctx = reqinfo->updt_applctx, pcor.updt_cnt =
     0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",build(
      "Unable to insert into PATHWAY_COMP_OS_RELTN",".  New comp ID=",parent_id,", old comp ID=",
      composreltn->list[i].pathway_comp_id))
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reltncnt = value(size(compreltn->list,5))
 FOR (i = 1 TO reltncnt)
   SET num = 0
   SET idx = locateval(num,1,idcnt,compreltn->list[i].pw_comp_s_id,ids->list[num].old)
   SET source_id = ids->list[idx].new
   SET num = 0
   SET idx = locateval(num,1,idcnt,compreltn->list[i].pw_comp_t_id,ids->list[num].old)
   SET target_id = ids->list[idx].new
   INSERT  FROM pw_comp_reltn pcr
    SET pcr.pathway_comp_s_id = source_id, pcr.pathway_comp_t_id = target_id, pcr.type_mean =
     compreltn->list[i].type_mean,
     pcr.offset_quantity = compreltn->list[i].offset_quantity, pcr.offset_unit_cd = compreltn->list[i
     ].offset_unit_cd, pcr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->updt_task, pcr.updt_cnt = 0,
     pcr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",build(
      "Unable to insert into PW_COMP_RELTN",".  New source ID=",source_id,", old source ID=",
      compreltn->list[i].pw_comp_s_id))
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reltncnt = value(size(pwreltn->list,5))
 FOR (i = 1 TO reltncnt)
   SET num = 0
   SET idx = locateval(num,1,idcnt,pwreltn->list[i].pw_cat_s_id,ids->list[num].old)
   SET source_id = ids->list[idx].new
   SET num = 0
   SET idx = locateval(num,1,idcnt,pwreltn->list[i].pw_cat_t_id,ids->list[num].old)
   SET target_id = ids->list[idx].new
   INSERT  FROM pw_cat_reltn pcr
    SET pcr.pw_cat_s_id = source_id, pcr.pw_cat_t_id = target_id, pcr.type_mean = pwreltn->list[i].
     type_mean,
     pcr.offset_qty = pwreltn->list[i].offset_qty, pcr.offset_unit_cd = pwreltn->list[i].
     offset_unit_cd, pcr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pcr.updt_id = reqinfo->updt_id, pcr.updt_task = reqinfo->updt_task, pcr.updt_cnt = 0,
     pcr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_PLAN_CATALOG",build(
      "Unable to insert into PW_CAT_RELTN",".  New source ID=",source_id,", old source ID=",pwreltn->
      list[i].pw_cat_s_id))
    GO TO exit_script
   ENDIF
 ENDFOR
 FREE RECORD ids
 FREE RECORD pw
 FREE RECORD pwreltn
 FREE RECORD lt
 FREE RECORD comp
 FREE RECORD composreltn
 FREE RECORD compreltn
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
