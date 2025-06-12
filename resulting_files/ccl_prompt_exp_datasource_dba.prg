CREATE PROGRAM ccl_prompt_exp_datasource:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Data source name :" = "",
  "Group NO (0=DBA)" = 0,
  "Export destination" = ""
  WITH outdev, datasrc, grp,
  dest
 RECORD _ccl_prompt_programs(
   1 qualify_on
     2 control_class_id = f8
     2 program_name = vc
     2 group_no = i4
   1 insert_data
     2 control_class_id = f8
     2 program_name = vc
     2 group_no = i4
     2 display = vc
     2 description = vc
     2 updt_applctx = i4
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_task = i4
 )
 SET prgname = cnvtupper( $DATASRC)
 SET prggroup =  $GRP
 SELECT INTO "nl:"
  cpg.*
  FROM ccl_prompt_programs cpg
  WHERE cpg.control_class_id=0
   AND cpg.program_name=prgname
   AND cpg.group_no=prggroup
  HEAD REPORT
   cnt = 0
  DETAIL
   _ccl_prompt_programs->qualify_on.control_class_id = cpg.control_class_id, _ccl_prompt_programs->
   qualify_on.program_name = cpg.program_name, _ccl_prompt_programs->qualify_on.group_no = cpg
   .group_no,
   _ccl_prompt_programs->insert_data.control_class_id = cpg.control_class_id, _ccl_prompt_programs->
   insert_data.program_name = cpg.program_name, _ccl_prompt_programs->insert_data.group_no = cpg
   .group_no,
   _ccl_prompt_programs->insert_data.display = cpg.display, _ccl_prompt_programs->insert_data.
   description = cpg.description, _ccl_prompt_programs->insert_data.updt_applctx = cpg.updt_applctx,
   _ccl_prompt_programs->insert_data.updt_cnt = cpg.updt_cnt, _ccl_prompt_programs->insert_data.
   updt_dt_tm = cpg.updt_dt_tm, _ccl_prompt_programs->insert_data.updt_task = cpg.updt_task
  WITH nocounter
 ;end select
 CALL echoxml(_ccl_prompt_programs, $DEST)
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   IF ((_ccl_prompt_programs->insert_data.program_name=prgname))
    col 1, "Data source exported to: ",  $DEST
   ELSE
    col 1, "Failed to create export, verify data source name and group"
   ENDIF
   row + 1
  WITH nocounter
 ;end select
END GO
