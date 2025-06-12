CREATE PROGRAM bsc_get_freqs_by_type:dba
 SET modify = predeclare
 RECORD reply(
   1 freq_list[*]
     2 frequency_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE freqcnt = i4 WITH noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SELECT DISTINCT INTO "NL:"
  fs.frequency_cd
  FROM frequency_schedule fs
  WHERE (fs.frequency_type=request->frequency_type)
  DETAIL
   freqcnt = (freqcnt+ 1)
   IF (mod(freqcnt,5)=1)
    stat = alterlist(reply->freq_list,(freqcnt+ 4))
   ENDIF
   reply->freq_list[freqcnt].frequency_cd = fs.frequency_cd
  FOOT REPORT
   stat = alterlist(reply->freq_list,freqcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "frequency_schedule "
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "08/08/2007"
 SET modify = nopredeclare
END GO
