CREATE PROGRAM dcp_get_prsnl:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET starting_string = fillstring(12," ")
 IF (cnvtupper(request->starting_string) > " ")
  SET starting_string = cnvtupper(trim(request->starting_string))
 ENDIF
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE cnvtupper(trim(p.name_full_formatted)) >= cnvtupper(trim(starting_string))
   AND p.active_ind=1
  ORDER BY cnvtupper(p.name_full_formatted)
  HEAD p.person_id
   count1 = count1
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].person_id = p.person_id, reply->qual[count1].name_full_formatted = p
   .name_full_formatted, reply->qual[count1].position_cd = p.position_cd
  WITH nocounter, maxqual(p,50), orahint("index(p XIE2PRSNL)")
 ;end select
#exit_script
 SET stat = alterlist(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
