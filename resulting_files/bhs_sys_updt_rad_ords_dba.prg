CREATE PROGRAM bhs_sys_updt_rad_ords:dba
 PROMPT
  "Enter File name" = "<<File Name without extension>>",
  "Mode" = "TEST"
  WITH outdev, mode
 SET filepath = build("bhscust:", $1,".txt")
 CALL echo(build("Reading File:",filepath))
 IF (findfile(filepath) > 0)
  CALL echo("Found File")
 ELSE
  CALL echo("Did not find the file, will exit")
  GO TO exit_code
 ENDIF
 FREE RECORD ordlist
 RECORD ordlist(
   1 qual[*]
     2 oid = f8
 )
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (trim(r.line,3) > " ")
    cnt = (cnt+ 1), stat = alterlist(ordlist->qual,cnt), ordlist->qual[cnt].oid = cnvtreal(r.line)
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(ordlist->qual,5))
   SET oid = ordlist->qual[x].oid
   CALL echo(build2("Updating Orders Table. Order Id;",oid))
   UPDATE  FROM orders o
    SET o.order_status_cd = 2548, o.dept_status_cd = 9316, o.sch_state_cd = 4548,
     o.last_action_sequence = (o.last_action_sequence - 1)
    WHERE o.order_id=oid
    WITH nocounter
   ;end update
   CALL echo(build2("deleting ",oid,"From Order action table"))
   DELETE  FROM order_action oa
    WHERE oa.order_id=oid
     AND oa.dept_status_cd=9314
    WITH nocounter
   ;end delete
   CALL echo(build2("Updating Order radiology table. Order ID ",oid))
   UPDATE  FROM order_radiology ord
    SET ord.cancel_by_id = 0, ord.cancel_dt_tm = null, ord.exam_status_cd = 4226,
     ord.report_status_cd = 4265
    WHERE ord.order_id=oid
     AND ord.exam_status_cd=4223
    WITH nocounter
   ;end update
   CALL echo(build2("deleting order id ",oid,"from clinical event with canceled status"))
   DELETE  FROM clinical_event ce
    WHERE ce.order_id=oid
     AND ce.event_tag="Canceled"
   ;end delete
   IF (( $2 != "TEST"))
    COMMIT
   ENDIF
   CALL echo(build2("update inprogress record in clincial event table. Order id: ",oid))
   UPDATE  FROM clinical_event ce
    SET ce.event_end_dt_tm = cnvtdatetime(curdate,curtime3), ce.valid_until_dt_tm = cnvtdatetime(
      cnvtdate(12312100),0), ce.authentic_flag = 1
    WHERE ce.order_id=oid
     AND ce.event_tag="In Progress"
    WITH nocounter
   ;end update
   CALL echo(build2("Mode: ", $2))
   IF (( $2 != "TEST"))
    COMMIT
   ENDIF
 ENDFOR
#exit_code
END GO
