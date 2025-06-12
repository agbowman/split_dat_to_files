CREATE PROGRAM bed_get_loc_by_loc_type:dba
 FREE SET reply
 RECORD reply(
   1 meanings[*]
     2 cdf_meaning = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
       3 locations[*]
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET mcnt = 0
 SET mcnt = size(request->meanings,5)
 IF (mcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->meanings,mcnt)
 FOR (x = 1 TO mcnt)
   SET reply->meanings[x].cdf_meaning = request->meanings[x].cdf_meaning
   SET ocnt = 0
   SET lcnt = 0
   SELECT INTO "nl:"
    FROM code_value cv1,
     location l,
     organization o,
     code_value cv2
    PLAN (cv1
     WHERE cv1.code_set=222
      AND (cv1.cdf_meaning=request->meanings[x].cdf_meaning))
     JOIN (l
     WHERE l.location_type_cd=cv1.code_value
      AND l.active_ind=1)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND o.active_ind=1)
     JOIN (cv2
     WHERE cv2.code_value=l.location_cd
      AND cv2.active_ind=1)
    ORDER BY l.organization_id, cv2.display
    HEAD l.organization_id
     lcnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->meanings[x].organizations,ocnt),
     reply->meanings[x].organizations[ocnt].id = l.organization_id, reply->meanings[x].organizations[
     ocnt].name = o.org_name
    DETAIL
     lcnt = (lcnt+ 1), stat = alterlist(reply->meanings[x].organizations[ocnt].locations,lcnt), reply
     ->meanings[x].organizations[ocnt].locations[lcnt].code_value = l.location_cd,
     reply->meanings[x].organizations[ocnt].locations[lcnt].display = cv2.display
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
