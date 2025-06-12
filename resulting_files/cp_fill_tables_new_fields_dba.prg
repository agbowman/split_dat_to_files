CREATE PROGRAM cp_fill_tables_new_fields:dba
 EXECUTE oragen3 "chart_format"
 CALL parser("rdb alter table chart_format add (unique_ident varchar2(60)) go")
 EXECUTE oragen3 "chart_format"
 EXECUTE oragen3 "chart_section"
 CALL parser("rdb alter table chart_section add (unique_ident varchar2(60)) go")
 EXECUTE oragen3 "chart_section"
 EXECUTE oragen3 "chart_distribution"
 CALL parser("rdb alter table chart_distribution add (unique_ident varchar2(60)) go")
 EXECUTE oragen3 "chart_distribution"
 EXECUTE oragen3 "chart_grp_evnt_set"
 CALL parser("rdb alter table chart_grp_evnt_set add (procedure_type_flag number) go")
 EXECUTE oragen3 "chart_grp_evnt_set"
 SET count1 = 0
 SET loop_count = 0
 SET nbr_updated = 0
 SET temp_uid = fillstring(132," ")
 RECORD unique_idents(
   1 format_array[*]
     2 id = f8
     2 uid = vc
   1 distribution_array[*]
     2 id = f8
     2 uid = vc
   1 section_array[*]
     2 id = f8
     2 uid = vc
 )
 SELECT INTO "nl:"
  cf.chart_format_id
  FROM chart_format cf
  WHERE trim(cf.unique_ident)=null
   AND cf.chart_format_id != 0
  HEAD REPORT
   count1 = 0, stat = alterlist(unique_idents->format_array,1)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(unique_idents->format_array,(count1+ 9))
   ENDIF
   temp_uid = concat(trim(cnvtstring(cf.chart_format_id,30,0,"R"),3)," ",trim(format(cnvtdatetime(cf
       .active_status_dt_tm),";;q"),3)), unique_idents->format_array[count1].id = cf.chart_format_id,
   unique_idents->format_array[count1].uid = temp_uid
  FOOT REPORT
   stat = alterlist(unique_idents->format_array,count1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  FOR (loop_count = 1 TO count1)
   UPDATE  FROM chart_format cf
    SET cf.unique_ident = unique_idents->format_array[loop_count].uid
    WHERE (cf.chart_format_id=unique_idents->format_array[loop_count].id)
   ;end update
   IF (curqual > 0)
    SET nbr_updated += 1
   ENDIF
  ENDFOR
 ENDIF
 IF (count1 > 0)
  IF (nbr_updated=count1)
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cs.chart_section_id
  FROM chart_section cs
  WHERE trim(cs.unique_ident)=null
   AND cs.chart_section_id != 0
  HEAD REPORT
   count1 = 0, stat = alterlist(unique_idents->section_array,1)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(unique_idents->section_array,(count1+ 9))
   ENDIF
   temp_uid = concat(trim(cnvtstring(cs.chart_section_id,30,0,"R"),3)," ",trim(format(cnvtdatetime(cs
       .active_status_dt_tm),";;q"),3)), unique_idents->section_array[count1].id = cs
   .chart_section_id, unique_idents->section_array[count1].uid = temp_uid
  FOOT REPORT
   stat = alterlist(unique_idents->section_array,count1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  FOR (loop_count = 1 TO count1)
   UPDATE  FROM chart_section cs
    SET cs.unique_ident = unique_idents->section_array[loop_count].uid
    WHERE (cs.chart_section_id=unique_idents->section_array[loop_count].id)
   ;end update
   IF (curqual > 0)
    SET nbr_updated += 1
   ENDIF
  ENDFOR
 ENDIF
 IF (count1 > 0)
  IF (nbr_updated=count1)
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cd.distribution_id
  FROM chart_distribution cd
  WHERE trim(cd.unique_ident)=null
   AND cd.distribution_id != 0
  HEAD REPORT
   count1 = 0, stat = alterlist(unique_idents->distribution_array,1)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(unique_idents->distribution_array,(count1+ 9))
   ENDIF
   temp_uid = concat(trim(cnvtstring(cd.distribution_id,30,0,"R"),3)," ",trim(format(cnvtdatetime(cd
       .active_status_dt_tm),";;q"),3)), unique_idents->distribution_array[count1].id = cd
   .distribution_id, unique_idents->distribution_array[count1].uid = temp_uid
  FOOT REPORT
   stat = alterlist(unique_idents->distribution_array,count1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  FOR (loop_count = 1 TO count1)
   UPDATE  FROM chart_distribution cd
    SET cd.unique_ident = unique_idents->distribution_array[loop_count].uid
    WHERE (cd.distribution_id=unique_idents->distribution_array[loop_count].id)
   ;end update
   IF (curqual > 0)
    SET nbr_updated += 1
   ENDIF
  ENDFOR
 ENDIF
 IF (count1 > 0)
  IF (nbr_updated=count1)
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
 UPDATE  FROM chart_grp_evnt_set cges
  SET cges.procedure_type_flag = 0
  WHERE cges.chart_group_id != 0
 ;end update
 IF (curqual > 0)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
