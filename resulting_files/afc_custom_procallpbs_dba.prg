CREATE PROGRAM afc_custom_procallpbs:dba
 RECORD request2(
   1 beg_action = i2
   1 end_action = i2
   1 first_time = c1
   1 file_name = c80
   1 charge_qual = i4
   1 charge[*]
     2 interface_charge_id = f8
     2 interface_file_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 pat_serverid = c1
     2 patid = c100
     2 pat_program_serverid = c1
     2 pat_programid = c100
     2 bill_code_serverid = c1
     2 prim_cdm = c40
     2 service_dt_tm = dq8
     2 service_end_dt_tm = dq8
     2 type = c1
     2 quantity = f8
 )
 IF (validate(request->rerun_mode,"XXX") != "XXX")
  IF (trim(request->rerun_mode)="DAY")
   SET r_mode = "DAY"
  ELSEIF (trim(request->rerun_mode)="OOPS")
   SET r_mode = "OOPS"
  ELSE
   SET r_mode = "REGULAR"
  ENDIF
 ELSE
  SET r_mode = "REGULAR"
 ENDIF
 CALL echo(build("Run Mode is: ",r_mode))
 IF (validate(request->ops_date,999) != 999)
  IF ((request->ops_date > 0))
   SET rn_dt = cnvtdatetime(request->ops_date)
  ELSE
   SET rn_dt = cnvtdatetime(curdate,curtime)
  ENDIF
 ELSE
  SET rn_dt = cnvtdatetime(curdate,curtime)
 ENDIF
 CALL echo(build("Ops date is:",rn_dt))
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE g_bill_mnem_cd = f8
 DECLARE g_org_alias_client_cd = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE pbs_person_alias_type_cd = f8
 DECLARE pbs_encntr_alias_type_cd = f8
 DECLARE object_name_cd = f8
 SET codeset = 25632
 SET cdf_meaning = "AFC_RUN_CUST"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,object_name_cd)
 CALL echo(build("the AFC_POST_INT code value is: ",object_name_cd))
 SET codeset = 4
 SET cdf_meaning = "PBSID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,pbs_person_alias_type_cd)
 CALL echo(build("the PERSON_ALIAS_TYPE_CD is: ",pbs_person_alias_type_cd))
 SET codeset = 319
 SET cdf_meaning = "PBSID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,pbs_encntr_alias_type_cd)
 CALL echo(build("the ENCNTR_ALIAS_TYPE_CD is: ",pbs_encntr_alias_type_cd))
 SET run_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 CALL echo(format(cnvtdatetime(run_dt),"DD-MMM-YYYY hh:mm;;d"))
 SET file_name = outputlist->ol_frecs[rptrun].ol_file_name
 CALL echo(build("filename is: ",file_name))
 IF (r_mode="DAY")
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE i.process_flg=999
     AND i.posted_dt_tm=cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))
   ORDER BY i.interface_charge_id
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    person_id = i.person_id, request2->charge[count1].encntr_id = i.encntr_id,
    request2->charge[count1].pat_serverid = "1", request2->charge[count1].pat_program_serverid = "1",
    request2->charge[count1].bill_code_serverid = "1",
    request2->charge[count1].prim_cdm = i.prim_cdm, request2->charge[count1].service_dt_tm = i
    .service_dt_tm, request2->charge[count1].service_end_dt_tm = i.service_dt_tm,
    request2->charge[count1].type = "1", request2->charge[count1].quantity = i.quantity, reply->
    t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
   WITH nocounter
  ;end select
  CALL echo("Finished DAY mode")
 ELSEIF (trim(r_mode)="OOPS")
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE ((i.process_flg=0
     AND i.beg_effective_dt_tm < cnvtdatetime(run_dt)) OR (i.process_flg=999
     AND i.posted_dt_tm=cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))) )
   ORDER BY i.interface_charge_id
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    person_id = i.person_id, request2->charge[count1].encntr_id = i.encntr_id,
    request2->charge[count1].pat_serverid = "1", request2->charge[count1].pat_program_serverid = "1",
    request2->charge[count1].bill_code_serverid = "1",
    request2->charge[count1].prim_cdm = i.prim_cdm, request2->charge[count1].service_dt_tm = i
    .service_dt_tm, request2->charge[count1].service_end_dt_tm = i.service_dt_tm,
    request2->charge[count1].type = "1", request2->charge[count1].quantity = i.quantity, reply->
    t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
   WITH nocounter, outerjoin = cv
  ;end select
  CALL echo("Finished OOPS mode")
 ELSE
  SELECT INTO "nl:"
   i.*
   FROM interface_charge i
   PLAN (i
    WHERE i.process_flg=0
     AND i.beg_effective_dt_tm < cnvtdatetime(run_dt)
     AND (i.interface_file_id=outputlist->ol_frecs[rptrun].ol_file_id))
   ORDER BY i.interface_charge_id
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request2->charge,count1), stat = alterlist(reply->t01_recs,
     count1),
    request2->charge[count1].interface_charge_id = i.interface_charge_id, request2->charge[count1].
    person_id = i.person_id, request2->charge[count1].encntr_id = i.encntr_id,
    request2->charge[count1].pat_serverid = "1", request2->charge[count1].pat_program_serverid = "1",
    request2->charge[count1].bill_code_serverid = "1",
    request2->charge[count1].prim_cdm = i.prim_cdm, request2->charge[count1].service_dt_tm = i
    .service_dt_tm, request2->charge[count1].service_end_dt_tm = i.service_dt_tm,
    request2->charge[count1].type = "1", request2->charge[count1].quantity = i.quantity, reply->
    t01_recs[count1].t01_interfaced = "Y",
    request2->charge_qual = count1
   WITH nocounter, outerjoin = cv
  ;end select
 ENDIF
 CALL echo(build("# Recs: ",request2->charge_qual))
 IF ((request2->charge_qual=0))
  SET reply->status_data.status = "Z"
  GO TO end_program
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request2->charge_qual > 0))
  SELECT INTO "nl:"
   pa.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    person_alias pa
   PLAN (d1)
    JOIN (pa
    WHERE (pa.person_id=request2->charge[d1.seq].person_id)
     AND pa.active_ind=1
     AND pa.person_alias_type_cd=pbs_person_alias_type_cd)
   DETAIL
    request2->charge[d1.seq].patid = pa.alias
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   ea.alias
   FROM (dummyt d1  WITH seq = value(request2->charge_qual)),
    encntr_alias ea
   PLAN (d1)
    JOIN (ea
    WHERE (ea.encntr_id=request2->charge[d1.seq].encntr_id)
     AND ea.active_ind=1
     AND ea.encntr_alias_type_cd=pbs_encntr_alias_type_cd)
   DETAIL
    request2->charge[d1.seq].pat_programid = ea.alias
   WITH nocounter
  ;end select
  SET outfile = substring(1,30,file_name)
  CALL echo(build("outfile is : ",outfile))
  UPDATE  FROM interface_charge i,
    (dummyt d  WITH seq = value(request2->charge_qual))
   SET i.process_flg = 999, i.posted_dt_tm = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D"),
      " 23:59:59.99"))
   PLAN (d
    WHERE size(trim(request2->charge[d.seq].pat_programid),3) > 0)
    JOIN (i
    WHERE (i.interface_charge_id=request2->charge[d.seq].interface_charge_id))
  ;end update
  COMMIT
  SET reply->status_data.status = "S"
  EXECUTE afc_create_pbs
  CALL echo("Executing Create XXX")
 ELSE
  CALL echo("No charges found")
 ENDIF
#end_program
 SET count1 = 1
 FREE SET request2
END GO
