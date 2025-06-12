CREATE PROGRAM dm_readme_create_status:dba
 SELECT INTO "dm_readme_create_status.csv"
  FROM dm_pkt_setup_process p
  WHERE p.change_ind=1
  HEAD REPORT
   "feature,process_id,environment,status,updt_dt_tm,instance", row + 1
  DETAIL
   str_data1 = build(p.effective_feature,",",cnvtint(p.process_id),",","CERT7_ALPHA",
    ",","1,",format(p.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),",",p.instance_nbr), str_data2 = build(p
    .effective_feature,",",cnvtint(p.process_id),",","CERT7_AIX",
    ",","1,",format(p.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),",",p.instance_nbr), str_data3 = build(p
    .effective_feature,",",cnvtint(p.process_id),",","ICERT7_ALPHA",
    ",","1,",format(p.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"),",",p.instance_nbr),
   str_data1, row + 1, str_data2,
   row + 1, str_data3, row + 1
  WITH nocounter, noformfeed, maxcol = 132
 ;end select
END GO
