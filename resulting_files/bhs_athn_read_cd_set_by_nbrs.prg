CREATE PROGRAM bhs_athn_read_cd_set_by_nbrs
 RECORD orequest(
   1 codes[*]
     2 code_set = i4
 )
 RECORD out_rec(
   1 status = vc
   1 code_sets[*]
     2 code_set = i4
     2 codes[*]
       3 code_display = vc
       3 code_meaning = vc
       3 code_value = vc
       3 collation_seq = i4
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE t_code = f8
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt = (cnt+ 1)
    SET stat = alterlist(orequest->codes,cnt)
    SET orequest->codes[cnt].code_set = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt = (cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->codes,cnt)
    SET orequest->codes[cnt].code_set = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET stat = tdbexecute(3200000,3200400,3200114,"REC",orequest,
  "REC",oreply,4)
 IF ((oreply->status_data.status="S"))
  SET out_rec->status = "Success"
  SET stat = alterlist(out_rec->code_sets,size(oreply->cd,5))
  FOR (i = 1 TO size(oreply->cd,5))
    SET out_rec->code_sets[i].code_set = oreply->cd[i].code_set
    SET stat = alterlist(out_rec->code_sets[i].codes,size(oreply->cd[i].code,5))
    FOR (j = 1 TO size(oreply->cd[i].code,5))
      SET out_rec->code_sets[i].codes[j].code_value = cnvtstring(oreply->cd[i].code[j].code)
      SET out_rec->code_sets[i].codes[j].code_display = uar_get_code_display(oreply->cd[i].code[j].
       code)
      SET out_rec->code_sets[i].codes[j].code_meaning = uar_get_code_meaning(oreply->cd[i].code[j].
       code)
      SET out_rec->code_sets[i].codes[j].collation_seq = oreply->cd[i].code[j].collation_seq
    ENDFOR
  ENDFOR
  CALL echojson(out_rec, $1)
 ELSE
  CALL echojson(out_rec, $1)
 ENDIF
END GO
