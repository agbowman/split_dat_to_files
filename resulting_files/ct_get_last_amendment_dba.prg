CREATE PROGRAM ct_get_last_amendment:dba
 RECORD reply(
   1 prot_amendment_id = f8
   1 prot_amendment_nbr = i4
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET trace = error
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET pmid = request->prot_master_id
 SET highestamdnbr = 0
 SET highestamdid = 0
 EXECUTE ct_get_highest_a_nbr
 CALL echo(build("return amd-nbr:",highestamdnbr))
 IF ((highestamdnbr=- (9)))
  SET reply->prot_amendment_nbr = highestamdnbr
  SET reply->prot_amendment_id = highestamdid
  SET reply->status_data.status = "F"
 ELSE
  SET reply->prot_amendment_id = highestamdid
  SET reply->prot_amendment_nbr = highestamdnbr
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("ret stat:",reply->status_data.status))
END GO
