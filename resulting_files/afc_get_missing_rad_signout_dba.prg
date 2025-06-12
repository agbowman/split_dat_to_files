CREATE PROGRAM afc_get_missing_rad_signout:dba
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE radcompleted = f8
 DECLARE def_result_type_text_cd = f8
 DECLARE radiology_cd = f8
 DECLARE text_cd = f8
 SET codeset = 14192
 SET cdf_meaning = "RADCOMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,radcompleted)
 CALL echo(build("the radcompleted code is : ",radcompleted))
 SET codeset = 289
 SET cdf_meaning = "1"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,def_result_type_text_cd)
 CALL echo(build("the def_result code is : ",def_result_type_text_cd))
 SET codeset = 13029
 SET cdf_meaning = "SIGNOUT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_signout)
 CALL echo(build("the signout code is : ",ce_signout))
 SET radiology_disp = fillstring(40," ")
 SET codeset = 106
 SET cdf_meaning = "RADIOLOGY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,radiology_cd)
 CALL echo(build("the rad code is : ",radiology_cd))
 SET radiology_disp = uar_get_code_display(radiology_cd)
 CALL echo(build("the rad display is : ",radiology_disp))
 SET codeset = 289
 SET cdf_meaning = "1"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,text_cd)
 CALL echo(build("the text code is : ",text_cd))
 SET count1 = 0
 CALL echo("READING FINAL REPORTS")
 SELECT INTO "nl:"
  r.order_id, r.rad_report_id, o.order_id,
  o.person_id, o.encntr_id, o.accession,
  r.final_dt_tm, re.service_resource_cd, rrp.report_prsnl_id,
  dta.task_assay_cd, dta.mnemonic
  FROM rad_report r,
   order_radiology o,
   rad_exam re,
   rad_report_prsnl rrp,
   order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (r
   WHERE r.final_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND r.sequence=1
    AND r.order_id > 0)
   JOIN (o
   WHERE o.parent_order_id=r.order_id
    AND o.parent_order_id > 0)
   JOIN (re
   WHERE re.order_id=o.parent_order_id
    AND re.exam_sequence=1)
   JOIN (rrp
   WHERE rrp.rad_report_id=r.rad_report_id
    AND rrp.prsnl_relation_flag=2)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.default_result_type_cd=text_cd)
  DETAIL
   CALL echo(build("order id: ",o.order_id," result id: ",o.group_event_id)), count1 = (count1+ 1),
   stat = alterlist(results->results,count1),
   results->results[count1].cs_order_id = o.order_id, results->results[count1].cs_catalog_cd = o
   .catalog_cd, results->results[count1].order_id = o.order_id,
   results->results[count1].accession = o.accession, results->results[count1].catalog_cd = o
   .catalog_cd, results->results[count1].result_id = o.group_event_id,
   results->results[count1].signout_dt_tm = r.final_dt_tm, results->results[count1].person_id = o
   .person_id, results->results[count1].encntr_id = o.encntr_id,
   results->results[count1].activity_type_cd = radiology_cd, results->results[count1].
   activity_type_disp = radiology_disp, results->results[count1].signout_flag = 1,
   results->results[count1].report_id = r.rad_report_id, results->results[count1].service_resource_cd
    = re.service_resource_cd, results->results[count1].mnemonic = dta.mnemonic,
   results->results[count1].task_assay_cd = dta.task_assay_cd, results->results[count1].order_mnem =
   oc.primary_mnemonic, results->results[count1].prsnl_id = rrp.report_prsnl_id
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
 IF (size(results->results,5) > 0)
  CALL echo("CHECKING FOR SIGNOUT CEA'S")
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(size(results->results,5))),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (results->results[d1.seq].signout_flag=1))
    JOIN (c
    WHERE (c.ext_m_event_id=results->results[d1.seq].cs_order_id)
     AND (c.ext_p_event_id=results->results[d1.seq].order_id)
     AND (c.ext_i_event_id=results->results[d1.seq].result_id)
     AND (c.ext_i_reference_id=results->results[d1.seq].task_assay_cd))
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_signout)
   DETAIL
    CALL echo(cea.charge_event_act_id)
    IF (cea.charge_event_act_id != 0)
     results->results[d1.seq].ce_signout_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  CALL echo("GETTING PERSON NAME")
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d1  WITH seq = value(size(results->results,5))),
    person p
   PLAN (d1
    WHERE (results->results[d1.seq].signout_flag=1)
     AND (results->results[d1.seq].ce_signout_flag=0))
    JOIN (p
    WHERE (p.person_id=results->results[d1.seq].person_id))
   DETAIL
    results->results[d1.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  CALL echorecord(results)
 ENDIF
 CALL echo("LEAVING AFC_GET_MISSING_RAD_SIGNOUT")
END GO
