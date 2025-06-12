CREATE PROGRAM afc_get_iface_file_by_name:dba
 SET afc_get_iface_file_by_name_vrsn = 000
 DECLARE lcount = i4 WITH noconstant(0)
 DECLARE lposition = i4 WITH noconstant(0)
 FREE RECORD reply
 RECORD reply(
   1 file_name = vc
   1 qual[*]
     2 interface_file_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->file_name = request->file_name
 SELECT INTO "Nl:"
  FROM interface_file ifl
  WHERE cnvtupper(trim(ifl.file_name,3))=parser(concat('"',"*",cnvtupper(trim(request->file_name,3)),
    "*",'"'))
  ORDER BY ifl.interface_file_id DESC
  DETAIL
   lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].interface_file_id
    = ifl.interface_file_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echorecord(reply)
END GO
