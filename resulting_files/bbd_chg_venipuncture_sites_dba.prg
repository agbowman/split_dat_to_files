CREATE PROGRAM bbd_chg_venipuncture_sites:dba
 RECORD reply(
   1 qual[*]
     2 body_site_cd = f8
     2 updt_cnt = i4
     2 add_row = i2
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
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE vensite_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 FOR (y = 1 TO request->vensite_cnt)
   IF ((request->qual[y].add_row=1))
    SELECT INTO "nl:"
     d.*
     FROM donor_venipuncture_site d
     WHERE (d.body_site_cd=request->qual[y].body_site_cd)
      AND d.active_ind=0
     WITH nocounter, forupdate(d)
    ;end select
    IF (curqual=0)
     SET new_pathnet_seq = 0.0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     SET vensite_id = new_pathnet_seq
     INSERT  FROM donor_venipuncture_site d
      SET d.venipuncture_id = vensite_id, d.body_site_cd = request->qual[y].body_site_cd, d
       .active_ind = 1,
       d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), d.active_status_prsnl_id = reqinfo->updt_id,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d
       .updt_id = reqinfo->updt_id,
       d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
      WITH nocounter
     ;end insert
    ELSE
     UPDATE  FROM donor_venipuncture_site d
      SET d.active_ind = 1, d.active_status_cd = reqdata->active_status_cd, d.updt_cnt = (request->
       qual[y].updt_cnt+ 1),
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
       reqinfo->updt_task,
       d.updt_applctx = reqinfo->updt_applctx
      WHERE (d.body_site_cd=request->qual[y].body_site_cd)
       AND d.active_ind=0
     ;end update
    ENDIF
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_venipuncture_sites"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "donor_venipuncture_site"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "venipuncture site insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].body_site_cd = request->qual[y].body_site_cd
     SET reply->qual[y].updt_cnt = 0
     SET reply->qual[y].add_row = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     d.*
     FROM donor_venipuncture_site d
     WHERE (d.body_site_cd=request->qual[y].body_site_cd)
      AND (d.updt_cnt=request->qual[y].updt_cnt)
      AND d.active_ind=1
     WITH counter, forupdate(d)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_venipuncture_sites"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "donor_venipuncture_site"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "venipuncture_site lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
    UPDATE  FROM donor_venipuncture_site d
     SET d.active_ind = 0, d.active_status_cd = reqdata->inactive_status_cd, d.updt_applctx = reqinfo
      ->updt_applctx,
      d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_task =
      reqinfo->updt_task,
      d.updt_cnt = (request->qual[y].updt_cnt+ 1)
     WHERE (d.body_site_cd=request->qual[y].body_site_cd)
      AND (d.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_venipuncture_sites"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "donor_venipuncture_site"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "venipuncture_site insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].body_site_cd = request->qual[y].body_site_cd
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
     SET reply->qual[y].add_row = 0
    ENDIF
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
