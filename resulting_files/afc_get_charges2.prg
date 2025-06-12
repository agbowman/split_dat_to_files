CREATE PROGRAM afc_get_charges2
 SET servicedatetime = fillstring(11," ")
 CALL echo("Begin")
 IF ((request->detail_ind=0))
  IF ((request->corsp_activity_id=0))
   IF (( $23=false))
    SELECT
     IF ((request->encntr_id > 0)
      AND (request->person_id <= 0))
      PLAN (e
       WHERE (e.encntr_id=request->encntr_id)
        AND  $32)
       JOIN (p
       WHERE p.person_id=e.person_id
        AND  $31)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
        AND  $33)
       JOIN (ce
       WHERE ce.charge_event_id=c.charge_event_id
        AND  $9
        AND ce.active_ind=1)
       JOIN (b
       WHERE b.bill_item_id=c.bill_item_id)
     ELSEIF ((request->encntr_id > 0))
      PLAN (p
       WHERE (p.person_id=request->person_id)
        AND p.active_ind=1
        AND  $31)
       JOIN (e
       WHERE (e.encntr_id=request->encntr_id)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
        AND  $33)
       JOIN (ce
       WHERE ce.charge_event_id=c.charge_event_id
        AND  $9
        AND ce.active_ind=1)
       JOIN (b
       WHERE b.bill_item_id=c.bill_item_id)
     ELSEIF ((request->person_id > 0))
      PLAN (p
       WHERE (p.person_id=request->person_id)
        AND p.active_ind=1
        AND  $31)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
        AND  $33)
       JOIN (e
       WHERE e.encntr_id=c.encntr_id
        AND  $12
        AND  $14
        AND  $32)
       JOIN (ce
       WHERE ce.charge_event_id=c.charge_event_id
        AND  $9
        AND ce.active_ind=1)
       JOIN (b
       WHERE b.bill_item_id=c.bill_item_id)
     ELSE
     ENDIF
     INTO "nl:"
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
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND ((c.active_ind+ 0)=1)
       AND  $33)
      JOIN (p
      WHERE p.person_id=c.person_id
       AND p.active_ind=1
       AND  $31)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND  $12
       AND  $14
       AND e.active_ind=1
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
   ELSE
    SELECT
     IF ((request->encntr_id > 0)
      AND (request->person_id <= 0))
      PLAN (e
       WHERE (e.encntr_id=request->encntr_id)
        AND  $32)
       JOIN (p
       WHERE p.person_id=e.person_id
        AND  $31)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
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
     ELSEIF ((request->encntr_id > 0))
      PLAN (p
       WHERE (p.person_id=request->person_id)
        AND p.active_ind=1
        AND  $31)
       JOIN (e
       WHERE (e.encntr_id=request->encntr_id)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
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
     ELSEIF ((request->person_id > 0))
      PLAN (p
       WHERE (p.person_id=request->person_id)
        AND p.active_ind=1
        AND  $31)
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
        AND  $25
        AND  $26
        AND  $27
        AND  $28
        AND  $29
        AND  $30
        AND ((c.active_ind+ 0)=1)
        AND  $33)
       JOIN (e
       WHERE e.encntr_id=c.encntr_id
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
     ELSE
     ENDIF
     INTO "nl:"
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
       AND  $25
       AND  $26
       AND  $27
       AND  $28
       AND  $29
       AND  $30
       AND ((c.active_ind+ 0)=1)
       AND  $33)
      JOIN (p
      WHERE p.person_id=c.person_id
       AND p.active_ind=1
       AND  $31)
      JOIN (e
      WHERE e.encntr_id=c.encntr_id
       AND  $12
       AND  $14
       AND e.active_ind=1
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
     charge_mod cm,
     prsnl p
    PLAN (d1
     WHERE (reply->qual[d1.seq].charge_item_id > 0))
     JOIN (cm
     WHERE (cm.charge_item_id=reply->qual[d1.seq].charge_item_id)
      AND cm.active_ind=1)
     JOIN (p
     WHERE (p.person_id= Outerjoin(cm.updt_id)) )
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
      reply->qual[d1.seq].bill_code[count2].nomen_id = cm.nomen_id, reply->qual[d1.seq].bill_code[
      count2].field4_id = cm.field4_id, reply->qual[d1.seq].bill_code[count2].activity_dt_tm = cm
      .activity_dt_tm,
      reply->qual[d1.seq].bill_code[count2].field8 = cm.field8, reply->qual[d1.seq].bill_code[count2]
      .username = p.username, reply->qual[d1.seq].bill_code_qual = count2
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
   SELECT INTO "nl:"
    o.org_name
    FROM organization o,
     (dummyt d1  WITH seq = value(reply->charge_qual))
    PLAN (d1)
     JOIN (o
     WHERE (o.organization_id=reply->qual[d1.seq].original_org_id)
      AND o.active_ind=true)
    DETAIL
     reply->qual[d1.seq].original_org_name = o.org_name
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
   CALL echo("GETTING INTERVAL STUFF")
   SET int_cnt = 0
   SELECT INTO "nl:"
    cid = reply->qual[d1.seq].charge_item_id
    FROM price_sched_items psi,
     interval_table it,
     item_interval_table iit,
     (dummyt d1  WITH seq = value(reply->charge_qual))
    PLAN (d1)
     JOIN (psi
     WHERE (psi.bill_item_id=reply->qual[d1.seq].bill_item_id)
      AND (psi.price_sched_id=reply->qual[d1.seq].price_sched_id)
      AND psi.beg_effective_dt_tm <= cnvtdatetime(reply->qual[d1.seq].service_dt_tm)
      AND psi.end_effective_dt_tm > cnvtdatetime(reply->qual[d1.seq].service_dt_tm)
      AND psi.active_ind=1)
     JOIN (it
     WHERE it.interval_template_cd=psi.interval_template_cd
      AND it.active_ind=1)
     JOIN (iit
     WHERE iit.parent_entity_id=psi.price_sched_items_id
      AND iit.parent_entity_name="PRICE_SCHED_ITEMS"
      AND iit.interval_template_cd=psi.interval_template_cd
      AND iit.interval_id=it.interval_id
      AND iit.active_ind=1)
    ORDER BY cid, it.beg_value, iit.item_interval_id
    HEAD cid
     int_cnt = 0
    HEAD it.beg_value
     reply->qual[d1.seq].interval_template_cd = it.interval_template_cd, int_cnt += 1, stat =
     alterlist(reply->qual[d1.seq].interval_qual,int_cnt),
     reply->qual[d1.seq].interval_qual[int_cnt].interval_id = it.interval_id, reply->qual[d1.seq].
     interval_qual[int_cnt].beg_value = it.beg_value, reply->qual[d1.seq].interval_qual[int_cnt].
     end_value = it.end_value,
     reply->qual[d1.seq].interval_qual[int_cnt].unit_type_cd = it.unit_type_cd, reply->qual[d1.seq].
     interval_qual[int_cnt].calc_type_cd = it.calc_type_cd, reply->qual[d1.seq].interval_qual[int_cnt
     ].interval_template_cd = it.interval_template_cd,
     CALL echo(build("The charge_item_id is ",reply->qual[d1.seq].charge_item_id)),
     CALL echo(build("The interval_template_cd is ",it.interval_template_cd)),
     CALL echo(build("The begin value is ",it.beg_value)),
     CALL echo(build("The end value is ",it.end_value))
    HEAD iit.item_interval_id
     reply->qual[d1.seq].interval_qual[int_cnt].price = iit.price,
     CALL echo(build("set the price to ",iit.price)), reply->qual[d1.seq].interval_qual[int_cnt].
     parent_entity_id = iit.parent_entity_id,
     CALL echo(build("The price is ",iit.price))
    DETAIL
     null
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM charge_event_act cea,
     (dummyt d1  WITH seq = value(reply->charge_qual))
    PLAN (d1
     WHERE (((reply->qual[d1.seq].item_interval_id > 0)) OR ((reply->qual[d1.seq].
     interval_template_cd > 0))) )
     JOIN (cea
     WHERE (cea.charge_event_id=reply->qual[d1.seq].charge_event_id)
      AND cea.quantity != 0.0)
    DETAIL
     reply->qual[d1.seq].cea_qty = cea.quantity
    WITH nocounter
   ;end select
   SET int_cnt = 0
   SELECT INTO "nl:"
    iit.item_interval_id, it.interval_id, cid = reply->qual[d1.seq].charge_item_id
    FROM item_interval_table iit,
     interval_table it,
     (dummyt d1  WITH seq = value(reply->charge_qual)),
     item_interval_table iit2,
     bill_item_modifier bim,
     dummyt d2,
     price_sched_items psi
    PLAN (d1
     WHERE (reply->qual[d1.seq].item_interval_id > 0))
     JOIN (psi
     WHERE (psi.bill_item_id=reply->qual[d1.seq].bill_item_id)
      AND (psi.price_sched_id=reply->qual[d1.seq].price_sched_id)
      AND psi.beg_effective_dt_tm <= cnvtdatetime(reply->qual[d1.seq].service_dt_tm)
      AND psi.end_effective_dt_tm > cnvtdatetime(reply->qual[d1.seq].service_dt_tm)
      AND psi.active_ind=1)
     JOIN (iit
     WHERE (iit.item_interval_id=reply->qual[d1.seq].item_interval_id)
      AND iit.parent_entity_id=psi.price_sched_items_id
      AND iit.parent_entity_name="PRICE_SCHED_ITEMS")
     JOIN (it
     WHERE it.interval_template_cd=iit.interval_template_cd
      AND it.active_ind=1)
     JOIN (d2)
     JOIN (iit2
     WHERE iit2.interval_id=it.interval_id)
     JOIN (bim
     WHERE (bim.bill_item_id=reply->qual[d1.seq].bill_item_id)
      AND bim.bill_item_type_cd=d13019_interval_cd
      AND bim.key2_id=iit2.item_interval_id
      AND bim.active_ind=1)
    ORDER BY cid, it.beg_value
    HEAD cid
     int_cnt = 0
    HEAD it.beg_value
     bc = 0, int_cnt += 1, reply->qual[d1.seq].interval_qual[int_cnt].item_interval_id = iit2
     .item_interval_id
    DETAIL
     IF (bim.bill_item_mod_id > 0)
      bc += 1, stat = alterlist(reply->qual[d1.seq].interval_qual[int_cnt].bc_qual,bc), reply->qual[
      d1.seq].interval_qual[int_cnt].bc_qual[bc].bill_item_mod_id = bim.bill_item_mod_id,
      reply->qual[d1.seq].interval_qual[int_cnt].bc_qual[bc].bill_item_type_cd = bim
      .bill_item_type_cd, reply->qual[d1.seq].interval_qual[int_cnt].bc_qual[bc].key1_id = bim
      .key1_id, reply->qual[d1.seq].interval_qual[int_cnt].bc_qual[bc].key2_id = bim.key2_id,
      reply->qual[d1.seq].interval_qual[int_cnt].bc_qual[bc].key6 = bim.key6, reply->qual[d1.seq].
      interval_qual[int_cnt].bc_qual[bc].key7 = bim.key7, reply->qual[d1.seq].interval_qual[int_cnt].
      bc_qual[bc].key3_id = bim.key3_id
     ENDIF
    WITH nocounter, outerjoin = d2
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
     reply->qual[d1.seq].bill_class_cdf = uar_get_code_meaning(br.bill_class_cd), igl_idx = 0, iidx
      = 0,
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
 ELSE
  SET count1 = 0
  SET stat = alterlist(reply->qual,count1)
  SELECT
   IF ((request->parent_charge_item_id > 0))
    PLAN (c
     WHERE (c.parent_charge_item_id=request->parent_charge_item_id)
      AND c.active_ind=1)
     JOIN (ce
     WHERE ce.charge_event_id=c.charge_event_id)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id)
   ELSE
    PLAN (c
     WHERE (c.charge_item_id=request->charge_item_id))
     JOIN (ce
     WHERE ce.charge_event_id=c.charge_event_id)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id)
   ENDIF
   INTO "nl:"
   FROM charge c,
    charge_event ce,
    encounter e
   DETAIL
    count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].charge_item_id = c
    .charge_item_id,
    reply->qual[count1].parent_charge_item_id = c.parent_charge_item_id, reply->qual[count1].
    charge_event_act_id = c.charge_event_act_id, reply->qual[count1].charge_event_id = c
    .charge_event_id,
    reply->qual[count1].bill_item_id = c.bill_item_id, reply->qual[count1].order_id = c.order_id,
    reply->qual[count1].encntr_id = c.encntr_id,
    reply->qual[count1].person_id = c.person_id, reply->qual[count1].payor_id = c.payor_id, reply->
    qual[count1].ord_loc_cd = c.ord_loc_cd,
    reply->qual[count1].perf_loc_cd = c.perf_loc_cd, reply->qual[count1].ord_phys_id = c.ord_phys_id,
    reply->qual[count1].perf_phys_id = c.perf_phys_id,
    reply->qual[count1].charge_description = c.charge_description, reply->qual[count1].price_sched_id
     = c.price_sched_id, reply->qual[count1].item_quantity = c.item_quantity,
    reply->qual[count1].item_price = c.item_price, reply->qual[count1].item_extended_price = c
    .item_extended_price, reply->qual[count1].item_allowable = c.item_allowable,
    reply->qual[count1].item_copay = c.item_copay, reply->qual[count1].charge_type_cd = c
    .charge_type_cd, reply->qual[count1].research_acct_id = c.research_acct_id,
    reply->qual[count1].suspense_rsn_cd = c.suspense_rsn_cd, reply->qual[count1].reason_comment = c
    .reason_comment, reply->qual[count1].posted_cd = c.posted_cd,
    reply->qual[count1].posted_dt_tm = c.posted_dt_tm, reply->qual[count1].process_flg = c
    .process_flg, reply->qual[count1].service_dt_tm = c.service_dt_tm,
    reply->qual[count1].activity_dt_tm = c.activity_dt_tm, reply->qual[count1].updt_cnt = c.updt_cnt,
    reply->qual[count1].updt_dt_tm = c.updt_dt_tm,
    reply->qual[count1].updt_id = c.updt_id, reply->qual[count1].updt_task = c.updt_task, reply->
    qual[count1].updt_applctx = c.updt_applctx,
    reply->qual[count1].active_ind = c.active_ind, reply->qual[count1].active_status_cd = c
    .active_status_cd, reply->qual[count1].active_status_dt_tm = c.active_status_dt_tm,
    reply->qual[count1].active_status_prsnl_id = c.active_status_prsnl_id, reply->qual[count1].
    beg_effective_dt_tm = c.beg_effective_dt_tm, reply->qual[count1].end_effective_dt_tm = c
    .end_effective_dt_tm,
    reply->qual[count1].credited_dt_tm = c.credited_dt_tm, reply->qual[count1].adjusted_dt_tm = c
    .adjusted_dt_tm, reply->qual[count1].interface_file_id = c.interface_file_id,
    reply->qual[count1].tier_group_cd = c.tier_group_cd, reply->qual[count1].def_bill_item_id = c
    .def_bill_item_id, reply->qual[count1].verify_phys_id = c.verify_phys_id,
    reply->qual[count1].gross_price = c.gross_price, reply->qual[count1].discount_amount = c
    .discount_amount, reply->qual[count1].manual_ind = c.manual_ind,
    reply->qual[count1].combine_ind = c.combine_ind, reply->qual[count1].bundle_id = c.bundle_id,
    reply->qual[count1].institution_cd = c.institution_cd,
    reply->qual[count1].department_cd = c.department_cd, reply->qual[count1].section_cd = c
    .section_cd, reply->qual[count1].subsection_cd = c.subsection_cd,
    reply->qual[count1].level5_cd = c.level5_cd, reply->qual[count1].admit_type_cd = c.admit_type_cd,
    reply->qual[count1].med_service_cd = c.med_service_cd,
    reply->qual[count1].activity_type_cd = c.activity_type_cd, reply->qual[count1].inst_fin_nbr = c
    .inst_fin_nbr, reply->qual[count1].cost_center_cd = c.cost_center_cd,
    reply->qual[count1].abn_status_cd = c.abn_status_cd, reply->qual[count1].health_plan_id = c
    .health_plan_id, reply->qual[count1].fin_class_cd = c.fin_class_cd,
    reply->qual[count1].payor_type_cd = c.payor_type_cd, reply->qual[count1].item_reimbursement = c
    .item_reimbursement, reply->qual[count1].item_interval_id = c.item_interval_id,
    reply->qual[count1].item_list_price = c.item_list_price, reply->qual[count1].list_price_sched_id
     = c.list_price_sched_id, reply->qual[count1].start_dt_tm = c.start_dt_tm,
    reply->qual[count1].stop_dt_tm = c.stop_dt_tm, reply->qual[count1].epsdt_ind = c.epsdt_ind, reply
    ->qual[count1].ref_phys_id = c.ref_phys_id,
    reply->qual[count1].item_deductible_amt = c.item_deductible_amt, reply->qual[count1].
    patient_responsibility_flag = c.patient_responsibility_flag, reply->qual[count1].
    offset_charge_item_id = c.offset_charge_item_id,
    reply->qual[count1].cs_cpp_undo_id = c.cs_cpp_undo_id, reply->qual[count1].provider_specialty_cd
     = c.provider_specialty_cd, reply->qual[count1].original_org_id = c.original_org_id,
    stat = assign(validate(reply->qual[count1].service_interface_flag),c.service_interface_flag),
    stat = assign(validate(reply->qual[count1].access_to_billing_entity),1), stat = assign(validate(
      reply->qual[count1].ext_parent_event_id),ce.ext_p_event_id)
    IF (c.posted_id > 0.0)
     reply->qual[count1].postedbyid = c.posted_id
    ELSE
     reply->qual[count1].postedbyid = c.updt_id
    ENDIF
    reply->qual[count1].updt_id = c.updt_id, reply->qual[count1].location_disp = uar_get_code_display
    (e.loc_nurse_unit_cd), reply->qual[count1].fin_class_disp = uar_get_code_display(e
     .financial_class_cd),
    reply->qual[count1].loc_room_disp = uar_get_code_display(e.loc_room_cd), reply->qual[count1].
    building_disp = uar_get_code_display(e.loc_building_cd)
   WITH nocounter
  ;end select
  SET reply->charge_qual = count1
  SET stat = alterlist(reply->qual,count1)
  IF ((reply->charge_qual > 0))
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
     (dummyt d1  WITH seq = value(reply->charge_qual))
    PLAN (d1)
     JOIN (o
     WHERE (o.organization_id=reply->qual[d1.seq].payor_id))
    DETAIL
     reply->qual[d1.seq].org_name = o.org_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_detail o,
     (dummyt d1  WITH seq = value(reply->charge_qual))
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=reply->qual[d1.seq].order_id)
      AND o.oe_field_meaning="REQSTARTDTTM")
    DETAIL
     reply->qual[d1.seq].requested_start_dt_tm = o.oe_field_dt_tm_value
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
     reply->qual[d1.seq].bill_class_cdf = uar_get_code_meaning(br.bill_class_cd), igl_idx = 0, iidx
      = 0,
     igl_idx = locateval(iidx,1,size(secbillingentities->be_qual,5),br.billing_entity_id,
      secbillingentities->be_qual[iidx].billingentityid)
     IF (igl_idx > 0)
      reply->qual[d1.seq].has_bill_access = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  CALL echorecord(reply)
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
END GO
