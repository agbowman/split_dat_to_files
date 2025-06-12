CREATE PROGRAM ajt_charge_audit_old
 PROMPT
  "Output to File/Printer/MINE/Email" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "Ending Date:" = "SYSDATE",
  "Suspense Reasons:" = "1",
  "Max Run Time" = 600,
  "Output Type" = "1",
  "Activity Type"
  WITH outdev, begdate, enddate,
  susp_reason, maxruntime, outtype,
  acttype
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
 DECLARE fin_nbr_cd = f8
 SET cnt = 0
 SET suspense_mod_cd = uar_get_code_by("MEANING",13019,"SUSPENSE")
 SET fin_nbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(7,0)))), public
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
     AND (c.activity_type_cd= $ACTTYPE)
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
   chgs->qual[cnt].charge_desc = c.charge_description
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
     AND (c.activity_type_cd= $ACTTYPE)
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
     AND (ic.activity_type_cd= $ACTTYPE))
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
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=chgs->qual[d.seq].updt_id))
  DETAIL
   chgs->qual[d.seq].updt_name = substring(1,20,p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   encntr_alias ea
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=chgs->qual[d.seq].encntr_id)
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=fin_nbr_cd)
  DETAIL
   chgs->qual[d.seq].fin_nbr = ea.alias
  WITH nocounter
 ;end select
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
    chgs->qual[d.seq].cdm_num = cm.field6, chgs->qual[d.seq].cdm_desc = cm.field7
   ELSEIF (uar_get_code_meaning(cm.field1_id)="HCPCS"
    AND cm.field7 > " ")
    chgs->qual[d.seq].qcf = cnvtreal(cm.field7)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE outstring = vc
 DECLARE filename_in = vc
 DECLARE filename_out = vc
 DECLARE include_rsn_disp = vc
 IF (( $OUTTYPE="1"))
  SET dynamic_maxcol = 200
 ELSEIF (( $OUTTYPE="2"))
  SET dynamic_maxcol = 250
 ENDIF
 SELECT INTO value(output_dest)
  activity_type_disp = uar_get_code_display(chgs->qual[d.seq].activity_type_cd), activity_dt_tm =
  chgs->qual[d.seq].activity_dt_tm
  FROM (dummyt d  WITH seq = value(cnt))
  ORDER BY activity_type_disp, activity_dt_tm
  HEAD REPORT
   IF (( $OUTTYPE="1"))
    col 1, "CDM    / Description", col 41,
    "Quan", col 46, "Service Dt",
    col 58, "Activity ", col 70,
    "STS", col 75, "Reason",
    col 95, "Act Type", col 112,
    "FAC/Fin", col 126, "Updt Prsnl",
    row + 1
   ELSEIF (( $OUTTYPE="2"))
    outstring = concat('CDM,"Description","Quan","Service Dt","Activity","Status",',
     '"Reason","Activity Type","FAC","Account Number","Update Personnel"'), col 1, outstring,
    row + 1
   ENDIF
  HEAD activity_type_disp
   IF (( $OUTTYPE="1"))
    col 1, activity_type_disp, row + 1
   ENDIF
  DETAIL
   IF ((chgs->qual[d.seq].qcf > 0.00))
    quan_out = (chgs->qual[d.seq].item_quantity * chgs->qual[d.seq].qcf)
   ELSE
    quan_out = chgs->qual[d.seq].item_quantity
   ENDIF
   IF (( $OUTTYPE="1"))
    service_date_disp = format(chgs->qual[d.seq].service_dt_tm,"MMDDYY HHMM;;D"), activity_date_disp
     = format(chgs->qual[d.seq].activity_dt_tm,"MMDDYY HHMM;;D")
   ELSEIF (( $OUTTYPE="2"))
    service_date_disp = format(chgs->qual[d.seq].service_dt_tm,"MM/DD/YYYY;;D"), activity_date_disp
     = format(chgs->qual[d.seq].activity_dt_tm,"MM/DD/YYYY;;D")
   ENDIF
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
   tier_fin_disp = substring(1,3,uar_get_code_display(chgs->qual[d.seq].tier_group_cd)), fin_number
    = trim(chgs->qual[d.seq].fin_nbr,3), act_type_disp = substring(1,15,uar_get_code_display(chgs->
     qual[d.seq].activity_type_cd))
   IF (( $OUTTYPE="1"))
    col 1, chgs->qual[d.seq].cdm_num, col 8,
    "/", col 9, chgs->qual[d.seq].charge_desc,
    col 41, quan_out"####", col 46,
    service_date_disp, col 58, activity_date_disp,
    col 70, chg_sts_disp, col 75,
    include_rsn_disp, col 95, act_type_disp,
    col 112, tier_fin_disp, col 116,
    fin_number, col 126, chgs->qual[d.seq].updt_name,
    row + 1
   ELSEIF (( $OUTTYPE="2"))
    outstring = trim(build(chgs->qual[d.seq].cdm_num,',"',chgs->qual[d.seq].charge_desc,'",',quan_out,
      ",",service_date_disp,",",activity_date_disp,',"',
      chg_sts_disp,'","',include_rsn_disp,'","',act_type_disp,
      '","',substring(1,3,uar_get_code_display(chgs->qual[d.seq].tier_group_cd)),'","',chgs->qual[d
      .seq].fin_nbr,'","',
      chgs->qual[d.seq].updt_name,'"')), col 1, outstring,
    row + 1
   ENDIF
  FOOT  activity_type_disp
   IF (( $OUTTYPE="1"))
    row + 1
   ENDIF
  WITH maxcol = value(dynamic_maxcol), formfeed = none, maxrow = 1,
   landscape, compress, format = variable
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  IF (( $OUTTYPE="1"))
   SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".txt")
  ELSEIF (( $OUTTYPE="2"))
   SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  ENDIF
  IF (( $1="chargeusers@"))
   SET email_address =
   "Diane.Witkos@bhs.org, yvette.carter@bhs.org, bob.Scalzo@bhs.org, Laura.Walsh@bhs.org"
  ELSE
   SET email_address =  $1
  ENDIF
  CALL echo(email_address)
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out,email_address,concat(curprog,
    " - Baystate Medical Center Charge Audit"),1)
 ENDIF
END GO
