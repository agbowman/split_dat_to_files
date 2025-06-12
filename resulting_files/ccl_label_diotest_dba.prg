CREATE PROGRAM ccl_label_diotest:dba
 PROMPT
  "Output to File/Printer/MINE= " = "MINE",
  "DIOTYPE (32)= " = 32
  WITH outdev, diotype
 SET _diotype = cnvtstring( $DIOTYPE)
 SET _domain = trim(curdomain)
 IF (textlen(_domain)=0)
  SET _domain = trim(logical("client_mnemonic"))
 ENDIF
 DECLARE _pname = vc
 DECLARE _courier = vc
 DECLARE _timesroman = vc
 DECLARE _helvetica = vc
 DECLARE _nodename = vc
 DECLARE _prcname = vc
 SET _courier = "AAA, Courier"
 SET _timesroman = "BBB, TimesRoman"
 SET _helvetica = "ZZZ, Helvetica"
 SET _nodename = build("Node:",trim(curnode))
 SET _prcname = build(trim(curprcname))
 SET _id = 1234567890
 SELECT INTO  $1
  d.*
  FROM dummyt d
  DETAIL
   row 0, col 1, "{F/1}{CPI/12}",
   row + 1, col 1, _domain,
   row + 1, "{F/0}{CPI/15}", row + 1,
   col 1, "Id:", _id,
   row + 1, col 1, "Font: ",
   _courier, col + 10, "{F/1}{CPI/15}",
   _courier, row + 1, "{F/4}{CPI/15}",
   row + 1, col 1, "Id:",
   _id, row + 1, col 1,
   "Font: ", _timesroman, col + 10,
   "{F/6}{CPI/15}", _timesroman, row + 1,
   "{F/8}{CPI/15}", row + 1, col 1,
   "Id:", _id, row + 1,
   col 1, "Font: ", _helvetica,
   col + 10, "{F/8}{CPI/15}", _helvetica,
   row + 1, row + 2, col 3,
   "{F/28}{CPI/8}", "*11393911*", "{F/6}",
   row + 2, col 3, "{F/31}{CPI/8}",
   "*128128128*", "{F/6}", row + 2,
   "{FR/1}{F/4}{CPI/15}", row + 1, col 5,
   _nodename, row + 1, row + 2,
   "{FR/3}{F/4}{CPI/15}", row + 1, col 15,
   _prcname, row + 1
  WITH maxrec = 1, dio =  $2, nocounter,
   separator = " ", format
 ;end select
END GO
