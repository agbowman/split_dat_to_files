CREATE PROGRAM ccl_prompt_rename_prompts
 DECLARE promptexist(strprgname=vc) = i2
 SET request->programname = cnvtlower(request->programname)
 SET request->newprogramname = cnvtlower(request->newprogramname)
 IF (promptexist(request->newprogramname) != 1)
  UPDATE  FROM ccl_prompt_definitions cpd
   SET cpd.program_name = request->newprogramname
   WHERE (cpd.program_name=request->programname)
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SUBROUTINE promptexist(strprgname)
   DECLARE bfound = i2 WITH noconstant(0), private
   SELECT INTO "nil"
    count(*)
    FROM ccl_prompt_definitions cpd
    WHERE cpd.program_name=strprgname
    DETAIL
     bfound = 1
    WITH nocounter
   ;end select
   CALL echo(cnvtstring(bfound))
   RETURN(bfound)
 END ;Subroutine
END GO
