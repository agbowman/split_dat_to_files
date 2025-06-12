CREATE PROGRAM bbt_get_patient_dispense:dba
 RECORD reply(
   1 qual[*]
     2 product_event_id = f8
     2 unknown_patient_ind = i2
     2 unknown_patient_text = c50
     2 name_full_formatted = c50
     2 person_id = f8
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET event_cnt = 0
 SET qual_cnt = 0
 SET event_cnt = cnvtint(size(request->eventlist,5))
 SET stat = alterlist(reply->qual,event_cnt)
 SET reply->status_data.status = "I"
 SELECT INTO "nl:"
  pd.unknown_patient_ind, pd.unknown_patient_text, per.name_full_formatted,
  pd.person_id, pe.encntr_id
  FROM (dummyt d  WITH seq = value(event_cnt)),
   product_event pe,
   patient_dispense pd,
   (dummyt d_per  WITH seq = 1),
   person per
  PLAN (d)
   JOIN (pe
   WHERE (pe.product_event_id=request->eventlist[d.seq].product_event_id))
   JOIN (pd
   WHERE pd.product_event_id=pe.product_event_id)
   JOIN (d_per
   WHERE d_per.seq=1)
   JOIN (per
   WHERE per.person_id=pd.person_id
    AND per.person_id > 0)
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt += 1, reply->qual[d.seq].product_event_id = pd.product_event_id, reply->qual[d.seq].
   unknown_patient_ind = pd.unknown_patient_ind,
   reply->qual[d.seq].unknown_patient_text = pd.unknown_patient_text, reply->qual[d.seq].person_id =
   pd.person_id
   IF (per.person_id > 0)
    reply->qual[d.seq].name_full_formatted = per.name_full_formatted
   ENDIF
   reply->qual[d.seq].encntr_id = pe.encntr_id
  WITH nocounter, outerjoin(d_per)
 ;end select
 SET count1 += 1
 IF (mod(count1,10)=1
  AND count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,(count1+ 9))
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "bbt_get_patient_dispense"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "patient_dispense"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get all requested patient_dispense rows"
 ELSEIF (qual_cnt != event_cnt)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "bbt_get_patient_dispense"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "patient_dispense"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get all requested patient_dispense rows"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "bbt_get_patient_dispense"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "patient_dispense"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "all requested patient_dispense rows retrieved"
 ENDIF
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status != "S")
  AND (reply->status_data.status != "F"))
  SET count1 += 1
  IF (mod(count1,10)=1
   AND count1 != 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 9))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "bbt_get_patient_dispense"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "patient_dispense"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "unknown script failure, refer to server generated messages"
 ENDIF
 FOR (x = 1 TO count1)
   CALL echo(build("reply->status_data->status =",reply->status_data.status))
   CALL echo(reply->status_data.status)
   CALL echo(reply->status_data.subeventstatus[x].operationname)
   CALL echo(reply->status_data.subeventstatus[x].operationstatus)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectname)
   CALL echo(reply->status_data.subeventstatus[x].targetobjectvalue)
   CALL echo(build("size reqly->qual =",size(reply->qual,5)))
 ENDFOR
END GO
