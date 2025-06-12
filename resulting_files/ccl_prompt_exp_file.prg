CREATE PROGRAM ccl_prompt_exp_file
 PROMPT
  "Folder Name : " = "/PDDOC/GROUP0",
  "File Name   : " = "CCL_DLG_EXAMPLE1",
  "Export file name : " = "ccl_prompt_docfile.xml"
  WITH folder, file, dest
 RECORD _ccl_prompt_file(
   1 qualify_on
     2 folder_name = vc
     2 file_name = vc
   1 insert_data[*]
     2 folder_name = vc
     2 file_name = vc
     2 collation_seq = i4
     2 content = vc
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 DECLARE content = vc WITH notrim
 SET foldername = concat(trim(cnvtupper( $FOLDER)),"/")
 SET filename = cnvtupper( $FILE)
 SELECT INTO "nl:"
  pf.*
  FROM ccl_prompt_file pf
  WHERE cnvtupper(pf.folder_name)=foldername
   AND cnvtupper(pf.file_name)=filename
  ORDER BY pf.collation_seq
  DETAIL
   item = (size(_ccl_prompt_file->insert_data,5)+ 1), stat = alterlist(_ccl_prompt_file->insert_data,
    item), _ccl_prompt_file->qualify_on.folder_name = pf.folder_name,
   _ccl_prompt_file->qualify_on.file_name = pf.file_name, _ccl_prompt_file->insert_data[item].
   folder_name = pf.folder_name, _ccl_prompt_file->insert_data[item].file_name = pf.file_name,
   _ccl_prompt_file->insert_data[item].collation_seq = pf.collation_seq, _ccl_prompt_file->
   insert_data[item].content = pf.content, _ccl_prompt_file->insert_data[item].updt_applctx = pf
   .updt_applctx,
   _ccl_prompt_file->insert_data[item].updt_cnt = pf.updt_cnt, _ccl_prompt_file->insert_data[item].
   updt_dt_tm = pf.updt_dt_tm, _ccl_prompt_file->insert_data[item].updt_id = pf.updt_id,
   _ccl_prompt_file->insert_data[item].updt_task = pf.updt_task
  WITH nocounter
 ;end select
 CALL echoxml(_ccl_prompt_file, $DEST)
END GO
