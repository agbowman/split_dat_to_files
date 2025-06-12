CREATE PROGRAM djh_l_prsnl_slct_by_usrnm
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.active_ind"##", p.username, p.name_full_formatted,
  p_position_disp = uar_get_code_display(p.position_cd), p.beg_effective_dt_tm, p.updt_dt_tm,
  p.person_id, p.position_cd, p.end_effective_dt_tm,
  p.updt_id, p1.name_full_formatted
  FROM prsnl p,
   prsnl p1
  PLAN (p
   WHERE p.active_ind >= 0
    AND p.username != "*09757"
    AND ((p.username="0000000") OR (((p.username="*05500*") OR (((p.username="*01219*") OR (((p
   .username="*48601*") OR (((p.username="*11389*") OR (((p.username="*11651*") OR (((p.username=
   "*30995*") OR (((p.username="*48654*") OR (((p.username="*01116*") OR (((p.username="*48691*") OR
   (((p.username="*08131*") OR (((p.username="*07637*") OR (((p.username="*05436*") OR (((p.username=
   "*41029*") OR (((p.username="*11722*") OR (((p.username="*49294*") OR (((p.username="*03827*") OR
   (((p.username="*48814*") OR (((p.username="*43841*") OR (((p.username="*11267*") OR (((p.username=
   "*11918*") OR (((p.username="*03287*") OR (((p.username="*07711*") OR (((p.username="*11342*") OR
   (((p.username="*42705*") OR (((p.username="*11615*") OR (((p.username="*48059*") OR (((p.username=
   "*02784*") OR (((p.username="*05676*") OR (((p.username="*06893*") OR (((p.username="*43778*") OR
   (((p.username="*45631*") OR (((p.username="*08068*") OR (((p.username="*42418*") OR (((p.username=
   "*00472*") OR (((p.username="*03638*") OR (((p.username="*10177*") OR (((p.username="*11482*") OR
   (((p.username="*10512*") OR (((p.username="*08654*") OR (((p.username="*44279*") OR (((p.username=
   "*00207*") OR (((p.username="*10871*") OR (((p.username="*11522*") OR (((p.username="*11598*") OR
   (((p.username="*41916*") OR (((p.username="*11266*") OR (((p.username="*46852*") OR (((p.username=
   "*48574*") OR (((p.username="*11465*") OR (((p.username="*42302*") OR (((p.username="*10126*") OR
   (((p.username="*02222*") OR (((p.username="*49131*") OR (((p.username="*08525*") OR (((p.username=
   "*21878*") OR (((p.username="*24552*") OR (((p.username="*48417*") OR (((p.username="*20262*") OR
   (((p.username="*41658*") OR (((p.username="*45285*") OR (((p.username="*11152*") OR (((p.username=
   "*09195*") OR (((p.username="*49007*") OR (((p.username="*04759*") OR (((p.username="*20959*") OR
   (((p.username="*08786*") OR (((p.username="*03355*") OR (((p.username="*06285*") OR (((p.username=
   "*11622*") OR (((p.username="*11412*") OR (((p.username="*10590*") OR (((p.username="*03483*") OR
   (((p.username="*11161*") OR (((p.username="*10507*") OR (((p.username="*43542*") OR (((p.username=
   "*05481*") OR (((p.username="*44513*") OR (((p.username="*11584*") OR (((p.username="*09825*") OR
   (((p.username="*47071*") OR (((p.username="*43936*") OR (((p.username="*47654*") OR (((p.username=
   "*10260*") OR (((p.username="*11375*") OR (((p.username="*07417*") OR (((p.username="*06902*") OR
   (((p.username="*48451*") OR (((p.username="*11125*") OR (((p.username="*41322*") OR (p.username=
   "*47399*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
   JOIN (p1
   WHERE p.updt_id=p1.person_id)
  ORDER BY p.username
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36, row + 1,
   CALL print(calcpos(36,(y_pos+ 1))),
   curdate, row + 1, "{F/0}{CPI/14}",
   CALL print(calcpos(231,(y_pos+ 0))), "List of Current Terminations", row + 1,
   row + 1, y_val = ((792 - y_pos) - 37), "{PS/newpath 2 setlinewidth   29 ",
   y_val, " moveto  528 ", y_val,
   " lineto stroke 29 ", y_val, " moveto/}",
   row + 1, y_pos = (y_pos+ 40)
  DETAIL
   IF (((y_pos+ 70) >= 792))
    y_pos = 0, BREAK
   ENDIF
   p_position_disp1 = substring(1,33,p_position_disp), name_full_formatted1 = substring(1,35,p
    .name_full_formatted), username1 = substring(1,12,p.username),
   CALL print(calcpos(21,(y_pos+ 3))), p.active_ind,
   CALL print(calcpos(56,(y_pos+ 3))),
   username1,
   CALL print(calcpos(123,(y_pos+ 2))), name_full_formatted1,
   CALL print(calcpos(309,(y_pos+ 1))), p_position_disp1, row + 1,
   "{F/0}{CPI/14}",
   CALL print(calcpos(484,(y_pos+ 0))), p.updt_dt_tm,
   y_pos = (y_pos+ 16)
  WITH maxcol = 300, maxrow = 500, dio = 08,
   noheading, format = variable, time = value(maxsecs)
 ;end select
END GO
