CREATE PROGRAM bbt_bpc_app_info:dba
 RECORD reply(
   1 application_nbr = i4
   1 user_name = vc
   1 app_start_dt_tm = dq8
   1 device_location = vc
   1 application_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF (validate(request->product_id)=1)
  SELECT INTO "nl:"
   p.product_id, p.updt_id, p.updt_dt_tm,
   pnl.person_id, pnl.name_full_formatted
   FROM product p,
    prsnl pnl
   PLAN (p
    WHERE (request->product_id=p.product_id))
    JOIN (pnl
    WHERE (pnl.person_id= Outerjoin(p.updt_id)) )
   DETAIL
    reply->user_name = pnl.name_full_formatted, reply->app_start_dt_tm = p.updt_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
