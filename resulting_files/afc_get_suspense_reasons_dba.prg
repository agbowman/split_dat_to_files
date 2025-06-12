CREATE PROGRAM afc_get_suspense_reasons:dba
 IF ("Z"=validate(afc_get_suspense_reasons_vrsn,"Z"))
  DECLARE afc_get_suspense_reasons_vrsn = vc WITH noconstant("429176.012")
 ENDIF
 SET afc_get_suspense_reasons_vrsn = "265113.011"
 RECORD reply(
   1 charge_item_qual = i2
   1 charge_item[*]
     2 charge_item_id = f8
     2 parent_charge_item_id = f8
     2 charge_event_act_id = f8
     2 charge_event_id = f8
     2 bill_item_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 payor_id = f8
     2 charge_description = vc
     2 item_quantity = f8
     2 item_price = f8
     2 item_extended_price = f8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 interface_file_id = f8
     2 realtime_ind = i2
     2 name_full_formatted = vc
     2 encntr_type_cd = f8
     2 discharge_dt_tm = dq8
     2 reason_qual = i2
     2 reason[*]
       3 charge_mod_id = f8
       3 reason_cd = f8
       3 reason_disp = c40
       3 reason_mean = c12
       3 reason_desc = c60
       3 suspended_by_profit_ind = i2
       3 field3_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET item_count = 0
 SET reason_count = 0
 DECLARE code_set = i4
 DECLARE cnt = i4
 DECLARE cdf_meaning = c12
 DECLARE suspense_code = f8
 SET code_set = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,suspense_code)
 CALL echo(concat("SUSPENSE_CODE: ",cnvtstring(suspense_code)))
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(25)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE num1 = i4 WITH noconstant(0)
 DECLARE count1 = i4
 SET cur_list_size = size(request->charge_item,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request->charge_item,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET request->charge_item[idx].charge_item_id = request->charge_item[cur_list_size].charge_item_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   charge c,
   person p,
   encounter e,
   interface_file i
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (c
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),c.charge_item_id,request->charge_item[idx].
    charge_item_id))
   JOIN (p
   WHERE p.person_id=c.person_id)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id)
   JOIN (i
   WHERE i.interface_file_id=c.interface_file_id)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->charge_item,count1), reply->charge_item[count1].
   charge_item_id = c.charge_item_id,
   reply->charge_item[count1].parent_charge_item_id = c.parent_charge_item_id, reply->charge_item[
   count1].charge_event_act_id = c.charge_event_act_id, reply->charge_item[count1].charge_event_id =
   c.charge_event_id,
   reply->charge_item[count1].bill_item_id = c.bill_item_id, reply->charge_item[count1].order_id = c
   .order_id, reply->charge_item[count1].encntr_id = c.encntr_id,
   reply->charge_item[count1].person_id = c.person_id, reply->charge_item[count1].payor_id = c
   .payor_id, reply->charge_item[count1].charge_description = c.charge_description,
   reply->charge_item[count1].item_quantity = c.item_quantity, reply->charge_item[count1].item_price
    = c.item_price, reply->charge_item[count1].item_extended_price = c.item_extended_price,
   reply->charge_item[count1].process_flg = c.process_flg, reply->charge_item[count1].service_dt_tm
    = cnvtdatetime(c.service_dt_tm), reply->charge_item[count1].interface_file_id = c
   .interface_file_id,
   reply->charge_item[count1].name_full_formatted = p.name_full_formatted, reply->charge_item[count1]
   .encntr_type_cd = e.encntr_type_cd, reply->charge_item[count1].discharge_dt_tm = cnvtdatetime(e
    .disch_dt_tm),
   reply->charge_item[count1].realtime_ind = i.realtime_ind
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 SET cur_list_size = size(reply->charge_item,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(reply->charge_item,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET reply->charge_item[idx].charge_item_id = reply->charge_item[cur_list_size].charge_item_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   charge_mod cm,
   code_value_extension cve
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (cm
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cm.charge_item_id,reply->charge_item[idx].
    charge_item_id)
    AND cm.charge_mod_type_cd=suspense_code
    AND cm.active_ind=1)
   JOIN (cve
   WHERE cve.code_value=cm.field1_id
    AND cve.field_name="SKIP_CHARGING_SERVER"
    AND cve.code_set=13030)
  ORDER BY cm.charge_item_id
  HEAD cm.charge_item_id
   index = locateval(num1,1,cur_list_size,cm.charge_item_id,reply->charge_item[num1].charge_item_id),
   reason_count = 0
  DETAIL
   IF (cm.charge_mod_id > 0)
    reason_count = (reason_count+ 1), stat = alterlist(reply->charge_item[index].reason,reason_count),
    reply->charge_item[index].reason_qual = reason_count,
    reply->charge_item[index].reason[reason_count].reason_cd = cm.field1_id, reply->charge_item[index
    ].reason[reason_count].charge_mod_id = cm.charge_mod_id, reply->charge_item[index].reason[
    reason_count].field3_id = cm.field3_id,
    reply->charge_item[index].reason[reason_count].suspended_by_profit_ind = cnvtint(cve.field_value)
    IF (uar_get_code_meaning(cm.field1_id)="POSTING")
     reply->charge_item[index].reason[reason_count].suspended_by_profit_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->charge_item,value(cur_list_size))
 SET reply->charge_item_qual = value(cur_list_size)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARGE_MOD"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
