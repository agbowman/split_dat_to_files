CREATE PROGRAM dcp_upd_apache_reltd_locs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE x = i2 WITH noconstant(0), public
 DECLARE cnt = i2 WITH noconstant(0), public
 SET cnt = size(request->loc_list,5)
 UPDATE  FROM location l,
   (dummyt d  WITH seq = value(cnt))
  SET l.apache_reltn_flag = request->loc_list[d.seq].apache_reltn_flag, l.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), l.updt_id = reqinfo->updt_id,
   l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l.updt_cnt
   + 1)
  PLAN (d)
   JOIN (l
   WHERE (l.location_cd=request->loc_list[d.seq].location_cd))
  WITH nocounter
 ;end update
 IF (curqual=cnt)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
