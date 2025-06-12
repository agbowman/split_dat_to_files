CREATE PROGRAM bed_ens_rx_fill_cycles:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = size(request->fill_cycles,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
   SET facility_cd = 0.0
   SET facility_tz = 0
   FREE SET temp
   RECORD temp(
     1 qual[*]
       2 cat_cd = f8
       2 loc_cd = f8
   )
   SET rcnt = 0
   SELECT INTO "nl:"
    FROM fill_batch b,
     fill_cycle_batch c
    PLAN (b
     WHERE (b.fill_batch_cd=request->fill_cycles[x].code_value))
     JOIN (c
     WHERE c.fill_batch_cd=b.fill_batch_cd
      AND c.location_cd > 0
      AND c.dispense_category_cd > 0)
    DETAIL
     rcnt = (rcnt+ 1), stat = alterlist(temp->qual,rcnt), facility_cd = b.loc_facility_cd,
     temp->qual[rcnt].cat_cd = c.dispense_category_cd, temp->qual[rcnt].loc_cd = c.location_cd
    WITH nocounter
   ;end select
   IF (facility_cd > 0)
    SELECT INTO "nl:"
     FROM time_zone_r t
     PLAN (t
      WHERE t.parent_entity_id=facility_cd
       AND t.parent_entity_name="LOCATION")
     DETAIL
      facility_tz = datetimezonebyname(trim(t.time_zone,3))
     WITH nocounter
    ;end select
   ENDIF
   IF (facility_tz=0)
    SET facility_tz = curtimezoneapp
   ENDIF
   IF (rcnt > 0)
    SET ierrcode = 0
    UPDATE  FROM fill_cycle f,
      (dummyt d  WITH seq = value(rcnt))
     SET f.from_dt_tm = cnvtdatetime(request->from_dt_tm), f.to_dt_tm = cnvtdatetime(request->
       to_dt_tm), f.last_operation_flag = 3,
      f.from_tz = facility_tz, f.to_tz = facility_tz, f.updt_id = reqinfo->updt_id,
      f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f.updt_applctx
       = reqinfo->updt_applctx,
      f.updt_cnt = (f.updt_cnt+ 1)
     PLAN (d)
      JOIN (f
      WHERE (f.location_cd=temp->qual[d.seq].loc_cd)
       AND (f.dispense_category_cd=temp->qual[d.seq].cat_cd))
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
