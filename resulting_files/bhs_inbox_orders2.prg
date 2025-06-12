CREATE PROGRAM bhs_inbox_orders2
 EXECUTE bhs_sys_stand_subroutine
 DECLARE o_canceled_cd = f8
 DECLARE o_discontinued_cd = f8
 DECLARE o_deleted_cd = f8
 DECLARE line = vc
 SET o_canceled_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET o_discontinued_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET o_deleted_cd = uar_get_code_by("MEANING",6004,"DELETED")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 pid = c15
     2 ocnt = i4
     2 o[*]
       3 oid = c15
 )
 SELECT INTO "NL:"
  n.to_prsnl_id, n.order_id
  FROM order_notification n
  PLAN (n
   WHERE n.to_prsnl_id > 1
    AND n.notification_status_flag=1
    AND n.notification_type_flag != 1)
  ORDER BY n.to_prsnl_id
  HEAD REPORT
   c = 0, cc = 0
  HEAD n.to_prsnl_id
   c = (c+ 1), stat = alterlist(temp->qual,c), temp->qual[c].pid = cnvtstring(n.to_prsnl_id),
   cc = 0, stat = alterlist(temp->qual[c].o,10)
  DETAIL
   cc = (cc+ 1)
   IF (mod(cc,10)=1)
    stat = alterlist(temp->qual[c].o,(cc+ 9))
   ENDIF
   temp->qual[c].o[cc].oid = cnvtstring(n.order_id)
  FOOT  n.to_prsnl_id
   temp->qual[c].ocnt = cc, stat = alterlist(temp->qual[c].o,cc), cc = 0
  WITH nocounter
 ;end select
 CALL echo(build("first qual:",curqual))
 SELECT INTO "inboxorders"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE p.person_id=cnvtint(temp->qual[d.seq].pid))
  HEAD REPORT
   line = build(',"',"Phys Name",'","',"OrdCnt",'",',
    "Position",'",'), col 0, line,
   row + 1
  DETAIL
   phyname = concat(trim(p.name_last)," ",trim(p.name_first)), ordcnt = temp->qual[d.seq].ocnt, line
    = build(',"',phyname,'","',ordcnt,'",'),
   col 0, line, row + 1
  WITH nocounter, format = variable, maxcol = 200,
   maxrow = 1
 ;end select
 CALL echo(build("second qual:",curqual))
 CALL emailfile("inboxorders.dat","inboxorders.csv","cisard@bhs.org","Inbox Orders",1)
#exit_prog
END GO
