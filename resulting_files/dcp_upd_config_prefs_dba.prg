CREATE PROGRAM dcp_upd_config_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET config_id = 0.0
 SET org_id = 0.0
 SET failed = "F"
 IF ((request->organization > ""))
  SET parent = "ORGANIZATION"
 ELSE
  SET parent = ""
 ENDIF
 IF ((request->organization > ""))
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o
   WHERE (o.org_name=request->organization)
   HEAD REPORT
    org_id = o.organization_id,
    CALL echo(o.organization_id)
  ;end select
 ELSE
  SET org_id = 0.0
 ENDIF
 CALL echo("middle")
 SELECT INTO "nl:"
  cp.config_prefs_id
  FROM config_prefs cp
  WHERE cnvtupper(trim(cp.parent_entity_name))=cnvtupper(trim(parent))
   AND cnvtupper(trim(cp.config_name))=cnvtupper(trim(request->name))
  WITH counter, dontcare = cv
 ;end select
 CALL echo("if statement")
 IF (curqual > 0)
  CALL echo("then part")
  CALL echo("")
  UPDATE  FROM config_prefs cp
   SET cp.config_value = request->value, cp.updt_cnt = (cp.updt_cnt+ 1)
   WHERE cnvtupper(trim(cp.parent_entity_name))=cnvtupper(trim(parent))
    AND cnvtupper(trim(cp.config_name))=cnvtupper(trim(request->name))
   WITH counter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "config_prefs table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "update"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to update table"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("else part")
  CALL echo("")
  CALL echo("before insert")
  CALL echo(build("config_id->",config_id))
  CALL echo(build("parent_entity->",request->organization))
  CALL echo(build("parent_entity_id->",org_id))
  CALL echo(build("config_name->",request->name))
  CALL echo(build("value->",request->value))
  CALL echo(build("updt_dt_tm->",cnvtdatetime(curdate,curtime)))
  CALL echo(build("updt_id->",reqinfo->updt_id))
  CALL echo(build("updt_task->",reqinfo->updt_task))
  INSERT  FROM config_prefs cp,
    dummyt d1
   SET cp.config_prefs_id = seq(carenet_seq,nextval), cp.parent_entity_name = parent, cp
    .parent_entity_id = org_id,
    cp.config_name = substring(1,12,request->name), cp.config_value = request->value, cp.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    cp.updt_id = reqinfo->updt_id, cp.updt_task = reqinfo->updt_task, cp.updt_cnt = 1,
    cp.updt_applctx = reqinfo->updt_applctx, cp.flexed_by =
    IF ((request->organization > "")) "ORGANIZATION"
    ELSE "INSTALLATION"
    ENDIF
   PLAN (d1)
    JOIN (cp)
   WITH counter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].targetobjectname = "config_prefs table"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "insert"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
   SET failed = "T"
  ENDIF
 ENDIF
 CALL echo("end if")
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
