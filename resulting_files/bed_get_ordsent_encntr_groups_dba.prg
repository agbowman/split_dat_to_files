CREATE PROGRAM bed_get_ordsent_encntr_groups:dba
 FREE SET reply
 RECORD reply(
   1 encntr_groups[*]
     2 code_value = f8
     2 display = vc
     2 encntr_types[*]
       3 code_value = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET gcnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM code_value c1,
   code_value_group g,
   code_value c2
  PLAN (c1
   WHERE c1.code_set=29100
    AND c1.active_ind=1)
   JOIN (g
   WHERE g.parent_code_value=outerjoin(c1.code_value))
   JOIN (c2
   WHERE c2.code_value=outerjoin(g.child_code_value)
    AND c2.active_ind=outerjoin(1))
  ORDER BY c1.display, c2.display
  HEAD c1.display
   tcnt = 0, gcnt = (gcnt+ 1), stat = alterlist(reply->encntr_groups,gcnt),
   reply->encntr_groups[gcnt].code_value = c1.code_value, reply->encntr_groups[gcnt].display = c1
   .display
  HEAD c2.display
   IF (c2.code_value > 0)
    tcnt = (tcnt+ 1), stat = alterlist(reply->encntr_groups[gcnt].encntr_types,tcnt), reply->
    encntr_groups[gcnt].encntr_types[tcnt].code_value = c2.code_value,
    reply->encntr_groups[gcnt].encntr_types[tcnt].display = c2.display
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (gcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
