CREATE PROGRAM bhs_sn_censitrac_out:dba
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ml_fill_qty = i4 WITH protect, noconstant(0)
 DECLARE ml_open_qty = i4 WITH protect, noconstant(0)
 DECLARE ml_hold_qty = i4 WITH protect, noconstant(0)
 DECLARE mf_csc_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ped_proc_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmc_endo_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_daly_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_anesth_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_heart_vasc_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmc_inpor_loc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tab = vc WITH protect, constant(char(9))
 DECLARE mf_itemnumber_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",11000,"ITEMNUMBER"
   ))
 DECLARE mf_bin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",220,"INVLOCATOR"))
 DECLARE mf_equip_mstr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",11001,
   "EQUIPMENTMASTER"))
 DECLARE ms_filename = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_sn_censitrac_out/sn_censitrac_out.dat"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 SET ms_beg_dt_tm = cnvtdatetime((curdate - 1),curtime)
 SET ms_end_dt_tm = cnvtdatetime((curdate+ 4),235959)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=221
   AND cv.cdf_meaning="SURGAREA"
   AND cv.display_key IN ("CHESTNUTSURGERYCENTER", "PEDIATRICPROCEDUREUNIT", "BMCENDOSCOPYCENTER",
  "DALYSURGERY", "ANESTHESIAREMOTESITES",
  "HEARTANDVASCULAROR", "BMCINPTOR")
  DETAIL
   CASE (cv.display_key)
    OF "CHESTNUTSURGERYCENTER":
     mf_csc_loc_cd = cv.code_value
    OF "PEDIATRICPROCEDUREUNIT":
     mf_ped_proc_loc_cd = cv.code_value
    OF "BMCENDOSCOPYCENTER":
     mf_bmc_endo_loc_cd = cv.code_value
    OF "DALYSURGERY":
     mf_daly_loc_cd = cv.code_value
    OF "ANESTHESIAREMOTESITES":
     mf_anesth_loc_cd = cv.code_value
    OF "HEARTANDVASCULAROR":
     mf_heart_vasc_loc_cd = cv.code_value
    OF "BMCINPTOR":
     mf_bmc_inpor_loc_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO value(ms_filename)
  FROM surgical_case sc,
   surg_case_procedure scp,
   preference_card pc,
   pref_card_pick_list pcpl,
   mm_omf_item_master im,
   object_identifier_index oi,
   prsnl p
  PLAN (sc
   WHERE sc.sched_start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND sc.cancel_dt_tm = null
    AND sc.active_ind=1
    AND sc.sched_surg_area_cd IN (mf_csc_loc_cd, mf_ped_proc_loc_cd, mf_bmc_endo_loc_cd,
   mf_daly_loc_cd, mf_anesth_loc_cd,
   mf_heart_vasc_loc_cd, mf_bmc_inpor_loc_cd))
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id)
   JOIN (pc
   WHERE pc.prsnl_id=scp.sched_primary_surgeon_id
    AND pc.catalog_cd=scp.sched_surg_proc_cd
    AND pc.surg_area_cd=scp.sched_surg_area_cd)
   JOIN (pcpl
   WHERE pcpl.pref_card_id=pc.pref_card_id)
   JOIN (im
   WHERE im.item_master_id=pcpl.item_id
    AND im.class_name="Container")
   JOIN (oi
   WHERE (oi.object_id= Outerjoin(pcpl.item_id))
    AND (oi.identifier_type_cd= Outerjoin(mf_itemnumber_cd))
    AND (oi.generic_object= Outerjoin(0)) )
   JOIN (p
   WHERE p.person_id=scp.sched_primary_surgeon_id)
  ORDER BY sc.surg_case_nbr_formatted, im.description
  HEAD REPORT
   ms_line = build("case_ref",ms_tab,"dest_name",ms_tab,"due_timestamp",
    ms_tab,"cancel_dt_tm",ms_tab,"case_duration",ms_tab,
    "case_doc",ms_tab,"item_ref",ms_tab,"qty",
    ms_tab,"facility",ms_tab,"item_name"), col 0, ms_line,
   row + 1
  HEAD pcpl.item_id
   ml_fill_qty = 0, ml_open_qty = 0, ml_hold_qty = 0
  DETAIL
   ml_open_qty = greatest(pcpl.request_open_qty,ml_open_qty), ml_hold_qty = greatest(pcpl
    .request_hold_qty,ml_hold_qty)
  FOOT  pcpl.item_id
   ml_fill_qty = (ml_open_qty+ ml_hold_qty), ms_line = build(substring(1,15,sc
     .surg_case_nbr_formatted),ms_tab,uar_get_code_display(sc.sched_op_loc_cd),ms_tab,format(sc
     .sched_start_dt_tm,"@SHORTDATETIMENOSEC"),
    ms_tab,format(sc.cancel_dt_tm,"@SHORTDATETIMENOSEC"),ms_tab,sc.sched_dur,ms_tab,
    p.name_full_formatted,ms_tab,oi.value,ms_tab,ml_fill_qty,
    ms_tab,uar_get_code_display(sc.sched_surg_area_cd),ms_tab,im.description), col 0,
   ms_line, row + 1
  WITH format = variable, maxrow = 1, maxcol = 300
 ;end select
#exit_program
END GO
