CREATE PROGRAM bhs_ops_phacharge_unverified:dba
 DECLARE ms_file_name = vc WITH protect, noconstant("")
 SET ms_file_name = concat("//cerner/d_p627/bhscust/phachargecredit_unverified_",trim(format(sysdate,
    "ddmmyyyy;;q")),".csv")
 EXECUTE bhs_rpt_phacharge_unverified ms_file_name
END GO
