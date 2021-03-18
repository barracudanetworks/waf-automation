#
# bash utility script to login to WAFaaS
#
# usage: source bwafaas_login.sh my_email my_password
#
# NOTE: You MUST source this file, not execute it, or else it will not set the environment variable properly
#
echo ""
echo email=$1
echo password=$2
echo ""
curl "https://api.waas.barracudanetworks.com/v2/waasapi/api_login/" -X POST -d "email=$1&password=$2" | tee blah.txt
#sed 's/"/ /g' < blah.txt | awk '{print $7}' > api_key.txt
echo ""
sed 's/"/ /g' < blah.txt | sed -n -e 's/^.*key ://p' | sed 's/}/ /g'
echo ""
echo ""
echo "We have saved your api key to a file in this directory named api_key.txt"
export WAAS_API_KEY=`cat api_key.txt`
echo ""
echo "Assuming you sourced this script, this script has set an environment variable named WAAS_API_KEY as follows:"
echo ""
echo WAAS_API_KEY=`cat api_key.txt`
echo ""
echo "Example of using this to get the list of applicaitons on WAFaaS:"
echo ""
echo "curl \"https://api.waas.barracudanetworks.com/v2/waasapi/applications/\" -H \"accept: application/json\" -H \"Content-Type: application/json\" -H \"auth-api: \$WAAS_API_KEY\" | python -m json.tool"
echo ""
echo "Go ahead, copy that curl line and try it right now!"
echo ""
