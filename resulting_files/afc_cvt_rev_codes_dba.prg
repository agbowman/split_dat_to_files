CREATE PROGRAM afc_cvt_rev_codes:dba
 EXECUTE cclseclogin
 SET message = nowindow
 DECLARE codevalue = f8
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE bi_type_cd = f8
 FREE SET rev_codes
 RECORD rev_codes(
   1 codes[*]
     2 bim_id = f8
     2 ext_desc = vc
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
 )
 FREE SET rev_scheds
 RECORD rev_scheds(
   1 scheds[*]
     2 rev_sched_cd = f8
 )
 SET num_cds = 1
 SET meaningval = fillstring(12," ")
 SET meaningval = "REVENUE"
 SET codeset = 14002
 SET cvct = 1
 SET iret = uar_get_meaning_by_codeset(codeset,meaningval,cvct,codevalue)
 IF (iret=0)
  CALL echo(concat("Success.  Code value: ",build(codevalue)))
  SET stat = alterlist(rev_scheds->scheds,cvct)
  SET rev_scheds->scheds[num_cds].rev_sched_cd = codevalue
 ELSE
  CALL echo("Failure.")
 ENDIF
 IF (cvct > 1)
  FOR (cvct2 = 2 TO cvct)
    SET i = cvct2
    SET iret = uar_get_meaning_by_codeset(codeset,meaningval,i,codevalue)
    IF (iret=0)
     CALL echo(concat("Success. Code Value: ",build(codevalue)))
     SET num_cds = (num_cds+ 1)
     SET rev_scheds->scheds[num_cds].rev_sched_cd = codevalue
    ELSE
     CALL echo("Failure.")
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(rev_scheds)
 SET codeset = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,bi_type_cd)
 CALL echo(build("the bi_type_cd value is: ",bi_type_cd))
 SET count = 0
 SELECT INTO "nl:"
  FROM bill_item b,
   bill_item_modifier bm,
   code_value cv,
   (dummyt d1  WITH seq = value(size(rev_scheds->scheds,5)))
  PLAN (bm
   WHERE bm.bill_item_type_cd=bi_type_cd
    AND bm.active_ind=1
    AND bm.key5_id > 0)
   JOIN (d1
   WHERE (rev_scheds->scheds[d1.seq].rev_sched_cd=bm.key1_id))
   JOIN (cv
   WHERE cv.code_value=bm.key5_id
    AND cv.code_set=20769
    AND cv.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=bm.bill_item_id)
  ORDER BY b.ext_description
  DETAIL
   count = (count+ 1), stat = alterlist(rev_codes->codes,count), rev_codes->codes[count].bim_id = bm
   .bill_item_mod_id,
   rev_codes->codes[count].ext_desc = trim(b.ext_description), rev_codes->codes[count].key6 = cv
   .display, rev_codes->codes[count].key7 = cv.description
  WITH nocounter
 ;end select
 CALL echo(build("The CSPricingTool built rev codes count is:",count))
 IF (count > 0)
  UPDATE  FROM bill_item_modifier bm,
    (dummyt d1  WITH seq = value(size(rev_codes->codes,5)))
   SET bm.key6 = rev_codes->codes[d1.seq].key6, bm.key7 = rev_codes->codes[d1.seq].key7, bm
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    bm.updt_id = 13659
   PLAN (d1)
    JOIN (bm
    WHERE (bm.bill_item_mod_id=rev_codes->codes[d1.seq].bim_id))
  ;end update
  SET equal_line = fillstring(130,"=")
  SELECT
   num_rows = count, rpt_date = concat(format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D"),format(
     cnvtdatetime(curdate,curtime)," HH:MM:SS;;S"))
   FROM (dummyt d1  WITH seq = value(size(rev_codes->codes,5)))
   HEAD REPORT
    col 50, "** CSPricingTool Built Rev Codes **", col 90,
    "Run Date: ", rpt_date, row + 2
   HEAD PAGE
    col 120, "Page: ", curpage"##",
    row + 1, col 00, equal_line,
    row + 2, col 00, "Orderable",
    col 32, "New Bill Code", col 48,
    "New Description", row + 2
   DETAIL
    col 00, rev_codes->codes[d1.seq].ext_desc"#############################", col 32,
    rev_codes->codes[d1.seq].key6"#########", col 48, rev_codes->codes[d1.seq].key7
    "#############################################",
    row + 1
   FOOT REPORT
    row + 2, col 70, "# of rows modified: ",
    num_rows
   WITH nocounter
  ;end select
 ELSE
  CALL echo("None found (that were built in CSPricingTool.")
 ENDIF
 SET count = 0
 SELECT INTO "nl:"
  FROM bill_item b,
   bill_item_modifier bm,
   code_value cv,
   (dummyt d1  WITH seq = value(size(rev_scheds->scheds,5)))
  PLAN (bm
   WHERE bm.active_ind=1
    AND bm.key5_id=0)
   JOIN (d1
   WHERE (rev_scheds->scheds[d1.seq].rev_sched_cd=bm.key1_id))
   JOIN (cv
   WHERE trim(cv.display)=trim(bm.key6)
    AND cv.code_set=20769
    AND cv.active_ind=1)
   JOIN (b
   WHERE b.bill_item_id=bm.bill_item_id)
  ORDER BY b.ext_description
  DETAIL
   count = (count+ 1), stat = alterlist(rev_codes->codes,count), rev_codes->codes[count].bim_id = bm
   .bill_item_mod_id,
   rev_codes->codes[count].ext_desc = trim(b.ext_description), rev_codes->codes[count].key5_id = cv
   .code_value
  WITH nocounter
 ;end select
 CALL echo(build("The CSBatchBuild built rev code count is:",count))
 IF (count > 0)
  UPDATE  FROM bill_item_modifier bm,
    (dummyt d1  WITH seq = value(size(rev_codes->codes,5)))
   SET bm.key5_id = rev_codes->codes[d1.seq].key5_id, bm.updt_dt_tm = cnvtdatetime(curdate,curtime),
    bm.updt_id = 13659
   PLAN (d1)
    JOIN (bm
    WHERE (bm.bill_item_mod_id=rev_codes->codes[d1.seq].bim_id))
  ;end update
  SET equal_line = fillstring(130,"=")
  SELECT
   num_rows = count, rpt_date = concat(format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;D"),format(
     cnvtdatetime(curdate,curtime)," HH:MM:SS;;S")), desc = rev_codes->codes[d1.seq].ext_desc,
   key5_id = rev_codes->codes[d1.seq].key5_id, mod_id = rev_codes->codes[d1.seq].bim_id
   FROM (dummyt d1  WITH seq = value(size(rev_codes->codes,5)))
   HEAD REPORT
    col 50, "** CSBatchBuild Built Rev Codes **", col 90,
    "Run Date: ", rpt_date, row + 2
   HEAD PAGE
    col 120, "Page: ", curpage"##",
    row + 1, col 00, equal_line,
    row + 2, col 00, "Orderable",
    col 32, "BIM ID", col 42,
    "New Code Value", row + 2
   DETAIL
    col 00, desc, col 32,
    mod_id, col 42, key5_id,
    row + 1
   FOOT REPORT
    row + 2, col 70, "# of rows modified: ",
    num_rows
   WITH nocounter
  ;end select
 ELSE
  CALL echo("None found (that were built in CSBatchBuild.")
 ENDIF
 CALL echo("****  Type commit go if the results are correct.  ****")
END GO
