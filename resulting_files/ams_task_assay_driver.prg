CREATE PROGRAM ams_task_assay_driver
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = "",
  "Select Audit/Commit" = ""
  WITH outdev, directory, inputfile,
  auditcommit
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 DECLARE line1 = c1000
 DECLARE line2 = c1000
 DECLARE j = i4
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,"/",infile)
 FREE DEFINE rtl2
 DEFINE rtl2 "CCLUSERDIR:add_task.csv"
 FREE RECORD file_content
 RECORD file_content(
   1 qual[*]
     2 catalog_display = vc
     2 assay_display = vc
     2 long_desc = vc
     2 result_type = vc
     2 required = vc
     2 repeat_ind = vc
     2 prompt_ind = vc
     2 post_prompt_ind = vc
     2 restrict_display_ind = vc
     2 resource = vc
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(file_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(file_content->qual,(row_count+ 9))
     ENDIF
     file_content->qual[row_count].catalog_display = piece(line1,",",1,"Not Found"), file_content->
     qual[row_count].assay_display = piece(line1,",",2,"Not Found"), file_content->qual[row_count].
     long_desc = piece(line1,",",3,"Not Found"),
     file_content->qual[row_count].result_type = piece(line1,",",4,"Not Found"), file_content->qual[
     row_count].required = piece(line1,",",5,"Not Found"), file_content->qual[row_count].repeat_ind
      = piece(line1,",",6,"Not Found"),
     file_content->qual[row_count].prompt_ind = piece(line1,",",7,"Not Found"), file_content->qual[
     row_count].post_prompt_ind = piece(line1,",",8,"Not Found"), file_content->qual[row_count].
     restrict_display_ind = piece(line1,",",9,"Not Found"),
     file_content->qual[row_count].resource = piece(line1,",",10,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->qual,row_count)
  WITH nocounter
 ;end select
 IF (( $AUDITCOMMIT="Audit"))
  SELECT INTO  $OUTDEV
   qual_catalog_display = substring(1,30,file_content->qual[d1.seq].catalog_display),
   qual_assay_display = substring(1,30,file_content->qual[d1.seq].assay_display), qual_long_desc =
   substring(1,30,file_content->qual[d1.seq].long_desc),
   qual_result_type = substring(1,30,file_content->qual[d1.seq].result_type), qual_required =
   substring(1,30,file_content->qual[d1.seq].required), qual_repeat_ind = substring(1,30,file_content
    ->qual[d1.seq].repeat_ind),
   qual_prompt_ind = substring(1,30,file_content->qual[d1.seq].prompt_ind), qual_post_prompt_ind =
   substring(1,30,file_content->qual[d1.seq].post_prompt_ind), qual_restrict_display_ind = substring(
    1,30,file_content->qual[d1.seq].restrict_display_ind),
   qual_resource = substring(1,30,file_content->qual[d1.seq].resource)
   FROM (dummyt d1  WITH seq = value(size(file_content->qual,5)))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSE
  EXECUTE ams_add_task_assay:group01
  SET failed_mess = true
  SET serrmsg = "Successfully Inserted"
 ENDIF
#exit_script
 SET script_ver = " 000 05/01/15 AK032157         Initial Release "
END GO
