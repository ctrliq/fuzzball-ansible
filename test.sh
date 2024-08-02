# List of Vultr regions 
declare -A regions=(
    ["Amsterdam"]="ams"
    ["Atlanta"]="atl"
    ["Bangalore"]="blr"
    ["Mumbai"]="bom"
    ["Paris"]="cdg"
    ["Delhi NCR"]="del"
    ["Dallas"]="dfw"
    ["New Jersey"]="ewr"
    ["Frankfurt"]="fra"
    ["Honolulu"]="hnl"
    ["Seoul"]="icn"
    ["Osaka"]="itm"
    ["Johannesburg"]="jnb"
    ["Los Angeles"]="lax"
    ["London"]="lhr"
    ["Madrid"]="mad"
    ["Manchester"]="man"
    ["Melbourne"]="mel"
    ["Mexico City"]="mex"
    ["Miami"]="mia"
    ["Tokyo"]="nrt"
    ["Chicago"]="ord"
    ["São Paulo"]="sao"
    ["Santiago"]="scl"
    ["Seattle"]="sea"
    ["Singapore"]="sgp"
    ["Silicon Valley"]="sjc"
    ["Stockholm"]="sto"
    ["Sydney"]="syd"
    ["Tel Aviv"]="tlv"
    ["Warsaw"]="waw"
    ["Toronto"]="yto"
)

echo "Please select a Vultr region:"

# Display the selection menu
select abbreviation in "${!regions[@]}"; do
    # Check if the selection is valid
    if [[ -n "$abbreviation" ]]; then
        selected_region=${regions[$abbreviation]}
        echo "You selected: $selected_region ($abbreviation)"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done