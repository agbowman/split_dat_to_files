CREATE PROGRAM dcp_get_dl_docset:dba
 RECORD reply(
   1 label_template_id_list[*]
     2 label_template_id = f8
     2 doc_set_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH protect, noconstant("000")
 DECLARE list_size = i4 WITH protect, constant(size(request->label_template_id_list,5))
 DECLARE template_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH protect, constant(20)
 IF (list_size=0)
  GO TO exit_script
 ENDIF
 RECORD expand_record(
   1 qual[*]
     2 id = f8
     2 index = i4
 )
 SET expand_blocks = ceil(((list_size * 1.0)/ expand_size))
 SET total_items = (expand_blocks * expand_size)
 SET stat = alterlist(expand_record->qual,total_items)
 FOR (x = 1 TO total_items)
   IF (x > list_size)
    SET expand_record->qual[x].id = expand_record->qual[list_size].id
    SET expand_record->qual[x].index = - (1)
   ELSE
    SET expand_record->qual[x].id = request->label_template_id_list[x].label_template_id
    SET expand_record->qual[x].index = x
   ENDIF
 ENDFOR
 SET expand_start = 0
 SET expand_stop = 0
 SET reply->status_data.status = "F"
 WHILE (expand_stop < list_size)
   SET expand_start = (expand_stop+ 1)
   SET expand_stop = (expand_stop+ expand_size)
   SELECT INTO "nl:"
    FROM dynamic_label_template dlt
    PLAN (dlt
     WHERE expand(expand_index,expand_start,(expand_start+ (expand_size - 1)),dlt.label_template_id,
      expand_record->qual[expand_index].id,
      expand_size))
    ORDER BY dlt.label_template_id
    HEAD dlt.label_template_id
     template_cnt = (template_cnt+ 1)
     IF (template_cnt > size(reply->label_template_id_list,5))
      stat = alterlist(reply->label_template_id_list,(template_cnt+ 5))
     ENDIF
     reply->label_template_id_list[template_cnt].label_template_id = dlt.label_template_id, reply->
     label_template_id_list[template_cnt].doc_set_ref_id = dlt.doc_set_ref_id
    FOOT  dlt.label_template_id
     stat = alterlist(reply->label_template_id_list,template_cnt)
    WITH nocounter
   ;end select
 ENDWHILE
 FREE RECORD expand_record
#exit_script
 IF (template_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "000"
END GO
