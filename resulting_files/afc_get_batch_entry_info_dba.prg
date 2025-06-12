CREATE PROGRAM afc_get_batch_entry_info:dba
 RECORD reply(
   1 new_batch_num = f8
   1 ref_cont_cd = f8
   1 batch_charge_entry_seq = f8
   1 ref_cont_cd_inquiry = f8
 )
 IF ((request->batch_charge_entry_seq_only=1))
  SELECT INTO "nl:"
   y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->batch_charge_entry_seq = cnvtreal(y)
   WITH format, counter
  ;end select
 ELSE
  SELECT INTO "nl:"
   y = seq(bce_batch_num_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->new_batch_num = cnvtreal(y)
   WITH format, counter
  ;end select
  DECLARE charge_entry = f8
  SET code_set = 13016
  SET cdf_meaning = "CHARGE ENTRY"
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,charge_entry)
  SET reply->ref_cont_cd = charge_entry
  DECLARE inquiry = f8
  SET code_set = 13016
  SET cdf_meaning = "INQUIRY"
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,inquiry)
  SET reply->ref_cont_cd_inquiry = inquiry
  SELECT INTO "nl:"
   y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->batch_charge_entry_seq = cnvtreal(y)
   WITH format, counter
  ;end select
 ENDIF
END GO
