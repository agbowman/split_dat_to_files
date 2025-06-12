CREATE PROGRAM dm_record_readme_components:dba
 DECLARE drrc_count = i4
 DECLARE drrc_ndx = i4
 SET drrc_count = 0
 SET drrc_ndx = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   ocd_readme_component orc
  PLAN (d)
   JOIN (orc
   WHERE (orc.end_state=request->qual[d.seq].script_name)
    AND orc.component_type="SCRIPT")
  DETAIL
   request->qual[d.seq].insert_ind = "F"
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d
   WHERE (request->qual[d.seq].insert_ind != "F"))
  DETAIL
   FOR (drrc_ndx = (d.seq+ 1) TO size(request->qual,5))
     IF ((request->qual[drrc_ndx].script_name=request->qual[d.seq].script_name)
      AND (request->qual[drrc_ndx].insert_ind != "F"))
      request->qual[drrc_ndx].insert_ind = "F"
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 INSERT  FROM ocd_readme_component orc,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET orc.end_state = request->qual[d.seq].script_name, orc.manual_ind = 1, orc.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   orc.component_type = "SCRIPT"
  PLAN (d
   WHERE (request->qual[d.seq].insert_ind != "F"))
   JOIN (orc)
  WITH nocounter
 ;end insert
 COMMIT
END GO
