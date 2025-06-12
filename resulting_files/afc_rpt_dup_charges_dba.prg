CREATE PROGRAM afc_rpt_dup_charges:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET from_date = cnvtdatetime(curdate,curtime)
 SET to_date = cnvtdatetime(curdate,curtime)
 SET run_date = cnvtdatetime(curdate,curtime)
 SET printer = fillstring(100," ")
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
  SET file_name = "MINE"
  SET from_date = cnvtdatetime( $1)
  CALL echo(build("the from date is: ",format(from_date,"DD-MMM-YYYY HH:MM:SS;;d")))
  SET to_date = cnvtdatetime( $2)
  CALL echo(build("the to date is: ",format(to_date,"DD-MMM-YYYY HH:MM:SS;;d")))
 ELSE
  IF (validate(request->output_dist,"") != "")
   SET printer = trim(request->output_dist)
  ENDIF
  SET file_name = "ccluserdir:afc_dup_chrgs.dat"
  SET run_date = cnvtdatetime(request->ops_date)
  SET from_date = cnvtdatetime(concat(format(run_date,"DD-MMM-YYYY;;D")," 00:00:00.00"))
  CALL echo(build("the from date is: ",format(from_date,"DD-MMM-YYYY HH:MM;;D")))
  SET to_date = cnvtdatetime(concat(format(run_date,"DD-MMM-YYYY;;D")," 23:59:59.99"))
  CALL echo(build("the to date is: ",format(to_date,"DD-MMM-YYYY HH:MM;;D")))
 ENDIF
 RECORD charges(
   1 charges[*]
     2 charge_event_id = f8
     2 tier_group_cd = f8
     2 charge_type_cd = f8
     2 bill_item_id = f8
     2 person_id = f8
     2 encntr_id = f8
 )
 RECORD rep_charges(
   1 charges[*]
     2 charge_item_id = f8
     2 charge_event_id = f8
     2 charge_desc = vc
     2 service_dt_tm = dq8
     2 person_id = f8
     2 charge_type_cd = f8
     2 process_flg = i4
     2 person_name = vc
     2 fin_nbr = vc
     2 encntr_id = f8
 )
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE fin_num_cd = f8
 SET codeset = 319
 SET cdf_meaning = "FIN NBR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,fin_num_cd)
 CALL echo(build("the code value is: ",fin_num_cd))
 SET count = 0
 SET num_dups = 0
 SELECT INTO "nl:"
  c.charge_event_id, c.tier_group_cd, c.charge_type_cd,
  c.bill_item_id, c.person_id, c.encntr_id
  FROM charge c
  WHERE c.service_dt_tm BETWEEN cnvtdatetime(from_date) AND cnvtdatetime(to_date)
   AND c.active_ind=1
  ORDER BY c.charge_event_id, c.tier_group_cd, c.charge_type_cd,
   c.bill_item_id, c.person_id, c.encntr_id
  HEAD c.charge_event_id
   dummy = 1
  HEAD c.tier_group_cd
   dummy = 1
  HEAD c.charge_type_cd
   dummy = 1
  HEAD c.bill_item_id
   dummy = 1
  HEAD c.person_id
   dummy = 1
  HEAD c.encntr_id
   num_dups = 0
  DETAIL
   num_dups = (num_dups+ 1)
   IF (num_dups=2)
    count = (count+ 1), stat = alterlist(charges->charges,count), charges->charges[count].
    charge_event_id = c.charge_event_id,
    charges->charges[count].tier_group_cd = c.tier_group_cd, charges->charges[count].charge_type_cd
     = c.charge_type_cd, charges->charges[count].bill_item_id = c.bill_item_id,
    charges->charges[count].person_id = c.person_id, charges->charges[count].encntr_id = c.encntr_id
   ENDIF
  WITH nocounter
 ;end select
 IF (value(size(charges->charges,5)) > 0)
  SET count = 0
  SELECT INTO "nl:"
   c.charge_event_id, c.tier_group_cd, c.charge_type_cd,
   c.charge_item_id, c.charge_description, c.service_dt_tm,
   c.person_id, c.process_flg
   FROM charge c,
    (dummyt d  WITH seq = value(size(charges->charges,5)))
   PLAN (d)
    JOIN (c
    WHERE (c.charge_event_id=charges->charges[d.seq].charge_event_id)
     AND (c.tier_group_cd=charges->charges[d.seq].tier_group_cd)
     AND (c.charge_type_cd=charges->charges[d.seq].charge_type_cd)
     AND (c.bill_item_id=charges->charges[d.seq].bill_item_id)
     AND (c.person_id=charges->charges[d.seq].person_id)
     AND (c.encntr_id=charges->charges[d.seq].encntr_id))
   DETAIL
    count = (count+ 1), stat = alterlist(rep_charges->charges,count), rep_charges->charges[count].
    charge_event_id = c.charge_event_id,
    rep_charges->charges[count].charge_item_id = c.charge_item_id, rep_charges->charges[count].
    charge_desc = trim(c.charge_description), rep_charges->charges[count].service_dt_tm =
    cnvtdatetime(c.service_dt_tm),
    rep_charges->charges[count].person_id = c.person_id, rep_charges->charges[count].charge_type_cd
     = c.charge_type_cd, rep_charges->charges[count].process_flg = c.process_flg,
    rep_charges->charges[count].encntr_id = c.encntr_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM person p,
    (dummyt d1  WITH seq = value(size(rep_charges->charges,5)))
   PLAN (d1)
    JOIN (p
    WHERE (p.person_id=rep_charges->charges[d1.seq].person_id))
   DETAIL
    rep_charges->charges[d1.seq].person_name = concat(trim(p.name_last_key),",",trim(p.name_first_key
      ))
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    (dummyt d1  WITH seq = value(size(rep_charges->charges,5)))
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=rep_charges->charges[d1.seq].encntr_id)
     AND ea.encntr_alias_type_cd=fin_num_cd
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime)
     AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   DETAIL
    rep_charges->charges[d1.seq].fin_nbr = trim(ea.alias)
   WITH nocounter
  ;end select
  SET dashline = fillstring(130,"-")
  SELECT INTO value(file_name)
   dt = format(from_date,"ddmmmyyyy;;d"), tm = format(to_date,"hhmm;;s"), event_id = rep_charges->
   charges[d1.seq].charge_event_id
   FROM (dummyt d1  WITH seq = value(size(rep_charges->charges,5)))
   PLAN (d1)
   ORDER BY rep_charges->charges[d1.seq].person_name
   HEAD REPORT
    col 01, "Duplicate Charges Report", row + 1,
    col 01, curdate, " ",
    curtime, row + 2
   HEAD PAGE
    col 01, "Person Name", col 25,
    "FIN", col 45, "Charge Item ID",
    col 60, "Charge Event ID", col 75,
    "Charge Desc", col 100, "Service Dt Tm",
    col 115, "Process_flg", row + 1,
    col 01, dashline, row + 1
   HEAD event_id
    row + 1
   DETAIL
    col 01, rep_charges->charges[d1.seq].person_name"#######################", col 25,
    rep_charges->charges[d1.seq].fin_nbr"###################", col 45, rep_charges->charges[d1.seq].
    charge_item_id,
    col 60, rep_charges->charges[d1.seq].charge_event_id, col 75,
    rep_charges->charges[d1.seq].charge_desc"##########################################", col 100,
    rep_charges->charges[d1.seq].service_dt_tm"dd-mmm-yyyy hh:mm;;d",
    col 120, rep_charges->charges[d1.seq].process_flg, row + 1
   WITH compress, nocounter
  ;end select
  CALL echo("Duplicates found!")
  SET reply->status_data.status = "S"
  IF (validate(request->output_dist,"") != "")
   SET spool value(file_name) value(printer)
  ENDIF
 ELSE
  CALL echo("No duplicates found.")
  SET reply->status_data.status = "Z"
 ENDIF
 FREE SET charges
 FREE SET rep_charges
END GO
