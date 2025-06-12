CREATE PROGRAM bsv_get_uom_conversion:dba
 SET modify = predeclare
 IF (validate(rx_request)=0)
  RECORD rx_request(
    1 qual[*]
      2 from_value = f8
      2 from_uom_cd = f8
      2 to_uom_cd = f8
      2 uom_type_flag = i2
  ) WITH persistscript
 ENDIF
 IF (validate(rx_reply)=0)
  RECORD rx_reply(
    1 qual[*]
      2 from_value = f8
      2 from_uom_cd = f8
      2 from_uom_display = vc
      2 to_value = f8
      2 to_uom_cd = f8
      2 to_uom_display = vc
      2 uom_type_flag = i2
      2 status = c1
      2 status_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 DECLARE lreq_size = i4 WITH protect, constant(size(rx_request->qual,5))
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dstarttime3 = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE scdfmeaning = vc WITH protect, noconstant("")
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 CALL echo(sline)
 CALL echo("********** BEGIN BSV_GET_UOM_CONVERSION **********")
 CALL echo(sline)
 CALL echorecord(rx_request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "Request was empty"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(rx_reply->qual,lreq_size)
 FOR (lcnt = 1 TO lreq_size)
   SET rx_reply->qual[lcnt].from_value = rx_request->qual[lcnt].from_value
   SET rx_reply->qual[lcnt].from_uom_cd = rx_request->qual[lcnt].from_uom_cd
   SET rx_reply->qual[lcnt].to_uom_cd = rx_request->qual[lcnt].to_uom_cd
   SET rx_reply->qual[lcnt].uom_type_flag = rx_request->qual[lcnt].uom_type_flag
   SET rx_reply->qual[lcnt].status = "F"
   SET scdfmeaning = trim(uar_get_code_meaning(rx_request->qual[lcnt].from_uom_cd),3)
   IF ((rx_reply->qual[lcnt].from_uom_cd > 0)
    AND uar_get_code_by("MEANING",54,scdfmeaning) > 0)
    SET rx_reply->qual[lcnt].from_uom_display = uar_get_code_display(rx_request->qual[lcnt].
     from_uom_cd)
   ELSE
    SET rx_reply->qual[lcnt].status_msg = "Invalid from_uom_cd"
   ENDIF
   SET scdfmeaning = trim(uar_get_code_meaning(rx_request->qual[lcnt].to_uom_cd),3)
   IF ((rx_reply->qual[lcnt].to_uom_cd > 0)
    AND uar_get_code_by("MEANING",54,scdfmeaning) > 0)
    SET rx_reply->qual[lcnt].to_uom_display = uar_get_code_display(rx_request->qual[lcnt].to_uom_cd)
   ELSE
    IF (textlen(rx_reply->qual[lcnt].status_msg)=0)
     SET rx_reply->qual[lcnt].status_msg = "Invalid to_uom_cd"
    ELSE
     SET rx_reply->qual[lcnt].status_msg = "Invalid from_uom_cd and to_uom_cd"
    ENDIF
   ENDIF
   IF (textlen(rx_reply->qual[lcnt].status_msg)=0)
    SET rx_reply->qual[lcnt].status_msg = "Units not convertible"
   ENDIF
 ENDFOR
 SET lcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lreq_size)),
   dose_calculator_uom dcu,
   dose_calculator_uom dcu2
  PLAN (d)
   JOIN (dcu
   WHERE (dcu.uom_cd=rx_reply->qual[d.seq].from_uom_cd)
    AND (dcu.uom_type_flag=rx_reply->qual[d.seq].uom_type_flag)
    AND ((dcu.uom_base_nbr+ 0) > 0))
   JOIN (dcu2
   WHERE (dcu2.uom_cd=rx_reply->qual[d.seq].to_uom_cd)
    AND (dcu2.uom_type_flag=rx_reply->qual[d.seq].uom_type_flag)
    AND ((dcu2.uom_base_nbr+ 0)=dcu.uom_base_nbr))
  ORDER BY d.seq
  HEAD d.seq
   IF (dcu2.uom_multiply_factor > 0)
    lcnt = (lcnt+ 1), rx_reply->qual[d.seq].to_value = ((rx_reply->qual[d.seq].from_value * dcu
    .uom_multiply_factor)/ dcu2.uom_multiply_factor), rx_reply->qual[d.seq].status = "S",
    rx_reply->qual[d.seq].status_msg = "Successful conversion"
   ELSE
    rx_reply->qual[d.seq].status = "F", rx_reply->qual[d.seq].status_msg =
    "To_uom_cd multiply factor less than or equal to zero"
   ENDIF
  WITH nocounter
 ;end select
 IF (lcnt=lreq_size)
  SET sscriptstatus = "S"
 ELSEIF (lcnt > 0)
  SET sscriptstatus = "P"
 ELSE
  SET sscriptstatus = "Z"
  SET sscriptmsg = "No conversions were performed"
 ENDIF
#exit_script
 SET rx_reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET rx_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET rx_reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET rx_reply->status_data.subeventstatus[1].targetobjectname = "bsc_get_uom_conversion"
  SET rx_reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET rx_reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET rx_reply->status_data.subeventstatus[1].operationname = "UOM CONVERSION"
  SET rx_reply->status_data.subeventstatus[1].targetobjectname = "bsc_get_uom_conversion"
  SET rx_reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="P")
  SET rx_reply->status_data.subeventstatus[1].operationstatus = "P"
  SET rx_reply->status_data.subeventstatus[1].operationname = "UOM CONVERSION"
  SET rx_reply->status_data.subeventstatus[1].targetobjectname = "bsc_get_uom_conversion"
  SET rx_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Some conversions were performed, check individual status"
 ELSE
  SET rx_reply->status_data.subeventstatus[1].operationstatus = "S"
  SET rx_reply->status_data.subeventstatus[1].operationname = "UOM CONVERSION"
  SET rx_reply->status_data.subeventstatus[1].targetobjectname = "bsc_get_uom_conversion"
  SET rx_reply->status_data.subeventstatus[1].targetobjectvalue = "All conversions were performed"
 ENDIF
 CALL echo(sline)
 CALL echorecord(rx_reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime3)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 001")
 CALL echo("Mod Date: 03/21/2013")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END BSV_GET_UOM_CONVERSION **********")
 CALL echo(sline)
END GO
