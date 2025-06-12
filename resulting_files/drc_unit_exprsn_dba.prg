CREATE PROGRAM drc_unit_exprsn:dba
 DECLARE logtotal(nbrofrecs=vc) = i2
 DECLARE logfailure(logvar=vc) = i2
 DECLARE trunc_str = vc WITH noconstant("")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE loopvarin = i4 WITH noconstant(1)
 DECLARE valid_recs = i4
 DECLARE input_data = vc WITH noconstant("")
 DECLARE logvar = i2 WITH noconstant(0)
 DECLARE dir_name = vc WITH noconstant("")
 DECLARE numrows = i4
 DECLARE recsize = i4
 SET dir_name = "ccluserdir:"
 SELECT INTO concat(trim(dir_name),"drc_unit_exprsn.log")
  logvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "drc_unit_exprsn Import Log"
  DETAIL
   col + 0
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 FREE RECORD datatowrite
 RECORD datatowrite(
   1 list_0[*]
     2 drc_unit_exprsn_id = f8
     2 unit_exprsn_cki = vc
     2 unit_expression = vc
 )
 CALL echorecord(requestin)
 SET recsize = size(requestin->list_0,5)
 CALL echo(build("Size of request = ",recsize))
 SET stat = alterlist(datatowrite->list_0,recsize)
 FOR (x = 1 TO recsize)
   SELECT INTO "nl:"
    y = seq(drc_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     datatowrite->list_0[x].drc_unit_exprsn_id = y
    WITH format, nocounter
   ;end select
   SET datatowrite->list_0[x].unit_exprsn_cki = requestin->list_0[x].unit_exprsn_cki
   SET datatowrite->list_0[x].unit_expression = requestin->list_0[x].unit_expression
 ENDFOR
 CALL echo("Data that will be written:")
 CALL echorecord(datatowrite)
 SET valid_recs = 0
 SET numrows = size(datatowrite->list_0,5)
 SET readme_data->status = "F"
 DELETE  FROM drc_unit_exprsn_reltn
  WHERE 1=1
 ;end delete
 DELETE  FROM drc_unit_exprsn
  WHERE 1=1
 ;end delete
 WHILE (loopvarin <= numrows)
  IF ((datatowrite->list_0[loopvarin].drc_unit_exprsn_id > 0)
   AND (datatowrite->list_0[loopvarin].unit_exprsn_cki != "")
   AND (datatowrite->list_0[loopvarin].unit_expression != ""))
   SELECT INTO "nl:"
    FROM drc_unit_exprsn t
    WHERE (t.drc_unit_exprsn_id=datatowrite->list_0[loopvarin].drc_unit_exprsn_id)
    WITH nocounter
   ;end select
   CALL echo(build("Duplicate Check curqual = ",curqual))
   IF (curqual=0)
    SET valid_recs = (valid_recs+ 1)
    SET input_data = build("Trying to insert the table: (",datatowrite->list_0[loopvarin].
     drc_unit_exprsn_id,", ",datatowrite->list_0[loopvarin].unit_exprsn_cki,", ",
     datatowrite->list_0[loopvarin].unit_expression,")")
    CALL echo(input_data)
    INSERT  FROM drc_unit_exprsn d
     SET d.drc_unit_exprsn_id = datatowrite->list_0[loopvarin].drc_unit_exprsn_id, d.unit_exprsn_cki
       = datatowrite->list_0[loopvarin].unit_exprsn_cki, d.unit_expression = datatowrite->list_0[
      loopvarin].unit_expression,
      d.updt_dt_tm = sysdate, d.updt_task = reqinfo->updt_task
     WITH check
    ;end insert
    SET errorcode = error(readme_data->message,0)
    CALL echo(build("Error Message:",readme_data->message))
    CALL echo(build("Error Code:",errorcode))
    IF (errorcode > 0)
     CALL logfailure(input_data)
     ROLLBACK
     GO TO enditnow
    ELSE
     COMMIT
    ENDIF
   ENDIF
  ENDIF
  SET loopvarin = (loopvarin+ 1)
 ENDWHILE
 CALL logtotal(valid_recs)
 SET readme_data->status = "S"
 SET readme_data->message = "CKI list inserted successfully"
 GO TO enditnow
 SUBROUTINE logtotal(nbrofrecs)
   SELECT INTO concat(trim(dir_name),"drc_unit_exprsn.log")
    nbrofrecs
    HEAD REPORT
     row + 1
    DETAIL
     row + 1, col 0, "Executing drc_unit_exprsn import for: ",
     nbrofrecs, " records"
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logfailure(logvar)
   SELECT INTO concat(trim(dir_name),"drc_unit_exprsn.log")
    logvar
    HEAD REPORT
     row + 1
    DETAIL
     row + 1, col 0, "Failure ",
     logvar
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 500, maxrow = 1
   ;end select
 END ;Subroutine
#enditnow
 SET mod_date = "11/15/05"
 SET last_mod = "000"
END GO
