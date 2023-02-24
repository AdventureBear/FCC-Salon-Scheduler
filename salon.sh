#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Welcome to the Salon ~~~~"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #show services - display a numbered list of services
  ALL_SERVICES=$($PSQL "SELECT service_id, name FROM SERVICES ORDER BY service_id")
  echo "$ALL_SERVICES" | while read SERVICE_ID BAR NAME
  do
	  echo -e "$SERVICE_ID) $NAME"
  done

  #ask for input
  read SERVICE_ID_SELECTED

  #check for valid input
	  #check if a number
  #  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  #  then
      # send to main menu
  #    MAIN_MENU "Please enter a number."
  #  else
		
     #check if existing service
	   SERVICE_NAME=$($PSQL "Select name from services where service_id=$SERVICE_ID_SELECTED")
	    if [[ -z  $SERVICE_NAME ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
         SERVICE_MENU
	    fi
  #  fi

 
}

SERVICE_MENU() {
 
  #SHEDULE SERVICE
  #enter phone number
  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE

  #check for existing customer
  CUSTOMER_ID=$($PSQL "Select customer_id from customers where phone='$CUSTOMER_PHONE'")
	#if not customer
	if [[ -z $CUSTOMER_ID ]]
	then
		#get name
		echo  -e "\nPlease enter your name"
		read CUSTOMER_NAME
		#add customer to customers table
		INSERT_CUSTOMER=$($PSQL "insert into customers (name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
		#get new customer ID
		CUSTOMER_ID=$($PSQL "Select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  else
    #get customer name
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  
  fi

#get time desired
echo -e "\nWhat time would you like to schedule?"
read SERVICE_TIME

#add to appointments
	#add customer ID, service id, time to appointments
	NEW_APPOINTMENT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
	echo  -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  if [[ $NEW_APPOINTMENT ]]
  then
    #exit
    echo "Have a good day"
    EXIT
  else
    echo "Could not make an appointment"
    MAIN MENU "How can I help you?"
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU "Welcome to the Salon, how may I help you?"
