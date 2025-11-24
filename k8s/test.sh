#!/bin/bash

##############################################
# CONFIGURATION
##############################################

STEP_DELAY=${STEP_DELAY:-10}

TARIFF_BASE="http://nowlege.com/tariff-api/api/Tariff"
SIMCARD_API_BASE="http://nowlege.com/simcard-api/api/SimCard"
SIMCARD_VIEW_BASE="http://nowlege.com/simcard-view/api/SimCard"

echo "Using STEP_DELAY = $STEP_DELAY seconds"
echo ""

##############################################
# JSON BODIES
##############################################

CREATE_TARIFF_DRAFT_BODY='{
  "name": "Simple",
  "perMinuteCost": 0.25,
  "smsCost": 0.1,
  "connectionFee": 0.15,
  "perSecondBilling": 10,
  "externalIncomingCallPerSecondReward": 0.2,
  "bonusForRecharge": {
    "amount": 100,
    "value": 10,
    "expiresIn": 30
  },
  "serviceBundle": {
    "recurring": {
      "price": 300,
      "callMinutesAmount": 500,
      "smsAmount": 500,
      "expiresIn": 28
    },
    "daily": {
      "price": 15,
      "callMinutesAmount": 10,
      "smsAmount": 10,
      "expiresIn": 1
    }
  },
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}'

CREATE_SIMCARD_TEMPLATE='{
  "number": "+380666666666",
  "tariff": {
    "id": "REPLACE",
    "name": "REPLACE_NAME",
    "perMinuteCost": 0.25,
    "smsCost": 0.1,
    "connectionFee": 0.15,
    "perSecondBilling": 10,
    "externalIncomingCallPerSecondReward": 0.2,
    "bonusForRecharge": {
      "amount": 100,
      "value": 10,
      "expiresIn": 30
    },
    "serviceBundle": {
      "recurring": {
        "price": 300,
        "callMinutesAmount": 500,
        "smsAmount": 500,
        "expiresIn": 28
      },
      "daily": {
        "price": 15,
        "callMinutesAmount": 10,
        "smsAmount": 10,
        "expiresIn": 1
      }
    }
  },
  "defaultExpiration": 180,
  "amountToExtendExpiration": 10,
  "balance": 10,
  "discountForPersonalization": 10
}'

##############################################
# STEP 1: Create Tariff Draft
##############################################
echo "STEP 1: Creating Tariff Draft..."
TARIFF_DRAFT_ID=$(curl -s -X POST "$TARIFF_BASE/create-tariff-draft" \
    -H "Content-Type: application/json" \
    -d "$CREATE_TARIFF_DRAFT_BODY" | jq -r .)

if [[ "$TARIFF_DRAFT_ID" == "null" || -z "$TARIFF_DRAFT_ID" ]]; then
  echo "❌ ERROR: Failed to create tariff draft."
  exit 1
fi

echo "✔ Created TariffDraftId: $TARIFF_DRAFT_ID"
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 2: Create Tariff
##############################################
echo "STEP 2: Creating Tariff..."
TARIFF_ID=$(echo "\"$TARIFF_DRAFT_ID\"" | curl -s -X POST "$TARIFF_BASE/create-tariff" \
      -H "Content-Type: application/json" \
      -d @- | jq -r .)

if [[ "$TARIFF_ID" == "null" || -z "$TARIFF_ID" ]]; then
  echo "❌ ERROR: Failed to create tariff."
  exit 1
fi

echo "✔ Created TariffId: $TARIFF_ID"
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 3: Get Tariff
##############################################
echo "STEP 3: Fetching Tariff..."
GET_TARIFF_RESULT=$(curl -s "$TARIFF_BASE/get-tariff/$TARIFF_ID")

if [[ -z "$GET_TARIFF_RESULT" || "$GET_TARIFF_RESULT" == "null" ]]; then
  echo "❌ ERROR: Failed to fetch tariff."
  exit 1
fi

TARIFF_NAME=$(echo "$GET_TARIFF_RESULT" | jq -r '.name')

echo "✔ Tariff fetched successfully:"
echo "$GET_TARIFF_RESULT" | jq .
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 4: Create SimCard (original tariff)
##############################################
echo "STEP 4: Creating SimCard with original tariff..."
CREATE_SIMCARD_BODY=$(jq --arg tariffId "$TARIFF_ID" --arg tariffName "$TARIFF_NAME" \
    '.tariff.id = $tariffId | .tariff.name = $tariffName' <<< "$CREATE_SIMCARD_TEMPLATE")

echo "📦 CREATE_SIMCARD_BODY:"
echo "$CREATE_SIMCARD_BODY" | jq .
echo ""

SIMCARD_ID_1=$(echo "$CREATE_SIMCARD_BODY" | \
    curl -s -X POST "$SIMCARD_API_BASE/create" \
    -H "Content-Type: application/json" \
    -d @- | jq -r .)

if [[ "$SIMCARD_ID_1" == "null" || -z "$SIMCARD_ID_1" ]]; then
  echo "❌ ERROR: SimCard creation failed."
  exit 1
fi

echo "✔ Created SimCardId: $SIMCARD_ID_1"
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 5: Get SimCard
##############################################
echo "STEP 5: Fetching SimCard..."
GET_SIMCARD_1=$(curl -s "$SIMCARD_VIEW_BASE/get-simcard/$SIMCARD_ID_1")

if [[ -z "$GET_SIMCARD_1" ]]; then
  echo "❌ ERROR: Failed to fetch SimCard."
  exit 1
fi

echo "✔ SimCard fetched successfully:"
echo "$GET_SIMCARD_1" | jq .
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 6: Update Tariff (rename 'name' to 'Free')
##############################################
echo "STEP 6: Updating Tariff..."
UPDATE_TARIFF_BODY=$(echo "$GET_TARIFF_RESULT" | jq '.name = "Free"')

# Call PUT /update-tariff silently
echo "$UPDATE_TARIFF_BODY" | curl -s -X PUT "$TARIFF_BASE/update-tariff" \
    -H "Content-Type: application/json" \
    -d @-

echo "✔ Tariff updated."
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 7: Fetch Updated Tariff
##############################################
echo "STEP 7: Fetching Updated Tariff..."
UPDATED_TARIFF=$(curl -s "$TARIFF_BASE/get-tariff/$TARIFF_ID")

if [[ -z "$UPDATED_TARIFF" || "$UPDATED_TARIFF" == "null" ]]; then
  echo "❌ ERROR: Failed to fetch updated tariff."
  exit 1
fi

UPDATED_TARIFF_NAME=$(echo "$UPDATED_TARIFF" | jq -r '.name')

echo "✔ Updated Tariff fetched successfully:"
echo "$UPDATED_TARIFF" | jq .
echo ""
sleep "$STEP_DELAY"

##############################################
# STEP 8: Get first SimCard again
##############################################
echo "STEP 8: Fetching SimCard after tariff update..."
GET_SIMCARD_2=$(curl -s "$SIMCARD_VIEW_BASE/get-simcard/$SIMCARD_ID_1")

if [[ -z "$GET_SIMCARD_2" ]]; then
  echo "❌ ERROR: Failed to fetch SimCard again."
  exit 1
fi

echo "✔ SimCard fetched successfully after tariff update:"
echo "$GET_SIMCARD_2" | jq .
echo ""

echo "🎉 TEST COMPLETED SUCCESSFULLY!"
