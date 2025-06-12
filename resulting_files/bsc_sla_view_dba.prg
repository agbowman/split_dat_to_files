CREATE PROGRAM bsc_sla_view:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE",
  "String 1: " = "*",
  "String 2: " = "*",
  "String 3: " = "*",
  "String 4: " = "*",
  "File Name:  " = ""
  WITH outdev, string1, string2,
  string3, string4, myfilename
 DECLARE str = vc
 DECLARE workfile = vc
 FREE DEFINE rtl2
 SET logical myfile  $MYFILENAME
 DEFINE rtl2 "myfile"
 SELECT INTO  $OUTDEV
  *
  FROM rtl2t t
  WHERE (t.line= $STRING1)
   AND (t.line= $STRING2)
   AND (t.line= $STRING3)
   AND (t.line= $STRING4)
  DETAIL
   curpos = 0, prevpos = 0, t.line,
   row + 1, curpos = findstring(",",t.line,1,0), prevpos = curpos,
   str = substring(1,(curpos - 1),t.line), "Date Stamp:         ", col + 1,
   str, row + 1, curpos = findstring(",",t.line,(curpos+ 1),0),
   str = substring((prevpos+ 1),((curpos - prevpos) - 1),t.line), "Timer Stamp:        ", col + 1,
   str, row + 1, prevpos = curpos,
   curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((curpos - prevpos) -
    1),t.line), "Client Node Name:   ",
   col + 1, str, row + 1,
   prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((
    curpos - prevpos) - 1),t.line),
   "Timer Name:         ", col + 1, str,
   row + 1, prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0),
   str = substring((prevpos+ 1),((curpos - prevpos) - 1),t.line), "Elapsed Time:       ", col + 1,
   str, row + 1, prevpos = curpos,
   curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((curpos - prevpos) -
    1),t.line), "Pass/Fail:          ",
   col + 1, str, row + 1,
   prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((
    curpos - prevpos) - 1),t.line),
   "Program Name:       ", col + 1, str,
   row + 1, prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0),
   str = substring((prevpos+ 1),((curpos - prevpos) - 1),t.line), "Process Id:         ", col + 1,
   str, row + 1, prevpos = curpos,
   curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((curpos - prevpos) -
    1),t.line), "Thread Id:          ",
   col + 1, str, row + 1,
   prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0), str = substring((prevpos+ 1),((
    curpos - prevpos) - 1),t.line),
   "User:               ", col + 1, str,
   row + 1, prevpos = curpos, curpos = findstring(",",t.line,(curpos+ 1),0),
   str = substring((prevpos+ 1),((curpos - prevpos) - 1),t.line), "Node Name:          ", col + 1,
   str, row + 1, prevpos = curpos,
   str = substring((prevpos+ 1),((size(t.line) - prevpos) - 1),t.line), "IP Address:         ", col
    + 1,
   str, row + 2, prevpos = curpos
  WITH maxcol = 3000
 ;end select
END GO
