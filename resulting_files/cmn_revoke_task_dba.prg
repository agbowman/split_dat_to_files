CREATE PROGRAM cmn_revoke_task:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 qual[1]
       2 app_group_cd = f8
       2 task_number = i4
   )
   SET request_details->qual[1].app_group_cd = cnvtreal(file_content->qual[i].app_group_cd)
   SET request_details->qual[1].task_number = cnvtint(file_content->qual[i].task_number)
   EXECUTE ta_del_from_task_access:dba  WITH replace("REQUEST",request_details)
 ENDFOR
 SET last_mod = "000  31/03/2016 KH043067 and VB035883"
END GO
