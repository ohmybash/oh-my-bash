# gpid007.plugin.sh
# Author: Gregor-Patrick Heine
# mkdir -p $HOME/.oh-my-bash/plugins/gpid007

AWS_CONFIG="$HOME/.aws/config"
AWS_HOME="$HOME/.aws"
BWHITE='\033[1;37m'
NOCOLOR='\033[0m'
BRED='\033[1;31m'
GREP=''
PROFILE=''

function evalSeq {
    INPUT="$1"
    REXP='\w\.\.\w'
    SEQ=$(echo $INPUT | grep -Eo $REXP)
    SEQ=$(eval "echo {$SEQ}")
    OUTPUT=$(echo $INPUT | sed "s/$REXP/$SEQ/g")
    OUTPUT=$(echo $OUTPUT | sed 's/ /" "\$/g ; s/,/" "\$/g')
    echo "{print \$${OUTPUT}}"
}
COLUMN=$(evalSeq '1..4')

function getAwsProfile {
    echo $AWS_DEFAULT_PROFILE
}

function setAwsProfile {
    local rprompt=${RPROMPT/<aws:$(getAwsProfile)>/}
    export AWS_DEFAULT_PROFILE=$1
    export AWS_PROFILE=$1
}

function helpCall {
    echo "Help
        ====
        -h --help or ?
        -H --head or --header
        -p --profile eg all|Name
        -c --column eg 2,4..6,8
        -g --grep or *
    " | column -t
}

function ec2Describe {
    JSON=$(aws ec2 describe-instances | jq --raw-output '.Reservations[].Instances[]')
    HEAD='
        INSTANCE_ID
        PRIVATE_IP
        NAME_TAG
        PROFILE_ROLE
        SECURITY_GROUP
        SECURITY_ID
        SUBNET_ID
        ACCOUNT_ID
    ' 
    BODY=$( \
        echo $JSON | jq --raw-output '
            select(.State.Name == "running") 
            | .IamInstanceProfile.Arn
                |= try gsub(".*profile/"; "")
                catch "NULL"
            | .SecurityGroups[]?.GroupName
                |= try gsub(" "; "_")
                catch "NULL"
            | .Tags[]?.Value
                |= try gsub(" "; "_")
                catch "NULL"
            # | .VpcId
            #     |= try gsub("vpc-"; "")
            #     catch "NULL"
            # | .SubnetId
            #     |= try gsub("subnet-"; "")
            #     catch "NULL"
            # | .SecurityGroups[]?.GroupId
            #     |= try gsub("sg-"; "")
            #     catch "NULL"
            | [
                .InstanceId // "NULL" 
                , .PrivateIpAddress // "NULL"
                , ( .Tags[]? | select(.Key == "Name") | .Value ) // "NULL"
                , .IamInstanceProfile.Arn // "NULL"
                , ( [.SecurityGroups[]?.GroupName?] | join(",") ) // "NULL"
                , ( [.SecurityGroups[]?.GroupId] | join(",") ) // "NULL"
                # , .VpcId // "NULL"
                , .SubnetId // "NULL"
                , .NetworkInterfaces[]?.OwnerId // "NULL"
            ]
            | [.[]] | @tsv
        ' \
    )
    echo -e "${HEAD}\n${BODY}"
}

function checkProfile {
    PROFILE_LIST=$(grep -Eo '\[profile \w*-?\w*' $AWS_CONFIG | awk '{print$2}')
    if [[ $PROFILE != '' ]] && [[ $PROFILE != 'all' ]]; then
        PROFILE_KNOWN='no'
        for entry in $PROFILE_LIST; do
            if [[ $entry == $PROFILE ]]; then
                PROFILE_KNOWN='yes'
                echo -e "${BWHITE}$entry${NOCOLOR}"
                setAwsProfile $entry
                ec2PrintPipe
            fi
        done
        if [[ $PROFILE_KNOWN == 'no' ]];then 
            echo -e "[${BRED}ERROR${NOCOLOR}] ${BWHITE}$PROFILE${NOCOLOR} - not a PROFILE in $AWS_CONFIG"
            return 0
        fi
    elif [[ $PROFILE == 'all' ]]; then
        for entry in $PROFILE_LIST; do
            echo -e "${BWHITE}$entry${NOCOLOR}"
            setAwsProfile $entry
            ec2PrintPipe
        done
    else
        ec2PrintPipe
    fi
    setAwsProfile $AWS_DEFAULT_PROFILE
}

function ec2PrintPipe {
    if [[ $COLUMN != '' ]] && [[ $GREP != '' ]]; then
        ec2Describe | grep -i $GREP | awk "${COLUMN}" | column -t
    elif [[ $COLUMN != '' ]]; then
        ec2Describe | awk "${COLUMN}" | column -t
    elif [[ $GREP != '' ]]; then
        ec2Describe | grep -i $GREP | column -t
    else
        ec2Describe | column -t
    fi
}

# main function
function getec2 {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help|*'?')
                helpCall
                return 0
            ;;
            -H|--head|--header)
                echo -e "Headers\n======="
                i=0
                for item in $HEAD; do
                    i=$[ i+1 ]
                    echo "$i) $item"
                done
                return 0
            ;;
            -c|--column)
                if [[ "$2" == 'all' ]]; then
                    COLUMN=$(evalSeq "1..$(echo $HEAD | wc -w)")
                else
                    COLUMN=$(evalSeq "$2")
                fi

                shift 2
            ;;
            -p|--profile)
                PROFILE="$2"
                shift 2
            ;;
            -g|--grep)
                GREP="$2"
                shift 2
            ;;
            *)
                GREP="$1"
                shift 1
            ;;
        esac
    done
    checkProfile
}