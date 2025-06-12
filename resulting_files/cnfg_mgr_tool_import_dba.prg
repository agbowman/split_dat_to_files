CREATE PROGRAM cnfg_mgr_tool_import:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting cnfg_mgr_tool_import script"
 FREE RECORD import
 RECORD import(
   1 utility_list[*]
     2 active_ind = i2
     2 collation_seq = i4
     2 help_txt = vc
     2 report_name = vc
     2 report_param = vc
     2 title_txt = vc
     2 tool_key_txt = vc
     2 parent_key_txt = vc
     2 exist_in_db_ind = i2
 ) WITH protect
 DECLARE main(null) = null WITH protect
 DECLARE createreadmedata(null) = null WITH protect
 DECLARE setexistindbind(null) = null WITH protect
 DECLARE insertdata(null) = null WITH protect
 DECLARE updatedata(null) = null WITH protect
 DECLARE checkforerrmsg(msg=vc) = i4 WITH protect
 CALL main(null)
 SUBROUTINE main(null)
   CALL createreadmedata(null)
   IF (size(import->utility_list,5)=0)
    GO TO exit_script
   ENDIF
   CALL setexistindbind(null)
   CALL insertdata(null)
   CALL updatedata(null)
   COMMIT
 END ;Subroutine
 SUBROUTINE createreadmedata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   DECLARE iter = i4 WITH protect, noconstant(0)
   SET stat = alterlist(import->utility_list,size(requestin->list_0,5))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(requestin)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(requestin->list_0,5))
    PLAN (d
     WHERE (requestin->list_0[d.seq].tool_key_txt > " "))
    DETAIL
     iter = (iter+ 1), import->utility_list[iter].active_ind = cnvtint(requestin->list_0[d.seq].
      active_ind), import->utility_list[iter].collation_seq = cnvtint(requestin->list_0[d.seq].
      collation_seq),
     import->utility_list[iter].help_txt = trim(requestin->list_0[d.seq].help_txt), import->
     utility_list[iter].title_txt = trim(requestin->list_0[d.seq].title_txt), import->utility_list[
     iter].tool_key_txt = trim(requestin->list_0[d.seq].tool_key_txt)
     IF ((requestin->list_0[d.seq].grp_key_txt >= " "))
      import->utility_list[iter].parent_key_txt = requestin->list_0[d.seq].grp_key_txt
     ELSE
      import->utility_list[iter].parent_key_txt = " "
     ENDIF
     import->utility_list[iter].report_param = trim(requestin->list_0[d.seq].report_param), import->
     utility_list[iter].report_name = trim(requestin->list_0[d.seq].report_name)
    FOOT REPORT
     stat = alterlist(import->utility_list,iter)
    WITH nocounter
   ;end select
   SET errorcode = checkforerrmsg("Error in CreateReadMeData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errcode=0)
     CALL echo("Executing CreateReadMeData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setexistindbind(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE utilitylistidx = i4 WITH protect, noconstant(0)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(requestin)
   ENDIF
   SELECT INTO "nl:"
    FROM cnfg_mgr_tool tool
    WHERE expand(idx,1,size(import->utility_list,5),cnvtupper(trim(tool.tool_key_txt)),cnvtupper(
      import->utility_list[idx].tool_key_txt))
    HEAD tool.tool_key_txt
     utilitylistidx = locateval(idx,1,size(import->utility_list,5),cnvtupper(tool.tool_key_txt),
      cnvtupper(import->utility_list[idx].tool_key_txt)), import->utility_list[utilitylistidx].
     exist_in_db_ind = 1
    WITH nocounter
   ;end select
   SET errorcode = checkforerrmsg("Error in setExistInDbInd Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing setExistInDbInd Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertdata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   INSERT  FROM cnfg_mgr_tool tool,
     (dummyt d  WITH seq = size(import->utility_list,5))
    SET tool.cnfg_mgr_tool_id = cnvtreal(seq(reference_seq,nextval)), tool.active_ind = import->
     utility_list[d.seq].active_ind, tool.cnfg_mgr_grp_id =
     (SELECT
      grp.cnfg_mgr_grp_id
      FROM cnfg_mgr_grp grp
      WHERE (grp.grp_key_txt=import->utility_list[d.seq].parent_key_txt)),
     tool.collation_seq = cnvtint(import->utility_list[d.seq].collation_seq), tool.help_txt = import
     ->utility_list[d.seq].help_txt, tool.tool_key_txt = import->utility_list[d.seq].tool_key_txt,
     tool.report_name = import->utility_list[d.seq].report_name, tool.report_param = import->
     utility_list[d.seq].report_param, tool.title_txt = import->utility_list[d.seq].title_txt,
     tool.updt_applctx = reqinfo->updt_applctx, tool.updt_cnt = 1, tool.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     tool.updt_id = reqinfo->updt_id, tool.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (import->utility_list[d.seq].exist_in_db_ind=0))
     JOIN (tool)
    WITH nocounter
   ;end insert
   SET errorcode = checkforerrmsg("Error in InsertData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing InsertData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updatedata(null)
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   UPDATE  FROM cnfg_mgr_tool tool,
     (dummyt d  WITH seq = value(size(import->utility_list,5)))
    SET tool.cnfg_mgr_grp_id =
     (SELECT
      grp.cnfg_mgr_grp_id
      FROM cnfg_mgr_grp grp
      WHERE (grp.grp_key_txt=import->utility_list[d.seq].parent_key_txt)), tool.active_ind =
     IF ((import->utility_list[d.seq].active_ind=1)) 1
     ELSE tool.active_ind
     ENDIF
     , tool.collation_seq = cnvtint(import->utility_list[d.seq].collation_seq),
     tool.help_txt = import->utility_list[d.seq].help_txt, tool.report_name = import->utility_list[d
     .seq].report_name, tool.report_param = import->utility_list[d.seq].report_param,
     tool.updt_applctx = reqinfo->updt_applctx, tool.updt_cnt = (1+ tool.updt_cnt), tool.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     tool.updt_id = reqinfo->updt_id, tool.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (import->utility_list[d.seq].exist_in_db_ind=1))
     JOIN (tool
     WHERE (tool.tool_key_txt=import->utility_list[d.seq].tool_key_txt))
    WITH nocounter
   ;end update
   SET errorcode = checkforerrmsg("Error in UpdateData Subroutine")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(import)
    IF (errorcode=0)
     CALL echo("Executing UpdateData Subroutine successfully")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforerrmsg(msg)
   DECLARE errcode = i4 WITH protect, noconstant(0)
   DECLARE errmsg = vc WITH protect, noconstant("")
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(msg,":",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(errcode)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully inserted data into the configured application data table"
#exit_script
 FREE RECORD import
END GO
