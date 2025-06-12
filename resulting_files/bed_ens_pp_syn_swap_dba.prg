CREATE PROGRAM bed_ens_pp_syn_swap:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET newversionrequest
 RECORD newversionrequest(
   1 pathway_catalog_id = f8
   1 updt_cnt = i4
   1 create_new_ind = i2
   1 copy_ind = i2
   1 copy_description = vc
   1 version_to_testing_ind = i2
 )
 FREE SET newversionreply
 RECORD newversionreply(
   1 version_number = i4
   1 pathway_catalog_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET swap_synonyms
 RECORD swap_synonyms(
   1 syns[*]
     2 new_syn_id = f8
     2 pp_id = f8
     2 multi_ind = i2
     2 component_id = f8
 )
 FREE SET temppp
 RECORD temppp(
   1 power_plans[*]
     2 power_plan_id = f8
     2 multi_ind = i2
     2 components[*]
       3 component_id = f8
       3 uuid = vc
 )
 FREE SET del_os_reltn
 RECORD del_os_reltn(
   1 reltns[*]
     2 component_id = f8
 )
 FREE SET tempdelsent
 RECORD tempdelsent(
   1 sents[*]
     2 id = f8
 )
 FREE SET tempaddsynos
 RECORD tempaddsynos(
   1 ordersentence[*]
     2 powerplanid = f8
     2 componentid = f8
     2 id = f8
     2 sequence = i4
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 usage_flag = i2
     2 comment = vc
     2 commentid = f8
     2 synonym_id = f8
     2 rx_type_mean = vc
 )
 FREE SET tempaddingos
 RECORD tempaddingos(
   1 ordersentence[*]
     2 powerplanid = f8
     2 phaseid = f8
     2 componentid = f8
     2 synonymid = f8
     2 id = f8
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 os_oe_format_id = f8
     2 comment = vc
     2 commentid = f8
     2 synonym_id = f8
 )
 FREE SET tempaddosdet
 RECORD tempaddosdet(
   1 fielddetail[*]
     2 powerplanid = f8
     2 phaseid = f8
     2 componentid = f8
     2 sentenceid = f8
     2 oef_id = f8
     2 value = f8
     2 display = vc
     2 field_type_flag = i4
     2 oe_field_meaning_id = f8
     2 sequence = i4
     2 synonym_id = f8
 )
 FREE SET tempaddosfilter
 RECORD tempaddosfilter(
   1 filters[*]
     2 sentence_id = f8
     2 order_sentence_filter_id = f8
     2 age_min_value = f8
     2 age_max_value = f8
     2 age_code_value = f8
     2 pma_min_value = f8
     2 pma_max_value = f8
     2 pma_code_value = f8
     2 weight_min_value = f8
     2 weight_max_value = f8
     2 weight_code_value = f8
 )
 FREE SET tempdelosfilter
 RECORD tempdelosfilter(
   1 filters[*]
     2 order_sentence_filter_id = f8
 )
 DECLARE logerror(namemsg=vc,valuemsg=vc) = null
 DECLARE populateversionrequest(ppid=f8,updtcnt=i4,createnewind=i2,testingind=i2) = null
 DECLARE populateswapstructure(newsynid=f8,ppid=f8,compid=f8) = null
 DECLARE getcomponentsbyplan(dummyvar=i2) = null
 DECLARE removeallos(compid=f8) = null
 DECLARE populatesentencestructure(planindex=i4,compindex=i4) = null
 DECLARE populatesentencedetails(planindex=i4,compindex=i4,osindex=i4,sentid=f8) = null
 DECLARE populatesynosfilters(i=i4,j=i4,k=i4,sentid=f8) = null
 DECLARE populateingos(planindex=i4,compindex=i4) = null
 DECLARE populateingosdet(planindex=i4,compindex=i4,ingindex=i4,sentid=f8) = null
 DECLARE plancount = i4 WITH noconstant(0), protect
 DECLARE tempplancount = i4 WITH noconstant(0), protect
 DECLARE temptestingind = i2 WITH noconstant(0), protect
 DECLARE compsize = i4 WITH noconstant(0), protect
 DECLARE swapcnt = i4 WITH noconstant(0), protect
 DECLARE delsentcnt = i4 WITH noconstant(0), protect
 DECLARE osdelcnt = i4 WITH noconstant(0), protect
 DECLARE ossyncnt = i4 WITH noconstant(0), protect
 DECLARE synosid = f8 WITH noconstant(0.0), protect
 DECLARE addsynoscnt = i4 WITH noconstant(0), protect
 DECLARE ossyndetcnt = i4 WITH noconstant(0), protect
 DECLARE addosdetcnt = i4 WITH noconstant(0), protect
 DECLARE ingcnt = i4 WITH noconstant(0), protect
 DECLARE addingoscnt = i4 WITH noconstant(0), protect
 DECLARE ingdetcnt = i4 WITH noconstant(0), protect
 DECLARE addosdetcnt = i4 WITH noconstant(0), protect
 DECLARE ingosid = f8 WITH noconstant(0.0), protect
 DECLARE osfiltercnt = i4 WITH noconstant(0), protect
 DECLARE addosfiltercnt = i4 WITH noconstant(0), protect
 DECLARE delosfiltercnt = i4 WITH noconstant(0), protect
 DECLARE osfilterid = f8 WITH protect, noconstant(0.0)
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE intermittent_oe_field_meaning_id = f8 WITH constant(2070.0), protect
 DECLARE intermittent_oe_field_id = f8 WITH protect
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET intermittent_oe_field_id = 0.0
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.oe_field_meaning_id=intermittent_oe_field_meaning_id
  DETAIL
   intermittent_oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 IF (intermittent_oe_field_id=0.0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Intermittent oe_field_id not found")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET plancount = size(request->power_plans,5)
 SET stat = alterlist(temppp->power_plans,plancount)
 FOR (ppindex = 1 TO plancount)
   SET temppp->power_plans[ppindex].power_plan_id = request->power_plans[ppindex].power_plan_id
   IF ((request->power_plans[ppindex].version_flag > 0))
    SET temptestingind = evaluate(request->power_plans[ppindex].version_flag,1,0,2,1)
    CALL populateversionrequest(request->power_plans[ppindex].power_plan_id,request->power_plans[
     ppindex].updt_cnt,1,temptestingind)
    EXECUTE dcp_version_plan_catalog  WITH replace("REQUEST",newversionrequest), replace("REPLY",
     newversionreply)
    IF ((newversionreply->status_data.status="F"))
     CALL echorecord(newversionreply)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error calling version ccl")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = newversionreply->status_data.
     subeventstatus[1].targetobjectvalue
     GO TO exit_script
    ENDIF
    SET request->power_plans[ppindex].power_plan_id = newversionreply->pathway_catalog_id
    SET temppp->power_plans[ppindex].power_plan_id = newversionreply->pathway_catalog_id
   ENDIF
   SET compsize = size(request->power_plans[ppindex].components,5)
   SET stat = alterlist(temppp->power_plans[ppindex].components,compsize)
   FOR (cindex = 1 TO compsize)
     SET temppp->power_plans[ppindex].components[cindex].uuid = request->power_plans[ppindex].
     components[cindex].uuid
   ENDFOR
 ENDFOR
 CALL getcomponentsbyplan(1)
 FOR (ppindex = 1 TO plancount)
  SET compsize = size(request->power_plans[ppindex].components,5)
  FOR (cindex = 1 TO compsize)
    CALL populateswapstructure(request->power_plans[ppindex].components[cindex].new_synonym_id,
     request->power_plans[ppindex].power_plan_id,temppp->power_plans[ppindex].components[cindex].
     component_id)
    IF ((request->power_plans[ppindex].components[cindex].remove_all_current_os=1))
     CALL removeallos(temppp->power_plans[ppindex].components[cindex].component_id)
    ENDIF
    CALL populatesentencestructure(ppindex,cindex)
    CALL populateingos(ppindex,cindex)
  ENDFOR
 ENDFOR
 IF (delsentcnt > 0)
  SET osdelcnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(delsentcnt)),
    pw_comp_os_reltn p
   PLAN (d)
    JOIN (p
    WHERE (p.pathway_comp_id=del_os_reltn->reltns[d.seq].component_id))
   DETAIL
    osdelcnt = (osdelcnt+ 1), stat = alterlist(tempdelsent->sents,osdelcnt), tempdelsent->sents[
    osdelcnt].id = p.order_sentence_id
   WITH nocounter
  ;end select
  SET ierrcode = 0
  DELETE  FROM pw_comp_os_reltn r,
    (dummyt d  WITH seq = value(delsentcnt))
   SET r.seq = 1
   PLAN (d)
    JOIN (r
    WHERE (r.pathway_comp_id=del_os_reltn->reltns[d.seq].component_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error removing sentence reltns",serrmsg)
  ENDIF
  IF (osdelcnt > 0)
   SET ierrcode = 0
   DELETE  FROM order_sentence_detail o,
     (dummyt d  WITH seq = value(osdelcnt))
    SET o.seq = 1
    PLAN (d)
     JOIN (o
     WHERE (o.order_sentence_id=tempdelsent->sents[d.seq].id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL logerror("Error removing sentence details",serrmsg)
   ENDIF
   SET ierrcode = 0
   DELETE  FROM order_sentence_filter f,
     (dummyt d  WITH seq = value(osdelcnt))
    SET f.seq = 1
    PLAN (d)
     JOIN (f
     WHERE (f.order_sentence_id=tempdelsent->sents[d.seq].id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL logerror("Error removing sentence filters",serrmsg)
   ENDIF
   SET ierrcode = 0
   DELETE  FROM order_sentence o,
     (dummyt d  WITH seq = value(osdelcnt))
    SET o.seq = 1
    PLAN (d)
     JOIN (o
     WHERE (o.order_sentence_id=tempdelsent->sents[d.seq].id))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL logerror("Error removing sentences",serrmsg)
   ENDIF
  ENDIF
 ENDIF
 IF (swapcnt > 0)
  SET ierrcode = 0
  UPDATE  FROM pathway_comp pc,
    (dummyt d  WITH seq = value(swapcnt))
   SET pc.parent_entity_id = swap_synonyms->syns[d.seq].new_syn_id, pc.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), pc.updt_id = reqinfo->updt_id,
    pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (pc
    WHERE (pc.pathway_comp_id=swap_synonyms->syns[d.seq].component_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error updating into pathway_comp",serrmsg)
  ENDIF
 ENDIF
 IF (addsynoscnt > 0)
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addsynoscnt)
   SET os.oe_format_id = tempaddsynos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddsynos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddsynos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.usage_flag = tempaddsynos->ordersentence[d.seq].usage_flag,
    os.ord_comment_long_text_id = tempaddsynos->ordersentence[d.seq].commentid, os.rx_type_mean =
    tempaddsynos->ordersentence[d.seq].rx_type_mean, os.updt_id = reqinfo->updt_id,
    os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task = reqinfo->updt_task, os
    .updt_applctx = reqinfo->updt_applctx,
    os.updt_cnt = 0
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].id > 0))
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into order_sentence",serrmsg)
  ENDIF
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addsynoscnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddsynos->ordersentence[d.seq].
    comment, lt.long_text_id = tempaddsynos->ordersentence[d.seq].commentid,
    lt.parent_entity_id = tempaddsynos->ordersentence[d.seq].id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_task = reqinfo->updt_task,
    lt.updt_id = reqinfo->updt_id, lt.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].comment > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into long_text",serrmsg)
  ENDIF
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addsynoscnt)
   SET pw.iv_comp_syn_id = 0, pw.order_sentence_id = tempaddsynos->ordersentence[d.seq].id, pw
    .order_sentence_seq = tempaddsynos->ordersentence[d.seq].sequence,
    pw.os_display_line = tempaddsynos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddsynos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d
    WHERE (tempaddsynos->ordersentence[d.seq].id > 0))
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into pw_comp_os_reltn",serrmsg)
  ENDIF
 ENDIF
 IF (addingoscnt > 0)
  INSERT  FROM order_sentence os,
    (dummyt d  WITH seq = addingoscnt)
   SET os.oe_format_id = tempaddingos->ordersentence[d.seq].os_oe_format_id, os
    .order_sentence_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, os
    .order_sentence_id = tempaddingos->ordersentence[d.seq].id,
    os.parent_entity_id = tempaddingos->ordersentence[d.seq].componentid, os.parent_entity_name =
    "PATHWAY_COMP", os.parent_entity2_id = tempaddingos->ordersentence[d.seq].synonymid,
    os.parent_entity2_name = "ORDER_CATALOG_SYNONYM", os.usage_flag = 1, os.ord_comment_long_text_id
     = tempaddingos->ordersentence[d.seq].commentid,
    os.updt_id = reqinfo->updt_id, os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.updt_task =
    reqinfo->updt_task,
    os.updt_applctx = reqinfo->updt_applctx, os.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].id > 0))
    JOIN (os)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into order_sentence2",serrmsg)
  ENDIF
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = addingoscnt)
   SET lt.active_ind = 1, lt.active_status_cd = active_cd, lt.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = tempaddingos->ordersentence[d.seq].
    comment, lt.long_text_id = tempaddingos->ordersentence[d.seq].commentid,
    lt.parent_entity_id = tempaddingos->ordersentence[d.seq].id, lt.parent_entity_name =
    "ORDER_SENTENCE", lt.updt_id = reqinfo->updt_id,
    lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_task = reqinfo->updt_task, lt
    .updt_applctx = reqinfo->updt_applctx,
    lt.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].comment > " "))
    JOIN (lt)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into long_text2",serrmsg)
  ENDIF
  INSERT  FROM pw_comp_os_reltn pw,
    (dummyt d  WITH seq = addingoscnt)
   SET pw.iv_comp_syn_id = tempaddingos->ordersentence[d.seq].synonymid, pw.order_sentence_id =
    tempaddingos->ordersentence[d.seq].id, pw.order_sentence_seq = 0,
    pw.os_display_line = tempaddingos->ordersentence[d.seq].order_sentence_display_line, pw
    .pathway_comp_id = tempaddingos->ordersentence[d.seq].componentid, pw.updt_id = reqinfo->updt_id,
    pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_task = reqinfo->updt_task, pw
    .updt_applctx = reqinfo->updt_applctx,
    pw.updt_cnt = 0
   PLAN (d
    WHERE (tempaddingos->ordersentence[d.seq].id > 0))
    JOIN (pw)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into pw_comp_os_reltn2",serrmsg)
  ENDIF
 ENDIF
 IF (addosdetcnt > 0)
  INSERT  FROM order_sentence_detail osd,
    (dummyt d  WITH seq = addosdetcnt)
   SET osd.default_parent_entity_name =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) ""
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 9))) "CODE_VALUE"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (12)))
     IF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=48)) "RESEARCH_ACCOUNT"
     ELSEIF ((tempaddosdet->fielddetail[d.seq].oe_field_meaning_id=123)) "SCH_BOOK_INSTR"
     ELSE "CODE_VALUE"
     ENDIF
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (8, 13))) "PERSON"
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (10))) "NOMENCLATURE"
    ENDIF
    , osd.default_parent_entity_id =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) 0
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 8, 9, 10, 12,
    13))) tempaddosdet->fielddetail[d.seq].value
    ENDIF
    , osd.field_type_flag = tempaddosdet->fielddetail[d.seq].field_type_flag,
    osd.oe_field_display_value = tempaddosdet->fielddetail[d.seq].display, osd.oe_field_id =
    tempaddosdet->fielddetail[d.seq].oef_id, osd.oe_field_meaning_id = tempaddosdet->fielddetail[d
    .seq].oe_field_meaning_id,
    osd.oe_field_value =
    IF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))) tempaddosdet->fielddetail[d.seq].value
    ELSEIF ((tempaddosdet->fielddetail[d.seq].field_type_flag IN (6, 8, 9, 10, 12,
    13))) 0
    ENDIF
    , osd.order_sentence_id = tempaddosdet->fielddetail[d.seq].sentenceid, osd.sequence =
    tempaddosdet->fielddetail[d.seq].sequence,
    osd.updt_id = reqinfo->updt_id, osd.updt_dt_tm = cnvtdatetime(curdate,curtime3), osd.updt_task =
    reqinfo->updt_task,
    osd.updt_applctx = reqinfo->updt_applctx, osd.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosdet->fielddetail[d.seq].oef_id > 0))
    JOIN (osd)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL logerror("Error inserting into order_sentence_detail",serrmsg)
  ENDIF
 ENDIF
 IF (addosfiltercnt > 0)
  INSERT  FROM order_sentence_filter f,
    (dummyt d  WITH seq = addosfiltercnt)
   SET f.order_sentence_filter_id = tempaddosfilter->filters[d.seq].order_sentence_filter_id, f
    .order_sentence_id = tempaddosfilter->filters[d.seq].sentence_id, f.age_max_value =
    tempaddosfilter->filters[d.seq].age_max_value,
    f.age_min_value = tempaddosfilter->filters[d.seq].age_min_value, f.age_unit_cd = tempaddosfilter
    ->filters[d.seq].age_code_value, f.pma_max_value = tempaddosfilter->filters[d.seq].pma_max_value,
    f.pma_min_value = tempaddosfilter->filters[d.seq].pma_min_value, f.pma_unit_cd = tempaddosfilter
    ->filters[d.seq].pma_code_value, f.weight_max_value = tempaddosfilter->filters[d.seq].
    weight_max_value,
    f.weight_min_value = tempaddosfilter->filters[d.seq].weight_min_value, f.weight_unit_cd =
    tempaddosfilter->filters[d.seq].weight_code_value, f.updt_id = reqinfo->updt_id,
    f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_task = reqinfo->updt_task, f.updt_applctx
     = reqinfo->updt_applctx,
    f.updt_cnt = 0
   PLAN (d
    WHERE (tempaddosfilter->filters[d.seq].order_sentence_filter_id > 0))
    JOIN (f)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (delosfiltercnt > 0)
  DELETE  FROM order_sentence_filter f,
    (dummyt d  WITH seq = delosfiltercnt)
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.order_sentence_filter_id=tempdelosfilter->filters[d.seq].order_sentence_filter_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error deleting from order_sentence_filter")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE populateswapstructure(newsynid,ppid,compid)
   SET swapcnt = (swapcnt+ 1)
   SET stat = alterlist(swap_synonyms->syns,swapcnt)
   SET swap_synonyms->syns[swapcnt].new_syn_id = newsynid
   SET swap_synonyms->syns[swapcnt].pp_id = ppid
   SET swap_synonyms->syns[swapcnt].component_id = compid
 END ;Subroutine
 SUBROUTINE populateversionrequest(ppid,updtcnt,createnewind,testingind)
   SET stat = initrec(newversionrequest)
   SET stat = initrec(newversionreply)
   SET newversionrequest->pathway_catalog_id = ppid
   SET newversionrequest->updt_cnt = updtcnt
   SET newversionrequest->create_new_ind = createnewind
   SET newversionrequest->version_to_testing_ind = testingind
 END ;Subroutine
 SUBROUTINE getcomponentsbyplan(dummyvar)
  SET tempplancount = size(request->power_plans,5)
  IF (tempplancount > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tempplancount)),
     pathway_catalog pw_cat
    PLAN (d)
     JOIN (pw_cat
     WHERE (pw_cat.pathway_catalog_id=temppp->power_plans[d.seq].power_plan_id)
      AND pw_cat.type_mean="PATHWAY")
    DETAIL
     temppp->power_plans[d.seq].multi_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tempplancount)),
     (dummyt d2  WITH seq = 1),
     pw_cat_reltn pcr,
     pathway_comp pc
    PLAN (d
     WHERE maxrec(d2,size(temppp->power_plans[d.seq].components,5))
      AND (temppp->power_plans[d.seq].multi_ind=1))
     JOIN (d2)
     JOIN (pcr
     WHERE (pcr.pw_cat_s_id=temppp->power_plans[d.seq].power_plan_id))
     JOIN (pc
     WHERE pc.pathway_catalog_id=pcr.pw_cat_t_id
      AND (pc.pathway_uuid=temppp->power_plans[d.seq].components[d2.seq].uuid))
    DETAIL
     temppp->power_plans[d.seq].components[d2.seq].component_id = pc.pathway_comp_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tempplancount)),
     (dummyt d2  WITH seq = 1),
     pathway_comp pc
    PLAN (d
     WHERE maxrec(d2,size(temppp->power_plans[d.seq].components,5))
      AND (temppp->power_plans[d.seq].multi_ind=0))
     JOIN (d2)
     JOIN (pc
     WHERE (pc.pathway_catalog_id=temppp->power_plans[d.seq].power_plan_id)
      AND (pc.pathway_uuid=temppp->power_plans[d.seq].components[d2.seq].uuid))
    DETAIL
     temppp->power_plans[d.seq].components[d2.seq].component_id = pc.pathway_comp_id
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE removeallos(compid)
   SET delsentcnt = (delsentcnt+ 1)
   SET stat = alterlist(del_os_reltn->reltns,delsentcnt)
   SET del_os_reltn->reltns[delsentcnt].component_id = compid
 END ;Subroutine
 SUBROUTINE populatesentencestructure(planindex,compindex)
  SET ossyncnt = size(request->power_plans[planindex].components[compindex].order_sentences,5)
  FOR (oindex = 1 TO ossyncnt)
    SET synosid = 0.0
    SELECT INTO "nl:"
     tempid = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      synosid = cnvtreal(tempid)
     WITH nocounter
    ;end select
    SET addsynoscnt = (addsynoscnt+ 1)
    SET stat = alterlist(tempaddsynos->ordersentence,addsynoscnt)
    SET tempaddsynos->ordersentence[addsynoscnt].id = synosid
    SET tempaddsynos->ordersentence[addsynoscnt].order_sentence_display_line = request->power_plans[
    planindex].components[compindex].order_sentences[oindex].order_sentence_display_line
    SET tempaddsynos->ordersentence[addsynoscnt].os_oe_format_id = request->power_plans[planindex].
    components[compindex].order_sentences[oindex].os_oe_format_id
    SET tempaddsynos->ordersentence[addsynoscnt].componentid = temppp->power_plans[planindex].
    components[compindex].component_id
    SET tempaddsynos->ordersentence[addsynoscnt].powerplanid = request->power_plans[planindex].
    power_plan_id
    SET tempaddsynos->ordersentence[addsynoscnt].sequence = request->power_plans[planindex].
    components[compindex].order_sentences[oindex].sequence
    SET tempaddsynos->ordersentence[addsynoscnt].usage_flag = request->power_plans[planindex].
    components[compindex].order_sentences[oindex].usage_flag
    IF (validate(request->power_plans[planindex].components[compindex].order_sentences[oindex].
     rx_type_mean))
     SET tempaddsynos->ordersentence[addsynoscnt].rx_type_mean = request->power_plans[planindex].
     components[compindex].order_sentences[oindex].rx_type_mean
    ENDIF
    IF ((request->power_plans[planindex].components[compindex].order_sentences[oindex].comment > " ")
    )
     SET tempaddsynos->ordersentence[addsynoscnt].comment = request->power_plans[planindex].
     components[compindex].order_sentences[oindex].comment
     SELECT INTO "nl:"
      tempid = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       tempaddsynos->ordersentence[addsynoscnt].commentid = cnvtreal(tempid)
      WITH nocounter
     ;end select
    ENDIF
    CALL populatesentencedetails(planindex,compindex,oindex,synosid)
    CALL populatesynosfilters(planindex,compindex,oindex,synosid)
  ENDFOR
 END ;Subroutine
 SUBROUTINE populatesentencedetails(planindex,compindex,osindex,sentid)
   SET ossyndetcnt = size(request->power_plans[planindex].components[compindex].order_sentences[
    osindex].details,5)
   IF (ossyndetcnt > 0)
    SET highseq = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = ossyndetcnt),
      order_entry_fields oef
     PLAN (d)
      JOIN (oef
      WHERE (oef.oe_field_id=request->power_plans[planindex].components[compindex].order_sentences[
      osindex].details[d.seq].oef_id))
     DETAIL
      addosdetcnt = (addosdetcnt+ 1), stat = alterlist(tempaddosdet->fielddetail,addosdetcnt),
      tempaddosdet->fielddetail[addosdetcnt].display = request->power_plans[planindex].components[
      compindex].order_sentences[osindex].details[d.seq].display,
      tempaddosdet->fielddetail[addosdetcnt].field_type_flag = oef.field_type_flag, tempaddosdet->
      fielddetail[addosdetcnt].oe_field_meaning_id = oef.oe_field_meaning_id, tempaddosdet->
      fielddetail[addosdetcnt].oef_id = request->power_plans[planindex].components[compindex].
      order_sentences[osindex].details[d.seq].oef_id,
      tempaddosdet->fielddetail[addosdetcnt].powerplanid = request->power_plans[planindex].
      power_plan_id, tempaddosdet->fielddetail[addosdetcnt].sentenceid = sentid, tempaddosdet->
      fielddetail[addosdetcnt].sequence = request->power_plans[planindex].components[compindex].
      order_sentences[osindex].details[d.seq].sequence,
      tempaddosdet->fielddetail[addosdetcnt].value = request->power_plans[planindex].components[
      compindex].order_sentences[osindex].details[d.seq].value
      IF ((request->power_plans[planindex].components[compindex].order_sentences[osindex].details[d
      .seq].sequence > highseq))
       highseq = request->power_plans[planindex].components[compindex].order_sentences[osindex].
       details[d.seq].sequence
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (validate(request->power_plans[planindex].components[compindex].order_sentences[osindex].
    intermittent_ind))
    IF ((request->power_plans[planindex].components[compindex].order_sentences[osindex].usage_flag=1)
    )
     IF ((request->power_plans[planindex].components[compindex].order_sentences[osindex].
     intermittent_ind > 0))
      SET addosdetcnt = (addosdetcnt+ 1)
      SET stat = alterlist(tempaddosdet->fielddetail,addosdetcnt)
      SET tempaddosdet->fielddetail[addosdetcnt].field_type_flag = 1
      SET tempaddosdet->fielddetail[addosdetcnt].oe_field_meaning_id =
      intermittent_oe_field_meaning_id
      SET tempaddosdet->fielddetail[addosdetcnt].oef_id = intermittent_oe_field_id
      SET tempaddosdet->fielddetail[addosdetcnt].powerplanid = request->power_plans[planindex].
      power_plan_id
      SET tempaddosdet->fielddetail[addosdetcnt].sentenceid = sentid
      SET tempaddosdet->fielddetail[addosdetcnt].sequence = (highseq+ 1)
      IF ((request->power_plans[planindex].components[compindex].order_sentences[osindex].
      intermittent_ind=1))
       SET tempaddosdet->fielddetail[addosdetcnt].display = "Intermittent"
       SET tempaddosdet->fielddetail[addosdetcnt].value = 3
      ELSE
       SET tempaddosdet->fielddetail[addosdetcnt].display = "Continuous"
       SET tempaddosdet->fielddetail[addosdetcnt].value = 2
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populatesynosfilters(i,j,k,sentid)
  SET osfiltercnt = size(request->power_plans[i].components[j].order_sentences[k].filters,5)
  IF (osfiltercnt > 0)
   FOR (m = 1 TO osfiltercnt)
     IF ((((request->power_plans[i].components[j].order_sentences[k].filters[m].age_code_value > 0))
      OR ((((request->power_plans[i].components[j].order_sentences[k].filters[m].pma_code_value > 0))
      OR ((request->power_plans[i].components[j].order_sentences[k].filters[m].weight_code_value > 0)
     )) )) )
      SET addosfiltercnt = (addosfiltercnt+ 1)
      SET temp = size(tempaddosfilter->filters,5)
      SET stat = alterlist(tempaddosfilter->filters,(addosfiltercnt+ temp))
      SELECT INTO "nl:"
       tempid = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        osfilterid = cnvtreal(tempid)
       WITH nocounter
      ;end select
      SET tempaddosfilter->filters[addosfiltercnt].order_sentence_filter_id = osfilterid
      SET tempaddosfilter->filters[addosfiltercnt].sentence_id = sentid
      SET tempaddosfilter->filters[addosfiltercnt].age_min_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].age_min_value
      SET tempaddosfilter->filters[addosfiltercnt].age_max_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].age_max_value
      SET tempaddosfilter->filters[addosfiltercnt].age_code_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].age_code_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_min_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].pma_min_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_max_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].pma_max_value
      SET tempaddosfilter->filters[addosfiltercnt].pma_code_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].pma_code_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_min_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].weight_min_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_max_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].weight_max_value
      SET tempaddosfilter->filters[addosfiltercnt].weight_code_value = request->power_plans[i].
      components[j].order_sentences[k].filters[m].weight_code_value
     ELSEIF ((request->power_plans[i].components[j].order_sentences[k].filters[m].
     order_sentence_filter_id > 0)
      AND (request->power_plans[i].components[j].order_sentences[k].filters[m].age_code_value=0)
      AND (request->power_plans[i].components[j].order_sentences[k].filters[m].pma_code_value=0)
      AND (request->power_plans[i].components[j].order_sentences[k].filters[m].weight_code_value=0))
      SET delosfiltercnt = (delosfiltercnt+ 1)
      SET temp = size(tempdelosfilter->filters,5)
      SET stat = alterlist(tempdelosfilter->filters,(delosfiltercnt+ temp))
      SET tempdelosfilter->filters[delosfiltercnt].order_sentence_filter_id = request->power_plans[i]
      .components[j].order_sentences[k].filters[m].order_sentence_filter_id
     ENDIF
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE populateingos(planindex,compindex)
  SET ingcnt = size(request->power_plans[planindex].components[compindex].iv_ingredients,5)
  FOR (l = 1 TO ingcnt)
    SET addingoscnt = (addingoscnt+ 1)
    SET stat = alterlist(tempaddingos->ordersentence,addingoscnt)
    SELECT INTO "nl:"
     tempid = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      ingosid = cnvtreal(tempid)
     WITH nocounter
    ;end select
    SET tempaddingos->ordersentence[addingoscnt].id = ingosid
    SET tempaddingos->ordersentence[addingoscnt].componentid = temppp->power_plans[planindex].
    components[compindex].component_id
    SET tempaddingos->ordersentence[addingoscnt].order_sentence_display_line = request->power_plans[
    planindex].components[compindex].iv_ingredients[l].iv_order_sentence.order_sentence_display_line
    SET tempaddingos->ordersentence[addingoscnt].order_sentence_id = request->power_plans[planindex].
    components[compindex].iv_ingredients[l].iv_order_sentence.order_sentence_id
    SET tempaddingos->ordersentence[addingoscnt].os_oe_format_id = request->power_plans[planindex].
    components[compindex].iv_ingredients[l].iv_order_sentence.os_oe_format_id
    SET tempaddingos->ordersentence[addingoscnt].powerplanid = request->power_plans[planindex].
    power_plan_id
    SET tempaddingos->ordersentence[addingoscnt].synonymid = request->power_plans[planindex].
    components[compindex].iv_ingredients[l].synonym_id
    IF ((request->power_plans[planindex].components[compindex].iv_ingredients[l].iv_order_sentence.
    comment > " "))
     SET tempaddingos->ordersentence[addingoscnt].comment = request->power_plans[planindex].
     components[compindex].iv_ingredients[l].iv_order_sentence.comment
     SELECT INTO "nl:"
      tempid = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       tempaddingos->ordersentence[addingoscnt].commentid = cnvtreal(tempid)
      WITH nocounter
     ;end select
    ENDIF
    CALL populateingosdet(planindex,compindex,l,ingosid)
  ENDFOR
 END ;Subroutine
 SUBROUTINE populateingosdet(planindex,compindex,ingindex,sentid)
  SET ingdetcnt = size(request->power_plans[planindex].components[compindex].iv_ingredients[ingindex]
   .iv_order_sentence.details,5)
  IF (ingdetcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = ingdetcnt),
     order_entry_fields oef
    PLAN (d)
     JOIN (oef
     WHERE (oef.oe_field_id=request->power_plans[planindex].components[compindex].iv_ingredients[
     ingindex].iv_order_sentence.details[d.seq].oef_id))
    DETAIL
     addosdetcnt = (addosdetcnt+ 1), stat = alterlist(tempaddosdet->fielddetail,addosdetcnt),
     tempaddosdet->fielddetail[addosdetcnt].componentid = temppp->power_plans[planindex].components[
     compindex].component_id,
     tempaddosdet->fielddetail[addosdetcnt].display = request->power_plans[planindex].components[
     compindex].iv_ingredients[ingindex].iv_order_sentence.details[d.seq].display, tempaddosdet->
     fielddetail[addosdetcnt].oef_id = request->power_plans[planindex].components[compindex].
     iv_ingredients[ingindex].iv_order_sentence.details[d.seq].oef_id, tempaddosdet->fielddetail[
     addosdetcnt].powerplanid = request->power_plans[planindex].power_plan_id,
     tempaddosdet->fielddetail[addosdetcnt].sentenceid = sentid, tempaddosdet->fielddetail[
     addosdetcnt].value = request->power_plans[planindex].components[compindex].iv_ingredients[
     ingindex].iv_order_sentence.details[d.seq].value, tempaddosdet->fielddetail[addosdetcnt].
     oe_field_meaning_id = oef.oe_field_meaning_id,
     tempaddosdet->fielddetail[addosdetcnt].field_type_flag = oef.field_type_flag, tempaddosdet->
     fielddetail[addosdetcnt].sequence = request->power_plans[planindex].components[compindex].
     iv_ingredients[ingindex].iv_order_sentence.details[d.seq].sequence
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
