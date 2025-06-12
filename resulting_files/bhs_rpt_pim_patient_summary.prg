CREATE PROGRAM bhs_rpt_pim_patient_summary
 FREE RECORD patsummary
 RECORD patsummary(
   1 cnt = i4
   1 qual[*]
     2 pat = f8
     2 attn = c1
     2 name = vc
     2 fin = vc
     2 age = vc
     2 sex = vc
     2 icnt = i2
     2 ccnt = i2
     2 ppr = vc
     2 totalmedsbyppr = i4
     2 restraintind = i2
     2 constcompind = i2
     2 antipsychind = i2
     2 quetiapine = i2
     2 alerts[*]
       3 code = f8
       3 phy = f8
       3 phyppr = cv
       3 orddate = dq8
       3 encntrid = f8
       3 personid = f8
       3 orderid = f8
       3 activityid = f8
       3 encntrfin = vc
       3 restraintind = i2
       3 constcompind = i2
       3 antipsychind = i2
 )
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 id = f8
     2 oid = f8
     2 pid = f8
     2 name = vc
     2 age = vc
     2 sex = vc
 )
 FREE RECORD drugs
 RECORD drugs(
   1 cnt = i4
   1 qual[*]
     2 dcode = f8
 )
 FREE RECORD rdrugs
 RECORD rdrugs(
   1 cnt = i4
   1 qual[*]
     2 dcode = f8
 )
 DECLARE indx = i4
 EXECUTE bhs_pim_drug_lists
 FOR (x = 1 TO pim_drugs->drug_class_cnt)
   FOR (y = 1 TO pim_drugs->drug_classes[x].drug_cnt)
     SET drugs->cnt += 1
     SET stat = alterlist(drugs->qual,drugs->cnt)
     SET drugs->qual[drugs->cnt].dcode = pim_drugs->drug_classes[x].drugs[y].catalog_cd
   ENDFOR
 ENDFOR
 FOR (x = 1 TO pim_drugs->drug_class_cnt)
   FOR (y = 1 TO pim_drugs->drug_classes[x].rcmd_cnt)
     SET rdrugs->cnt += 1
     SET stat = alterlist(rdrugs->qual,rdrugs->cnt)
     SET rdrugs->qual[rdrugs->cnt].dcode = pim_drugs->drug_classes[x].rcmd_drugs[y].catalog_cd
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  alert.order_id, age = trim(replace(cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1
      )),"Years","",0),4)
  FROM bhs_pim_alert_activity alert,
   bhs_pim_assoc_orders bpao,
   encounter e,
   person p
  PLAN (alert
   WHERE alert.activity_id <= 20878.0)
   JOIN (bpao
   WHERE bpao.activity_id=alert.activity_id
    AND expand(indx,1,drugs->cnt,bpao.order_id,drugs->qual[indx].dcode))
   JOIN (e
   WHERE e.encntr_id=alert.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY alert.order_id, 0
  HEAD alert.order_id
   IF (cnvtint(age) > 64)
    temp->cnt += 1, stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].oid = alert
    .order_id,
    temp->qual[temp->cnt].id = alert.encntr_id, temp->qual[temp->cnt].pid = p.person_id, temp->qual[
    temp->cnt].name = p.name_full_formatted,
    temp->qual[temp->cnt].age = cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),
    temp->qual[temp->cnt].sex = uar_get_code_display(p.sex_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pid = temp->qual[d.seq].pid, eid = temp->qual[d.seq].id, oid = temp->qual[d.seq].oid,
  name = temp->qual[d.seq].name, age = temp->qual[d.seq].age, sex = temp->qual[d.seq].sex
  FROM (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d
   WHERE d.seq > 0)
  ORDER BY eid, oid, 0
  HEAD eid
   patsummary->cnt += 1, stat = alterlist(patsummary->qual,patsummary->cnt), patsummary->qual[
   patsummary->cnt].pat = pid,
   patsummary->qual[patsummary->cnt].name = name, patsummary->qual[patsummary->cnt].age = age,
   patsummary->qual[patsummary->cnt].sex = sex,
   ecnt = 0
  DETAIL
   ecnt += 1, stat = alterlist(patsummary->qual[patsummary->cnt].alerts,ecnt), patsummary->qual[
   patsummary->cnt].alerts[ecnt].encntrid = eid,
   patsummary->qual[patsummary->cnt].alerts[ecnt].personid = pid, patsummary->qual[patsummary->cnt].
   alerts[ecnt].orderid = oid
  WITH nocounter
 ;end select
 FOR (x = 1 TO patsummary->cnt)
   IF (size(patsummary->qual[x].alerts,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(patsummary->qual[x].alerts,5))),
      bhs_pim_alert_activity alert,
      bhs_pim_assoc_orders bpao
     PLAN (d)
      JOIN (alert
      WHERE (alert.encntr_id=patsummary->qual[x].alerts[d.seq].encntrid)
       AND (alert.order_id=patsummary->qual[x].alerts[d.seq].orderid))
      JOIN (bpao
      WHERE bpao.activity_id=alert.activity_id
       AND expand(indx,1,drugs->cnt,bpao.order_id,drugs->qual[indx].dcode))
     DETAIL
      patsummary->qual[x].alerts[d.seq].code = bpao.order_id, patsummary->qual[x].alerts[d.seq].
      orddate = alert.create_dt_tm, patsummary->qual[x].alerts[d.seq].orderid = alert.order_id,
      patsummary->qual[x].alerts[d.seq].phy = alert.prsnl_id
     FOOT REPORT
      patsummary->qual[x].totalmedsbyppr = count(bpao.order_id)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(patsummary->qual[x].alerts,5))),
      bhs_pim_provider bpp,
      encntr_prsnl_reltn epr
     PLAN (d)
      JOIN (bpp
      WHERE (bpp.prsnl_id=patsummary->qual[x].alerts[d.seq].phy))
      JOIN (epr
      WHERE (epr.encntr_id= Outerjoin(patsummary->qual[x].alerts[d.seq].encntrid))
       AND (epr.prsnl_person_id= Outerjoin(patsummary->qual[x].alerts[d.seq].phy))
       AND (epr.encntr_prsnl_r_cd= Outerjoin(1119)) )
     DETAIL
      patsummary->qual[x].ppr = bpp.group_role
     FOOT REPORT
      patsummary->qual[x].ccnt = count(bpp.group_role
       WHERE bpp.group_role="C"), patsummary->qual[x].icnt = count(bpp.group_role
       WHERE bpp.group_role="I")
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(patsummary->qual[x].alerts,5))),
      encntr_alias ea
     PLAN (d)
      JOIN (ea
      WHERE (ea.encntr_id=patsummary->qual[x].alerts[d.seq].encntrid)
       AND ea.encntr_alias_type_cd=1077
       AND ea.end_effective_dt_tm > sysdate
       AND ea.active_ind=1)
     DETAIL
      patsummary->qual[x].alerts[d.seq].encntrfin = trim(ea.alias,3), patsummary->qual[x].fin = trim(
       ea.alias,3)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(patsummary->qual[x].alerts,5))),
      orders o
     PLAN (d)
      JOIN (o
      WHERE (o.encntr_id=patsummary->qual[x].alerts[d.seq].encntrid)
       AND o.template_order_id=0)
     DETAIL
      IF (o.catalog_cd IN (120790238.00, 792203.00, 792205.00, 792207.00, 792209.00,
      792211.00, 792213.00, 792215.00, 120790541.00, 135963366.00,
      120790130.00, 120790379.00, 120790831.00)
       AND (o.orig_order_dt_tm > patsummary->qual[x].alerts[d.seq].orddate))
       patsummary->qual[x].alerts[d.seq].restraintind += 1, patsummary->qual[x].restraintind += 1
      ELSEIF (o.catalog_cd=791988.00
       AND (o.orig_order_dt_tm > patsummary->qual[x].alerts[d.seq].orddate))
       patsummary->qual[x].alerts[d.seq].constcompind += 1, patsummary->qual[x].constcompind += 1
      ELSEIF (o.catalog_cd IN (773630.00, 773238.00, 772554.00, 773418.00, 124919393.00,
      772882.00, 908682.00)
       AND (o.orig_order_dt_tm > patsummary->qual[x].alerts[d.seq].orddate))
       patsummary->qual[x].antipsychind += 1
      ELSEIF (o.catalog_cd=773394.00
       AND (o.orig_order_dt_tm > patsummary->qual[x].alerts[d.seq].orddate))
       patsummary->qual[x].quetiapine += 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SELECT INTO "pim_patient_rpt"
  name = substring(1,50,patsummary->qual[d.seq].name), fin = substring(1,20,patsummary->qual[d.seq].
   fin), age = substring(1,20,patsummary->qual[d.seq].age),
  sex = substring(1,10,patsummary->qual[d.seq].sex), i = substring(1,10,cnvtstring(patsummary->qual[d
    .seq].icnt)), c = substring(1,10,cnvtstring(patsummary->qual[d.seq].ccnt)),
  attn = substring(1,10,patsummary->qual[d.seq].ppr), pim_meds = substring(1,10,cnvtstring(patsummary
    ->qual[d.seq].totalmedsbyppr)), restraint_orders = substring(1,10,cnvtstring(patsummary->qual[d
    .seq].restraintind)),
  companion_orders = substring(1,10,cnvtstring(patsummary->qual[d.seq].constcompind)), antipsychotic
   = substring(1,10,cnvtstring(patsummary->qual[d.seq].antipsychind)), quetiapine = substring(1,10,
   cnvtstring(patsummary->qual[d.seq].quetiapine))
  FROM (dummyt d  WITH seq = value(patsummary->cnt))
  WITH nocunter, format, separator = "|"
 ;end select
#end_script
END GO
