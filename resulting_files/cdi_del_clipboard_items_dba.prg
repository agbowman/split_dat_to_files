CREATE PROGRAM cdi_del_clipboard_items:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(value(size(request->pages,5))), protect
 DECLARE num = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (count > 0)
  DELETE  FROM cdi_clipboard c
   WHERE expand(num,1,count,c.cdi_clipboard_id,request->pages[num].cdi_clipboard_id)
   WITH nocounter
  ;end delete
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
