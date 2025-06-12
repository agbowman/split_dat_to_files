CREATE PROGRAM bed_imp_br_pharm_product_work:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET row_cnt = 0
 SET row_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO row_cnt)
   SET facility_cd = 0.0
   IF ((requestin->list_0[x].facility > " "))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.display_key=cnvtupper(cnvtalphanum(requestin->list_0[x].facility))
      AND cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
     DETAIL
      facility_cd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   SET acquisition_cost = 0.0
   IF ((requestin->list_0[x].acquisition_cost > " "))
    SET acquisition_cost = cnvtreal(requestin->list_0[x].acquisition_cost)
   ENDIF
   INSERT  FROM br_pharm_product_work b
    SET b.ndc = cnvtalphanum(requestin->list_0[x].ndc), b.description = requestin->list_0[x].
     description, b.charge_nbr = requestin->list_0[x].charge_nbr,
     b.ubc_ident = requestin->list_0[x].ubc_ident, b.acquisition_cost = acquisition_cost, b
     .facility_cd = facility_cd,
     b.match_ind = 0, b.match_ndc = " ", b.match_option = 0,
     b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
