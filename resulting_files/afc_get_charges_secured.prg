CREATE PROGRAM afc_get_charges_secured
 SET servicedatetime = fillstring(11," ")
 CALL echo("Begin afc_get_charges_secured")
 IF ((request->corsp_activity_id=0))
  IF (( $23=false))
   IF ((request->person_id > 0))
    SELECT INTO "nl:"
     c.charge_item_id, ce.ext_m_event_id, ce.ext_p_event_id,
     c.ord_phys_id, e.encntr_id
     FROM person p,
      encounter e,
      charge c,
      charge_event ce,
      bill_item b
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND p.active_ind=1
       AND  $31)
      JOIN (e
      WHERE e.person_id=p.person_id
       AND e.active_ind=1
       AND  EXISTS (
      (SELECT
       por.organization_id
       FROM prsnl_org_reltn por
       WHERE (por.organization_id=(e.organization_id+ 0))
        AND ((por.person_id+ 0)=reqinfo->updt_id)
        AND por.active_ind=1
        AND ((por.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((por.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))))
       AND  $12
       AND  $14
       AND  $32)
      JOIN (c
      WHERE  $1
       AND  $2
       AND  $3
       AND  $4
       AND  $5
       AND  $6
       AND  $7
       AND  $8
       AND  $11
       AND  $13
       AND  $15
       AND  $16
       AND  $17
       AND  $18
       AND  $19
       AND  $20
       AND  $21
       AND  $22
       AND ((c.active_ind+ 0)=1)
       AND c.encntr_id=e.encntr_id
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND  $33)
      JOIN (ce
      WHERE ce.charge_event_id=c.charge_event_id
       AND  $9
       AND ce.active_ind=1)
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
     ORDER BY ce.ext_m_event_id, ce.ext_p_event_id, c.charge_item_id,
      0
     HEAD ce.ext_m_event_id
      firstmaster = true
     HEAD c.charge_item_id
      CALL fillchargeinfo(0)
     WITH nocounter, maxqual(c,value(cap_plus_1))
    ;end select
   ELSE
    SELECT INTO "nl:"
     c.charge_item_id, ce.ext_m_event_id, ce.ext_p_event_id,
     c.ord_phys_id, e.encntr_id
     FROM charge c,
      person p,
      encounter e,
      charge_event ce,
      bill_item b
     PLAN (c
      WHERE c.charge_item_id > 0.0
       AND  $1
       AND  $2
       AND  $3
       AND  $4
       AND  $5
       AND  $6
       AND  $7
       AND  $8
       AND  $11
       AND  $13
       AND  $15
       AND  $16
       AND  $17
       AND  $18
       AND  $19
       AND  $20
       AND  $21
       AND  $22
       AND ((c.active_ind+ 0)=1)
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND  $33)
      JOIN (p
      WHERE p.person_id=c.person_id
       AND  $31)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND e.active_ind=1
       AND  EXISTS (
      (SELECT
       por.organization_id
       FROM prsnl_org_reltn por
       WHERE (por.organization_id=(e.organization_id+ 0))
        AND ((por.person_id+ 0)=reqinfo->updt_id)
        AND por.active_ind=1
        AND ((por.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((por.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))))
       AND  $12
       AND  $14
       AND  $32)
      JOIN (ce
      WHERE ce.charge_event_id=c.charge_event_id
       AND  $9
       AND ce.active_ind=1)
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
     ORDER BY ce.ext_m_event_id, ce.ext_p_event_id, c.charge_item_id,
      0
     HEAD ce.ext_m_event_id
      firstmaster = true
     HEAD c.charge_item_id
      CALL fillchargeinfo(0)
     WITH nocounter, maxqual(c,value(cap_plus_1))
    ;end select
   ENDIF
  ELSE
   IF ((request->person_id > 0))
    SELECT INTO "nl:"
     c.charge_item_id, ce.ext_m_event_id, ce.ext_p_event_id,
     c.ord_phys_id, e.encntr_id
     FROM person p,
      encounter e,
      charge c,
      charge_event ce,
      bill_item b,
      interface_charge ic
     PLAN (p
      WHERE (p.person_id=request->person_id)
       AND p.active_ind=1
       AND  $31)
      JOIN (e
      WHERE e.person_id=p.person_id
       AND e.active_ind=1
       AND  EXISTS (
      (SELECT
       por.organization_id
       FROM prsnl_org_reltn por
       WHERE (por.organization_id=(e.organization_id+ 0))
        AND ((por.person_id+ 0)=reqinfo->updt_id)
        AND por.active_ind=1
        AND ((por.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((por.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))))
       AND  $12
       AND  $14
       AND  $32)
      JOIN (c
      WHERE  $1
       AND  $2
       AND  $3
       AND  $4
       AND  $5
       AND  $6
       AND  $7
       AND  $8
       AND  $11
       AND  $13
       AND  $15
       AND  $16
       AND  $17
       AND  $18
       AND  $19
       AND  $20
       AND  $21
       AND  $22
       AND ((c.active_ind+ 0)=1)
       AND c.encntr_id=e.encntr_id
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND  $33)
      JOIN (ce
      WHERE ce.charge_event_id=c.charge_event_id
       AND  $9
       AND ce.active_ind=1)
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
      JOIN (ic
      WHERE ic.charge_item_id=c.charge_item_id
       AND  $24
       AND ic.active_ind=1)
     ORDER BY ce.ext_m_event_id, ce.ext_p_event_id, c.charge_item_id,
      0
     HEAD ce.ext_m_event_id
      firstmaster = true
     HEAD c.charge_item_id
      CALL fillchargeinfo(0)
     WITH nocounter, maxqual(c,value(cap_plus_1))
    ;end select
   ELSE
    SELECT INTO "nl:"
     c.charge_item_id, ce.ext_m_event_id, ce.ext_p_event_id,
     c.ord_phys_id, e.encntr_id
     FROM charge c,
      person p,
      encounter e,
      charge_event ce,
      bill_item b,
      interface_charge ic
     PLAN (c
      WHERE c.charge_item_id > 0.0
       AND  $1
       AND  $2
       AND  $3
       AND  $4
       AND  $5
       AND  $6
       AND  $7
       AND  $8
       AND  $11
       AND  $13
       AND  $15
       AND  $16
       AND  $17
       AND  $18
       AND  $19
       AND  $20
       AND  $21
       AND  $22
       AND ((c.active_ind+ 0)=1)
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND  $33)
      JOIN (p
      WHERE p.person_id=c.person_id
       AND  $31)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND e.active_ind=1
       AND  EXISTS (
      (SELECT
       por.organization_id
       FROM prsnl_org_reltn por
       WHERE (por.organization_id=(e.organization_id+ 0))
        AND ((por.person_id+ 0)=reqinfo->updt_id)
        AND por.active_ind=1
        AND ((por.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
        AND ((por.end_effective_dt_tm+ 0) >= cnvtdatetime(sysdate))))
       AND  $12
       AND  $14
       AND  $32)
      JOIN (ce
      WHERE ce.charge_event_id=c.charge_event_id
       AND  $9
       AND ce.active_ind=1)
      JOIN (b
      WHERE b.bill_item_id=c.bill_item_id)
      JOIN (ic
      WHERE ic.charge_item_id=c.charge_item_id
       AND  $24
       AND ic.active_ind=1)
     ORDER BY ce.ext_m_event_id, ce.ext_p_event_id, c.charge_item_id,
      0
     HEAD ce.ext_m_event_id
      firstmaster = true
     HEAD c.charge_item_id
      CALL fillchargeinfo(0)
     WITH nocounter, maxqual(c,value(cap_plus_1))
    ;end select
   ENDIF
  ENDIF
  IF (count1 > cap)
   SET count1 = cap
  ENDIF
  SET stat = alterlist(reply->qual,count1)
  SET reply->charge_qual = count1
 ELSE
  EXECUTE afc_get_charges_for_claim
 ENDIF
 CALL echo(build("count1: ",count1))
 CALL echo("***********************************************")
 CALL echo("***********************************************")
 IF ((reply->charge_qual > 0))
  CALL echo(build("value(reply->charge_qual): ",value(reply->charge_qual)))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    charge c,
    bill_item b
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=reply->qual[d1.seq].charge_item_id))
    JOIN (b
    WHERE b.bill_item_id=c.bill_item_id)
   DETAIL
    reply->qual[d1.seq].ext_owner_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   b.bill_item_id
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    bill_item b
   PLAN (d1)
    JOIN (b
    WHERE (b.ext_parent_reference_id=reply->qual[d1.seq].ext_master_reference_id)
     AND (b.ext_parent_contributor_cd=reply->qual[d1.seq].ext_master_reference_cont_cd)
     AND b.ext_child_reference_id=0
     AND b.ext_child_contributor_cd=0
     AND ((b.active_ind+ 0)=1))
   DETAIL
    reply->qual[d1.seq].bill_item_id = b.bill_item_id, reply->qual[d1.seq].ext_description = b
    .ext_description
   WITH nocounter, orahint("index(b XIE1BILL_ITEM)")
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    bill_item b
   PLAN (d1)
    JOIN (b
    WHERE (b.ext_parent_reference_id=reply->qual[d1.seq].ext_master_reference_id)
     AND b.ext_parent_contributor_cd=ord_cat
     AND b.ext_child_reference_id != 0
     AND b.ext_child_contributor_cd=ord_cat
     AND ((b.active_ind+ 0)=1))
   DETAIL
    reply->qual[d1.seq].careset_ind = 1, reply->qual[d1.seq].ext_owner_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
  SET max_qual = 0
  SET eventcounter = 0
  SELECT INTO "nl:"
   cm.charge_mod_id, cm.charge_item_id, cm.field1_id,
   cm.field2_id, cm.field3_id, cm.field6,
   cm.field7, cm.cm1_nbr
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    charge_mod cm
   PLAN (d1
    WHERE (reply->qual[d1.seq].charge_item_id > 0))
    JOIN (cm
    WHERE (cm.charge_item_id=reply->qual[d1.seq].charge_item_id)
     AND cm.active_ind=1)
   ORDER BY cm.charge_item_id, cm.field2_id, cm.updt_dt_tm DESC
   HEAD cm.charge_item_id
    count2 = 0
   DETAIL
    IF (cm.charge_mod_id > 0
     AND (reply->qual[d1.seq].place_holder != 1))
     count2 += 1
     IF (max_qual < count2)
      max_qual = count2
     ENDIF
     stat = alterlist(reply->qual[d1.seq].bill_code,count2), reply->qual[d1.seq].bill_code[count2].
     charge_mod_id = cm.charge_mod_id, reply->qual[d1.seq].bill_code[count2].charge_item_id = cm
     .charge_item_id,
     reply->qual[d1.seq].bill_code[count2].charge_mod_type_cd = cm.charge_mod_type_cd
     IF (cm.charge_mod_type_cd=cs13019_changelog_cd)
      eventcounter += 1, stat = alterlist(changelogchargeeventids->charge_events,eventcounter),
      changelogchargeeventids->charge_events[eventcounter].charge_event_id = reply->qual[d1.seq].
      charge_event_id
     ENDIF
     reply->qual[d1.seq].bill_code[count2].field1_id = cm.field1_id, reply->qual[d1.seq].bill_code[
     count2].field6 = cm.field6, reply->qual[d1.seq].bill_code[count2].field7 = cm.field7,
     reply->qual[d1.seq].bill_code[count2].field2_id = cm.field2_id, reply->qual[d1.seq].bill_code[
     count2].field3_id = cm.field3_id, reply->qual[d1.seq].bill_code[count2].cm1_nbr = cm.cm1_nbr,
     reply->qual[d1.seq].bill_code[count2].nomen_id = cm.nomen_id, reply->qual[d1.seq].bill_code_qual
      = count2, reply->qual[d1.seq].bill_code[count2].field4_id = cm.field4_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    (dummyt d2  WITH seq = 1),
    charge_event_mod cem
   PLAN (d1
    WHERE maxrec(d2,reply->qual[d1.seq].bill_code_qual))
    JOIN (d2)
    JOIN (cem
    WHERE (cem.charge_event_id=reply->qual[d1.seq].charge_event_id)
     AND (cem.field1_id=reply->qual[d1.seq].bill_code[d2.seq].field1_id)
     AND (cem.nomen_id=reply->qual[d1.seq].bill_code[d2.seq].nomen_id)
     AND (cem.field6=reply->qual[d1.seq].bill_code[d2.seq].field6)
     AND (cem.field3_id=reply->qual[d1.seq].bill_code[d2.seq].field3_id))
   DETAIL
    reply->qual[d1.seq].bill_code[d2.seq].charge_event_mod_id = cem.charge_event_mod_id
   WITH nocounter
  ;end select
  IF (size(request->suspense_reasons,5) > 0)
   FOR (x1 = 1 TO reply->charge_qual)
     FOR (x2 = 1 TO reply->qual[x1].bill_code_qual)
       IF ((reply->qual[x1].bill_code[x2].charge_mod_type_cd=suspended))
        IF (parser(suspensereasons))
         SET reply->qual[x1].suspense_in_list = 1
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
  ENDIF
  FOR (x1 = 1 TO reply->charge_qual)
    IF ((reply->qual[x1].process_flg=2))
     FOR (x2 = 1 TO reply->qual[x1].bill_code_qual)
       IF ((reply->qual[x1].bill_code[x2].charge_mod_type_cd=suspended))
        IF ((((reply->qual[x1].bill_code[x2].field1_id=dmissingmodauth)
         AND (request->reviewed_missingmodauth=1)) OR ((((reply->qual[x1].bill_code[x2].field1_id=
        dmissingicd9)
         AND (request->reviewed_missingicd9=1)) OR ((((reply->qual[x1].bill_code[x2].field1_id=
        dmissingrenphys)
         AND (request->reviewed_missingrenphys=1)) OR ((((reply->qual[x1].bill_code[x2].field1_id=
        dmissingpatresp)
         AND (request->reviewed_missingpatresp=1)) OR ((reply->qual[x1].bill_code[x2].field1_id=
        dradreviewsuspense)
         AND (request->reviewed_radnetcoding=1))) )) )) )) )
         SET reply->qual[x1].review_in_list = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
    interface_file i
   PLAN (d1)
    JOIN (i
    WHERE (i.interface_file_id=reply->qual[d1.seq].interface_file_id)
     AND i.profit_type_cd IN (pftptacct, pftcltbill, pftcltacct))
   DETAIL
    reply->qual[d1.seq].profit_ind = 1, reply->qual[d1.seq].profit_type_cd = i.profit_type_cd
   WITH nocounter
  ;end select
  CALL echo("NOMEN")
  SELECT INTO "nl:"
   FROM nomen_entity_reltn n,
    (dummyt d1  WITH seq = value(reply->charge_qual)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,reply->qual[d1.seq].bill_code_qual))
    JOIN (d2)
    JOIN (n
    WHERE (n.parent_entity_id=reply->qual[d1.seq].bill_code[d2.seq].charge_item_id)
     AND n.parent_entity_name="CHARGE"
     AND (n.nomenclature_id=reply->qual[d1.seq].bill_code[d2.seq].nomen_id)
     AND n.active_ind=1)
   DETAIL
    reply->qual[d1.seq].bill_code[d2.seq].nomen_entity_reltn_id = n.nomen_entity_reltn_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->charge_qual > 0))
  SELECT INTO "nl:"
   ea.encntr_id
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
     AND ea.encntr_alias_type_cd=finnbr
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime))
   DETAIL
    reply->qual[d1.seq].fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.encntr_id
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
     AND ea.encntr_alias_type_cd=mrn
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime))
   DETAIL
    reply->qual[d1.seq].mrn_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM person_alias pa,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_id=reply->qual[d1.seq].person_id)
     AND pa.person_alias_type_cd=cs4_ssn
     AND ((pa.active_ind+ 0)=true)
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   DETAIL
    reply->qual[d1.seq].ssn_nbr = cnvtalias(pa.alias,pa.alias_pool_cd)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pr.person_id
   FROM prsnl pr,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (pr
    WHERE (pr.person_id=reply->qual[d1.seq].ord_phys_id)
     AND pr.physician_ind=1
     AND pr.active_ind=1)
   DETAIL
    reply->qual[d1.seq].physician_name = pr.name_full_formatted, reply->qual[d1.seq].physician_id =
    pr.person_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pr.person_id
   FROM prsnl pr,
    charge c,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (c
    WHERE (c.charge_item_id=reply->qual[d1.seq].charge_item_id))
    JOIN (pr
    WHERE pr.person_id=c.perf_phys_id
     AND pr.physician_ind=1
     AND pr.active_ind=1)
   DETAIL
    reply->qual[d1.seq].perf_physician_name = pr.name_full_formatted, stat = assign(validate(reply->
      qual[d1.seq].perf_phys_id),pr.person_id)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pr.person_id
   FROM prsnl pr,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (pr
    WHERE (pr.person_id=reply->qual[d1.seq].verify_phys_id)
     AND pr.physician_ind=1
     AND pr.active_ind=1)
   DETAIL
    reply->qual[d1.seq].verify_physician_name = pr.name_full_formatted
   WITH nocounter
  ;end select
  IF ((request->report_ind=1))
   EXECUTE afc_rpt_charge_viewer
  ENDIF
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1
    WHERE (reply->qual[d1.seq].charge_item_id > 0))
    JOIN (p
    WHERE (p.person_id=reply->qual[d1.seq].updt_id))
   DETAIL
    reply->qual[d1.seq].username = p.username
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1
    WHERE (reply->qual[d1.seq].charge_item_id > 0))
    JOIN (p
    WHERE (p.person_id=reply->qual[d1.seq].postedbyid))
   DETAIL
    reply->qual[d1.seq].postedby = p.username
   WITH nocounter
  ;end select
  IF (size(changelogchargeeventids->charge_events,5) > 0)
   SELECT INTO "n1:"
    FROM (dummyt d1  WITH seq = value(reply->charge_qual)),
     (dummyt d2  WITH seq = size(changelogchargeeventids->charge_events,5))
    PLAN (d2)
     JOIN (d1
     WHERE (changelogchargeeventids->charge_events[d2.seq].charge_event_id=reply->qual[d1.seq].
     charge_event_id))
    DETAIL
     reply->qual[d1.seq].changelog = true
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   o.org_name
   FROM organization o,
    encounter e,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (e
    WHERE (e.encntr_id=reply->qual[d1.seq].encntr_id))
    JOIN (o
    WHERE o.organization_id=e.organization_id)
   DETAIL
    reply->qual[d1.seq].org_name = o.org_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM interface_charge ic,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1
    WHERE (reply->qual[d1.seq].process_flg=999))
    JOIN (ic
    WHERE (ic.charge_item_id=reply->qual[d1.seq].charge_item_id))
   DETAIL
    reply->qual[d1.seq].interfaced_dt_tm = ic.posted_dt_tm
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM accession_order_r aor,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1
    WHERE (reply->qual[d1.seq].order_id > 0)
     AND trim(reply->qual[d1.seq].accession_nbr) IN ("", null))
    JOIN (aor
    WHERE (aor.order_id=reply->qual[d1.seq].order_id)
     AND aor.primary_flag=0)
   DETAIL
    reply->qual[d1.seq].accession_nbr = aor.accession
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   bsr.billing_entity_id
   FROM be_security_reltn bsr
   WHERE bsr.parent_entity_name="PRSNL"
    AND (bsr.parent_entity_id=reqinfo->updt_id)
    AND bsr.active_ind=1
   DETAIL
    lbecnt += 1
    IF (lbecnt > size(secbillingentities->be_qual,5))
     stat = alterlist(secbillingentities->be_qual,(lbecnt+ 2))
    ENDIF
    secbillingentities->be_qual[lbecnt].billingentityid = bsr.billing_entity_id
   FOOT REPORT
    stat = alterlist(secbillingentities->be_qual,lbecnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pft_charge pc,
    pft_line_item_chrg_reltn pr,
    pft_line_item pl,
    bill_rec br,
    (dummyt d1  WITH seq = value(reply->charge_qual))
   PLAN (d1)
    JOIN (pc
    WHERE (pc.charge_item_id=reply->qual[d1.seq].charge_item_id)
     AND pc.active_ind=1)
    JOIN (pr
    WHERE pr.pft_charge_id=pc.pft_charge_id)
    JOIN (pl
    WHERE pl.pft_line_item_id=pr.pft_line_item_id)
    JOIN (br
    WHERE br.corsp_activity_id=pl.corsp_activity_id
     AND br.bill_vrsn_nbr=pl.bill_vrsn_nbr
     AND br.active_ind=1)
   DETAIL
    reply->qual[d1.seq].corsp_activity_id = br.corsp_activity_id, reply->qual[d1.seq].bill_type_cdf
     = uar_get_code_meaning(br.bill_type_cd), reply->qual[d1.seq].bill_nbr_disp = trim(br
     .bill_nbr_disp),
    reply->qual[d1.seq].bill_class_cdf = uar_get_code_meaning(br.bill_class_cd), igl_idx = 0, iidx =
    0,
    igl_idx = locateval(iidx,1,size(secbillingentities->be_qual,5),br.billing_entity_id,
     secbillingentities->be_qual[iidx].billingentityid)
    IF (igl_idx > 0)
     reply->qual[d1.seq].has_bill_access = 1
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->order_status_cd != 0.0))
   CALL lookuporderinfo(null)
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARGE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("DID IT WORK?",reply->status_data.status))
END GO
