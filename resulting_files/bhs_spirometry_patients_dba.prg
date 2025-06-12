CREATE PROGRAM bhs_spirometry_patients:dba
 SET logical spirometry "bhscust:spirometry_patient_list.csv"
 FREE DEFINE rtl
 DEFINE rtl "spirometry"
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 lastname = vc
     2 firstname = vc
     2 dob = vc
     2 testdate = vc
     2 mrn = vc
     2 gender = vc
 )
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].line =
   trim(r.line,3)
  FOOT REPORT
   FOR (x = 2 TO temp->cnt)
     data = " ", str = " ", data = temp->qual[x].line,
     num = 1
     WHILE (str != notfnd)
       str = " ", str = piece(data,",",num,notfnd), num = (num+ 1)
       IF (str != "<not_found>")
        CASE (num)
         OF 1:
          temp->qual[x].mrn = str
         OF 2:
          temp->qual[x].testdate = str
         OF 3:
          temp->qual[x].gender = str
         OF 4:
          temp->qual[x].lastname = str
         OF 5:
          temp->qual[x].firstname = str
        ENDCASE
       ENDIF
     ENDWHILE
   ENDFOR
  WITH nocounter, time = 120
 ;end select
 CALL echorecord(temp)
END GO
