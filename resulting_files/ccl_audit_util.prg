CREATE PROGRAM ccl_audit_util
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "Enter mode (QUERY,TEST): " = "TEST",
  "Enter audit event name (default): " = "DEFAULT",
  "Enter audit event type (default): " = "DEFAULT"
  WITH outdev, mode, audit_name,
  audit_type
 DECLARE errmsg = c255
 SET errmsg = fillstring(132," ")
 SET failed = "F"
 DECLARE infocnt = i4
 SET mode = cnvtupper( $2)
 SET event_name = trim( $3)
 SET event_type = trim( $4)
 IF (mode="TEST")
  RECORD request1(
    1 qual[3]
      2 person_id = f8
    1 person_id = f8
  )
  RECORD reply(
    1 info[*]
      2 line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET request1->person_id = reqinfo->updt_id
  SET reply->status_data.status = "S"
  IF (( $3="DEFAULT")
   AND ( $4="DEFAULT"))
   SET infocnt = 3
   SET stat = alterlist(reply->info,3)
   SET reply->info[1].line =
   "CCLAUDIT Test. Default event name and type specified. Test auditing for query transactions..."
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "1", "1", "2",
   "5", request1->person_id, " "
   SET reply->info[2].line = concat("Event_name=Query Person, Event_type=Demographics, Status= ",
    build(reply->status_data.status))
   EXECUTE cclaudit 0, "Query Encounter", "Information",
   "1", "1", "2",
   "5", request1->person_id, " "
   SET reply->info[3].line = concat("Event_name=Query Encounter, Event_type=Information, Status= ",
    build(reply->status_data.status))
  ELSE
   SET infocnt = 2
   SET stat = alterlist(reply->info,2)
   SET reply->info[1].line = "CCLAUDIT Test..."
   EXECUTE cclaudit 0, value(event_name), value(event_type),
   "1", "1", "2",
   "5", request1->person_id, " "
   SET reply->info[2].line = concat("Event_name=",event_name,", Event_type= ",event_type,", Status= ",
    build(reply->status_data.status))
  ENDIF
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET failed = "T"
   SET stat = alterlist(reply->info,(infocnt+ 2))
   SET reply->info[(infocnt+ 1)] = "Errors:"
   SET reply->info[(infocnt+ 2)] = errmsg
   SET infocnt = (infocnt+ 2)
  ENDIF
  CALL echorecord(reply)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = value(infocnt))
   DETAIL
    col 0, reply->info[d.seq].line, row + 1
   WITH nocounter
  ;end select
 ELSEIF (mode="QUERY")
  SELECT INTO  $OUTDEV
   a.audit_event_nbr, ar.audit_request_nbr, a.audit_ind,
   ar.request_nbr, an.audit_name, at.audit_type,
   a.updt_dt_tm
   FROM audit_event a,
    audit_request ar,
    audit_name_def an,
    audit_type_def at
   PLAN (an
    WHERE an.audit_name=patstring(event_name))
    JOIN (at
    WHERE at.audit_type=patstring(event_type))
    JOIN (a
    WHERE a.audit_name_def_nbr=an.audit_name_def_nbr
     AND a.audit_ind=1
     AND a.audit_type_def_nbr=at.audit_type_def_nbr)
    JOIN (ar
    WHERE ar.audit_event_nbr=a.audit_event_nbr)
   WITH format, separator = " ", nocounter
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   "CCLAUDIT: Invalid mode"
   WITH nocounter
  ;end select
 ENDIF
END GO
