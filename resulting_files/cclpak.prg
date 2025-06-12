CREATE PROGRAM cclpak
 PAINT
#start
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL video(r)
 CALL clear(2,2,78)
 CALL text(2,15,"CCLPAK  --  REGISTRATION OF CCL UPDATE PROGRAM")
 CALL video(n)
 CALL text(6,5,"Delete/Add/Report")
 CALL text(7,5,"CCL Program")
 CALL text(7,45,"Duration")
 CALL text(8,5,"Report Printer/File")
 CALL text(12,10,"Enter the name of the CCL program containing updates")
 CALL text(13,10,"to a system database. All programs updating system")
 CALL text(14,10,"files must first be registered with this program.")
 CALL text(15,10,"Press HELP for list of active programs.")
 CALL text(16,10,"Press PF3 to end this program.")
 CALL text(18,10,"Set duration to 0 if this program has no expiration.")
 SET len = 0
 SET num = 0
 SET num2 = 0
 SET chr = " "
 SET p_mode = " "
 SET p_program = fillstring(12," ")
 SET p_duration = 0
 SET p_eprogram = fillstring(20," ")
 SET p_printer = fillstring(30," ")
#repeat
 SET help = fix('A"Add",D"Delete",R"Report"')
 CALL accept(6,30,"A;CU","A"
  WHERE curaccept IN ("D", "A", "R"))
 SET p_mode = curaccept
 IF (p_mode != "R")
  SET help =
  SELECT INTO "NL:"
   d.object_name, d.group
   FROM dprotect d
   WHERE d.object="P"
    AND d.group=0
   WITH nocounter
  ;end select
  CALL accept(7,30,"PPPPPPPPPPPP;CU")
  SET p_program = curaccept
  IF (p_mode="A")
   SET help = "Enter number of days before expiration, 0 if none"
   CALL accept(7,55,"999999999",0)
   SET p_duration = curaccept
  ENDIF
  CALL clear(24,1)
  CALL text(24,1,"Correct (Y/N)?")
  CALL accept(24,18,"A;CU","Y")
  CALL clear(24,1)
  IF (curaccept="N")
   GO TO repeat
  ENDIF
  SET len = findstring(" ",p_program)
  SET p_eprogram = modcheck(9910,p_program)
 ENDIF
 CASE (p_mode)
  OF "A":
   INSERT  FROM cclpak p
    SET p.datestamp = curdate, p.timestamp = curtime, p.datespan = p_duration,
     p.eprogram = p_eprogram, p.len = num2
    WITH nocounter
   ;end insert
   CALL text(24,1,format(curqual,"#####"))
   CALL text(24,10,"Program added to registration")
   GO TO repeat
  OF "D":
   IF (p_program="ALL")
    DELETE  FROM cclpak p
     WHERE p.eprogram="*"
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM cclpak p
     WHERE p.eprogram=p_eprogram
     WITH nocounter
    ;end delete
   ENDIF
   CALL text(24,1,format(curqual,"#####"))
   CALL text(24,10,"Program removed from registration")
   GO TO repeat
  OF "R":
   SET help = "Enter printer name, file name or MINE"
   CALL video(ru)
   CALL text(7,30,"ALL         ")
   CALL text(7,55,"         ")
   CALL video(n)
   CALL accept(8,30,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU","MINE")
   SET p_printer = curaccept
   EXECUTE cclpak2 trim(p_printer)
   GO TO start
 ENDCASE
END GO
