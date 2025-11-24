// mongo-init/init.js

db = db.getSiblingDB('SimCard'); // create/use the database

db.createCollection('SimCards');
db.createCollection('Payments');
db.createCollection('Expenses');
db.createCollection('BalanceRecords');

db.SimCards.insertOne({
  SimCardId: '11111111-1111-1111-1111-111111111111',
  Expires: ISODate('2026-11-01T00:00:00.000Z'),
  Status: 1,
  Number: '+380666666666',
  Tariff: {
      TariffId: '11111111-1111-1111-1111-111111111110',
      Name: 'Simple',
      PerMinuteCost: NumberDecimal('0.1'),
      SmsCost: NumberDecimal('0.2'),
      ConnectionFee: NumberDecimal('0.3'),
      PerSecondBilling: 10,
      ExternalIncomingCallPerSecondReward: null,
      BonusForRecharge: null,
      ServiceBundle: null
  },
  DefaultExpiration: 180,
  AmountToExtendExpiration: NumberDecimal('10'),
  Balance: NumberDecimal('20'),
  DiscountForPersonalization: null,
  AbonentPersonalInfo: null,
  ActiveServiceBundlePackage: null
});

db.Payments.insertOne({
  RecordId: '11111111-1111-1111-1111-111111111112',
  SimCardId: '11111111-1111-1111-1111-111111111111',
  Amount: NumberDecimal('20'),
  Date: new Date(),
  Reason: 0,
  Details: {
      _t: 'BalanceIncreasedInitDetails'
  }
});

db.Expenses.insertOne({
  RecordId: '11111111-1111-1111-1111-111111111113',
  SimCardId: '11111111-1111-1111-1111-111111111111',
  Amount: NumberDecimal('0.2'),
  Date: new Date(),
  Reason: 1,
  Tariff: {
      TariffId: '11111111-1111-1111-1111-111111111110',
      Name: 'Simple',
      PerMinuteCost: NumberDecimal('0.1'),
      SmsCost: NumberDecimal('0.2'),
      ConnectionFee: NumberDecimal('0.3'),
      PerSecondBilling: 10,
      ExternalIncomingCallPerSecondReward: null,
      BonusForRecharge: null,
      ServiceBundle: null
  },
  BonusAccountAmount: NumberDecimal('0'),
  MainAccountAmount: NumberDecimal('0.2'),
  Details: {
      _t: 'BalanceDecreasedSmsDetails',
      Number: '+380999999999'
  }
});

db.BalanceRecords.insertOne({
  RecordId: '11111111-1111-1111-1111-111111111112',
  SimCardId: '11111111-1111-1111-1111-111111111111',
  Amount: NumberDecimal('20'),
  Date: new Date(),
  Reason: 0,
  Details: {
      _t: 'BalanceIncreasedInitDetails'
  }
});

db.BalanceRecords.insertOne({
  RecordId: '11111111-1111-1111-1111-111111111113',
  SimCardId: '11111111-1111-1111-1111-111111111111',
  Amount: NumberDecimal('0.2'),
  Date: new Date(),
  Reason: 1,
  Tariff: {
      TariffId: '11111111-1111-1111-1111-111111111110',
      Name: 'Simple',
      PerMinuteCost: NumberDecimal('0.1'),
      SmsCost: NumberDecimal('0.2'),
      ConnectionFee: NumberDecimal('0.3'),
      PerSecondBilling: 10,
      ExternalIncomingCallPerSecondReward: null,
      BonusForRecharge: null,
      ServiceBundle: null
  },
  BonusAccountAmount: NumberDecimal('0'),
  MainAccountAmount: NumberDecimal('0.2'),
  Details: {
      _t: 'BalanceDecreasedSmsDetails',
      Number: '+380999999999'
  }
});
