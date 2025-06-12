CREATE PROGRAM ccl_prompt_addprogram:dba
 DECLARE berror = i1 WITH noconstant(0)
 CALL echo("add program")
 IF (size(request->programname,1)=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Missing program name"
  RETURN(0)
 ENDIF
 SET request->programname = trim(cnvtupper(request->programname))
 SELECT INTO "nl:"
  cpg.*
  FROM ccl_prompt_programs cpg
  WHERE (cpg.control_class_id=request->classid)
   AND (cpg.program_name=request->programname)
   AND (cpg.group_no=request->groupno)
  DETAIL
   berror = 1
  WITH nocounter
 ;end select
 IF (berror=0)
  INSERT  FROM ccl_prompt_programs cpg
   SET cpg.control_class_id = request->classid, cpg.program_name = request->programname, cpg.group_no
     = request->groupno,
    cpg.display = request->display, cpg.description = request->description, cpg.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    cpg.updt_id = reqinfo->updt_id, cpg.updt_task = reqinfo->updt_task, cpg.updt_cnt = 0,
    cpg.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  COMMIT
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = concat("program '",request->programname,
   "' inserted")
 ELSE
  CALL echo("duplicate program found, aborting...")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = concat("'",trim(request->programname),
   "' already defined.")
 ENDIF
END GO
