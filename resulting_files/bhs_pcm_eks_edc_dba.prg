CREATE PROGRAM bhs_pcm_eks_edc:dba
 FREE RECORD m_request
 RECORD m_request(
   1 patient_list[1]
     2 patient_id = f8
   1 pregnancy_list[*]
     2 pregnancy_id = f8
 ) WITH protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE log_misc1 = vc WITH public, noconstant(" ")
 DECLARE log_message = vc WITH public, noconstant(" ")
 DECLARE retval = i4 WITH public, noconstant(0)
 SET retval = 0
 SET log_message = concat("No pregnancy instance found. - ",trim(cnvtstring(cnvtint(link_personid)),3
   ))
 SET m_request->patient_list[1].patient_id = cnvtreal(link_personid)
 EXECUTE dcp_get_final_ega  WITH replace("REQUEST",m_request), replace("REPLY",m_reply)
 IF (size(m_reply->gestation_info,5) > 0)
  IF ((m_reply->gestation_info[1].delivered_ind=0))
   SET log_misc1 = format(m_reply->gestation_info[1].est_delivery_date,"DD-MMM-YYYY HHMMSS;;Q")
   SET retval = 100
   SET log_message = concat("EDC: ",log_misc1," - ",trim(cnvtstring(cnvtint(link_personid)),3))
  ELSE
   SET retval = 0
   SET log_message = concat("Latest pregnancy has delivered - ",trim(cnvtstring(cnvtint(link_personid
       )),3))
  ENDIF
 ELSE
  SET retval = 0
 ENDIF
#exit_script
 FREE RECORD m_request
END GO
