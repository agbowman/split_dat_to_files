CREATE PROGRAM bed_get_person_by_alias_pool:dba
 FREE SET reply
 RECORD reply(
   1 persons[*]
     2 id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 DECLARE id_count = i4
 DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_count = i2 WITH protect, constant(2)
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM alias_pool ap
  PLAN (ap
   WHERE (ap.alias_pool_cd=request->alias_pool_cd))
  DETAIL
   x = 1
  WITH nocounter
 ;end select
 SET id_count = 0
 IF (size(trim(request->alias)) > 0)
  SELECT INTO "nl:"
   FROM prsnl_alias pa
   PLAN (pa
    WHERE (pa.alias_pool_cd=request->alias_pool_cd)
     AND (pa.alias=request->alias)
     AND pa.active_ind=1)
   DETAIL
    id_count = (id_count+ 1)
    IF (prsnl_cnt < max_count)
     stat = alterlist(reply->persons,id_count), reply->persons[id_count].id = pa.person_id
    ENDIF
    prsnl_cnt = (prsnl_cnt+ 1)
   WITH nocounter
  ;end select
 ENDIF
 IF (size(trim(request->alias)) > 0)
  SELECT INTO "nl:"
   FROM person_alias pra
   PLAN (pra
    WHERE (pra.alias_pool_cd=request->alias_pool_cd)
     AND (pra.alias=request->alias)
     AND pra.active_ind=1)
   DETAIL
    id_count = (id_count+ 1)
    IF (person_cnt < max_count)
     stat = alterlist(reply->persons,id_count), reply->persons[id_count].id = pra.person_id
    ENDIF
    person_cnt = (person_cnt+ 1)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_PERSON_BY_ALIAS_POOL  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
