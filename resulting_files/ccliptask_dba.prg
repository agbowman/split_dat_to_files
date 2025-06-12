CREATE PROGRAM ccliptask:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "ENTER MODULE NAME:           " = "*",
  "ENTER TASK NAME:             " = "*"
 SELECT INTO  $1
  module = i.module_k, task_name = i.task_name_k, i.status,
  type = i.prog_type, i.prog_file, sec = i.security,
  param = i.program_params, fof = i.function_keys, date = i.idate,
  time = i.itime"#####", id = i.iid
  FROM (ip00_1 i  WITH access_code = none)
  WHERE i.entity="01"
   AND i.rec_type="TASK"
   AND (i.module_k= $2)
   AND (i.task_name_k= $3)
  WITH check
 ;end select
END GO
