CREATE PROGRAM cclbrowse
 PAINT
 SET browse_file = concat("CCLBROWSE",trim(curuser),".DAT")
 SET width = 80
 SET first_time = 1
 SET buffer = fillstring(130," ")
 SET printer = fillstring(60," ")
 SET choice = fillstring(20," ")
 SET choice_help = concat("BROWSE    ,","DIRECTORY ,","PRINT      ")
 SET trace = printdsp
 SET accept = video(ui)
 CALL clear(1,1)
 SET printer = "MINE"
 SET dir_name = fillstring(60," ")
 SET file_name = fillstring(60," ")
 SET choice_row = 06
 SET dir_row = 08
 SET file_row = 10
 SET print_row = 12
#start
 CALL video(r)
 CALL clear(1,1,80)
 CALL clear(2,1,80)
 CALL clear(22,1,80)
 CALL video(r)
 CALL text(01,10," CCL Browse Utility",wide)
 CALL video(n)
 CALL clear(24,1)
 CALL box(3,1,18,80)
 CALL text(choice_row,05,"Choice")
 CALL text(file_row,05,"File")
 CALL text(dir_row,05,"Directory")
 CALL text(print_row,05,"Printer")
 CALL text(choice_row,15,choice,accept)
 CALL text(dir_row,15,dir_name,accept)
 CALL text(file_row,15,file_name,accept)
 CALL text(print_row,15,printer,accept)
#begin_choice
 FREE DEFINE rtl
 SET help = fix(value(choice_help))
 CALL accept(choice_row,15,"P(20);CUF")
 SET choice = curaccept
 SET help = off
 CALL video(n)
 CASE (choice)
  OF "DIRECTORY":
   CALL accept(dir_row,15,"P(60);CU")
   SET dir_name = curaccept
   SET buffer = concat("DIR/COL=1/OUTPUT=",browse_file," ",dir_name)
   CALL text(24,1,"WAIT FOR DIRECTORY")
   CALL dcl(buffer,size(trim(buffer)),0)
   CALL clear(24,1)
   SET logical cclb value(trim(dir_name))
  OF "BROWSE":
   IF (dir_name != " ")
    DEFINE rtl trim(browse_file)
    SET help =
    SELECT INTO "NL:"
     file_name = rtlt.line
     FROM rtlt
     WHERE rtlt.line != " "
     WITH nocounter
    ;end select
    CALL accept(file_row,15,"P(60);FCU")
    SET file_name = curaccept
    IF (findstring(".DIR",file_name)=0)
     SET help = off
     FREE DEFINE rtl
     SET buffer = concat("CCLB:",trim(file_name))
     DEFINE rtl trim(buffer)
     SELECT INTO mine
      line = rtlt.line
      FROM rtlt
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  OF "PRINT":
   CALL accept(print_row,15,"P(60);CU")
   SET printer = curaccept
   SET buffer = concat("CCLB:",trim(file_name))
   SET spool value(buffer) value(printer) WITH notify
   CALL video(n)
 ENDCASE
 GO TO start
#last
 CALL clear(1,1)
;#end
END GO
