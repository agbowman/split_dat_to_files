CREATE PROGRAM cclpak2
 PROMPT
  "Enter report printer or file name" = "MINE"
 DEFINE cclpak "CCLDIR:CCLPAK"
 SELECT INTO  $1
  p.eprogram, p.datestamp, p.timestamp,
  p.len, p.datespan
  FROM cclpak p
  HEAD REPORT
   program_decode = fillstring(12," "), line = fillstring(75,"-")
  HEAD PAGE
   col 25, "REGISTERED  CCL  UPDATE  PROGRAMS", col 63,
   "Page: ", curpage"####", row + 1,
   col 5, "Program", col 20,
   "Date", col 35, "Time",
   col 45, "Duration", col 55,
   "Encryption", row + 1, line,
   row + 1
  DETAIL
   program_decode = modcheck(9920,p.eprogram), col 5, program_decode,
   col 20, p.datestamp, col 35,
   p.timestamp, col 45, p.datespan"######",
   col 55, row + 1
  WITH counter, maxcol = 76
 ;end select
END GO
