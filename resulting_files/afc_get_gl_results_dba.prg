CREATE PROGRAM afc_get_gl_results:dba
 RECORD results(
   1 result_qual = i4
   1 results[*]
     2 order_id = f8
     2 cs_order_id = f8
     2 order_mnem = c15
     2 catalog_cd = f8
     2 result_id = f8
     2 mnemonic = c15
     2 task_assay_cd = f8
     2 perform_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c15
     2 accession = c18
     2 result_status_cd = f8
     2 perform_result_status_cd = f8
     2 performed_flag = i2
     2 verified_flag = i2
     2 charge_event_id = f8
     2 ce_performed_flag = i2
     2 ce_verified_flag = i2
     2 bill_item_found = i2
     2 price_found = i2
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
 DECLARE bb_code = f8
 DECLARE ce_ord_id = f8
 DECLARE ce_ord_cat = f8
 DECLARE ce_result_id = f8
 DECLARE ce_task_assay = f8
 DECLARE ce_verified = f8
 DECLARE result_verified = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 EXECUTE afc_get_missing_results
 SET code_set = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_task_assay)
 SET code_set = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_ord_id)
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_ord_cat)
 SET code_set = 13016
 SET cdf_meaning = "RESULT ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_result_id)
 SET code_set = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_task_assay)
 SET count1 = 0
 SELECT INTO "NL:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(results->result_qual))
  PLAN (d1
   WHERE (results->results[d1.seq].verified_flag=1)
    AND (results->results[d1.seq].ce_verified_flag=0))
  ORDER BY results->results[d1.seq].order_id, results->results[d1.seq].result_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->charge_event,count1), reply->charge_event[count1].
   ext_master_event_id =
   IF ((results->results[d1.seq].cs_order_id != 0)) results->results[d1.seq].cs_order_id
   ELSE results->results[d1.seq].order_id
   ENDIF
   ,
   reply->charge_event[count1].ext_master_event_cont_cd = ce_ord_id, reply->charge_event[count1].
   ext_master_reference_id = results->results[d1.seq].catalog_cd, reply->charge_event[count1].
   ext_master_reference_cont_cd = ce_ord_cat,
   reply->charge_event[count1].ext_parent_event_id = results->results[d1.seq].order_id, reply->
   charge_event[count1].ext_parent_event_cont_cd = ce_ord_id, reply->charge_event[count1].
   ext_parent_reference_id = results->results[d1.seq].catalog_cd,
   reply->charge_event[count1].ext_parent_reference_cont_cd = ce_ord_cat, reply->charge_event[count1]
   .ext_item_event_id = results->results[d1.seq].result_id, reply->charge_event[count1].
   ext_item_event_cont_cd = ce_result_id,
   reply->charge_event[count1].ext_item_reference_id = results->results[d1.seq].task_assay_cd, reply
   ->charge_event[count1].ext_item_reference_cont_cd = ce_task_assay, reply->charge_event[count1].
   person_id = results->results[d1.seq].person_id,
   reply->charge_event[count1].person_name = results->results[d1.seq].person_name, reply->
   charge_event[count1].encntr_id = results->results[d1.seq].encntr_id, reply->charge_event[count1].
   accession = results->results[d1.seq].accession,
   reply->charge_event[count1].order_mnemonic = results->results[d1.seq].order_mnem, reply->
   charge_event[count1].order_id = results->results[d1.seq].order_id, reply->charge_event[count1].
   mnemonic = results->results[d1.seq].mnemonic,
   stat = alterlist(reply->charge_event[count1].charge_event_act,1), reply->charge_event[count1].
   charge_event_act[1].cea_type_cd = ce_verified, reply->charge_event[count1].charge_event_act[1].
   service_resource_cd = 0,
   reply->charge_event[count1].charge_event_act[1].service_dt_tm = results->results[d1.seq].
   perform_dt_tm, reply->charge_event[count1].charge_event_act[1].charge_type_cd = 0, reply->
   charge_event[count1].charge_event_act[1].quantity = 1,
   reply->charge_event[count1].charge_event_act_qual = 1
  WITH nocounter
 ;end select
 SET reply->charge_event_qual = count1
 CALL echo(build("cHARGE_EVENT_QUAL IS: ",reply->charge_event_qual))
 FREE SET results
END GO
