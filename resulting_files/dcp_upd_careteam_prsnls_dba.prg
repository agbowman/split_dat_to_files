CREATE PROGRAM dcp_upd_careteam_prsnls:dba
 RECORD reply(
   1 careteam_list[*]
     2 careteam_id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET careteam_id = 0.0
 SET updt_cnt = 0
 SET care_cnt = size(request->careteam_list,5)
 SET stat = alterlist(reply->careteam_list,care_cnt)
 SET flag = 0
 FOR (i = 1 TO care_cnt)
   IF ((request->careteam_list[i].careteam_id > 0))
    CALL echo(build("careTeamId:",request->careteam_list[i].careteam_id))
    SET careteam_id = request->careteam_list[i].careteam_id
    SELECT INTO "nl:"
     FROM dcp_care_team dct
     WHERE (dct.careteam_id=request->careteam_list[i].careteam_id)
     DETAIL
      updt_cnt = (dct.updt_cnt+ 1)
     WITH nocounter
    ;end select
    UPDATE  FROM dcp_care_team_prsnl dcp
     SET dcp.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dcp.active_ind = 0, dcp.updt_cnt
       = updt_cnt
     WHERE (dcp.careteam_id=request->careteam_list[i].careteam_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_care_team"
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ELSE
    SELECT INTO "nl:"
     w = seq(dcp_assignment_seq,nextval)
     FROM dual
     DETAIL
      careteam_id = cnvtreal(w)
     WITH nocounter
    ;end select
    INSERT  FROM dcp_care_team dct
     SET dct.careteam_id = careteam_id, dct.name = request->careteam_list[i].name, dct
      .beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm),
      dct.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm), dct.updt_cnt = updt_cnt,
      dct.updt_id = reqinfo->updt_id,
      dct.updt_task = reqinfo->updt_task, dct.updt_applctx = reqinfo->updt_applctx, dct.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      dct.active_ind = 1
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "s"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_care_team"
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
   SET reply->careteam_list[i].careteam_id = careteam_id
   SET prsnl_cnt = size(request->careteam_list[i].prsnl_list,5)
   FOR (j = 1 TO prsnl_cnt)
     SET flag = 0
     SELECT INTO "nl:"
      FROM dcp_care_team_prsnl dcp
      WHERE dcp.careteam_id=careteam_id
       AND (dcp.prsnl_id=request->careteam_list[i].prsnl_list[j].prsnl_id)
      DETAIL
       flag = 1
      WITH nocounter
     ;end select
     IF (flag=1)
      CALL echo(build("Prsnl_id1:",request->careteam_list[i].prsnl_list[j].prsnl_id))
      UPDATE  FROM dcp_care_team_prsnl dcp
       SET dcp.end_effective_dt_tm = cnvtdatetime(request->end_effective_dt_tm), dcp.active_ind = 1,
        dcp.updt_cnt = (updt_cnt - 1)
       WHERE dcp.careteam_id=careteam_id
        AND (dcp.prsnl_id=request->careteam_list[i].prsnl_list[j].prsnl_id)
       WITH nocounter
      ;end update
     ELSE
      CALL echo(build("Prsnl_id:",request->careteam_list[i].prsnl_list[j].prsnl_id))
      INSERT  FROM dcp_care_team_prsnl dcp
       SET dcp.careteam_prsnl_id = cnvtreal(seq(dcp_assignment_seq,nextval)), dcp.careteam_id =
        careteam_id, dcp.prsnl_id = request->careteam_list[i].prsnl_list[j].prsnl_id,
        dcp.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), dcp.end_effective_dt_tm
         = cnvtdatetime(request->end_effective_dt_tm), dcp.updt_cnt = 0,
        dcp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dcp.updt_id = reqinfo->updt_id, dcp
        .updt_task = reqinfo->updt_task,
        dcp.updt_id = reqinfo->updt_id, dcp.updt_applctx = reqinfo->updt_applctx, dcp.active_ind = 1
       WITH nocounter
      ;end insert
     ENDIF
     CALL echo(build("care teamId on;",careteam_id))
     IF (curqual=0)
      SET reply->status_data.subeventstatus[1].operationname = "insert"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_care_team_prsnls"
      SET reply->status_data.status = "Z"
      CALL echo(build("care teamId;",careteam_id))
     ELSE
      SET reply->status_data.status = "S"
     ENDIF
   ENDFOR
 ENDFOR
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
