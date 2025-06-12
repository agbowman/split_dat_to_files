CREATE PROGRAM dcp_get_pathway:dba
 RECORD reply(
   1 person_id = f8
   1 pathway_cnt = i4
   1 qual_pathway[*]
     2 pathway_id = f8
     2 pathway_catalog_id = f8
     2 pw_cat_version = i4
     2 description = vc
     2 pw_status_cd = f8
     2 pw_status_disp = vc
     2 pw_status_mean = c12
     2 status_dt_tm = dq8
     2 status_prsnl_name = vc
     2 age_units_cd = f8
     2 age_units_disp = vc
     2 age_units_mean = c12
     2 pw_forms_ref_id = f8
     2 comp_forms_ref_id = f8
     2 restrict_comp_add_ind = i2
     2 restrict_tf_add_ind = i2
     2 restrict_cc_add_ind = i2
     2 order_dt_tm = dq8
     2 started_ind = i2
     2 start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
     2 ended_ind = i2
     2 actual_end_dt_tm = dq8
     2 discontinued_ind = i2
     2 dc_reason_cd = f8
     2 dc_reason_disp = vc
     2 dc_reason_mean = c12
     2 dc_text_id = f8
     2 dc_reason_freetext = vc
     2 long_text_id = f8
     2 comment_text = vc
     2 comment_updt_cnt = i4
     2 active_ind = i2
     2 last_action_sequence = i4
     2 version = i4
     2 version_pw_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
     2 processing_ind = i2
     2 variance_event_cnt = i4
     2 variance_event_list[*]
       3 pw_variance_reltn_id = f8
       3 event_id = f8
       3 event_title_text = vc
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 event_end_dt_tm = dq8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 variance_type_cd = f8
       3 variance_type_disp = vc
       3 variance_type_mean = c12
       3 reason_cd = f8
       3 reason_disp = vc
       3 reason_mean = c12
       3 reason_text_id = f8
       3 reason_text_updt_cnt = i4
       3 reason_text = vc
       3 action_cd = f8
       3 action_disp = vc
       3 action_mean = c12
       3 action_text_id = f8
       3 action_text_updt_cnt = i4
       3 action_text = vc
       3 outcome_operator_cd = f8
       3 result_value = f8
       3 result_units_cd = f8
       3 result_units_disp = vc
       3 result_units_mean = c12
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = c12
       3 updt_cnt = i4
       3 updt_prsnl_id = f8
       3 variance_dt_tm = dq8
     2 time_frame_cnt = i4
     2 qual_time_frame[*]
       3 act_time_frame_id = f8
       3 time_frame_id = f8
       3 sequence = i4
       3 description = vc
       3 duration_qty = i4
       3 age_units_cd = f8
       3 age_units_disp = vc
       3 age_units_mean = c12
       3 calc_start_dt_tm = dq8
       3 actual_start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 actual_end_dt_tm = dq8
       3 continuous_ind = i2
       3 activated_comp_ind = i2
       3 pending_comp_ind = i2
       3 start_ind = i2
       3 end_ind = i2
       3 parent_tf_id = f8
       3 active_ind = i2
       3 updt_cnt = i4
     2 care_category_cnt = i4
     2 qual_care_category[*]
       3 act_care_cat_id = f8
       3 care_category_id = f8
       3 sequence = i4
       3 description = vc
       3 active_ind = i2
       3 restrict_comp_add_ind = i2
       3 comp_add_variance_ind = i2
       3 updt_cnt = i4
     2 relationship_cnt = i4
     2 qual_relationship[*]
       3 relationship_mean = c12
       3 entity_id = f8
       3 entity_display = vc
     2 pw_focus_cnt = i4
     2 qual_pw_focus[*]
       3 act_pw_focus_id = f8
       3 nomenclature_id = f8
       3 vocabulary = vc
       3 principle_type = vc
       3 source_string = vc
       3 status_cd = f8
       3 status_disp = vc
       3 status_mean = c12
       3 status_dt_tm = dq8
       3 status_prsnl_id = f8
       3 pathway_level_ind = i2
       3 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET pwcnt = 0
 SET tfcnt = 0
 SET cccnt = 0
 SET pvcnt = 0
 SET dercnt = 0
 SET pfcnt = 0
 SET echo_label = fillstring(30," ")
 SET idpathway = 0
 SET idlongtext = 0
 SET idtimeframe = 0
 SET idcarecategory = 0
 SET idcomponent = 0
 SET stale_in_min = 0
 IF ((((request->stale_in_min=0)) OR ((request->stale_in_min=null))) )
  SET stale_in_min = 10
 ELSE
  SET stale_in_min = request->stale_in_min
 ENDIF
 SET reply->status_data.status = "F"
 SET cfailed = "F"
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET note_meaning = "NOTE"
 SET order_create_meaning = "ORDER CREATE"
 SET label_meaning = "LABEL"
 SET outcome_create_meaning = "OUTCOME CREA"
 SET task_create_meaning = "TASK CREATE"
 SET pw_text_id = 0
 SET comp_text_id = 0
 SET ent_rel_id = 0
 SET parent_entity_name = fillstring(32," ")
 SET cur_dt_tm = cnvtdatetime(curdate,curtime3)
 SET cur_date_in_min = cnvtmin2(cnvtdate(cur_dt_tm),cnvttime(cur_dt_tm))
 SELECT INTO "nl:"
  pw.pathway_id, check = decode(atf.seq,"t",acc.seq,"c",pvr.seq,
   "v",ppa.seq,"p",pr.seq,"r",
   apf.seq,"f","z")
  FROM pathway pw,
   act_time_frame atf,
   act_care_cat acc,
   pw_variance_reltn pvr,
   clinical_event ce,
   pw_processing_action ppa,
   prsnl pr,
   act_pw_focus apf,
   nomenclature nom,
   (dummyt d  WITH seq = 1)
  PLAN (pw
   WHERE (request->person_id=pw.person_id)
    AND pw.type_mean=null)
   JOIN (d
   WHERE d.seq=1)
   JOIN (((atf
   WHERE atf.pathway_id=pw.pathway_id)
   ) ORJOIN ((((acc
   WHERE acc.pathway_id=pw.pathway_id)
   ) ORJOIN ((((pvr
   WHERE pvr.pathway_id=pw.pathway_id
    AND pvr.active_ind=1)
   JOIN (ce
   WHERE ((ce.event_id=pvr.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")) OR (ce.event_id=pvr.event_id
    AND ce.event_id=0)) )
   ) ORJOIN ((((ppa
   WHERE ppa.pathway_id=pw.pathway_id
    AND ppa.processing_updt_cnt > pw.updt_cnt)
   ) ORJOIN ((((pr
   WHERE pr.person_id=pw.status_prsnl_id)
   ) ORJOIN ((apf
   WHERE apf.pathway_id=pw.pathway_id
    AND apf.active_ind=1)
   JOIN (nom
   WHERE nom.nomenclature_id=apf.nomenclature_id)
   )) )) )) )) ))
  ORDER BY pw.pathway_id
  HEAD REPORT
   pwcnt = 0, tfcnt = 0, cccnt = 0,
   pvcnt = 0, pfcnt = 0, reply->person_id = request->person_id
  HEAD pw.pathway_id
   tfcnt = 0, cccnt = 0, pvcnt = 0,
   pfcnt = 0, pwcnt = (pwcnt+ 1)
   IF (pwcnt > size(reply->qual_pathway,5))
    stat = alterlist(reply->qual_pathway,(pwcnt+ 10))
   ENDIF
   reply->qual_pathway[pwcnt].pathway_id = pw.pathway_id, reply->qual_pathway[pwcnt].
   pathway_catalog_id = pw.pathway_catalog_id, reply->qual_pathway[pwcnt].pw_cat_version = pw
   .pw_cat_version,
   reply->qual_pathway[pwcnt].description = pw.description, reply->qual_pathway[pwcnt].pw_status_cd
    = pw.pw_status_cd, reply->qual_pathway[pwcnt].status_dt_tm = pw.status_dt_tm,
   reply->qual_pathway[pwcnt].age_units_cd = pw.age_units_cd, reply->qual_pathway[pwcnt].
   pw_forms_ref_id = pw.pw_forms_ref_id, reply->qual_pathway[pwcnt].comp_forms_ref_id = pw
   .comp_forms_ref_id,
   reply->qual_pathway[pwcnt].restrict_comp_add_ind = pw.restrict_comp_add_ind, reply->qual_pathway[
   pwcnt].restrict_tf_add_ind = pw.restrict_tf_add_ind, reply->qual_pathway[pwcnt].
   restrict_cc_add_ind = pw.restrict_cc_add_ind,
   reply->qual_pathway[pwcnt].started_ind = pw.started_ind, reply->qual_pathway[pwcnt].start_dt_tm =
   cnvtdatetime(pw.start_dt_tm), reply->qual_pathway[pwcnt].order_dt_tm = cnvtdatetime(pw.order_dt_tm
    ),
   reply->qual_pathway[pwcnt].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm), reply->qual_pathway[
   pwcnt].ended_ind = pw.ended_ind, reply->qual_pathway[pwcnt].actual_end_dt_tm = cnvtdatetime(pw
    .actual_end_dt_tm),
   reply->qual_pathway[pwcnt].discontinued_ind = pw.discontinued_ind, reply->qual_pathway[pwcnt].
   dc_reason_cd = pw.dc_reason_cd, reply->qual_pathway[pwcnt].dc_text_id = pw.dc_text_id,
   reply->qual_pathway[pwcnt].long_text_id = pw.long_text_id, reply->qual_pathway[pwcnt].active_ind
    = pw.active_ind, reply->qual_pathway[pwcnt].last_action_sequence = pw.last_action_seq,
   reply->qual_pathway[pwcnt].version = pw.version, reply->qual_pathway[pwcnt].version_pw_id = pw
   .version_pathway_id, reply->qual_pathway[pwcnt].beg_effective_dt_tm = cnvtdatetime(pw
    .beg_effective_dt_tm),
   reply->qual_pathway[pwcnt].end_effective_dt_tm = cnvtdatetime(pw.end_effective_dt_tm), reply->
   qual_pathway[pwcnt].updt_cnt = pw.updt_cnt, reply->qual_pathway[pwcnt].processing_ind = 0
  DETAIL
   IF (check="t")
    tfcnt = (tfcnt+ 1)
    IF (tfcnt > size(reply->qual_pathway[pwcnt].qual_time_frame,5))
     stat = alterlist(reply->qual_pathway[pwcnt].qual_time_frame,(tfcnt+ 10))
    ENDIF
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].act_time_frame_id = atf.act_time_frame_id,
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].time_frame_id = atf.time_frame_id, reply->
    qual_pathway[pwcnt].qual_time_frame[tfcnt].sequence = atf.sequence,
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].description = atf.description, reply->
    qual_pathway[pwcnt].qual_time_frame[tfcnt].duration_qty = atf.duration_qty, reply->qual_pathway[
    pwcnt].qual_time_frame[tfcnt].age_units_cd = atf.age_units_cd,
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].calc_start_dt_tm = cnvtdatetime(atf
     .calc_start_dt_tm), reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].actual_start_dt_tm =
    cnvtdatetime(atf.actual_start_dt_tm), reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].
    calc_end_dt_tm = cnvtdatetime(atf.calc_end_dt_tm),
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].actual_end_dt_tm = cnvtdatetime(atf
     .actual_end_dt_tm), reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].continuous_ind = atf
    .continuous_ind, reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].activated_comp_ind = 0,
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].pending_comp_ind = 0, reply->qual_pathway[pwcnt
    ].qual_time_frame[tfcnt].start_ind = atf.start_ind, reply->qual_pathway[pwcnt].qual_time_frame[
    tfcnt].end_ind = atf.end_ind,
    reply->qual_pathway[pwcnt].qual_time_frame[tfcnt].parent_tf_id = atf.parent_tf_id, reply->
    qual_pathway[pwcnt].qual_time_frame[tfcnt].active_ind = atf.active_ind, reply->qual_pathway[pwcnt
    ].qual_time_frame[tfcnt].updt_cnt = atf.updt_cnt
   ELSEIF (check="c")
    cccnt = (cccnt+ 1)
    IF (cccnt > size(reply->qual_pathway[pwcnt].qual_care_category,5))
     stat = alterlist(reply->qual_pathway[pwcnt].qual_care_category,(cccnt+ 10))
    ENDIF
    reply->qual_pathway[pwcnt].qual_care_category[cccnt].act_care_cat_id = acc.act_care_cat_id, reply
    ->qual_pathway[pwcnt].qual_care_category[cccnt].care_category_id = acc.care_category_id, reply->
    qual_pathway[pwcnt].qual_care_category[cccnt].sequence = acc.sequence,
    reply->qual_pathway[pwcnt].qual_care_category[cccnt].description = acc.description, reply->
    qual_pathway[pwcnt].qual_care_category[cccnt].active_ind = acc.active_ind, reply->qual_pathway[
    pwcnt].qual_care_category[cccnt].restrict_comp_add_ind = acc.restrict_comp_add_ind,
    reply->qual_pathway[pwcnt].qual_care_category[cccnt].comp_add_variance_ind = acc
    .comp_add_variance_ind, reply->qual_pathway[pwcnt].qual_care_category[cccnt].updt_cnt = acc
    .updt_cnt
   ELSEIF (check="v")
    pvcnt = (pvcnt+ 1)
    IF (pvcnt > size(reply->qual_pathway[pwcnt].variance_event_list,5))
     stat = alterlist(reply->qual_pathway[pwcnt].variance_event_list,(pvcnt+ 10))
    ENDIF
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].pw_variance_reltn_id = pvr
    .pw_variance_reltn_id, reply->qual_pathway[pwcnt].variance_event_list[pvcnt].event_id = pvr
    .event_id, reply->qual_pathway[pwcnt].variance_event_list[pvcnt].event_title_text = ce
    .event_title_text,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].valid_from_dt_tm = cnvtdatetime(ce
     .valid_from_dt_tm), reply->qual_pathway[pwcnt].variance_event_list[pvcnt].valid_until_dt_tm =
    cnvtdatetime(ce.valid_until_dt_tm), reply->qual_pathway[pwcnt].variance_event_list[pvcnt].
    event_end_dt_tm = cnvtdatetime(ce.event_end_dt_tm),
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].parent_entity_id = pvr.parent_entity_id,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].parent_entity_name = pvr.parent_entity_name,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].variance_type_cd = pvr.variance_type_cd,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].reason_cd = pvr.reason_cd, reply->
    qual_pathway[pwcnt].variance_event_list[pvcnt].reason_text_id = pvr.reason_text_id, reply->
    qual_pathway[pwcnt].variance_event_list[pvcnt].action_cd = pvr.action_cd,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].action_text_id = pvr.action_text_id, reply
    ->qual_pathway[pwcnt].variance_event_list[pvcnt].outcome_operator_cd = pvr.outcome_operator_cd,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].result_value = pvr.result_value,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].result_units_cd = pvr.result_units_cd,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].result_status_cd = ce.result_status_cd,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].updt_cnt = pvr.updt_cnt,
    reply->qual_pathway[pwcnt].variance_event_list[pvcnt].updt_prsnl_id = pvr.updt_id, reply->
    qual_pathway[pwcnt].variance_event_list[pvcnt].variance_dt_tm = cnvtdatetime(pvr.variance_dt_tm)
   ELSEIF (check="p")
    IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
    stale_in_min) > cur_date_in_min))
     reply->qual_pathway[pwcnt].processing_ind = 1
    ENDIF
   ELSEIF (check="r")
    reply->qual_pathway[pwcnt].status_prsnl_name = pr.name_full_formatted
   ELSEIF (check="f")
    pfcnt = (pfcnt+ 1)
    IF (pfcnt > size(reply->qual_pathway[pwcnt].qual_pw_focus,5))
     stat = alterlist(reply->qual_pathway[pwcnt].qual_pw_focus,(pfcnt+ 10))
    ENDIF
    reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].act_pw_focus_id = apf.act_pw_focus_id, reply->
    qual_pathway[pwcnt].qual_pw_focus[pfcnt].nomenclature_id = apf.nomenclature_id, reply->
    qual_pathway[pwcnt].qual_pw_focus[pfcnt].principle_type = uar_get_code_meaning(nom
     .principle_type_cd),
    reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].vocabulary = uar_get_code_meaning(nom
     .source_vocabulary_cd), reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].source_string = nom
    .source_string, reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].status_cd = apf.status_cd,
    reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].status_dt_tm = apf.status_dt_tm, reply->
    qual_pathway[pwcnt].qual_pw_focus[pfcnt].status_prsnl_id = apf.status_prsnl_id, reply->
    qual_pathway[pwcnt].qual_pw_focus[pfcnt].pathway_level_ind = apf.pathway_level_ind,
    reply->qual_pathway[pwcnt].qual_pw_focus[pfcnt].sequence = apf.sequence
   ENDIF
  FOOT  pw.pathway_id
   stat = alterlist(reply->qual_pathway[pwcnt].variance_event_list,pvcnt), reply->qual_pathway[pwcnt]
   .variance_event_cnt = pvcnt, stat = alterlist(reply->qual_pathway[pwcnt].qual_time_frame,tfcnt),
   reply->qual_pathway[pwcnt].time_frame_cnt = tfcnt, stat = alterlist(reply->qual_pathway[pwcnt].
    qual_care_category,cccnt), reply->qual_pathway[pwcnt].care_category_cnt = cccnt,
   stat = alterlist(reply->qual_pathway[pwcnt].qual_pw_focus,pfcnt), reply->qual_pathway[pwcnt].
   pw_focus_cnt = pfcnt
  FOOT REPORT
   stat = alterlist(reply->qual_pathway,pwcnt)
 ;end select
 SET reply->pathway_cnt = pwcnt WITH nocounter, outerjoin = d
 IF (pwcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  FROM pw_processing_action ppa,
   pathway_catalog pc,
   (dummyt d  WITH seq = 1),
   pathway p
  PLAN (ppa
   WHERE (ppa.person_id=request->person_id)
    AND ppa.processing_updt_cnt=0)
   JOIN (pc
   WHERE pc.pathway_catalog_id=ppa.pathway_catalog_id)
   JOIN (d)
   JOIN (p
   WHERE p.pathway_id=ppa.pathway_id)
  DETAIL
   IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
   stale_in_min) > cur_date_in_min))
    pwcnt = (pwcnt+ 1)
    IF (pwcnt > size(reply->qual_pathway,5))
     stat = alterlist(reply->qual_pathway,(pwcnt+ 5))
    ENDIF
    reply->qual_pathway[pwcnt].pathway_id = ppa.pathway_id, reply->qual_pathway[pwcnt].
    pathway_catalog_id = pc.pathway_catalog_id, reply->qual_pathway[pwcnt].description = pc
    .description,
    reply->qual_pathway[pwcnt].processing_ind = 1, reply->qual_pathway[pwcnt].active_ind = 1
   ENDIF
  WITH outerjoin = d, dontexist
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(reply->qual_pathway,pwcnt)
  SET reply->pathway_cnt = pwcnt
 ENDIF
 FOR (x = 1 TO pwcnt)
   IF ((((reply->qual_pathway[x].long_text_id > 0)) OR ((reply->qual_pathway[x].dc_text_id > 0))) )
    SELECT INTO "nl:"
     lt.long_text_id
     FROM long_text lt
     WHERE (((lt.long_text_id=reply->qual_pathway[x].long_text_id)) OR ((lt.long_text_id=reply->
     qual_pathway[x].dc_text_id)))
      AND lt.parent_entity_name="PATHWAY"
     DETAIL
      IF ((reply->qual_pathway[x].long_text_id=lt.long_text_id)
       AND lt.long_text_id > 0)
       reply->qual_pathway[x].comment_text = lt.long_text, reply->qual_pathway[x].comment_updt_cnt =
       lt.updt_cnt
      ELSEIF ((reply->qual_pathway[x].dc_text_id=lt.long_text_id)
       AND lt.long_text_id > 0)
       reply->qual_pathway[x].dc_reason_freetext = lt.long_text
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (x = 1 TO pwcnt)
  SET vcnt = size(reply->qual_pathway[x].variance_event_list,5)
  FOR (y = 1 TO vcnt)
    IF ((((reply->qual_pathway[x].variance_event_list[y].reason_text_id > 0)) OR ((reply->
    qual_pathway[x].variance_event_list[y].action_text_id > 0))) )
     SELECT INTO "nl:"
      lt.long_text_id
      FROM long_text lt
      WHERE (((lt.long_text_id=reply->qual_pathway[x].variance_event_list[y].reason_text_id)) OR ((lt
      .long_text_id=reply->qual_pathway[x].variance_event_list[y].action_text_id)))
      DETAIL
       IF ((reply->qual_pathway[x].variance_event_list[y].reason_text_id=lt.long_text_id)
        AND lt.long_text_id > 0)
        reply->qual_pathway[x].variance_event_list[y].reason_text = lt.long_text, reply->
        qual_pathway[x].variance_event_list[y].reason_text_updt_cnt = lt.updt_cnt
       ELSEIF ((reply->qual_pathway[x].variance_event_list[y].action_text_id=lt.long_text_id)
        AND lt.long_text_id > 0)
        reply->qual_pathway[x].variance_event_list[y].action_text = lt.long_text, reply->
        qual_pathway[x].variance_event_list[y].action_text_updt_cnt = lt.updt_cnt
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  d.seq, der.dcp_entity_reltn_id, nc.nomenclature_id
  FROM (dummyt d  WITH seq = value(pwcnt)),
   dcp_entity_reltn der,
   nomenclature nc
  PLAN (d)
   JOIN (der
   WHERE (der.entity1_id=reply->qual_pathway[d.seq].pathway_id)
    AND der.entity_reltn_mean="PW/DIAGN")
   JOIN (nc
   WHERE nc.nomenclature_id=der.entity2_id)
  ORDER BY d.seq
  HEAD d.seq
   dercnt = 0
  HEAD der.dcp_entity_reltn_id
   dercnt = (dercnt+ 1)
   IF (dercnt > size(reply->qual_pathway[d.seq].qual_relationship,5))
    stat = alterlist(reply->qual_pathway[d.seq].qual_relationship,(dercnt+ 10))
   ENDIF
   reply->qual_pathway[d.seq].qual_relationship[dercnt].relationship_mean = der.entity_reltn_mean,
   reply->qual_pathway[d.seq].qual_relationship[dercnt].entity_id = der.entity2_id, reply->
   qual_pathway[d.seq].qual_relationship[dercnt].entity_display = nc.source_string
  DETAIL
   col + 0
  FOOT  d.seq
   stat = alterlist(reply->qual_pathway[d.seq].qual_relationship,dercnt), reply->qual_pathway[d.seq].
   relationship_cnt = dercnt
  WITH nocounter
 ;end select
