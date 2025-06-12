CREATE PROGRAM cp_get_cpt4_codes
 RECORD reply(
   1 qual[*]
     2 code = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET x = 0
 SET count = size(request->order_list,5)
 DECLARE debit_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13028,"DR")), protect
 SELECT INTO "nl:"
  cm.field6, cm.field7
  FROM (dummyt d1  WITH seq = value(count)),
   charge ch,
   charge_mod cm,
   code_value cv
  PLAN (d1)
   JOIN (ch
   WHERE (ch.encntr_id=request->encntr_id)
    AND (ch.order_id=request->order_list[d1.seq].order_id)
    AND  NOT (ch.process_flg IN (6, 10))
    AND ch.active_ind=1
    AND ch.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ch.end_effective_dt_tm >= cnvtdatetime("31-dec-2100")
    AND ch.charge_type_cd=debit_type_cd
    AND ch.offset_charge_item_id=0)
   JOIN (cm
   WHERE cm.charge_item_id=ch.charge_item_id
    AND cm.active_ind=1
    AND cm.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cm.end_effective_dt_tm >= cnvtdatetime("31-dec-2100"))
   JOIN (cv
   WHERE cv.code_value=cm.field1_id
    AND cv.code_set=14002
    AND (cv.cdf_meaning=request->code_meaning)
    AND cv.active_ind=1)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(reply->qual,x), reply->qual[x].code = cm.field6,
   reply->qual[x].description = cm.field7
  WITH nocounter
 ;end select
 IF (x > 0)
  SET failed = "S"
 ELSE
  SET failed = "Z"
 ENDIF
#exit_script
 SET reply->status_data.status = failed
END GO
