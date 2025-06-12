CREATE PROGRAM bhs_prax_tdb_ord_notification
 RECORD requestin(
   1 notification_action_flag = i2
   1 notification_list[*]
     2 order_notification_id = f8
     2 notification_comment = vc
     2 notification_reason_cd = f8
     2 to_prsnl_list[*]
       3 to_prsnl_id = f8
     2 from_prsnl_id = f8
     2 to_prsnl_group_list[*]
       3 to_prsnl_group_id = f8
     2 from_prsnl_group_id = f8
 )
 SET requestin->notification_action_flag = 2
 SET stat = alterlist(requestin->notification_list,1)
 SET requestin->notification_list[1].order_notification_id =  $2
 SET requestin->notification_list[1].notification_comment =  $3
 SET requestin->notification_list[1].notification_reason_cd =  $4
 SET requestin->notification_list[1].from_prsnl_id = 1.00
 SET stat = alterlist(requestin->notification_list[1].to_prsnl_list,1)
 SET requestin->notification_list[1].to_prsnl_list[1].to_prsnl_id = 0
 DECLARE jsonout = vc
 SET stat = tdbexecute(967100,967350,560438,"REC",requestin,
  "JSON",jsonout)
 CALL echo(build("TDBEXECUTE=",stat))
 CALL echorecord(requestin)
 CALL echo(jsonout)
 SELECT INTO  $1
  jsonout
  FROM dummyt d
  HEAD REPORT
   col 01, jsonout
  WITH format, separator = " ", maxcol = 32000
 ;end select
END GO
