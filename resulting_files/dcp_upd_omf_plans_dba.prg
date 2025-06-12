CREATE PROGRAM dcp_upd_omf_plans:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD phases(
   1 qual[*]
     2 pathway_id = f8
     2 pathway_catalog_id = f8
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 pw_status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 phase_desc = vc
     2 plan_desc = vc
     2 order_dt_tm = dq8
     2 order_dt_nbr = i4
     2 order_min_nbr = i4
     2 order_prsnl_id = f8
     2 started_ind = i2
     2 start_dt_tm = dq8
     2 start_dt_nbr = i4
     2 start_min_nbr = i4
     2 start_prsnl_id = f8
     2 discontinued_ind = i2
     2 discontinued_dt_tm = dq8
     2 discontinued_dt_nbr = i4
     2 discontinued_min_nbr = i4
     2 dc_prsnl_id = f8
     2 pw_duration_min_nbr = i4
     2 actual_duration_min_nbr = i4
     2 duration_delta_min_nbr = i4
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 calc_end_dt_tm = dq8
     2 calc_end_dt_nbr = i4
     2 calc_end_min_nbr = i4
     2 version = i4
     2 type_mean = c12
     2 pathway_type_cd = f8
     2 pathway_class_cd = f8
     2 ref_owner_person_id = f8
 )
 RECORD orders(
   1 qual[*]
     2 pw_ord_comp_id = f8
     2 pathway_comp_id = f8
     2 ord_comp_description = vc
     2 encntr_id = f8
     2 person_id = f8
     2 order_id = f8
     2 order_catalog_cd = f8
     2 order_synonym_id = f8
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 included_ind = i2
     2 included_dt_tm = dq8
     2 included_dt_nbr = i4
     2 included_min_nbr = i4
     2 included_prsnl_id = f8
     2 excluded_ind = i2
     2 excluded_dt_tm = dq8
     2 excluded_dt_nbr = i4
     2 excluded_min_nbr = i4
     2 excluded_prsnl_id = f8
     2 activated_ind = i2
     2 activated_dt_tm = dq8
     2 activated_dt_nbr = i4
     2 activated_min_nbr = i4
     2 activated_prsnl_id = f8
     2 required_ind = i2
     2 added_ind = i2
     2 default_incl_ind = i2
     2 type_mean = c12
     2 pw_phase_desc = vc
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 plan_desc = vc
     2 phase_desc = vc
     2 pathway_id = f8
     2 pw_catalog_id = f8
     2 pw_version = i4
     2 category_display = vc
     2 category_cd = f8
     2 sub_category_display = vc
     2 sub_category_cd = f8
 )
 RECORD outcomes(
   1 qual[*]
     2 pw_out_comp_id = f8
     2 pathway_comp_id = f8
     2 out_comp_description = vc
     2 outcome_activity_id = f8
     2 outcome_catalog_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 event_cd = f8
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 included_ind = i2
     2 included_dt_tm = dq8
     2 included_dt_nbr = i4
     2 included_min_nbr = i4
     2 included_prsnl_id = f8
     2 excluded_ind = i2
     2 excluded_dt_tm = dq8
     2 excluded_dt_nbr = i4
     2 excluded_min_nbr = i4
     2 excluded_prsnl_id = f8
     2 activated_ind = i2
     2 activated_dt_tm = dq8
     2 activated_dt_nbr = i4
     2 activated_min_nbr = i4
     2 activated_prsnl_id = f8
     2 required_ind = i2
     2 added_ind = i2
     2 default_incl_ind = i2
     2 pw_phase_desc = vc
     2 type_mean = vc
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 plan_desc = vc
     2 phase_desc = vc
     2 category_display = vc
     2 category_cd = f8
     2 sub_category_display = vc
     2 sub_category_cd = f8
     2 pathway_id = f8
     2 pw_catalog_id = f8
     2 pw_version = i4
 )
 DECLARE zero_dt_tm = q8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE zero_dt_nbr = i4 WITH constant(cnvtdate(zero_dt_tm)), protect
 DECLARE zero_min_nbr = i4 WITH constant(cnvtmin(zero_dt_tm,5)), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE phs_count = i4 WITH noconstant(0), protect
 DECLARE out_count = i4 WITH noconstant(0), protect
 DECLARE ord_count = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE prev_status_cd = f8 WITH noconstant(0.0), protect
 DECLARE status_changed = c1 WITH noconstant("N"), protect
 DECLARE failed = c1 WITH noconstant("F"), protect
 DECLARE plan_version_id = f8 WITH noconstant(0.0), protect
 DECLARE phase_initiated_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITIATED")), protect
 DECLARE phase_dc_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED")), protect
 DECLARE phase_void_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"VOID")), protect
 DECLARE days_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"DAYS")), protect
 DECLARE hours_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS")), protect
 DECLARE minutes_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"MINUTES")), protect
 DECLARE comp_activated_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"ACTIVATED")), protect
 DECLARE comp_included_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"INCLUDED")), protect
 DECLARE comp_excluded_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"EXCLUDED")), protect
 DECLARE phase_cnt = i4 WITH constant(value(size(request->phases,5))), protect
 DECLARE order_cnt = i4 WITH constant(value(size(request->orders,5))), protect
 DECLARE outcome_cnt = i4 WITH constant(value(size(request->outcomes,5))), protect
 IF ((((phase_initiated_cd=- (1))) OR ((((phase_dc_cd=- (1))) OR ((((phase_void_cd=- (1))) OR ((((
 days_cd=- (1))) OR ((((hours_cd=- (1))) OR ((((minutes_cd=- (1))) OR ((((comp_included_cd=- (1)))
  OR ((((comp_activated_cd=- (1))) OR ((comp_excluded_cd=- (1)))) )) )) )) )) )) )) )) )
  CALL echo("Unable to load code values!  Exit.")
  SET failed = "T"
  GO TO end_program
 ENDIF
 DECLARE load_phase_data(idx=i4) = null
 DECLARE write_phase_data(high=i4) = null
 DECLARE insert_phase(idx=i4) = null
 DECLARE update_phase(idx=i4) = null
 DECLARE load_order_data(idx=i4) = null
 DECLARE write_order_data(high=i4) = null
 DECLARE insert_order(idx=i4) = null
 DECLARE update_order(idx=i4) = null
 DECLARE load_outcome_data(idx=i4) = null
 DECLARE write_outcome_data(high=i4) = null
 DECLARE insert_outcome(idx=i4) = null
 DECLARE update_outcome(idx=i4) = null
 IF (phase_cnt > 0)
  CALL load_phase_data(phase_cnt)
 ENDIF
 IF (value(size(phases->qual,5)) > 0)
  CALL write_phase_data(value(size(phases->qual,5)))
 ENDIF
 IF (order_cnt > 0)
  CALL load_order_data(order_cnt)
 ENDIF
 IF (value(size(orders->qual,5)) > 0)
  CALL write_order_data(value(size(orders->qual,5)))
 ENDIF
 IF (outcome_cnt > 0)
  CALL load_outcome_data(outcome_cnt)
 ENDIF
 IF (value(size(outcomes->qual,5)) > 0)
  CALL write_outcome_data(value(size(outcomes->qual,5)))
 ENDIF
 SUBROUTINE load_phase_data(idx)
   SELECT INTO "nl:"
    FROM pathway pw,
     pathway_action pwa,
     pathway_catalog pwc,
     pathway_catalog pwc2
    PLAN (pw
     WHERE expand(num,1,phase_cnt,pw.pathway_id,request->phases[num].pathway_id))
     JOIN (pwa
     WHERE pwa.pathway_id=pw.pathway_id)
     JOIN (pwc
     WHERE pwc.pathway_catalog_id=pw.pathway_catalog_id)
     JOIN (pwc2
     WHERE pwc2.pathway_catalog_id=pw.pw_cat_group_id)
    ORDER BY pw.pathway_id, pwa.pw_action_seq
    HEAD REPORT
     cnt = 0
    HEAD pw.pathway_id
     cnt = (cnt+ 1)
     IF (cnt > value(size(phases->qual,5)))
      stat = alterlist(phases->qual,(cnt+ 10))
     ENDIF
     phases->qual[cnt].pathway_id = pw.pathway_id, phases->qual[cnt].pathway_catalog_id = pw
     .pathway_catalog_id, phases->qual[cnt].pw_group_nbr = pw.pw_group_nbr
     IF (pwc2.version_pw_cat_id > 0)
      phases->qual[cnt].pw_cat_group_id = pwc2.version_pw_cat_id
     ELSE
      phases->qual[cnt].pw_cat_group_id = pwc2.pathway_catalog_id
     ENDIF
     phases->qual[cnt].pw_status_cd = pw.pw_status_cd, phases->qual[cnt].status_dt_tm = cnvtdatetime(
      pw.status_dt_tm), phases->qual[cnt].status_dt_nbr = cnvtdate(cnvtdatetimeutc(pw.status_dt_tm,2)
      ),
     phases->qual[cnt].status_min_nbr = (cnvtmin(cnvtdatetimeutc(pw.status_dt_tm,2),5)+ 1), phases->
     qual[cnt].status_prsnl_id = pw.status_prsnl_id, phases->qual[cnt].person_id = pw.person_id,
     phases->qual[cnt].encntr_id = pw.encntr_id, phases->qual[cnt].phase_desc = pw.description,
     phases->qual[cnt].plan_desc = pw.pw_group_desc,
     phases->qual[cnt].order_dt_tm = cnvtdatetime(pw.order_dt_tm), phases->qual[cnt].order_dt_nbr =
     cnvtdate(cnvtdatetimeutc(pw.order_dt_tm,2)), phases->qual[cnt].order_min_nbr = (cnvtmin(
      cnvtdatetimeutc(pw.order_dt_tm,2),5)+ 1),
     phases->qual[cnt].started_ind = pw.started_ind, phases->qual[cnt].start_dt_tm = cnvtdatetime(pw
      .start_dt_tm), phases->qual[cnt].start_dt_nbr = cnvtdate(cnvtdatetimeutc(pw.start_dt_tm,2)),
     phases->qual[cnt].start_min_nbr = (cnvtmin(cnvtdatetimeutc(pw.start_dt_tm,2),5)+ 1), phases->
     qual[cnt].discontinued_ind = pw.discontinued_ind, phases->qual[cnt].discontinued_dt_tm =
     cnvtdatetime(pw.discontinued_dt_tm),
     phases->qual[cnt].discontinued_dt_nbr = cnvtdate(cnvtdatetimeutc(pw.discontinued_dt_tm,2)),
     phases->qual[cnt].discontinued_min_nbr = (cnvtmin(cnvtdatetimeutc(pw.discontinued_dt_tm,2),5)+ 1
     ), phases->qual[cnt].duration_qty = pwc.duration_qty,
     phases->qual[cnt].duration_unit_cd = pwc.duration_unit_cd, phases->qual[cnt].calc_end_dt_tm =
     cnvtdatetime(pw.calc_end_dt_tm), phases->qual[cnt].calc_end_dt_nbr = cnvtdate(cnvtdatetimeutc(pw
       .calc_end_dt_tm,2)),
     phases->qual[cnt].calc_end_min_nbr = (cnvtmin(cnvtdatetimeutc(pw.calc_end_dt_tm,2),5)+ 1)
     IF ((phases->qual[cnt].duration_unit_cd=days_cd))
      phases->qual[cnt].pw_duration_min_nbr = (phases->qual[cnt].duration_qty * 1440)
     ELSEIF ((phases->qual[cnt].duration_unit_cd=hours_cd))
      phases->qual[cnt].pw_duration_min_nbr = (phases->qual[cnt].duration_qty * 60)
     ELSEIF ((phases->qual[cnt].duration_unit_cd=minutes_cd))
      phases->qual[cnt].pw_duration_min_nbr = phases->qual[cnt].duration_qty
     ENDIF
     IF ((phases->qual[cnt].discontinued_ind=1))
      phases->qual[cnt].calc_end_dt_tm = cnvtdatetime(phases->qual[cnt].discontinued_dt_tm), phases->
      qual[cnt].calc_end_dt_nbr = cnvtdate(cnvtdatetimeutc(phases->qual[cnt].discontinued_dt_tm,2)),
      phases->qual[cnt].calc_end_min_nbr = (cnvtmin(cnvtdatetimeutc(phases->qual[cnt].
        discontinued_dt_tm,2),5)+ 1),
      phases->qual[cnt].actual_duration_min_nbr = datetimediff(phases->qual[cnt].discontinued_dt_tm,
       phases->qual[cnt].start_dt_tm,4)
      IF ((phases->qual[cnt].pw_duration_min_nbr > 0))
       phases->qual[cnt].duration_delta_min_nbr = (phases->qual[cnt].actual_duration_min_nbr - phases
       ->qual[cnt].pw_duration_min_nbr)
      ENDIF
     ELSEIF ((phases->qual[cnt].started_ind=1))
      phases->qual[cnt].actual_duration_min_nbr = datetimediff(pw.calc_end_dt_tm,phases->qual[cnt].
       start_dt_tm,4)
      IF ((phases->qual[cnt].pw_duration_min_nbr > 0))
       phases->qual[cnt].duration_delta_min_nbr = (phases->qual[cnt].actual_duration_min_nbr - phases
       ->qual[cnt].pw_duration_min_nbr)
      ENDIF
     ENDIF
     phases->qual[cnt].version = pw.pw_cat_version, phases->qual[cnt].type_mean = pw.type_mean,
     phases->qual[cnt].pathway_type_cd = pw.pathway_type_cd,
     phases->qual[cnt].pathway_class_cd = pw.pathway_class_cd, phases->qual[cnt].ref_owner_person_id
      = pw.ref_owner_person_id, prev_status_cd = 0
    HEAD pwa.pw_action_seq
     IF (pwa.pw_status_cd != prev_status_cd)
      status_changed = "Y"
     ENDIF
     IF (pwa.pw_action_seq=1)
      phases->qual[cnt].order_prsnl_id = pwa.action_prsnl_id
      IF (pwa.pw_status_cd=phase_initiated_cd)
       phases->qual[cnt].start_prsnl_id = pwa.action_prsnl_id
      ENDIF
     ELSEIF (status_changed="Y")
      IF (pwa.pw_status_cd=phase_initiated_cd)
       phases->qual[cnt].start_prsnl_id = pwa.action_prsnl_id
      ELSEIF (pwa.pw_status_cd=phase_dc_cd)
       phases->qual[cnt].dc_prsnl_id = pwa.action_prsnl_id
      ELSEIF (pwa.pw_status_cd=phase_void_cd)
       phases->qual[cnt].dc_prsnl_id = pwa.action_prsnl_id, cnt = cnt
      ENDIF
     ENDIF
    FOOT  pwa.pw_action_seq
     prev_status_cd = pwa.pw_status_cd, status_changed = "N"
    FOOT  pw.pathway_id
     cnt = cnt
    FOOT REPORT
     stat = alterlist(phases->qual,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE write_phase_data(high)
  DECLARE omf_status = f8 WITH noconstant(0.0), private
  FOR (i = 1 TO high)
    SELECT INTO "nl:"
     FROM cn_pathway_st cn
     WHERE (cn.pathway_id=phases->qual[i].pathway_id)
     DETAIL
      omf_status = cn.pw_status_cd
     WITH nocounter, forupdate(cn)
    ;end select
    SET status_changed = "N"
    IF (curqual=0)
     CALL insert_phase(i)
    ELSE
     IF ((omf_status != phases->qual[i].pw_status_cd))
      SET status_changed = "Y"
     ENDIF
     CALL update_phase(i)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE insert_phase(idx)
   INSERT  FROM cn_pathway_st cn
    SET cn.pathway_id = phases->qual[idx].pathway_id, cn.pathway_catalog_id = phases->qual[idx].
     pathway_catalog_id, cn.pathway_ind = 1,
     cn.pw_group_nbr = phases->qual[idx].pw_group_nbr, cn.pw_cat_group_id = phases->qual[idx].
     pw_cat_group_id, cn.pw_status_cd = phases->qual[idx].pw_status_cd,
     cn.status_dt_tm = cnvtdatetime(phases->qual[idx].status_dt_tm), cn.status_dt_nbr = phases->qual[
     idx].status_dt_nbr, cn.status_min_nbr = phases->qual[idx].status_min_nbr,
     cn.status_prsnl_id = phases->qual[idx].status_prsnl_id, cn.person_id = phases->qual[idx].
     person_id, cn.encntr_id = phases->qual[idx].encntr_id,
     cn.description = trim(phases->qual[idx].plan_desc), cn.pw_phase_desc = concat(trim(phases->qual[
       idx].plan_desc)," ",trim(phases->qual[idx].phase_desc)), cn.pw_group_desc = trim(phases->qual[
      idx].plan_desc),
     cn.tf_desc = trim(phases->qual[idx].phase_desc), cn.ordered_ind = 1, cn.order_dt_tm =
     cnvtdatetime(phases->qual[idx].order_dt_tm),
     cn.order_dt_nbr = phases->qual[idx].order_dt_nbr, cn.order_min_nbr = phases->qual[idx].
     order_min_nbr, cn.order_prsnl_id = phases->qual[idx].order_prsnl_id,
     cn.started_ind = phases->qual[idx].started_ind, cn.start_dt_tm = cnvtdatetime(phases->qual[idx].
      start_dt_tm), cn.start_dt_nbr = phases->qual[idx].start_dt_nbr,
     cn.start_min_nbr = phases->qual[idx].start_min_nbr, cn.start_prsnl_id = phases->qual[idx].
     start_prsnl_id, cn.complete_ind = 0,
     cn.discontinued_ind = phases->qual[idx].discontinued_ind, cn.discontinued_dt_tm = cnvtdatetime(
      phases->qual[idx].discontinued_dt_tm), cn.discontinued_dt_nbr = phases->qual[idx].
     discontinued_dt_nbr,
     cn.discontinued_min_nbr = phases->qual[idx].discontinued_min_nbr, cn.dc_prsnl_id = phases->qual[
     idx].dc_prsnl_id, cn.duration_qty = phases->qual[idx].duration_qty,
     cn.duration_unit_cd = phases->qual[idx].duration_unit_cd, cn.pw_duration_min_nbr = phases->qual[
     idx].pw_duration_min_nbr, cn.actual_duration_min_nbr = phases->qual[idx].actual_duration_min_nbr,
     cn.duration_delta_min_nbr = phases->qual[idx].duration_delta_min_nbr, cn.calc_end_dt_tm =
     cnvtdatetime(phases->qual[idx].calc_end_dt_tm), cn.calc_end_dt_nbr = phases->qual[idx].
     calc_end_dt_nbr,
     cn.calc_end_min_nbr = phases->qual[idx].calc_end_min_nbr, cn.version = phases->qual[idx].version,
     cn.type_mean = phases->qual[idx].type_mean,
     cn.pathway_type_cd = phases->qual[idx].pathway_type_cd, cn.pathway_class_cd = phases->qual[idx].
     pathway_class_cd, cn.ref_owner_person_id = phases->qual[idx].ref_owner_person_id,
     cn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cn.updt_cnt = 0, cn.updt_id = reqinfo->updt_id,
     cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE update_phase(idx)
   UPDATE  FROM cn_pathway_st cn
    SET cn.encntr_id =
     IF (status_changed="Y"
      AND (phases->qual[idx].pw_status_cd=phase_initiated_cd)
      AND (phases->qual[idx].encntr_id > 0)) phases->qual[idx].encntr_id
     ELSE cn.encntr_id
     ENDIF
     , cn.pw_status_cd =
     IF (status_changed="Y") phases->qual[idx].pw_status_cd
     ELSE cn.pw_status_cd
     ENDIF
     , cn.status_dt_tm =
     IF (status_changed="Y") cnvtdatetime(phases->qual[idx].status_dt_tm)
     ELSE cn.status_dt_tm
     ENDIF
     ,
     cn.status_dt_nbr =
     IF (status_changed="Y") phases->qual[idx].status_dt_nbr
     ELSE cn.status_dt_nbr
     ENDIF
     , cn.status_min_nbr =
     IF (status_changed="Y") phases->qual[idx].status_min_nbr
     ELSE cn.status_min_nbr
     ENDIF
     , cn.status_prsnl_id =
     IF (status_changed="Y") phases->qual[idx].status_prsnl_id
     ELSE cn.status_prsnl_id
     ENDIF
     ,
     cn.started_ind = phases->qual[idx].started_ind, cn.start_dt_tm = cnvtdatetime(phases->qual[idx].
      start_dt_tm), cn.start_dt_nbr = phases->qual[idx].start_dt_nbr,
     cn.start_min_nbr = phases->qual[idx].start_min_nbr, cn.start_prsnl_id = phases->qual[idx].
     start_prsnl_id, cn.discontinued_ind = phases->qual[idx].discontinued_ind,
     cn.discontinued_dt_tm = cnvtdatetime(phases->qual[idx].discontinued_dt_tm), cn
     .discontinued_dt_nbr = phases->qual[idx].discontinued_dt_nbr, cn.discontinued_min_nbr = phases->
     qual[idx].discontinued_min_nbr,
     cn.dc_prsnl_id = phases->qual[idx].dc_prsnl_id, cn.actual_duration_min_nbr = phases->qual[idx].
     actual_duration_min_nbr, cn.duration_delta_min_nbr = phases->qual[idx].duration_delta_min_nbr,
     cn.calc_end_dt_tm =
     IF ((phases->qual[idx].calc_end_dt_tm != null)) cnvtdatetime(phases->qual[idx].calc_end_dt_tm)
     ELSE cn.calc_end_dt_tm
     ENDIF
     , cn.calc_end_dt_nbr =
     IF ((phases->qual[idx].calc_end_dt_tm != null)) phases->qual[idx].calc_end_dt_nbr
     ELSE cn.calc_end_dt_nbr
     ENDIF
     , cn.calc_end_min_nbr =
     IF ((phases->qual[idx].calc_end_dt_tm != null)) phases->qual[idx].calc_end_min_nbr
     ELSE cn.calc_end_min_nbr
     ENDIF
     ,
     cn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cn.updt_cnt = (cn.updt_cnt+ 1), cn.updt_id =
     reqinfo->updt_id,
     cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->updt_applctx
    WHERE (cn.pathway_id=phases->qual[idx].pathway_id)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE load_order_data(idx)
   SELECT INTO "nl:"
    FROM act_pw_comp apc,
     pathway_comp pc,
     order_catalog_synonym ocs,
     pw_comp_action pca,
     pathway pw,
     pathway_catalog pwc
    PLAN (apc
     WHERE expand(num,1,order_cnt,apc.act_pw_comp_id,request->orders[num].act_pw_comp_id))
     JOIN (pc
     WHERE pc.pathway_comp_id=apc.pathway_comp_id)
     JOIN (ocs
     WHERE ocs.synonym_id=apc.ref_prnt_ent_id)
     JOIN (pca
     WHERE pca.act_pw_comp_id=apc.act_pw_comp_id)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
     JOIN (pwc
     WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
    ORDER BY apc.act_pw_comp_id, pca.pw_comp_action_seq
    HEAD REPORT
     cnt = 0
    HEAD apc.act_pw_comp_id
     cnt = (cnt+ 1)
     IF (cnt > value(size(orders->qual,5)))
      stat = alterlist(orders->qual,(cnt+ 10))
     ENDIF
     orders->qual[cnt].pw_ord_comp_id = apc.act_pw_comp_id, orders->qual[cnt].pathway_comp_id = apc
     .pathway_comp_id, orders->qual[cnt].ord_comp_description = trim(ocs.mnemonic),
     orders->qual[cnt].encntr_id = apc.encntr_id, orders->qual[cnt].person_id = apc.person_id, orders
     ->qual[cnt].order_id = apc.parent_entity_id,
     orders->qual[cnt].order_catalog_cd = ocs.catalog_cd, orders->qual[cnt].order_synonym_id = ocs
     .synonym_id, orders->qual[cnt].status_cd = apc.comp_status_cd,
     orders->qual[cnt].included_ind = apc.included_ind, orders->qual[cnt].activated_ind = apc
     .activated_ind, orders->qual[cnt].activated_dt_tm = cnvtdatetime(apc.activated_dt_tm),
     orders->qual[cnt].activated_dt_nbr = cnvtdate(cnvtdatetimeutc(apc.activated_dt_tm,2)), orders->
     qual[cnt].activated_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.activated_dt_tm,2),5)+ 1), orders->
     qual[cnt].activated_prsnl_id = apc.activated_prsnl_id,
     orders->qual[cnt].required_ind = apc.required_ind
     IF ((orders->qual[cnt].pathway_comp_id=0))
      orders->qual[cnt].added_ind = 1
     ELSE
      orders->qual[cnt].added_ind = 0
     ENDIF
     orders->qual[cnt].default_incl_ind = pc.include_ind, orders->qual[cnt].type_mean = pw.type_mean,
     orders->qual[cnt].pw_phase_desc = concat(trim(pw.pw_group_desc)," ",trim(pw.description)),
     orders->qual[cnt].pw_group_nbr = pw.pw_group_nbr
     IF (pwc.version_pw_cat_id > 0)
      orders->qual[cnt].pw_cat_group_id = pwc.version_pw_cat_id
     ELSE
      orders->qual[cnt].pw_cat_group_id = pwc.pathway_catalog_id
     ENDIF
     orders->qual[cnt].plan_desc = trim(pw.pw_group_desc), orders->qual[cnt].phase_desc = trim(pw
      .description), orders->qual[cnt].pathway_id = pw.pathway_id,
     orders->qual[cnt].pw_catalog_id = pw.pathway_catalog_id, orders->qual[cnt].pw_version = pw
     .pw_cat_version, orders->qual[cnt].category_display = uar_get_code_display(apc.dcp_clin_cat_cd),
     orders->qual[cnt].category_cd = apc.dcp_clin_cat_cd, orders->qual[cnt].sub_category_display =
     uar_get_code_display(apc.dcp_clin_sub_cat_cd), orders->qual[cnt].sub_category_cd = apc
     .dcp_clin_sub_cat_cd,
     prev_status_cd = 0
    DETAIL
     IF (pca.comp_status_cd != prev_status_cd)
      status_changed = "Y"
     ENDIF
     IF (status_changed="Y"
      AND (orders->qual[cnt].status_cd=pca.comp_status_cd))
      orders->qual[cnt].status_dt_tm = cnvtdatetime(pca.action_dt_tm), orders->qual[cnt].
      status_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), orders->qual[cnt].status_min_nbr
       = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      orders->qual[cnt].status_prsnl_id = pca.action_prsnl_id
     ENDIF
     IF (status_changed="Y"
      AND pca.comp_status_cd=comp_activated_cd
      AND ((pca.pw_comp_action_seq=1) OR (prev_status_cd=comp_excluded_cd)) )
      orders->qual[cnt].included_dt_tm = cnvtdatetime(pca.action_dt_tm), orders->qual[cnt].
      included_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), orders->qual[cnt].
      included_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      orders->qual[cnt].included_prsnl_id = pca.action_prsnl_id
     ELSEIF (status_changed="Y"
      AND pca.comp_status_cd=comp_included_cd)
      orders->qual[cnt].included_dt_tm = cnvtdatetime(pca.action_dt_tm), orders->qual[cnt].
      included_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), orders->qual[cnt].
      included_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      orders->qual[cnt].included_prsnl_id = pca.action_prsnl_id
     ELSEIF (status_changed="Y"
      AND pca.comp_status_cd=comp_excluded_cd)
      orders->qual[cnt].excluded_ind = 1, orders->qual[cnt].excluded_dt_tm = cnvtdatetime(pca
       .action_dt_tm), orders->qual[cnt].excluded_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,
        2)),
      orders->qual[cnt].excluded_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      orders->qual[cnt].excluded_prsnl_id = pca.action_prsnl_id
     ENDIF
     prev_status_cd = pca.comp_status_cd, status_changed = "N"
    FOOT  apc.act_pw_comp_id
     cnt = cnt
    FOOT REPORT
     stat = alterlist(orders->qual,cnt)
   ;end select
 END ;Subroutine
 SUBROUTINE write_order_data(high)
   FOR (i = 1 TO high)
    SELECT INTO "nl:"
     FROM cn_pw_order_st cpo
     WHERE (cpo.pw_ord_comp_id=orders->qual[i].pw_ord_comp_id)
     WITH nocounter, forupdate(cpo)
    ;end select
    IF (curqual=0)
     CALL insert_order(i)
    ELSE
     CALL update_order(i)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE insert_order(idx)
   INSERT  FROM cn_pw_order_st cpo
    SET cpo.pw_ord_comp_id = orders->qual[idx].pw_ord_comp_id, cpo.pathway_comp_id = orders->qual[idx
     ].pathway_comp_id, cpo.pw_ord_comp_ind = 1,
     cpo.ord_comp_description = orders->qual[idx].ord_comp_description, cpo.encntr_id = orders->qual[
     idx].encntr_id, cpo.person_id = orders->qual[idx].person_id,
     cpo.order_id = orders->qual[idx].order_id, cpo.order_catalog_cd = orders->qual[idx].
     order_catalog_cd, cpo.order_synonym_id = orders->qual[idx].order_synonym_id,
     cpo.status_cd = orders->qual[idx].status_cd, cpo.status_dt_tm = cnvtdatetime(orders->qual[idx].
      status_dt_tm), cpo.status_dt_nbr = orders->qual[idx].status_dt_nbr,
     cpo.status_min_nbr = orders->qual[idx].status_min_nbr, cpo.status_prsnl_id = orders->qual[idx].
     status_prsnl_id, cpo.included_ind = orders->qual[idx].included_ind,
     cpo.included_dt_tm =
     IF ((orders->qual[idx].included_ind=1)) cnvtdatetime(orders->qual[idx].included_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     , cpo.included_dt_nbr =
     IF ((orders->qual[idx].included_ind=1)) orders->qual[idx].included_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     , cpo.included_min_nbr =
     IF ((orders->qual[idx].included_ind=1)) orders->qual[idx].included_min_nbr
     ELSE zero_min_nbr
     ENDIF
     ,
     cpo.included_prsnl_id =
     IF ((orders->qual[idx].included_ind=1)) orders->qual[idx].included_prsnl_id
     ELSE 0
     ENDIF
     , cpo.excluded_ind = orders->qual[idx].excluded_ind, cpo.excluded_dt_tm =
     IF ((orders->qual[idx].excluded_ind=1)) cnvtdatetime(orders->qual[idx].excluded_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     ,
     cpo.excluded_dt_nbr =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     , cpo.excluded_min_nbr =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_min_nbr
     ELSE zero_min_nbr
     ENDIF
     , cpo.excluded_prsnl_id =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_prsnl_id
     ELSE 0
     ENDIF
     ,
     cpo.activated_ind = orders->qual[idx].activated_ind, cpo.activated_dt_tm = cnvtdatetime(orders->
      qual[idx].activated_dt_tm), cpo.activated_dt_nbr = orders->qual[idx].activated_dt_nbr,
     cpo.activated_min_nbr = orders->qual[idx].activated_min_nbr, cpo.activated_prsnl_id = orders->
     qual[idx].activated_prsnl_id, cpo.required_ind = orders->qual[idx].required_ind,
     cpo.added_ind = orders->qual[idx].added_ind, cpo.default_incl_ind = orders->qual[idx].
     default_incl_ind, cpo.type_mean = orders->qual[idx].type_mean,
     cpo.pw_phase_desc = orders->qual[idx].pw_phase_desc, cpo.pw_group_nbr = orders->qual[idx].
     pw_group_nbr, cpo.pw_cat_group_id = orders->qual[idx].pw_cat_group_id,
     cpo.pw_description = orders->qual[idx].plan_desc, cpo.pw_group_desc = orders->qual[idx].
     plan_desc, cpo.tf_description = orders->qual[idx].phase_desc,
     cpo.pathway_id = orders->qual[idx].pathway_id, cpo.pathway_catalog_id = orders->qual[idx].
     pw_catalog_id, cpo.version = orders->qual[idx].pw_version,
     cpo.category_display = orders->qual[idx].category_display, cpo.category_cd = orders->qual[idx].
     category_cd, cpo.sub_category_display = orders->qual[idx].sub_category_display,
     cpo.sub_category_cd = orders->qual[idx].sub_category_cd, cpo.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), cpo.updt_cnt = 0,
     cpo.updt_id = reqinfo->updt_id, cpo.updt_task = reqinfo->updt_task, cpo.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE update_order(idx)
   UPDATE  FROM cn_pw_order_st cpo
    SET cpo.encntr_id =
     IF ((orders->qual[idx].encntr_id != 0)) orders->qual[idx].encntr_id
     ELSE cpo.encntr_id
     ENDIF
     , cpo.order_id =
     IF ((orders->qual[idx].order_id != null)
      AND (orders->qual[idx].order_id > 0)) orders->qual[idx].order_id
     ELSE cpo.order_id
     ENDIF
     , cpo.status_cd = orders->qual[idx].status_cd,
     cpo.status_dt_tm = cnvtdatetime(orders->qual[idx].status_dt_tm), cpo.status_dt_nbr = orders->
     qual[idx].status_dt_nbr, cpo.status_min_nbr = orders->qual[idx].status_min_nbr,
     cpo.status_prsnl_id = orders->qual[idx].status_prsnl_id, cpo.included_ind =
     IF ((orders->qual[idx].included_ind=1)) orders->qual[idx].included_ind
     ELSE cpo.included_ind
     ENDIF
     , cpo.included_dt_tm = cnvtdatetime(orders->qual[idx].included_dt_tm),
     cpo.included_dt_nbr = orders->qual[idx].included_dt_nbr, cpo.included_min_nbr = orders->qual[idx
     ].included_min_nbr, cpo.included_prsnl_id =
     IF ((orders->qual[idx].included_prsnl_id != 0)
      AND (orders->qual[idx].included_prsnl_id != null)) orders->qual[idx].included_prsnl_id
     ELSE cpo.included_prsnl_id
     ENDIF
     ,
     cpo.excluded_ind =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_ind
     ELSE cpo.excluded_ind
     ENDIF
     , cpo.excluded_dt_tm =
     IF ((orders->qual[idx].excluded_ind=1)) cnvtdatetime(orders->qual[idx].excluded_dt_tm)
     ELSE cpo.excluded_dt_tm
     ENDIF
     , cpo.excluded_dt_nbr =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_dt_nbr
     ELSE cpo.excluded_dt_nbr
     ENDIF
     ,
     cpo.excluded_min_nbr =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_min_nbr
     ELSE cpo.excluded_min_nbr
     ENDIF
     , cpo.excluded_prsnl_id =
     IF ((orders->qual[idx].excluded_ind=1)) orders->qual[idx].excluded_prsnl_id
     ELSE cpo.excluded_prsnl_id
     ENDIF
     , cpo.activated_ind =
     IF ((orders->qual[idx].activated_ind=1)) orders->qual[idx].activated_ind
     ELSE cpo.activated_ind
     ENDIF
     ,
     cpo.activated_dt_tm = cnvtdatetime(orders->qual[idx].activated_dt_tm), cpo.activated_dt_nbr =
     orders->qual[idx].activated_dt_nbr, cpo.activated_min_nbr = orders->qual[idx].activated_min_nbr,
     cpo.activated_prsnl_id = orders->qual[idx].activated_prsnl_id, cpo.added_ind =
     IF ((orders->qual[idx].added_ind=1)) orders->qual[idx].added_ind
     ELSE cpo.added_ind
     ENDIF
     , cpo.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cpo.updt_cnt = (cpo.updt_cnt+ 1), cpo.updt_id = reqinfo->updt_id, cpo.updt_task = reqinfo->
     updt_task,
     cpo.updt_applctx = reqinfo->updt_applctx
    WHERE (cpo.pw_ord_comp_id=orders->qual[idx].pw_ord_comp_id)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE load_outcome_data(idx)
   SELECT INTO "nl:"
    FROM act_pw_comp apc,
     pathway_comp pc,
     outcome_catalog oc,
     outcome_activity oa,
     pw_comp_action pca,
     pathway pw,
     pathway_catalog pwc
    PLAN (apc
     WHERE expand(num,1,outcome_cnt,apc.act_pw_comp_id,request->outcomes[num].act_pw_comp_id))
     JOIN (pc
     WHERE pc.pathway_comp_id=apc.pathway_comp_id)
     JOIN (oc
     WHERE oc.outcome_catalog_id=apc.ref_prnt_ent_id)
     JOIN (oa
     WHERE oa.outcome_activity_id=apc.parent_entity_id)
     JOIN (pca
     WHERE pca.act_pw_comp_id=apc.act_pw_comp_id)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
     JOIN (pwc
     WHERE pwc.pathway_catalog_id=pw.pw_cat_group_id)
    ORDER BY apc.act_pw_comp_id, pca.pw_comp_action_seq
    HEAD REPORT
     cnt = 0
    HEAD apc.act_pw_comp_id
     cnt = (cnt+ 1)
     IF (cnt > value(size(outcomes->qual,5)))
      stat = alterlist(outcomes->qual,(cnt+ 10))
     ENDIF
     outcomes->qual[cnt].pw_out_comp_id = apc.act_pw_comp_id, outcomes->qual[cnt].pathway_comp_id =
     apc.pathway_comp_id, outcomes->qual[cnt].outcome_activity_id = apc.parent_entity_id,
     outcomes->qual[cnt].outcome_catalog_id = apc.ref_prnt_ent_id, outcomes->qual[cnt].encntr_id =
     apc.encntr_id, outcomes->qual[cnt].person_id = apc.person_id,
     outcomes->qual[cnt].event_cd = oc.event_cd, outcomes->qual[cnt].status_cd = apc.comp_status_cd,
     outcomes->qual[cnt].included_ind = apc.included_ind,
     outcomes->qual[cnt].activated_ind = apc.activated_ind, outcomes->qual[cnt].activated_dt_tm =
     cnvtdatetime(apc.activated_dt_tm), outcomes->qual[cnt].activated_dt_nbr = cnvtdate(
      cnvtdatetimeutc(apc.activated_dt_tm,2)),
     outcomes->qual[cnt].activated_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.activated_dt_tm,2),5)+ 1),
     outcomes->qual[cnt].activated_prsnl_id = apc.activated_prsnl_id, outcomes->qual[cnt].
     required_ind = apc.required_ind
     IF ((outcomes->qual[cnt].pathway_comp_id=0))
      outcomes->qual[cnt].added_ind = 1
     ELSE
      outcomes->qual[cnt].added_ind = 0
     ENDIF
     outcomes->qual[cnt].default_incl_ind = pc.include_ind, outcomes->qual[cnt].type_mean = pw
     .type_mean
     IF ((outcomes->qual[cnt].activated_ind=1))
      outcomes->qual[cnt].out_comp_description = concat(trim(oa.description)," - ",trim(oa
        .expectation))
     ELSE
      outcomes->qual[cnt].out_comp_description = concat(trim(oc.description)," - ",trim(oc
        .expectation))
     ENDIF
     outcomes->qual[cnt].pw_phase_desc = concat(trim(pw.pw_group_desc)," ",trim(pw.description)),
     outcomes->qual[cnt].pw_group_nbr = pw.pw_group_nbr
     IF (pwc.version_pw_cat_id > 0)
      outcomes->qual[cnt].pw_cat_group_id = pwc.version_pw_cat_id
     ELSE
      outcomes->qual[cnt].pw_cat_group_id = pwc.pathway_catalog_id
     ENDIF
     outcomes->qual[cnt].plan_desc = trim(pw.pw_group_desc), outcomes->qual[cnt].phase_desc = trim(pw
      .description), outcomes->qual[cnt].pathway_id = pw.pathway_id,
     outcomes->qual[cnt].pw_catalog_id = pw.pathway_catalog_id, outcomes->qual[cnt].pw_version = pw
     .pw_cat_version, outcomes->qual[cnt].category_display = uar_get_code_display(apc.dcp_clin_cat_cd
      ),
     outcomes->qual[cnt].category_cd = apc.dcp_clin_cat_cd, outcomes->qual[cnt].sub_category_display
      = uar_get_code_display(apc.dcp_clin_sub_cat_cd), outcomes->qual[cnt].sub_category_cd = apc
     .dcp_clin_sub_cat_cd,
     prev_status_cd = 0
    DETAIL
     IF (pca.comp_status_cd != prev_status_cd)
      status_changed = "Y"
     ENDIF
     IF (status_changed="Y"
      AND (outcomes->qual[cnt].status_cd=pca.comp_status_cd))
      outcomes->qual[cnt].status_dt_tm = cnvtdatetime(pca.action_dt_tm), outcomes->qual[cnt].
      status_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), outcomes->qual[cnt].
      status_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      outcomes->qual[cnt].status_prsnl_id = pca.action_prsnl_id
     ENDIF
     IF (status_changed="Y"
      AND pca.comp_status_cd=comp_activated_cd
      AND ((pca.pw_comp_action_seq=1) OR (prev_status_cd=comp_excluded_cd)) )
      outcomes->qual[cnt].included_dt_tm = cnvtdatetime(pca.action_dt_tm), outcomes->qual[cnt].
      included_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), outcomes->qual[cnt].
      included_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      outcomes->qual[cnt].included_prsnl_id = pca.action_prsnl_id
     ELSEIF (status_changed="Y"
      AND pca.comp_status_cd=comp_included_cd)
      outcomes->qual[cnt].included_dt_tm = cnvtdatetime(pca.action_dt_tm), outcomes->qual[cnt].
      included_dt_nbr = cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), outcomes->qual[cnt].
      included_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      outcomes->qual[cnt].included_prsnl_id = pca.action_prsnl_id
     ELSEIF (status_changed="Y"
      AND pca.comp_status_cd=comp_excluded_cd)
      outcomes->qual[cnt].excluded_ind = 1, outcomes->qual[cnt].excluded_dt_tm = cnvtdatetime(pca
       .action_dt_tm), outcomes->qual[cnt].excluded_dt_nbr = cnvtdate(cnvtdatetimeutc(pca
        .action_dt_tm,2)),
      outcomes->qual[cnt].excluded_min_nbr = (cnvtmin(cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
      outcomes->qual[cnt].excluded_prsnl_id = pca.action_prsnl_id
     ENDIF
     prev_status_cd = pca.comp_status_cd, status_changed = "N"
    FOOT  apc.act_pw_comp_id
     cnt = cnt
    FOOT REPORT
     stat = alterlist(outcomes->qual,cnt)
   ;end select
 END ;Subroutine
 SUBROUTINE write_outcome_data(high)
   FOR (i = 1 TO high)
    SELECT INTO "nl:"
     FROM cn_pw_outcome_st cpu
     WHERE (cpu.pw_out_comp_id=outcomes->qual[i].pw_out_comp_id)
     WITH nocounter, forupdate(cpu)
    ;end select
    IF (curqual=0)
     CALL insert_outcome(i)
    ELSE
     CALL update_outcome(i)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE insert_outcome(idx)
   INSERT  FROM cn_pw_outcome_st cpu
    SET cpu.pw_out_comp_id = outcomes->qual[idx].pw_out_comp_id, cpu.pathway_comp_id = outcomes->
     qual[idx].pathway_comp_id, cpu.pw_out_comp_ind = 1,
     cpu.out_comp_description = outcomes->qual[idx].out_comp_description, cpu.outcome_activity_id =
     outcomes->qual[idx].outcome_activity_id, cpu.outcome_catalog_id = outcomes->qual[idx].
     outcome_catalog_id,
     cpu.encntr_id = outcomes->qual[idx].encntr_id, cpu.person_id = outcomes->qual[idx].person_id,
     cpu.event_cd = outcomes->qual[idx].event_cd,
     cpu.status_cd = outcomes->qual[idx].status_cd, cpu.status_dt_tm = cnvtdatetime(outcomes->qual[
      idx].status_dt_tm), cpu.status_dt_nbr = outcomes->qual[idx].status_dt_nbr,
     cpu.status_min_nbr = outcomes->qual[idx].status_min_nbr, cpu.status_prsnl_id = outcomes->qual[
     idx].status_prsnl_id, cpu.included_ind = outcomes->qual[idx].included_ind,
     cpu.included_dt_tm =
     IF ((outcomes->qual[idx].included_ind=1)) cnvtdatetime(outcomes->qual[idx].included_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     , cpu.included_dt_nbr =
     IF ((outcomes->qual[idx].included_ind=1)) outcomes->qual[idx].included_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     , cpu.included_min_nbr =
     IF ((outcomes->qual[idx].included_ind=1)) outcomes->qual[idx].included_min_nbr
     ELSE zero_min_nbr
     ENDIF
     ,
     cpu.included_prsnl_id =
     IF ((outcomes->qual[idx].included_ind=1)) outcomes->qual[idx].included_prsnl_id
     ELSE 0
     ENDIF
     , cpu.excluded_ind = outcomes->qual[idx].excluded_ind, cpu.excluded_dt_tm =
     IF ((outcomes->qual[idx].excluded_ind=1)) cnvtdatetime(outcomes->qual[idx].excluded_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     ,
     cpu.excluded_dt_nbr =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     , cpu.excluded_min_nbr =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_min_nbr
     ELSE zero_min_nbr
     ENDIF
     , cpu.excluded_prsnl_id =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_prsnl_id
     ELSE 0
     ENDIF
     ,
     cpu.activated_ind = outcomes->qual[idx].activated_ind, cpu.activated_dt_tm = cnvtdatetime(
      outcomes->qual[idx].activated_dt_tm), cpu.activated_dt_nbr = outcomes->qual[idx].
     activated_dt_nbr,
     cpu.activated_min_nbr = outcomes->qual[idx].activated_min_nbr, cpu.activated_prsnl_id = outcomes
     ->qual[idx].activated_prsnl_id, cpu.required_ind = outcomes->qual[idx].required_ind,
     cpu.added_ind = outcomes->qual[idx].added_ind, cpu.default_incl_ind = outcomes->qual[idx].
     default_incl_ind, cpu.type_mean = outcomes->qual[idx].type_mean,
     cpu.pw_phase_desc = outcomes->qual[idx].pw_phase_desc, cpu.pw_group_nbr = outcomes->qual[idx].
     pw_group_nbr, cpu.pw_cat_group_id = outcomes->qual[idx].pw_cat_group_id,
     cpu.pw_description = outcomes->qual[idx].plan_desc, cpu.pw_group_desc = outcomes->qual[idx].
     plan_desc, cpu.tf_description = outcomes->qual[idx].phase_desc,
     cpu.pathway_id = outcomes->qual[idx].pathway_id, cpu.pathway_catalog_id = outcomes->qual[idx].
     pw_catalog_id, cpu.version = outcomes->qual[idx].pw_version,
     cpu.category_display = outcomes->qual[idx].category_display, cpu.category_cd = outcomes->qual[
     idx].category_cd, cpu.sub_category_display = outcomes->qual[idx].sub_category_display,
     cpu.sub_category_cd = outcomes->qual[idx].sub_category_cd, cpu.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), cpu.updt_cnt = 0,
     cpu.updt_id = reqinfo->updt_id, cpu.updt_task = reqinfo->updt_task, cpu.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE update_outcome(idx)
   UPDATE  FROM cn_pw_outcome_st cpu
    SET cpu.encntr_id =
     IF ((outcomes->qual[idx].encntr_id != 0)) outcomes->qual[idx].encntr_id
     ELSE cpu.encntr_id
     ENDIF
     , cpu.outcome_activity_id =
     IF ((outcomes->qual[idx].outcome_activity_id != null)
      AND (outcomes->qual[idx].outcome_activity_id > 0)) outcomes->qual[idx].outcome_activity_id
     ELSE cpu.outcome_activity_id
     ENDIF
     , cpu.status_cd = outcomes->qual[idx].status_cd,
     cpu.status_dt_tm = cnvtdatetime(outcomes->qual[idx].status_dt_tm), cpu.status_dt_nbr = outcomes
     ->qual[idx].status_dt_nbr, cpu.status_min_nbr = outcomes->qual[idx].status_min_nbr,
     cpu.status_prsnl_id = outcomes->qual[idx].status_prsnl_id, cpu.included_ind =
     IF ((outcomes->qual[idx].included_ind=1)) outcomes->qual[idx].included_ind
     ELSE cpu.included_ind
     ENDIF
     , cpu.included_dt_tm = cnvtdatetime(outcomes->qual[idx].included_dt_tm),
     cpu.included_dt_nbr = outcomes->qual[idx].included_dt_nbr, cpu.included_min_nbr = outcomes->
     qual[idx].included_min_nbr, cpu.included_prsnl_id =
     IF ((outcomes->qual[idx].included_prsnl_id != 0)
      AND (outcomes->qual[idx].included_prsnl_id != null)) outcomes->qual[idx].included_prsnl_id
     ELSE cpu.included_prsnl_id
     ENDIF
     ,
     cpu.excluded_ind =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_ind
     ELSE cpu.excluded_ind
     ENDIF
     , cpu.excluded_dt_tm =
     IF ((outcomes->qual[idx].excluded_ind=1)) cnvtdatetime(outcomes->qual[idx].excluded_dt_tm)
     ELSE cpu.excluded_dt_tm
     ENDIF
     , cpu.excluded_dt_nbr =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_dt_nbr
     ELSE cpu.excluded_dt_nbr
     ENDIF
     ,
     cpu.excluded_min_nbr =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_min_nbr
     ELSE cpu.excluded_min_nbr
     ENDIF
     , cpu.excluded_prsnl_id =
     IF ((outcomes->qual[idx].excluded_ind=1)) outcomes->qual[idx].excluded_prsnl_id
     ELSE cpu.excluded_prsnl_id
     ENDIF
     , cpu.activated_ind =
     IF ((outcomes->qual[idx].activated_ind=1)) outcomes->qual[idx].activated_ind
     ELSE cpu.activated_ind
     ENDIF
     ,
     cpu.activated_dt_tm = cnvtdatetime(outcomes->qual[idx].activated_dt_tm), cpu.activated_dt_nbr =
     outcomes->qual[idx].activated_dt_nbr, cpu.activated_min_nbr = outcomes->qual[idx].
     activated_min_nbr,
     cpu.activated_prsnl_id = outcomes->qual[idx].activated_prsnl_id, cpu.added_ind =
     IF ((outcomes->qual[idx].added_ind=1)) outcomes->qual[idx].added_ind
     ELSE cpu.added_ind
     ENDIF
     , cpu.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cpu.updt_cnt = (cpu.updt_cnt+ 1), cpu.updt_id = reqinfo->updt_id, cpu.updt_task = reqinfo->
     updt_task,
     cpu.updt_applctx = reqinfo->updt_applctx
    WHERE (cpu.pw_out_comp_id=outcomes->qual[idx].pw_out_comp_id)
    WITH nocounter
   ;end update
 END ;Subroutine
#end_program
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD phases
 FREE RECORD orders
 FREE RECORD outcomes
END GO
