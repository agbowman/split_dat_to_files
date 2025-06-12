CREATE PROGRAM afc_cvt_charge_points
 SET charge_point_sched = 0
 SET charge_point = 0.0
 SET manual_charge = 0.0
 SET ordered_charge = 0.0
 SET code_value = 0.0
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13029
   AND cv.cdf_meaning="MANUAL"
  DETAIL
   manual_charge = cv.code_value
  WITH nocounter
 ;end select
 CALL echo("MANUAL CHARGE POINT: ",0)
 CALL echo(cnvtstring(manual_charge,17,2))
 SET code_set = 13029
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_charge = code_value
 CALL echo("ORDERED CHARGE POINT: ",0)
 CALL echo(cnvtstring(ordered_charge,17,2))
 SET code_set = 13019
 SET cdf_meaning = "CHARGE POINT"
 EXECUTE cpm_get_cd_for_cdf
 CALL echo("code_value: ",0)
 CALL echo(code_value)
 SET charge_point = code_value
 CALL echo("CHARGE_POINT: ",0)
 CALL echo(cnvtstring(charge_point,17,2))
 RECORD chg_pt_sched(
   1 qual[*]
     2 code_value = f8
 )
 SET chg_pt_sched_qual = 0
 SET count1 = 0
 SELECT INTO "NL:"
  cv.code_value, cv.cdf_meaning, cv.code_set
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning="CHARGE POINT"
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(chg_pt_sched->qual,count1), chg_pt_sched->qual[count1].
   code_value = cv.code_value
  WITH nocounter
 ;end select
 SET chg_pt_sched_qual = count1
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i4
   1 updt_id = f8
   1 updt_applctx = i4
   1 updt_task = i4
 )
 SET reqinfo->updt_id = 2208
 SET reqinfo->updt_applctx = 0
 SET reqinfo->updt_task = 951000
 FREE SET request
 RECORD request(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.bill_item_id, b.charge_point_cd
  FROM bill_item b,
   (dummyt d1  WITH seq = value(chg_pt_sched_qual))
  PLAN (d1)
   JOIN (b
   WHERE b.charge_point_cd != 0
    AND b.active_ind=1)
  DETAIL
   count1 = (count1+ 1), request->bill_item_modifier_qual = count1, stat = alterlist(request->
    bill_item_modifier,count1),
   request->bill_item_modifier[count1].bill_item_id = b.bill_item_id, request->bill_item_modifier[
   count1].bill_item_type_cd = charge_point, request->bill_item_modifier[count1].key1_id =
   chg_pt_sched->qual[d1.seq].code_value,
   request->bill_item_modifier[count1].key2_id =
   IF (b.charge_point_cd != manual_charge) b.charge_point_cd
   ELSE ordered_charge
   ENDIF
   , request->bill_item_modifier[count1].key3_id =
   IF (b.charge_point_cd != manual_charge) 0
   ELSE 1
   ENDIF
   , request->bill_item_modifier[count1].key6 = "Converted from bill_item charge_point_cd"
  WITH nocounter
 ;end select
 EXECUTE afc_add_bill_item_modifier
 CALL echo("Commit Ind: ",0)
 CALL echo(reqinfo->commit_ind)
 FREE SET chg_pt_sched
END GO
