CREATE PROGRAM bhs_athn_forward_order
 RECORD orequest(
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
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET orequest->notification_action_flag = 1
 SET stat = alterlist(orequest->notification_list,1)
 SET orequest->notification_list[1].order_notification_id =  $2
 IF (( $3 > 0))
  SET orequest->notification_list[1].from_prsnl_id =  $3
 ENDIF
 IF (( $4 > 0))
  SET orequest->notification_list[1].from_prsnl_id =  $4
 ENDIF
 IF (( $5 > " "))
  SET t_line =  $5
  SET cnt = 0
  WHILE (done=0)
    IF (findstring(",",t_line)=0)
     SET cnt = (cnt+ 1)
     SET stat = alterlist(orequest->notification_list[1].to_prsnl_list,cnt)
     SET orequest->notification_list[1].to_prsnl_list[cnt].to_prsnl_id = cnvtreal(t_line)
     SET done = 1
    ELSE
     SET cnt = (cnt+ 1)
     SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
     SET stat = alterlist(orequest->notification_list[1].to_prsnl_list,cnt)
     SET orequest->notification_list[1].to_prsnl_list[cnt].to_prsnl_id = cnvtreal(t_line2)
     SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
    ENDIF
  ENDWHILE
 ENDIF
 IF (( $6 > " "))
  SET done = 0
  SET t_line =  $6
  SET cnt = 0
  WHILE (done=0)
    IF (findstring(",",t_line)=0)
     SET cnt = (cnt+ 1)
     SET stat = alterlist(orequest->notification_list[1].to_prsnl_group_list,cnt)
     SET orequest->notification_list[1].to_prsnl_group_list[cnt].to_prsnl_group_id = cnvtreal(t_line)
     SET done = 1
    ELSE
     SET cnt = (cnt+ 1)
     SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
     SET stat = alterlist(orequest->notification_list[1].to_prsnl_group_list,cnt)
     SET orequest->notification_list[1].to_prsnl_group_list[cnt].to_prsnl_group_id = cnvtreal(t_line2
      )
     SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
    ENDIF
  ENDWHILE
 ENDIF
 IF (( $7 > " "))
  SET orequest->notification_list[1].notification_comment =  $7
 ENDIF
 SET stat = tdbexecute(600005,3202004,560438,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
