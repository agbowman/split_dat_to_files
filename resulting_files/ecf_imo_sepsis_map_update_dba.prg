CREATE PROGRAM ecf_imo_sepsis_map_update:dba
 CALL echo("IMO Sepsis Update Script Began")
 CALL echo("IMO Sepsis Update Script Began")
 CALL echo("IMO Sepsis Update Script Began")
 CALL echo("*** UPDATE CMT_CROSS_MAP_LOAD ***")
 CALL echo("*** UPDATE CMT_CROSS_MAP_LOAD ***")
 CALL echo("*** UPDATE CMT_CROSS_MAP_LOAD ***")
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069624"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069642"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069644"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069959"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070500"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070502"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070947"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10071073"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10071074"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1056020"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1056021"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!13270"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!13404"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489594"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489596"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489599"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!1619449"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16546848"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546947"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546969"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546988"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546994"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546999"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547001"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16547010"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547026"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547044"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547051"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547057"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16549826"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16549845"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16549860"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16904261"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1725718"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!1821267"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!20567741"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!21905635"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347610"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347613"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!24347619"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347622"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!24347629"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347640"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!29240174"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!325966"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!32930722"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!32930723"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!332941"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!332945"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!333001"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!33432365"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!34886285"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!3540261"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!370119"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013462"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!37013471"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013488"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013514"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013523"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4099"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4100"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4102"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!501758"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!502247"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!50755057"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!50998433"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!511617"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!513178"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525455"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525457"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525458"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525459"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54469"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54470"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54471"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!55240323"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045140"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045142"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045143"
   AND target_concept_cki="ICD10-CM!*"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055437"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055457"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055458"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!819819"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!821686"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!853113"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map_load
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!940936"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 CALL echo("*** UPDATE CMT_CROSS_MAP ***")
 CALL echo("*** UPDATE CMT_CROSS_MAP ***")
 CALL echo("*** UPDATE CMT_CROSS_MAP ***")
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069624"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069642"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069644"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10069959"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070500"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070502"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10070947"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10071073"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!10071074"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1056020"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1056021"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!13270"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!13404"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489594"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489596"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!15489599"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!1619449"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16546848"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546947"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546969"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546988"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546994"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16546999"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547001"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16547010"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547026"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547044"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547051"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16547057"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16549826"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16549845"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!16549860"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!16904261"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!1725718"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!1821267"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!20567741"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!21905635"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347610"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347613"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!24347619"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347622"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!24347629"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!24347640"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!29240174"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!325966"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!32930722"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!32930723"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!332941"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!332945"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!333001"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!33432365"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!34886285"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!3540261"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!370119"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013462"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!37013471"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013488"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013514"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!37013523"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4099"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4100"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!4102"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!501758"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!502247"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!50755057"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!50998433"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!511617"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!513178"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525455"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525457"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525458"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!525459"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54469"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54470"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!54471"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!55240323"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045140"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045142"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!58045143"
   AND target_concept_cki="ICD10-CM!*"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055437"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055457"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!58055458"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!819819"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!821686"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.20"
  WHERE concept_cki="IMO!853113"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 UPDATE  FROM cmt_cross_map
  SET target_concept_cki = "ICD10-CM!R65.21"
  WHERE concept_cki="IMO!940936"
   AND end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
   AND target_concept_cki="ICD10-CM!*"
  WITH nocounter
 ;end update
 COMMIT
 UPDATE  FROM cmt_cross_map
  SET source_identifier = replace(target_concept_cki,"ICD10-CM!","")
  WHERE target_concept_cki IN ("ICD10-CM!R65.20", "ICD10-CM!R65.21")
 ;end update
 COMMIT
 RECORD deletes(
   1 total_deletes = f8
   1 list[*]
     2 concept_cki = vc
     2 target_cki = vc
     2 cmt_cross_map_id = f8
 )
 DECLARE cnt = i4 WITH protect
 SELECT INTO "nl:"
  ccm.concept_cki, ccm.target_concept_cki, cross_map_id = min(ccm.cmt_cross_map_id)
  FROM cmt_cross_map ccm
  WHERE ccm.concept_cki="IMO!*"
   AND ccm.target_concept_cki IN ("ICD10-CM!R65.20", "ICD10-CM!R65.21")
   AND ccm.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  GROUP BY ccm.concept_cki, ccm.target_concept_cki
  HAVING count(*) > 1
  HEAD REPORT
   cnt = 0, stat = alterlist(deletes->list,100)
  DETAIL
   cnt = (cnt+ 1), deletes->list[cnt].concept_cki = ccm.concept_cki, deletes->list[cnt].target_cki =
   ccm.target_concept_cki,
   deletes->list[cnt].cmt_cross_map_id = cross_map_id
  FOOT REPORT
   deletes->total_deletes = cnt, stat = alterlist(deletes->list,cnt)
  WITH nocounter
 ;end select
 IF (size(deletes->list,5) > 0)
  DELETE  FROM cmt_cross_map ccm,
    (dummyt d  WITH seq = value(cnt))
   SET ccm.seq = 1
   PLAN (d)
    JOIN (ccm
    WHERE (ccm.concept_cki=deletes->list[d.seq].concept_cki)
     AND (ccm.target_concept_cki=deletes->list[d.seq].target_cki)
     AND (ccm.cmt_cross_map_id != deletes->list[d.seq].cmt_cross_map_id)
     AND ccm.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
  ;end delete
  COMMIT
 ENDIF
 CALL echo("IMO Sepsis Update Script Completed")
 CALL echo("IMO Sepsis Update Script Completed")
 CALL echo("IMO Sepsis Update Script Completed")
#exit_script
END GO
