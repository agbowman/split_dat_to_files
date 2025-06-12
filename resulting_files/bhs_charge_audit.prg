CREATE PROGRAM bhs_charge_audit
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "Ending Date:" = "SYSDATE",
  "Suspense Reasons:" = "1",
  "Max Run Time" = 600,
  "Activity Type" = 0
  WITH outdev, begdate, enddate,
  susp_reason, maxruntime, acttype
 DECLARE output_dest = vc
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $1
 ENDIF
 IF (( $BEGDATE="YESTERDAY"))
  SET beg_date_qual = cnvtdatetime((curdate - 1),0)
 ELSE
  SET beg_date_qual = cnvtdatetime( $BEGDATE)
 ENDIF
 IF (( $ENDDATE="YESTERDAY"))
  SET end_date_qual = cnvtdatetime((curdate - 1),235959)
 ELSE
  SET end_date_qual = cnvtdatetime( $ENDDATE)
 ENDIF
 FREE RECORD chgs
 RECORD chgs(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 charge_item_id = f8
     2 qcf = f8
     2 cdm_class = c3
     2 cdm_num = vc
     2 cdm_desc = vc
     2 charge_desc = c32
     2 item_quantity = i4
     2 charge_status = i4
     2 include_rsn = i4
     2 service_dt_tm = dq8
     2 activity_dt_tm = dq8
     2 activity_type_cd = f8
     2 fin_nbr = vc
     2 tier_group_cd = f8
     2 updt_id = f8
     2 updt_name = c25
     2 susp_rsn_cd = f8
 )
 DECLARE cnt = i4
 DECLARE suspense_mod_cd = f8
 SET cnt = 0
 SET suspense_mod_cd = uar_get_code_by("MEANING",13019,"SUSPENSE")
 SET fin_nbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(6,0)))), public
 SELECT
  IF (any_status_ind="C")
   PLAN (c
    WHERE c.process_flg IN (3, 2, 4, 5, 8,
    177, 777, 997)
     AND c.active_ind=1)
  ELSE
   PLAN (c
    WHERE c.process_flg IN (3, 2, 4, 5, 8,
    177, 777, 997)
     AND c.activity_type_cd=cnvtreal( $ACTTYPE)
     AND c.active_ind=1)
  ENDIF
  INTO "nl:"
  FROM charge c
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(chgs->qual,(cnt+ 99))
   ENDIF
   chgs->qual[cnt].encntr_id = c.encntr_id, chgs->qual[cnt].person_id = c.person_id, chgs->qual[cnt].
   charge_item_id = c.charge_item_id,
   chgs->qual[cnt].service_dt_tm = c.service_dt_tm, chgs->qual[cnt].activity_dt_tm = c.activity_dt_tm,
   chgs->qual[cnt].activity_type_cd = c.activity_type_cd,
   chgs->qual[cnt].item_quantity = c.item_quantity, chgs->qual[cnt].updt_id = c.updt_id, chgs->qual[
   cnt].tier_group_cd = c.tier_group_cd,
   chgs->qual[cnt].charge_desc = c.charge_description, chgs->qual[cnt].charge_status = c.process_flg
   IF (c.process_flg=3)
    chgs->qual[cnt].include_rsn = 1
   ELSE
    chgs->qual[cnt].include_rsn = 10
   ENDIF
   chgs->qual[cnt].charge_status = c.process_flg
  WITH nocounter
 ;end select
 CALL echo(build("First Count:",cnt))
 SELECT
  IF (any_status_ind="C")
   PLAN (c
    WHERE c.process_flg=1
     AND c.charge_item_id > 0
     AND c.active_ind=1)
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND cm.charge_mod_type_cd=suspense_mod_cd)
    JOIN (d
    WHERE ((( $4="1")
     AND uar_get_code_meaning(cm.field1_id) IN ("ONHOLD", "NOCDM")) OR (( $4="2"))) )
  ELSE
   PLAN (c
    WHERE c.process_flg=1
     AND c.charge_item_id > 0
     AND c.activity_type_cd=cnvtreal( $ACTTYPE)
     AND c.active_ind=1)
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND cm.charge_mod_type_cd=suspense_mod_cd)
    JOIN (d
    WHERE ((( $4="1")
     AND uar_get_code_meaning(cm.field1_id) IN ("ONHOLD", "NOCDM")) OR (( $4="2"))) )
  ENDIF
  INTO "nl:"
  FROM charge c,
   charge_mod cm,
   dummyt d
  ORDER BY c.charge_item_id
  HEAD c.charge_item_id
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(chgs->qual,(cnt+ 99))
   ENDIF
   chgs->qual[cnt].encntr_id = c.encntr_id, chgs->qual[cnt].person_id = c.person_id, chgs->qual[cnt].
   charge_item_id = c.charge_item_id,
   chgs->qual[cnt].service_dt_tm = c.service_dt_tm, chgs->qual[cnt].activity_dt_tm = c.activity_dt_tm,
   chgs->qual[cnt].activity_type_cd = c.activity_type_cd,
   chgs->qual[cnt].item_quantity = c.item_quantity, chgs->qual[cnt].updt_id = c.updt_id, chgs->qual[
   cnt].tier_group_cd = c.tier_group_cd,
   chgs->qual[cnt].charge_desc = c.charge_description, chgs->qual[cnt].include_rsn = 2, chgs->qual[
   cnt].charge_status = c.process_flg,
   chgs->qual[cnt].susp_rsn_cd = cm.field1_id
  WITH nocounter
 ;end select
 CALL echo(build("Second Count:",cnt))
 SELECT
  IF (any_status_ind="C")
   PLAN (ic
    WHERE ic.posted_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
    JOIN (e
    WHERE e.encntr_id=ic.encntr_id)
    JOIN (c
    WHERE c.charge_item_id=ic.charge_item_id
     AND c.process_flg != 999)
  ELSE
   PLAN (ic
    WHERE ic.posted_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
     AND ic.activity_type_cd=cnvtreal( $ACTTYPE))
    JOIN (e
    WHERE e.encntr_id=ic.encntr_id)
    JOIN (c
    WHERE c.charge_item_id=ic.charge_item_id
     AND c.process_flg != 999)
  ENDIF
  INTO "nl:"
  FROM interface_charge ic,
   encounter e,
   charge c
  ORDER BY c.charge_item_id
  HEAD c.charge_item_id
   report_charge = 0
   IF (uar_get_code_display(ic.encntr_type_cd)="One Time OP"
    AND cnvtdate(ic.service_dt_tm) != cnvtdate(e.reg_dt_tm))
    report_charge = 3
   ELSEIF ( NOT (uar_get_code_display(ic.encntr_type_cd) IN ("Observation", "Inpatient", "Outpatient",
   "Emergency", "One Time OP",
   "Recurring OP", "Disch IP", "Expired IP", "Disch ES", "Disch Obv",
   "Disch Daystay", "Daystay", "Expired ES", "Expired Obv", "Expired Daystay",
   "Disch Recurring OP")))
    report_charge = 4
   ELSEIF (ic.service_dt_tm > e.disch_dt_tm)
    report_charge = 5
   ELSEIF (ic.service_dt_tm < e.reg_dt_tm)
    report_charge = 6
   ELSEIF ((( NOT (substring(1,1,ic.prim_cdm) IN ("1", "2", "3", "4", "5",
   "6", "7", "8", "9"))) OR ((( NOT (substring(2,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR ((( NOT (substring(3,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR ((( NOT (substring(4,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR ((( NOT (substring(5,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR ((( NOT (substring(6,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR ((( NOT (substring(7,1,ic.prim_cdm) IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9"))) OR (size(trim(ic.prim_cdm)) != 7)) )) )) )) )) )) ))
    AND ic.prim_cdm != "MANUAL")
    report_charge = 7
   ELSEIF (cnvtlookbehind("6,D",c.activity_dt_tm) > c.service_dt_tm)
    report_charge = 8
   ELSEIF (cnvtlookahead("1,H",c.activity_dt_tm) < c.service_dt_tm)
    report_charge = 9
   ENDIF
   IF (report_charge > 0)
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(chgs->qual,(cnt+ 99))
    ENDIF
    chgs->qual[cnt].encntr_id = c.encntr_id, chgs->qual[cnt].person_id = c.person_id, chgs->qual[cnt]
    .charge_item_id = c.charge_item_id,
    chgs->qual[cnt].service_dt_tm = c.service_dt_tm, chgs->qual[cnt].activity_dt_tm = c
    .activity_dt_tm, chgs->qual[cnt].activity_type_cd = c.activity_type_cd,
    chgs->qual[cnt].updt_id = c.updt_id, chgs->qual[cnt].item_quantity = c.item_quantity, chgs->qual[
    cnt].tier_group_cd = c.tier_group_cd,
    chgs->qual[cnt].charge_desc = c.charge_description, chgs->qual[cnt].include_rsn = report_charge,
    chgs->qual[cnt].charge_status = c.process_flg
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(chgs->qual,cnt)
 CALL echo(build("Last Count:",cnt))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   charge_mod cm,
   dummyt d2
  PLAN (d)
   JOIN (cm
   WHERE (cm.charge_item_id=chgs->qual[d.seq].charge_item_id))
   JOIN (d2
   WHERE uar_get_code_meaning(cm.field1_id) IN ("CDM_SCHED", "HCPCS"))
  DETAIL
   IF (uar_get_code_meaning(cm.field1_id)="CDM_SCHED")
    chgs->qual[d.seq].cdm_num = cm.field6, chgs->qual[d.seq].cdm_desc = cm.field7, chgs->qual[d.seq].
    cdm_class = substring(1,3,cm.field6)
   ELSEIF (uar_get_code_meaning(cm.field1_id)="HCPCS"
    AND cm.field7 > " ")
    chgs->qual[d.seq].qcf = cnvtreal(cm.field7)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("count x:",cnt))
 DECLARE outstring = vc
 DECLARE filename_in = vc
 DECLARE filename_out = vc
 DECLARE include_rsn_disp = vc
 SET dynamic_maxcol = 150
 SELECT INTO value(output_dest)
  activity_type_disp = uar_get_code_display(chgs->qual[d.seq].activity_type_cd), activity_dt_tm =
  chgs->qual[d.seq].activity_dt_tm, activity_class = concat(trim(uar_get_code_display(chgs->qual[d
     .seq].activity_type_cd))," ",chgs->qual[d.seq].cdm_class)
  FROM (dummyt d  WITH seq = value(cnt))
  ORDER BY activity_class, activity_dt_tm
  HEAD REPORT
   detail_count = 0, detail_count_bmc = 0, detail_count_fmc = 0,
   detail_count_mlh = 0, detail_count_oth = 0, held_count_tot = 0,
   held_count_bmc = 0, held_count_fmc = 0, held_count_mlh = 0,
   held_count_oth = 0, susp_count_tot = 0, susp_count_bmc = 0,
   susp_count_fmc = 0, susp_count_mlh = 0, susp_count_oth = 0,
   held_bmc_0_5 = 0, held_bmc_6_15 = 0, held_bmc_16_30 = 0,
   held_bmc_31 = 0, susp_bmc_0_5 = 0, susp_bmc_6_15 = 0,
   susp_bmc_16_30 = 0, susp_bmc_31 = 0, held_fmc_0_5 = 0,
   held_fmc_6_15 = 0, held_fmc_16_30 = 0, held_fmc_31 = 0,
   susp_fmc_0_5 = 0, susp_fmc_6_15 = 0, susp_fmc_16_30 = 0,
   susp_fmc_31 = 0, held_mlh_0_5 = 0, held_mlh_6_15 = 0,
   held_mlh_16_30 = 0, held_mlh_31 = 0, susp_mlh_0_5 = 0,
   susp_mlh_6_15 = 0, susp_mlh_16_30 = 0, susp_mlh_31 = 0,
   held_oth_0_5 = 0, held_oth_6_15 = 0, held_oth_16_30 = 0,
   held_oth_31 = 0, susp_oth_0_5 = 0, susp_oth_6_15 = 0,
   susp_oth_16_30 = 0, susp_oth_31 = 0, held_tot_0_5 = 0,
   held_tot_6_15 = 0, held_tot_16_30 = 0, held_tot_31 = 0,
   susp_tot_0_5 = 0, susp_tot_6_15 = 0, susp_tot_16_30 = 0,
   susp_tot_31 = 0, bmc_tot_0_5 = 0, bmc_tot_6_15 = 0,
   bmc_tot_16_30 = 0, bmc_tot_31 = 0, fmc_tot_0_5 = 0,
   fmc_tot_6_15 = 0, fmc_tot_16_30 = 0, fmc_tot_31 = 0,
   mlh_tot_0_5 = 0, mlh_tot_6_15 = 0, mlh_tot_16_30 = 0,
   mlh_tot_31 = 0, oth_tot_0_5 = 0, oth_tot_6_15 = 0,
   oth_tot_16_30 = 0, oth_tot_31 = 0, t_detail_count = 0,
   t_detail_count_bmc = 0, t_detail_count_fmc = 0, t_detail_count_mlh = 0,
   t_detail_count_oth = 0, t_held_count_tot = 0, t_held_count_bmc = 0,
   t_held_count_fmc = 0, t_held_count_mlh = 0, t_held_count_oth = 0,
   t_susp_count_tot = 0, t_susp_count_bmc = 0, t_susp_count_fmc = 0,
   t_susp_count_mlh = 0, t_susp_count_oth = 0, t_held_bmc_0_5 = 0,
   t_held_bmc_6_15 = 0, t_held_bmc_16_30 = 0, t_held_bmc_31 = 0,
   t_susp_bmc_0_5 = 0, t_susp_bmc_6_15 = 0, t_susp_bmc_16_30 = 0,
   t_susp_bmc_31 = 0, t_held_fmc_0_5 = 0, t_held_fmc_6_15 = 0,
   t_held_fmc_16_30 = 0, t_held_fmc_31 = 0, t_susp_fmc_0_5 = 0,
   t_susp_fmc_6_15 = 0, t_susp_fmc_16_30 = 0, t_susp_fmc_31 = 0,
   t_held_mlh_0_5 = 0, t_held_mlh_6_15 = 0, t_held_mlh_16_30 = 0,
   t_held_mlh_31 = 0, t_susp_mlh_0_5 = 0, t_susp_mlh_6_15 = 0,
   t_susp_mlh_16_30 = 0, t_susp_mlh_31 = 0, t_held_oth_0_5 = 0,
   t_held_oth_6_15 = 0, t_held_oth_16_30 = 0, t_held_oth_31 = 0,
   t_susp_oth_0_5 = 0, t_susp_oth_6_15 = 0, t_susp_oth_16_30 = 0,
   t_susp_oth_31 = 0, t_held_tot_0_5 = 0, t_held_tot_6_15 = 0,
   t_held_tot_16_30 = 0, t_held_tot_31 = 0, t_susp_tot_0_5 = 0,
   t_susp_tot_6_15 = 0, t_susp_tot_16_30 = 0, t_susp_tot_31 = 0,
   t_bmc_tot_0_5 = 0, t_bmc_tot_6_15 = 0, t_bmc_tot_16_30 = 0,
   t_bmc_tot_31 = 0, t_fmc_tot_0_5 = 0, t_fmc_tot_6_15 = 0,
   t_fmc_tot_16_30 = 0, t_fmc_tot_31 = 0, t_mlh_tot_0_5 = 0,
   t_mlh_tot_6_15 = 0, t_mlh_tot_16_30 = 0, t_mlh_tot_31 = 0,
   t_oth_tot_0_5 = 0, t_oth_tot_6_15 = 0, t_oth_tot_16_30 = 0,
   t_oth_tot_31 = 0, line120 = fillstring(120,"-"), delim = ","
  HEAD PAGE
   col 1, "Activity Class", col + 1,
   delim, col + 1, "FAC",
   col + 1, delim, col + 1,
   "Status", col + 1, delim,
   col + 1, "Total", col + 1,
   delim, col + 1, "0-5",
   col + 1, delim, col + 1,
   "6-15", col + 1, delim,
   col + 1, "16-30", col + 1,
   delim, col + 1, "30 +",
   row + 1
  HEAD activity_class
   row + 1
  DETAIL
   IF ((chgs->qual[d.seq].qcf > 0.00))
    quan_out = (chgs->qual[d.seq].item_quantity * chgs->qual[d.seq].qcf)
   ELSE
    quan_out = chgs->qual[d.seq].item_quantity
   ENDIF
   service_date_disp = format(chgs->qual[d.seq].service_dt_tm,"MMDDYY HHMM;;D"), activity_date_disp
    = format(chgs->qual[d.seq].activity_dt_tm,"MMDDYY HHMM;;D")
   CASE (chgs->qual[d.seq].charge_status)
    OF 0:
     chg_sts_disp = "Pnd"
    OF 1:
     chg_sts_disp = "Sus"
    OF 2:
     chg_sts_disp = "Rvw"
    OF 3:
     chg_sts_disp = "Hld"
    OF 4:
     chg_sts_disp = "Mnl"
    OF 6:
     chg_sts_disp = "Cmb"
    OF 7:
     chg_sts_disp = "Abs"
    OF 8:
     chg_sts_disp = "ABN"
    OF 10:
     chg_sts_disp = "Ofs"
    OF 11:
     chg_sts_disp = "Adj"
    OF 100:
     chg_sts_disp = "Pst"
    OF 177:
     chg_sts_disp = "Bnd"
    OF 777:
     chg_sts_disp = "Bnd"
    OF 977:
     chg_sts_disp = "Bnd"
    OF 996:
     chg_sts_disp = "OMF"
    OF 997:
     chg_sts_disp = "Stt"
    OF 998:
     chg_sts_disp = "PNC"
    OF 999:
     chg_sts_disp = "Itf"
   ENDCASE
   CASE (chgs->qual[d.seq].include_rsn)
    OF 1:
     include_rsn_disp = "Held"
    OF 2:
     include_rsn_disp = substring(1,20,uar_get_code_display(chgs->qual[d.seq].susp_rsn_cd))
    OF 3:
     include_rsn_disp = "Svc Dt Not Reg"
    OF 4:
     include_rsn_disp = "Enc Type"
    OF 5:
     include_rsn_disp = "Svc Dt post DC"
    OF 6:
     include_rsn_disp = "Svc Dt pre ADM"
    OF 7:
     include_rsn_disp = "CDM Issue"
    OF 8:
     include_rsn_disp = "Act too late"
    OF 9:
     include_rsn_disp = "Act too early"
    OF 10:
     include_rsn_disp = "Charge Status"
   ENDCASE
   tier_fin_disp = substring(1,4,uar_get_code_display(chgs->qual[d.seq].tier_group_cd)),
   act_type_disp = substring(1,20,uar_get_code_display(chgs->qual[d.seq].activity_type_cd)),
   detail_count = (detail_count+ 1)
   IF (tier_fin_disp="BMC")
    detail_count_bmc = (detail_count_bmc+ 1), t_detail_count_bmc = (t_detail_count_bmc+ 1)
    IF (chg_sts_disp="Hld")
     held_count_bmc = (held_count_bmc+ 1), t_held_count_bmc = (t_held_count_bmc+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      held_bmc_0_5 = (held_bmc_0_5+ 1), t_held_bmc_0_5 = (t_held_bmc_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      held_bmc_6_15 = (held_bmc_6_15+ 1), t_held_bmc_6_15 = (t_held_bmc_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      held_bmc_16_30 = (held_bmc_16_30+ 1), t_held_bmc_16_30 = (t_held_bmc_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      held_bmc_31 = (held_bmc_31+ 1), t_held_bmc_31 = (t_held_bmc_31+ 1)
     ENDIF
    ELSEIF (chg_sts_disp="Sus")
     susp_count_bmc = (susp_count_bmc+ 1), t_susp_count_bmc = (t_susp_count_bmc+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      susp_bmc_0_5 = (susp_bmc_0_5+ 1), t_susp_bmc_0_5 = (t_susp_bmc_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      susp_bmc_6_15 = (susp_bmc_6_15+ 1), t_susp_bmc_6_15 = (t_susp_bmc_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      susp_bmc_16_30 = (susp_bmc_16_30+ 1), t_susp_bmc_16_30 = (t_susp_bmc_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      susp_bmc_31 = (susp_bmc_31+ 1), t_susp_bmc_31 = (t_susp_bmc_31+ 1)
     ENDIF
    ENDIF
   ELSEIF (((tier_fin_disp="FMC") OR (tier_fin_disp="BFMC")) )
    detail_count_fmc = (detail_count_fmc+ 1), t_detail_count_fmc = (t_detail_count_fmc+ 1)
    IF (chg_sts_disp="Hld")
     held_count_fmc = (held_count_fmc+ 1), t_held_count_fmc = (t_held_count_fmc+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      held_fmc_0_5 = (held_fmc_0_5+ 1), t_held_fmc_0_5 = (t_held_fmc_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      held_fmc_6_15 = (held_fmc_6_15+ 1), t_held_fmc_6_15 = (t_held_fmc_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      held_fmc_16_30 = (held_fmc_16_30+ 1), t_held_fmc_16_30 = (t_held_fmc_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      held_fmc_31 = (held_fmc_31+ 1), t_held_fmc_31 = (t_held_fmc_31+ 1)
     ENDIF
    ELSEIF (chg_sts_disp="Sus")
     susp_count_fmc = (susp_count_fmc+ 1), t_susp_count_fmc = (t_susp_count_fmc+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      susp_fmc_0_5 = (susp_fmc_0_5+ 1), t_susp_fmc_0_5 = (t_susp_fmc_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      susp_fmc_6_15 = (susp_fmc_6_15+ 1), t_susp_fmc_6_15 = (t_susp_fmc_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      susp_fmc_16_30 = (susp_fmc_16_30+ 1), t_susp_fmc_16_30 = (t_susp_fmc_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      susp_fmc_31 = (susp_fmc_31+ 1), t_susp_fmc_31 = (t_susp_fmc_31+ 1)
     ENDIF
    ENDIF
   ELSEIF (((tier_fin_disp="MLH") OR (tier_fin_disp="BMLH")) )
    detail_count_mlh = (detail_count_mlh+ 1), t_detail_count_mlh = (t_detail_count_mlh+ 1)
    IF (chg_sts_disp="Hld")
     held_count_mlh = (held_count_mlh+ 1), t_held_count_mlh = (t_held_count_mlh+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      held_mlh_0_5 = (held_mlh_0_5+ 1), t_held_mlh_0_5 = (t_held_mlh_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      held_mlh_6_15 = (held_mlh_6_15+ 1), t_held_mlh_6_15 = (t_held_mlh_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      held_mlh_16_30 = (held_mlh_16_30+ 1), t_held_mlh_16_30 = (t_held_mlh_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      held_mlh_31 = (held_mlh_31+ 1), t_held_mlh_31 = (t_held_mlh_31+ 1)
     ENDIF
    ELSEIF (chg_sts_disp="Sus")
     susp_count_mlh = (susp_count_mlh+ 1), t_susp_count_mlh = (t_susp_count_mlh+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      susp_mlh_0_5 = (susp_mlh_0_5+ 1), t_susp_mlh_0_5 = (t_susp_mlh_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      susp_mlh_6_15 = (susp_mlh_6_15+ 1), t_susp_mlh_6_15 = (t_susp_mlh_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      susp_mlh_16_30 = (susp_mlh_16_30+ 1), t_susp_mlh_16_30 = (t_susp_mlh_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      susp_mlh_31 = (susp_mlh_31+ 1), t_susp_mlh_31 = (t_susp_mlh_31+ 1)
     ENDIF
    ENDIF
   ELSE
    detail_count_oth = (detail_count_oth+ 1), t_detail_count_oth = (t_detail_count_oth+ 1)
    IF (chg_sts_disp="Hld")
     held_count_oth = (held_count_oth+ 1), t_held_count_oth = (t_held_count_oth+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      held_oth_0_5 = (held_oth_0_5+ 1), t_held_oth_0_5 = (t_held_oth_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      held_oth_6_15 = (held_oth_6_15+ 1), t_held_oth_6_15 = (t_held_oth_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      held_oth_16_30 = (held_oth_16_30+ 1), t_held_oth_16_30 = (t_held_oth_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      held_oth_31 = (held_oth_31+ 1), t_held_oth_31 = (t_held_oth_31+ 1)
     ENDIF
    ELSEIF (chg_sts_disp="Sus")
     susp_count_oth = (susp_count_oth+ 1), t_susp_count_oth = (t_susp_count_oth+ 1)
     IF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN 0.00
      AND 5.00)
      susp_oth_0_5 = (susp_oth_0_5+ 1), t_susp_oth_0_5 = (t_susp_oth_0_5+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     5.01 AND 15.00)
      susp_oth_6_15 = (susp_oth_6_15+ 1), t_susp_oth_6_15 = (t_susp_oth_6_15+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) BETWEEN
     15.01 AND 30.00)
      susp_oth_16_30 = (susp_oth_16_30+ 1), t_susp_oth_16_30 = (t_susp_oth_16_30+ 1)
     ELSEIF (datetimediff(cnvtdatetime(curdate,curtime),chgs->qual[d.seq].service_dt_tm,1) > 30.01)
      susp_oth_31 = (susp_oth_31+ 1), t_susp_oth_31 = (t_susp_oth_31+ 1)
     ENDIF
    ENDIF
   ENDIF
   susp_count_tot = (((susp_count_bmc+ susp_count_fmc)+ susp_count_mlh)+ susp_count_oth),
   held_count_tot = (((held_count_bmc+ held_count_fmc)+ held_count_mlh)+ held_count_oth),
   t_susp_count_tot = (((t_susp_count_bmc+ t_susp_count_fmc)+ t_susp_count_mlh)+ t_susp_count_oth),
   t_held_count_tot = (((t_held_count_bmc+ t_held_count_fmc)+ t_held_count_mlh)+ t_held_count_oth),
   bmc_tot_0_5 = (held_bmc_0_5+ susp_bmc_0_5), bmc_tot_6_15 = (held_bmc_6_15+ susp_bmc_6_15),
   bmc_tot_16_30 = (held_bmc_16_30+ susp_bmc_16_30), bmc_tot_31 = (held_bmc_31+ susp_bmc_31),
   fmc_tot_0_5 = (held_fmc_0_5+ susp_fmc_0_5),
   fmc_tot_6_15 = (held_fmc_6_15+ susp_fmc_6_15), fmc_tot_16_30 = (held_fmc_16_30+ susp_fmc_16_30),
   fmc_tot_31 = (held_fmc_31+ susp_fmc_31),
   mlh_tot_0_5 = (held_mlh_0_5+ susp_mlh_0_5), mlh_tot_6_15 = (held_mlh_6_15+ susp_mlh_6_15),
   mlh_tot_16_30 = (held_mlh_16_30+ susp_mlh_16_30),
   mlh_tot_31 = (held_mlh_31+ susp_mlh_31), oth_tot_0_5 = (held_oth_0_5+ susp_oth_0_5), oth_tot_6_15
    = (held_oth_6_15+ susp_oth_6_15),
   oth_tot_16_30 = (held_oth_16_30+ susp_oth_16_30), oth_tot_31 = (held_oth_31+ susp_oth_31),
   t_bmc_tot_0_5 = (t_held_bmc_0_5+ t_susp_bmc_0_5),
   t_bmc_tot_6_15 = (t_held_bmc_6_15+ t_susp_bmc_6_15), t_bmc_tot_16_30 = (t_held_bmc_16_30+
   t_susp_bmc_16_30), t_bmc_tot_31 = (t_held_bmc_31+ t_susp_bmc_31),
   t_fmc_tot_0_5 = (t_held_fmc_0_5+ t_susp_fmc_0_5), t_fmc_tot_6_15 = (t_held_fmc_6_15+
   t_susp_fmc_6_15), t_fmc_tot_16_30 = (t_held_fmc_16_30+ t_susp_fmc_16_30),
   t_fmc_tot_31 = (t_held_fmc_31+ t_susp_fmc_31), t_mlh_tot_0_5 = (t_held_mlh_0_5+ t_susp_mlh_0_5),
   t_mlh_tot_6_15 = (t_held_mlh_6_15+ t_susp_mlh_6_15),
   t_mlh_tot_16_30 = (t_held_mlh_16_30+ t_susp_mlh_16_30), t_mlh_tot_31 = (t_held_mlh_31+
   t_susp_mlh_31), t_oth_tot_0_5 = (t_held_oth_0_5+ t_susp_oth_0_5),
   t_oth_tot_6_15 = (t_held_oth_6_15+ t_susp_oth_6_15), t_oth_tot_16_30 = (t_held_oth_16_30+
   t_susp_oth_16_30), t_oth_tot_31 = (t_held_oth_31+ t_susp_oth_31),
   row + 0
  FOOT  activity_class
   col 1, activity_class, col + 1,
   delim, col + 1, "BMC",
   col + 1, delim, col + 1,
   "Held Charges", col + 1, delim,
   col + 1, held_count_bmc, col + 1,
   delim, col + 1, held_bmc_0_5,
   col + 1, delim, col + 1,
   held_bmc_6_15, col + 1, delim,
   col + 1, held_bmc_16_30, col + 1,
   delim, col + 1, held_bmc_31,
   row + 1, col 1, activity_class,
   col + 1, delim, col + 1,
   "BMC", col + 1, delim,
   col + 1, "Susp Charges", col + 1,
   delim, col + 1, susp_count_bmc,
   col + 1, delim, col + 1,
   susp_bmc_0_5, col + 1, delim,
   col + 1, susp_bmc_6_15, col + 1,
   delim, col + 1, susp_bmc_16_30,
   col + 1, delim, col + 1,
   susp_bmc_31, row + 1, col 1,
   activity_class, col + 1, delim,
   col + 1, "BMC", col + 1,
   delim, col + 1, "Tot  Charges",
   col + 1, delim, col + 1,
   detail_count_bmc, col + 1, delim,
   col + 1, bmc_tot_0_5, col + 1,
   delim, col + 1, bmc_tot_6_15,
   col + 1, delim, col + 1,
   bmc_tot_16_30, col + 1, delim,
   col + 1, bmc_tot_31, row + 1,
   col 1, activity_class, col + 1,
   delim, col + 1, "BFMC",
   col + 1, delim, col + 1,
   "Held Charges", col + 1, delim,
   col + 1, held_count_fmc, col + 1,
   delim, col + 1, held_fmc_0_5,
   col + 1, delim, col + 1,
   held_fmc_6_15, col + 1, delim,
   col + 1, held_fmc_16_30, col + 1,
   delim, col + 1, held_fmc_31,
   row + 1, col 1, activity_class,
   col + 1, delim, col + 1,
   "BFMC", col + 1, delim,
   col + 1, "Susp Charges", col + 1,
   delim, col + 1, susp_count_fmc,
   col + 1, delim, col + 1,
   susp_fmc_0_5, col + 1, delim,
   col + 1, susp_fmc_6_15, col + 1,
   delim, col + 1, susp_fmc_16_30,
   col + 1, delim, col + 1,
   susp_fmc_31, row + 1, col 1,
   activity_class, col + 1, delim,
   col + 1, "BFMC", col + 1,
   delim, col + 1, "Tot  Charges",
   col + 1, delim, col + 1,
   detail_count_fmc, col + 1, delim,
   col + 1, fmc_tot_0_5, col + 1,
   delim, col + 1, fmc_tot_6_15,
   col + 1, delim, col + 1,
   fmc_tot_16_30, col + 1, delim,
   col + 1, fmc_tot_31, row + 1,
   col 1, activity_class, col + 1,
   delim, col + 1, "BMLH",
   col + 1, delim, col + 1,
   "Held Charges", col + 1, delim,
   col + 1, held_count_mlh, col + 1,
   delim, col + 1, held_mlh_0_5,
   col + 1, delim, col + 1,
   held_mlh_6_15, col + 1, delim,
   col + 1, held_mlh_16_30, col + 1,
   delim, col + 1, held_mlh_31,
   row + 1, col 1, activity_class,
   col + 1, delim, col + 1,
   "BMLH", col + 1, delim,
   col + 1, "Susp Charges", col + 1,
   delim, col + 1, susp_count_mlh,
   col + 1, delim, col + 1,
   susp_mlh_0_5, col + 1, delim,
   col + 1, susp_mlh_6_15, col + 1,
   delim, col + 1, susp_mlh_16_30,
   col + 1, delim, col + 1,
   susp_mlh_31, row + 1, col 1,
   activity_class, col + 1, delim,
   col + 1, "BMLH", col + 1,
   delim, col + 1, "Tot  Charges",
   col + 1, delim, col + 1,
   detail_count_mlh, col + 1, delim,
   col + 1, mlh_tot_0_5, col + 1,
   delim, col + 1, mlh_tot_6_15,
   col + 1, delim, col + 1,
   mlh_tot_16_30, col + 1, delim,
   col + 1, mlh_tot_31, row + 1,
   col 1, activity_class, col + 1,
   delim, col + 1, "OTH",
   col + 1, delim, col + 1,
   "Held Charges", col + 1, delim,
   col + 1, held_count_oth, col + 1,
   delim, col + 1, held_oth_0_5,
   col + 1, delim, col + 1,
   held_oth_6_15, col + 1, delim,
   col + 1, held_oth_16_30, col + 1,
   delim, col + 1, held_oth_31,
   row + 1, col 1, activity_class,
   col + 1, delim, col + 1,
   "OTH", col + 1, delim,
   col + 1, "Susp Charges", col + 1,
   delim, col + 1, susp_count_oth,
   col + 1, delim, col + 1,
   susp_oth_0_5, col + 1, delim,
   col + 1, susp_oth_6_15, col + 1,
   delim, col + 1, susp_oth_16_30,
   col + 1, delim, col + 1,
   susp_oth_31, row + 1, col 1,
   activity_class, col + 1, delim,
   col + 1, "OTH", col + 1,
   delim, col + 1, "Tot  Charges",
   col + 1, delim, col + 1,
   detail_count_oth, col + 1, delim,
   col + 1, oth_tot_0_5, col + 1,
   delim, col + 1, oth_tot_6_15,
   col + 1, delim, col + 1,
   oth_tot_16_30, col + 1, delim,
   col + 1, oth_tot_31, row + 1,
   detail_count = 0, detail_count_bmc = 0, detail_count_fmc = 0,
   detail_count_mlh = 0, detail_count_oth = 0, susp_count_tot = 0,
   susp_count_bmc = 0, susp_count_fmc = 0, susp_count_mlh = 0,
   susp_count_oth = 0, held_count_tot = 0, held_count_bmc = 0,
   held_count_fmc = 0, held_count_mlh = 0, held_count_oth = 0,
   held_bmc_0_5 = 0, held_bmc_6_15 = 0, held_bmc_16_30 = 0,
   held_bmc_31 = 0, susp_bmc_0_5 = 0, susp_bmc_6_15 = 0,
   susp_bmc_16_30 = 0, susp_bmc_31 = 0, held_fmc_0_5 = 0,
   held_fmc_6_15 = 0, held_fmc_16_30 = 0, held_fmc_31 = 0,
   susp_fmc_0_5 = 0, susp_fmc_6_15 = 0, susp_fmc_16_30 = 0,
   susp_fmc_31 = 0, held_mlh_0_5 = 0, held_mlh_6_15 = 0,
   held_mlh_16_30 = 0, held_mlh_31 = 0, susp_mlh_0_5 = 0,
   susp_mlh_6_15 = 0, susp_mlh_16_30 = 0, susp_mlh_31 = 0,
   held_oth_0_5 = 0, held_oth_6_15 = 0, held_oth_16_30 = 0,
   held_oth_31 = 0, susp_oth_0_5 = 0, susp_oth_6_15 = 0,
   susp_oth_16_30 = 0, susp_oth_31 = 0, bmc_tot_0_5 = 0,
   bmc_tot_6_15 = 0, bmc_tot_16_30 = 0, bmc_tot_31 = 0,
   fmc_tot_0_5 = 0, fmc_tot_6_15 = 0, fmc_tot_16_30 = 0,
   fmc_tot_31 = 0, mlh_tot_0_5 = 0, mlh_tot_6_15 = 0,
   mlh_tot_16_30 = 0, mlh_tot_31 = 0, oth_tot_0_5 = 0,
   oth_tot_6_15 = 0, oth_tot_16_30 = 0, oth_tot_31 = 0
  FOOT REPORT
   col 1, "All Activity", col + 1,
   delim, col + 1, "BMC",
   col + 1, delim, col + 1,
   "Held Charges", col + 1, delim,
   col + 1, t_held_count_bmc, col + 1,
   delim, col + 1, t_held_bmc_0_5,
   col + 1, delim, col + 1,
   t_held_bmc_6_15, col + 1, delim,
   col + 1, t_held_bmc_16_30, col + 1,
   delim, col + 1, t_held_bmc_31,
   row + 1, col 1, "All Activity",
   col + 1, delim, col + 1,
   "BMC", col + 1, delim,
   col + 1, "Susp Charges", col + 1,
   delim, col + 1, t_susp_count_bmc,
   col + 1, delim, col + 1,
   t_susp_bmc_0_5, col + 1, delim,
   col + 1, t_susp_bmc_6_15, col + 1,
   delim, col + 1, t_susp_bmc_16_30,
   col + 1, delim, col + 1,
   t_susp_bmc_31, row + 1, col 1,
   "All Activity", col + 1, delim,
   col + 1, "BMC", col + 1,
   delim, col + 1, "Tot  Charges",
   col + 1, delim, col + 1,
   t_detail_count_bmc, col + 1, delim,
   col + 1, t_bmc_tot_0_5, col + 1,
   delim, col + 1, t_bmc_tot_6_15,
   col + 1, delim, col + 1,
   t_bmc_tot_16_30, col + 1, delim,
   col + 1, t_bmc_tot_31, row + 1,
   col 1, "All Activity", col + 1,
   delim, col + 1, "BFMC",
   col + 1, delim, col + 1,
   "Susp Charges", col + 1, delim,
   col + 1, t_susp_count_fmc, col + 1,
   delim, col + 1, t_susp_fmc_0_5,
   col + 1, delim, col + 1,
   t_susp_fmc_6_15, col + 1, delim,
   col + 1, t_susp_fmc_16_30, col + 1,
   delim, col + 1, t_susp_fmc_31,
   row + 1, col 1, "All Activity",
   col + 1, delim, col + 1,
   "BFMC", col + 1, delim,
   col + 1, "Tot  Charges", col + 1,
   delim, col + 1, t_detail_count_fmc,
   col + 1, delim, col + 1,
   t_fmc_tot_0_5, col + 1, delim,
   col + 1, t_fmc_tot_6_15, col + 1,
   delim, col + 1, t_fmc_tot_16_30,
   col + 1, delim, col + 1,
   t_fmc_tot_31, row + 1, col 1,
   "All Activity", col + 1, delim,
   col + 1, "BMLH", col + 1,
   delim, col + 1, "Held Charges",
   col + 1, delim, col + 1,
   t_held_count_mlh, col + 1, delim,
   col + 1, t_held_mlh_0_5, col + 1,
   delim, col + 1, t_held_mlh_6_15,
   col + 1, delim, col + 1,
   t_held_mlh_16_30, col + 1, delim,
   col + 1, t_held_mlh_31, row + 1,
   col 1, "All Activity", col + 1,
   delim, col + 1, "BMLH",
   col + 1, delim, col + 1,
   "Susp Charges", col + 1, delim,
   col + 1, t_susp_count_mlh, col + 1,
   delim, col + 1, t_susp_mlh_0_5,
   col + 1, delim, col + 1,
   t_susp_mlh_6_15, col + 1, delim,
   col + 1, t_susp_mlh_16_30, col + 1,
   delim, col + 1, t_susp_mlh_31,
   row + 1, col 1, "All Activity",
   col + 1, delim, col + 1,
   "BMLH", col + 1, delim,
   col + 1, "Tot  Charges", col + 1,
   delim, col + 1, t_detail_count_mlh,
   col + 1, delim, col + 1,
   t_mlh_tot_0_5, col + 1, delim,
   col + 1, t_mlh_tot_6_15, col + 1,
   delim, col + 1, t_mlh_tot_16_30,
   col + 1, delim, col + 1,
   t_mlh_tot_31, row + 1, col 1,
   "All Activity", col + 1, delim,
   col + 1, "OTH", col + 1,
   delim, col + 1, "Held Charges",
   col + 1, delim, col + 1,
   t_held_count_oth, col + 1, delim,
   col + 1, t_held_oth_0_5, col + 1,
   delim, col + 1, t_held_oth_6_15,
   col + 1, delim, col + 1,
   t_held_oth_16_30, col + 1, delim,
   col + 1, t_held_oth_31, row + 1,
   col 1, "All Activity", col + 1,
   delim, col + 1, "OTH",
   col + 1, delim, col + 1,
   "Susp Charges", col + 1, delim,
   col + 1, t_susp_count_oth, col + 1,
   delim, col + 1, t_susp_oth_0_5,
   col + 1, delim, col + 1,
   t_susp_oth_6_15, col + 1, delim,
   col + 1, t_susp_oth_16_30, col + 1,
   delim, col + 1, t_susp_oth_31,
   row + 1, col 1, "All Activity",
   col + 1, delim, col + 1,
   "OTH", col + 1, delim,
   col + 1, "Tot  Charges", col + 1,
   delim, col + 1, detail_count_oth,
   col + 1, delim, col + 1,
   t_oth_tot_0_5, col + 1, delim,
   col + 1, t_oth_tot_6_15, col + 1,
   delim, col + 1, t_oth_tot_16_30,
   col + 1, delim, col + 1,
   t_oth_tot_31, row + 1
  WITH maxcol = value(dynamic_maxcol), maxrow = 1, landscape,
   compress, format = variable
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,"Baystate Medical Center Mgmt Charge Audit",1)
 ENDIF
END GO
