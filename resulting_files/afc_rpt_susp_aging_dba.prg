CREATE PROGRAM afc_rpt_susp_aging:dba
 DECLARE afc_rpt_susp_aging_version = vc
 SET afc_rpt_susp_aging_version = "323720.FT.007"
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET printer = fillstring(100," ")
 IF (validate(request->output_dist," ") != " ")
  SET printer = request->output_dist
  SET printer = trim(printer)
 ENDIF
 IF (trim(printer) != " ")
  SET prtr_name = printer
 ELSE
  SET prtr_name = "MINE"
 ENDIF
 RECORD susp1(
   1 charge[*]
     2 charge_item_id = f8
     2 process_flg = i4
     2 service_dt_tm = dq8
     2 age_in_days = i4
     2 age_category = c20
 )
 DECLARE rpttitle = vc
 DECLARE rptpage = vc
 DECLARE rptdate = vc
 DECLARE hdragerange = vc
 DECLARE hdrquantity = vc
 DECLARE ftragecategory = vc
 DECLARE ftrtotalsuspcharges = vc
 DECLARE ftrendofreport = vc
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET suspense = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="SUSPENSE"
  DETAIL
   suspense = cv.code_value
  WITH nocounter
 ;end select
 SET count = 0
 SELECT INTO "nl:"
  c.charge_item_id, c.service_dt_tm, c.process_flg
  FROM charge c,
   charge_mod cm
  PLAN (c
   WHERE c.process_flg IN (1, 2, 3, 4)
    AND c.active_ind=1)
   JOIN (cm
   WHERE c.charge_item_id=cm.charge_item_id
    AND cm.charge_mod_type_cd=suspense
    AND cm.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(susp1->charge,count), susp1->charge[count].charge_item_id = c
   .charge_item_id,
   susp1->charge[count].process_flg = c.process_flg, susp1->charge[count].service_dt_tm = c
   .service_dt_tm, susp1->charge[count].age_in_days = datetimecmp(cnvtdatetime(curdate,curtime3),c
    .service_dt_tm)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   susp1->charge[d.seq].age_in_days
   FROM (dummyt d  WITH seq = value(count))
   ORDER BY susp1->charge[d.seq].age_in_days
   DETAIL
    IF ((susp1->charge[d.seq].age_in_days > 180))
     susp1->charge[d.seq].age_category = "> 180 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 150))
     susp1->charge[d.seq].age_category = "150 - 179 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 120))
     susp1->charge[d.seq].age_category = "120 - 149 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 90))
     susp1->charge[d.seq].age_category = "90 - 119 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 60))
     susp1->charge[d.seq].age_category = "60 - 89 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 30))
     susp1->charge[d.seq].age_category = "30 - 59 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 3))
     susp1->charge[d.seq].age_category = "3 - 29 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 2))
     susp1->charge[d.seq].age_category = "2 - 3 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 1))
     susp1->charge[d.seq].age_category = "1 - 2 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days > 0))
     susp1->charge[d.seq].age_category = "0 - 1 days"
    ELSEIF ((susp1->charge[d.seq].age_in_days <= 0))
     susp1->charge[d.seq].age_category = "<= 0 days"
    ELSE
     susp1->charge[d.seq].age_category = "other"
    ENDIF
   WITH nocounter
  ;end select
  SET age_cnt = 0
  SET total_cnt = 0
  SET count1 = 1
  SET dt = format(curdate,"dd-mmm-yyyy;;d")
  SET tm = format(curtime,"hh:mm;;s")
  SET rpttitle = uar_i18ngetmessage(i18nhandle,"k1","SUSPENDED CHARGE AGING ANALYSIS")
  SET rptpage = uar_i18ngetmessage(i18nhandle,"k1","PAGE:")
  SET rptdate = uar_i18ngetmessage(i18nhandle,"k1","REPORT DATE:")
  SET hdragerange = uar_i18ngetmessage(i18nhandle,"k1","AGE RANGE")
  SET hdrquantity = uar_i18ngetmessage(i18nhandle,"k1","QUANTITY")
  SET ftrtotalsuspcharges = uar_i18ngetmessage(i18nhandle,"k1","TOTAL NUMBER OF SUSPENDED CHARGES:")
  SET ftrendofreport = uar_i18ngetmessage(i18nhandle,"k1","END OF REPORT")
  SELECT INTO value(prtr_name)
   age_category = susp1->charge[d.seq].age_category, susp1->charge[d.seq].age_in_days
   FROM (dummyt d  WITH seq = value(count))
   ORDER BY susp1->charge[d.seq].age_in_days
   HEAD REPORT
    row + 1, col 40, rpttitle,
    row + 1
   HEAD PAGE
    col 92, rptpage, col 98,
    curpage, row + 1, col 85,
    rptdate, col 98, dt,
    row + 1, col 00, "========================================",
    col 40, "=====================================================================", row + 1,
    col 40, hdragerange, col 65,
    hdrquantity, row + 1, col 00,
    "========================================", col 40,
    "=====================================================================",
    row + 2
   HEAD age_category
    reas_cnt = 0
   DETAIL
    age_cnt = (age_cnt+ 1), total_cnt = (total_cnt+ 1), count1 = (count1+ 1)
   FOOT  age_category
    ftragecategory = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(age_category))), col 40,
    ftragecategory,
    col 60, age_cnt, age_cnt = 0,
    row + 1
   FOOT REPORT
    row + 1, col 25, ftrtotalsuspcharges,
    col 60, total_cnt, row + 2,
    col 37, "**************  ", ftrendofreport,
    col + 1, " **************"
   WITH nocounter, compress, nolandscape,
    maxrow = 60, maxcol = 132
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo("No charges qualified.")
 ENDIF
 FREE SET susp1
END GO
