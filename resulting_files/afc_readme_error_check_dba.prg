CREATE PROGRAM afc_readme_error_check:dba
 IF ((((request->setup_proc[1].process_id=237)) OR ((((request->setup_proc[1].process_id=245)) OR (((
 (request->setup_proc[1].process_id=246)) OR ((request->setup_proc[1].process_id=247))) )) )) )
  SET count1 = 0
  SELECT INTO "nl:"
   b.*, b1.*
   FROM bill_item b,
    bill_item b1
   WHERE b.ext_parent_reference_id=b1.ext_parent_reference_id
    AND b.ext_parent_contributor_cd=b1.ext_parent_contributor_cd
    AND b.ext_child_reference_id=b1.ext_child_reference_id
    AND b.ext_child_contributor_cd=b1.ext_child_contributor_cd
    AND b.active_ind=b1.active_ind
    AND b.bill_item_id != b1.bill_item_id
   ORDER BY b.ext_parent_reference_id, b.ext_parent_contributor_cd, b.ext_child_reference_id,
    b.ext_child_contributor_cd, b.active_ind
   HEAD b.ext_parent_reference_id
    save_bill_item_id = b.bill_item_id
   HEAD b.ext_parent_contributor_cd
    save_bill_item_id = b.bill_item_id
   HEAD b.ext_child_reference_id
    save_bill_item_id = b.bill_item_id
   HEAD b.ext_child_contributor_cd
    save_bill_item_id = b.bill_item_id
   HEAD b.active_ind
    save_bill_item_id = b.bill_item_id
   DETAIL
    IF (((b.bill_item_id != save_bill_item_id) OR (b1.bill_item_id != save_bill_item_id)) )
     count1 = (count1+ 1)
    ENDIF
   WITH nocounter
  ;end select
  IF (count1 > 0)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "Duplicate bill items still exist."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No duplicate bill items exist."
  ENDIF
 ELSEIF ((((request->setup_proc[1].process_id=324)) OR ((((request->setup_proc[1].process_id=325))
  OR ((((request->setup_proc[1].process_id=326)) OR ((((request->setup_proc[1].process_id=327)) OR ((
 request->setup_proc[1].process_id=328))) )) )) )) )
  IF ((validate(cv->bill_code,- (1))=- (1)))
   CALL echo("cv struct doesn't exist")
  ENDIF
  SET f_field1 = 0
  SELECT
   f_field1 = cnvtreal(field1), field1_id, active_ind
   FROM charge_mod
   WHERE charge_mod_type_cd IN (cv->bill_code, cv->suspense)
    AND f_field1 != 0
    AND field1_id=0
    AND active_ind=1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = concat("Not all charge_mod records converted properly: ",
    cnvtstring(cv->update_cnt)," of ",cnvtstring(cv->item_cnt))
  ELSE
   SET request->setup_proc[1].success_ind = 1
   IF ((cv->item_cnt=0))
    SET request->setup_proc[1].error_msg = "No charge_mod records needed conversion."
   ELSE
    SET request->setup_proc[1].error_msg = concat(cnvtstring(cv->update_cnt),
     " charge_mod records converted successfully.")
   ENDIF
  ENDIF
  FREE SET cv
 ELSEIF ((((request->setup_proc[1].process_id=368)) OR ((((request->setup_proc[1].process_id=369))
  OR ((((request->setup_proc[1].process_id=370)) OR ((((request->setup_proc[1].process_id=371)) OR ((
 request->setup_proc[1].process_id=372))) )) )) )) )
  RECORD holdrec(
    1 holdrec_qual = i2
    1 hold[*]
      2 price_sched_id = f8
      2 price_sched_desc = vc
      2 active_ind = i2
      2 pharm_ind = i2
  )
  SET count1 = 0
  SET stat = alterlist(holdrec->hold,count1)
  SELECT INTO "nl:"
   p.price_sched_id, p.active_ind, p.pharm_ind,
   p.price_sched_desc
   FROM price_sched p
   WHERE p.price_sched_id > 0
   ORDER BY p.price_sched_desc, p.active_ind, p.pharm_ind
   DETAIL
    count1 = (count1+ 1), stat = alterlist(holdrec->hold,count1), holdrec->hold[count1].
    price_sched_id = p.price_sched_id,
    holdrec->hold[count1].price_sched_desc = p.price_sched_desc, holdrec->hold[count1].active_ind = p
    .active_ind, holdrec->hold[count1].pharm_ind = p.pharm_ind
   WITH nocounter
  ;end select
  SET holdrec->holdrec_qual = count1
  SET count2 = 0
  FOR (i = 1 TO holdrec->holdrec_qual)
    IF (((i+ 1) <= holdrec->holdrec_qual))
     IF ((holdrec->hold[i].price_sched_desc=holdrec->hold[(i+ 1)].price_sched_desc)
      AND (holdrec->hold[i].pharm_ind=holdrec->hold[(i+ 1)].pharm_ind))
      SET count2 = (count2+ 1)
     ENDIF
    ENDIF
  ENDFOR
  IF (count2 > 0)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "Duplicate price schedules still exist."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No duplicate price schedules exist."
  ENDIF
 ELSEIF ((((request->setup_proc[1].process_id=417)) OR ((((request->setup_proc[1].process_id=418))
  OR ((((request->setup_proc[1].process_id=419)) OR ((((request->setup_proc[1].process_id=420)) OR ((
 request->setup_proc[1].process_id=421))) )) )) )) )
  RECORD bim(
    1 b_l[*]
      2 bi_id = f8
      2 bim_id = f8
      2 old_pri = i4
      2 new_pri = i4
  )
  SET bill_code = 0.0
  SELECT INTO "NL:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13019
    AND cv.cdf_meaning="BILL CODE"
   DETAIL
    bill_code = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   b.bill_item_id, bm.key1_id, bm.key2_id,
   bm.bill_item_mod_id, bm.beg_effective_dt_tm, bm.end_effective_dt_tm
   FROM bill_item b,
    bill_item_modifier bm
   PLAN (bm
    WHERE bm.bill_item_type_cd=bill_code
     AND bm.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN bm.beg_effective_dt_tm AND bm.end_effective_dt_tm)
    JOIN (b
    WHERE b.bill_item_id=bm.bill_item_id)
   ORDER BY b.bill_item_id, bm.key1_id, bm.beg_effective_dt_tm,
    bm.end_effective_dt_tm, bm.key2_id, bm.bill_item_mod_id
   HEAD bm.key1_id
    pri = 0
   DETAIL
    pri = (pri+ 1), count1 = (count1+ 1), stat = alterlist(bim->b_l,count1),
    bim->b_l[count1].bi_id = b.bill_item_id, bim->b_l[count1].bim_id = bm.bill_item_mod_id, bim->b_l[
    count1].old_pri = bm.key2_id,
    bim->b_l[count1].new_pri = pri
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(bim->b_l,5)))
   WHERE (bim->b_l[d1.seq].old_pri != bim->b_l[d1.seq].new_pri)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("invalid priorities found, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "Invalid priorities exist."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "Priorities ok."
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=620))
  SELECT INTO "nl:"
   t.active_ind, t.bill_org_type_cd, t.bill_org_type_id,
   t.organization_id, count(*)
   FROM bill_org_payor t
   GROUP BY t.active_ind, t.bill_org_type_cd, t.bill_org_type_id,
    t.organization_id
   HAVING count(*) > 1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("DUPLICATES FOUND, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "Duplicate BILL_ORG_PAYOR rows found."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "No Duplicate BILL_ORG_PAYOR rows found."
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=646))
  SELECT INTO "nl:"
   b.*
   FROM bill_item b
   WHERE (b.ext_child_contributor_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=13016
     AND cdf_meaning="TASKCAT"))
    AND ((b.ext_parent_reference_id=0) OR (b.ext_child_entity_name != "ORDER_TASK"))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("curqual > 0, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg =
   "Default task bill items found, or child_entity_name is wrong."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "Task bill items have been successfully modified."
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=670))
  RECORD bim(
    1 b_l[*]
      2 bi_id = f8
      2 bim_id = f8
      2 old_pri = i4
      2 new_pri = i4
  )
  SET bill_code = 0.0
  SELECT INTO "NL:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=13019
    AND cv.cdf_meaning="BILL CODE"
   DETAIL
    bill_code = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   b.bill_item_id, bm.key1_id, bm.bim1_int,
   bm.bill_item_mod_id, bm.beg_effective_dt_tm, bm.end_effective_dt_tm
   FROM bill_item b,
    bill_item_modifier bm
   PLAN (bm
    WHERE bm.bill_item_type_cd=bill_code
     AND bm.active_ind=1
     AND cnvtdatetime(curdate,curtime) BETWEEN bm.beg_effective_dt_tm AND bm.end_effective_dt_tm)
    JOIN (b
    WHERE b.bill_item_id=bm.bill_item_id)
   ORDER BY b.bill_item_id, bm.key1_id, bm.beg_effective_dt_tm,
    bm.end_effective_dt_tm, bm.bim1_int, bm.bill_item_mod_id
   HEAD bm.key1_id
    pri = 0
   DETAIL
    pri = (pri+ 1), count1 = (count1+ 1), stat = alterlist(bim->b_l,count1),
    bim->b_l[count1].bi_id = b.bill_item_id, bim->b_l[count1].bim_id = bm.bill_item_mod_id, bim->b_l[
    count1].old_pri = bm.bim1_int,
    bim->b_l[count1].new_pri = pri
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(bim->b_l,5)))
   WHERE (bim->b_l[d1.seq].old_pri != bim->b_l[d1.seq].new_pri)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("invalid priorities found, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "Invalid bill code priorities (bim1_int) exist."
  ELSE
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "Bill Code Priorities OK."
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=681))
  SELECT INTO "nl:"
   t.active_ind, t.bill_item_id, t.bill_item_type_cd,
   t.bim1_int, t.bim_ind, t.key1_id,
   t.key2_id, t.key3_id, t.beg_effective_dt_tm,
   t.end_effective_dt_tm, count(*)
   FROM bill_item_modifier t
   GROUP BY t.active_ind, t.bill_item_id, t.bill_item_type_cd,
    t.bim1_int, t.bim_ind, t.key1_id,
    t.key2_id, t.key3_id, t.beg_effective_dt_tm,
    t.end_effective_dt_tm
   HAVING count(*) > 1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("DUPLICATES FOUND, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "FAILURE: Duplicates found on BILL_ITEM_MODIFIER"
  ELSE
   CALL echo("NO DUPLICATES FOUND, step succeded")
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "SUCCESS: No Duplicates found on BILL_ITEM_MODIFIER"
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=694))
  SELECT INTO "nl:"
   f.field_name, f.field_display, f.table_name,
   f.field_report_type, count(*)
   FROM pm_rpt_field f
   WHERE f.field_report_type="A"
   GROUP BY f.field_name, f.field_display, f.table_name,
    f.field_report_type
   HAVING count(*) > 1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("DUPLICATES FOUND, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "FAILURE: Duplicates found on PM_RPT_FIELD"
  ELSE
   CALL echo("NO DUPLICATES FOUND, step succeded")
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "SUCCESS: No Duplicates found on PM_RPT_FIELD"
  ENDIF
 ELSEIF ((request->setup_proc[1].process_id=701))
  SET addon = 0.0
  SET billcode = 0.0
  SET chargepoint = 0.0
  SET workload = 0.0
  SET cdf_meaning = fillstring(12," ")
  SET code_set = 13019
  SET code_value = 0.0
  SET cdf_meaning = "ADD ON"
  EXECUTE cpm_get_cd_for_cdf
  SET addon = code_value
  SET code_value = 0.0
  SET cdf_meaning = "BILL CODE"
  EXECUTE cpm_get_cd_for_cdf
  SET billcode = code_value
  SET code_value = 0.0
  SET cdf_meaning = "CHARGE POINT"
  EXECUTE cpm_get_cd_for_cdf
  SET chargepoint = code_value
  SET code_value = 0.0
  SET cdf_meaning = "WORKLOAD"
  EXECUTE cpm_get_cd_for_cdf
  SET workload = code_value
  CALL echo("ADDON: ",0)
  CALL echo(addon)
  CALL echo("BILLCODE: ",0)
  CALL echo(billcode)
  CALL echo("CHARGEPOINT: ",0)
  CALL echo(chargepoint)
  CALL echo("WORKLOAD: ",0)
  CALL echo(workload)
  SELECT INTO "nl:"
   b.*
   FROM bill_item_modifier b
   WHERE ((b.bill_item_type_cd IN (addon, billcode, chargepoint)
    AND b.key3_id != 0
    AND b.bim1_int=0) OR (b.bill_item_type_cd=workload
    AND ((b.key13_id != 0
    AND b.bim_ind=0) OR (((b.key5_id != 0
    AND b.bim1_nbr=0) OR (b.key11_id != 0
    AND b.bim2_int=0)) )) ))
    AND b.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("ERRORS FOUND ON TABLE, step failed")
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = concat("FAILURE: ",cnvtstring(curqual),
    " INVALID ROWS FOUND")
  ELSE
   CALL echo("NO ERRORS FOUND ON TABLE, step succeded")
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = "SUCCESS: No Invalid Rows Found"
  ENDIF
 ELSE
  CALL echo("Unknown process id")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "AFC_README_ERROR_CHECK - Unknown process id"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 FREE SET holdrec
 FREE SET bim
END GO
