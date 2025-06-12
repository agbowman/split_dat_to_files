CREATE PROGRAM dm_land_early_removal:dba
 FREE RECORD le_remove
 RECORD le_remove(
   1 le_rmvl[*]
     2 end_state = vc
 )
 SET land_early_version = "000"
 DECLARE cnt = i4
 DECLARE cnt1 = i4
 DECLARE x = i4
 DECLARE a = i4
 SET cnt = 0
 SET cnt1 = 0
 SET x = 0
 SET a = 0
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(le_remove->le_rmvl,cnt)
 FOR (a = 1 TO cnt)
   SET le_remove->le_rmvl[a].end_state = trim(requestin->list_0[a].end_state,3)
 ENDFOR
 FOR (x = 1 TO cnt)
  DELETE  FROM ocd_readme_component o
   WHERE (cnvtupper(o.end_state)=le_remove->le_rmvl[x].end_state)
  ;end delete
  COMMIT
 ENDFOR
END GO
