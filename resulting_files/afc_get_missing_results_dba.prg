CREATE PROGRAM afc_get_missing_results:dba
 SET afc_get_missing_results_vrsn = "129876.008"
 DECLARE result_verified = f8
 DECLARE auto_verified = f8
 DECLARE ce_verified = f8
 DECLARE order_id = f8
 DECLARE cs_order_id = f8
 DECLARE catalog_cd = f8
 SET order_id = 0.0
 SET cs_order_id = 0.0
 SET catalog_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1901,"VERIFIED",1,result_verified)
 CALL echo(build("RESULT_VERIFIED:",result_verified))
 IF (result_verified <= 0.0)
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1901,"AUTOVERIFIED",1,auto_verified)
 CALL echo(build("AUTO_VERIFIED:",auto_verified))
 IF (auto_verified <= 0.0)
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"VERIFIED",1,ce_verified)
 CALL echo(build("CE_VERIFIED:",ce_verified))
 IF (ce_verified <= 0.0)
  GO TO end_program
 ENDIF
 SET count1 = 0
 SELECT INTO "nl:"
  r.order_id, r.result_id, r.result_status_cd,
  o.person_id, dta.mnemonic, o.activity_type_cd,
  cv.display
  FROM result_event re,
   result r,
   discrete_task_assay dta,
   orders o,
   code_value cv
  PLAN (re
   WHERE re.event_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND re.event_type_cd IN (result_verified, auto_verified))
   JOIN (r
   WHERE r.result_id=re.result_id)
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd)
   JOIN (o
   WHERE o.order_id=r.order_id
    AND ((o.person_id+ 0) > 0)
    AND ((o.product_id+ 0)=0))
   JOIN (cv
   WHERE cv.code_value=o.activity_type_cd)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(results->results,count1), results->results[count1].order_id
    = r.order_id,
   results->results[count1].order_mnem = o.order_mnemonic, results->results[count1].catalog_cd = o
   .catalog_cd, results->results[count1].result_id = r.result_id,
   results->results[count1].mnemonic = dta.mnemonic, results->results[count1].task_assay_cd = dta
   .task_assay_cd, results->results[count1].perform_dt_tm = r.updt_dt_tm,
   results->results[count1].person_id = o.person_id, results->results[count1].encntr_id = o.encntr_id,
   results->results[count1].activity_type_cd = o.activity_type_cd,
   results->results[count1].activity_type_disp = cv.display, results->results[count1].
   result_status_cd = re.event_type_cd, results->results[count1].verified_flag =
   IF ((((results->results[count1].result_status_cd=result_verified)) OR ((results->results[count1].
   result_status_cd=auto_verified))) ) 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("count1: ",count1))
 SET results->result_qual = count1
 IF ((results->result_qual > 0))
  FOR (i = 1 TO value(size(results->results,5)))
    SELECT INTO "nl:"
     o.catalog_cd, o.cs_order_id, o.order_id
     FROM orders o
     WHERE (o.order_id=results->results[i].order_id)
     DETAIL
      catalog_cd = o.catalog_cd, order_id = o.order_id, cs_order_id = o.cs_order_id
     WITH nocounter
    ;end select
    WHILE (cs_order_id > 0)
     SELECT INTO "nl:"
      o.catalog_cd, o.cs_order_id, o.order_id
      FROM orders o
      WHERE o.order_id=cs_order_id
      DETAIL
       catalog_cd = o.catalog_cd, order_id = o.order_id, cs_order_id = o.cs_order_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET cs_order_id = 0.0
     ENDIF
    ENDWHILE
    SET results->results[i].cs_order_id = order_id
    SET results->results[i].catalog_cd = catalog_cd
  ENDFOR
  SELECT INTO "nl:"
   pr.result_status_cd, pr.perform_dt_tm
   FROM (dummyt d1  WITH seq = value(results->result_qual)),
    perform_result pr
   PLAN (d1)
    JOIN (pr
    WHERE (pr.result_id=results->results[d1.seq].result_id))
   DETAIL
    IF (pr.perform_dt_tm != 0)
     results->results[d1.seq].perform_dt_tm = pr.perform_dt_tm
    ENDIF
    results->results[d1.seq].perform_result_status_cd = pr.result_status_cd, results->results[d1.seq]
    .verified_flag =
    IF (((pr.result_status_cd=result_verified) OR (pr.result_status_cd=auto_verified)) ) 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(results->result_qual)),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (results->results[d1.seq].verified_flag=1))
    JOIN (c
    WHERE (((c.ext_m_event_id=results->results[d1.seq].order_id)
     AND (c.ext_i_event_id=results->results[d1.seq].result_id)
     AND (results->results[d1.seq].cs_order_id=0)) OR ((c.ext_m_event_id=results->results[d1.seq].
    cs_order_id)
     AND (c.ext_p_event_id=results->results[d1.seq].order_id)
     AND (c.ext_i_event_id=results->results[d1.seq].result_id)
     AND (results->results[d1.seq].cs_order_id != 0))) )
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_verified)
   DETAIL
    IF (cea.charge_event_act_id != 0)
     results->results[d1.seq].ce_verified_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d1  WITH seq = value(results->result_qual)),
    person p
   PLAN (d1
    WHERE (results->results[d1.seq].verified_flag=1)
     AND (results->results[d1.seq].ce_verified_flag=0))
    JOIN (p
    WHERE (p.person_id=results->results[d1.seq].person_id))
   DETAIL
    results->results[d1.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   a.accession
   FROM (dummyt d1  WITH seq = value(results->result_qual)),
    accession_order_r r,
    accession a
   PLAN (d1
    WHERE (results->results[d1.seq].verified_flag=1)
     AND (results->results[d1.seq].ce_verified_flag=0))
    JOIN (r
    WHERE (r.order_id=results->results[d1.seq].order_id))
    JOIN (a
    WHERE a.accession_id=r.accession_id)
   DETAIL
    results->results[d1.seq].accession = a.accession
   WITH nocounter
  ;end select
 ENDIF
#end_program
END GO
