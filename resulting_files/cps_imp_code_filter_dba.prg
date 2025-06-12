CREATE PROGRAM cps_imp_code_filter:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD request
 RECORD request(
   1 qual_cnt = i4
   1 qual[*]
     2 code_set = i4
     2 code_cnt = i4
     2 code[*]
       3 code_value = f8
 )
 SELECT INTO "nl:"
  FROM dm_code_set dc,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (dc
   WHERE dc.code_set=cnvtint(requestin->list_0[d.seq].code_set))
  ORDER BY dc.code_set
  HEAD REPORT
   cnt = 0, stat = alterlist(request->qual,5)
  HEAD dc.code_set
   d_cnt = 0, cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(request->qual,(cnt+ 10))
   ENDIF
   request->qual[cnt].code_set = cnvtint(requestin->list_0[d.seq].code_set)
  DETAIL
   d_cnt = (d_cnt+ 1)
   IF (mod(d_cnt,10)=1)
    stat = alterlist(request->qual[cnt].code,(d_cnt+ 10))
   ENDIF
   request->qual[cnt].code[d_cnt].code_value = cnvtint(requestin->list_0[d.seq].code_value),
   CALL echo(build("cv  : ",request->qual[cnt].code_set," : ",request->qual[cnt].code[d_cnt].
    code_value))
  FOOT  dc.code_set
   request->qual[cnt].code_cnt = d_cnt, stat = alterlist(request->qual[cnt].code,d_cnt)
  FOOT REPORT
   request->qual_cnt = cnt, stat = alterlist(request->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL echo("error in import")
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("start import")
  EXECUTE dm_ins_code_filter
 ENDIF
#exit_script
END GO
