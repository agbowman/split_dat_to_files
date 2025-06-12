CREATE PROGRAM bed_get_pp_with_warnings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 power_plans[*]
      2 power_plan_id = f8
      2 display_description = vc
      2 version = i4
      2 active_ind = i2
      2 highest_powerplan_ver_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
      2 uuid = vc
      2 updt_cnt = i4
      2 synonym_inactive_ind = i2
      2 synonym_type_invalid_ind = i2
      2 virtual_view_warn_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD plan_temp(
   1 power_plans[*]
     2 power_plan_id = f8
     2 display_description = vc
     2 version = i4
     2 active_ind = i2
     2 highest_powerplan_ver_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 uuid = vc
     2 updt_cnt = i4
     2 synonym_inactive_ind = i2
     2 synonym_type_invalid_ind = i2
     2 virtual_view_warn_ind = i2
     2 vv_all_facilities_ind = i2
     2 vv_facility[*]
       3 id = f8
     2 phases[*]
       3 phase_id = f8
 )
 RECORD phase_temp(
   1 phases[*]
     2 phase_id = f8
     2 synonym_inactive_ind = i2
     2 synonym_type_invalid_ind = i2
     2 virtual_view_warn_ind = i2
 )
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE med_ord_ct_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE med_ord_at_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE clin_cat_disp_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 SET total_pp_cnt = 0
 SET total_phase_cnt = 0
 SET cnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog p
  PLAN (p
   WHERE p.type_mean="CAREPLAN"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY p.pathway_catalog_id
  HEAD REPORT
   total_pp_cnt = 0, total_phase_cnt = 0, stat = alterlist(plan_temp->power_plans,10),
   stat = alterlist(phase_temp->phases,10)
  HEAD p.pathway_catalog_id
   cnt = (cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1), total_phase_cnt = (total_phase_cnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10)), stat = alterlist(phase_temp
     ->phases,(total_phase_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,1), plan_temp->power_plans[
   total_pp_cnt].phases[1].phase_id = p.pathway_catalog_id, phase_temp->phases[total_phase_cnt].
   phase_id = p.pathway_catalog_id
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt), stat = alterlist(phase_temp->phases,
    total_phase_cnt)
  WITH nocounter
 ;end select
 SET plan_cnt = 0
 SET plan_phase_cnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_reltn pcr
  PLAN (p
   WHERE p.type_mean="PATHWAY"
    AND p.display_method_cd=clin_cat_disp_method_cd
    AND p.ref_owner_person_id=0
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=p.pathway_catalog_id
    AND pcr.type_mean="GROUP")
  ORDER BY p.pathway_catalog_id, pcr.pw_cat_t_id
  HEAD REPORT
   total_pp_cnt = size(plan_temp->power_plans,5), total_phase_cnt = size(phase_temp->phases,5),
   plan_cnt = 0,
   stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10))
  HEAD p.pathway_catalog_id
   plan_cnt = (plan_cnt+ 1), total_pp_cnt = (total_pp_cnt+ 1)
   IF (plan_cnt > 10)
    plan_cnt = 1, stat = alterlist(plan_temp->power_plans,(total_pp_cnt+ 10))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].power_plan_id = p.pathway_catalog_id, plan_temp->power_plans[
   total_pp_cnt].display_description = p.display_description, plan_temp->power_plans[total_pp_cnt].
   version = p.version,
   plan_temp->power_plans[total_pp_cnt].active_ind = p.active_ind, plan_temp->power_plans[
   total_pp_cnt].highest_powerplan_ver_id = p.version_pw_cat_id, plan_temp->power_plans[total_pp_cnt]
   .beg_effective_dt_tm = p.beg_effective_dt_tm,
   plan_temp->power_plans[total_pp_cnt].end_effective_dt_tm = p.end_effective_dt_tm, plan_temp->
   power_plans[total_pp_cnt].uuid = p.pathway_uuid, plan_temp->power_plans[total_pp_cnt].updt_cnt = p
   .updt_cnt,
   total_plan_phase_cnt = 0, plan_phase_cnt = 0, stat = alterlist(plan_temp->power_plans[total_pp_cnt
    ].phases,5)
  HEAD pcr.pw_cat_t_id
   plan_phase_cnt = (plan_phase_cnt+ 1), total_plan_phase_cnt = (total_plan_phase_cnt+ 1)
   IF (plan_phase_cnt > 5)
    plan_phase_cnt = 1, stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,(
     total_plan_phase_cnt+ 5))
   ENDIF
   plan_temp->power_plans[total_pp_cnt].phases[total_plan_phase_cnt].phase_id = pcr.pw_cat_t_id,
   total_phase_cnt = (total_phase_cnt+ 1), stat = alterlist(phase_temp->phases,total_phase_cnt),
   phase_temp->phases[total_phase_cnt].phase_id = pcr.pw_cat_t_id
  FOOT  p.pathway_catalog_id
   stat = alterlist(plan_temp->power_plans[total_pp_cnt].phases,total_plan_phase_cnt)
  FOOT REPORT
   stat = alterlist(plan_temp->power_plans,total_pp_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_pp_cnt)),
   pw_cat_flex pcf,
   code_value cv
  PLAN (d)
   JOIN (pcf
   WHERE (pcf.pathway_catalog_id=plan_temp->power_plans[d.seq].power_plan_id)
    AND pcf.parent_entity_name="CODE_VALUE")
   JOIN (cv
   WHERE cv.code_value=outerjoin(pcf.parent_entity_id)
    AND cv.active_ind=outerjoin(1))
  ORDER BY d.seq, cv.code_value
  HEAD d.seq
   fcnt = 0, ftcnt = 0, stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,10)
  HEAD cv.code_value
   IF (pcf.parent_entity_id=0)
    plan_temp->power_plans[d.seq].vv_all_facilities_ind = 1
   ELSEIF (cv.code_value > 0)
    fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
    IF (fcnt > 10)
     stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,(ftcnt+ 10)), fcnt = 1
    ENDIF
    plan_temp->power_plans[d.seq].vv_facility[ftcnt].id = cv.code_value
   ENDIF
  FOOT  d.seq
   stat = alterlist(plan_temp->power_plans[d.seq].vv_facility,ftcnt)
  WITH nocounter
 ;end select
 FREE SET temp_vv
 RECORD temp_vv(
   1 all_ind = i2
   1 vv[*]
     2 id = f8
 )
 SELECT INTO "nl:"
  FROM pathway_comp pc,
   order_catalog_synonym ocs,
   code_value cv_mt,
   ocs_facility_r ofr,
   (dummyt d  WITH seq = value(total_phase_cnt))
  PLAN (d)
   JOIN (pc
   WHERE (phase_temp->phases[d.seq].phase_id=pc.pathway_catalog_id)
    AND pc.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND pc.active_ind=1)
   JOIN (ocs
   WHERE outerjoin(pc.parent_entity_id)=ocs.synonym_id)
   JOIN (cv_mt
   WHERE outerjoin(ocs.mnemonic_type_cd)=cv_mt.code_value)
   JOIN (ofr
   WHERE outerjoin(ocs.synonym_id)=ofr.synonym_id)
  ORDER BY d.seq, ocs.synonym_id
  HEAD d.seq
   cnt = 0
  HEAD ocs.synonym_id
   IF (ocs.active_ind=0)
    phase_temp->phases[d.seq].synonym_inactive_ind = 1
   ENDIF
   IF (ocs.synonym_id > 0)
    IF (pc.comp_type_cd=prescription_comp_cd)
     IF ( NOT (cv_mt.cdf_meaning IN ("GENERICPROD", "GENERICTOP", "TRADETOP", "TRADEPROD", "PRIMARY",
     "BRANDNAME")))
      phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
     ENDIF
    ELSEIF (pc.comp_type_cd=order_comp_cd)
     IF (ocs.catalog_type_cd=med_ord_ct_cd
      AND ocs.activity_type_cd=med_ord_at_cd
      AND ocs.orderable_type_flag IN (0, 1, 8, 11))
      IF ( NOT (cv_mt.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICNAME", "GENERICTOP",
      "IVNAME", "PRIMARY", "TRADETOP")))
       phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
      ENDIF
     ELSE
      IF ( NOT (cv_mt.cdf_meaning IN ("DCP", "PRIMARY")))
       phase_temp->phases[d.seq].synonym_type_invalid_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   cnt = 0, vv_cnt = 0, stat = alterlist(temp_vv->vv,10)
  DETAIL
   IF (ofr.facility_cd=0
    AND ofr.synonym_id > 0)
    temp_vv->all_ind = 1
   ELSEIF (ofr.facility_cd > 0)
    cnt = (cnt+ 1), vv_cnt = (vv_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(temp_vv->vv,(vv_cnt+ 10)), cnt = 1
    ENDIF
    temp_vv->vv[vv_cnt].id = ofr.facility_cd
   ENDIF
  FOOT  ocs.synonym_id
   IF ((temp_vv->all_ind=0))
    FOR (p = 1 TO total_pp_cnt)
      tempphasecnt = size(plan_temp->power_plans[p].phases,5), tempplanvvcnt = size(plan_temp->
       power_plans[p].vv_facility,5)
      FOR (t = 1 TO tempphasecnt)
        IF ((phase_temp->phases[d.seq].phase_id=plan_temp->power_plans[p].phases[t].phase_id))
         IF ((((plan_temp->power_plans[p].vv_all_facilities_ind=1)) OR (vv_cnt=0
          AND tempplanvvcnt > 0)) )
          plan_temp->power_plans[p].virtual_view_warn_ind = 1
         ELSE
          FOR (v = 1 TO tempplanvvcnt)
            found = 0
            FOR (tv = 1 TO vv_cnt)
              IF ((plan_temp->power_plans[p].vv_facility[v].id=temp_vv->vv[tv].id))
               found = 1
              ENDIF
            ENDFOR
            IF (found=0)
             plan_temp->power_plans[p].virtual_view_warn_ind = 1
            ENDIF
          ENDFOR
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   stat = initrec(temp_vv)
  WITH nocounter
 ;end select
 FOR (p = 1 TO total_phase_cnt)
   IF ((((phase_temp->phases[p].synonym_inactive_ind=1)) OR ((phase_temp->phases[p].
   synonym_type_invalid_ind=1))) )
    FOR (pt = 1 TO total_pp_cnt)
     SET phasecnt = size(plan_temp->power_plans[pt].phases,5)
     FOR (h = 1 TO phasecnt)
       IF ((plan_temp->power_plans[pt].phases[h].phase_id=phase_temp->phases[p].phase_id))
        IF ((phase_temp->phases[p].synonym_inactive_ind=1))
         SET plan_temp->power_plans[pt].synonym_inactive_ind = 1
        ENDIF
        IF ((phase_temp->phases[p].synonym_type_invalid_ind=1))
         SET plan_temp->power_plans[pt].synonym_type_invalid_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(total_pp_cnt))
  PLAN (d
   WHERE (((plan_temp->power_plans[d.seq].synonym_inactive_ind=1)) OR ((((plan_temp->power_plans[d
   .seq].synonym_type_invalid_ind=1)) OR ((plan_temp->power_plans[d.seq].virtual_view_warn_ind=1)))
   )) )
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->power_plans,total_pp_cnt)
  HEAD d.seq
   cnt = (cnt+ 1), reply->power_plans[cnt].power_plan_id = plan_temp->power_plans[d.seq].
   power_plan_id, reply->power_plans[cnt].active_ind = plan_temp->power_plans[d.seq].active_ind,
   reply->power_plans[cnt].beg_effective_dt_tm = plan_temp->power_plans[d.seq].beg_effective_dt_tm,
   reply->power_plans[cnt].display_description = plan_temp->power_plans[d.seq].display_description,
   reply->power_plans[cnt].end_effective_dt_tm = plan_temp->power_plans[d.seq].end_effective_dt_tm,
   reply->power_plans[cnt].highest_powerplan_ver_id = plan_temp->power_plans[d.seq].
   highest_powerplan_ver_id, reply->power_plans[cnt].synonym_inactive_ind = plan_temp->power_plans[d
   .seq].synonym_inactive_ind, reply->power_plans[cnt].synonym_type_invalid_ind = plan_temp->
   power_plans[d.seq].synonym_type_invalid_ind,
   reply->power_plans[cnt].updt_cnt = plan_temp->power_plans[d.seq].updt_cnt, reply->power_plans[cnt]
   .uuid = plan_temp->power_plans[d.seq].uuid, reply->power_plans[cnt].version = plan_temp->
   power_plans[d.seq].version,
   reply->power_plans[cnt].virtual_view_warn_ind = plan_temp->power_plans[d.seq].
   virtual_view_warn_ind
  FOOT REPORT
   stat = alterlist(reply->power_plans,cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
