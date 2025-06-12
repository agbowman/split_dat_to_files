CREATE PROGRAM cps_nomen_get_outbound:dba
 RECORD reply(
   1 nomenclature_id = f8
   1 nomen_outbound_cnt = i2
   1 nomenclature_outbound[*]
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c20
     2 source_vocabulary_mean = c20
     2 alias = vc
     2 alias_type_meaning = vc
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET searchmsg = fillstring(100," ")
 SELECT INTO "nl:"
  no.nomenclature_id
  FROM nomenclature_outbound no
  WHERE (no.nomenclature_id=request->nomenclature_id)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->nomenclature_outbound,(count1+ 10))
   ENDIF
   reply->nomenclature_id = no.nomenclature_id, reply->nomenclature_outbound[count1].
   source_vocabulary_cd = no.source_vocabulary_cd, reply->nomenclature_outbound[count1].alias = no
   .alias,
   reply->nomenclature_outbound[count1].alias_type_meaning = no.alias_type_meaning, reply->
   nomenclature_outbound[count1].updt_dt_tm = no.updt_dt_tm
  WITH nocounter, maxqual(no,100)
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
  SET reply->nomen_outbound_cnt = 0
 ELSEIF (count1 > 0)
  SET reply->status_data.status = "S"
  SET reply->nomen_outbound_cnt = count1
  SET stat = alterlist(reply->nomenclature_outbound,count1)
 ELSE
  GO TO error_check
 ENDIF
#error_check
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE_OUTBOUND"
 ENDIF
END GO
