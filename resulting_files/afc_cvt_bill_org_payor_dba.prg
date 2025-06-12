CREATE PROGRAM afc_cvt_bill_org_payor:dba
 RECORD parent_entity(
   1 pe_qual = i4
   1 pe[*]
     2 bill_org_type_cd = f8
     2 org_payor_id = f8
 )
 RECORD tiergroup_cv(
   1 tg_num = i2
   1 tg_cd[*]
     2 tg_cv = f8
 )
 SET wl_group_cv = 0.0
 SET code_set = 13031
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="STANDARD"
   AND a.active_ind=1
  DETAIL
   wl_group_cv = a.code_value
  WITH nocounter
 ;end select
 CALL echo(build("WL CV: ",wl_group_cv))
 SET count1 = 0
 SET tg_string = fillstring(200," ")
 SET tg_string = "parent_entity->pe[d1.seq]->bill_org_type_cd in ("
 SET code_set = 13031
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=code_set
   AND a.cdf_meaning="TIERGROUP"
   AND a.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(tiergroup_cv->tg_cd,count1), tiergroup_cv->tg_cd[count1].
   tg_cv = a.code_value
   IF (count1=1)
    tg_string = build(tg_string,tiergroup_cv->tg_cd[count1].tg_cv)
   ELSE
    tg_string = build(tg_string,","), tg_string = build(tg_string,tiergroup_cv->tg_cd[count1].tg_cv)
   ENDIF
  WITH nocounter
 ;end select
 SET tg_string = build(tg_string,")")
 SET tg_string = trim(tg_string)
 CALL echo(build("Count of tier groups : ",count1))
 CALL echo(build("TG String : ",tg_string))
 SET count2 = 0
 SELECT INTO "nl:"
  b.parent_entity_name, b.org_payor_id
  FROM bill_org_payor b
  WHERE (b.bill_org_type_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=13031
    AND ((cdf_meaning="STANDARD") OR (((cdf_meaning="TIERGROUP") OR (((cdf_meaning="FINNUM") OR (((
   cdf_meaning="CLIENTBILL") OR (cdf_meaning="BILLPERFORG")) )) )) )) ))
  DETAIL
   count2 = (count2+ 1), stat = alterlist(parent_entity->pe,count2), parent_entity->pe[count2].
   bill_org_type_cd = b.bill_org_type_cd,
   parent_entity->pe[count2].org_payor_id = b.org_payor_id
  WITH nocounter
 ;end select
 SET parent_entity->pe_qual = count2
 CALL echo(build("Qual rows : ",parent_entity->pe_qual))
 EXECUTE afc_bill_org parser(
  IF (count1 > 0) tg_string
  ELSE "0=0"
  ENDIF
  )
END GO
