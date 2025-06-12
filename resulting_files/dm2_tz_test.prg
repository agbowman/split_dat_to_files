CREATE PROGRAM dm2_tz_test
 DECLARE str = vc
 SET str = build('select into "nl:" '," t.", $2,", y=count(*) "," from ",
   $1," t"," where t.", $2," in (",
   $3,",", $4,")"," and ",
   $5," group by t.", $2," detail "," t->cnt=t->cnt+1",
  " stat=alterlist(t->qual, t->cnt)",' t->qual[t->cnt]->table_name = "', $1,'"',
  ' t->qual[t->cnt]->column_name = "',
   $2,'"'," t->qual[t->cnt]->tz_value = t.", $2," t->qual[t->cnt]->conditional_tz_cnt = y",
  " with nocounter go")
 CALL echo(str)
 CALL parser(str)
 SET str = build('select into "nl:" '," t.", $2,", y=count(*) "," from ",
   $1," t"," where t.", $2," in (",
   $3,",", $4,")"," group by t.",
   $2," detail "," fnd=0"," for (i=1 to t->cnt)",'	if (t->qual[i]->table_name = "',
   $1,'" and ','		t->qual[i]->column_name = "', $2,'" and ',
  "		t->qual[i]->tz_value = t.", $2,")","		fnd=1","		t->qual[i]->tz_cnt=y",
  "	endif"," endfor"," if (fnd=0)"," t->cnt=t->cnt+1"," stat=alterlist(t->qual, t->cnt)",
  ' t->qual[t->cnt]->table_name = "', $1,'"',' t->qual[t->cnt]->column_name = "', $2,
  '"'," t->qual[t->cnt]->tz_value = t.", $2," t->qual[t->cnt]->tz_cnt = y"," endif",
  " with nocounter go")
 CALL echo(str)
 CALL parser(str)
END GO
