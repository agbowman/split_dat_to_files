CREATE PROGRAM bed_ens_prsnl_specialty_reltn:dba
 RECORD reqcopy(
   1 provider_specialties[*]
     2 action_flag = i2
     2 prsnl_id = f8
     2 specialty_cd = f8
     2 locked_primary_specialty_cd = f8
     2 primary_ind = i2
     2 orig_primary_ind = i2
     2 orig_active_ind = i2
     2 rel_primary_key = f8
     2 rel_original_key = f8
     2 begin_date = dq8
     2 end_date = dq8
     2 specific_locations[*]
       3 location_cd = f8
     2 locations[*]
       3 location_cd = f8
       3 location_primary_key = f8
       3 location_original_key = f8
       3 action_flag = i2
       3 orig_active_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD add_reference_entity(
   1 entity[*]
     2 entity_id = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE fail = i2 WITH protect, constant(0)
 DECLARE success = i2 WITH protect, constant(1)
 DECLARE max_validity = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE status_flag = i2 WITH protect, noconstant(fail)
 DECLARE req_size = i4 WITH protect, noconstant(size(request->provider_specialties,5))
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE unique_id_counter = i4 WITH protect, noconstant(0)
 DECLARE unique_id_index = i4 WITH protect, noconstant(0)
 DECLARE validateandcopyrequest() = i2
 DECLARE lockprimaryspecialty() = i2
 DECLARE getversioningdataandsetuplocationupdates() = i2
 DECLARE validateprimaryspecialty() = i2
 DECLARE performupdates() = null
 DECLARE logdebugmessage(operation_name=vc,status=i2,name=vc,message=vc) = null
 DECLARE setuplocations() = null
 DECLARE generateuniqueids() = i2
 DECLARE updatelocations(index=i4) = null
 DECLARE addproviderspecialty(index=i4,primary_ind=i2,active_ind=i2) = null
 DECLARE modifyproviderspecialty(index=i4,primary_ind=i2,active_ind=i2) = null
 DECLARE addlocationentity(rel_index=i4,loc_index=i4,active_ind=i2) = null
 DECLARE modifylocationentity(rel_index=i4,loc_index=i4,active_ind=i2) = null
 SET status_flag = validateandcopyrequest(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SET status_flag = lockprimaryspecialty(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SET status_flag = getversioningdataandsetuplocationupdates(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SET status_flag = generateuniqueids(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 CALL performupdates(null)
 SET status_flag = validateprimaryspecialty(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SUBROUTINE logdebugmessage(operation_name,status,name,message)
   SET reply->status_data.subeventstatus[1].operationname = operation_name
   IF (status=fail)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationstatus = "S"
   ENDIF
   SET reply->status_data.subeventstatus[1].targetobjectname = name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = message
 END ;Subroutine
 SUBROUTINE validateandcopyrequest(null)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE loc_index = i4 WITH protect, noconstant(0)
   DECLARE action_flag = i4 WITH protect, noconstant(0)
   DECLARE loc_size = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reqcopy->provider_specialties,req_size)
   FOR (index = 1 TO req_size)
     IF ((((request->provider_specialties[index].action_flag < 1)) OR ((((request->
     provider_specialties[index].action_flag > 3)) OR ((((request->provider_specialties[index].
     prsnl_id <= 0.0)) OR ((request->provider_specialties[index].specialty_cd <= 0.0))) )) )) )
      CALL logdebugmessage("ENS",fail,"validateAndCopyRequest","Request contains invalid values")
      RETURN(fail)
     ELSE
      SET unique_id_counter = (unique_id_counter+ 1)
      SET reqcopy->provider_specialties[index].action_flag = request->provider_specialties[index].
      action_flag
      SET reqcopy->provider_specialties[index].prsnl_id = request->provider_specialties[index].
      prsnl_id
      SET reqcopy->provider_specialties[index].primary_ind = request->provider_specialties[index].
      primary_ind
      SET reqcopy->provider_specialties[index].specialty_cd = request->provider_specialties[index].
      specialty_cd
      SET loc_size = size(request->provider_specialties[index].specific_locations,5)
      SET stat = alterlist(reqcopy->provider_specialties[index].specific_locations,loc_size)
      FOR (loc_index = 1 TO loc_size)
        IF ((request->provider_specialties[index].specific_locations[loc_index].location_cd <= 0.0))
         CALL logdebugmessage("ENS",fail,"validateAndCopyRequest",
          "Request contains invalid location values")
         RETURN(fail)
        ELSE
         SET reqcopy->provider_specialties[index].specific_locations[loc_index].location_cd = request
         ->provider_specialties[index].specific_locations[loc_index].location_cd
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL logdebugmessage("ENS",success,"validateAndCopyRequest","Leaving validateAndCopyRequest")
   RETURN(success)
 END ;Subroutine
 SUBROUTINE lockprimaryspecialty(null)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(1)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE z_index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_specialty_reltn psr
    PLAN (psr
     WHERE expand(z_index,1,req_size,psr.prsnl_id,reqcopy->provider_specialties[z_index].prsnl_id)
      AND psr.prsnl_specialty_reltn_id=psr.orig_prsnl_specialty_reltn_id
      AND psr.primary_ind=1
      AND psr.active_ind=1)
    ORDER BY psr.prsnl_id
    HEAD REPORT
     start = 1
    DETAIL
     pos = locateval(index,start,req_size,psr.prsnl_id,reqcopy->provider_specialties[index].prsnl_id)
     WHILE (pos > 0)
       start = (pos+ 1), reqcopy->provider_specialties[pos].locked_primary_specialty_cd = psr
       .specialty_cd, pos = locateval(index,start,req_size,psr.prsnl_id,reqcopy->
        provider_specialties[index].prsnl_id)
     ENDWHILE
    WITH nocounter, forupdate(psr)
   ;end select
   IF (error(error_msg,1))
    CALL logdebugmessage("ENS",fail,"lockPrimarySpecialty",error_msg)
    RETURN(fail)
   ENDIF
   CALL logdebugmessage("ENS",success,"lockPrimarySpecialty","Leaving lockPrimarySpecialty")
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getversioningdataandsetuplocationupdates(null)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE loc_index = i4 WITH protect, noconstant(0)
   DECLARE z_index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_specialty_reltn psr,
     prsnl_specialty_loc_reltn pslr
    PLAN (psr
     WHERE expand(z_index,1,req_size,psr.prsnl_id,reqcopy->provider_specialties[z_index].prsnl_id,
      psr.specialty_cd,reqcopy->provider_specialties[z_index].specialty_cd)
      AND psr.prsnl_specialty_reltn_id=psr.orig_prsnl_specialty_reltn_id)
     JOIN (pslr
     WHERE outerjoin(psr.prsnl_specialty_reltn_id)=pslr.prsnl_specialty_reltn_id
      AND pslr.beg_effective_dt_tm < outerjoin(cnvtdatetime(cur_dt_tm))
      AND pslr.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm)))
    ORDER BY psr.prsnl_id, psr.specialty_cd, pslr.location_cd
    HEAD psr.prsnl_id
     pos = 0
    HEAD psr.specialty_cd
     pos = locateval(index,1,req_size,psr.prsnl_id,reqcopy->provider_specialties[index].prsnl_id,
      psr.specialty_cd,reqcopy->provider_specialties[index].specialty_cd), reqcopy->
     provider_specialties[pos].orig_primary_ind = psr.primary_ind, reqcopy->provider_specialties[pos]
     .orig_active_ind = psr.active_ind,
     reqcopy->provider_specialties[pos].rel_primary_key = psr.prsnl_specialty_reltn_id, reqcopy->
     provider_specialties[pos].rel_original_key = psr.orig_prsnl_specialty_reltn_id, reqcopy->
     provider_specialties[pos].begin_date = psr.beg_effective_dt_tm,
     reqcopy->provider_specialties[pos].end_date = psr.end_effective_dt_tm, loc_index = 0
    DETAIL
     IF (pslr.location_cd > 0.0)
      loc_index = (loc_index+ 1), stat = alterlist(reqcopy->provider_specialties[pos].locations,
       loc_index), reqcopy->provider_specialties[pos].locations[loc_index].location_cd = pslr
      .location_cd,
      reqcopy->provider_specialties[pos].locations[loc_index].location_primary_key = pslr
      .prsnl_specialty_loc_reltn_id, reqcopy->provider_specialties[pos].locations[loc_index].
      location_original_key = pslr.orig_prsnl_specialty_loc_r_id, reqcopy->provider_specialties[pos].
      locations[loc_index].beg_effective_dt_tm = pslr.beg_effective_dt_tm,
      reqcopy->provider_specialties[pos].locations[loc_index].end_effective_dt_tm = pslr
      .end_effective_dt_tm, reqcopy->provider_specialties[pos].locations[loc_index].orig_active_ind
       = pslr.active_ind
     ENDIF
    WITH nocounter
   ;end select
   IF (error(error_msg,1))
    CALL logdebugmessage("ENS",fail,"getVersioningDataAndSetupLocationUpdates",error_msg)
    RETURN(fail)
   ENDIF
   CALL setuplocations(null)
   CALL logdebugmessage("ENS",success,"getVersioningDataAndSetupLocationUpdates",
    "Leaving getVersioningDataAndSetupLocationUpdates")
   RETURN(success)
 END ;Subroutine
 SUBROUTINE validateprimaryspecialty(null)
   DECLARE primary_cnt = i2 WITH protect, noconstant(0)
   DECLARE primary_err = i2 WITH protect, noconstant(0)
   DECLARE z_index = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_specialty_reltn psr,
     prsnl_specialty_reltn psr2
    PLAN (psr
     WHERE expand(z_index,1,req_size,psr.prsnl_id,reqcopy->provider_specialties[z_index].prsnl_id)
      AND psr.prsnl_specialty_reltn_id=psr.orig_prsnl_specialty_reltn_id
      AND psr.active_ind=1)
     JOIN (psr2
     WHERE psr2.prsnl_id=outerjoin(psr.prsnl_id)
      AND psr2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(cur_dt_tm))
      AND psr2.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm))
      AND psr2.primary_ind=outerjoin(1)
      AND psr2.active_ind=outerjoin(1))
    ORDER BY psr.prsnl_id, psr.specialty_cd
    HEAD psr.prsnl_id
     primary_cnt = 0
    HEAD psr.specialty_cd
     primary_cnt = 0
    DETAIL
     primary_cnt = (primary_cnt+ psr2.primary_ind)
    FOOT  psr.specialty_cd
     IF (primary_cnt != 1)
      primary_err = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (((error(error_msg,1)) OR (primary_err=1)) )
    IF (primary_err=1)
     SET error_msg = "Found none or more than one primary specialties"
    ENDIF
    CALL logdebugmessage("ENS",fail,"validatePrimarySpecialty",error_msg)
    RETURN(fail)
   ENDIF
   CALL logdebugmessage("ENS",success,"validatePrimarySpecialty",
    "All updates completed successfully and were validated")
   RETURN(success)
 END ;Subroutine
 SUBROUTINE setuplocations(null)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE z_index = i4 WITH protect, noconstant(0)
   DECLARE loc_index = i4 WITH protect, noconstant(0)
   DECLARE specific_locations_size = i4 WITH protect, noconstant(0)
   FOR (index = 1 TO req_size)
     SET specific_locations_size = size(reqcopy->provider_specialties[index].specific_locations,5)
     FOR (idx = 1 TO specific_locations_size)
      SET pos = locateval(z_index,1,size(reqcopy->provider_specialties[index].locations,5),reqcopy->
       provider_specialties[index].specific_locations[idx].location_cd,reqcopy->provider_specialties[
       index].locations[z_index].location_cd)
      IF (pos=0)
       SET unique_id_counter = (unique_id_counter+ 1)
       SET loc_index = (size(reqcopy->provider_specialties[index].locations,5)+ 1)
       SET stat = alterlist(reqcopy->provider_specialties[index].locations,loc_index)
       SET reqcopy->provider_specialties[index].locations[loc_index].location_cd = reqcopy->
       provider_specialties[index].specific_locations[idx].location_cd
       SET reqcopy->provider_specialties[index].locations[loc_index].action_flag = 1
      ELSEIF ((reqcopy->provider_specialties[index].locations[pos].orig_active_ind=0))
       SET unique_id_counter = (unique_id_counter+ 1)
       SET reqcopy->provider_specialties[index].locations[pos].action_flag = 1
      ENDIF
     ENDFOR
     FOR (idx = 1 TO size(reqcopy->provider_specialties[index].locations,5))
      SET pos = locateval(z_index,1,specific_locations_size,reqcopy->provider_specialties[index].
       locations[idx].location_cd,reqcopy->provider_specialties[index].specific_locations[z_index].
       location_cd)
      IF (pos=0
       AND (reqcopy->provider_specialties[index].locations[idx].orig_active_ind=1))
       SET unique_id_counter = (unique_id_counter+ 1)
       SET reqcopy->provider_specialties[index].locations[idx].action_flag = 3
      ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE generateuniqueids(index)
   EXECUTE dm2_dar_get_bulk_seq "ADD_REFERENCE_ENTITY->ENTITY", unique_id_counter, "ENTITY_ID",
   1, "REFERENCE_SEQ"
   IF ((m_dm2_seq_stat->n_status != 1))
    CALL logdebugmessage("GET",fail,"DM2_DAR_GET_BULK_SEQ",concat("Sequence retrieval error: ",
      m_dm2_seq_stat->s_error_msg," ERROR ENCOUNTERED IN DM2_DAR_GET_BULK_SEQ (REFERENCE_SEQ)"))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE index = i4 WITH protect, noconstant(0)
   FOR (index = 1 TO req_size)
    IF ((reqcopy->provider_specialties[index].action_flag=1))
     IF ((reqcopy->provider_specialties[index].rel_original_key > 0.0))
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].rel_primary_key = add_reference_entity->entity[
      unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].end_date = cur_dt_tm
      CALL addproviderspecialty(index,reqcopy->provider_specialties[index].orig_primary_ind,reqcopy->
       provider_specialties[index].orig_active_ind)
      CALL modifyproviderspecialty(index,reqcopy->provider_specialties[index].primary_ind,1)
     ELSE
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].rel_primary_key = add_reference_entity->entity[
      unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].rel_original_key = add_reference_entity->entity[
      unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].begin_date = cur_dt_tm
      SET reqcopy->provider_specialties[index].end_date = max_validity
      CALL addproviderspecialty(index,reqcopy->provider_specialties[index].primary_ind,1)
     ENDIF
    ELSEIF ((reqcopy->provider_specialties[index].action_flag=2))
     IF ((((reqcopy->provider_specialties[index].rel_original_key <= 0.0)) OR ((reqcopy->
     provider_specialties[index].orig_active_ind=0))) )
      CALL logdebugmessage("MOD",fail,"performUpdates","Relationship not found. ")
      RETURN(fail)
     ENDIF
     IF ((reqcopy->provider_specialties[index].primary_ind != reqcopy->provider_specialties[index].
     orig_primary_ind))
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].rel_primary_key = add_reference_entity->entity[
      unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].end_date = cur_dt_tm
      CALL addproviderspecialty(index,reqcopy->provider_specialties[index].orig_primary_ind,reqcopy->
       provider_specialties[index].orig_active_ind)
      CALL modifyproviderspecialty(index,reqcopy->provider_specialties[index].primary_ind,1)
     ENDIF
    ELSEIF ((reqcopy->provider_specialties[index].action_flag != 3))
     CALL logdebugmessage("ENS",fail,"performUpdates","Invalid entry.")
     RETURN(fail)
    ENDIF
    CALL updatelocations(index)
   ENDFOR
   FOR (index = 1 TO req_size)
     IF ((reqcopy->provider_specialties[index].action_flag=3))
      IF ((reqcopy->provider_specialties[index].rel_primary_key <= 0.0))
       CALL logdebugmessage("MOD",fail,"performUpdates","Relationship not found.")
       RETURN(fail)
      ENDIF
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].rel_primary_key = add_reference_entity->entity[
      unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].end_date = cur_dt_tm
      CALL addproviderspecialty(index,reqcopy->provider_specialties[index].orig_primary_ind,reqcopy->
       provider_specialties[index].orig_active_ind)
      CALL modifyproviderspecialty(index,reqcopy->provider_specialties[index].orig_primary_ind,0)
     ENDIF
   ENDFOR
   CALL logdebugmessage("ENS",success,"performUpdates","Leaving performUpdates")
 END ;Subroutine
 SUBROUTINE updatelocations(index)
  DECLARE loc_index = i4 WITH protect, noconstant(0)
  FOR (loc_index = 1 TO size(reqcopy->provider_specialties[index].locations,5))
    IF ((reqcopy->provider_specialties[index].locations[loc_index].action_flag=1))
     IF ((reqcopy->provider_specialties[index].locations[loc_index].location_original_key > 0.0))
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].locations[loc_index].end_effective_dt_tm = cur_dt_tm
      SET reqcopy->provider_specialties[index].locations[loc_index].location_primary_key =
      add_reference_entity->entity[unique_id_index].entity_id
      CALL addlocationentity(index,loc_index,reqcopy->provider_specialties[index].locations[loc_index
       ].orig_active_ind)
      CALL modifylocationentity(index,loc_index,1)
     ELSE
      SET unique_id_index = (unique_id_index+ 1)
      SET reqcopy->provider_specialties[index].locations[loc_index].beg_effective_dt_tm = cur_dt_tm
      SET reqcopy->provider_specialties[index].locations[loc_index].end_effective_dt_tm =
      max_validity
      SET reqcopy->provider_specialties[index].locations[loc_index].location_original_key =
      add_reference_entity->entity[unique_id_index].entity_id
      SET reqcopy->provider_specialties[index].locations[loc_index].location_primary_key =
      add_reference_entity->entity[unique_id_index].entity_id
      CALL addlocationentity(index,loc_index,1)
     ENDIF
    ELSEIF ((reqcopy->provider_specialties[index].locations[loc_index].action_flag=3))
     SET unique_id_index = (unique_id_index+ 1)
     SET reqcopy->provider_specialties[index].locations[loc_index].end_effective_dt_tm = cur_dt_tm
     SET reqcopy->provider_specialties[index].locations[loc_index].location_primary_key =
     add_reference_entity->entity[unique_id_index].entity_id
     CALL addlocationentity(index,loc_index,reqcopy->provider_specialties[index].locations[loc_index]
      .orig_active_ind)
     CALL modifylocationentity(index,loc_index,0)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addproviderspecialty(index,primary_ind,active_ind)
  INSERT  FROM prsnl_specialty_reltn psr
   SET psr.prsnl_specialty_reltn_id = reqcopy->provider_specialties[index].rel_primary_key, psr
    .orig_prsnl_specialty_reltn_id = reqcopy->provider_specialties[index].rel_original_key, psr
    .prsnl_id = reqcopy->provider_specialties[index].prsnl_id,
    psr.specialty_cd = reqcopy->provider_specialties[index].specialty_cd, psr.primary_ind =
    primary_ind, psr.active_ind = active_ind,
    psr.beg_effective_dt_tm = cnvtdatetime(reqcopy->provider_specialties[index].begin_date), psr
    .end_effective_dt_tm = cnvtdatetime(reqcopy->provider_specialties[index].end_date), psr
    .updt_dt_tm = cnvtdatetime(cur_dt_tm),
    psr.updt_id = reqinfo->updt_id, psr.updt_task = reqinfo->updt_task, psr.updt_applctx = reqinfo->
    updt_applctx
   PLAN (psr)
   WITH nocounter
  ;end insert
  IF (error(error_msg,1))
   CALL logdebugmessage("ADD",fail,"addProviderSpecialty()",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE modifyproviderspecialty(index,primary_ind,active_ind)
  UPDATE  FROM prsnl_specialty_reltn psr
   SET psr.active_ind = active_ind, psr.primary_ind = primary_ind, psr.beg_effective_dt_tm =
    cnvtdatetime(cur_dt_tm),
    psr.end_effective_dt_tm = cnvtdatetime(max_validity), psr.updt_cnt = (psr.updt_cnt+ 1), psr
    .updt_dt_tm = cnvtdatetime(cur_dt_tm),
    psr.updt_id = reqinfo->updt_id, psr.updt_task = reqinfo->updt_task, psr.updt_applctx = reqinfo->
    updt_applctx
   PLAN (psr
    WHERE (psr.prsnl_specialty_reltn_id=reqcopy->provider_specialties[index].rel_original_key))
   WITH nocounter
  ;end update
  IF (error(error_msg,1))
   CALL logdebugmessage("ADD",fail,"modifyProviderSpecialty()",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE addlocationentity(rel_index,loc_index,active_ind)
  INSERT  FROM prsnl_specialty_loc_reltn pslr
   SET pslr.prsnl_specialty_reltn_id = reqcopy->provider_specialties[rel_index].rel_original_key,
    pslr.location_cd = reqcopy->provider_specialties[rel_index].locations[loc_index].location_cd,
    pslr.active_ind = active_ind,
    pslr.orig_prsnl_specialty_loc_r_id = reqcopy->provider_specialties[rel_index].locations[loc_index
    ].location_original_key, pslr.prsnl_specialty_loc_reltn_id = reqcopy->provider_specialties[
    rel_index].locations[loc_index].location_primary_key, pslr.beg_effective_dt_tm = cnvtdatetime(
     reqcopy->provider_specialties[rel_index].locations[loc_index].beg_effective_dt_tm),
    pslr.end_effective_dt_tm = cnvtdatetime(reqcopy->provider_specialties[rel_index].locations[
     loc_index].end_effective_dt_tm), pslr.updt_dt_tm = cnvtdatetime(cur_dt_tm), pslr.updt_id =
    reqinfo->updt_id,
    pslr.updt_task = reqinfo->updt_task, pslr.updt_applctx = reqinfo->updt_applctx
   PLAN (pslr)
   WITH nocounter
  ;end insert
  IF (error(error_msg,1))
   CALL logdebugmessage("ADD",fail,"addLocationEntity()",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE modifylocationentity(rel_index,loc_index,active_ind)
  UPDATE  FROM prsnl_specialty_loc_reltn pslr
   SET pslr.active_ind = active_ind, pslr.beg_effective_dt_tm = cnvtdatetime(cur_dt_tm), pslr
    .updt_cnt = (pslr.updt_cnt+ 1),
    pslr.updt_dt_tm = cnvtdatetime(cur_dt_tm), pslr.updt_id = reqinfo->updt_id, pslr.updt_task =
    reqinfo->updt_task,
    pslr.updt_applctx = reqinfo->updt_applctx
   PLAN (pslr
    WHERE (pslr.prsnl_specialty_loc_reltn_id=reqcopy->provider_specialties[rel_index].locations[
    loc_index].location_original_key))
   WITH nocounter
  ;end update
  IF (error(error_msg,1))
   CALL logdebugmessage("ADD",fail,"modifyLocationEntity()",error_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF (status_flag=success)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
