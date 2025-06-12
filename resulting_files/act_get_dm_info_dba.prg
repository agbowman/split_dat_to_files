CREATE PROGRAM act_get_dm_info:dba
 RECORD reply(
   1 qual[*]
     2 info_number = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE num_cnt = i4 WITH public, noconstant(0)
 SET num_cnt = size(request->num_list,5)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(num_cnt)),
   dm_info d
  PLAN (d1)
   JOIN (d
   WHERE (d.info_number=request->num_list[d1.seq].info_number)
    AND d.info_domain="CODE SET UPDATE")
  ORDER BY d.updt_dt_tm DESC
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].info_number = d.info_number,
   reply->qual[cnt].updt_dt_tm = d.updt_dt_tm
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
