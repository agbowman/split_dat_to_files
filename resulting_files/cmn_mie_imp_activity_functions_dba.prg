CREATE PROGRAM cmn_mie_imp_activity_functions:dba
 DECLARE PUBLIC::create_import_activity(import_type=vc,requested_name=vc,replacement_name=vc,
  repl_parent_entity_id=f8,repl_parent_entity_name=vc,
  process_guid=vc) = vc WITH copy, protect
 SUBROUTINE PUBLIC::create_import_activity(import_type,requested_name,replacement_name,
  repl_parent_entity_id,repl_parent_entity_name,process_guid)
   DECLARE import_result = vc WITH protect, noconstant("")
   DECLARE errmsg = vc WITH protect, noconstant("")
   INSERT  FROM cmn_import_activity cia
    SET cia.cmn_import_activity_id = seq(activity_seq,nextval), cia.cmn_import_type = import_type,
     cia.requested_name = requested_name,
     cia.replacement_name = replacement_name, cia.import_dt_tm = cnvtdatetime(curdate,curtime3), cia
     .repl_parent_entity_id = repl_parent_entity_id,
     cia.repl_parent_entity_name = repl_parent_entity_name, cia.process_guid = process_guid, cia
     .performing_prsnl_id = reqinfo->updt_id,
     cia.updt_id = reqinfo->updt_id, cia.updt_dt_tm = cnvtdatetime(curdate,curtime3), cia.updt_task
      = reqinfo->updt_task,
     cia.updt_applctx = reqinfo->updt_applctx, cia.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET import_result = errmsg
   ELSE
    SET import_result = "SUCCESS"
   ENDIF
   RETURN(import_result)
 END ;Subroutine
END GO
