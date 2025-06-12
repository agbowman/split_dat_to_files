CREATE PROGRAM dcp_get_encounters:dba
 RECORD reply(
   1 encntr_id_list[*]
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD temp_encntr_ids
 RECORD temp_encntr_ids(
   1 encntr_id_list[*]
     2 encntr_id = f8
 )
 DECLARE encntr_cnt = i4 WITH public, noconstant(0)
 SET modify = predeclare
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 SELECT INTO "n1"
  FROM encounter e
  WHERE (e.person_id=request->person_id)
  HEAD e.encntr_id
   encntr_cnt = (encntr_cnt+ 1)
   IF (mod(encntr_cnt,5)=1)
    stat = alterlist(temp_encntr_ids->encntr_id_list,(encntr_cnt+ 4))
   ENDIF
   temp_encntr_ids->encntr_id_list[encntr_cnt].encntr_id = e.encntr_id
  FOOT REPORT
   stat = alterlist(temp_encntr_ids->encntr_id_list,encntr_cnt)
 ;end select
 SET stat = alterlist(reply->encntr_id_list,encntr_cnt)
 FOR (idx = 1 TO encntr_cnt)
   SET reply->encntr_id_list[idx].encntr_id = temp_encntr_ids->encntr_id_list[idx].encntr_id
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 SET modify = nopredeclare
END GO
