CREATE PROGRAM ct_add_role_multi_prots:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE insert_prot_role_error = i2 WITH private, constant(1)
 DECLARE insert_entity_access_error = i2 WITH private, constant(2)
 DECLARE search_amd_error = i2 WITH private, constant(3)
 DECLARE person_in_request = i2 WITH private, constant(4)
 DECLARE personal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17296,"PERSONAL"))
 SET reply->status_data.status = "F"
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE person_cnt = i2 WITH protect, noconstant(0)
 SET person_cnt = cnvtint(size(request->qual,5))
 IF (person_cnt <= 0)
  SET fail_flag = person_in_request
  GO TO check_error
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE total_amd_cnt = i2 WITH protect, noconstant(0)
 DECLARE prot_counter = i2 WITH protect, noconstant(0)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE person_counter = i2 WITH protect, noconstant(0)
 DECLARE amd_size = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE entity_cnt = i2 WITH protect, noconstant(0)
 DECLARE role_exists = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  pa.*
  FROM prot_amendment pa,
   prot_role pr,
   (dummyt d1  WITH seq = value(cnvtint(size(request->qual,5)))),
   (dummyt d2  WITH seq = value(cnvtint(size(request->qual[(row+ 1)].protocols,5))))
  PLAN (d1)
   JOIN (d2)
   JOIN (pa
   WHERE (pa.prot_master_id=request->qual[d1.seq].protocols[d2.seq].prot_master_id))
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  ORDER BY pa.prot_master_id, pa.prot_amendment_id, pr.prot_role_id
  HEAD REPORT
   amd_insert_cnt = 0
  HEAD pa.prot_master_id
   amd_insert_cnt = 0, stat = alterlist(request->qual[d1.seq].protocols[d2.seq].amd,amd_insert_cnt)
  HEAD pa.prot_amendment_id
   role_exists = 0
  DETAIL
   IF ((pr.person_id=request->qual[d1.seq].person_id)
    AND (pr.organization_id=request->qual[d1.seq].organization_id)
    AND (pr.prot_role_cd=request->qual[d1.seq].protocols[d2.seq].prot_role_cd)
    AND pr.prot_role_type_cd=personal_cd)
    role_exists = 1
   ENDIF
  FOOT  pa.prot_amendment_id
   IF (role_exists=0)
    total_amd_cnt = (total_amd_cnt+ 1), amd_insert_cnt = (amd_insert_cnt+ 1)
    IF (mod(amd_insert_cnt,10)=1)
     stat = alterlist(request->qual[d1.seq].protocols[d2.seq].amd,(amd_insert_cnt+ 9))
    ENDIF
    request->qual[d1.seq].protocols[d2.seq].amd[amd_insert_cnt].prot_amendment_id = pa
    .prot_amendment_id
   ENDIF
  FOOT  pa.prot_master_id
   stat = alterlist(request->qual[d1.seq].protocols[d2.seq].amd,amd_insert_cnt)
  WITH nocounter
 ;end select
 CALL echo(build("total_amd_cnt: ",total_amd_cnt))
 IF (total_amd_cnt > 0)
  IF (curqual=0)
   SET fail_flag = search_amd_error
   GO TO check_error
  ENDIF
 ENDIF
 IF (total_amd_cnt > 0)
  FOR (person_counter = 1 TO person_cnt)
   SET prot_cnt = size(request->qual[person_counter].protocols,5)
   FOR (prot_counter = 1 TO prot_cnt)
    SET amd_size = size(request->qual[person_counter].protocols[prot_counter].amd,5)
    IF (amd_size > 0)
     INSERT  FROM prot_role pr,
       (dummyt d  WITH seq = value(cnvtint(size(request->qual[person_counter].protocols[prot_counter]
          .amd,5))))
      SET pr.prot_role_id = cnvtint(seq(protocol_def_seq,nextval)), pr.organization_id = request->
       qual[person_counter].organization_id, pr.prot_amendment_id = request->qual[person_counter].
       protocols[prot_counter].amd[d.seq].prot_amendment_id,
       pr.person_id = request->qual[person_counter].person_id, pr.prot_role_cd = request->qual[
       person_counter].protocols[prot_counter].prot_role_cd, pr.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime3),
       pr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), pr.updt_cnt = 0, pr.updt_dt_tm
        = cnvtdatetime(curdate,curtime3),
       pr.updt_id = reqinfo->updt_id, pr.updt_task = reqinfo->updt_task, pr.updt_applctx = reqinfo->
       updt_applctx,
       pr.prot_role_type_cd = personal_cd
      PLAN (d)
       JOIN (pr)
      WITH counter
     ;end insert
     IF (curqual != amd_size)
      SET fail_flag = insert_prot_role_error
      GO TO check_error
     ENDIF
    ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 IF (person_cnt > 0)
  FOR (person_counter = 1 TO person_cnt)
   SET entity_cnt = size(request->qual[person_counter].entity_access_list,5)
   IF (entity_cnt > 0)
    INSERT  FROM entity_access ea,
      (dummyt d2  WITH seq = value(cnvtint(entity_cnt)))
     SET ea.entity_access_id = cnvtint(seq(protocol_def_seq,nextval)), ea.person_id = request->qual[
      person_counter].person_id, ea.prot_amendment_id = request->qual[person_counter].
      entity_access_list[d2.seq].prot_amendment_id,
      ea.functionality_cd = request->qual[person_counter].entity_access_list[d2.seq].functionality_cd,
      ea.access_mask = request->qual[person_counter].entity_access_list[d2.seq].access_mask, ea
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      ea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ea.updt_cnt = 0, ea.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      ea.updt_id = reqinfo->updt_id, ea.updt_applctx = reqinfo->updt_applctx, ea.updt_task = reqinfo
      ->updt_task
     PLAN (d2)
      JOIN (ea)
     WITH nocounter
    ;end insert
    CALL echo(build("insert to entity_access curqual is: ",curqual))
    IF (curqual=0)
     SET fail_flag = insert_entity_access_error
     GO TO check_error
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_prot_role_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into prot_role table"
   OF insert_entity_access_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Inserting into entity_access table"
   OF search_amd_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Searching for amendments in prot_amendment table"
   OF person_in_request:
    SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectname = "QUAL"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No items in qual list in request"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "004"
 SET mod_date = "August 10, 2009"
END GO
