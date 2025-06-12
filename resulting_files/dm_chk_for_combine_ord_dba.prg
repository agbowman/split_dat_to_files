CREATE PROGRAM dm_chk_for_combine_ord:dba
 RECORD reply(
   1 personid = f8
   1 encntrid = f8
   1 error_message = c132
   1 orderlist[*]
     2 encntrid = f8
     2 error_message = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE program_version = vc WITH private, constant("003")
 DECLARE enc_size = i4 WITH noconstant(0)
 SET enc_size = size(request->orderlist,5)
 SET stat = alterlist(reply->orderlist,enc_size)
 SET reply->status_data.status = "S"
 SET reply->personid = request->personid
 SET reply->encntrid = request->encntrid
 FOR (dm_cnt = 1 TO enc_size)
   SET reply->orderlist[dm_cnt].encntrid = request->orderlist[dm_cnt].encntrid
 ENDFOR
 CALL echo("reply - before processing")
 CALL echo(concat("reply->personId = ",cnvtstring(reply->personid)))
 CALL echo(concat("reply->encntrId = ",cnvtstring(reply->encntrid)))
 FOR (x = 1 TO enc_size)
   CALL echo(build("orderlist->encntr_id",cnvtstring(x)," = ",reply->orderlist[x].encntrid))
 ENDFOR
 CALL echo(" ")
 DECLARE top_level_encntr_id_found = i1 WITH noconstant(false)
 DECLARE top_level_encntr_active_ind = i2 WITH noconstant(0)
 DECLARE encntr_found_in_combine = i1 WITH noconstant(false)
#dm_chk_top_encntr
 IF ((reply->encntrid != 0))
  SET top_level_encntr_id_found = false
  SET top_level_encntr_active_ind = 0
  SELECT INTO "nl:"
   e.encntr_id
   FROM encounter e
   WHERE (e.encntr_id=reply->encntrid)
   DETAIL
    top_level_encntr_id_found = true, top_level_encntr_active_ind = e.active_ind
   WITH nocounter
  ;end select
  IF (top_level_encntr_id_found=false)
   SET reply->status_data.status = "F"
   SET reply->error_message = concat("EncntrId ",trim(cnvtstring(reply->encntrid))," does not exist."
    )
   GO TO end_dm_chk_top_encntr
  ELSEIF (top_level_encntr_active_ind=0)
   SET encntr_found_in_combine = false
   SELECT INTO "nl:"
    ec.to_encntr_id
    FROM encntr_combine ec
    WHERE (ec.from_encntr_id=reply->encntrid)
    DETAIL
     reply->encntrid = ec.to_encntr_id, encntr_found_in_combine = true
    WITH nocounter
   ;end select
   IF (encntr_found_in_combine=false)
    GO TO end_dm_chk_top_encntr
   ELSE
    GO TO dm_chk_top_encntr
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   e.person_id
   FROM encounter e
   WHERE e.active_ind=1
    AND (e.encntr_id=reply->encntrid)
   DETAIL
    reply->personid = e.person_id
   WITH nocounter
  ;end select
  DECLARE dm_active_person_cnt1 = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   p.person_id
   FROM person p
   WHERE p.active_ind=1
    AND (p.person_id=reply->personid)
   DETAIL
    dm_active_person_cnt1 += 1
   WITH nocounter
  ;end select
  IF (dm_active_person_cnt1=0)
   SET reply->status_data.status = "F"
   SET reply->error_message = concat("PersonId ",trim(cnvtstring(reply->personid))," is inactive.")
  ENDIF
 ENDIF
#end_dm_chk_top_encntr
 CALL echo("reply - after processing top level")
 CALL echo(concat("reply->personId = ",cnvtstring(reply->personid)))
 CALL echo(concat("reply->encntrId = ",cnvtstring(reply->encntrid)))
 CALL echo(concat("reply->error_message = ",reply->error_message))
 CALL echo(concat("Status = ",reply->status_data.status))
 DECLARE order_level_encntr_found = i1 WITH noconstant(false)
 DECLARE order_level_active_ind = i4 WITH noconstant(0)
 DECLARE order_level_encntr_found_in_combine = i1 WITH noconstant(false)
 DECLARE start_encntr_index = i4 WITH protect, noconstant(1)
#dm_chk_encntr_list
 FOR (current_encntr_index = start_encntr_index TO enc_size)
   IF ((reply->orderlist[start_encntr_index].encntrid=0))
    GO TO end_dm_chk_encntr_list
   ENDIF
   SET order_level_encntr_found = false
   SET order_level_active_ind = 0
   SELECT INTO "nl:"
    e.encntr_id
    FROM encounter e
    WHERE (e.encntr_id=reply->orderlist[current_encntr_index].encntrid)
    DETAIL
     order_level_encntr_found = true, order_level_active_ind = e.active_ind
    WITH nocounter
   ;end select
   IF (order_level_encntr_found=false)
    SET reply->status_data.status = "P"
    SET reply->orderlist[current_encntr_index].error_message = concat("EncntrId ",trim(cnvtstring(
       reply->orderlist[current_encntr_index].encntrid))," does not exist.")
   ELSEIF (order_level_active_ind=0)
    SET order_level_encntr_found_in_combine = false
    SELECT INTO "nl:"
     ec.to_encntr_id
     FROM encntr_combine ec
     WHERE (ec.from_encntr_id=reply->orderlist[current_encntr_index].encntrid)
     DETAIL
      reply->orderlist[current_encntr_index].encntrid = ec.to_encntr_id,
      order_level_encntr_found_in_combine = true
     WITH nocounter
    ;end select
    IF (order_level_encntr_found_in_combine=true)
     SET start_encntr_index = current_encntr_index
     GO TO dm_chk_encntr_list
    ENDIF
   ENDIF
 ENDFOR
#end_dm_chk_encntr_list
 IF (enc_size > 0
  AND (reply->orderlist[start_encntr_index].encntrid != 0))
  SELECT INTO "nl:"
   e.person_id
   FROM encounter e
   WHERE (e.encntr_id=reply->orderlist[1].encntrid)
   DETAIL
    reply->personid = e.person_id
   WITH nocounter
  ;end select
  DECLARE dm_active_person_cnt2 = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   p.person_id
   FROM person p
   WHERE p.active_ind=1
    AND (p.person_id=reply->personid)
   DETAIL
    dm_active_person_cnt2 += 1
   WITH nocounter
  ;end select
  IF (dm_active_person_cnt2=0)
   SET reply->status_data.status = "F"
   SET reply->error_message = concat("PersonId ",trim(cnvtstring(reply->personid))," is inactive.")
  ENDIF
 ENDIF
 CALL echorecord(reply)
#exit_dm_script
END GO
