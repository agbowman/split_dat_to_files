CREATE PROGRAM dta_ec_maint:dba
 PAINT
#loop
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,79)
 CALL video(n)
 CALL text(2,17,"D T A - E C   M A I N T A I N A N C E")
 CALL text(19,15,"ENTER TASK ASSAY CD -->")
 CALL text(21,15,"ENTER EVENT CD -->")
 CALL accept(19,50,"999999999;")
 SET dta = curaccept
 CALL accept(21,50,"999999999;")
 SET ec = curaccept
 IF (dta=0)
  GO TO done
 ENDIF
 UPDATE  FROM discrete_task_assay
  SET event_cd = ec
  WHERE task_assay_cd=dta
 ;end update
 GO TO loop
#done
 CALL clear(1,1)
 CALL text(12,30,"Commit changes?")
 CALL accept(12,60,"X;CU","N")
 IF (curaccept="Y")
  COMMIT
 ENDIF
END GO
