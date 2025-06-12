CREATE PROGRAM cv_import_dataset_5646:dba
 EXECUTE cv_omf_del_view_reference
 EXECUTE cv_omf_del_cvcase
 EXECUTE cv_omf_del_cvcase2
 EXECUTE cv_omf_del_tscase
 EXECUTE cv_omf_del_cvgsts
 EXECUTE cv_omf_del_cvaccg
 EXECUTE dm_ocd_readme "sts_nomenclature.csv", "Cps_import_nomenclature", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dataset.csv", "cv_import_dataset", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dta.csv", "orm_import_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_files.csv", "cv_import_dataset_files", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_validation.csv", "cv_import_xref_validation", 10000,
 5646
 EXECUTE dm_ocd_readme "dcp_51834_pf.csv", "dcp_import_powerforms", 10000,
 5646
 EXECUTE cv_omf_upd_pv_security_name
 EXECUTE cv_omf_functions_compiler
 COMMIT
END GO
