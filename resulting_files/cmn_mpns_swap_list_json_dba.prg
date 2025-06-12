CREATE PROGRAM cmn_mpns_swap_list_json:dba
 PROMPT
  "Outdev : " = "MINE",
  "ConfigInfoJson: " = ""
  WITH outdev, configinfojson
 SET trace = recpersist
 EXECUTE cmn_mpns_swap_list  $CONFIGINFOJSON
 SET trace = norecpersist
 SET _memory_reply_string = cnvtrectojson(reply)
END GO
