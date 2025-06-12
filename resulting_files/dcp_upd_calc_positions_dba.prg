CREATE PROGRAM dcp_upd_calc_positions:dba
 RECORD internal(
   1 positions[*]
     2 position_cd = f8
   1 equations[*]
     2 dcp_equation_id = f8
 )
 DECLARE pos_cnt = i4 WITH noconstant(0), public
 DECLARE equa_cnt = i4 WITH noconstant(0), public
 SELECT INTO "nl:"
  c.code_set
  FROM code_value c
  WHERE c.code_set=88
   AND c.active_ind=1
  DETAIL
   pos_cnt = (pos_cnt+ 1)
   IF (pos_cnt > size(internal->positions,5))
    stat = alterlist(internal->positions,(pos_cnt+ 10))
   ENDIF
   internal->positions[pos_cnt].position_cd = c.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(internal->positions,pos_cnt)
 DELETE  FROM dcp_equa_position dep
  WHERE dep.dcp_equation_id > 0
   AND dep.position_cd > 0
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  de.dcp_equation_id
  FROM dcp_equation de
  WHERE de.dcp_equation_id > 0
  ORDER BY de.dcp_equation_id
  DETAIL
   equa_cnt = (equa_cnt+ 1)
   IF (equa_cnt > size(internal->equations,5))
    stat = alterlist(internal->equations,(equa_cnt+ 5))
   ENDIF
   internal->equations[equa_cnt].dcp_equation_id = de.dcp_equation_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO equa_cnt)
   INSERT  FROM dcp_equa_position dep,
     (dummyt d1  WITH seq = value(pos_cnt))
    SET dep.seq = 1, dep.dcp_equation_id = internal->equations[x].dcp_equation_id, dep.position_cd =
     internal->positions[d1.seq].position_cd,
     dep.updt_dt_tm = cnvtdatetime(curdate,curtime), dep.updt_id = 0, dep.updt_task = 0,
     dep.updt_applctx = 0, dep.updt_cnt = 0
    PLAN (d1)
     JOIN (dep)
    WITH nocounter
   ;end insert
 ENDFOR
 COMMIT
END GO
