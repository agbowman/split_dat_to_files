CREATE PROGRAM cclmpagertl:dba
 IF (validate(fileio_def,999)=999)
  EXECUTE uar_fileiortl:dba
 ENDIF
 IF (validate(cclmpagertl_def,999)=999)
  CALL echo("Declaring CclmPageRtl_def")
  DECLARE cclmpagertl_def = i2 WITH persist
  SET cclmpagertll_def = 1
  IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
   CALL echo("omf_functions.inc: declaring omfsql_def")
   DECLARE omfsql_def = i2 WITH persist
   SET omfsql_def = 1
   IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
    SET trace = recpersist
    DECLARE v_omfcnt = i4 WITH protect
    SET v_omfcnt = 0
    FREE SET omf_function
    RECORD omf_function(
      1 v_func[*]
        2 v_func_name = c40
        2 v_dtype = c10
    )
    SELECT INTO "nl:"
     function_name = function_name, dtype = return_dtype
     FROM omf_function
     WHERE function_name != "uar*"
      AND function_name != "cclsql*"
     ORDER BY function_name
     DETAIL
      v_omfcnt += 1
      IF (mod(v_omfcnt,100)=1)
       stat = alterlist(omf_function->v_func,(v_omfcnt+ 99))
      ENDIF
      omf_function->v_func[v_omfcnt].v_func_name = trim(function_name)
      IF (trim(dtype)="q8")
       omf_function->v_func[v_omfcnt].v_dtype = "dq8"
      ELSE
       omf_function->v_func[v_omfcnt].v_dtype = trim(dtype)
      ENDIF
     FOOT REPORT
      stat = alterlist(omf_function->v_func,v_omfcnt)
     WITH nocounter
    ;end select
    SET trace = norecpersist
   ENDIF
   DECLARE _omfcnt = i4 WITH protect
   IF (size(omf_function->v_func,5) > 0)
    FOR (_omfcnt = 1 TO size(omf_function->v_func,5))
      IF ((omf_function->v_func[_omfcnt].v_func_name > " "))
       SET v_declare = fillstring(100," ")
       SET v_declare = concat("declare ",trim(omf_function->v_func[_omfcnt].v_func_name),"() = ",trim
        (omf_function->v_func[_omfcnt].v_dtype)," WITH PERSIST GO")
       CALL parser(trim(v_declare))
      ENDIF
    ENDFOR
   ENDIF
   CALL echo("omf_functions: defined")
  ELSE
   CALL echo("omf_functions: already defined")
  ENDIF
  DECLARE _scclscratch = vc WITH persist
  SET _scclscratch = logical("CCLSCRATCH")
 ENDIF
END GO
