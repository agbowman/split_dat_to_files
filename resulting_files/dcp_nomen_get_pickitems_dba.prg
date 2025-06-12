CREATE PROGRAM dcp_nomen_get_pickitems:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 active_ind = i2
     2 source_string = vc
     2 mnemonic = vc
     2 short_string = vc
     2 nomenclature_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET max = 100
 SET stat = alterlist(reply->qual,(max+ 1))
 SET maxread = max
 SET seed = build(cnvtlower(trim(request->searchstring)),"*")
 SET count1 = 0
 SET n = 0
 SELECT INTO "nl:"
  FROM normalized_string_index s,
   nomenclature n
  PLAN (s
   WHERE s.normalized_string=patstring(seed))
   JOIN (n
   WHERE s.nomenclature_id=n.nomenclature_id
    AND (n.source_vocabulary_cd=request->source_vocabulary_cd)
    AND (n.principle_type_cd=request->principle_type_cd)
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   IF (count1 < max)
    count1 = (count1+ 1), reply->qual[count1].source_string = n.source_string, reply->qual[count1].
    mnemonic = n.mnemonic,
    reply->qual[count1].short_string = n.short_string, reply->qual[count1].nomenclature_id = n
    .nomenclature_id
   ENDIF
  WITH counter, maxqual(n,value(maxread))
 ;end select
 SET reply->cnt = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_pickitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "no matches"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_pickitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "success"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
 CALL echo(build("status = ",reply->status_data.status))
END GO
