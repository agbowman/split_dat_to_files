CREATE PROGRAM dcp_get_plan_activity:dba
 SET modify = predeclare
 RECORD reply(
   1 pwlist[*]
     2 pw_group_nbr = f8
     2 type_mean = c12
     2 pw_group_desc = vc
     2 cross_encntr_ind = i2
     2 version = i4
     2 pathway_catalog_id = f8
     2 pathway_type_cd = f8
     2 pathway_type_disp = c40
     2 pathway_type_mean = c12
     2 pathway_class_cd = f8
     2 pathway_class_disp = c40
     2 pathway_class_mean = c12
     2 display_method_cd = f8
     2 display_method_disp = c40
     2 display_method_mean = c12
     2 phaselist[*]
       3 pathway_id = f8
       3 encntr_id = f8
       3 pw_status_cd = f8
       3 pw_status_disp = c40
       3 pw_status_mean = c12
       3 calc_status_cd = f8
       3 calc_status_disp = c40
       3 calc_status_mean = c12
       3 description = vc
       3 type_mean = c12
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 duration_unit_disp = c40
       3 duration_unit_mean = c12
       3 started_ind = i2
       3 processing_ind = i2
       3 updt_cnt = i4
       3 start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 pathway_catalog_id = f8
       3 order_dt_tm = dq8
       3 time_zero_ind = i2
       3 start_offset_ind = i2
       3 complist[*]
         4 act_pw_comp_id = f8
         4 dcp_clin_cat_cd = f8
         4 dcp_clin_cat_disp = c40
         4 dcp_clin_cat_mean = c12
         4 dcp_clin_sub_cat_cd = f8
         4 dcp_clin_sub_cat_disp = c40
         4 dcp_clin_sub_cat_mean = c12
         4 ocs_clin_cat_cd = f8
         4 ocs_clin_cat_disp = c40
         4 ocs_clin_cat_mean = c12
         4 comp_status_cd = f8
         4 comp_status_disp = c40
         4 comp_status_mean = c12
         4 comp_type_cd = f8
         4 comp_type_disp = c40
         4 comp_type_mean = c12
         4 sequence = i4
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 synonym_id = f8
         4 catalog_cd = f8
         4 catalog_disp = c40
         4 catalog_mean = c12
         4 catalog_type_cd = f8
         4 catalog_type_disp = c40
         4 catalog_type_mean = c12
         4 activity_type_cd = f8
         4 activity_type_disp = c40
         4 activity_type_mean = c12
         4 mnemonic = vc
         4 oe_format_id = f8
         4 rx_mask = i4
         4 linked_to_tf_ind = i2
         4 required_ind = i2
         4 included_ind = i2
         4 activated_ind = i2
         4 persistent_ind = i2
         4 comp_text_id = f8
         4 comp_text = vc
         4 order_sentence_id = f8
         4 processing_ind = i2
         4 updt_cnt = i4
         4 pathway_comp_id = f8
         4 offset_quantity = f8
         4 offset_unit_cd = f8
         4 offset_unit_disp = c40
         4 offset_unit_mean = c12
         4 ordsentlist[*]
           5 order_sentence_id = f8
           5 order_sentence_seq = i4
           5 order_sentence_display_line = vc
           5 iv_comp_syn_id = f8
           5 ord_comment_long_text_id = f8
           5 ord_comment_long_text = vc
         4 duration_qty = i4
         4 duration_unit_cd = f8
         4 duration_unit_disp = c40
         4 duration_unit_mean = c12
         4 outcome_catalog_id = f8
         4 outcome_description = vc
         4 outcome_expectation = vc
         4 outcome_type_cd = f8
         4 outcome_type_disp = c40
         4 outcome_type_mean = c12
         4 outcome_status_cd = f8
         4 outcome_status_disp = c40
         4 outcome_status_mean = c12
         4 target_type_cd = f8
         4 target_type_disp = c40
         4 target_type_mean = c12
         4 expand_qty = i4
         4 expand_unit_cd = f8
         4 expand_unit_disp = c40
         4 expand_unit_mean = c12
         4 outcome_start_dt_tm = dq8
         4 outcome_end_dt_tm = dq8
         4 outcome_updt_cnt = i4
         4 outcome_event_cd = f8
         4 time_zero_offset_qty = f8
         4 time_zero_mean = c12
         4 time_zero_offset_unit_cd = f8
         4 time_zero_offset_unit_disp = c40
         4 time_zero_offset_unit_mean = c12
         4 time_zero_active_ind = i2
         4 task_assay_cd = f8
         4 reference_task_id = f8
         4 orderable_type_flag = i2
         4 comp_label = vc
         4 result_type_cd = f8
         4 result_type_disp = c40
         4 result_type_mean = c12
       3 phasereltnlist[*]
         4 pathway_s_id = f8
         4 pathway_t_id = f8
         4 type_mean = c12
       3 compgrouplist[*]
         4 act_pw_comp_g_id = f8
         4 type_mean = c12
         4 memberlist[*]
           5 act_pw_comp_id = f8
           5 pw_comp_seq = i4
     2 planevidencelist[*]
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 pathway_comp_id = f8
       3 evidence_type_mean = c12
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 pathway_catalog_id = f8
   1 variancelist[*]
     2 variance_reltn_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 event_id = f8
     2 variance_type_cd = f8
     2 variance_type_disp = c40
     2 variance_type_mean = c12
     2 action_cd = f8
     2 action_disp = c40
     2 action_mean = c12
     2 action_text_id = f8
     2 action_text = vc
     2 action_text_updt_cnt = i4
     2 reason_cd = f8
     2 reason_disp = c40
     2 reason_mean = c12
     2 reason_text_id = f8
     2 reason_text = vc
     2 reason_text_updt_cnt = i4
     2 variance_updt_cnt = i4
     2 active_ind = i2
     2 note_text_id = f8
     2 note_text = vc
     2 note_text_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 planlist[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 type_mean = c12
     2 cross_encntr_ind = i2
     2 version = i4
     2 pathway_catalog_id = f8
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 display_method_cd = f8
     2 focus_ind = i2
     2 status_ind = i2
     2 phaselist[*]
       3 pathway_id = f8
       3 description = vc
       3 pw_status_cd = f8
       3 calc_status_cd = f8
       3 encntr_id = f8
       3 type_mean = c12
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 started_ind = i2
       3 updt_cnt = i4
       3 start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 order_dt_tm = dq8
       3 pathway_catalog_id = f8
 )
 RECORD temp2(
   1 phaselist[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 group_type_mean = c12
     2 cross_encntr_ind = i2
     2 version = i4
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 display_method_cd = f8
     2 pathway_id = f8
     2 description = vc
     2 pw_status_cd = f8
     2 calc_status_cd = f8
     2 encntr_id = f8
     2 type_mean = c12
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 started_ind = i2
     2 updt_cnt = i4
     2 start_dt_tm = dq8
     2 calc_end_dt_tm = dq8
     2 order_dt_tm = dq8
     2 pathway_catalog_id = f8
     2 pw_cat_group_id = f8
     2 processing_ind = i2
     2 phasereltnlist[*]
       3 pathway_s_id = f8
       3 pathway_t_id = f8
       3 type_mean = c12
     2 compgrouplist[*]
       3 act_pw_comp_g_id = f8
       3 type_mean = c12
       3 memberlist[*]
         4 act_pw_comp_id = f8
         4 pw_comp_seq = i4
     2 planevidencelist[*]
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 pathway_comp_id = f8
       3 evidence_type_mean = c12
       3 pw_evidence_reltn_id = f8
       3 evidence_locator = vc
       3 pathway_catalog_id = f8
 )
 RECORD temp3(
   1 phaselist[*]
     2 pathway_id = f8
     2 encntr_id = f8
     2 pathway_catalog_id = f8
     2 pw_group_nbr = f8
 )
 RECORD temp4(
   1 oclist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 ocs_clin_cat_cd = f8
     2 comp_status_cd = f8
     2 comp_type_cd = f8
     2 sequence = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 ref_prnt_ent_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 rx_mask = i4
     2 linked_to_tf_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 activated_ind = i2
     2 order_sentence_id = f8
     2 updt_cnt = i4
     2 sort_cd = f8
     2 orderable_type_flag = i2
     2 comp_label = vc
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 ordsentlist[*]
       3 order_sentence_id = f8
       3 order_sentence_seq = i4
       3 order_sentence_display_line = vc
       3 iv_comp_syn_id = f8
       3 ord_comment_long_text_id = f8
       3 ord_comment_long_text = vc
   1 orlist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 ocs_clin_cat_cd = f8
     2 comp_status_cd = f8
     2 comp_type_cd = f8
     2 sequence = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 ref_prnt_ent_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 rx_mask = i4
     2 linked_to_tf_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 activated_ind = i2
     2 order_sentence_id = f8
     2 order_exists = i2
     2 order_status_cd = f8
     2 activated_dt_tm = dq8
     2 updt_cnt = i4
     2 sort_cd = f8
     2 orderable_type_flag = i2
     2 comp_label = vc
     2 offset_quantity = f8
     2 offset_unit_cd = f8
   1 ltlist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 comp_type_cd = f8
     2 sequence = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 persistent_ind = i2
     2 comp_text_id = f8
     2 comp_text = vc
     2 updt_cnt = i4
     2 sort_cd = f8
     2 comp_label = vc
   1 outcomecatlist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 comp_status_cd = f8
     2 comp_type_cd = f8
     2 sequence = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 ref_prnt_ent_id = f8
     2 linked_to_tf_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 activated_ind = i2
     2 updt_cnt = i4
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 outcome_description = vc
     2 outcome_expectation = vc
     2 outcome_type_cd = f8
     2 outcome_event_cd = f8
     2 target_type_cd = f8
     2 expand_qty = i4
     2 expand_unit_cd = f8
     2 sort_cd = f8
     2 task_assay_cd = f8
     2 reference_task_id = f8
     2 comp_label = vc
     2 result_type_cd = f8
     2 offset_quantity = f8
     2 offset_unit_cd = f8
   1 outcomeactlist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 act_pw_comp_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 comp_status_cd = f8
     2 comp_type_cd = f8
     2 sequence = i4
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 ref_prnt_ent_id = f8
     2 linked_to_tf_ind = i2
     2 required_ind = i2
     2 included_ind = i2
     2 activated_ind = i2
     2 activated_dt_tm = dq8
     2 updt_cnt = i4
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 outcome_description = vc
     2 outcome_expectation = vc
     2 outcome_type_cd = f8
     2 outcome_status_cd = f8
     2 target_type_cd = f8
     2 expand_qty = i4
     2 expand_unit_cd = f8
     2 outcome_start_dt_tm = dq8
     2 outcome_end_dt_tm = dq8
     2 outcome_updt_cnt = i4
     2 outcome_event_cd = f8
     2 outcome_exists = i2
     2 sort_cd = f8
     2 task_assay_cd = f8
     2 reference_task_id = f8
     2 comp_label = vc
     2 result_type_cd = f8
     2 offset_quantity = f8
     2 offset_unit_cd = f8
 )
 RECORD temp5(
   1 list[*]
     2 id = f8
     2 id2 = f8
 )
 RECORD temp8(
   1 phaselist[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 comprlist[*]
       3 source_id = f8
       3 target_id = f8
       3 type_mean = c12
       3 offset_qty = f8
       3 offset_unit_cd = f8
       3 active_ind = i2
 )
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE pathway_where = vc WITH noconstant(fillstring(100," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE occnt = i4 WITH noconstant(0)
 DECLARE orcnt = i4 WITH noconstant(0)
 DECLARE oscnt = i4 WITH noconstant(0)
 DECLARE ltcnt = i4 WITH noconstant(0)
 DECLARE outcatcnt = i4 WITH noconstant(0)
 DECLARE outactcnt = i4 WITH noconstant(0)
 DECLARE cursize = i4 WITH noconstant(0)
 DECLARE total = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE phasecnt = i4 WITH noconstant(0)
 DECLARE plancnt = i4 WITH noconstant(0)
 DECLARE itemcnt = i4 WITH noconstant(0)
 DECLARE stale_in_min = i4 WITH noconstant(0)
 DECLARE cur_date_in_min = i4 WITH noconstant(0)
 DECLARE cur_dt_tm = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(0)
 DECLARE stop = i4 WITH noconstant(0)
 DECLARE found = c1 WITH noconstant("N")
 IF ((((request->stale_in_min=0)) OR ((request->stale_in_min=null))) )
  SET stale_in_min = 10
 ELSE
  SET stale_in_min = request->stale_in_min
 ENDIF
 SET cur_date_in_min = cnvtmin2(cnvtdate(cur_dt_tm),cnvttime(cur_dt_tm))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE pw_planned_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE pw_init_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE pw_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE note_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"NOTE"))
 DECLARE outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE failed_create = f8 WITH constant(uar_get_code_by("MEANING",16789,"FAILEDCREATE"))
 DECLARE activated = f8 WITH constant(uar_get_code_by("MEANING",16789,"ACTIVATED"))
 DECLARE outcome_activated_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"ACTIVATED"))
 DECLARE outcome_completed_cd = f8 WITH constant(uar_get_code_by("MEANING",30182,"COMPLETED"))
 DECLARE clin_cat_display_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT"))
 DECLARE query_cnt = i4 WITH constant(cnvtint(size(request->querylist,5)))
 DECLARE access_cnt = i4 WITH constant(cnvtint(size(request->accesslist,5)))
 SELECT INTO "nl:"
  ppa.pathway_id
  FROM pw_processing_action ppa
  PLAN (ppa
   WHERE (ppa.person_id=request->person_id)
    AND ppa.processing_updt_cnt=0
    AND  NOT ( EXISTS (
   (SELECT
    pw.pathway_id
    FROM pathway pw
    WHERE pw.pathway_id=ppa.pathway_id))))
  ORDER BY ppa.pathway_id
  HEAD REPORT
   pwcnt = 0
  DETAIL
   IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
   stale_in_min) > cur_date_in_min))
    IF (access_cnt > 0)
     found = "N", idx = locateval(idx,1,access_cnt,ppa.encntr_id,request->accesslist[idx].encntr_id)
     IF (idx != 0)
      found = "Y"
     ENDIF
    ENDIF
    IF (((access_cnt=0) OR (found="Y")) )
     pwcnt = (pwcnt+ 1)
     IF (pwcnt > size(temp3->phaselist,5))
      stat = alterlist(temp3->phaselist,(pwcnt+ 5))
     ENDIF
     temp3->phaselist[pwcnt].pathway_id = ppa.pathway_id, temp3->phaselist[pwcnt].encntr_id = ppa
     .encntr_id, temp3->phaselist[pwcnt].pathway_catalog_id = ppa.pathway_catalog_id,
     temp3->phaselist[pwcnt].pw_group_nbr = ppa.pw_group_nbr
    ENDIF
   ENDIF
  FOOT REPORT
   IF (pwcnt > 0)
    stat = alterlist(temp3->phaselist,pwcnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (access_cnt > 0)
  SET high = access_cnt
  SET pathway_where = concat(trim(pathway_where),
   "  expand(num,1,high,pw.encntr_id,request->accessList[num]->encntr_id)")
 ELSE
  SET pathway_where = concat(trim(pathway_where)," (pw.person_id = request->person_id)")
 ENDIF
 SET pathway_where = concat(trim(pathway_where)," AND (pw.pw_group_nbr > 0)")
 SELECT INTO "nl:"
  pw.pathway_id, pw.person_id, pw.encntr_id
  FROM pathway pw
  PLAN (pw
   WHERE parser(trim(pathway_where)))
  ORDER BY pw.pw_group_nbr, pw.pathway_id
  HEAD REPORT
   plancnt = 0
  HEAD pw.pw_group_nbr
   phasecnt = 0, plancnt = (plancnt+ 1)
   IF (plancnt > size(temp->planlist,5))
    stat = alterlist(temp->planlist,(plancnt+ 10))
   ENDIF
   temp->planlist[plancnt].pw_group_nbr = pw.pw_group_nbr, temp->planlist[plancnt].pw_group_desc =
   trim(pw.pw_group_desc), temp->planlist[plancnt].type_mean =
   IF (pw.type_mean="PHASE") "PATHWAY"
   ELSE "CAREPLAN"
   ENDIF
   ,
   temp->planlist[plancnt].cross_encntr_ind = pw.cross_encntr_ind, temp->planlist[plancnt].version =
   pw.pw_cat_version, temp->planlist[plancnt].pathway_catalog_id = pw.pw_cat_group_id,
   temp->planlist[plancnt].pathway_type_cd = pw.pathway_type_cd, temp->planlist[plancnt].
   pathway_class_cd = pw.pathway_class_cd, temp->planlist[plancnt].display_method_cd = pw
   .display_method_cd,
   temp->planlist[plancnt].focus_ind = 0, temp->planlist[plancnt].status_ind = 0
  HEAD pw.pathway_id
   phasecnt = (phasecnt+ 1)
   IF (phasecnt > size(temp->planlist[plancnt].phaselist,5))
    stat = alterlist(temp->planlist[plancnt].phaselist,(phasecnt+ 10))
   ENDIF
   temp->planlist[plancnt].phaselist[phasecnt].pathway_id = pw.pathway_id, temp->planlist[plancnt].
   phaselist[phasecnt].description = trim(pw.description), temp->planlist[plancnt].phaselist[phasecnt
   ].pw_status_cd = pw.pw_status_cd,
   temp->planlist[plancnt].phaselist[phasecnt].calc_status_cd =
   IF (pw.calc_end_dt_tm != null
    AND pw.calc_end_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pw.pw_status_cd=pw_init_cd) pw_completed_cd
   ELSE pw.pw_status_cd
   ENDIF
   , temp->planlist[plancnt].phaselist[phasecnt].encntr_id = pw.encntr_id, temp->planlist[plancnt].
   phaselist[phasecnt].type_mean = pw.type_mean,
   temp->planlist[plancnt].phaselist[phasecnt].duration_qty = pw.duration_qty, temp->planlist[plancnt
   ].phaselist[phasecnt].duration_unit_cd = pw.duration_unit_cd, temp->planlist[plancnt].phaselist[
   phasecnt].started_ind = pw.started_ind,
   temp->planlist[plancnt].phaselist[phasecnt].updt_cnt = pw.updt_cnt, temp->planlist[plancnt].
   phaselist[phasecnt].start_dt_tm = pw.start_dt_tm, temp->planlist[plancnt].phaselist[phasecnt].
   calc_end_dt_tm = pw.calc_end_dt_tm,
   temp->planlist[plancnt].phaselist[phasecnt].order_dt_tm = pw.order_dt_tm, temp->planlist[plancnt].
   phaselist[phasecnt].pathway_catalog_id = pw.pathway_catalog_id
   IF (pw.pw_status_cd=pw_planned_cd)
    temp->planlist[plancnt].status_ind = 1
   ENDIF
  FOOT  pw.pathway_id
   dummy = 0
  FOOT  pw.pw_group_nbr
   stat = alterlist(temp->planlist[plancnt].phaselist,phasecnt)
  FOOT REPORT
   stat = alterlist(temp->planlist,plancnt)
  WITH nocounter
 ;end select
 IF (query_cnt > 0
  AND value(size(temp->planlist,5)) > 0)
  SELECT INTO "nl:"
   pathway_id = temp->planlist[d1.seq].phaselist[d2.seq].pathway_id
   FROM (dummyt d1  WITH seq = value(size(temp->planlist,5))),
    (dummyt d2  WITH seq = value(5)),
    (dummyt d3  WITH seq = value(size(request->querylist,5)))
   PLAN (d3)
    JOIN (d1
    WHERE maxrec(d2,size(temp->planlist[d1.seq].phaselist,5)) > 0)
    JOIN (d2
    WHERE (request->querylist[d3.seq].encntr_id=temp->planlist[d1.seq].phaselist[d2.seq].encntr_id))
   ORDER BY pathway_id
   HEAD REPORT
    dummy = 0
   HEAD pathway_id
    temp->planlist[d1.seq].focus_ind = 1
   FOOT  pathway_id
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ELSE
  FOR (i = 1 TO value(size(temp->planlist,5)))
    SET temp->planlist[i].focus_ind = 1
  ENDFOR
 ENDIF
 SET total = 0
 FOR (i = 1 TO value(size(temp->planlist,5)))
  SET phasecnt = value(size(temp->planlist[i].phaselist,5))
  IF ((temp->planlist[i].focus_ind=1))
   SET stat = alterlist(temp2->phaselist,(total+ phasecnt))
   FOR (j = 1 TO phasecnt)
     SET total = (total+ 1)
     SET temp2->phaselist[total].pw_group_nbr = temp->planlist[i].pw_group_nbr
     SET temp2->phaselist[total].pw_group_desc = temp->planlist[i].pw_group_desc
     SET temp2->phaselist[total].group_type_mean = temp->planlist[i].type_mean
     SET temp2->phaselist[total].cross_encntr_ind = temp->planlist[i].cross_encntr_ind
     SET temp2->phaselist[total].version = temp->planlist[i].version
     SET temp2->phaselist[total].pathway_type_cd = temp->planlist[i].pathway_type_cd
     SET temp2->phaselist[total].pathway_class_cd = temp->planlist[i].pathway_class_cd
     SET temp2->phaselist[total].display_method_cd = temp->planlist[i].display_method_cd
     SET temp2->phaselist[total].pw_cat_group_id = temp->planlist[i].pathway_catalog_id
     SET temp2->phaselist[total].pathway_id = temp->planlist[i].phaselist[j].pathway_id
     SET temp2->phaselist[total].description = temp->planlist[i].phaselist[j].description
     SET temp2->phaselist[total].pw_status_cd = temp->planlist[i].phaselist[j].pw_status_cd
     SET temp2->phaselist[total].calc_status_cd = temp->planlist[i].phaselist[j].calc_status_cd
     SET temp2->phaselist[total].encntr_id = temp->planlist[i].phaselist[j].encntr_id
     SET temp2->phaselist[total].type_mean = temp->planlist[i].phaselist[j].type_mean
     SET temp2->phaselist[total].duration_qty = temp->planlist[i].phaselist[j].duration_qty
     SET temp2->phaselist[total].duration_unit_cd = temp->planlist[i].phaselist[j].duration_unit_cd
     SET temp2->phaselist[total].started_ind = temp->planlist[i].phaselist[j].started_ind
     SET temp2->phaselist[total].updt_cnt = temp->planlist[i].phaselist[j].updt_cnt
     SET temp2->phaselist[total].start_dt_tm = temp->planlist[i].phaselist[j].start_dt_tm
     SET temp2->phaselist[total].calc_end_dt_tm = temp->planlist[i].phaselist[j].calc_end_dt_tm
     SET temp2->phaselist[total].order_dt_tm = temp->planlist[i].phaselist[j].order_dt_tm
     SET temp2->phaselist[total].pathway_catalog_id = temp->planlist[i].phaselist[j].
     pathway_catalog_id
   ENDFOR
  ELSEIF ((temp->planlist[i].status_ind=1))
   FOR (j = 1 TO phasecnt)
     IF ((temp->planlist[i].phaselist[j].pw_status_cd=pw_planned_cd))
      SET total = (total+ 1)
      SET stat = alterlist(temp2->phaselist,total)
      SET temp2->phaselist[total].pw_group_nbr = temp->planlist[i].pw_group_nbr
      SET temp2->phaselist[total].pw_group_desc = temp->planlist[i].pw_group_desc
      SET temp2->phaselist[total].group_type_mean = temp->planlist[i].type_mean
      SET temp2->phaselist[total].cross_encntr_ind = temp->planlist[i].cross_encntr_ind
      SET temp2->phaselist[total].version = temp->planlist[i].version
      SET temp2->phaselist[total].pathway_type_cd = temp->planlist[i].pathway_type_cd
      SET temp2->phaselist[total].pathway_class_cd = temp->planlist[i].pathway_class_cd
      SET temp2->phaselist[total].display_method_cd = temp->planlist[i].display_method_cd
      SET temp2->phaselist[total].pw_cat_group_id = temp->planlist[i].pathway_catalog_id
      SET temp2->phaselist[total].pathway_id = temp->planlist[i].phaselist[j].pathway_id
      SET temp2->phaselist[total].description = temp->planlist[i].phaselist[j].description
      SET temp2->phaselist[total].pw_status_cd = temp->planlist[i].phaselist[j].pw_status_cd
      SET temp2->phaselist[total].calc_status_cd = temp->planlist[i].phaselist[j].calc_status_cd
      SET temp2->phaselist[total].encntr_id = temp->planlist[i].phaselist[j].encntr_id
      SET temp2->phaselist[total].type_mean = temp->planlist[i].phaselist[j].type_mean
      SET temp2->phaselist[total].duration_qty = temp->planlist[i].phaselist[j].duration_qty
      SET temp2->phaselist[total].duration_unit_cd = temp->planlist[i].phaselist[j].duration_unit_cd
      SET temp2->phaselist[total].started_ind = temp->planlist[i].phaselist[j].started_ind
      SET temp2->phaselist[total].updt_cnt = temp->planlist[i].phaselist[j].updt_cnt
      SET temp2->phaselist[total].start_dt_tm = temp->planlist[i].phaselist[j].start_dt_tm
      SET temp2->phaselist[total].calc_end_dt_tm = temp->planlist[i].phaselist[j].calc_end_dt_tm
      SET temp2->phaselist[total].order_dt_tm = temp->planlist[i].phaselist[j].order_dt_tm
      SET temp2->phaselist[total].pathway_catalog_id = temp->planlist[i].phaselist[j].
      pathway_catalog_id
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 FREE RECORD temp
 IF (value(size(temp2->phaselist,5)) > 0)
  SET high = value(size(temp2->phaselist,5))
  SELECT INTO "nl:"
   FROM pathway_reltn pr
   PLAN (pr
    WHERE expand(num,1,high,pr.pathway_s_id,temp2->phaselist[num].pathway_id)
     AND pr.active_ind=1)
   ORDER BY pr.pathway_s_id
   HEAD REPORT
    pwrcnt = 0, idx = 0
   HEAD pr.pathway_s_id
    pwrcnt = 0, idx = locateval(idx,1,high,pr.pathway_s_id,temp2->phaselist[idx].pathway_id)
   DETAIL
    pwrcnt = (pwrcnt+ 1)
    IF (pwrcnt > size(temp2->phaselist[idx].phasereltnlist,5))
     stat = alterlist(temp2->phaselist[idx].phasereltnlist,(pwrcnt+ 10))
    ENDIF
    temp2->phaselist[idx].phasereltnlist[pwrcnt].pathway_s_id = pr.pathway_s_id, temp2->phaselist[idx
    ].phasereltnlist[pwrcnt].pathway_t_id = pr.pathway_t_id, temp2->phaselist[idx].phasereltnlist[
    pwrcnt].type_mean = pr.type_mean
   FOOT  pr.pathway_s_id
    IF (pwrcnt > 0)
     stat = alterlist(temp2->phaselist[idx].phasereltnlist,pwrcnt)
    ENDIF
   FOOT REPORT
    pwrcnt = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pw_processing_action ppa
   PLAN (ppa
    WHERE expand(num,1,high,ppa.pathway_id,temp2->phaselist[num].pathway_id))
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,high,ppa.pathway_id,temp2->phaselist[idx].pathway_id)
    IF ((ppa.processing_updt_cnt > temp2->phaselist[idx].updt_cnt))
     IF (((cnvtmin2(cnvtdate(ppa.processing_start_dt_tm),cnvttime(ppa.processing_start_dt_tm))+
     stale_in_min) > cur_date_in_min))
      temp2->phaselist[idx].processing_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET high = value(size(temp2->phaselist,5))
  SELECT INTO "nl:"
   FROM act_pw_comp_g apcg
   PLAN (apcg
    WHERE expand(num,1,high,apcg.pathway_id,temp2->phaselist[num].pathway_id))
   ORDER BY apcg.pathway_id, apcg.act_pw_comp_g_id, apcg.pw_comp_seq
   HEAD REPORT
    idx = 0
   HEAD apcg.pathway_id
    gcnt = 0, idx = locateval(idx,1,high,apcg.pathway_id,temp2->phaselist[idx].pathway_id)
   HEAD apcg.act_pw_comp_g_id
    ccnt = 0, gcnt = (gcnt+ 1)
    IF (gcnt > size(temp2->phaselist[idx].compgrouplist,5))
     stat = alterlist(temp2->phaselist[idx].compgrouplist,(gcnt+ 10))
    ENDIF
    temp2->phaselist[idx].compgrouplist[gcnt].act_pw_comp_g_id = apcg.act_pw_comp_g_id, temp2->
    phaselist[idx].compgrouplist[gcnt].type_mean = apcg.type_mean
   DETAIL
    ccnt = (ccnt+ 1)
    IF (ccnt > size(temp2->phaselist[idx].compgrouplist[gcnt].memberlist,5))
     stat = alterlist(temp2->phaselist[idx].compgrouplist[gcnt].memberlist,(ccnt+ 10))
    ENDIF
    temp2->phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].act_pw_comp_id = apcg.act_pw_comp_id,
    temp2->phaselist[idx].compgrouplist[gcnt].memberlist[ccnt].pw_comp_seq = apcg.pw_comp_seq
   FOOT  apcg.act_pw_comp_g_id
    IF (ccnt > 0)
     stat = alterlist(temp2->phaselist[idx].compgrouplist[gcnt].memberlist,ccnt)
    ENDIF
   FOOT  apcg.pathway_id
    IF (gcnt > 0)
     stat = alterlist(temp2->phaselist[idx].compgrouplist,gcnt)
    ENDIF
   FOOT REPORT
    cnt = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pw_group_nbr = temp2->phaselist[d1.seq].pw_group_nbr, pathway_id = temp2->phaselist[d1.seq].
   pathway_id, per.pathway_catalog_id,
   per.type_mean, pw_group_cat_id = temp2->phaselist[d1.seq].pw_cat_group_id, pw_cat_id = temp2->
   phaselist[d1.seq].pathway_catalog_id
   FROM (dummyt d1  WITH seq = value(size(temp2->phaselist,5))),
    pw_evidence_reltn per
   PLAN (d1)
    JOIN (per
    WHERE per.pathway_catalog_id IN (temp2->phaselist[d1.seq].pathway_catalog_id, temp2->phaselist[d1
    .seq].pw_cat_group_id))
   ORDER BY pw_group_nbr, pathway_id, per.type_mean
   HEAD REPORT
    dummy = 0
   HEAD pw_group_nbr
    foundref = "N", foundlink = "N"
   HEAD pathway_id
    evidencecnt = 0
   DETAIL
    IF (((foundref="N"
     AND per.type_mean="REFTEXT"
     AND per.pathway_catalog_id=pw_group_cat_id) OR (((foundlink="N"
     AND ((per.type_mean="ZYNX") OR (per.type_mean="URL"))
     AND per.pathway_catalog_id=pw_group_cat_id) OR (per.pathway_catalog_id=pw_cat_id)) )) )
     evidencecnt = (evidencecnt+ 1)
     IF (evidencecnt > size(temp2->phaselist[d1.seq].planevidencelist,5))
      stat = alterlist(temp2->phaselist[d1.seq].planevidencelist,(evidencecnt+ 5))
     ENDIF
     temp2->phaselist[d1.seq].planevidencelist[evidencecnt].dcp_clin_cat_cd = per.dcp_clin_cat_cd,
     temp2->phaselist[d1.seq].planevidencelist[evidencecnt].dcp_clin_sub_cat_cd = per
     .dcp_clin_sub_cat_cd, temp2->phaselist[d1.seq].planevidencelist[evidencecnt].pathway_comp_id =
     per.pathway_comp_id,
     temp2->phaselist[d1.seq].planevidencelist[evidencecnt].evidence_type_mean = per.type_mean, temp2
     ->phaselist[d1.seq].planevidencelist[evidencecnt].pw_evidence_reltn_id = per
     .pw_evidence_reltn_id, temp2->phaselist[d1.seq].planevidencelist[evidencecnt].evidence_locator
      = per.evidence_locator,
     temp2->phaselist[d1.seq].planevidencelist[evidencecnt].pathway_catalog_id = per
     .pathway_catalog_id
     IF (foundref="N"
      AND per.type_mean="REFTEXT"
      AND per.pathway_catalog_id=pw_group_cat_id)
      foundref = "Y"
     ELSEIF (foundlink="N"
      AND ((per.type_mean="ZYNX") OR (per.type_mean="URL"))
      AND per.pathway_catalog_id=pw_group_cat_id)
      foundlink = "Y"
     ENDIF
    ENDIF
   FOOT  pathway_id
    stat = alterlist(temp2->phaselist[d1.seq].planevidencelist,evidencecnt)
   FOOT  pw_group_nbr
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
  SET high = value(size(temp2->phaselist,5))
  SELECT INTO "nl:"
   FROM act_pw_comp apc
   PLAN (apc
    WHERE expand(num,1,high,apc.pathway_id,temp2->phaselist[num].pathway_id)
     AND apc.active_ind=1)
   ORDER BY apc.pathway_id, apc.act_pw_comp_id
   HEAD REPORT
    idx = 0, occnt = 0, orcnt = 0,
    ltcnt = 0, outcatcnt = 0, outactcnt = 0
   HEAD apc.pathway_id
    idx = locateval(idx,1,high,apc.pathway_id,temp2->phaselist[idx].pathway_id), comp_r_cnt = 0
   HEAD apc.act_pw_comp_id
    IF ((temp2->phaselist[idx].processing_ind=0))
     IF (apc.comp_type_cd=order_comp_cd
      AND apc.comp_status_cd != activated)
      occnt = (occnt+ 1), cursize = value(size(temp4->oclist,5))
      IF (occnt > cursize)
       stat = alterlist(temp4->oclist,(occnt+ 50))
      ENDIF
      temp4->oclist[occnt].pw_group_nbr = temp2->phaselist[idx].pw_group_nbr, temp4->oclist[occnt].
      pathway_id = apc.pathway_id, temp4->oclist[occnt].act_pw_comp_id = apc.act_pw_comp_id,
      temp4->oclist[occnt].pathway_comp_id = apc.pathway_comp_id, temp4->oclist[occnt].
      dcp_clin_cat_cd = apc.dcp_clin_cat_cd, temp4->oclist[occnt].dcp_clin_sub_cat_cd = apc
      .dcp_clin_sub_cat_cd,
      temp4->oclist[occnt].comp_status_cd = apc.comp_status_cd, temp4->oclist[occnt].comp_type_cd =
      apc.comp_type_cd, temp4->oclist[occnt].sequence = apc.sequence,
      temp4->oclist[occnt].parent_entity_name = apc.parent_entity_name, temp4->oclist[occnt].
      parent_entity_id = apc.parent_entity_id, temp4->oclist[occnt].ref_prnt_ent_id = apc
      .ref_prnt_ent_id,
      temp4->oclist[occnt].linked_to_tf_ind = apc.linked_to_tf_ind, temp4->oclist[occnt].required_ind
       = apc.required_ind, temp4->oclist[occnt].included_ind = apc.included_ind,
      temp4->oclist[occnt].activated_ind = apc.activated_ind, temp4->oclist[occnt].order_sentence_id
       = apc.order_sentence_id, temp4->oclist[occnt].updt_cnt = apc.updt_cnt,
      temp4->oclist[occnt].comp_label = apc.comp_label, temp4->oclist[occnt].offset_quantity = apc
      .offset_quantity, temp4->oclist[occnt].offset_unit_cd = apc.offset_unit_cd
      IF ((temp2->phaselist[idx].display_method_cd IN (clin_cat_display_method_cd, 0)))
       temp4->oclist[occnt].sort_cd = apc.dcp_clin_cat_cd
      ENDIF
     ELSEIF (apc.comp_type_cd=order_comp_cd
      AND apc.comp_status_cd=activated)
      orcnt = (orcnt+ 1), cursize = value(size(temp4->orlist,5))
      IF (orcnt > cursize)
       stat = alterlist(temp4->orlist,(orcnt+ 50))
      ENDIF
      temp4->orlist[orcnt].pw_group_nbr = temp2->phaselist[idx].pw_group_nbr, temp4->orlist[orcnt].
      pathway_id = apc.pathway_id, temp4->orlist[orcnt].act_pw_comp_id = apc.act_pw_comp_id,
      temp4->orlist[orcnt].pathway_comp_id = apc.pathway_comp_id, temp4->orlist[orcnt].
      dcp_clin_cat_cd = apc.dcp_clin_cat_cd, temp4->orlist[orcnt].dcp_clin_sub_cat_cd = apc
      .dcp_clin_sub_cat_cd,
      temp4->orlist[orcnt].comp_status_cd = apc.comp_status_cd, temp4->orlist[orcnt].comp_type_cd =
      apc.comp_type_cd, temp4->orlist[orcnt].sequence = apc.sequence,
      temp4->orlist[orcnt].parent_entity_name = apc.parent_entity_name, temp4->orlist[orcnt].
      parent_entity_id = apc.parent_entity_id, temp4->orlist[orcnt].ref_prnt_ent_id = apc
      .ref_prnt_ent_id,
      temp4->orlist[orcnt].linked_to_tf_ind = apc.linked_to_tf_ind, temp4->orlist[orcnt].required_ind
       = apc.required_ind, temp4->orlist[orcnt].included_ind = apc.included_ind,
      temp4->orlist[orcnt].activated_ind = apc.activated_ind, temp4->orlist[orcnt].activated_dt_tm =
      cnvtdatetime(apc.activated_dt_tm), temp4->orlist[orcnt].order_sentence_id = apc
      .order_sentence_id,
      temp4->orlist[orcnt].order_exists = 0, temp4->orlist[orcnt].updt_cnt = apc.updt_cnt, temp4->
      orlist[orcnt].comp_label = apc.comp_label,
      temp4->orlist[orcnt].offset_quantity = apc.offset_quantity, temp4->orlist[orcnt].offset_unit_cd
       = apc.offset_unit_cd
      IF ((temp2->phaselist[idx].display_method_cd IN (clin_cat_display_method_cd, 0)))
       temp4->orlist[orcnt].sort_cd = apc.dcp_clin_cat_cd
      ENDIF
     ELSEIF (apc.comp_type_cd=note_comp_cd)
      ltcnt = (ltcnt+ 1), cursize = value(size(temp4->ltlist,5))
      IF (ltcnt > cursize)
       stat = alterlist(temp4->ltlist,(ltcnt+ 50))
      ENDIF
      temp4->ltlist[ltcnt].pw_group_nbr = temp2->phaselist[idx].pw_group_nbr, temp4->ltlist[ltcnt].
      pathway_id = apc.pathway_id, temp4->ltlist[ltcnt].act_pw_comp_id = apc.act_pw_comp_id,
      temp4->ltlist[ltcnt].pathway_comp_id = apc.pathway_comp_id, temp4->ltlist[ltcnt].
      dcp_clin_cat_cd = apc.dcp_clin_cat_cd, temp4->ltlist[ltcnt].dcp_clin_sub_cat_cd = apc
      .dcp_clin_sub_cat_cd,
      temp4->ltlist[ltcnt].comp_type_cd = apc.comp_type_cd, temp4->ltlist[ltcnt].sequence = apc
      .sequence, temp4->ltlist[ltcnt].parent_entity_name = apc.parent_entity_name,
      temp4->ltlist[ltcnt].parent_entity_id = apc.parent_entity_id, temp4->ltlist[ltcnt].
      persistent_ind = apc.persistent_ind, temp4->ltlist[ltcnt].updt_cnt = apc.updt_cnt,
      temp4->ltlist[ltcnt].comp_label = apc.comp_label
      IF ((temp2->phaselist[idx].display_method_cd IN (clin_cat_display_method_cd, 0)))
       temp4->ltlist[ltcnt].sort_cd = apc.dcp_clin_cat_cd
      ENDIF
     ELSEIF (apc.comp_type_cd=outcome_comp_cd
      AND apc.comp_status_cd != activated)
      outcatcnt = (outcatcnt+ 1), cursize = value(size(temp4->outcomecatlist,5))
      IF (outcatcnt > cursize)
       stat = alterlist(temp4->outcomecatlist,(outcatcnt+ 50))
      ENDIF
      temp4->outcomecatlist[outcatcnt].pw_group_nbr = temp2->phaselist[idx].pw_group_nbr, temp4->
      outcomecatlist[outcatcnt].pathway_id = apc.pathway_id, temp4->outcomecatlist[outcatcnt].
      act_pw_comp_id = apc.act_pw_comp_id,
      temp4->outcomecatlist[outcatcnt].pathway_comp_id = apc.pathway_comp_id, temp4->outcomecatlist[
      outcatcnt].dcp_clin_cat_cd = apc.dcp_clin_cat_cd, temp4->outcomecatlist[outcatcnt].
      dcp_clin_sub_cat_cd = apc.dcp_clin_sub_cat_cd,
      temp4->outcomecatlist[outcatcnt].comp_status_cd = apc.comp_status_cd, temp4->outcomecatlist[
      outcatcnt].comp_type_cd = apc.comp_type_cd, temp4->outcomecatlist[outcatcnt].sequence = apc
      .sequence,
      temp4->outcomecatlist[outcatcnt].parent_entity_name = apc.parent_entity_name, temp4->
      outcomecatlist[outcatcnt].parent_entity_id = apc.parent_entity_id, temp4->outcomecatlist[
      outcatcnt].ref_prnt_ent_id = apc.ref_prnt_ent_id,
      temp4->outcomecatlist[outcatcnt].linked_to_tf_ind = apc.linked_to_tf_ind, temp4->
      outcomecatlist[outcatcnt].required_ind = apc.required_ind, temp4->outcomecatlist[outcatcnt].
      included_ind = apc.included_ind,
      temp4->outcomecatlist[outcatcnt].activated_ind = apc.activated_ind, temp4->outcomecatlist[
      outcatcnt].updt_cnt = apc.updt_cnt, temp4->outcomecatlist[outcatcnt].duration_qty = apc
      .duration_qty,
      temp4->outcomecatlist[outcatcnt].duration_unit_cd = apc.duration_unit_cd, temp4->
      outcomecatlist[outcatcnt].comp_label = apc.comp_label, temp4->outcomecatlist[outcatcnt].
      offset_quantity = apc.offset_quantity,
      temp4->outcomecatlist[outcatcnt].offset_unit_cd = apc.offset_unit_cd
      IF ((temp2->phaselist[idx].display_method_cd IN (clin_cat_display_method_cd, 0)))
       temp4->outcomecatlist[outcatcnt].sort_cd = apc.dcp_clin_cat_cd
      ENDIF
     ELSEIF (apc.comp_type_cd=outcome_comp_cd
      AND apc.comp_status_cd=activated)
      outactcnt = (outactcnt+ 1), cursize = value(size(temp4->outcomeactlist,5))
      IF (outactcnt > cursize)
       stat = alterlist(temp4->outcomeactlist,(outactcnt+ 50))
      ENDIF
      temp4->outcomeactlist[outactcnt].pw_group_nbr = temp2->phaselist[idx].pw_group_nbr, temp4->
      outcomeactlist[outactcnt].pathway_id = apc.pathway_id, temp4->outcomeactlist[outactcnt].
      act_pw_comp_id = apc.act_pw_comp_id,
      temp4->outcomeactlist[outactcnt].pathway_comp_id = apc.pathway_comp_id, temp4->outcomeactlist[
      outactcnt].dcp_clin_cat_cd = apc.dcp_clin_cat_cd, temp4->outcomeactlist[outactcnt].
      dcp_clin_sub_cat_cd = apc.dcp_clin_sub_cat_cd,
      temp4->outcomeactlist[outactcnt].comp_status_cd = apc.comp_status_cd, temp4->outcomeactlist[
      outactcnt].comp_type_cd = apc.comp_type_cd, temp4->outcomeactlist[outactcnt].sequence = apc
      .sequence,
      temp4->outcomeactlist[outactcnt].parent_entity_name = apc.parent_entity_name, temp4->
      outcomeactlist[outactcnt].parent_entity_id = apc.parent_entity_id, temp4->outcomeactlist[
      outactcnt].ref_prnt_ent_id = apc.ref_prnt_ent_id,
      temp4->outcomeactlist[outactcnt].linked_to_tf_ind = apc.linked_to_tf_ind, temp4->
      outcomeactlist[outactcnt].required_ind = apc.required_ind, temp4->outcomeactlist[outactcnt].
      included_ind = apc.included_ind,
      temp4->outcomeactlist[outactcnt].activated_ind = apc.activated_ind, temp4->outcomeactlist[
      outactcnt].activated_dt_tm = cnvtdatetime(apc.activated_dt_tm), temp4->outcomeactlist[outactcnt
      ].outcome_exists = 0,
      temp4->outcomeactlist[outactcnt].updt_cnt = apc.updt_cnt, temp4->outcomeactlist[outactcnt].
      duration_qty = apc.duration_qty, temp4->outcomeactlist[outactcnt].duration_unit_cd = apc
      .duration_unit_cd,
      temp4->outcomeactlist[outactcnt].comp_label = apc.comp_label, temp4->outcomeactlist[outactcnt].
      offset_quantity = apc.offset_quantity, temp4->outcomeactlist[outactcnt].offset_unit_cd = apc
      .offset_unit_cd
      IF ((temp2->phaselist[idx].display_method_cd IN (clin_cat_display_method_cd, 0)))
       temp4->outcomeactlist[outactcnt].sort_cd = apc.dcp_clin_cat_cd
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    dummy = 0
   FOOT  apc.act_pw_comp_id
    dummy = 0
   FOOT  apc.pathway_id
    idx = 0
   FOOT REPORT
    IF (occnt > 0)
     stat = alterlist(temp4->oclist,occnt)
    ENDIF
    IF (orcnt > 0)
     stat = alterlist(temp4->orlist,orcnt)
    ENDIF
    IF (ltcnt > 0)
     stat = alterlist(temp4->ltlist,ltcnt)
    ENDIF
    IF (outcatcnt > 0)
     stat = alterlist(temp4->outcomecatlist,outcatcnt)
    ENDIF
    IF (outactcnt > 0)
     stat = alterlist(temp4->outcomeactlist,outactcnt)
    ENDIF
   WITH nocounter
  ;end select
  SET high = value(size(temp4->orlist,5))
  IF (high > 0)
   SELECT INTO "nl:"
    FROM act_pw_comp_r apcr
    PLAN (apcr
     WHERE expand(num,1,high,apcr.act_pw_comp_s_id,temp4->orlist[num].act_pw_comp_id))
    ORDER BY apcr.act_pw_comp_s_id
    HEAD REPORT
     idx = 0, phasecnt = 0
    HEAD apcr.act_pw_comp_s_id
     idx = locateval(idx,1,high,apcr.act_pw_comp_s_id,temp4->orlist[idx].act_pw_comp_id), phasecnt =
     (phasecnt+ 1)
     IF (phasecnt > size(temp8->phaselist,5))
      stat = alterlist(temp8->phaselist,(phasecnt+ 10))
     ENDIF
     temp8->phaselist[phasecnt].pw_group_nbr = temp4->orlist[idx].pw_group_nbr, temp8->phaselist[
     phasecnt].pathway_id = temp4->orlist[idx].pathway_id, comp_r_cnt = 0
    DETAIL
     comp_r_cnt = (comp_r_cnt+ 1)
     IF (comp_r_cnt > size(temp8->phaselist[phasecnt].comprlist,5))
      stat = alterlist(temp8->phaselist[phasecnt].comprlist,(comp_r_cnt+ 10))
     ENDIF
     temp8->phaselist[phasecnt].comprlist[comp_r_cnt].source_id = apcr.act_pw_comp_s_id, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].target_id = apcr.act_pw_comp_t_id, temp8->phaselist[
     phasecnt].comprlist[comp_r_cnt].type_mean = apcr.type_mean,
     temp8->phaselist[phasecnt].comprlist[comp_r_cnt].offset_qty = apcr.offset_quantity, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].offset_unit_cd = apcr.offset_unit_cd, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].active_ind = apcr.active_ind
    FOOT  apcr.act_pw_comp_s_id
     IF (comp_r_cnt > 0)
      stat = alterlist(temp8->phaselist[phasecnt].comprlist,comp_r_cnt)
     ENDIF
    FOOT REPORT
     IF (phasecnt > 0)
      stat = alterlist(temp8->phaselist,phasecnt)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET high = value(size(temp4->oclist,5))
  IF (high > 0)
   SELECT INTO "nl:"
    FROM act_pw_comp_r apcr
    PLAN (apcr
     WHERE expand(num,1,high,apcr.act_pw_comp_s_id,temp4->oclist[num].act_pw_comp_id))
    ORDER BY apcr.act_pw_comp_s_id
    HEAD REPORT
     idx = 0, phasecnt = size(temp8->phaselist,5)
    HEAD apcr.act_pw_comp_s_id
     idx = locateval(idx,1,high,apcr.act_pw_comp_s_id,temp4->oclist[idx].act_pw_comp_id), phasecnt =
     (phasecnt+ 1)
     IF (phasecnt > size(temp8->phaselist,5))
      stat = alterlist(temp8->phaselist,(phasecnt+ 10))
     ENDIF
     temp8->phaselist[phasecnt].pw_group_nbr = temp4->oclist[idx].pw_group_nbr, temp8->phaselist[
     phasecnt].pathway_id = temp4->oclist[idx].pathway_id, comp_r_cnt = 0
    DETAIL
     comp_r_cnt = (comp_r_cnt+ 1)
     IF (comp_r_cnt > size(temp8->phaselist[phasecnt].comprlist,5))
      stat = alterlist(temp8->phaselist[phasecnt].comprlist,(comp_r_cnt+ 10))
     ENDIF
     temp8->phaselist[phasecnt].comprlist[comp_r_cnt].source_id = apcr.act_pw_comp_s_id, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].target_id = apcr.act_pw_comp_t_id, temp8->phaselist[
     phasecnt].comprlist[comp_r_cnt].type_mean = apcr.type_mean,
     temp8->phaselist[phasecnt].comprlist[comp_r_cnt].offset_qty = apcr.offset_quantity, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].offset_unit_cd = apcr.offset_unit_cd, temp8->
     phaselist[phasecnt].comprlist[comp_r_cnt].active_ind = apcr.active_ind
    FOOT  apcr.act_pw_comp_s_id
     IF (comp_r_cnt > 0)
      stat = alterlist(temp8->phaselist[phasecnt].comprlist,comp_r_cnt)
     ENDIF
    FOOT REPORT
     IF (phasecnt > 0)
      stat = alterlist(temp8->phaselist,phasecnt)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(temp4->ltlist,5))
  IF (high <= 1000)
   SET stop = high
  ELSE
   SET stop = 1000
  ENDIF
  WHILE (start <= stop)
    SET max = ((stop - start)+ 1)
    SET stat = alterlist(temp5->list,max)
    FOR (x = 1 TO max)
      SET temp5->list[x].id = temp4->ltlist[((start+ x) - 1)].parent_entity_id
    ENDFOR
    SELECT INTO "nl:"
     FROM long_text lt
     PLAN (lt
      WHERE expand(num,1,max,lt.long_text_id,temp5->list[num].id))
     HEAD REPORT
      idx = 0
     DETAIL
      idx = locateval(idx,start,stop,lt.long_text_id,temp4->ltlist[idx].parent_entity_id), temp4->
      ltlist[idx].comp_text_id = lt.long_text_id, temp4->ltlist[idx].comp_text = trim(lt.long_text)
     FOOT REPORT
      idx = 0
     WITH nocounter
    ;end select
    SET start = (stop+ 1)
    IF ((high <= (stop+ 1000)))
     SET stop = high
    ELSE
     SET stop = (stop+ 1000)
    ENDIF
    SET stat = alterlist(temp5->list,0)
  ENDWHILE
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(temp4->oclist,5))
  IF (high <= 1000)
   SET stop = high
  ELSE
   SET stop = 1000
  ENDIF
  RECORD temp10(
    1 list[*]
      2 ord_comment_long_text_id = f8
      2 ord_comment_long_text = vc
  )
  WHILE (start <= stop)
    SET max = ((stop - start)+ 1)
    SET stat = alterlist(temp5->list,max)
    FOR (x = 1 TO max)
     SET temp5->list[x].id = temp4->oclist[((start+ x) - 1)].ref_prnt_ent_id
     SET temp5->list[x].id2 = temp4->oclist[((start+ x) - 1)].pathway_comp_id
    ENDFOR
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs
     PLAN (ocs
      WHERE expand(num,1,max,ocs.synonym_id,temp5->list[num].id))
     ORDER BY ocs.synonym_id
     HEAD REPORT
      idx = 0
     DETAIL
      idx = locateval(idx,start,stop,ocs.synonym_id,temp4->oclist[idx].ref_prnt_ent_id), temp4->
      oclist[idx].synonym_id = ocs.synonym_id, temp4->oclist[idx].catalog_cd = ocs.catalog_cd,
      temp4->oclist[idx].catalog_type_cd = ocs.catalog_type_cd, temp4->oclist[idx].activity_type_cd
       = ocs.activity_type_cd, temp4->oclist[idx].mnemonic = trim(ocs.mnemonic),
      temp4->oclist[idx].oe_format_id = ocs.oe_format_id, temp4->oclist[idx].ocs_clin_cat_cd = ocs
      .dcp_clin_cat_cd, temp4->oclist[idx].rx_mask = ocs.rx_mask,
      temp4->oclist[idx].orderable_type_flag = ocs.orderable_type_flag, idx2 = idx
      WHILE (idx != 0)
       idx2 = locateval(idx2,(idx+ 1),stop,ocs.synonym_id,temp4->oclist[idx2].ref_prnt_ent_id),
       IF (idx2 != 0)
        idx = idx2, temp4->oclist[idx].synonym_id = ocs.synonym_id, temp4->oclist[idx].catalog_cd =
        ocs.catalog_cd,
        temp4->oclist[idx].catalog_type_cd = ocs.catalog_type_cd, temp4->oclist[idx].activity_type_cd
         = ocs.activity_type_cd, temp4->oclist[idx].mnemonic = trim(ocs.mnemonic),
        temp4->oclist[idx].oe_format_id = ocs.oe_format_id, temp4->oclist[idx].ocs_clin_cat_cd = ocs
        .dcp_clin_cat_cd, temp4->oclist[idx].rx_mask = ocs.rx_mask,
        temp4->oclist[idx].orderable_type_flag = ocs.orderable_type_flag
       ELSE
        idx = idx2
       ENDIF
      ENDWHILE
     FOOT REPORT
      idx = 0
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pw_comp_os_reltn pcor,
      order_sentence os
     PLAN (pcor
      WHERE expand(num,1,max,pcor.pathway_comp_id,temp5->list[num].id2))
      JOIN (os
      WHERE os.order_sentence_id=pcor.order_sentence_id)
     ORDER BY pcor.pathway_comp_id, pcor.order_sentence_seq
     HEAD REPORT
      idx = 0
     HEAD pcor.pathway_comp_id
      osrcnt = 0, idx = locateval(idx,start,stop,pcor.pathway_comp_id,temp4->oclist[idx].
       pathway_comp_id), ltcnt = size(temp10->list,5),
      ltidx = 0
     DETAIL
      osrcnt = (osrcnt+ 1), stat = alterlist(temp4->oclist[idx].ordsentlist,osrcnt), temp4->oclist[
      idx].ordsentlist[osrcnt].order_sentence_id = pcor.order_sentence_id,
      temp4->oclist[idx].ordsentlist[osrcnt].order_sentence_seq = pcor.order_sentence_seq, temp4->
      oclist[idx].ordsentlist[osrcnt].order_sentence_display_line = trim(os
       .order_sentence_display_line), temp4->oclist[idx].ordsentlist[osrcnt].iv_comp_syn_id = pcor
      .iv_comp_syn_id,
      temp4->oclist[idx].ordsentlist[osrcnt].ord_comment_long_text_id = os.ord_comment_long_text_id
      IF (os.ord_comment_long_text_id > 0)
       ltidx = locateval(ltidx,1,ltcnt,os.ord_comment_long_text_id,temp10->list[ltidx].
        ord_comment_long_text_id)
       IF (ltidx=0)
        ltcnt = (ltcnt+ 1), stat = alterlist(temp10->list,ltcnt), temp10->list[ltcnt].
        ord_comment_long_text_id = os.ord_comment_long_text_id
       ENDIF
      ENDIF
      idx2 = idx, idx3 = idx, limit = 0
      WHILE (limit != 1)
       idx2 = locateval(idx2,(idx3+ 1),stop,pcor.pathway_comp_id,temp4->oclist[idx2].pathway_comp_id),
       IF (idx2 != 0)
        idx3 = idx2, stat = alterlist(temp4->oclist[idx2].ordsentlist,osrcnt), temp4->oclist[idx2].
        ordsentlist[osrcnt].order_sentence_id = pcor.order_sentence_id,
        temp4->oclist[idx2].ordsentlist[osrcnt].order_sentence_seq = pcor.order_sentence_seq, temp4->
        oclist[idx2].ordsentlist[osrcnt].order_sentence_display_line = trim(os
         .order_sentence_display_line), temp4->oclist[idx2].ordsentlist[osrcnt].iv_comp_syn_id = pcor
        .iv_comp_syn_id,
        temp4->oclist[idx2].ordsentlist[osrcnt].ord_comment_long_text_id = os
        .ord_comment_long_text_id
       ELSE
        limit = 1
       ENDIF
      ENDWHILE
     FOOT  pcor.pathway_comp_id
      dummy = 0
     FOOT REPORT
      dummy = 0
     WITH nocounter
    ;end select
    SET start = (stop+ 1)
    IF ((high <= (stop+ 1000)))
     SET stop = high
    ELSE
     SET stop = (stop+ 1000)
    ENDIF
    SET stat = alterlist(temp5->list,0)
  ENDWHILE
  IF (value(size(temp10->list,5)) > 0)
   SET num = 0
   SET high = value(size(temp10->list,5))
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,temp10->list[num].ord_comment_long_text_id)
      AND lt.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,temp10->list[idx].ord_comment_long_text_id)
     IF (idx > 0)
      temp10->list[idx].ord_comment_long_text = trim(lt.long_text)
     ENDIF
    FOOT REPORT
     dummy = 0
    WITH nocounter
   ;end select
   FOR (i = 1 TO value(size(temp4->oclist,5)))
     FOR (j = 1 TO value(size(temp4->oclist[i].ordsentlist,5)))
       IF ((temp4->oclist[i].ordsentlist[j].ord_comment_long_text_id > 0))
        FOR (k = 1 TO value(size(temp10->list,5)))
          IF ((temp10->list[k].ord_comment_long_text_id=temp4->oclist[i].ordsentlist[j].
          ord_comment_long_text_id))
           SET temp4->oclist[i].ordsentlist[j].ord_comment_long_text = trim(temp10->list[k].
            ord_comment_long_text)
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(temp4->orlist,5))
  IF (high <= 1000)
   SET stop = high
  ELSE
   SET stop = 1000
  ENDIF
  WHILE (start <= stop)
    SET max = ((stop - start)+ 1)
    SET stat = alterlist(temp5->list,max)
    FOR (x = 1 TO max)
      SET temp5->list[x].id = temp4->orlist[((start+ x) - 1)].parent_entity_id
    ENDFOR
    SELECT INTO "nl:"
     o.order_id
     FROM orders o
     PLAN (o
      WHERE expand(num,1,max,o.order_id,temp5->list[num].id))
     HEAD REPORT
      idx = 0
     DETAIL
      idx = locateval(idx,start,stop,o.order_id,temp4->orlist[idx].parent_entity_id), temp4->orlist[
      idx].catalog_cd = o.catalog_cd, temp4->orlist[idx].catalog_type_cd = o.catalog_type_cd,
      temp4->orlist[idx].activity_type_cd = o.activity_type_cd, temp4->orlist[idx].order_exists = 1,
      temp4->orlist[idx].order_status_cd = o.order_status_cd,
      temp4->orlist[idx].orderable_type_flag = o.orderable_type_flag
     FOOT REPORT
      idx = 0
     WITH nocounter
    ;end select
    IF (locateval(idx,start,stop,0,temp4->orlist[idx].order_exists))
     RECORD temp6(
       1 complist[*]
         2 id = f8
     )
     SET cnt = 0
     FOR (j = start TO stop)
       IF ((temp4->orlist[j].order_exists=0))
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp6->complist,cnt)
        SET temp6->complist[cnt].id = temp4->orlist[j].ref_prnt_ent_id
       ENDIF
     ENDFOR
     SET itemcnt = value(size(temp6->complist,5))
     SET i = 0
     SELECT INTO "nl:"
      ocs.synonym_id, ocs.mnemonic
      FROM order_catalog_synonym ocs
      PLAN (ocs
       WHERE expand(i,1,itemcnt,ocs.synonym_id,temp6->complist[i].id))
      ORDER BY ocs.synonym_id
      HEAD REPORT
       idx = 0
      DETAIL
       idx = locateval(idx,start,stop,ocs.synonym_id,temp4->orlist[idx].ref_prnt_ent_id)
       IF ((temp4->orlist[idx].order_exists=0))
        temp4->orlist[idx].synonym_id = ocs.synonym_id, temp4->orlist[idx].catalog_cd = ocs
        .catalog_cd, temp4->orlist[idx].catalog_type_cd = ocs.catalog_type_cd,
        temp4->orlist[idx].activity_type_cd = ocs.activity_type_cd, temp4->orlist[idx].mnemonic =
        trim(ocs.mnemonic), temp4->orlist[idx].oe_format_id = ocs.oe_format_id,
        temp4->orlist[idx].ocs_clin_cat_cd = ocs.dcp_clin_cat_cd, temp4->orlist[idx].rx_mask = ocs
        .rx_mask, temp4->orlist[idx].orderable_type_flag = ocs.orderable_type_flag
       ENDIF
       idx2 = idx
       WHILE (idx != 0)
        idx2 = locateval(idx2,(idx+ 1),stop,ocs.synonym_id,temp4->orlist[idx2].ref_prnt_ent_id),
        IF (idx2 != 0)
         idx = idx2
         IF ((temp4->orlist[idx].order_exists=0))
          temp4->orlist[idx].synonym_id = ocs.synonym_id, temp4->orlist[idx].catalog_cd = ocs
          .catalog_cd, temp4->orlist[idx].catalog_type_cd = ocs.catalog_type_cd,
          temp4->orlist[idx].activity_type_cd = ocs.activity_type_cd, temp4->orlist[idx].mnemonic =
          trim(ocs.mnemonic), temp4->orlist[idx].oe_format_id = ocs.oe_format_id,
          temp4->orlist[idx].ocs_clin_cat_cd = ocs.dcp_clin_cat_cd, temp4->orlist[idx].rx_mask = ocs
          .rx_mask, temp4->orlist[idx].orderable_type_flag = ocs.orderable_type_flag
         ENDIF
        ELSE
         idx = idx2
        ENDIF
       ENDWHILE
      FOOT REPORT
       idx = 0
      WITH nocounter
     ;end select
     FREE RECORD temp6
    ENDIF
    SET start = (stop+ 1)
    IF ((high <= (stop+ 1000)))
     SET stop = high
    ELSE
     SET stop = (stop+ 1000)
    ENDIF
    SET stat = alterlist(temp5->list,0)
  ENDWHILE
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(temp4->outcomecatlist,5))
  IF (high <= 1000)
   SET stop = high
  ELSE
   SET stop = 1000
  ENDIF
  WHILE (start <= stop)
    SET max = ((stop - start)+ 1)
    SET stat = alterlist(temp5->list,max)
    FOR (x = 1 TO max)
     SET temp5->list[x].id = temp4->outcomecatlist[((start+ x) - 1)].ref_prnt_ent_id
     SET temp5->list[x].id2 = temp4->outcomecatlist[((start+ x) - 1)].pathway_comp_id
    ENDFOR
    SELECT INTO "nl:"
     oc.outcome_catalog_id
     FROM outcome_catalog oc,
      pathway_comp pc
     PLAN (oc
      WHERE expand(num,1,max,oc.outcome_catalog_id,temp5->list[num].id))
      JOIN (pc
      WHERE pc.parent_entity_id=oc.outcome_catalog_id)
     ORDER BY oc.outcome_catalog_id
     HEAD REPORT
      idx = 0
     DETAIL
      idx = locateval(idx,start,stop,oc.outcome_catalog_id,temp4->outcomecatlist[idx].ref_prnt_ent_id
       ), temp4->outcomecatlist[idx].outcome_description = oc.description, temp4->outcomecatlist[idx]
      .outcome_expectation = oc.expectation,
      temp4->outcomecatlist[idx].outcome_type_cd = oc.outcome_type_cd, temp4->outcomecatlist[idx].
      outcome_event_cd = oc.event_cd, temp4->outcomecatlist[idx].target_type_cd = pc.target_type_cd,
      temp4->outcomecatlist[idx].expand_qty = pc.expand_qty, temp4->outcomecatlist[idx].
      expand_unit_cd = pc.expand_unit_cd, temp4->outcomecatlist[idx].task_assay_cd = oc.task_assay_cd,
      temp4->outcomecatlist[idx].reference_task_id = oc.reference_task_id, temp4->outcomecatlist[idx]
      .result_type_cd = oc.result_type_cd, idx2 = idx
      WHILE (idx != 0)
       idx2 = locateval(idx2,(idx+ 1),stop,oc.outcome_catalog_id,temp4->outcomecatlist[idx2].
        ref_prnt_ent_id),
       IF (idx2 != 0)
        idx = idx2, temp4->outcomecatlist[idx].outcome_description = oc.description, temp4->
        outcomecatlist[idx].outcome_expectation = oc.expectation,
        temp4->outcomecatlist[idx].outcome_type_cd = oc.outcome_type_cd, temp4->outcomecatlist[idx].
        outcome_event_cd = oc.event_cd, temp4->outcomecatlist[idx].target_type_cd = pc.target_type_cd,
        temp4->outcomecatlist[idx].expand_qty = pc.expand_qty, temp4->outcomecatlist[idx].
        expand_unit_cd = pc.expand_unit_cd, temp4->outcomecatlist[idx].task_assay_cd = oc
        .task_assay_cd,
        temp4->outcomecatlist[idx].reference_task_id = oc.reference_task_id, temp4->outcomecatlist[
        idx].result_type_cd = oc.result_type_cd
       ELSE
        idx = idx2
       ENDIF
      ENDWHILE
     FOOT REPORT
      idx = 0
     WITH nocounter
    ;end select
    SET start = (stop+ 1)
    IF ((high <= (stop+ 1000)))
     SET stop = high
    ELSE
     SET stop = (stop+ 1000)
    ENDIF
    SET stat = alterlist(temp5->list,0)
  ENDWHILE
  SET num = 0
  SET max = 0
  SET start = 1
  SET high = value(size(temp4->outcomeactlist,5))
  IF (high <= 1000)
   SET stop = high
  ELSE
   SET stop = 1000
  ENDIF
  WHILE (start <= stop)
    SET max = ((stop - start)+ 1)
    SET stat = alterlist(temp5->list,max)
    FOR (x = 1 TO max)
      SET temp5->list[x].id = temp4->outcomeactlist[((start+ x) - 1)].parent_entity_id
    ENDFOR
    SELECT INTO "nl:"
     oa.outcome_activity_id
     FROM outcome_activity oa
     PLAN (oa
      WHERE expand(num,1,max,oa.outcome_activity_id,temp5->list[num].id))
     HEAD REPORT
      idx = 0
     DETAIL
      idx = locateval(idx,start,stop,oa.outcome_activity_id,temp4->outcomeactlist[idx].
       parent_entity_id), temp4->outcomeactlist[idx].outcome_description = oa.description, temp4->
      outcomeactlist[idx].outcome_expectation = oa.expectation,
      temp4->outcomeactlist[idx].outcome_type_cd = oa.outcome_type_cd, temp4->outcomeactlist[idx].
      target_type_cd = oa.target_type_cd, temp4->outcomeactlist[idx].expand_qty = oa.expand_qty,
      temp4->outcomeactlist[idx].expand_unit_cd = oa.expand_unit_cd, temp4->outcomeactlist[idx].
      outcome_start_dt_tm = cnvtdatetime(oa.start_dt_tm), temp4->outcomeactlist[idx].
      outcome_end_dt_tm = cnvtdatetime(oa.end_dt_tm),
      temp4->outcomeactlist[idx].outcome_updt_cnt = oa.updt_cnt, temp4->outcomeactlist[idx].
      outcome_event_cd = oa.event_cd, temp4->outcomeactlist[idx].outcome_exists = 1,
      temp4->outcomeactlist[idx].task_assay_cd = oa.task_assay_cd, temp4->outcomeactlist[idx].
      reference_task_id = oa.reference_task_id, temp4->outcomeactlist[idx].result_type_cd = oa
      .result_type_cd
      IF (oa.outcome_status_cd=outcome_activated_cd
       AND oa.end_dt_tm != null
       AND cnvtdatetime(oa.end_dt_tm) < cnvtdatetime(cur_dt_tm))
       temp4->outcomeactlist[idx].outcome_status_cd = outcome_completed_cd
      ELSE
       temp4->outcomeactlist[idx].outcome_status_cd = oa.outcome_status_cd
      ENDIF
     FOOT REPORT
      idx = 0
     WITH nocounter
    ;end select
    IF (locateval(idx,start,stop,0,temp4->outcomeactlist[idx].outcome_exists))
     RECORD temp7(
       1 complist[*]
         2 id = f8
     )
     SET cnt = 0
     FOR (j = start TO stop)
       IF ((temp4->outcomeactlist[j].outcome_exists=0))
        SET cnt = (cnt+ 1)
        SET stat = alterlist(temp7->complist,cnt)
        SET temp7->complist[cnt].id = temp4->outcomeactlist[j].ref_prnt_ent_id
       ENDIF
     ENDFOR
     SET itemcnt = value(size(temp7->complist,5))
     SET i = 0
     SELECT INTO "nl:"
      oc.outcome_catalog_id
      FROM outcome_catalog oc
      PLAN (oc
       WHERE expand(i,1,itemcnt,oc.outcome_catalog_id,temp7->complist[i].id))
      ORDER BY oc.outcome_catalog_id
      HEAD REPORT
       idx = 0
      DETAIL
       idx = locateval(idx,start,stop,oc.outcome_catalog_id,temp4->outcomeactlist[idx].
        ref_prnt_ent_id)
       IF ((temp4->outcomeactlist[idx].outcome_exists=0))
        temp4->outcomeactlist[idx].outcome_description = oc.description, temp4->outcomeactlist[idx].
        outcome_expectation = oc.expectation, temp4->outcomeactlist[idx].outcome_type_cd = oc
        .outcome_type_cd,
        temp4->outcomeactlist[idx].outcome_event_cd = oc.event_cd, temp4->outcomeactlist[idx].
        task_assay_cd = oc.task_assay_cd, temp4->outcomeactlist[idx].reference_task_id = oc
        .reference_task_id,
        temp4->outcomeactlist[idx].result_type_cd = oc.result_type_cd
       ENDIF
       idx2 = idx
       WHILE (idx != 0)
        idx2 = locateval(idx2,(idx+ 1),stop,oc.outcome_catalog_id,temp4->outcomeactlist[idx2].
         ref_prnt_ent_id),
        IF (idx2 != 0)
         idx = idx2
         IF ((temp4->outcomeactlist[idx].outcome_exists=0))
          temp4->outcomeactlist[idx].outcome_description = oc.description, temp4->outcomeactlist[idx]
          .outcome_expectation = oc.expectation, temp4->outcomeactlist[idx].outcome_type_cd = oc
          .outcome_type_cd,
          temp4->outcomeactlist[idx].outcome_event_cd = oc.event_cd, temp4->outcomeactlist[idx].
          task_assay_cd = oc.task_assay_cd, temp4->outcomeactlist[idx].reference_task_id = oc
          .reference_task_id,
          temp4->outcomeactlist[idx].result_type_cd = oc.result_type_cd
         ENDIF
        ELSE
         idx = idx2
        ENDIF
       ENDWHILE
      FOOT REPORT
       idx = 0
      WITH nocounter
     ;end select
     FREE RECORD temp7
    ENDIF
    SET start = (stop+ 1)
    IF ((high <= (stop+ 1000)))
     SET stop = high
    ELSE
     SET stop = (stop+ 1000)
    ENDIF
    SET stat = alterlist(temp5->list,0)
  ENDWHILE
  FREE RECORD temp5
  SELECT INTO "nl:"
   pw_group_nbr = temp2->phaselist[d1.seq].pw_group_nbr, pathway_id = temp2->phaselist[d1.seq].
   pathway_id, target_id = temp2->phaselist[d1.seq].phasereltnlist[d2.seq].pathway_t_id
   FROM (dummyt d1  WITH seq = value(size(temp2->phaselist,5))),
    (dummyt d2  WITH seq = 5)
   PLAN (d1
    WHERE maxrec(d2,size(temp2->phaselist[d1.seq].phasereltnlist,5)) > 0)
    JOIN (d2)
   ORDER BY pw_group_nbr, pathway_id, target_id
   HEAD REPORT
    pwcnt = 0
   HEAD pw_group_nbr
    phscnt = 0, compcnt = 0, comptotal = 0,
    pwcnt = (pwcnt+ 1)
    IF (pwcnt > size(reply->pwlist,5))
     stat = alterlist(reply->pwlist,(pwcnt+ 10))
    ENDIF
    reply->pwlist[pwcnt].pw_group_nbr = temp2->phaselist[d1.seq].pw_group_nbr, reply->pwlist[pwcnt].
    type_mean = temp2->phaselist[d1.seq].group_type_mean, reply->pwlist[pwcnt].pw_group_desc = temp2
    ->phaselist[d1.seq].pw_group_desc,
    reply->pwlist[pwcnt].cross_encntr_ind = temp2->phaselist[d1.seq].cross_encntr_ind, reply->pwlist[
    pwcnt].version = temp2->phaselist[d1.seq].version, reply->pwlist[pwcnt].pathway_catalog_id =
    temp2->phaselist[d1.seq].pw_cat_group_id,
    reply->pwlist[pwcnt].pathway_type_cd = temp2->phaselist[d1.seq].pathway_type_cd, reply->pwlist[
    pwcnt].pathway_class_cd = temp2->phaselist[d1.seq].pathway_class_cd, reply->pwlist[pwcnt].
    display_method_cd = temp2->phaselist[d1.seq].display_method_cd
   HEAD pathway_id
    phscnt = (phscnt+ 1)
    IF (phscnt > size(reply->pwlist[pwcnt].phaselist,5))
     stat = alterlist(reply->pwlist[pwcnt].phaselist,(phscnt+ 10))
    ENDIF
    reply->pwlist[pwcnt].phaselist[phscnt].pathway_id = temp2->phaselist[d1.seq].pathway_id, reply->
    pwlist[pwcnt].phaselist[phscnt].encntr_id = temp2->phaselist[d1.seq].encntr_id, reply->pwlist[
    pwcnt].phaselist[phscnt].pw_status_cd = temp2->phaselist[d1.seq].pw_status_cd,
    reply->pwlist[pwcnt].phaselist[phscnt].calc_status_cd = temp2->phaselist[d1.seq].calc_status_cd,
    reply->pwlist[pwcnt].phaselist[phscnt].description = temp2->phaselist[d1.seq].description, reply
    ->pwlist[pwcnt].phaselist[phscnt].type_mean = temp2->phaselist[d1.seq].type_mean,
    reply->pwlist[pwcnt].phaselist[phscnt].duration_qty = temp2->phaselist[d1.seq].duration_qty,
    reply->pwlist[pwcnt].phaselist[phscnt].duration_unit_cd = temp2->phaselist[d1.seq].
    duration_unit_cd, reply->pwlist[pwcnt].phaselist[phscnt].started_ind = temp2->phaselist[d1.seq].
    started_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].processing_ind = temp2->phaselist[d1.seq].processing_ind,
    reply->pwlist[pwcnt].phaselist[phscnt].updt_cnt = temp2->phaselist[d1.seq].updt_cnt, reply->
    pwlist[pwcnt].phaselist[phscnt].start_dt_tm = temp2->phaselist[d1.seq].start_dt_tm,
    reply->pwlist[pwcnt].phaselist[phscnt].calc_end_dt_tm = temp2->phaselist[d1.seq].calc_end_dt_tm,
    reply->pwlist[pwcnt].phaselist[phscnt].order_dt_tm = temp2->phaselist[d1.seq].order_dt_tm, reply
    ->pwlist[pwcnt].phaselist[phscnt].pathway_catalog_id = temp2->phaselist[d1.seq].
    pathway_catalog_id,
    gtotal = size(temp2->phaselist[d1.seq].compgrouplist,5), stat = alterlist(reply->pwlist[pwcnt].
     phaselist[phscnt].compgrouplist,gtotal)
    FOR (gcnt = 1 TO gtotal)
      reply->pwlist[pwcnt].phaselist[phscnt].compgrouplist[gcnt].act_pw_comp_g_id = temp2->phaselist[
      d1.seq].compgrouplist[gcnt].act_pw_comp_g_id, reply->pwlist[pwcnt].phaselist[phscnt].
      compgrouplist[gcnt].type_mean = temp2->phaselist[d1.seq].compgrouplist[gcnt].type_mean, ctotal
       = size(temp2->phaselist[d1.seq].compgrouplist[gcnt].memberlist,5),
      stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].compgrouplist[gcnt].memberlist,ctotal)
      FOR (ccnt = 1 TO ctotal)
       reply->pwlist[pwcnt].phaselist[phscnt].compgrouplist[gcnt].memberlist[ccnt].act_pw_comp_id =
       temp2->phaselist[d1.seq].compgrouplist[gcnt].memberlist[ccnt].act_pw_comp_id,reply->pwlist[
       pwcnt].phaselist[phscnt].compgrouplist[gcnt].memberlist[ccnt].pw_comp_seq = temp2->phaselist[
       d1.seq].compgrouplist[gcnt].memberlist[ccnt].pw_comp_seq
      ENDFOR
    ENDFOR
    phsevidencetotal = size(temp2->phaselist[d1.seq].planevidencelist,5), planevidencetotal = size(
     reply->pwlist[pwcnt].planevidencelist,5), stat = alterlist(reply->pwlist[pwcnt].planevidencelist,
     (phsevidencetotal+ planevidencetotal))
    FOR (ecnt = 1 TO phsevidencetotal)
      reply->pwlist[pwcnt].planevidencelist[(planevidencetotal+ ecnt)].dcp_clin_cat_cd = temp2->
      phaselist[d1.seq].planevidencelist[ecnt].dcp_clin_cat_cd, reply->pwlist[pwcnt].
      planevidencelist[(planevidencetotal+ ecnt)].dcp_clin_sub_cat_cd = temp2->phaselist[d1.seq].
      planevidencelist[ecnt].dcp_clin_sub_cat_cd, reply->pwlist[pwcnt].planevidencelist[(
      planevidencetotal+ ecnt)].pathway_comp_id = temp2->phaselist[d1.seq].planevidencelist[ecnt].
      pathway_comp_id,
      reply->pwlist[pwcnt].planevidencelist[(planevidencetotal+ ecnt)].evidence_type_mean = temp2->
      phaselist[d1.seq].planevidencelist[ecnt].evidence_type_mean, reply->pwlist[pwcnt].
      planevidencelist[(planevidencetotal+ ecnt)].pw_evidence_reltn_id = temp2->phaselist[d1.seq].
      planevidencelist[ecnt].pw_evidence_reltn_id, reply->pwlist[pwcnt].planevidencelist[(
      planevidencetotal+ ecnt)].evidence_locator = temp2->phaselist[d1.seq].planevidencelist[ecnt].
      evidence_locator,
      reply->pwlist[pwcnt].planevidencelist[(planevidencetotal+ ecnt)].pathway_catalog_id = temp2->
      phaselist[d1.seq].planevidencelist[ecnt].pathway_catalog_id
    ENDFOR
    pwrcnt = 0
   DETAIL
    IF (d2.seq > 0)
     pwrcnt = (pwrcnt+ 1), stat = alterlist(reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist,
      pwrcnt), reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].pathway_s_id = temp2->
     phaselist[d1.seq].phasereltnlist[d2.seq].pathway_s_id,
     reply->pwlist[pwcnt].phaselist[phscnt].phasereltnlist[pwrcnt].pathway_t_id = temp2->phaselist[d1
     .seq].phasereltnlist[d2.seq].pathway_t_id, reply->pwlist[pwcnt].phaselist[phscnt].
     phasereltnlist[pwrcnt].type_mean = temp2->phaselist[d1.seq].phasereltnlist[d2.seq].type_mean
    ENDIF
   FOOT  pathway_id
    dummy = 0
   FOOT  pw_group_nbr
    IF (phscnt > 0)
     stat = alterlist(reply->pwlist[pwcnt].phaselist,phscnt)
    ENDIF
   FOOT REPORT
    IF (pwcnt > 0)
     stat = alterlist(reply->pwlist,pwcnt)
    ENDIF
   WITH nocounter, outerjoin = d1
  ;end select
  SELECT INTO "nl:"
   plan_id = decode(d2.seq,temp4->oclist[d2.seq].pw_group_nbr,d3.seq,temp4->orlist[d3.seq].
    pw_group_nbr,d4.seq,
    temp4->ltlist[d4.seq].pw_group_nbr,d5.seq,temp4->outcomecatlist[d5.seq].pw_group_nbr,d6.seq,temp4
    ->outcomeactlist[d6.seq].pw_group_nbr,
    0.0), phase_id = decode(d2.seq,temp4->oclist[d2.seq].pathway_id,d3.seq,temp4->orlist[d3.seq].
    pathway_id,d4.seq,
    temp4->ltlist[d4.seq].pathway_id,d5.seq,temp4->outcomecatlist[d5.seq].pathway_id,d6.seq,temp4->
    outcomeactlist[d6.seq].pathway_id,
    0.0), sort_cd = decode(d2.seq,temp4->oclist[d2.seq].sort_cd,d3.seq,temp4->orlist[d3.seq].sort_cd,
    d4.seq,
    temp4->ltlist[d4.seq].sort_cd,d5.seq,temp4->outcomecatlist[d5.seq].sort_cd,d6.seq,temp4->
    outcomeactlist[d6.seq].sort_cd,
    0.0),
   comp_seq = decode(d2.seq,temp4->oclist[d2.seq].sequence,d3.seq,temp4->orlist[d3.seq].sequence,d4
    .seq,
    temp4->ltlist[d4.seq].sequence,d5.seq,temp4->outcomecatlist[d5.seq].sequence,d6.seq,temp4->
    outcomeactlist[d6.seq].sequence,
    0), check = decode(d2.seq,"oc",d3.seq,"or",d4.seq,
    "lt",d5.seq,"ot",d6.seq,"oa",
    "zz")
   FROM (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = value(size(temp4->oclist,5))),
    (dummyt d3  WITH seq = value(size(temp4->orlist,5))),
    (dummyt d4  WITH seq = value(size(temp4->ltlist,5))),
    (dummyt d5  WITH seq = value(size(temp4->outcomecatlist,5))),
    (dummyt d6  WITH seq = value(size(temp4->outcomeactlist,5)))
   PLAN (d1)
    JOIN (((d2
    WHERE (temp4->oclist[d2.seq].pathway_id > 0))
    ) ORJOIN ((((d3
    WHERE (temp4->orlist[d3.seq].pathway_id > 0))
    ) ORJOIN ((((d4
    WHERE (temp4->ltlist[d4.seq].pathway_id > 0))
    ) ORJOIN ((((d5
    WHERE (temp4->outcomecatlist[d5.seq].pathway_id > 0))
    ) ORJOIN ((d6
    WHERE (temp4->outcomeactlist[d6.seq].pathway_id > 0))
    )) )) )) ))
   ORDER BY plan_id, phase_id, sort_cd,
    comp_seq
   HEAD REPORT
    pwcnt = 0, g_idx = 0, p_idx = 0,
    g_high = size(reply->pwlist,5)
   HEAD plan_id
    g_idx = locateval(g_idx,1,g_high,plan_id,reply->pwlist[g_idx].pw_group_nbr), p_high = size(reply
     ->pwlist[g_idx].phaselist,5)
   HEAD phase_id
    p_idx = locateval(p_idx,1,p_high,phase_id,reply->pwlist[g_idx].phaselist[p_idx].pathway_id),
    cmpcnt = 0
    IF ((reply->pwlist[g_idx].phaselist[p_idx].duration_qty=0)
     AND (reply->pwlist[g_idx].phaselist[p_idx].pw_status_cd=pw_init_cd))
     pwcompflag = 1
    ELSE
     pwcompflag = 0
    ENDIF
   HEAD sort_cd
    cmpcnt = cmpcnt
   HEAD comp_seq
    osrcnt = 0, cmpcnt = (cmpcnt+ 1)
    IF (cmpcnt > size(reply->pwlist[g_idx].phaselist[p_idx].complist,5))
     stat = alterlist(reply->pwlist[g_idx].phaselist[p_idx].complist,(cmpcnt+ 10))
    ENDIF
    IF (check="oc")
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].act_pw_comp_id = temp4->oclist[d2.seq].
     act_pw_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].dcp_clin_cat_cd = temp4->
     oclist[d2.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     dcp_clin_sub_cat_cd = temp4->oclist[d2.seq].dcp_clin_sub_cat_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = temp4->oclist[d2.seq].
     comp_status_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_type_cd = temp4->
     oclist[d2.seq].comp_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].sequence =
     temp4->oclist[d2.seq].sequence,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_name = temp4->oclist[d2.seq
     ].parent_entity_name, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_id =
     temp4->oclist[d2.seq].parent_entity_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     linked_to_tf_ind = temp4->oclist[d2.seq].linked_to_tf_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].required_ind = temp4->oclist[d2.seq].
     required_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].included_ind = temp4->
     oclist[d2.seq].included_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     activated_ind = temp4->oclist[d2.seq].activated_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].order_sentence_id = temp4->oclist[d2.seq]
     .order_sentence_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].synonym_id = temp4->
     oclist[d2.seq].synonym_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].catalog_cd =
     temp4->oclist[d2.seq].catalog_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].catalog_type_cd = temp4->oclist[d2.seq].
     catalog_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].activity_type_cd = temp4
     ->oclist[d2.seq].activity_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     mnemonic = trim(temp4->oclist[d2.seq].mnemonic),
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].oe_format_id = temp4->oclist[d2.seq].
     oe_format_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ocs_clin_cat_cd = temp4->
     oclist[d2.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].rx_mask
      = temp4->oclist[d2.seq].rx_mask,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].updt_cnt = temp4->oclist[d2.seq].updt_cnt,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].pathway_comp_id = temp4->oclist[d2.seq].
     pathway_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].orderable_type_flag =
     temp4->oclist[d2.seq].orderable_type_flag,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_label = temp4->oclist[d2.seq].
     comp_label, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity = temp4->
     oclist[d2.seq].offset_quantity, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     offset_unit_cd = temp4->oclist[d2.seq].offset_unit_cd
     IF ((reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind=0)
      AND (reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity > 0))
      reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind = 1
     ENDIF
     count = size(temp4->oclist[d2.seq].ordsentlist,5)
     IF (count > 0)
      stat = alterlist(reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ordsentlist,count)
      FOR (j = 1 TO count)
        reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ordsentlist[j].order_sentence_seq =
        temp4->oclist[d2.seq].ordsentlist[j].order_sentence_seq, reply->pwlist[g_idx].phaselist[p_idx
        ].complist[cmpcnt].ordsentlist[j].order_sentence_id = temp4->oclist[d2.seq].ordsentlist[j].
        order_sentence_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ordsentlist[j].
        order_sentence_display_line = trim(temp4->oclist[d2.seq].ordsentlist[j].
         order_sentence_display_line),
        reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ordsentlist[j].iv_comp_syn_id = temp4
        ->oclist[d2.seq].ordsentlist[j].iv_comp_syn_id, reply->pwlist[g_idx].phaselist[p_idx].
        complist[cmpcnt].ordsentlist[j].ord_comment_long_text_id = temp4->oclist[d2.seq].ordsentlist[
        j].ord_comment_long_text_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
        ordsentlist[j].ord_comment_long_text = temp4->oclist[d2.seq].ordsentlist[j].
        ord_comment_long_text
      ENDFOR
     ENDIF
    ELSEIF (check="or")
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].act_pw_comp_id = temp4->orlist[d3.seq].
     act_pw_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].dcp_clin_cat_cd = temp4->
     orlist[d3.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     dcp_clin_sub_cat_cd = temp4->orlist[d3.seq].dcp_clin_sub_cat_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = temp4->orlist[d3.seq].
     comp_status_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_type_cd = temp4->
     orlist[d3.seq].comp_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].sequence =
     temp4->orlist[d3.seq].sequence,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_name = temp4->orlist[d3.seq
     ].parent_entity_name, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_id =
     temp4->orlist[d3.seq].parent_entity_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     linked_to_tf_ind = temp4->orlist[d3.seq].linked_to_tf_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].required_ind = temp4->orlist[d3.seq].
     required_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].included_ind = temp4->
     orlist[d3.seq].included_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     activated_ind = temp4->orlist[d3.seq].activated_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].order_sentence_id = temp4->orlist[d3.seq]
     .order_sentence_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].synonym_id = temp4->
     orlist[d3.seq].synonym_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].catalog_cd =
     temp4->orlist[d3.seq].catalog_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].catalog_type_cd = temp4->orlist[d3.seq].
     catalog_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].activity_type_cd = temp4
     ->orlist[d3.seq].activity_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     mnemonic = trim(temp4->orlist[d3.seq].mnemonic),
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].oe_format_id = temp4->orlist[d3.seq].
     oe_format_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].ocs_clin_cat_cd = temp4->
     orlist[d3.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].rx_mask
      = temp4->orlist[d3.seq].rx_mask,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].updt_cnt = temp4->orlist[d3.seq].updt_cnt,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].pathway_comp_id = temp4->orlist[d3.seq].
     pathway_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].orderable_type_flag =
     temp4->orlist[d3.seq].orderable_type_flag,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_label = temp4->orlist[d3.seq].
     comp_label, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity = temp4->
     orlist[d3.seq].offset_quantity, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     offset_unit_cd = temp4->orlist[d3.seq].offset_unit_cd
     IF ((reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind=0)
      AND (reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity > 0))
      reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind = 1
     ENDIF
     IF ((temp4->orlist[d3.seq].order_exists=0))
      IF (((cnvtmin2(cnvtdate(temp4->orlist[d3.seq].activated_dt_tm),cnvttime(temp4->orlist[d3.seq].
        activated_dt_tm))+ stale_in_min) > cur_date_in_min))
       reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].processing_ind = 1
      ELSE
       reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = failed_create
      ENDIF
     ENDIF
     IF (pwcompflag=1)
      IF ((((temp4->orlist[d3.seq].order_status_cd != canceled_cd)
       AND (temp4->orlist[d3.seq].order_status_cd != completed_cd)
       AND (temp4->orlist[d3.seq].order_status_cd != deleted_cd)
       AND (temp4->orlist[d3.seq].order_status_cd != discontinued_cd)
       AND (temp4->orlist[d3.seq].order_status_cd != trans_cancel_cd)
       AND (temp4->orlist[d3.seq].order_status_cd != voidedwrslt_cd)) OR ((reply->pwlist[g_idx].
      phaselist[p_idx].complist[cmpcnt].processing_ind=1))) )
       pwcompflag = 0
      ENDIF
     ENDIF
    ELSEIF (check="lt")
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].act_pw_comp_id = temp4->ltlist[d4.seq].
     act_pw_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].dcp_clin_cat_cd = temp4->
     ltlist[d4.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     dcp_clin_sub_cat_cd = temp4->ltlist[d4.seq].dcp_clin_sub_cat_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_type_cd = temp4->ltlist[d4.seq].
     comp_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].sequence = temp4->ltlist[d4
     .seq].sequence, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_name =
     temp4->ltlist[d4.seq].parent_entity_name,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_id = temp4->ltlist[d4.seq].
     parent_entity_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].persistent_ind = temp4
     ->ltlist[d4.seq].persistent_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     comp_text_id = temp4->ltlist[d4.seq].comp_text_id,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_text = trim(temp4->ltlist[d4.seq].
      comp_text), reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].updt_cnt = temp4->ltlist[d4
     .seq].updt_cnt, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].pathway_comp_id = temp4->
     ltlist[d4.seq].pathway_comp_id,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_label = temp4->ltlist[d4.seq].
     comp_label
    ELSEIF (check="ot")
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].act_pw_comp_id = temp4->outcomecatlist[d5
     .seq].act_pw_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].dcp_clin_cat_cd =
     temp4->outcomecatlist[d5.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].dcp_clin_sub_cat_cd = temp4->outcomecatlist[d5.seq].dcp_clin_sub_cat_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = temp4->outcomecatlist[d5
     .seq].comp_status_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_type_cd =
     temp4->outcomecatlist[d5.seq].comp_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].sequence = temp4->outcomecatlist[d5.seq].sequence,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_name = temp4->
     outcomecatlist[d5.seq].parent_entity_name, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt
     ].parent_entity_id = temp4->outcomecatlist[d5.seq].parent_entity_id, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].linked_to_tf_ind = temp4->outcomecatlist[d5.seq].
     linked_to_tf_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].required_ind = temp4->outcomecatlist[d5
     .seq].required_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].included_ind = temp4
     ->outcomecatlist[d5.seq].included_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     activated_ind = temp4->outcomecatlist[d5.seq].activated_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].updt_cnt = temp4->outcomecatlist[d5.seq].
     updt_cnt, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].duration_qty = temp4->
     outcomecatlist[d5.seq].duration_qty, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     duration_unit_cd = temp4->outcomecatlist[d5.seq].duration_unit_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].pathway_comp_id = temp4->outcomecatlist[
     d5.seq].pathway_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     outcome_description = temp4->outcomecatlist[d5.seq].outcome_description, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].outcome_expectation = temp4->outcomecatlist[d5.seq].
     outcome_expectation,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].outcome_type_cd = temp4->outcomecatlist[
     d5.seq].outcome_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].outcome_event_cd
      = temp4->outcomecatlist[d5.seq].outcome_event_cd, reply->pwlist[g_idx].phaselist[p_idx].
     complist[cmpcnt].target_type_cd = temp4->outcomecatlist[d5.seq].target_type_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].expand_qty = temp4->outcomecatlist[d5.seq
     ].expand_qty, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].expand_unit_cd = temp4->
     outcomecatlist[d5.seq].expand_unit_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     outcome_catalog_id = temp4->outcomecatlist[d5.seq].ref_prnt_ent_id,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].task_assay_cd = temp4->outcomecatlist[d5
     .seq].task_assay_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].reference_task_id =
     temp4->outcomecatlist[d5.seq].reference_task_id, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].comp_label = temp4->outcomecatlist[d5.seq].comp_label,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].result_type_cd = temp4->outcomecatlist[d5
     .seq].result_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity =
     temp4->outcomecatlist[d5.seq].offset_quantity, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].offset_unit_cd = temp4->outcomecatlist[d5.seq].offset_unit_cd
     IF ((reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind=0)
      AND (reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity > 0))
      reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind = 1
     ENDIF
    ELSEIF (check="oa")
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].act_pw_comp_id = temp4->outcomeactlist[d6
     .seq].act_pw_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].dcp_clin_cat_cd =
     temp4->outcomeactlist[d6.seq].dcp_clin_cat_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].dcp_clin_sub_cat_cd = temp4->outcomeactlist[d6.seq].dcp_clin_sub_cat_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = temp4->outcomeactlist[d6
     .seq].comp_status_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_type_cd =
     temp4->outcomeactlist[d6.seq].comp_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[
     cmpcnt].sequence = temp4->outcomeactlist[d6.seq].sequence,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].parent_entity_name = temp4->
     outcomeactlist[d6.seq].parent_entity_name, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt
     ].parent_entity_id = temp4->outcomeactlist[d6.seq].parent_entity_id, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].linked_to_tf_ind = temp4->outcomeactlist[d6.seq].
     linked_to_tf_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].required_ind = temp4->outcomeactlist[d6
     .seq].required_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].included_ind = temp4
     ->outcomeactlist[d6.seq].included_ind, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     activated_ind = temp4->outcomeactlist[d6.seq].activated_ind,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].updt_cnt = temp4->outcomeactlist[d6.seq].
     updt_cnt, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].duration_qty = temp4->
     outcomeactlist[d6.seq].duration_qty, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     duration_unit_cd = temp4->outcomeactlist[d6.seq].duration_unit_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].pathway_comp_id = temp4->outcomeactlist[
     d6.seq].pathway_comp_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     outcome_description = temp4->outcomeactlist[d6.seq].outcome_description, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].outcome_expectation = temp4->outcomeactlist[d6.seq].
     outcome_expectation,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].outcome_type_cd = temp4->outcomeactlist[
     d6.seq].outcome_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     outcome_status_cd = temp4->outcomeactlist[d6.seq].outcome_status_cd, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].target_type_cd = temp4->outcomeactlist[d6.seq].target_type_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].expand_qty = temp4->outcomeactlist[d6.seq
     ].expand_qty, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].expand_unit_cd = temp4->
     outcomeactlist[d6.seq].expand_unit_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     outcome_start_dt_tm = temp4->outcomeactlist[d6.seq].outcome_start_dt_tm,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].outcome_end_dt_tm = temp4->
     outcomeactlist[d6.seq].outcome_end_dt_tm, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt]
     .outcome_updt_cnt = temp4->outcomeactlist[d6.seq].outcome_updt_cnt, reply->pwlist[g_idx].
     phaselist[p_idx].complist[cmpcnt].outcome_event_cd = temp4->outcomeactlist[d6.seq].
     outcome_event_cd,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].outcome_catalog_id = temp4->
     outcomeactlist[d6.seq].ref_prnt_ent_id, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     task_assay_cd = temp4->outcomeactlist[d6.seq].task_assay_cd, reply->pwlist[g_idx].phaselist[
     p_idx].complist[cmpcnt].reference_task_id = temp4->outcomeactlist[d6.seq].reference_task_id,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_label = temp4->outcomeactlist[d6.seq
     ].comp_label, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].result_type_cd = temp4->
     outcomeactlist[d6.seq].result_type_cd, reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].
     offset_quantity = temp4->outcomeactlist[d6.seq].offset_quantity,
     reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_unit_cd = temp4->outcomeactlist[d6
     .seq].offset_unit_cd
     IF ((reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind=0)
      AND (reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].offset_quantity > 0))
      reply->pwlist[g_idx].phaselist[p_idx].start_offset_ind = 1
     ENDIF
     IF ((temp4->outcomeactlist[d6.seq].outcome_exists=0))
      IF (((cnvtmin2(cnvtdate(temp4->outcomeactlist[d6.seq].activated_dt_tm),cnvttime(temp4->
        outcomeactlist[d6.seq].activated_dt_tm))+ stale_in_min) > cur_date_in_min))
       reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].processing_ind = 1
      ELSE
       reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].comp_status_cd = failed_create
      ENDIF
     ENDIF
     IF (pwcompflag=1)
      IF ((((temp4->outcomeactlist[d6.seq].outcome_status_cd=outcome_activated_cd)) OR ((reply->
      pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].processing_ind=1))) )
       pwcompflag = 0
      ENDIF
     ENDIF
    ENDIF
    reply->pwlist[g_idx].phaselist[p_idx].complist[cmpcnt].time_zero_mean = "NONE", reply->pwlist[
    g_idx].phaselist[p_idx].complist[cmpcnt].time_zero_active_ind = 0
   DETAIL
    dummy = 0
   FOOT  comp_seq
    dummy = 0
   FOOT  sort_cd
    dummy = 0
   FOOT  phase_id
    IF (pwcompflag=1)
     reply->pwlist[g_idx].phaselist[p_idx].calc_status_cd = pw_completed_cd
    ENDIF
    IF (cmpcnt > 0)
     stat = alterlist(reply->pwlist[g_idx].phaselist[p_idx].complist,cmpcnt)
    ENDIF
   FOOT  plan_id
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d1
  ;end select
  FREE RECORD temp4
 ENDIF
 IF (value(size(temp3->phaselist,5)) > 0)
  RECORD temp9(
    1 list[*]
      2 pw_group_nbr = f8
      2 pw_group_type_mean = c12
      2 pw_group_desc = vc
      2 cross_encntr_ind = i2
      2 version = i2
      2 pw_group_cat_id = f8
      2 pathway_type_cd = f8
      2 pathway_class_cd = f8
      2 display_method_cd = f8
      2 pathway_id = f8
      2 encntr_id = f8
      2 description = vc
      2 type_mean = c12
      2 processing_ind = i2
      2 pathway_catalog_id = f8
  )
  SET high = value(size(temp3->phaselist,5))
  SELECT INTO "nl:"
   FROM pw_cat_reltn pcr,
    pathway_catalog pc1,
    pathway_catalog pc2
   PLAN (pc2
    WHERE expand(num,1,high,pc2.pathway_catalog_id,temp3->phaselist[num].pathway_catalog_id))
    JOIN (pcr
    WHERE pcr.pw_cat_t_id=outerjoin(pc2.pathway_catalog_id)
     AND pcr.type_mean=outerjoin("GROUP"))
    JOIN (pc1
    WHERE pc1.pathway_catalog_id=outerjoin(pcr.pw_cat_s_id))
   ORDER BY pcr.pw_cat_s_id, pcr.pw_cat_t_id
   HEAD REPORT
    cnt = 0, idx = 0, stop = size(temp3->phaselist,5)
   DETAIL
    cnt = (cnt+ 1), idx = locateval(idx,1,stop,pc2.pathway_catalog_id,temp3->phaselist[idx].
     pathway_catalog_id), stat = alterlist(temp9->list,cnt),
    temp9->list[cnt].pw_group_nbr = temp3->phaselist[idx].pw_group_nbr, temp9->list[cnt].pathway_id
     = temp3->phaselist[idx].pathway_id, temp9->list[cnt].encntr_id = temp3->phaselist[idx].encntr_id,
    temp9->list[cnt].pathway_catalog_id = temp3->phaselist[idx].pathway_catalog_id, temp9->list[cnt].
    description = trim(pc2.display_description), temp9->list[cnt].type_mean = pc2.type_mean
    IF (pc2.type_mean="PHASE")
     temp9->list[cnt].pw_group_type_mean = pc1.type_mean, temp9->list[cnt].pw_group_desc = trim(pc1
      .display_description), temp9->list[cnt].cross_encntr_ind = pc1.cross_encntr_ind,
     temp9->list[cnt].version = pc1.version, temp9->list[cnt].pw_group_cat_id = pc1
     .pathway_catalog_id, temp9->list[cnt].pathway_type_cd = pc1.pathway_type_cd,
     temp9->list[cnt].pathway_class_cd = pc1.pathway_class_cd, temp9->list[cnt].display_method_cd =
     pc1.display_method_cd
    ELSEIF (pc2.type_mean="CAREPLAN")
     temp9->list[cnt].pw_group_type_mean = pc2.type_mean, temp9->list[cnt].pw_group_desc = trim(pc2
      .display_description), temp9->list[cnt].cross_encntr_ind = pc2.cross_encntr_ind,
     temp9->list[cnt].version = pc2.version, temp9->list[cnt].pw_group_cat_id = pc2
     .pathway_catalog_id, temp9->list[cnt].pathway_type_cd = pc2.pathway_type_cd,
     temp9->list[cnt].pathway_class_cd = pc2.pathway_class_cd, temp9->list[cnt].display_method_cd =
     pc2.display_method_cd
    ENDIF
    temp9->list[cnt].processing_ind = 1, idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),stop,pc2.pathway_catalog_id,temp3->phaselist[idx2].
      pathway_catalog_id),
     IF (idx2 != 0)
      idx = idx2, cnt = (cnt+ 1), stat = alterlist(temp9->list,cnt),
      temp9->list[cnt].pw_group_nbr = temp3->phaselist[idx].pw_group_nbr, temp9->list[cnt].pathway_id
       = temp3->phaselist[idx].pathway_id, temp9->list[cnt].encntr_id = temp3->phaselist[idx].
      encntr_id,
      temp9->list[cnt].pathway_catalog_id = temp3->phaselist[idx].pathway_catalog_id, temp9->list[cnt
      ].description = trim(pc2.display_description), temp9->list[cnt].type_mean = pc2.type_mean
      IF (pc2.type_mean="PHASE")
       temp9->list[cnt].pw_group_type_mean = pc1.type_mean, temp9->list[cnt].pw_group_desc = trim(pc1
        .display_description), temp9->list[cnt].cross_encntr_ind = pc1.cross_encntr_ind,
       temp9->list[cnt].version = pc1.version, temp9->list[cnt].pw_group_cat_id = pc1
       .pathway_catalog_id, temp9->list[cnt].pathway_type_cd = pc1.pathway_type_cd,
       temp9->list[cnt].pathway_class_cd = pc1.pathway_class_cd, temp9->list[cnt].display_method_cd
        = pc1.display_method_cd
      ELSEIF (pc2.type_mean="CAREPLAN")
       temp9->list[cnt].pw_group_type_mean = pc2.type_mean, temp9->list[cnt].pw_group_desc = trim(pc2
        .display_description), temp9->list[cnt].cross_encntr_ind = pc2.cross_encntr_ind,
       temp9->list[cnt].version = pc2.version, temp9->list[cnt].pw_group_cat_id = pc2
       .pathway_catalog_id, temp9->list[cnt].pathway_type_cd = pc2.pathway_type_cd,
       temp9->list[cnt].pathway_class_cd = pc2.pathway_class_cd, temp9->list[cnt].display_method_cd
        = pc2.display_method_cd
      ENDIF
      temp9->list[cnt].processing_ind = 1
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    stat = alterlist(temp9->list,cnt)
   WITH nocounter
  ;end select
  SET high = value(size(temp9->list,5))
  FOR (i = 1 TO high)
    SET idx = 0
    SET idx2 = 0
    SET phasecnt = 0
    SET plancnt = 0
    SET stop = value(size(reply->pwlist,5))
    SET idx = locateval(idx,1,stop,temp9->list[i].pw_group_nbr,reply->pwlist[idx].pw_group_nbr)
    IF (idx > 0)
     SET phasecnt = value(size(reply->pwlist[idx].phaselist,5))
     SET idx2 = locateval(idx2,1,phasecnt,temp9->list[i].pathway_id,reply->pwlist[idx].phaselist[idx2
      ].pathway_id)
     IF (idx2=0)
      SET stat = alterlist(reply->pwlist[idx].phaselist,(phasecnt+ 1))
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].pathway_id = temp9->list[i].pathway_id
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].encntr_id = temp9->list[i].encntr_id
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].description = trim(temp9->list[i].description)
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].type_mean = temp9->list[i].type_mean
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].processing_ind = 1
      SET reply->pwlist[idx].phaselist[(phasecnt+ 1)].pathway_catalog_id = temp9->list[i].
      pathway_catalog_id
     ENDIF
    ELSE
     SET plancnt = value(size(reply->pwlist,5))
     SET stat = alterlist(reply->pwlist,(plancnt+ 1))
     SET reply->pwlist[(plancnt+ 1)].pw_group_nbr = temp9->list[i].pw_group_nbr
     SET reply->pwlist[(plancnt+ 1)].type_mean = temp9->list[i].pw_group_type_mean
     SET reply->pwlist[(plancnt+ 1)].pw_group_desc = trim(temp9->list[i].pw_group_desc)
     SET reply->pwlist[(plancnt+ 1)].cross_encntr_ind = temp9->list[i].cross_encntr_ind
     SET reply->pwlist[(plancnt+ 1)].version = temp9->list[i].version
     SET reply->pwlist[(plancnt+ 1)].pathway_catalog_id = temp9->list[i].pw_group_cat_id
     SET reply->pwlist[(plancnt+ 1)].pathway_type_cd = temp9->list[i].pathway_type_cd
     SET reply->pwlist[(plancnt+ 1)].pathway_class_cd = temp9->list[i].pathway_class_cd
     SET reply->pwlist[(plancnt+ 1)].display_method_cd = temp9->list[i].display_method_cd
     SET stat = alterlist(reply->pwlist[(plancnt+ 1)].phaselist,1)
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].pathway_id = temp9->list[i].pathway_id
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].encntr_id = temp9->list[i].encntr_id
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].description = trim(temp9->list[i].description)
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].type_mean = temp9->list[i].type_mean
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].processing_ind = 1
     SET reply->pwlist[(plancnt+ 1)].phaselist[1].pathway_catalog_id = temp9->list[i].
     pathway_catalog_id
    ENDIF
  ENDFOR
  FREE RECORD temp9
 ENDIF
 FREE RECORD temp3
 IF (value(size(temp2->phaselist,5)) > 0)
  DECLARE variancecnt = i4 WITH noconstant(0)
  SET high = value(size(temp2->phaselist,5))
  SELECT INTO "nl:"
   FROM pw_variance_reltn pvr
   PLAN (pvr
    WHERE expand(num,1,high,pvr.pathway_id,temp2->phaselist[num].pathway_id)
     AND pvr.active_ind=1)
   HEAD REPORT
    variancecnt = 0
   DETAIL
    variancecnt = (variancecnt+ 1)
    IF (variancecnt > size(reply->variancelist,5))
     stat = alterlist(reply->variancelist,(variancecnt+ 5))
    ENDIF
    reply->variancelist[variancecnt].variance_reltn_id = pvr.pw_variance_reltn_id, reply->
    variancelist[variancecnt].parent_entity_name = pvr.parent_entity_name, reply->variancelist[
    variancecnt].parent_entity_id = pvr.parent_entity_id,
    reply->variancelist[variancecnt].event_id = pvr.event_id, reply->variancelist[variancecnt].
    variance_type_cd = pvr.variance_type_cd, reply->variancelist[variancecnt].action_cd = pvr
    .action_cd,
    reply->variancelist[variancecnt].action_text_id = pvr.action_text_id, reply->variancelist[
    variancecnt].reason_cd = pvr.reason_cd, reply->variancelist[variancecnt].reason_text_id = pvr
    .reason_text_id,
    reply->variancelist[variancecnt].variance_updt_cnt = pvr.updt_cnt, reply->variancelist[
    variancecnt].active_ind = pvr.active_ind, reply->variancelist[variancecnt].note_text_id = pvr
    .note_text_id
   FOOT REPORT
    stat = alterlist(reply->variancelist[variancecnt],variancecnt)
   WITH nocounter
  ;end select
  SET high = value(size(reply->variancelist,5))
  IF (high > 0)
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].action_text_id)
      AND lt.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].action_text_id)
     IF (idx > 0)
      reply->variancelist[idx].action_text = trim(lt.long_text), reply->variancelist[idx].
      action_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].reason_text_id)
      AND lt.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].reason_text_id)
     IF (idx > 0)
      reply->variancelist[idx].reason_text = trim(lt.long_text), reply->variancelist[idx].
      reason_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(num,1,high,lt.long_text_id,reply->variancelist[num].note_text_id)
      AND lt.active_ind=1)
    HEAD REPORT
     idx = 0
    DETAIL
     idx = locateval(idx,1,high,lt.long_text_id,reply->variancelist[idx].note_text_id)
     IF (idx > 0)
      reply->variancelist[idx].note_text = trim(lt.long_text), reply->variancelist[idx].
      note_text_updt_cnt = lt.updt_cnt
     ENDIF
    FOOT REPORT
     idx = idx
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FREE RECORD temp2
 IF (value(size(temp8->phaselist,5)) > 0)
  SELECT INTO "nl:"
   pw_group_nbr = temp8->phaselist[d1.seq].pw_group_nbr, pathway_id = temp8->phaselist[d1.seq].
   pathway_id, source_id = temp8->phaselist[d1.seq].comprlist[d2.seq].source_id,
   target_id = temp8->phaselist[d1.seq].comprlist[d2.seq].target_id
   FROM (dummyt d1  WITH seq = value(size(temp8->phaselist,5))),
    (dummyt d2  WITH seq = 5)
   PLAN (d1
    WHERE maxrec(d2,size(temp8->phaselist[d1.seq].comprlist,5)) > 0)
    JOIN (d2)
   ORDER BY pw_group_nbr, pathway_id, source_id,
    target_id
   HEAD REPORT
    idx1 = 0, high1 = size(reply->pwlist,5), idx2 = 0,
    high2 = 0, idx3 = 0, high3 = 0
   HEAD pw_group_nbr
    idx1 = locateval(idx1,1,high1,pw_group_nbr,reply->pwlist[idx1].pw_group_nbr), high2 = size(reply
     ->pwlist[idx1].phaselist,5)
   HEAD pathway_id
    idx2 = locateval(idx2,1,high2,pathway_id,reply->pwlist[idx1].phaselist[idx2].pathway_id), reply->
    pwlist[idx1].phaselist[idx2].time_zero_ind = 1, high3 = size(reply->pwlist[idx1].phaselist[idx2].
     complist,5)
   HEAD source_id
    idx3 = locateval(idx3,1,high3,source_id,reply->pwlist[idx1].phaselist[idx2].complist[idx3].
     act_pw_comp_id)
    IF (idx3 > 0)
     reply->pwlist[idx1].phaselist[idx2].complist[idx3].time_zero_mean = "TIMEZERO", reply->pwlist[
     idx1].phaselist[idx2].complist[idx3].time_zero_active_ind = 1
    ENDIF
   HEAD target_id
    idx3 = locateval(idx3,1,high3,target_id,reply->pwlist[idx1].phaselist[idx2].complist[idx3].
     act_pw_comp_id)
    IF (idx3 > 0)
     reply->pwlist[idx1].phaselist[idx2].complist[idx3].time_zero_mean = "TIMEZEROLINK", reply->
     pwlist[idx1].phaselist[idx2].complist[idx3].time_zero_offset_qty = temp8->phaselist[d1.seq].
     comprlist[d2.seq].offset_qty, reply->pwlist[idx1].phaselist[idx2].complist[idx3].
     time_zero_offset_unit_cd = temp8->phaselist[d1.seq].comprlist[d2.seq].offset_unit_cd,
     reply->pwlist[idx1].phaselist[idx2].complist[idx3].time_zero_active_ind = temp8->phaselist[d1
     .seq].comprlist[d2.seq].active_ind
    ENDIF
   DETAIL
    dummy = 0
   FOOT  target_id
    dummy = 0
   FOOT  source_id
    dummy = 0
   FOOT  pathway_id
    dummy = 0
   FOOT  pw_group_nbr
    dummy = 0
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d1
  ;end select
  FREE RECORD temp8
 ENDIF
#exit_script
 SET modify = nopredeclare
 EXECUTE cclaudit 0, "Care Plan", "Read",
 "Person", "Person", "Person",
 "Person", request->person_id, ""
 SET modify = predeclare
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
