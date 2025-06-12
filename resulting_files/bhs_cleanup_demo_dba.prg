CREATE PROGRAM bhs_cleanup_demo:dba
 CALL echo("starting bhs_cleanup_demo")
 FREE RECORD clup_rec
 RECORD clup_rec(
   1 desc[*]
     2 clup_demo_id = f8
     2 clup_code_value = f8
     2 clup_description = vc
     2 clup_display = vc
 )
 DECLARE c_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM bhs_demographics bh,
   code_value cv,
   code_value_alias cva
  PLAN (cv
   WHERE cv.code_set=104490
    AND cv.active_ind=1)
   JOIN (cva
   WHERE cva.code_set=cv.code_set
    AND cva.code_value=cv.code_value)
   JOIN (bh
   WHERE trim(bh.display,3)=trim(cva.alias,3)
    AND bh.code_value=0.00
    AND bh.description="ethnicity*"
    AND bh.active_ind=1)
  ORDER BY bh.bhs_demographics_id
  HEAD bh.bhs_demographics_id
   c_cnt = (c_cnt+ 1), stat = alterlist(clup_rec->desc,c_cnt), clup_rec->desc[c_cnt].clup_demo_id =
   bh.bhs_demographics_id,
   clup_rec->desc[c_cnt].clup_code_value = cva.code_value, clup_rec->desc[c_cnt].clup_description =
   bh.description, clup_rec->desc[c_cnt].clup_display = bh.display
  WITH nocounter
 ;end select
 CALL echorecord(clup_rec)
 CALL echo("Updating BHS_DEMOGRAPHIC table")
 IF (curqual > 0)
  UPDATE  FROM bhs_demographics bh,
    (dummyt d  WITH seq = value(size(clup_rec->desc,5)))
   SET bh.code_value = clup_rec->desc[d.seq].clup_code_value, bh.updt_cnt = (bh.updt_cnt+ 1), bh
    .updt_dt_tm = sysdate,
    bh.updt_id = bh.updt_id
   PLAN (d)
    JOIN (bh
    WHERE (bh.bhs_demographics_id=clup_rec->desc[d.seq].clup_demo_id)
     AND (bh.display=clup_rec->desc[d.seq].clup_display))
   WITH nocounter
  ;end update
  COMMIT
  SET reqinfo->commit_ind = 1
  SET log_message = build("Update completed for BHS_DEMOGRAPHICS table")
  CALL echo(log_message)
  GO TO exit_script
 ELSE
  SET log_message = concat("General failure - BHS_DEMOGRAPHICS	table not updated")
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(clup_rec)
 FREE RECORD clup_rec
END GO
