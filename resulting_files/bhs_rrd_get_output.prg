CREATE PROGRAM bhs_rrd_get_output
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Handle ID: " = 0
 DECLARE file_node = vc
 DECLARE file_path = vc
 SELECT INTO "nl:"
  FROM outputctx o
  WHERE (o.handle_id= $2)
  DETAIL
   file_node = o.server, file_path = o.file_name
  WITH nocounter
 ;end select
 CALL echo(file_node)
 CALL echo(file_path)
 IF (file_path="")
  SELECT INTO  $1
   FROM dummyt
   DETAIL
    col 1, "Invalid selection", row + 1
   WITH nocounter
  ;end select
  GO TO end_program
 ENDIF
 CALL echo(file_node)
 CALL echo(curnode)
 IF (file_node != curnode)
  FREE SET dclcom
  DECLARE dclcom = vc
  SET dclcom = concat('$cust_script/bhs_get_rrd_file.ksh "',file_node,'" "',substring(22,100,
    file_path))
  CALL echo(dclcom)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
 ENDIF
 FREE RECORD data_out
 RECORD data_out(
   1 list[*]
     2 line = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 FREE DEFINE rtl3
 SET logical rrd_file file_path
 CALL echo(logical("rrd_file"))
 DEFINE rtl3 "rrd_file"
 SELECT INTO "nl:"
  FROM rtl3t r
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(data_out->list,(cnt+ 9))
   ENDIF
   bsize = 0, my_var = fillstring(65536," "), my_var = trim(r.line),
   CALL uar_rtf2(trim(my_var),size(my_var),my_var,size(my_var),bsize,0), data_out->list[cnt].line =
   trim(my_var,3)
  FOOT REPORT
   stat = alterlist(data_out->list,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(data_out)
 FREE DEFINE rtl3
 DECLARE context = i4
 DECLARE status1 = i4
 DECLARE pgwidth = i4
 DECLARE cnvtto = i4
 DECLARE binit = i4
 SET pgwidth = 8.0
 SET cnvtto = 0
 SET context = 0
 SET binit = 1
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = value(cnt))
  HEAD PAGE
   ycol = 20, xcol = 15, output_string = fillstring(130," ")
  DETAIL
   IF (size(data_out->list[d.seq].line) > 130)
    i = 1
    WHILE (i < size(data_out->list[d.seq].line))
      output_string = substring(i,125,data_out->list[d.seq].line), col 1, output_string,
      row + 1, i = (i+ 125)
    ENDWHILE
   ELSE
    col 1, data_out->list[d.seq].line, row + 1
   ENDIF
  WITH maxcol = 132, format = variable
 ;end select
#end_program
END GO
