CREATE PROGRAM dummy_mpages_pos:dba
 PROMPT
  "Output Device: = " = "MINE",
  "position code" = 0.0
  WITH outdev, position_code
 FREE RECORD reply
 RECORD reply(
   1 tab_name_list[*]
     2 tab_name = vc
     2 mpage_list[*]
       3 mpage_id = f8
       3 mpage_display_txt = vc
 ) WITH persistscript
 IF (( $POSITION_CODE=111.0))
  SET stat = alterlist(reply->tab_name_list,1)
  SET reply->tab_name_list[1].tab_name = "Tab-One"
  SET stat = alterlist(reply->tab_name_list[1].mpage_list,2)
  SET reply->tab_name_list[1].mpage_list[1].mpage_id = 11111.0
  SET reply->tab_name_list[1].mpage_list[1].mpage_display_txt = "MPAGE ONE"
  SET reply->tab_name_list[1].mpage_list[2].mpage_id = 22222.0
  SET reply->tab_name_list[1].mpage_list[2].mpage_display_txt = "MPAGE TWO"
 ELSE
  SET stat = alterlist(reply->tab_name_list,0)
 ENDIF
#exit_script
END GO
