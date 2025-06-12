CREATE PROGRAM dcp_del_prsnl_group_reltn:dba
 RECORD mem_reltn(
   1 qual[*]
     2 prsnl_group_reltn_id = f8
 )
 RECORD reply(
   1 qual[*]
     2 prsnl_group_id = f8
   1 batch_qual[*]
     2 batch_person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET select_ind = 0
 IF ((request->person_id > 0)
  AND (request->batch_prsnl_group_id > 0))
  GO TO exit_script
 ELSEIF ((request->person_id=0)
  AND (request->batch_prsnl_group_id=0))
  GO TO exit_script
 ELSEIF ((request->person_id > 0)
  AND (request->batch_prsnl_group_id=0))
  SET select_ind = 1
  SET number_to_del = size(request->qual,5)
 ELSEIF ((request->person_id=0)
  AND (request->batch_prsnl_group_id > 0))
  SET select_ind = 2
  SET number_to_del = size(request->batch_qual,5)
 ENDIF
 RECORD updates(
   1 qual[*]
     2 status = i1
 )
 SET stat = alterlist(updates->qual,number_to_del)
 CALL echo(build("number to del is->",number_to_del))
 SET failures = 0
 SET count1 = 0
 SET x = 1
 SELECT
  IF (select_ind=1)
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_group_id=request->qual[d.seq].prsnl_group_id)
     AND (p.person_id=request->person_id))
  ELSEIF (select_ind=2)
   PLAN (d)
    JOIN (p
    WHERE (p.prsnl_group_id=request->batch_prsnl_group_id)
     AND (p.person_id=request->batch_qual[d.seq].batch_person_id))
  ELSE
  ENDIF
  INTO "nl:"
  p.prsnl_group_reltn_id
  FROM prsnl_group_reltn p,
   (dummyt d  WITH seq = value(number_to_del))
  HEAD REPORT
   x = 1
  DETAIL
   IF (x > size(mem_reltn->qual,5))
    stat = alterlist(mem_reltn->qual,(x+ 10))
   ENDIF
   mem_reltn->qual[x].prsnl_group_reltn_id = p.prsnl_group_reltn_id, x = (x+ 1)
  FOOT REPORT
   stat = alterlist(mem_reltn->qual,(x - 1))
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(mem_reltn->qual,5))
  CALL echo(build("Deleting ",mem_reltn->qual[x].prsnl_group_reltn_id,"from team_mem_ppr_reltn"))
  DELETE  FROM team_mem_ppr_reltn t
   WHERE (t.prsnl_group_reltn_id=mem_reltn->qual[x].prsnl_group_reltn_id)
   WITH nocounter
  ;end delete
 ENDFOR
 IF (select_ind=2)
  FOR (x = 1 TO number_to_del)
    CALL echo(build("x=",x))
    CALL echo(build("Deleting person ",request->batch_qual[x].batch_person_id))
    CALL echo(build("from group",request->batch_prsnl_group_id))
    DELETE  FROM prsnl_group_reltn p
     WHERE (p.prsnl_group_id=request->batch_prsnl_group_id)
      AND (p.person_id=request->batch_qual[x].batch_person_id)
     WITH nocounter
    ;end delete
  ENDFOR
 ELSEIF (select_ind=1)
  FOR (x = 1 TO number_to_del)
    CALL echo(build("x=",x))
    CALL echo(build("Deleting group ",request->qual[x].prsnl_group_id,"for a person"))
    DELETE  FROM prsnl_group_reltn p
     WHERE (p.prsnl_group_id=request->qual[x].prsnl_group_id)
      AND (p.person_id=request->person_id)
     WITH nocounter
    ;end delete
  ENDFOR
 ENDIF
 FOR (x = 1 TO number_to_del)
   IF ((updates->qual[x].status=0))
    SET failures = (failures+ 1)
    IF (select_ind=1)
     SET stat = alterlist(reply->qual,failures)
    ELSEIF (select_ind=2)
     SET stat = alterlist(reply->batch_qual,failures)
    ENDIF
    IF (select_ind=1)
     SET reply->qual[failures].prsnl_group_id = request->qual[x].prsnl_group_id
    ELSEIF (select_ind=2)
     SET reply->batch_qual[failures].batch_person_id = request->batch_qual[x].batch_person_id
    ENDIF
   ENDIF
 ENDFOR
 IF (failures=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "prsnl_group_reltn"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET reqinfo->commit_ind = 0
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_del_prsnl_group_reltn"
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
