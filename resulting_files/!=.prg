   AND r.line != "DROP PROGRAM*"
  WITH nocounter
 ;end select
#view_mode_end
#qual_help_begin
 SET help =
 SELECT INTO "NL:"
  field = concat(trim(dica.table_name),".",dicl.attr_name,"=",dicl.type,
   cnvtstring(dicl.len,4))
  WHERE dica.table_name IN (g_table[1,1], g_table[2,1], g_table[3,1], g_table[1,2], g_table[2,2],
  g_table[3,2], g_table[1,3], g_table[2,3], g_table[3,3])
   AND dicl.structtype="F"
   AND btest(dicl.stat,11)=0
   AND btest(dicl.stat,10)=0
  WITH nocounter
 ;end select
 IF (g_width=80)
  SET help = pos(2,20,11,50)
 ELSE
  SET help = pos(2,75,20,50)
 ENDIF
#qual_help_end
#done
 CALL clear(1,1)
END GO
