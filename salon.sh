#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  # If a message is passed to the function (like an error), display it
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"

  # Get and display the services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    # Use sed to trim any accidental whitespace 
    SERVICE_NAME=$(echo $NAME | sed -E 's/^ *| *$//g') 
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Prompt for input immediately after the list
  read SERVICE_ID_SELECTED

#check if the service exists
HAVE_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

#if not found
if [[ -z $HAVE_SERVICE ]]
then
MAIN_MENU "I could not find that service. What would you like today?"
else
SERVICE_NAME=$(echo $HAVE_SERVICE | sed -E 's/^ *| *$//g')
#prompt for phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

#check if customer name exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

#if not found
 if [[ -z $CUSTOMER_NAME ]]
 then
 #get new customer name
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME

#insert new customer into the database
INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

else
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
 fi

#fetch customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")

# prompt for service time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

#insert appointment into database
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

#confirmation of appointment
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

fi

}

# Call the function to start
MAIN_MENU
