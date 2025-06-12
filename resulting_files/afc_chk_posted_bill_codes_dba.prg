CREATE PROGRAM afc_chk_posted_bill_codes:dba
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 FREE SET reply
 RECORD reply(
   1 t01_qual = i2
   1 t01_recs[*]
     2 t01_id = f8
     2 t01_charge_item_id = f8
     2 t01_interfaced = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET charges
 RECORD charges(
   1 charges[*]
     2 name = vc
     2 charge_item_id = f8
     2 interface_file_id = f8
     2 mult_bill_cd = f8
     2 old_bill_code1 = c50
     2 old_bill_code2 = c50
     2 old_bill_code3 = c50
     2 old_prim_cdm = c50
     2 old_prim_cpt = c50
     2 old_diag_code1 = c50
     2 old_diag_code2 = c50
     2 old_diag_code3 = c50
     2 old_prim_icd9_proc = c50
     2 old_code_modifier1_cd = f8
     2 old_code_modifier2_cd = f8
     2 old_code_modifier3_cd = f8
     2 new_bill_code1 = c50
     2 new_bill_code2 = c50
     2 new_bill_code3 = c50
     2 new_prim_cdm = c50
     2 new_prim_cpt = c50
     2 new_diag_code1 = c50
     2 new_diag_code2 = c50
     2 new_diag_code3 = c50
     2 new_prim_icd9_proc = c50
     2 new_code_modifier1_cd = f8
     2 new_code_modifier2_cd = f8
     2 new_code_modifier3_cd = f8
 )
 DECLARE code_set = i4
 DECLARE cnt = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_code_cd = f8
 DECLARE codevalue = f8
 DECLARE modifier_cd = f8
 IF (validate(request->ops_date,999) != 999)
  SET run_date = cnvtdatetime(request->ops_date)
 ELSE
  SET run_date = cnvtdatetime(curdate,curtime)
 ENDIF
 SET posted_run_dt = cnvtdatetime(concat(format(run_date,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET code_set = 13019
 SET cnt = 1
 SET cdf_meaning = "BILL CODE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_code_cd)
 FREE SET cdm_codes
 RECORD cdm_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET num_cds = 1
 SET cdf_meaning = "CDM_SCHED"
 SET code_set = 14002
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cvct,codevalue)
 IF (iret=0)
  CALL echo(concat("Success.  Code value: ",build(codevalue)))
  SET stat = alterlist(cdm_codes->code_vals,cvct)
  SET cdm_codes->code_vals[num_cds].code_val = codevalue
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,codevalue)
    IF (iret=0)
     CALL echo(concat("Success. Code Value: ",build(codevalue)))
     SET num_cds = (num_cds+ 1)
     SET cdm_codes->code_vals[num_cds].code_val = codevalue
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Echoing out cdm record:")
 CALL echorecord(cdm_codes)
 FREE SET cpt_codes
 RECORD cpt_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET num_cds = 1
 SET cdf_meaning = "CPT4"
 SET code_set = 14002
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cvct,codevalue)
 IF (iret=0)
  CALL echo(concat("Success.  Code value: ",build(codevalue)))
  SET stat = alterlist(cpt_codes->code_vals,cvct)
  SET cpt_codes->code_vals[num_cds].code_val = codevalue
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,codevalue)
    IF (iret=0)
     CALL echo(concat("Success. Code Value: ",build(codevalue)))
     SET num_cds = (num_cds+ 1)
     SET cpt_codes->code_vals[num_cds].code_val = codevalue
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Echoing out cpt record:")
 CALL echorecord(cpt_codes)
 FREE SET icd9_diag_codes
 RECORD icd9_diag_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET num_cds = 1
 SET cdf_meaning = "ICD9"
 SET code_set = 14002
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cvct,codevalue)
 IF (iret=0)
  CALL echo(concat("Success.  Code value: ",build(codevalue)))
  SET stat = alterlist(icd9_diag_codes->code_vals,cvct)
  SET icd9_diag_codes->code_vals[num_cds].code_val = codevalue
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,codevalue)
    IF (iret=0)
     CALL echo(concat("Success. Code Value: ",build(codevalue)))
     SET num_cds = (num_cds+ 1)
     SET icd9_diag_codes->code_vals[num_cds].code_val = codevalue
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Echoing out icd9 diag record:")
 CALL echorecord(icd9_diag_codes)
 FREE SET icd9_proc_codes
 RECORD icd9_proc_codes(
   1 code_vals[*]
     2 code_val = f8
 )
 SET num_cds = 1
 SET cdf_meaning = "PROCCODE"
 SET code_set = 14002
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cvct,codevalue)
 IF (iret=0)
  CALL echo(concat("Success.  Code value: ",build(codevalue)))
  SET stat = alterlist(icd9_proc_codes->code_vals,cvct)
  SET icd9_proc_codes->code_vals[num_cds].code_val = codevalue
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,i,codevalue)
    IF (iret=0)
     CALL echo(concat("Success. Code Value: ",build(codevalue)))
     SET num_cds = (num_cds+ 1)
     SET icd9_proc_codes->code_vals[num_cds].code_val = codevalue
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("Echoing out icd9 proc record:")
 CALL echorecord(icd9_proc_codes)
 SET code_set = 14002
 SET cnt = 1
 SET cdf_meaning = "MODIFIER"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,modifier_cd)
 SET num_charges = 0
 SELECT INTO "nl:"
  FROM interface_charge i
  WHERE i.process_flg=0
   AND i.posted_dt_tm=cnvtdatetime(posted_run_dt)
  DETAIL
   num_charges = (num_charges+ 1), stat = alterlist(charges->charges,num_charges), charges->charges[
   num_charges].charge_item_id = i.charge_item_id,
   charges->charges[num_charges].name = trim(i.person_name), charges->charges[num_charges].
   interface_file_id = i.interface_file_id, charges->charges[num_charges].old_bill_code1 = i
   .bill_code1,
   charges->charges[num_charges].old_bill_code2 = i.bill_code2, charges->charges[num_charges].
   old_bill_code3 = i.bill_code3, charges->charges[num_charges].old_prim_cdm = i.prim_cdm,
   charges->charges[num_charges].old_prim_cpt = i.prim_cpt, charges->charges[num_charges].
   old_diag_code1 = i.diag_code1, charges->charges[num_charges].old_diag_code2 = i.diag_code2,
   charges->charges[num_charges].old_diag_code3 = i.diag_code3, charges->charges[num_charges].
   old_prim_icd9_proc = i.prim_icd9_proc, charges->charges[num_charges].old_code_modifier1_cd = i
   .code_modifier1_cd,
   charges->charges[num_charges].old_code_modifier2_cd = i.code_modifier2_cd, charges->charges[
   num_charges].old_code_modifier3_cd = i.code_modifier3_cd, charges->charges[num_charges].
   new_bill_code1 = fillstring(50," "),
   charges->charges[num_charges].new_bill_code2 = fillstring(50," "), charges->charges[num_charges].
   new_bill_code3 = fillstring(50," "), charges->charges[num_charges].new_prim_cdm = fillstring(50,
    " "),
   charges->charges[num_charges].new_prim_cpt = fillstring(50," "), charges->charges[num_charges].
   new_diag_code1 = fillstring(50," "), charges->charges[num_charges].new_diag_code2 = fillstring(50,
    " "),
   charges->charges[num_charges].new_diag_code3 = fillstring(50," "), charges->charges[num_charges].
   new_prim_icd9_proc = fillstring(50," "), charges->charges[num_charges].new_code_modifier1_cd = 0,
   charges->charges[num_charges].new_code_modifier2_cd = 0, charges->charges[num_charges].
   new_code_modifier3_cd = 0
  WITH nocounter
 ;end select
 CALL echorecord(charges,"ccluserdir:afc_chk_bc.out")
 IF (value(size(charges->charges,5)) > 0)
  SELECT INTO "nl:"
   FROM interface_file i,
    (dummyt d1  WITH seq = value(size(charges->charges,5)))
   PLAN (d1)
    JOIN (i
    WHERE (i.interface_file_id=charges->charges[d1.seq].interface_file_id))
   DETAIL
    charges->charges[d1.seq].mult_bill_cd = i.mult_bill_code_sched_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1
     AND (cm.field1_id=charges->charges[d1.seq].mult_bill_cd))
   DETAIL
    IF ((charges->charges[d1.seq].mult_bill_cd > 0))
     IF (cm.field2_id=2)
      IF ((charges->charges[d1.seq].old_bill_code1 > " "))
       IF ((charges->charges[d1.seq].old_bill_code1 != cm.field6))
        charges->charges[d1.seq].new_bill_code1 = cm.field6
       ELSE
        charges->charges[d1.seq].new_bill_code1 = charges->charges[d1.seq].old_bill_code1
       ENDIF
      ELSE
       charges->charges[d1.seq].new_bill_code1 = cm.field6
      ENDIF
     ENDIF
     IF (cm.field2_id=3)
      IF ((charges->charges[d1.seq].old_bill_code2 > " "))
       IF ((charges->charges[d1.seq].old_bill_code2 != cm.field6))
        charges->charges[d1.seq].new_bill_code2 = cm.field6
       ELSE
        charges->charges[d1.seq].new_bill_code2 = charges->charges[d1.seq].old_bill_code2
       ENDIF
      ELSE
       charges->charges[d1.seq].new_bill_code2 = cm.field6
      ENDIF
     ENDIF
     IF (cm.field2_id=4)
      IF ((charges->charges[d1.seq].old_bill_code3 > " "))
       IF ((charges->charges[d1.seq].old_bill_code3 != cm.field6))
        charges->charges[d1.seq].new_bill_code3 = cm.field6
       ELSE
        charges->charges[d1.seq].new_bill_code3 = charges->charges[d1.seq].old_bill_code3
       ENDIF
      ELSE
       charges->charges[d1.seq].new_bill_code3 = cm.field6
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5))),
    (dummyt d2  WITH seq = value(size(cdm_codes->code_vals,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1)
    JOIN (d2
    WHERE (cm.field1_id=cdm_codes->code_vals[d2.seq].code_val))
   DETAIL
    IF (cm.field2_id=1)
     IF ((charges->charges[d1.seq].old_prim_cdm > " "))
      IF ((charges->charges[d1.seq].old_prim_cdm != cm.field6))
       charges->charges[d1.seq].new_prim_cdm = cm.field6
      ELSE
       charges->charges[d1.seq].new_prim_cdm = charges->charges[d1.seq].old_prim_cdm
      ENDIF
     ELSE
      charges->charges[d1.seq].new_prim_cdm = cm.field6
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5))),
    (dummyt d2  WITH seq = value(size(cpt_codes->code_vals,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1)
    JOIN (d2
    WHERE (cm.field1_id=cpt_codes->code_vals[d2.seq].code_val))
   DETAIL
    IF (cm.field2_id=1)
     IF ((charges->charges[d1.seq].old_prim_cpt > " "))
      IF ((charges->charges[d1.seq].old_prim_cpt != cm.field6))
       charges->charges[d1.seq].new_prim_cpt = cm.field6
      ELSE
       charges->charges[d1.seq].new_prim_cpt = charges->charges[d1.seq].old_prim_cpt
      ENDIF
     ELSE
      charges->charges[d1.seq].new_prim_cpt = cm.field6
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5))),
    (dummyt d2  WITH seq = value(size(icd9_proc_codes->code_vals,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1)
    JOIN (d2
    WHERE (cm.field1_id=icd9_proc_codes->code_vals[d2.seq].code_val))
   DETAIL
    IF (cm.field2_id=1)
     IF ((charges->charges[d1.seq].old_prim_icd9_proc > " "))
      IF ((charges->charges[d1.seq].old_prim_icd9_proc != cm.field6))
       charges->charges[d1.seq].new_prim_icd9_proc = cm.field6
      ELSE
       charges->charges[d1.seq].new_prim_icd9_proc = charges->charges[d1.seq].old_prim_icd9_proc
      ENDIF
     ELSE
      charges->charges[d1.seq].new_prim_icd9_proc = cm.field6
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5))),
    (dummyt d2  WITH seq = value(size(icd9_diag_codes->code_vals,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1)
    JOIN (d2
    WHERE (cm.field1_id=icd9_diag_codes->code_vals[d2.seq].code_val))
   DETAIL
    IF (cm.field2_id=1)
     IF ((charges->charges[d1.seq].old_diag_code1 > " "))
      IF ((charges->charges[d1.seq].old_diag_code1 != cm.field6))
       charges->charges[d1.seq].new_diag_code1 = cm.field6
      ELSE
       charges->charges[d1.seq].new_diag_code1 = charges->charges[d1.seq].old_diag_code1
      ENDIF
     ELSE
      charges->charges[d1.seq].new_diag_code1 = cm.field6
     ENDIF
    ENDIF
    IF (cm.field2_id=2)
     IF ((charges->charges[d1.seq].old_diag_code2 > " "))
      IF ((charges->charges[d1.seq].old_diag_code2 != cm.field6))
       charges->charges[d1.seq].new_diag_code2 = cm.field6
      ELSE
       charges->charges[d1.seq].new_diag_code2 = charges->charges[d1.seq].old_diag_code2
      ENDIF
     ELSE
      charges->charges[d1.seq].new_diag_code2 = cm.field6
     ENDIF
    ENDIF
    IF (cm.field2_id=3)
     IF ((charges->charges[d1.seq].old_diag_code3 > " "))
      IF ((charges->charges[d1.seq].old_diag_code3 != cm.field6))
       charges->charges[d1.seq].new_diag_code3 = cm.field6
      ELSE
       charges->charges[d1.seq].new_diag_code3 = charges->charges[d1.seq].old_diag_code3
      ENDIF
     ELSE
      charges->charges[d1.seq].new_diag_code3 = cm.field6
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_mod cm,
    (dummyt d1  WITH seq = value(size(charges->charges,5)))
   PLAN (d1)
    JOIN (cm
    WHERE (cm.charge_item_id=charges->charges[d1.seq].charge_item_id)
     AND cm.charge_mod_type_cd=bill_code_cd
     AND cm.active_ind=1
     AND cm.field1_id=modifier_cd)
   DETAIL
    IF (cm.field2_id=1)
     IF ((charges->charges[d1.seq].old_code_modifier1_cd > 0))
      IF ((charges->charges[d1.seq].old_code_modifier1_cd != cm.field3_id))
       charges->charges[d1.seq].new_code_modifier1_cd = cm.field3_id
      ELSE
       charges->charges[d1.seq].new_code_modifier1_cd = charges->charges[d1.seq].
       old_code_modifier1_cd
      ENDIF
     ELSE
      charges->charges[d1.seq].new_code_modifier1_cd = cm.field3_id
     ENDIF
    ENDIF
    IF (cm.field2_id=2)
     IF ((charges->charges[d1.seq].old_code_modifier2_cd > 0))
      IF ((charges->charges[d1.seq].old_code_modifier2_cd != cm.field3_id))
       charges->charges[d1.seq].new_code_modifier2_cd = cm.field3_id
      ELSE
       charges->charges[d1.seq].new_code_modifier2_cd = charges->charges[d1.seq].
       old_code_modifier2_cd
      ENDIF
     ELSE
      charges->charges[d1.seq].new_code_modifier2_cd = cm.field3_id
     ENDIF
    ENDIF
    IF (cm.field2_id=3)
     IF ((charges->charges[d1.seq].old_code_modifier3_cd > 0))
      IF ((charges->charges[d1.seq].old_code_modifier3_cd != cm.field3_id))
       charges->charges[d1.seq].new_code_modifier3_cd = cm.field3_id
      ELSE
       charges->charges[d1.seq].new_code_modifier3_cd = charges->charges[d1.seq].
       old_code_modifier3_cd
      ENDIF
     ELSE
      charges->charges[d1.seq].new_code_modifier3_cd = cm.field3_id
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  FOR (counter = 1 TO value(size(charges->charges,5)))
    CALL echo(build("charge_item_id: ",charges->charges[counter].charge_item_id))
    IF ((((charges->charges[counter].old_bill_code1 != charges->charges[counter].new_bill_code1)) OR
    ((charges->charges[counter].mult_bill_cd=0)
     AND (charges->charges[counter].old_bill_code1 > " "))) )
     CALL echo("bill_code1 discrepancy")
     UPDATE  FROM interface_charge
      SET bill_code1 = charges->charges[counter].new_bill_code1, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((((charges->charges[counter].old_bill_code2 != charges->charges[counter].new_bill_code2)) OR
    ((charges->charges[counter].mult_bill_cd=0)
     AND (charges->charges[counter].old_bill_code2 > " "))) )
     CALL echo("bill_code2 discrepancy")
     UPDATE  FROM interface_charge
      SET bill_code2 = charges->charges[counter].new_bill_code2, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((((charges->charges[counter].old_bill_code3 != charges->charges[counter].new_bill_code3)) OR
    ((charges->charges[counter].mult_bill_cd=0)
     AND (charges->charges[counter].old_bill_code3 > " "))) )
     CALL echo("bill_code3 discrepancy")
     UPDATE  FROM interface_charge
      SET bill_code3 = charges->charges[counter].new_bill_code3, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_prim_cdm != charges->charges[counter].new_prim_cdm))
     CALL echo("prim_cdm discrepancy")
     UPDATE  FROM interface_charge
      SET prim_cdm = charges->charges[counter].new_prim_cdm, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_prim_cpt != charges->charges[counter].new_prim_cpt))
     CALL echo("prim_cpt discrepancy")
     UPDATE  FROM interface_charge
      SET prim_cpt = charges->charges[counter].new_prim_cpt, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_prim_icd9_proc != charges->charges[counter].new_prim_icd9_proc
    ))
     CALL echo("prim_icd9_proc discrepancy")
     UPDATE  FROM interface_charge
      SET prim_icd9_proc = charges->charges[counter].new_prim_icd9_proc, updt_id = 13659, updt_dt_tm
        = cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_diag_code1 != charges->charges[counter].new_diag_code1))
     CALL echo("diag1 discrepancy")
     UPDATE  FROM interface_charge
      SET diag_code1 = charges->charges[counter].new_diag_code1, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_diag_code2 != charges->charges[counter].new_diag_code2))
     CALL echo("diag2 discrepancy")
     UPDATE  FROM interface_charge
      SET diag_code2 = charges->charges[counter].new_diag_code2, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_diag_code3 != charges->charges[counter].new_diag_code3))
     CALL echo("diag3 discrepancy")
     UPDATE  FROM interface_charge
      SET diag_code3 = charges->charges[counter].new_diag_code3, updt_id = 13659, updt_dt_tm =
       cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_code_modifier1_cd != charges->charges[counter].
    new_code_modifier1_cd))
     CALL echo("mod1 discrepancy")
     UPDATE  FROM interface_charge
      SET code_modifier1_cd = charges->charges[counter].new_code_modifier1_cd, updt_id = 13659,
       updt_dt_tm = cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_code_modifier2_cd != charges->charges[counter].
    new_code_modifier2_cd))
     CALL echo("mod2 discrepancy")
     UPDATE  FROM interface_charge
      SET code_modifier2_cd = charges->charges[counter].new_code_modifier2_cd, updt_id = 13659,
       updt_dt_tm = cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    IF ((charges->charges[counter].old_code_modifier3_cd != charges->charges[counter].
    new_code_modifier3_cd))
     CALL echo("mod3 discrepancy")
     UPDATE  FROM interface_charge
      SET code_modifier3_cd = charges->charges[counter].new_code_modifier3_cd, updt_id = 13659,
       updt_dt_tm = cnvtdatetime(run_date)
      WHERE (charge_item_id=charges->charges[counter].charge_item_id)
     ;end update
    ENDIF
    COMMIT
  ENDFOR
  CALL echo(build("********************************"))
  CALL echo(build("# of charges: ",value(size(charges->charges,5))))
  SET equal_line = fillstring(130,"=")
  SELECT INTO "ccluserdir:afc_bc_rpt.dat"
   charge_item_id = charges->charges[d1.seq].charge_item_id, name = trim(charges->charges[d1.seq].
    name), old_bill_code1 = charges->charges[d1.seq].old_bill_code1,
   new_bill_code1 = charges->charges[d1.seq].new_bill_code1, old_bill_code2 = charges->charges[d1.seq
   ].old_bill_code2, new_bill_code2 = charges->charges[d1.seq].new_bill_code2,
   old_bill_code3 = charges->charges[d1.seq].old_bill_code3, new_bill_code3 = charges->charges[d1.seq
   ].new_bill_code3, old_prim_cdm = charges->charges[d1.seq].old_prim_cdm,
   new_prim_cdm = charges->charges[d1.seq].new_prim_cdm, old_prim_cpt = charges->charges[d1.seq].
   old_prim_cpt, new_prim_cpt = charges->charges[d1.seq].new_prim_cpt,
   old_prim_icd9_proc = charges->charges[d1.seq].old_prim_icd9_proc, new_prim_icd9_proc = charges->
   charges[d1.seq].new_prim_icd9_proc, old_diag_code1 = charges->charges[d1.seq].old_diag_code1,
   new_diag_code1 = charges->charges[d1.seq].new_diag_code1, old_diag_code2 = charges->charges[d1.seq
   ].old_diag_code2, new_diag_code2 = charges->charges[d1.seq].new_diag_code2,
   old_diag_code3 = charges->charges[d1.seq].old_diag_code3, new_diag_code3 = charges->charges[d1.seq
   ].new_diag_code3, old_code_modifier1_cd = charges->charges[d1.seq].old_code_modifier1_cd,
   new_code_modifier1_cd = charges->charges[d1.seq].new_code_modifier1_cd, old_code_modifier2_cd =
   charges->charges[d1.seq].old_code_modifier2_cd, new_code_modifier2_cd = charges->charges[d1.seq].
   new_code_modifier2_cd,
   old_code_modifier3_cd = charges->charges[d1.seq].old_code_modifier3_cd, new_code_modifier3_cd =
   charges->charges[d1.seq].new_code_modifier3_cd, rpt_date = concat(format(run_date,"DD-MMM-YYYY;;D"
     ),format(run_date," HH:MM:SS;;S"))
   FROM (dummyt d1  WITH seq = value(size(charges->charges,5)))
   ORDER BY name, charge_item_id
   HEAD REPORT
    col 50, "** Bill Code Discrepancy Report **", col 90,
    "Run Date: ", rpt_date, row + 2
   HEAD PAGE
    col 120, "Page: ", curpage"##",
    row + 1, col 00, "Person Name",
    row + 1, col 10, "Charge Item Id",
    row + 1, col 30, "Old Bill Code",
    col 50, "New Bill Code", row + 1,
    col 00, equal_line, row + 1
   HEAD name
    col 00, name, row + 1
   DETAIL
    col 10, charge_item_id, row + 2
    IF (old_bill_code1 != new_bill_code1)
     col 30, old_bill_code1, col 50,
     new_bill_code1, row + 1
    ENDIF
    IF (old_bill_code2 != new_bill_code2)
     col 30, old_bill_code2, col 50,
     new_bill_code2, row + 1
    ENDIF
    IF (old_bill_code3 != new_bill_code3)
     col 30, old_bill_code3, col 50,
     new_bill_code3, row + 1
    ENDIF
    IF (old_prim_cdm != new_prim_cdm)
     col 30, old_prim_cdm, col 50,
     new_prim_cdm, row + 1
    ENDIF
    IF (old_prim_cpt != new_prim_cpt)
     col 30, old_prim_cpt, col 50,
     new_prim_cpt, row + 1
    ENDIF
    IF (old_diag_code1 != new_diag_code1)
     col 30, old_diag_code1, col 50,
     new_diag_code1, row + 1
    ENDIF
    IF (old_diag_code2 != new_diag_code2)
     col 30, old_diag_code2, col 50,
     new_diag_code2, row + 1
    ENDIF
    IF (old_diag_code3 != new_diag_code3)
     col 30, old_diag_code3, col 50,
     new_diag_code3, row + 1
    ENDIF
    IF (old_prim_icd9_proc != new_prim_icd9_proc)
     col 30, old_prim_icd9_proc, col 50,
     new_prim_icd9_proc, row + 1
    ENDIF
    IF (old_code_modifier1_cd != new_code_modifier1_cd)
     col 30, old_code_modifier1_cd, col 50,
     new_code_modifier1_cd, row + 1
    ENDIF
    IF (old_code_modifier2_cd != new_code_modifier2_cd)
     col 30, old_code_modifier2_cd, col 50,
     new_code_modifier2_cd, row + 1
    ENDIF
    IF (old_code_modifier3_cd != new_code_modifier3_cd)
     col 30, old_code_modifier3_cd, col 50,
     new_code_modifier3_cd, row + 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  CALL echo("No charges found.")
 ENDIF
END GO
