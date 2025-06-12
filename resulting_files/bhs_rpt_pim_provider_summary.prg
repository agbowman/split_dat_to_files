CREATE PROGRAM bhs_rpt_pim_provider_summary
 FREE RECORD providerdsummary
 RECORD providersummary(
   1 cnt = i4
   1 qual[*]
     2 phys = f8
     2 phytype = c1
     2 phyposition = vc
     2 totalmedordered = i4
     2 totalalerts = i4
     2 totalpatseen = i4
     2 percentoverrride = f8
     2 pattakemedathome = i2
     2 patfamrequest = i2
     2 riskminimal = i2
     2 alternoteffective = i2
     2 altertoomanyeffect = i2
     2 altertooexpensive = i2
     2 recomendedmed30min = i2
     2 permdisable = i2
     2 class1 = f8
     2 class2 = f8
     2 class3 = f8
     2 class4 = f8
     2 class5 = f8
     2 class6 = f8
     2 class7 = f8
     2 class8 = f8
     2 class9 = f8
     2 class10 = f8
     2 class11 = f8
     2 class12 = f8
     2 class13 = f8
     2 class14 = f8
     2 class1b = f8
     2 class2b = f8
     2 class3b = f8
     2 class4b = f8
     2 class5b = f8
     2 class6b = f8
     2 class7b = f8
     2 class8b = f8
     2 class9b = f8
     2 class10b = f8
     2 class11b = f8
     2 class12b = f8
     2 class13b = f8
     2 class14b = f8
     2 patients[*]
       3 patient = f8
       3 medication = vc
       3 action = vc
       3 medclass = vc
       3 orderid = f8
       3 activityid = f8
       3 encntrid = f8
       3 phyreltn = vc
       3 recomendedmed30min = i2
       3 reason = vc
       3 alertdate = dq8
       3 age = vc
       3 assoind = i2
       3 eventfnd = i2
 )
 FREE RECORD displine
 RECORD displine(
   1 cnt = i4
   1 qual[*]
     2 phys = f8
     2 phytype = c1
     2 phyposition = vc
     2 totalmedordered = i4
     2 totalalerts = i4
     2 totalpatseen = i4
     2 percentoverrride = f8
     2 pattakemedathome = i2
     2 patfamrequest = i2
     2 riskminimal = i2
     2 alternoteffective = i2
     2 altertoomanyeffect = i2
     2 altertooexpensive = i2
     2 permdisable = i2
     2 class1 = i2
     2 class2 = i2
     2 class3 = i2
     2 class4 = i2
     2 class5 = i2
     2 class6 = i2
     2 class7 = i2
     2 class8 = i2
     2 class9 = i2
     2 class10 = i2
     2 class11 = i2
     2 class12 = i2
     2 class13 = i2
     2 class14 = i2
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
 DECLARE totalmeds = i4
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
  FROM bhs_pim_provider bpp,
   prsnl pr
  PLAN (bpp
   WHERE bpp.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=bpp.prsnl_id)
  HEAD REPORT
   stat = alterlist(providersummary->qual,100)
  DETAIL
   providersummary->cnt += 1
   IF (mod(providersummary->cnt,10)=1
    AND (providersummary->cnt > 100))
    stat = alterlist(providersummary->qual,(providersummary->cnt+ 9))
   ENDIF
   providersummary->qual[providersummary->cnt].phys = bpp.prsnl_id, providersummary->qual[
   providersummary->cnt].phytype = bpp.group_role, providersummary->qual[providersummary->cnt].
   phyposition = uar_get_code_display(pr.position_cd)
  FOOT REPORT
   stat = alterlist(providersummary->qual,providersummary->cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  age = trim(replace(cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)),"Years","",0),
   4)
  FROM (dummyt d  WITH seq = value(providersummary->cnt)),
   bhs_pim_alert_activity alert,
   encounter e,
   person p
  PLAN (d)
   JOIN (alert
   WHERE (alert.prsnl_id=providersummary->qual[d.seq].phys))
   JOIN (e
   WHERE e.encntr_id=alert.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY d.seq
  HEAD REPORT
   override = 0
  HEAD d.seq
   stat = alterlist(providersummary->qual[d.seq].patients,100), totalpatseen = 0, override = 0
  DETAIL
   IF (cnvtint(age) > 64)
    totalpatseen += 1
    IF (mod(totalpatseen,10)=1
     AND totalpatseen > 100)
     stat = alterlist(providersummary->qual[d.seq].patients,(totalpatseen+ 9))
    ENDIF
    IF (alert.override_reason_cd > 0)
     override += 1
    ENDIF
    providersummary->qual[d.seq].patients[totalpatseen].patient = e.person_id, providersummary->qual[
    d.seq].patients[totalpatseen].age = age, providersummary->qual[d.seq].patients[totalpatseen].
    encntrid = alert.encntr_id,
    providersummary->qual[d.seq].patients[totalpatseen].orderid = alert.order_id, providersummary->
    qual[d.seq].patients[totalpatseen].activityid = alert.activity_id, providersummary->qual[d.seq].
    patients[totalpatseen].alertdate = alert.create_dt_tm,
    providersummary->qual[d.seq].patients[totalpatseen].assoind = alert.assoc_orders_ind,
    providersummary->qual[d.seq].patients[totalpatseen].eventfnd = alert.events_found_ind,
    providersummary->qual[d.seq].patients[totalpatseen].reason =
    IF (alert.override_reason_cd=259179745) "patient taking this med at home"
    ELSEIF (alert.override_reason_cd=259179750) "patient/family requested"
    ELSEIF (alert.override_reason_cd=259179755) "risk is minimal"
    ELSEIF (alert.override_reason_cd=259179760) "alternative not effective"
    ELSEIF (alert.override_reason_cd=259179765) "alternative has too many side effects"
    ELSEIF (alert.override_reason_cd=259179770) "alternative too expensive"
    ELSEIF (alert.override_reason_cd=259179775) "perm disable alert for all patients"
    ELSE cnvtstring(alert.override_reason_cd)
    ENDIF
    IF (alert.override_reason_cd=259179745)
     providersummary->qual[d.seq].pattakemedathome += 1
    ELSEIF (alert.override_reason_cd=259179750)
     providersummary->qual[d.seq].patfamrequest += 1
    ELSEIF (alert.override_reason_cd=259179755)
     providersummary->qual[d.seq].riskminimal += 1
    ELSEIF (alert.override_reason_cd=259179760)
     providersummary->qual[d.seq].alternoteffective += 1
    ELSEIF (alert.override_reason_cd=259179765)
     providersummary->qual[d.seq].altertoomanyeffect += 1
    ELSEIF (alert.override_reason_cd=259179770)
     providersummary->qual[d.seq].altertooexpensive += 1
    ELSEIF (alert.override_reason_cd=259179775)
     providersummary->qual[d.seq].permdisable += 1
    ENDIF
   ENDIF
  FOOT  d.seq
   stat = alterlist(providersummary->qual[d.seq].patients,totalpatseen), providersummary->qual[d.seq]
   .totalpatseen = totalpatseen, providersummary->qual[d.seq].percentoverrride = override
  WITH nocounter
 ;end select
 FOR (x = 1 TO providersummary->cnt)
   IF (size(providersummary->qual[x].patients,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(providersummary->qual[x].patients,5))),
      bhs_pim_assoc_orders bpao,
      bhs_pim_alert_activity alert
     PLAN (d
      WHERE d.seq > 0)
      JOIN (bpao
      WHERE (bpao.activity_id=providersummary->qual[x].patients[d.seq].activityid)
       AND expand(indx,1,drugs->cnt,bpao.order_id,drugs->qual[indx].dcode))
      JOIN (alert
      WHERE bpao.activity_id=alert.activity_id)
     DETAIL
      providersummary->qual[x].totalalerts += 1, providersummary->qual[x].patients[d.seq].medication
       = uar_get_code_display(bpao.order_id), providersummary->qual[x].patients[d.seq].medclass =
      trim(bpao.order_type,3)
      FOR (class = 1 TO pim_drugs->drug_class_cnt)
        FOR (drug = 1 TO pim_drugs->drug_classes[class].drug_cnt)
          IF ((bpao.order_id=pim_drugs->drug_classes[class].drugs[drug].catalog_cd))
           CASE (class)
            OF 1:
             providersummary->qual[x].class1 += 1
            OF 2:
             providersummary->qual[x].class2 += 1
            OF 3:
             providersummary->qual[x].class3 += 1
            OF 4:
             providersummary->qual[x].class4 += 1
            OF 5:
             providersummary->qual[x].class5 += 1
            OF 6:
             providersummary->qual[x].class6 += 1
            OF 7:
             providersummary->qual[x].class7 += 1
            OF 8:
             providersummary->qual[x].class8 += 1
            OF 9:
             providersummary->qual[x].class9 += 1
            OF 10:
             providersummary->qual[x].class10 += 1
            OF 11:
             providersummary->qual[x].class11 += 1
            OF 12:
             providersummary->qual[x].class12 += 1
            OF 13:
             providersummary->qual[x].class13 += 1
            OF 14:
             providersummary->qual[x].class14 += 1
           ENDCASE
           IF (alert.override_reason_cd > 0)
            CASE (class)
             OF 1:
              providersummary->qual[x].class1b += 1
             OF 2:
              providersummary->qual[x].class2b += 1
             OF 3:
              providersummary->qual[x].class3b += 1
             OF 4:
              providersummary->qual[x].class4b += 1
             OF 5:
              providersummary->qual[x].class5b += 1
             OF 6:
              providersummary->qual[x].class6b += 1
             OF 7:
              providersummary->qual[x].class7b += 1
             OF 8:
              providersummary->qual[x].class8b += 1
             OF 9:
              providersummary->qual[x].class9b += 1
             OF 10:
              providersummary->qual[x].class10b += 1
             OF 11:
              providersummary->qual[x].class11b += 1
             OF 12:
              providersummary->qual[x].class12b += 1
             OF 13:
              providersummary->qual[x].class13b += 1
             OF 14:
              providersummary->qual[x].class14b += 1
            ENDCASE
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     FOOT REPORT
      providersummary->qual[x].percentoverrride = ((providersummary->qual[x].percentoverrride/
      providersummary->qual[x].totalalerts) * 100)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(providersummary->qual[x].patients,5))),
      encntr_prsnl_reltn epr
     PLAN (d)
      JOIN (epr
      WHERE (epr.encntr_id=providersummary->qual[x].patients[d.seq].encntrid)
       AND (epr.prsnl_person_id=providersummary->qual[x].phys)
       AND epr.end_effective_dt_tm > sysdate)
     ORDER BY d.seq
     HEAD d.seq
      providersummary->qual[x].patients[d.seq].phyreltn = uar_get_code_display(epr.encntr_prsnl_r_cd)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(providersummary->qual[x].patients,5))),
      orders o
     PLAN (d)
      JOIN (o
      WHERE (o.encntr_id=providersummary->qual[x].patients[d.seq].encntrid)
       AND ((o.activity_type_cd+ 0)=705)
       AND o.template_order_id=0)
     DETAIL
      IF ((providersummary->qual[x].phytype="I")
       AND locateval(indx,1,rdrugs->cnt,o.catalog_cd,rdrugs->qual[indx].dcode))
       IF (datetimediff(o.orig_order_dt_tm,providersummary->qual[x].patients[d.seq].alertdate,4) > 0
        AND datetimediff(o.orig_order_dt_tm,providersummary->qual[x].patients[d.seq].alertdate,4) <
       31)
        providersummary->qual[x].recomendedmed30min += 1
       ENDIF
      ENDIF
     FOOT REPORT
      providersummary->qual[x].totalmedordered = count(o.order_id)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(providersummary)
 SELECT INTO "pim_phy_rpt"
  physician = substring(1,20,cnvtstring(providersummary->qual[d.seq].phys)), group = substring(1,2,
   providersummary->qual[d.seq].phytype), position = substring(1,30,providersummary->qual[d.seq].
   phyposition),
  total_med_orders = substring(1,10,cnvtstring(providersummary->qual[d.seq].totalmedordered)),
  total_alerts = substring(1,10,cnvtstring(providersummary->qual[d.seq].totalalerts)), total_patients
   = substring(1,10,cnvtstring(providersummary->qual[d.seq].totalpatseen)),
  percent_override = substring(1,10,cnvtstring(providersummary->qual[d.seq].percentoverrride)),
  recommended_med_30_min = substring(1,10,cnvtstring(providersummary->qual[d.seq].recomendedmed30min)
   ), patient_taking_this_med_at_home = substring(1,10,cnvtstring(providersummary->qual[d.seq].
    pattakemedathome)),
  patient_family_requested = substring(1,10,cnvtstring(providersummary->qual[d.seq].patfamrequest)),
  risck_minimal = substring(1,10,cnvtstring(providersummary->qual[d.seq].riskminimal)),
  alternative_not_effective = substring(1,10,cnvtstring(providersummary->qual[d.seq].
    alternoteffective)),
  alternative_has_too_many_side_effects = substring(1,10,cnvtstring(providersummary->qual[d.seq].
    altertoomanyeffect)), alternative_too_expensive = substring(1,10,cnvtstring(providersummary->
    qual[d.seq].altertooexpensive)), perm_disable_alert_all_patients = substring(1,10,cnvtstring(
    providersummary->qual[d.seq].permdisable)),
  class1 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class1b/ providersummary->qual[d
    .seq].class1) * 100))), class2 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class2b
    / providersummary->qual[d.seq].class2) * 100))), class3 = substring(1,10,cnvtstring(((
    providersummary->qual[d.seq].class3b/ providersummary->qual[d.seq].class3) * 100))),
  class4 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class4b/ providersummary->qual[d
    .seq].class4) * 100))), class5 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class5b
    / providersummary->qual[d.seq].class5) * 100))), class6 = substring(1,10,cnvtstring(((
    providersummary->qual[d.seq].class6b/ providersummary->qual[d.seq].class6) * 100))),
  class7 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class7b/ providersummary->qual[d
    .seq].class7) * 100))), class8 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class8b
    / providersummary->qual[d.seq].class8) * 100))), class9 = substring(1,10,cnvtstring(((
    providersummary->qual[d.seq].class9b/ providersummary->qual[d.seq].class9) * 100))),
  class10 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class10b/ providersummary->qual[
    d.seq].class10) * 100))), class11 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].
    class11b/ providersummary->qual[d.seq].class11) * 100))), class12 = substring(1,10,cnvtstring(((
    providersummary->qual[d.seq].class12b/ providersummary->qual[d.seq].class12) * 100))),
  class13 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].class13b/ providersummary->qual[
    d.seq].class13) * 100))), class14 = substring(1,10,cnvtstring(((providersummary->qual[d.seq].
    class14b/ providersummary->qual[d.seq].class14) * 100)))
  FROM (dummyt d  WITH seq = value(providersummary->cnt))
  PLAN (d)
  WITH nocounter, format, separator = ","
 ;end select
#end_script
END GO
