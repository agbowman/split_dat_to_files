CREATE PROGRAM assist_match_tag_get_table:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 table_rec_qual = i4
    1 match_tag_rec[10]
      2 match_function_cd = f8
      2 match_field_cd = f8
      2 match_validation_cd = f8
      2 alias_entity_name = c32
      2 alias_entity_alias_type_cd = f8
    1 esi_ensure_parms_rec[10]
      2 esi_task_cd = f8
      2 contributor_system_type_cd = f8
      2 person_ensure_type_cd = f8
      2 encntr_ensure_type_cd = f8
      2 event_ensure_type_cd = f8
    1 esi_alias_translation_rec[10]
      2 esi_alias_field_cd = f8
      2 alias_entity_name = c32
      2 alias_entity_alias_type_cd = f8
      2 filter = c100
      2 trunc_size = i4
      2 skip_string = c100
    1 alias_pool_rec[10]
      2 location_cd = f8
      2 organization_id = i4
      2 alias_entity_name = c32
      2 alias_entity_alias_type_cd = f8
      2 unique_alias_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_match_tag_get_table = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET kount = 0
 IF (cnvtupper(trim(request->table_name,3))="MATCH_TAG_PARMS*")
  SET table_name = "MATCH_TAG_PARMS"
  SELECT DISTINCT INTO "NL:"
   c.*
   FROM match_tag_parms c
   WHERE (c.contributor_system_cd=request->contributor_system_cd)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->match_tag_rec,(kount+ 10))
    ENDIF
    reply->match_tag_rec[kount].match_function_cd = c.match_function_cd, reply->match_tag_rec[kount].
    match_field_cd = c.match_field_cd, reply->match_tag_rec[kount].alias_entity_name = c
    .alias_entity_name,
    reply->match_tag_rec[kount].alias_entity_alias_type_cd = c.alias_entity_alias_type_cd
   WITH nocounter
  ;end select
  SET reply->table_rec_qual = kount
  SET stat = alter(reply->match_tag_rec,kount)
 ENDIF
 IF (cnvtupper(trim(request->table_name,3))="ESI_ENSURE_PARMS*")
  SET table_name = "ESI_ENSURE_PARMS"
  SELECT DISTINCT INTO "NL:"
   c.*
   FROM esi_ensure_parms c
   WHERE (c.contributor_system_cd=request->contributor_system_cd)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->match_tag_rec,(kount+ 10))
    ENDIF
    reply->match_tag_rec[kount].esi_task_cd = c.esi_task_cd, reply->match_tag_rec[kount].
    contributor_system_type_cd = c.contributor_system_type_cd, reply->match_tag_rec[kount].
    encntr_ensure_type_cd = c.encntr_ensure_type_cd,
    reply->match_tag_rec[kount].person_ensure_type_cd = c.person_ensure_type_cd, reply->
    match_tag_rec[kount].event_ensure_type_cd = c.event_ensure_type_cd
   WITH nocounter
  ;end select
  SET reply->table_rec_qual = kount
  SET stat = alter(reply->esi_ensure_parms_rec,kount)
 ENDIF
 IF (cnvtupper(trim(request->table_name,3))="ESI_ALIAS_TRANSLATION*")
  SET table_name = "ESI_ALIAS_TRANSLATION"
  SELECT DISTINCT INTO "NL:"
   c.*
   FROM esi_alias_translation c
   WHERE (c.contributor_system_cd=request->contributor_system_cd)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->esi_alias_translation_rec,(kount+ 10))
    ENDIF
    reply->esi_alias_translation_rec[kount].esi_alias_field_cd = c.esi_alias_field_cd, reply->
    esi_alias_translation_rec[kount].alias_entity_name = c._alias_entity_name, reply->
    esi_alias_translation_rec[kount].alias_entity_alias_type_cd = c.alias_entity_alias_type_cd,
    reply->esi_alias_translation_rec[kount].filter = c.filter, reply->esi_alias_translation_rec[kount
    ].trunc_size = c.trunc_size, reply->esi_alias_translation_rec[kount].skip_string = c.skip_string
   WITH nocounter
  ;end select
  SET reply->table_rec_qual = kount
  SET stat = alter(reply->esi_alias_translation_rec,kount)
 ENDIF
 IF (cnvtupper(trim(request->table_name,3))="ALIAS_POOL*")
  SET table_name = "ALIAS_POOL"
  SELECT DISTINCT INTO "NL:"
   c.*
   FROM alias_pool c
   WHERE (c.alias_entity_name=request->alias_entity_name)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->alias_pool_rec,(kount+ 10))
    ENDIF
    reply->alias_pool_rec[kount].location_cd = c.location_cd, reply->alias_pool_rec[kount].
    organization_id = c.organization_id, reply->alias_pool_rec[kount].alias_entity_name = c
    .alias_entity_name,
    reply->alias_pool_rec[kount].alias_entity_alias_type_cd = c.alias_entity_alias_type_cd, reply->
    alias_pool_rec[kount].unique_alias_ind = c.unique_alias_ind
   WITH nocounter
  ;end select
  SET reply->table_rec_qual = kount
  SET stat = alter(reply->alias_pool_rec,kount)
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
 ENDIF
 GO TO end_program
#end_program
END GO
