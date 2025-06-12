CREATE PROGRAM dcp_alter_note_type_list:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE nt_cnt = i4 WITH protect, noconstant(0)
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_cnt = i4 WITH protect, noconstant(0)
 DECLARE checkforerrors(operation) = null
 IF ((((request->role_type_cd=0)
  AND (request->prsnl_id=0)
  AND (request->encntr_type_class_cd=0)) OR ((((request->role_type_cd > 0)
  AND (request->prsnl_id > 0)) OR ((((request->role_type_cd > 0)
  AND (request->encntr_type_class_cd > 0)) OR ((request->prsnl_id > 0)
  AND (request->encntr_type_class_cd > 0))) )) )) )
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF ((request->role_type_cd > 0))
  DELETE  FROM note_type_list n
   WHERE (n.role_type_cd=request->role_type_cd)
    AND n.prsnl_id=0
    AND n.encntr_type_class_cd=0
  ;end delete
 ELSEIF ((request->prsnl_id > 0))
  DELETE  FROM note_type_list n
   WHERE (n.prsnl_id=request->prsnl_id)
    AND n.role_type_cd=0
    AND n.encntr_type_class_cd=0
  ;end delete
 ELSEIF ((request->encntr_type_class_cd > 0))
  DELETE  FROM note_type_list n
   WHERE (n.encntr_type_class_cd=request->encntr_type_class_cd)
    AND n.role_type_cd=0
    AND n.prsnl_id=0
  ;end delete
 ENDIF
 CALL checkforerrors("Delete")
 IF (errcode != 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET nt_cnt = cnvtint(size(request->qual,5))
 INSERT  FROM note_type_list ntl,
   (dummyt d  WITH seq = value(nt_cnt))
  SET ntl.seq = 1, ntl.note_type_list_id = cnvtreal(seq(reference_seq,nextval)), ntl.note_type_id =
   request->qual[d.seq].note_type_id,
   ntl.role_type_cd = request->role_type_cd, ntl.prsnl_id = request->prsnl_id, ntl
   .encntr_type_class_cd = request->encntr_type_class_cd,
   ntl.seq_num = request->qual[d.seq].seq_num, ntl.updt_dt_tm = cnvtdatetime(curdate,curtime), ntl
   .updt_id = reqinfo->updt_id,
   ntl.updt_task = reqinfo->updt_task, ntl.updt_applctx = reqinfo->updt_applctx, ntl.updt_cnt = 0
  PLAN (d)
   JOIN (ntl)
  WITH nocounter
 ;end insert
 CALL checkforerrors("Insert")
 IF (((curqual=0) OR (errcode != 0)) )
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SUBROUTINE checkforerrors(operation)
   SET errcode = 1
   WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET error_cnt += 1
     IF (size(reply->status_data.subeventstatus,5) < error_cnt)
      SET stat = alterlist(reply->status_data.subeventstatus,error_cnt)
     ENDIF
     SET reply->status_data.subeventstatus[error_cnt].operationname = substring(1,25,trim(operation))
     SET reply->status_data.subeventstatus[error_cnt].targetobjectname = cnvtstring(errcode)
     SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = errmsg
    ENDIF
   ENDWHILE
   IF (error_cnt > 0)
    SET errcode = 1
    SET reply->status_data.status = "F"
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
