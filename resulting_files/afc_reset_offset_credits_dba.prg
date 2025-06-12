CREATE PROGRAM afc_reset_offset_credits:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET credits
 RECORD credits(
   1 charges[*]
     2 credit_charge_item_id = f8
     2 debit_charge_item_id = f8
 )
 SET reply->status_data.status = "F"
 IF (validate(request->ops_date,999)=999)
  EXECUTE cclseclogin
  SET message = nowindow
 ENDIF
 DECLARE cnt = i4
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE charge_type = f8
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,charge_type)
 CALL echo(build("the credit code value is: ",charge_type))
 SET count = 0
 SELECT INTO "nl:"
  FROM charge c1,
   charge c2,
   interface_charge i
  PLAN (c1
   WHERE c1.charge_type_cd=charge_type
    AND c1.process_flg=10)
   JOIN (c2
   WHERE c2.charge_item_id=c1.parent_charge_item_id
    AND c2.process_flg IN (999, 10))
   JOIN (i
   WHERE i.charge_item_id=c2.charge_item_id)
  DETAIL
   count = (count+ 1), stat = alterlist(credits->charges,count), credits->charges[count].
   credit_charge_item_id = c1.charge_item_id,
   credits->charges[count].debit_charge_item_id = c2.charge_item_id
  WITH nocounter
 ;end select
 UPDATE  FROM charge c,
   (dummyt d1  WITH seq = value(size(credits->charges,5)))
  SET c.process_flg = 0, c.updt_id = 13659, c.updt_dt_tm = cnvtdatetime(curdate,curtime)
  PLAN (d1)
   JOIN (c
   WHERE (c.charge_item_id=credits->charges[d1.seq].credit_charge_item_id))
 ;end update
 UPDATE  FROM charge c,
   (dummyt d1  WITH seq = value(size(credits->charges,5)))
  SET c.process_flg = 999, c.updt_id = 13659, c.updt_dt_tm = cnvtdatetime(curdate,curtime)
  PLAN (d1)
   JOIN (c
   WHERE (c.charge_item_id=credits->charges[d1.seq].debit_charge_item_id)
    AND c.process_flg != 999)
 ;end update
 COMMIT
 IF (count > 0)
  CALL echo("Found some offset credits to update.")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  CALL echo("Didn't find any offset credits to update.")
  SET reply->status_data.status = "Z"
 ENDIF
END GO
