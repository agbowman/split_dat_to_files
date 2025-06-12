CREATE PROGRAM afc_ct_get_rulesets:dba
 DECLARE afc_ct_get_rulesets_version = vc WITH private, noconstant("318193.FT.002")
 RECORD reply(
   1 ruleset_cnt = i4
   1 rulesets[*]
     2 ruleset_id = f8
     2 ruleset_name = vc
     2 priority_nbr = i4
     2 process_ind = i2
     2 active_ind = i2
     2 updt_cnt = i4
     2 tier_row[1]
       3 tier_id = f8
       3 health_plan_excl_ind = i2
       3 org_excl_ind = i2
       3 ins_org_excl_ind = i2
       3 encntr_type_excl_ind = i2
       3 fin_class_excl_ind = i2
       3 encntr_type_class_excl_ind = i2
       3 health_plan[*]
         4 health_plan_id = f8
         4 health_plan_disp = vc
       3 org[*]
         4 org_id = f8
         4 org_disp = vc
       3 ins_org[*]
         4 ins_org_id = f8
         4 ins_org_disp = vc
       3 encntr_type[*]
         4 encntr_type_cd = f8
       3 encntr_class[*]
         4 encntr_class_cd = f8
       3 fin_class[*]
         4 fin_class_cd = f8
       3 charge_status_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE hpidx = i4 WITH protect, noconstant(0)
 DECLARE orgidx = i4 WITH protect, noconstant(0)
 DECLARE insidx = i4 WITH protect, noconstant(0)
 DECLARE encntrtypeidx = i4 WITH protect, noconstant(0)
 DECLARE encntrclassidx = i4 WITH protect, noconstant(0)
 DECLARE finidx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM cs_cpp_ruleset r,
   cs_cpp_tier t,
   cs_cpp_tier_detail td,
   health_plan h,
   organization o,
   organization io
  PLAN (r
   WHERE r.cs_cpp_ruleset_id != 0.0
    AND r.active_ind=1)
   JOIN (t
   WHERE t.cs_cpp_ruleset_id=outerjoin(r.cs_cpp_ruleset_id)
    AND t.cs_cpp_tier_id != outerjoin(0.0)
    AND t.active_ind=outerjoin(1))
   JOIN (td
   WHERE td.cs_cpp_tier_id=outerjoin(t.cs_cpp_tier_id)
    AND td.active_ind=outerjoin(1))
   JOIN (h
   WHERE h.health_plan_id=outerjoin(td.cs_cpp_tier_detail_entity_id))
   JOIN (o
   WHERE o.organization_id=outerjoin(td.cs_cpp_tier_detail_entity_id))
   JOIN (io
   WHERE io.organization_id=outerjoin(td.cs_cpp_tier_detail_entity_id))
  ORDER BY t.priority_nbr, t.cs_cpp_tier_id, td.cs_cpp_tier_id,
   td.cs_cpp_tier_detail_id
  HEAD r.cs_cpp_ruleset_id
   cnt = (cnt+ 1), stat = alterlist(reply->rulesets,cnt), reply->rulesets[cnt].ruleset_id = r
   .cs_cpp_ruleset_id,
   reply->rulesets[cnt].ruleset_name = r.ruleset_name, reply->rulesets[cnt].priority_nbr = t
   .priority_nbr, reply->rulesets[cnt].process_ind = r.process_ind,
   reply->rulesets[cnt].active_ind = r.active_ind, reply->rulesets[cnt].updt_cnt = r.updt_cnt
  HEAD t.cs_cpp_tier_id
   reply->rulesets[cnt].tier_row[1].tier_id = t.cs_cpp_tier_id, reply->rulesets[cnt].tier_row[1].
   health_plan_excl_ind = t.health_plan_excld_ind, reply->rulesets[cnt].tier_row[1].org_excl_ind = t
   .organization_excld_ind,
   reply->rulesets[cnt].tier_row[1].ins_org_excl_ind = t.ins_org_excld_ind, reply->rulesets[cnt].
   tier_row[1].encntr_type_excl_ind = t.encntr_type_excld_ind, reply->rulesets[cnt].tier_row[1].
   fin_class_excl_ind = t.fin_class_excld_ind,
   reply->rulesets[cnt].tier_row[1].charge_status_ind = t.charge_status_ind, reply->rulesets[cnt].
   tier_row[1].encntr_type_class_excl_ind = t.encntr_type_class_excld_ind, hpidx = 0,
   orgidx = 0, insidx = 0, encntrtypeidx = 0,
   encntrclassidx = 0, finidx = 0
  HEAD td.cs_cpp_tier_detail_id
   IF (td.cs_cpp_tier_detail_entity_name="CODE_VALUE")
    IF (td.cs_cpp_tier_detail_subtype="ENCNTR_TYPE")
     encntrtypeidx = (encntrtypeidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].
      encntr_type,encntrtypeidx), reply->rulesets[cnt].tier_row[1].encntr_type[encntrtypeidx].
     encntr_type_cd = td.cs_cpp_tier_detail_entity_id
    ENDIF
    IF (td.cs_cpp_tier_detail_subtype="ENCNTR_TYPE_CLASS")
     encntrclassidx = (encntrclassidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].
      encntr_class,encntrclassidx), reply->rulesets[cnt].tier_row[1].encntr_class[encntrclassidx].
     encntr_class_cd = td.cs_cpp_tier_detail_entity_id
    ENDIF
    IF (td.cs_cpp_tier_detail_subtype="FIN_CLASS")
     finidx = (finidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].fin_class,finidx), reply
     ->rulesets[cnt].tier_row[1].fin_class[finidx].fin_class_cd = td.cs_cpp_tier_detail_entity_id
    ENDIF
    IF (td.cs_cpp_tier_detail_subtype="INSURANCE_ORG")
     insidx = (insidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].ins_org,insidx), reply->
     rulesets[cnt].tier_row[1].ins_org[insidx].ins_org_id = io.organization_id,
     reply->rulesets[cnt].tier_row[1].ins_org[insidx].ins_org_disp = io.org_name
    ENDIF
   ENDIF
   IF (td.cs_cpp_tier_detail_entity_name="HEALTH_PLAN")
    hpidx = (hpidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].health_plan,hpidx), reply->
    rulesets[cnt].tier_row[1].health_plan[hpidx].health_plan_id = h.health_plan_id,
    reply->rulesets[cnt].tier_row[1].health_plan[hpidx].health_plan_disp = h.plan_name
   ENDIF
   IF (td.cs_cpp_tier_detail_entity_name="ORGANIZATION")
    orgidx = (orgidx+ 1), stat = alterlist(reply->rulesets[cnt].tier_row[1].org,orgidx), reply->
    rulesets[cnt].tier_row[1].org[orgidx].org_id = o.organization_id,
    reply->rulesets[cnt].tier_row[1].org[orgidx].org_disp = o.org_name
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reply->ruleset_cnt = size(reply->rulesets,5)
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
