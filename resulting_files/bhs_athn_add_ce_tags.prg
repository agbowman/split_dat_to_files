CREATE PROGRAM bhs_athn_add_ce_tags
 RECORD t_record(
   1 event_cnt = i4
   1 event_qual[*]
     2 event_id = f8
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $4
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->event_cnt = (t_record->event_cnt+ 1)
    SET stat = alterlist(t_record->event_qual,t_record->event_cnt)
    SET t_record->event_qual[t_record->event_cnt].event_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET t_record->event_cnt = (t_record->event_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->event_qual,t_record->event_cnt)
    SET t_record->event_qual[t_record->event_cnt].event_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 DECLARE c_string = vc
 SET c_string = concat(
  "<?xml version='1.0' encoding='UTF-8'?><category-data xmlns:xsi='http://www.w3.org/2001/",
  "XMLSchema-instance' xsi:noNamespaceSchemaLocation='categorization.xsd'><category display='Laboratory' />",
  "</category-data>")
 DECLARE t_string = vc
 SET t_string = concat(format(sysdate,"yyyy-mm-dd;;q"),"T",format(sysdate,"hh:mm:ss;;q"),"Z")
 DECLARE json_string = vc
 SET json_string = '{"SAVE_TAGS": {"TAG_LIST": ['
 FOR (i = 1 TO t_record->event_cnt)
   IF (i=1)
    SET json_string = concat(json_string,'{"EMR_TYPE": "LABS","EMR_TYPE_CD": "LABS",',
     '"TAG_ENTITY_ID": "',trim(cnvtstring(t_record->event_qual[i].event_id)),'.00",',
     '"TAG_DT_TM": "',t_string,'",','"CATEGORIZATION_XML": "',c_string,
     '",','"FORMAT_CD": "",','"STORAGE_CD": "",','"BLOB_HANDLE": "",','"TAG_TEXT": ""}')
   ELSE
    SET json_string = concat(json_string,',{"EMR_TYPE": "LABS","EMR_TYPE_CD": "LABS",',
     '"TAG_ENTITY_ID": "',trim(cnvtstring(t_record->event_qual[i].event_id)),'.00",',
     '"TAG_DT_TM": "',t_string,'",','"CATEGORIZATION_XML": "',c_string,
     '",','"FORMAT_CD": "",','"STORAGE_CD": "",','"BLOB_HANDLE": "",','"TAG_TEXT": ""}')
   ENDIF
 ENDFOR
 SET json_string = concat(json_string,"]}}")
 EXECUTE mp_save_tagged_results "mine", cnvtreal( $2), cnvtreal( $3),
 json_string
END GO
