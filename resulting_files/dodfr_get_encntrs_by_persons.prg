CREATE PROGRAM dodfr_get_encntrs_by_persons
 RECORD reply(
   1 person_qual[*]
     2 person_id = f8
     2 encntr_qual[*]
       3 encntr_id = f8
       3 create_dt_tm = dq8
       3 encntr_complete_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE populatepersons(null) = null
 DECLARE populateencounters(null) = null
 DECLARE person_count = i2 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE encounter_count = i2 WITH public, noconstant(0)
 DECLARE temp_seq = i2 WITH public, noconstant(0)
 IF (size(request->qual,5) > 0)
  CALL populatepersons(null)
  CALL populateencounters(null)
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE populatepersons(null)
   DECLARE person_list_size = i4 WITH noconstant(0)
   SET person_list_size = size(request->qual,5)
   SET stat = alterlist(reply->person_qual,person_list_size)
   FOR (i = 1 TO person_list_size)
     SET reply->person_qual[i].person_id = request->qual[i].person_id
   ENDFOR
 END ;Subroutine
 SUBROUTINE populateencounters(null)
  SELECT INTO "nl:"
   FROM encounter e,
    (dummyt d  WITH seq = size(request->qual,5))
   PLAN (d)
    JOIN (e
    WHERE (e.person_id=request->qual[d.seq].person_id))
   DETAIL
    IF (d.seq > temp_seq)
     IF (encounter_count > 0)
      stat = alterlist(reply->person_qual[temp_seq].encntr_qual,encounter_count)
     ENDIF
     temp_seq = d.seq, encounter_count = 0
    ENDIF
    encounter_count = (encounter_count+ 1)
    IF (encounter_count > size(reply->person_qual[d.seq].encntr_qual,5))
     stat = alterlist(reply->person_qual[d.seq].encntr_qual,(encounter_count+ 9))
    ENDIF
    reply->person_qual[d.seq].encntr_qual[encounter_count].encntr_id = e.encntr_id, reply->
    person_qual[d.seq].encntr_qual[encounter_count].create_dt_tm = e.create_dt_tm, reply->
    person_qual[d.seq].encntr_qual[encounter_count].encntr_complete_dt_tm = e.encntr_complete_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->person_qual[temp_seq].encntr_qual,encounter_count)
 END ;Subroutine
END GO
