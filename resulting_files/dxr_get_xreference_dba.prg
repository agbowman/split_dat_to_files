CREATE PROGRAM dxr_get_xreference:dba
 RECORD reply(
   1 qual[10]
     2 dept_cat_xref_id = f8
     2 department_cd = f8
     2 section_cd = f8
     2 task_type_cd = f8
     2 updt_cnt = i4
     2 dept_sect_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 IF ((request->section_cd > 0))
  SELECT INTO "nl:"
   dx.*
   FROM dept_xreference dx
   WHERE (dx.section_cd=request->section_cd)
    AND dx.dept_sect_ind=1
    AND dx.active_ind=1
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alter(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].dept_cat_xref_id = dx.dept_cat_xref_id, reply->qual[count1].department_cd =
    dx.department_cd, reply->qual[count1].section_cd = dx.section_cd,
    reply->qual[count1].task_type_cd = dx.task_type_cd, reply->qual[count1].dept_sect_ind = dx
    .dept_sect_ind, reply->qual[count1].updt_cnt = dx.updt_cnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   dx.*
   FROM dept_xreference dx
   WHERE (dx.department_cd=request->department_cd)
    AND dx.dept_sect_ind=0
    AND dx.active_ind=1
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alter(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].dept_cat_xref_id = dx.dept_cat_xref_id, reply->qual[count1].department_cd =
    dx.department_cd, reply->qual[count1].section_cd = dx.section_cd,
    reply->qual[count1].task_type_cd = dx.task_type_cd, reply->qual[count1].dept_sect_ind = dx
    .dept_sect_ind, reply->qual[count1].updt_cnt = dx.updt_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
