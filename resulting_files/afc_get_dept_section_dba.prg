CREATE PROGRAM afc_get_dept_section:dba
 SET dept_cd = 0.0
 SET section_cd = 0.0
 SET subsection_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("DEPARTMENT", "SECTION", "SUBSECTION")
  DETAIL
   IF (cv.cdf_meaning="DEPARTMENT")
    dept_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="SECTION")
    section_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="SUBSECTION")
    subsection_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET last_level = 0
 SET stat = alterlist(hold_dept->row,1)
 SET hold_dept->num = 1
 SET hold_dept->row[1].dept =  $1
 SET hold_dept->row[1].section = 0.0
 SET hold_dept->row[1].subsection = 0.0
 SET hold_dept->row[1].group_type_cd = dept_cd
 SET hold_dept->row[1].srv_cd =  $1
 SET hold_dept->row[1].level = 0
 SET finished = 0
 FOR (count1 = 1 TO 50)
  CALL get_children("bogus")
  IF (finished=1)
   SET count1 = 50
  ENDIF
 ENDFOR
 IF (( $2="DEBUG"))
  SELECT
   d1.seq, level = hold_dept->row[d1.seq].level, dept = hold_dept->row[d1.seq].dept,
   section = hold_dept->row[d1.seq].section, subsection = hold_dept->row[d1.seq].subsection, type =
   hold_dept->row[d1.seq].group_type_cd,
   srv_cd = hold_dept->row[d1.seq].srv_cd
   FROM (dummyt d1  WITH seq = value(hold_dept->num))
   WITH nocounter
  ;end select
 ENDIF
 GO TO end_program
 SUBROUTINE get_children(bogus)
   SET last_num = hold_dept->num
   SELECT INTO "nl:"
    FROM resource_group a,
     (dummyt d1  WITH seq = value(hold_dept->num))
    PLAN (d1
     WHERE (hold_dept->row[d1.seq].level=last_level))
     JOIN (a
     WHERE (a.parent_service_resource_cd=hold_dept->row[d1.seq].srv_cd)
      AND a.child_service_resource_cd > 0
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND a.resource_group_type_cd IN (dept_cd, section_cd, subsection_cd)
      AND a.active_ind=1)
    DETAIL
     last_num = (last_num+ 1), stat = alterlist(hold_dept->row,last_num), hold_dept->row[last_num].
     level = (last_level+ 1),
     hold_dept->row[last_num].dept = hold_dept->row[d1.seq].dept, hold_dept->row[last_num].section =
     hold_dept->row[d1.seq].section, hold_dept->row[last_num].subsection = hold_dept->row[d1.seq].
     subsection,
     hold_dept->row[last_num].srv_cd = a.child_service_resource_cd, hold_dept->row[last_num].
     group_type_cd = a.resource_group_type_cd
     IF (a.resource_group_type_cd=dept_cd)
      hold_dept->row[last_num].section = a.child_service_resource_cd
     ENDIF
     IF (a.resource_group_type_cd=section_cd)
      hold_dept->row[last_num].subsection = a.child_service_resource_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET finished = 1
   ENDIF
   SET hold_dept->num = last_num
   SET last_level = (last_level+ 1)
 END ;Subroutine
#end_program
 FREE SET hold_dept
END GO
