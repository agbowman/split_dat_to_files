CREATE PROGRAM dm_combine_in_process:dba
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 new_person_id = f8
   1 new_encntr_id = f8
   1 valid_person_ind = i2
   1 valid_encntr_ind = i2
   1 person_encntr_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cip_data
 RECORD cip_data(
   1 person_active_ind = i2
   1 encntr_active_ind = i2
   1 temp_entity_id = f8
   1 new_entity_id = f8
   1 entity[*]
     2 id = f8
   1 cnt = i4
 )
 SET cip_data->cnt = 0
 SET stat = alterlist(cip_data->entity,0)
 SET cip_data->person_active_ind = 0
 SET cip_data->encntr_active_ind = 0
 SET cip_data->temp_entity_id = 0
 SET cip_data->new_entity_id = 0
 SET reply->status_data.status = "F"
 SET reply->person_id = request->person_id
 SET reply->encntr_id = request->encntr_id
 SET reply->valid_person_ind = 0
 SET reply->new_person_id = 0
 SET reply->valid_encntr_ind = 0
 SET reply->new_encntr_id = 0
 SET reply->person_encntr_match_ind = 0
 IF ((request->person_id <= 0))
  CALL cip_set_status("F","Check person_id","F","request->person_id",cnvtstring(request->person_id))
  GO TO exit_script
 ENDIF
 SET reply->valid_person_ind = cip_chk_person_validity(request->person_id)
 IF ((reply->valid_person_ind=0))
  SET reply->new_person_id = cip_get_cmb_person_id(request->person_id)
 ENDIF
 IF ((request->encntr_id > 0))
  SET reply->valid_encntr_ind = cip_chk_encntr_validity(request->encntr_id)
  IF ((reply->valid_encntr_ind=0))
   SET reply->new_encntr_id = cip_get_cmb_encntr_id(request->encntr_id)
  ENDIF
 ENDIF
 IF ((reply->valid_person_ind=1)
  AND (reply->valid_encntr_ind=1))
  SET reply->person_encntr_match_ind = cip_chk_person_enctr_match(request->person_id,request->
   encntr_id)
  IF ((reply->person_encntr_match_ind=0))
   SET reply->new_person_id = cip_get_person_for_encntr(request->encntr_id)
  ENDIF
 ENDIF
 CALL cip_set_status("S"," "," "," "," ")
 SUBROUTINE cip_chk_person_validity(cpa_pid)
  SELECT INTO "nl:"
   FROM person p
   WHERE p.person_id=cpa_pid
    AND p.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE cip_chk_encntr_validity(cea_eid)
  SELECT INTO "nl:"
   FROM encounter e
   WHERE e.encntr_id=cea_eid
    AND e.active_ind=1
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE cip_get_cmb_person_id(gcp_pid)
   SET cip_data->temp_entity_id = 0
   SET cip_data->cnt = 0
   SET stat = alterlist(cip_data->entity,0)
   SELECT INTO "nl:"
    FROM person_combine pc,
     person p
    PLAN (pc
     WHERE pc.from_person_id=gcp_pid
      AND pc.encntr_id=0
      AND pc.active_ind=1)
     JOIN (p
     WHERE p.person_id=pc.from_person_id
      AND p.active_ind=0)
    ORDER BY pc.updt_dt_tm DESC
    DETAIL
     cip_data->temp_entity_id = pc.to_person_id
    WITH nocounter, maxread(pc,1)
   ;end select
   IF (curqual)
    SET cip_data->cnt = 1
    SET stat = alterlist(cip_data->entity,1)
    SET cip_data->entity[1].id = gcp_pid
    SET cfe_looping_flag = 0
    WHILE ((cip_data->temp_entity_id > 0)
     AND  NOT (cfe_looping_flag))
      SET cip_data->cnt += 1
      SET stat = alterlist(cip_data->entity,cip_data->cnt)
      SET cip_data->entity[cip_data->cnt].id = cip_data->temp_entity_id
      SET cip_data->temp_entity_id = 0
      SELECT INTO "nl:"
       FROM person_combine pc
       PLAN (pc
        WHERE (pc.from_person_id=cip_data->entity[cip_data->cnt].id)
         AND pc.encntr_id=0
         AND pc.active_ind=1)
       ORDER BY pc.updt_dt_tm DESC
       DETAIL
        cip_data->temp_entity_id = pc.to_person_id
       WITH nocounter, maxread(pc,1)
      ;end select
      IF (curqual)
       FOR (cfe_i = 1 TO cip_data->cnt)
         IF ((cip_data->temp_entity_id=cip_data->entity[cfe_i].id))
          SET cfe_looping_flag = 1
          SET cfe_i = cip_data->cnt
         ENDIF
       ENDFOR
      ENDIF
    ENDWHILE
   ENDIF
   IF ((cip_data->cnt > 0))
    RETURN(cip_data->entity[cip_data->cnt].id)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE cip_get_cmb_encntr_id(gce_eid)
   SET cip_data->temp_entity_id = 0
   SET cip_data->cnt = 0
   SET stat = alterlist(cip_data->entity,0)
   SELECT INTO "nl:"
    FROM encntr_combine ec,
     encounter e
    PLAN (ec
     WHERE ec.from_encntr_id=gce_eid
      AND ec.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=ec.from_encntr_id
      AND e.active_ind=0)
    ORDER BY ec.updt_dt_tm DESC
    DETAIL
     cip_data->temp_entity_id = ec.to_encntr_id
    WITH nocounter, maxread(ec,1)
   ;end select
   IF (curqual)
    SET cip_data->cnt = 1
    SET stat = alterlist(cip_data->entity,1)
    SET cip_data->entity[1].id = gce_eid
    SET cfe_looping_flag = 0
    WHILE ((cip_data->temp_entity_id > 0)
     AND  NOT (cfe_looping_flag))
      SET cip_data->cnt += 1
      SET stat = alterlist(cip_data->entity,cip_data->cnt)
      SET cip_data->entity[cip_data->cnt].id = cip_data->temp_entity_id
      SET cip_data->temp_entity_id = 0
      SELECT INTO "nl:"
       FROM encntr_combine ec
       PLAN (ec
        WHERE (ec.from_encntr_id=cip_data->entity[cip_data->cnt].id)
         AND ec.active_ind=1)
       ORDER BY ec.updt_dt_tm DESC
       DETAIL
        cip_data->temp_entity_id = ec.to_encntr_id
       WITH nocounter, maxread(ec,1)
      ;end select
      IF (curqual)
       FOR (cfe_i = 1 TO cip_data->cnt)
         IF ((cip_data->temp_entity_id=cip_data->entity[cfe_i].id))
          SET cfe_looping_flag = 1
          SET cfe_i = cip_data->cnt
         ENDIF
       ENDFOR
      ENDIF
    ENDWHILE
   ENDIF
   IF ((cip_data->cnt > 0))
    RETURN(cip_data->entity[cip_data->cnt].id)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE cip_chk_person_enctr_match(pem_pid,pem_eid)
   SET pem_person_id = 0.0
   SET pem_person_id = cip_get_person_for_encntr(pem_eid)
   IF (pem_person_id=pem_pid)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE cip_get_person_for_encntr(pfe_eid)
   SET pfe_person_id = 0.0
   SELECT INTO "nl:"
    e.person_id
    FROM encounter e
    WHERE e.encntr_id=pfe_eid
    DETAIL
     pfe_person_id = e.person_id
    WITH nocounter
   ;end select
   RETURN(pfe_person_id)
 END ;Subroutine
 SUBROUTINE cip_set_status(css_stat,css_op,css_op_stat,css_obj,css_obj_val)
   SET reply->status_data.status = substring(1,1,css_stat)
   SET reply->status_data.subeventstatus[1].operationname = substring(1,25,css_op)
   SET reply->status_data.subeventstatus[1].operationstatus = substring(1,1,css_op_stat)
   SET reply->status_data.subeventstatus[1].targetobjectname = substring(1,25,css_obj)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = css_obj_val
 END ;Subroutine
#exit_script
END GO
