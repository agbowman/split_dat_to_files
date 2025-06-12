CREATE PROGRAM dcp_prt_driver:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD temp(
   1 text1 = vc
   1 text2 = vc
   1 text3 = vc
   1 s[*]
     2 reps = vc
     2 psze = i2
 )
 RECORD result(
   1 line_cnt = i4
   1 line_qual[*]
     2 disp_line = vc
     2 list_ln_cnt = i2
     2 list_tag[*]
       3 list_line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET prtr_cnt = size(request->prtr_list,5)
 SET firsttime = "Y"
 SET result->line_cnt = 0
 SET reps_cnt = 2
 SET stat = alterlist(temp->s,reps_cnt)
 SET temp->s[1].reps = "\par"
 SET temp->s[1].psze = 4
 SET temp->s[2].reps = "\pard"
 SET temp->s[2].psze = 5
 SET tot_size = textlen(request->text)
 IF (tot_size=0)
  GO TO exit_script
 ENDIF
 SET temp->text1 = request->text
 FOR (y = 1 TO reps_cnt)
   EXECUTE FROM search1 TO search2
 ENDFOR
#search1
 SET t = 0
 SET t = findstring(temp->s[2].reps,temp->text1)
 IF (t > 0)
  SET temp->text2 = substring(1,(t - 1),temp->text1)
  SET temp->text3 = substring((t+ temp->s[2].psze),(tot_size - (t+ temp->s[2].psze)),temp->text1)
  IF (firsttime="Y")
   SET temp->text1 = concat(trim(temp->text2),"\par",trim(temp->text3))
   SET firsttime = "N"
  ELSE
   SET temp->text1 = concat(trim(temp->text2),trim(temp->text3))
  ENDIF
  GO TO search1
 ENDIF
#search2
 SET t = 0
 SET t = findstring(temp->s[1].reps,temp->text1)
 IF (t > 0)
  SET temp->text2 = substring(1,(t+ temp->s[1].psze),temp->text1)
  SET temp->text1 = substring((t+ temp->s[1].psze),(tot_size - (t+ temp->s[1].psze)),temp->text1)
  SET blob_out = fillstring(32000," ")
  SET blob_out2 = fillstring(32000," ")
  SET blob_out = temp->text2
  CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,
   0)
  SET temp->text2 = concat(trim(blob_out2))
  SET result->line_cnt = (result->line_cnt+ 1)
  SET stat = alterlist(result->line_qual,result->line_cnt)
  SET result->line_qual[result->line_cnt].disp_line = temp->text2
  GO TO search2
 ENDIF
 SET pt->line_cnt = 0
 SET max_length = 80
 FOR (x = 1 TO result->line_cnt)
   EXECUTE dcp_parse_text value(result->line_qual[x].disp_line), value(max_length)
   SET stat = alterlist(result->line_qual[x].list_tag,pt->line_cnt)
   SET result->line_qual[x].list_ln_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET result->line_qual[x].list_tag[w].list_line = pt->lns[w].line
   ENDFOR
 ENDFOR
 FOR (y = 1 TO prtr_cnt)
   SELECT INTO request->prtr_list[y].output_device
    d.seq
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     xcol = 40, ycol = 60
     FOR (x = 1 TO result->line_cnt)
       FOR (z = 1 TO result->line_qual[x].list_ln_cnt)
         CALL print(calcpos(xcol,ycol)), result->line_qual[x].list_tag[z].list_line, row + 1,
         ycol = (ycol+ 15)
       ENDFOR
     ENDFOR
    WITH nocounter, maxrow = 200, maxcol = 132,
     dio = postscript
   ;end select
 ENDFOR
#exit_script
END GO
