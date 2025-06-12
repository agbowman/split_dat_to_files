CREATE PROGRAM bed_get_ps_sel_reltn_limits:dba
 FREE SET reply
 RECORD reply(
   1 reltns[*]
     2 display = vc
     2 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET setup_id = 0
 SET pos_cd = 0
 IF (validate(request->position_code_value))
  SET pos_cd = request->position_code_value
 ENDIF
 SELECT INTO "nl:"
  FROM pm_sch_setup p
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.person_id=0
    AND p.position_cd=pos_cd)
  DETAIL
   setup_id = p.setup_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pm_sch_filter p
  PLAN (p
   WHERE p.setup_id=setup_id
    AND p.meaning="FAMILY_LIMIT"
    AND p.data_type_flag=0)
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->reltns,rcnt), reply->reltns[rcnt].value = p.value
  WITH nocounter
 ;end select
 FOR (x = 1 TO rcnt)
   SET a = findstring("F",reply->reltns[x].value)
   SET b = textlen(reply->reltns[x].value)
   SET disp1 = substring(2,(a - 2),reply->reltns[x].value)
   SET disp2 = substring((a+ 1),(b - a),reply->reltns[x].value)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_value=cnvtreal(disp1))
    DETAIL
     reply->reltns[x].display = c.display
    WITH nocounter
   ;end select
   IF (disp2 != "0")
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_value=cnvtreal(disp2))
     DETAIL
      reply->reltns[x].display = concat(reply->reltns[x].display," - ",c.display)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
