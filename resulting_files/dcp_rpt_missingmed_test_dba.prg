CREATE PROGRAM dcp_rpt_missingmed_test:dba
 CALL echo("dcp_rpt_missingmed")
 FREE RECORD request
 RECORD request(
   1 encntr_id = f8
   1 text = vc
   1 reason_cd = f8
   1 ord[*]
     2 order_id = f8
 )
 SET stat = alterlist(request->ord,1)
 SET request->ord[1].order_id = 804911525
 SET request->encntr_id = 56868115.00
 SELECT
  o.encntr_id
  FROM orders o,
   person p
  PLAN (o
   WHERE o.order_id=701340140)
   JOIN (p
   WHERE p.person_id=o.person_id)
 ;end select
 CALL echo(build("medRequest_orderID:",request->ord[1].order_id))
 DECLARE reprintind = i4 WITH public, noconstant(1)
 DECLARE replacecomments = vc WITH noconstant(" ")
 DECLARE idx = i2
 DECLARE outputdevice = vc
 DECLARE dispensecat = vc
 SET medlabel = uar_get_code_by("displaykey",4039,"BHSMEDLABEL")
 SET ivlabel = uar_get_code_by("displaykey",4039,"BHSIVLABEL")
 SET ord_cnt = value(size(request->ord,5))
 FREE RECORD dispense_cat
 RECORD dispense_cat(
   1 qual[*]
     2 cat_type = f8
     2 cat_disp = vc
     2 label_cd = f8
     2 label_disp = vc
 )
 FREE RECORD printlabel
 RECORD printlabel(
   1 qual[*]
     2 order_id = f8
     2 runid = f8
     2 dispensecode = f8
     2 labelcode = f8
     2 dispensecat = vc
 )
 RECORD data(
   1 rows_to_process = i4
   1 run_id = f8
   1 run_type_cd = f8
   1 run_user_id = f8
   1 fill_hx_id = f8
   1 fill_batch_cd = f8
   1 batch_description = vc
   1 s_operation = c12
   1 rerun_flag = i2
   1 bat_fill_time = i4
   1 s_bat_fill_time_unit = c10
   1 cyc_from_dt_tm = dq8
   1 cyc_to_dt_tm = dq8
   1 output_format_cd = f8
   1 output_device_cd = f8
   1 output_device_s = c20
   1 dio = c12
   1 output_script = c40
   1 order_id = f8
 )
 RECORD reply(
   1 elapsed_time = f8
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
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD comment(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 ) WITH persist
 IF (textlen(request->text) > 0)
  SET pt->line_cnt = 0
  SET max_length = 55
  EXECUTE dcp_parse_text value(request->text), value(max_length)
  SET stat = alterlist(comment->lns,pt->line_cnt)
  SET comment->line_cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET comment->lns[x].line = pt->lns[x].line
  ENDFOR
 ENDIF
 SET replacecomments = uar_get_code_display(request->reason_cd)
 SELECT INTO "nl:"
  FROM dispense_category dc
  PLAN (dc
   WHERE dc.dispense_category_cd > 0
    AND dc.label_format_cd > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(dispense_cat->qual,cnt), dispense_cat->qual[cnt].cat_type = dc
   .dispense_category_cd,
   dispense_cat->qual[cnt].cat_disp = uar_get_code_display(dc.dispense_category_cd)
   CASE (uar_get_code_display(dc.label_format_cd))
    OF "BHS MED LABEL":
     dispense_cat->qual[cnt].label_cd = medlabel
    OF "BHS IV LABEL":
     dispense_cat->qual[cnt].label_cd = ivlabel
   ENDCASE
  WITH nocounter
 ;end select
 CALL echorecord(dispense_cat)
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.order_id=request->ord[1].order_id))
  DETAIL
   request->encntr_id = o.encntr_id
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (yy = 1 TO ord_cnt)
   SELECT INTO "NL:"
    f.order_id, f.updt_dt_tm
    FROM fill_print_ord_hx f
    PLAN (f
     WHERE (f.order_id=request->ord[yy].order_id))
    ORDER BY f.order_id, f.updt_dt_tm DESC
    HEAD REPORT
     cnt = 0, found = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (((f.dispense_id > 0) OR (cnt=1))
      AND found=0)
      IF (f.dispense_id > 0)
       found = 1
      ENDIF
      stat = alterlist(printlabel->qual,1), printlabel->qual[1].runid = f.run_id, printlabel->qual[1]
      .order_id = f.order_id,
      printlabel->qual[1].dispensecode = f.dispense_category_cd,
      CALL echo("found Dispense"), printlabel->qual[1].dispensecat = cnvtupper(trim(
        uar_get_code_display(f.dispense_category_cd),3))
     ENDIF
    WITH nocounter, format
   ;end select
   CALL echorecord(printlabel)
   IF (curqual=0)
    CALL echo("calling original medreqest label")
    EXECUTE dcp_rpt_missingmed_org_tst
   ENDIF
 ENDFOR
 IF (size(printlabel->qual,5) <= 0)
  CALL echo("No TRUE lables to print, exiting program")
  GO TO exit_script
 ENDIF
 SET unit = fillstring(50," ")
 SET room = fillstring(50," ")
 SET bed = fillstring(50," ")
 SET facility = fillstring(4," ")
 DECLARE med_output_device = c20 WITH public, noconstant(fillstring(20," "))
 DECLARE iv_output_device = c20 WITH public, noconstant(fillstring(20," "))
 CALL echo(request->encntr_id)
 SELECT INTO "NL:"
  FROM encounter e
  WHERE (e.encntr_id=request->encntr_id)
  DETAIL
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)),
   facility = trim(substring(1,4,uar_get_code_display(e.loc_facility_cd))),
   CALL echo(e.encntr_id)
   IF (cnvtupper(facility)="BMC")
    IF (cnvtupper(trim(unit)) IN ("NCCN", "NICU", "NNURA", "NNURB", "NNURC",
    "NNURD"))
     IF (curtime BETWEEN 0800 AND 1815)
      med_output_device = "bmcww2rxpo", iv_output_device = "bmcww2rxtpn"
     ELSE
      med_output_device = "bmcspgrxpo", iv_output_device = "bmcspgrxtpn"
     ENDIF
    ELSE
     med_output_device = "bmcspgrxpo", iv_output_device = "bmcspgrxtpn"
    ENDIF
   ELSEIF (cnvtupper(facility) IN ("FMC", "BFMC"))
    med_output_device = "fmcflgrxpo", iv_output_device = "fmcflgrxtpn"
   ELSEIF (cnvtupper(facility) IN ("MLH", "BMLH"))
    med_output_device = "mlhstgrxpo", iv_output_device = "mlhstgrxtpn"
   ELSE
    med_output_device = "mlhstgrxpo", iv_output_device = "mlhstgrxtpn"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(med_output_device)
 CALL echo(iv_output_device)
 CALL echo(facility)
 SET iv_output_device = "bmc361rxtst1"
 SET med_output_device = "bmc361rxtst1"
 CALL echorecord(printlabel)
 FREE RECORD request
 RECORD request(
   1 run_id = f8
   1 fill_hx_id = f8
   1 output_format_cd = f8
   1 output_device_cd = f8
   1 output_device_s = vc
   1 nbr_of_labels = i4
   1 order_id = f8
 )
 FOR (xx = 1 TO size(printlabel->qual,5))
   CALL echo(build(size(printlabel->qual,5),"TESTING"))
   IF ((printlabel->qual[xx].dispensecat IN ("PREMIX IV", "TPN", "EPIDURAL", "IRRIGATION", "IVPB",
   "LVP", "PCA", "CHEMO INFUSION")))
    SET data->output_device_s = iv_output_device
    CALL echo("IV Output")
   ELSEIF ((printlabel->qual[xx].dispensecat IN ("HBM")))
    SET data->output_device_s = "bmcww2milk1"
    CALL echo("IV - Brest Milk")
   ELSE
    SET data->output_device_s = med_output_device
    CALL echo("IV Med")
   ENDIF
   CALL echo(build("outPutDevice:",data->output_device_s))
   SET pos = 0
   SET pos = locateval(idx,1,size(dispense_cat->qual,5),printlabel->qual[xx].dispensecode,
    dispense_cat->qual[idx].cat_type)
   CALL echo(printlabel->qual[xx].dispensecode)
   CALL echo(dispense_cat->qual[pos].cat_type)
   SET printlabel->qual[xx].labelcode = dispense_cat->qual[pos].label_cd
   CALL echo(printlabel->qual[xx].dispensecode)
   CALL echo(dispense_cat->qual[pos].cat_type)
   CALL echo(printlabel->qual[xx].labelcode)
   CALL echo(build("pos:",pos))
   CALL echo(build("printlabel->qual [xx].labelcode:",printlabel->qual[xx].labelcode))
   SET request->run_id = printlabel->qual[xx].runid
   SET request->order_id = printlabel->qual[xx].order_id
   SET request->output_format_cd = printlabel->qual[xx].labelcode
   SET request->output_device_cd = - (1)
   SET request->nbr_of_labels = 1
   SET reprintorderid = printlabel->qual[xx].order_id
   CALL echo("load data")
   SELECT INTO "nl:"
    FROM fill_print_hx fph
    WHERE (request->run_id=fph.run_id)
    DETAIL
     data->run_id = fph.run_id, data->run_type_cd = fph.run_type_cd, data->run_user_id = fph
     .run_user_id,
     data->fill_hx_id = fph.fill_hx_id, data->fill_batch_cd = fph.fill_batch_cd, data->
     batch_description = fph.batch_description,
     data->s_operation = fph.s_operation, data->rerun_flag = fph.rerun_flag, data->bat_fill_time =
     fph.bat_fill_time,
     data->s_bat_fill_time_unit = fph.s_bat_fill_time_unit, data->cyc_from_dt_tm = fph.cyc_from_dt_tm,
     data->cyc_to_dt_tm = fph.cyc_to_dt_tm,
     data->output_format_cd =
     IF ((request->output_format_cd=0)) fph.output_format_cd
     ELSE request->output_format_cd
     ENDIF
     , data->output_device_cd =
     IF ((request->output_device_cd=0)) fph.output_device_cd
     ELSE request->output_device_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(data)
   SELECT INTO "nl:"
    c.description, c.cdf_meaning
    FROM code_value c
    WHERE c.code_set=4039
     AND (data->output_format_cd=c.code_value)
    DETAIL
     data->output_script = c.description, cdf = c.cdf_meaning,
     CALL echo(cdf)
    WITH nocounter
   ;end select
   SET script_name = fillstring(60," ")
   SET script_name = trim(data->output_script)
   CALL echo(build("call script:",script_name))
   CALL parser("execute ")
   CALL parser(value(trim(script_name)))
   CALL parser(" go")
   IF ((reply->status_data.status != "F"))
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
 CALL echorecord(request)
#exit_script
 FREE SET allergy
 FREE SET runs
 FREE SET data
 FREE SET request
 FREE SET pdata
 FREE SET reply
 FREE SET errors
 FREE SET o_errors
END GO
