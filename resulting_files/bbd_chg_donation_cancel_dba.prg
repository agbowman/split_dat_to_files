CREATE PROGRAM bbd_chg_donation_cancel:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET donate_cd = 0.0
 SET cancelled_cd = 0.0
 SET stat = 0
 SET qual_index = 0
 SET number_in = size(request->qual,5)
 SET cancelleda_cd = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 0
 SET code_set = 14220
 SET cdf_meaning = "DONATE"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donate_cd)
 SET code_set = 14224
 SET cdf_meaning = "CANCELLED"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,cancelled_cd)
 CALL echo(cancelled_cd)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=261
   AND cdf_meaning="CANCELLED"
   AND display="Cancelled"
  DETAIL
   cancelleda_cd = c.code_value
  WITH nocounter
 ;end select
 UPDATE  FROM bbd_donor_contact dc,
   (dummyt d1  WITH seq = value(number_in))
  SET dc.updt_cnt = (dc.updt_cnt+ 1), dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id =
   reqinfo->updt_id,
   dc.updt_task = reqinfo->updt_task, dc.updt_applctx = reqinfo->updt_applctx, dc.contact_status_cd
    = cancelled_cd
  PLAN (d1)
   JOIN (dc
   WHERE (dc.contact_id=request->qual[d1.seq].contact_id)
    AND (request->qual[d1.seq].contact_id != 0))
  WITH nocounter
 ;end update
 UPDATE  FROM encounter ec,
   (dummyt d1  WITH seq = value(number_in))
  SET ec.updt_cnt = (ec.updt_cnt+ 1), ec.updt_dt_tm = cnvtdatetime(curdate,curtime3), ec.updt_id =
   reqinfo->updt_id,
   ec.updt_task = reqinfo->updt_task, ec.updt_applctx = reqinfo->updt_applctx, ec.encntr_status_cd =
   cancelleda_cd
  PLAN (d1)
   JOIN (ec
   WHERE (ec.encntr_id=request->qual[d1.seq].encntr_id)
    AND (request->qual[d1.seq].encntr_id != 0))
  WITH nocounter
 ;end update
 COMMIT
 SET reply->status_data.status = "S"
END GO
