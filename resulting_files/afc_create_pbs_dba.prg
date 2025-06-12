CREATE PROGRAM afc_create_pbs:dba
 DECLARE line1 = vc
 CALL create_bfa("INTEXT")
 GO TO end_of_bfa
 SUBROUTINE create_bfa(intext)
   CALL echo("CHARGE QUAL: ",0)
   CALL echo(request2->charge_qual)
   CALL echo(file_name)
   SELECT INTO value(file_name)
    t01_id = d.seq, patserverid = request2->charge[d.seq].pat_serverid, patid = request2->charge[d
    .seq].patid,
    patprogramserverid = request2->charge[d.seq].pat_program_serverid, patprogramid = request2->
    charge[d.seq].pat_programid, billcodeserverid = request2->charge[d.seq].bill_code_serverid,
    billcodeid = request2->charge[d.seq].prim_cdm, servicestart = format(request2->charge[d.seq].
     service_dt_tm,"MM/DD/YY;;DATE"), serviceend = format(request2->charge[d.seq].service_dt_tm,
     "MM/DD/YY;;DATE"),
    payortype = request2->charge[d.seq].type, servicequantity = format(request2->charge[d.seq].
     quantity,"###############.##;L;F"), batchserverid = "1",
    batchtblid = "0"
    FROM (dummyt d  WITH seq = value(request2->charge_qual))
    WHERE size(trim(request2->charge[d.seq].pat_programid),3) > 0
    ORDER BY request2->charge[d.seq].interface_charge_id
    DETAIL
     line1 = concat('"',patserverid,'","',trim(patid),'","',
      patprogramserverid,'","'), line1 = concat(line1,trim(patprogramid),'","',billcodeserverid,'","',
      trim(billcodeid)), line1 = concat(line1,'","',trim(servicestart),'","',trim(serviceend),
      '","',payortype),
     line1 = concat(line1,'","',trim(servicequantity),'","',batchserverid), line1 = concat(line1,
      '","',batchtblid,'"'), col 0,
     line1, row + 1
    WITH nocounter, format = variable
   ;end select
 END ;Subroutine
#end_of_bfa
END GO
