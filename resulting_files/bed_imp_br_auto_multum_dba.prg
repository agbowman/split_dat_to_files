CREATE PROGRAM bed_imp_br_auto_multum:dba
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
 DECLARE concentration_per_ml = f8
 DECLARE strength = f8
 DECLARE volume = f8
 DECLARE dispense_qty = f8
 DECLARE dc_display_days = f8
 DECLARE dc_inter_days = f8
 DECLARE def_format = f8
 DECLARE search_med = f8
 DECLARE search_intermit = f8
 DECLARE search_cont = f8
 DECLARE divisible_ind = f8
 DECLARE infinite_div_ind = f8
 DECLARE minimum_dose_qty = f8
 SET row_cnt = 0
 SET row_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO row_cnt)
   IF ((requestin->list_0[x].concentration_per_ml > " "))
    SET concentration_per_ml = cnvtreal(requestin->list_0[x].concentration_per_ml)
   ELSE
    SET concentration_per_ml = 0
   ENDIF
   IF ((requestin->list_0[x].strength > " "))
    SET strength = cnvtreal(requestin->list_0[x].strength)
   ELSE
    SET strength = 0
   ENDIF
   IF ((requestin->list_0[x].volume > " "))
    SET volume = cnvtreal(requestin->list_0[x].volume)
   ELSE
    SET volume = 0
   ENDIF
   IF ((requestin->list_0[x].dispense_qty > " "))
    SET dispense_qty = cnvtreal(requestin->list_0[x].dispense_qty)
   ELSE
    SET dispense_qty = 0
   ENDIF
   IF ((requestin->list_0[x].dc_display_days > " "))
    SET dc_display_days = cnvtint(requestin->list_0[x].dc_display_days)
   ELSE
    SET dc_display_days = 0
   ENDIF
   IF ((requestin->list_0[x].dc_inter_days > " "))
    SET dc_inter_days = cnvtint(requestin->list_0[x].dc_inter_days)
   ELSE
    SET dc_inter_days = 0
   ENDIF
   IF ((requestin->list_0[x].def_format > " "))
    SET def_format = cnvtint(requestin->list_0[x].def_format)
   ELSE
    SET def_format = 0
   ENDIF
   IF ((requestin->list_0[x].search_med > " "))
    SET search_med = cnvtint(requestin->list_0[x].search_med)
   ELSE
    SET search_med = 0
   ENDIF
   IF ((requestin->list_0[x].search_intermit > " "))
    SET search_intermit = cnvtint(requestin->list_0[x].search_intermit)
   ELSE
    SET search_intermit = 0
   ENDIF
   IF ((requestin->list_0[x].search_cont > " "))
    SET search_cont = cnvtint(requestin->list_0[x].search_cont)
   ELSE
    SET search_cont = 0
   ENDIF
   IF ((requestin->list_0[x].divisible_ind > " "))
    SET divisible_ind = cnvtint(requestin->list_0[x].divisible_ind)
   ELSE
    SET divisible_ind = 0
   ENDIF
   IF ((requestin->list_0[x].infinite_div_ind > " "))
    SET infinite_div_ind = cnvtint(requestin->list_0[x].infinite_div_ind)
   ELSE
    SET infinite_div_ind = 0
   ENDIF
   IF ((requestin->list_0[x].minimum_dose_qty > " "))
    SET minimum_dose_qty = cnvtreal(requestin->list_0[x].minimum_dose_qty)
   ELSE
    SET minimum_dose_qty = 0
   ENDIF
   INSERT  FROM br_auto_multum b
    SET b.mmdc = requestin->list_0[x].mmdc, b.generic_name = requestin->list_0[x].generic_name, b
     .brand_name = requestin->list_0[x].brand_name,
     b.label_description = requestin->list_0[x].label_description, b.product_type = requestin->
     list_0[x].product_type, b.concentration_per_ml = concentration_per_ml,
     b.concentration_unit = requestin->list_0[x].concentration_unit, b.concentration_unit_cki =
     requestin->list_0[x].concentration_unit_cki, b.strength = strength,
     b.strength_unit = requestin->list_0[x].strength_unit, b.strength_unit_cki = requestin->list_0[x]
     .strength_unit_cki, b.volume = volume,
     b.volume_unit = requestin->list_0[x].volume_unit, b.volume_unit_cki = requestin->list_0[x].
     volume_unit_cki, b.dispense_qty = dispense_qty,
     b.dispense_qty_unit = requestin->list_0[x].dispense_qty_unit, b.dispense_qty_unit_cki =
     requestin->list_0[x].dispense_qty_unit_cki, b.dc_display_days = dc_display_days,
     b.dc_inter_days = dc_inter_days, b.def_format = def_format, b.search_med = search_med,
     b.search_intermit = search_intermit, b.search_cont = search_cont, b.divisible_ind =
     divisible_ind,
     b.infinite_div_ind = infinite_div_ind, b.minimum_dose_qty = minimum_dose_qty, b.updt_cnt = 0,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
