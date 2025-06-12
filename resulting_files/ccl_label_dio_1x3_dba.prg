CREATE PROGRAM ccl_label_dio_1x3:dba
 PROMPT
  "Output to File/Printer/MINE= " = "MINE",
  "DIOTYPE (42)= " = 46
  WITH outdev, diotype
 SET _diotype = cnvtstring( $DIOTYPE)
 SET _domain = trim(curdomain)
 DECLARE _pname = vc
 DECLARE _courier = vc
 DECLARE _timesroman = vc
 DECLARE _helvetica = vc
 SET _courier = "ZZ,Courier"
 SET _timesroman = "ZZ,TimesRoman"
 DECLARE stext = vc
 SET _id = 12345678
 SELECT INTO  $1
  d.*
  FROM dummyt d
  HEAD REPORT
   "{FR/3}"
  DETAIL
   row 0, col 1, "{F/1}{CPI/20}",
   row + 1, col 1, _domain,
   row + 1, "{F/1}{CPI/25}", row + 1,
   stext = concat(_courier," (25)"), col 1, "Id:",
   _id, col + 5, stext,
   row + 1, "{F/1}{CPI/28}", row + 1,
   stext = concat(_courier," (28)"), col 1, "Id:",
   _id, col + 5, stext,
   row + 1, "{lpi/12}{cpi/28}{font/1}", row + 1,
   stext = concat(_courier," (LPI12,CPI28)"), col 1, "Id:",
   _id, col + 5, stext,
   row + 1, "{F/5}{CPI/25}", row + 1,
   col 1, "Id:", _id,
   row + 1, stext = concat(_timesroman," (25)"), col 1,
   "{F/5}{CPI/25}", "Font: ", stext,
   stext = concat(_timesroman," (28)"), col + 3, "{F/5}{CPI/28}",
   stext, row + 1, stext = concat(_timesroman," (18)"),
   col 1, "{F/5}{CPI/18}", "Font: ",
   stext, stext = concat(_timesroman," (20)"), col + 3,
   "{F/5}{CPI/20}", stext, row + 1,
   row + 1, col 1, "{F/28}{lpi/6}{cpi/16}{bcr/300}{CPI/8}",
   "*39393939*", ""
  WITH maxrec = 1, dio =  $2, nocounter,
   separator = " ", format
 ;end select
END GO
