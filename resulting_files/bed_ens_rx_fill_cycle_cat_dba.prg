CREATE PROGRAM bed_ens_rx_fill_cycle_cat:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET ccnt = 0
 SET lcnt = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = size(request->fill_cycles,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
   SET update_fb_row = 0
   FREE SET temp
   RECORD temp(
     1 qual[*]
       2 loc_cd = f8
   )
   SET lcnt = 0
   SELECT INTO "nl:"
    FROM fill_cycle_batch f
    PLAN (f
     WHERE (f.fill_batch_cd=request->fill_cycles[x].code_value)
      AND f.location_cd > 0
      AND f.dispense_category_cd > 0)
    HEAD f.location_cd
     lcnt = (lcnt+ 1), stat = alterlist(temp->qual,lcnt), temp->qual[lcnt].loc_cd = f.location_cd
    WITH nocounter
   ;end select
   SET ccnt = size(request->fill_cycles[x].dispense_categories,5)
   FOR (y = 1 TO ccnt)
    IF ((request->fill_cycles[x].dispense_categories[y].action_flag=1))
     FOR (z = 1 TO lcnt)
       SET insert_fcb_row = 1
       SELECT INTO "nl:"
        FROM fill_cycle_batch f
        PLAN (f
         WHERE (f.fill_batch_cd=request->fill_cycles[x].code_value)
          AND (f.location_cd=temp->qual[z].loc_cd)
          AND (f.dispense_category_cd=request->fill_cycles[x].dispense_categories[y].code_value))
        DETAIL
         insert_fcb_row = 0
        WITH nocounter
       ;end select
       IF (insert_fcb_row=1)
        SET update_fb_row = 1
        SET ierrcode = 0
        INSERT  FROM fill_cycle_batch f
         SET f.fill_batch_cd = request->fill_cycles[x].code_value, f.location_cd = temp->qual[z].
          loc_cd, f.dispense_category_cd = request->fill_cycles[x].dispense_categories[y].code_value,
          f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_id = reqinfo->updt_id,
          f.updt_task = reqinfo->updt_task, f.updt_applctx = reqinfo->updt_applctx
         PLAN (f)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
       SET insert_fc_row = 1
       SELECT INTO "nl:"
        FROM fill_cycle f
        PLAN (f
         WHERE (f.location_cd=temp->qual[z].loc_cd)
          AND (f.dispense_category_cd=request->fill_cycles[x].dispense_categories[y].code_value))
        DETAIL
         insert_fc_row = 0
        WITH nocounter
       ;end select
       IF (insert_fc_row=1)
        SET update_fb_row = 1
        SET ierrcode = 0
        INSERT  FROM fill_cycle f
         SET f.location_cd = temp->qual[z].loc_cd, f.dispense_category_cd = request->fill_cycles[x].
          dispense_categories[y].code_value, f.from_dt_tm = null,
          f.to_dt_tm = null, f.fill_cycle_id = seq(pharmacy_seq,nextval), f.last_operation_flag = 0,
          f.audit_flag = 0, f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task, f.updt_applctx = reqinfo->
          updt_applctx
         PLAN (f)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF ((request->fill_cycles[x].dispense_categories[y].action_flag=3))
     FOR (z = 1 TO lcnt)
       SET update_fb_row = 1
       SET ierrcode = 0
       DELETE  FROM fill_cycle_batch f
        WHERE (f.fill_batch_cd=request->fill_cycles[x].code_value)
         AND (f.location_cd=temp->qual[z].loc_cd)
         AND (f.dispense_category_cd=request->fill_cycles[x].dispense_categories[y].code_value)
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
   IF (update_fb_row=1)
    SET ierrcode = 0
    UPDATE  FROM fill_batch f
     SET f.updt_id = reqinfo->updt_id, f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task =
      reqinfo->updt_task,
      f.updt_applctx = reqinfo->updt_applctx, f.updt_cnt = (f.updt_cnt+ 1)
     PLAN (f
      WHERE (f.fill_batch_cd=request->fill_cycles[x].code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
