CREATE PROGRAM cdi_get_clipboard_by_user:dba
 RECORD reply(
   1 pages[*]
     2 cdi_clipboard_id = f8
     2 object_file = vc
     2 anno_file = vc
     2 copy_dt_tm = dq8
     2 media_object_file_ident = vc
     2 media_object_anno_ident = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  c.cdi_clipboard_id, c.object_file, c.anno_file,
  c.copy_dt_tm, c.media_object_file_ident, c.media_object_anno_ident
  FROM cdi_clipboard c
  WHERE (c.copy_user_id=request->copy_user_id)
  ORDER BY c.cdi_clipboard_id
  HEAD REPORT
   count = 0, stat = alterlist(reply->pages,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->pages,(count+ 9))
   ENDIF
   reply->pages[count].cdi_clipboard_id = c.cdi_clipboard_id, reply->pages[count].object_file = c
   .object_file, reply->pages[count].anno_file = c.anno_file,
   reply->pages[count].copy_dt_tm = c.copy_dt_tm, reply->pages[count].media_object_file_ident = c
   .media_object_file_ident, reply->pages[count].media_object_anno_ident = c.media_object_anno_ident,
   reply->pages[count].updt_cnt = c.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->pages,count)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
