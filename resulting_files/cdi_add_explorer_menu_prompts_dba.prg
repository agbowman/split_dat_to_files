CREATE PROGRAM cdi_add_explorer_menu_prompts:dba
 DECLARE buildexplorermenutree(parentmenuid=f8(ref),indexparam=i4) = i4 WITH protect
 DECLARE i4promptqualcount = i4 WITH noconstant(0), protect
 DECLARE f8parentmenuid = f8 WITH noconstant(0.0), protect
 DECLARE f8sequence = f8 WITH noconstant(0.0), protect
 DECLARE vcpromptname = vc WITH noconstant(""), protect
 DECLARE i1processitem = i1 WITH noconstant(0), protect
 FREE RECORD prompts
 RECORD prompts(
   1 qual[*]
     2 name = c30
     2 description = c40
     2 type = c1
 )
 DEFINE rtl3 value("cer_install:cdi_prompts.csv")
 SELECT INTO "nl:"
  line = substring(1,32768,t.line)
  FROM rtl3t t
  WHERE t.line > " "
  DETAIL
   IF (mod(i4promptqualcount,10)=0)
    stat = alterlist(prompts->qual,(i4promptqualcount+ 10))
   ENDIF
   i4promptqualcount = (i4promptqualcount+ 1), commadescription = findstring(",",line,1,0), prompts->
   qual[i4promptqualcount].description = trim(substring(1,40,substring(1,(commadescription - 1),line)
     ),3),
   commaname = findstring(",",line,(commadescription+ 1),0), prompts->qual[i4promptqualcount].name =
   trim(substring(1,30,substring((commadescription+ 1),((commaname - commadescription) - 1),line)),3),
   prompts->qual[i4promptqualcount].type = substring((commaname+ 1),1,line)
  FOOT REPORT
   stat = alterlist(prompts->qual,i4promptqualcount)
  WITH nocounter
 ;end select
 CALL buildexplorermenutree(f8parentmenuid,1)
 SUBROUTINE buildexplorermenutree(parentmenuid,indexparam)
  DECLARE f8parentmenuidhold = f8 WITH noconstant(0.0), protect
  FOR (curindex = indexparam TO i4promptqualcount)
   SET vcpromptname = cnvtupper(prompts->qual[curindex].name)
   IF ((((prompts->qual[curindex].type="M")) OR ((prompts->qual[curindex].type="P"))) )
    SELECT INTO "nl:"
     menu_id = em.menu_id
     FROM explorer_menu em
     WHERE em.active_ind=1
      AND em.item_name=vcpromptname
      AND (em.item_desc=prompts->qual[curindex].description)
      AND (em.item_type=prompts->qual[curindex].type)
      AND em.menu_parent_id=parentmenuid
     DETAIL
      IF ((prompts->qual[curindex].type="M"))
       i4parentmenuid = menu_id
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET f8sequence = 0
     SELECT INTO "nl:"
      ms = seq(explorer_menu_seq,nextval)
      FROM dual
      DETAIL
       f8sequence = cnvtreal(ms)
      WITH nocounter
     ;end select
     INSERT  FROM explorer_menu em
      SET em.menu_id = f8sequence, em.item_name = vcpromptname, em.item_desc = prompts->qual[curindex
       ].description,
       em.item_type = prompts->qual[curindex].type, em.menu_parent_id = parentmenuid, em.active_ind
        = 1,
       em.updt_dt_tm = cnvtdatetime(curdate,curtime3), em.updt_id = reqinfo->updt_id, em.updt_task =
       reqinfo->updt_task,
       em.updt_applctx = reqinfo->updt_applctx, em.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual != 0)
      CALL echo(build2("Inserted prompt with name = ",vcpromptname))
      IF ((prompts->qual[curindex].type="M"))
       SET parentmenuid = f8sequence
      ENDIF
     ELSE
      CALL echo(build2("Failed to insert prompt with name = ",vcpromptname))
     ENDIF
     CALL echo(build2("			   description = ",prompts->qual[curindex].description))
    ENDIF
   ELSEIF ((prompts->qual[curindex].type="S"))
    SET prompts->qual[curindex].type = "M"
    SET f8parentmenuidhold = parentmenuid
    CALL echo(build("Building submenu ","'",prompts->qual[curindex].description,"'"))
    SET curindex = buildexplorermenutree(parentmenuid,curindex)
    SET parentmenuid = f8parentmenuidhold
   ELSEIF ((prompts->qual[curindex].type="E"))
    RETURN(curindex)
   ENDIF
  ENDFOR
 END ;Subroutine
 COMMIT
 FREE RECORD prompts
END GO
