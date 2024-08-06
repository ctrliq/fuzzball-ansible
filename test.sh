# Print the available regions
echo "
    [\"Amsterdam\"]=\"ams\"
    [\"Atlanta\"]=\"atl\"
    [\"Bangalore\"]=\"blr\"
    [\"Mumbai\"]=\"bom\"
    [\"Paris\"]=\"cdg\"
    [\"New Jersey\"]=\"ewr\"
    [\"Frankfurt\"]=\"fra\"
    [\"Honolulu\"]=\"hnl\"
    [\"London\"]=\"lhr\"
    [\"Madrid\"]=\"mad\"
    [\"Manchester\"]=\"man\"
    [\"Melbourne\"]=\"mel\"
    [\"Mexico City\"]=\"mex\"
    [\"Miami\"]=\"mia\"
    [\"Tokyo\"]=\"nrt\"
    [\"Chicago\"]=\"ord\"
    [\"São Paulo\"]=\"sao\"
    [\"Santiago\"]=\"scl\"
    [\"Seattle\"]=\"sea\"
    [\"Singapore\"]=\"sgp\"
    [\"Silicon Valley\"]=\"sjc\"
    [\"Stockholm\"]=\"sto\"
    [\"Sydney\"]=\"syd\"
    [\"Tel Aviv\"]=\"tlv\"
    [\"Warsaw\"]=\"waw\"
    [\"Toronto\"]=\"yto\"
"

# Prompt the user to input a region
while true; do
  read -p "Please type the Vultr region: " region
  if [[ ${#region} -eq 3 ]]; then
      echo "You have picked the $region region."
      break
  else
      echo "Region must be a 3-letter string. Please try again."
  fi
done
