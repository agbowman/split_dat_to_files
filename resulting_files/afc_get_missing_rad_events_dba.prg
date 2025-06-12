CREATE PROGRAM afc_get_missing_rad_events:dba
 SET afc_get_missing_rad_events_vrsn = "129876.008"
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE radcompleted = f8
 DECLARE radiology_cd = f8
 SET codeset = 14192
 SET cdf_meaning = "RADCOMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,radcompleted)
 CALL echo(build("the radcompleted cd is : ",radcompleted))
 SET codeset = 13029
 SET cdf_meaning = "EXAMCOMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_examcomplete)
 CALL echo(build("the exam complete cd is : ",ce_examcomplete))
 SET radiology_disp = fillstring(40," ")
 SET codeset = 106
 SET cdf_meaning = "RADIOLOGY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,radiology_cd)
 CALL echo(build("the rad code is : ",radiology_cd))
 SET radiology_disp = uar_get_code_display(radiology_cd)
 CALL echo(build("the rad display is : ",radiology_disp))
 SET count1 = 0
 CALL echo("READING COMPLETE RAD EXAMS")
 SELECT INTO "nl	:"
  r.order_id, r.rad_exam_id, o.person_id,
  dta.mnemonic, oc.activity_type_cd, oc.primary_mnemonic
  FROM rad_exam r,
   discrete_task_assay dta,
   order_radiology o,
   order_catalog oc
  PLAN (o
   WHERE ((o.exam_status_cd+ 0)=radcompleted)
    AND o.complete_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.complete_dt_tm != null)
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(results->results,count1), results->results[count1].
   cs_order_id = r.order_id,
   results->results[count1].cs_catalog_cd = o.catalog_cd, results->results[count1].order_id = r
   .order_id, results->results[count1].accession = o.accession,
   results->results[count1].order_mnem = oc.primary_mnemonic, results->results[count1].catalog_cd = o
   .catalog_cd, results->results[count1].result_id = r.rad_exam_id,
   results->results[count1].service_resource_cd = r.service_resource_cd, results->results[count1].
   quantity = r.quantity, results->results[count1].credit_ind = r.credit_ind,
   results->results[count1].mnemonic = dta.mnemonic, results->results[count1].task_assay_cd = dta
   .task_assay_cd, results->results[count1].examcomplete_dt_tm = r.complete_dt_tm,
   results->results[count1].signout_dt_tm = null, results->results[count1].person_id = o.person_id,
   results->results[count1].encntr_id = o.encntr_id,
   results->results[count1].activity_type_cd = radiology_cd, results->results[count1].
   activity_type_disp = radiology_disp, results->results[count1].examcomplete_flag = 1,
   results->results[count1].bill_item_found = 1, results->results[count1].price_found = 1
  WITH nocounter
 ;end select
 CALL echo(build("count1: ",count1))
 SET results->result_qual = count1
 SET done = 0
 IF (count1=0)
  SET done = 1
 ENDIF
 WHILE (done=0)
  SET done = 1
  SELECT INTO "nl:"
   next_cs_id = o.cs_order_id
   FROM (dummyt d1  WITH seq = value(size(results->results,5))),
    orders o
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=results->results[d1.seq].cs_order_id))
   DETAIL
    IF (o.cs_order_id != 0)
     done = 0, results->results[d1.seq].cs_order_id = o.cs_order_id
    ELSE
     results->results[d1.seq].cs_catalog_cd = o.catalog_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDWHILE
 CALL echo("CHECKING FOR EXAMCOMPLETE CEA'S")
 SELECT INTO "nl:"
  cea.charge_event_act_id
  FROM (dummyt d1  WITH seq = value(results->result_qual)),
   charge_event c,
   charge_event_act cea
  PLAN (d1
   WHERE (results->results[d1.seq].examcomplete_flag=1)
    AND (results->results[d1.seq].price_found=1))
   JOIN (c
   WHERE (c.ext_m_event_id=results->results[d1.seq].cs_order_id)
    AND (c.ext_p_event_id=results->results[d1.seq].order_id)
    AND (c.ext_i_reference_id=results->results[d1.seq].task_assay_cd))
   JOIN (cea
   WHERE cea.charge_event_id=c.charge_event_id
    AND cea.cea_type_cd=ce_examcomplete)
  DETAIL
   CALL echo(c.ext_p_event_id,0),
   CALL echo(" ",0),
   CALL echo(c.ext_i_event_id)
   IF (cea.charge_event_act_id != 0)
    results->results[d1.seq].ce_examcomplete_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("GETTING PERSON NAME")
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(results->result_qual)),
   person p
  PLAN (d1
   WHERE (results->results[d1.seq].examcomplete_flag=1)
    AND (results->results[d1.seq].ce_examcomplete_flag=0)
    AND (results->results[d1.seq].price_found=1))
   JOIN (p
   WHERE (p.person_id=results->results[d1.seq].person_id))
  DETAIL
   results->results[d1.seq].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 CALL echorecord(results)
 CALL echo("LEAVING AFC_GET_MISSING_RAD_EVENTS")
END GO
