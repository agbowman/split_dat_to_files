CREATE PROGRAM bed_get_fn_edareas:dba
 FREE SET reply
 RECORD reply(
   1 edareas[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 RECORD room(
   1 qual[*]
     2 cd = f8
 )
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM location_group l
  PLAN (l
   WHERE (l.parent_loc_cd=request->ed_code_value)
    AND l.root_loc_cd=0
    AND l.active_ind=1)
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(room->qual,rcnt), room->qual[rcnt].cd = l.child_loc_cd
  WITH nocounter
 ;end select
 IF (rcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_name_value b,
   (dummyt d  WITH seq = value(rcnt)),
   br_name_value b2
  PLAN (b
   WHERE b.br_nv_key1="EDAREA")
   JOIN (d)
   JOIN (b2
   WHERE b2.br_nv_key1="EDAREAROOMRELTN"
    AND cnvtreal(trim(b2.br_name))=b.br_name_value_id
    AND (cnvtreal(b2.br_value)=room->qual[d.seq].cd))
  ORDER BY b.br_value
  HEAD b.br_value
   cnt = (cnt+ 1), stat = alterlist(reply->edareas,cnt), reply->edareas[cnt].id = b.br_name_value_id,
   reply->edareas[cnt].name = b.br_value
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->edareas,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
