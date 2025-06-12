CREATE PROGRAM dcp_print_barcode:dba
 PAINT
#loop
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL text(2,24,"B A R C O D E   P R I N T I N G")
 CALL text(5,15,"Enter a barcode:")
 CALL accept(6,15,"P(50);CU")
 SET barcode_value = trim(substring(1,textlen(trim(curaccept)),curaccept))
 CALL text(8,15,"Enter a barcode display:")
 CALL accept(9,15,"P(50);C")
 SET barcode_disp = trim(substring(1,textlen(trim(curaccept)),curaccept))
 CALL text(11,15,"Enter a printer:")
 CALL accept(12,15,"P(50);CU")
 SET printer = trim(substring(1,textlen(trim(curaccept)),curaccept))
 CALL text(14,15,"Number of copies:")
 CALL accept(15,15,"99;C","1")
 SET totalcopies = curaccept
 SET barcode = trim(build("*",cnvtalphanum(trim(barcode_value)),"*"))
 FOR (cnt = 1 TO cnvtint(totalcopies))
   SELECT INTO value(printer)
    FROM dummyt d
    DETAIL
     "{ps/792 0 translate 90 rotate/}", row + 1, "{CPI/15}{LPI/6}{F/8}",
     row + 1, row + 1, "{POS/50/35}",
     barcode_disp, row + 1, "{POS/50/45}",
     barcode_value, row + 1, "{POS/50/10}",
     "{BCR/100}{FR/0}{CPI/6}{F/28/2}", barcode
    WITH nocounter, noformfeed, dio = postscript,
     maxcol = 300
   ;end select
 ENDFOR
 CALL text(18,15,"Print Another Barcode (Y/N)?")
 CALL accept(19,15,"P(1);CU")
 IF (curaccept="Y")
  GO TO loop
 ENDIF
END GO
