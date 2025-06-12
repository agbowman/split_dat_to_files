CREATE PROGRAM afc_get_rad_results:dba
 SET afc_get_rad_results_vrsn = "129876.005"
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE ce_task_assay = f8
 DECLARE ce_ord_id = f8
 DECLARE ce_ord_cat = f8
 DECLARE ce_result_id = f8
 DECLARE ce_examcomplete = f8
 RECORD results(
   1 result_qual = i4
   1 results[*]
     2 cs_order_id = f8
     2 cs_catalog_cd = f8
     2 order_id = f8
     2 order_mnem = c15
     2 catalog_cd = f8
     2 result_id = f8
     2 mnemonic = c15
     2 task_assay_cd = f8
     2 examcomplete_dt_tm = dq8
     2 signout_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c15
     2 accession = c18
     2 charge_event_id = f8
     2 service_resource_cd = f8
     2 examcomplete_flag = i2
     2 signout_flag = i2
     2 ce_examcomplete_flag = i2
     2 ce_signout_flag = i2
     2 bill_item_found = i2
     2 price_found = i2
     2 quantity = f8
     2 credit_ind = i2
 )
 IF (validate(reply->action_type,"XXX")="XXX")
  RECORD reply(
    1 action_type = c3
    1 charge_event_qual = i2
    1 charge_event[*]
      2 ext_master_event_id = f8
      2 ext_master_event_cont_cd = f8
      2 ext_master_reference_id = f8
      2 ext_master_reference_cont_cd = f8
      2 ext_parent_event_id = f8
      2 ext_parent_event_cont_cd = f8
      2 ext_parent_reference_id = f8
      2 ext_parent_reference_cont_cd = f8
      2 ext_item_event_id = f8
      2 ext_item_event_cont_cd = f8
      2 ext_item_reference_id = f8
      2 ext_item_reference_cont_cd = f8
      2 person_id = f8
      2 person_name = vc
      2 accession = vc
      2 encntr_id = f8
      2 order_mnemonic = c20
      2 mnemonic = c20
      2 charge_event_act_qual = i2
      2 charge_event_act[*]
        3 charge_event_id = f8
        3 cea_type_cd = f8
        3 cea_prsnl_id = f8
        3 cea_prsnl_type_cd = f8
        3 service_resource_cd = f8
        3 service_dt_tm = dq8
        3 charge_type_cd = f8
        3 quantity = i4
  )
 ENDIF
 SET begdate = format(cnvtdatetime(request->beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 CALL echo(build("begdate: ",begdate))
 SET enddate = format(cnvtdatetime(request->end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 CALL echo(build("begdate: ",begdate))
 CALL echo(build("enddate: ",enddate))
 CALL echo("CALL GET MISSING RAD EVENTS")
 EXECUTE afc_get_missing_rad_events
 CALL echo("AFTER GET MISSING RAD EVENTS")
 CALL echo(build("ce_examcomplete: ",ce_examcomplete))
 SET codeset = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_task_assay)
 CALL echo(build("the task assay code is : ",ce_task_assay))
 SET codeset = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_ord_id)
 CALL echo(build("the ord id code is : ",ce_ord_id))
 SET codeset = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_ord_cat)
 CALL echo(build("the ord cat code is : ",ce_ord_cat))
 SET codeset = 13016
 SET cdf_meaning = "RAD RESULT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,ce_result_id)
 CALL echo(build("the result id code is : ",ce_result_id))
 SET count1 = 0
 CALL echo("FILLING OUT REPLY")
 SELECT INTO "NL:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(results->result_qual))
  PLAN (d1
   WHERE (results->results[d1.seq].examcomplete_flag=1)
    AND (results->results[d1.seq].ce_examcomplete_flag=0)
    AND (results->results[d1.seq].price_found=1)
    AND (results->results[d1.seq].credit_ind=0))
  ORDER BY results->results[d1.seq].order_id, results->results[d1.seq].result_id
  DETAIL
   CALL echo(build("ORDER_ID",results->results[d1.seq].order_id)), count1 = (count1+ 1), stat =
   alterlist(reply->charge_event,count1),
   reply->charge_event[count1].ext_master_event_id = results->results[d1.seq].cs_order_id, reply->
   charge_event[count1].ext_master_event_cont_cd = ce_ord_id, reply->charge_event[count1].
   ext_master_reference_id = results->results[d1.seq].cs_catalog_cd,
   reply->charge_event[count1].ext_master_reference_cont_cd = ce_ord_cat, reply->charge_event[count1]
   .ext_parent_event_id = results->results[d1.seq].order_id, reply->charge_event[count1].
   ext_parent_event_cont_cd = ce_ord_id,
   reply->charge_event[count1].ext_parent_reference_id = results->results[d1.seq].catalog_cd, reply->
   charge_event[count1].ext_parent_reference_cont_cd = ce_ord_cat, reply->charge_event[count1].
   ext_item_event_id = results->results[d1.seq].result_id,
   reply->charge_event[count1].ext_item_event_cont_cd = ce_result_id, reply->charge_event[count1].
   ext_item_reference_id = results->results[d1.seq].task_assay_cd, reply->charge_event[count1].
   ext_item_reference_cont_cd = ce_task_assay,
   reply->charge_event[count1].person_id = results->results[d1.seq].person_id, reply->charge_event[
   count1].person_name = results->results[d1.seq].person_name, reply->charge_event[count1].encntr_id
    = results->results[d1.seq].encntr_id,
   reply->charge_event[count1].accession = results->results[d1.seq].accession, reply->charge_event[
   count1].order_mnemonic = results->results[d1.seq].order_mnem, reply->charge_event[count1].order_id
    = results->results[d1.seq].order_id,
   reply->charge_event[count1].mnemonic = results->results[d1.seq].mnemonic, stat = alterlist(reply->
    charge_event[count1].charge_event_act,1), reply->charge_event[count1].charge_event_act[1].
   cea_type_cd = ce_examcomplete,
   reply->charge_event[count1].charge_event_act[1].service_resource_cd = results->results[d1.seq].
   service_resource_cd, reply->charge_event[count1].charge_event_act[1].service_dt_tm = results->
   results[d1.seq].examcomplete_dt_tm, reply->charge_event[count1].charge_event_act[1].charge_type_cd
    = 0,
   reply->charge_event[count1].charge_event_act[1].quantity = results->results[d1.seq].quantity,
   reply->charge_event[count1].charge_event_act_qual = 1
  WITH nocounter
 ;end select
 SET reply->charge_event_qual = count1
 CALL echo(build("CHARGE_EVENT_QUAL IS: ",reply->charge_event_qual))
 FREE SET results
END GO
