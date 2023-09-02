#!/bin/bash
# psql query variable
PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"

# menu
echo -e "\n~~~~~ MY SALON ~~~~~\n"

PRINT_SERVICES() {
     # get and print all available services
    AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id ; ")

    # print services
    echo "$AVAILABLE_SERVICES" | while read ID BAR SERVICE 
    do 
        echo "$ID) $SERVICE"
    done 
}

CREATE_APPOINTMENT() {
    SERVICE_ID_SELECTED=$1

    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED ; ")    

    # filter service name
    SERVICE_NAME=$(echo $SERVICE_NAME | sed -r 's/ //')

    # get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE            

    # get custome name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';") 
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/ //')

    # if not exists
    if [[ -z $CUSTOMER_NAME ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"  
        read CUSTOMER_NAME

        # insert customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ;")                
    fi

    # get time 
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
            
    # create appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ;")

    # print message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

MAIN_MENU() {
    # check wrong inputs 
    if [[ $1 ]]
    then 
        echo -e "\n$1"
    else 
        # welcome message
        echo -e "\nWelcome to My Salon, how can I help you?"
    fi

    #print all services 
    PRINT_SERVICES

    # read service 
    read SERVICE_ID_SELECTED

    # check answer input 
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_ID_SELECTED  ]]
    then 
        MAIN_MENU "I could not find that service. What would you like today?"
    else      
        CREATE_APPOINTMENT $SERVICE_ID_SELECTED
    fi 
}

MAIN_MENU