CREATE PROGRAM bhs_sn_extract_dt_pref_card:dba
 DECLARE pc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_file = vc WITH protect, constant("pref_card_downtime.html")
 DECLARE ms_filepath = vc WITH protect, constant(concat(trim(logical("BHSCUST"),3),
   "/surginet/pref_card/"))
 DECLARE ms_filepathd = vc WITH protect, constant(concat(trim(logical("BHSCUST"),3),
   "/surginet/pref_card/data/"))
 CALL echo(ms_file)
 FREE RECORD pref_card
 RECORD pref_card(
   1 cnt = i4
   1 list[*]
     2 f_pref_card_id = f8
     2 f_prsnl_id = f8
     2 s_prov_last_name = vc
     2 s_prov_first_name = vc
     2 s_prov_full_name = vc
     2 f_catalog_cd = f8
     2 s_procedure = vc
     2 s_location = vc
     2 s_specialty = vc
     2 s_procedure_code = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM preference_card pc,
   prsnl p,
   order_catalog oc,
   prsnl_group pg,
   surg_proc_detail spd,
   code_value cv1
  PLAN (pc
   WHERE pc.active_ind=1)
   JOIN (p
   WHERE (p.person_id= Outerjoin(pc.prsnl_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(pc.catalog_cd)) )
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(pc.surg_specialty_id)) )
   JOIN (spd
   WHERE (spd.catalog_cd= Outerjoin(pc.catalog_cd))
    AND (spd.surg_specialty_id= Outerjoin(pc.surg_specialty_id))
    AND (spd.surg_area_cd= Outerjoin(pc.surg_area_cd)) )
   JOIN (cv1
   WHERE (cv1.code_value= Outerjoin(spd.ud5_cd)) )
  HEAD REPORT
   pref_card->cnt = 0
  DETAIL
   pref_card->cnt += 1, stat = alterlist(pref_card->list,pref_card->cnt), pref_card->list[pref_card->
   cnt].f_pref_card_id = pc.pref_card_id,
   pref_card->list[pref_card->cnt].f_prsnl_id = pc.prsnl_id, pref_card->list[pref_card->cnt].
   s_prov_last_name = trim(p.name_last_key,3), pref_card->list[pref_card->cnt].s_prov_first_name =
   trim(p.name_first_key,3),
   pref_card->list[pref_card->cnt].s_prov_full_name = trim(p.name_full_formatted,3), pref_card->list[
   pref_card->cnt].f_catalog_cd = pc.catalog_cd, pref_card->list[pref_card->cnt].s_procedure = oc
   .primary_mnemonic,
   pref_card->list[pref_card->cnt].s_location = uar_get_code_display(pc.surg_area_cd), pref_card->
   list[pref_card->cnt].s_specialty = trim(pg.prsnl_group_name,3), pref_card->list[pref_card->cnt].
   s_procedure_code = trim(cv1.display,3)
  WITH nocounter
 ;end select
 SELECT INTO value(concat(ms_filepath,ms_file))
  FROM (dummyt d  WITH seq = pref_card->cnt)
  PLAN (d)
  HEAD REPORT
   CALL print("<html>"), row + 1,
   CALL print("<head>"),
   row + 1, row + 1,
   CALL print('<meta http-equiv="X-UA-Compatible" content="IE=edge;" /> '),
   row + 1,
   CALL print(concat('<link rel="stylesheet" type="text/css" ',
    'href="datatables/DataTables-1.10.12/DataTables-1.10.12/media/css/jquery.dataTables.min.css"/>')),
   row + 1,
   CALL print(
   '<script type="text/javascript" language="javascript" src="jquery/jquery-3.1.0.min.js"></script>'),
   row + 1,
   CALL print(concat('<script type="text/javascript" ',
    'src="datatables/DataTables-1.10.12/DataTables-1.10.12/media/js/jquery.dataTables.min.js"></script>'
    )),
   row + 1,
   CALL print('<script type ="text/javascript">'), row + 1,
   CALL print("var dataSet = ["), row + 1
  DETAIL
   IF ((d.seq != pref_card->cnt))
    CALL print(concat('["',pref_card->list[d.seq].s_prov_full_name,'","',pref_card->list[d.seq].
     s_specialty,'","',
     pref_card->list[d.seq].s_location,'","',pref_card->list[d.seq].s_procedure_code,'","',pref_card
     ->list[d.seq].s_procedure,
     '","',trim(cnvtstring(pref_card->list[d.seq].f_pref_card_id,20),3),'.pdf"],'))
   ELSE
    CALL print(concat('["',pref_card->list[d.seq].s_prov_full_name,'","',pref_card->list[d.seq].
     s_specialty,'","',
     pref_card->list[d.seq].s_location,'","',pref_card->list[d.seq].s_procedure_code,'","',pref_card
     ->list[d.seq].s_procedure,
     '","',trim(cnvtstring(pref_card->list[d.seq].f_pref_card_id,20),3),'.pdf"]'))
   ENDIF
   row + 1
  FOOT REPORT
   CALL print("  ];"), row + 1,
   CALL print("   $(document).ready( function () {"),
   row + 1,
   CALL print("      $('#example').DataTable({"), row + 1,
   CALL print("	    data : dataSet,"), row + 1,
   CALL print('		"lengthMenu": [10, 25, 50, 100, 200],'),
   row + 1,
   CALL print('		"pageLength": 200,'), row + 1,
   CALL print("		columns: ["), row + 1,
   CALL print('			{ title: "ProviderName" },'),
   row + 1,
   CALL print('			{ title: "Specialty" },'), row + 1,
   CALL print('			{ title: "Location" },'), row + 1,
   CALL print('			{ title: "ProcedureCode" },'),
   row + 1,
   CALL print('			{ title: "Procedure" },'), row + 1,
   CALL print('			{ title: "File" ,'), row + 1,
   CALL print("			  render: function(data,type,full,meta){"),
   row + 1,
   CALL print(^			    return '<a href="data/'+data+'" target="_blank">PrefCard</a>';^), row + 1,
   CALL print("			  }"), row + 1,
   CALL print("			 }"),
   row + 1,
   CALL print("		]"), row + 1,
   CALL print("	  });"), row + 1,
   CALL print("   });"),
   row + 1,
   CALL print("</script>"), row + 1,
   CALL print("</head>"), row + 1,
   CALL print("<body>"),
   row + 1,
   CALL print("<div>"), row + 1,
   CALL print('<table id="example" class="display" width="100%"></table>'), row + 1,
   CALL print("</div>"),
   row + 1,
   CALL print("</body>"), row + 1,
   CALL print("</html>")
  WITH nocounter, formfeed = none, maxcol = 500
 ;end select
 FOR (pc_cnt = 1 TO pref_card->cnt)
   EXECUTE bhs_sn_extract_dt_save_pref pref_card->list[pc_cnt].f_pref_card_id
 ENDFOR
 SET ms_dclcom = concat(
  "$cust_script/bhs_sftp_file.ksh ciscoreftp@transfer.baystatehealth.org:/surginet/prefcard/data",
  " '/cerner/d_p627/bhscust/surginet/pref_card/data/*.pdf'")
 CALL echo(ms_dclcom)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat(
  "$cust_script/bhs_sftp_file.ksh ciscoreftp@transfer.baystatehealth.org:/surginet/prefcard",
  " '/cerner/d_p627/bhscust/surginet/pref_card/*.html'")
 CALL echo(ms_dclcom)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
END GO
