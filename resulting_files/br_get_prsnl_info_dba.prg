CREATE PROGRAM br_get_prsnl_info:dba
 FREE SET reply
 RECORD reply(
   1 item_list[*]
     2 br_prsnl_id = f8
     2 name_full_formatted = vc
     2 username = vc
     2 br_client_id = f8
     2 active_ind = i2
     2 name_last = vc
     2 name_first = vc
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = vc
     2 email = vc
     2 client[*]
       3 br_client_id = f8
       3 br_client_name = vc
       3 slist[*]
         4 item_type = vc
         4 item_mean = vc
         4 item_disp = vc
       3 sclist[*]
         4 item_type = vc
         4 item_mean = vc
         4 item_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4
 DECLARE start_name = vc
 DECLARE cloop = i4
 DECLARE repcnt = i4
 DECLARE parser_str = vc
 SET repcnt = 0
 SET count1 = 0
 SET scnt = 0
 SET reply->status_data.status = "F"
 SET count1 = size(request->item_list,5)
 FOR (cloop = 1 TO count1)
   CALL echo(build("cloop:",cloop))
   SET start_name = ""
   SET start_name = cnvtupper(request->item_list[cloop].username)
   CALL echo(build("br_prsnl_id:",request->item_list[cloop].br_prsnl_id))
   CALL echo(build("username:",request->item_list[cloop].username))
   SET parser_str = ""
   IF ((request->item_list[cloop].br_prsnl_id > 0))
    SET parser_str = " value(request->item_list[cloop].br_prsnl_id) = p.br_prsnl_id "
   ENDIF
   IF ((request->item_list[cloop].username > ""))
    IF (parser_str > "")
     SET parser_str = concat(parser_str,
      " and cnvtupper(p.username) = cnvtupper(value(request->item_list[cloop].username))")
    ELSE
     SET parser_str = " cnvtupper(p.username) = cnvtupper(value(request->item_list[cloop].username))"
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    p.name_full_formatted, p.br_prsnl_id, p.username
    FROM br_prsnl p,
     br_client_prsnl_reltn bcpr,
     br_client bc
    PLAN (p
     WHERE parser(parser_str))
     JOIN (bcpr
     WHERE bcpr.br_prsnl_id=outerjoin(p.br_prsnl_id))
     JOIN (bc
     WHERE bc.br_client_id=outerjoin(bcpr.br_client_id))
    HEAD p.br_prsnl_id
     repcnt = (repcnt+ 1), stat = alterlist(reply->item_list,repcnt), reply->item_list[repcnt].
     br_prsnl_id = p.br_prsnl_id,
     reply->item_list[repcnt].name_full_formatted = p.name_full_formatted, reply->item_list[repcnt].
     username = p.username, reply->item_list[repcnt].active_ind = p.active_ind,
     reply->item_list[repcnt].name_last = p.name_last, reply->item_list[repcnt].name_first = p
     .name_first, reply->item_list[repcnt].position_cd = 441,
     reply->item_list[repcnt].email = p.email, ccnt = 0
    HEAD bcpr.br_client_id
     IF (bcpr.br_client_id > 0)
      ccnt = (ccnt+ 1), stat = alterlist(reply->item_list[repcnt].client,ccnt)
      IF (ccnt=1)
       reply->item_list[repcnt].br_client_id = bcpr.br_client_id
      ENDIF
      reply->item_list[repcnt].client[ccnt].br_client_id = bcpr.br_client_id, reply->item_list[repcnt
      ].client[ccnt].br_client_name = bc.br_client_name
     ENDIF
    WITH counter, skipbedrock = 1
   ;end select
 ENDFOR
 IF (repcnt > 0)
  FOR (x = 1 TO repcnt)
    IF ((request->item_list[x].get_sol_ind=1))
     SET count1 = size(reply->item_list[x].client,5)
     FOR (y = 1 TO count1)
       SELECT INTO "nl:"
        FROM br_prsnl_item_reltn bpir
        PLAN (bpir
         WHERE (bpir.br_client_id=reply->item_list[x].client[y].br_client_id)
          AND (bpir.br_prsnl_id=reply->item_list[x].br_prsnl_id)
          AND bpir.item_type IN ("STEP", "STEPCAT"))
        HEAD REPORT
         scnt = 0, sccnt = 0
        DETAIL
         IF (bpir.item_type="STEP")
          scnt = (scnt+ 1), stat = alterlist(reply->item_list[x].client[y].slist,scnt), reply->
          item_list[x].client[y].slist[scnt].item_mean = bpir.item_mean,
          reply->item_list[x].client[y].slist[scnt].item_type = bpir.item_type, reply->item_list[x].
          client[y].slist[scnt].item_disp = bpir.item_display
         ELSE
          sccnt = (sccnt+ 1), stat = alterlist(reply->item_list[x].client[y].sclist,sccnt), reply->
          item_list[x].client[y].sclist[sccnt].item_mean = bpir.item_mean,
          reply->item_list[x].client[y].sclist[sccnt].item_type = bpir.item_type, reply->item_list[x]
          .client[y].sclist[sccnt].item_disp = bpir.item_display
         ENDIF
        WITH nocounter, skipbedrock = 1
       ;end select
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 IF (repcnt < 1)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_PRSNL"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NONE Found"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
#exit_script
END GO
