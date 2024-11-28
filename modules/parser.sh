#parse les lignes des fichier contenants les taches a éxécuter
parser() {
    task_to_execute=""
    #split the seven fields using the space delimiter
    IFS=' ' read -a fields <<< "$1"

    #check if the line is a comment
    if [[ ${fields[0]} == \#* ]]; then
        return
    fi
    #check if the line is empty
    if [[ ${fields[0]} == "" ]]; then
        return
    fi

    # Obtenir l'heure actuelle
    sec=$(date +"%-S")
    CURRENT_SEC=$((sec))
    #convertir les secondes entre 0 et 3 
    if [ $CURRENT_SEC -lt 15 ]; then
        CURRENT_SEC="0"
    elif [ $CURRENT_SEC -lt 30 ]; then
        CURRENT_SEC="1"
    elif [ $CURRENT_SEC -lt 45 ]; then
        CURRENT_SEC="2"
    else
        CURRENT_SEC="3"
    fi

    CURRENT_MIN=$(date +"%-M")
    CURRENT_HOUR=$(date +"%-H")
    CURRENT_DAY=$(date +"%-d")
    CURRENT_MONTH=$(date +"%-m")
    CURRENT_WDAY=$(date +"%-w")
    for i in "${!fields[@]}"; do
        echo "${fields[$i]}"
    done
    #check if the task is to be executed
    sec_satisfied=false
    min_satisfied=false
    hour_satisfied=false
    day_satisfied=false
    month_satisfied=false
    wday_satisfied=false

    sec=

    if [[ ${fields[0]} == "*" || ${fields[0]} == $CURRENT_SEC ]]; then
        sec_satisfied=true
    fi
    if [[ ${fields[1]} == "*" || ${fields[1]} == $CURRENT_MIN ]]; then
        min_satisfied=true
    fi
    if [[ ${fields[2]} == "*" || ${fields[2]} == $CURRENT_HOUR ]]; then
        hour_satisfied=true
    fi
    if [[ ${fields[3]} == "*" || ${fields[3]} == $CURRENT_DAY ]]; then
        day_satisfied=true
    fi
    if [[ ${fields[4]} == "*" || ${fields[4]} == $CURRENT_MONTH ]]; then
        month_satisfied=true
    fi
    if [[ ${fields[5]} == "*" || ${fields[5]} == $CURRENT_WDAY ]]; then
        wday_satisfied=true
    fi

    if $sec_satisfied && $min_satisfied && $hour_satisfied && $day_satisfied && $month_satisfied && $wday_satisfied; then
        task_to_execute=${fields[@]:6}
        echo "Task to execute: $task_to_execute"
    fi
    echo $task_to_execute
}

temporal_parser() {
    #verifier le format de l'argument, il ne doit contenir que : ou - ou ~ et un seul chiffre entre chacun des caractères
    if [[ ! $1 =~ ^([0-5]?[0-9][-:])*[0-5]?[0-9](~[0-5]?[0-9])*$ ]]; then
        echo " (temporal parser): This arg is not valid : $arg"
        exit 1
    fi
    arg_begging=$(grep -o -E '^([0-5]?[0-9][-:])*[0-5]?[0-9]' <<< "$1")
    arg_end=$(grep -o -E '(~[0-5]?[0-9])*$' <<< "$1")
    echo $arg_begging
    echo $arg_end
    
    
    if [[ $arg_end != "" ]]; then 
        IFS='~' read -a num_rem <<< "$arg_end"

    fi
   
}

make_list() {
    local values_kept=()
    local arg=$1
    if [[ $arg == \#* ]]; then
        return
    fi
    if [[ $arg == "" ]]; then
        return
    fi
    if [[ $arg == "*" ]]; then
        echo "*"
        return
    fi
    if [[ ! $arg =~ ^([0-5]?[0-9][-:])*[0-5]?[0-9]$ ]]; then
        echo "(make list) : This arg is not valid : $arg"
        exit 1
    fi
    #if arg contains both : and - don't split
    if [[ $arg == *":"* && $arg == *"-"* ]]; then
        echo "This arg is not valid : $arg it should contain either : or -"
        exit 1
    fi
    #verifier si arg contient le caractère : pour le split
    if [[ $arg == *":"* ]]; then
        IFS=':' read -a nums <<< "$arg"
        echo "lala"
    elif [[ $arg == *"-"* ]]; then
        echo "lolo"
        IFS='-' read -a range <<< "$arg"
        if [[ ${range[0]} -gt ${range[1]} ]]; then
            echo "This arg is not valid : $arg"
            exit 1
        fi
        for ((i=${range[0]}; i<=${range[1]}; i++)) do
            echo $i
            values_kept+=($i)
            echo ${values_kept[@]}
            return
        done
        
    else
        values_kept+=($arg)
        return
    fi
    if [[ ${fields[0]} == "" || ${fields[1]} == "" ]]; then
        echo "This argulemnt is not valid : $arg"
        exit 1
    fi
     for num in "${nums[@]}"; do
        if [[ $field == "" ]]; then
            continue
        fi
        if [[ " ${num_rem[@]} " =~ " $field " ]]; then 
            continue
        fi
        values_kept+=($field)
    done
}

#temporal_parser "0-59~45~54"
make_list "0-59"


