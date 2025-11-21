#!/bin/bash

##############################################
# CONFIGURATION
##############################################

# Delay between steps (default 10 seconds)
STEP_DELAY=${STEP_DELAY:-10}

# Base URLs
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
# STEP 3: Create SimCard
##############################################
echo "STEP 3: Creating SimCard..."

# Build request body with tariffId included
CREATE_SIMCARD_BODY=$(jq --arg tariffId "$TARIFF_ID" \
    '.tariff.id = $tariffId' <<< "$CREATE_SIMCARD_TEMPLATE")

# ⬅⬅⬅ PRINT THE FINAL BODY BEFORE SENDING
echo "📦 CREATE_SIMCARD_BODY:"
echo "$CREATE_SIMCARD_BODY" | jq .
echo ""

# Execute API call
SIMCARD_ID=$(echo "$CREATE_SIMCARD_BODY" | \
    curl -s -X POST "$SIMCARD_API_BASE/create" \
    -H "Content-Type: application/json" \
    -d @- | jq -r .)

if [[ "$SIMCARD_ID" == "null" || -z "$SIMCARD_ID" ]]; then
  echo "❌ ERROR: SimCard creation failed."
  exit 1
fi

echo "✔ Created SimCardId: $SIMCARD_ID"
echo ""
sleep "$STEP_DELAY"



##############################################
# STEP 4: Get SimCard by returned ID
##############################################
echo "STEP 4: Fetching SimCard..."
GET_RESULT=$(curl -s "$SIMCARD_VIEW_BASE/get-simcard/$SIMCARD_ID")

if [[ -z "$GET_RESULT" ]]; then
  echo "❌ ERROR: Failed to fetch SimCard."
  exit 1
fi

echo "✔ SimCard fetched successfully:"
echo "$GET_RESULT" | jq .
echo ""

echo "🎉 TEST COMPLETED SUCCESSFULLY!"
