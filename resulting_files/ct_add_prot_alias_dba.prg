CREATE PROGRAM ct_add_prot_alias:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE prot_alias_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE parent_alias_id = f8 WITH protect, noconstant(0.0)
 DECLARE cur_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE l_unique_ind = i2 WITH protect, noconstant(0)
 DECLARE num_to_add = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(12801,"PROT_MASTER",1,prot_alias_type_cd)
 CALL echo(build("prot_alias_type_cd: ",prot_alias_type_cd))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 CALL echo("inside aliases")
 SET l_unique_ind = 0
 SET num_to_add = size(request->aliases,5)
 FOR (i = 1 TO num_to_add)
   SELECT INTO "nl:"
    p.unique_ind
    FROM alias_pool p
    WHERE (p.alias_pool_cd=request->aliases[i].alias_pool_cd)
    DETAIL
     l_unique_ind = p.unique_ind
    WITH nocounter
   ;end select
   IF (l_unique_ind=3)
    SELECT INTO "NL:"
     a.*
     FROM prot_alias a
     WHERE (a.prot_alias=request->aliases[i].alias)
     WITH nocounter
    ;end select
    IF (curqual != 0)
     SET reply->debug = "MNEM"
     CALL report_failure("NONUNIQUE","D","CT_ADD_PROT_ALIAS","Error due to alias not being unique.")
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo(build("- aliases updt cnt:",request->aliases[i].alias_updt_cnt))
   IF ((request->aliases[i].alias_updt_cnt=- (9)))
    CALL echo("before insert - aliases")
    INSERT  FROM prot_alias p
     SET p.prot_alias_id = seq(protocol_def_seq,nextval), p.alias_id = seq(protocol_def_seq,currval),
      p.prot_master_id = prot_master_id,
      p.prot_alias = request->aliases[i].alias, p.alias_pool_cd = request->aliases[i].alias_pool_cd,
      p.prot_alias_type_cd = prot_alias_type_cd,
      p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), p.updt_id = reqinfo->updt_id,
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","CT_ADD_PROT_ALIAS",
      "Error inserting new row into prot_alias table.")
     GO TO exit_script
    ENDIF
   ELSE
    IF ((request->aliases[i].alias_id > 0))
     CALL echo("before SELECT - aliases")
     CALL echo(build("alias_id: ",request->aliases[i].alias_id))
     SELECT INTO "nl:"
      p.*
      FROM prot_alias p
      WHERE (p.prot_alias_id=request->aliases[i].alias_id)
      DETAIL
       cur_updt_cnt = p.updt_cnt, parent_alias_id = p.alias_id,
       CALL echo(build("parent_alias_id: ",parent_alias_id))
      WITH nocounter, forupdate(p)
     ;end select
     CALL echo("before SELECT for delete - aliases")
     IF (curqual=0)
      CALL report_failure("LOCKING","F","CT_ADD_PROT_ALIAS",
       "Error locking the prot_alias table for update.")
      GO TO exit_script
     ENDIF
     IF ((cur_updt_cnt != request->aliases[i].alias_updt_cnt))
      CALL report_failure("UPDATE_CNT","F","CT_ADD_PROT_ALIAS",
       "Error locking the prot_alias table for update, updt_cnt's not correct.")
      GO TO exit_script
     ENDIF
     IF ((request->aliases[i].delete_ind=1))
      CALL echo("before delete - aliases")
      UPDATE  FROM prot_alias p
       SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE (p.prot_alias_id=request->aliases[i].alias_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("DELETE","F","CT_ADD_PROT_ALIAS",
        "Error logically deleting the protocol alias")
       GO TO exit_script
      ENDIF
     ELSE
      UPDATE  FROM prot_alias p
       SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE (p.prot_alias_id=request->aliases[i].alias_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       CALL report_failure("INSERT","F","CT_ADD_PROT_ALIAS","Error updating row in prot_alias table."
        )
       GO TO exit_script
      ENDIF
      INSERT  FROM prot_alias p
       SET p.prot_alias_id = seq(protocol_def_seq,nextval), p.alias_id = parent_alias_id, p
        .prot_master_id = prot_master_id,
        p.prot_alias = request->aliases[i].alias, p.alias_pool_cd = request->aliases[i].alias_pool_cd,
        p.prot_alias_type_cd = prot_alias_type_cd,
        p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
         "31-DEC-2100 00:00:00.00"), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
        updt_applctx,
        p.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL report_failure("INSERT","F","CT_ADD_PROT_ALIAS",
        "Error inserting new row into prot_alias table for update.")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "004"
 SET mod_date = "March 19, 2007"
END GO
