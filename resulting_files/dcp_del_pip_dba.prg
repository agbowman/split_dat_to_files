CREATE PROGRAM dcp_del_pip:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET pip_section_id[100] = 0
 SET pip_column_id[100] = 0
 SET count = 0
 SELECT INTO "nl:"
  FROM pip_section ps
  WHERE (ps.pip_id=request->pip_id)
  DETAIL
   count = (count+ 1), pip_section_id[count] = ps.pip_section_id,
   CALL echo(build("pip section id = ",pip_section_id[count])),
   CALL echo(build("count = ",count))
  WITH nocounter
 ;end select
 SET count2 = 0
 FOR (x = 1 TO count)
   DELETE  FROM pip_prefs pp
    WHERE (pp.parent_entity_id=pip_section_id[x])
    WITH nocounter
   ;end delete
   SELECT INTO "nl:"
    FROM pip_column pc
    WHERE (pip_section_id[x]=pc.pip_section_id)
    DETAIL
     count2 = (count2+ 1), pip_column_id[count2] = pc.pip_column_id,
     CALL echo(build("pip column id = ",pip_column_id[count2])),
     CALL echo(build("count2 = ",count2))
    WITH nocounter
   ;end select
   FOR (i = 1 TO count2)
    DELETE  FROM pip_prefs pp
     WHERE (pp.parent_entity_id=pip_column_id[i])
     WITH nocounter
    ;end delete
    DELETE  FROM pip_column pc
     WHERE (pc.pip_section_id=pip_section_id[x])
     WITH nocounter
    ;end delete
   ENDFOR
 ENDFOR
 DELETE  FROM pip_section ps
  WHERE (ps.pip_id=request->pip_id)
  WITH nocounter
 ;end delete
 DELETE  FROM pip p
  WHERE (p.pip_id=request->pip_id)
  WITH nocounter
 ;end delete
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
