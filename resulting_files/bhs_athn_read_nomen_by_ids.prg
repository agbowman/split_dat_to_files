CREATE PROGRAM bhs_athn_read_nomen_by_ids
 RECORD t_record(
   1 nomen_cnt = i4
   1 nomen_qual[*]
     2 nomen_id = f8
 )
 RECORD orequest(
   1 nomenclature_id = f8
   1 principle_type_cd = f8
   1 source_vocabulary_cd = f8
   1 source_string = vc
   1 principle_type_ind = i2
   1 source_vocabulary_ind = i2
   1 source_string_ind = i2
 )
 RECORD out_rec(
   1 status = vc
   1 nomenclatures[*]
     2 mnemonic = vc
     2 nomenclature_id = vc
     2 principle_type_disp = vc
     2 principle_type_mean = vc
     2 principle_type_cd = vc
     2 short_string = vc
     2 source_string = vc
     2 source_vocabulary_disp = vc
     2 source_vocabulary_mean = vc
     2 source_vocabulary_cd = vc
     2 vocab_axis_disp = vc
     2 vocab_axis_mean = vc
     2 vocab_axis_value = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->nomen_cnt += 1
    SET stat = alterlist(t_record->nomen_qual,t_record->nomen_cnt)
    SET t_record->nomen_qual[t_record->nomen_cnt].nomen_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET t_record->nomen_cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->nomen_qual,t_record->nomen_cnt)
    SET t_record->nomen_qual[t_record->nomen_cnt].nomen_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET stat = alterlist(out_rec->nomenclatures,t_record->nomen_cnt)
 FOR (i = 1 TO t_record->nomen_cnt)
   SET orequest->nomenclature_id = t_record->nomen_qual[i].nomen_id
   SET stat = tdbexecute(3200000,3200071,964003,"REC",orequest,
    "REC",oreply,4)
   IF ((oreply->status_data.status="S"))
    SET out_rec->status = "Success"
   ELSE
    SET out_rec->status = "Failed"
   ENDIF
   SET out_rec->nomenclatures[i].mnemonic = oreply->s_qual[1].mnemonic
   SET out_rec->nomenclatures[i].nomenclature_id = cnvtstring(oreply->s_qual[1].nomenclature_id)
   SET out_rec->nomenclatures[i].principle_type_disp = uar_get_code_display(oreply->s_qual[1].
    principle_type_cd)
   SET out_rec->nomenclatures[i].principle_type_mean = uar_get_code_meaning(oreply->s_qual[1].
    principle_type_cd)
   SET out_rec->nomenclatures[i].principle_type_cd = cnvtstring(oreply->s_qual[1].principle_type_cd)
   SET out_rec->nomenclatures[i].short_string = oreply->s_qual[1].short_string
   SET out_rec->nomenclatures[i].source_string = oreply->s_qual[1].source_string
   SET out_rec->nomenclatures[i].source_vocabulary_disp = uar_get_code_display(oreply->s_qual[1].
    source_vocabulary_cd)
   SET out_rec->nomenclatures[i].source_vocabulary_mean = uar_get_code_meaning(oreply->s_qual[1].
    source_vocabulary_cd)
   SET out_rec->nomenclatures[i].source_vocabulary_cd = cnvtstring(oreply->s_qual[1].
    source_vocabulary_cd)
   SET out_rec->nomenclatures[i].vocab_axis_disp = uar_get_code_display(oreply->s_qual[1].
    vocab_axis_cd)
   SET out_rec->nomenclatures[i].vocab_axis_mean = uar_get_code_meaning(oreply->s_qual[1].
    vocab_axis_cd)
   SET out_rec->nomenclatures[i].vocab_axis_value = cnvtstring(oreply->s_qual[1].vocab_axis_cd)
   SET stat = alterlist(oreply->s_qual,0)
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
