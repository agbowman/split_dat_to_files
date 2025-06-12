CREATE PROGRAM dcp_get_entity_list:dba
 RECORD reply(
   1 qual[*]
     2 id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE table_name = vc WITH noconstant(fillstring(1000,""))
 DECLARE display_field = vc WITH noconstant(fillstring(1000,""))
 DECLARE id_field = vc WITH noconstant(fillstring(1000,""))
 DECLARE criteria = vc WITH noconstant(fillstring(1000,""))
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE qualsz = i4 WITH constant(size(request->qual,5))
 DECLARE x = i4 WITH noconstant(0)
 DECLARE script_name = vc WITH noconstant(fillstring(100,""))
 SET script_name = cnvtupper(trim(request->script))
 IF (script_name != "")
  EXECUTE value(script_name)
 ELSE
  SET id_field = trim(request->id_field)
  SET table_name = trim(request->table_name)
  SET display_field = trim(request->display_field)
  IF (qualsz > 0)
   SET criteria = concat("expand(x, 1, ",trim(cnvtstring(qualsz)),", ",id_field,
    ", request->qual[x].id)")
   SET criteria = concat(criteria," and ",trim(request->criteria))
  ELSE
   SET criteria = trim(request->criteria)
  ENDIF
  SET reply->status_data.status = "F"
  SELECT INTO "nl:"
   FROM (parser(table_name) a)
   WHERE parser(criteria)
   ORDER BY parser(display_field)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->qual,(cnt+ 9))
    ENDIF
    reply->qual[cnt].display = parser(concat("a.",display_field)), reply->qual[cnt].id = parser(
     concat("a.",id_field))
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
