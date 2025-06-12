CREATE PROGRAM dts_get_rad_report_id:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[10]
      2 rad_report_id = f8
      2 rad_rpt_reference_nbr = c40
      2 no_proxy_ind = i2
      2 report_event_id = f8
      2 sequence = i4
      2 rr_updt_cnt = i4
      2 addendum_ind = i2
    1 qual_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "NL:"
  rr.*
  FROM rad_report rr
  WHERE (rr.order_id=request->order_id)
  DETAIL
   count1 = (count1+ 1), stat = alter(reply->qual,count1), reply->qual[count1].rad_report_id = rr
   .rad_report_id,
   reply->qual[count1].rad_rpt_reference_nbr = rr.rad_rpt_reference_nbr, reply->qual[count1].
   report_event_id = rr.report_event_id, reply->qual[count1].no_proxy_ind = rr.no_proxy_ind,
   reply->qual[count1].sequence = rr.sequence, reply->qual[count1].rr_updt_cnt = rr.updt_cnt, reply->
   qual[count1].addendum_ind = rr.addendum_ind
 ;end select
 SET stat = alter(reply->qual,count1)
 SET reply->qual_cnt = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO reply->qual_cnt)
   CALL echo(build("report id: ",reply->qual[cnt].rad_report_id))
   CALL echo(build("reference number: ",reply->qual[cnt].rad_rpt_reference_nbr))
   CALL echo(build("event id: ",reply->qual[cnt].report_event_id))
   CALL echo(build("proxy ind: ",reply->qual[cnt].no_proxy_ind))
   CALL echo(build("sequence: ",reply->qual[cnt].sequence))
   CALL echo(build("updt_cnt: ",reply->qual[cnt].rr_updt_cnt))
   CALL echo(build("addendum ind: ",reply->qual[cnt].addendum_ind))
 ENDFOR
END GO
