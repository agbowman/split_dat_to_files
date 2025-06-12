CREATE PROGRAM bed_get_pp_by_placehldr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 power_plans[*]
      2 power_plan_id = f8
      2 display_description = vc
      2 testing_ind = i2
      2 components[*]
        3 id = f8
      2 vv_all_facilities_ind = i2
      2 vv_facilities[*]
        3 id = f8
        3 display = vc
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
 SET place_count = size(request->placeholders,5)
 DECLARE ppt_cnt = i4
 IF (place_count=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_pw_comp_placehldr_r pw_place_r,
   pathway_comp pw_cmp,
   pathway_catalog pw_cat,
   pw_cat_reltn pw_reltn,
   pathway_catalog pw_cat_pp,
   (dummyt d  WITH seq = value(place_count))
  PLAN (d)
   JOIN (pw_place_r
   WHERE (pw_place_r.br_pw_comp_placehldr_id=request->placeholders[d.seq].placehldr_id))
   JOIN (pw_cmp
   WHERE pw_cmp.pathway_uuid=pw_place_r.pathway_uuid
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
  ORDER BY pw_cat_pp.pathway_catalog_id, pw_cat.pathway_catalog_id, pw_cmp.pathway_comp_id
  HEAD REPORT
   pp_cnt = 0, ppt_cnt = 0, stat = alterlist(reply->power_plans,10)
  HEAD pw_cat_pp.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id > 0
    AND pw_cat.type_mean="PHASE"
    AND pw_cat.ref_owner_person_id=0.0)
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    cmp_cnt = 0, cmpt_cnt = 0, stat = alterlist(reply->power_plans[ppt_cnt].components,10),
    reply->power_plans[ppt_cnt].power_plan_id = pw_cat_pp.pathway_catalog_id, reply->power_plans[
    ppt_cnt].display_description = pw_cat_pp.display_description
    IF (pw_cat_pp.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     reply->power_plans[ppt_cnt].testing_ind = 1
    ENDIF
   ENDIF
  HEAD pw_cat.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id=0
    AND pw_cat.type_mean="CAREPLAN"
    AND pw_cat.ref_owner_person_id=0.0)
    pp_cnt = (pp_cnt+ 1), ppt_cnt = (ppt_cnt+ 1)
    IF (pp_cnt > 10)
     stat = alterlist(reply->power_plans,(ppt_cnt+ 10)), pp_cnt = 1
    ENDIF
    cmp_cnt = 0, cmpt_cnt = 0, stat = alterlist(reply->power_plans[ppt_cnt].components,10),
    reply->power_plans[ppt_cnt].power_plan_id = pw_cat.pathway_catalog_id, reply->power_plans[ppt_cnt
    ].display_description = pw_cat.display_description
    IF (pw_cat.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     reply->power_plans[ppt_cnt].testing_ind = 1
    ENDIF
   ENDIF
  HEAD pw_cmp.pathway_comp_id
   cmp_cnt = (cmp_cnt+ 1), cmpt_cnt = (cmpt_cnt+ 1)
   IF (cmp_cnt > 10)
    stat = alterlist(reply->power_plans[ppt_cnt].components,(cmpt_cnt+ 10)), cmp_cnt = 1
   ENDIF
   reply->power_plans[ppt_cnt].components[cmpt_cnt].id = pw_cmp.pathway_comp_id
  FOOT  pw_cat.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id=0
    AND pw_cat.type_mean="CAREPLAN"
    AND pw_cat.ref_owner_person_id=0.0)
    stat = alterlist(reply->power_plans[ppt_cnt].components,cmpt_cnt)
   ENDIF
  FOOT  pw_cat_pp.pathway_catalog_id
   IF (pw_cat_pp.pathway_catalog_id > 0
    AND pw_cat.type_mean="PHASE"
    AND pw_cat.ref_owner_person_id=0.0)
    stat = alterlist(reply->power_plans[ppt_cnt].components,cmpt_cnt)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->power_plans,ppt_cnt)
  WITH nocount
 ;end select
 IF (ppt_cnt > 0)
  SELECT INTO "nl:"
   FROM pw_cat_flex f,
    code_value f_cv,
    (dummyt d_pp  WITH seq = value(ppt_cnt))
   PLAN (d_pp)
    JOIN (f
    WHERE (f.pathway_catalog_id=reply->power_plans[d_pp.seq].power_plan_id)
     AND f.parent_entity_name="CODE_VALUE")
    JOIN (f_cv
    WHERE f_cv.code_value=f.parent_entity_id)
   ORDER BY d_pp.seq
   HEAD d_pp.seq
    fac_iter = 0, fac_cnt = 0, stat = alterlist(reply->power_plans[d_pp.seq].vv_facilities,10)
   DETAIL
    IF (f_cv.code_value=0.0)
     reply->power_plans[d_pp.seq].vv_all_facilities_ind = 1
    ELSEIF (f_cv.active_ind=1)
     fac_iter = (fac_iter+ 1), fac_cnt = (fac_cnt+ 1)
     IF (fac_iter > 10)
      stat = alterlist(reply->power_plans[d_pp.seq].vv_facilities,(fac_cnt+ 10)), fac_iter = 1
     ENDIF
     reply->power_plans[d_pp.seq].vv_facilities[fac_cnt].id = f.parent_entity_id, reply->power_plans[
     d_pp.seq].vv_facilities[fac_cnt].display = f_cv.display
    ENDIF
   FOOT  d_pp.seq
    stat = alterlist(reply->power_plans[d_pp.seq].vv_facilities,fac_cnt)
   WITH nocount
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
