CREATE PROGRAM dm_cnvt_readmes_to_downtime:dba
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 readme_id = c10
     2 execution = c10
     2 instance = i4
 )
 DECLARE dm_temp_cnt = i4
 DECLARE dm_err_ind = i4
 DECLARE dm_err_msg = c132
 DECLARE dm_csv_name = c50
 DECLARE dm_first_ind = c1
 DECLARE dm_temp_id = c10
 DECLARE dm_temp_exec = c10
 DECLARE dm_temp_find = i4
 DECLARE dm_temp_string = c50
 DECLARE stat = i4
 SET dm_temp_cnt = 0
 SET dm_err_ind = 0
 SET dm_err_msg = fillstring(132," ")
 SET dm_csv_name = " "
 SET dm_fist_ind = "N"
 SET dm_temp_id = " "
 SET dm_temp_exec = " "
 SET dm_temp_find = 0
 SET dm_temp_string = " "
 SET stat = 0
 SET stat = alterlist(temp->qual,10)
 CALL parser(concat('set logical dm_csv_name "cer_install:dm_cnvt_readmes_to_downtime.csv"'))
 CALL parser("go")
 FREE DEFINE rtl2
 DEFINE rtl2 "dm_csv_name"
 SELECT INTO "nl:"
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dm_first_ind = "Y"
  DETAIL
   IF (dm_first_ind="N")
    dm_temp_cnt = (dm_temp_cnt+ 1)
    IF (mod(dm_temp_cnt,10)=1)
     stat = alterlist(temp->qual,(dm_temp_cnt+ 9))
    ENDIF
    dm_temp_find = findstring(",",t.line), dm_temp_id = substring(1,(dm_temp_find - 1),t.line),
    dm_temp_string = substring((dm_temp_find+ 2),size(t.line,1),t.line),
    dm_temp_exec = substring((dm_temp_find+ 2),(findstring("'",dm_temp_string) - 1),t.line), temp->
    qual[dm_temp_cnt].readme_id = dm_temp_id, temp->qual[dm_temp_cnt].execution = dm_temp_exec
   ENDIF
   dm_first_ind = "N"
  WITH nocounter
 ;end select
 IF (error(dm_err_msg,1) != 0)
  CALL echo("** Initial Select Stmt Failed **")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->qual,dm_temp_cnt)
 FOR (dm_for_cnt = 1 TO size(temp->qual,5))
  SELECT INTO "nl:"
   FROM dm_readme dr
   WHERE dr.readme_id=cnvtreal(temp->qual[dm_for_cnt].readme_id)
   ORDER BY dr.readme_id, dr.instance DESC
   HEAD dr.readme_id
    IF (dr.active_ind=1)
     temp->qual[dm_for_cnt].instance = dr.instance
    ENDIF
   WITH nocounter
  ;end select
  IF (error(dm_err_msg,1) != 0)
   CALL echo("** Select Stmt #2 Failed **")
   GO TO exit_script
  ENDIF
 ENDFOR
 FOR (dm_for_cnt = 1 TO dm_temp_cnt)
   IF ((temp->qual[dm_for_cnt].instance > 0))
    UPDATE  FROM dm_readme dr
     SET dr.execution = trim(temp->qual[dm_for_cnt].execution,3)
     WHERE dr.readme_id=cnvtreal(temp->qual[dm_for_cnt].readme_id)
      AND (dr.instance=temp->qual[dm_for_cnt].instance)
     WITH nocounter
    ;end update
    IF (error(dm_err_msg,1) != 0)
     CALL echo("** Update Stmt Failed **")
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM dm_readme dr
    WHERE dr.readme_id=cnvtreal(temp->qual[dm_for_cnt].readme_id)
     AND (dr.instance=temp->qual[dm_for_cnt].instance)
    DETAIL
     IF ((dr.execution != temp->qual[dm_for_cnt].execution))
      dm_err_ind = 1,
      CALL echo(build(dr.readme_id," still has an execution of --",dr.execution))
     ENDIF
    WITH nocounter
   ;end select
   IF (error(dm_err_msg,1) != 0)
    CALL echo("******************************")
    CALL echo("** Check Select Stmt Failed **")
    CALL echo("******************************")
    ROLLBACK
   ENDIF
 ENDFOR
 IF (dm_err_ind=1)
  CALL echo("*********************************************************")
  CALL echo("*** Not all rows updated correctly on DM README table ***")
  CALL echo("*********************************************************")
  ROLLBACK
 ELSE
  CALL echo("*************************************")
  CALL echo("*** All rows SUCCESSFULLY Updated ***")
  CALL echo("*************************************")
  COMMIT
 ENDIF
#exit_script
 FREE RECORD temp
END GO
