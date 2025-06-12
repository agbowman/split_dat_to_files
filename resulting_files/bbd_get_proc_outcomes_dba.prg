CREATE PROGRAM bbd_get_proc_outcomes:dba
 RECORD reply(
   1 qual[*]
     2 procedure_outcome_id = f8
     2 outcome_cd = f8
     2 outcome_cd_disp = vc
     2 outcome_cd_mean = vc
     2 order_processing_ind = i2
     2 count_as_donation_ind = i2
     2 add_product_ind = i2
     2 updt_cnt = i4
     2 synonym_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  bpo.procedure_outcome_id, bpo.outcome_cd, bpo.count_as_donation_ind,
  bpo.add_product_ind, bpo.synonym_id, bpo.updt_cnt,
  o.mnemonic
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   order_catalog_synonym o
  PLAN (bdp
   WHERE (bdp.procedure_cd=request->procedure_cd)
    AND bdp.active_ind=1)
   JOIN (bpo
   WHERE bpo.procedure_id=bdp.procedure_id
    AND bpo.active_ind=1)
   JOIN (o
   WHERE o.synonym_id=bpo.synonym_id)
  HEAD REPORT
   stat = alterlist(reply->qual,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].procedure_outcome_id = bpo.procedure_outcome_id, reply->qual[count].outcome_cd
    = bpo.outcome_cd
   IF (bpo.synonym_id > 0.0)
    reply->qual[count].order_processing_ind = 1
   ELSE
    reply->qual[count].order_processing_ind = 0
   ENDIF
   reply->qual[count].count_as_donation_ind = bpo.count_as_donation_ind, reply->qual[count].
   add_product_ind = bpo.add_product_ind, reply->qual[count].synonym_id = bpo.synonym_id,
   reply->qual[count].updt_cnt = bpo.updt_cnt, reply->qual[count].mnemonic = o.mnemonic
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
