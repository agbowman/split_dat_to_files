CREATE PROGRAM bed_ens_sch_loc_orders:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ocnt = 0
 DECLARE active_cd = f8 WITH public, noconstant(0.0)
 SET ocnt = size(request->orders,5)
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO ocnt)
   IF ((request->orders[x].action_flag=1))
    SET stat = add_ord(x)
   ELSEIF ((request->orders[x].action_flag=3))
    SET stat = del_ord(x)
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE add_ord(x)
   SET loc_found = 0
   SET activate_loc = 0
   SELECT INTO "nl:"
    FROM sch_order_loc s
    PLAN (s
     WHERE (s.catalog_cd=request->orders[x].code_value)
      AND (s.location_cd=request->dept_code_value))
    DETAIL
     loc_found = 1
     IF (s.active_ind=0)
      activate_loc = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (loc_found=0)
    SET ierrcode = 0
    INSERT  FROM sch_order_loc s
     SET s.catalog_cd = request->orders[x].code_value, s.location_cd = request->dept_code_value, s
      .version_dt_tm = cnvtdatetime("31-DEC-2100"),
      s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.candidate_id = seq(sch_candidate_seq,nextval), s
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
      s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
      active_cd,
      s.active_status_dt_tm = cnvtdatetime(curdate,curtime), s.active_status_prsnl_id = reqinfo->
      updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
      s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
      s.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   IF (activate_loc=0)
    SET ierrcode = 0
    UPDATE  FROM sch_order_loc s
     SET s.active_ind = 1, s.active_status_cd = active_cd, s.active_status_dt_tm = cnvtdatetime(
       curdate,curtime),
      s.active_status_prsnl_id = reqinfo->updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s
      .updt_applctx = reqinfo->updt_applctx,
      s.updt_id = reqinfo->updt_id, s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
     PLAN (s
      WHERE (s.catalog_cd=request->orders[x].code_value)
       AND (s.location_cd=request->dept_code_value))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_ord(x)
   SET ierrcode = 0
   DELETE  FROM sch_order_loc s
    WHERE (s.location_cd=request->dept_code_value)
     AND (s.catalog_cd=request->orders[x].code_value)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   DELETE  FROM sch_order_duration s
    WHERE (s.location_cd=request->dept_code_value)
     AND (s.catalog_cd=request->orders[x].code_value)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   SET ierrcode = 0
   DELETE  FROM sch_order_role s
    WHERE (s.location_cd=request->dept_code_value)
     AND (s.catalog_cd=request->orders[x].code_value)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
