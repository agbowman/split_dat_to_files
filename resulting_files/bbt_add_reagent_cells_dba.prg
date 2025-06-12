CREATE PROGRAM bbt_add_reagent_cells:dba
 RECORD reply(
   1 cell_group_cd = f8
   1 cell_data[10]
     2 cell_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alter(reply->cell_data,request->cells_cnt)
 SET failures = 0
 FOR (y = 1 TO request->cells_cnt)
   SELECT INTO "nl:"
    cg.*
    FROM cell_group cg
    WHERE (cg.cell_group_cd=request->cell_group_cd)
     AND (cg.cell_cd=request->cells_data[y].cells_cd)
    WITH nocounter, forupdate(cg)
   ;end select
   IF (curqual=0)
    SET next_code = 0.0
    EXECUTE cpm_next_code
    INSERT  FROM cell_group cg
     SET cg.cell_id = next_code, cg.cell_group_cd = request->cell_group_cd, cg.cell_cd = request->
      cells_data[y].cells_cd,
      cg.active_ind = 1, cg.active_status_cd = reqdata->active_status_cd, cg.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cg.active_status_prsnl_id = reqinfo->updt_id, cg.updt_cnt = 0, cg.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cg.updt_id = reqinfo->updt_id, cg.updt_task = reqinfo->updt_task, cg.updt_applctx = reqinfo->
      updt_applctx
    ;end insert
    SET reply->cell_data[y].cell_cd = next_code
   ELSE
    UPDATE  FROM cell_group cg
     SET cg.active_ind = 1, cg.active_status_cd = reqdata->active_status_cd, cg
      .active_status_prsnl_id = reqinfo->updt_id,
      cg.updt_cnt = (cg.updt_cnt+ 1), cg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cg.updt_id =
      reqinfo->updt_id,
      cg.updt_task = reqinfo->updt_task, cg.updt_applctx = reqinfo->updt_applctx
     WHERE (cg.cell_group_cd=request->cell_group_cd)
      AND (cg.cell_cd=request->cells_data[y].cells_cd)
    ;end update
   ENDIF
   IF (curqual=0)
    SET failures = 1
    GO TO exit_script
   ENDIF
 ENDFOR
 COMMIT
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
 ENDIF
END GO
