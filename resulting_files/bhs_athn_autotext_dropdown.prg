CREATE PROGRAM bhs_athn_autotext_dropdown
 FREE RECORD orequest
 RECORD orequest(
   1 uuids[*]
     2 drop_list_uuid = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    SET stat = alterlist(orequest->uuids,cnt)
    SET orequest->uuids[cnt].drop_list_uuid = t_line
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->uuids,cnt)
    SET orequest->uuids[cnt].drop_list_uuid = t_line2
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET stat = tdbexecute(600005,3202004,969556,"REC",orequest,
  "REC",oreply)
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
