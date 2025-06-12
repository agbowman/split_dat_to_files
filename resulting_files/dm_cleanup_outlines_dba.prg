CREATE PROGRAM dm_cleanup_outlines:dba
 FREE RECORD unique_id
 RECORD unique_id(
   1 qual[*]
     2 str_from = vc
     2 str_to = vc
 )
 FREE RECORD unique_temp
 RECORD unique_temp(
   1 newname = vc
   1 tmp = vc
   1 temp1 = vc
   1 addtemp = f8
   1 fchr = f8
   1 ftmp = f8
   1 sqllen = i4
 )
 DECLARE unique_single(uni_str=vc) = vc
 DECLARE unique_multi(d=i2) = i2
 SUBROUTINE unique_multi(d)
   IF (value(size(unique_id->qual,5)) > 0)
    FOR (x = 1 TO value(size(unique_id->qual,5)))
      SET unique_id->qual[x].str_to = unique_single(trim(unique_id->qual[x].str_from,3))
    ENDFOR
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE unique_single(uni_str)
   SET unique_temp->newname = ""
   IF (textlen(trim(uni_str,3)) > 0)
    SET unique_temp->addtemp = 0
    SET unique_temp->tmp = ""
    SET unique_temp->sqllen = textlen(trim(uni_str,3))
    SET unique_temp->newname = cnvtstring(unique_temp->sqllen)
    FOR (y = 1 TO value(unique_temp->sqllen))
      SET unique_temp->fchr = ichar(substring(y,1,trim(uni_str,3)))
      SET unique_temp->ftmp = y
      SET unique_temp->ftmp = (unique_temp->fchr/ y)
      SET unique_temp->addtemp = (unique_temp->addtemp+ unique_temp->ftmp)
    ENDFOR
    SET unique_temp->tmp = cnvtalphanum(cnvtstring(unique_temp->addtemp,19,16,r))
    SET unique_temp->newname = trim(concat(unique_temp->newname,unique_temp->tmp),3)
   ENDIF
   RETURN(unique_temp->newname)
 END ;Subroutine
 IF (currdb="DB2UDB")
  CALL echo("** Auto Exit for DB2 **")
  GO TO exit_immediately
 ENDIF
 DECLARE totalcount = i4
 DECLARE sqllen = i4
 RECORD outln(
   1 qual[*]
     2 oname = c30
     2 sqltext = vc
     2 rowid = c18
     2 deleted = i2
 )
 RECORD temp(
   1 newname = vc
   1 tmp = vc
   1 temp1 = vc
   1 searchby = vc
   1 str_spec1 = vc
   1 str_spec2 = vc
   1 err_msg = vc
   1 fail_flag = i2
 )
 RECORD del_sql(
   1 qual[5]
     2 sql = vc
 )
 SET err_msg = ""
 SET fail_flag = 0
 SET width = 132
 SET message = window
 CALL clear(1,1)
 CALL text(1,2,concat("Gathering outlines ",format(curtime3,"HH:MM:SS;;S")))
 CALL text(2,2,"This can take several minutes....please be patient.")
 SET del_sql->qual[1].sql = concat("ENCOUNTER E  SET E.PERSON_ID ",
  "=     DECODE(  :1 ,0.000000,E.PERSON_ID, - 1.000000,0.000000, :2 )")
 SET del_sql->qual[2].sql = "GETMOVESERIESDATA"
 SET del_sql->qual[3].sql = "GETMATCHDATA"
 SET del_sql->qual[4].sql = "OMF_GET_GROUPING"
 SET del_sql->qual[5].sql = "OLOL"
 SET str_spec1 = "FROM  CLINICAL_EVENT RDB  WHERE (RDB.EVENT_ID ="
 SET str_spec2 = "VALID_UNTIL_DT_TM =     :1  AND  NOT RDB.RECORD_STATUS_CD =     :2 )"
 SET trace symbol mark
 SELECT INTO "nl:"
  uo.sql_text, uo.name
  FROM user_outlines uo
  WHERE uo.name="SYS_OUTLINE*"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(outln->qual,cnt), outln->qual[cnt].oname = uo.name,
   outln->qual[cnt].sqltext = uo.sql_text, outln->qual[cnt].deleted = 0
  FOOT REPORT
   totalcount = count(uo.name)
  WITH nocounter
 ;end select
 IF (error(temp->err_msg,0) != 0)
  SET temp->fail_flag = 1
  GO TO exit_script
 ELSE
  SET temp->fail_flag = 0
 ENDIF
 IF (curqual < 1)
  SET temp->err_msg = "All outlines are completed"
  SET temp->fail_flag = 1
  GO TO exit_script
 ENDIF
 CALL text(1,2,concat("Cleaning specific and non-bound ",format(curtime3,"HH:MM:SS;;S")))
 CALL text(2,2,"This can take several minutes....please be patient.")
 CALL text(3,2,"Total Count: ")
 CALL text(3,15,cnvtstring(totalcount))
 CALL text(4,2,"Current: ")
 CALL text(5,2,"Counter: ")
 SET totalcount = 0
 CALL text(5,11,"0")
 FOR (x = 1 TO value(size(outln->qual,5)))
   CALL text(4,11,cnvtstring(x))
   CALL clear(7,2,128)
   IF (findstring(str_spec1,outln->qual[x].sqltext) > 0)
    IF (findstring(str_spec2,outln->qual[x].sqltext) > 0)
     SET outln->qual[x].deleted = 1
     CALL text(7,2,"Duplicate")
    ENDIF
   ENDIF
   IF ((outln->qual[x].deleted=0))
    IF (findstring(":1",outln->qual[x].sqltext)=0)
     SET outln->qual[x].deleted = 1
     CALL text(7,2,"Missing Bind Variable")
    ENDIF
   ENDIF
   IF ((outln->qual[x].deleted=0))
    FOR (y = 1 TO 5)
      IF (findstring(del_sql->qual[y].sql,outln->qual[x].sqltext) > 0)
       SET outln->qual[x].deleted = 1
       CALL text(7,2,"List Value Match")
      ENDIF
    ENDFOR
   ENDIF
   IF ((outln->qual[x].deleted=1))
    SET totalcount = (totalcount+ 1)
    SET temp->temp1 = concat("RDB DROP OUTLINE ",trim(outln->qual[x].oname,3)," END GO")
