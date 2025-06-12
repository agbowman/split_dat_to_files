CREATE PROGRAM dcp_get_codevalues:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 table_qual_cnt = i4
   1 table_qual[*]
     2 qual_cnt = i4
     2 qual[*]
       3 code_value = f8
       3 cdf_meaning = c12
       3 display = vc
       3 description = vc
       3 active_ind = i2
       3 collation_seq = i4
       3 display_key = vc
       3 definition = vc
       3 codeset = i4
 )
 SET reply->status_data.status = "F"
 SET reply->table_qual_cnt = 1
 SET code_set = request->code_set
 SET tablecnt = 1
 SET total_cnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY cnvtupper(c.display)
  HEAD REPORT
   tablecnt = 1, stat = alterlist(reply->table_qual,5), count1 = 0
  DETAIL
   count1 += 1
   IF (mod(reply->table_qual_cnt,5)=0)
    stat = alterlist(reply->table_qual,(reply->table_qual_cnt+ 5))
   ENDIF
   IF (mod(count1,5000)=1)
    stat = alterlist(reply->table_qual[tablecnt].qual,(count1+ 4999))
   ENDIF
   reply->table_qual[tablecnt].qual_cnt = count1, total_cnt += 1, reply->table_qual[tablecnt].qual[
   count1].code_value = c.code_value,
   reply->table_qual[tablecnt].qual[count1].cdf_meaning = c.cdf_meaning, reply->table_qual[tablecnt].
   qual[count1].display = c.display, reply->table_qual[tablecnt].qual[count1].description = c
   .description,
   reply->table_qual[tablecnt].qual[count1].active_ind = c.active_ind, reply->table_qual[tablecnt].
   qual[count1].collation_seq = c.collation_seq, reply->table_qual[tablecnt].qual[count1].display_key
    = c.display_key,
   reply->table_qual[tablecnt].qual[count1].definition = c.definition, reply->table_qual[tablecnt].
   qual[count1].codeset = c.code_set
   IF (mod(count1,20000)=0)
    reply->table_qual_cnt += 1, tablecnt = reply->table_qual_cnt, count1 = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->table_qual[tablecnt].qual,count1), stat = alterlist(reply->table_qual,
    tablecnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO reply->table_qual_cnt)
   IF ((reply->table_qual[i].qual_cnt != 0))
    SET stat = alterlist(reply->table_qual[i].qual,reply->table_qual[i].qual_cnt)
   ENDIF
 ENDFOR
 IF ((reply->table_qual[0].qual_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
