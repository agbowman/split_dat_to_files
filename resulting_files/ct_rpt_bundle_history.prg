CREATE PROGRAM ct_rpt_bundle_history
 FREE SET code_val
 RECORD code_val(
   1 14002_cpt4 = c50
 )
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
  ELSE
   SET rn_dt = cnvtdatetime(curdate,curtime)
  ENDIF
 ELSE
  SET rn_dt = cnvtdatetime(curdate,curtime)
 ENDIF
 CALL echo(build("rn_dt is : ",format(rn_dt,"MM-DD-YYYY HH:MM.SS;;D")))
 RECORD request2(
   1 charge_qual = i4
   1 charges[*]
     2 ct_bundle_history_id = f8
     2 ct_rule_id = f8
     2 bundle_id = f8
     2 charge_item_id = f8
     2 price = f8
     2 department_cd = f8
     2 department_alias = c20
     2 section_cd = f8
     2 section_alias = c20
     2 accession = c50
     2 date_of_service = dq8
     2 cpt = c20
     2 to_ind = i2
     2 person_name = c50
     2 quantity = f8
     2 med_rec_num = c200
     2 encntr = f8
 )
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.active_ind=1
   AND cv.cdf_meaning="CPT4"
  DETAIL
   code_val->14002_cpt4 = cv.display
  WITH nocounter
 ;end select
 SET beg_run_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 00:00:00.00"))
 SET end_run_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET cnt = 0
 SELECT INTO "nl:"
  FROM ct_bundle_history ct
  WHERE ct.bundle_dt_tm BETWEEN cnvtdatetime(beg_run_dt) AND cnvtdatetime(end_run_dt)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(request2->charges,cnt), request2->charges[cnt].
   ct_bundle_history_id = ct.ct_bundle_history_id,
   request2->charges[cnt].ct_rule_id = ct.ct_rule_id, request2->charges[cnt].bundle_id = ct.bundle_id
   IF (ct.to_charge_item_id=0
    AND ct.from_charge_item_id=0)
    request2->charges[cnt].to_ind = 2
   ELSE
    IF (ct.to_charge_item_id=0)
     request2->charges[cnt].charge_item_id = ct.from_charge_item_id, request2->charges[cnt].to_ind =
     0
    ELSE
     request2->charges[cnt].charge_item_id = ct.to_charge_item_id, request2->charges[cnt].to_ind = 1
    ENDIF
   ENDIF
   request2->charge_qual = cnt
  WITH nocounter
 ;end select
 CALL echo(build("charge_qual is : ",request2->charge_qual))
 IF ((request2->charge_qual > 0))
  SELECT INTO "nl:"
   FROM charge c,
    charge_mod cm,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request2->charges[d.seq].charge_item_id))
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id)
   DETAIL
    request2->charges[d.seq].price = c.item_price, request2->charges[d.seq].department_cd = c
    .department_cd, request2->charges[d.seq].section_cd = c.section_cd,
    request2->charges[d.seq].date_of_service = c.service_dt_tm, request2->charges[d.seq].cpt = cm
    .field6, request2->charges[d.seq].quantity = c.item_quantity,
    request2->charges[d.seq].encntr = c.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge c,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request2->charges[d.seq].charge_item_id))
   ORDER BY request2->charges[d.seq].bundle_id, request2->charges[d.seq].to_ind
   DETAIL
    IF ((request2->charges[d.seq].to_ind=2))
     request2->charges[d.seq].department_cd = request2->charges[(d.seq - 1)].department_cd, request2
     ->charges[d.seq].section_cd = request2->charges[(d.seq - 1)].section_cd
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge c,
    charge_event ce,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request2->charges[d.seq].charge_item_id))
    JOIN (ce
    WHERE ce.charge_event_id=c.charge_event_id)
   DETAIL
    request2->charges[d.seq].accession = ce.accession
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge c,
    person p,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_item_id=request2->charges[d.seq].charge_item_id))
    JOIN (p
    WHERE p.person_id=c.person_id)
   DETAIL
    request2->charges[d.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE c.code_set=221
     AND c.cdf_meaning="DEPARTMENT"
     AND c.active_ind=1)
   DETAIL
    request2->charges[d.seq].department_alias = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value c,
    (dummyt d  WITH seq = value(request2->charge_qual))
   PLAN (d)
    JOIN (c
    WHERE c.code_set=221
     AND c.cdf_meaning="SECTION"
     AND c.active_ind=1)
   DETAIL
    request2->charges[d.seq].section_alias = c.display
   WITH nocounter
  ;end select
  SET g_person_alias_med_rec_num = 0.0
  SELECT INTO "nl:"
   a.code_value
   FROM code_value a
   WHERE a.code_set=319
    AND a.cdf_meaning="MRN"
    AND a.active_ind=1
   DETAIL
    g_person_alias_med_rec_num = a.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pa.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    encntr_alias pa
   PLAN (d1)
    JOIN (pa
    WHERE (pa.encntr_id=request2->charges[d1.seq].encntr)
     AND pa.encntr_alias_type_cd=g_person_alias_med_rec_num
     AND pa.active_ind=true)
   DETAIL
    request2->charges[d1.seq].med_rec_num = pa.alias
   WITH nocounter
  ;end select
  SET line_140 = fillstring(140,"=")
  SELECT
   rpt_department_cd = request2->charges[d.seq].department_cd, rpt_section_cd = request2->charges[d
   .seq].section_cd, rpt_department_alias = request2->charges[d.seq].department_alias,
   rpt_section_alias = request2->charges[d.seq].section_alias, rpt_bundle_id = request2->charges[d
   .seq].bundle_id, rpt_charge_item_id = request2->charges[d.seq].charge_item_id,
   rpt_accession = trim(request2->charges[d.seq].accession,3), rpt_service_dt_tm = request2->charges[
   d.seq].date_of_service, rpt_price = request2->charges[d.seq].price,
   rpt_cpt = request2->charges[d.seq].cpt, rpt_person_name = request2->charges[d.seq].person_name,
   rpt_to_ind = request2->charges[d.seq].to_ind,
   rpt_quantity = request2->charges[d.seq].quantity, rpt_med_rec_num = request2->charges[d.seq].
   med_rec_num
   FROM (dummyt d  WITH seq = value(request2->charge_qual))
   ORDER BY rpt_department_cd, rpt_section_cd, rpt_bundle_id,
    rpt_to_ind DESC
   HEAD REPORT
    rpt_date = cnvtdatetime(rn_dt), col 115, rpt_date"DD MMM YYYY HH:MM.SS;R;DATE",
    row + 1
   HEAD PAGE
    head2 = "Department", head3 = "Section", head4 = "Person",
    head5 = "Bundle ID", head6 = "Accession", head7 = "Date of Service",
    head8 = "Charge Item Id", head9 = code_val->14002_cpt4, head10 = "Price",
    head11 = "MRN", head12 = "Quantity", col 00,
    head2, row + 1, col 20,
    head3, row + 2, col 30,
    head4, col 55, head11,
    row + 1, col 30, head5,
    col 45, head6, col 65,
    head7, row + 2, col 35,
    head8, col 50, head9,
    col 65, head12, col 75,
    head10, row + 1, col 00,
    line_140, row + 1
   HEAD rpt_department_cd
    col 00, rpt_department_alias"####################", row + 1
   HEAD rpt_section_cd
    col 20, rpt_section_alias"####################", row + 1
   HEAD rpt_bundle_id
    row + 1, col 30, rpt_person_name"#################################",
    col 55, rpt_med_rec_num"####################", row + 1,
    col 30, rpt_bundle_id"##########", col 45,
    rpt_accession"####################", col 65, rpt_service_dt_tm"DD MMM YYYY HH:MM.SS;R;DATE",
    row + 2
   HEAD rpt_to_ind
    IF (rpt_to_ind=0)
     col 35, "Before", row + 1
    ELSE
     col 35, "After", row + 1
    ENDIF
   DETAIL
    IF (rpt_to_ind=2)
     col 35, "NO CHARGE CREATED.  CHECK DATABASE BUILD."
    ELSE
     col 35, rpt_charge_item_id"##########", col 50,
     rpt_cpt"##############", col 65, rpt_quantity"##########",
     col 75, rpt_price"#####.##"
    ENDIF
    row + 1
   WITH maxcol = 150
  ;end select
 ELSE
  CALL echo("no charges found")
 ENDIF
END GO
