CREATE PROGRAM cp_retrofit_unique_idents:dba
 SET status = 0
 SET status_msg = fillstring(132," ")
 SET num_to_update = 0
 SELECT INTO "nl:"
  cf.chart_format_id
  FROM chart_format cf
  WITH nocounter
 ;end select
 SET num_to_update = curqual
 IF (curqual > 0)
  UPDATE  FROM chart_format cf
   SET cf.unique_ident = concat(trim(cnvtstring(cf.chart_format_id,30,0,"R"),3)," ",trim(format(
       curdate,"DD-MMM-YYYY;;D"),3)," ",trim(format(curtime3,";3;M"),3))
   WHERE 1=1
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual != num_to_update)
  SET status = (status+ 1)
 ENDIF
 SELECT INTO "nl:"
  cs.chart_section_id
  FROM chart_section cs
  WITH nocounter
 ;end select
 SET num_to_update = curqual
 IF (curqual > 0)
  UPDATE  FROM chart_section cs
   SET cs.unique_ident = concat(trim(cnvtstring(cs.chart_section_id,30,0,"R"),3)," ",trim(format(
       curdate,"DD-MMM-YYYY;;D"),3)," ",trim(format(curtime3,";3;M"),3))
   WHERE 1=1
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual != num_to_update)
  SET status = (status+ 2)
 ENDIF
 SELECT INTO "nl:"
  cd.distribution_id
  FROM chart_distribution cd
  WITH nocounter
 ;end select
 SET num_to_update = curqual
 IF (curqual > 0)
  UPDATE  FROM chart_distribution cd
   SET cd.unique_ident = concat(trim(cnvtstring(cd.distribution_id,30,0,"R"),3)," ",trim(format(
       curdate,"DD-MMM-YYYY;;D"),3)," ",trim(format(curtime3,";3;M"),3))
   WHERE 1=1
   WITH nocounter
  ;end update
 ENDIF
 IF (curqual != num_to_update)
  SET status = (status+ 4)
 ENDIF
 CASE (status)
  OF 0:
   SET status_msg = "Tables successfully updated"
  OF 1:
   SET status_msg = "Error Updating chart_format table"
  OF 2:
   SET status_msg = "Error Updating chart_section table"
  OF 3:
   SET status_msg = "Error Updating chart_format, chart_section tables"
  OF 4:
   SET status_msg = "Error Updating chart_distribution table"
  OF 5:
   SET status_msg = "Error Updating chart_format, chart_distribution tables"
  OF 6:
   SET status_msg = "Error Updating chart_section, chart_distribution tables"
  OF 7:
   SET status_msg = "Error Updating chart_format, chart_section, chart_distribution tables"
 ENDCASE
 CALL echo(status_msg)
END GO
