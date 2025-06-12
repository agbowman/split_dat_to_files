CREATE PROGRAM ams_gen_modify_serv_routing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Direcrory" = "",
  "input file" = ""
  WITH outdev, directory, input_file
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUT_FILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 FREE RECORD request_10070
 RECORD request_10070(
   1 catalog_cd = f8
   1 qual[*]
     2 service_resource_cd = f8
     2 sequence = i4
     2 primary_ind = i2
     2 script_name = c50
     2 active_ind = i2
 )
 FREE RECORD reply_10070
 RECORD reply_10070(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 catalog_cd = f8
     2 service_resource_cd = f8
 )
 FREE RECORD request_15018
 RECORD request_15018(
   1 catalog_cd = f8
   1 qual[*]
     2 service_resource_cd = f8
     2 sequence = i4
     2 primary_ind = i2
     2 script_name = c50
     2 updt_cnt = i4
     2 active_ind = i2
     2 end_effective_dt_tm = dq8
 )
 RECORD reply_15018(
   1 exception_data[1]
     2 catalog_cd = f8
     2 service_resource_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_10078
 RECORD request_10078(
   1 qual[*]
     2 service_resource_cd = f8
     2 task_assay_cd = f8
     2 active_ind = i2
     2 default_result_type_cd = f8
     2 default_result_template_id = f8
     2 qc_result_type_cd = f8
     2 qc_sequence = i4
     2 display_sequence = i4
     2 downld_ind = i2
     2 code_set = i4
 )
 FREE RECORD reply_10078
 RECORD reply_10078(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_10038
 RECORD request_10038(
   1 get_all_flag = i2
   1 qual[*]
     2 catalog_cd = f8
 )
 FREE RECORD reply_10038
 RECORD reply_10038(
   1 qual[1]
     2 catalog_cd = f8
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
     2 sequence = i4
     2 primary_ind = i2
     2 script_name = c50
     2 location_cd = f8
     2 svc_resource_type_cd = f8
     2 updt_cnt = i4
     2 active_ind = i2
     2 reltn_active_ind = i2
     2 active_status_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 instrument_ben_subsec = vc
     2 default = vc
     2 dep_disp_name = vc
     2 ins_bench_sub_status = vc
     2 status = c5
 )
 DEFINE rtl2 value(file_path)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, stat = alterlist(temp->list,10), cnt = 0
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    IF (cnt > 0)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(temp->list,(row_count+ 9))
     ENDIF
     temp->list[row_count].instrument_ben_subsec = piece(r.line,",",1,"0"), temp->list[row_count].
     default = piece(r.line,",",2,"0"), temp->list[row_count].dep_disp_name = piece(r.line,",",3,"0"),
     temp->list[row_count].ins_bench_sub_status = piece(r.line,",",4,"0"), temp->list[row_count].
     status = piece(r.line,",",5,"0")
    ENDIF
   ENDIF
   cnt = (cnt+ 1)
  FOOT REPORT
   stat = alterlist(temp->list,row_count)
  WITH nocounter
 ;end select
 SET scnt = 1
 DECLARE serv_cd = f8
 DECLARE cat_cd = f8
 DECLARE sequ = i4
 DECLARE seqn = i4
 DECLARE v_status = vc
 FOR (i = 1 TO size(temp->list,5))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE (cv.description=temp->list[i].instrument_ben_subsec)
     AND cv.code_set=221
     AND cv.active_ind=1
    DETAIL
     serv_cd = cv.code_value
    WITH nocounter
   ;end select
   SET scnt1 = 0
   SELECT INTO "nl:"
    FROM code_value cv1,
     orc_resource_list o
    WHERE cv1.code_value=o.catalog_cd
     AND cv1.display=trim(temp->list[i].dep_disp_name)
     AND cv1.code_set=200
     AND cv1.active_ind=1
    ORDER BY o.sequence DESC
    HEAD o.catalog_cd
     scnt1 = (scnt1+ 1), stat = alterlist(request_10070->qual,scnt1), request_10070->catalog_cd = cv1
     .code_value,
     request_10070->qual[scnt1].active_ind = 1, request_10070->qual[scnt1].service_resource_cd =
     serv_cd, request_10070->qual[scnt1].sequence = (o.sequence+ 1)
    WITH nocounter
   ;end select
   SET stat = tdbexecute(15000,15001,10070,"REC",request_10070,
    "REC",reply_10070)
   SET v_status = reply_10070->status_data
   IF (v_status="S")
    SET temp->list[i].status = v_status
   ELSE
    SET temp->list[i].status = "F"
   ENDIF
   SET scnt2 = 0
   SELECT INTO "nl:"
    p.sequence, dat.task_assay_cd
    FROM profile_task_r p,
     discrete_task_assay dat,
     assay_resource_list arl
    PLAN (p
     WHERE (p.catalog_cd=request_10070->catalog_cd))
     JOIN (dat
     WHERE dat.task_assay_cd=p.task_assay_cd)
     JOIN (arl
     WHERE arl.task_assay_cd=outerjoin(dat.task_assay_cd))
    ORDER BY dat.task_assay_cd
    HEAD dat.task_assay_cd
     scnt2 = (scnt2+ 1), stat = alterlist(request_10078->qual,scnt2), request_10078->qual[scnt2].
     task_assay_cd = dat.task_assay_cd,
     request_10078->qual[scnt2].service_resource_cd = serv_cd, request_10078->qual[scnt2].
     default_result_type_cd = dat.default_result_type_cd, request_10078->qual[scnt2].active_ind = 1,
     request_10078->qual[scnt2].downld_ind = 1
    WITH nocounter
   ;end select
   SET stat = tdbexecute(15000,15001,10078,"REC",request_10078,
    "REC",reply_10078)
   CALL echo("--------------------------------------")
 ENDFOR
 SET outputfile = build("cer_print:ams_gen_routing_",format(cnvtdatetime(curdate,curtime3),
   "dd_mmm_yyyy_HH_MM;;Q"),".csv")
 SELECT INTO value(outputfile)
  list_instrument_ben_subsec = substring(1,30,temp->list[d1.seq].instrument_ben_subsec), list_default
   = substring(1,30,temp->list[d1.seq].default), list_dep_disp_name = substring(1,30,temp->list[d1
   .seq].dep_disp_name),
  list_ins_bench_sub_status = substring(1,30,temp->list[d1.seq].ins_bench_sub_status), list_status =
  temp->list[d1.seq].status
  FROM (dummyt d1  WITH seq = value(size(temp->list,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO  $OUTDEV
  output = build("Output has been generated to: ",outputfile)
  FROM dummyt d
  WITH format, seperator = ""
 ;end select
END GO
