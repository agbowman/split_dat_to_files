CREATE PROGRAM drc_calc_get_units:dba
 RECORD reply(
   1 uomlist[*]
     2 uom_id = f8
     2 uom_cki = vc
     2 uom_cd = f8
     2 uom_disp = vc
     2 uom_base_nbr = i4
     2 uom_branch_nbr = i4
     2 uom_multiply_factor = f8
     2 uom_addition_addend = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 SET count1 = 0
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SELECT INTO "nl:"
  c.drc_unit_cki, uom_cd = uar_get_code_by_cki(c.drc_unit_cki)
  FROM drc_unit c
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->uomlist,5))
    stat = alterlist(reply->uomlist,(count1+ 10))
   ENDIF
   reply->uomlist[count1].uom_id = c.drc_unit_id, reply->uomlist[count1].uom_cki = c.drc_unit_cki,
   reply->uomlist[count1].uom_cd = uom_cd,
   reply->uomlist[count1].uom_disp = uar_get_code_display(uom_cd), reply->uomlist[count1].
   uom_base_nbr = c.base_nbr, reply->uomlist[count1].uom_branch_nbr = c.branch_nbr,
   reply->uomlist[count1].uom_multiply_factor = c.multiply_factor_amt, reply->uomlist[count1].
   uom_addition_addend = c.addition_addend_amt
  FOOT REPORT
   stat = alterlist(reply->uomlist,count1)
  WITH nocounter
 ;end select
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,errcnt)
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
 ENDWHILE
 IF (curqual=0
  AND (errors->err_cnt > 1))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDERS"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
