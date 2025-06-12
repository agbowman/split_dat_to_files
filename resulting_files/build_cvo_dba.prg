CREATE PROGRAM build_cvo:dba
 PAINT
 FREE SET request
 RECORD request(
   1 alias = c255
   1 code_set = i4
   1 contributor_source_cd = f8
   1 cva_contributor_source_cd = f8
   1 code_value = f8
   1 alias_type_meaning = c12
 )
 SET active_ind = 0
 SET mode = 1
 SET delete_ind = 0
 SET temp_code_set = 0
#paint_screen
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"B U I L D  C O D E _ V A L U E _ O U T B O U N D  U T I L I T Y")
 CALL box(6,9,19,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11,"Enter Data:")
 CALL text(9,11,"1. Delete Rows First (Yes=1,No=0)")
 CALL text(11,11,"2. Code Set (0=All Code Set)")
 CALL text(13,11,"3. Contributor Source Cd")
 CALL text(15,11,"4. Create Alias from Display (1), Blanks (2),")
 CALL text(16,11,"         Inbound Alias (3), Outbound Alias(4)")
 CALL text(23,60,"<HELP> <PF3> Exit")
 CALL text(23,2,"< Enter Integer Value (0,1) >                       ")
 SET help = fix('0       "No",1       "Yes"')
 CALL accept(9,60,"9",cnvtint(delete_ind)
  WHERE curaccept IN (0, 1))
 SET delete_ind = curaccept
 CALL text(23,2,"< Enter Integer Value (>=0; use 0 with caution) >   ")
 SET help = promptmsg("Enter Starting Code Set -> ")
 SET help =
 SELECT INTO "nl:"
  cvs.code_set, cvs.display
  FROM code_value_set cvs
  WHERE cvs.code_set >= cnvtint(curaccept)
  WITH nocounter
 ;end select
 CALL accept(11,60,"9(11);P",cnvtint(request->code_set)
  WHERE curaccept >= 0)
 SET request->code_set = curaccept
 CALL text(23,2,"< Enter Integer Value (>0) >                        ")
 SET help =
 SELECT INTO "nl:"
  cnvtint(cv.code_value), cv.display
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.active_ind=1
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_value=curaccept
   AND cv.code_set=73
   AND cv.active_ind=1
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(13,60,"9(11)",cnvtint(request->contributor_source_cd))
 SET validate = off
 SET request->contributor_source_cd = curaccept
 CALL text(23,2,"< Enter Integer Value (1,2,3,4) >                   ")
 SET help = fix('1       "Display",2       "Blanks",3       "Inbound Alias",4       "Outbound Alias"'
  )
 CALL accept(16,60,"9",cnvtint(mode)
  WHERE curaccept IN (1, 2, 3, 4))
 SET help = off
 SET mode = curaccept
 IF (((mode=1) OR (mode=2)) )
  CALL text(18,11,"5. Select All Rows (1) or only Active Rows (2)")
  CALL text(23,2,"< Enter Integer Value (1,2) >    ")
  SET help = fix('1       "All Rows",2       "Only Active Rows"')
  CALL accept(18,60,"9",cnvtint((active_ind+ 1))
   WHERE curaccept IN (1, 2))
  SET help = off
  SET active_ind = (curaccept - 1)
 ENDIF
 IF (mode=3)
  CALL text(18,11,"5. Inbound Contributor Source Cd")
  CALL text(23,2,"< Enter Integer Value (>0) >     ")
  SET help =
  SELECT DISTINCT INTO "nl:"
   source_cd = cnvtint(cva.contributor_source_cd), cv.display
   FROM code_value_alias cva,
    code_value cv
   PLAN (cva
    WHERE cva.code_value > 0
     AND cva.contributor_source_cd > 0)
    JOIN (cv
    WHERE cv.code_value=cva.contributor_source_cd)
   WITH nocounter
  ;end select
  SET validate =
  SELECT INTO "nl:"
   cva.contributor_source_cd
   FROM code_value_alias cva
   WHERE cva.code_value > 0
    AND cva.contributor_source_cd=curaccept
    AND cva.contributor_source_cd > 0
   WITH nocounter, maxqual(cva,1)
  ;end select
  SET validate = 1
  CALL accept(18,60,"9(11)",cnvtint(request->cva_contributor_source_cd))
  SET validate = off
  SET help = off
  SET request->cva_contributor_source_cd = curaccept
 ENDIF
 IF (mode=4)
  CALL text(18,11,"5. Outbound Contributor Source Cd")
  CALL text(23,2,"< Enter Integer Value (>0) >     ")
  SET help =
  SELECT DISTINCT INTO "nl:"
   source_cd = cnvtint(cvo.contributor_source_cd), cv.display
   FROM code_value_outbound cvo,
    code_value cv
   PLAN (cvo
    WHERE cvo.code_value > 0
     AND cvo.contributor_source_cd > 0)
    JOIN (cv
    WHERE cv.code_value=cvo.contributor_source_cd)
   WITH nocounter
  ;end select
  SET validate =
  SELECT INTO "nl:"
   cvo.contributor_source_cd
   FROM code_value_outbound cvo
   WHERE cvo.code_value > 0
    AND cvo.contributor_source_cd=curaccept
    AND cvo.contributor_source_cd > 0
   WITH nocounter, maxqual(cvo,1)
  ;end select
  SET validate = 1
  CALL accept(18,60,"9(11)",cnvtint(request->cva_contributor_source_cd))
  SET validate = off
  SET help = off
  SET request->cva_contributor_source_cd = curaccept
 ENDIF
 CALL clear(23,1)
 CALL text(23,60,"<HELP> <PF3> Exit")
 CALL text(23,2,"Correct (Y/N)")
 SET help = fix('Y       "Yes",N       "No"')
 CALL accept(23,17,"p;cu","Y"
  WHERE curaccept IN ("Y", "N", "y", "n"))
 SET help = off
 IF (((curaccept="N") OR (curaccept="n")) )
  GO TO paint_screen
 ENDIF
 CALL clear(23,1)
 FREE RECORD cv_list
 RECORD cv_list(
   1 qual[*]
     2 code_set = i4
     2 code_value = f8
     2 alias_type_meaning = vc
     2 alias = vc
 )
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = 0
 SET reqinfo->updt_app = 0
 SET reqinfo->updt_task = 0
 SET reqinfo->updt_applctx = 0
 CALL clear(24,1)
 CALL video(br)
 IF (delete_ind > 0)
  CALL text(24,2,"Deleting Data...")
  IF ((request->code_set=0))
   DELETE  FROM code_value_outbound cvo
    WHERE (cvo.contributor_source_cd=request->contributor_source_cd)
   ;end delete
  ELSE
   DELETE  FROM code_value_outbound cvo
    WHERE (cvo.code_set=request->code_set)
     AND (cvo.contributor_source_cd=request->contributor_source_cd)
   ;end delete
  ENDIF
  COMMIT
 ENDIF
 CALL text(24,2,"Retrieving Data...")
 SET count = 0
 SET stat = 0
 IF (((mode=1) OR (mode=2)) )
  SET active_val = - (1)
  IF (active_ind=1)
   SET active_val = 0
  ENDIF
  SELECT
   IF ((request->code_set > 0))
    WHERE (cv.code_set=request->code_set)
     AND cv.active_ind > active_val
   ELSE
    WHERE cv.active_ind > active_val
   ENDIF
   INTO "nl:"
   cv.code_value, cv.display, cv.cdf_meaning,
   cv.code_set
   FROM code_value cv
   DETAIL
    count = (count+ 1), stat = alterlist(cv_list->qual,count), cv_list->qual[count].code_set = cv
    .code_set,
    cv_list->qual[count].code_value = cv.code_value, cv_list->qual[count].alias = cv.display, cv_list
    ->qual[count].alias_type_meaning = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (mode=3)
  SELECT
   IF ((request->code_set > 0))
    WHERE (cv.code_set=request->code_set)
     AND (cv.contributor_source_cd=request->cva_contributor_source_cd)
   ELSE
    WHERE (cv.contributor_source_cd=request->cva_contributor_source_cd)
   ENDIF
   INTO "nl:"
   cv.code_value, cv.alias, cv.alias_type_meaning,
   cv.code_set
   FROM code_value_alias cv
   DETAIL
    count = (count+ 1), stat = alterlist(cv_list->qual,count), cv_list->qual[count].code_set = cv
    .code_set,
    cv_list->qual[count].code_value = cv.code_value, cv_list->qual[count].alias = cv.alias, cv_list->
    qual[count].alias_type_meaning = cv.alias_type_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (mode=4)
  SELECT
   IF ((request->code_set > 0))
    WHERE (cv.code_set=request->code_set)
     AND (cv.contributor_source_cd=request->cva_contributor_source_cd)
   ELSE
    WHERE (cv.contributor_source_cd=request->cva_contributor_source_cd)
   ENDIF
   INTO "nl:"
   cv.code_value, cv.alias, cv.alias_type_meaning,
   cv.code_set
   FROM code_value_outbound cv
   DETAIL
    count = (count+ 1), stat = alterlist(cv_list->qual,count), cv_list->qual[count].code_set = cv
    .code_set,
    cv_list->qual[count].code_value = cv.code_value, cv_list->qual[count].alias = cv.alias, cv_list->
    qual[count].alias_type_meaning = cv.alias_type_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET idx = 0
 SET request->alias = " "
 SET temp_code_set = request->code_set
 FOR (idx = 1 TO count)
   CALL text(23,2,concat("cv=",trim(cnvtstring(cv_list->qual[idx].code_value)),", src=",trim(
      cnvtstring(request->contributor_source_cd)),", alias=",
     cv_list->qual[idx].alias))
   CALL text(24,2,concat("Building Data... ",trim(cnvtstring(idx))," of ",trim(cnvtstring(count))))
   IF (((mode=1) OR (((mode=3) OR (mode=4)) )) )
    SET request->alias = cv_list->qual[idx].alias
   ENDIF
   SET request->code_value = cv_list->qual[idx].code_value
   SET request->alias_type_meaning = cv_list->qual[idx].alias_type_meaning
   SET request->code_set = cv_list->qual[idx].code_set
   EXECUTE dm_code_value_outbound
   COMMIT
 ENDFOR
 SET request->code_set = temp_code_set
 CALL clear(23,1)
 CALL clear(24,1)
 CALL video(br)
 CALL text(24,2,concat(trim(cnvtstring(count)),
   " Row Inserted/Updated... Press <Enter> to Continue..."))
 CALL accept(24,65,"9;H",0)
 CALL clear(24,1)
 GO TO paint_screen
#ext_prg
END GO
