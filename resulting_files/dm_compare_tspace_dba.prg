CREATE PROGRAM dm_compare_tspace:dba
 FOR (t_tsp = 1 TO tgtdb->tspace_cnt)
   SET c_tsp = 0
   FOR (ci = 1 TO curdb->tspace_cnt)
     IF ((curdb->tspace[ci].tspace_name=tgtdb->tspace[t_tsp].tspace_name))
      SET c_tsp = ci
      SET ci = curdb->tspace_cnt
     ENDIF
   ENDFOR
   IF (c_tsp=0)
    SET tgtdb->tspace[t_tsp].new_ind = 1
    SET tgtdb->tspace[t_tsp].cur_idx = 0
   ELSE
    SET tgtdb->tspace[t_tsp].new_ind = 0
    SET tgtdb->tspace[t_tsp].cur_idx = c_tsp
   ENDIF
 ENDFOR
END GO
