CREATE PROGRAM co_get_list_update_dt_tm:dba
 RECORD reply(
   1 encntrs[*]
     2 encntr_id = f8
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_string_builder(p1) = vc
 IF (size(request->encntrs,5) > 0)
  SET enctr_id_query_string = parse_string_builder("")
  SELECT INTO "nl:"
   FROM dcp_patient_list pl,
    dcp_pl_argument pa,
    dcp_pl_custom_entry pce
   WHERE (pl.patient_list_id=request->patient_list_id)
    AND pa.patient_list_id=pl.patient_list_id
    AND pa.argument_name="careteam_id"
    AND pce.prsnl_group_id=pa.parent_entity_id
    AND parser(enctr_id_query_string)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,50)=1)
     stat = alterlist(reply->encntrs,(count+ 49))
    ENDIF
    reply->encntrs[count].encntr_id = pce.encntr_id, reply->encntrs[count].updt_dt_tm = pce
    .updt_dt_tm
   FOOT REPORT
    stat = alterlist(reply->encntrs,count)
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 SUBROUTINE parse_string_builder(p1)
   SET parse_string = fillstring(1000," ")
   SET parse_string = "pce.encntr_id in ("
   SET listsize = size(request->encntrs,5)
   FOR (x = 1 TO listsize)
     IF ((request->encntrs[x].encntr_id > 0))
      IF (x > 1)
       SET parse_string = build(parse_string,",")
      ENDIF
      SET parse_string = build(parse_string,cnvtstring(request->encntrs[x].encntr_id),".0")
     ENDIF
   ENDFOR
   SET parse_string = build(parse_string,")")
   CALL echo(parse_string)
   RETURN(parse_string)
 END ;Subroutine
END GO
