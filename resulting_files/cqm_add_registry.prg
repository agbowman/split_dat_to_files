CREATE PROGRAM cqm_add_registry
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
 SET registry_id = 0.0
 SET listener_id = 0.0
 FREE SET failed
 SET failed = "F"
 SELECT INTO "nl:"
  l.listener_id
  FROM cqm_listener_config l
  WHERE l.application_name=trim(request->app_name,3)
   AND l.listener_alias=trim(request->listener_alias,3)
  DETAIL
   listener_id = l.listener_id
  WITH nocounter
 ;end select
 IF (listener_id > 0)
  SELECT INTO "nl:"
   r.registry_id, r.class, r.type,
   r.subtype, r.subtype_detail
   FROM cqm_listener_registry r
   WHERE r.listener_id=listener_id
    AND ((r.class=trim(request->class,3)
    AND trim(request->class,3) > " ") OR (r.class=null
    AND trim(request->class,3) <= " "))
    AND ((r.type=trim(request->type,3)
    AND trim(request->type,3) > " ") OR (r.type=null
    AND trim(request->type,3) <= " "))
    AND ((r.subtype=trim(request->subtype,3)
    AND trim(request->subtype,3) > " ") OR (r.subtype=null
    AND trim(request->subtype,3) <= " "))
    AND ((r.subtype_detail=trim(request->subtype_detail,3)) OR (r.subtype_detail=null))
   DETAIL
    registry_id = r.registry_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT INTO "nl:"
    nextseqnum = seq(cqm_registry_id_seq,nextval)
    FROM dual
    DETAIL
     registry_id = nextseqnum
    WITH nocounter
   ;end select
   INSERT  FROM cqm_listener_registry r
    SET r.registry_id = registry_id, r.listener_id = listener_id, r.class =
     IF ((request->class > "")) request->class
     ELSE null
     ENDIF
     ,
     r.type =
     IF ((request->type > "")) request->type
     ELSE null
     ENDIF
     , r.subtype =
     IF ((request->subtype > "")) request->subtype
     ELSE null
     ENDIF
     , r.subtype_detail =
     IF ((request->subtype_detail > "")) request->subtype_detail
     ELSE null
     ENDIF
     ,
     r.target_priority = request->target_priority, r.debug_ind = request->debug_ind, r.verbosity_flag
      = request->verbosity_flag,
     r.create_dt_tm = cnvtdatetime(sysdate), r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = 1,
     r.updt_task = 1255000, r.updt_applctx = 1255000, r.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ELSEIF (curqual=1)
   UPDATE  FROM cqm_listener_registry r
    SET r.class =
     IF ((request->class > "")) request->class
     ELSE null
     ENDIF
     , r.type =
     IF ((request->type > "")) request->type
     ELSE null
     ENDIF
     , r.subtype =
     IF ((request->subtype > "")) request->subtype
     ELSE null
     ENDIF
     ,
     r.subtype_detail =
     IF ((request->subtype_detail > "")) request->subtype_detail
     ELSE null
     ENDIF
     , r.target_priority = request->target_priority, r.debug_ind = request->debug_ind,
     r.verbosity_flag = request->verbosity_flag, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = 1,
     r.updt_task = 1255000, r.updt_applctx = 1255000, r.updt_cnt = (r.updt_cnt+ 1)
    WHERE r.registry_id=registry_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  IF (validate(reqinfo->commit_ind,0) != 0)
   SET reqinfo->commit_ind = 0
  ELSE
   ROLLBACK
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  IF (validate(reqinfo->commit_ind,0) != 0)
   SET reqinfo->commit_ind = 1
  ELSE
   COMMIT
  ENDIF
 ENDIF
END GO
