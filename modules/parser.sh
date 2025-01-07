# Description: This file contains the functions used to parse the pcrontab file
parser() {
    task_to_execute=""
    # Split the seven fields using the space delimiter
    IFS=' ' read -a fields <<< "$1"

    # Check if the line is a comment
    if [[ ${fields[0]} == \#* ]]; then
        return
    fi
    # Check if the line is empty
    if [[ ${fields[0]} == "" ]]; then
        return
    fi
    is_task_to_execute=false
    # Get the current time
    sec=$(date +"%-S")
    CURRENT_SEC=$((sec / 15))
    CURRENT_MIN=$(date +"%-M")
    CURRENT_HOUR=$(date +"%-H")
    CURRENT_DAY=$(date +"%-d")
    CURRENT_MONTH=$(date +"%-m")
    CURRENT_WDAY=$(date +"%-w")
    # Check if the task is to be executed
    sec_satisfied=false
    min_satisfied=false
    hour_satisfied=false
    day_satisfied=false
    month_satisfied=false
    wday_satisfied=false

    temporal_parser "${fields[0]}"
    sec=$final_list
    temporal_parser "${fields[1]}"
    min=$final_list
    temporal_parser "${fields[2]}"
    hour=$final_list
    temporal_parser "${fields[3]}"
    day=$final_list
    temporal_parser "${fields[4]}"
    month=$final_list
    temporal_parser "${fields[5]}"
    wday=$final_list
    
    
    IFS=" " read -a sec <<< $sec
    for i in "${sec[@]}"; do
        if [[ $i == "*" || $((i / 15)) == $CURRENT_SEC ]]; then
            sec_satisfied=true
        fi
    done

    IFS=" " read -a min <<< $min
    for i in "${min[@]}"; do
        if [[ $i == "*" || $i == $CURRENT_MIN ]]; then
            min_satisfied=true
        fi
    done
   
    IFS=" " read -a hour <<< $hour
    for i in "${hour[@]}"; do
        if [[ $i == "*" || $i == $CURRENT_HOUR ]]; then
            hour_satisfied=true
        fi
    done


    IFS=" " read -a day <<< $day
    for i in "${day[@]}"; do
        if [[ $i == "*" || $i == $CURRENT_DAY ]]; then
            day_satisfied=true
        fi
    done

    IFS=" " read -a month <<< $month
    for i in "${month[@]}"; do
        if [[ $i == "*" || $i == $CURRENT_MONTH ]]; then
            month_satisfied=true
        fi
    done

    IFS=" " read -a wday <<< $wday
    for i in "${wday[@]}"; do
        if [[ $i == "*" || $i == $CURRENT_WDAY ]]; then
            wday_satisfied=true
        fi
    done

    if $sec_satisfied && $min_satisfied && $hour_satisfied && $day_satisfied && $month_satisfied && $wday_satisfied; then
        is_task_to_execute=true
        task_to_execute=${fields[@]:6}
        echo "Task to execute: $task_to_execute"
    fi
}

temporal_parser() {
    if [[ $1 == "*" ]]; then
        final_list="*"
        return
    fi
    if [[ $1 =~ \*/[0-5]?[0-9] ]]; then
        IFS='/' read -a nums <<< "$1"
        final_list=""
        #On ajoute a la liste les valeurs de 0 à 59 avec un pas de nums[1] 
        #Ca ne pose pas de problème même si le champ conerne les heures ou les jours 
        #car lors de la comparaison on vérifie si le jour/mois courrant est dans la liste
        for ((i=0; i<=59; i+=${nums[1]})); do
            final_list+=" $i"
        done
        return
    fi
    #verifier le format de l'argument, il ne doit contenir que : ou - ou ~ et un seul chiffre entre chacun des caractères
    if [[ ! $1 =~ ^([0-5]?[0-9][-:])*[0-5]?[0-9](~([0-5]?[0-9][-:])*[0-5]?[0-9])*$ ]]; then
        echo " (temporal parser): This arg is not valid : $1"
        exit 1
    fi
    arg_begging=$(grep -o -E '^([0-5]?[0-9][-:])*[0-5]?[0-9]' <<< "$1")
    arg_end=$(grep -oP '(?<=~).*' <<< "$1")
    liste_all=""
    make_list $arg_begging
    liste_all+="$values_kept"
    IFS='~' read -a nums <<< "$arg_end"
    remove=""
    for num in "${nums[@]}"; do
        make_list $num
        remove+=" $values_kept"
    done
    final_list=""
    for num in $liste_all; do
        if [[ " ${remove[@]} " =~ " $num " ]]; then
            continue
        fi
        final_list+=" $num"
    done
}

make_list() {
    values_kept=""
    local arg=$1
    if [[ $arg == \#* ]]; then
        return
    fi
    if [[ $arg == "" ]]; then
        return
    fi
    if [[ $arg == "*" ]]; then
        values_kept="*"
        return
    fi
    if [[ ! $arg =~ ^([0-5]?[0-9][-:])*[0-5]?[0-9]$ ]]; then
        echo "(make list) : This arg is not valid : $arg"
        exit 1
    fi
    # If arg contains both : and - don't split
    if [[ $arg == *":"* && $arg == *"-"* ]]; then
        echo "(make list) This arg is not valid : $arg it should contain either : or - not both"
        exit 1
    fi
    # If arg contains : split using :
    if [[ $arg == *":"* ]]; then
        IFS=':' read -a nums <<< "$arg"
        for field in "${nums[@]}"; do
            if [[ $field == "" ]]; then
                continue
            fi
            if [[ " ${num_rem[@]} " =~ " $field " ]]; then 
                continue
            fi
            values_kept+=" $field"
        done
    elif [[ $arg == *"-"* ]]; then
        IFS='-' read -a range <<< "$arg"
        if [[ ${range[0]} -gt ${range[1]} ]]; then
            echo "This arg is not valid : $arg, the first number should be less than the second number"
            exit 1
        fi
        for ((i=${range[0]}; i<=${range[1]}; i++)) do
            values_kept+=" $i"
        done
        
    else
        values_kept+="$arg"
    fi
}