CREATE PROGRAM afc_rpt_csops_summ:dba
 RECORD csops_files(
   1 files_qual = i2
   1 files[*]
     2 csops_summ_id = f8
     2 interface_file_id = f8
     2 description = c100
     2 interface_qual = i2
     2 interface[*]
       3 job_name_cd = f8
       3 job_display = c200
       3 job_status = c1
       3 batch_num = f8
       3 seq = i4
       3 charge_type_cd = f8
       3 charge_display = c200
       3 raw_count = i4
       3 quantity = f8
       3 amount = f8
       3 start_dt_tm = dq8
       3 end_dt_tm = dq8
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 DECLARE post_cd = f8
 DECLARE custom_cd = f8
 SET codeset = 25632
 SET cdf_meaning = "AFC_POST_INT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,post_cd)
 CALL echo(build("The code_value for afc_post_interface_charge is: ",post_cd))
 SET codeset = 25632
 SET cdf_meaning = "AFC_RUN_CUST"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,custom_cd)
 CALL echo(build("The code_value for afc_run_custom is: ",custom_cd))
 SET count_csops = 0
 SET count_summ = 0
 SELECT INTO "nl:"
  start_date = format(c.start_dt_tm,"MM:DD:YYYY"), i.interface_file_id, i.description,
  c.job_name_cd, job_name_display = cv.display, c.charge_type_cd,
  charge_type_display = cv1.display
  FROM interface_file i,
   csops_summ c,
   code_value cv,
   code_value cv1
  PLAN (i
   WHERE i.active_ind=1
    AND i.interface_file_id > 0)
   JOIN (c
   WHERE i.interface_file_id=c.interface_file_id)
   JOIN (cv
   WHERE c.job_name_cd=cv.code_value)
   JOIN (cv1
   WHERE c.charge_type_cd=cv1.code_value)
  ORDER BY start_date DESC, i.interface_file_id
  HEAD start_date
   count_csops = (count_csops+ 1), stat = alterlist(csops_files->files,count_csops), csops_files->
   files_qual = count_csops,
   count_summ = 0
  DETAIL
   count_summ = (count_summ+ 1), stat = alterlist(csops_files->files[count_csops].interface,
    count_summ), csops_files->files[count_csops].csops_summ_id = c.csops_summ_id,
   csops_files->files[count_csops].interface_file_id = c.interface_file_id, csops_files->files[
   count_csops].description = i.description, csops_files->files[count_csops].interface[count_summ].
   job_display = cv.display,
   csops_files->files[count_csops].interface[count_summ].job_name_cd = c.job_name_cd, csops_files->
   files[count_csops].interface[count_summ].job_status = c.job_status, csops_files->files[count_csops
   ].interface[count_summ].batch_num = c.batch_num,
   csops_files->files[count_csops].interface[count_summ].seq = c.seq, csops_files->files[count_csops]
   .interface[count_summ].charge_display = cv1.display, csops_files->files[count_csops].interface[
   count_summ].charge_type_cd = c.charge_type_cd,
   csops_files->files[count_csops].interface[count_summ].raw_count = c.raw_count, csops_files->files[
   count_csops].interface[count_summ].quantity = c.quantity, csops_files->files[count_csops].
   interface[count_summ].amount = c.amount,
   csops_files->files[count_csops].interface[count_summ].start_dt_tm = c.start_dt_tm, csops_files->
   files[count_csops].interface[count_summ].end_dt_tm = c.end_dt_tm, csops_files->files[count_csops].
   interface_qual = count_summ
  WITH nocounter
 ;end select
 SET output = "ccluserdir:afc_rpt_csops.dat"
 SET total_count_raw = 0
 SET total_count_quantity = 0
 SET total_count_amount = 0
 IF (curqual > 0)
  SELECT INTO value(output)
   rpt_csops_summ_id = csops_files->files[d1.seq].csops_summ_id, rpt_interface_file_id = csops_files
   ->files[d1.seq].interface_file_id, rpt_description = csops_files->files[d1.seq].description,
   rpt_start_dt_tm = format(csops_files->files[d1.seq].interface[d2.seq].start_dt_tm,
    "MM-DD-YYYY HH:MM.SS;;D")
   FROM (dummyt d1  WITH seq = value(size(csops_files->files,5))),
    dummyt d2,
    dummyt d3
   PLAN (d1)
    JOIN (d3)
    JOIN (d2
    WHERE d2.seq <= size(csops_files->files[d1.seq].interface,5))
   ORDER BY rpt_start_dt_tm DESC, rpt_interface_file_id
   HEAD REPORT
    line_d = fillstring(120,"="),
    CALL center("**** C H A R G E   S E R V I C E S   O P E R A T I O N S   S U M M A R Y ***",0,80),
    row + 1,
    col 100, "Report Date: ", curdate"MM/DD/YY;;D",
    row + 1, col 100, "Report Time: ",
    curtime"HH:MM;;M"
   HEAD PAGE
    MACRO (col_heads)
     col 0, "Interface", col 72,
     "Job", col 92, "Charge",
     col 102, "Raw", row + 1,
     col 0, "File", col 25,
     "Job Name", col 55, "Status",
     col 62, "Batch", col 72,
     "Seq", col 82, "Type",
     col 92, "Count", col 102,
     "QTY", col 112, "Amount"
    ENDMACRO
    , row + 1, row + 1,
    col_heads, row + 2, line_d,
    row + 1
   HEAD rpt_start_dt_tm
    row + 1, col 0, "Ops Date: ",
    col 11, csops_files->files[d1.seq].interface[d2.seq].start_dt_tm"DD MMM YYYY HH:MM.SS;R;DATE",
    gtotal_posted_charge = 0,
    gtotal_posted_quantity = 0, gtotal_posted_amount = 0, gtotal_sent_charge = 0,
    gtotal_sent_quantity = 0, gtotal_sent_amount = 0, gtotal_received_charge = 0,
    gtotal_received_quantity = 0, gtotal_received_amount = 0
   HEAD rpt_interface_file_id
    total_posted_charge = 0, total_posted_quantity = 0, total_posted_amount = 0,
    total_sent_charge = 0, total_sent_quantity = 0, total_sent_amount = 0,
    total_received_charge = 0, total_received_quantity = 0, total_received_amount = 0
    FOR (x = 1 TO csops_files->files[d1.seq].interface_qual)
      row + 1
      IF ((csops_files->files[d1.seq].interface[x].job_name_cd=post_cd))
       total_posted_charge = (total_posted_charge+ csops_files->files[d1.seq].interface[x].raw_count),
       total_posted_quantity = (total_posted_quantity+ csops_files->files[d1.seq].interface[x].
       quantity), total_posted_amount = (total_posted_amount+ csops_files->files[d1.seq].interface[x]
       .amount)
      ELSEIF ((csops_files->files[d1.seq].interface[x].job_name_cd=custom_cd))
       total_sent_charge = (total_sent_charge+ csops_files->files[d1.seq].interface[x].raw_count),
       total_sent_quantity = (total_posted_quantity+ csops_files->files[d1.seq].interface[x].quantity
       ), total_sent_amount = (total_sent_amount+ csops_files->files[d1.seq].interface[x].amount)
      ELSE
       total_received_charge = (total_received_charge+ csops_files->files[d1.seq].interface[x].
       raw_count), total_received_quantity = (total_received_quantity+ csops_files->files[d1.seq].
       interface[x].quantity), total_received_amount = (total_received_amount+ csops_files->files[d1
       .seq].interface[x].amount)
      ENDIF
      col 0, csops_files->files[d1.seq].description"###############", col 25,
      csops_files->files[d1.seq].interface[x].job_display"###########################", col 55,
      csops_files->files[d1.seq].interface[x].job_status"##",
      col 58, csops_files->files[d1.seq].interface[x].batch_num"##########", col 72,
      csops_files->files[d1.seq].interface[x].seq"####", col 82, csops_files->files[d1.seq].
      interface[x].charge_display"######",
      col 88, csops_files->files[d1.seq].interface[x].raw_count"######", col 98,
      csops_files->files[d1.seq].interface[x].quantity"###.##", col 108, csops_files->files[d1.seq].
      interface[x].amount"$######.##"
    ENDFOR
   FOOT  rpt_interface_file_id
    gtotal_posted_charge = (gtotal_posted_charge+ total_posted_charge), gtotal_posted_quantity = (
    gtotal_posted_quantity+ total_posted_quantity), gtotal_posted_amount = (gtotal_posted_amount+
    total_posted_amount),
    gtotal_sent_charge = (gtotal_sent_charge+ total_sent_charge), gtotal_sent_quantity = (
    gtotal_sent_quantity+ total_sent_quantity), gtotal_sent_amount = (gtotal_sent_amount+
    total_sent_amount),
    gtotal_received_charge = (gtotal_received_charge+ total_received_charge),
    gtotal_received_quantity = (gtotal_received_quantity+ total_received_quantity),
    gtotal_received_amount = (gtotal_received_amount+ total_received_amount),
    row + 4, col 10, csops_files->files[d1.seq].description"#####################",
    col 26, "Totals:", row + 1,
    col 30, "Posted Interface_charge: ", col 88,
    total_posted_charge"######", col 98, total_posted_quantity"###.##",
    col 108, total_posted_amount"$######.##", row + 1,
    col 30, "Send: ", col 88,
    total_sent_charge"######", col 98, total_sent_quantity"###.##",
    col 108, total_sent_amount"$######.##", row + 1,
    col 30, "Received: ", col 88,
    total_received_charge"######", col 98, total_received_quantity"###.##",
    col 108, total_sent_amount"$######.##", row + 4
   FOOT  rpt_start_dt_tm
    row + 4, col 20, "REPORT TOTALS: ",
    row + 1, col 30, "Posted Interface_charge: ",
    col 88, gtotal_posted_charge"######", col 98,
    gtotal_posted_quantity"####.##", col 108, gtotal_posted_amount"$######.##",
    row + 1, col 30, "Send: ",
    col 88, gtotal_sent_charge"######", col 98,
    gtotal_sent_quantity"####.##", col 108, gtotal_sent_amount"$######.##",
    row + 1, col 30, "Received: ",
    col 88, gtotal_received_charge"######", col 98,
    gtotal_received_quantity"####.##", col 108, gtotal_sent_amount"$######.##",
    row + 4
   FOOT REPORT
    row + 1, col 30, "End of the Report"
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo("No charges qualified.")
 ENDIF
END GO
