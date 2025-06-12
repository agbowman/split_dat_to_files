CREATE PROGRAM bhs_eks_date_template
 PROMPT
  "Prompt1 " = "MMDDYYYY",
  "Prompt2 " = "MMDDYYYY"
 SET retval = 0
 IF (( $1="DAYOFWEEK"))
  CASE (weekday(curdate))
   OF 0:
    IF (findstring("U",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 1:
    IF (findstring("M",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 2:
    IF (findstring("T",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 3:
    IF (findstring("W",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 4:
    IF (findstring("H",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 5:
    IF (findstring("F",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
   OF 6:
    IF (findstring("S",cnvtupper( $2)) > 0)
     SET retval = 100
    ENDIF
  ENDCASE
 ELSE
  SET this_day = format(curdate,"DD;;D")
  SET this_month = format(curdate,"MM;;D")
  SET this_year = format(curdate,"YYYY;;D")
  SET beg_date_qual = replace( $1,"DD",this_day)
  SET beg_date_qual = replace(beg_date_qual,"MM",this_month)
  SET beg_date_qual = replace(beg_date_qual,"YYYY",this_year)
  SET end_date_qual = replace( $2,"DD",this_day)
  SET end_date_qual = replace(end_date_qual,"MM",this_month)
  SET end_date_qual = replace(end_date_qual,"YYYY",this_year)
  CALL echo(beg_date_qual)
  CALL echo(end_date_qual)
  IF (cnvtdatetime(curdate,curtime3) BETWEEN cnvtdatetime(cnvtdate(beg_date_qual),0) AND cnvtdatetime
  (cnvtdate(end_date_qual),235959))
   SET retval = 100
  ENDIF
 ENDIF
END GO
