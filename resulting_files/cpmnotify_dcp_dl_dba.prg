CREATE PROGRAM cpmnotify_dcp_dl:dba
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 dynamic_label_id = f8
       3 label_status_cd = f8
       3 label_name = vc
       3 label_prsnl_id = f8
       3 template_id = f8
       3 updt_dt_tm = dq8
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 sequence_nbr = i4
       3 long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH protect, noconstant("000")
 DECLARE person_list_sz = i4 WITH protect, constant(size(request->entity_list,5))
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE dl_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(60)
 IF (person_list_sz=0)
  GO TO exit_script
 ENDIF
 RECORD expand_record(
   1 qual[*]
     2 id = f8
     2 index = i4
 )
 SET expand_blocks = ceil(((person_list_sz * 1.0)/ expand_size))
 SET total_items = (expand_blocks * expand_size)
 SET stat = alterlist(expand_record->qual,total_items)
 FOR (x = 1 TO total_items)
   IF (x > person_list_sz)
    SET expand_record->qual[x].id = expand_record->qual[person_list_sz].id
    SET expand_record->qual[x].index = - (1)
   ELSE
    SET expand_record->qual[x].id = request->entity_list[x].entity_id
    SET expand_record->qual[x].index = x
   ENDIF
 ENDFOR
 SET expand_start = 0
 SET expand_stop = 0
 SET reply->status_data.status = "F"
 SET reply->overlay_ind = 1
 SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
 WHILE (expand_stop < person_list_sz)
   SET expand_start = (expand_stop+ 1)
   SET expand_stop = (expand_stop+ expand_size)
   SELECT INTO "nl:"
    FROM ce_dynamic_label dl,
     long_text lt
    PLAN (dl
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dl.person_id,
      expand_record->qual[expand_index].id,
      expand_size)
      AND dl.updt_dt_tm >= cnvtdatetime(request->last_run_dt_tm)
      AND ((dl.ce_dynamic_label_id+ 0)=dl.prev_dynamic_label_id))
     JOIN (lt
     WHERE lt.long_text_id=dl.long_text_id)
    ORDER BY dl.person_id
    HEAD dl.person_id
     dl_cnt = 0, person_cnt = (person_cnt+ 1)
     IF (person_cnt > size(reply->entity_list,5))
      stat = alterlist(reply->entity_list,(person_cnt+ 5))
     ENDIF
     reply->entity_list[person_cnt].entity_id = dl.person_id
    DETAIL
     dl_cnt = (dl_cnt+ 1)
     IF (dl_cnt > size(reply->entity_list[person_cnt].datalist,5))
      stat = alterlist(reply->entity_list[person_cnt].datalist,(dl_cnt+ 5))
     ENDIF
     reply->entity_list[person_cnt].datalist[dl_cnt].dynamic_label_id = dl.ce_dynamic_label_id, reply
     ->entity_list[person_cnt].datalist[dl_cnt].label_status_cd = dl.label_status_cd, reply->
     entity_list[person_cnt].datalist[dl_cnt].label_name = dl.label_name,
     reply->entity_list[person_cnt].datalist[dl_cnt].label_prsnl_id = dl.label_prsnl_id, reply->
     entity_list[person_cnt].datalist[dl_cnt].template_id = dl.label_template_id, reply->entity_list[
     person_cnt].datalist[dl_cnt].updt_dt_tm = cnvtdatetime(dl.updt_dt_tm),
     reply->entity_list[person_cnt].datalist[dl_cnt].valid_from_dt_tm = cnvtdatetime(dl
      .valid_from_dt_tm), reply->entity_list[person_cnt].datalist[dl_cnt].valid_until_dt_tm =
     cnvtdatetime(dl.valid_until_dt_tm), reply->entity_list[person_cnt].datalist[dl_cnt].sequence_nbr
      = dl.label_seq_nbr,
     reply->entity_list[person_cnt].datalist[dl_cnt].long_text = lt.long_text
    FOOT  dl.person_id
     stat = alterlist(reply->entity_list[person_cnt].datalist,dl_cnt)
    WITH nocounter
   ;end select
 ENDWHILE
 SET stat = alterlist(reply->entity_list,person_cnt)
 FREE RECORD expand_record
#exit_script
 IF (person_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
END GO
