CREATE PROGRAM bbd_chg_cross_results:dba
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
 SET count1 = 0
 SET y = 0
 SET x = 0
 SET next_code = 0.0
 SET cross_results_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->cross_count)
   IF ((request->qual[y].add_row="A"))
    EXECUTE cpm_next_code
    SET cross_results_id = next_code
    INSERT  FROM cross_results c
     SET c.interp_id = request->interp_id, c.cross_results_id = next_code, c.donor_eligibility_cd =
      request->qual[y].donor_eligibility_cd,
      c.donor_reason_cd = request->qual[y].donor_reason_cd, c.active_ind = request->qual[y].
      active_ind, c.active_status_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      c.active_status_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , c.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      , c.updt_applctx = reqinfo->updt_applctx,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
      reqinfo->updt_task,
      c.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cross results"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "cross result insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = y
     GO TO exit_script
    ENDIF
    FOR (x = 1 TO request->qual[y].results_cnt)
      EXECUTE cpm_next_code
      INSERT  FROM cross_results_r c
       SET c.cross_results_r_id = next_code, c.cross_results_id = cross_results_id, c.interp_id =
        request->interp_id,
        c.result_hash_id = request->qual[y].qual2[x].result_hash_id, c.active_ind = request->qual[y].
        qual2[x].active_ind, c.active_status_cd =
        IF ((request->qual[y].qual2[x].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->inactive_status_cd
        ENDIF
        ,
        c.active_status_dt_tm =
        IF ((request->qual[y].qual2[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
        ELSE null
        ENDIF
        , c.active_status_prsnl_id =
        IF ((request->qual[y].qual2[x].active_ind=1)) reqinfo->updt_id
        ELSE 0
        ENDIF
        , c.updt_applctx = reqinfo->updt_applctx,
        c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
        reqinfo->updt_task,
        c.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = "T"
       SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
       SET reply->status_data.subeventstatus[1].operationname = "insert"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "cross results r"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "cross result r insert"
       SET reply->status_data.subeventstatus[1].sourceobjectqual = x
       GO TO exit_script
      ENDIF
    ENDFOR
   ELSEIF ((request->qual[y].add_row="M"))
    SELECT INTO "nl:"
     c.*
     FROM cross_results c
     WHERE (c.cross_results_id=request->qual[y].cross_results_id)
      AND (c.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(c)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM cross_results c
     SET c.interp_id = request->interp_id, c.cross_results_id = request->qual[y].cross_results_id, c
      .donor_eligibility_cd = request->qual[y].donor_eligibility_cd,
      c.donor_reason_cd = request->qual[y].donor_reason_cd, c.active_ind = request->qual[y].
      active_ind, c.active_status_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      c.active_status_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE c.active_status_dt_tm
      ENDIF
      , c.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE c.active_status_prsnl_id
      ENDIF
      , c.updt_applctx = reqinfo->updt_applctx,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
      reqinfo->updt_task,
      c.updt_cnt = (request->qual[y].updt_cnt+ 1)
     WHERE (c.cross_results_id=request->qual[y].cross_results_id)
      AND (c.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results table"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
    FOR (x = 1 TO request->qual[y].results_cnt)
      IF ((request->qual[y].qual2[x].add_row="A"))
       EXECUTE cpm_next_code
       INSERT  FROM cross_results_r c
        SET c.cross_results_r_id = next_code, c.cross_results_id = cross_results_id, c.interp_id =
         request->interp_id,
         c.result_hash_id = request->qual[y].qual2[x].result_hash_id, c.active_ind = request->qual[y]
         .qual2[x].active_ind, c.active_status_cd =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         c.active_status_dt_tm =
         IF ((request->qual[y].qual2[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
         ELSE null
         ENDIF
         , c.active_status_prsnl_id =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqinfo->updt_id
         ELSE 0
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
         reqinfo->updt_task,
         c.updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "insert"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross results r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "cross result r insert"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = x
        GO TO exit_script
       ENDIF
      ELSEIF ((request->qual[y].qual2[x].add_row="M"))
       SELECT INTO "nl:"
        c.*
        FROM cross_results_r c
        WHERE (c.cross_results_r_id=request->qual[y].qual2[x].cross_results_r_id)
         AND (c.updt_cnt=request->qual[y].qual2[x].updt_cnt)
        WITH counter, forupdate(c)
       ;end select
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "lock"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results_r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results r lock1"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
        GO TO exit_script
       ENDIF
       UPDATE  FROM cross_results_r c
        SET c.cross_results_r_id = request->qual[y].qual2[x].cross_results_r_id, c.cross_results_id
          = request->qual[y].cross_results_id, c.interp_id = request->interp_id,
         c.result_hash_id = request->qual[y].qual2[x].result_hash_id, c.active_ind = request->qual[y]
         .qual2[x].active_ind, c.active_status_cd =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         c.active_status_dt_tm =
         IF ((request->qual[y].qual2[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
         ELSE c.active_status_dt_tm
         ENDIF
         , c.active_status_prsnl_id =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqinfo->updt_id
         ELSE c.active_status_prsnl_id
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
         reqinfo->updt_task,
         c.updt_cnt = (request->qual[y].qual2[x].updt_cnt+ 1)
        WHERE (c.cross_results_r_id=request->qual[y].qual2[x].cross_results_r_id)
         AND (c.updt_cnt=request->qual[y].qual2[x].updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "update"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results_r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results r table"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    FOR (x = 1 TO request->qual[y].results_cnt)
      IF ((request->qual[y].qual2[x].add_row="A"))
       EXECUTE cpm_next_code
       INSERT  FROM cross_results_r c
        SET c.cross_results_r_id = next_code, c.cross_results_id = cross_results_id, c.interp_id =
         request->interp_id,
         c.result_hash_id = request->qual[y].qual2[x].result_hash_id, c.active_ind = request->qual[y]
         .qual2[x].active_ind, c.active_status_cd =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         c.active_status_dt_tm =
         IF ((request->qual[y].qual2[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
         ELSE null
         ENDIF
         , c.active_status_prsnl_id =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqinfo->updt_id
         ELSE 0
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
         reqinfo->updt_task,
         c.updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "insert"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross results r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "cross result r insert"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = x
        GO TO exit_script
       ENDIF
      ELSEIF ((request->qual[y].qual2[x].add_row="M"))
       SELECT INTO "nl:"
        c.*
        FROM cross_results_r c
        WHERE (c.cross_results_r_id=request->qual[y].qual2[x].cross_results_r_id)
         AND (c.updt_cnt=request->qual[y].qual2[x].updt_cnt)
        WITH counter, forupdate(c)
       ;end select
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "lock"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results_r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results r lock2"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
        GO TO exit_script
       ENDIF
       UPDATE  FROM cross_results_r c
        SET c.cross_results_r_id = request->qual[y].qual2[x].cross_results_r_id, c.cross_results_id
          = request->qual[y].cross_results_id, c.interp_id = request->interp_id,
         c.result_hash_id = request->qual[y].qual2[x].result_hash_id, c.active_ind = request->qual[y]
         .qual2[x].active_ind, c.active_status_cd =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqdata->active_status_cd
         ELSE reqdata->inactive_status_cd
         ENDIF
         ,
         c.active_status_dt_tm =
         IF ((request->qual[y].qual2[x].active_ind=1)) cnvtdatetime(curdate,curtime3)
         ELSE c.active_status_dt_tm
         ENDIF
         , c.active_status_prsnl_id =
         IF ((request->qual[y].qual2[x].active_ind=1)) reqinfo->updt_id
         ELSE c.active_status_prsnl_id
         ENDIF
         , c.updt_applctx = reqinfo->updt_applctx,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
         reqinfo->updt_task,
         c.updt_cnt = (request->qual[y].qual2[x].updt_cnt+ 1)
        WHERE (c.cross_results_r_id=request->qual[y].qual2[x].cross_results_r_id)
         AND (c.updt_cnt=request->qual[y].qual2[x].updt_cnt)
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET failed = "T"
        SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
        SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_cross_results"
        SET reply->status_data.subeventstatus[1].operationname = "update"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "cross_results_r"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "code results r table"
        SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
