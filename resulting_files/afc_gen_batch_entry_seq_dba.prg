CREATE PROGRAM afc_gen_batch_entry_seq:dba
 SET afc_gen_batch_entry_seq_vrsn = "000"
 RECORD reply(
   1 batch_charge_entry_seq = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  batch_seq = seq(pft_activity_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(batch_seq)
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET reply->status_data[1].status = "F"
  SET reply->status_data[1].subeventstatus[1].operationstatus = "F"
 ELSE
  SET reply->batch_charge_entry_seq = new_nbr
  SET reply->status_data[1].status = "S"
  SET reply->status_data[1].subeventstatus[1].operationstatus = "S"
 ENDIF
 GO TO end_program
#end_program
END GO
