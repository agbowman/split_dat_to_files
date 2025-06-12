CREATE PROGRAM bhs_athn_delete_tagged_text
 RECORD t_record(
   1 entity_cnt = i4
   1 entity_qual[*]
     2 tag_enity_id = f8
 )
 DECLARE person_id = f8
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $3))
  HEAD REPORT
   person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $4
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->entity_cnt = (t_record->entity_cnt+ 1)
    SET stat = alterlist(t_record->entity_qual,t_record->entity_cnt)
    SET t_record->entity_qual[t_record->entity_cnt].tag_enity_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET t_record->entity_cnt = (t_record->entity_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->entity_qual,t_record->entity_cnt)
    SET t_record->entity_qual[t_record->entity_cnt].tag_enity_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 DECLARE json_string = vc
 SET json_string = '{"DELETE_TAG":{"TAG_LIST":['
 FOR (i = 1 TO t_record->entity_cnt)
   IF (i=1)
    SET json_string = concat(json_string,'{"contentType":"TAGTEXT","entityId":"',trim(cnvtstring(
       t_record->entity_qual[i].tag_enity_id)),'.00"}')
   ELSE
    SET json_string = concat(json_string,',{"contentType":"TAGTEXT","entityId":"',trim(cnvtstring(
       t_record->entity_qual[i].tag_enity_id)),'.00"}')
   ENDIF
 ENDFOR
 SET json_string = concat(json_string,"]}}")
 EXECUTE mp_delete_tagged_results "mine", cnvtreal( $2), person_id,
 cnvtreal( $3), 0.00, json_string
END GO
