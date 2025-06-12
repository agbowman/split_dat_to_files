CREATE PROGRAM bhs_inact_end_dt_fix_v2
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 UPDATE  FROM prsnl p
  SET p.active_ind = 1, p.active_status_cd = 194, p.end_effective_dt_tm = p.updt_dt_tm,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 99999999
  WHERE p.active_ind=0
   AND ((p.username="Z99999999") OR (((p.person_id=5823084) OR (((p.person_id=950895) OR (((p
  .person_id=950894) OR (((p.person_id=750832) OR (((p.person_id=750619) OR (((p.person_id=749865)
   OR (((p.person_id=6020993) OR (((p.person_id=3188412) OR (((p.person_id=750352) OR (((p.person_id=
  749914) OR (((p.person_id=748986) OR (((p.person_id=749121) OR (((p.person_id=589882) OR (((p
  .person_id=589842) OR (((p.person_id=589836) OR (((p.person_id=589835) OR (((p.person_id=589834)
   OR (((p.person_id=589833) OR (((p.person_id=748798) OR (((p.person_id=748873) OR (((p.person_id=
  748546) OR (((p.person_id=748544) OR (((p.person_id=749128) OR (((p.person_id=749126) OR (((p
  .person_id=748663) OR (((p.person_id=748689) OR (((p.person_id=748686) OR (((p.person_id=749030)
   OR (((p.person_id=748916) OR (((p.person_id=748990) OR (((p.person_id=748616) OR (((p.person_id=
  748537) OR (((p.person_id=748703) OR (((p.person_id=748519) OR (((p.person_id=747120) OR (((p
  .person_id=749152) OR (((p.person_id=749351) OR (((p.person_id=749191) OR (((p.person_id=749307)
   OR (((p.person_id=748621) OR (((p.person_id=749404) OR (((p.person_id=748944) OR (((p.person_id=
  748748) OR (((p.person_id=748747) OR (((p.person_id=748555) OR (((p.person_id=748554) OR (((p
  .person_id=748549) OR (((p.person_id=748950) OR (((p.person_id=589857) OR (((p.person_id=748647)
   OR (((p.person_id=749029) OR (((p.person_id=749142) OR (((p.person_id=749136) OR (((p.person_id=
  748939) OR (((p.person_id=749095) OR (((p.person_id=749094) OR (((p.person_id=749092) OR (((p
  .person_id=748736) OR (((p.person_id=749176) OR (((p.person_id=749160) OR (((p.person_id=748812)
   OR (((p.person_id=748809) OR (((p.person_id=748797) OR (((p.person_id=749164) OR (((p.person_id=
  748973) OR (((p.person_id=749115) OR (((p.person_id=748764) OR (((p.person_id=748910) OR (((p
  .person_id=940325) OR (((p.person_id=749189) OR (((p.person_id=748673) OR (((p.person_id=748761)
   OR (((p.person_id=748741) OR (((p.person_id=748785) OR (((p.person_id=749076) OR (((p.person_id=
  748863) OR (p.person_id=748836)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
 ;end update
 COMMIT
END GO