#exit_script
 SET echo = 0
 IF (echo=1)
  FOR (x = 1 TO reply->pathway_cnt)
    SET echo_label = build("pw",x," ")
    CALL echo(build(echo_label,"pathway_id: ",reply->qual_pathway[x].pathway_id))
    CALL echo(build(echo_label,"description: ",reply->qual_pathway[x].description))
    CALL echo(build(echo_label,"status_cd: ",reply->qual_pathway[x].pw_status_cd))
    CALL echo(build("size-------------- ",reply->qual_pathway[x].variance_event_cnt))
    FOR (y = 1 TO size(reply->qual_pathway[x].variance_event_list,5))
      CALL echo(build("PE_ID---",reply->qual_pathway[x].variance_event_list[y].parent_entity_id))
      CALL echo(build("PE_nm---",reply->qual_pathway[x].variance_event_list[y].parent_entity_name))
      CALL echo(build("VT_CD---",reply->qual_pathway[x].variance_event_list[y].variance_type_cd))
      CALL echo(build("re_CD---",reply->qual_pathway[x].variance_event_list[y].reason_cd))
      CALL echo(build("RTE_ID---",reply->qual_pathway[x].variance_event_list[y].reason_text_id))
      CALL echo(build("RT   ---",reply->qual_pathway[x].variance_event_list[y].reason_text))
      CALL echo(build("ac_cD---",reply->qual_pathway[x].variance_event_list[y].action_cd))
      CALL echo(build("act_ID---",reply->qual_pathway[x].variance_event_list[y].action_text_id))
      CALL echo(build("at-  --",reply->qual_pathway[x].variance_event_list[y].action_text))
      CALL echo(build("out---",reply->qual_pathway[x].variance_event_list[y].outcome_operator_cd))
      CALL echo(build("res---",reply->qual_pathway[x].variance_event_list[y].result_value))
      CALL echo(build("units---",reply->qual_pathway[x].variance_event_list[y].result_units_cd))
      CALL echo(build("resST---",reply->qual_pathway[x].variance_event_list[y].result_status_cd))
      CALL echo(build("upCNT---",reply->qual_pathway[x].variance_event_list[y].updt_cnt))
      CALL echo(build("uprnlID---",reply->qual_pathway[x].variance_event_list[y].updt_prsnl_id))
    ENDFOR
  ENDFOR
 ENDIF
END GO
