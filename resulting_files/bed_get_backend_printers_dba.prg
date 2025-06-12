CREATE PROGRAM bed_get_backend_printers:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 printers[*]
      2 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE printer_code_value = f8 WITH constant(uar_get_code_by("MEANING",3000,"PRINTER")), protect
 SET printercnt = 0
 SELECT INTO "nl:"
  FROM output_dest od,
   device d
  PLAN (od
   WHERE od.output_dest_cd > 0
    AND od.name > " ")
   JOIN (d
   WHERE d.device_cd=od.device_cd
    AND d.device_type_cd=printer_code_value)
  DETAIL
   printercnt = (printercnt+ 1), stat = alterlist(reply->printers,printercnt), reply->printers[
   printercnt].name = od.name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
