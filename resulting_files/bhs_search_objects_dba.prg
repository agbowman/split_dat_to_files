CREATE PROGRAM bhs_search_objects:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Object Name" = "",
  "Search String" = ""
  WITH outdev, object_name, search_string
 DECLARE prog_name = vc WITH protect, noconstant(patstring(cnvtupper( $OBJECT_NAME)))
 DECLARE search_str = vc WITH protect, noconstant(patstring(cnvtupper( $SEARCH_STRING)))
 DECLARE ndx = i4
 FREE RECORD s
 RECORD s(
   1 cnt = i4
   1 list[*]
     2 name = vc
 )
 CALL echo("***")
 CALL echo(prog_name)
 CALL echo(search_str)
 CALL echo("***")
 EXECUTE cclprogsearch "bhs_search_objects.dat", prog_name, search_str
 FREE DEFINE rtl2
 DEFINE rtl2 "bhs_search_objects.dat"
 SELECT INTO "nl:"
  FROM rtl2t t
  DETAIL
   s->cnt = (s->cnt+ 1), stat = alterlist(s->list,s->cnt), s->list[s->cnt].name = substring(6,
    findstring(char(32),substring(6,size(t.line),t.line)),t.line)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  object_name = dp.object_name, group = dp.group, source_file = dp.source_name
  FROM dprotect dp
  WHERE dp.object="P"
   AND expand(ndx,1,s->cnt,dp.object_name,s->list[ndx].name)
  ORDER BY dp.object_name, dp.group
  WITH nocounter, format, separator = " ",
   maxrow = 200
 ;end select
END GO
