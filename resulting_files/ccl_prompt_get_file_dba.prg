CREATE PROGRAM ccl_prompt_get_file:dba
 DECLARE foldername = vc
 DECLARE content = vc
 RECORD reply(
   1 folder_name = c100
   1 file_name = c100
   1 content = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET foldername = concat(trim(cnvtupper(request->folder_name)),"/")
 SET filename = trim(cnvtupper(request->file_name))
 SET reply->folder_name = foldername
 SET reply->file_name = filename
 SELECT INTO "nl:"
  pf.*
  FROM ccl_prompt_file pf
  WHERE cnvtupper(trim(pf.folder_name))=foldername
   AND cnvtupper(trim(pf.file_name))=filename
  ORDER BY pf.collation_seq
  DETAIL
   content = notrim(concat(content,pf.content))
 ;end select
 SET reply->content = notrim(content)
 SET reply->status_data.status = "S" WITH nocounter
END GO
