CREATE PROGRAM cp_upd_sec_pos_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE req_size = i2 WITH public, noconstant(0)
 DECLARE pos_size = i2 WITH public, noconstant(0)
 DECLARE x = i2 WITH public, noconstant(0)
 SET failed = true
 SET req_size = size(request->qual,5)
 FOR (x = 1 TO req_size)
   DELETE  FROM sect_position_reltn s
    WHERE (s.chart_format_id=request->qual[x].chart_format_id)
     AND (s.chart_section_id=request->qual[x].chart_section_id)
   ;end delete
   SET pos_size = size(request->qual[x].position_qual,5)
   IF (pos_size > 0)
    INSERT  FROM (dummyt d  WITH seq = value(pos_size)),
      sect_position_reltn s
     SET s.seq = 1, s.position_cd = request->qual[x].position_qual[d.seq].position_cd, s
      .chart_format_id = request->qual[x].chart_format_id,
      s.chart_section_id = request->qual[x].chart_section_id, s.organization_id = request->qual[x].
      position_qual[d.seq].organization_id, s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), s.updt_id = reqinfo->updt_id,
      s.updt_cnt = 0, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task,
      s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      s.active_status_prsnl_id = reqinfo->updt_id
     PLAN (d)
      JOIN (s)
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET failed = false
    ELSE
     SET failed = true
     GO TO programend
    ENDIF
   ELSE
    SET failed = false
   ENDIF
 ENDFOR
#programend
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SECT_POSITION_RELTN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Insert Failed"
  SET reqinfo->commit_ind = false
 ENDIF
END GO
