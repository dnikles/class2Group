
source ./getCreds.sh
getCreds

echo "input Class number"
read -r classNumber
echo "input Group number"
read -r groupNumber
groupInfo=$(curl -H "Accept: application/json" -su "${jssAPIUsername}":"${jssAPIPassword}" -X GET "${jssAddress}"/JSSResource/mobiledevicegroups/id/"$groupNumber")
groupName=$(echo "$groupInfo"|./jq --raw-output '.mobile_devic_group.name')
classInfo=$(curl -H "Accept: application/json" -su "${jssAPIUsername}":"${jssAPIPassword}" -X GET "${jssAddress}"/JSSResource/classes/id/"$classNumber")

className=$(echo "$classInfo"|./jq --raw-output '.class.name')
deviceCount=$(echo "$classInfo"|./jq '.class.mobile_devices|length')
echo "Do you want to add $deviceCount devices from $className to the group $groupName? (y/n)"
read -r response
if [ "$response" == "y" ]; then
  id=$(echo "$classInfo"|./jq --raw-output '.class.mobile_devices[].udid')
  i=1
  apiUdid=""
  while [ "$i" -le "$deviceCount" ]; do
    udid=$(echo "$id"|awk -v i=$i '{print $i}' )
    apiUdid="$apiUdid<mobile_device><udid>$udid</udid></mobile_device>"
    (( i++ ))
  done
  apiData="<mobile_device_group><mobile_device_additions>$apiUdid</mobile_device_additions></mobile_device_group>"
  curl -sS -k -i -u "${jssAPIUsername}":"${jssAPIPassword}" -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$apiData" "${jssAddress}"/JSSResource/mobiledevicegroups/id/"$groupNumber"
else
  exit 0
fi
