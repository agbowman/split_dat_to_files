CREATE PROGRAM bbt_get_reagent_cells:dba
 RECORD reply(
   1 cell_group_active_ind = i4
   1 cell_group_description = vc
   1 cell_data[10]
     2 cell_id = f8
     2 cell_cd = f8
     2 cell_display = vc
     2 cell_mean = c12
     2 updt_cnt = i4
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
 SELECT INTO "nl:"
  cv.description, cg.cell_id
  FROM code_value cv,
   cell_group cg
  PLAN (cv
   WHERE cv.code_set=1602
    AND (cv.code_value=request->cell_group_cd))
   JOIN (cg
   WHERE cg.cell_group_cd=outerjoin(cv.code_value)
    AND cg.active_ind=outerjoin(1))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->cell_data,(count1+ 9))
   ENDIF
   reply->cell_group_active_ind = cv.active_ind, reply->cell_group_description = cv.description,
   reply->cell_data[count1].cell_id = cg.cell_id,
   reply->cell_data[count1].cell_cd = cg.cell_cd, reply->cell_data[count1].cell_display =
   uar_get_code_display(cg.cell_cd), reply->cell_data[count1].cell_mean = uar_get_code_meaning(cg
    .cell_cd),
   reply->cell_data[count1].updt_cnt = cg.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->cell_data,count1)
#stop
END GO
