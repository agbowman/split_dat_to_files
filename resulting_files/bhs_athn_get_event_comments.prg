CREATE PROGRAM bhs_athn_get_event_comments
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
     2 event_id = f8
   1 action_type_cd_list[*]
     2 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD t_record(
   1 prsnl_cnt = i4
   1 prsnl_qual[*]
     2 person_id = f8
     2 prsnl = vc
 )
 DECLARE t_line = vc
 DECLARE d_line = vc
 DECLARE tz_line = vc
 DECLARE note_prsnl = vc
 DECLARE i_line = vc
 SET orequest->query_mode = 3
 SET orequest->event_id =  $2
 SET orequest->query_mode_ind = 1
 SET orequest->valid_from_dt_tm_ind = 1
 SET orequest->decode_flag = 3
 SET orequest->subtable_bit_map_ind = 1
 SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
  "REC",oreply)
 IF (size(oreply->rb_list[1].event_note_list,5) < 1)
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    t_line = concat("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, t_line,
    row + 1, t_line = "<ReplyMessage>", col 0,
    t_line, row + 1, t_line = "</ReplyMessage>",
    col 0, t_line, row + 1
   WITH nocounter, formfeed = none, maxcol = 100,
    format = variable, time = 30
  ;end select
 ELSE
  FOR (i = 1 TO size(oreply->rb_list[1].event_note_list,5))
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=oreply->rb_list[1].event_note_list[i].note_prsnl_id))
     HEAD p.person_id
      t_record->prsnl_cnt = (t_record->prsnl_cnt+ 1), stat = alterlist(t_record->prsnl_qual,t_record
       ->prsnl_cnt), t_record->prsnl_qual[t_record->prsnl_cnt].person_id = p.person_id,
      t_record->prsnl_qual[t_record->prsnl_cnt].prsnl = trim(replace(replace(replace(replace(replace(
            p.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3)
     WITH nocounter, time = 30
    ;end select
  ENDFOR
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    t_line = concat("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, t_line,
    row + 1, t_line = "<ReplyMessage>", col 0,
    t_line, row + 1
    FOR (i = 1 TO size(oreply->rb_list[1].event_note_list,5))
      IF ((oreply->rb_list[1].event_note_list[i].note_type_cd=74))
       t_line = "<ResultComment>"
      ELSE
       t_line = "<Reason>"
      ENDIF
      col 0, t_line, row + 1,
      t_line = concat("<BlobResult>",trim(replace(replace(replace(replace(replace(trim(oreply->
              rb_list[1].event_note_list[i].long_blob,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
          "'","&apos;",0),'"',"&quot;",0),3),"</BlobResult>"), col 0, t_line,
      row + 1, t_line = concat("<ResultType>",trim(uar_get_code_display(oreply->rb_list[1].
         event_note_list[i].note_type_cd),3),"</ResultType>"), col 0,
      t_line, row + 1, v1 = build("<NoteDateTime>",datetimezoneformat(oreply->rb_list[1].
        event_note_list[i].note_dt_tm,oreply->rb_list[1].event_note_list[i].note_tz,
        "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef),"</NoteDateTime>"),
      col 0, v1, row + 1,
      note_prsnl = ""
      FOR (j = 1 TO t_record->prsnl_cnt)
        IF ((oreply->rb_list[1].event_note_list[i].note_prsnl_id=t_record->prsnl_qual[i].person_id))
         note_prsnl = t_record->prsnl_qual[i].prsnl
        ENDIF
      ENDFOR
      t_line = concat("<NotePerformedBy>",note_prsnl,"</NotePerformedBy>"), col 0, t_line,
      row + 1
      IF ((oreply->rb_list[1].event_note_list[i].importance_flag=1))
       i_line = "Low Importance"
      ELSEIF ((oreply->rb_list[1].event_note_list[i].importance_flag=2))
       i_line = "Medium Importance"
      ELSEIF ((oreply->rb_list[1].event_note_list[i].importance_flag=4))
       i_line = "High Importance"
      ENDIF
      t_line = concat("<ImportanceFlag>",i_line,"</ImportanceFlag>"), col 0, t_line,
      row + 1
      IF ((oreply->rb_list[1].event_note_list[i].note_type_cd=74))
       t_line = "</ResultComment>"
      ELSE
       t_line = "</Reason>"
      ENDIF
      col 0, t_line, row + 1
    ENDFOR
    t_line = "</ReplyMessage>", col 0, t_line,
    row + 1
   WITH nocounter, formfeed = none, maxcol = 33000,
    format = variable, time = 30
  ;end select
 ENDIF
END GO
