CREATE PROGRAM dcp_get_ino_orders:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 hna_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 start_dt_tm = dq8
     2 start_tz = i4
     2 end_dt_tm = dq8
     2 end_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE activity_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"FLUID BALANC"))
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE onhold_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE cnt = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id=request->person_id)
    AND o.activity_type_cd=activity_cd
    AND o.current_start_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND ((o.projected_stop_dt_tm >= cnvtdatetime(request->start_dt_tm)) OR (o.projected_stop_dt_tm=
   null))
    AND  NOT (o.order_status_cd IN (incomplete_cd, onhold_cd))
    AND ((o.template_order_id+ 0)=0))
  ORDER BY o.projected_stop_dt_tm DESC, o.current_start_dt_tm DESC, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 5))
   ENDIF
   reply->qual[cnt].order_id = o.order_id, reply->qual[cnt].hna_mnemonic = o.hna_order_mnemonic,
   reply->qual[cnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
   reply->qual[cnt].order_mnemonic = o.order_mnemonic, reply->qual[cnt].start_dt_tm = o
   .current_start_dt_tm, reply->qual[cnt].start_tz = o.current_start_tz,
   reply->qual[cnt].end_dt_tm = o.projected_stop_dt_tm, reply->qual[cnt].end_tz = o.projected_stop_tz
  FOOT  o.order_id
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
