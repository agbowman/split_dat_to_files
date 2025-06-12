CREATE PROGRAM cv_utl_test_part_nbr:dba
 PROMPT
  "CASE_DATASET_R_ID(0)=" = 0
 RECORD cv_omf_rec(
   1 cv_case_id = f8
   1 encntr_id = f8
   1 organization_id = f8
   1 dataset[*]
     2 dataset_id = f8
     2 alias_pool_cd = f8
     2 alias_pool_mean = c12
     2 organization_id = f8
     2 participant_prsnl_id = f8
     2 participant_prsnl_group_id = f8
     2 participant_nbr = vc
     2 case_dataset_r_id = f8
 )
 SET stat = alterlist(cv_omf_rec->dataset,1)
 SET cv_omf_rec->dataset[1].dataset_id = 112780
 SET cv_omf_rec->dataset[1].alias_pool_cd = 0
 SET cv_omf_rec->dataset[1].alias_pool_mean = ""
 SET cv_omf_rec->dataset[1].organization_id = 1234
 SET cv_omf_rec->dataset[1].participant_prsnl_id = 1234
 SET cv_omf_rec->dataset[1].participant_prsnl_group_id = 0
 SET cv_omf_rec->dataset[1].case_dataset_r_id =  $1
 CALL echo(build("Participant Prsnl Id",cv_omf_rec->dataset[1].participant_prsnl_id))
 CALL echo(build("Participant Org Id",cv_omf_rec->dataset[1].organization_id))
 SELECT INTO "nl:"
  FROM cv_case_dataset_r d,
   cv_case c
  PLAN (d
   WHERE (d.case_dataset_r_id=cv_omf_rec->dataset[1].case_dataset_r_id))
   JOIN (c
   WHERE c.cv_case_id=d.cv_case_id)
  DETAIL
   cv_omf_rec->cv_case_id = c.cv_case_id, cv_omf_rec->encntr_id = c.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cv_case_abstr_data cad
  PLAN (cad
   WHERE (cv_omf_rec->cv_case_id=cad.cv_case_id)
    AND cad.event_cd=181339)
  DETAIL
   cv_omf_rec->dataset[1].participant_prsnl_id = cad.result_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_type_class_cd, e.loc_facility_cd
  FROM encounter e
  WHERE (e.encntr_id=cv_omf_rec->encntr_id)
   AND e.active_ind=1
  DETAIL
   cv_omf_rec->organization_id = e.organization_id, cv_omf_rec->dataset[1].organization_id = e
   .organization_id
  WITH nocounter
 ;end select
 CALL echorecord(cv_omf_rec)
 EXECUTE cv_get_dataset_part_nbr
 CALL echorecord(cv_omf_rec)
 UPDATE  FROM cv_case_dataset_r d
  SET d.participant_nbr = cv_omf_rec->dataset[d.seq].participant_nbr
  PLAN (d
   WHERE (d.case_dataset_r_id=cv_omf_rec->dataset[1].case_dataset_r_id))
  WITH nocounter
 ;end update
 CALL echo("Commit is needed")
END GO
