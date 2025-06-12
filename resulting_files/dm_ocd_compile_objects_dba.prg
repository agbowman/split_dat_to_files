CREATE PROGRAM dm_ocd_compile_objects:dba
 SET obj_name = "OCDMODE"
 SET obj_type = "OCDMODE"
 SET co_ocd_nbr =  $1
 RECORD str(
   1 str = vc
 )
 RECORD olist(
   1 olist_cnt = i4
   1 qual[*]
     2 oname = vc
     2 otype = vc
     2 otype2 = vc
 )
 SET olist->olist_cnt = 0
 SET prev_cnt = 0
 SET first_pass_ind = 1
 SET more_ind = 0
 WHILE (((first_pass_ind=1) OR (more_ind=1)) )
   IF (first_pass_ind=0)
    SET prev_cnt = olist->olist_cnt
    SET olist->olist_cnt = 0
    SET more_ind = 0
   ENDIF
   SELECT
    IF (obj_name="ALLTABLES")
     FROM user_objects u
     WHERE u.status="INVALID"
      AND u.object_type IN ("PACKAGE", "PROCEDURE", "FUNCTION", "TRIGGER", "VIEW",
     "PACKAGE BODY")
     ORDER BY u.object_name
    ELSEIF (obj_type="OCDMODE")
     FROM dm_afd_tables a,
      user_dependencies d,
      user_objects u
     WHERE a.alpha_feature_nbr=co_ocd_nbr
      AND d.referenced_name=a.table_name
      AND u.object_name=d.name
      AND u.status="INVALID"
      AND u.object_type IN ("PACKAGE", "PROCEDURE", "FUNCTION", "TRIGGER", "VIEW",
     "PACKAGE BODY")
     ORDER BY u.object_name
    ELSEIF (obj_type="TABLE")
     FROM user_objects u,
      user_dependencies d
     WHERE d.referenced_name=patstring(obj_name)
      AND u.object_name=d.name
      AND u.status="INVALID"
      AND u.object_type IN ("PACKAGE", "PROCEDURE", "FUNCTION", "TRIGGER", "VIEW",
     "PACKAGE BODY")
     ORDER BY u.object_name
    ELSEIF (obj_type="OBJECT")
     FROM user_objects u
     WHERE u.status="INVALID"
      AND u.object_name=patstring(obj_name)
      AND u.object_type IN ("PACKAGE", "PROCEDURE", "FUNCTION", "TRIGGER", "VIEW",
     "PACKAGE BODY")
     ORDER BY u.object_name
    ELSE
    ENDIF
    DISTINCT INTO "nl:"
    u.object_name
    DETAIL
     olist->olist_cnt = (olist->olist_cnt+ 1), stat = alterlist(olist->qual,olist->olist_cnt), olist
     ->qual[olist->olist_cnt].oname = u.object_name,
     olist->qual[olist->olist_cnt].otype = u.object_type
     IF ((olist->qual[olist->olist_cnt].otype="PACKAGE BODY"))
      olist->qual[olist->olist_cnt].otype2 = "PACKAGE"
     ELSE
      olist->qual[olist->olist_cnt].otype2 = u.object_type
     ENDIF
    WITH nocounter, noformfeed, maxcol = 200
   ;end select
   IF ((olist->olist_cnt > 0))
    IF (first_pass_ind=1)
     SET more_ind = 1
    ELSEIF ((olist->olist_cnt != prev_cnt))
     SET more_ind = 1
    ENDIF
   ENDIF
   IF (more_ind=1)
    FOR (i = 1 TO olist->olist_cnt)
      SET str->str = concat("RDB ASIS('ALTER ",olist->qual[i].otype2," ",olist->qual[i].oname," ')")
      CALL echo(str->str)
      CALL parser(str->str)
      IF ((olist->qual[i].otype="PACKAGE BODY"))
       SET str->str = "ASIS(' COMPILE BODY ')"
      ELSE
       SET str->str = "ASIS(' COMPILE ')"
      ENDIF
      CALL echo(str->str)
      CALL parser(str->str)
      SET str->str = "end go "
      CALL echo(str->str)
      CALL parser(str->str)
    ENDFOR
   ENDIF
   SET first_pass_ind = 0
 ENDWHILE
#exit_script
END GO
