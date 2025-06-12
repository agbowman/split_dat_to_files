CREATE PROGRAM bmditranslatelocandpat:dba
 RECORD reply(
   1 qual[*]
     2 smon = c100
     2 sunit = c40
     2 dunitcd = f8
     2 sroom = c40
     2 droomcd = f8
     2 sbed = c40
     2 dbedcd = f8
     2 spat = c100
     2 dpatid = f8
     2 ideviceind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET count1 = 0
 SELECT INTO "nl:"
  spat = p.name_full_formatted
  FROM person p,
   (dummyt d  WITH seq = value(number_to_add))
  PLAN (d)
   JOIN (p
   WHERE p.person_id=outerjoin(request->qual[d.seq].dpatid))
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].smon = request->
   qual[d.seq].smon,
   reply->qual[count1].dunitcd = request->qual[d.seq].dunitcd, reply->qual[count1].droomcd = request
   ->qual[d.seq].droomcd, reply->qual[count1].dbedcd = request->qual[d.seq].dbedcd,
   reply->qual[count1].dpatid = request->qual[d.seq].dpatid, reply->qual[count1].dpatid = request->
   qual[d.seq].dpatid, reply->qual[count1].ideviceind = request->qual[d.seq].ideviceind,
   reply->qual[count1].sunit = uar_get_code_display(request->qual[d.seq].dunitcd), reply->qual[count1
   ].sroom = uar_get_code_display(request->qual[d.seq].droomcd), reply->qual[count1].sbed =
   uar_get_code_display(request->qual[d.seq].dbedcd),
   reply->qual[count1].spat = spat
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
