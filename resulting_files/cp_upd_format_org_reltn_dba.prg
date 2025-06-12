CREATE PROGRAM cp_upd_format_org_reltn:dba
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
 SET failed = false
 DECLARE x = i2 WITH public, noconstant(0)
 DECLARE org_size = i2 WITH public, noconstant(0)
 DECLARE req_size = i2 WITH public, noconstant(0)
 SET org_size = size(request->org_qual,5)
 FOR (x = 1 TO org_size)
   DELETE  FROM format_org_reltn f
    WHERE (f.organization_id=request->org_qual[x].organization_id)
   ;end delete
   SET req_size = size(request->org_qual[x].qual,5)
   IF (req_size > 0)
    INSERT  FROM (dummyt d  WITH seq = value(req_size)),
      format_org_reltn f
     SET f.seq = 1, f.organization_id = request->org_qual[x].organization_id, f.chart_format_id =
      request->org_qual[x].qual[d.seq].chart_format_id,
      f.primary_format_ind = request->org_qual[x].qual[d.seq].primary_format_ind, f
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), f.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"),
      f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_id = reqinfo->updt_id, f.updt_cnt = 0,
      f.updt_applctx = reqinfo->updt_applctx, f.updt_task = reqinfo->updt_task, f.active_ind = 1,
      f.active_status_cd = reqdata->active_status_cd, f.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), f.active_status_prsnl_id = reqinfo->updt_id
     PLAN (d)
      JOIN (f)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = true
    ENDIF
   ENDIF
 ENDFOR
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
END GO
