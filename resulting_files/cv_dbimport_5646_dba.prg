CREATE PROGRAM cv_dbimport_5646:dba
 EXECUTE dm_ocd_readme "sts_nomenclature.csv", "Cps_import_nomenclature", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dataset.csv", "cv_import_dataset", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dta.csv", "cv_import_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_files.csv", "cv_import_dataset_files", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_validation.csv", "cv_import_xref_validation", 10000,
 5646
 EXECUTE dm_ocd_readme "sts_validation_add.csv", "cv_import_xref_validation", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_nomenclature.csv", "Cps_import_nomenclature", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_dataset.csv", "cv_import_dataset", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_dta.csv", "cv_import_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_dta.csv", "cv_updt_cdf_meaning_by_dta", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_files.csv", "cv_import_dataset_files", 10000,
 5646
 EXECUTE dm_ocd_readme "accv2_validation.csv", "cv_import_xref_validation", 10000,
 5646
 COMMIT
END GO
