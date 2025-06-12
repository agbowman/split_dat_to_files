CREATE PROGRAM bed_get_power_plan_by_syn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 synonym_id = f8
      2 power_plans[*]
        3 power_plan_id = f8
        3 display_description = vc
        3 version = i4
        3 active_ind = i2
        3 highest_powerplan_ver_id = f8
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 uuid = vc
        3 updt_cnt = i4
        3 test_version_exists_ind = i2
        3 vv_all_facilities_ind = i2
        3 vv_facility[*]
          4 id = f8
          4 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET syn_count = size(request->synonyms,5)
 IF (syn_count=0)
  GO TO exit_script
 ENDIF
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE facility_count = i4 WITH noconstant(0), protect
 DECLARE alter_facility_count = i4 WITH noconstant(0), protect
 SET stat = alterlist(reply->synonyms,syn_count)
 FOR (x = 1 TO syn_count)
   SET reply->synonyms[x].synonym_id = request->synonyms[x].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM pathway_comp pw_cmp,
   pathway_catalog pw_cat,
   pw_cat_reltn pw_reltn,
   pathway_catalog pw_cat_pp,
   (dummyt d  WITH seq = value(syn_count))
  PLAN (d)
   JOIN (pw_cmp
   WHERE ((pw_cmp.comp_type_cd=order_comp_cd
    AND (request->synonyms[d.seq].comp_type IN ("NONMED", "MED"))) OR (pw_cmp.comp_type_cd=
   prescription_comp_cd
    AND (request->synonyms[d.seq].comp_type="PRESCRIPTION")))
    AND (pw_cmp.parent_entity_id=request->synonyms[d.seq].synonym_id)
    AND pw_cmp.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND pw_cmp.active_ind=1)
   JOIN (pw_cat
   WHERE pw_cat.pathway_catalog_id=pw_cmp.pathway_catalog_id
    AND pw_cat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pw_reltn
   WHERE pw_reltn.pw_cat_t_id=outerjoin(pw_cat.pathway_catalog_id)
    AND pw_reltn.type_mean=outerjoin("GROUP"))
   JOIN (pw_cat_pp
   WHERE pw_cat_pp.pathway_catalog_id=outerjoin(pw_reltn.pw_cat_s_id)
    AND pw_cat_pp.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY d.seq, pw_cat_pp.pathway_catalog_id, pw_cat.pathway_catalog_id
  HEAD d.seq
   pp_cnt = 0, ppt_cnt = 0, stat = alterlist(reply->synonyms[d.seq].power_plans,10)
  HEAD pw_cat_pp.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id != 0
    AND pw_cat.type_mean="PHASE"
    AND pw_cat.ref_owner_person_id=0.0)
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->synonyms[d.seq].power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    reply->synonyms[d.seq].power_plans[ppt_cnt].power_plan_id = pw_cat_pp.pathway_catalog_id, reply->
    synonyms[d.seq].power_plans[ppt_cnt].display_description = pw_cat_pp.display_description, reply->
    synonyms[d.seq].power_plans[ppt_cnt].version = pw_cat_pp.version,
    reply->synonyms[d.seq].power_plans[ppt_cnt].active_ind = pw_cat_pp.active_ind, reply->synonyms[d
    .seq].power_plans[ppt_cnt].highest_powerplan_ver_id = pw_cat_pp.version_pw_cat_id, reply->
    synonyms[d.seq].power_plans[ppt_cnt].beg_effective_dt_tm = pw_cat_pp.beg_effective_dt_tm,
    reply->synonyms[d.seq].power_plans[ppt_cnt].end_effective_dt_tm = pw_cat_pp.end_effective_dt_tm,
    reply->synonyms[d.seq].power_plans[ppt_cnt].uuid = pw_cat_pp.pathway_uuid, reply->synonyms[d.seq]
    .power_plans[ppt_cnt].updt_cnt = pw_cat_pp.updt_cnt
   ENDIF
  HEAD pw_cat.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id=0
    AND pw_cat.type_mean="CAREPLAN"
    AND pw_cat.ref_owner_person_id=0.0)
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->synonyms[d.seq].power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    reply->synonyms[d.seq].power_plans[ppt_cnt].power_plan_id = pw_cat.pathway_catalog_id, reply->
    synonyms[d.seq].power_plans[ppt_cnt].display_description = pw_cat.display_description, reply->
    synonyms[d.seq].power_plans[ppt_cnt].version = pw_cat.version,
    reply->synonyms[d.seq].power_plans[ppt_cnt].active_ind = pw_cat.active_ind, reply->synonyms[d.seq
    ].power_plans[ppt_cnt].highest_powerplan_ver_id = pw_cat.version_pw_cat_id, reply->synonyms[d.seq
    ].power_plans[ppt_cnt].beg_effective_dt_tm = pw_cat.beg_effective_dt_tm,
    reply->synonyms[d.seq].power_plans[ppt_cnt].end_effective_dt_tm = pw_cat.end_effective_dt_tm,
    reply->synonyms[d.seq].power_plans[ppt_cnt].uuid = pw_cat.pathway_uuid, reply->synonyms[d.seq].
    power_plans[ppt_cnt].updt_cnt = pw_cat.updt_cnt
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->synonyms[d.seq].power_plans,ppt_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pathway_catalog pw_cat,
   (dummyt d_syn  WITH seq = value(syn_count)),
   (dummyt d_pp  WITH seq = value(1))
  PLAN (d_syn
   WHERE maxrec(d_pp,size(reply->synonyms[d_syn.seq].power_plans,5)))
   JOIN (d_pp)
   JOIN (pw_cat
   WHERE (pw_cat.pathway_uuid=reply->synonyms[d_syn.seq].power_plans[d_pp.seq].uuid)
    AND pw_cat.type_mean != "PHASE"
    AND pw_cat.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pw_cat.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pw_cat.ref_owner_person_id=0.0)
  ORDER BY d_syn.seq, d_pp.seq, pw_cat.pathway_uuid
  DETAIL
   reply->synonyms[d_syn.seq].power_plans[d_pp.seq].test_version_exists_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_cat_flex p,
   code_value c,
   (dummyt d_syn  WITH seq = value(syn_count)),
   (dummyt d_pp  WITH seq = value(1))
  PLAN (d_syn
   WHERE maxrec(d_pp,size(reply->synonyms[d_syn.seq].power_plans,5)))
   JOIN (d_pp)
   JOIN (p
   WHERE (p.pathway_catalog_id=reply->synonyms[d_syn.seq].power_plans[d_pp.seq].power_plan_id)
    AND p.parent_entity_name=outerjoin("CODE_VALUE"))
   JOIN (c
   WHERE c.code_value=outerjoin(p.parent_entity_id))
  DETAIL
   IF (c.code_value=0.0)
    reply->synonyms[d_syn.seq].power_plans[d_pp.seq].vv_all_facilities_ind = 1
   ENDIF
   IF (c.active_ind=1)
    facility_count = (facility_count+ 1), stat = alterlist(reply->synonyms[d_syn.seq].power_plans[
     d_pp.seq].vv_facility,facility_count), reply->synonyms[d_syn.seq].power_plans[d_pp.seq].
    vv_facility[facility_count].id = p.parent_entity_id,
    reply->synonyms[d_syn.seq].power_plans[d_pp.seq].vv_facility[facility_count].display = c.display
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
