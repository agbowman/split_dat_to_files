CREATE PROGRAM bbd_upd_default_bag_type:dba
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
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  p.*
  FROM donation_procedure p,
   (dummyt d  WITH seq = value(size(request->bag_type_qual,5)))
  PLAN (d)
   JOIN (p
   WHERE (p.default_bag_type_cd=request->bag_type_qual[d.seq].bag_type_cd))
  WITH counter, forupdate(p)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
 UPDATE  FROM donation_procedure p,
   (dummyt d  WITH seq = value(size(request->bag_type_qual,5)))
  SET p.default_bag_type_cd = 0, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p.updt_cnt+ 1),
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (p
   WHERE (p.default_bag_type_cd=request->bag_type_qual[d.seq].bag_type_cd))
  WITH nocounter
 ;end update
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  SET reqinfo->commit_ind = 0
 ENDIF
#exitscript
END GO
