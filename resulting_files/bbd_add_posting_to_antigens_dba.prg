CREATE PROGRAM bbd_add_posting_to_antigens:dba
 RECORD codes(
   1 row[*]
     2 code_value = f8
 )
 SET x = 0
 SELECT INTO "nl:"
  *
  FROM code_value_extension c
  PLAN (c
   WHERE c.code_set=1612
    AND c.field_name="PostToDonor")
  DETAIL
   x = (x+ 1)
  WITH nocounter, maxqual(c,1)
 ;end select
 IF (x > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM code_value c
  PLAN (c
   WHERE c.code_set=1612
    AND c.active_ind=1)
  DETAIL
   x = (x+ 1), stat = alterlist(codes->row,x), codes->row[x].code_value = c.code_value
  WITH nocounter
 ;end select
 SET y = 0
 FOR (y = 1 TO x)
  INSERT  FROM code_value_extension
   SET code_value = codes->row[y].code_value, field_name = "PostToDonor", code_set = 1612,
    updt_dt_tm = cnvtdate(curdate,curtime), field_type = 1, field_value = "0",
    updt_cnt = 0, updt_task = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
#exit_script
END GO
