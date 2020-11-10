# Remove VM-Series from Device Group
sleep 120
echo '\n\nPanorama Commit'
curl --insecure "https://"$1"/api/?type=commit&cmd=<commit></commit>&key="$2


