CREATE PROGRAM bbt_chg_reagent_cells:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET number_of_cells = request->cell_cnt
 SET cur_updt_cnt = 0
 SET y = 1
 IF ((request->cell_group_flag="F")
  AND (request->cell_flag="F"))
  SET reply->status_data.status = "P"
  GO TO exit_script
 ENDIF
 IF ((request->cell_group_flag="T"))
  SELECT INTO "nl:"
   c.*
   FROM code_value c
   WHERE c.code_set=1602
    AND (c.code_value=request->cell_group_cd)
    AND (c.updt_cnt=request->cell_group_updt_cnt)
    AND (c.active_ind=request->cell_group_active_ind)
   DETAIL
    cur_updt_cnt = c.updt_cnt
   WITH nocounter, forupdate(c)
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_reagent_cells"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "code_value"
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->cell_flag="T"))
  FOR (x = 1 TO number_of_cells)
   SELECT INTO "nl:"
    cg.*
    FROM cell_group cg
    WHERE (cg.cell_group_cd=request->cell_group_cd)
     AND (cg.cell_cd=request->cell_data[x].cell_cd)
     AND (cg.updt_cnt=request->cell_data[x].cell_updt_cnt)
     AND cg.active_ind=1
    WITH nocounter, forupdate(cg)
   ;end select
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_reagent_cells"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cell_group"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "cell_group"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
 IF ((request->cell_group_flag="T"))
  UPDATE  FROM code_value c
   SET c.description = request->cell_group_description, c.active_ind = request->cell_group_new_ind, c
    .updt_cnt = (c.updt_cnt+ 1),
    c.inactive_dt_tm =
    IF ((request->cell_group_new_ind=0)) cnvtdatetime(curdate,curtime3)
    ELSE null
    ENDIF
    , c.active_dt_tm =
    IF ((request->cell_group_new_ind=1)) cnvtdatetime(curdate,curtime3)
    ELSE null
    ENDIF
    , c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
    updt_applctx
   WHERE c.code_set=1602
    AND (c.code_value=request->cell_group_cd)
    AND (c.updt_cnt=request->cell_group_updt_cnt)
    AND (c.active_ind=request->cell_group_active_ind)
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_reagent_cells"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "code_value"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->cell_flag="T"))
  FOR (y = 1 TO number_of_cells)
   UPDATE  FROM cell_group cg
    SET cg.active_ind = 0, cg.active_status_cd = reqdata->active_status_cd, cg.active_status_prsnl_id
      = reqinfo->updt_id,
     cg.updt_cnt = (cg.updt_cnt+ 1), cg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cg.updt_id =
     reqinfo->updt_id,
     cg.updt_task = reqinfo->updt_task, cg.updt_applctx = reqinfo->updt_applctx
    WHERE (cg.cell_group_cd=request->cell_group_cd)
     AND (cg.cell_cd=request->cell_data[y].cell_cd)
     AND (cg.updt_cnt=request->cell_data[y].cell_updt_cnt)
     AND cg.active_ind=1
   ;end update
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_chg_reagent_cells"
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "cell_group"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "cell_group"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF ((((reply->status_data.status="P")) OR ((reply->status_data.status="F"))) )
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
