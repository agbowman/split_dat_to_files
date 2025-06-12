CREATE PROGRAM ccps_drv_post_doc:dba
 SET post_doc_rec->extended_api_flag = 1
 EXECUTE pm_drv_post_doc
 IF (bdebug)
  CALL echorecord(post_doc_rec)
 ENDIF
 DECLARE insured_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"INSURED")), protect
 DECLARE dnokcd = f8 WITH constant(uar_get_code_by("MEANING",351,"NOK")), protect
 DECLARE demccd = f8 WITH constant(uar_get_code_by("MEANING",351,"EMC")), protect
 DECLARE dguarantorcd = f8 WITH constant(uar_get_code_by("MEANING",351,"DEFGUAR")), protect
 DECLARE addr_home_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"HOME")), protect
 DECLARE addr_bus_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"BUSINESS")), protect
 DECLARE dsub01pprid = f8 WITH noconstant(0.0), protect
 DECLARE dsub01eprid = f8 WITH noconstant(0.0), protect
 DECLARE dsub02pprid = f8 WITH noconstant(0.0), protect
 DECLARE dsub02eprid = f8 WITH noconstant(0.0), protect
 DECLARE dsub03pprid = f8 WITH noconstant(0.0), protect
 DECLARE dsub03eprid = f8 WITH noconstant(0.0), protect
 RECORD addl_rec(
   1 facilitydesc = vc
   1 patient_disease_alert = vc
   1 guarantor_religion = vc
   1 nok_sex = vc
   1 emc_sex = vc
   1 sub01_plan_reltn_id = f8
   1 sub01_fin_class = vc
   1 sub01_group_name = vc
   1 sub01_addr = vc
   1 sub01_city = vc
   1 sub01_state = vc
   1 sub01_zip = vc
   1 sub01_hp_auth01_authcon = vc
   1 sub02_plan_reltn_id = f8
   1 sub02_fin_class = vc
   1 sub02_group_name = vc
   1 sub02_addr = vc
   1 sub02_city = vc
   1 sub02_state = vc
   1 sub02_zip = vc
   1 sub02_city_state_zip = vc
   1 sub02_hp_auth01_authcon = vc
   1 sub03_plan_reltn_id = f8
   1 sub03_group_name = vc
   1 sub03_fin_class = vc
   1 sub03_addr = vc
   1 sub03_city = vc
   1 sub03_state = vc
   1 sub03_zip = vc
   1 sub03_hp_auth01_authcon = vc
   1 printed_by = vc
   1 last_prsnl_updt_dt_tm = dq8
   1 last_prsnl_updt_name = vc
 ) WITH persistscript
 SELECT INTO "NL:"
  FROM person_patient pp
  PLAN (pp
   WHERE (pp.person_id=post_doc_rec->person_id)
    AND pp.active_ind=1
    AND pp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   addl_rec->patient_disease_alert = uar_get_code_display(pp.disease_alert_cd)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM person_person_reltn ppr,
   person p
  PLAN (ppr
   WHERE (ppr.person_id=post_doc_rec->person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ppr.related_person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ppr.person_reltn_type_cd, ppr.priority_seq, ppr.internal_seq,
   cnvtdatetime(ppr.beg_effective_dt_tm), cnvtdatetime(ppr.end_effective_dt_tm)
  HEAD ppr.person_reltn_type_cd
   IF (ppr.person_reltn_type_cd=dnokcd)
    addl_rec->nok_sex = trim(uar_get_code_display(p.sex_cd),3)
   ELSEIF (ppr.person_reltn_type_cd=demccd)
    addl_rec->emc_sex = trim(uar_get_code_display(p.sex_cd),3)
   ELSEIF (ppr.person_reltn_type_cd=dguarantorcd
    AND ppr.priority_seq=1)
    addl_rec->guarantor_religion = trim(uar_get_code_display(p.religion_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM encounter e,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=post_doc_rec->encntr_id))
   JOIN (p
   WHERE p.person_id=e.updt_id)
  DETAIL
   addl_rec->facilitydesc = uar_get_code_description(e.loc_facility_cd), addl_rec->
   last_prsnl_updt_dt_tm = e.updt_dt_tm, addl_rec->last_prsnl_updt_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM encntr_plan_reltn r,
   encntr_person_reltn epr,
   person p,
   health_plan hp,
   address a
  PLAN (r
   WHERE (r.encntr_id=post_doc_rec->encntr_id)
    AND r.active_ind=1
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (epr
   WHERE epr.encntr_id=r.encntr_id
    AND epr.related_person_id=r.person_id
    AND epr.person_reltn_type_cd=insured_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.related_person_id
    AND p.active_ind=1)
   JOIN (hp
   WHERE hp.health_plan_id=r.health_plan_id)
   JOIN (a
   WHERE a.parent_entity_id=r.encntr_plan_reltn_id
    AND a.parent_entity_name="ENCNTR_PLAN_RELTN"
    AND a.address_type_cd=addr_bus_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY r.priority_seq, cnvtdatetime(r.beg_effective_dt_tm) DESC, epr.priority_seq,
   epr.internal_seq, cnvtdatetime(epr.beg_effective_dt_tm) DESC, cnvtdatetime(epr.end_effective_dt_tm
    ) DESC,
   a.address_type_seq, cnvtdatetime(a.beg_effective_dt_tm) DESC, cnvtdatetime(a.end_effective_dt_tm)
    DESC
  HEAD r.priority_seq
   IF (r.priority_seq=1)
    dsub01pprid = r.person_plan_reltn_id, dsub01eprid = r.encntr_plan_reltn_id, addl_rec->
    sub01_fin_class = uar_get_code_display(hp.financial_class_cd),
    addl_rec->sub01_group_name = r.group_name, addl_rec->sub01_addr = build2(a.street_addr), addl_rec
    ->sub01_zip = trim(a.zipcode),
    addl_rec->sub01_city = trim(a.city)
    IF (a.state_cd > 0)
     addl_rec->sub01_state = uar_get_code_display(a.state_cd)
    ELSE
     addl_rec->sub01_state = trim(a.state)
    ENDIF
   ELSEIF (r.priority_seq=2)
    dsub02pprid = r.person_plan_reltn_id, dsub02eprid = r.encntr_plan_reltn_id, addl_rec->
    sub02_fin_class = uar_get_code_display(hp.financial_class_cd),
    addl_rec->sub02_group_name = r.group_name, addl_rec->sub02_addr = build2(a.street_addr), addl_rec
    ->sub02_zip = trim(a.zipcode),
    addl_rec->sub02_city = trim(a.city)
    IF (a.state_cd > 0)
     addl_rec->sub02_state = uar_get_code_display(a.state_cd)
    ELSE
     addl_rec->sub02_state = trim(a.state)
    ENDIF
   ELSEIF (r.priority_seq=3)
    dsub03pprid = r.person_plan_reltn_id, dsub03eprid = r.encntr_plan_reltn_id, addl_rec->
    sub03_fin_class = uar_get_code_display(hp.financial_class_cd),
    addl_rec->sub03_group_name = r.group_name, addl_rec->sub03_addr = build2(a.street_addr), addl_rec
    ->sub03_zip = trim(a.zipcode),
    addl_rec->sub03_city = trim(a.city)
    IF (a.state_cd > 0)
     addl_rec->sub03_state = uar_get_code_display(a.state_cd)
    ELSE
     addl_rec->sub03_state = trim(a.state)
    ENDIF
   ENDIF
  FOOT  r.priority_seq
   null
  WITH nocounter
 ;end select
 IF (((textlen(trim(addl_rec->sub01_fin_class,3))=0) OR (((textlen(trim(addl_rec->sub02_fin_class,3))
 =0) OR (textlen(trim(addl_rec->sub03_fin_class,3))=0)) )) )
  SELECT INTO "nl:"
   FROM person_plan_reltn r,
    person_person_reltn ppr,
    health_plan hp
   PLAN (r
    WHERE (r.person_id=post_doc_rec->person_id)
     AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND r.active_ind=1)
    JOIN (ppr
    WHERE ppr.related_person_id=outerjoin(r.subscriber_person_id)
     AND ppr.person_reltn_type_cd=outerjoin(insured_cd)
     AND ppr.active_ind=outerjoin(1)
     AND ppr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (hp
    WHERE hp.health_plan_id=outerjoin(r.health_plan_id))
   ORDER BY r.priority_seq, r.beg_effective_dt_tm DESC, ppr.priority_seq,
    ppr.internal_seq, ppr.beg_effective_dt_tm DESC, ppr.end_effective_dt_tm DESC
   HEAD r.priority_seq
    IF (r.priority_seq=1
     AND size(trim(addl_rec->sub01_fin_class,3))=0)
     dsub01pprid = r.person_plan_reltn_id, addl_rec->sub01_fin_class = uar_get_code_display(hp
      .financial_class_cd)
    ELSEIF (r.priority_seq=2
     AND size(trim(addl_rec->sub02_fin_class,3))=0)
     dsub02pprid = r.person_plan_reltn_id, addl_rec->sub02_fin_class = uar_get_code_display(hp
      .financial_class_cd)
    ELSEIF (r.priority_seq=3
     AND size(trim(addl_rec->sub03_fin_class,3))=0)
     dsub03pprid = r.person_plan_reltn_id, addl_rec->sub03_fin_class = uar_get_code_display(hp
      .financial_class_cd)
    ENDIF
   FOOT  r.priority_seq
    null
   WITH nocounter
  ;end select
 ENDIF
 IF ((post_doc_rec->encntr_id > 0.0))
  SET addl_rec->sub01_plan_reltn_id = dsub01eprid
  SET addl_rec->sub02_plan_reltn_id = dsub02eprid
  SET addl_rec->sub03_plan_reltn_id = dsub03eprid
 ELSE
  SET addl_rec->sub01_plan_reltn_id = dsub01pprid
  SET addl_rec->sub02_plan_reltn_id = dsub02pprid
  SET addl_rec->sub03_plan_reltn_id = dsub03pprid
 ENDIF
 SELECT INTO "NL:"
  ad.auth_detail_id
  FROM encntr_plan_auth_r epa,
   authorization auth,
   auth_detail ad
  PLAN (epa
   WHERE epa.encntr_plan_reltn_id IN (addl_rec->sub01_plan_reltn_id, addl_rec->sub02_plan_reltn_id,
   addl_rec->sub03_plan_reltn_id)
    AND ((epa.encntr_plan_reltn_id+ 0) > 0.0)
    AND epa.active_ind=1
    AND epa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND epa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (auth
   WHERE auth.authorization_id=epa.authorization_id
    AND auth.active_ind=1)
   JOIN (ad
   WHERE ad.authorization_id=auth.authorization_id
    AND ((ad.authorization_id+ 0) > 0.0)
    AND ad.active_ind=1
    AND ad.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ad.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY auth.authorization_id, cnvtdatetime(auth.beg_effective_dt_tm), cnvtdatetime(ad
    .beg_effective_dt_tm)
  HEAD epa.encntr_plan_reltn_id
   CASE (epa.encntr_plan_reltn_id)
    OF addl_rec->sub01_plan_reltn_id:
     addl_rec->sub01_hp_auth01_authcon = trim(ad.auth_contact,3)
    OF addl_rec->sub02_plan_reltn_id:
     addl_rec->sub02_hp_auth01_authcon = trim(ad.auth_contact,3)
    OF addl_rec->sub03_plan_reltn_id:
     addl_rec->sub03_hp_auth01_authcon = trim(ad.auth_contact,3)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   addl_rec->printed_by = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (bdebug)
  CALL echorecord(addl_rec)
 ENDIF
 SET last_mod = "003  06/22/12  MW017700"
END GO
