CREATE PROGRAM afc_rpt_charges_audit:dba
 PAINT
 SET width = 140
 SET modify = system
 RECORD request(
   1 from_dt_tm = dq8
   1 to_dt_tm = dq8
   1 debug_flag = c1
   1 file_name = vc
   1 payor_id = f8
 )
 RECORD rpt(
   1 data[*]
     2 order_id = f8
     2 updt_dt_tm = dq8
     2 ord_stat = c10
     2 ord_desc = c15
     2 charge_item_id = f8
     2 name = c20
     2 mrn = c13
     2 encntr_type = c2
     2 fin = c13
     2 desc = c20
     2 qty = c4
     2 ext_price = c8
     2 status = c4
     2 cdm_num = c8
     2 cpt_num = c8
     2 nc = c8
     2 dt_tm = dq8
     2 accession = c21
     2 drawn_dt_tm = dq8
 )
 RECORD reply(
   1 file_name = vc
   1 page_count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[3]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET status_codeset = 48
 SET status_mean_active = "ACTIVE"
 SET charge_type_codeset = 13028
 SET charge_type_mean_suspended = "SUSPENDED"
 SET person_alias_codeset = 319
 SET person_alias_mean_med_rec_num = "MRN"
 SET encounter_alias_codeset = 319
 SET encounter_alias_mean_fin_num = "FIN NBR"
 SET bill_org_type_codeset = 13031
 SET bill_org_mean_mnem = "BILLMNEM"
 SET bill_item_type_codeset = 13019
 SET bill_item_mean_billcode = "BILL CODE"
 SET charge_debit = 0.0
 SET charge_credit = 0.0
 SET charge_nocharge = 0.0
 SET mrn_nbr = 0
 SET fin_nbr = 0
 SET request->from_dt_tm = curdate
 SET request->to_dt_tm = cnvtdatetime(concat(format(curdate,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET end_date = concat(format(curdate,"DD-MMM-YYYY;;D")," 23:59:59.99")
 SET all = "Y"
 SET pending = "N"
 SET suspend1 = "N"
 SET suspend2 = "N"
 SET onhold = "N"
 SET manual = "N"
 SET absorb = "N"
 SET combine = "N"
 SET offsets = "N"
 SET charged = "N"
 SET allct = "Y"
 SET debits = "N"
 SET credits = "N"
 SET nocharge = "N"
 SET mr# = "Y"
 SET fin# = "N"
 DECLARE uar_fmt_accession(p1,p2) = c25
 SET reply->status_data.status = "F"
 SET g_code_value = 0.0
 SET g_status_code_active = 0.0
 SET g_charge_type_suspended = 0.0
 SET g_person_alias_med_rec_num = 0.0
 SET g_encounter_alias_fin_num = 0.0
 SET g_bill_org_type_mnem = 0.0
 SET g_bill_item_type_billcode = 0.0
 SET tpa_num = 0
 SET cpt4_num = 0.0
#main
 SET i = 0
 CALL get_code_value(status_codeset,status_mean_active)
 SET g_status_code_active = g_code_value
 IF (failed=false)
  CALL get_code_value(person_alias_codeset,person_alias_mean_med_rec_num)
  SET g_person_alias_med_rec_num = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(encounter_alias_codeset,encounter_alias_mean_fin_num)
  SET g_encounter_alias_fin_num = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(bill_item_type_codeset,bill_item_mean_billcode)
  SET g_bill_item_type_billcode = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(13028,"CR")
  SET charge_credit = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(13028,"DR")
  SET charge_debit = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(13028,"NO CHARGE")
  SET charge_nocharge = g_code_value
 ENDIF
 RECORD pf(
   1 p[10]
     2 flg = i4
 )
 FOR (i = 1 TO 10)
   SET pf->p[i].flg = 1000
 ENDFOR
 RECORD ct(
   1 c[10]
     2 flg = i4
 )
 FOR (i = 1 TO 10)
   SET ct->c[i].flg = - (1)
 ENDFOR
 RECORD pi(
   1 p[10]
     2 flg = i4
 )
 FOR (i = 1 TO 10)
   SET pi->p[i].flg = - (1)
 ENDFOR
 RECORD cdm_nums(
   1 cdm_occ[100]
     2 cdm_num = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.cdf_meaning="CDM_SCHED"
   AND c.active_ind=true
  DETAIL
   count1 += 1, cdm_nums->cdm_occ[count1].cdm_num = c.code_value
  WITH nocounter
 ;end select
 SET cdm_numbers = count1
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=14002
   AND c.display_key="CPT4"
   AND c.active_ind=true
  DETAIL
   cpt4_num = c.code_value
  WITH nocounter
 ;end select
#menu
 SET find_key = fillstring(40," ")
 SET cv_first_time = "Y"
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,100)
 CALL text(2,1,"Charge Report Menu",w)
 CALL text(7,20," 1)  *Inactive*")
 CALL text(8,20," 2)  Date Range")
 CALL text(9,20," 3)  Charge Type")
 CALL text(10,20," 4)  Charge Status")
 CALL text(11,20," 5)  Patient Identifier")
 CALL text(15,20," 6)  Create Report")
 CALL text(17,20," 7)  Exit")
 CALL text(24,2,"Select Option (1,2,3,...)")
 CALL accept(24,29,"9;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   GO TO owner_cd
  OF 2:
   GO TO date_range
  OF 3:
   GO TO charge_type
  OF 4:
   GO TO process_flg
  OF 5:
   GO TO patient_ind
  OF 6:
   IF (failed=false)
    IF (all="Y")
     SET pf->p[1].flg = 0
     SET pf->p[2].flg = 1
     SET pf->p[3].flg = 2
     SET pf->p[4].flg = 3
     SET pf->p[5].flg = 4
     SET pf->p[6].flg = 5
     SET pf->p[7].flg = 6
     SET pf->p[8].flg = 7
     SET pf->p[9].flg = 10
     SET pf->p[10].flg = 999
    ELSE
     IF (pending="Y")
      SET pf->p[1].flg = 0
     ENDIF
     IF (suspend1="Y")
      SET pf->p[2].flg = 1
     ENDIF
     IF (suspend2="Y")
      SET pf->p[3].flg = 2
     ENDIF
     IF (onhold="Y")
      SET pf->p[4].flg = 3
     ENDIF
     IF (manual="Y")
      SET pf->p[5].flg = 4
     ENDIF
     IF (absorb="Y")
      SET pf->p[6].flg = 5
     ENDIF
     IF (combine="Y")
      SET pf->p[7].flg = 6
     ENDIF
     IF (offsets="Y")
      SET pf->p[8].flg = 10
     ENDIF
     IF (charged="Y")
      SET pf->p[9].flg = 999
     ENDIF
    ENDIF
    IF (allct="Y")
     SET ct->c[1].flg = charge_debit
     SET ct->c[2].flg = charge_credit
     SET ct->c[3].flg = charge_nocharge
     SET ct->c[4].flg = 0
    ELSE
     IF (debits="Y")
      SET ct->c[1].flg = charge_debit
      SET ct->c[4].flg = 0
     ENDIF
     IF (credits="Y")
      SET ct->c[2].flg = charge_credit
     ENDIF
     IF (nocharge="Y")
      SET ct->c[3].flg = charge_nocharge
     ENDIF
    ENDIF
    IF (mr#="Y")
     SET pi->p[1].flg = mrn_nbr
    ELSE
     IF (fin#="Y")
      SET pi->p[2].flg = fin_nbr
     ENDIF
    ENDIF
    CALL get_charges(0)
   ENDIF
   CALL check_error(failed)
   GO TO main_exit
  OF 7:
   GO TO the_end
  ELSE
   GO TO the_end
 ENDCASE
 GO TO menu
#main_exit
 GO TO end_program
 SUBROUTINE get_code_value(l_code_set,l_cdf_meaning)
   SET g_code_value = 0.0
   SET table_name = "code_value"
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=l_code_set
     AND c.cdf_meaning=l_cdf_meaning
     AND c.active_ind=true
    DETAIL
     g_code_value = c.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = select_error
   ENDIF
 END ;Subroutine
 SUBROUTINE get_charges(l_dummy)
   SET pagecount = 0
   SET lower_owner = 00000000.0
   SET upper_owner = 99999999.9
   IF (trim(request->file_name,3)="")
    SET request->file_name = "MINE"
    SET filename = "MINE"
   ELSEIF (cnvtupper(trim(request->file_name))="MINE")
    SET filename = "MINE"
   ELSE
    SET filename = concat("CER_DATA:[TEMP]",trim(request->file_name,3))
    SET dclcom = concat("delete ",trim(filename,3),".dat;* ")
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
   ENDIF
   CALL echo(build("filename: ",filename,".dat "))
   IF ((request->payor_id > 0))
    SET lower_owner = request->payor_id
    SET upper_owner = request->payor_id
   ENDIF
   SET count1 = 0
   SET count2 = 0
   SET fnc = 0
   SET mrnc = 0
   SELECT INTO "nl:"
    o.order_mnemonic, o.order_status_cd, o.order_id,
    cv_os.display, o.updt_dt_tm, c.charge_item_id,
    c.order_id, c.charge_event_id, c.bill_item_id,
    c.payor_id, c.item_quantity, c.item_extended_price,
    c.charge_description, c.charge_type_cd, c.activity_dt_tm,
    c.process_flg, c.person_id, c.encntr_id,
    p.name_full_formatted, e.encntr_type_cd, e.organization_id,
    cv_etc.display, mrn = cnvtstring(trim(pa.alias)), oapr_eapc.alias_pool_cd,
    fn = cnvtstring(trim(ea.alias)), cm.charge_mod_id, cm.field1_id,
    cm.field2, c.order_id, aor.order_id
    FROM charge c,
     (dummyt o_ch  WITH seq = 1),
     orders o,
     person p,
     encounter e,
     code_value cv_etc,
     code_value cv_os,
     encntr_alias pa,
     org_alias_pool_reltn oapr_eapc,
     encntr_alias ea,
     (dummyt d_cm  WITH seq = 1),
     charge_mod cm,
     accession_order_r aor
    PLAN (o
     WHERE o.active_ind=true
      AND o.updt_dt_tm >= cnvtdatetime(request->from_dt_tm)
      AND o.updt_dt_tm >= cnvtdatetime(end_date))
     JOIN (cv_os
     WHERE o.order_status_cd=cv_os.code_value
      AND cv_os.active_ind=true)
     JOIN (o_ch)
     JOIN (c
     WHERE c.active_ind=true
      AND (((c.process_flg=pf->p[1].flg)) OR ((((c.process_flg=pf->p[2].flg)) OR ((((c.process_flg=pf
     ->p[3].flg)) OR ((((c.process_flg=pf->p[4].flg)) OR ((((c.process_flg=pf->p[5].flg)) OR ((((c
     .process_flg=pf->p[6].flg)) OR ((((c.process_flg=pf->p[7].flg)) OR ((((c.process_flg=pf->p[8].
     flg)) OR ((((c.process_flg=pf->p[9].flg)) OR ((c.process_flg=pf->p[10].flg))) )) )) )) )) )) ))
     )) ))
      AND (((c.charge_type_cd=ct->c[1].flg)) OR ((((c.charge_type_cd=ct->c[2].flg)) OR ((((c
     .charge_type_cd=ct->c[3].flg)) OR ((c.charge_type_cd=ct->c[4].flg))) )) )) )
     JOIN (p
     WHERE p.person_id=c.person_id
      AND p.active_ind=true)
     JOIN (e
     WHERE e.encntr_id=c.encntr_id
      AND e.active_ind=true)
     JOIN (cv_etc
     WHERE cv_etc.code_value=e.encntr_type_cd
      AND cv_etc.active_ind=true)
     JOIN (pa
     WHERE pa.encntr_id=c.encntr_id
      AND pa.encntr_alias_type_cd=g_person_alias_med_rec_num
      AND pa.active_ind=true)
     JOIN (oapr_eapc
     WHERE oapr_eapc.organization_id=c.payor_id
      AND oapr_eapc.alias_entity_name="ENCNTR_ALIAS"
      AND oapr_eapc.alias_entity_alias_type_cd=g_encounter_alias_fin_num
      AND oapr_eapc.active_ind=true)
     JOIN (ea
     WHERE ea.encntr_id=c.encntr_id
      AND ea.alias_pool_cd=oapr_eapc.alias_pool_cd
      AND ea.encntr_alias_type_cd=g_encounter_alias_fin_num
      AND ea.active_ind=true)
     JOIN (d_cm)
     JOIN (cm
     WHERE cm.charge_item_id=c.charge_item_id
      AND cm.charge_mod_type_cd=g_bill_item_type_billcode
      AND cm.active_ind=true)
     JOIN (aor
     WHERE c.order_id=aor.order_id
      AND aor.accession_id != 0)
    ORDER BY o.order_id
    DETAIL
     count2 += 1, stat = alterlist(rpt->data,count2), i = 0,
     stopx = cnvtint(size(mrn)), stopi = cnvtint(size(mrn))
     FOR (i = 1 TO stopx)
       IF (substring(i,1,mrn)=" ")
        stopi = (i - 1), i = cnvtint(size(mrn))
       ENDIF
     ENDFOR
     spcs = 0
     IF (stopi > 13)
      mrn8 = substring((stopi - 12),13,mrn), mrnc = 25
     ELSE
      mrn8 = substring(1,stopi,mrn), mrnc = ((25+ 13) - stopi)
     ENDIF
     i = 0, stopx = cnvtint(size(fn)), stopi = cnvtint(size(fn))
     FOR (i = 1 TO stopx)
       IF (substring(i,1,fn)=" ")
        stopi = (i - 1), i = cnvtint(size(fn))
       ENDIF
     ENDFOR
     spcs = 0
     IF (stopi > 13)
      fns = substring((stopi - 12),13,fn), fnc = 39
     ELSE
      fns = substring(1,stopi,fn), fnc = ((39+ 13) - stopi)
     ENDIF
     mrn8 = format(cnvtreal(trim(mrn)),"#############"), fns = format(cnvtreal(trim(fn)),
      "#############"), rpt->data[count2].order_id = c.order_id,
     rpt->data[count2].charge_item_id = c.charge_item_id, rpt->data[count2].dt_tm = o.updt_dt_tm, rpt
     ->data[count2].encntr_type = format(cv_etc.display,"##"),
     rpt->data[count2].name = p.name_full_formatted
     IF ((pi->p[1].flg=mrn_nbr))
      rpt->data[count2].mrn = mrn8
     ELSE
      rpt->data[count2].fin = fns
     ENDIF
     rpt->data[count2].ord_desc = format(o.order_mnemonic,"###############"), rpt->data[count2].
     ord_stat = cv_os.display, rpt->data[count2].desc = format(c.charge_description,
      "#####################"),
     rpt->data[count2].qty = format(c.item_quantity,"####"), rpt->data[count2].ext_price = format(c
      .item_extended_price,"#####.##"), rpt->data[count2].accession = uar_fmt_accession(aor.accession,
      size(aor.accession,1))
     IF (c.process_flg=0)
      rpt->data[count2].status = "Pend"
     ELSEIF (c.process_flg=999)
      rpt->data[count2].status = "Chrg"
     ELSEIF (c.process_flg=1)
      rpt->data[count2].status = "Data"
     ELSEIF (c.process_flg=2)
      rpt->data[count2].status = "Miss"
     ELSEIF (c.process_flg=3)
      rpt->data[count2].status = "Held"
     ELSEIF (c.process_flg=4)
      rpt->data[count2].status = "Man"
     ELSEIF (c.process_flg=5)
      rpt->data[count2].status = "Abs"
     ELSEIF (c.process_flg=6)
      rpt->data[count2].status = "Comb"
     ELSEIF (c.process_flg=10)
      rpt->data[count2].status = "Offs"
     ENDIF
     IF (cm.field4 != null
      AND cm.field4 > " ")
      FOR (count1 = 1 TO cdm_numbers)
        IF (cm.field1_id != null
         AND cm.field1_id > 0)
         IF ((cm.field1_id=cdm_nums->cdm_occ[count1].cdm_num))
          rpt->data[count2].cdm_num = format(cm.field2,"########"), count1 = cdm_numbers
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (cm.field1_id != null
      AND cm.field1_id > 0)
      IF (cm.field1_id=cpt4_num)
       rpt->data[count2].cpt_num = format(cm.field2,"########")
      ENDIF
     ENDIF
     IF ((c.charge_type_cd=ct->c[3].flg))
      rpt->data[count2].nc = "nc"
     ENDIF
    WITH nocounter, outerjoin = d_cm
   ;end select
   SELECT INTO "nl:"
    cn.drawn_dt_tm
    FROM (dummyt d1  WITH seq = value(count2)),
     order_container_r ocr,
     container cn
    PLAN (d1)
     JOIN (ocr
     WHERE (ocr.order_id=rpt->data[d1.seq].order_id))
     JOIN (cn
     WHERE cn.container_id=ocr.container_id)
    DETAIL
     rpt->data[d1.seq].drawn_dt_tm = cn.drawn_dt_tm
    WITH nocounter
   ;end select
   SET old_order_id = - (1)
   SET old_charge_item_id = - (1)
   SELECT INTO value(filename)
    nm = rpt->data[d1.seq].name
    FROM (dummyt d1  WITH seq = value(count2))
    PLAN (d1)
    ORDER BY rpt->data[d1.seq].name, rpt->data[d1.seq].order_id, rpt->data[d1.seq].dt_tm
    HEAD REPORT
     team_name = "Cerner - Foundation Charge Services", report_name =
     "Order Status -> Charge Audit Report", line140 = fillstring(133,"-"),
     firsttime = true, billcodetab = 1
    HEAD PAGE
     col 01, team_name, col 95,
     report_name, row + 1, col 01,
     line140, row + 2, col 01,
     "Person Name", col 15, "PT"
     IF ((pi->p[1].flg=mrn_nbr))
      col 18, " MR # "
     ELSE
      col 18, " FIN #"
     ENDIF
     col 32, "Ord Stat", col 40,
     "Accession #", col 54, " Date     Time",
     col 70, "  Procedure      ", col 91,
     "CDM #", col 100, "CPT-4",
     col 109, "Qty", col 121,
     "Charge  ", row + 1, col 01,
     "-----------", col 15, "--",
     col 18, "-------------", col 32,
     "-----------", col 40, "-----------------------------",
     col 70, "--------------------", col 91,
     "--------", col 100, "--------",
     col 109, "---", col 121,
     "--------"
    HEAD nm
     row + 1, col 01, rpt->data[d1.seq].name"####################"
    DETAIL
     IF ((old_charge_item_id=rpt->data[d1.seq].charge_item_id))
      count1 = count1
     ELSE
      IF (((row+ 4) > maxrow))
       BREAK
      ENDIF
      old_charge_item_id = rpt->data[d1.seq].charge_item_id, row + 1, col 15,
      rpt->data[d1.seq].encntr_type
      IF ((pi->p[1].flg=mrn_nbr))
       col 18, rpt->data[d1.seq].mrn
      ELSE
       col 18, rpt->data[d1.seq].fin
      ENDIF
      col 32, rpt->data[d1.seq].ord_stat, col 40,
      rpt->data[d1.seq].accession, col 70, rpt->data[d1.seq].desc,
      col 108, rpt->data[d1.seq].qty, col 121,
      rpt->data[d1.seq].ext_price, col 114, rpt->data[d1.seq].status
      IF ((rpt->data[d1.seq].drawn_dt_tm != 0))
       col 54, rpt->data[d1.seq].drawn_dt_tm"DD-MMM-YY HH:MM;;D"
      ELSE
       col 54, rpt->data[d1.seq].dt_tm"DD-MMM-YY HH:MM;;D"
      ENDIF
     ENDIF
     IF ((rpt->data[d1.seq].cdm_num > " "))
      col 91, rpt->data[d1.seq].cdm_num
     ENDIF
     IF ((rpt->data[d1.seq].cpt_num > " "))
      col 100, rpt->data[d1.seq].cpt_num
     ENDIF
    FOOT PAGE
     row 58, col 01, line140,
     row + 1, col 01, "Printed: ",
     col 10, curdate"DDMMMYY;;D", col 18,
     curtime"HH:MM;;M", col 25, "By: ",
     col 29, curuser"######", col 114,
     "Page: ", col 120, curpage"###",
     pagecount = curpage
    WITH nocounter, maxcol = 200, outerjoin = d_oj_ocr
   ;end select
   SET reply->page_count = pagecount
   CALL echo(build("page_count = ",reply->page_count))
 END ;Subroutine
 SUBROUTINE check_error(error_ind)
   IF (error_ind=false)
    SET reply->status_data.status = "S"
   ELSE
    CASE (error_ind)
     OF gen_nbr_error:
      SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
     OF insert_error:
      SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     OF update_error:
      SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     OF replace_error:
      SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
     OF delete_error:
      SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     OF undelete_error:
      SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
     OF remove_error:
      SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
     OF attribute_error:
      SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
     OF lock_error:
      SET reply->status_data.subeventstatus[1].operationname = "LOCK"
     OF none_found:
      SET reply->status_data.subeventstatus[1].operationname = "NONE"
     OF select_error:
      SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     ELSE
      SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    ENDCASE
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
   ENDIF
 END ;Subroutine
#owner_cd
 GO TO menu
#date_range
 EXECUTE FROM display_dates TO display_dates_end
 EXECUTE FROM display_dates_fields TO display_dates_fields_end
 EXECUTE FROM accept_dates_fields TO accept_dates_fields_end
 GO TO menu
#charge_type
 EXECUTE FROM display_ct TO display_ct_end
 EXECUTE FROM display_ct_fields TO display_ct_fields_end
 EXECUTE FROM accept_ct_fields TO accept_ct_fields_end
 GO TO menu
#patient_ind
 EXECUTE FROM display_pi TO display_pi_end
 EXECUTE FROM display_pi_fields TO display_pi_fields_end
 EXECUTE FROM accept_pi_fields TO accept_pi_fields_end
 GO TO menu
#process_flg
 EXECUTE FROM display_processes TO display_processes_end
 EXECUTE FROM display_processes_fields TO display_processes_fields_end
 EXECUTE FROM accept_processes_fields TO accept_processes_fields_end
 GO TO menu
#display_dates
 CALL clear(1,1)
 CALL text(4,4,"01 Begin Date       : ")
 CALL text(5,4,"02 End Date         : ")
#display_dates_end
#display_dates_fields
 CALL video(nu)
 CALL text(4,29,format(request->from_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
 CALL text(5,29,format(request->to_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
 CALL video(n)
#display_dates_fields_end
#accept_dates_fields
 CALL video(n)
 CALL text(24,1,"Correct (Y/N/Q)?")
 CALL accept(24,18,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   GO TO accept_dates_fields_end
  OF "N":
   GO TO accept_dates_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_dates_fields
 ENDCASE
#accept_dates_01
 CALL accept(4,29,"nndpppdnnnndnndnn;cs",format(request->from_dt_tm,"dd-mmm-yyyy hh:mm;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=curaccept)
 CASE (curscroll)
  OF 0:
   SET request->from_dt_tm = cnvtdatetime(curaccept)
  OF 2:
   CALL text(4,29,format(request->from_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_01
  OF 3:
   CALL text(4,29,format(request->from_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_end
  ELSE
   GO TO accept_dates_01
 ENDCASE
#accept_dates_02
 CALL accept(5,29,"nndpppdnnnndnndnn;cs",format(request->to_dt_tm,"dd-mmm-yyyy hh:mm;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy hh:mm;;d")=curaccept)
 CASE (curscroll)
  OF 0:
   SET request->to_dt_tm = cnvtdatetime(curaccept)
   SET end_date = concat(curaccept," 23:59:59.99")
  OF 2:
   CALL text(5,29,format(request->to_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_01
  OF 3:
   CALL text(5,29,format(request->to_dt_tm,"DD-MMM-YYYY HH:MM;3;d"))
   GO TO accept_dates_end
  ELSE
   GO TO accept_dates_02
 ENDCASE
#accept_dates_end
 GO TO accept_dates_fields
#accept_dates_line_nbr
 CALL video(n)
 CALL text(24,1,"Line Number :")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"9;",0
  WHERE curaccept >= 0
   AND curaccept <= 8)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_dates_fields
  OF 1:
   GO TO accept_dates_01
  OF 2:
   GO TO accept_dates_02
  ELSE
   GO TO accept_dates_line_nbr
 ENDCASE
#accept_dates_fields_end
#display_ct
 CALL clear(1,1)
 CALL text(4,4,"01 All              : ")
 CALL text(5,4,"02 Debits           : ")
 CALL text(6,4,"03 Credits          : ")
 CALL text(7,4,"04 No Charges       : ")
#display_ct_end
#display_ct_fields
 CALL video(nu)
 CALL text(4,29,"Y")
 CALL text(5,29,"N")
 CALL text(6,29,"N")
 CALL text(7,29,"N")
 CALL video(n)
#display_ct_fields_end
#accept_ct_fields
 CALL video(n)
 CALL text(24,1,"Correct (Y/N/Q)?")
 CALL accept(24,18,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   GO TO accept_ct_fields_end
  OF "N":
   GO TO accept_ct_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_ct_fields
 ENDCASE
#accept_ct_01
 CALL accept(4,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET allct = curaccept
   CALL text(4,29,allct)
  OF 2:
   CALL text(4,29,allct)
   GO TO accept_ct_01
  OF 3:
   CALL text(4,29,allct)
   GO TO accept_ct_end
  ELSE
   GO TO accept_ct_01
 ENDCASE
#accept_ct_02
 CALL accept(5,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET debits = curaccept
   CALL text(5,29,debits)
  OF 2:
   CALL text(5,29,debits)
   GO TO accept_ct_01
  OF 3:
   CALL text(5,29,debits)
   GO TO accept_ct_end
  ELSE
   GO TO accept_ct_02
 ENDCASE
#accept_ct_03
 CALL accept(6,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET credits = curaccept
   CALL text(6,29,credits)
  OF 2:
   CALL text(6,29,credits)
   GO TO accept_ct_02
  OF 3:
   CALL text(6,29,credits)
   GO TO accept_ct_end
  ELSE
   GO TO accept_ct_03
 ENDCASE
#accept_ct_04
 CALL accept(7,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET nocharge = curaccept
   CALL text(7,29,nocharge)
  OF 2:
   CALL text(7,29,nocharge)
   GO TO accept_ct_03
  OF 3:
   CALL text(7,29,nocharge)
   GO TO accept_ct_end
  ELSE
   GO TO accept_ct_04
 ENDCASE
#accept_ct_end
 GO TO accept_ct_fields
#accept_ct_line_nbr
 CALL video(n)
 CALL text(24,1,"Line Number :")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"9;",0
  WHERE curaccept >= 0
   AND curaccept <= 8)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_ct_fields
  OF 1:
   GO TO accept_ct_01
  OF 2:
   GO TO accept_ct_02
  OF 3:
   GO TO accept_ct_03
  OF 4:
   GO TO accept_ct_04
  ELSE
   GO TO accept_ct_line_nbr
 ENDCASE
#accept_ct_fields_end
#display_pi
 CALL clear(1,1)
 CALL text(4,4,"01 MR#     :")
 CALL text(5,4,"02 FIN#    :")
#display_pi_end
#display_pi_fields
 CALL video(nu)
 CALL text(4,29,"Y")
 CALL text(5,29,"N")
 CALL video(n)
#display_pi_fields_end
#accept_pi_fields
 CALL video(n)
 CALL text(24,1,"Correct (Y/N/Q)?")
 CALL accept(24,18,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   GO TO accept_pi_fields_end
  OF "N":
   GO TO accept_pi_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_pi_fields
 ENDCASE
#accept_pi_01
 CALL accept(4,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET mr# = curaccept
   CALL text(4,29,mr#)
  OF 2:
   CALL text(4,29,mr#)
   GO TO accept_pi_01
  OF 3:
   CALL text(4,29,mr#)
   GO TO accept_pi_end
  ELSE
   GO TO accept_pi_01
 ENDCASE
#accept_pi_02
 CALL accept(5,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET fin# = curaccept
   CALL text(5,29,fin#)
  OF 2:
   CALL text(5,29,fin#)
   GO TO accept_pi_01
  OF 3:
   CALL text(5,29,fin#)
   GO TO accept_pi_end
  ELSE
   GO TO accept_pi_02
 ENDCASE
#accept_pi_end
 GO TO accept_pi_fields
#accept_pi_line_nbr
 CALL video(n)
 CALL text(24,1,"Line Number:")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"9;",0
  WHERE curaccept >= 0
   AND curaccept <= 2)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO pi_fields
  OF 1:
   GO TO accept_pi_01
  OF 2:
   GO TO accept_pi_02
  ELSE
   GO TO accept_pi_line_nbr
 ENDCASE
#accept_pi_fields_end
#display_processes
 CALL clear(1,1)
 CALL text(4,4,"01 All              : ")
 CALL text(5,4,"02 Pending          : ")
 CALL text(6,4,"03 Invalid Data     : ")
 CALL text(7,4,"04 Missing Data     : ")
 CALL text(8,4,"05 On Hold          : ")
 CALL text(9,4,"06 Manual Charges   : ")
 CALL text(10,4,"07 Absorbed Charges : ")
 CALL text(11,4,"08 Combined Charges : ")
 CALL text(12,4,"09 Offset Charges   : ")
 CALL text(13,4,"10 Posted Charges   : ")
#display_processes_end
#display_processes_fields
 CALL video(nu)
 CALL text(4,29,"Y")
 CALL text(5,29,"N")
 CALL text(6,29,"N")
 CALL text(7,29,"N")
 CALL text(8,29,"N")
 CALL text(9,29,"N")
 CALL text(10,29,"N")
 CALL text(11,29,"N")
 CALL text(12,29,"N")
 CALL text(13,29,"N")
 CALL video(n)
#display_processes_fields_end
#accept_processes_fields
 CALL video(n)
 CALL text(24,1,"Correct (Y/N/Q)?")
 CALL accept(24,18,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "Q"))
 CALL clear(24,1)
 CASE (curaccept)
  OF "Y":
   GO TO accept_processes_fields_end
  OF "N":
   GO TO accept_processes_line_nbr
  OF "Q":
   GO TO menu
  ELSE
   GO TO accept_processes_fields
 ENDCASE
#accept_processes_01
 CALL accept(4,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET all = curaccept
   CALL text(4,29,all)
  OF 2:
   CALL text(4,29,all)
   GO TO accept_processes_01
  OF 3:
   CALL text(4,29,all)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_01
 ENDCASE
#accept_processes_02
 CALL accept(5,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET pending = curaccept
   CALL text(5,29,pending)
  OF 2:
   CALL text(5,29,pending)
   GO TO accept_processes_01
  OF 3:
   CALL text(5,29,pending)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_02
 ENDCASE
#accept_processes_03
 CALL accept(6,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET suspend1 = curaccept
   CALL text(6,29,suspend1)
  OF 2:
   CALL text(6,29,suspend1)
   GO TO accept_processes_02
  OF 3:
   CALL text(6,29,suspend1)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_03
 ENDCASE
#accept_processes_04
 CALL accept(7,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET suspend2 = curaccept
   CALL text(7,29,suspend2)
  OF 2:
   CALL text(7,29,suspend2)
   GO TO accept_processes_03
  OF 3:
   CALL text(7,29,suspend2)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_04
 ENDCASE
#accept_processes_05
 CALL accept(8,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET onhold = curaccept
   CALL text(8,29,onhold)
  OF 2:
   CALL text(8,29,onhold)
   GO TO accept_processes_04
  OF 3:
   CALL text(8,29,onhold)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_05
 ENDCASE
#accept_processes_06
 CALL accept(9,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET manual = curaccept
   CALL text(9,29,manual)
  OF 2:
   CALL text(9,29,manual)
   GO TO accept_processes_05
  OF 3:
   CALL text(9,29,manual)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_06
 ENDCASE
#accept_processes_07
 CALL accept(10,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET absorb = curaccept
   CALL text(10,29,absorb)
  OF 2:
   CALL text(10,29,absorb)
   GO TO accept_processes_06
  OF 3:
   CALL text(10,29,absorb)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_07
 ENDCASE
#accept_processes_08
 CALL accept(11,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET combine = curaccept
   CALL text(11,29,combine)
  OF 2:
   CALL text(11,29,combine)
   GO TO accept_processes_07
  OF 3:
   CALL text(11,29,combine)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_08
 ENDCASE
#accept_processes_09
 CALL accept(12,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET offsets = curaccept
   CALL text(12,29,offsets)
  OF 2:
   CALL text(12,29,offsets)
   GO TO accept_processes_08
  OF 3:
   CALL text(12,29,offsets)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_09
 ENDCASE
#accept_processes_10
 CALL accept(13,29,"p(1);CDUS")
 CASE (curscroll)
  OF 0:
   SET charged = curaccept
   CALL text(13,29,charged)
  OF 2:
   CALL text(13,29,charged)
   GO TO accept_processes_09
  OF 3:
   CALL text(13,29,charged)
   GO TO accept_processes_end
  ELSE
   GO TO accept_processes_10
 ENDCASE
#accept_processes_end
 GO TO accept_processes_fields
#accept_processes_line_nbr
 CALL video(n)
 CALL text(24,1,"Line Number :")
 CALL video(lu)
 SET accept = nochange
 CALL accept(24,15,"99;",0
  WHERE curaccept >= 0
   AND curaccept <= 10)
 CALL clear(24,1)
 SET accept = change
 CASE (curaccept)
  OF 0:
   GO TO accept_processes_fields
  OF 1:
   GO TO accept_processes_01
  OF 2:
   GO TO accept_processes_02
  OF 3:
   GO TO accept_processes_03
  OF 4:
   GO TO accept_processes_04
  OF 5:
   GO TO accept_processes_05
  OF 6:
   GO TO accept_processes_06
  OF 7:
   GO TO accept_processes_07
  OF 8:
   GO TO accept_processes_08
  OF 9:
   GO TO accept_processes_09
  OF 10:
   GO TO accept_processes_10
  ELSE
   GO TO accept_processes_line_nbr
 ENDCASE
#accept_processes_fields_end
#end_program
#the_end
 FREE SET rpt
 FREE SET pf
 FREE SET ct
 FREE SET pi
 FREE SET cdm_nums
 FREE SET cpt_nums
END GO
