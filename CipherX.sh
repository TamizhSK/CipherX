#! /bin/bash

CLOCK_VALUE="0"

# This generates pseudo random values that are added to each byte
setClock() {
  MESSAGE_LENGTH="$1"

  CLOCK_INTERVAL=$(echo "$MESSAGE_LENGTH"*4 | bc -l)
  MAX_CLOCK_VALUE=$(echo "$MESSAGE_LENGTH"*25 | bc -l)

  CLOCK_VALUE=$(($CLOCK_INTERVAL + $CLOCK_VALUE))

  if [[ $CLOCK_VALUE -gt $MAX_CLOCK_VALUE ]]; then
    CLOCK_VALUE=$(($CLOCK_VALUE - $MAX_CLOCK_VALUE))
  fi
}

encrypt() {
  TO_ENCRYPT="$1"

  ENCRYPTED_MESSAGE=""

  for (( i=0; i<"${#TO_ENCRYPT}"; i++ )); do
    setClock "${#TO_ENCRYPT}"

    CHAR="${TO_ENCRYPT:$i:1}"
    LC_CTYPE=C BYTE=$(printf "%d" "'$CHAR")

    ENCRYPTED_MESSAGE+="$(($BYTE + $CLOCK_VALUE)) "

  done

  RESULT=$(echo -n "$ENCRYPTED_MESSAGE" | base64 -w 0)
  echo "$RESULT"
}

decrypt() {
  TO_DECRYPT=$(echo -n "$1" | base64 --decode)

  DECRYPTED_MESSAGE=""

  for OBFUSCATED_BYTE in $TO_DECRYPT; do
    setClock "$(echo "$TO_DECRYPT" | wc -w)"

    BYTE="$(($OBFUSCATED_BYTE - $CLOCK_VALUE))"

    printf "\x$(printf %x $BYTE)"
  done
}

if [[ "$1" == "--decode" ]]; then
  decrypt "$2"
else
  encrypt "'$1'"
fi
