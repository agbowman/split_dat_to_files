CREATE PROGRAM agc_test_ins:dba
 SET ssn_alias_cd = uar_get_code_by("MEANING",4,"SSN")
 SET bus_address_cd = uar_get_code_by("MEANING",212,"BUSINESS")
 SET bus_phone_cd = uar_get_code_by("MEANING",43,"BUSINESS")
 SELECT INTO  $1
  e.encntr_id, e.encntr_plan_reltn_id, e.end_effective_dt_tm,
  e.member_nbr, e.group_nbr, e.person_id,
  e.organization_id, e.active_ind, h.beg_effective_dt_tm,
  h.end_effective_dt_tm, h.plan_name, plan_type_disp = uar_get_code_display(h.plan_type_cd),
  org.org_name, o.group_nbr, o.organization_id,
  a.street_addr, a.street_addr2, a.state,
  a.city, a.zipcode, p.phone_num,
  code1 = decode(a.seq,1,p.seq,2,3), pe.name_full_formatted, pe.birth_dt_tm,
  sex_cd = uar_get_code_display(pe.sex_cd), pa.alias, pa.alias_pool_cd,
  code1 = decode(a.seq,1,p.seq,2,3), state_cd = uar_get_code_display(a.state_cd)
  FROM encntr_plan_reltn e,
   person pe,
   person_alias pa,
   health_plan h,
   org_plan_reltn o,
   dummyt d1,
   organization org,
   dummyt d2,
   address a,
   dummyt d3,
   phone p
  PLAN (e
   WHERE e.encntr_id=2419452
    AND e.active_ind=1
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (h
   WHERE h.health_plan_id=e.health_plan_id
    AND h.active_ind=1)
   JOIN (pe
   WHERE pe.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(e.person_id)
    AND outerjoin(ssn_alias_cd)=pa.person_alias_type_cd
    AND outerjoin(1)=pa.active_ind)
   JOIN (o
   WHERE o.health_plan_id=h.health_plan_id
    AND o.organization_id=e.organization_id
    AND o.active_ind=1)
   JOIN (d1)
   JOIN (org
   WHERE org.organization_id=o.organization_id)
   JOIN (d2)
   JOIN (a
   WHERE o.health_plan_id=a.parent_entity_id
    AND a.active_ind=1
    AND a.address_type_cd=bus_address_cd
    AND a.parent_entity_name="ORGANIZATION")
   JOIN (d3)
   JOIN (p
   WHERE o.health_plan_id=p.parent_entity_id
    AND p.active_ind=1
    AND p.phone_type_cd=bus_phone_cd
    AND p.parent_entity_name="ORGANIZATION")
  ORDER BY e.encntr_plan_reltn_id
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
   dontcare = org, dontcare = a, dontcare = p,
   format, separator = " "
 ;end select
END GO
