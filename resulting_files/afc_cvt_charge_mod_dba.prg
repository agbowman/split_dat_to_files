CREATE PROGRAM afc_cvt_charge_mod:dba
 SET count1 = 0
 SET readme = 0
 IF (validate(request->setup_proc[1].success_ind,999) != 999)
  SET readme = 1
  EXECUTE oragen3 "CHARGE_MOD"
 ENDIF
 IF (readme=1)
  SET trace = recpersist
 ENDIF
 RECORD cv(
   1 bill_code = f8
   1 suspense = f8
   1 item_cnt = f8
   1 update_cnt = f8
 )
 IF (readme=1)
  SET trace = norecpersist
 ENDIF
 RECORD c_mods(
   1 mods[*]
     2 charge_mod_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
 )
 SET bill_code = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="BILL CODE"
  DETAIL
   cv->bill_code = cv.code_value
  WITH nocounter
 ;end select
 SET suspense = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="SUSPENSE"
  DETAIL
   cv->suspense = cv.code_value
  WITH nocounter
 ;end select
 CALL echo("Finding charge_mod records...")
 SET count1 = 0
 SELECT INTO "nl:"
  cm.charge_mod_id, cm.field1, cm.field2,
  cm.field3, cm.field4
  FROM charge_mod cm
  WHERE cm.field1_id=0
   AND cm.charge_mod_type_cd IN (cv->bill_code, cv->suspense)
   AND cm.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(c_mods->mods,count1)
   IF ((cm.charge_mod_type_cd=cv->bill_code))
    c_mods->mods[count1].charge_mod_id = cm.charge_mod_id, c_mods->mods[count1].field1_id = cnvtreal(
     trim(cm.field1)), c_mods->mods[count1].field2_id = cnvtreal(trim(cm.field4)),
    c_mods->mods[count1].field6 = cm.field2, c_mods->mods[count1].field7 = cm.field3
   ELSE
    c_mods->mods[count1].charge_mod_id = cm.charge_mod_id, c_mods->mods[count1].field1_id = cnvtreal(
     trim(cm.field1)), c_mods->mods[count1].field2_id = cnvtreal(trim(cm.field3)),
    c_mods->mods[count1].field6 = cm.field2
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("Total: ",count1))
 SET cv->item_cnt = count1
 CALL echo("Updating charge_mod records...")
 UPDATE  FROM charge_mod cm,
   (dummyt d1  WITH seq = value(size(c_mods->mods,5)))
  SET cm.field1_id = c_mods->mods[d1.seq].field1_id, cm.field2_id = c_mods->mods[d1.seq].field2_id,
   cm.field6 = c_mods->mods[d1.seq].field6,
   cm.field7 = c_mods->mods[d1.seq].field7, cm.field5 =
   IF (readme=1) "Converted from old schema by afc_cvt_charge_mod from readme step"
   ELSE "Converted from old schema by afc_cvt_charge_mod from ccl"
   ENDIF
   , cm.updt_cnt = (cm.updt_cnt+ 1),
   cm.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d1)
   JOIN (cm
   WHERE (cm.charge_mod_id=c_mods->mods[d1.seq].charge_mod_id))
  WITH nocounter
 ;end update
 SET cv->update_cnt = curqual
 IF ((cv->update_cnt != cv->item_cnt))
  CALL echo(build("Only ",cv->update_cnt," of ",cv->item_cnt," records updated."))
 ENDIF
 IF (readme=0)
  CALL echo("Done.  Type 'commit go' to commit updates.")
 ELSE
  CALL echo("Done.  Commit.")
  COMMIT
 ENDIF
 FREE SET cv
 FREE SET c_mods
END GO
